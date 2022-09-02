################################################
###   
###   This script will create a new user for CheckCity
###   
###   Created on: 7-FEB-2022
###   Created by: Josue Franco
###   
###   
###   Edits:
###   05-AUG-2022: Jake Barlocker - finalizing script and adding O365 code to create email accounts.
###   08-AUG-2022: Jake Barlocker - fixing AD to O365 sync and adding license to account in o365
###   10-AUG-2022: Jake Barlocker - building query for source account's o365 licenses and adding the same licenses to the new user.
###   
###   
###   
###   
###   
###   
###   To Do: - Add logging to an excel file
###          - email the operator of this script when a license cant be applied due to lack of available licenses.
###          - remove trailing space character on first name if entered
###          - 
###          - 
###          - 
###   
###   
################################################



Function Create_New_AD_User {

clear




# Check to see if powershell is running as an admin, and if not then stop the script.
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            Write-Host ""
            Write-Host "This Script Must be run as Administrator!" -ForegroundColor Yellow;
            Write-Host ""
            pause
            break;
            } ELSE {



# Check for NuGet, AzureAD, MSOnline, and ExchangeOnlineManagement then install them if they are missing
clear
    if (Get-PackageProvider -ListAvailable -Name NuGet) {
                                                         clear
                                                         Write-Host " "
                                                         Write-Host " "
                                                         Write-Host " "
                                                         Write-Host " "
                                                         Write-Host " "
                                                         Write-Host " "
                                                         Write-Host " "
                                                         Write-Host " "
                                                         Write-Host " "
                                                         Write-Host "NuGet is already installed" -ForegroundColor Green
                                                         Write-Host " "
                                                         } else {
                                                                 clear
                                                                 Write-Host "Installing NuGet" -ForegroundColor Yellow
                                                                 Write-Host " "
                                                                 Install-PackageProvider -Name NuGet -Force
                                                                 }
    if (Get-Module -ListAvailable -Name AzureAD) {
                                                      Write-Host " "
                                                      Write-Host "AzureAD is already installed" -ForegroundColor Green
                                                      Write-Host " "
                                                      } else {
                                                              Write-Host "Installing AzureAD" -ForegroundColor Yellow
                                                              Write-Host " "
                                                              Find-Module AzureAD | Install-Module -Force
                                                              }
    if (Get-Module -ListAvailable -Name MSOnline ) {
                                                      Write-Host " "
                                                      Write-Host "MSOnline  is already installed" -ForegroundColor Green
                                                      Write-Host " "
                                                      } else {
                                                              Write-Host "Installing MSOnline " -ForegroundColor Yellow
                                                              Write-Host " "
                                                              Find-Module MSOnline  | Install-Module -Force
                                                              }
    if (Get-Module -ListAvailable -Name ExchangeOnlineManagement ) {
                                                      Write-Host " "
                                                      Write-Host "ExchangeOnlineManagement  is already installed" -ForegroundColor Green
                                                      Write-Host " "
                                                      } else {
                                                              Write-Host "Installing ExchangeOnlineManagement " -ForegroundColor Yellow
                                                              Write-Host " "
                                                              Find-Module ExchangeOnlineManagement  | Install-Module -Force
                                                              }
    if (Get-Module -ListAvailable -Name ImportExcel ) {
                                                      Write-Host " "
                                                      Write-Host "ImportExcel  is already installed" -ForegroundColor Green
                                                      Write-Host " "
                                                      } else {
                                                              Write-Host "Installing ImportExcel " -ForegroundColor Yellow
                                                              Write-Host " "
                                                              Find-Module ImportExcel  | Install-Module -Force
                                                              }


Function Sync-DC_and_Azure {
    ##### Set ccc7dc01 to sync all domain controllers, then sync to azureAD
    Write-Host ""
    Write-Host "Syncing all Active Directory Domain Controllers..." -ForegroundColor Yellow
    Invoke-Command -ComputerName ccc7dc01.checkcity.local -FilePath "\\ccc7dc01.checkcity.local\c$\Windows\Scripts\SYNC all DCs and Azure AD.ps1" | ft
    Write-Host "Syncing from Active Directory to AzureAD..." -ForegroundColor Yellow
    }


# Find out who is running this script
$OperatorDomainAndUsername = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$OperatorUsername = $OperatorDomainAndUsername.Split('\')
$OperatorIdentity = Get-ADUser -Identity $OperatorUsername[1] -Properties *
$OperatorFirstName = $OperatorIdentity.GivenName
$OperatorLastName = $OperatorIdentity.Surname


# Get Date and Time
$Date = Get-Date -Format "dddd MM/dd/yyyy"
$Time = Get-Date -Format "HH:mm (K)"


# Generate a Random Password
function Get-RandomCharacters($length, $characters) {
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs=""
    return [String]$characters[$random]
}
function Scramble-String([string]$inputString){     
    $characterArray = $inputString.ToCharArray()   
    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
    $outputString = -join $scrambledStringArray
   return $outputString 
} 
$password = Get-RandomCharacters -length 6 -characters 'abcdefghiklmnoprstuvwxyz'
$password += Get-RandomCharacters -length 2 -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
$password += Get-RandomCharacters -length 2 -characters '1234567890'
$password += Get-RandomCharacters -length 2 -characters '!$%&/()=?}][{@#*+' 
$NewUserTempPassword = Scramble-String $password








# Login to ExchangeOnline
Write-Host " "
Write-Host " "
Write-Host "Connecting to ExchangeOnline..." -ForegroundColor Cyan
Connect-MsolService -ErrorAction Stop







##### Grab variables for new user
Write-Host ""
Write-Host ""
Write-Host "Starting Script" -ForegroundColor Yellow
Write-Host ""
Write-Host ""
$FirstName = Read-Host "Please enter new user's first name"
$LastName = Read-Host "Please enter new user's last name"
Write-Host ""
$CellPhoneNumber = Read-Host "Enter the new user's cell phone number if it is known"

##### Capitalize the input for first and last names
$FirstName = $FirstName.substring(0,1).toupper()+$FirstName.substring(1) 
$LastName = $LastName.substring(0,1).toupper()+$LastName.substring(1) 

##### Create variables with lowercase names
$FirstnameLowercase = $FirstName.ToLower()
$LastnameLowercase = $LastName.ToLower()


<#
$JobTitle = Read-Host -Prompt "Please enter new user's job title"
$Department = Read-Host -Prompt "Please enter new user's department"
$Manager = Read-Host -Prompt "Please enter new user's manager"
$Company = Read-Host -Prompt "Please enter new user's company name"
$Description = Read-Host -Prompt "Please enter new user's job description"
#>




##### Enter user that will be used as template
Write-Host ""
$TemplateUser = Read-Host "Please enter the username that settings will be copied from"


##### Display the user to verify that it is the correct source account
Write-Host ""
Write-Host ""
$TemplateUserObject = Get-ADUser $TemplateUser -Properties *
Write-Host Get-ADUser ($TemplateUserObject | Select-Object Name,Department,Manager,UserPrincipalName | fl | Out-String) -ForegroundColor DarkMagenta
$CorrectAccount = Read-Host "Is this the correct user to copy attributes from?   (y/n)   "
        # Take the first letter of the answer and make it lowercase
        $CorrectAccount = $CorrectAccount.ToLower().Substring(0,1)

# only continue if the displayed source account is correct, otherwise stop running the script
If ( $CorrectAccount -eq "n") {Write-Host "";Write-Host "Stopping script due to incorrect source account. Please lookup the username for the correct source account." -ForegroundColor Red; break}



##### Grab variables from templateuser
$TemplateUserOu = Get-ADUser -Identity $TemplateUser -Properties distinguishedname,cn | select @{n='Path';e={$_.distinguishedname -replace "CN=$($_.cn),",''}} | select -ExpandProperty Path
$TemplateUserGroups = Get-ADPrincipalGroupMembership -Identity $TemplateUserObject | Where-Object {$_.name -ne "Domain Users"}
### $templateuserdescription = Get-ADUser -Identity $templateuser -Properties Description
### $templateusertitle = Get-ADUser -Identity $templateuser -Properties Title
### $templateuserdepartment = Get-ADUser -Identity $templateuser -Properties Department



##### Check if SamAccountName is available
$inc = 1
$Sam = $firstname.ToLower() + $lastname.ToLower().Substring(0,$inc)

##### Keep adding letters from the new users last name until the new username is unique
if(Get-ADUser -Filter {SamAccountName -eq $Sam})
   {
    do {$Sam = $firstname.ToLower() + $lastname.ToLower().Substring(0,$inc++)
    }
    until (-not (Get-ADUser -Filter {SamAccountName -eq $Sam}))
    }
Write-Host ""
Write-Host "Username will be:   $Sam" -ForegroundColor Green



##### Create the new AD User account with only the most basic info
Write-Host "Creating user account..." -ForegroundColor Yellow
New-ADUser `
    -Name "$FirstName $LastName" `
    -AccountPassword (ConvertTo-SecureString $NewUserTempPassword -AsPlainText -Force) `
    -ChangePasswordAtLogon 1 `
    -DisplayName ("$FirstName "+$LastName.Substring(0,1)+".") `
    -Enabled 1 `
    -GivenName $FirstName `
    -Surname $LastName `
    -Path $TemplateUserOu `
    -SamAccountName $Sam `
    -UserPrincipalName "$Sam@checkcity.com"


Sync-DC_and_Azure


##### Assign group membership to new user
$TemplateUserGroups | Add-ADGroupMember -Members $Sam

##### Create a variable of the new user object
$NewlyCreatedUser = Get-ADUser $Sam -Properties *


##### Populate account fields if available
Write-Host ""
Write-Host "Copying user metadata..." -ForegroundColor Yellow
If ($TemplateUserObject.Title){ Set-ADUser -Identity $Sam -Title $TemplateUserObject.Title }
If ($TemplateUserObject.Department){ Set-ADUser -Identity $Sam -Department $TemplateUserObject.Department }
If ($TemplateUserObject.Manager){ Set-ADUser -Identity $Sam -Manager $TemplateUserObject.Manager }
If ($TemplateUserObject.Company){ Set-ADUser -Identity $Sam -Company $TemplateUserObject.Company }
If ($TemplateUserObject.Description){ Set-ADUser -Identity $Sam -Description $TemplateUserObject.Description }
If ($TemplateUserObject.Office){ Set-ADUser -Identity $Sam -Office $TemplateUserObject.Office }
If ($CellPhoneNumber -ne ""){ Set-ADUser -Identity $Sam -MobilePhone $CellPhoneNumber } 

$EmailAddress = $NewlyCreatedUser.UserPrincipalName
Write-Host ""
Write-Host "Generating email address..." -ForegroundColor Yellow
Write-Host ""
Set-ADUser -Identity $Sam -email $EmailAddress
Set-ADUser -Identity $Sam -add @{ProxyAddresses="SMTP:$EmailAddress"}


Sync-DC_and_Azure

##### Sleep while Active Directory syncs to AzureAD
sleep -Seconds 90


##### Give exchangeonline license to new user

    # Get all SKUs
    $AllO365Skus = Get-MsolAccountSku

    # Show O365 attributes
    #Get-MsolUser -UserPrincipalName $EmailAddress | Select-Object *
    #Get-MsolUser -UserPrincipalName $TemplateUserObject.UserPrincipalName | Select-Object licenses

    # Set Usage location so that the license can be added
    Set-MsolUser -UserPrincipalName $EmailAddress -UsageLocation "US"

    # Add O365 Licenses
    Remove-Variable FailedSkus -ErrorAction SilentlyContinue
    $FailedSkus = @()
    Foreach ($Sku in $AllO365Skus) {
                                    $SkuName = $Sku.AccountSkuId
                                    $UsersOfSku = Get-MsolUser -All | Where-Object {($_.licenses).AccountSkuId -match $Sku.AccountSkuId}
                                    If ($UsersOfSku.DisplayName -contains $TemplateUserObject.DisplayName) {
                                                                                                            Set-MsolUserLicense -UserPrincipalName $EmailAddress -AddLicenses $Sku.AccountSkuId -ErrorAction SilentlyContinue
                                                                                                            If ($Sku.ActiveUnits -eq $Sku.ConsumedUnits) { 
                                                                                                                                                          $FailedSkus += $SkuName
                                                                                                                                                          Write-Host ""
                                                                                                                                                          Write-Host "$EmailAddress was NOT given the --$SkuName-- license! There are none available." -ForegroundColor Red
                                                                                                                                                          Write-Host ""
                                                                                                                                                          }
                                                                                                      }
                                    }



    # List out the licenses that failed to apply
    If ($FailedSkus) {
                       Write-Host ""
                       Write-Host "Licenses that Failed to be applied to the user:" -ForegroundColor Red -BackgroundColor Blue
                       Write-Host ""
                        foreach ( $FailedSku in $FailedSkus ) {
                                                               Write-Host "--$FailedSku--" -ForegroundColor Red -BackgroundColor Blue
                                                               }
                        }






##### Send out emails to appropriate parties
    # Find out who is running this script to generate the email's "From:" field
    $OperatorDisplayName = $OperatorIdentity.DisplayName
    $OperatorEmailAddress = $OperatorIdentity.EmailAddress
        # Get the operator's email address if it cant be found
        If ($OperatorEmailAddress) {} else {
                                            Write-Host ""
                                            $OperatorEmailAddress = Read-Host "Your email address could not be found in Active Directory. Please enter it now"
                                            }
    $emailFrom = "$OperatorDisplayName <$OperatorEmailAddress>"




    # check to see if the new account's email is still being built or if it is still provisioning
    Sleep -Seconds 15



##### send email to the new user's manager and CC the user that includes the user's temporary password and a link to change it to their own password (maybe webmail login)

    # Email server settings
    $SmtpServer                 = 'checkcity-com.mail.protection.outlook.com'
    $Port                       = '25' 
    $DeliveryNotificationOption = 'OnFailure'
    
    # Generate Manager's variables
    $ManagerCanonicalName = (Get-ADUser $Sam -Properties Manager | Select-Object Manager).Manager
    $ManagerName = (Get-ADUser -Identity $ManagerCanonicalName).Name
    $ManagerEmail = (Get-ADUser -Identity $ManagerCanonicalName).UserPrincipalName
    
    # Generate email body to manager [https://html-online.com/editor/]
    $ManagerEmailBody = "
    <p>Dear $ManagerName,</p>
    <p>A new user account has been setup for $Firstname $Lastname. Please Print this out and give this to the employee on their first day. <span style=""text-decoration: underline;""><strong>Dont forward this email to their new address because they will not be able to login to their email without this password!</strong></span></p>
    <p>Their new information is as follows:</p>
    <ul>
    <li style=""text-align: left;"">Username:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Sam</li>
    <li>Domain\user name:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; checkcity\$Sam</li>
    <li>eMail Address:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; $emailAddress</li>
    <li>Temporary Password:&nbsp; &nbsp; $NewUserTempPassword</li>
    </ul>
    <p>&nbsp;</p>
    <p><span style=""background-color: #ffff00;"">PLEASE HAVE THE NEW EMPLOYEE CHANGE THIS PASSWORD ASAP ON THEIR FIRST DAY!</span></p>
    <p><span style=""background-color: #ffff00;"">They can change the password <a style=""background-color: #ffff00;"" href=""https://adfs.checkcity.com"">here</a>.</span></p>
    <p>&nbsp;</p>
    <p>Any questions with logging in should be directed to the <a href=""https://helpdesk.checkcity.com"">Help Desk</a> (855-317-0694)</p>
    <p>Thanks, <br />I.T. Department</p>
    <p>&nbsp;</p>
    <p>&nbsp;</p>
    <p>This account was created by $OperatorDisplayName on $Date at $Time</p>
    <p>&nbsp;</p>
    <p>&nbsp;</p>
        "

    # Send email to manager
    Write-Host "Emailing credentials to manager: $ManagerEmail" -ForegroundColor Yellow
    Sleep -Seconds 60
    Send-MailMessage -To $ManagerEmail -from $emailFrom -Cc $EmailAddress -Bcc $OperatorEmailAddress -Subject "A new user has been created:  $EmailAddress" -SmtpServer $SmtpServer -UseSsl -DeliveryNotificationOption $DeliveryNotificationOption -Port $Port -body $ManagerEmailBody -bodyasHTML -priority High
    Send-MailMessage -To $OperatorEmailAddress -from $emailFrom -Subject "A new user has been created:  $EmailAddress" -SmtpServer $SmtpServer -UseSsl -DeliveryNotificationOption $DeliveryNotificationOption -Port $Port -body $ManagerEmailBody -bodyasHTML -priority High

##### Log the new user, time created, and some metadata to an excel file in the housekeeping share





#Get-MsolUser -UserPrincipalName $EmailAddress | Select-Object *


}




}
