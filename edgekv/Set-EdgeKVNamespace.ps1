function Set-EdgeKVNamespace
{
    Param(
        [Parameter(Mandatory=$true)]  [string] [ValidateSet('STAGING','PRODUCTION')] $Network,
        [Parameter(Mandatory=$true)]  [string] $NamespaceID,
        [Parameter(Mandatory=$true,ParameterSetName='pipeline', ValueFromPipeline=$true)]  [object] $Namespace,
        [Parameter(Mandatory=$true,ParameterSetName='attributes')]  [string] $Name,
        [Parameter(Mandatory=$true,ParameterSetName='attributes')]  [int]    $RetentionInSeconds,
        [Parameter(Mandatory=$true,ParameterSetName='attributes')]  [int]    $GroupID,
        [Parameter(Mandatory=$true,ParameterSetName='body')]        [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        $Path = "/edgekv/v1/networks/$Network/namespaces/$NamespaceID"

        if($PSCmdlet.ParameterSetName -eq 'attributes'){
            $BodyObj = @{
                name = $Name
                retentionInSeconds = $RetentionInSeconds
                groupId = $GroupID
            }
            $Body = $BodyObj | ConvertTo-Json
        }
        elseif($PSCmdlet.ParameterSetName -eq 'pipeline'){
            $Body = $Namespace | ConvertTo-Json
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            return $Result
        }
        catch {
            throw $_
        }
    }

    end{}
}
