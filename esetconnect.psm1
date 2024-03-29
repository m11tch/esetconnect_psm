Function Invoke-EsetConnectAuthentication {
    [CmdletBinding()]
    param(
        $Username,
        $Password,
        $BaseUri
    )

    $Headers = @{
        "Accept" = "application/json"
    }

    $Body = @{
        "grant_type"    = "client_credentials"
        "client_id"     = "$Username"
        "client_secret" = "$Password"
    }

    try {
        $JWT = Invoke-RestMethod -Method Post -Uri "https://$BaseUri/oauth/token" -Headers $Headers -Body $Body
    } catch {
        $_.Exception.Response.Headers
    }

    Write-Debug($JWT)
    Set-Variable -Scope Script -Name AccessToken -Value $JWT.access_token
}

Function Get-EsetConnectDetections {
    [CmdletBinding(DefaultParameterSetName="AllDetections")]
    param(
        [Parameter(ParameterSetName="AllDetections")][string]$DeviceUuid,
        [Parameter(ParameterSetName="AllDetections")][datetime]$StartTime,
        [Parameter(ParameterSetName="AllDetections")][datetime]$EndTime,
        [Parameter(ParameterSetName="AllDetections")][int]$PageSize,
        [Parameter(ParameterSetName="AllDetections")][string]$PageToken,
        [Parameter(ParameterSetName="SpecificDetection")][string]$DetectionUuid
    )
    $Headers = @{
        "Content-Type" = "application/json"
        "Accept" = "application/json"
        "Authorization" = "bearer $AccessToken"
    }

    if ($DetectionUuid) {
        Try {
            $Detections = Invoke-EsetConnectRequest -Method Get -BaseUri $BaseUri -Endpoint "/v1/detections/$DetectionUuid" -Headers $Headers
        } catch {
            $_.Exception
        }
    
        return $Detections
    } else {
        $Query = @{
            "device_uuid" = "$DeviceUuid"
            "page_size" = $PageSize
            "page_token" = "$PageToken"
        }
        if ($StartTime) {
            $Query["start_time"] = $StartTime
        }
        if ($EndTime) {
            $Query["end_time"] = $EndTime
        }
    
        Try {
            $Detections = Invoke-EsetConnectRequest -Method Get -BaseUri "incident-management.eset.systems" -Endpoint "v1/detections" -Body $Query -Headers $Headers
        } catch {
            $_.Exception
        }
        Write-Debug $Detections
        return $Detections.detections
    }

}

Function Get-EsetConnectDeviceTasks {
    param(
        [String]$TaskUuid
    )

    $Headers = @{
        "Content-Type" = "application/json"
        "Accept" = "application/json"
        "Authorization" = "bearer $AccessToken"
    }
    
    if ($TaskUuid) { 
        Try {
            $DeviceTasks = Invoke-RestMethod -Method Get -Uri "https://automation.eset.systems/v1/device_tasks/$TaskUuid" -Headers $Headers
        } catch {
            $_.Exception
        }
    } else {
        Try {
            $DeviceTasks = Invoke-RestMethod -Method Get -Uri "https://automation.eset.systems/v1/device_tasks" -Headers $Headers
        } catch {
            $_.Exception
        }
    }


    Return $DeviceTasks
}

Function Get-EsetConnectDeviceGroups {
    param(
        [int]$PageSize,
        [string]$PageToken
    )

    $Headers = @{
        "Content-Type" = "application/json"
        "Accept" = "application/json"
        "Authorization" = "bearer $AccessToken"
    }

    Try {
        $DeviceGroups = Invoke-RestMethod -Method Get -Uri "https://device-management.eset.systems/v1/device_groups" -Headers $Headers
    } catch {
        $_.Exception
    }
    Return $DeviceGroups.deviceGroups
}

Function SwitchToBool([string]$Value) {
#there is probably a better way to do this..
    switch ($value.ToLower()) {
        "true" { return 1}
        "false" { return 0}
    }
}

Function Set-EsetConnectSyslogConfiguration {
    param(
        [Parameter(Mandatory=$True)][ValidateSet("json", "leef", "cef")]$LogType,
        [Parameter(Mandatory=$True)][ValidateSet("information", "warning", "error", "critical")]$MinLogLevel,
        [Parameter(Mandatory=$True)][ValidateSet("syslog", "bsd")]$Format,
        [Switch]$Enabled,
        [Switch]$EventThreat,
        [Switch]$EventBlockedFiles,
        [Switch]$EventHIPS,
        [Switch]$EventEIAlerts,
        [Switch]$EventFWAgregated,
        [Switch]$EventWebsites,
        [Switch]$EventAudit,
        [Parameter(Mandatory=$True)][String]$Hostname,
        [Switch]$ValidateCARoot,
        [String]$SyslogCARoot

    )

    $SyslogSettings = @{
        "syslogEnabled" = SwitchToBool($Enabled)
        "syslogFormat" = $Format
        "syslogLogtype" = $LogType
        "syslogMinLogLevel" = $MinLogLevel
        "syslogTransport" = "tls"
        "syslogOctetFraming" = 1
        "syslogEventThreat" = SwitchToBool($EventThreat)
        "syslogEventBlockedFiles" = SwitchToBool($EventBlockedFiles)
        "syslogEventHIPS" = SwitchToBool($EventHIPS)
        "syslogEventEIAlerts" = SwitchToBool($EventEIAlerts)
        "syslogEventFwAgregated" = SwitchToBool($EventFWAgregated)
        "syslogEventWebsites" = SwitchToBool($EventWebsites)
        "syslogEventAudit" = SwitchToBool($EventAudit)
        "syslogHostIP" = $Hostname
        "syslogPort" = 6514
        "syslogValidateCARoot" = SwitchToBool($ValidateCARoot)
        "syslogCARoot" = $SyslogCARoot
    } | ConvertTo-Json

    $Headers = @{
        "Content-Type" = "application/json"
        "Accept" = "application/json"
        "Authorization" = "bearer $AccessToken"
    }
    
    $Data = @{
        "config_data_json" = $SyslogSettings
    } | ConvertTo-Json

    Try {
        $SetSyslogSettingsResponse = Invoke-RestMethod -Method post -Uri "https://esetconnect.eset.systems/v1/configuration:setSyslogConfiguration" -Headers $Headers -Body $Data
    } catch {
        $_.Exception
    }
    Return $SetSyslogSettingsResponse
}

Function Get-EsetConnectSyslogConfiguration {
    $Headers = @{
        "Content-Type" = "application/json"
        "Accept" = "application/json"
        "Authorization" = "bearer $AccessToken"
    }

    Try {
        $GetSyslogSettingsResponse = Invoke-RestMethod -Method post -Uri "https://esetconnect.eset.systems/v1/configuration:getSyslogConfiguration" -Headers $Headers
    } catch {
        $_.Exception
    }
    Return $GetSyslogSettingsResponse
}

Function Invoke-EsetConnectRequest {
    Param(
        [ValidateSet("get", "post", "delete", "put")]$Method,
        [string]$Endpoint,
        [string]$Body,
        [string]$BaseUri
    )

    $Headers = @{
        "Content-Type" = "application/json"
        "Accept" = "application/json"
        "Authorization" = "Bearer $AccessToken"
    }

    try {
        Invoke-RestMethod -Method $Method -Uri "https://$BaseUri/$Endpoint" -Headers $Headers -Body $Body 
    } catch {
        $_.Exception
    }
   
}