#Import module
Import-Module $PSScriptRoot\..\ESETConnectPSModule\ESETConnect.psm1

#Define credentials
$username = ""
$password = ""

$accessToken = Get-ESETAuthToken -Username $username -Password $password

$groupId = "00000000-0000-0000-7001-000000000001" #All Group always has this uuid, see Get-ESETDeviceGroups for all available groups

# Get devices in group & include devices from subgroups
$devicesInGroup = Get-ESETDevicesInGroup -GroupId $groupId -AccessToken $accessToken -RecurseSubGroups
# uncomment if you want to print all found devices
#$devicesInGroup

#Get All Device Detaills
$deviceDetails = Get-ESETDevicesBatch -AccessToken $accessToken -DeviceIds ($devicesInGroup.uuid)

#Show only specific values
$deviceDetails | Select-Object -Property uuid, displayName, lastSyncTime, functionalityProblemCount, functionalityStatus, deployedComponents, operatingSystem | format-Table -AutoSize
