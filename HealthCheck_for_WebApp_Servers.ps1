################################################################################################################################################################################
###   This script can be used to check the health of the WebApp servers and the LoadBalancer.  It will also check supporting structure like DNS and the code of the sites.   ###
###   
###   Created By: Jake Barlocker
###   Created On: 13-DEC-2023
###   
###   Edits:
###   
###   
###   
###   
###   
###   
###   
###   
################################################################################################################################################################################


Function Start_Health_Check{
Clear


# Populate variable for the time at the begininng of the script
$StartTime = (Get-Date)



# Endpoints to check
$Endpoints = @(
               [pscustomobject]@{Server="CCDBWebApp02";Protocol="HTTPS";Site="cww-nv";Binding="cww02.checkcitynevada.com"}
               [pscustomobject]@{Server="CCDBWebApp03";Protocol="HTTPS";Site="cww-nv";Binding="cww03.checkcitynevada.com"}
               [pscustomobject]@{Server="LoadBalancer";Protocol="HTTPS";Site="cww-nv";Binding="lb-cww.checkcitynevada.com"}
               [pscustomobject]@{Server="ProductionURL";Protocol="HTTPS";Site="cww-nv";Binding="cww.checkcitynevada.com"}
               [pscustomobject]@{Server="CCDBWebApp02";Protocol="HTTPS";Site="cww-ut";Binding="cww02.checkcity.com"}
               [pscustomobject]@{Server="CCDBWebApp03";Protocol="HTTPS";Site="cww-ut";Binding="cww03.checkcity.com"}
               [pscustomobject]@{Server="LoadBalancer";Protocol="HTTPS";Site="cww-ut";Binding="lb-cww.checkcity.com"}
               [pscustomobject]@{Server="ProductionURL";Protocol="HTTPS";Site="cww-ut";Binding="cww.checkcity.com"}
               [pscustomobject]@{Server="CCDBWebApp02";Protocol="HTTPS";Site="cww-va";Binding="va-cww02.checkcity.com"}
               [pscustomobject]@{Server="CCDBWebApp03";Protocol="HTTPS";Site="cww-va";Binding="va-cww03.checkcity.com"}
               [pscustomobject]@{Server="LoadBalancer";Protocol="HTTPS";Site="cww-va";Binding="lb-va-cww.checkcity.com"}
               [pscustomobject]@{Server="ProductionURL";Protocol="HTTPS";Site="cww-va";Binding="va-cww.checkcity.com"}
               [pscustomobject]@{Server="CCDBWebApp02";Protocol="HTTPS";Site="DSU";Binding="dsu02.checkcity.com"}
               [pscustomobject]@{Server="CCDBWebApp02";Protocol="HTTPS";Site="DSU";Binding="dsu02.softwise.com"}
               [pscustomobject]@{Server="CCDBWebApp03";Protocol="HTTPS";Site="DSU";Binding="dsu03.checkcity.com"}
               [pscustomobject]@{Server="CCDBWebApp03";Protocol="HTTPS";Site="DSU";Binding="dsu03.softwise.com"}
               [pscustomobject]@{Server="LoadBalancer";Protocol="HTTPS";Site="DSU";Binding="lb-dsu.checkcity.com"}
               [pscustomobject]@{Server="LoadBalancer";Protocol="HTTPS";Site="DSU";Binding="lb-dsu.softwise.com"}
               [pscustomobject]@{Server="ProductionURL";Protocol="HTTPS";Site="DSU";Binding="dsu.checkcity.com"}
               [pscustomobject]@{Server="ProductionURL";Protocol="HTTPS";Site="DSU";Binding="dsu.softwise.com"}
               [pscustomobject]@{Server="CCDBWebApp02";Protocol="HTTPS";Site="dsu-nv";Binding="dsu02.checkcitynevada.com"}
               [pscustomobject]@{Server="CCDBWebApp03";Protocol="HTTPS";Site="dsu-nv";Binding="dsu03.checkcitynevada.com"}
               [pscustomobject]@{Server="LoadBalancer";Protocol="HTTPS";Site="dsu-nv";Binding="lb-dsu.checkcitynevada.com"}
               [pscustomobject]@{Server="ProductionURL";Protocol="HTTPS";Site="dsu-nv";Binding="dsu.checkcitynevada.com"}
               [pscustomobject]@{Server="CCDBWebApp02";Protocol="HTTP";Site="lms-nv";Binding="lms02.checkcitynevada.com"}
               [pscustomobject]@{Server="CCDBWebApp02";Protocol="HTTPS";Site="lms-nv";Binding="lms02.checkcitynevada.com"}
               [pscustomobject]@{Server="CCDBWebApp03";Protocol="HTTP";Site="lms-nv";Binding="lms03.checkcitynevada.com"}
               [pscustomobject]@{Server="CCDBWebApp03";Protocol="HTTPS";Site="lms-nv";Binding="lms03.checkcitynevada.com"}
               [pscustomobject]@{Server="LoadBalancer";Protocol="HTTP";Site="lms-nv";Binding="lb-lms.checkcitynevada.com"}
               [pscustomobject]@{Server="LoadBalancer";Protocol="HTTPS";Site="lms-nv";Binding="lb-lms.checkcitynevada.com"}
               [pscustomobject]@{Server="ProductionURL";Protocol="HTTP";Site="lms-nv";Binding="lms.checkcitynevada.com"}
               [pscustomobject]@{Server="ProductionURL";Protocol="HTTPS";Site="lms-nv";Binding="lms.checkcitynevada.com"}
               [pscustomobject]@{Server="CCDBWebApp02";Protocol="HTTP";Site="lms-ut";Binding="lms02.checkcity.com"}
               [pscustomobject]@{Server="CCDBWebApp02";Protocol="HTTPS";Site="lms-ut";Binding="lms02.checkcity.com"}
               [pscustomobject]@{Server="CCDBWebApp03";Protocol="HTTP";Site="lms-ut";Binding="lms03.checkcity.com"}
               [pscustomobject]@{Server="CCDBWebApp03";Protocol="HTTPS";Site="lms-ut";Binding="lms03.checkcity.com"}
               [pscustomobject]@{Server="LoadBalancer";Protocol="HTTP";Site="lms-ut";Binding="lb-lms.checkcity.com"}
               [pscustomobject]@{Server="LoadBalancer";Protocol="HTTPS";Site="lms-ut";Binding="lb-lms.checkcity.com"}
               [pscustomobject]@{Server="ProductionURL";Protocol="HTTP";Site="lms-ut";Binding="lms.checkcity.com"}
               [pscustomobject]@{Server="ProductionURL";Protocol="HTTPS";Site="lms-ut";Binding="lms.checkcity.com"}
               [pscustomobject]@{Server="CCDBWebApp02";Protocol="HTTP";Site="loc";Binding="loc02.checkcity.com"}
               [pscustomobject]@{Server="CCDBWebApp02";Protocol="HTTPS";Site="loc";Binding="loc02.checkcity.com"}
               [pscustomobject]@{Server="CCDBWebApp03";Protocol="HTTP";Site="loc";Binding="loc03.checkcity.com"}
               [pscustomobject]@{Server="CCDBWebApp03";Protocol="HTTPS";Site="loc";Binding="loc03.checkcity.com"}
               [pscustomobject]@{Server="LoadBalancer";Protocol="HTTP";Site="loc";Binding="lb-loc.checkcity.com"}
               [pscustomobject]@{Server="LoadBalancer";Protocol="HTTPS";Site="loc";Binding="lb-loc.checkcity.com"}
               [pscustomobject]@{Server="ProductionURL";Protocol="HTTP";Site="loc";Binding="loc.checkcity.com"}
               [pscustomobject]@{Server="ProductionURL";Protocol="HTTPS";Site="loc";Binding="loc.checkcity.com"}
               [pscustomobject]@{Server="CCDBWebApp02";Protocol="HTTP";Site="wapi";Binding="wapi02.checkcity.com";Page="/api/v1/version"}
               [pscustomobject]@{Server="CCDBWebApp02";Protocol="HTTPS";Site="wapi";Binding="wapi02.checkcity.com";Page="/api/v1/version"}
               [pscustomobject]@{Server="CCDBWebApp03";Protocol="HTTP";Site="wapi";Binding="wapi03.checkcity.com";Page="/api/v1/version"}
               [pscustomobject]@{Server="CCDBWebApp03";Protocol="HTTPS";Site="wapi";Binding="wapi03.checkcity.com";Page="/api/v1/version"}
               [pscustomobject]@{Server="LoadBalancer";Protocol="HTTP";Site="wapi";Binding="lb-wapi.checkcity.com";Page="/api/v1/version"}
               [pscustomobject]@{Server="LoadBalancer";Protocol="HTTPS";Site="wapi";Binding="lb-wapi.checkcity.com";Page="/api/v1/version"}
               [pscustomobject]@{Server="ProductionURL";Protocol="HTTP";Site="wapi";Binding="wapi.checkcity.com";Page="/api/v1/version"}
               [pscustomobject]@{Server="ProductionURL";Protocol="HTTPS";Site="wapi";Binding="wapi.checkcity.com";Page="/api/v1/version"}
               [pscustomobject]@{Server="HeartBeat-CCDBWebApp02";Protocol="HTTP";Site="wapi";Binding="10.127.192.129";Page="/api/v1/version"}
#               [pscustomobject]@{Server="HeartBeat-CCDBWebApp02";Protocol="HTTPS";Site="wapi";Binding="10.127.192.129";Page="/api/v1/version"}
               [pscustomobject]@{Server="HeartBeat-CCDBWebApp03";Protocol="HTTP";Site="wapi";Binding="10.127.192.130";Page="/api/v1/version"}
#               [pscustomobject]@{Server="HeartBeat-CCDBWebApp03";Protocol="HTTPS";Site="wapi";Binding="10.127.192.130";Page="/api/v1/version"}
               [pscustomobject]@{Server="CCDBWebApp02";Protocol="HTTP";Site="wapi-nv";Binding="wapi02.checkcitynevada.com";Page="/api/v1/version"}
               [pscustomobject]@{Server="CCDBWebApp02";Protocol="HTTPS";Site="wapi-nv";Binding="wapi02.checkcitynevada.com";Page="/api/v1/version"}
               [pscustomobject]@{Server="CCDBWebApp03";Protocol="HTTP";Site="wapi-nv";Binding="wapi03.checkcitynevada.com";Page="/api/v1/version"}
               [pscustomobject]@{Server="CCDBWebApp03";Protocol="HTTPS";Site="wapi-nv";Binding="wapi03.checkcitynevada.com";Page="/api/v1/version"}
               [pscustomobject]@{Server="LoadBalancer";Protocol="HTTP";Site="wapi-nv";Binding="lb-wapi.checkcitynevada.com";Page="/api/v1/version"}
               [pscustomobject]@{Server="LoadBalancer";Protocol="HTTPS";Site="wapi-nv";Binding="lb-wapi.checkcitynevada.com";Page="/api/v1/version"}
               [pscustomobject]@{Server="ProductionURL";Protocol="HTTP";Site="wapi-nv";Binding="wapi.checkcitynevada.com";Page="/api/v1/version"}
               [pscustomobject]@{Server="ProductionURL";Protocol="HTTPS";Site="wapi-nv";Binding="wapi.checkcitynevada.com";Page="/api/v1/version"}
               [pscustomobject]@{Server="CCDBWebApp02";Protocol="HTTP";Site="wapi-ut";Binding="ut-wapi02.checkcity.com";Page="/api/v1/version"}
               [pscustomobject]@{Server="CCDBWebApp02";Protocol="HTTPS";Site="wapi-ut";Binding="ut-wapi02.checkcity.com";Page="/api/v1/version"}
               [pscustomobject]@{Server="CCDBWebApp03";Protocol="HTTP";Site="wapi-ut";Binding="ut-wapi03.checkcity.com";Page="/api/v1/version"}
               [pscustomobject]@{Server="CCDBWebApp03";Protocol="HTTPS";Site="wapi-ut";Binding="ut-wapi03.checkcity.com";Page="/api/v1/version"}
               [pscustomobject]@{Server="LoadBalancer";Protocol="HTTP";Site="wapi-ut";Binding="lb-ut-wapi.checkcity.com";Page="/api/v1/version"}
               [pscustomobject]@{Server="LoadBalancer";Protocol="HTTPS";Site="wapi-ut";Binding="lb-ut-wapi.checkcity.com";Page="/api/v1/version"}
               [pscustomobject]@{Server="ProductionURL";Protocol="HTTP";Site="wapi-ut";Binding="ut-wapi.checkcity.com";Page="/api/v1/version"}
               [pscustomobject]@{Server="ProductionURL";Protocol="HTTPS";Site="wapi-ut";Binding="ut-wapi.checkcity.com";Page="/api/v1/version"}
               )


Remove-Variable Results -ErrorAction SilentlyContinue
$Results = @()


Foreach ($Endpoint in $Endpoints) {
                                   $FullAddress = $Endpoint.Protocol + "://" + $Endpoint.Binding + $Endpoint.Page
                                   $WebRequest = try { Invoke-WebRequest $FullAddress } catch { [pscustomobject]@{StatusCode=$_.Exception.Response.StatusCode.Value__;StatusDescription="Error"} }
                                   $Results += [pscustomobject]@{Server=$Endpoint.Server;Protocol=$Endpoint.Protocol;Site=$Endpoint.Site;Binding=$Endpoint.Binding;StatusCode=$WebRequest.StatusCode;StatusDescription=$WebRequest.StatusDescription}
                                   #$Results += [pscustomobject]@{Server=$Endpoint.Server;Protocol=$Endpoint.Protocol;Site=$Endpoint.Site;Binding=$Endpoint.Binding;StatusCode=$WebRequest.StatusCode;StatusDescription=$WebRequest.StatusDescription;Content=$WebRequest.Content}
                                   Remove-Variable WebRequest, SiteNotFound -ErrorAction SilentlyContinue
                                   
                                   
                                   }


$Results | Sort-Object Server, Site, Protocol | Out-GridView -Title "Health Checks for CCDBWebApp02, CCDBWebApp03, and the Load Balancer"





# Populate variable for the time at the end of the script
$EndTime = (Get-Date)


# Calculate elapsed time
Write-Host "This script took this long to run: " $($EndTime - $StartTime) -ForegroundColor Yellow



}