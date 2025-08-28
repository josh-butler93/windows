# Function to check Windows 11 compatibility
function Check-Windows11Compatibility {
    $isCompatible = $true
    $failedRequirements = @()

    # Check Processor
    $cpu = Get-WmiObject -Class Win32_Processor
    $cpuName = $cpu.Name
    $cpuCores = $cpu.NumberOfCores
    $cpuSpeed = $cpu.MaxClockSpeed

    # Check if CPU is supported (example for Intel and AMD)
    if ($cpuCores -lt 2 -or $cpuSpeed -lt 1000) {
        $isCompatible = $false
        $failedRequirements += "Processor: Must be 1 GHz or faster with at least 2 cores."
    }

    # Check RAM
    $ram = (Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory / 1GB
    if ($ram -lt 4) {
        $isCompatible = $false
        $failedRequirements += "RAM: Must be 4 GB or more."
    }

    # Check Storage
    $storage = (Get-PSDrive C).Used + (Get-PSDrive C).Free
    if ($storage -lt 64GB) {
        $isCompatible = $false
        $failedRequirements += "Storage: Must have 64 GB or larger storage device."
    }

    <# Check System Firmware (UEFI)
    $firmware = (Get-WmiObject -Class Win32_BIOS).FirmwareType
    if ($firmware -ne "UEFI") {
        $isCompatible = $false
        $failedRequirements += "System Firmware: Must be UEFI."
    }

    # Check TPM
    $tpm = Get-WmiObject -Namespace "Root\CIMv2\Security\MicrosoftTpm" -Class Win32_Tpm
    if (-not $tpm) {
        $isCompatible = $false
        $failedRequirements += "TPM: Trusted Platform Module (TPM) version 2.0 is required."
    } elseif ($tpm.SpecVersion -lt "2.0") {
        $isCompatible = $false
        $failedRequirements += "TPM: Must be version 2.0 or higher."
    }
    #>
    
    # Check Graphics Card
    $graphics = Get-WmiObject -Class Win32_VideoController
    if ($graphics.Count -eq 0) {
        $isCompatible = $false
        $failedRequirements += "Graphics Card: A DirectX 12 compatible graphics card is required."
    }

    <# Check Display
    $screenWidth = (Get-WmiObject -Class Win32_DesktopMonitor).ScreenWidth
    $screenHeight = (Get-WmiObject -Class Win32_DesktopMonitor).ScreenHeight
    if ($screenWidth -lt 1280 -or $screenHeight -lt 720) {
        $isCompatible = $false
        $failedRequirements += "Display: Must be greater than 9 inches with HD resolution (720p)."
    }

    # Check Internet Connection
    # This is a basic check to see if the machine can reach a public URL
    <#try {
        $request = Invoke-WebRequest -Uri "http://www.microsoft.com" -UseBasicP -Timeout 5
    } catch {
        $isCompatible = $false
        $failedRequirements += "Internet Connection: Required for updates and features."
    }
#>
    # Output results
    if ($isCompatible) {
        Write-Host "This machine is Windows 11 compatible." -ForegroundColor Green
    } else {
        Write-Host "This machine is NOT Windows 11 compatible." -ForegroundColor Red
        Write-Host "Failed Requirements:" -ForegroundColor Yellow
        foreach ($requirement in $failedRequirements) {
            Write-Host "- $requirement" -ForegroundColor Red
        }
    }
}

# Run the compatibility check
Check-Windows11Compatibility
