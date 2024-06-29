#################################
#           LockOut             #
#      File: Main Runtime       #
#        By Scott Lyon          #
        $Version = "v1.9"       #
#          Jun 25,2024          #
#################################
[void][System.Reflection.Assembly]::LoadWithPartialName("System")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
Add-Type -AssemblyName PresentationFramework

#########################
# Base Paths & Includes #
#########################
    #$Script:BasePathMode = $true
    $Script:BasePathMode = $false

. "$PSScriptRoot\funcCommon.ps1"      # v1.2
. "$PSScriptRoot\funcRegistry.ps1"    # v2.3
. "$PSScriptRoot\funcMainWindow.ps1"  # v1.5
. "$PSScriptRoot\funcForms.ps1"       # v1.3
. "$PSScriptRoot\runtimeFunc.ps1"     # v1.8
. "$PSScriptRoot\runtimePaths.ps1"    # v1.7

###############################
# App Launch Sequence Initate #
###############################

#$DebugPreference, $VerbosePreference = "Continue", "SilentlyContinue"
#$DebugPreference, $VerbosePreference, $InformationPreference = "SilentlyContinue", "SilentlyContinue", "SilentlyContinue"
$DebugPreference, $VerbosePreference, $InformationPreference = "Continue", "Continue", "Continue"
# Initialize a variable to track user interaction
$isUserInteraction = $false
$AboutInfo = @{ Title = "LockOut"; Author = "Scott Lyon"; Description = "Lockdown Kisok or Public access consoles"; Version = $Version; Icon = "" }
    
# Trap block to execute cleanup on script exit & Register the script exit event
$ScriptExitHandler = { Cleanup }
$null = Register-EngineEvent -SourceIdentifier ScriptExit -Action { Cleanup }

$main = Create-Window 600 500 "LockOut $version" "LockOut"
Add-DefaultMenus $main
$TabControlList = New-Object System.Collections.Generic.List[System.Windows.Forms.Control]
$OtherUserTabControlList = New-Object System.Collections.Generic.List[System.Windows.Forms.Control]
$tabControls =  Setup-Tabs -TabID "MainTabs" -TabNames ('HKEY_USER','HKEY_LOCAL_MACHINE','Browsers','AutoLogin') -TabParent $main -ybuffer 65 -xbuffer 14
$tab_0_Controls = Setup-Tabs -TabID "UserTabs" -TabNames ('System','StartMenu','TaskBar','Browsers','Explorer','Desktop','DisallowRun','Other') -TabParent $tabControls.TabPages[0] -ybuffer 45 -xbuffer 7 -SizeRefCtrl $tabControls -xBuff 25
$tab_2_Controls = Setup-Tabs -TabID "BrowserTabs" -TabNames ('Edge', 'Chrome') -TabParent $tabControls.TabPages[2] -ybuffer 0 -xbuffer 7 -SizeRefCtrl $tabControls -xBuff 21
$CompNameBox = Add-TextBox 65 30 150 "hostName" $main "Localhost" "Host:"
$host_name = Add-Text -text "LocalHost" -label "Host" -x 280 -y 28 -font_size 9 -width 200 -main_form $main
$host_IP = Add-Text -text "127.0.0.1" -label "IP" -x 280 -y 41 -font_size 9 -width 200 -main_form $main
$host_model = Add-Text -text "Computer" -label "Model" -x 280 -y 54 -font_size 9 -width 200 -main_form $main


$progBar = Add-ProgressBar -Progress 0 -width 150 -y 53 -x 300 -main_form $main -height 12 -cName "HostLoad"
$progBar.Visible = $false
$compNameBox.Add_Leave({
    $currentText = $compNameBox.Text
    $previousText = $compNameBox.Tag
    if ($currentText -ne $previousText) {
        Pull-Host
    }
})
$compNameBox.Add_KeyUp({
    $keyCode = $_.KeyCode
    if (($keyCode -eq [System.Windows.Forms.Keys]::Enter) -and ($compNameBox.Text.ToUpper() -ne $compNameBox.Tag)) {
        if ($compNameBox.Text.ToUpper() -ne "LOCALHOST"){
            $compNameBox.Text = $compNameBox.Text.ToUpper()
        }
        Pull-Host
    }
})
$CompNameBox.Add_TextChanged{
    $currentText = $compNameBox.Text
    $previousText = $compNameBox.Tag
    if ($currentText -eq $previousText) {
        $compNameBox.BackColor = [System.Drawing.Color]::LightGreen
    }else{
        $compNameBox.BackColor = [System.Drawing.SystemColors]::Window
    }
}
# Create Lists to store control variables
$RegControlList = New-Object System.Collections.Generic.List[System.Windows.Forms.Control]
$RegCheckList = New-Object System.Collections.Generic.List[System.Windows.Forms.Control]
$RegEntryList = New-Object System.Collections.Generic.List[System.Windows.Forms.Control]

