<# 
	1. PowerCLI single session Config: 

		command: Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Scope Session 
		
	
	2. Verify Session Parameters: 
	
		command: Get-PowerCLIConfiguration
		
			a. once the session is set up run the script and connect to the vCenter server

	3. (Optional) Prevent the script from outputting code to the console

		$null = $function:__init  # Optional, ensures no initialization code output.
#>

if ($PSVersionTable.PSVersion.Major -lt 7) {
	# Locate the PowerShell 7 executable (pwsh)
	$pwshPath = (Get-Command pwsh -ErrorAction SilentlyContinue).Path
	
	if ($pwshPath) {
		Write-Host "Detected an older version of PowerShell. Restarting this script in PowerShell 7 as Administrator..."
		# Get the current script's path
		$scriptPath = $MyInvocation.MyCommand.Path
		
		# Build the argument list, including any additional arguments passed to the script.
		$arguments = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $scriptPath) + $args
		
		# Start a new PowerShell 7 process with elevated privileges in a separate window
		Start-Process -FilePath $pwshPath -ArgumentList $arguments -Verb RunAs -WindowStyle Normal
		
		# Exit the current session
		exit
	}
	else {
		Write-Error "This script requires PowerShell 7, but it was not found on this machine."
		Pause
		exit 1
	}
}

$line  = '==========================================================================================='
$line2 = '___________________________________________________________________________________________' #spacing 
$line3 = '-------------------------------------------------------------------------------------------'

