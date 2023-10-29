#################################
#           LockOut             #
#      File: runtimeFunc        #
#        By Scott Lyon          #
#         SubVer:  v1.5.1       #
#          Oct 26,2023          #
#################################
function pop_StartMenuSearch{ 
    $var = pop_groupCheck -Name "StartMenuSearch" -Label "StartMenu Search" -Path [explorer] -Keys @(
        "Dword:ClearRecentProgForNewUserInStartMenu{1|0}", 
        "Dword:NoSearchCommInStartMenu{1|0}", 
        "Dword:NoSearchComputerLinkInStartMenu{1|0}", 
        "Dword:NoSearchFilesInStartMenu{1|0}", 
        "Dword:NoSearchInternetInStartMenu{1|0}", 
        "Dword:NoSearchProgramsInStartMenu{1|0}")
    #write-debug $var
    return $var
}
function pop_StartMenuExtras{ 
    $var = pop_groupCheck -Name "StartMenuExtras" -Label "StartMenu Extras" -Path [explorer] -Keys @(
        "Dword:NoUserNameInStartMenu{1|0}", 
        "Dword:NoRecentDocsMenu{1|0}", 
        "Dword:NoFavoritesMenu{1|0}", 
        "Dword:NoSMConfigurePrograms{1|0}", 
        "Dword:NoStartMenuEjectPC{1|0}", 
        "Dword:NoSMHelp{1|0}", 
        "Dword:NoSMBalloonTip{1|0}")
    #write-debug $var
    return $var
}
function pop_StartMenuPlaces{ 
    $var = pop_groupCheck -Name "StartMenuPlaces" -Label "StartMenu Place" -Path [explorer] -Keys @(
        "Dword:NoSMMyDOCS{1|0}", 
        "Dword:NoFavoritesMenu{1|0}", 
        "Dword:NoSMMyPictures{1|0}", 
        "Dword:NoStartMenuMyMusic{1|0}", 
        "Dword:NoStartMenuMyGames{1|0}", 
        "Dword:NoUserFolderInStartMenu{1|0}", 
        "Dword:NoStartMenuNetworkPlaces{1|0}")
    #write-debug $var
    return $var
}
function pop_MediaButtons{ 
    $var = pop_groupCheck -Name "MediaButtons" -Label "Keyboard Media Buttons" -Path [explorer] -Keys @(
        "Dword:Btn_Media{2|0}",
        "Dword:Btn_Back{2|0}", 
        "Dword:Btn_Forward{2|0}",
        "Dword:Btn_Home{1|0}", 
        "Dword:Btn_Search{2|0}", 
        "Dword:Btn_Favorites{2|0}", 
        "Dword:Btn_History{2|0}", 
        "Dword:Btn_Folders{2|0}",
        "Dword:Btn_Fullscreen{2|0}", 
        "Dword:Btn_Tools{2|0}", 
        "Dword:Btn_MailNews{2|0}",
        "Dword:Btn_Size{2|0}", 
        "Dword:Btn_Print{2|0}", 
        "Dword:Btn_Edit{2|0}", 
        "Dword:Btn_Discussions{2|0}", 
        "Dword:Btn_Cut{2|0}", 
        "Dword:Btn_Copy{2|0}",
        "Dword:Btn_Paste{2|0}", 
        "Dword:Btn_Encoding{2|0}")
    #write-debug $var
    return $var
}
function pop_CustomTaskbar{ 
    $var = pop_groupCheck -Name "CustomTaskbar" -Label "Disable Taskbar Customizations" -Path [explorer] -Keys @(
        "Dword:NoSetTaskbar",
        "Dword:NoTaskGrouping", 
        "Dword:NoAutoTrayNotify",
        "Dword:NoSMBalloonTip", 
        "Dword:NoToolbarsOnTaskbar", 
        "Dword:NoCloseDragDropBands", 
        "Dword:NoMovingBands", 
        "Dword:NoToolbarCustomize",
        "Dword:NoBandCustomize", 
        "Dword:SpecifyDefaultButtons", 
        "Dword:TaskbarNoThumbnail")
    #write-debug $var
    return $var
}
function pop_NeverSleep{ 
    $var = pop_groupCheck -Name "NeverSleepProfile" -Label "NeverSleep Power Profile" -Path [cp_power] -Keys @(
        "String:CurrentPowerPolicy{0|1}",
        "\PowerPolicies\0:String:Description{This Scheme keeps the screen on continually.|This scheme is suited to most home or desktop computers that are left plugged in all the time.}", 
        "\PowerPolicies\0:String:Name{NeverSleep|Home/Office Desk}", 
        "\PowerPolicies\0:Hex:Policies{01 00 00 00 02 00 00 00 01 00 00 00 00 00 00 00 02 00 00 00 00|01 00 00 00 02 00 00 00 01 00 00 00 00 00 00 00 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 2c 01 00 00 32 32 00 03 04 00 00 00 04 00 00 00 00 00 00 00 00 00 00 00 b0 04 00 00 2c 01 00 00 00 00 00 00 58 02 00 00 01 01 64 50 64 64 00 00}")
    #write-debug $var
    return $var
}
function Clear-Panel{
    $isUserInteraction = $false
    foreach($control in $RegControlList){
        $control.Enabled = $false
    }    
    foreach($check in $RegCheckList){
        $check.checked = $false
    }
    $isUserInteraction = $true
 }
