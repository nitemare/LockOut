#################################
#           LockOut             #
#      File: runtimePaths       #
#        By Scott Lyon          #
#         SubVer:  v1.6         #
#          Oct 22,2023          #
#################################
function get-Path{
    param($Path, $SpoofOverride = $false)
    $Base_Paths = @{
        "pol_sys" = "HKU:\{SID}\SOFTWARE\Policies\Microsoft\Windows\System"
        "system" = "HKU:\{SID}\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
        "explorer" = "HKU:\{SID}\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
        "int_exp_cv" = "HKU:\{SID}\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
        "int_exp" = "HKU:\{SID}\Software\Microsoft\Internet Explorer"
        "int_exp_main" = "HKU:\{SID}\Software\Microsoft\Internet Explorer\Main"
        "int_exp_cp" = "HKU:\{SID}\Software\Policies\Microsoft\Internet Explorer\Control Panel"
        "profilelist" = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
        "winlogon" = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
        "chrome_pol" = "SOFTWARE\Policies\Google\Chrome"
        "edge_pol" = "SOFTWARE\Policies\Microsoft\Edge"
        "cp_power" = "HKU:\{SID}\Control Panel\PowerCfg"
        "sm_data" = "HKU:\{SID}\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\`$de`${03957959-2101-4892-96cf-b0368a46ac95}`$`$windows.data.unifiedtile.startglobalproperties\Current"

        }
    $FakeBase_Paths = @{
        "pol_sys" = "HKU:\{SID}\SOFTWARE\PoliciesSpoof\Microsoft\Windows\System"
        "system" = "HKU:\{SID}\SOFTWARE\Microsoft\Windows\CurrentVersion\PoliciesFake\System"
        "explorer" = "HKU:\{SID}\SOFTWARE\Microsoft\Windows\CurrentVersion\PoliciesFake\Explorer"
        "int_exp_cv" = "HKU:\{SID}\Software\Microsoft\Windows\CurrentVersion\Internet Settings Spoof"
        "int_exp" = "HKU:\{SID}\Software\Microsoft\Internet Explorer Spoof"
        "int_exp_main" = "HKU:\{SID}\Software\Microsoft\Internet Explorer Spoof\Main"
        "int_exp_cp" = "HKU:\{SID}\Software\Policies\Microsoft\Internet Explorer Spoof\Control Panel"
        "profilelist" = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
        "winlogon" = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinlogonSpoof"
        "chrome_pol" = "SOFTWARE\Policies\Google\ChromeSpoof"
        "edge_pol" = "SOFTWARE\Policies\Microsoft\EdgeSpoof"
        "cp_power" = "HKU:\{SID}\Control Panel Spoof\PowerCfg"
        "sm_data" = "HKU:\{SID}\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStoreSpoof\Store\Cache\DefaultAccount\`$de`${03957959-2101-4892-96cf-b0368a46ac95}`$`$windows.data.unifiedtile.startglobalproperties\Current"
        }
    #enable Spoofed Registiry paths for debug and diagnostics
    #Write-Debug
    if ($Script:BasePathMode -eq $true -and $SpoofOverride -eq $false){
        return $FakeBase_Paths[$Path]
    }else{
        return $Base_Paths[$Path]
    }
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