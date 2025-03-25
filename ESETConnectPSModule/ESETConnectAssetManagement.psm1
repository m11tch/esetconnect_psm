function New-ESETGroup {
    param (
        [string]$AccessToken,
        [string]$GroupName,
        [string]$GroupDescription,
        [string]$ParentGroupUuid
    )

    $uri = "https://eu.asset-management.eset.systems/v1/groups"
    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type" = "application/json"
    }
    $body = @{
        group = @{
            "displayName" = $GroupName
            "parentGroupUuid" = $ParentGroupUuid
            "description" = $GroupDescription
        }
    }
    
    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body ($body | ConvertTo-Json)
        
        return $response
    } catch {
        Write-Error "Failed to create Group: $_"
    }
}

function Remove-ESETGroup {
    param (
        [string]$GroupUuid,
        [string]$AccessToken,
        [switch]$ReleaseConsumedUnits
    )

    $uri =  $uri = "https://eu.asset-management.eset.systems/v1/groups/$GroupUuid"
    if ($RecurseSubgroups) {
        $uri += "?releaseConsumedUnits=true"
    }
    $headers = @{
        "Authorization" = "Bearer $AccessToken"
    }

    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Delete
        return $response
    } catch {
        Write-Error "Failed to delete group: $_"
    }
}

function Move-ESETGroup {
    param (
        [string]$AccessToken,
        [string]$GroupUuid,
        [string]$NewParentGroupUuid
    )

    $uri = "https://eu.asset-management.eset.systems/v1/groups/" + $GroupUuid + ":move"
    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type" = "application/json"
    }
    $body = @{
        "newParentUuid" = $NewParentGroupUuid
    }

    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body ($body | ConvertTo-Json)
        return $response
    } catch {
        Write-Error "Failed to move Group: $_"
    }
}

function Rename-ESETGroup {
    param (
        [string]$AccessToken,
        [string]$GroupUuid,
        [string]$NewName
    )

    $uri = "https://eu.asset-management.eset.systems/v1/groups/" + $GroupUuid + ":rename"
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
        Write-Error "Failed to create Group: $_"
    }
}

Export-ModuleMember -Function New-ESETGroup, Remove-ESETGroup, Move-ESETGroup, Rename-ESETGroup