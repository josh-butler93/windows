function Show-Menu {
    param (
        [string]$Title,
        [string[]]$Options
    )

    Write-Host $Title
    $i = 1
    foreach ($option in $Options) {
        Write-Host "$i. $option"
        $i++
    }
    Write-Host "0. Exit"
}

function Get-ServicesByType {
    param (
        [string]$Type
    )

    switch ($Type) {
        'Running' { return Get-Service | Where-Object { $_.Status -eq 'Running' } }
        'Stopped' { return Get-Service | Where-Object { $_.Status -eq 'Stopped' } }
        default { Write-Host "Invalid type"; return @() }
    }
}

function Search-Service {
    param (
        [string]$Type
    )

    $services = Get-ServicesByType -Type $Type
    if ($services.Count -eq 0) {
        Write-Host "No services found for type $Type."
        return
    }

    Write-Host "Select a service from the list:"
    $services | Format-Table -Property Name, DisplayName, Status

    $searchName = Read-Host "Enter the name of the service to search for"
    $service = $services | Where-Object { $_.Name -eq $searchName }

    if ($service) {
        $service | Format-Table -Property Name, DisplayName, Status
    } else {
        Write-Host "Service '$searchName' not found."
    }
}

do {
    Show-Menu -Title "Main Menu" -Options @("View Running Services", "View Stopped Services", "Exit")
    $choice = Read-Host "Enter your choice"

    switch ($choice) {
        '1' {
            do {
                Search-Service -Type 'Running'
                $returnToMenu = Read-Host "Enter 'M' to return to the main menu or 'E' to exit"
            } while ($returnToMenu -eq 'E')
        }
        '2' {
            do {
                Search-Service -Type 'Stopped'
                $returnToMenu = Read-Host "Enter 'M' to return to the main menu or 'E' to exit"
            } while ($returnToMenu -eq 'E')
        }
        '0' {
            Write-Host "Exiting..."
            exit
        }
        default {
            Write-Host "Invalid choice. Please select again."
        }
    }
} while ($true)
