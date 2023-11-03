function Clone-AppSecSecurityPolicy
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ConfigID,
        [Parameter(Mandatory=$true)]  [int]    $VersionNumber,
        [Parameter(Mandatory=$true, ParameterSetName='attributes')] [string] $CreateFromSecurityPolicy,
        [Parameter(Mandatory=$true, ParameterSetName='attributes')] [string] $PolicyName,
        [Parameter(Mandatory=$true, ParameterSetName='attributes')] [string] $PolicyPrefix,
        [Parameter(Mandatory=$true, ParameterSetName='postbody')]   [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/appsec/v1/configs/$ConfigID/versions/$VersionNumber/security-policies"

    if($PSCmdlet.ParameterSetName -eq "attributes"){
        $BodyObj = @{ 
            'createFromSecurityPolicy' = $CreateFromSecurityPolicy
            'policyName' = $PolicyName
            'policyPrefix' = $PolicyPrefix
        }
        $Body = $BodyObj | ConvertTo-Json -Depth 10
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey -Body $Body
        return $Result
    }
    catch {
        throw $_ 
    }
}
