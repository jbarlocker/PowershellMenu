##########################################################
###   
###   Created on:   31-MAR-2022
###   Created by:   Jake Barlocker
###   
###   This script will get a list of all client computers in a domain and reset the local admin password on them.
###   
###   
###   
###   
##########################################################


Function ResetLocalAdminPassword {


clear

# https://fsymbols.com/generators/carty/
$Title = @"



█▀█ █▀▀ █▀ █▀▀ ▀█▀   █░░ █▀█ █▀▀ ▄▀█ █░░   ▄▀█ █▀▄ █▀▄▀█ █ █▄░█   █▀█ ▄▀█ █▀ █▀ █░█░█ █▀█ █▀█ █▀▄ █▀   █▀█ █▄░█
█▀▄ ██▄ ▄█ ██▄ ░█░   █▄▄ █▄█ █▄▄ █▀█ █▄▄   █▀█ █▄▀ █░▀░█ █ █░▀█   █▀▀ █▀█ ▄█ ▄█ ▀▄▀▄▀ █▄█ █▀▄ █▄▀ ▄█   █▄█ █░▀█

▄▀█ █░░ █░░   █░█░█ █▀█ █▀█ █▄▀ █▀ ▀█▀ ▄▀█ ▀█▀ █ █▀█ █▄░█ █▀
█▀█ █▄▄ █▄▄   ▀▄▀▄▀ █▄█ █▀▄ █░█ ▄█ ░█░ █▀█ ░█░ █ █▄█ █░▀█ ▄█


This will not reset any local admin accounts on computers with Server OS's.

"@

Write-Host $Title -ForegroundColor DarkMagenta

Write-Host ""
Write-Host ""


# Get the domain admin credential to use to connect to client computers
$DomainAdminCredential = Get-Credential -Message "Enter a Domain Admin credential."

# Get the new password for the Administrator account
$NewAdministratorPassword = Read-Host "Enter the new password for the Administrator account. (The Administrator user will be disabled)"
$NewITPassword = Read-Host "Enter the new password for the IT account (The IT account will be a local admin)"

# Get a list of all client computers
$AllNonServerComputers = Get-ADComputer -Filter 'operatingsystem -notlike "*server*" -and enabled -eq "true"' ` -Properties Name,Operatingsystem,OperatingSystemVersion,IPv4Address | Sort-Object -Property Operatingsystem | Select-Object -Property Name,Operatingsystem,OperatingSystemVersion,IPv4Address
#$AllNonServerComputers = Get-ADComputer -Filter 'operatingsystem -notlike "*server*" -and name -eq "jakeb"' ` -Properties Name,Operatingsystem,OperatingSystemVersion,IPv4Address | Sort-Object -Property Operatingsystem | Select-Object -Property Name,Operatingsystem,OperatingSystemVersion,IPv4Address





# Invoke PSSessions on remote computers (as a job - to run concurrently) to reset the administrator password
Write-Host "Invoking Jobs on all workstation computers to reset passwords." -ForegroundColor Magenta
$Sessions = New-PSSession -ComputerName ($AllNonServerComputers.Name) -Credential $DomainAdminCredential -ThrottleLimit 16
Invoke-Command -Session $Sessions -ScriptBlock {
                                                #Set the Username for the account that the I.T. Dept will use
                                                $IT_Dept_account_name = "IT"
                                                
                                                # Set the password for the "Administrator" ccount
                                                $Administrator_Password = $using:NewAdministratorPassword;

                                                # Set the password for the "IT" account
                                                $IT_Password = $using:NewITPassword;

                                                # Encrypt the passwords to a SecureString
                                                $Administrator_EncryptedPassword = ConvertTo-SecureString $Administrator_Password -AsPlainText -Force;
                                                $IT_EncryptedPassword = ConvertTo-SecureString $IT_Password -AsPlainText -Force;

                                                # Check to see if the "IT" user is created
                                                $Local_IT_user = Get-LocalUser | Where-Object {$_.Name -eq "IT"};

                                                # If the local user "IT" doesnt exist, then create it
                                                if (!$Local_IT_user) {New-LocalUser $IT_Dept_account_name -Password $IT_EncryptedPassword -FullName "I.T. Account"};

                                                # Set group memberships
                                                Add-LocalGroupMember -Group "Administrators" -Member $IT_Dept_account_name;
                                                Add-LocalGroupMember -Group "Users" -Member $IT_Dept_account_name;
                                                Add-LocalGroupMember -Group "Remote Desktop Users" -Member $IT_Dept_account_name

                                                # Set the password to the local usernames
                                                Get-LocalUser -Name "Administrator" | Set-LocalUser -Password $Administrator_EncryptedPassword;
                                                Get-LocalUser -Name $IT_Dept_account_name | Set-LocalUser -Password $IT_EncryptedPassword;
                                                
                                                # Get the Date
                                                $Date = Get-Date -Format "dd-MMM-yyyy"

                                                # Set the description of users
                                                Set-LocalUser -Name $IT_Dept_account_name -Description "IT Dept use only - Password Set $Date"
                                                
                                                # Disable the "Administrator" account
                                                Disable-LocalUser -Name "Administrator"} -AsJob




$currentsessions = Get-PSSession 
$currentsessions.count


Get-PSSession | Remove-PSSession
Remove-PSSession -Session (Get-PSSession)
$s = Get-PSSession
Remove-PSSession -Session $s

Write-Host "Completed." -ForegroundColor Green

}