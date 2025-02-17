﻿

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
#Write-Host "This Must be run on a Domain Controller" -ForegroundColor Red
Write-Host ""
Write-Host ""
Write-Host "Synchronizing Domain Controllers..." -ForegroundColor Magenta

# replicate all domain controllers
(Get-ADDomainController -Filter *).Name | Foreach-Object {repadmin /syncall $_ (Get-ADDomain).DistinguishedName /e /A | Out-Null}; Start-Sleep 10; Get-ADReplicationPartnerMetadata -Target "$env:userdnsdomain" -Scope Domain | Select-Object Server, LastReplicationSuccess

Write-Host ""
Write-Host "Complete." -ForegroundColor Green

Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
<#
Write-Host "Initiating Synchronizations to Azure Active Directory..." -ForegroundColor Magenta




#get a list of all domain controllers
$DomainControllers = (Get-ADDomainController -Filter *).Name

# Create a blank variable
$DcRunningAdSync = $null

# Scan each DC for the AD Sync program
foreach ($DomainController in $DomainControllers) {
                                                    
                                                    # Run the commands on the remote DC to initiate an AD Sync to AzureAD
                                                    Invoke-Command -ComputerName $DomainController -ScriptBlock {
                                                            #Import modeult to sunc to Azure AD
                                                            Import-Module ADSync;

                                                            # replicate to Azure AD (sync changes)
                                                            Start-ADSyncSyncCycle -PolicyType Delta;
                                                            
                                                            # replicate to Azure AD (full sync)
                                                            #Start-ADSyncSyncCycle -PolicyType Initial
                                                            } -ErrorAction SilentlyContinue

                                                   }
#>

# write the hostname of the server with AD Sync installed to the console
#Write-Host "Syncing from $DcRunningAdSync" -ForegroundColor Magenta

<#
# Run the commands on the remote DC to initiate an AD Sync to AzureAD
Invoke-Command -ComputerName $DcRunningAdSync -ScriptBlock {
                                                            #Import modeult to sunc to Azure AD
                                                            Import-Module ADSync;

                                                            # replicate to Azure AD (sync changes)
                                                            Start-ADSyncSyncCycle -PolicyType Delta;
                                                            
                                                            # replicate to Azure AD (full sync)
                                                            #Start-ADSyncSyncCycle -PolicyType Initial
                                                            }

                                                            
Write-Host "Command Sent. Syncing to AzureAD should be complete in the next few minutes." -ForegroundColor Green

#>


                                }
