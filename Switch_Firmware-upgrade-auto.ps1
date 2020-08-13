
###############################################################################
# Script info     :  Network Switch Automated Firmware Upgrade using SSH and TFTP
# Script          :  Network_switch_auto_upgrade.ps1
# Verified on     :  HP(Procurve and Aruba)
# Author          :  Sijo John
# Version         :  V-1.0
# Last Modified   :  10/08/2020
# The Script can be used for automate firmware upgrade of network devices which are accessible via ssh.
# Note : At present HP/Aruba the script supports HP Pro-curve/Aruba switch models (Works on most of the models)
# .SYNOPSIS
# Usage Example   : PS>.\Network_switch_auto_upgrade.ps1 hp (For HP network switches)
#
##################: MODULES UNDER DEVELOPMENT AND TESTING - NOT AVAILABLE AT PRESENT######
#
#                 : PS>.\Network_switch_auto_upgrade.ps1 cisco (For cisco network switches)
#                 : PS>.\Network_switch_auto_upgrade.ps1 fortigate (For Fortigate Firewall)
#                 : PS>.\Network_switch_auto_upgrade.ps1 All (For All the above)
##########################################################################################


Param
(
    [Parameter(Mandatory = $True)]
    [ValidateNotNull()]
    $devicename
)

Begin {

    write-host $devicename
    $tftpfolder = "$PSScriptRoot"
    Write-Host ("Starting TFTP Server")
    Invoke-Item "$PSScriptRoot\tftpd64\tftpd64.exe"

    $ContentFolder = "$PSScriptRoot\Content"
    $LogFolder = "$PSScriptRoot\logs"
    $securePassword = Get-Content $ContentFolder\pass.txt | ConvertTo-SecureString
    #Change the user name if it is not manager - Ex: admin, root
    $cred = New-Object System.Management.Automation.PSCredential ('admin', $securePassword)
    $today = Get-Date -Format "ddMMyyy"
    $year = Get-Date -Format "yyyy"
    #Enter your TFTP Server ip address here.
    $tftp_server = "Enter the IP address of TFTP Server"
    #Enter your flash version name here
    $FlashVersion = "Example : WB_16_10_0003.swi"


    #region generate the transcript log
    #Modifying the VerbosePreference in the Function Scope
    $Start = Get-Date
    $VerbosePreference = 'Continue'
    $TranscriptName = '{0}_{1}.log' -f $(($MyInvocation.MyCommand.Name.split('.'))[0]), $(Get-Date -Format ddMMyyyyhhmmss)
    Start-Transcript -Path "$LogFolder\$TranscriptName"
    #endregion generate the transcript log

    # create a folder for every year
    try {
        Get-Item "$PSScriptRoot\$year\" -ErrorAction SilentlyContinue
        if (!$?) {
            New-Item "$PSScriptRoot\$year\" -ItemType Directory
        }

        # create a folder for every day
        Get-Item "$PSScriptRoot\$year\$today\" -ErrorAction SilentlyContinue
        if (!$?) {
            New-Item "$PSScriptRoot\$year\$today\" -ItemType Directory
        }
    }
    Catch {
        Show-Message -Severity high -Message "Failed to create the folder. Permission!"
        Write-Verbose -ErrorInfo $PSItem
        Stop-Transcript
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }

    # Import required PS Modules

    try {
        Import-Module -name posh-ssh
 
    }
    catch {
        Show-Message -Severity high -Message "[EndRegion] Failed - Prerequisite of loading modules"
        Write-VerboseLog -ErrorInfo $PSItem
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }


    Function hp()
    {

        Write-Host ("Getting switch ip address from hp.txt list")

        # Collect all the devices from hp.txt and put into the array
        $switches_array = @()
        $switches_array = Get-Content $ContentFolder\hp.txt
        foreach ($switch in $switches_array) {
            # create a folder for every device
            Get-Item "$PSScriptRoot\$year\$today\$switch" -ErrorAction SilentlyContinue
            if (!$?) {
                New-Item "$PSScriptRoot\$year\$today\$switch" -ItemType Director
            }

            # start the SSH Session
            New-SSHSession -ComputerName $switch -Credential $Cred -AcceptKey:$true
            $session = Get-SSHSession -Index 0
            # usual SSH won't work for many switches, so using shell stream
            $stream = $session.Session.CreateShellStream("dumb", 80, 9999, 800, 600, 1024)
            # send a "space" for the "Press any key to continue" and wait before you issue the next command
            $stream.Write("`n")
            Sleep 10

            # copy config1 to config2 and wait before you issue the next command
            $stream.Write("copy config config1 config config2")
            $stream.Write("`n")
            Write-Host ("Copying config1 and create config2 of $switch")
            Sleep 10

            # Copy primary/active flash to secondary flash
            $stream.Write("copy flash flash secondary")
            $stream.Write("`n")
            Write-Host ("Copying active flash to secondary flash of $switch")
            Sleep 10

            # Set secondary/passive flash to use confg2 on startup
            $stream.Write("startup-default secondary config config2")
            $stream.Write("`n")
            Write-Host ("Setting secondary flash to boot from config2 of $switch")
            Sleep 10

            # Copy new firmware from tftp to primary/active flash
            $stream.Write("copy tftp flash $tftp_server $FlashVersion primary")
            $stream.Write("`n")
            $stream.Write("y")
            $stream.Write("`n")
            Write-Host ("Copying flash from tftp to $switch")
            Sleep 30

            # Boot the switch from primary flash after firmware upgrade
            $stream.Write("boot system flash primary")
            $stream.Write("`n")

   
            Sleep 10
            # disconnect from host
            Remove-SSHSession -SessionId 0
        }
    }

    Function cisco() 
    {

    ######CISCO SWITCH FIRMWARE UPGRADE AUTOMATION TEST IS IN PROGRESS AND WILL BE AVAILABLE ON NEXT UPDATE#######

        Write-Host ("Getting switch ip address from cisco.txt list")

        # Collect all the devices from cisco.txt and put into the array
        $switches_array = @()
        $switches_array = Get-Content $ContentFolder\cisco.txt
        foreach ($switch in $switches_array) {
            # create a folder for every device
            Get-Item "$PSScriptRoot\$year\$today\$switch" -ErrorAction SilentlyContinue
            if (!$?) {
                New-Item "$PSScriptRoot\$year\$today\$switch" -ItemType Director
            }

            # start the SSH Session
            New-SSHSession -ComputerName $switch -Credential $Cred -AcceptKey:$true -force

            $session = Get-SSHSession -Index 0
            # usual SSH won't work for many switches, so using shell stream
            $stream = $session.Session.CreateShellStream("dumb", 80, 9999, 800, 600, 1024)
            # send a "space" for the "Press any key to continue" and wait before you issue the next command
            $stream.Write("`n")
            Sleep 10

            ##CISCO SWITCH FIRMWARE UPGRADE AUTOMATION TEST IS IN PROGRESS AND WILL BE AVAILABLE ON NEXT UPDATE##

            Sleep 10

            ##CISCO SWITCH FIRMWARE UPGRADE AUTOMATION TEST IS IN PROGRESS AND WILL BE AVAILABLE ON NEXT UPDATE##
            
            Sleep 10

            # disconnect from host

            Remove-SSHSession -SessionId 0
        }
    }

    Function fortigate()
    {
    ######FORTINET FIREWALL FIRMWARE UPGRADE AUTOMATION MODULE DEVELOPMENT IS IN PROGRESS AND WILL BE AVAILABLE ON NEXT UPDATE#######

        Write-Host ("Getting switch ip address from fortigate.txt list")

        # Collect all the devices from fortigate.txt and put into the array
        $switches_array = @()
        $switches_array = Get-Content $ContentFolder\fortigate.txt
        foreach ($switch in $switches_array) {
            # create a folder for every device
            Get-Item "$PSScriptRoot\$year\$today\$switch" -ErrorAction SilentlyContinue
            if (!$?) {
                New-Item "$PSScriptRoot\$year\$today\$switch" -ItemType Director
            }

            # start the SSH Session
            New-SSHSession -ComputerName $switch -Credential $Cred -AcceptKey:$true -Force
            $session = Get-SSHSession -Index 0
            # usual SSH won't work for many switches, so using shell stream
            $stream = $session.Session.CreateShellStream("dumb", 80, 9999, 800, 600, 1024)
            # send a "space" for the "Press any key to continue" and wait before you issue the next command
            $stream.Write("`n")
            Sleep 10
           
            # Fortinet Firmware Upgrade automation development is in progress and will be available soon in next uupdate#
            Sleep 10
            # disconnect from host
            Remove-SSHSession -SessionId 0
        }
    }

    if ($devicename -like "HP") {hp continue; }
    elseif ($devicename -like "Cisco") {cisco continue; }
    elseif ($devicename -like "fortigate") {fortigate continue; }
    elseif ($devicename -like "All") {hp continue; cisco continue; fortigate continue; }
    else {Write-host "Enter valid options"} 
    
    Write-Host ("Configuration backup has been saved into the defined location, stopping tftp server.....")
    Sleep 15
    Stop-Process -Name tftpd64
    Write-Host ("TFTP Server stopped")
    Write-Host ("End")
               
}
    
