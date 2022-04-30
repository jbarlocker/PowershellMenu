############################################
#### Created on 14-SEP-2021
#### Create by Jake Barlocker
####
#### Edits:
####
####
############################################


function Scan_for_Certs {


clear

# https://fsymbols.com/generators/carty/
$Title = @"


█▀ █▀▀ ▄▀█ █▄░█   █▀▄ █▀█ █▀▄▀█ ▄▀█ █ █▄░█   █▀ █▀▀ █▀█ █░█ █▀▀ █▀█ █▀   █▀▀ █▀█ █▀█   █▀▀ ▀▄▀ █▀█ █ █▀█ █ █▄░█ █▀▀
▄█ █▄▄ █▀█ █░▀█   █▄▀ █▄█ █░▀░█ █▀█ █ █░▀█   ▄█ ██▄ █▀▄ ▀▄▀ ██▄ █▀▄ ▄█   █▀░ █▄█ █▀▄   ██▄ █░█ █▀▀ █ █▀▄ █ █░▀█ █▄█

█▀▀ █▀▀ █▀█ ▀█▀ █ █▀▀ █ █▀▀ ▄▀█ ▀█▀ █▀▀ █▀
█▄▄ ██▄ █▀▄ ░█░ █ █▀░ █ █▄▄ █▀█ ░█░ ██▄ ▄█


"@

Write-Host $Title -ForegroundColor DarkMagenta

Write-Host ""
Write-Host ""

# Ask the operator for how many days into the future that expirations should be searched for
$ExpiringInNumberOfDays = Read-Host "Find certificates expiring in How many days?"

# print something on the screen so that the operator knows that work is being done
Write-Host ""
Write-Host "Scanning... (this may take some time)" -ForegroundColor Cyan

# Get a list of all Servers in the domain
$serverlist= (Get-ADComputer -LDAPFilter "(&(objectCategory=computer)(operatingSystem=Windows Server*) (!serviceprincipalname=*MSClusterVirtualServer*) (!(userAccountControl:1.2.840.113556.1.4.803:=2)))").Name

# create an array variable to be used
Remove-Variable array
$array=@()

# iterate commands on all servers
foreach ($server in $serverlist) {
                                    $ErrorActionPreference="SilentlyContinue"
                                    
                                    # Get a list of all certs expiring in XXX days or less
                                    $RemoteCertificate = Invoke-Command -ComputerName $server -ArgumentList $ExpiringInNumberOfDays { Param( $ExpiringInNumberOfDays ); Get-ChildItem -Path Cert:\LocalMachine\My -Recurse -ExpiringInDays $ExpiringInNumberOfDays}                                    
                                    # add each certificate to the array
                                    foreach ($cert in $RemoteCertificate) {
                                                                            $array+=New-Object -TypeName PSObject -Property ([ordered]@{
                                                                                                                                        'Server'=$server;
                                                                                                                                        'Certificate'=$cert.Issuer;
                                                                                                                                        'Expiry Date'=$cert.NotAfter;
                                                                                                                                        'Friendly Name'=$cert.FriendlyName
                                                                                                                                        })
                                                                            }
                                  }





# Print the array
Write-Output $array | Sort-Object "Expiry Date",Certificate


}


