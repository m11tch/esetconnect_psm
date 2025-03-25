#Import module
Import-Module $PSScriptRoot\..\ESETConnectPSModule\ESETConnect.psm1 -Force

#Define credentials
$username = ""
$password = ""

$accessToken = Get-ESETAuthToken -Username $username -Password $password

# Get Existing Device Groups
#Get-ESETDeviceGroups -AccessToken $accessToken

#Create a new group
New-ESETGroup -GroupName "API TEST" -GroupDescription "Created via PowerShell" -ParentGroupUuid "792a3582-60c4-4648-9cb6-ad3c1dd4ca68" -AccessToken $accessToken

#Move a group 
Move-ESETGroup -GroupUuid "df3fb0c4-d9fe-474c-a635-d3546f5b9de2" -AccessToken $accessToken -NewParentGroupUuid "00000000-0000-0000-7001-000000000001"

#Rename a group
Rename-ESETGroup -GroupUuid "df3fb0c4-d9fe-474c-a635-d3546f5b9de2" -AccessToken $accessToken -NewName "TEST - PowerShell Renamed"