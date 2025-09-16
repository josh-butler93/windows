function Show-ProcessMenu {
    param (
        [string]$Title = "Process Menu"
    )

    Clear-Host
    Write-Host "$Title" -ForegroundColor Cyan
    Write-Host "1: List All Processes Alphabetically"
    Write-Host "2: List Processes by Specific Letter"
    Write-Host "3: Search for a Specific Process"
    Write-Host "4: Return to Main Menu"
    Write-Host "5: Exit"
}

function List-AllProcessesAlphabetically {
    Clear-Host
    Write-Host "All Processes (Grouped Alphabetically):" -ForegroundColor Cyan

    $processes = Get-Process | Sort-Object Name
    $currentLetter = ""
    $global:i = 0

    $processes | ForEach-Object {
        $firstLetter = $_.Name.Substring(0, 1).ToUpper()

        if ($firstLetter -ne $currentLetter) {
            if ($currentLetter -ne "") {
                Write-Host "`n"
            }
            $currentLetter = $firstLetter
            Write-Host "Processes starting with '$currentLetter':" -ForegroundColor Yellow
        }

        [PSCustomObject]@{
            Number = $global:i++
            Name = $_.Name
            Id = $_.Id
            CPU = $_.CPU
            MemoryUsage = $_.WorkingSet
        } | Format-Table -HideTableHeaders -AutoSize
    }

    Write-Host "`nEnter the number of the process to view more details:"
    $processNumber = [int] (Read-Host)

    if ($processNumber -ge 0 -and $processNumber -lt $processes.Count) {
        $selectedProcess = $processes[$processNumber]
        Clear-Host
        Write-Host "Process Details:" -ForegroundColor Cyan
        $selectedProcess | Format-List -Property Name, Id, CPU, WorkingSet, StartTime, Path
    } else {
        Write-Host "Invalid process number." -ForegroundColor Red
    }

    Pause
}

function List-ProcessesByLetter {
    Clear-Host
    Write-Host "Enter the letter to list processes that start with it:"
    $letter = Read-Host

    if ($letter.Length -ne 1) {
        Write-Host "Please enter a single letter." -ForegroundColor Red
        Pause
        return
    }

    $letter = $letter.ToUpper()
    $processes = Get-Process | Where-Object { $_.Name.Substring(0, 1).ToUpper() -eq $letter } | Sort-Object Name

    if ($processes.Count -eq 0) {
        Write-Host "No processes found starting with '$letter'." -ForegroundColor Red
    } else {
        Write-Host "Processes starting with '$letter':" -ForegroundColor Yellow
        $global:i = 0

        $processes | ForEach-Object {
            [PSCustomObject]@{
                Number = $global:i++
                Name = $_.Name
                Id = $_.Id
                CPU = $_.CPU
                MemoryUsage = $_.WorkingSet
            }
        } | Format-Table -AutoSize

        Write-Host "`nEnter the number of the process to view more details:"
        $processNumber = [int] (Read-Host)

        if ($processNumber -ge 0 -and $processNumber -lt $processes.Count) {
            $selectedProcess = $processes[$processNumber]
            Clear-Host
            Write-Host "Process Details:" -ForegroundColor Cyan
            $selectedProcess | Format-List -Property Name, Id, CPU, WorkingSet, StartTime, Path
        } else {
            Write-Host "Invalid process number." -ForegroundColor Red
        }
    }

    Pause
}

function Search-Process {
    Clear-Host
    Write-Host "Enter the process name to search (use * for wildcard):"
    $searchName = Read-Host

    if ($searchName -like "*") {
        $processes = Get-Process | Where-Object { $_.Name -like $searchName }
    } else {
        $processes = Get-Process | Where-Object { $_.Name -eq $searchName }
    }

    if ($processes) {
        $processes | Format-Table -Property Name, Id, CPU, WorkingSet
        Write-Host "`nEnter the number of the process to view more details:"
        $processNumber = [int] (Read-Host)

        if ($processNumber -ge 0 -and $processNumber -lt $processes.Count) {
            $selectedProcess = $processes[$processNumber]
            Clear-Host
            Write-Host "Process Details:" -ForegroundColor Cyan
            $selectedProcess | Format-List -Property Name, Id, CPU, WorkingSet, StartTime, Path
        } else {
            Write-Host "Invalid process number." -ForegroundColor Red
        }
    } else {
        Write-Host "Process not found." -ForegroundColor Red
    }

    Pause
}

function Pause {
    Write-Host "`nPress any key to continue..."
    [void][System.Console]::ReadKey($true)
}

$i = 0
while ($true) {
    Show-ProcessMenu
    $choice = Read-Host "Choose an option"

    switch ($choice) {
        1 { List-AllProcessesAlphabetically }
        2 { List-ProcessesByLetter }
        3 { Search-Process }
        4 { break }
        5 { exit }
        default { Write-Host "Invalid choice" -ForegroundColor Red }
    }
}
