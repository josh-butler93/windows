function Get-EventLogCategory {
    $logCategories = @(
        "Application",
        "System",
        "Security",
        "Setup",
        "ForwardedEvents"
    )
    Write-Host "`nChoose a log category to search through:"
    for ($i = 0; $i -lt $logCategories.Count; $i++) {
        Write-Host "$($i+1). $($logCategories[$i])"
    }

    $selection = Read-Host "Enter the number of your choice"
    if ($selection -ge 1 -and $selection -le $logCategories.Count) {
        return $logCategories[$selection - 1]
    } else {
        Write-Host "Invalid selection. Please choose a number between 1 and $($logCategories.Count)."
        return $null
    }
}

function Set-SearchParameters {
    $startTime = Read-Host "Enter the start date (yyyy-mm-dd) or leave blank for no start date"
    $endTime = Read-Host "Enter the end date (yyyy-mm-dd) or leave blank for no end date"
    $maxEvents = Read-Host "How many events would you like to have output?"

    $filterHash = @{}
    if ($startTime) {
        try {
            $filterHash.StartTime = [datetime]::ParseExact($startTime, 'yyyy-MM-dd', $null)
        } catch {
            Write-Host "Invalid start date format. Using no start date."
        }
    }
    if ($endTime) {
        try {
            $filterHash.EndTime = [datetime]::ParseExact($endTime, 'yyyy-MM-dd', $null)
        } catch {
            Write-Host "Invalid end date format. Using no end date."
        }
    }

    return $filterHash, [int]$maxEvents
}

function Save-LogsToFile {
    param (
        [array]$Events
    )
    
    $desktopPath = [Environment]::GetFolderPath('Desktop')
    $fileName = Read-Host "Enter the name of the file to save (without extension)"
    $filePath = "$desktopPath\$fileName.txt"

    $Events | Out-File -FilePath $filePath

    Write-Host "`nLogs saved to $filePath" -ForegroundColor Green
    
    $openFile = Read-Host "Do you want to open the file? (yes/no)"
    if ($openFile -eq 'yes') {
        Start-Process notepad.exe $filePath
    }
}

function Show-Help {
    Write-Host "`nHere are the correct parameters for Get-WinEvent:" -ForegroundColor Yellow
    Get-Help Get-WinEvent -Detailed
}

function MainMenu {
    do {
        Write-Host "`nHello! Would you like to search through event logs? (yes/no)"
        $searchLogs = Read-Host "Enter your choice"
        
        if ($searchLogs -eq 'yes') {
            $logName = $null
            while (-not $logName) {
                $logName = Get-EventLogCategory
            }
            
            $filterHash, $maxEvents = Set-SearchParameters

            Write-Host "`nRetrieving events from $logName log..."

            try {
                # Retrieve events with proper parameters
                if ($maxEvents -gt 0) {
                    $events = Get-WinEvent -LogName $logName -FilterHashtable $filterHash -MaxEvents $maxEvents
                } else {
                    $events = Get-WinEvent -LogName $logName -FilterHashtable $filterHash
                }
                
                $events | Format-Table -AutoSize

                $saveLogs = Read-Host "`nWould you like to save these logs? (yes/no)"
                if ($saveLogs -eq 'yes') {
                    Save-LogsToFile -Events $events
                }
            } catch {
                Write-Host "An error occurred: $_" -ForegroundColor Red
                Show-Help
            }
        }
        
        $continue = Read-Host "`nWould you like to return to the main menu or exit? (menu/exit)"
    } while ($continue -eq 'menu')
}

# Run the main function
MainMenu
