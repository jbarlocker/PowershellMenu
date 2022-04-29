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
$MenuTitle = @"
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
         Write-Host $MenuTitle -ForegroundColor Cyan
         Write-Host ""
         Write-Host "Enter '1' to Choice1      - Shadow RDP into a computer"
         Write-Host "Enter '2' to Choice2      - Sync all domain controllers, then sync to AzureAD"
         Write-Host "Enter '3' to Choice3      - Create a new user"
         Write-Host "Enter '4' to Choice4      - Delete a user"
         Write-Host "Enter '5' to Choice5      - Choice5"
         Write-Host "Enter '6' to Choice6      - Choice6"
         Write-Host "Enter '7' to Choice7      - Choice7"
         Write-Host "Enter 'Q' to Quit"
         Write-Host ""
         $MenuChoice = Read-Host "Select an option"
     }
    until ($MenuChoice -match '[1-7,qQ]')
    $Global:WindowsUpdates=$False
    $Global:DriverandFirmware=$False
    $Global:Confirm=$False

    if($MenuChoice -match 1){
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-Expression('$module="ShadowRDP";$repo="PowershellScripts"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jbarlocker/PowershellMenu/main/ShadowRDP.ps1'));Start_Shadow_RDP
    }
    if($MenuChoice -match 2){
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-Expression('$module="Sync_AD_and_AzureAD";$repo="PowershellScripts"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jbarlocker/PowershellMenu/main/Sync_AD_and_AzureAD.ps1'));SyncAllActiveDirectory
    }
<#    if($MenuChoice -match 3){
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-Expression('$module="FLEP";$repo="PowershellScripts"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jbarlocker/PowershellMenu/main/Choice3.ps1'));Invoke-Choice3function
    }
    if($MenuChoice -match 4){
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
}#End of ShowMenu
ListMenu
}
