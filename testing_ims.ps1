Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
Add-Type -AssemblyName System.Windows.Forms

# ---------------- Win32 Foreground Helper ----------------
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
}
"@

# ---------------- Helpers ----------------

function Get-EditByLabel {
    param (
        [System.Windows.Automation.AutomationElement]$root,
        [string]$labelText
    )

    $label = $root.FindAll(
        [System.Windows.Automation.TreeScope]::Descendants,
        (New-Object System.Windows.Automation.PropertyCondition(
            [System.Windows.Automation.AutomationElement]::NameProperty,
            $labelText
        ))
    ) | Select-Object -Last 1

    if (-not $label) {
        throw "Label '$labelText' not found"
    }

    $walker = [System.Windows.Automation.TreeWalker]::ControlViewWalker
    $next = $walker.GetNextSibling($label)

    while ($next -and $next.Current.ControlType -ne [System.Windows.Automation.ControlType]::Edit) {
        $next = $walker.GetNextSibling($next)
    }

    if (-not $next) {
        throw "Edit field for '$labelText' not found"
    }

    return $next
}

function Set-EditText {
    param (
        [System.Windows.Automation.AutomationElement]$edit,
        [string]$text
    )

    $edit.SetFocus()
    [System.Windows.Forms.SendKeys]::SendWait("^a")
    [System.Windows.Forms.SendKeys]::SendWait("{DEL}")
    [System.Windows.Forms.SendKeys]::SendWait($text)
}

# ---------------- Locate IMS Window (YOUR METHOD) ----------------
$root = [System.Windows.Automation.AutomationElement]::RootElement

$windows = $root.FindAll(
    [System.Windows.Automation.TreeScope]::Children,
    [System.Windows.Automation.Condition]::TrueCondition
)

$window = $windows | Where-Object {
    $_.Current.Name -like "*Insurance Management System*"
} | Select-Object -First 1

if (-not $window) {
    throw "Insurance Management System window not found"
}

[Win32]::SetForegroundWindow($window.Current.NativeWindowHandle)
Start-Sleep -Milliseconds 400

# ---------------- Open New Insured ----------------
[System.Windows.Forms.SendKeys]::SendWait("{F3}")
Start-Sleep -Milliseconds 800

# ---------------- Find ACTIVE 'Type:' label ----------------
$typeLabel = $window.FindAll(
    [System.Windows.Automation.TreeScope]::Descendants,
    (New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::NameProperty,
        "Type:"
    ))
) | Select-Object -Last 1

if (-not $typeLabel) {
    throw "'Type:' label not found"
}

# ---------------- Walk UP to container pane ----------------
$walker = [System.Windows.Automation.TreeWalker]::ControlViewWalker
$container = $walker.GetParent($typeLabel)

while ($container -and $container.Current.ControlType -ne [System.Windows.Automation.ControlType]::Pane) {
    $container = $walker.GetParent($container)
}

if (-not $container) {
    throw "Container pane for Type not found"
}

# ---------------- Find Type ComboBox by CONTENT ----------------
$typeCombo = $null

$comboBoxes = $container.FindAll(
    [System.Windows.Automation.TreeScope]::Descendants,
    (New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
        [System.Windows.Automation.ControlType]::ComboBox
    ))
)

foreach ($cb in $comboBoxes) {
    $items = $cb.FindAll(
        [System.Windows.Automation.TreeScope]::Descendants,
        (New-Object System.Windows.Automation.PropertyCondition(
            [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
            [System.Windows.Automation.ControlType]::ListItem
        ))
    )

    foreach ($item in $items) {
        if ($item.Current.Name -eq "Individual") {
            $typeCombo = $cb
            break
        }
    }

    if ($typeCombo) { break }
}

if (-not $typeCombo) {
    throw "Type ComboBox containing 'Individual' not found"
}

# ---------------- Open dropdown + select ----------------
$typeCombo.SetFocus()
Start-Sleep -Milliseconds 200
[System.Windows.Forms.SendKeys]::SendWait("%{DOWN}")
Start-Sleep -Milliseconds 200
[System.Windows.Forms.SendKeys]::SendWait("C")

# ---------------- Resolve ALL fields first ----------------
$businessNameEdit = Get-EditByLabel $window "Business Name:"
$feinEdit         = Get-EditByLabel $window "FEIN:"
$addressEdit      = Get-EditByLabel $window "Address"
$zipEdit          = Get-EditByLabel $window "Zip:"

# ---------------- Fill fields in one batch ----------------
Set-EditText $businessNameEdit "Acme Logistics LLC"
Set-EditText $feinEdit         "12-3456789"
Set-EditText $addressEdit      "742 Evergreen Terrace"
Set-EditText $zipEdit          "90210"
