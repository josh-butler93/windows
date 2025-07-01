Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Remote Desktop Launcher - LabNet"
$form.Size = New-Object System.Drawing.Size(500, 400)  # Increased Size
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false

# Path where your .rdp files are stored
$rdpFolder = "C:\Launcher"

# Define your session names (without .rdp extension)
$sessions = @("test", "server2", "server3", "server4", "server5", "server6", "server7", "server8")

# Layout variables
$buttonWidth = 140
$buttonHeight = 40
$padding = 10
$buttonsPerRow = 3

for ($i = 0; $i -lt $sessions.Count; $i++) {
    $sessionName = $sessions[$i]

    $button = New-Object System.Windows.Forms.Button
    $button.Text = $sessionName
    $button.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)

    # Calculate position
    $row = [math]::Floor($i / $buttonsPerRow)
    $col = $i % $buttonsPerRow
    $xPos = $padding + ($col * ($buttonWidth + $padding))
    $yPos = $padding + ($row * ($buttonHeight + $padding))
    $button.Location = New-Object System.Drawing.Point($xPos, $yPos)

    # Correct per-button event binding with captured variable
    $currentSession = $sessionName
    $button.Add_Click({
        $rdpPath = Join-Path $rdpFolder "$($currentSession).rdp"
        if (Test-Path $rdpPath) {
            Start-Process $rdpPath
        }
        else {
            [System.Windows.Forms.MessageBox]::Show("RDP file not found:`n$rdpPath","Error",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }.GetNewClosure())

    $form.Controls.Add($button)
}

# Show the form
[void]$form.ShowDialog()
