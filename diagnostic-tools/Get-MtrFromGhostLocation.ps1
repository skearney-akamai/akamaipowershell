function Get-MtrFromGhostLocation
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $LocationID,
        [Parameter(Mandatory=$true)]  [string] $DestinationDomain,
        [Parameter(Mandatory=$false)] [switch] $ResolveDNS,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $ResolveDNSString = $ResolveDNS.IsPresent.ToString().ToLower()
    if(!$ResolveDNS){ $ResolveDNSString = '' }

    $Path = "/diagnostic-tools/v2/ghost-locations/$LocationId/mtr-data?destinationDomain=$DestinationDomain&resolveDns=$ResolveDNSString"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
