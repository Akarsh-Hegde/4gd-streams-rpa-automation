############################################
# CONFIG – CHANGE VALUES HERE
############################################
$DATA = @{
    BusinessName = "Acme Logistics LLC"
    FEIN         = "12-3456789"
    Address      = "123 Industrial Way"
    Zip          = "75001"
}

############################################
# LOAD DEPENDENCIES
############################################
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
Add-Type -AssemblyName System.Windows.Forms

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
}
"@

$root   = [System.Windows.Automation.AutomationElement]::RootElement
$walker = [System.Windows.Automation.TreeWalker]::ControlViewWalker

############################################
# FIND IMS WINDOW (YOUR METHOD)
############################################
function Get-IMSWindow {
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
    return $window
}

############################################
# FIND INPUT FIELD BY LABEL
############################################
function Find-InputByLabel {
    param (
        [System.Windows.Automation.AutomationElement]$Root,
        [string]$LabelText
    )

    $label = $Root.FindAll(
        [System.Windows.Automation.TreeScope]::Descendants,
        (New-Object System.Windows.Automation.PropertyCondition(
            [System.Windows.Automation.AutomationElement]::NameProperty,
            $LabelText
        ))
    ) | Select-Object -Last 1

    if (-not $label) {
        throw "Label '$LabelText' not found"
    }

    $next = $walker.GetNextSibling($label)
    while ($next -and $next.Current.ControlType -ne
           [System.Windows.Automation.ControlType]::Edit) {
        $next = $walker.GetNextSibling($next)
    }

    if (-not $next) {
        throw "Input field for '$LabelText' not found"
    }

    return $next
}

############################################
# SAFE TEXT ENTRY
############################################
function Set-TextField {
    param (
        [System.Windows.Automation.AutomationElement]$Field,
        [string]$Value
    )

    $Field.SetFocus()
    Start-Sleep -Milliseconds 150

    [System.Windows.Forms.SendKeys]::SendWait("^a")
    [System.Windows.Forms.SendKeys]::SendWait("{BACKSPACE}")
    Start-Sleep -Milliseconds 100

    [System.Windows.Forms.SendKeys]::SendWait($Value)
    Start-Sleep -Milliseconds 150
}

############################################
# FIND TYPE COMBOBOX (SEMANTIC)
############################################
function Get-TypeDropdownButton {
    param (
        [Parameter(Mandatory)]
        [System.Windows.Automation.AutomationElement]$Root
    )

    # Find the LAST "Type:" label (New Insured form)
    $typeLabel = $Root.FindAll(
        [System.Windows.Automation.TreeScope]::Descendants,
        (New-Object System.Windows.Automation.PropertyCondition(
            [System.Windows.Automation.AutomationElement]::NameProperty,
            "Type:"
        ))
    ) | Select-Object -Last 1

    if (-not $typeLabel) {
        throw "'Type:' label not found"
    }

    # Walk up to containing pane
    $walker = [System.Windows.Automation.TreeWalker]::ControlViewWalker
    $container = $walker.GetParent($typeLabel)

    while ($container -and
           $container.Current.ControlType -ne
           [System.Windows.Automation.ControlType]::Pane) {
        $container = $walker.GetParent($container)
    }

    if (-not $container) {
        throw "Type container pane not found"
    }

    # Find ComboBox with 'Individual'
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

        if ($items | Where-Object { $_.Current.Name -eq "Individual" }) {

            # Find dropdown button INSIDE this ComboBox
            $btn = $cb.FindFirst(
                [System.Windows.Automation.TreeScope]::Descendants,
                (New-Object System.Windows.Automation.PropertyCondition(
                    [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
                    [System.Windows.Automation.ControlType]::Button
                ))
            )

            if ($btn) {
                return $btn
            }
        }
    }

    throw "Type dropdown button not found"
}

############################################
# MAIN FLOW
############################################
$window = Get-IMSWindow

# Open New Insured
[System.Windows.Forms.SendKeys]::SendWait("{F3}")
Start-Sleep -Milliseconds 1000

# Select Type
$typeCombo = Get-TypeDropdownButton -Root $window
$typeCombo.SetFocus()
Start-Sleep -Milliseconds 200
[System.Windows.Forms.SendKeys]::SendWait("%{DOWN}")
Start-Sleep -Milliseconds 200
[System.Windows.Forms.SendKeys]::SendWait("I")   # Individual
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

############################################
# PARALLEL DISCOVERY
############################################
$tasks = @{
    BusinessName = [System.Threading.Tasks.Task]::Run({
        Find-InputByLabel -Root $window -LabelText "Business Name:"
    })
    FEIN = [System.Threading.Tasks.Task]::Run({
        Find-InputByLabel -Root $window -LabelText "FEIN:"
    })
    Address = [System.Threading.Tasks.Task]::Run({
        Find-InputByLabel -Root $window -LabelText "Address:"
    })
    Zip = [System.Threading.Tasks.Task]::Run({
        Find-InputByLabel -Root $window -LabelText "Zip:"
    })
}

[System.Threading.Tasks.Task]::WaitAll($tasks.Values)

############################################
# SEQUENTIAL UI WRITES
############################################
Set-TextField $tasks.BusinessName.Result $DATA.BusinessName
Set-TextField $tasks.FEIN.Result         $DATA.FEIN
Set-TextField $tasks.Address.Result      $DATA.Address
Set-TextField $tasks.Zip.Result          $DATA.Zip