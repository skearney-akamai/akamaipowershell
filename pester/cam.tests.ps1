Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:EdgeRCFile = $env:PesterEdgeRCFile
$Script:SafeEdgeRCFile = $env:PesterSafeEdgeRCFile
$Script:Section = 'default'
$Script:TestContract = '1-1NC95D'
$Script:TestKeyName = 'AkamaiPowershell'
$Script:TestKeyVersion = 1
$Script:TestNewKeyBody = '{
    "credentials": {
         "cloudAccessKeyId": "AKAMAICAMKEYID1EXAMPLE",
         "cloudSecretAccessKey": "cDblrAMtnIAxN/g7dF/bAxLfiANAXAMPLEKEY"
    },
    "networkConfiguration": {
         "securityNetwork": "STANDARD_TLS"
    },
    "accessKeyName": "Sales-s3",
    "contractId": "1-7FALA",
    "groupId": 10725
}'
$Script:TestNewKeyObject = ConvertFrom-Json $TestNewKeyBody

Describe 'Safe Cloud Access Manager Tests' {

    BeforeDiscovery {

    }

    ### List-AccessKeys
    $Script:Keys = List-AccessKeys -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AccessKeys returns a list' {
        $Keys.count | Should -Not -BeNullOrEmpty
    }

    # Find test key
    $Script:KeyUID = ($Keys | where accessKeyName -eq $TestKeyName).accessKeyUid
    if($null -eq $KeyUID){
        throw "Unable to find key $TestKeyName. Bailing out"
    }

    ### Get-AccessKey
    $Script:Key = Get-AccessKey -AccessKeyUID $KeyUID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AccessKey returns the right key' {
        $Key.accessKeyName | Should -Be $TestKeyName
    }

    ### List-AccessKeyVersions
    $Script:Versions = List-AccessKeyVersions -AccessKeyUID $KeyUID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AccessKeyVersions returns a list' {
        $Versions.count | Should -Not -BeNullOrEmpty
    }

    ### Get-AccessKeyVersion
    $Script:Version = Get-AccessKeyVersion -AccessKeyUID $KeyUID -Version $TestKeyVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AccessKeyVersion returns the right version' {
        $Version.version | Should -Be $TestKeyVersion
    }

    ### Get-AccessKeyVersionProperties
    $Script:Properties = Get-AccessKeyVersionProperties -AccessKeyUID $KeyUID -Version $TestKeyVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AccessKeyVersionProperties returns a list' {
        $Properties.count | Should -Not -Be 0
    }

    AfterAll {
        
    }
    
}

Describe 'Unsafe Cloud Access Manager Tests' {
    ### New-AccessKey by Body
    $Script:NewKeyByBody = New-AccessKey -Body $TestNewKeyBody -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'New-AccessKey completes successfully' {
        $NewKeyByBody.requestId | Should -Not -BeNullOrEmpty
    }

    ### New-AccessKey by object
    $Script:NewKeyByObject = New-AccessKey -AccessKey $TestNewKeyObject -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'New-AccessKey completes successfully' {
        $NewKeyByObject.requestId | Should -Not -BeNullOrEmpty
    }

    ### Get-AccessKeyCreateRequest
    $Script:CreateRequest = Get-AccessKeyCreateRequest -RequestID 12345 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Get-AccessKeyCreateRequest completes successfully' {
        $CreateRequest.accessKeyVersion.accessKeyUid | Should -Not -BeNullOrEmpty
    }

    ### New-AccessKeyVersion
    $Script:NewVersion = New-AccessKeyVersion -AccessKeyUID $KeyUID -CloudAccessKeyID 123456789 -CloudSecretAccessKey 123456789 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'New-AccessKeyVersion completes successfully' {
        $NewVersion.requestId | Should -Not -BeNullOrEmpty
    }

    ### Remove-AccessKeyVersion
    $Script:RemoveVersion = Remove-AccessKeyVersion -AccessKeyUID $KeyUID -Version 2 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Remove-AccessKeyVersion completes successfully' {
        $NewVersion.requestId | Should -Not -BeNullOrEmpty
    }
    
}

