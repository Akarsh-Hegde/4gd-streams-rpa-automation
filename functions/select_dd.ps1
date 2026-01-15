Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
Add-Type -AssemblyName System.Windows.Forms

# ---------------- Win32 helper (safe add) ----------------
if (-not ("Win32" -as [type])) {
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
}
"@
}

# Select DropDown---------------- Helper: Select IMS Combo by Value ----------------
function Select-IMSComboByValue {
    param (
        [Parameter(Mandatory)]
        [System.Windows.Automation.AutomationElement]$container,

        [Parameter(Mandatory)]
        [string]$value
    )

    Write-Host "▶ Selecting IMS Combo value: '$value'" -ForegroundColor Cyan

    $initialKey = $value.Substring(0,1)
    Write-Host "  • Initial key derived: '$initialKey'"

    $comboBoxes = $container.FindAll(
        [System.Windows.Automation.TreeScope]::Descendants,
        (New-Object System.Windows.Automation.PropertyCondition(
            [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
            [System.Windows.Automation.ControlType]::ComboBox
        ))
    )

    Write-Host "  • ComboBoxes found in container: $($comboBoxes.Count)"

    $comboIndex = 0
    foreach ($combo in $comboBoxes) {
        $comboIndex++

        Write-Host ""
        Write-Host "  ▶ Inspecting ComboBox #$comboIndex (AutomationId='$($combo.Current.AutomationId)')" -ForegroundColor Yellow

        $items = $combo.FindAll(
            [System.Windows.Automation.TreeScope]::Descendants,
            (New-Object System.Windows.Automation.PropertyCondition(
                [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
                [System.Windows.Automation.ControlType]::ListItem
            ))
        )

        if ($items.Count -eq 0) {
            Write-Host "    ⛔ No ListItems found — skipping"
            continue
        }

        Write-Host "    • ListItems found: $($items.Count)"

        $matching = @()
        foreach ($i in $items) {
            Write-Host "      - Item: '$($i.Current.Name)'"

            if ($i.Current.Name.StartsWith($initialKey, [StringComparison]::InvariantCultureIgnoreCase)) {
                $matching += $i
            }
        }

        if ($matching.Count -eq 0) {
            Write-Host "    ⛔ No items starting with '$initialKey' — skipping"
            continue
        }

        Write-Host "    • Items starting with '$initialKey': $($matching.Count)"

        $targetIndex = -1
        for ($i = 0; $i -lt $matching.Count; $i++) {
            if ($matching[$i].Current.Name -eq $value) {
                $targetIndex = $i
                break
            }
        }

        if ($targetIndex -lt 0) {
            Write-Host "    ⛔ '$value' not found among matching items — skipping ComboBox"
            continue
        }

        Write-Host "    ✅ Target value '$value' found at index $targetIndex"

        try {
            $combo.SetFocus()
            Write-Host "    • ComboBox focused"
        } catch {
            Write-Host "    ⚠ ComboBox could not receive focus — continuing anyway"
        }

        Start-Sleep -Milliseconds 200

        Write-Host "    • Opening dropdown (ALT+DOWN)"
        [System.Windows.Forms.SendKeys]::SendWait("%{DOWN}")
        Start-Sleep -Milliseconds 300

        Write-Host "    • Sending key '$initialKey' $($targetIndex + 1) time(s)"
        for ($k = 0; $k -le $targetIndex; $k++) {
            [System.Windows.Forms.SendKeys]::SendWait($initialKey)
            Start-Sleep -Milliseconds 120
        }

        Write-Host "    • Confirming selection (ENTER)"
        [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

        Write-Host "✔ Successfully selected '$value'" -ForegroundColor Green
        return
    }

    throw "❌ No ComboBox found containing value '$value'"
}

function Set-IMSFieldByLabel {
    param (
        [Parameter(Mandatory)]
        [System.Windows.Automation.AutomationElement]$container,

        [Parameter(Mandatory)]
        [string]$labelText,

        [Parameter(Mandatory)]
        [string]$value
    )

    Write-Host "▶ Setting '$labelText' → '$value'"

    # 1. Find the label
    $label = $container.FindAll(
        [System.Windows.Automation.TreeScope]::Children,
        [System.Windows.Automation.Condition]::TrueCondition
    ) | Where-Object {
        $_.Current.ControlType -eq [System.Windows.Automation.ControlType]::Text -and
        $_.Current.Name -eq $labelText
    } | Select-Object -First 1

    if (-not $label) {
        throw "Label '$labelText' not found"
    }

    Write-Host "  • Label found"

    # 2. Get siblings and locate the Edit after the label
    $siblings = $container.FindAll(
        [System.Windows.Automation.TreeScope]::Children,
        [System.Windows.Automation.Condition]::TrueCondition
    )

    $found = $false
    $editWrapper = $null

    foreach ($el in $siblings) {
        if ($el.Equals($label)) {
            $found = $true
            continue
        }

        if ($found -and
            $el.Current.ControlType -eq [System.Windows.Automation.ControlType]::Edit) {
            $editWrapper = $el
            break
        }
    }

    if (-not $editWrapper) {
        throw "Edit control for '$labelText' not found"
    }

    # 3. Find inner [Editor] Edit Area
    $editArea = $editWrapper.FindFirst(
        [System.Windows.Automation.TreeScope]::Descendants,
        (New-Object System.Windows.Automation.PropertyCondition(
            [System.Windows.Automation.AutomationElement]::AutomationIdProperty,
            "[Editor] Edit Area"
        ))
    )

    if (-not $editArea) {
        throw "Inner editor not found for '$labelText'"
    }

    Write-Host "  • Edit field located"

    # 4. Focus and type
    try { $editArea.SetFocus() } catch {}

    Start-Sleep -Milliseconds 150
    [System.Windows.Forms.SendKeys]::SendWait("^a")
    [System.Windows.Forms.SendKeys]::SendWait($value)
    # [System.Windows.Forms.SendKeys]::SendWait("{TAB}")

    Write-Host "✔ '$labelText' set"
}

function Set-IMSFieldByLabel2 {
    param (
        [Parameter(Mandatory)]
        [System.Windows.Automation.AutomationElement]$container,

        [Parameter(Mandatory)]
        [string]$labelText
    )

    Write-Host "▶ Locating field '$labelText'"

    $elements = $container.FindAll(
        [System.Windows.Automation.TreeScope]::Descendants,
        [System.Windows.Automation.Condition]::TrueCondition
    )

    $labelIndex = -1
    for ($i = 0; $i -lt $elements.Count; $i++) {
        if (
            $elements[$i].Current.ControlType -eq
                [System.Windows.Automation.ControlType]::Text -and
            $elements[$i].Current.Name -eq $labelText
        ) {
            $labelIndex = $i
            break
        }
    }

    if ($labelIndex -lt 0) {
        throw "Label '$labelText' not found"
    }

    Write-Host "  • Label found"

    $editWrapper = $null

    for ($i = $labelIndex + 1; $i -lt $elements.Count; $i++) {
        $el = $elements[$i]

        if (
            $el.Current.ControlType -eq
                [System.Windows.Automation.ControlType]::Text -and
            $el.Current.Name.EndsWith(":")
        ) {
            break
        }

        if ($el.Current.ControlType -eq
            [System.Windows.Automation.ControlType]::Edit) {
            $editWrapper = $el
            break
        }
    }

    if (-not $editWrapper) {
        throw "Edit control not found for '$labelText'"
    }

    Write-Host "  • Edit wrapper located"

    $editor = $editWrapper.FindFirst(
        [System.Windows.Automation.TreeScope]::Descendants,
        (New-Object System.Windows.Automation.PropertyCondition(
            [System.Windows.Automation.AutomationElement]::AutomationIdProperty,
            "[Editor] Edit Area"
        ))
    )

    if (-not $editor) { $editor = $editWrapper }

    try {
        $editor.SetFocus()
        Write-Host "  • Editor focused"
    } catch {
        Write-Host "  ⚠ Editor could not receive focus"
    }

    Write-Host "✔ Field '$labelText' ready for input"
    return $editor
}

# ---------------- Find IMS window ----------------
$root = [System.Windows.Automation.AutomationElement]::RootElement

$windows = $root.FindAll(
    [System.Windows.Automation.TreeScope]::Children,
    [System.Windows.Automation.Condition]::TrueCondition
)

$window = $windows | Where-Object {
    $_.Current.Name -like "Insurance Management System"
} | Select-Object -First 1

if (-not $window) {
    throw "Insurance Management System window not found"
}

[Win32]::SetForegroundWindow($window.Current.NativeWindowHandle)
Start-Sleep -Milliseconds 400

# ---------------- Open New Insured ----------------
[System.Windows.Forms.SendKeys]::SendWait("{F3}")
# Start-Sleep -Milliseconds 900

# ---------------- Find 'Insured Information' Pane ----------------
$insuredPane = $window.FindFirst(
    [System.Windows.Automation.TreeScope]::Descendants,
    (New-Object System.Windows.Automation.AndCondition(
        (New-Object System.Windows.Automation.PropertyCondition(
            [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
            [System.Windows.Automation.ControlType]::Pane
        )),
        (New-Object System.Windows.Automation.PropertyCondition(
            [System.Windows.Automation.AutomationElement]::NameProperty,
            "Insured Information"
        ))
    ))
)

if (-not $insuredPane) {
    throw "Insured Information pane not found"
}

# ---------------- Select Type and Gender ----------------
Select-IMSComboByValue -container $insuredPane -value "Limited Partnership"
# Select-IMSComboByValue -container $insuredPane -value "Corporation"
# Select-IMSComboByValue -container $insuredPane -value "Female"
# Select-IMSComboByValue -container $insuredPane -value "Dr"
# add wait
Start-Sleep -Milliseconds 500
# Set-IMSFieldByLabel2 `
#     -container $insuredPane `
#     -labelText "Business Name:" `
#     # -value "12345"
#     # -value "Acme Insurance Holdings LLC"
# [System.Windows.Forms.SendKeys]::SendWait("^a")
# [System.Windows.Forms.SendKeys]::SendWait("Acme Insurance Holdings LLC")
Set-IMSFieldByLabel2 `
    -container $insuredPane `
    -labelText "Risk ID:" `
    # -value ""
[System.Windows.Forms.SendKeys]::SendWait("^a")
[System.Windows.Forms.SendKeys]::SendWait("12345")
Write-Host "✔ Type set to Individual and Gender set to Female successfully"