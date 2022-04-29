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
 
Powershell Menu

by: Jake Barlocker

"@
Function ListMenu{
    do
     {

         Remove-Variable MenuChoice -ErrorAction SilentlyContinue
         Clear-Host
         Write-Host $MenuTitle -ForegroundColor Magenta
         Write-Host ""
         Write-Host "==================== Please select an option ====================="
         Write-Host ""
         Write-Host "Press '1' to Choice1      - Shadow RDP into a computer"
         Write-Host "Press '2' to Choice2      - Get Windows Updates on a remote computer"
         Write-Host "Press '3' to Choice3      - Create a new user"
         Write-Host "Press '4' to Choice4      - Delete a user"
         Write-Host "Press '5' to Choice5      - Choice5"
         Write-Host "Press '6' to Choice6      - Choice6"
         Write-Host "Press '7' to Choice7      - Choice7"
         Write-Host "Press 'Q' to Quit"
         Write-Host ""
         $MenuChoice = Read-Host "Select an option"
     }
    until ($MenuChoice -match '[1-7,qQ]')
    $Global:WindowsUpdates=$False
    $Global:DriverandFirmware=$False
    $Global:Confirm=$False

    if($MenuChoice -match 1){
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-Expression('$module="BOILER";$repo="PowershellScripts"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/DellProSupportGse/Tools/main/BOILER.ps1'));Invoke-BOILER
    }
    if($MenuChoice -match 2){
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-Expression('$module="DART";$repo="PowershellScripts"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/DellProSupportGse/Tools/main/DART.ps1'));Invoke-DART
    }
    if($MenuChoice -match 3){
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-Expression('$module="FLEP";$repo="PowershellScripts"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/DellProSupportGse/Tools/main/FLEP.ps1'));Invoke-FLEP
    }
    if($MenuChoice -match 4){
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-Expression('$module="FLCkr";$repo="PowershellScripts"'+(new-object System.net.webclient).DownloadString('https://raw.githubusercontent.com/DellProSupportGse/Tools/main/FLCkr.ps1'));Invoke-FLCkr
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

    if($MenuChoice -imatch 'q'){
        Write-Host "Ending..." -ForegroundColor Red
        EndScript
    }
}#End of ShowMenu
ListMenu
}
