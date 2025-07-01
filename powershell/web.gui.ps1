Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Remote Desktop Launcher - LabNet"
$form.Size = New-Object System.Drawing.Size(400, 300)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false

# Path where your .rdp files are stored
$rdpFolder = "C:\Launcher"

# Define your session names (without .rdp extension)
$sessions = @("server1", "server2", "server3", "server4", "server5", "server6")

# Layout variables
$buttonWidth = 120
$buttonHeight = 30
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
    $button.Location = New-Object System.Drawing.Point(
        $padding + ($col * ($buttonWidth + $padding)),
        $padding + ($row * ($buttonHeight + $padding))
    )

    # Button click event to launch RDP file
    $button.Add_Click({
        $rdpPath = Join-Path $rdpFolder "$($sessionName).rdp"
        if (Test-Path $rdpPath) {
            Start-Process $rdpPath
        }
        else {
            [System.Windows.Forms.MessageBox]::Show("RDP file not found:`n$rdpPath","Error",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })

    $form.Controls.Add($button)
}

# Show the form
[void]$form.ShowDialog()
