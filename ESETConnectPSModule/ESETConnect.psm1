# Import submodules
Import-Module -Name "$PSScriptRoot\ESETConnectAuthentication.psm1" -Force
Import-Module -Name "$PSScriptRoot\ESETConnectDeviceManagement.psm1" -Force
Import-Module -Name "$PSScriptRoot\ESETConnectAssetManagement.psm1" -Force

# Export functions from submodules
Export-ModuleMember -Function Get-ESETAuthToken, Get-ESETDevice, Move-ESETDevice, Rename-ESETDevice, Get-ESETDevicesBatch, Get-ESETDeviceGroups, Get-ESETDevicesInGroup, New-ESETGroup, Remove-ESETGroup, Move-ESETGroup, Rename-ESETGroup