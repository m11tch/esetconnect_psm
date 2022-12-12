Function Invoke-EsetConnectAuthentication {
    param(
        $Username,
        $Password,
        $BaseUri
    )
    $Headers = @{
        "Content-Type" = "application/json"
        "Accept" = "application/json"
    }

    $Body = @"
{
    "username": "$Username",
    "password": "$Password"
}
"@
    $Uri = "$BaseUri" + "/auth:getToken"
    try {
        $JWT = Invoke-RestMethod -Method Post -Uri 'http://epcpublicapi-test.westeurope.cloudapp.azure.com/v1/auth:getToken' -Headers $Headers -Body $Body
    } catch {
        $_.Exception.Response.Headers
    }

    Write-Debug($JWT)
    Set-Variable -Scope Script -Name AccessToken -Value $JWT.access_token
}

Function Get-EsetConnectDetections {
    param(
        [string]$DeviceUuid,
        [datetime]$StartTime,
        [datetime]$EndTime,
        [int]$PageSize,
        [string]$PageToken
    )
    $Headers = @{
        "Content-Type" = "application/json"
        "Accept" = "application/json"
        "access-token" = "$AccessToken"
    }

    $Query = @{
        "device_uuid" = "$DeviceUuid"
        "page_size" = $PageSize
        "page_token" = "$PageToken"
    }
    if ($null -ne $StartTime) {
        $Query["start_time"] = $StartTime
    }
    if ($null -ne $EndTime) {
        $Query["end_time"] = $EndTime
    }

    Try {
        $Detections = Invoke-RestMethod -Method Get -Uri 'http://epcpublicapi-test.westeurope.cloudapp.azure.com/v1/detections' -Headers $Headers -Body $Query
    } catch {
        $_.Exception
    }

    return $Detections.detections
}

Function Get-EsetConnectDeviceTasks {
    $Headers = @{
        "Content-Type" = "application/json"
        "Accept" = "application/json"
        "access-token" = "$AccessToken"
    }
    
    Try {
        $DeviceTasks = Invoke-RestMethod -Method Get -Uri 'http://epcpublicapi-test.westeurope.cloudapp.azure.com/v1/device_tasks' -Headers $Headers
    } catch {
        $_.Exception
    }

    Return $DeviceTasks
}

Function Get-EsetConnectDeviceGroups {
    param(
        [string]$DeviceUuid,
        [int]$PageSize,
        [string]$PageToken
    )

    $Headers = @{
        "Content-Type" = "application/json"
        "Accept" = "application/json"
        "access-token" = "$AccessToken"
    }

    Try {
        $DeviceGroups = Invoke-RestMethod -Method Get -Uri 'http://epcpublicapi-test.westeurope.cloudapp.azure.com/v1/device_groups' -Headers $Headers
    } catch {
        $_.Exception
    }
    Return $DeviceGroups.device_groups
}
