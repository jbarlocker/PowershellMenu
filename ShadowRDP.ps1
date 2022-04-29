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
Write-Host ""
Write-Host ""
Write-Host "This script must be run on a computer in the checkcity.local domain." -ForegroundColor Red
Write-Host ""
Write-Host ""
$ShadowTarget = Read-Host "What workstation do you want to shadow?  (example: u210w6.checkcity.local) "



$TargetSessions = query session /server:$ShadowTarget
Write-Host ""
$TargetSessions
Write-Host ""
Write-Host ""
$SessionToShadow = Read-Host "Enter the ID of the session you want to shadow"

If (!$SessionToShadow) {} else {
                        mstsc /v:$ShadowTarget /shadow:$SessionToShadow /NoConsentPrompt
                        }



                            }

