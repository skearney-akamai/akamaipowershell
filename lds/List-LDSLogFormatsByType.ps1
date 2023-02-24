function List-LDSLogFormatsByType
{
    Param(
        [Parameter(Mandatory=$false)] [string] $LogSourceType = "cpcode-products",
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    Write-Host -ForegroundColor Yellow "Warning: This cmdlet is deprecated and will be removed in a future release. Please use List-LDSLogFormats instead"
    
    $Path = "/lds-api/v3/log-sources/$LogSourceType/log-formats"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
