Function Set-PropertyIncludeRuleTree
{
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)] [string] $IncludeName,
        [Parameter(ParameterSetName="id", Mandatory=$true)] [string] $IncludeID,
        [Parameter(Mandatory=$true)]  [string] $IncludeVersion,
        [Parameter(Mandatory=$false, ValueFromPipeline)] [System.Object] $RuleTree,
        [Parameter(Mandatory=$false)] [string] $InputFile,
        [Parameter(Mandatory=$false)] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $VersionNotes,
        [Parameter(Mandatory=$false)] [string] $SetRuleFormat,
        [Parameter(Mandatory=$false)] [switch] $DryRun,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('fast','full')]  $ValidateMode,
        [Parameter(Mandatory=$false)] [switch] $ValidateRules,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Must use Process block as using ValueFromPipeline
    process {
        # Check vars
        if(!$Body -and !$InputFile -and !$RuleTree){
            throw "You must specify one of the following: Rules object, POST body or input filename"
        }
        # nullify false switches
        $DryRunString = $DryRun.IsPresent.ToString().ToLower()
        if(!$DryRun){ $DryRunString = '' }
        $ValidateRulesString = $ValidateRules.IsPresent.ToString().ToLower()
        if(!$ValidateRules){ $ValidateRulesString = '' }

        if($SetRuleFormat){
            $AdditionalHeaders = @{
                'Content-Type' = "application/vnd.akamai.papirules.$SetRuleFormat+json"
            }
        }

        if($InputFile){
            if(!(Test-Path $InputFile)){
                throw "Input file $Inputfile does not exist"
            }
            $Body = Get-Content $InputFile -Raw
        }
        elseif($RuleTree){
            $Body = $RuleTree | ConvertTo-Json -Depth 100
        }

        # Check body length
        if($Body.length -eq 0 -or $Body -eq 'null'){
            # if ConvertTo-Json gets a $null object, it converts it to a string that is literally 'null'
            throw 'Request body or input object is invalid. Please check'
        }

        # Add notes if required
        if($VersionNotes){
            if ($PSVersionTable.PSVersion.Major -le 5) { 
                $BodyObj = $Body | ConvertFrom-Json
            }
            else{
                $BodyObj = $Body | ConvertFrom-Json -Depth 100
            }
            if($BodyObj.comments){
                $BodyObj.comments = $VersionNotes
            }
            else{
                $BodyObj | Add-Member -MemberType NoteProperty -Name 'comments' -Value $VersionNotes
            }

            $Body = $BodyObj | ConvertTo-Json -Depth 100
        }

        if($IncludeName){
            $Include = Find-Property -IncludeName $IncludeName -latest -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            if($null -eq $Include){
                throw "Include '$IncludeName' not found"
            }
            $IncludeID = $Include.includeId
        }

        #Sanitize body to remove NO-BREAK SPACE Unicode character, which breaks PAPI
        $Body = $Body -replace "[\u00a0]", ""

        if($IncludeVersion.ToLower() -eq "latest"){
            if($IncludeName -eq ''){
                $Include = Find-Property -IncludeName $IncludeName -latest -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            }
            $IncludeVersion = $Include.includeVersion
        }

        $Path = "/papi/v1/includes/$IncludeID/versions/$IncludeVersion/rules?validateRules=$ValidateRulesString&validateMode=$ValidateMode&dryRun=$DryRunString&contractId=$ContractId&groupId=$GroupID&accountSwitchKey=$AccountSwitchKey"

        try
        {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result
        }
        catch
        {
            throw $_
        }
    }
    
}