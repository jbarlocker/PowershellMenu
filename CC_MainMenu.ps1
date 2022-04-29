######################################################################
###   
###   Created By: Jake Barlocker
###   Created on:  29-APR-2022
###   
###   
###   
###   
###   
###   
######################################################################






Function EndScript{ 
    break
}

Function Master-Menu{
Clear-Host

# https://fsymbols.com/generators/carty/
$Title = @"

██████╗░░█████╗░░██╗░░░░░░░██╗███████╗██████╗░░██████╗██╗░░██╗███████╗██╗░░░░░██╗░░░░░███╗░░░███╗███████╗███╗░░██╗██╗░░░██╗
██╔══██╗██╔══██╗░██║░░██╗░░██║██╔════╝██╔══██╗██╔════╝██║░░██║██╔════╝██║░░░░░██║░░░░░████╗░████║██╔════╝████╗░██║██║░░░██║
██████╔╝██║░░██║░╚██╗████╗██╔╝█████╗░░██████╔╝╚█████╗░███████║█████╗░░██║░░░░░██║░░░░░██╔████╔██║█████╗░░██╔██╗██║██║░░░██║
██╔═══╝░██║░░██║░░████╔═████║░██╔══╝░░██╔══██╗░╚═══██╗██╔══██║██╔══╝░░██║░░░░░██║░░░░░██║╚██╔╝██║██╔══╝░░██║╚████║██║░░░██║
██║░░░░░╚█████╔╝░░╚██╔╝░╚██╔╝░███████╗██║░░██║██████╔╝██║░░██║███████╗███████╗███████╗██║░╚═╝░██║███████╗██║░╚███║╚██████╔╝
╚═╝░░░░░░╚════╝░░░░╚═╝░░░╚═╝░░╚══════╝╚═╝░░╚═╝╚═════╝░╚═╝░░╚═╝╚══════╝╚══════╝╚══════╝╚═╝░░░░░╚═╝╚══════╝╚═╝░░╚══╝░╚═════╝░

█▀▀ █▀█ █▀█   ▄▄   █▀▀ █░█ █▀▀ █▀▀ █▄▀ █▀▀ █ ▀█▀ █▄█   █░█ ▀█▀ ▄▀█ █░█
█▀░ █▄█ █▀▄   ░░   █▄▄ █▀█ ██▄ █▄▄ █░█ █▄▄ █ ░█░ ░█░   █▄█ ░█░ █▀█ █▀█


by: Jake Barlocker
==================================================================================

"@
Function ListMenu{
    do
     {

         Remove-Variable MenuChoice -ErrorAction SilentlyContinue
         Clear-Host
         Write-Host $Title -ForegroundColor Cyan
         Write-Host ""
         Write-Host "Enter '1' - Shadow RDP into a computer"
         Write-Host "Enter '2' - Sync all domain controllers, then sync to AzureAD"
         Write-Host "Enter '3' - Reset the Local Admin Password on all domain joined computers"
         #Write-Host "Enter '4' - Delete a user"
         #Write-Host "Enter '5' - Choice5"
         #Write-Host "Enter '6' - Choice6"
         #Write-Host "Enter '7' - Choice7"
         Write-Host "Enter 'Q' to Quit"
         Write-Host ""
         $MenuChoice = Read-Host "Select an option"
     }
    until ($MenuChoice -match '[1-3,qQ,wtfWTF]')
    $Global:WindowsUpdates=$False
    $Global:DriverandFirmware=$False
    $Global:Confirm=$False

    if($MenuChoice -match 1){
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-Expression('$module="ShadowRDP";$repo="PowershellScripts"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jbarlocker/PowershellMenu/main/ShadowRDP.ps1'));Start_Shadow_RDP
    }
    if($MenuChoice -match 2){
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-Expression('$module="Sync_AD_and_AzureAD";$repo="PowershellScripts"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jbarlocker/PowershellMenu/main/Sync_AD_and_AzureAD.ps1'));SyncAllActiveDirectory
    }
    if($MenuChoice -match 3){
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-Expression('$module="Reset_Local_Admin_Passwords";$repo="PowershellScripts"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jbarlocker/PowershellMenu/main/Reset_Local_Admin_Passwords.ps1'));ResetLocalAdminPassword
    }
<#    if($MenuChoice -match 4){
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-Expression('$module="FLCkr";$repo="PowershellScripts"'+(new-object System.net.webclient).DownloadString('https://raw.githubusercontent.com/jbarlocker/PowershellMenu/main/Choice4.ps1'));Invoke-Choice4function
    }
    if($MenuChoice -match 5){
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-Expression('$module="LogCollector";$repo="PowershellScripts"'+(new-object System.net.webclient).DownloadString('https://raw.githubusercontent.com/DellProSupportGse/Tools/main/LogCollector.ps1'));Invoke-LogCollector
    }
    if($MenuChoice -match 6){
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-Expression('$module="RunDrifT";$repo="PowershellScripts"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/DellProSupportGse/Tools/main/rundrift.ps1'));Invoke-RunDrifT
    }
    if($MenuChoice -match 7){
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-Expression('$module="RunCluChk";$repo="PowershellScripts"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/DellProSupportGse/Tools/main/RunCluChk.ps1'));Invoke-RunCluChk
    }
#>
    if($MenuChoice -imatch 'q'){
        Write-Host "Ending..." -ForegroundColor Red
        EndScript
    }
        if($MenuChoice -imatch 'wtf'){
        Start-Process https://www.youtube.com/watch?v=lUVQz6_-vxc
        EndScript
    }
}#End of ShowMenu
ListMenu
}
