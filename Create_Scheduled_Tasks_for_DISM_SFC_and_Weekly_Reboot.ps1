#########################################################################
###   Created By: Jake Barlocker
###   Created On: 14-AUG-2023
###   
###   This script will create scheduled tasks to run SFC, DISM, and Reboot weekly. This should automate keeping a computer or server healthy over a long period
###   
###   Edits:
###   
###   
###   
#########################################################################




# Check to see if powershell is running as an admin, and if not then stop the script.
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            Write-Host ""
            Write-Host "This Script Must be run as Administrator!" -ForegroundColor Yellow;
            Write-Host ""
            pause
            break;
            } ELSE {

$WantsWeeklyReboot = Read-Host "Do you want the scheduled task for a weekly reboot? (y/n)"
$WantsWeeklyReboot = $WantsWeeklyReboot.ToLower()


$action = New-ScheduledTaskAction -Execute 'dism.exe' -Argument '/Online /Cleanup-Image /CheckHealth';
$trigger =  New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 1am;
$Principal = New-ScheduledTaskPrincipal -UserId "System" -RunLevel Highest;
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "DISM - 1 - CheckHealth" -Description "This will check Windows files against Microsofts online repository every week." -Force -Principal $Principal

$action = New-ScheduledTaskAction -Execute 'dism.exe' -Argument '/Online /Cleanup-Image /ScanHealth';
$trigger =  New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 1:15am;
$Principal = New-ScheduledTaskPrincipal -UserId "System" -RunLevel Highest;
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "DISM - 2 - ScanHealth" -Description "This will check Windows files for any corruption." -Force -Principal $Principal

$action = New-ScheduledTaskAction -Execute 'dism.exe' -Argument '/Online /Cleanup-Image /RestoreHealth';
$trigger =  New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2am;
$Principal = New-ScheduledTaskPrincipal -UserId "System" -RunLevel Highest;
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "DISM - 3 - RestoreHealth" -Description "This will fix any corruption in the local Windows installation." -Force -Principal $Principal

$action = New-ScheduledTaskAction -Execute 'sfc.exe' -Argument '/scannow';
$trigger =  New-ScheduledTaskTrigger -Weekly -DaysOfWeek Saturday -At 2am;
$Principal = New-ScheduledTaskPrincipal -UserId "System" -RunLevel Highest;
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "SFC - System File Checker" -Description "This will fix any corruption in the local Windows installation." -Force -Principal $Principal

$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument 'Get-Volume | Where-Object DriveLetter | Where-Object DriveType -eq Fixed | Optimize-Volume -Defrag';
$trigger =  New-ScheduledTaskTrigger -Weekly -DaysOfWeek Wednesday -At 2am;
$Principal = New-ScheduledTaskPrincipal -UserId "System" -RunLevel Highest;
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "DEFRAG all drives" -Description "This will defrag all fixed drives on the system." -Force -Principal $Principal

if ($WantsWeeklyReboot -eq "y"){
                                $action = New-ScheduledTaskAction -Execute 'shutdown.exe' -Argument '-g -d p:0:0 -c "Planned Weekly Reboot. Rebooting in 30 minutes." -t 1800 -f';
                                $trigger =  New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 4am;
                                $Principal = New-ScheduledTaskPrincipal -UserId "System" -RunLevel Highest;
                                Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Weekly Reboot" -Description "Reboot the local computer every week" -Force -Principal $Principal
                                }



}