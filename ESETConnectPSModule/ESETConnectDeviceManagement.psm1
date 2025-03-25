function Get-ESETDevice {
    param (
        [string]$DeviceId,
        [string]$AccessToken
    )

    $uri = "https://eu.device-management.eset.systems/v1/devices/$DeviceId"
    $headers = @{
        "Authorization" = "Bearer $AccessToken"
    }

    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
        return $response
    } catch {
        Write-Error "Failed to retrieve device information: $_"
    }
}

function Move-ESETDevice {
    param (
        [string]$DeviceId,
        [string]$AccessToken,
        [string]$TargetGroupId
    )

    $uri = "https://eu.device-management.eset.systems/v1/devices/" +$DeviceId + ":move"
    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type" = "application/json"
    }
    $body = @{
        "newParentUuid" = $TargetGroupId
    }

    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body ($body | ConvertTo-Json)
        return $response
    } catch {
        Write-Error "Failed to move device: $_"
    }
}

function Rename-ESETDevice {
    param (
        [string]$DeviceId,
        [string]$AccessToken,
        [string]$NewName
    )

    $uri = "https://eu.device-management.eset.systems/v1/devices/"+ $DeviceId + ":rename"
    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type" = "application/json"
    }
    $body = @{
        "displayName" = $NewName
    }

    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body ($body | ConvertTo-Json) 
        return $response
    } catch {
        Write-Error ("Failed to rename device: " + $_.ErrorDetails)
    }
}

function Get-ESETDevicesBatch {
    param (
        [string]$AccessToken,
        [array]$DeviceIds
    )

    $queryParams = ($DeviceIds | ForEach-Object { "devicesUuids=$_" }) -join "&"
    $uri = "https://eu.device-management.eset.systems/v1/devices:batchGet?$queryParams"
    
    $headers = @{
        "Authorization" = "Bearer $AccessToken"
    }

    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
        return $response.devices
    } catch {
        Write-Error "Failed to retrieve devices batch: $_"
    }
}

function Get-ESETDeviceGroups {
    param (
        [string]$AccessToken
    )

    $uri = "https://eu.device-management.eset.systems/v1/device_groups"
    $headers = @{
        "Authorization" = "Bearer $AccessToken"
    }

    try {
        $allGroups = @()
        do {
            $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
            $allGroups += $response.deviceGroups
            $uri = "https://eu.device-management.eset.systems/v1/device_groups?pageToken=$($response.nextPageToken)"
        } while ($response.nextPageToken)
        return $allGroups
    } catch {
        Write-Error "Failed to retrieve device groups: $_"
    }
}

function Get-ESETDevicesInGroup {
    param (
        [string]$GroupId,
        [string]$AccessToken,
        [switch]$recurseSubgroups
    )

    $uri = "https://eu.device-management.eset.systems/v1/device_groups/$GroupId/devices"
    if ($RecurseSubgroups) {
        $uri += "?recurseSubgroups=true"
    }
    $headers = @{
        "Authorization" = "Bearer $AccessToken"
    }

    try {
        $allDevices = @()
        do {
            $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
            $allDevices += $response.devices
            $uri = "https://eu.esetconnect.eset.systems/api/v1/device_groups/$GroupId/devices?pageToken=$($response.nextPageToken)"
        } while ($response.nextPageToken)
        return $allDevices
    } catch {
        Write-Error "Failed to retrieve devices in group: $_"
    }
}

Export-ModuleMember -Function Get-ESETDevice, Move-ESETDevice, Rename-ESETDevice, Get-ESETDevicesBatch, Get-ESETDeviceGroups, Get-ESETDevicesInGroup