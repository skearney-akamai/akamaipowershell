function Generate-Report {
    Param(
        [Parameter(Mandatory = $true)] [Alias('ReportType')] [String] $Name,
        [Parameter(Mandatory = $true)] [String] $Version,
        [Parameter(Mandatory = $true)] [String] $Start,
        [Parameter(Mandatory = $true)] [String] $End,
        [Parameter(Mandatory = $true, ParameterSetName = 'attributes')] [string] $ObjectIDs,
        [Parameter(Mandatory = $true)] [ValidateSet('FIVE_MINUTES', 'HOUR', 'DAY', 'WEEK', 'MONTH')] [String] $Interval,
        [Parameter(Mandatory = $false, ParameterSetName = 'attributes')] [string] $Filters,
        [Parameter(Mandatory = $false, ParameterSetName = 'attributes')] [string] $Metrics,
        [Parameter(Mandatory = $false, ParameterSetName = 'postbody')] [String] $Body,
        [Parameter(Mandatory = $false)] [string] $Limit,
        [Parameter(Mandatory = $false)] [string] $EdgeRCFile,
        [Parameter(Mandatory = $false)] [string] $Section,
        [Parameter(Mandatory = $false)] [string] $AccountSwitchKey
    )

    $ISO8601Match = '^[\d]{4}-[\d]{2}-[\d]{2}(T[\d]{2}:[\d]{2}(:[\d]{2})?(Z|[+-]{1}[\d]{2}[:][\d]{2})?)?$'
    if ($Start -notmatch $ISO8601Match -or $End -notmatch $ISO8601Match) {
        throw "ERROR: Start & End must be in the format 'YYYY-MM-DDThh:mm(:ss optional) and (optionally) end with: 'Z' for UTC or '+/-XX:XX' to specify another timezone"
    }

    # Encode specific params
    if ($Start) { $Start = [System.Uri]::EscapeDataString($Start) }
    if ($End) { $End = [System.Uri]::EscapeDataString($End) }

    $Path = "/reporting-api/v1/reports/$Name/versions/$Version/report-data?start=$Start&end=$End&interval=$Interval&limit=$Limit"

    if ($PSCmdlet.ParameterSetName -eq 'attributes') {
        $BodyObj = @{ 
            objectType = 'cpcode'
            objectIds  = ($ObjectIDs -split ',')
        }

        # Metrics
        if ($Metrics) {
            $BodyObj['metrics'] = @()
            $Metrics -split ',' | ForEach-Object {
                $BodyObj['metrics'] += [System.Uri]::EscapeDataString($_)
            }
        }

        # Filters
        if ($Filters) {
            $BodyObj['filters'] = @()
            $Filters -split ',' | ForEach-Object {
                $BodyObj['filters'] += [System.Uri]::EscapeDataString($_)
            }
        }

        $Body = $BodyObj | ConvertTo-Json -Depth 100
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey -Body $Body
        return $Result
    }
    catch {
        throw $_
    }
}
