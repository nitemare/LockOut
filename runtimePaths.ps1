#################################
#           LockOut             #
#      File: runtimePaths       #
#        By Scott Lyon          #
#         SubVer:  v1.7         #
#          Jun 24,2024          #
#################################
function get-Path{
    param($Path, $SpoofOverride = $false, $sid = $null)
    $Base_Paths = @{
        "pol_sys" = "HKU:\{SID}\SOFTWARE\Policies\Microsoft\Windows\System"
        "system" = "HKU:\{SID}\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
        "explorer" = "HKU:\{SID}\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
        "policies" = "HKU:\{SID}\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies"
        "searchPol" = "HKU:\{SID}\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
        "int_exp_cv" = "HKU:\{SID}\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
        "int_exp" = "HKU:\{SID}\Software\Microsoft\Internet Explorer"
        "int_exp_main" = "HKU:\{SID}\Software\Microsoft\Internet Explorer\Main"
        "int_exp_cp" = "HKU:\{SID}\Software\Policies\Microsoft\Internet Explorer\Control Panel"
        "profilelist" = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
        "winlogon" = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
        "disable_search" = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Search\DisableSearch"
        "search" = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
        "local_explorer" = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
        "dsh" = "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"
        "chrome_pol" = "SOFTWARE\Policies\Google\Chrome"
        "edge_pol" = "SOFTWARE\Policies\Microsoft\Edge"
        "cp_power" = "HKU:\{SID}\Control Panel\PowerCfg"
        "copilot" = "HKU:\{SID}\Software\Policies\Microsoft\Windows\WindowsCopilot"
        "sm_data" = "HKU:\{SID}\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\`$de`${03957959-2101-4892-96cf-b0368a46ac95}`$`$windows.data.unifiedtile.startglobalproperties\Current"

        }
    $FakeBase_Paths = @{
        "pol_sys" = "HKU:\{SID}\SOFTWARE\PoliciesSpoof\Microsoft\Windows\System"
        "system" = "HKU:\{SID}\SOFTWARE\Microsoft\Windows\CurrentVersion\PoliciesFake\System"
        "explorer" = "HKU:\{SID}\SOFTWARE\Microsoft\Windows\CurrentVersion\PoliciesFake\Explorer"
        "policies" = "HKU:\{SID}\SOFTWARE\Microsoft\Windows\CurrentVersion\PoliciesFake"
        "searchPol" = "HKU:\{SID}\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSpoof"
        "int_exp_cv" = "HKU:\{SID}\Software\Microsoft\Windows\CurrentVersion\Internet Settings Spoof"
        "int_exp" = "HKU:\{SID}\Software\Microsoft\Internet Explorer Spoof"
        "int_exp_main" = "HKU:\{SID}\Software\Microsoft\Internet Explorer Spoof\Main"
        "int_exp_cp" = "HKU:\{SID}\Software\Policies\Microsoft\Internet Explorer Spoof\Control Panel"
        "profilelist" = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
        "winlogon" = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinlogonSpoof"
        "disable_search" = "HKLM:\SOFTWARE\Microsoft\PolicyManagerSpoof\default\Search\DisableSearch"
        "search" = "HKLM:\SOFTWARE\Policies Spoof\Microsoft\Windows\Windows Search"
        "local_explorer" = "HKLM:\SOFTWARE\PoliciesSpoof\Microsoft\Windows\Explorer"
        "chrome_pol" = "SOFTWARE\Policies\Google\ChromeSpoof"
        "dsh" = "HKLM:\SOFTWARE\Policies\MicrosoftSpoof\Dsh"
        "edge_pol" = "SOFTWARE\Policies\Microsoft\EdgeSpoof"
        "cp_power" = "HKU:\{SID}\Control Panel Spoof\PowerCfg"
        "copilot" = "HKU:\{SID}\Software\PoliciesSpoof\Microsoft\Windows\WindowsCopilot"
        "sm_data" = "HKU:\{SID}\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStoreSpoof\Store\Cache\DefaultAccount\`$de`${03957959-2101-4892-96cf-b0368a46ac95}`$`$windows.data.unifiedtile.startglobalproperties\Current"
        }
    #enable Spoofed Registiry paths for debug and diagnostics
    #Write-Debug
    if ($Script:BasePathMode -eq $true -and $SpoofOverride -eq $false){
        $returnable = $FakeBase_Paths[$Path]
    }else{
        $returnable = $Base_Paths[$Path]
    }
    if ($sid -ne $null){
        return $returnable.replace("{SID}", $sid)
    }
    return $returnable 
}
function Get-PathName {
    param ([string]$inputString )
    $parts = $inputString -split '\\'
    if ($parts.Count -ge 2) {
        $result = $parts[-2..-1] -join '\'
        return $result
    } else {
        return $inputString
    }
}
