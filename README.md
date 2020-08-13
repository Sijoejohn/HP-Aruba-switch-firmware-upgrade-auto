# HP-Aruba-switch-firmware-auto-upgrade
The Script can be used for automate firmware upgrade of HP Pro-curve and Aruba network switches which are accessible via ssh.

Script is developed based on the assumption that the "Primary" flash is the active flash in your switch.

If your switch is running on secondary flash (which is active flash) then the script commands need to be amended with secondary instead of primary vice versa.

# Pre-requisites

Windows PowerShell version 5.0 or above
Posh-SSH module should be installed on windows PowerShell
Install and configure a TFTP Server
SSH should be enabled on all network devices
All devices should be configured with same login credentials (Read only)
After logging in, the devices should be in "Enable" (Privileged #) mode
Network devices firmware should be in-line with industry standards
Add IP address of devices into hp.txt, Cisco.txt & fortigate.txt
Not recommended to run on any servers installed with SCCM, WDS or any other tftp services.
Login credential need to be encrypted and saved in a text file pass.txt. Copy the pass.txt file into the script “content” folder
How to Convert

Open Administrative PowerShell window and execute the command below.

"Temp123*" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File "C:\pass.txt”.

Password – Temp123* Output File – pass.txt in C drive

Note: In case if your password contains special characters like "$" make sure you input the password in below format. Otherwise while encrypting the password get altered.

Example:

Temp123$upp0rt

"Temp123"+"$"+upp0rt

# How to use the script

STEP 1) Download the script “Network_switch_config_auto_backup” from the GitHub and extract it to any drive.

STEP 2) Open tftpd64 folder under script root folder and run tftpd64.exe, note down the IP address and edit the following settings. It is a one-time job.

2a) Open Tftpd64 program, click on Settings button.

2b) Settings window will open as shown below. Put a check mark only to TFTP Server option. Remove check mark from all other options

2c) then next select TFTP tab. click on Browse button to specify Base Directory. You need to specify the Base Directory of the TFTP Server. Set your script root folder as the base directory. Ex: H:\Network_switch_auto_backup Where H = your disk drive where the script folder is extracted to. Network_switch_auto_backup is the script folder.

2d) Under TFTP Security, select the option None

2e) A very important Step, Bind TFTP to this address: To set the IP address for TFTP server, please select the option Bind TFTP to this address then select the IP address available for you. You may get a different IP address, please use the IP address available in the drop down window.

You have to note down bonded IP address and write into the script line as mentioned in Step 3.

2f) once you have performed all the above steps, Click on OK. Now you will receive a window asking to restart Tftpd64 to apply the new settings. Click on OK.

2e) Reopen Tftpd64 program. Just ensure that you selected same IP address for Server Interface.

Reference: http://techzain.com/how-to-setup-tftp-server-tftpd64-tfptd32-windows/

STEP 3) Download the new firmware flash and copy it into script root folder

STEP 4) Edit the following portion in the script

If user name to login to your device is not "manager”, change it to your user name.

$cred = New-Object System.Management.Automation.PSCredential ('manager', $securePassword)

Enter your TFTP server IP address (Bonded TFTP Server IP address – Step 2e)

$tftp_server = "Enter your TFTP server ip address here"

Enter the name of firmware flash 

$FlashVersion = "Example : WB_16_10_0003.swi"

STEP 5) Open script root folder and navigate to “Content" folder

Replace Pass.txt with your encrypted device password key file

Enter the IP address of HP devices into hp.txt

STEP 6) Open a PowerShell (Administrative PS recommended)

STEP 7) Navigate and set path to script root folder

STEP 8) If you want to backup HP devices configuration execute the below command

PS>.\Network_switch_auto_backup.ps1 HP

STEP 9) Logging is enabled on the script to troubleshoot the, check “logs” folder under the script root folder if you come across any errors.

STEP 10) SSH session will be disconnected once the firmware is updated on primary flash

STEP 11) Once switch is online , login and verify the Firmware.

STEP 12) Ensure that there are no errors on the logs after the Firmware upgrade.

# Warning

Use at your own risk as there are many other dependencies based on your switch model and configuration that can break the network switch during Firmware upgrade.

Go through the best practices as mentioned in the below article and additionally take a backup of flash as well even-though we're keeping a secondary flash with duplicated configuration config2

https://sjohnonline.blogspot.com/2019/05/network-switch-firmware-upgrade-best.html

Always test the script on a test/non-critical network switch before going for wide range of upgrades.

After sanity test optionally primary flash can be copied to secondary flash.

# Troubleshooting


1)  Logging is enabled on the script with run time, date and year, check the folder “logs”


# Future Enhancements


1)  Expand functionality for larger pool of network devices.

2)  Include the functionality for staged firmware upgrade (Firmware1 --> Firmware2 -->Firmware3)


# Devices Tested

1) HP Switches (Procurve and Aruba)

2920-48G-POE+
2910al-48G-POE+
2920-24G-POE
2530-48G-PoEP

Tested Firmware versions

WB.16.01.0004 --> WB.16.05.0003 --> WB.16.10.0003


