############################################################
###   
###   Created by:  Jake Barlocker
###   Created on:  13-JUL-2022
###   
###   http://woshub.com/pswindowsupdate-module/
###   WINDOWS UPDATES
###   
############################################################

Function RunWindowsUpdates {


clear

# Check to see if powershell is running as an admin, and if not then stop the script.
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            Write-Host ""
            Write-Host "This Script Must be run as Administrator!" -ForegroundColor Yellow;
            Write-Host ""
            pause
            break;
            } ELSE {






# Check for NuGet and PSWindowsUpdate, then install them if they are missing
    if (Get-PackageProvider -ListAvailable -Name NuGet) {
                                                         clear
                                                         Write-Host "NuGet is already installed" -ForegroundColor Green
                                                         Write-Host " "
                                                         } else {
                                                                 clear
                                                                 Write-Host "Installing NuGet" -ForegroundColor Yellow
                                                                 Write-Host " "
                                                                 Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
                                                                 }
    if (Get-Module -ListAvailable -Name PSWindowsUpdate) {
                                                      Write-Host "PSWindowsUpdate is already installed" -ForegroundColor Green
                                                      Write-Host " "
                                                      } else {
                                                              Write-Host "Installing PSWindowsUpdate" -ForegroundColor Yellow
                                                              Write-Host " "
                                                              Find-Module PSWindowsUpdate | Install-Module -Force
                                                              }





$DomainToScan = Read-Host "Enter domain to scan and update (example: contoso.com)"

$DomainController = Get-ADDomainController -DomainName $DomainToScan -Discover
$DomainControllerFQDN = $DomainController.Name + "." + $DomainController.Domain


$Domain_User_Prepopulate = $DomainToScan + "\USERNAME"
$Credential = Get-Credential -Message "Enter Credentials for $DomainToScan" -UserName $Domain_User_Prepopulate





# Get a list of all computer and server objects
Remove-Variable ComputerObjects, ServerObjects -ErrorAction SilentlyContinue
$ComputerObjects = @()
$ComputerObjects = Invoke-Command -Credential $Credential -ComputerName $DomainControllerFQDN {(Get-ADComputer -LDAPFilter "(&(objectCategory=computer)(!operatingSystem=Windows Server*) (!serviceprincipalname=*MSClusterVirtualServer*) (!(userAccountControl:1.2.840.113556.1.4.803:=2)))").DNSHostName | Sort-Object}
$ComputerObjects = $ComputerObjects | Sort-Object
$ComputerObjectsCount = $ComputerObjects.count
$ComputerObjects.count


<#
$ServerObjects = @()
$ServerObjects = Invoke-Command -Credential $Credential -ComputerName $DomainControllerFQDN {(Get-ADComputer -LDAPFilter "(&(objectCategory=computer)(operatingSystem=Windows Server*) (!serviceprincipalname=*MSClusterVirtualServer*) (!(userAccountControl:1.2.840.113556.1.4.803:=2)))").DNSHostName | Sort-Object}
$ServerObjects = $ServerObjects | Sort-Object
$ServerObjectsCount = $ServerObjects.count
$ServerObjects.count


#######################################################
### Get Clustered Servers to exclude from updates   ###
#######################################################

Install-WindowsFeature RSAT-Clustering-PowerShell 

$ClusterNames = (Get-Cluster -Domain $DomainToScan).Name 


# remove servers objects that must be updated manually (such as clustered systems)
Remove-Variable ServerObjectsToNotUpdate -ErrorAction SilentlyContinue
$ServerObjectsToNotUpdate = @()

ForEach ($ClusterName in $ClusterNames){
                                        $NodeNames = (Get-ClusterNode -Cluster $ClusterName).Name
                                        Foreach ($Node in $NodeNames) {
                                                                       $ServerObjectsToNotUpdate += (Get-ADComputer -Identity $Node).DNSHostName
                                                                       }
                                        }


$ServerObjects = $ServerObjects | Where-Object {$ServerObjectsToNotUpdate -notcontains $_ }


########################################################


$ServerObjectsCount = $ServerObjects.count
$ServerObjects.count

#>





Remove-Variable Sessions -ErrorAction SilentlyContinue
$Sessions = New-PSSession -ComputerName $ComputerObjects -Credential $Credential -ThrottleLimit 10



# on each computer run commands
foreach ($Session in $Sessions) {
 Invoke-Command -Session $Session -ScriptBlock {
                                                
                                                Set-ExecutionPolicy Bypass -Force
                                                Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.208 -Force;
                                                Find-Module PSWindowsUpdate -MinimumVersion 2.2.1.4 | Install-Module -Force;
                                                Import-Module PSWindowsUpdate;
                                                #Get-WUList -MicrosoftUpdate | ft;
                                                Enable-WURemoting;

                                                #Install-WindowsUpdate -AcceptAll -ForceDownload -ForceInstall | Out-File C:\TEMP\PSWindowsUpdate.log -Append;
                                                Invoke-WUJob -Script { Install-WindowsUpdate -AcceptAll -ForceDownload -ForceInstall -SendReport -IgnoreReboot | Out-File C:\TEMP\PSWindowsUpdate.log -Append } -Confirm:$false -verbose -RunNow;


                                                $action = New-ScheduledTaskAction -Execute 'sfc.exe' -Argument '/scannow';
                                                $trigger =  New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 12am;
                                                $Principal = New-ScheduledTaskPrincipal -UserId "System" -RunLevel Highest;
                                                Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "SFC - System File Checker" -Description "This will fix any corruption in the local Windows installation." -Force -Principal $Principal;

                                                $action = New-ScheduledTaskAction -Execute 'dism.exe' -Argument '/Online /Cleanup-Image /CheckHealth';
                                                $trigger =  New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 1am;
                                                $Principal = New-ScheduledTaskPrincipal -UserId "System" -RunLevel Highest;
                                                Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "DISM - 1 - CheckHealth" -Description "This will check Windows files against Microsofts online repository every week." -Force -Principal $Principal;

                                                $action = New-ScheduledTaskAction -Execute 'dism.exe' -Argument '/Online /Cleanup-Image /ScanHealth';
                                                $trigger =  New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 1:15am;
                                                $Principal = New-ScheduledTaskPrincipal -UserId "System" -RunLevel Highest;
                                                Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "DISM - 2 - ScanHealth" -Description "This will check Windows files for any corruption." -Force -Principal $Principal;

                                                $action = New-ScheduledTaskAction -Execute 'dism.exe' -Argument '/Online /Cleanup-Image /RestoreHealth';
                                                $trigger =  New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2am;
                                                $Principal = New-ScheduledTaskPrincipal -UserId "System" -RunLevel Highest;
                                                Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "DISM - 3 - RestoreHealth" -Description "This will fix any corruption in the local Windows installation." -Force -Principal $Principal;

                                                $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument 'Get-Volume | Where-Object DriveLetter | Where-Object DriveType -eq Fixed | Optimize-Volume -Defrag';
                                                $trigger =  New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 3am;
                                                $Principal = New-ScheduledTaskPrincipal -UserId "System" -RunLevel Highest;
                                                Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "DEFRAG all drives" -Description "This will defrag all fixed drives on the system." -Force -Principal $Principal;

                                                } -AsJob
                                    }





<#

Remove-Variable ServerSessions -ErrorAction SilentlyContinue
$ServerSessions = New-PSSession -ComputerName $ServerObjects -Credential $Credential -ThrottleLimit 10

# on each server run commands
foreach ($ServerSession in $ServerSessions) {
 Invoke-Command -Session $ServerSession -ScriptBlock {
                                                
                                                Set-ExecutionPolicy Bypass -Force
                                                Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.208 -Force;
                                                Find-Module PSWindowsUpdate -MinimumVersion 2.2.1.4 | Install-Module -Force;
                                                Import-Module PSWindowsUpdate;
                                                #Get-WUList -MicrosoftUpdate | ft;
                                                Enable-WURemoting;
                                                New-Item -Path "C:\" -Name "TEMP" -ItemType Directory -ErrorAction SilentlyContinue
                                                
                                                #Install-WindowsUpdate -AcceptAll -ForceDownload -ForceInstall | Out-File C:\TEMP\PSWindowsUpdate.log -Append;
                                                Invoke-WUJob -Script { Install-WindowsUpdate -AcceptAll -ForceDownload -ForceInstall -SendReport -IgnoreReboot | Out-File C:\TEMP\PSWindowsUpdate.log -Append } -Confirm:$false -verbose -RunNow;
                                             } -AsJob



                                             }

#>



Get-Job | Sort-Object state, location
(Get-Job).count
#Get-Job | Remove-Job -Force

<#
Get-WUJob

Get-Job -State Failed | Remove-Job
Get-Job -State Completed | Remove-Job
Get-Job -State Disconnected | Remove-Job -Force
Get-Job -State Blocked | Remove-Job -Force
#>


















}


}


