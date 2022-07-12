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


clear
$Number_of_domains_to_scan = Read-Host "How many domains do you want to scan?"
$Counter = 0



# Delete variable, then make sure to create it as an array
Remove-Variable List_Of_Domains -ErrorAction SilentlyContinue
$List_Of_Domains = @()


# Get a list of servers to create PS Sessions on (one domain controller from each domain)
While ($Counter -ne $Number_of_domains_to_scan) {
                                                 $Counter++
                                                 $List_Of_Domains += Read-Host "$Counter) Enter a domain name (ie - contoso.local)"
                                                 }


#################################
# Get Credentials for each domain
#################################

Remove-Variable Credentials -ErrorAction SilentlyContinue
$Credentials = @()
$Counter = 0
While ($Counter -ne ($List_Of_Domains.Count)) {
                                               $CurrentDomain = $List_Of_Domains[$Counter]
                                               $Domain_User_Prepopulate = $CurrentDomain + "\USERNAME"
                                               $Credentials += Get-Credential -Message "Enter Credentials for $CurrentDomain" -UserName $Domain_User_Prepopulate
                                               $Counter++
                                       }


################################################
# Get FQDN of a domain controller in each domain
################################################

Remove-Variable DomainControllerFQDN -ErrorAction SilentlyContinue
$DomainControllerFQDN = @()

# reset counter to zero
$Counter = 0

While ($Counter -ne $List_Of_Domains.Count) {
                                             
                                             $CurrentDomain = $List_Of_Domains[$Counter]
                                             $DomainController = Get-ADDomainController -DomainName $CurrentDomain -Discover
                                             $DomainControllerFQDN += $DomainController.Name + "." + $DomainController.Domain
                                             
                                             $Counter++
                                             }





################################
# Open PSSessions to each domain
################################

Get-PSSession | Remove-PSSession

# reset counter to zero
$Counter = 0

While ($Counter -ne $List_Of_Domains.Count) {
                                             # Open a pssession.
                                             $CurrentCredential = $Credentials[$Counter]
                                             New-PSSession -ComputerName $DomainControllerFQDN[$Counter] -Credential $CurrentCredential
                                             
                                             $Counter++
                                             }


Get-PSSession


##########################################################
# Use open PSSessions to scan each domain for certificates
##########################################################

# Ask the operator for how many days into the future that expirations should be searched for
Write-Host " "
$ExpiringInNumberOfDays = Read-Host "Find certificates expiring in How many days?"

$Counter = 0

# create an array variable to be used
Remove-Variable Certificates -ErrorAction SilentlyContinue
$Certificates = @()

While ($Counter -lt $List_Of_Domains.Count) {
                                                                                          
                                             # Get a list of all Servers in the domain
                                             Remove-Variable serverlist -ErrorAction SilentlyContinue
                                             $serverlist = Invoke-Command -Credential $Credentials[$Counter] -ComputerName $DomainControllerFQDN[$Counter] {(Get-ADComputer -LDAPFilter "(&(objectCategory=computer) (operatingSystem=Windows Server*) (!(userAccountControl:1.2.840.113556.1.4.803:=2)))").DNSHostName}
                                             
                                             $ServerNumber = 1

                                             # iterate commands on all servers
                                             foreach ($server in $serverlist) {
                                                                               $ErrorActionPreference="SilentlyContinue"
                                                                               
                                                                               $NumberOfServersInDomain = $serverlist.count
                                                                               Write-Host "Scanning ($server)...     $ServerNumber of $NumberOfServersInDomain" -ForegroundColor Yellow
                                                                               $ServerNumber ++

                                                                               $CurrentDomain = $List_Of_Domains[$Counter]
                                                                               Write-Host $CurrentDomain -ForegroundColor Green

                                                                               # Get a list of all certs expiring in XXX days or less
                                                                               $RemoteCertificate = Invoke-Command -Credential $Credentials[$Counter] -ComputerName $server -ArgumentList $ExpiringInNumberOfDays { Param( $ExpiringInNumberOfDays ); Get-ChildItem -Path Cert:\LocalMachine\My -Recurse -ExpiringInDays $ExpiringInNumberOfDays}                                    
                                                                               
                                                                               # add each certificate to the array
                                                                               foreach ($cert in $RemoteCertificate) {
                                                                                                                      $Certificates += New-Object -TypeName PSObject -Property ([ordered]@{
                                                                                                                                                                                           'Server'=$server;
                                                                                                                                                                                           'Certificate'=$cert.Issuer;
                                                                                                                                                                                           'Expiry Date'=$cert.NotAfter;
                                                                                                                                                                                           'Friendly Name'=$cert.FriendlyName;
                                                                                                                                                                                           'Thumbprint'=$cert.Thumbprint
                                                                                                                                                                                           })
                                                                                                                      }
                                                                                }
                                              $Counter ++
                                              }



# Print the array
Write-Output $Certificates | Sort-Object "Expiry Date",Certificate | ft








Get-PSSession | Remove-PSSession