# SIG # Begin signature block
# MIIpogYJKoZIhvcNAQcCoIIpkzCCKY8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCB0FDKwxjTF9156
# cbwtRp8n835QiS6XJv5LE241LQr+JqCCDo4wggawMIIEmKADAgECAhAIrUCyYNKc
# TJ9ezam9k67ZMA0GCSqGSIb3DQEBDAUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNV
# BAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yMTA0MjkwMDAwMDBaFw0z
# NjA0MjgyMzU5NTlaMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAw
# ggIKAoICAQDVtC9C0CiteLdd1TlZG7GIQvUzjOs9gZdwxbvEhSYwn6SOaNhc9es0
# JAfhS0/TeEP0F9ce2vnS1WcaUk8OoVf8iJnBkcyBAz5NcCRks43iCH00fUyAVxJr
# Q5qZ8sU7H/Lvy0daE6ZMswEgJfMQ04uy+wjwiuCdCcBlp/qYgEk1hz1RGeiQIXhF
# LqGfLOEYwhrMxe6TSXBCMo/7xuoc82VokaJNTIIRSFJo3hC9FFdd6BgTZcV/sk+F
# LEikVoQ11vkunKoAFdE3/hoGlMJ8yOobMubKwvSnowMOdKWvObarYBLj6Na59zHh
# 3K3kGKDYwSNHR7OhD26jq22YBoMbt2pnLdK9RBqSEIGPsDsJ18ebMlrC/2pgVItJ
# wZPt4bRc4G/rJvmM1bL5OBDm6s6R9b7T+2+TYTRcvJNFKIM2KmYoX7BzzosmJQay
# g9Rc9hUZTO1i4F4z8ujo7AqnsAMrkbI2eb73rQgedaZlzLvjSFDzd5Ea/ttQokbI
# YViY9XwCFjyDKK05huzUtw1T0PhH5nUwjewwk3YUpltLXXRhTT8SkXbev1jLchAp
# QfDVxW0mdmgRQRNYmtwmKwH0iU1Z23jPgUo+QEdfyYFQc4UQIyFZYIpkVMHMIRro
# OBl8ZhzNeDhFMJlP/2NPTLuqDQhTQXxYPUez+rbsjDIJAsxsPAxWEQIDAQABo4IB
# WTCCAVUwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUaDfg67Y7+F8Rhvv+
# YXsIiGX0TkIwHwYDVR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0P
# AQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMDMHcGCCsGAQUFBwEBBGswaTAk
# BggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAC
# hjVodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9v
# dEc0LmNydDBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNybDAcBgNVHSAEFTATMAcGBWeBDAED
# MAgGBmeBDAEEATANBgkqhkiG9w0BAQwFAAOCAgEAOiNEPY0Idu6PvDqZ01bgAhql
# +Eg08yy25nRm95RysQDKr2wwJxMSnpBEn0v9nqN8JtU3vDpdSG2V1T9J9Ce7FoFF
# UP2cvbaF4HZ+N3HLIvdaqpDP9ZNq4+sg0dVQeYiaiorBtr2hSBh+3NiAGhEZGM1h
# mYFW9snjdufE5BtfQ/g+lP92OT2e1JnPSt0o618moZVYSNUa/tcnP/2Q0XaG3Ryw
# YFzzDaju4ImhvTnhOE7abrs2nfvlIVNaw8rpavGiPttDuDPITzgUkpn13c5Ubdld
# AhQfQDN8A+KVssIhdXNSy0bYxDQcoqVLjc1vdjcshT8azibpGL6QB7BDf5WIIIJw
# 8MzK7/0pNVwfiThV9zeKiwmhywvpMRr/LhlcOXHhvpynCgbWJme3kuZOX956rEnP
# LqR0kq3bPKSchh/jwVYbKyP/j7XqiHtwa+aguv06P0WmxOgWkVKLQcBIhEuWTatE
# QOON8BUozu3xGFYHKi8QxAwIZDwzj64ojDzLj4gLDb879M4ee47vtevLt/B3E+bn
# KD+sEq6lLyJsQfmCXBVmzGwOysWGw/YmMwwHS6DTBwJqakAwSEs0qFEgu60bhQji
# WQ1tygVQK+pKHJ6l/aCnHwZ05/LWUpD9r4VIIflXO7ScA+2GRfS0YW6/aOImYIbq
# yK+p/pQd52MbOoZWeE4wggfWMIIFvqADAgECAhAByZH9J50Asj/oHHbeHclzMA0G
# CSqGSIb3DQEBCwUAMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwHhcNMjMwNjEzMDAwMDAwWhcNMjQwMzAy
# MjM1OTU5WjCB3jETMBEGCysGAQQBgjc8AgEDEwJVUzEZMBcGCysGAQQBgjc8AgEC
# EwhEZWxhd2FyZTEdMBsGA1UEDwwUUHJpdmF0ZSBPcmdhbml6YXRpb24xEDAOBgNV
# BAUTBzI5MzM2MzcxCzAJBgNVBAYTAlVTMRYwFAYDVQQIEw1NYXNzYWNodXNldHRz
# MRIwEAYDVQQHEwlDYW1icmlkZ2UxIDAeBgNVBAoTF0FrYW1haSBUZWNobm9sb2dp
# ZXMgSW5jMSAwHgYDVQQDExdBa2FtYWkgVGVjaG5vbG9naWVzIEluYzCCAiIwDQYJ
# KoZIhvcNAQEBBQADggIPADCCAgoCggIBANdcrYnd5Y2q/LVByT4/w8A8XsvNZyET
# aJPcPw3DKpswy7TCGFLdVd5sD923zWlXy5VmXqYB/QQ1+yPjgSdgxiOFuhxL8tll
# 8OSb6auUUyrnIXx4PbcDAOKfd9J0IkQuBGNZvnMom9DkxTEpunaLEqjVFo08i53H
# 4VNmPgr7//qbEBCCulDYAg6K6HV7vckP/dTwqJ17jP3Qw0N8rnjcoxf6AwuuKcxl
# lQ4Zdr9q1yYUkvuAw6I5Vw78ODwb1Q+/nK+rYMY+Lx4W7YeAsvAXKWlUE5AXLgVC
# 3N7Xa5ZtAsaLzXJIcqW3HhCEWTygP0lTaPN9CIMnQqLtbve1PVaHH4bXG8hV9kuR
# hT5ZjvVGPDAJ9+xZap9AV+oVNp7QcbQ/p4r104TDGMA2j1wGUmRBcZobo2ypOREd
# jaI4xymenRenRhnxuAdU6Vm3yYam6XiWrIJszEk0i23bFs6wDy5wSPqr11lxn3Zh
# ksb04q+UvU+IhNkStSfwS5wizLA/KSuUjBkU7+sEd5lJaFEHHj3sH192ajODOi4s
# 3empeuwFjZbWukcq8fTLHiTkhyPoPgjvYq+6l0pZdH48pZA6utqMDO/0xIHl+PAy
# oQDVZgufYvvzsAGGF7cyFRyS7F/Tprxbd11w8DNv9I0MR+1zCMRPldAQ4aMYEakI
# kSHYuPZjXWVnAgMBAAGjggICMIIB/jAfBgNVHSMEGDAWgBRoN+Drtjv4XxGG+/5h
# ewiIZfROQjAdBgNVHQ4EFgQU4lrKPnD2cLwdOGv6x3R0iO+5q64wDgYDVR0PAQH/
# BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMIG1BgNVHR8Ega0wgaowU6BRoE+G
# TWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNENvZGVT
# aWduaW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEuY3JsMFOgUaBPhk1odHRwOi8vY3Js
# NC5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRDb2RlU2lnbmluZ1JTQTQw
# OTZTSEEzODQyMDIxQ0ExLmNybDA9BgNVHSAENjA0MDIGBWeBDAEDMCkwJwYIKwYB
# BQUHAgEWG2h0dHA6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzCBlAYIKwYBBQUHAQEE
# gYcwgYQwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBcBggr
# BgEFBQcwAoZQaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZEc0Q29kZVNpZ25pbmdSU0E0MDk2U0hBMzg0MjAyMUNBMS5jcnQwCQYDVR0T
# BAIwADANBgkqhkiG9w0BAQsFAAOCAgEA0yVWE59ZytC1egGLlmnUVBJk6TmpFZ2s
# dl8UtpZvb8YvDM105QhMGPtnEd4ffoqPqvgQwU7GZe7ZXrWxUu0C/ui5R5sp0fFI
# eahFBPc7cfz54jD/z+AIYDmw+Q/RgFCkAY9N2OF1KNjssKhj6cd6Z7aSc3Zj7FG3
# crXhXAmUWVosvFunEKkHXWXYbpv8edv8FC8ASvVUmVqdrHaXXSS8HigZEh/HE+XK
# A+CbBy2vQvwHq12brc7tkpSk6r15aG+RRdWmP8BirKeNYOzMZNP3XcgemmaK1SjO
# jOw/A3zyQXNEaDiAULvze1gtf8r6WT/nItgthpvKQhFejNhaAaBqlrS1YbOSvTtK
# CZMsKSTb+DEbN0dG/wcnJ4vWk4dOrgdgIDpNBhPy7q7l1v+woOWRH5UJsGNq0oFn
# wxOEdKYJ5Qn+5EMw++NMax1VlJaRrDL1nTPJudpuhpf1h1JOPhiNBsJHtCJXcxX/
# n6SUpn/VR+6Y0Lx/Knii2f8wZRFd8pCbnDLlQbwR1AxlGbQ9FlICmy+rIk+gHXC4
# 7P2JRO6uOBQcbwQDFUFC882CtKHhUtveU39LUBzkhPBByqx0e1ACcUyRIMwj4pC1
# ZS6sTPp622OBbsv0NKXZIpaSdcsF7Lak56ZQwHlO9tUDKm9KzVQHrp2v/0tdv9cz
# moABt8TK7rsxghpqMIIaZgIBATB9MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5E
# aWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2Rl
# IFNpZ25pbmcgUlNBNDA5NiBTSEEzODQgMjAyMSBDQTECEAHJkf0nnQCyP+gcdt4d
# yXMwDQYJYIZIAWUDBAIBBQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0B
# CQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAv
# BgkqhkiG9w0BCQQxIgQg6Ft02Png6HOHaCm07kFhH97nGIsNTuFQo/U46kf34gsw
# DQYJKoZIhvcNAQEBBQAEggIAWdVdhI1+nThlFwZTFCdl+LgzlgdFbel6ak9rQLvW
# oNGf2rzt3Ww3JWH2qifzmNGSkBYSSKo09XgExTndaZTWA3HqSkxasKfakE9EcWth
# 5L1PUoRmLjLWQ0tSA2fiAU3w4ZgW1bGL6aQQ7gGeKmz6SfuIzu1HC8PuKR4vT7Ru
# kWl1Fpm4KIvaL3ljO+T85zvaoez6++7Z6uwj9QTbHeIEX//GBjuww6UodVG4WkAh
# KoErGXVllirCWQtJH7sXXmbw3ptHArBgZCa1yaHFci6NCPUlHJeG86ve/qzMnb3G
# ufNVWgnrrfcsi/2+z2d4+EuFUhV2qdkPm2BWjoEIV9p2zhcTNx99LbjA6lr74uK6
# k1jClzjiu22lCKQHlnyQ9Fw+ZBNSxU4CQ/1n5QRzTxgXvkqMbXTu+1Jo8sLAytm/
# a7uRNGriqI22Awt/QVE7eP54Mdp+LqiPZD72GlrN4rDsuyz7o5iJ3brg6gOG2drr
# F11S+RSGN/LuZwmIY/Wn90er7gVKlXtZsOVE8YsVuzma7KRQlTsbfLp4oAOSfPj0
# rlyF8lN8VYCsa2AwzU68trhlSL5b7OfaVW82ZTNU7C+rvzqAyLeZTOnxZJ+tBRfL
# a8whAxlL84dPbRx5/xwECF2BybI/Qt1hCtFejeqXLw7qAJO3Nsomv28iKll0yGMp
# u9uhghdAMIIXPAYKKwYBBAGCNwMDATGCFywwghcoBgkqhkiG9w0BBwKgghcZMIIX
# FQIBAzEPMA0GCWCGSAFlAwQCAQUAMHgGCyqGSIb3DQEJEAEEoGkEZzBlAgEBBglg
# hkgBhv1sBwEwMTANBglghkgBZQMEAgEFAAQg0zHIiJhPvVuVsbIr+ZRsmfRWCmiX
# vtPMfg6Xp2vtSBkCEQCnPKrLBmeWDlaJ3CqoM2L4GA8yMDIzMTEwNjE3MTEyM1qg
# ghMJMIIGwjCCBKqgAwIBAgIQBUSv85SdCDmmv9s/X+VhFjANBgkqhkiG9w0BAQsF
# ADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNV
# BAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1w
# aW5nIENBMB4XDTIzMDcxNDAwMDAwMFoXDTM0MTAxMzIzNTk1OVowSDELMAkGA1UE
# BhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMSAwHgYDVQQDExdEaWdpQ2Vy
# dCBUaW1lc3RhbXAgMjAyMzCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# AKNTRYcdg45brD5UsyPgz5/X5dLnXaEOCdwvSKOXejsqnGfcYhVYwamTEafNqrJq
# 3RApih5iY2nTWJw1cb86l+uUUI8cIOrHmjsvlmbjaedp/lvD1isgHMGXlLSlUIHy
# z8sHpjBoyoNC2vx/CSSUpIIa2mq62DvKXd4ZGIX7ReoNYWyd/nFexAaaPPDFLnkP
# G2ZS48jWPl/aQ9OE9dDH9kgtXkV1lnX+3RChG4PBuOZSlbVH13gpOWvgeFmX40Qr
# StWVzu8IF+qCZE3/I+PKhu60pCFkcOvV5aDaY7Mu6QXuqvYk9R28mxyyt1/f8O52
# fTGZZUdVnUokL6wrl76f5P17cz4y7lI0+9S769SgLDSb495uZBkHNwGRDxy1Uc2q
# TGaDiGhiu7xBG3gZbeTZD+BYQfvYsSzhUa+0rRUGFOpiCBPTaR58ZE2dD9/O0V6M
# qqtQFcmzyrzXxDtoRKOlO0L9c33u3Qr/eTQQfqZcClhMAD6FaXXHg2TWdc2PEnZW
# pST618RrIbroHzSYLzrqawGw9/sqhux7UjipmAmhcbJsca8+uG+W1eEQE/5hRwqM
# /vC2x9XH3mwk8L9CgsqgcT2ckpMEtGlwJw1Pt7U20clfCKRwo+wK8REuZODLIivK
# 8SgTIUlRfgZm0zu++uuRONhRB8qUt+JQofM604qDy0B7AgMBAAGjggGLMIIBhzAO
# BgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEF
# BQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwHwYDVR0jBBgw
# FoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFKW27xPn783QZKHVVqll
# MaPe1eNJMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5j
# cmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5k
# aWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdD
# QS5jcnQwDQYJKoZIhvcNAQELBQADggIBAIEa1t6gqbWYF7xwjU+KPGic2CX/yyzk
# zepdIpLsjCICqbjPgKjZ5+PF7SaCinEvGN1Ott5s1+FgnCvt7T1IjrhrunxdvcJh
# N2hJd6PrkKoS1yeF844ektrCQDifXcigLiV4JZ0qBXqEKZi2V3mP2yZWK7Dzp703
# DNiYdk9WuVLCtp04qYHnbUFcjGnRuSvExnvPnPp44pMadqJpddNQ5EQSviANnqlE
# 0PjlSXcIWiHFtM+YlRpUurm8wWkZus8W8oM3NG6wQSbd3lqXTzON1I13fXVFoaVY
# JmoDRd7ZULVQjK9WvUzF4UbFKNOt50MAcN7MmJ4ZiQPq1JE3701S88lgIcRWR+3a
# EUuMMsOI5ljitts++V+wQtaP4xeR0arAVeOGv6wnLEHQmjNKqDbUuXKWfpd5OEhf
# ysLcPTLfddY2Z1qJ+Panx+VPNTwAvb6cKmx5AdzaROY63jg7B145WPR8czFVoIAR
# yxQMfq68/qTreWWqaNYiyjvrmoI1VygWy2nyMpqy0tg6uLFGhmu6F/3Ed2wVbK6r
# r3M66ElGt9V/zLY4wNjsHPW2obhDLN9OTH0eaHDAdwrUAuBcYLso/zjlUlrWrBci
# I0707NMX+1Br/wd3H3GXREHJuEbTbDJ8WC9nR2XlG3O2mflrLAZG70Ee8PBf4NvZ
# rZCARK+AEEGKMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipeWzANBgkqhkiG
# 9w0BAQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkw
# FwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVz
# dGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1OTU5WjBjMQsw
# CQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRp
# Z2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENB
# MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1BkmzwT1ySVFVxyUD
# xPKRN6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkLf50fng8zH1AT
# CyZzlm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C3GeO6lE98NZW
# 1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5n12sy+iEZLRS
# 8nZH92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUdzTYNXNXmG6jB
# ZHRAp8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWHpo9OdhVVJnCY
# Jn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/oN7jPqJz+ucf
# WmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPVA+C/8KI8ykLc
# GEh/FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg0ixXNXkrqPNF
# YLwjjVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mMDDtbiiKowSYI
# +RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6EVO7O6V3IXjAS
# vUaetdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB/wQIMAYBAf8C
# AQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1UdIwQYMBaAFOzX
# 44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggr
# BgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3Nw
# LmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGlnaWNl
# cnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4oDag
# NIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RH
# NC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqGSIb3
# DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBTzr8Y+8dQXeJL
# Kftwig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/EUExiHQwIgqgW
# valWzxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fmniye4Iqs5f2M
# vGQmh2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szwcqMj+sAngkSu
# mScbqyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8THwcFqcdnGE4AJ
# xLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/JWOZJyw9P2un
# 8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9Pzt4rUyt+8SV
# e+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm228Vex4Ziza4
# k9Tm8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVBtzrVFZgxtGIJ
# Dwq9gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnwZXZCpimHCUcr
# 5n8apIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv27dZ8/DCCBY0w
# ggR1oAMCAQICEA6bGI750C3n79tQ4ghAGFowDQYJKoZIhvcNAQEMBQAwZTELMAkG
# A1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRp
# Z2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENB
# MB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEwOTIzNTk1OVowYjELMAkGA1UEBhMCVVMx
# FTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNv
# bTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQc2jeu+RdSjwwIjBpM+zCpyUuySE98orY
# WcLhKac9WKt2ms2uexuEDcQwH/MbpDgW61bGl20dq7J58soR0uRf1gU8Ug9SH8ae
# FaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU0RBEEC7fgvMHhOZ0O21x4i0MG+4g1ckg
# HWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzryc/NrDRAX7F6Zu53yEioZldXn1RYjgwr
# t0+nMNlW7sp7XeOtyU9e5TXnMcvak17cjo+A2raRmECQecN4x7axxLVqGDgDEI3Y
# 1DekLgV9iPWCPhCRcKtVgkEy19sEcypukQF8IUzUvK4bA3VdeGbZOjFEmjNAvwjX
# WkmkwuapoGfdpCe8oU85tRFYF/ckXEaPZPfBaYh2mHY9WV1CdoeJl2l6SPDgohIb
# Zpp0yt5LHucOY67m1O+SkjqePdwA5EUlibaaRBkrfsCUtNJhbesz2cXfSwQAzH0c
# lcOP9yGyshG3u3/y1YxwLEFgqrFjGESVGnZifvaAsPvoZKYz0YkH4b235kOkGLim
# dwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2QXXeeqxfjT/JvNNBERJb5RBQ6zHFynIW
# IgnffEx1P2PsIV/EIFFrb7GrhotPwtZFX50g/KEexcCPorF+CiaZ9eRpL5gdLfXZ
# qbId5RsCAwEAAaOCATowggE2MA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFOzX
# 44LScV1kTN8uZz/nupiuHA9PMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3z
# bcgPMA4GA1UdDwEB/wQEAwIBhjB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGG
# GGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2Nh
# Y2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDBF
# BgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRBc3N1cmVkSURSb290Q0EuY3JsMBEGA1UdIAQKMAgwBgYEVR0gADANBgkqhkiG
# 9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0Gz22Ftf3v1cHvZqsoYcs7IVeqRq7IviH
# GmlUIu2kiHdtvRoU9BNKei8ttzjv9P+Aufih9/Jy3iS8UgPITtAq3votVs/59Pes
# MHqai7Je1M/RQ0SbQyHrlnKhSLSZy51PpwYDE3cnRNTnf+hZqPC/Lwum6fI0POz3
# A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix3P0c2PR3WlxUjG/voVA9/HYJaISfb8rb
# II01YBwCA8sgsKxYoA5AY8WYIsGyWfVVa88nq2x2zm8jLfR+cWojayL/ErhULSd+
# 2DrZ8LaHlv1b0VysGMNNn3O3AamfV6peKOK5lDGCA3YwggNyAgEBMHcwYzELMAkG
# A1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdp
# Q2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQQIQ
# BUSv85SdCDmmv9s/X+VhFjANBglghkgBZQMEAgEFAKCB0TAaBgkqhkiG9w0BCQMx
# DQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTIzMTEwNjE3MTEyM1owKwYL
# KoZIhvcNAQkQAgwxHDAaMBgwFgQUZvArMsLCyQ+CXc6qisnGTxmcz0AwLwYJKoZI
# hvcNAQkEMSIEIEY2fu/xqlC9ogQkUF1xZTTil0klsH051Bzr0EFZHl5GMDcGCyqG
# SIb3DQEJEAIvMSgwJjAkMCIEINL25G3tdCLM0dRAV2hBNm+CitpVmq4zFq9NGprU
# DHgoMA0GCSqGSIb3DQEBAQUABIICAD+1aaJFfRaXQkDgkp1906gE0aQ7Tdag18dG
# c3jaEPm6Ak8CYALzTsHJdfCIsJ2QRp+ETPHbT/nObja8e/9exqq/ziyE24hDJPBd
# zviBWrnvobfF3FIct4SAPw1nLzzL8JXR5bFkFW6nfw7NA0wiQBKQzQWQSf32Ugie
# 5p/0qBx3ydE4ugcpKihoGtJ/dgvrZdupobiuk/ns7hHKmsnNitwSDV6dkV/P9dI6
# ydNhV8+P09zsn9UTL8qKlEWeiys5qlLYpqRln5N/t5ghKbez7Aw4jTy8JZdo1EZ9
# iBSgJMl5+PWUY0FAxdItczO9xvXwwJnEPIeuAPPdCPGXyoNYU6pajMm4iNd72b7i
# mK4K6WZugHxwVi/kyGz4pCJA4q9yMIHbH0ZTq3Oq8vt4FnQApuXFaltxArIcuh7e
# P4fq/2eLCA721JHD5wu7KCNGMHS7xvNa6h7N+L6s3bowiD0OVdHc5jo2/ppQfax8
# mCM7KogpB94RHdzNMwP8MR/k3Yll8xWO1Kk56vSEllv08+qJa+xwGJy4te820jLL
# ZerqchNYP3gFLq9L7lQRCjgQGVvMo5W8xpdR6n8CxTvrtEwlTiwWPo7lIb8mTq0A
# MB6U7HrUan1YnCDLSIWULSVlRLv8k3RhG2IiqEcMF02dpLP9wUkFRPcDMXxqHYJC
# QQLODeQZ
# SIG # End signature block
