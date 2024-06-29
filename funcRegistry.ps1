#################################
#            Surveys            #
#      File: funcRegistry v2    #
#        By Scott Lyon          #
#         SubVer:  v2.3         #
#          Jun 24,2024          #
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
        {($_ -eq "HKCR") -or ($_ -eq "HKEY_CLASSES_ROOT")} { $HiveValue = "ClassesRoot" }
        {($_ -eq "HKCU") -or ($_ -eq "HKEY_CURRENT_USER")} { $HiveValue = "CurrentUser" }
        {($_ -eq "HKLM") -or ($_ -eq "HKEY_LOCAL_MACHINE")} { $HiveValue = "LocalMachine" }
        {($_ -eq "HKU") -or ($_ -eq "HKEY_USERS")} { $HiveValue = "Users" }
        {($_ -eq "HKCC") -or ($_ -eq "HKEY_CURRENT_CONFIG")} { $HiveValue = "CurrentConfig" }
        default { Write-Debug "Invalid Hive. [$rHive]" }
    }
    return $HiveValue
}
function Check-Hive {
    param($compName, $sid)
    $HiveValue = get-HiveValue "HKU"
    # Create a Reg instance
    $regInstance = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($HiveValue, $compName)
    if ( $sid -in $regInstance.GetSubKeyNames()) {
        # If the subkeys are found, the user's hive is loaded
        return $true
    } else {
        # If subkeys are not found, the user's hive is not loaded
        return $false
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
    # Create a Reg instance
    $regInstance = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($HiveValue, $compName, [Microsoft.Win32.RegistryView]::Registry64)
    # Enumerate registry values
    $RegKey = $regInstance.OpenSubKey($rPath)
   ## write-host "Host:$($result.sNames)"
    if ($RegKey.ValueCount -gt 0) {
        $result = $RegKey.GetSubKeyNames()
    } else {
        Write-Debug "Failed to retrieve value. Return Code: $($result.ReturnValue) Path: $rPath"
        $result = $false
    }
    if ($RegKey -ne $null){
        $RegKey.Dispose()
        $RegKey = $null
    }
    $regInstance.Dispose()
    $regInstance = $null
    return $result
}
function get-RemoteRegistryEntries{
    param($compName, $rHive, $rPath)
    $HiveValue = get-HiveValue $rHive
    # Create a Reg instance
    $regInstance = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($HiveValue, $compName, [Microsoft.Win32.RegistryView]::Registry64)
    # Enumerate registry values
    $RegKey = $regInstance.OpenSubKey($rPath)
   ## write-host "Host:$($result.sNames)"
    if ($RegKey.ValueCount -gt 0) {
        $result = $RegKey.GetValueNames()
        
    } else {
        Write-Debug "Failed to retrieve value. Return Code: $($result.ReturnValue) Path: $($rHive):\$rPath"
        $result = $false
    }
    if ($RegKey -ne $null){
        $RegKey.Dispose()
        $RegKey = $null
    }
    $regInstance.Dispose()
    $regInstance = $null
    return $result
}
function get-RemoteRegistryKeys{
    param($compName, $rHive, $rPath)
    $HiveValue = get-HiveValue $rHive
    # Create a Reg instance
    $regInstance = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($HiveValue, $compName, [Microsoft.Win32.RegistryView]::Registry64)
    # Enumerate registry values
    $RegKey = $regInstance.OpenSubKey($rPath)
   ## write-host "Host:$($result.sNames)"
    if ($RegKey.ValueCount -gt 0) {
        $result = $RegKey.GetSubKeyNames()
    } else {
        Write-Debug "Failed to retrieve value. Return Code: $($result.ReturnValue) Path: $rPath"
        $result = $false
    }
    if ($RegKey -ne $null){
        $RegKey.Dispose()
        $RegKey = $null
    }
    $regInstance.Dispose()
    $regInstance = $null
    return $result
}
function Set-RemoteRegistryValue {
    param($compName, $rHive, $rPath, $rKey, $valueType, $valueData)
    write-debug "Path: $rPath"
    write-debug "key : $rKey"
    
    # Create the registry key if it doesn't exist
    New-RemoteRegistryKey -compName $compName -rHive $rHive -rPath $rPath -rKey $rKey
    
    write-debug "Path Created"
    $HiveValue = Get-HiveValue $rHive
    # Create a Reg instance
    $regInstance = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($HiveValue, $compName, [Microsoft.Win32.RegistryView]::Registry64)

    $RegKey = $regInstance.OpenSubKey($rPath, $true)
 if ($RegKey -ne $null) {
        # Convert value type to numeric type (if needed)
        $rType = $valueType
        switch ($rType.ToLower()) {
            "string" { $valueType = 1 }
            "expandstring" { $valueType = 2 }
            "binary" { $valueType = 3 }
            "dword" { $valueType = 4 }
            "hex" { $valueType = 5 }
            "multistring" { $valueType = 7 }
            "qword" { $valueType = 11 }
        }
        #Write-Debug "[$valueType]"
        # Depending on the value type, use the appropriate method to set the value
        switch ($valueType) {
            1 { $RegKey.SetValue($rKey, $valueData, [Microsoft.Win32.RegistryValueKind]::String) }
            2 { $RegKey.SetValue($rKey, $valueData, [Microsoft.Win32.RegistryValueKind]::ExpandString) }
            3 { $RegKey.SetValue($rKey, $valueData, [Microsoft.Win32.RegistryValueKind]::Binary) }
            4 { $RegKey.SetValue($rKey, $valueData, [Microsoft.Win32.RegistryValueKind]::DWord) }
        
            #5 { $RegKey.SetValue($rKey, $valueData, [Microsoft.Win32.RegistryValueKind]::Binary) }        
            5 { $RegKey.SetValue($rKey, [byte[]](StringToByte $valueData), [Microsoft.Win32.RegistryValueKind]::Binary) }
            7 { $RegKey.SetValue($rKey, $valueData, [Microsoft.Win32.RegistryValueKind]::QWord) }
            default { Write-Debug "Invalid value type." }
        }
        #$RegKey.Flush()
    } else {
    }
    $RegKey.Dispose()
    $RegKey = $null
    $regInstance.Dispose()
    $regInstance = $null
}
function get-RemoteRegistryValue {
    param($compName, $rHive, $rPath, $rKey)
    
    $HiveValue = Get-HiveValue $rHive

    # Create a Reg instance
    $regInstance = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($HiveValue, $compName, [Microsoft.Win32.RegistryView]::Registry64)
    $regValue = $null
    # Enumerate registry values
    $RegKey = $regInstance.OpenSubKey($rPath)
    if ($RegKey.ValueCount -gt 0) {
        $regValue = $RegKey.GetValue($rKey)
          if ($regValue -ne $null){
            switch ($regValue.GetType()) {
                "String"   { $returnVal = $regValue }
                "Int32"    { $returnVal =  $regValue }
                "Byte[]"   { $returnVal =  ByteToString($regValue) }
                "String[]" { $returnVal =  $regValue }
                "Int64"    { $returnVal =  $regValue }
                default    { $returnVal =  $regValue }
            }
         } else {
            #Write-Debug "Failed to enumerate values. Return Code: $($RegKey.ToString()), Key: $($rHive):\$($rPath)\$($rKey)"
            #return $false
         }
    }else{
        #Write-Debug "Failed to read key. Return Code: $rPath, Key: $($rHive):\$($rPath)\"
        #return $false
    }
    if ($RegKey -ne $null){
        $RegKey.Dispose()
        $RegKey = $null
    }
    $regInstance.Dispose()
    $regInstance = $null
    Return $returnVal
}

function New-RemoteRegistryKey {
    param($compName, $rHive, $rPath)

    $HiveValue = Get-HiveValue $rHive 
    
    # Create a Reg instance
    $regInstance = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($HiveValue, $compName)

    # Convert path to a Key format
    $splitPath = $rPath.split('\')
    $rKey = $splitPath[-1]
    $remotePath = $splitPath[0..($splitpath.length - 2)] -join '\'
    # Check if the key exists
    Write-Warning "Remote Path: $remotePath"
 
    $RegKey = $regInstance.OpenSubKey($remotePath, $true)
    $regKey
    #$keyExists = $regInstance.EnumKey($HiveValue, $remotePath).sNames -contains $rKey
    if ($RegKey -eq $null){
        New-RemoteRegistryKey -compName $compName -rHive $rHive -rPath $remotePath
        
        $RegKey = $regInstance.OpenSubKey($remotePath, $true)
    }
    if ($rKey -notin $RegKey.GetSubKeyNames()) {
        # If the key doesn't exist, create it
        $null = $RegKey.CreateSubKey($rKey)
    }
    
    if ($RegKey -ne $null){
        $RegKey.Dispose()
        $RegKey = $null
    }
    $regInstance.Dispose()
    $regInstance = $null
}
function get-RemoteRegistryString{
    param($compName, $rHive, $rPath, $rKey)
    
   return  get-RemoteRegistryValue $compName  $rHive  $rPath  $rKey
}
function Delete-RemoteRegistryValue{
    param($compName, $rHive, $rPath, $rValue)
    $HiveValue = get-HiveValue $rHive
    # Create a Reg instance
    $regInstance = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($HiveValue, $compName)
    # Enumerate registry values
    $RegKey = $regInstance.OpenSubKey($rPath, $true)
    if ($rValue -in $RegKey.GetValueNames()) {
        $RegKey.DeleteValue($rValue)
        if ($rValue -notin $RegKey.GetValueNames()) {
            $returnVal = $true
        } else {
            Write-Debug "Failed to delete value."
            $returnVal = $false
        }
    } else {
        Write-Debug "Failed to delete value. Value does not Exist"
        $returnVal = $false
    }
    
    if ($RegKey -ne $null){
        $RegKey.Dispose()
        $RegKey = $null
    }
    $regInstance.Dispose()
    $regInstance = $null
    return $returnVal
}
function StringToByte{
    param($inStr)
    return [byte[]] -split ($($inStr -replace ' ', '') -replace '..', '0x$& ')

}
function ByteToString{
    param($inBytes)
    return ($inBytes | ForEach-Object { [string]$('{0:d2}' -f [int]$_) }) -join " "
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
