function Invalidate-CacheByURL
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $URL,
        [Parameter(Mandatory=$false)] [string] $Network = 'production',
        [Parameter(Mandatory=$false)] [string] $Section = 'ccu',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $PostBody = @{ objects = @("$URL") }
    $PostJson = $PostBody | ConvertTo-Json -Depth 100
    $ReqURL = "https://" + $Credentials.host + "/ccu/v3/invalidate/url/$Network"

    if($AccountSwitchKey)
    {
        $ReqURL += "&accountSwitchKey=$AccountSwitchKey"
    }

    Write-host $PostJson
    Write-Host $ReqURL

    try
    {
        $Result = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $PostJson
        return $Result
    }
    catch
    {
       return $_ 
    }
}
