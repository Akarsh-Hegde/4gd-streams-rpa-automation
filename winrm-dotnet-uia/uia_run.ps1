<#
UI Automation (UIA) runner using built-in .NET assemblies.

This script is designed to be executed ON the Windows machine, ideally in the
interactive user session, and can be triggered remotely (e.g., via WinRM).

It reads a JSON input file describing an action, performs the UI operation, and
writes a JSON output file with the result.

Why file-based I/O?
- When you trigger UIA through WinRM, the actual UIA work typically must run in
  the interactive desktop session (not the WinRM service session).
- Scheduled tasks are a common way to jump into the user session; files are an
  easy interchange format.

Example input JSON:
{
  "action": "sendKeysToWindow",
  "windowName": "Notepad",
  "keys": "Hello{ENTER}"
}
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$InputJsonPath,

  [Parameter(Mandatory = $true)]
  [string]$OutputJsonPath,

  [int]$TimeoutSeconds = 15
)

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName UIAutomationClient | Out-Null
Add-Type -AssemblyName UIAutomationTypes  | Out-Null
Add-Type -AssemblyName System.Windows.Forms | Out-Null

function Write-ResultJson {
  param(
    [Parameter(Mandatory=$true)][hashtable]$Obj,
    [Parameter(Mandatory=$true)][string]$Path
  )
  $dir = Split-Path -Parent $Path
  if ($dir -and -not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }
  ($Obj | ConvertTo-Json -Depth 6) | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Find-TopLevelWindowByName {
  param(
    [Parameter(Mandatory=$true)][string]$Name,
    [int]$TimeoutSeconds = 10
  )

  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  $root = [System.Windows.Automation.AutomationElement]::RootElement
  $cond = New-Object System.Windows.Automation.PropertyCondition(
    [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
    [System.Windows.Automation.ControlType]::Window
  )

  while ((Get-Date) -lt $deadline) {
    $windows = $root.FindAll([System.Windows.Automation.TreeScope]::Children, $cond)
    foreach ($w in $windows) {
      try {
        $n = $w.Current.Name
        if ($n -and $n -like "*$Name*") {
          return $w
        }
      } catch {
        # Ignore transient UIA exceptions.
      }
    }
    Start-Sleep -Milliseconds 250
  }

  return $null
}

function Focus-Window {
  param([Parameter(Mandatory=$true)]$Window)
  $pattern = $null
  if ($Window.TryGetCurrentPattern([System.Windows.Automation.WindowPattern]::Pattern, [ref]$pattern)) {
    # Best-effort. Some windows don't support all operations.
  }

  try {
    # Setting focus is typically enough.
    $Window.SetFocus()
  } catch {
    # Fallback: try using a clickable point.
    $pt = $Window.GetClickablePoint()
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point([int]$pt.X, [int]$pt.Y)
  }
}

function Find-TopLevelWindowsByProcessId {
  param(
    [Parameter(Mandatory=$true)][int]$ProcessId
  )

  $root = [System.Windows.Automation.AutomationElement]::RootElement
  $condWin = New-Object System.Windows.Automation.PropertyCondition(
    [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
    [System.Windows.Automation.ControlType]::Window
  )

  $windows = $root.FindAll([System.Windows.Automation.TreeScope]::Children, $condWin)
  $matches = @()
  foreach ($w in $windows) {
    try {
      $pid = [int]$w.GetCurrentPropertyValue([System.Windows.Automation.AutomationElement]::ProcessIdProperty)
      if ($pid -eq $ProcessId) { $matches += $w }
    } catch {}
  }
  return $matches
}

function Dismiss-OutlookModalDialogs {
  param(
    [Parameter(Mandatory=$true)][int]$OutlookPid,
    [int]$TimeoutSeconds = 10
  )

  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  $dismissed = @()

  while ((Get-Date) -lt $deadline) {
    $foundAny = $false
    $wins = Find-TopLevelWindowsByProcessId -ProcessId $OutlookPid
    foreach ($w in $wins) {
      try {
        $isModal = $w.GetCurrentPropertyValue([System.Windows.Automation.AutomationElement]::IsModalProperty)
        if (-not $isModal) { continue }
        $foundAny = $true
        $title = $w.Current.Name

        # Try clicking common affirmative buttons first.
        $btnNames = @('OK','Yes','Close','Continue','Next')
        $clicked = $false
        foreach ($bn in $btnNames) {
          $condBtn = New-Object System.Windows.Automation.AndCondition(
            (New-Object System.Windows.Automation.PropertyCondition(
              [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
              [System.Windows.Automation.ControlType]::Button
            )),
            (New-Object System.Windows.Automation.PropertyCondition(
              [System.Windows.Automation.AutomationElement]::NameProperty,
              $bn
            ))
          )
          $btn = $w.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $condBtn)
          if ($btn) {
            $inv = $null
            if ($btn.TryGetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern, [ref]$inv)) {
              $inv.Invoke()
              $clicked = $true
              break
            }
          }
        }

        if (-not $clicked) {
          # Fallback: focus the dialog and press Escape.
          Focus-Window -Window $w
          [System.Windows.Forms.SendKeys]::SendWait('{ESC}')
        }

        if ($title) { $dismissed += $title } else { $dismissed += '(modal dialog)' }
      } catch {
        continue
      }
    }

    if (-not $foundAny) { break }
    Start-Sleep -Milliseconds 300
  }

  return $dismissed
}

function Resolve-OutlookFolder {
  param(
    [Parameter(Mandatory=$true)]$Namespace,
    [Parameter(Mandatory=$true)][string]$FolderPath
  )

  $p = $FolderPath.Trim()
  if (-not $p) { throw "folderPath is empty" }

  $parts = $p -split "\\\\" | Where-Object { $_ -and $_.Trim() }
  if ($parts.Count -eq 0) { throw "folderPath is invalid: $FolderPath" }

  # Support a minimal, safe subset: Inbox\\<Subfolder...>
  if ($parts[0].ToLower() -ne 'inbox') {
    throw "Only folderPath starting with 'Inbox\\' is supported right now. Got: $FolderPath"
  }

  # olFolderInbox = 6
  $folder = $Namespace.GetDefaultFolder(6)
  for ($i = 1; $i -lt $parts.Count; $i++) {
    $name = $parts[$i]
    $next = $folder.Folders.Item($name)
    if (-not $next) { throw "Outlook folder not found: $name (under $($folder.Name))" }
    $folder = $next
  }
  return $folder
}

function Get-OutlookExePath {
  $candidates = @()

  try {
    $cmd = Get-Command outlook.exe -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.Source) { $candidates += $cmd.Source }
  } catch {}

  $pf = $env:ProgramFiles
  $pfx86 = ${env:ProgramFiles(x86)}
  if ($pf) {
    $candidates += Join-Path $pf 'Microsoft Office\\root\\Office16\\OUTLOOK.EXE'
    $candidates += Join-Path $pf 'Microsoft Office\\Office16\\OUTLOOK.EXE'
    $candidates += Join-Path $pf 'Microsoft Office\\root\\Office15\\OUTLOOK.EXE'
    $candidates += Join-Path $pf 'Microsoft Office\\Office15\\OUTLOOK.EXE'
  }
  if ($pfx86) {
    $candidates += Join-Path $pfx86 'Microsoft Office\\root\\Office16\\OUTLOOK.EXE'
    $candidates += Join-Path $pfx86 'Microsoft Office\\Office16\\OUTLOOK.EXE'
    $candidates += Join-Path $pfx86 'Microsoft Office\\root\\Office15\\OUTLOOK.EXE'
    $candidates += Join-Path $pfx86 'Microsoft Office\\Office15\\OUTLOOK.EXE'
  }

  foreach ($p in $candidates) {
    if ($p -and (Test-Path -LiteralPath $p)) {
      return $p
    }
  }

  return $null
}

function Ensure-OutlookRunning {
  $p = Get-Process OUTLOOK -ErrorAction SilentlyContinue
  if ($p) { return }

  $exe = Get-OutlookExePath
  if (-not $exe) {
    # Fall back to relying on PATH.
    $exe = 'outlook.exe'
  }

  # Launch Outlook explicitly. /recycle reuses existing instance (safe if one starts quickly).
  Start-Process -FilePath $exe -ArgumentList '/recycle' | Out-Null

  # Wait briefly for process to appear.
  $deadline = (Get-Date).AddSeconds(30)
  while ((Get-Date) -lt $deadline) {
    $p = Get-Process OUTLOOK -ErrorAction SilentlyContinue
    if ($p) { break }
    Start-Sleep -Milliseconds 250
  }
}

function Open-OutlookEmailFromFolder {
  param(
    [Parameter(Mandatory=$true)][string]$FolderPath,
    [string]$SubjectContains
  )

  # Launch Outlook explicitly via OUTLOOK.EXE to avoid COM startup issues.
  Ensure-OutlookRunning

  $outlookPid = $null
  try {
    $p = Get-Process OUTLOOK -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($p) { $outlookPid = [int]$p.Id }
  } catch {}

  # Attach to running Outlook via COM.
  $outlook = $null
  try {
    $outlook = [Runtime.InteropServices.Marshal]::GetActiveObject('Outlook.Application')
  } catch {
    $outlook = New-Object -ComObject Outlook.Application
  }

  $ns = $outlook.GetNamespace('MAPI')

  # Outlook can throw "A dialog box is open" if a modal prompt is blocking.
  # We'll retry once after attempting to dismiss modal dialogs.
  $attempt = 0
  while ($true) {
    $attempt++
    try {
      $folder = Resolve-OutlookFolder -Namespace $ns -FolderPath $FolderPath

      # Ensure a visible Explorer and switch folder.
      $explorer = $outlook.ActiveExplorer()
      if (-not $explorer) {
        # Prefer folder.GetExplorer(displayMode) to avoid COM signature issues.
        # olFolderDisplayNormal = 0
        $explorer = $folder.GetExplorer(0)
        $explorer.Display()
      } else {
        $explorer.Display()
        $explorer.CurrentFolder = $folder
      }
      break
    } catch {
      $msg = $_.Exception.Message
      if (($attempt -lt 2) -and $outlookPid -and ($msg -like '*dialog box is open*')) {
        Dismiss-OutlookModalDialogs -OutlookPid $outlookPid -TimeoutSeconds 10 | Out-Null
        Start-Sleep -Milliseconds 500
        continue
      }
      throw
    }
  }

  $items = $folder.Items
  if (-not $items) { throw "No items collection for folder: $FolderPath" }
  try { $items.Sort('[ReceivedTime]', $true) } catch {}

  $mail = $null
  $count = 0
  foreach ($it in $items) {
    $count++
    if ($count -gt 200) { break }
    # Be defensive: folders can contain reports/meetings/etc.
    try {
      $subj = [string]$it.Subject
      if ($SubjectContains -and ($subj -notlike "*$SubjectContains*")) { continue }
      # MailItem.Class = 43, but avoid relying on constants when possible.
      if ($it -and $it.PSObject.Properties.Match('Class').Count -gt 0) {
        if ($it.Class -ne 43) { continue }
      }
      $mail = $it
      break
    } catch {
      continue
    }
  }
  if (-not $mail) { throw "No matching email found in $FolderPath" }

  $mail.Display()

  return @{ folder = $FolderPath; subject = [string]$mail.Subject }
}

try {
  if (-not (Test-Path -LiteralPath $InputJsonPath)) {
    throw "InputJsonPath not found: $InputJsonPath"
  }

  $input = Get-Content -LiteralPath $InputJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
  if (-not $input.action) {
    throw "Input JSON must include 'action'"
  }

  $result = @{
    ok = $false
    action = [string]$input.action
    error = $null
    data = $null
  }

  switch ($input.action) {
    'listTopWindows' {
      $root = [System.Windows.Automation.AutomationElement]::RootElement
      $cond = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
        [System.Windows.Automation.ControlType]::Window
      )
      $windows = $root.FindAll([System.Windows.Automation.TreeScope]::Children, $cond)
      $names = @()
      foreach ($w in $windows) {
        try {
          $n = $w.Current.Name
          if ($n) { $names += $n }
        } catch {}
      }
      $result.ok = $true
      $result.data = @{ windows = $names }
    }

    'sendKeysToWindow' {
      $win = Find-TopLevelWindowByName -Name ([string]$input.windowName) -TimeoutSeconds $TimeoutSeconds
      if (-not $win) { throw "Window not found: $($input.windowName)" }
      Focus-Window -Window $win

      $keys = [string]$input.keys
      # SendKeys syntax uses {ENTER}, {TAB}, etc.
      [System.Windows.Forms.SendKeys]::SendWait($keys)

      $result.ok = $true
      $result.data = @{ window = $win.Current.Name }
    }

    'openOutlookEmail' {
      $folderPath = [string]$input.folderPath
      if (-not $folderPath) { $folderPath = 'Inbox\\RPA' }
      $subjectContains = $null
      if ($input.subjectContains) { $subjectContains = [string]$input.subjectContains }

      $data = Open-OutlookEmailFromFolder -FolderPath $folderPath -SubjectContains $subjectContains
      $result.ok = $true
      $result.data = $data
    }

    default {
      throw "Unsupported action: $($input.action)"
    }
  }

  Write-ResultJson -Obj $result -Path $OutputJsonPath
  exit 0
} catch {
  $err = $_.Exception.Message
  $out = @{
    ok = $false
    action = $null
    error = $err
    data = $null
  }
  try {
    Write-ResultJson -Obj $out -Path $OutputJsonPath
  } catch {
    # If we can't write output, at least write to stderr.
    Write-Error $err
  }
  exit 1
}
