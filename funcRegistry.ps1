#################################
#           LockOut             #
#      File: funcRegistry       #
#        By Scott Lyon          #
#         SubVer:  v1.5         #
#          Oct 19,2023          #
#################################
function Split-RegistryPath {
    param($registryPath)
    if ($registryPath.GetType().FullName -eq "System.Collections.Hashtable"){
        $registryPath = $registryPath[0]
    }
    #write-warning $registryPath
    $firstRegex = "^(?:[a-zA-Z]+:\\)?\[(.+)\](?:(?:[\:])|(?:[\\])(.+?)(?:[\:]))(String|ExpandString|Binary|Dword|Qword|Hex|MultiString)(?:\:)([^\{\n]+)(?:\{([^\|]*?)\|([^\|]*?)\}){0,}$"
    if ($registryPath -match $firstRegex) {
        $registryPath = $registryPath -replace "\[(.+)\]", $(get-path -path $Matches[1])
    }
    $regex = "^([a-zA-Z]+):\\({SID}|[0-9sS\-]{2,})?\\?(.+)(?:\:)(String|ExpandString|Binary|Dword|Qword|Hex|MultiString)(?:\:)([^\{\n]+)(?:\{([^\|]*?)\|([^\|]*?)\}){0,}$"
    if ($registryPath -match $regex) {
        $matchGroups = $Matches.GetEnumerator() | Where-Object { $_.Name -ne "0" }
        if ($($matchGroups[3].Value).substring(0,2) -ne "HK" ){
            $tHive = [string]$(get-Index $matchGroups 1).trim()
            $tSID = [string]$(get-Index $matchGroups 2)
        }else{
            $tHive = [string]$(get-Index $matchGroups 1)
            $tSID = $false
        }

        if ($matchGroups.length -ge 6){
            $trueVal = [string]$(get-Index $matchGroups 6)
            $falseVal = [string]$(get-Index $matchGroups 7)
        }else{
            $trueVal = 1
            $falseVal = 0
        }
        
        $customObject = [PSCustomObject]@{
            Hive = $tHive
            SID = $tSID
            Path = [string]$(get-Index $matchGroups 3)
            Type = [string]$(get-Index $matchGroups 4)
            Key = [string]$(get-Index $matchGroups 5)
            TrueValue = $trueVal
            FalseValue = $falseVal
        }
       $tHive = ""
       $tSID = ""
        
        return $customObject
    } else {
        Write-Debug "Invalid registry path format. [$registryPath]"
        return $null
    }
}
function Build-RegistrySubPath {
    param($registryObject)
    $registryPath = "$($registryObject.Hive):\"
    if ($registryObject.SID -ne $false) { $registryPath += "$($registryObject.SID)" }
    $registryPath += "$($registryObject.Path):$($registryObject.Type):$($registryObject.Key)"
    $registryPath += "\{$($registryObject.TrueValue)|$($registryObject.FalseValue)\}"
    

    return [String]$registryPath
}
function Build-RegistryPathNew {
    param($registryObject)
    $registryPath = "$($registryObject.Hive):\"
    if ($registryObject.SID -ne $false) { $registryPath += "$($registryObject.SID)" }
    $registryPath += "$($registryObject.Path):$($registryObject.Type):$($registryObject.Key)"
    $registryPath += "\{$($registryObject.TrueValue)|$($registryObject.FalseValue)\}"
    

    return [String]$registryPath
}
function Split-RegistryPathnew {
    param($registryPath)
    if ($registryPath.GetType().FullName -eq "System.Collections.Hashtable"){
        $registryPath = $registryPath[0]
    }
    $regex = "^([a-zA-Z]+):\\({SID}|[0-9sS\-]{2,})?\\?(.+)(?:\:)(String|ExpandString|Binary|Dword|Qword|Hex|MultiString)(?:\:)([^\{\n]+)(?:\{([^\|]*?)\|([^\|]*?)\}){0,}$"
    if ($registryPath -match $regex) {
        $matchGroups = $Matches.GetEnumerator() | Where-Object { $_.Name -ne "0" }
        if ($($matchGroups[3].Value).substring(0,2) -ne "HK" ){
            $tHive = [string]$(get-Index $matchGroups 1).trim()
            $tSID = [string]$(get-Index $matchGroups 2)
        }else{
            $tHive = [string]$(get-Index $matchGroups 1)
            $tSID = $false
        }

        if ($matchGroups.length -ge 6){
            $trueVal = [string]$(get-Index $matchGroups 6)
            $falseVal = [string]$(get-Index $matchGroups 7)
        }else{
            $trueVal = 1
            $falseVal = 0
        }
        
        $customObject = [PSCustomObject]@{
            Hive = $tHive
            SID = $tSID
            Path = [string]$(get-Index $matchGroups 3)
            Type = [string]$(get-Index $matchGroups 4)
            Key = [string]$(get-Index $matchGroups 5)
            TrueValue = $trueVal
            FalseValue = $falseVal
        }
       $tHive = ""
       $tSID = ""
        
        return $customObject
    } else {
        Write-Debug "Invalid registry path format. [$registryPath]"
        return $null
    }
}
function Build-RegistryPath {
    param($registryObject)
    $registryPath = "$($registryObject.Hive):\"
    if ($registryObject.SID -ne $false) { $registryPath += "$($registryObject.SID)" }
    $registryPath += "$($registryObject.Path):$($registryObject.Type):$($registryObject.Key)"
    $registryPath += "\{$($registryObject.TrueValue)|$($registryObject.FalseValue)\}"
    

    return [String]$registryPath
}
Function get-Index{
    Param($inputList, $index)
   $inputList | ForEach-Object({
        if($_.Name -eq $index){
            return $_.Value
        }
   })
}
function Dummy-PathComment{
# Example usage 
#$customObject = [PSCustomObject]@{
#    Hive = "HKU"
#    SID = "S-1-5-21-1234567890-1234567890-1234567890-1001"
#    Path = "\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
#    Type = "Dword"
#    Key = "NoControlPanel"
#}

#$restoredRegistryPath = Build-RegistryPath -registryObject $customObject
#$restoredRegistryPath 
}
function get-HiveValue{
    param($rHive)
    switch ($rHive) {
        {($_ -eq "HKCR") -or ($_ -eq "HKEY_CLASSES_ROOT")} { $HiveValue = [uint32]"0x80000000" }
        {($_ -eq "HKCU") -or ($_ -eq "HKEY_CURRENT_USER")} { $HiveValue = [uint32]"0x80000001" }
        {($_ -eq "HKLM") -or ($_ -eq "HKEY_LOCAL_MACHINE")} { $HiveValue = [uint32]"0x80000002" }
        {($_ -eq "HKU") -or ($_ -eq "HKEY_USERS")} { $HiveValue = [uint32]"0x80000003" }
        {($_ -eq "HKCC") -or ($_ -eq "HKEY_CURRENT_CONFIG")} { $HiveValue = [uint32]"0x80000005" }
        default { Write-Debug "Invalid Hive. [$rHive]" }
    }
    return $HiveValue
}
function Check-Hive {
    param($compName, $sid)
    
    # Enumerate registry subkeys
    $resultEnumSubKeys = $([wmiclass]"\\$compName\root\default:StdRegProv").EnumKey($(get-HiveValue "HKU"), $sid) 
    if ($resultEnumSubKeys.ReturnValue -eq 0) {
        # If the subkeys are found, the user's hive is loaded
        return $true
    } else {
        # If subkeys are not found, the user's hive is not loaded
        return $false
    }
}
function Load-RegistryHive {
    param(
        [string]$computerName,
        [string]$username,
        [string]$userSID
    )

    $command = "REG LOAD HKU\$userSID C:\Users\$username\NTUSER.DAT"
    
    $process = ([wmiclass]"\\$computerName\root\cimv2:Win32_Process").Create($command)
    $processReturnValue = $process.ReturnValue
    if ($processReturnValue -eq 0) {
        Write-Debug "Registry hive loaded successfully."
    } else {
        Write-Debug "Failed to load registry hive. Return Code: $processReturnValue"
    }
}
function Unload-RegistryHive {
    param(
        [string]$computerName,
        [string]$userSID
    )

    $command = "REG UNLOAD HKU\$userSID"
    
    $process = ([wmiclass]"\\$computerName\root\cimv2:Win32_Process").Create($command)
    $processReturnValue = $process.ReturnValue
    if ($processReturnValue -eq 0) {
        Write-Debug "Registry hive unloaded successfully."
    } else {
        Write-Debug "Failed to unload registry hive. Return Code: $processReturnValue"
    }
}
function Dummy-HiveComment{
# Usage example
#$computerName = "RemoteComputerName"
#$username = "Username"
#$userSID = "UserSID"

### Load-RegistryHive -computerName $computerName -username $username -userSID $userSID

# Do some operations with the loaded hive

### Unload-RegistryHive -computerName $computerName -userSID $userSID
}
function get-RemoteRegistryKeys{
    param($compName, $rHive, $rPath)
    $HiveValue = get-HiveValue $rHive
    # Create a WMI instance
    $regInstance = [wmiclass]"\\$compName\root\default:StdRegProv"
    $result = $regInstance.EnumKey($HiveValue, $rPath)
   ## write-host "Host:$($result.sNames)"
    if ($result.ReturnValue -eq 0) {
        return $result.sNames
    } else {
        Write-Debug "Failed to retrieve value. Return Code: $($result.ReturnValue) Path: $($rHive):\$rPath"
        return $false
    }
}
function get-RemoteRegistryEntries{
    param($compName, $rHive, $rPath)
    $HiveValue = get-HiveValue $rHive
    # Create a WMI instance
    $regInstance = [wmiclass]"\\$compName\root\default:StdRegProv"
    $result = $regInstance.EnumValues($HiveValue, $rPath)
    #write-host "Host:$($result.sNames)"
    #write-host "Host:$($result.Type)"
    if ($result.ReturnValue -eq 0) {
        return $result.sNames
    } else {
        Write-Debug "Failed to retrieve value. Return Code: $($result.ReturnValue) Path: $($rHive):\$rPath"
        return $false
    }
}
function get-RemoteRegistryString{
    param($compName, $rHive, $rPath, $rKey)
    $HiveValue = get-HiveValue $rHive

    # Create a WMI instance
    $regInstance = [wmiclass]"\\$compName\root\default:StdRegProv"
    $result = $regInstance.GetStringValue($HiveValue, $rPath, $rKey)
    
    if ($result.ReturnValue -eq 0) {
        return $result.sValue
    } else {
        Write-Debug "Failed to retrieve value. Return Code: $($result.ReturnValue)  Path: $($rHive):\$($rPath)::$rKey"
        return $false
    }
}
function Delete-RemoteRegistryValue{
    param($compName, $rHive, $rPath, $rValue)
    $HiveValue = get-HiveValue $rHive

    # Create a WMI instance
    $regInstance = [wmiclass]"\\$compName\root\default:StdRegProv"
    $result = $regInstance.DeleteValue($HiveValue, $rPath, $rValue)
    
    if ($result.ReturnValue -eq 0) {
        return $result.sValue
    } else {
        Write-Debug "Failed to delete value. Return Code: $($result.ReturnValue)"
        return $false
    }
}
function New-RemoteRegistryKey {
    param($compName, $rHive, $rPath)

    $HiveValue = Get-HiveValue $rHive

    # Create a WMI instance
    $regInstance = [wmiclass]"\\$compName\root\default:StdRegProv"

    # Convert path to a Key format
    $splitPath = $rPath.split('\')
    $rKey = $splitPath[-1]
    $remotePath = $splitPath[0..($splitpath.length - 2)] -join '\'

    # Check if the key exists
    $keyExists = $regInstance.EnumKey($HiveValue, $remotePath).sNames -contains $rKey
    
    if (-not $keyExists) {
        # If the key doesn't exist, create it
        $null = $regInstance.CreateKey($HiveValue, $rPath)
    }
}
function Set-RemoteRegistryValue {
    param($compName, $rHive, $rPath, $rKey, $valueType, $valueData)
    # Create the registry key if it doesn't exist
    New-RemoteRegistryKey -compName $compName -rHive $rHive -rPath $rPath -rKey $rKey

    $HiveValue = Get-HiveValue $rHive

    # Create a WMI instance
    $regInstance = [wmiclass]"\\$compName\root\default:StdRegProv"

    # Convert value type to numeric type (if needed)
    $rType = $valueType
    switch ($rType) {
        "String" { $valueType = 1 }
        "ExpandString" { $valueType = 2 }
        "Binary" { $valueType = 3 }
        "Dword" { $valueType = 4 }
        "Hex" { $valueType = 5 }
        "MultiString" { $valueType = 7 }
        "Qword" { $valueType = 11 }
    }

    # Depending on the value type, use the appropriate method to set the value
    switch ($valueType) {
        1 { $regInstance.SetStringValue($HiveValue, $rPath, $rKey, $valueData) }
        2 { $regInstance.SetExpandedStringValue($HiveValue, $rPath, $rKey, $valueData) }
        3 { $regInstance.SetBinaryValue($HiveValue, $rPath, $rKey, $valueData) }
        4 { $regInstance.SetDWORDValue($HiveValue, $rPath, $rKey, $valueData) }
        5 { $regInstance.SetBinaryValue($HiveValue, $rPath, $rKey, $($valueData -split ' ' | ForEach-Object { [byte]::Parse($_, 'Hex') })) }
        7 { $regInstance.SetMultiStringValue($HiveValue, $rPath, $rKey, $valueData) }
        default { Write-Debug "Invalid value type." }
    }
}
function BackupSet-RemoteRegistryValue {
    param($compName, $rHive, $rPath, $rKey, $valueType, $valueData)
    $HiveValue = get-HiveValue $rHive
    # Create a WMI instance
    $regInstance = [wmiclass]"\\$compName\root\default:StdRegProv"
    
    # Convert value type to numeric type (if needed)
    $rType = $valueType
    switch ($rType) {
        "String" { $valueType = 1 }
        "ExpandString" { $valueType = 2 }
        "Binary" { $valueType = 3 }
        "Dword" { $valueType = 4 }
        "Qword" { $valueType = 11 }
        "MultiString" { $valueType = 7 }
    }
    # Depending on the value type, use the appropriate method to set the value
    switch ($valueType) {
        1 { $regInstance.SetStringValue($HiveValue, $rPath, $rKey, $valueData) }
        2 { $regInstance.SetExpandedStringValue($HiveValue, $rPath, $rKey, $valueData) }
        3 { $regInstance.SetBinaryValue($HiveValue, $rPath, $rKey, $valueData) }
        4 { $regInstance.SetDWORDValue($HiveValue, $rPath, $rKey, $valueData) }
        7 { $regInstance.SetMultiStringValue($HiveValue, $rPath, $rKey, $valueData) }
        default { Write-Debug "Invalid value type." }
    }
}
function Get-RemoteRegistryValue {
    param($compName, $rHive, $rPath, $rKey)
    $HiveValue = Get-HiveValue $rHive

    # Create a WMI instance
    $regInstance = [wmiclass]"\\$compName\root\default:StdRegProv"

    # Enumerate registry values
    $resultEnumKeys = $regInstance.EnumKey($HiveValue, $rPath)
    if ($resultEnumKeys.ReturnValue -eq 0) {
        $matchingKeys = $resultEnumKeys.sNames | Where-Object { $_ -like $rKey }
        if ($matchingKeys.Count -gt 0) {
            $foundKey = $matchingKeys[0]
            $result = $regInstance.GetStringValue($HiveValue, "$rPath\$foundKey", $rKey)
            if ($result.ReturnValue -eq 0) {
                switch ($result.Types[0]) {
                    1 { return $result.sValue }
                    2 { return $result.sValue }
                    3 {
                        $hexString = $result.uValue | ForEach-Object { $_.ToString("X2") }
                        return $hexString -join " "
                    }
                    4 { return $result.uValue }
                    7 { return $result.sValue }
                    default { return $false }
                }
            } else {
                Write-Debug "Failed to read registry value. Return Code: $($result.ReturnValue), Key: $($rHive):\$($rPath)\$foundKey\$($rKey)"
                return $false
            }
        }
    } else {
        Write-Debug "Failed to enumerate keys. Return Code: $($resultEnumKeys.ReturnValue), Key: $($rHive):\$($rPath)"
        return $false
    }
}

function get-RemoteRegistryValuebak {
    param($compName, $rHive, $rPath, $rKey)
    $HiveValue = get-HiveValue $rHive

    # Create a WMI instance
    $regInstance = [wmiclass]"\\$compName\root\default:StdRegProv"

    # Enumerate registry values
    $resultEnumValues = $regInstance.EnumValues($HiveValue, $rPath)
    if ($resultEnumValues.ReturnValue -eq 0) {
        for ($i = 0; $i -lt $resultEnumValues.sNames.Length; $i++) {
            if ($resultEnumValues.sNames[$i] -eq $rKey){
                    # Depending on the value type, handle it accordingly
                    switch ($resultEnumValues.Types[$i]) {
                        1 { $result = $regInstance.GetStringValue($HiveValue, $rPath, $rKey) }
                        2 { $result = $regInstance.GetExpandedStringValue($HiveValue, $rPath, $rKey)  }
                        3 { $result = $regInstance.GetBinaryValue($HiveValue, $rPath, $rKey)  }
                        4 { $result = $regInstance.GetDWORDValue($HiveValue, $rPath, $rKey)  }
                        7 { $result = $regInstance.GetMultiStringValue($HiveValue, $rPath, $rKey)  }
                        default { $result = $false }
                    }
                    if ($result.ReturnValue -eq 0){
                        switch ($resultEnumValues.Types[$i]) {
                            1 { return $result.sValue }
                            2 { return $result.sValue  }
                            3 { $hexString = $result.uValue | ForEach-Object { $_.ToString("X2") }
                                return $hexString -join " "  }
                            4 { return $result.uValue  }
                            7 { return $result.sValue  }
                            default { return $false }
                        }
                    }
                break
           }
        }
    } else {
        Write-Debug "Failed to enumerate values. Return Code: $($resultEnumValues.ReturnValue), Key: $($rHive):\$($rPath)\$($rKey)"
        return $false
    }
}