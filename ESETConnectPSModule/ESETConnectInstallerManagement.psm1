function Get-ESETInstallers {
    param (
        [string]$AccessToken,
        [Parameter()][ValidateSet('true', 'false')][string]$usable
    )

    $uri = "https://eu.installer-management.eset.systems/v1/installers"
    $headers = @{
        "Authorization" = "Bearer $AccessToken"
    }

    if ($usable) {
        $uri += "?usable=$usable"
    }

    
    try {
        $allInstallers = @()
        do {
            $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
            $allInstallers += $response.installers
            $uri = "https://eu.installer-management.eset.systems/v1/installers?pageToken=$($response.nextPageToken)"
        } while ($response.nextPageToken)
        return $allInstallers
    } catch {
        Write-Error "Failed to retrieve installers: $_"
    }
}

function Get-ESETInstaller {
    param (
        [string]$AccessToken,
        [string]$installerUuid
    )

    $uri = "https://eu.installer-management.eset.systems/v1/installers/$installerUuid"
    $headers = @{
        "Authorization" = "Bearer $AccessToken"
    }

    try {
        $response = Invoke-Restmethod -Method Get -Uri $uri -Headers $Headers
        return $response.installer
    } catch {
        Write-Error "Failed to retrieve installer: $_"
    }
}

function Remove-ESETInstaller {
    param (
        [string]$AccessToken,
        [string]$installerUuid
    )

    $uri = "https://eu.installer-management.eset.systems/v1/installers/$installerUuid"
    $headers = @{
        "Authorization" = "Bearer $AccessToken"
    }

    try {
        $response = Invoke-Restmethod -Method Delete -Uri $uri -Headers $Headers
        return $response
    } catch {
        Write-Error "Failed to remove installer: $_"
    }
}

function New-ESETInstaller {
    param (
        [string]$AccessToken,
        [string]$DeviceGroupUuid,
        [string]$displayName,
        [Parameter()][ValidateSet(0,1,2,3)][int]$operatingSystemFamilyId,
        [bool]$enablePuaDetection,
        [bool]$enableCloudScannerFeedback,
        [bool]$sendAnonymousDiagnosticData,
        [string]$preferredLanguageCode = "en-us"
    )

    $uri = "https://eu.installer-management.eset.systems/v1/installers/$installerUuid"
    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type" = "application/json"
    }

    $body = @{
        installer = @{
            deviceEnrollment = @{
                "securityGroupUuid" = $DeviceGroupUuid
            }
            displayName = $displayName
            enableCloudScannerFeedback = $enableCloudScannerFeedback
            enablePuaDetection = $enablePuaDetection
            sendAnonymousDiagnosticData = $sendAnonymousDiagnosticData
            preferredLanguageCode = $preferredLanguageCode
            operatingSystemFamilyId = $operatingSystemFamilyId
        }
    }
    try {
        $response = Invoke-Restmethod -Method Post -Uri $uri -Headers $Headers -Body ($body | ConvertTo-Json)
        return $response.installer
    } catch {
        Write-Error "Failed to create installer: $_"
    }
}
Export-ModuleMember -Function Get-ESETInstallers, Get-ESETInstaller, Remove-ESETInstaller, New-ESETInstaller