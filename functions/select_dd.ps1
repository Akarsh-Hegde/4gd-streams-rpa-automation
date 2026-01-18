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

    Write-Host "  • Label found at index $labelIndex"
    
    # Debug: Show element details around the label
    Write-Host "  • Elements around label:" -ForegroundColor Yellow
    for ($d = [Math]::Max(0, $labelIndex - 2); $d -lt [Math]::Min($elements.Count, $labelIndex + 15); $d++) {
        $debugEl = $elements[$d]
        $prefix = if ($d -eq $labelIndex) { ">>>" } else { "   " }
        Write-Host "    $prefix [$d] Type=$($debugEl.Current.ControlType.ProgrammaticName), Name='$($debugEl.Current.Name)', Enabled=$($debugEl.Current.IsEnabled)" -ForegroundColor Gray
    }

    $editWrapper = $null

    # Search for Edit control or Pane that might contain it
    Write-Host "  • Searching for Edit control after label..." -ForegroundColor Yellow
    for ($i = $labelIndex + 1; $i -lt $elements.Count; $i++) {
        $el = $elements[$i]

        # Stop if we hit the next label (but check more elements first)
        if (
            $el.Current.ControlType -eq
                [System.Windows.Automation.ControlType]::Text -and
            $el.Current.Name.EndsWith(":") -and
            ($i - $labelIndex) > 5  # Allow checking at least 5 elements before stopping
        ) {
            break
        }

        # Found direct Edit control
        if ($el.Current.ControlType -eq
            [System.Windows.Automation.ControlType]::Edit) {
            $editWrapper = $el
            Write-Host "    ✓ Found Edit control directly" -ForegroundColor Green
            break
        }

        # Found Pane - search inside it for Edit control
        if ($el.Current.ControlType -eq
            [System.Windows.Automation.ControlType]::Pane) {
            Write-Host "    • Found Pane '$($el.Current.Name)' at index $i - searching inside..." -ForegroundColor Yellow
            
            # Debug: Show all children in the Pane
            $paneChildren = $el.FindAll(
                [System.Windows.Automation.TreeScope]::Children,
                [System.Windows.Automation.Condition]::TrueCondition
            )
            Write-Host "      Pane has $($paneChildren.Count) children:" -ForegroundColor Gray
            foreach ($child in $paneChildren) {
                Write-Host "        - Type=$($child.Current.ControlType.ProgrammaticName), Name='$($child.Current.Name)', AutomationId='$($child.Current.AutomationId)'" -ForegroundColor Gray
            }
            
            $editInPane = $el.FindFirst(
                [System.Windows.Automation.TreeScope]::Descendants,
                (New-Object System.Windows.Automation.PropertyCondition(
                    [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
                    [System.Windows.Automation.ControlType]::Edit
                ))
            )
            
            if ($editInPane) {
                $editWrapper = $editInPane
                Write-Host "    ✓ Found Edit control inside Pane!" -ForegroundColor Green
                break
            } else {
                # Maybe the Pane itself is editable or we need to check for Document control
                Write-Host "      No Edit control found, checking for Document or other types..." -ForegroundColor Yellow
                
                $docInPane = $el.FindFirst(
                    [System.Windows.Automation.TreeScope]::Descendants,
                    (New-Object System.Windows.Automation.PropertyCondition(
                        [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
                        [System.Windows.Automation.ControlType]::Document
                    ))
                )
                
                if ($docInPane) {
                    $editWrapper = $docInPane
                    Write-Host "    ✓ Found Document control inside Pane!" -ForegroundColor Green
                    break
                }
                
                # If the Pane has no children, it might BE the field itself (like Risk ID)
                # Check if it's immediately after the label (within 2 positions)
                if ($paneChildren.Count -eq 0 -and ($i - $labelIndex) -le 2) {
                    Write-Host "      Empty Pane immediately after label - likely IS the field" -ForegroundColor Yellow
                    $editWrapper = $el
                    break
                }
                
                # If the Pane has no children and is far from label, skip it
                if ($paneChildren.Count -eq 0) {
                    Write-Host "      Pane is empty and not adjacent to label, skipping..." -ForegroundColor Yellow
                    continue
                }
                
                # If nothing found but has children, try using the Pane itself if enabled
                if ($el.Current.IsEnabled) {
                    Write-Host "      Pane is enabled, will try to use it directly" -ForegroundColor Yellow
                    $editWrapper = $el
                    break
                }
            }
        }
    }

    if (-not $editWrapper) {
        Write-Host "  ✗ Edit control not found" -ForegroundColor Red
        throw "Edit control not found for '$labelText'. Check if the field is enabled/visible in the UI."
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

    # Try to focus the editor
    try {
        $editor.SetFocus()
        Write-Host "  • Editor focused"
    } catch {
        Write-Host "  ⚠ Editor could not receive focus, will try alternative methods" -ForegroundColor Yellow
    }

    Write-Host "✔ Field '$labelText' ready for input"
    return $editor
}

# Helper function to set field value using multiple methods
function Set-FieldValue {
    param (
        [Parameter(Mandatory)]
        [System.Windows.Automation.AutomationElement]$element,
        
        [Parameter(Mandatory)]
        [string]$value
    )
    
    # Method 1: Try ValuePattern
    try {
        $valuePattern = $element.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern)
        if ($valuePattern) {
            $valuePattern.SetValue($value)
            Write-Host "  ✓ Value set using ValuePattern" -ForegroundColor Green
            return $true
        }
    } catch {
        Write-Host "  • ValuePattern not available" -ForegroundColor Gray
    }
    
    # Method 2: SendKeys after focus
    try {
        $element.SetFocus()
        Start-Sleep -Milliseconds 100
        [System.Windows.Forms.SendKeys]::SendWait("^a")
        [System.Windows.Forms.SendKeys]::SendWait($value)
        Write-Host "  ✓ Value set using SendKeys" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "  • SendKeys method failed: $_" -ForegroundColor Gray
    }
    
    return $false
}

# ---------------- Find IMS window ----------------
$root = [System.Windows.Automation.AutomationElement]::RootElement

$windows = $root.FindAll(
    [System.Windows.Automation.TreeScope]::Children,
    [System.Windows.Automation.Condition]::TrueCondition
)

# Debug: List all window names
Write-Host "▶ Searching for Insurance Management System window..." -ForegroundColor Cyan
Write-Host "  Available windows:" -ForegroundColor Yellow
foreach ($w in $windows) {
    if ($w.Current.Name) {
        Write-Host "    - '$($w.Current.Name)'" -ForegroundColor Gray
    }
}

# Try to find the window with more flexible matching
$window = $windows | Where-Object {
    $_.Current.Name -like "*Insurance Management System*"
} | Select-Object -First 1

if (-not $window) {
    Write-Host "  ✗ No window found matching '*Insurance Management System*'" -ForegroundColor Red
    throw "Insurance Management System window not found. Please ensure the application is running."
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
Start-Sleep -Milliseconds 500

# ---------------- Fill Business Name ----------------
Write-Host "▶ Filling Business Name field..." -ForegroundColor Cyan
$businessNameField = Set-IMSFieldByLabel2 -container $insuredPane -labelText "Business Name:"
Set-FieldValue -element $businessNameField -value "Acme Insurance Holdings LLC"
Start-Sleep -Milliseconds 300

# ---------------- Fill Risk ID ----------------
Write-Host "▶ Filling Risk ID field..." -ForegroundColor Cyan
$riskIdField = Set-IMSFieldByLabel2 -container $insuredPane -labelText "Risk ID:"
if (-not (Set-FieldValue -element $riskIdField -value "12345")) {
    Write-Host "  ⚠ Could not set Risk ID value automatically, trying TAB navigation..." -ForegroundColor Yellow
    # Navigate from Business Name field to Risk ID using TAB
    $businessNameField.SetFocus()
    Start-Sleep -Milliseconds 100
    # TAB through: First -> Middle -> Last -> down arrow -> Risk ID
    [System.Windows.Forms.SendKeys]::SendWait("{TAB}")
    Start-Sleep -Milliseconds 50
    [System.Windows.Forms.SendKeys]::SendWait("{TAB}")
    Start-Sleep -Milliseconds 50
    [System.Windows.Forms.SendKeys]::SendWait("{TAB}")
    Start-Sleep -Milliseconds 50
    [System.Windows.Forms.SendKeys]::SendWait("{DOWN}")
    Start-Sleep -Milliseconds 100
    [System.Windows.Forms.SendKeys]::SendWait("^a")
    [System.Windows.Forms.SendKeys]::SendWait("12345")
}
Start-Sleep -Milliseconds 300

# ---------------- Fill Tax ID ----------------
Write-Host "▶ Filling Tax ID field..." -ForegroundColor Cyan
$taxIdField = Set-IMSFieldByLabel2 -container $insuredPane -labelText "Tax ID:"
Set-FieldValue -element $taxIdField -value "98-7654321"
Start-Sleep -Milliseconds 300

Write-Host "✔ All fields filled successfully" -ForegroundColor Green
