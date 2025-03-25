function Get-ESETAuthToken {
    param (
        [string]$Username,
        [string]$Password
    )

    $uri = "https://eu.business-account.iam.eset.systems/oauth/token"
    $body = @{
        "grant_type" = "password"
        "username" = $Username
        "password" = $Password
    }

    try {
        $response = Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/x-www-form-urlencoded" -Body $body
        return $response.access_token
    } catch {
        Write-Error "Failed to retrieve authentication token: $_"
    }
}

Export-ModuleMember -Function Get-ESETAuthToken