#################################
#                               #
#       Tab Page Details        #
#                               #
#################################

#################
# LOCAL_MACHINE #
#################

    $SrchTaskStart1_box = make-CheckBox 10 10 150 "SrchTaskStart1" "Disable Search on Start or Taskbar (1) [Win11]" "[disable_search]:Dword:value" $tabControls.TabPages[1]
    $SrchTaskStart2_box = make-CheckBox 10 30 150 "SrchTaskStart2" "Disable Search on Start or Taskbar (2) [Win11]" "[search]:Dword:DisableSearch" $tabControls.TabPages[1]
    $startRecmmdt_box = make-CheckBox 10 50 150 "startRecmmd" "Disable Start Menu 'Recommended' section [Win11]" "[local_explorer]:Dword:HideRecommendedSection" $tabControls.TabPages[1]
    $tskwidget_box = make-CheckBox 10 70 150 "tskwidget" "Disable Taskbar widgetsr [Win11]" "[dsh]:Dword:AllowNewsAndInterests{1|0}" $tabControls.TabPages[1]
    $DisableControlCenter_box = make-CheckBox 10 90 150 "DisableControlCenter" "Disable System Tray 'Control Center' [Win11]" "[local_explorer]:Dword:DisableControlCenter" $tabControls.TabPages[1]
    $TaskbarNoPinnedList_box = make-CheckBox 10 110 150 "TaskbarNoPinnedList" "Disable TaskBar Pinned Icons [Win11]" "[local_explorer]:Dword:TaskbarNoPinnedList" $tabControls.TabPages[1]

##############
# System Tab #
##############
    $SysTaskMgr_box = make-UserCheck 10 5 "SysTaskMgrBox" "Disable TaskMgr" "[system]:Dword:DisableTaskMgr" $tab_0_Controls.TabPages[0]
    $SysLockWorkstation_box = make-UserCheck 30 5 "SysLockWorkstationBox" "Disable Lock Workstation" "[system]:Dword:DisableLockWorkstation" $tab_0_Controls.TabPages[0]
    $SysChangePassword_box = make-UserCheck 50 5 "SysChangePasswordBox" "Disable Change Password" "[system]:Dword:DisableChangePassword" $tab_0_Controls.TabPages[0]
    $SysRegEdit_box = make-UserCheck 70 5 "SysRegEditBox" "Disable Registry Tools (Regedit)" "[system]:Dword:DisableRegistryTools{2|0}" $tab_0_Controls.TabPages[0]
    $noCP_box = make-UserCheck 90 5 "NoControlPanelBox" "No ControlPanel" "[explorer]:Dword:NoControlPanel" $tab_0_Controls.TabPages[0]
    $noRun_box = make-UserCheck 110 5 "NoRunBox" "Disable Run box" "[explorer]:Dword:NoRun" $tab_0_Controls.TabPages[0]
    $noCMD_box = make-UserCheck 130 5 "DisableCMDBox" "Disable CMD" "[pol_sys]:Dword:DisableCMD{2|0}" $tab_0_Controls.TabPages[0]
    $noPower_box = make-UserCheck 150 5 "NoClose" "No Shutdown/Restart" "[explorer]:Dword:NoClose" $tab_0_Controls.TabPages[0]
    $noLock_box = make-UserCheck 170 5 "DisableLockBox" "Disable Lock Windows" "[system]:Dword:DisableLockWorkstation" $tab_0_Controls.TabPages[0]
    $noAC_box = make-UserCheck 190 5 "DisableActionCenter" "Disable Action Center" "[explorer]:Dword:DisableActionCenter" $tab_0_Controls.TabPages[0]
    $noNC_box = make-UserCheck 210 5 "NoNetworkConnections" "No Network Connections" "[explorer]:Dword:NoNetworkConnections" $tab_0_Controls.TabPages[0]
    $noAutoRun_box = make-UserCheck 230 5 "NoDriveTypeAutoRun" "Disable Autorun/Autoplay" "[explorer]:Dword:NoDriveTypeAutoRun" $tab_0_Controls.TabPages[0]
    $NeverSleeps_box = make-UserGroupCheck 250 5 $(pop_NeverSleep) $tab_0_Controls.TabPages[0]
    $noWindowsUpdate_box = make-UserCheck 270 5 "NoWindowsUpdate" "Disable Windows Update" "[explorer]:Dword:NoWindowsUpdate" $tab_0_Controls.TabPages[0]
    $TurnOffWinCal_box = make-UserCheck 290 5 "TurnOffWinCal" "Disable Windows Calendar" "[explorer]:Dword:TurnOffWinCal" $tab_0_Controls.TabPages[0]
    $NoWelcomeScreen_box = make-UserCheck 310 5 "NoWelcomeScreen" "Disable the Welcome Screen for new users" "[explorer]:Dword:NoWelcomeScreen" $tab_0_Controls.TabPages[0]
    $NoViewContextMenu_box = make-UserCheck 330 5 "NoViewContextMenu" "Disable Right-Click Menu" "[explorer]:Dword:NoViewContextMenu" $tab_0_Controls.TabPages[0]


