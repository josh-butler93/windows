Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "LabNet RDP Launcher"
$form.Size = New-Object System.Drawing.Size(750, 550)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::Black

$rdpFolder = "C:\Launcher"
$sessions = @("test", "server2", "server3", "server4", "server5", "server6", "server7", "server8")

$font = New-Object System.Drawing.Font("Consolas", 12, [System.Drawing.FontStyle]::Bold)
$titleFont = New-Object System.Drawing.Font("Consolas", 18, [System.Drawing.FontStyle]::Bold)

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "LabNet RDP Launcher"
$titleLabel.ForeColor = [System.Drawing.Color]::Lime
$titleLabel.BackColor = [System.Drawing.Color]::Black
$titleLabel.Font = $titleFont
$titleLabel.AutoSize = $true
$form.Controls.Add($titleLabel)

# Delay setting Location until form is shown so sizes are known
$form.Add_Shown({
    # Center title horizontally based on actual widths
    $titleLabel.Location = New-Object System.Drawing.Point( 
        [int]( ($form.ClientSize.Width - $titleLabel.Width) / 2 ), 20)

    # Now we can position buttons below the title safely
    $buttonWidth = 180
    $buttonHeight = 50
    $padding = 15
    $buttonsPerRow = 3
    $startY = $titleLabel.Location.Y + $titleLabel.Height + 20

    for ($i = 0; $i -lt $sessions.Count; $i++) {
        $sessionName = $sessions[$i]

        $button = New-Object System.Windows.Forms.Button
        $button.Text = $sessionName
        $button.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
        $button.ForeColor = [System.Drawing.Color]::Lime
        $button.BackColor = [System.Drawing.Color]::Black
        $button.FlatStyle = 'Flat'
        $button.Font = $font
        $button.FlatAppearance.BorderSize = 1
        $button.FlatAppearance.BorderColor = [System.Drawing.Color]::Lime

        $row = [math]::Floor($i / $buttonsPerRow)
        $col = $i % $buttonsPerRow
        $xPos = $padding + ($col * ($buttonWidth + $padding))
        $yPos = $startY + ($row * ($buttonHeight + $padding))
        $button.Location = New-Object System.Drawing.Point($xPos, $yPos)

        $button.Add_MouseEnter({
            $this.FlatAppearance.BorderSize = 2
            $this.FlatAppearance.BorderColor = [System.Drawing.Color]::LimeGreen
        })
        $button.Add_MouseLeave({
            $this.FlatAppearance.BorderSize = 1
            $this.FlatAppearance.BorderColor = [System.Drawing.Color]::Lime
        })

        $currentSession = $sessionName
        $button.Add_Click({
            $rdpPath = Join-Path $rdpFolder "$($currentSession).rdp"
            if (Test-Path $rdpPath) {
                Start-Process $rdpPath
            } else {
                [System.Windows.Forms.MessageBox]::Show("RDP file not found:`n$rdpPath",
                    "Error",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        }.GetNewClosure())

        $form.Controls.Add($button)
    }
})

[void]$form.ShowDialog()
