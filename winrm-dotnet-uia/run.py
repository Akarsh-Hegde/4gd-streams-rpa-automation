"""Friendly runner for the WinRM + .NET UIA example.

This wraps `winrm_client.py` with:
- shorter subcommands
- env var defaults
- interactive password prompts (so you don't paste secrets into your shell history)

Examples:
  # List top-level windows
  python run.py list-windows --host 10.0.0.42 --username 'DOMAIN\\user'

  # Send keys to Notepad (prompts for passwords)
  python run.py send-keys --host 10.0.0.42 --username 'DOMAIN\\user' --run-as-user 'DOMAIN\\user' \
    --window-name Notepad --keys 'Hello{ENTER}'

Env vars (optional):
  WINRM_HOST, WINRM_USERNAME, WINRM_PASSWORD,
  WINRM_RUN_AS_USER, WINRM_RUN_AS_PASSWORD,
  WINRM_TRANSPORT (ntlm|kerberos|basic), WINRM_PORT, WINRM_USE_SSL (true/false)
"""

from __future__ import annotations

import argparse
import os
from getpass import getpass
from pathlib import Path

from winrm_client import Args, run_action


def load_dotenv(path: Path) -> None:
    """Minimal .env loader (no external dependency).

    Loads KEY=VALUE lines and sets os.environ only if the key is not already set.
    """
    if not path.exists():
        return

    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if line.lower().startswith("export "):
            line = line[7:].strip()
        if "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip().strip("\"").strip("'")
        if key and key not in os.environ:
            os.environ[key] = value


def env_bool(name: str, default: bool = False) -> bool:
    val = os.getenv(name)
    if val is None:
        return default
    return val.strip().lower() in {"1", "true", "yes", "y", "on"}


def parse() -> tuple[str, Args]:
    # Allow users to keep WINRM_* defaults in a local `.env` file.
    load_dotenv(Path(__file__).resolve().parent / ".env")

    p = argparse.ArgumentParser()

    sub = p.add_subparsers(dest="cmd", required=True)

    def add_common(sp: argparse.ArgumentParser) -> None:
        sp.add_argument("--host", default=os.getenv("WINRM_HOST"), required=os.getenv("WINRM_HOST") is None)
        sp.add_argument("--username", default=os.getenv("WINRM_USERNAME"), required=os.getenv("WINRM_USERNAME") is None)
        sp.add_argument("--password", default=os.getenv("WINRM_PASSWORD"))

        sp.add_argument("--run-as-user", default=os.getenv("WINRM_RUN_AS_USER"))
        sp.add_argument("--run-as-password", default=os.getenv("WINRM_RUN_AS_PASSWORD"))

        sp.add_argument("--transport", default=os.getenv("WINRM_TRANSPORT", "ntlm"), choices=["ntlm", "kerberos", "basic"])
        sp.add_argument("--port", type=int, default=int(os.getenv("WINRM_PORT", "5985")))
        sp.add_argument("--use-ssl", action="store_true", default=env_bool("WINRM_USE_SSL", False))

    sp_list = sub.add_parser("list-windows", help="List top-level window titles")
    add_common(sp_list)

    sp_send = sub.add_parser("send-keys", help="Focus window and SendKeys")
    add_common(sp_send)
    sp_send.add_argument("--window-name", required=True)
    sp_send.add_argument("--keys", required=True)

    sp_outlook = sub.add_parser("open-outlook-email", help="Open Outlook and display an email from a folder")
    add_common(sp_outlook)
    sp_outlook.add_argument(
        "--folder-path",
        default=os.getenv("OUTLOOK_FOLDER_PATH", "Inbox\\RPA"),
        help="Outlook folder path (currently supports Inbox\\...)",
    )
    sp_outlook.add_argument(
        "--subject-contains",
        default=os.getenv("OUTLOOK_SUBJECT_CONTAINS"),
        help="Optional substring filter for email subject",
    )

    ns = p.parse_args()

    password = ns.password or getpass("WinRM password: ")

    # For UIA we normally need the scheduled task to run as an interactive user.
    run_as_user = ns.run_as_user or ns.username
    run_as_password = ns.run_as_password or password

    if ns.cmd == "list-windows":
        action = "listTopWindows"
    elif ns.cmd == "send-keys":
        action = "sendKeysToWindow"
    else:
        action = "openOutlookEmail"

    args = Args(
        host=ns.host,
        username=ns.username,
        password=password,
        run_as_user=run_as_user,
        run_as_password=run_as_password,
        action=action,
        window_name=getattr(ns, "window_name", None),
        keys=getattr(ns, "keys", None),
        folder_path=getattr(ns, "folder_path", None),
        subject_contains=getattr(ns, "subject_contains", None),
        transport=ns.transport,
        port=ns.port,
        use_ssl=bool(ns.use_ssl),
    )

    return ns.cmd, args


def main() -> None:
    _, args = parse()
    print(run_action(args))


if __name__ == "__main__":
    main()
