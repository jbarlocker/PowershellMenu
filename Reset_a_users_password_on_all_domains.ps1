########################################################
###   
###   Created by: Jake Barlocker
###   Created on: 5-JAN-2023
###   
###   This script will set your password on all checkcity domains.
###   
###   
########################################################


Function ResetAllDomainsPasswords {

clear
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host "Dont run this on a Domain Controller.  This script cant remote into a DC that it is running on and will break." -ForegroundColor Red
Write-Host ""


$List_Of_Domains = @(
                   'ccoc7.com',
                   'ccoc7test.com',
                   'checkcity.local',
                   'checkcitynevada.com',
                   'checkcitynv.com',
                   'softwise.co'
                   )




#################################
# Get Credentials for each domain
#################################

Remove-Variable Credentials -ErrorAction SilentlyContinue
$Credentials = @()
$Counter = 0
While ($Counter -ne ($List_Of_Domains.Count)) {
                                               $CurrentDomain = $List_Of_Domains[$Counter]
                                               $Domain_User_Prepopulate = $CurrentDomain + "\USERNAME"
                                               $Credentials += Get-Credential -Message "Enter Credentials for $CurrentDomain" -UserName $Domain_User_Prepopulate
                                               $Counter++
                                       }







################################################
# Get FQDN of a domain controller in each domain
################################################

Remove-Variable DomainControllerFQDN -ErrorAction SilentlyContinue
$DomainControllerFQDN = @()

# reset counter to zero
$Counter = 0

While ($Counter -ne $List_Of_Domains.Count) {
                                             
                                             $CurrentDomain = $List_Of_Domains[$Counter]
                                             $DomainController = Get-ADDomainController -DomainName $CurrentDomain -Discover
                                             $DomainControllerFQDN += $DomainController.Name + "." + $DomainController.Domain
                                             
                                             $Counter++
                                             }








################################
# Open PSSessions to each domain
################################

Get-PSSession | Remove-PSSession

# reset counter to zero
$Counter = 0

While ($Counter -ne $List_Of_Domains.Count) {
                                             # Open a pssession.
                                             $CurrentCredential = $Credentials[$Counter]
                                             New-PSSession -ComputerName $DomainControllerFQDN[$Counter] -Credential $CurrentCredential -ErrorAction Stop
                                             
                                             $Counter++
                                             }
# Get-PSSession







##########################################################
# Use open PSSessions to reset the users password on each domain
##########################################################

# Ask the operator for the new password
Remove-Variable NewPassword, NewPasswordVerification, Var1, Var2 -ErrorAction SilentlyContinue
Function GetNewPassword {
                         Write-Host " "
                         $global:NewPassword = Read-Host "Enter the new password you want to use. Remember to abide by complexity and password history requirements!  " -AsSecureString
                         $global:NewPasswordVerification = Read-Host "Re-enter your new password to verify that you typed it correctly" -AsSecureString
                         }

GetNewPassword


Function CheckPasswordMatch {
                             $Var1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:NewPassword))
                             $Var2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:NewPasswordVerification))
                             If ($Var1 -ceq $Var2) {Clear; Write-Host "Passwords match... continuing" -ForegroundColor Green} else { Clear; Write-Host "Passwords do not match" -ForegroundColor Red; Write-Host "Passwords do not match" -ForegroundColor Red; Write-Host "Passwords do not match" -ForegroundColor Red; Write-Host "Passwords do not match" -ForegroundColor Red; Write-Host "Passwords do not match" -ForegroundColor Red; Write-Host "Passwords do not match" -ForegroundColor Red; Write-Host "Passwords do not match" -ForegroundColor Red; GetNewPassword; CheckPasswordMatch}
                             }

CheckPasswordMatch







##########################################################
# change the passwords in each domain
##########################################################

# reset counter to zero
$Counter = 0

While ($Counter -ne $List_Of_Domains.Count) {
                                             # use the pssession to reset the password in each domain
                                             $CurrentCredential = $Credentials[$Counter]
                                             $CurrentUser = $Credentials[$Counter].UserName
                                                $PositionOfSplitter = $CurrentUser.IndexOf("\")
                                                $Username = $CurrentUser.Substring($PositionOfSplitter+1)
                                             $CurrentDomain = $List_Of_Domains[$Counter]
                                             Invoke-Command -Credential $Credentials[$Counter] -ComputerName $DomainControllerFQDN[$Counter] {Set-ADAccountPassword -Identity $Using:Username -Reset -NewPassword $Using:global:NewPassword}
                                             
                                             Write-Host ""
                                             Write-Host "Password reset in $CurrentDomain for $CurrentUser" -ForegroundColor Cyan
                                             
                                             $Counter++
                                             }





# cleanup
Get-PSSession | Remove-PSSession





}