#################
# StartMenu Tab #
#################
    $NoSaveSettings_box = make-UserCheck 10 5 "NoSaveSettingsBox" "No Save Settings" "[explorer]:Dword:NoSaveSettings" $tab_0_Controls.TabPages[1]
    $NoChangeSM_box = make-UserCheck 30 5 "NoChangeSMBox" "No ChangeStartMenu" "[explorer]:Dword:NoChangeStartMenu" $tab_0_Controls.TabPages[1]
    $NoSMPinned_box = make-UserCheck 50 5 "NoSMPinnedBox" "No StartMenu PinnedList" "[explorer]:Dword:NoStartMenuPinnedList" $tab_0_Controls.TabPages[1]
    $NoSMMorePrograms_box = make-UserCheck 70 5 "NoSMMoreProgramsBox" "No StartMenu MorePrograms" "[explorer]:Dword:NoStartMenuMorePrograms" $tab_0_Controls.TabPages[1]
    $NoSMMFUPList_box = make-UserCheck 90 5 "NoSMMFUPListBox" "No StartMenu MFUprogramsList" "[explorer]:Dword:NoStartMenuMFUprogramsList" $tab_0_Controls.TabPages[1]
    $NoSMSubfolders_box = make-UserCheck 110 5 "NoSMSubfoldersBox" "No StartMenu SubFolders" "[explorer]:Dword:NoStartMenuSubFolders" $tab_0_Controls.TabPages[1]
    $NoCommonGroups_box = make-UserCheck 130 5 "NoCommonGroupsBox" "No Common Groups" "[explorer]:Dword:NoCommonGroups" $tab_0_Controls.TabPages[1]
    $noLogoff_box = make-UserCheck 150 5 "NoLogoff" "No User Logoff" "[explorer]:Dword:NoLogoff{1|0}" $tab_0_Controls.TabPages[1]
    $noLogoff2_box = make-UserCheck 170 5 "NoLogoff" "No User Logoff [Alternative]" "[explorer]:Dword:StartMenuLogOff{1|0}" $tab_0_Controls.TabPages[1]
    $nosetFolder_box = make-UserCheck 190 5 "NoSetFolders" "No Settings Folder/Icons" "[explorer]:Dword:NoSetFolders{1|0}" $tab_0_Controls.TabPages[1]
    $clearRecentDocsOnExit_box = make-UserCheck 210 5 "ClearRecentDocsOnExit" "Clear Recent Documents list on Reboot" "[explorer]:Dword:ClearRecentDocsOnExit{1|0}" $tab_0_Controls.TabPages[1]
    #$noSettingDoc_box = make-UserCheck 150 5 "NoSettingDoc" "no 'Setting'/'Documents'" "[sm_data]:Hex:data{02 00 00 00 83 0d 46 6b 81 7c d9 01 00 00 00 00 43 42 01 00 c2 3c 01 c2 46 01 c5 5a 01 00|0}" $tab_0_Controls.TabPages[1]
    

    $SearchStartMenu = make-UserGroupCheck 230 5 $(pop_StartMenuSearch) $tab_0_Controls.TabPages[1]
    $ExtrasStartMenu = make-UserGroupCheck 250 5 $(pop_StartMenuExtras) $tab_0_Controls.TabPages[1]
    $PlacesStartMenu = make-UserGroupCheck 270 5 $(pop_StartMenuPlaces) $tab_0_Controls.TabPages[1]
