"""WinRM client to trigger UIA PowerShell actions on a Windows host.

This example intentionally avoids installing rpaframework on Windows.
Instead it:
- Uploads a PowerShell UIA script (`uia_run.ps1`) + an input JSON payload
- Creates a one-shot scheduled task that runs PowerShell with -STA in the
  interactive session (requires credentials)
- Runs the task, waits, and reads an output JSON file

Limitations:
- UI Automation needs an interactive desktop session.
- WinRM itself runs in a service session and generally cannot drive desktop UI.
  The scheduled task is the "session bridge".

Usage:
  python winrm_client.py \
    --host 10.0.0.42 --username 'DOMAIN\\user' --password '***' \
    --run-as-user 'DOMAIN\\user' --run-as-password '***' \
    --action sendKeysToWindow --window-name Notepad --keys 'Hello{ENTER}'

Requires on your machine:
  pip install pywinrm
"""

from __future__ import annotations

import argparse
import base64
import json
import sys
import time
from datetime import datetime
from pathlib import Path
from dataclasses import dataclass

import winrm  # type: ignore


@dataclass
class Args:
    host: str
    username: str
    password: str
    run_as_user: str
    run_as_password: str
    action: str
    window_name: str | None
    keys: str | None
    folder_path: str | None
    subject_contains: str | None
    transport: str
    port: int
    use_ssl: bool


def parse_args() -> Args:
    p = argparse.ArgumentParser()
    p.add_argument("--host", required=True)
    p.add_argument("--username", required=True, help="WinRM username")
    p.add_argument("--password", required=True, help="WinRM password")

    # Creds used by the scheduled task to run in the user session.
    p.add_argument("--run-as-user", required=True)
    p.add_argument("--run-as-password", required=True)

    p.add_argument(
        "--action",
        required=True,
        choices=["listTopWindows", "sendKeysToWindow", "openOutlookEmail"],
    )
    p.add_argument("--window-name")
    p.add_argument("--keys")
    p.add_argument("--folder-path")
    p.add_argument("--subject-contains")

    p.add_argument("--transport", default="ntlm", choices=["ntlm", "kerberos", "basic"]) 
    p.add_argument("--port", type=int, default=5985)
    p.add_argument("--use-ssl", action="store_true")

    ns = p.parse_args()
    return Args(
        host=ns.host,
        username=ns.username,
        password=ns.password,
        run_as_user=ns.run_as_user,
        run_as_password=ns.run_as_password,
        action=ns.action,
        window_name=ns.window_name,
        keys=ns.keys,
        folder_path=ns.folder_path,
        subject_contains=ns.subject_contains,
        transport=ns.transport,
        port=ns.port,
        use_ssl=bool(ns.use_ssl),
    )


def ps_quote(s: str) -> str:
    # Single-quote and escape single quotes for PowerShell.
    return "'" + s.replace("'", "''") + "'"


def run_ps(session: winrm.Session, script: str) -> str:
    r = session.run_ps(script)
    if r.status_code != 0:
        raise RuntimeError(f"PowerShell failed ({r.status_code}): {r.std_err.decode(errors='ignore')}")
    return r.std_out.decode(errors="ignore")


def tlog(message: str) -> None:
    """Timestamped log to stderr (keeps stdout reserved for JSON results)."""
    ts = datetime.now().astimezone().isoformat(timespec="milliseconds")
    print(f"[{ts}] {message}", file=sys.stderr, flush=True)


def upload_bytes_b64_chunked(
    session: winrm.Session,
    remote_path: str,
    data: bytes,
    *,
    chunk_size: int = 2000,
) -> None:
    """Upload bytes to a remote path using multiple small PowerShell calls.

    This avoids WinRM/PowerShell command-line length limits that occur when
    embedding large Base64 strings in a single `run_ps` call.
    """

    b64 = base64.b64encode(data).decode("ascii")

    # Ensure parent dir exists and remove existing file.
    tlog(f"Uploading to {remote_path} ({len(data)} bytes)")
    run_ps(
        session,
        f"$p={ps_quote(remote_path)}; "
        "New-Item -ItemType Directory -Force -Path (Split-Path -Parent $p) | Out-Null; "
        "if (Test-Path -LiteralPath $p) { Remove-Item -Force -LiteralPath $p }",
    )

    # Append chunks as bytes.
    for i in range(0, len(b64), chunk_size):
        chunk = b64[i : i + chunk_size]
        run_ps(
            session,
            "$ErrorActionPreference='Stop'; "
            f"$p={ps_quote(remote_path)}; "
            f"$c={ps_quote(chunk)}; "
            "$b=[Convert]::FromBase64String($c); "
            "$fs=[IO.File]::Open($p,[IO.FileMode]::Append,[IO.FileAccess]::Write,[IO.FileShare]::Read); "
            "$fs.Write($b,0,$b.Length); $fs.Close()",
        )


