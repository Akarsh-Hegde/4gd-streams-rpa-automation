# WinRM + PowerShell + .NET UI Automation (UIA)

This example shows how to **trigger Windows UI Automation** from a remote machine **without installing `rpaframework` on the Windows host**.

It uses:

- WinRM (PowerShell Remoting) to connect
- A PowerShell script that uses built-in .NET UIA assemblies (`UIAutomationClient`, `UIAutomationTypes`)
- A scheduled task to run the UIA script in the **interactive user session** (needed for desktop UI automation)

## Important limitations

- WinRM sessions run in a **service session** and usually cannot access the interactive desktop UI.
- UI Automation generally requires an **unlocked interactive desktop session**.
- Therefore, a **session bridge** is needed. This example uses Task Scheduler.

If you cannot run a scheduled task as the interactive user (credentials policy, UAC, no user logged on), this approach will not work reliably.

## Files

- `uia_run.ps1`: performs UIA actions based on an input JSON file and writes JSON output.
- `winrm_client.py`: uploads files, creates a one-shot scheduled task, runs it, reads output.

## Windows prerequisites

- WinRM enabled and reachable (5985 HTTP / 5986 HTTPS)
- Target user is allowed to create/run scheduled tasks
- Target user is logged on with an active desktop session (RDP is fine)

## Local prerequisites

- Python 3.9+
- `pip install pywinrm`

## Example: send keys to Notepad

1. On Windows, ensure Notepad is open in the interactive session.

2. On your local machine, run:

```bash
cd examples/winrm-dotnet-uia
pip install pywinrm

# Nicer runner (prompts for passwords):
python run.py send-keys \
  --host <windows-ip> \
  --username '<DOMAIN\\user>' \
  --run-as-user '<DOMAIN\\user>' \
  --window-name Notepad \
  --keys 'Hello{ENTER}'

# Original direct command (if you prefer explicit args):
python winrm_client.py \
  --host <windows-ip> \
  --username '<DOMAIN\\user>' --password '***' \
  --run-as-user '<DOMAIN\\user>' --run-as-password '***' \
  --action sendKeysToWindow --window-name Notepad --keys 'Hello{ENTER}'
```

The script prints a JSON response from the Windows side.

## Supported actions

- `listTopWindows`
- `sendKeysToWindow` (finds top-level window by name substring, focuses it, sends `SendKeys`)

## Security notes

- Prefer WinRM over HTTPS (5986) and restrict access by firewall.
- Avoid embedding credentials in scripts; use a secret manager or CI secret store.
