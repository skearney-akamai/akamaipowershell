function Remove-CPSEnrollment
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $EnrollmentID,
        [Parameter(Mandatory=$false)] [switch] $AllowCancelPendingChanges,
        [Parameter(Mandatory=$false)] [string] $DeployNotAfter,
        [Parameter(Mandatory=$false)] [string] $DeployNotBefore,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $AllowCancelPendingChangesString = $AllowCancelPendingChanges.IsPresent.ToString().ToLower()
    if(!$AllowCancelPendingChanges){ $AllowCancelPendingChangesString = '' }

    $DateMatch = '[\d]{4}-[\d]{2}-[\d]{2}'
    if(($DeployNotAfter -or $DeployNotBefore) -and ($DeployNotAfter -notmatch $DateMatch -or $DeployNotBefore -notmatch $DateMatch)){
        throw "ERROR: DeployNotAfter & DeployNotBefore must be in the format 'YYYY-MM-DD'"
    }

    $AdditionalHeaders = @{
        'accept' = 'application/vnd.akamai.cps.enrollment-status.v1+json'
    }
    $Path = "/cps/v2/enrollments/$EnrollmentID`?allow-cancel-pending-changes=$AllowCancelPendingChangesString&deploy-not-after=$DeployNotAfter&deploy-not-before=$DeployNotBefore"

    try {
        $Result = Invoke-AkamaiRestMethod -Method DELETE -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }  
}