#################
#  TaskBar Tab  #
#################
    $CustomTaskbarBox = make-UserGroupCheck 10 5 $(pop_CustomTaskbar) $tab_0_Controls.TabPages[2]
    $LockTaskbar_box = make-UserCheck 30 5 "LockTaskbar" "Lock Taskbar Position" "[explorer]:Dword:LockTaskbar" $tab_0_Controls.TabPages[2]
    $LockAllTaskbar_box = make-UserCheck 50 5 "LockAllTaskbars" "Lock All Taskbars In Place" "[explorer]:Dword:TaskbarLockAll" $tab_0_Controls.TabPages[2]
    $TaskbarNoResize_box = make-UserCheck 70 5 "TaskbarNoResize" "Taskbar No Resize" "[explorer]:Dword:TaskbarNoResize" $tab_0_Controls.TabPages[2]
    $NoTrayClock_box = make-UserCheck 90 5 "HideClock" "Hide SystemTray Clock" "[explorer]:Dword:HideClock" $tab_0_Controls.TabPages[2]
    $NoTrayItemsDisplay_box = make-UserCheck 110 5 "NoTrayItemsDisplay" "NoTrayItemsDisplay" "[explorer]:Dword:NoTrayItemsDisplay" $tab_0_Controls.TabPages[2]
    $NoRightClickTray_box = make-UserCheck 130 5 "NoTrayContextMenu" "No System Tray (Right-Click) Context Menu" "[explorer]:Dword:NoTrayContextMenu" $tab_0_Controls.TabPages[2]
    $NoCopilot_box = make-UserCheck 150 5 "NoCoPilot" "No Copilot on Taskbar [Win11]" "[copilot]:Dword:TurnOffWindowsCopilot" $tab_0_Controls.TabPages[2]
    $DisableControlCenterUser_box = make-UserCheck 170 5 "DisableControlCenter" "Disable System Tray 'Control Center' [Win11]" "[explorer]:Dword:DisableControlCenter" $tab_0_Controls.TabPages[2]
    $TaskbarNoPinnedListUser_box = make-UserCheck 190 5 "TaskbarNoPinnedList" "Disable TaskBar Pinned Icons [Win11]" "[explorer]:Dword:TaskbarNoPinnedList" $tab_0_Controls.TabPages[2]
    $DisableNotificationCenter_box = make-UserCheck 210 5 "DisableNotificationCenter" "Disable Notification Center [Win11]" "[explorer]:Dword:DisableNotificationCenter" $tab_0_Controls.TabPages[2]
    $NoSystraySystemPromotion_box = make-UserCheck 230 5 "NoSystraySystemPromotion" "Disable System Tray Icon Promotion [Win11]" "[explorer]:Dword:NoSystraySystemPromotion" $tab_0_Controls.TabPages[2]
    

