[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-Expression('$module="ListMenu";$repo="PowershellMenu"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jbarlocker/PowershellMenu/main/CC_MainMenu.ps1'));Master-Menu 






#Echo ToolBox
#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Invoke-Expression('$module="ToolBox";$repo="PowershellScripts"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/DellProSupportGse/Tools/main/ToolBox.ps1'))
#Invoke-ToolBox 