# Loop to display menu and execute based on user input
do {
    #Clear the screen ( Used to clear any previous output)
    #Clear-Host

    # Display the menu (this part is fine, you want to show this)
    Write-Host ''
    Write-Host "$line" -ForegroundColor Green 
    Write-Host '                         VMWare Services Section ( v 2.0 )' -ForegroundColor Green 
    Write-Host "$line" -ForegroundColor Green 
    Write-Host '-------------------------------------------------------------------------------------------' 
    Write-Host '                           VMWare | Domain | Services' -ForegroundColor Green
    Write-Host '-------------------------------------------------------------------------------------------' 
    Write-Host ' 1 - Connect to vCenter                           18 - List snapshots for a VM' 
    Write-Host ' 2 - VM Details                                   19 - Revert to a snapshot' 
    Write-Host ' 3 - Information about a specific VM              20 - Change the number of CPUs on a VM' 
    Write-Host ' 4 - List VMs with their resource usage	          21 - Change the amount of memory on a VM' 
    Write-Host ' 5 - Create VM snapshot                           22 - Add a new network adapter to a VM' 
    Write-Host ' 6 - Get information about VM snapshots           23 - Add a new hard disk to a VM' 
    Write-Host ' 7 - Delete VM snapshot                           24 - Convert a VM to a template' 
    Write-Host ' 8 - Create a new VM                              25 - Deploy a VM from a template' 
    Write-Host ' 9 - Clone a VM                                   26 - Export a VM (OVF format)' 
    Write-Host '10 - Create a VM from a template                  27 - Import a VM (OVF format)' 
    Write-Host '11 - Create a VM with additional settings         28 - Migrate a VM to another host' 
    Write-Host '12 - Power on a VM                                29 - Migrate a VM to a different datastore' 
    Write-Host '13 - Power off a VM                               30 - Increase CPU allocation for a VM' 
    Write-Host '14 - Suspend a VM                                 31 - Increase memory allocation for a VM' 
    Write-Host '15 - Restart a VM                                 32 - Get CPU and Memory usage for all VMs' 
    Write-Host '16 - Upgrade VMware Tools                         33 - Get performance data for a VM'
    Write-Host '17 - Disconnect from vCenter                      34 - Get performance data for a VM' 
    Write-Host '-------------------------------------------------------------------------------------------' -ForegroundColor Red
    Write-Host '0  - Quit' -ForegroundColor Red
    Write-Host '-------------------------------------------------------------------------------------------' -ForegroundColor Red
    Write-Host ''

    $input = Read-Host 'Select'

    switch ($input) {
        '1' { 
            Write-Host 'Connecting to vCenter...'
            $vCenterServer = Read-Host 'Enter vCenter Server <ip or hostname>'
            $username = Read-Host 'Enter username'
            $password = Read-Host 'Enter user credentials'
            Connect-VIServer -Server $vCenterServer -Protocol https -User $username -Password $password
            Write-Host ''
            Write-Host 'Connecting to vCenter...'

            Write-Host ''
        }
        '2' { 
            # Display menu or a prompt to the user
            Write-Host 'Getting information about a specific VM...'
            Write-Host ''
            
            # Prompt for VM Name
            $vmName = Read-Host 'Enter VM Name'

            Write-Host ''
    
            # Assuming you have a list of VMs, you'd filter or find the matching VM
            # For example, assuming you have an array or collection of VM objects
            $vm = Get-VM -Name $vmName | Select-Object Name, PowerState, CPU, MemoryGB  # This is just an example of getting a VM object
            
            # Write-Host ''
            # Display the information about the VM
            Write-Host "VM Name: $($vm.Name)"
            #Write-Host ''
            Write-Host "PowerState: $($vm.PowerState)"
            #Write-Host ''
            Write-Host "CPU: $($vm.Cpu)"
            #Write-Host ''
            Write-Host "Memory: $($vm.MemoryGB) GB"
            
            Write-Host ''
            <# You can add logic here to continue or break the loop based on user input or conditions
               $continue = Read-Host 'Do you want to search for another VM? (y/n)'
            ########## Continue Portion Needs work
            #>
		}
        '3' { 
            Write-Host 'Getting VM Details...'
            Write-Host ''
            # Prompt user for the VM Name
            $vmName = Read-Host 'Enter VM Name'

            Write-Host ''

            # Get Details and VM Guest information, then display the results
            $vmInfo = Get-VM -Name $vmName | Get-VMGuest

            # Check if VM was found
            if ($vmInfo) {
            Write-Host "VM Name: $($vmInfo.Name)"
            Write-Host "VM Guest OS: $($vmInfo.Guest.OSFullName)"
            Write-Host "VM Power State: $($vmInfo.VM.PowerState)"
            Write-Host "VM IP Address: $($vmInfo.IPAddress)"
            Write-Host ''
            } else {
            Write-Host "VM not found with the name '$vmName'."
            }

            Write-Host ''
            <#Ask user if they want to search for another VM
            $continue = Read-Host 'Do you want to search for another VM? (y/n)'
            !!! Continue Portion Needs Work
			#>
        }
        '4' { 
            Write-Host 'Listing VMs with their resource usage...'
            Write-Host ''
            #Prompt User for VM Name
            $vmName = Read-Host 'Enter VM Name'

            Write-Host ''

            # Get VM and extract resource usage information
            $vmInfo = Get-VM -Name $vmName | Select-Object Name,
                @{Name="CPU Usage (MHz)";Expression={($_.ExtensionData.Summary.QuickStats.OverallCpuUsage)}}, 
                @{Name="Memory Usage (MB)";Expression={($_.ExtensionData.Summary.QuickStats.GuestMemoryUsage)}},
                @{Name="Uptime (Days)";Expression={([datetime]::Now - $_.ExtensionData.Summary.Runtime.BootTime).Days}},
                @{Name="Power State";Expression={$_.PowerState}},
                @{Name="IP Address";Expression={($_.Guest.IPAddress -join ', ')}} 

            # Check if VM was found
            if ($vmInfo) {
            Write-Host "VM Name: $($vmInfo.Name)"
            Write-Host "CPU Usage: $($vmInfo.'CPU Usage (MHz)') MHz"
            Write-Host "Memory Usage: $($vmInfo.'Memory Usage (MB)') MB"
            Write-Host "Uptime: $($vmInfo.'Uptime (Days)') days"
            Write-Host "Power State: $($vmInfo.'Power State')"
            Write-Host "IP Address: $($vmInfo.'IP Address')"
            } else {
            Write-Host "VM not found with the name '$vmName'."
            ############### Continue Portion Needs Work
            }

            Write-Host ''
            <# Ask User if the want to search for another VM
            $continue = Read-Host 'Do you want to search for another VM? (y/n)'
            !!!Continue Portion Needs work
			#>
        }
        '5' { 
            Write-Host 'Creating VM Snapshot'

            # Prompt User for VM Name
            $vmName = Read-Host 'Enter VM Name...'

            Write-Host ''

            # Check if the VM exists before proceeding
            $vm = Get-VM $vmName -ErrorAction SilentlyContinue
            if ($vm -eq $null) {
            Write-Host "VM '$vmame' not found. Please try again."
            #$continue = Read-Host 'Do you want to try another VM? (y/n)'
            #continue
            }
            
            # Prompt for snapshot details
            $snapshotName = Read-Host 'Enter Snapshot Name'
            $snapshotDescription = 'Enter Snapshot Description'

            try {
            # Create snapshot
            New-Snapshot -VM $vm -Name $snapshotName -Description $snapshotDescription
            Write-Host "Snapshot '$snapshotName' created successfully for vm '$vmName'."
            } 
            catch {
            Write-Host "Error creating snapshot: $_"
            } 

            Write-Host ''
            <# Ask user if they want to create another snapshot
            #$continue = Read-Host 'Do you want to create another snapshot? (y/n)'
            !!!Continue Portion needs work
			#>
        }
        '6'{ 
           Write-Host 'Getting information about VM snapshots...'
           Write-Host ''

           # Prompt for the VM name
           $vmName = Read-Host 'Enter VM Name'

           Write-Host ''

           # Get the snapshots for the specified VM and output them to the console
           try {
               $snapshots = Get-Snapshot -VM $vmName
               # Check if any snapshots were found
               if ($snapshots -and $snapshots.Count -gt 0) {
                   Write-Host ''
                   Write-Host "Snapshots for VM '$vmName':"
                   $snapshots | Format-Table -Property Name, Created, Description
               } else {
                   Write-Host "No snapshots found for VM '$vmName'."
               }
           } catch {
               Write-Host "Error: $_"
           }
        
            Write-Host ''
        } 
        '7' { 
            Write-Host 'Deleting VM snapshot...'

            # Prompt for the VM and snapshot names
            $vmName = Read-Host 'Enter VM Name'
            $snapshotName = Read-Host 'Enter Snapshot Name'

            # Attempt to delete the snapshot
            try {
                # Remove the snapshot
                Remove-Snapshot -VM $vmName -Name $snapshotName -Confirm:$false

                # Output success message
                Write-Host "Snapshot '$snapshotName' for VM '$vmName' has been deleted successfully."
            } catch {
                # In case of an error (snapshot not found, permission issues, etc.)
                Write-Host "Error: $_"
            }

        }
        '8' { 
            Write-Host 'Creating a new VM...'
            Write-Host ''

            # Prompt for the VM name
            $vmName = Read-Host 'Enter VM Name'

            Write-Host ''

            # Attempt to create the VM
            try {
                # Create the VM
                $newVM = New-VM -Name $vmName -ResourcePool "Resources" -Datastore "datastore1" -MemoryGB 4 -NumCpu 2 -DiskGB 50

                # Output success message with VM details
                Write-Host
                Write-Host "New VM '$vmName' has been created successfully with the following details:"
                Write-Host "  - Resource Pool: Resources"
                Write-Host "  - Datastore: datastore1"
                Write-Host "  - Memory: 4 GB"
                Write-Host "  - CPUs: 2"
                Write-Host "  - Disk Size: 50 GB"
                Write-Host "VM Power State: $($newVM.PowerState)"
            } catch {
                # In case of an error (e.g., resource allocation failure, permission issues, etc.)
                Write-Host "Error: $_"
            }

            Write-Host ''
        }
        '9' { 
            Write-Host 'Cloning a VM...'
            Write-Host ''

            # Prompt for the source VM and clone name
            $vmName = Read-Host 'Enter VM Name'
            $cloneName = Read-Host 'Enter Clone Name'

            Write-Host ''

            # Attempt to clone the VM
            try {
                # Clone the VM
                $clonedVM = New-VM -Name $cloneName -VM $vmName -Clone

                # Output success message with the clone details
                Write-Host ''
                Write-Host "VM '$vmName' has been successfully cloned to '$cloneName'."
                Write-Host "The new VM '$cloneName' has the following properties:"
                Write-Host "  - Original VM: $vmName"
                Write-Host "  - Clone Name: $cloneName"
                Write-Host "VM Power State: $($clonedVM.PowerState)"
            } catch {
                # In case of an error (e.g., cloning issues, permissions, etc.)
                Write-Host "Error: $_"
            }

            Write-Host ''
        }
        '10'{ 
            Write-Host 'Creating a VM from template...'
            Write-Host ''
            
            # Prompt for the template and new VM names
            $templateName = Read-Host 'Enter Template Name'
            $newVMName = Read-Host 'Enter New VM Name'

            Write-Host ''
    
            # Attempt to create the VM from the template
            try {
                # Create the VM from the template
                $newVM = New-VM -Name $newVMName -Template $templateName -Datastore "datastore1"

                # Output success message with the VM details
                Write-Host ''
                Write-Host "New VM '$newVMName' has been created successfully from the template '$templateName'."
                Write-Host "The new VM '$newVMName' has the following details:"
                Write-Host "  - Template: $templateName"
                Write-Host "  - Datastore: datastore1"
                Write-Host "VM Power State: $($newVM.PowerState)"
            } catch {
                # In case of an error (e.g., template not found, permissions, resource allocation issues, etc.)
                Write-Host "Error: $_"
            }

            Write-Host ''
        }
        '11'{ 
            Write-Host 'Creating VM with additional settings...'
            Write-Host ''

            # Prompt for the VM name, additional memory, and CPUs
            $vmName = Read-Host 'Enter VM Name'
            $additionalMemory = Read-Host 'Enter Additional Memory in GB'
            $additionalCPUs = Read-Host 'Enter Additional CPUs'

            Write-Host ''

            # Attempt to apply additional settings to the VM
            try {
                # Get the VM and set additional memory and CPUs
                $vm = Get-VM -Name $vmName
            if ($vm) {
                # Apply memory and CPU changes
                Set-VM -VM $vm -MemoryGB ($vm.MemoryGB + $additionalMemory) -NumCpu ($vm.NumCpu + $additionalCPUs)

                # Output success message with updated VM details
                Write-Host ''
                Write-Host "The settings for VM '$vmName' have been updated successfully."
                Write-Host "Updated VM details:"
                Write-Host "  - Memory: $($vm.MemoryGB + $additionalMemory) GB"
                Write-Host "  - CPUs: $($vm.NumCpu + $additionalCPUs)"
            } else {
                Write-Host "Error: VM '$vmName' not found."
            }
         } catch {
            # In case of an error (e.g., invalid input or issues applying settings)
            Write-Host "Error: $_"
         }
        
            Write-Host ''
        }
        '12'{ 
            Write-Host 'Powering on a VM...'
            Write-Host ''

            # Prompt for the VM name
            $vmName = Read-Host 'Enter VM Name'

            Write-Host ''

            # Attempt to power on the VM
            try {
                # Start the VM
                Start-VM -VM $vmName

                # Output success message
                Write-Host ''
                Write-Host "VM '$vmName' has been powered on successfully."
            } catch {
                # In case of an error (e.g., VM not found, permissions, etc.)
                Write-Host "Error: $_"
            }

            Write-Host ''
        }
        '13'{ 
            Write-Host 'Powering off a VM...'
            Write-Host ''

            # Prompt for the VM name
            $vmName = Read-Host 'Enter VM Name'

            Write-Host ''

            # Attempt to power on the VM
            try {
                # Start the VM
                Shutdown-VMGuest -VM $vmName

                # Output success message
                Write-Host ''
                Write-Host "VM '$vmName' has been powered off successfully."
            } catch {
                # In case of an error (e.g., VM not found, permissions, etc.)
                Write-Host "Error: $_"
            }

           Write-Host ''
        
        }
        '14' { 
            Write-Host 'Suspending a VM...'
            Write-Host ''

            # Prompt for the VM name
            $vmName = Read-Host 'Enter VM Name'

            Write-Host ''

            # Attempt to suspend the VM
            try {
                # Suspend the VM
                Suspend-VM -VM $vmName

                # Output success message
                Write-Host "VM '$vmName' has been successfully suspended."
            } catch {
                # In case of an error (e.g., VM not found, already suspended, permission issues)
                Write-Host "Error: $_"
            }

            Write-Host ''

        }
        '15'{ 
            Write-Host 'Restarting a VM...'
            Write-Host ''

            # Prompt for the VM name
            $vmName = Read-Host 'Enter VM Name'

            Write-Host ''

            # Attempt to restart the VM
            try {
                # Restart the VM
                Restart-VM -VM $vmName

                # Output success message
                Write-Host ''
                Write-Host "VM '$vmName' has been successfully restarted."
            } catch {
                # In case of an error (e.g., VM not found, permissions, VM state issues)
                Write-Host "Error: $_"
            }

            Write-Host ''
        
        }
        '16'{ 
            Write-Host 'Upgrading VMware Tools...'

            # Prompt for the VM name
            $vmName = Read-Host 'Enter VM Name'

            Write-Host ''

            # Attempt to upgrade VMware Tools
            try {
                # Update VMware Tools
                Update-VMTools -VM $vmName

                # Output success message
                Write-Host "VMware Tools for VM '$vmName' have been successfully upgraded."
            } catch {
                # In case of an error (e.g., VM not found, permissions, VMware Tools not upgradable)
                Write-Host "Error: $_"
            }

            Write-Host ''
        
        }
        '17'{ 
            Write-Host 'Disconnecting from vCenter Server...'
            Write-Host ''

            # Prompt for the vCenter server name or address
            $vCenterServer = Read-Host 'Enter vCenter Server'

            Write-Host ''

            <# Use try-catch to handle errors
            #try {
                 Check if the vCenter server is already disconnected
                 $server = Get-VIServer -Name $vCenterServer -ErrorAction SilentlyContinue
                 if ($server) {
                     Attempt to disconnect from the vCenter server
                    #>
                    Disconnect-VIServer -Server $vCenterServer -Force -Confirm:$false -ErrorAction Stop
                    Write-Host "Successfully disconnected from vCenter server '$vCenterServer'."
                <#} else {
                    Write-Host "vCenter server '$vCenterServer' is not currently connected."
                }
                 catch {
                   If an error occurs, display the error message
                #>
                Write-Host "Error: Failed to disconnect from vCenter server '$vCenterServer'."
                Write-Host "Details: $_"
            #}

            Write-Host ''
            
        }
        '18'{ 
            Write-Host 'Listing snapshots for a VM...'
            Write-Host ''

            # Prompt for the VM name
            $vmName = Read-Host 'Enter VM Name'

            Write-Host ''

            # Attempt to get snapshots for the VM
            try {
                # Get snapshots for the specified VM
                $snapshots = Get-Snapshot -VM $vmName

            if ($snapshots) {
                # If snapshots exist, display them
                Write-Host "Snapshots for VM '$vmName':"
                $snapshots | ForEach-Object { Write-Host "  - Snapshot Name: $($_.Name), Created: $($_.Created), State: $($_.State)" }
            } else {
                # If no snapshots are found
                Write-Host "No snapshots found for VM '$vmName'."
            }
        } catch {
            # In case of an error (e.g., VM not found, permissions, or other issues)
            Write-Host "Error: $_"
        }

       Write-Host ''
    
        }
        '19'{ 
            Write-Host 'Reverting to a snapshot...'
            Write-Host ''

            # Prompt for the VM name and snapshot name
            $vmName = Read-Host 'Enter VM Name'
            $snapshotName = Read-Host 'Enter Snapshot Name'

            Write-Host ''

            # Attempt to revert to the snapshot
            try {
                # Revert to the snapshot
                Set-VM -VM $vmName -Snapshot $snapshotName -Confirm:$false

                # Output success message
                Write-Host "VM '$vmName' has been successfully reverted to snapshot '$snapshotName'."
            } catch {
                # In case of an error (e.g., VM or snapshot not found, permission issues, or invalid snapshot state)
                Write-Host "Error: $_"
            }

            Write-Host ''

        }
        '20'{ 
            Write-Host 'Changing the number of CPUs on a VM...'
            Write-Host ''

            # Prompt for the VM name
            $vmName = Read-Host 'Enter VM Name'

            Write-Host ''

            # Check if the VM exists
            $vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue
            if ($vm -eq $null) {
                Write-Host "Error: VM '$vmName' does not exist."
            } else {
                # Prompt for the new CPU count
                $cpuCount = Read-Host 'Enter New CPU Count'

                # Validate the CPU count (must be a positive integer)
            if ($cpuCount -lt 1 -or $cpuCount -gt 128) {
                Write-Host "Error: CPU count must be between 1 and 128."
            } else {
                # Use try-catch to handle errors
            try {
                # Attempt to set the number of CPUs on the VM
                Set-VM -VM $vmName -NumCpu $cpuCount -ErrorAction Stop

                # If successful, print a success message
                Write-Host "Successfully changed the number of CPUs for VM '$vmName' to $cpuCount."
            } catch {
                # If an error occurs, display the error message
                Write-Host "Error: Failed to change the CPU count for VM '$vmName'."
                Write-Host "Details: $_"
                }
            }
          }
       
          Write-Host ''
       
        }
        '21'{ 
            Write-Host 'Changing the amount of memory on a VM...'
            Write-Host ''

            # Prompt for the VM name
            $vmName = Read-Host 'Enter VM Name'
            # Prompt for the new memory size in GB
            $memorySize = Read-Host 'Enter New Memory Size in GB'

            Write-Host ''

            # Validate that the entered memory size is a positive number
            if (-not [int]::TryParse($memorySize, [ref]$null) -or $memorySize -lt 1) {
                Write-Host "Error: Please enter a valid positive integer for memory size in GB."
            } else {
                # Use try-catch to handle errors
            try {
                # Attempt to set the memory size for the VM
                Set-VM -VM $vmName -MemoryGB $memorySize -ErrorAction Stop

                # If successful, print a success message
                Write-Host ''
                Write-Host "Successfully changed the memory size for VM '$vmName' to $memorySize GB."
            } catch {
                # If an error occurs, display the error message
                Write-Host "Error: Failed to change the memory size for VM '$vmName'."
                Write-Host "Details: $_"
            }
        }

            Write-Host ''
        }
        '22'{ 
            Write-Host 'Adding a new network adapter to a VM...'
            Write-Host ''

            # Prompt for the VM name
            $vmName = Read-Host 'Enter VM Name'

            Write-Host ''
            
            # Check if the VM exists
            $vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue
            if ($vm -eq $null) {
                Write-Host "Error: VM '$vmName' does not exist."
            } else {
                # Use try-catch to handle errors
                try {
                    # Attempt to add a new network adapter to the VM
                    New-NetworkAdapter -VM $vmName -NetworkName "VM Network" -Type vmxnet3 -ErrorAction Stop
            
                    # If successful, print a success message
                    Write-Host "Successfully added a new network adapter to VM '$vmName'."
                } catch {
                    # If an error occurs, display the error message
                    Write-Host "Error: Failed to add a new network adapter to VM '$vmName'."
                    Write-Host "Details: $_"
                }
            }
            
            Write-Host ''
        }
        '23'{ 
            Write-Host 'Adding a new hard disk to a VM...'

            # Prompt for the VM name
            $vmName = Read-Host 'Enter VM Name'
            Write-Host ''
            # Prompt for the disk size in GB
            $diskSize = Read-Host 'Enter Disk Size in GB'

            Write-Host ''
            
            # Validate that the entered disk size is a positive number
            if (-not [int]::TryParse($diskSize, [ref]$null) -or $diskSize -lt 1) {
                Write-Host "Error: Please enter a valid positive integer for disk size in GB."
            } else {
                # Check if the VM exists
                $vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue
                if ($vm -eq $null) {
                    Write-Host "Error: VM '$vmName' does not exist."
                } else {
                    # Use try-catch to handle errors
                    try {
                        # Attempt to add a new hard disk to the VM
                        New-HardDisk -VM $vmName -CapacityGB $diskSize -ErrorAction Stop
            
                        # If successful, print a success message
                        Write-Host "Successfully added a new hard disk of $diskSize GB to VM '$vmName'."
                    } catch {
                        # If an error occurs, display the error message
                        Write-Host "Error: Failed to add a new hard disk to VM '$vmName'."
                        Write-Host "Details: $_"
                    }
                }
            }
            
            Write-Host ''
        }
        '24'{ 
            Write-Host 'Converting a VM to a template...'
            Write-Host ''

            # Prompt for the VM name
            $vmName = Read-Host 'Enter VM Name'

            Write-Host ''
            
            # Check if the VM exists
            $vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue
            if ($vm -eq $null) {
                Write-Host "Error: VM '$vmName' does not exist."
            } else {
                # Ensure the VM is not already a template
                if ($vm.ExtensionData.Config.Template) {
                    Write-Host "Error: VM '$vmName' is already a template."
                } else {
                    # Use try-catch to handle errors
                    try {
                        # Attempt to convert the VM to a template
                        Set-VM -VM $vmName -Template -ErrorAction Stop
            
                        # If successful, print a success message
                        Write-Host "Successfully converted VM '$vmName' to a template."
                    } catch {
                        # If an error occurs, display the error message
                        Write-Host "Error: Failed to convert VM '$vmName' to a template."
                        Write-Host "Details: $_"
                    }
                }
            }
            
            Write-Host ''
        }
        '25'{ 
            Write-Host 'Deploying a VM from a template...'
            Write-Host ''
            
            # Prompt for the template name
            $templateName = Read-Host 'Enter Template Name'
            # Prompt for the new VM name
            $newVMName = Read-Host 'Enter New VM Name'

            Write-Host ''
            
            # Check if the template exists
            $template = Get-VM -Name $templateName -ErrorAction SilentlyContinue
            if ($template -eq $null) {
                Write-Host "Error: Template '$templateName' does not exist."
            } else {
                # Check if the new VM name is valid
                if ([string]::IsNullOrWhiteSpace($newVMName)) {
                    Write-Host "Error: New VM name cannot be empty."
                } else {
                    # Use try-catch to handle errors during VM deployment
                    try {
                        # Attempt to deploy a new VM from the template
                        New-VM -Name $newVMName -Template $templateName -ErrorAction Stop
            
                        # If successful, print a success message
                        Write-Host "Successfully deployed VM '$newVMName' from template '$templateName'."
                    } catch {
                        # If an error occurs, display the error message
                        Write-Host "Error: Failed to deploy VM '$newVMName' from template '$templateName'."
                        Write-Host "Details: $_"
                    }
                }
            }
            
            Write-Host ''
        }
        '26'{ 
            Write-Host 'Exporting a VM (OVF format)...'
            Write-Host ''

            # Prompt for the VM name
            $vmName = Read-Host 'Enter VM Name'
            # Prompt for the export destination path
            $exportPath = Read-Host 'Enter Export Path'

            Write-Host ''
            
            # Check if the VM exists
            $vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue
            if ($vm -eq $null) {
                Write-Host "Error: VM '$vmName' does not exist."
            } else {
                # Check if the export path is valid
                if (-not (Test-Path $exportPath)) {
                    Write-Host "Error: The specified export path '$exportPath' does not exist."
                } elseif (-not (Test-Path -Path $exportPath -PathType Container)) {
                    Write-Host "Error: The specified export path '$exportPath' is not a directory."
                } else {
                    # Use try-catch to handle errors during VM export
                    try {
                        # Attempt to export the VM to OVF format
                        Export-VApp -VM $vmName -Destination $exportPath -Format OVF -ErrorAction Stop
            
                        # If successful, print a success message
                        Write-Host "Successfully exported VM '$vmName' to '$exportPath'."
                    } catch {
                        # If an error occurs, display the error message
                        Write-Host "Error: Failed to export VM '$vmName' to '$exportPath'."
                        Write-Host "Details: $_"
                    }
                }
            }
            
            Write-Host ''
        }
        '27'{ 
            Write-Host 'Importing a VM (OVF format)...'
            Write-Host ''

            # Prompt for the OVF file path
            $ovfPath = Read-Host 'Enter OVF File Path'
            # Prompt for the datastore name
            $datastore = Read-Host 'Enter Datastore Name'

            Write-Host ''
            
            # Check if the OVF file exists
            if (-not (Test-Path $ovfPath)) {
                Write-Host "Error: The specified OVF file '$ovfPath' does not exist."
            } else {
                # Check if the datastore exists
                $datastoreObj = Get-Datastore -Name $datastore -ErrorAction SilentlyContinue
                if ($datastoreObj -eq $null) {
                    Write-Host "Error: The specified datastore '$datastore' does not exist."
                } else {
                    # Use try-catch to handle errors during VM import
                    try {
                        # Attempt to import the VM from OVF file
                        Import-VApp -Source $ovfPath -Datastore $datastore -ErrorAction Stop
            
                        # If successful, print a success message
                        Write-Host "Successfully imported VM from OVF file '$ovfPath' to datastore '$datastore'."
                    } catch {
                        # If an error occurs, display the error message
                        Write-Host "Error: Failed to import VM from OVF file '$ovfPath'."
                        Write-Host "Details: $_"
                    }
                }
            }
            
            Write-Host ''
        }
        '28'{ 
            Write-Host 'Migrating a VM to another host...'
            Write-Host ''
            # Prompt for the VM name
            $vmName = Read-Host 'Enter VM Name'
            # Prompt for the target host name
            $hostName = Read-Host 'Enter Target Host Name'

            Write-Host ''
            
            # Check if the VM exists
            $vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue
            if ($vm -eq $null) {
                Write-Host "Error: VM '$vmName' does not exist."
            } else {
                # Check if the target host exists
                $host = Get-VMHost -Name $hostName -ErrorAction SilentlyContinue
                if ($host -eq $null) {
                    Write-Host "Error: Target host '$hostName' does not exist."
                } else {
                    # Use try-catch to handle errors during VM migration
                    try {
                        # Attempt to move the VM to the target host
                        Move-VM -VM $vm -Destination $host -ErrorAction Stop
            
                        # If successful, print a success message
                        Write-Host "Successfully migrated VM '$vmName' to host '$hostName'."
                    } catch {
                        # If an error occurs, display the error message
                        Write-Host "Error: Failed to migrate VM '$vmName' to host '$hostName'."
                        Write-Host "Details: $_"
                    }
                }
            }
            
            Write-Host ''
        }
        '29'{ 
            Write-Host 'Migrating a VM to a different datastore...'
            Write-Host ''

            # Prompt for the VM name
            $vmName = Read-Host 'Enter VM Name'
            # Prompt for the target datastore name
            $datastoreName = Read-Host 'Enter Datastore Name'

            Write-Host ''
            
            # Check if the VM exists
            $vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue
            if ($vm -eq $null) {
                Write-Host "Error: VM '$vmName' does not exist."
            } else {
                # Check if the datastore exists
                $datastore = Get-Datastore -Name $datastoreName -ErrorAction SilentlyContinue
                if ($datastore -eq $null) {
                    Write-Host "Error: Datastore '$datastoreName' does not exist."
                } else {
                    # Check if the datastore has sufficient space
                    $datastoreFreeSpace = $datastore.ExtensionData.Info.FreeSpace
                    $vmSize = $vm.ExtensionData.Summary.Storage.Committed
                    if ($datastoreFreeSpace -lt $vmSize) {
                        Write-Host "Error: Insufficient space on datastore '$datastoreName' for VM '$vmName'."
                    } else {
                        # Use try-catch to handle errors during VM migration
                        try {
                            # Attempt to move the VM to the target datastore
                            Move-VM -VM $vm -Datastore $datastore -ErrorAction Stop
            
                            # If successful, print a success message
                            Write-Host "Successfully migrated VM '$vmName' to datastore '$datastoreName'."
                        } catch {
                            # If an error occurs, display the error message
                            Write-Host "Error: Failed to migrate VM '$vmName' to datastore '$datastoreName'."
                            Write-Host "Details: $_"
                        }
                    }
                }
            }
            
            Write-Host ''
        }
        '30'{ 
            Write-Host 'Increasing CPU allocation for a VM...'
            Write-Host ''
            
            # Prompt for the VM name
            $vmName = Read-Host 'Enter VM Name'
            # Prompt for the new CPU count
            $cpuCount = Read-Host 'Enter New CPU Count'
            
            Write-Host ''

            # Check if the VM exists
            $vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue
            if ($vm -eq $null) {
                Write-Host "Error: VM '$vmName' does not exist."
            } else {
                # Check if the CPU count is a valid number and greater than the current number of CPUs
                if ($cpuCount -lt 1) {
                    Write-Host "Error: CPU count must be at least 1."
                } elseif ($cpuCount -eq $vm.NumCpu) {
                    Write-Host "Error: The CPU count is already set to $cpuCount. No change needed."
                } else {
                    # Use try-catch to handle errors during the CPU allocation change
                    try {
                        # Attempt to change the CPU count
                        Set-VM -VM $vm -NumCpu $cpuCount -ErrorAction Stop
            
                        # If successful, print a success message
                        Write-Host "Successfully updated CPU allocation for VM '$vmName' to $cpuCount CPUs."
                    } catch {
                        # If an error occurs, display the error message
                        Write-Host "Error: Failed to increase CPU allocation for VM '$vmName'."
                        Write-Host "Details: $_"
                    }
                }
            }
            
            Write-Host ''
        }
        '31'{ 
            Write-Host 'Increasing memory allocation for a VM...'
            Write-Host

            # Prompt for the VM name
            $vmName = Read-Host 'Enter VM Name'
            # Prompt for the new memory size in GB
            $memorySize = Read-Host 'Enter New Memory Size in GB'
            
            Write-Host ''

            # Check if the memory size is a valid positive number
            if ($memorySize -lt 1) {
                Write-Host "Error: Memory size must be at least 1 GB."
            } else {
                # Check if the VM exists
                $vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue
                if ($vm -eq $null) {
                    Write-Host "Error: VM '$vmName' does not exist."
                } else {
                    # Use try-catch to handle errors during the memory allocation change
                    try {
                        # Attempt to change the memory size
                        Set-VM -VM $vm -MemoryGB $memorySize -ErrorAction Stop
            
                        # If successful, print a success message
                        Write-Host "Successfully updated memory allocation for VM '$vmName' to $memorySize GB."
                    } catch {
                        # If an error occurs, display the error message
                        Write-Host "Error: Failed to increase memory allocation for VM '$vmName'."
                        Write-Host "Details: $_"
                    }
                }
            }
            
            Write-Host ''
        }
        '32'{ 
            Write-Host 'Getting CPU and memory usage for all VMs...'
            Write-Host ''

            # Attempt to retrieve the CPU and memory usage for all VMs
            try {
                $vmUsageData = Get-VM | Select-Object Name, `
                                                @{Name="CPU Usage";Expression={($_.ExtensionData.Summary.QuickStats.OverallCpuUsage)}}, `
                                                @{Name="Memory Usage";Expression={($_.ExtensionData.Summary.QuickStats.GuestMemoryUsage)}}
            
                # Check if any VM data was retrieved
                if ($vmUsageData.Count -eq 0) {
                    Write-Host "No VM data found. Ensure that the vCenter is connected and there are VMs available."
                } else {
                    # Output the VM usage data in a readable table format
                    $vmUsageData | Format-Table -AutoSize
                }
            } catch {
                # If an error occurs, display the error message
                Write-Host "Error: Failed to retrieve CPU and memory usage data."
                Write-Host "Details: $_"
            }
            
            Write-Host ''
        }
        '33'{ 
            Write-Host 'Getting performance data for a VM...'
            Write-Host ''
            
            # Prompt for the VM name
            $vmName = Read-Host 'Enter VM Name'
            
            Write-Host ''

            # Use try-catch to handle errors during the retrieval of performance data
            try {
                # Attempt to get the VM by name
                $vm = Get-VM -Name $vmName -ErrorAction Stop
                
                # Check if the VM is found
                if ($vm -eq $null) {
                    Write-Host "Error: VM '$vmName' does not exist."
                } else {
                    # Attempt to retrieve the performance statistics (stats) for the specified VM
                    $stats = $vm | Get-Stat -ErrorAction Stop
            
                    # Check if performance data was returned
                    if ($stats.Count -eq 0) {
                        Write-Host "No performance data found for VM '$vmName'."
                    } else {
                        # Display the performance data
                        $stats | Format-Table -AutoSize
                    }
                }
            } catch {
                # If an error occurs, display the error message
                Write-Host "Error: Failed to retrieve performance data for VM '$vmName'."
                Write-Host "Details: $_"
            }
            
            Write-Host ''
        }
        '0'{ 
            Write-Host 'Exiting...'
            break
            Clear-Host
        }
        default { 
            Write-Host 'Invalid option. Please try again.'
        }
    }
} while ($input -ne '0')
