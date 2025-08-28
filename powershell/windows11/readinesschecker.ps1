# Function to check Windows 11 compatibility
function Check-Windows11Compatibility {
    $isCompatible = $true
    $failedRequirements = @()

    # Check Processor
    $cpu = Get-WmiObject -Class Win32_Processor
    $cpuCores = $cpu.NumberOfCores
    $cpuSpeed = $cpu.MaxClockSpeed

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

    <#
    # Check System Firmware (UEFI)
    $firmware = (Get-WmiObject -Class Win32_BIOS).FirmwareType
    if ($firmware -ne "UEFI") {
        $isCompatible = $false
        $failedRequirements += "System Firmware: Must be UEFI."
    }
    #>

    # Check TPM
    # TPM
# Define the UpdateReturnCode function
function UpdateReturnCode {
    param (
        [int]$ReturnCode
    )
    # Logic to handle the return code (e.g., logging, setting a global variable)
    Write-Host "Return code updated to: $ReturnCode"
}

# Main TPM check logic
try {
    $tpm = Get-Tpm

    if ($null -eq $tpm) {
        UpdateReturnCode -ReturnCode 1
        $outObject.returnReason += "TPM is null."
        $outObject.logging += "TPM is null. FAIL"
        $exitCode = 1
    }
    elseif ($tpm.TpmPresent) {
        $tpmVersion = Get-WmiObject -Class Win32_Tpm -Namespace "root\CIMV2\Security\MicrosoftTpm" | Select-Object -Property SpecVersion

        if ($null -eq $tpmVersion.SpecVersion) {
            UpdateReturnCode -ReturnCode 1
            $outObject.returnReason += "TPM version is null."
            $outObject.logging += "TPM version is null. FAIL"
            $exitCode = 1
        }

        $majorVersion = $tpmVersion.SpecVersion.Split(",")[0] -as [int]
        if ($majorVersion -lt 2) {
            UpdateReturnCode -ReturnCode 1
            $outObject.returnReason += "TPM version is less than 2."
            $outObject.logging += "TPM version is $($tpmVersion.SpecVersion). FAIL"
            $exitCode = 1
        }
        else {
            $outObject.logging += "TPM version is $($tpmVersion.SpecVersion). PASS"
            UpdateReturnCode -ReturnCode 0
        }
    }
    else {
        UpdateReturnCode -ReturnCode 1
        $outObject.returnReason += "TPM is not present."
        $outObject.logging += "TPM is not present. FAIL"
        $exitCode = 1
    }
}
catch {
    UpdateReturnCode -ReturnCode -1
    #$outObject.logging += "TPM check failed: " + $_.Exception.Message
    $exitCode = 1
}

<# Output the results
Write-Host "Return Code: $exitCode"
Write-Host "Return Reason: $($outObject.returnReason)"
Write-Host "Log: $($outObject.logging)"
#>
    # Check Graphics Card
    $graphics = Get-WmiObject -Class Win32_VideoController
    if ($graphics.Count -eq 0) {
        $isCompatible = $false
        $failedRequirements += "Graphics Card: A DirectX 12 compatible graphics card is required."
    }

    <#
    # Check Display
    $screenWidth = (Get-WmiObject -Class Win32_DesktopMonitor).ScreenWidth
    $screenHeight = (Get-WmiObject -Class Win32_DesktopMonitor).ScreenHeight
    if ($screenWidth -lt 1280 -or $screenHeight -lt 720) {
        $isCompatible = $false
        $failedRequirements += "Display: Must be greater than 9 inches with HD resolution (720p)."
    }

    # Check Internet Connection
    try {
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