function Pull-Host{
    
    $isUserInteraction = $false
    $compNameBox.Tag = $compNameBox.Text
    if(Ping-Computer -ComputerName $compNameBox.Text){
        $progBar.visible = $true
        Clear-Panel
        Set-ProgressBar "HostLoad" 5 $main
        populate-dropdown
        populate-browserlists
        populate-host
        $compNameBox.BackColor = [System.Drawing.Color]::LightGreen
        Set-ProgressBar "HostLoad" 95 $main
        Start-Sleep -Milliseconds 500 | Set-ProgressBar "HostLoad" 100 $main
        $progBar.visible = $false
    }else{
        $compNameBox.BackColor = [System.Drawing.Color]::LightPink
        Clear-Panel
    }
    
    $isUserInteraction = $true
}
function Load-TextBox{
    Param($inControl)
    $regProps = Split-RegistryPath $inControl.Tag
    $inControl.Text = [string]$(get-RemoteRegistryValue $CompNameBox.Text -rHive $regProps.Hive -rPath "$($regProps.Path)" -rKey $regProps.Key)
}
function Prime-TextBox{
    Param($inControl)
    $inControl.backColor = [System.Drawing.SystemColors]::Window
    $inControl.Add_Leave({
        $currentText = $this.Text
        $previousText = $this.Tag[1]
        if ($currentText -ne $previousText) {
            $rTag = Split-RegistryPath $this.Tag[0]
            Set-RemoteRegistryValue -compName $compNameBox.Text -rHive $rTag.Hive -rPath $rTag.Path -rKey $rTag.Key -valueType $rTag.Type -valueData $currentText
            $this.Tag[1] = $currentText
        }
    })
    $inControl.Add_KeyUp({
        $keyCode = $_.KeyCode
        $currentText = $this.Text
        $previousText = $this.Tag[1]
        if (($keyCode -eq [System.Windows.Forms.Keys]::Enter) -and ($currentText -ne $previousText)) {
            $rTag = Split-RegistryPath $this.Tag[0]
            $this.backColor = [System.Drawing.Color]::LightGreen
            Set-RemoteRegistryValue -compName $compNameBox.Text -rHive $rTag.Hive -rPath $rTag.Path -rKey $rTag.Key -valueType $rTag.Type -valueData $currentText
            $timer = New-Object Windows.Forms.Timer
            $timer.Interval = 5000  # 5 seconds (in milliseconds)
            $timer.tag = $this.Name
            $timer.add_Tick({ param($sender, $eventArgs)
                $inCont = $main.Controls.Find($sender.tag, $true)[0]
                if ($inCont.BackColor -eq [System.Drawing.SystemColors]::Window) {
                    $inCont.backColor = [System.Drawing.Color]::LightGreen
                } else {
                    $inCont.BackColor = [System.Drawing.SystemColors]::Window
                    $sender.Stop()
                    $sender.Dispose()
                }
            })
            $timer.Start()
            $this.Tag[1] = $currentText
        }
    })
    $inControl.Add_TextChanged{
        $currentText = $this.Text
        $previousText = $this.Tag[1]
        if ($currentText -eq $previousText) {
            $this.BackColor = [System.Drawing.Color]::LightGreen
        }else{
            $this.BackColor = [System.Drawing.SystemColors]::Window
        }
    }
}
function Prime-TextBoxBack{
    Param($inControl)
    $inControl.Add_Leave({
        $currentText = $inControl.Text
        $previousText = $inControl.Tag[1]
        if ($currentText -ne $previousText) {
            $rTag = Split-RegistryPath $inControl.Tag[0]
            Set-RemoteRegistryValue -compName $compNameBox.Text -rHive $rTag.Hive -rPath $rTag.Path -rKey $rTag.Key -valueType $rTag.valueType -valueData $currentText
            $inControl.Tag[1] = $currentText
        }
    })
    $inControl.Add_KeyUp({
        $keyCode = $_.KeyCode
        $currentText = $inControl.Text
        write-debug $inControl.Tag
        $previousText = $inControl.Tag[1]
        if (($keyCode -eq [System.Windows.Forms.Keys]::Enter) -and ($currentText -ne $previousText)) {
            $rTag = Split-RegistryPath $inControl.Tag[0]
            Set-RemoteRegistryValue -compName $compNameBox.Text -rHive $rTag.Hive -rPath $rTag.Path -rKey $rTag.Key -valueType $rTag.Type -valueData $currentText
            $inControl.Tag[1] = $currentText
        }
    })
    $inControl.Add_TextChanged{
        $currentText = $inControl.Text
        $previousText = $inControl.Tag[1]
        if ($currentText -eq $previousText) {
            $inControl.BackColor = [System.Drawing.Color]::LightGreen
        }else{
            $inControl.BackColor = [System.Drawing.SystemColors]::Window
        }
    }
}
function Load-CheckBox{
    Param($inControl)
    $regProps = Split-RegistryPath $inControl.Tag
    $inControl.Checked = $((get-RemoteRegistryValue $CompNameBox.Text -rHive $regProps.Hive -rPath "$($regProps.Path)" -rKey $regProps.Key) -eq $regProps.TrueValue)
}
function populate-host{
    Param()
    Load-TextBox $LoginUserName_box
    Set-ProgressBar "HostLoad" 5 $main "+"
    Load-TextBox $LoginUserPass_box
    Set-ProgressBar "HostLoad" 5 $main "+"
    Load-TextBox $LoginUserDomain_box
    Set-ProgressBar "HostLoad" 5 $main "+"
    Load-CheckBox $LoginAuto_box
    Set-ProgressBar "HostLoad" 98 $main 
}
function populate-host1{
    Param()
    $regProps = Split-RegistryPath $LoginUserName_box.Tag
   ## write-host $regProps
    $LoginUserNameText = get-RemoteRegistryValue $CompNameBox.Text -rHive $regProps.Hive -rPath "$($regProps.Path)" -rKey $regProps.Key
   ## write-host "Username: $($LoginUserNameText)"
    $LoginUserName_box.Text = "$($LoginUserNameText)"
    $regProps = $null
    Set-ProgressBar "HostLoad" 5 $main "+"
    $regProps = Split-RegistryPath $LoginUserPass_box.Tag
   ## write-host $regProps
    $LoginUserPassword = get-RemoteRegistryValue $CompNameBox.Text -rHive $regProps.Hive -rPath "$($regProps.Path)" -rKey $regProps.Key
    $LoginUserPass_box.Text = $LoginUserPassword
    $regProps = $null
    Set-ProgressBar "HostLoad" 5 $main "+"
    $regProps = Split-RegistryPath $LoginUserDomain_box.Tag
   ## write-host $regProps
    $LoginUserDomainName = get-RemoteRegistryValue $CompNameBox.Text -rHive $regProps.Hive -rPath "$($regProps.Path)" -rKey $regProps.Key
    $LoginUserDomain_box.Text = $LoginUserDomainName
    $regProps = $null
    Set-ProgressBar "HostLoad" 5 $main "+"
    $regProps = Split-RegistryPath $LoginAuto_box.Tag
   ## write-host $regProps
    $LoginAutoCheck = get-RemoteRegistryValue $CompNameBox.Text -rHive $regProps.Hive -rPath "$($regProps.Path)" -rKey $regProps.Key
    $LoginAuto_box.Checked = $($LoginAutoCheck -eq 1)
    $regProps = $null
    Set-ProgressBar "HostLoad" 98 $main 
}
function populate-browserlists{
  Param()
  populate-list "Allow"  "Edge"
  populate-list "Block"  "Edge"
  populate-list "Allow"  "Chrome"
  populate-list "Block"  "Chrome"
  Load-TextBox $ChromeHomePage_box
  Load-TextBox $EdgeHomePage_box
  Load-CheckBox $EdgeSideBar_box
  Load-CheckBox $EdgeDisablePass_box
  Load-CheckBox $EdgeDisablePassReveal_box
}
function populate-list{
  Param($AorB, $brow, $sender = $null)

    if ($sender -ne $null){
        $splitTag = $sender.tag.Split("|")
        $AorB = $splitTag[0]
        $brow = $splitTag[1]
    }
    #in this code, Would $allowDataTable and $blockDataTable become seperate objects, or would they both just referance $dataTable?
    $SelList = if ("A", "Allowed", "Allow" -contains $AorB){ "Allow" }else{ "Block" }
    $base_brow = if ("E","Edge" -contains $brow){ "Edge" }else{ "Chrome" }
    $DataList = if ("A", "Allowed", "Allow" -contains $AorB){ $(Get-Variable -Name ("allow" + $base_brow + "List")).value }else{ $(Get-Variable -Name ("block" + $base_brow + "List")).value }
   # write-debug "DataList: $($DataList.DisplayMember)"
    $base_path_local = if ("E","Edge" -contains $brow){ get-path -path 'edge_pol' }else{ get-path -path 'chrome_pol' }
    
    # Create a DataTable
    $DataTable = New-Object System.Data.DataTable
    $computerName = $CompNameBox.Text

    #Define Columns
    $DataTable.Columns.Add($(New-Object system.Data.DataColumn "Site",([string])))
    $DataTable.Columns.Add($(New-Object system.Data.DataColumn "SiteNum",([Int])))
    $DataTable.Columns.Add($(New-Object system.Data.DataColumn "DisplaySite",([String])))
    
    #$dataTable.Rows.Add([DBNull]::Value, "")
    # Populate the DataTable with non-system user profiles
    
    $ListData = get-RemoteRegistryEntries $computerName "HKLM" "$($base_path_local)\URL$($SelList)list"
    Set-ProgressBar "HostLoad" 5 $main "+"
    foreach ($siteNum in $ListData){
        $datarow = $Datatable.NewRow()
        $datarow.SiteNum = $siteNum
        $Site = $(get-RemoteRegistryValue $computerName "HKLM" "$($base_path_local)\URL$($SelList)List" $SiteNum)
        if ($([bool]$Site)){
            $datarow.Site = $Site
            $datarow.DisplaySite = "$($siteNum): $Site"
            $DataTable.Rows.Add($datarow)
        }
        $Site = ""
        Set-ProgressBar "HostLoad" $(15 / $DataList.length)  $main "+"
        $datarow = $null
    }
    #write-debug "DataListName: $($DataList.Name)"
    # Define value/display members, Set the data source, and cleaar the index
    #$dropdown.Items.Clear()
    #write-debug "Name: $($(Get-Variable -Name ("allow" + $base_brow + "List")).name)"
    $DataTable.DefaultView.Sort = "SiteNum ASC"
    $DataList.DisplayMember = "DisplaySite"
    $DataList.ValueMember = "SiteNum"
    $DataList.DataSource = $DataTable # $(Fix-DataTable $sortedList)
    #$DataList.Sorted = $true
    $DataList.SelectedIndex = -1

}
function populate-dropdown{
    Param()

    # Create a DataTable
    $dataTable = New-Object System.Data.DataTable
    $computerName = $CompNameBox.Text

    #Define Columns
    $dataTable.Columns.Add($(New-Object system.Data.DataColumn "SID",([string])))
    $dataTable.Columns.Add($(New-Object system.Data.DataColumn "Username",([string])))
    #$dataTable.Rows.Add([DBNull]::Value, "")
    # Populate the DataTable with non-system user profiles

    $profileList = get-RemoteRegistryKeys $computerName "HKLM" "SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
    Set-ProgressBar "HostLoad" 10 $main
    foreach ($sid in $profileList){
        if ($sid -like "S-1-5-21-*") {
            #Create a row
            $datarow = $datatable.NewRow()
            $datarow.SID = $sid
            $userName = $(get-RemoteRegistryValue $computerName "HKLM" "SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$sid" "ProfileImagePath")
            if ($([bool]$userName)){
                $datarow.username = $userName -replace ".*\\"
                $datatable.Rows.Add($datarow)
            }
            $userName = ""
        }

        Set-ProgressBar "HostLoad" $(40 / $profileList.length)  $main "+"
        
    }

    # Define value/display members, Set the data source, and cleaar the index
    #$dropdown.Items.Clear()
    $dropdown.DisplayMember = "Username"
    $dropdown.ValueMember = "SID"
    $dropdown.DataSource = $dataTable
    $dropdown.SelectedIndex = -1

}
function checkState-AlterUser{
    param($inControl)
  if ($isUserInteraction) {
        $selectedProfile = $dropdown.SelectedItem
        $sid = $selectedProfile["SID"]
        $computerName = $CompNameBox.Text
        #write-host "incontrol: $($inControl.Tag)"
        #write-debug ($inControl.Tag.substring(0,11) -ne "##KeyList##")
        #write-debug $inControl.Tag.substring(0,11)
        if ($inControl.Tag.substring(0,11) -eq "##KeyList##"){
            $arrList = $(convertFrom-Json $inControl.Tag.substring(12))
            #write-debug $arrList
            $iCount = 0
            $arrList | ForEach-Object{
                #Write-debug $_
                $regProps = Split-RegistryPath $_
            #$regProps = Split-RegistryPath $inControl.Tag
                $setVal = if ($inControl.Checked) { $regProps.TrueValue }else{ $regProps.FalseValue }
                Set-RemoteRegistryValue -compName $CompNameBox.Text -rHive $regProps.Hive -rPath "$($sid)\$($regProps.Path)" -rKey $regProps.Key -valueType $regProps.Type -valueData $setVal
            }
        }elseif ($inControl.Tag.substring(0,11) -ne "##KeyList##"){
           #write-Debug "incontrol: $($inControl.Tag)"
            $regProps = Split-RegistryPath $inControl.Tag
            $setVal = if ($inControl.Checked) { $regProps.TrueValue }else{ $regProps.FalseValue }
           #write-Debug "$($sid)\$($regProps.Path):$($regProps.Key)"
            Set-RemoteRegistryValue -compName $CompNameBox.Text -rHive $regProps.Hive -rPath "$($sid)\$($regProps.Path)" -rKey $regProps.Key -valueType $regProps.Type -valueData $setVal
        }
    }
}
function checkState-Alter{
    param($inControl)
  if ($isUserInteraction) {
        $computerName = $CompNameBox.Text
        if ($inControl.Tag.substring(0,11) -eq "##KeyList##"){
            $arrList = $(convertFrom-Json $inControl.Tag.substring(11))
            $iCount = 0
            $arrList | ForEach-Object{
                $regProps = Split-RegistryPath $_
                $setVal = if ($inControl.Checked) { $regProps.TrueValue }else{ $regProps.FalseValue }
                Set-RemoteRegistryValue -compName $CompNameBox.Text -rHive $regProps.Hive -rPath "$($regProps.Path)" -rKey $regProps.Key -valueType $regProps.Type -valueData $setVal
            }
        }elseif ($inControl.Tag.substring(0,11) -ne "##KeyList##"){
            $regProps = Split-RegistryPath $inControl.Tag
            $setVal = if ($inControl.Checked) { $regProps.TrueValue }else{ $regProps.FalseValue }
            Set-RemoteRegistryValue -compName $CompNameBox.Text -rHive $regProps.Hive -rPath "$($regProps.Path)" -rKey $regProps.Key -valueType $regProps.Type -valueData $setVal
        }
    }
}
function pop_GroupCheck {
    param( [String]$Name, [String]$Label, [String]$Path, [Array]$Keys, $toolTip = "Applies '{Path}' keys: {Keys}", $allOrNothing = $false)
    if ($allOrNothing -eq $true){ $AorN = "!" } else { $AorN = "#" }
    $keyList, $outKeys = @(), @()
    $Keys | ForEach-Object{
        if ($_[0] -eq "\"){
            
            $outKeys += "$($Path)$($_)"
        }else{
            $outKeys += "$($Path):$($_)"

        }
        $splitStr = Split-RegistryPath $outKeys[-1]
        $keyList += $splitStr.Key
    }
    #write-warning $Path #$(Get-PathName $Path)
    #write-warning $($Path.Substring(1,$Path.Length-2)) 
    #write-warning $(Get-Path $($Path.Substring(1,$Path.Length-2)))
    $Path = $(Get-Path $($Path.Substring(1,$Path.Length-2)) $true)
    #write-warning $Path 
return [PSCustomObject]@{
    Name = $Name
    Label = $Label
    KeyTag = "##KeyList##$AorN$(ConvertTo-Json $outKeys -Compress)"  
    ToolTipText = $toolTip.replace("{Path}",$(Get-PathName $Path)).replace("{Keys}",$("`n$($keyList -join "`n")"))
    }
}
function make-UserGroupCheck{
    param( $inputX, $inputY, $inputObject, $inputForm = $tabControls.TabPages[0] )
    $ControlObj = Add-OptionBox $inputY $inputX 150 $inputObject.Name "$($inputObject.Label) +" $inputForm "check"
    $ControlObj.tag = $inputObject.KeyTag
    #write-warning $inputObject.KeyTag
    Add-ToolTip $ControlObj $inputObject.ToolTipText
    $RegControlList.Add($ControlObj)
    $RegCheckList.Add($ControlObj)
    $RegEntryList.Add($ControlObj.Tag)
    $ControlObj.Add_CheckStateChanged({ param($sender, $eventArgs) checkState-AlterUser $sender })
    return $ControlObj
}
function make-UserCheck{
    param( $inputX, $inputY, $inputName, $inputTitle, $inputTag, $inputForm = $tabControls.TabPages[0] )
    $ControlObj = Add-OptionBox $inputY $inputX 150 $inputName $inputTitle $inputForm "check"
    $ControlObj.tag = $inputTag
    $RegControlList.Add($ControlObj)
    $RegCheckList.Add($ControlObj)
    $RegEntryList.Add($ControlObj.Tag)
    $ControlObj.Add_CheckStateChanged({ param($sender, $eventArgs) checkState-AlterUser $sender })
    return $ControlObj
}
function Load-BulkCheckbox{
    param($inputControl, $inc = 1, $allOrNothing = $false)
    if ($inputControl.Tag.substring(0,11) -eq "##KeyList##"){
        if ($inputControl.Tag.substring(11,12) -eq "!"){ $allOrNothing = $true } Else { $allOrNothing = $false }
        $arrList = $(convertFrom-Json $inputControl.Tag.substring(12))
        $ControlCount = 0
        $iCount = 0
        $arrList | ForEach-Object{
            $regProps = Split-RegistryPath $_
            $Control = get-RemoteRegistryValue $CompNameBox.Text -rHive $regProps.Hive -rPath "$($sid)\$($regProps.Path)" -rKey $regProps.Key
            if ($Control -eq $regProps.TrueValue){
                $ControlCount++
            }
            #write-warning $($ControlCount)
            $iCount++
        }
        
        if ($ControlCount -eq $iCount){
            $inputControl.checked = $true
        }elseif ($ControlCount -eq 0 -or $allOrNothing -eq $true){
            $inputControl.checked = $false
        }else{
            $inputControl.CheckState = [System.Windows.Forms.CheckState]::Indeterminate
        }
    }else{
        $regProps = Split-RegistryPath $inputControl.Tag
        $Control = get-RemoteRegistryValue $CompNameBox.Text -rHive $regProps.Hive -rPath "$($sid)\$($regProps.Path)" -rKey $regProps.Key
        if ($Control -eq $regProps.TrueValue){
            $inputControl.checked = $true
        }
    }
    $inputControl.Enabled = $true
    Set-ProgressBar "HostLoad" $inc $main "+"
}
function delete-site{
    Param($AorB, $brow, $sender = $null)

    if ($sender -ne $null){
        $splitTag = $sender.tag.Split("|")
        $AorB = $splitTag[0]
        $brow = $splitTag[1]
    }
    $base_path_local = if ("E","Edge" -contains $brow){ get-path -path 'edge_pol' }else{ get-path -path 'chrome_pol' }
    #$selectedRow = [System.Data.DataRowView]$allowList.SelectedItem 
    if ($(Get-Variable -Name ($AorB + $brow + "List")).value.SelectedIndex -ne -1){
        Delete-RemoteRegistryValue -CompName $compNameBox.Text -rHive "HKLM"  -rPath "$($base_path_local)\URL$($AorB)list" -rValue $(Get-Variable -Name ($AorB + $brow + "List")).value.SelectedValue
        populate-list $AorB $brow
    }
}
function Add-Site{
    
    Param($AorB, $brow, $sender = $null)

    if ($sender -ne $null){
        $splitTag = $sender.tag.Split("|")
        $AorB = $splitTag[0]
        $brow = $splitTag[1]
    }
    $base_path_local = if ("E","Edge" -contains $brow){ get-path -path 'edge_pol' }else{ get-path -path 'chrome_pol' }
    $ListData = Get-RemoteRegistryEntries -CompName $compNameBox.Text -rHive "HKLM"  -rPath "$($base_path_local)\URL$($AorB)list"
    write-debug "$($base_path_local)\URL$($AorB)list"
    $newSite = Show-InputBox -Prompt "Enter Site to Add:" -Title "Enter Site"
    if ($newSite -ne $null) { Set-RemoteRegistryValue -CompName $compNameBox.Text -rHive "HKLM"  -rPath "$($base_path_local)\URL$($AorB)list" -rKey $(Get-NextNumber $ListData) -valueType "String" -valueData $newSite }
    populate-list $AorB $brow
}
function Make-SiteList{
    Param($AorB, $browser, $form, $width = 200, $height = 200, $x = 10, $y = 30)
    $tags = "$AorB|$browser"
    $List = Make-listBox -width $width -height $height -x $x -y $y -main_form $form
    $AddButton = Add-Button -text "Add" -width $($List.Width / 3) -height 20 -x $List.Left -y $($List.Top + $List.Height) -main_form $form
    $RefreshButton = Add-Button -text "Refresh" -width $($List.Width / 3) -height 20 -x $($AddButton.Left + $AddButton.Width) -y $($List.Top + $List.Height) -main_form $form
    $RemoveButton = Add-Button -text "Remove" -width $($List.Width / 3) -height 20 -x $($RefreshButton.Left + $RefreshButton.Width) -y $($List.Top + $List.Height) -main_form $form
    $Label = Add-Label -text "URL$($AorB)List" -x $($List.left + 35) -y 10 -font_size 12 -width 150 -main_form $form
    $RefreshButton.tag = $tags
    $RemoveButton.tag = $tags
    $AddButton.tag = $tags
    $RefreshButton.Add_Click({ populate-list -sender $this })
    $RemoveButton.Add_Click({  delete-site -sender $this   })
    $AddButton.Add_Click({     Add-Site -sender $this      })
    return $List
}
function make-TextBox{
    param($x, $y, $width, $name, $label, $Key, $form, $passwordChar = $null, $drop = 5)
    
    if ($(Get-ParentType $y) -eq "System.Windows.Forms"){
        $y = $($y.top + $y.height + $drop)
    }
    $Text_box = Add-TextBox $x $y $width $name $form -prompt $label 
    $Text_box.tag = @{
        0 = $key 
        1 = ""
        }
    if ($passwordChar -ne $null){
         $Text_box.PasswordChar = '*'
    }
    Prime-TextBox $Text_box
    return $Text_box
}
function make-CheckBox{
    param($x, $y, $width, $name, $label, $Key, $form, $drop = 5)
    
    if ($(Get-ParentType $y) -eq "System.Windows.Forms"){
        $y = $($y.top + $y.height + $drop)
    }
    $Check_box = Add-OptionBox $x $y $width $name $label $form "Check"
    $Check_box.tag = $key 
    $Check_box.Add_CheckStateChanged({ param($sender, $eventArgs) checkState-Alter $sender })
    return $Check_box
}
function dropdown-change{
 write-debug "Dropdown index changed, Interaction: $isUserInteraction"
    if ($isUserInteraction) {
        $isUserInteraction = $false
        $selectedProfile = $dropdown.SelectedItem
        #write-debug "Host: $($selectedProfile.value)"
        if ([bool]$selectedProfile){
            $sid = $selectedProfile["SID"]
            if ($sid.length -gt 5){
                $computerName = $CompNameBox.Text
                $isHiveLoaded = Check-Hive -compName $computerName -sid $sid
                $inc = (90 / $RegControlList.Count)
                $progBar.visible = $true
                Set-ProgressBar "HostLoad" 5 $main
                if ($isHiveLoaded -and $isUserInteraction -eq $false) {
                    foreach($control in $RegControlList){ Load-BulkCheckbox $control $inc}  
                }else{
                    Clear-Panel
                }
                Set-ProgressBar "HostLoad" 95 $main
                Start-Sleep -Milliseconds 500 | Set-ProgressBar "HostLoad" 100 $main
                $progBar.visible = $false
            }
            $isUserInteraction = $true
        }
    }
}