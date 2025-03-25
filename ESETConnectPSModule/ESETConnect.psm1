# Import submodules
Import-Module -Name "$PSScriptRoot\ESETConnectAuthentication.psm1"
Import-Module -Name "$PSScriptRoot\ESETConnectDeviceManagement.psm1"

# Export functions from submodules
Export-ModuleMember -Function Get-ESETAuthToken, Get-ESETDevice, Move-ESETDevice, Rename-ESETDevice, Get-ESETDevicesBatch, Get-ESETDeviceGroups, Get-ESETDevicesInGroup