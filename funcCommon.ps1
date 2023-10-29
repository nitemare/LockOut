#################################
#           LockOut             #
#      File: funcCommon         #
#        By Scott Lyon          #
#         SubVer:  v1.1         #
#          Oct 26,2023          #
#################################
function Ping-Computer {
    param (
        [string]$ComputerName
    )
    $HostName = if ($ComputerName -eq ".") { "localhost" } else { $ComputerName } 
    try {
        $pingResult = Get-WmiObject -Class Win32_PingStatus -Filter "Address='$HostName'"
        if ($pingResult.StatusCode -eq 0) {
            Write-Information "$ComputerName responded to ping."
            return $true
        } else {
            Write-Information "$ComputerName did not respond to ping."
            return $false
        }
    } catch {
        Write-Information "An error occurred while pinging $($ComputerName): $($_.Exception.Message)"
        return $false
    }
}
function Find-Control{
    param($UID, $controls = $main.controls)
    if ($main.UID -eq $UID){ return $main } else {
        foreach ($control in $controls) {
            if ($control.PSObject.Properties["UID"] -ne $null -and $control.UID -eq $UID) {
                return $control
            }
            if ($control -is [System.Windows.Forms.TabControl] -and $control.Controls.Count -gt 0) {
                $foundControl = Find-Control -UID $UID -controls $control.Controls
                if ($foundControl -ne $null) {
                    return $foundControl
                }
            }
        }
    }
    return $null 
}
function Get-NextNumber {
    param(
        [int[]]$numbersList
    )
    # Sort the array in ascending order
    $sortedNumbers = $numbersList | Sort-Object
    $missingNumber = $null
    if ($sortedNumbers.length -gt 0){
        # Check for the first missing number or the next number in the sequence
        for ($i = 0; $i -lt $sortedNumbers.Count; $i++) {
            if ($i -eq 0){
                if ($sortedNumbers[0] -ne 1){
                    $missingNumber = 1
                    break
                }
            }
            $currentNumber = $sortedNumbers[$i]
            Write-debug "CN: $currentNumber"
            # Check if the next number is missing
            if ($currentNumber + 1 -ne $sortedNumbers[$i + 1]) {
                $missingNumber = $currentNumber + 1
                break
            }
        }
     }else{
        $missingNumber = 1
     }
    # If no missing number was found, return the next number in the sequence
    if ($missingNumber -eq $null) {  $missingNumber = $sortedNumbers[-1] + 1 }

    return $missingNumber
}
function Get-ParentType{
    param($inOb)
    $fName = $inOb.GetType().FullName
    $sName = $fName.Split('.')
    $jName = $sName[0..$($sName.length - 2)] -Join '.'
    return $jName
}