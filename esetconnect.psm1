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
    try {
        $JWT = Invoke-RestMethod -Method Post -Uri "https://$BaseUri/v1/auth:authenticate" -Headers $Headers -Body $Body
    } catch {
        $_.Exception.Response.Headers
    }

    Write-Debug($JWT)
    Set-Variable -Scope Script -Name AccessToken -Value $JWT.access_token
    Set-Variable -Scope Script -Name BaseUri -Value $BaseUri
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
        "access-token" = "$AccessToken"
    }
    if ($DetectionUuid) {
        Try {
            $Detections = Invoke-RestMethod -Method Get -Uri "http://$BaseUri/v1/detections/$DetectionUuid" -Headers $Headers
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
            $Detections = Invoke-RestMethod -Method Get -Uri "http://$BaseUri/v1/detections" -Headers $Headers -Body $Query
        } catch {
            $_.Exception
        }
    
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
        "access-token" = "$AccessToken"
    }
    
    if ($TaskUuid) { 
        Try {
            $DeviceTasks = Invoke-RestMethod -Method Get -Uri "http://$BaseUri/v1/device_tasks/$TaskUuid" -Headers $Headers
        } catch {
            $_.Exception
        }
    } else {
        Try {
            $DeviceTasks = Invoke-RestMethod -Method Get -Uri "http://$BaseUri/v1/device_tasks" -Headers $Headers
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
        "access-token" = "$AccessToken"
    }

    Try {
        $DeviceGroups = Invoke-RestMethod -Method Get -Uri "http://$BaseUri/v1/device_groups" -Headers $Headers
    } catch {
        $_.Exception
    }
    Return $DeviceGroups.device_groups
}

function SwitchToBool([string]$Value) {
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
        "access-token" = "$AccessToken"
    }
    
    $Data = @{
        "config_data_json" = $SyslogSettings
    } | ConvertTo-Json

    Try {
        $SetSyslogSettingsResponse = Invoke-RestMethod -Method post -Uri "https://$BaseUri/v1/configuration:setSyslogConfiguration" -Headers $Headers -Body $Data
    } catch {
        $_.Exception
    }
    Return $SetSyslogSettingsResponse
}

Function Get-EsetConnectSyslogConfiguration {
    $Headers = @{
        "Content-Type" = "application/json"
        "Accept" = "application/json"
        "access-token" = "$AccessToken"
    }

    Try {
        $GetSyslogSettingsResponse = Invoke-RestMethod -Method post -Uri "https://$BaseUri/v1/configuration:getSyslogConfiguration" -Headers $Headers
    } catch {
        $_.Exception
    }
    Return $GetSyslogSettingsResponse
}