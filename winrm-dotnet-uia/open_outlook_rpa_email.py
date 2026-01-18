"""One-shot runner: open Outlook and open an email from a folder.

This is a convenience wrapper around `winrm_client.py` so you can do the full flow
(open Outlook -> switch to folder -> open an email) with a single command.

Usage:
  python open_outlook_rpa_email.py

Optional env vars (loaded from a local `.env` next to this file if present):
  WINRM_HOST, WINRM_USERNAME, WINRM_PASSWORD,
  WINRM_RUN_AS_USER, WINRM_RUN_AS_PASSWORD,
  WINRM_TRANSPORT (ntlm|kerberos|basic), WINRM_PORT, WINRM_USE_SSL (true/false)

  OUTLOOK_FOLDER_PATH (default: Inbox\\RPA)
  OUTLOOK_SUBJECT_CONTAINS (optional)
"""

from __future__ import annotations

import os
from getpass import getpass
from pathlib import Path

from winrm_client import Args, run_action


def load_dotenv(path: Path) -> None:
    """Minimal .env loader (no external dependency)."""
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
        value = value.strip().strip('"').strip("'")
        if key and key not in os.environ:
            os.environ[key] = value


def env_bool(name: str, default: bool = False) -> bool:
    val = os.getenv(name)
    if val is None:
        return default
    return val.strip().lower() in {"1", "true", "yes", "y", "on"}


def main() -> None:
    load_dotenv(Path(__file__).resolve().parent / ".env")

    host = os.getenv("WINRM_HOST")
    username = os.getenv("WINRM_USERNAME")
    if not host or not username:
        raise SystemExit("WINRM_HOST and WINRM_USERNAME must be set (e.g. in .env)")

    password = os.getenv("WINRM_PASSWORD") or getpass("WinRM password: ")

    run_as_user = os.getenv("WINRM_RUN_AS_USER") or username
    run_as_password = os.getenv("WINRM_RUN_AS_PASSWORD") or password

    folder_path = os.getenv("OUTLOOK_FOLDER_PATH", r"Inbox\\RPA")
    subject_contains = os.getenv("OUTLOOK_SUBJECT_CONTAINS")

    transport = os.getenv("WINRM_TRANSPORT", "ntlm")
    port = int(os.getenv("WINRM_PORT", "5985"))
    use_ssl = env_bool("WINRM_USE_SSL", False)

    args = Args(
        host=host,
        username=username,
        password=password,
        run_as_user=run_as_user,
        run_as_password=run_as_password,
        action="openOutlookEmail",
        window_name=None,
        keys=None,
        folder_path=folder_path,
        subject_contains=subject_contains,
        transport=transport,
        port=port,
        use_ssl=use_ssl,
    )

    print(run_action(args))


if __name__ == "__main__":
    main()