def run_action(args: Args) -> str:
    """Execute the requested UIA action and return output JSON as a string."""

    tlog(f"Action start: {args.action}")

    scheme = "https" if args.use_ssl else "http"
    endpoint = f"{scheme}://{args.host}:{args.port}/wsman"

    session = winrm.Session(
        target=endpoint,
        auth=(args.username, args.password),
        transport=args.transport,
        server_cert_validation="ignore" if args.use_ssl else "validate",
    )

    # Remote paths
    # Use single backslashes to avoid confusing PowerShell/schtasks quoting.
    base = r"C:\Windows\Temp\winrm-uia"
    ps_path = base + r"\uia_run.ps1"
    runner_path = base + r"\run_task.ps1"
    in_path = base + r"\input.json"
    out_path = base + r"\output.json"
    log_path = base + r"\task.log"

    local_ps = Path(__file__).resolve().parent / "uia_run.ps1"
    ps_bytes = local_ps.read_bytes()

    payload = {"action": args.action}
    if args.window_name:
        payload["windowName"] = args.window_name
    if args.keys:
        payload["keys"] = args.keys
    if args.folder_path:
        payload["folderPath"] = args.folder_path
    if args.subject_contains:
        payload["subjectContains"] = args.subject_contains

    task_name = "WinRM-UIA-OneShot"

    # 1) Prepare files
    # Upload the UIA runner script in small chunks to avoid command length limits.
    upload_bytes_b64_chunked(session, ps_path, ps_bytes)

    # Input JSON is small; write it directly.
    tlog(f"Writing input payload to {in_path}")
    input_json = json.dumps(payload)
    run_ps(
        session,
        "$ErrorActionPreference='Stop'; "
        f"$base={ps_quote(base)}; "
        "New-Item -ItemType Directory -Force -Path $base | Out-Null; "
        f"Set-Content -LiteralPath {ps_quote(in_path)} -Value {ps_quote(input_json)} -Encoding UTF8; "
        f"if (Test-Path -LiteralPath {ps_quote(out_path)}) {{ Remove-Item -Force -LiteralPath {ps_quote(out_path)} }}; "
        f"if (Test-Path -LiteralPath {ps_quote(log_path)}) {{ Remove-Item -Force -LiteralPath {ps_quote(log_path)} }}",
    )

    # Create a short wrapper script to keep schtasks /TR under 261 chars.
    tlog(f"Writing task wrapper to {runner_path}")
    runner_script = (
        "$ErrorActionPreference='Stop'\n"
        f"$logPath = {ps_quote(log_path)}\n"
        f"$outPath = {ps_quote(out_path)}\n"
        f"$psPath = {ps_quote(ps_path)}\n"
        f"$inPath = {ps_quote(in_path)}\n"
        "('=== START ' + (Get-Date).ToString('s')) | Out-File -LiteralPath $logPath -Encoding UTF8\n"
        "try {\n"
        "  & $psPath -InputJsonPath $inPath -OutputJsonPath $outPath 2>&1 | Out-File -LiteralPath $logPath -Append -Encoding UTF8\n"
        "  $code = $LASTEXITCODE\n"
        "  ('=== EXIT ' + $code + ' ' + (Get-Date).ToString('s')) | Out-File -LiteralPath $logPath -Append -Encoding UTF8\n"
        "  if (($code -ne 0) -and (-not (Test-Path -LiteralPath $outPath))) {\n"
        "    $obj = @{ ok = $false; action = $null; error = ('uia_run.ps1 exited with ' + $code); data = $null }\n"
        "    ($obj | ConvertTo-Json -Depth 6) | Set-Content -LiteralPath $outPath -Encoding UTF8\n"
        "  }\n"
        "  exit $code\n"
        "} catch {\n"
        "  ('=== ERROR ' + (Get-Date).ToString('s')) | Out-File -LiteralPath $logPath -Append -Encoding UTF8\n"
        "  ($_ | Out-String) | Out-File -LiteralPath $logPath -Append -Encoding UTF8\n"
        "  if (-not (Test-Path -LiteralPath $outPath)) {\n"
        "    $err = $_.Exception.Message\n"
        "    $obj = @{ ok = $false; action = $null; error = $err; data = $null }\n"
        "    ($obj | ConvertTo-Json -Depth 6) | Set-Content -LiteralPath $outPath -Encoding UTF8\n"
        "  }\n"
        "  exit 1\n"
        "}\n"
    )
    run_ps(
        session,
        "$ErrorActionPreference='Stop'; "
        f"Set-Content -LiteralPath {ps_quote(runner_path)} -Value {ps_quote(runner_script)} -Encoding UTF8",
    )

    # 2) Create and run a scheduled task
    # IMPORTANT: For UI Automation, the process must run in the interactive user session.
    # Using schtasks.exe with /IT forces "run only when user is logged on".
    create_task = f"""
$ErrorActionPreference = 'Stop'
$taskName = {ps_quote(task_name)}
$runAsUser = {ps_quote(args.run_as_user)}
$runAsPass = {ps_quote(args.run_as_password)}

$schtasks = Join-Path $env:WINDIR 'System32\\schtasks.exe'

# We run the task immediately via schtasks /Run, so the scheduled time/date is
# only required to satisfy schtasks /Create validation.
$st = '00:00'
$sd = (Get-Date).ToString('MM/dd/yyyy')

# /TR must be a single argument and cannot exceed 261 chars.
# Use a wrapper script file to keep it short.
$psExe = Join-Path $env:WINDIR 'System32\\WindowsPowerShell\\v1.0\\powershell.exe'
$runnerPath = {ps_quote(runner_path)}
$tr = "$psExe -NoProfile -ExecutionPolicy Bypass -STA -File $runnerPath"

try {{ & $schtasks /Delete /TN $taskName /F *> $null }} catch {{}}

& $schtasks /Create /F /TN $taskName /SC ONCE /ST $st /SD $sd /RL HIGHEST /RU $runAsUser /RP $runAsPass /IT /TR $tr | Out-Null

& $schtasks /Run /TN $taskName | Out-Null
"""
    tlog("Creating and running scheduled task")
    run_ps(session, create_task)

    # 3) Wait for output
    try:
        # Outlook startup / profile initialization can easily exceed 30 seconds.
        wait_seconds = 180 if args.action == "openOutlookEmail" else 30
        deadline = time.time() + wait_seconds
        while time.time() < deadline:
            check = f"""
if (Test-Path {ps_quote(out_path)}) {{
  Get-Content -LiteralPath {ps_quote(out_path)} -Raw -Encoding UTF8
}}
"""
            out = run_ps(session, check).strip()
            if out:
                tlog(f"Received output from {out_path}")
                return out
            time.sleep(0.25)

        diag = run_ps(
            session,
            f"""
$ErrorActionPreference = 'Continue'
$base = {ps_quote(base)}
$outPath = {ps_quote(out_path)}
$logPath = {ps_quote(log_path)}
$taskName = {ps_quote(task_name)}
$schtasks = Join-Path $env:WINDIR 'System32\\schtasks.exe'

"=== DIAG: outPath exists ==="
if (Test-Path -LiteralPath $outPath) {{
  "YES"
  try {{ Get-Item -LiteralPath $outPath | Format-List * | Out-String }} catch {{}}
}} else {{
  "NO"
}}

"=== DIAG: base dir listing ==="
try {{ Get-ChildItem -LiteralPath $base -Force | Select-Object Name,Length,LastWriteTime | Format-Table -AutoSize | Out-String }} catch {{ "(could not list base dir)" }}

"=== DIAG: task.log (last 200 lines) ==="
if (Test-Path -LiteralPath $logPath) {{
    try {{ Get-Content -LiteralPath $logPath -Tail 200 -Encoding UTF8 | Out-String }} catch {{ "(could not read task.log)" }}
}} else {{
    "(no task.log)"
}}

"=== DIAG: schtasks query ==="
try {{ & $schtasks /Query /TN $taskName /V /FO LIST 2>&1 | Out-String }} catch {{ "(schtasks query failed)" }}
""",
        )
        raise TimeoutError(f"Timed out waiting for output.json after {wait_seconds}s\n{diag}")
    finally:
        tlog("Cleaning up scheduled task")
        cleanup = f"""
    $taskName = {ps_quote(task_name)}
    $schtasks = Join-Path $env:WINDIR 'System32\\schtasks.exe'
    try {{ & $schtasks /End /TN $taskName *> $null }} catch {{}}
    try {{ & $schtasks /Delete /TN $taskName /F *> $null }} catch {{}}
    """
        run_ps(session, cleanup)

    # Unreachable, but keep type-checkers happy.
    tlog("Action end")
    return ""


def main() -> None:
    args = parse_args()

    print(run_action(args))


if __name__ == "__main__":
    main()
