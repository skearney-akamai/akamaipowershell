function Get-ChinaCDNProvisionStateChange
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Hostname,
        [Parameter(Mandatory=$true)]  [int]    $ChangeID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/chinacdn/v1/property-hostnames/$Hostname/provision-state-changes/$ChangeID"

    $AdditionalHeaders = @{
        Accept = 'application/vnd.akamai.chinacdn.provision-state-changes.v1+json'
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_ 
    }
}
