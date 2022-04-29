#############################################################################################################################################
####    
####    Created by:  Jake Barlocker
####    Created on:  3-NOV-2021
####    
####    This script will query and connect to a store computer via RDP Shadowing.
####    
####    http://woshub.com/rds-shadow-how-to-connect-to-a-user-session-in-windows-server-2012-r2/
####    http://woshub.com/rdp-session-shadow-to-windows-10-user/
####    https://thesysadminchannel.com/how-to-enable-remote-desktop-via-group-policy-gpo/
####    
#############################################################################################################################################



Function Start_Shadow_RDP{
Clear

# https://fsymbols.com/generators/carty/
$Title = @"


░██████╗██╗░░██╗░█████╗░██████╗░░█████╗░░██╗░░░░░░░██╗  ██████╗░██████╗░██████╗░
██╔════╝██║░░██║██╔══██╗██╔══██╗██╔══██╗░██║░░██╗░░██║  ██╔══██╗██╔══██╗██╔══██╗
╚█████╗░███████║███████║██║░░██║██║░░██║░╚██╗████╗██╔╝  ██████╔╝██║░░██║██████╔╝
░╚═══██╗██╔══██║██╔══██║██║░░██║██║░░██║░░████╔═████║░  ██╔══██╗██║░░██║██╔═══╝░
██████╔╝██║░░██║██║░░██║██████╔╝╚█████╔╝░░╚██╔╝░╚██╔╝░  ██║░░██║██████╔╝██║░░░░░
╚═════╝░╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░░╚════╝░░░░╚═╝░░░╚═╝░░  ╚═╝░░╚═╝╚═════╝░╚═╝░░░░░
"@

Write-Host $Title -ForegroundColor DarkMagenta
Write-Host ""
Write-Host "This script must be run on a computer that is in the same domain as the target computer." -ForegroundColor Red
Write-Host ""
Write-Host ""
$ShadowTarget = Read-Host "What system do you want to shadow?  (example: hostname.domain.local) "



$TargetSessions = query session /server:$ShadowTarget
Write-Host ""
$TargetSessions
Write-Host ""
Write-Host ""
$SessionToShadow = Read-Host "Enter the ID of the session you want to shadow. (Use the console session to watch a user that is sitting at the computer, or use an rdp-tcp session to watch a remoted in user.) "

If (!$SessionToShadow) {} else {
                        mstsc /v:$ShadowTarget /shadow:$SessionToShadow /NoConsentPrompt
                        }



                            }

