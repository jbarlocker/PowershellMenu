


# Self-elevate the script if required
    if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
     if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
      $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
      Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
      Exit
     }
    }



# Check to see if the local computer is a member of a domain.
$JoinedToDomain = (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain
if ($JoinedToDomain -eq $False) {
                                    Write-Host ""
                                    Write-Host ""
                                    Write-Host "This computer needs to be joined to a domain." -ForegroundColor Red
                                    Write-Host ""
                                    Write-Host ""
                                    break
                                  } else {
                                          Write-Host ""
                                          Write-Host "This computer is joined to a domain... Continuing." -ForegroundColor Green
                                          Write-Host ""
                                          }

# Check to see if RSAT tools are installed, and install them if they arent.
$RsatToolList = Get-WindowsCapability -Name RSAT* -Online | Select-Object -Property *
foreach ($Tool in $RsatToolList){
                                    if ($Tool.State -eq 'NotPresent') {
                                                                        $ToolName = $Tool.Name
                                                                        Write-Host "Installing $ToolName" -ForegroundColor Yellow
                                                                        Add-WindowsCapability -Online -Name $ToolName
                                                                    }
                                 }



# Download and run Main Menu powershell script from github
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-Expression('$module="ListMenu";$repo="PowershellMenu"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jbarlocker/PowershellMenu/main/CC_MainMenu.ps1'));Master-Menu 