#####################
#  UserBrowser Tab  #
#####################

    $noIEPassCache_box = make-UserCheck 10 5 "DisablePasswordCaching" "Disable IE Password Caching" "[int_exp_cv]:Dword:DisablePasswordCaching" $tab_0_Controls.TabPages[3]
    $noIEFormSugPass1_box = make-UserCheck 30 5 "DisableFormSuggestPasswords1" "Disable IE FormSuggest Passwords (#1)" "[int_exp_main]:String:FormSuggest Passwords{no|yes}" $tab_0_Controls.TabPages[3]
    $noIEFormSugPWAsk_box = make-UserCheck 50 5 "DisableFormSuggestPWAsk" "Disable IE FormSuggest PW Ask" "[int_exp_main]:String:FormSuggest PW Ask{no|yes}" $tab_0_Controls.TabPages[3]
    $noIEFormSugPass2_box = make-UserCheck 70 5 "DisableFormSuggestPasswords2" "Disable IE FormSuggest Passwords (#2)" "[int_exp_cp]:Dword:FormSuggest Passwords{1|0}" $tab_0_Controls.TabPages[3]
    $noIEFormSugPass2_box = make-UserCheck 90 5 "RestrictToList" "Restrict IE Addings to listed" "[policies]\Ext:Dword:RestrictToList{1|0}" $tab_0_Controls.TabPages[3]
    #$noIEAutoComp_box = make-UserCheck 30 5 "DisableAutoComplete" "Disable IE AutoComplete" "[int_exp]:String:AutoComplete" $tab_0_Controls.TabPages[3]
    
##################
#  Explorer Tab  #
##################

    $MediaButtons_box = make-UserGroupCheck 10 5 $(pop_MediaButtons) $tab_0_Controls.TabPages[4]
    $noRecentDocHistory_box = make-UserCheck 30 5 "NoRecentDocsHistory" "Disable Recent Documetn History" "[explorer]:Dword:NoRecentDocsHistory{1|0}" $tab_0_Controls.TabPages[4]
    $noResolveSearch_box = make-UserCheck 50 5 "NoResolveSearch" "Disable Search-Based Shortcut Resolution" "[explorer]:Dword:NoResolveSearch{1|0}" $tab_0_Controls.TabPages[4]
    $noResolveTrack_box = make-UserCheck 70 5 "NoResolveTrack" "Disable Tracking-Based Shortcut Resolution" "[explorer]:Dword:NoResolveTrack{1|0}" $tab_0_Controls.TabPages[4]
    $noPropertiesMyDocuments_box = make-UserCheck 90 5 "NoPropertiesMyDocuments" "Disable My Documents" "[explorer]:Dword:NoPropertiesMyDocuments{1|0}" $tab_0_Controls.TabPages[4]
    $noPropertiesMyComputer_box = make-UserCheck 110 5 "NoPropertiesMyComputer" "Disable My Computer" "[explorer]:Dword:NoPropertiesMyComputer{1|0}" $tab_0_Controls.TabPages[4]
    $noPropertiesRecycleBin_box = make-UserCheck 130 5 "NoPropertiesRecycleBin" "Disable Recycling Bin" "[explorer]:Dword:NoPropertiesRecycleBin{1|0}" $tab_0_Controls.TabPages[4]
    $DisablePersonalDirChange_box = make-UserCheck 150 5 "DisablePersonalDirChange" "Disable Personal folder redirects ('Documents','Music','Pictures'...)" "[explorer]:Dword:DisablePersonalDirChange{1|0}" $tab_0_Controls.TabPages[4]
    $HideViewDrives_box = make-UserCheck 170 5 "NoDrives" "Hide All drives in File Explorer" "[explorer]:Dword:NoDrives{03ffffff|0}" $tab_0_Controls.TabPages[4]
    $DisableViewDrives_box = make-UserCheck 190 5 "NoViewOnDrive" "Disables All drives in File Explorer" "[explorer]:Dword:NoViewOnDrive{03ffffff|0}" $tab_0_Controls.TabPages[4]
    $NoInplaceSharings_box = make-UserCheck 210 5 "NoInplaceSharing" "Disables InPlace File Sharing in File Explorer" "[explorer]:Dword:NoInplaceSharing{1|0}" $tab_0_Controls.TabPages[4]
    #NoNetHood

   #$HexCheck_box = make-UserCheck 30 5 "HexPolicy" "TestHexAdd" "[cp_power]:Hex:Policies{01 00 00 00 02 00 00 00 01 00 00 00 00 00 00 00 02 00 00 00 00|00}" $tab_0_Controls.TabPages[4]
    
