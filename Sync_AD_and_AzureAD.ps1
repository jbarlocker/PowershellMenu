

function SyncAllActiveDirectory {

clear

# https://fsymbols.com/generators/carty/
$Title = @"

░██████╗██╗░░░██╗███╗░░██╗░█████╗░  ░█████╗░░█████╗░████████╗██╗██╗░░░██╗███████╗
██╔════╝╚██╗░██╔╝████╗░██║██╔══██╗  ██╔══██╗██╔══██╗╚══██╔══╝██║██║░░░██║██╔════╝
╚█████╗░░╚████╔╝░██╔██╗██║██║░░╚═╝  ███████║██║░░╚═╝░░░██║░░░██║╚██╗░██╔╝█████╗░░
░╚═══██╗░░╚██╔╝░░██║╚████║██║░░██╗  ██╔══██║██║░░██╗░░░██║░░░██║░╚████╔╝░██╔══╝░░
██████╔╝░░░██║░░░██║░╚███║╚█████╔╝  ██║░░██║╚█████╔╝░░░██║░░░██║░░╚██╔╝░░███████╗
╚═════╝░░░░╚═╝░░░╚═╝░░╚══╝░╚════╝░  ╚═╝░░╚═╝░╚════╝░░░░╚═╝░░░╚═╝░░░╚═╝░░░╚══════╝

██████╗░██╗██████╗░███████╗░█████╗░████████╗░█████╗░██████╗░██╗░░░██╗
██╔══██╗██║██╔══██╗██╔════╝██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗╚██╗░██╔╝
██║░░██║██║██████╔╝█████╗░░██║░░╚═╝░░░██║░░░██║░░██║██████╔╝░╚████╔╝░
██║░░██║██║██╔══██╗██╔══╝░░██║░░██╗░░░██║░░░██║░░██║██╔══██╗░░╚██╔╝░░
██████╔╝██║██║░░██║███████╗╚█████╔╝░░░██║░░░╚█████╔╝██║░░██║░░░██║░░░
╚═════╝░╚═╝╚═╝░░╚═╝╚══════╝░╚════╝░░░░╚═╝░░░░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░

"@

Write-Host $Title -ForegroundColor DarkMagenta

Write-Host ""
Write-Host ""
Write-Host "This Must be run on a Domain Controller" -ForegroundColor Red
Write-Host ""
Write-Host ""
Write-Host "Synchronizating on Domain Controllers..." -ForegroundColor Magenta

# replicate all domain controllers
(Get-ADDomainController -Filter *).Name | Foreach-Object {repadmin /syncall $_ (Get-ADDomain).DistinguishedName /e /A | Out-Null}; Start-Sleep 10; Get-ADReplicationPartnerMetadata -Target "$env:userdnsdomain" -Scope Domain | Select-Object Server, LastReplicationSuccess

Write-Host ""
Write-Host "Complete." -ForegroundColor Green

Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host "Initiating Synchronizations to Azure Active Directory..." -ForegroundColor Magenta

#Import modeult to sunc to Azure AD
Import-Module ADSync

# replicate to Azure AD (sync changes)
Start-ADSyncSyncCycle -PolicyType Delta

# replicate to Azure AD (full sync)
#Start-ADSyncSyncCycle -PolicyType Initial


Write-Host "Command Sent. Syncing to AzureAD should be complete in the next few minutes." -ForegroundColor Green



                                }