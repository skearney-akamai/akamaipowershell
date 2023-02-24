function Set-GTMLoadData
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Domain,
        [Parameter(Mandatory=$true)]  [string] $Resource,
        [Parameter(Mandatory=$true)]  [string] $DatacenterID,
        [Parameter(Mandatory=$true)]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/gtm-load-data/v1/$Domain/$Resource/$DatacenterID"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
