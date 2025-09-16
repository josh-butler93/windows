# WSUS Matrix GUI - PowerShell (Updated so the window stays open after running commands)
# Save as WsUs-MatrixGui-StayOpen.ps1 and run. Script will attempt to elevate if not running as admin.

# Elevation check and relaunch if necessary
function Ensure-Elevated {
    $current = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $current.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $ps = (Get-Process -Id $PID).Path
        $args = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        Start-Process -FilePath $ps -ArgumentList $args -Verb RunAs
        Exit
    }
}

Ensure-Elevated

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "WSUS Matrix Control"
$form.Size = New-Object System.Drawing.Size(620,420)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::Black
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.MinimizeBox = $false

# Title label
$lbl = New-Object System.Windows.Forms.Label
$lbl.Text = "WSUS Client Controls"
$lbl.AutoSize = $true
$lbl.ForeColor = [System.Drawing.Color]::Lime
$lbl.Font = New-Object System.Drawing.Font("Consolas",16,[System.Drawing.FontStyle]::Bold)
$lbl.Location = New-Object System.Drawing.Point(14,10)
$form.Controls.Add($lbl)

# Output textbox (multi-line)
$txtOut = New-Object System.Windows.Forms.TextBox
$txtOut.Multiline = $true
$txtOut.ScrollBars = "Vertical"
$txtOut.ReadOnly = $true
$txtOut.WordWrap = $false
$txtOut.BackColor = [System.Drawing.Color]::Black
$txtOut.ForeColor = [System.Drawing.Color]::Lime
$txtOut.Font = New-Object System.Drawing.Font("Consolas",10)
$txtOut.Location = New-Object System.Drawing.Point(14,60)
$txtOut.Size = New-Object System.Drawing.Size(580,260)
$form.Controls.Add($txtOut)

# Helper to append text (invoked on UI thread)
function Append-Output {
    param($text)
    # Ensure UI thread appends safely
    if ($txtOut.InvokeRequired) {
        $txtOut.Invoke( { param($t) 
            $now = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            $txtOut.AppendText("$now`t$t`r`n")
            $txtOut.SelectionStart = $txtOut.Text.Length
            $txtOut.ScrollToCaret()
        } , $text) | Out-Null
    } else {
        $now = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        $txtOut.AppendText("$now`t$text`r`n")
        $txtOut.SelectionStart = $txtOut.Text.Length
        $txtOut.ScrollToCaret()
    }
}

# Function to start a job that runs wuauclt and then signals back via event handler
function Start-WuaucltJob {
    param([string]$arguments)

    Append-Output "Starting job: wuauclt.exe $arguments"

    # Start the job (runs asynchronously)
    $job = Start-Job -ScriptBlock {
        param($a)
        try {
            # Use Start-Process so wuauclt runs and returns quickly in many cases.
            $p = Start-Process -FilePath "wuauclt.exe" -ArgumentList $a -NoNewWindow -WindowStyle Hidden -PassThru -Wait -ErrorAction Stop
            $code = $p.ExitCode
            return @{ Result = "ExitCode:$code"; Args = $a }
        } catch {
            return @{ Result = "ERROR:$($_.Exception.Message)"; Args = $a }
        }
    } -ArgumentList $arguments

    # Register an event to capture when the job state changes to Completed/Failed/Stopped
    $action = {
        param($sender, $eventArgs)
        $jb = $eventArgs.Job
        if ($jb.State -in "Completed","Failed","Stopped") {
            # Retrieve results (safe to call Receive-Job once)
            try {
                $res = Receive-Job -Job $jb -ErrorAction SilentlyContinue
            } catch {
                $res = @{ Result = "ERROR:Failed to receive job output"; Args = $arguments }
            }
            # Append output on the UI thread
            foreach ($item in @($res)) {
                if ($null -ne $item) {
                    Append-Output "Job finished for args: $($item.Args) -> $($item.Result)"
                } else {
                    Append-Output "Job finished but returned no output."
                }
            }
            # Clean up: unregister event and remove job
            try {
                Unregister-Event -SourceIdentifier "JobStateChanged_$($jb.Id)" -ErrorAction SilentlyContinue
            } catch {}
            Remove-Job -Job $jb -Force -ErrorAction SilentlyContinue
        }
    }

    # Unique event name per job
    $eventName = "JobStateChanged_$($job.Id)"
    Register-ObjectEvent -InputObject $job -EventName StateChanged -SourceIdentifier $eventName -Action $action | Out-Null

    Append-Output "Job [$($job.Id)] started (asynchronous). Window will remain open."
}

# Create buttons and map to actions (window will not close when a button is clicked)
$btnSpecs = @(
    @{Text="Detect Now";        Args="/detectnow";                         Loc= New-Object System.Drawing.Point(14,330)}
    @{Text="Report Now";        Args="/reportnow";                         Loc= New-Object System.Drawing.Point(154,330)}
    @{Text="Reset Auth";        Args="/resetauthorization";                Loc= New-Object System.Drawing.Point(294,330)}
    @{Text="Detect + Report";   Args="/detectnow /reportnow";             Loc= New-Object System.Drawing.Point(434,330)}
    @{Text="Reset + Detect";    Args="/resetauthorization /detectnow";    Loc= New-Object System.Drawing.Point(14,370)}
    @{Text="Clear Output";      Args="CLEAR";                             Loc= New-Object System.Drawing.Point(154,370)}
    @{Text="Close";             Args="CLOSE";                             Loc= New-Object System.Drawing.Point(294,370)}
)

foreach ($spec in $btnSpecs) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $spec.Text
    $btn.Size = New-Object System.Drawing.Size(120,28)
    $btn.Location = $spec.Loc
    $btn.Font = New-Object System.Drawing.Font("Consolas",9,[System.Drawing.FontStyle]::Bold)
    $btn.ForeColor = [System.Drawing.Color]::Black
    $btn.BackColor = [System.Drawing.Color]::Lime

    $btn.Add_Click({
        $arg = $spec.Args
        switch ($arg) {
            "CLEAR" { $txtOut.Clear() ; return }
            "CLOSE" { $form.Close() ; return }
            default {
                Append-Output "-> Queuing: $arg"
                Start-WuaucltJob -arguments $arg
            }
        }
    })
    $form.Controls.Add($btn)
}

# Decorative "matrix" animated effect (optional subtle)
$rand = New-Object System.Random
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 500
$timer.Add_Tick({
    if ($rand.Next(0,10) -gt 7) {
        $lbl.ForeColor = [System.Drawing.Color]::FromArgb(0,255,0)
        $lbl.Text = "WSUS Client Controls"
    } else {
        $lbl.ForeColor = [System.Drawing.Color]::Lime
    }
})
$timer.Start()

# Show initial usage info
Append-Output "WSUS Matrix GUI started."
Append-Output "Available commands:"
Append-Output "  wuauclt.exe /detectnow"
Append-Output "  wuauclt.exe /reportnow"
Append-Output "  wuauclt.exe /resetauthorization"
Append-Output "  wuauclt.exe /detectnow /reportnow"
Append-Output "  wuauclt.exe /resetauthorization /detectnow"

# Run the form (this keeps the UI open until the user closes it)
[void]$form.ShowDialog()
