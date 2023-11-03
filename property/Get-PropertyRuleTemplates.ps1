<#
.SYNOPSIS
Akamai Powershell - Recursively converting rules to snippets
.DESCRIPTION
Takes a property rule tree and converts to a json, replacing with #include: statement.
.PARAMETER Rules
Rule PS object to recurse
.PARAMETER Path
Current folder path to write content to
.PARAMETER CurrentDepth
Current level of recursion. If equal or greater than MaxDept children will remain in the parent json file
.PARAMETER MaxDepth
Maximum depth as specified by the user. Allows you to limit the level of recursion and just leave children in json
.EXAMPLE
Get-ChildRuleTemplate -Rules $Rules -Path /property/offload -CurrentDepth 1 -MaxDepth 2
.LINK
developer.akamai.com
#>

function Get-ChildRuleTemplate {
    Param(
        [Parameter(Mandatory = $true)] [object] $Rules,
        [Parameter(Mandatory = $true)] [string] $Path,
        [Parameter(Mandatory = $true)] [int]    $CurrentDepth,
        [Parameter(Mandatory = $true)] [int]    $MaxDepth
    )

    $OSSlashChar = Get-OSSlashCharacter
    
    $SafeName = Sanitize-FileName -FileName $Rules.Name
    $ChildPath = "$Path$OSSlashChar$SafeName"
    $NewDepth = $CurrentDepth + 1

    if ($NewDepth -lt $MaxDepth) {
        if ($Rules.children.count -gt 0) {
            if (!(Test-Path $ChildPath)) {
                New-Item -Name $ChildPath -ItemType Directory | Out-Null
            }
        }
        for ($i = 0; $i -lt $Rules.children.count; $i++) {
            Get-ChildRuleTemplate -Rules $Rules.children[$i] -Path $ChildPath -CurrentDepth $NewDepth -MaxDepth $MaxDepth
            $SafeChildName = Sanitize-FileName -FileName $Rules.children[$i].Name
            $Rules.children[$i] = "#include:$SafeName$OSSlashChar$SafeChildName.json"
        }
    }

    $Rules | ConvertTo-Json -Depth 100 | Out-File "$Path$OSSlashChar$SafeName.json"
}

<#
.SYNOPSIS
Akamai Powershell - Splitting out properties to snippets
.DESCRIPTION
Pulls a property rule tree from PAPI and breaks it down into json snippets, to a specified depth
.PARAMETER PropertyName
Property name to read from PAPI. Either this or PropertyID is required
.PARAMETER PropertyID
Property ID to read from PAPI. Either this or PropertyName is required
.PARAMETER PropertyVersion
Version of property to read from PAPI. Can be integer or 'latest'
.PARAMETER OutputDir
Folder to write snippets to. Defaults to the property name. OPTIONAL
.PARAMETER MaxDepth
Depth of recursion. Defaults to 100, which is effectively unlimited. OPTIONAL
.PARAMETER GroupID
PAPI group for the property. OPTIONAL
.PARAMETER ContractId
PAPI contract from the property. OPTIONAL
.PARAMETER EdgeRCFile
Path to .edgerc file, defaults to ~/.edgerc. OPTIONAL
.PARAMETER ContractId
.edgerc Section name. Defaults to 'default'. OPTIONAL
.PARAMETER AccountSwitchKey
Account switch key if applying to an account external to yoru API user. Only usable by Akamai staff and partners. OPTIONAL
.EXAMPLE
Get-PropertyRuleTemplates -PropertyName MyProperty -PropertyVersion latest -OutputDir MyProperty
.LINK
developer.akamai.com
#>

function Get-PropertyRuleTemplates {
    Param(
        [Parameter(ParameterSetName = "name", Mandatory = $true)]  [string] $PropertyName,
        [Parameter(ParameterSetName = "id", Mandatory = $true)]  [string] $PropertyID,
        [Parameter(Mandatory = $true)]  [string] $PropertyVersion,
        [Parameter(Mandatory = $false)] [string] $OutputDir,
        [Parameter(Mandatory = $false)] [int]    $MaxDepth = 100,
        [Parameter(Mandatory = $false)] [string] $GroupID,
        [Parameter(Mandatory = $false)] [string] $ContractId,
        [Parameter(Mandatory = $false)] [string] $EdgeRCFile,
        [Parameter(Mandatory = $false)] [string] $Section,
        [Parameter(Mandatory = $false)] [string] $AccountSwitchKey
    )

    if ($PropertyName) {
        try {
            $Property = Find-Property -PropertyName $PropertyName -latest -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            $PropertyID = $Property.propertyId
            if ($PropertyID -eq '') {
                throw "Property '$PropertyName' not found"
            }
        }
        catch {
            throw $_
        }
    }

    if ($PropertyVersion.ToLower() -eq "latest") {
        try {
            if ($PropertyName) {
                $PropertyVersion = $Property.propertyVersion
            }
            else {
                $Property = Get-Property -PropertyID $PropertyID -GroupID $GroupID -ContractId $ContractId -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
                $PropertyVersion = $Property.latestVersion
            }
        }
        catch {
            throw $_
        }
    }

    $Rules = Get-PropertyRuleTree -PropertyID $PropertyID -PropertyVersion $PropertyVersion -GroupID $GroupId -ContractId $ContractId -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey

    if ($OutputDir -eq '') {
        $OutputDir = $Rules.propertyName
    }
    
    # Make Property Directory if required
    if (!(Test-Path $OutputDir)) {
        Write-Host "Creating new property directory " -NoNewLine
        Write-Host -ForegroundColor Cyan $OutputDir
        New-Item -Name $OutputDir -ItemType Directory | Out-Null
    }

    for ($i = 0; $i -lt $Rules.rules.children.count; $i++) {
        Get-ChildRuleTemplate -Rules $Rules.rules.children[$i] -Path $OutputDir -CurrentDepth 0 -MaxDepth $MaxDepth
        $SafeName = Sanitize-FileName -FileName $Rules.rules.children[$i].Name
        $Rules.rules.children[$i] = "#include:$SafeName.json"
    }

    ### Split variables out to its own file
    if ($Rules.rules.variables.count -gt 0) {
        $Rules.rules.variables | ConvertTo-Json -depth 100 | Out-File "$outputdir\pmVariables.json" -Force
    }
    else {
        '[]' | Out-File "$outputdir\pmVariables.json" -Force -NoNewline
    }
    $Rules.rules.variables = "#include:pmVariables.json"

    ### Write default rule to main file
    $Rules.rules | ConvertTo-Json -depth 100 | Out-File "$outputdir\main.json" -Force

    Write-Host "Wrote version " -NoNewLine
    Write-Host -ForegroundColor Cyan $Rules.propertyVersion -NoNewline
    Write-Host " of property " -NoNewline
    Write-Host  -ForegroundColor Cyan $Rules.propertyName -NoNewline
    Write-Host " to " -NoNewline
    Write-Host  -ForegroundColor Cyan $OutputDir
}
