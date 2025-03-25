#Import module
Import-Module $PSScriptRoot\..\ESETConnectPSModule\ESETConnect.psm1 -Force

#Define credentials
$username = ""
$password = ""

$accessToken = Get-ESETAuthToken -Username $username -Password $password

# Get Existing Device Groups
#Get-ESETDeviceGroups -AccessToken $accessToken

#Get Installers
Get-ESETInstallers -AccessToken $accessToken -usable "true"

#Get Installer details by Uuid
Get-ESETInstaller -AccessToken $accessToken -installerUuid "7ebcb584-d651-4f24-9501-5d35269451c8"

#Create new Installer
New-ESETInstaller -AccessToken $accessToken -displayName "test API" -enableCloudScannerFeedback 1 -enablePuaDetection 1 -operatingSystemFamilyId 1 -sendAnonymousDiagnosticData 0 -DeviceGroupUuid "f9178888-ecdf-438e-945e-8fdee280bbf2" 

#Remove Installer
Remove-ESETInstaller -AccessToken $accessToken -installerUuid "26fbede4-a0b7-4b0c-84b4-5f661c3a0f82"