##################
#  Desktop Tab  #
##################

    $noInternetIcon_box = make-UserCheck 10 5 "NoInternetIcon" "Disable Internet Explorer Icon on the Desktop" "[explorer]:Dword:NoInternetIcon{1|0}" $tab_0_Controls.TabPages[5]
    $noNetHood_box = make-UserCheck 30 5 "NoNetHood" "Disable Network Neighborhood" "[explorer]:Dword:NoNetHood{1|0}" $tab_0_Controls.TabPages[5]
    $noRecentDocsNetHood_box = make-UserCheck 50 5 "NoNetHood" "Disable Recently opened documents in the Network Neighborhood." "[explorer]:Dword:NoRecentDocsNetHood{1|0}" $tab_0_Controls.TabPages[5]
    $noNetHood_box = make-UserCheck 70 5 "NoNetHood" "Disable Network Neighborhood" "[explorer]:Dword:NoNetHood{1|0}" $tab_0_Controls.TabPages[5]
        
#####################
#  DisallowRun Tab  #
#####################

    $noRunPrg_box = make-UserCheck 10 5 "DisallowRunBox" "Disallow Runing of specific programs" "[explorer]:Dword:DisallowRun" $tab_0_Controls.TabPages[6]
    
    $DisallowRunList = Make-AppList -y 60 -x 10 -form $tab_0_Controls.TabPages[6]

    
###############
#  Other Tab  #
###############
    
    $radioButtons = (("SearchTaskbarMode0", "None", "0", 10, 15, 50),("SearchTaskbarMode1", "Icon", "1", 110, 15, 50),("SearchTaskbarMode2", "Box", "2", 210, 15, 50),("SearchTaskbarMode3", "Button", "3", 310, 15, 50))
    $SearchTaskbarModeGrp = Make-RadioGroup -groupTitle "Taskbar Search Mode" -regpath "[searchPol]:Dword:SearchboxTaskbarMode" -x 10 -y 10 -height 39 -width 425 -buttonArr $radioButtons -main_form $tab_0_Controls.TabPages[7]
    $TraySearchBoxVisible_box = make-UserCheck 60 5 "TraySearchBoxVisible" "Disable Taskbar Search Box" "[searchPol]:Dword:TraySearchBoxVisible{1|0}" $tab_0_Controls.TabPages[7]
    $TraySearchBoxVisibleOnAnyMonitor_box = make-UserCheck 80 5 "TraySearchBoxVisibleOnAnyMonitor" "Disable Taskbar Search Box (On Any Monitor)" "[searchPol]:Dword:TraySearchBoxVisibleOnAnyMonitor{1|0}" $tab_0_Controls.TabPages[7]
    $TraySearchBoxIsAssignedAccess_box = make-UserCheck 100 5 "TraySearchBoxIsAssignedAccess" "Taskbar Search 'IsAssignedAccess' (Function unknown)" "[searchPol]:Dword:IsAssignedAccess{1|0}" $tab_0_Controls.TabPages[7]
    $CortanaLastStateRun_box = make-UserCheck 120 5 "CortanaStateLastRun" "CortanaStateLastRun" "[searchPol]:HEX:CortanaStateLastRun{57 c1 45 64 00 00 00 00|00}" $tab_0_Controls.TabPages[7]
    $SaveZoneInformation_box = make-UserCheck 140 5 "SaveZoneInformation" "Do not preserve zone information in file attachments" "[policies]\Attachments:Dword:SaveZoneInformation{1|2}" $tab_0_Controls.TabPages[7]
    $ScanWithAntiVirus_box = make-UserCheck 160 5 "ScanWithAntiVirus" "Notify antivirus programs when opening attachments" "[policies]\Attachments:Dword:ScanWithAntiVirus{3|1}" $tab_0_Controls.TabPages[7]

   # $SearchTaskbarModeGrp.Controls | ForEach-Object{ $_.GetType().ToString() }
##################
#  End User Tab  #
##################

Clear-Panel

# Create a dropdown list
$dropdown = Make-comboList 457 10 10 20 $tabControls.TabPages[0] -mono
$tabUTitle = [System.Windows.Forms.Label]@{
                Text = 'User Profile:'
                Top = 5
                Left = 10 }
