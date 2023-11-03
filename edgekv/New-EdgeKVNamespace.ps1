function New-EdgeKVNamespace {
    Param(
        [Parameter(Mandatory = $true)]  [string] $Name,
        [Parameter(Mandatory = $false)] [string] $RetentionInSeconds = 0,
        [Parameter(Mandatory = $false)] [string] [ValidateSet('US', 'EU', 'JP')] $GeoLocation = 'US',
        [Parameter(Mandatory = $true)]  [string] [ValidateSet('STAGING', 'PRODUCTION')] $Network,
        [Parameter(Mandatory = $false)] [int]    $GroupID,
        [Parameter(Mandatory = $false)] [string] $EdgeRCFile,
        [Parameter(Mandatory = $false)] [string] $Section,
        [Parameter(Mandatory = $false)] [string] $AccountSwitchKey
    )

    if ($Network -eq 'STAGING' -and $GeoLocation -ne 'US') {
        throw 'Only valid GeoLocation for STAGING network is US currently'
    }

    $Path = "/edgekv/v1/networks/$Network/namespaces"

    $BodyObj = @{
        name               = $Name
        geoLocation        = $GeoLocation
        retentionInSeconds = $RetentionInSeconds
        groupId            = $GroupID
    }
    $Body = $BodyObj | ConvertTo-Json

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
