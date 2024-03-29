######################################################################
###   
###   Created By: Jake Barlocker
###   Created on:  3-JAN-2024
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

Function QA-Menu{
Clear-Host

# https://fsymbols.com/generators/carty/
$Title = @"

QA and Testing Menu
   - For CheckCity Utah


by: Jake Barlocker
==================================================================================

"@
Function ListMenu{
    do
     {

         Remove-Variable MenuChoice -ErrorAction SilentlyContinue
         Clear-Host
         Write-Host $Title -ForegroundColor Cyan -BackgroundColor Black
         Write-Host ""
         Write-Host "Enter '1' - VPN Tester - Ping all subnets"
         Write-Host "Enter '2' - Run a health check for websites on the webapp servers"
         Write-Host "Enter '3' - Check webservers for file parity"
<#         Write-Host "Enter '4' - Reset the Local Admin Password on all domain joined computers"
         Write-Host "Enter '5' - Scan domain servers for expiring certificates"
         Write-Host "Enter '6' - Reset your passwords on all domains"
         Write-Host "Enter '7' - Setup Automated Health Maintenance Tasks on local computer"
         Write-Host "Enter 'QA' - Enter the Quality Assurance and Testing Submenu"
#>
         Write-Host "Enter 'Q' to Quit"
         Write-Host ""
         $MenuChoice = Read-Host "Select an option"
     }
    until ($MenuChoice -match '[1-7,qQ,]')
    $Global:WindowsUpdates=$False
    $Global:DriverandFirmware=$False
    $Global:Confirm=$False

    if($MenuChoice -match 1){
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-Expression('$module="Test_Subnets";$repo="PowershellScripts"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jbarlocker/PowershellMenu/main/VPN_Route_Tester.ps1'));Test_Subnets
    }
    if($MenuChoice -match 2){
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-Expression('$module="Start_Health_Check";$repo="PowershellScripts"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jbarlocker/PowershellMenu/main/HealthCheck_for_WebApp_Servers.ps1'));Start_Health_Check
    }
    if($MenuChoice -match 3){
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-Expression('$module="Webserver_File_Parity_Check";$repo="PowershellScripts"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jbarlocker/PowershellMenu/main/QA_Check_Webservers_file_parity.ps1'));Webserver_File_Parity_Check
    }
    if($MenuChoice -match 4){
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-Expression('$module="Reset_Local_Admin_Passwords";$repo="PowershellScripts"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jbarlocker/PowershellMenu/main/Reset_Local_Admin_Passwords.ps1'));ResetLocalAdminPassword
    }
    if($MenuChoice -match 5){
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-Expression('$module="Scan_Domain_Servers_for_Expiring_Certificates";$repo="PowershellScripts"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jbarlocker/PowershellMenu/main/Scan_Domain_Servers_for_Expiring_Certificates.ps1'));Scan_for_Certs
    }
    if($MenuChoice -match 6){
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-Expression('$module="Reset_a_users_password_on_all_domains.ps1";$repo="PowershellScripts"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jbarlocker/PowershellMenu/main/Reset_a_users_password_on_all_domains.ps1'));ResetAllDomainsPasswords
    }
    if($MenuChoice -match 7){
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-Expression('$module="Create_Scheduled_Tasks_for_DISM_SFC_and_Weekly_Reboot.ps1";$repo="PowershellScripts"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jbarlocker/PowershellMenu/main/Create_Scheduled_Tasks_for_DISM_SFC_and_Weekly_Reboot.ps1'));CreateScheduledTasks
    }
    if($MenuChoice -match 'qa'){
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-Expression('$module="Create_Scheduled_Tasks_for_DISM_SFC_and_Weekly_Reboot.ps1";$repo="PowershellScripts"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jbarlocker/PowershellMenu/main/Create_Scheduled_Tasks_for_DISM_SFC_and_Weekly_Reboot.ps1'));CreateScheduledTasks
    }

    if($MenuChoice -imatch 'q'){
        Write-Host "Ending..." -ForegroundColor Red
        EndScript
    }

}#End of ShowMenu
ListMenu
}