$tabControls.TabPages[0].Controls.Add($tabUTitle)
$dropdown.Add_SelectedIndexChanged({ dropdown-change })


#########################
# Edge Browser Settings #
#########################
    $allowEdgeList = Make-SiteList "allow" "Edge" $tab_2_Controls.TabPages[0] -x 10
    $BlockEdgeList = Make-SiteList "block" "Edge" $tab_2_Controls.TabPages[0] -x 250

    $EdgeHomePage_box = make-TextBox 95 $blockEdgeList 360 "EdgeHomePage" "Homepage" "HKLM:\[edge_pol]:String:NewTabPageLocation" $tab_2_Controls.TabPages[0] -drop 25 -EnableToolTip
    Write-Warning $EdgeHomePage_box.tag
    $EdgeSideBar_box = make-CheckBox 75 $EdgeHomePage_box 100 "EdgeDisableSidebar" "Disable SideBar" "HKLM:\[edge_pol]:Dword:HubsSidebarEnabled{0|1}" $tab_2_Controls.TabPages[0]

    $EdgeDisablePass_box = make-CheckBox 75 $EdgeSideBar_box 100 "PasswordManagerEnabled" "Password Manager Disabled" "HKLM:\[edge_pol]:Dword:PasswordManagerEnabled{0|1}" $tab_2_Controls.TabPages[0] -drop 0
    $EdgeDisablePassReveal_box = make-CheckBox 75 $EdgeDisablePass_box 100 "PasswordRevealEnabled" "Password Reveal Disabled" "HKLM:\[edge_pol]:Dword:PasswordRevealEnabled{0|1}" $tab_2_Controls.TabPages[0] -drop 0

###########################
# Chrome Browser Settings #
###########################

    $allowChromeList = Make-SiteList "allow" "Chrome" $tab_2_Controls.TabPages[1] -x 10
    $BlockChromeList = Make-SiteList "block" "Chrome" $tab_2_Controls.TabPages[1] -x 250

    $ChromeHomePage_box = make-TextBox 95 $blockChromeList 360 "ChromeHomePage" "Homepage" "HKLM:\[chrome_pol]:String:NewTabPageLocation" $tab_2_Controls.TabPages[1] -drop 25

###############
# Auto Log In #
###############
    $LoginAuto_box = make-CheckBox 200 10 250 "Login_Auto" "AutoAdminLogOn" "[winlogon]:String:AutoAdminLogon" $tabControls.TabPages[3]
    $LoginUserDomain_box = make-TextBox 200 35 250 "Login_Domainname" "DefaultDomainName" "[winlogon]:String:DefaultDomainName" $tabControls.TabPages[3]
    $LoginUserName_box = make-TextBox 200 65 250 "Login_Username" "DefaultUserName" "[winlogon]:String:DefaultUserName" $tabControls.TabPages[3]
    $LoginUserPass_box = make-TextBox 200 95 250 "Login_UserPass" "DefaultPassword" "[winlogon]:String:DefaultPassword" $tabControls.TabPages[3] -PasswordChar '*'

    $LoginShowPass_box = Add-OptionBox 200 120 250 "Login_ShowPass" "Show Password" $tabControls.TabPages[3] "Check"
    $LoginShowPass_box.Add_MouseClick({
        if ($LoginShowPass_box.Checked){
            $LoginUserPass_box.PasswordChar = $null
        }else{
            $LoginUserPass_box.PasswordChar = "*"
        }
    })
   
Pull-Host

$isUserInteraction = $true

$tabControls.SelectTab(0)
# Show the form
#$main.ShowDialog()
[system.windows.forms.application]::run($main)

New-Event -SourceIdentifier ScriptExit | Out-Null



function dummy_Debug_Details{
#write-debug "TestFile"
#Write-Verbose "Verbose Message"
#Write-Warning "Warn Message"
#Write-Error "Error Meessage"
# Inquire:           [Pause]   Asks whether to continue after each Write-Debug statement
# Continue:         [Display]  Outputs Write-Debug messages to the console.
# SilentlyContinue: [Ignore]*  Writes Write-Debug messages but doesn't display them in the console.
# Stop:              [Fatal]   Stops the script on the first Write-Debug statement encountered.

}
