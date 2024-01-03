####################
###   
###   Created On:  1-JAN-2024
###   Created By:  Jake Barlocker
###   
###   
###   This script will ping an IP on all the subnets on the network and output a table so that you can see where failures are
###   
###   
###   
###   
###   
###   
###   
###   
###   
###   
######################



# Script to test all vlans in the internal network and display the result in an eay to read format

Function Test_Subnets {

Write-Host "Please wait while the script runs.  It can take upwards of 5 minutes..." -ForegroundColor Cyan -BackgroundColor DarkGray

$Endpoints = @( 
               [pscustomobject]@{Group="Databank";Name="VLAN 43";IpAddress='10.127.43.1'}
               [pscustomobject]@{Group="Databank";Name="VLAN 74";IpAddress='10.127.74.10'}
               [pscustomobject]@{Group="Databank";Name="VLAN 75";IpAddress='10.127.75.62'}
               [pscustomobject]@{Group="Databank";Name="VLAN 76";IpAddress='10.127.76.1'}
               [pscustomobject]@{Group="Databank";Name="VLAN 77";IpAddress='10.127.77.10'}
               [pscustomobject]@{Group="Databank";Name="VLAN 83";IpAddress='10.127.83.82'}
               [pscustomobject]@{Group="Databank";Name="VLAN 172";IpAddress='10.127.172.1'}
               [pscustomobject]@{Group="Databank";Name="VLAN 190";IpAddress='10.127.190.1'}
               [pscustomobject]@{Group="Databank";Name="VLAN 192";IpAddress='10.127.192.1'}
               [pscustomobject]@{Group="Corporate";Name="VLAN CCHQ-10";IpAddress='10.130.10.1'}
               [pscustomobject]@{Group="Corporate";Name="VLAN CCHQ-11";IpAddress='10.130.11.1'}
               [pscustomobject]@{Group="Corporate";Name="VLAN CCHQ-12";IpAddress='10.130.12.1'}
               [pscustomobject]@{Group="Corporate";Name="VLAN 192";IpAddress='10.130.192.1'}
               [pscustomobject]@{Group="Corporate";Name="VLAN 26";IpAddress='10.130.26.1'}
               [pscustomobject]@{Group="Corporate";Name="VLAN 43";IpAddress='10.130.43.1'}
               [pscustomobject]@{Group="Corporate";Name="VLAN 44";IpAddress='10.130.44.1'}
               [pscustomobject]@{Group="Stores";Name="Store U20 Router";IpAddress='10.133.2.1'}
               [pscustomobject]@{Group="Stores";Name="Store U40 Router";IpAddress='10.133.4.1'}
               [pscustomobject]@{Group="Stores";Name="Store U50 Router";IpAddress='10.133.5.1'}
               [pscustomobject]@{Group="Stores";Name="Store U60 Router";IpAddress='10.133.6.1'}
               [pscustomobject]@{Group="Stores";Name="Store U70 Router";IpAddress='10.133.7.1'}
               [pscustomobject]@{Group="Stores";Name="Store U80 Router";IpAddress='10.133.8.1'}
               [pscustomobject]@{Group="Stores";Name="Store U90 Router";IpAddress='10.133.9.1'}
               [pscustomobject]@{Group="Stores";Name="Store U100 Router";IpAddress='10.133.10.1'}
               [pscustomobject]@{Group="Stores";Name="Store U110 Router";IpAddress='10.133.11.1'}
               [pscustomobject]@{Group="Stores";Name="Store U120 Router";IpAddress='10.133.12.1'}
               [pscustomobject]@{Group="Stores";Name="Store U130 Router";IpAddress='10.133.13.1'}
               [pscustomobject]@{Group="Stores";Name="Store U140 Router";IpAddress='10.133.14.1'}
               [pscustomobject]@{Group="Stores";Name="Store U150 Router";IpAddress='10.133.15.1'}
               [pscustomobject]@{Group="Stores";Name="Store U160 Router";IpAddress='10.133.16.1'}
               [pscustomobject]@{Group="Stores";Name="Store U170 Router";IpAddress='10.133.17.1'}
               [pscustomobject]@{Group="Stores";Name="Store U180 Router";IpAddress='10.133.18.1'}
               [pscustomobject]@{Group="Stores";Name="Store U190 Router";IpAddress='10.133.19.1'}
               [pscustomobject]@{Group="Stores";Name="Store U200 Router";IpAddress='10.133.20.1'}
               [pscustomobject]@{Group="Stores";Name="Store U210 Router";IpAddress='10.133.21.1'}
               [pscustomobject]@{Group="Stores";Name="Store U220 Router";IpAddress='10.133.22.1'}
               [pscustomobject]@{Group="Stores";Name="Store U230 Router";IpAddress='10.133.23.1'}
               [pscustomobject]@{Group="Stores";Name="Store U240 Router";IpAddress='10.133.24.1'}
               [pscustomobject]@{Group="Stores";Name="Store U250 Router";IpAddress='10.133.25.1'}
               [pscustomobject]@{Group="Stores";Name="Store U260 Router";IpAddress='10.133.26.1'}
               [pscustomobject]@{Group="Stores";Name="Store U270 Router";IpAddress='10.133.27.1'}
               [pscustomobject]@{Group="Stores";Name="Store U290 Router";IpAddress='10.133.29.1'}
               [pscustomobject]@{Group="Stores";Name="Store U300 Router";IpAddress='10.133.30.1'}
               [pscustomobject]@{Group="Stores";Name="Store U300 Router";IpAddress='10.133.30.1'}
               [pscustomobject]@{Group="Internet";Name="google dns";IpAddress='8.8.8.8'}
               [pscustomobject]@{Group="Internet";Name="cloudflare dns";IpAddress='1.1.1.1'}
               [pscustomobject]@{Group="Internet";Name="Level3 dns";IpAddress='4.2.2.1'}
               )

Remove-Variable ResultTable -ErrorAction SilentlyContinue
$ResultTable = @()

#Workflow Test-AllConnections {
                             
                             Foreach  ($Endpoint in $Endpoints)  {
                                                                   #Test-NetConnection -Port 80 -InformationLevel "Detailed"
                                                                   
                                                                   $Results = Test-NetConnection -InformationLevel "Detailed" -ComputerName $Endpoint.IpAddress
                                                                   $ResultTable += [pscustomobject]@{Name=$Endpoint.Name;IpAddress=$Endpoint.IpAddress;Interface=$Results.InterfaceAlias;SourceAddress=$Results.SourceAddress.IPAddress;PingSucceeded=$Results.PingSucceeded;RTT=$Results.PingReplyDetails.RoundtripTime}
                                                                   }
#                             }

Test-AllConnections

$ResultTable | Out-GridView

}
