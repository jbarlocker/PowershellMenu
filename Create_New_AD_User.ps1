################################################
###   
###   This script will create a new user for CheckCity
###   
###   Created on: 7-FEB-2022
###   Created by: Josue Franco
###   
###   
###   Edits:
###   5-AUG-2022: Jake Barlocker - finalizing script and adding O365 code to create email accounts.
###   8-AUG-2022: Jake Barlocker - fixing AD to O365 sync and adding license to account in o365
###   
###   
###   
###   
###   
###   
###   
###   
###   
################################################


Function Create_New_AD_User {


clear


$NewUserTempPassword = "Ch3ckcity!"


# Check to see if powershell is running as an admin, and if not then stop the script.
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            Write-Host ""
            Write-Host "This Script Must be run as Administrator!" -ForegroundColor Yellow;
            Write-Host ""
            pause
            break;
            }



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


# Find out who is running this script
$OperatorDomainAndUsername = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$OperatorUsername = $OperatorDomainAndUsername.Split('\')
$OperatorIdentity = Get-ADUser -Identity $OperatorUsername[1]
$OperatorFirstName = $OperatorIdentity.GivenName
$OperatorLastName = $OperatorIdentity.Surname

<#
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
#>





# Login to ExchangeOnline
Write-Host " "
Write-Host " "
Write-Host "Connecting to ExchangeOnline..." -ForegroundColor Cyan
Connect-MsolService





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


##### Assign group membership to new user
$TemplateUserGroups | Add-ADGroupMember -Members $Sam

##### Create a variable of the new user object
$NewlyCreatedUser = Get-ADUser $Sam -Properties *


##### Populate account fields if available
If ($TemplateUserObject.Title -ne $null){ $NewlyCreatedUser | Set-ADUser -Title $TemplateUserObject.Title }
If ($TemplateUserObject.Department -ne $null){ $NewlyCreatedUser | Set-ADUser -Department $TemplateUserObject.Department }
If ($TemplateUserObject.Manager -ne $null){ $NewlyCreatedUser | Set-ADUser -Manager $TemplateUserObject.Manager }
If ($TemplateUserObject.Company -ne $null){ $NewlyCreatedUser | Set-ADUser -Company $TemplateUserObject.Company }
If ($TemplateUserObject.Description -ne $null){ $NewlyCreatedUser | Set-ADUser -Description $TemplateUserObject.Description }
If ($TemplateUserObject.Office -ne $null){ $NewlyCreatedUser | Set-ADUser -Office $TemplateUserObject.Office }
If ($CellPhoneNumber -ne ""){ $NewlyCreatedUser | Set-ADUser -MobilePhone $CellPhoneNumber } 

$EmailAddress = $NewlyCreatedUser.UserPrincipalName
$NewlyCreatedUser | Set-ADUser -email $EmailAddress
$NewlyCreatedUser | Set-ADUser -add @{ProxyAddresses="SMTP:$EmailAddress"}



##### Set ccc7dc01 to sync all domain controllers, then sync to azureAD
Write-Host ""
Write-Host "Syncing all Active Directory Domain Controllers..." -ForegroundColor Yellow
Invoke-Command -ComputerName ccc7dc01.checkcity.local -FilePath "\\ccc7dc01.checkcity.local\c$\Windows\Scripts\SYNC all DCs and Azure AD.ps1" | ft
Write-Host "Syncing from Active Directory to AzureAD..." -ForegroundColor Yellow


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
    Remove-Variable FailedSkus
    $FailedSkus = @()
    Foreach ($Sku in $AllO365Skus) {
                                    $SkuName = $Sku.AccountSkuId
                                    $UsersOfSku = Get-MsolUser -All | Where-Object {($_.licenses).AccountSkuId -match $Sku.AccountSkuId}
                                    If ($UsersOfSku.DisplayName -contains $TemplateUserObject.DisplayName) {
                                                                                                            Set-MsolUserLicense -UserPrincipalName $EmailAddress -AddLicenses $Sku.AccountSkuId
                                                                                                            If ($Sku.ActiveUnits -eq $Sku.ConsumedUnits) { 
                                                                                                                                                          $FailedSkus += $SkuName
                                                                                                                                                          Write-Host "$EmailAddress was NOT given the $FailedSkus license! There are none available." -ForegroundColor Red
                                                                                                                                                          }
                                                                                                      }
                                    }



    # List out the licenses that failed to apply
    If ($FailedSkus) {
                       Write-Host "Licenses that Failed to be applied to the user:" -ForegroundColor Red
                       Write-Host ""
                        foreach ( $FailedSku in $FailedSkus ) {
                                                               Write-Host "[$FailedSku]" -ForegroundColor Red
                                                               }
                        }











}






