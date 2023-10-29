#################################
#           LockOut             #
#      File: Main Runtime       #
#        By Scott Lyon          #
        $Version = "v1.7.1"     #
#          Oct 26,2023          #
#################################
[void][System.Reflection.Assembly]::LoadWithPartialName("System")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")


#########################
# Base Paths & Includes #
#########################
    #$Script:BasePathMode = $true
     $Script:BasePathMode = $false

. "$PSScriptRoot\funcCommon.ps1"      # v1.1
. "$PSScriptRoot\funcRegistry.ps1"    # v1.4
. "$PSScriptRoot\funcMainWindow.ps1"  # v1.3
. "$PSScriptRoot\funcForms.ps1"       # v1.1
. "$PSScriptRoot\runtimeFunc.ps1"     # v1.5.1
. "$PSScriptRoot\runtimePaths.ps1"    # v1.6

###############################
# App Launch Sequence Initate #
###############################

#$DebugPreference, $VerbosePreference = "Continue", "SilentlyContinue"
$DebugPreference, $VerbosePreference, $InformationPreference = "SilentlyContinue", "SilentlyContinue", "SilentlyContinue"
# Initialize a variable to track user interaction
$isUserInteraction = $false
$AboutInfo = @{ Title = "LockOut"; Author = "Scott Lyon"; Description = "Lockdown Kisok or Public access consoles"; Version = $Version; Icon = "" }
    
# Trap block to execute cleanup on script exit & Register the script exit event
$ScriptExitHandler = { Cleanup }
$null = Register-EngineEvent -SourceIdentifier ScriptExit -Action { Cleanup }

$main = Create-Window 500 500 "LockOut $version" "LockOut"
Add-DefaultMenus $main
$TabControlList = New-Object System.Collections.Generic.List[System.Windows.Forms.Control]
$tabControls =  Setup-Tabs -TabID "MainTabs" -TabNames ('HKEY_USER','HKEY_LOCAL_MACHINE','Browsers','AutoLogin') -TabParent $main -ybuffer 65 -xbuffer 14
$tab_0_Controls = Setup-Tabs -TabID "UserTabs" -TabNames ('System','StartMenu','TaskBar','Browsers','Explorer') -TabParent $tabControls.TabPages[0] -ybuffer 45 -xbuffer 7 -SizeRefCtrl $tabControls -xBuff 25
$tab_2_Controls = Setup-Tabs -TabID "BrowserTabs" -TabNames ('Edge', 'Chrome') -TabParent $tabControls.TabPages[2] -ybuffer 0 -xbuffer 7 -SizeRefCtrl $tabControls -xBuff 21
$CompNameBox = Add-TextBox 300 30 150 "hostName" $main "Localhost" "HostName:"
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

##############
# System Tab #
##############
    $SysTaskMgr_box = make-UserCheck 10 5 "SysTaskMgrBox" "Disable TaskMgr" "[system]:Dword:DisableTaskMgr" $tab_0_Controls.TabPages[0]
    $SysLockWorkstation_box = make-UserCheck 30 5 "SysLockWorkstationBox" "Disable Lock Workstation" "[system]:Dword:DisableLockWorkstation" $tab_0_Controls.TabPages[0]
    $SysChangePassword_box = make-UserCheck 50 5 "SysChangePasswordBox" "Disable Change Password" "[system]:Dword:DisableChangePassword" $tab_0_Controls.TabPages[0]
    $SysRegEdit_box = make-UserCheck 70 5 "SysRegEditBox" "Disable Registry Tools (Regedit)" "[system]:Dword:DisableRegistryTools{2|0}" $tab_0_Controls.TabPages[0]
    $noCP_box = make-UserCheck 90 5 "NoControlPanelBox" "No ControlPanel" "[explorer]:Dword:NoControlPanel" $tab_0_Controls.TabPages[0]
    $noRun_box = make-UserCheck 110 5 "DisallowRunBox" "Disallow Run" "[explorer]:Dword:DisallowRun" $tab_0_Controls.TabPages[0]
    $noCMD_box = make-UserCheck 130 5 "DisableCMDBox" "Disable CMD" "[pol_sys]:Dword:DisableCMD{2|0}" $tab_0_Controls.TabPages[0]
    $noPower_box = make-UserCheck 150 5 "NoClose" "No Shutdown/Restart" "[explorer]:Dword:NoClose" $tab_0_Controls.TabPages[0]
    $noLock_box = make-UserCheck 170 5 "DisableLockBox" "Disable Lock Windows" "[system]:Dword:DisableLockWorkstation" $tab_0_Controls.TabPages[0]
    $noAC_box = make-UserCheck 190 5 "DisableActionCenter" "Disable Action Center" "[explorer]:Dword:DisableActionCenter" $tab_0_Controls.TabPages[0]
    $noNC_box = make-UserCheck 210 5 "NoNetworkConnections" "No Network Connections" "[explorer]:Dword:NoNetworkConnections" $tab_0_Controls.TabPages[0]
    $NeverSleeps_box = make-UserGroupCheck 230 5 $(pop_NeverSleep) $tab_0_Controls.TabPages[0]
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
    #$noSettingDoc_box = make-UserCheck 150 5 "NoSettingDoc" "no 'Setting'/'Documents'" "[sm_data]:Hex:data{02 00 00 00 83 0d 46 6b 81 7c d9 01 00 00 00 00 43 42 01 00 c2 3c 01 c2 46 01 c5 5a 01 00|0}" $tab_0_Controls.TabPages[1]
    

    $SearchStartMenu = make-UserGroupCheck 190 5 $(pop_StartMenuSearch) $tab_0_Controls.TabPages[1]
    $ExtrasStartMenu = make-UserGroupCheck 210 5 $(pop_StartMenuExtras) $tab_0_Controls.TabPages[1]
    $PlacesStartMenu = make-UserGroupCheck 230 5 $(pop_StartMenuPlaces) $tab_0_Controls.TabPages[1]
#################
#  TaskBar Tab  #
#################
    $CustomTaskbarBox = make-UserGroupCheck 10 5 $(pop_CustomTaskbar) $tab_0_Controls.TabPages[2]
    $LockTaskbar_box = make-UserCheck 30 5 "LockTaskbar" "Lock Taskbar Position" "[explorer]:Dword:LockTaskbar" $tab_0_Controls.TabPages[2]
    $LockAllTaskbar_box = make-UserCheck 50 5 "LockAllTaskbars" "Lock All Taskbars In Place" "[explorer]:Dword:TaskbarLockAll" $tab_0_Controls.TabPages[2]
    $TaskbarNoResize_box = make-UserCheck 70 5 "TaskbarNoResize" "Taskbar No Resize" "[explorer]:Dword:TaskbarNoResize" $tab_0_Controls.TabPages[2]
    $NoTrayClock_box = make-UserCheck 90 5 "HideClock" "Hide SystemTray Clock" "[explorer]:Dword:HideClock" $tab_0_Controls.TabPages[2]
    $NoTrayItemsDisplay_box = make-UserCheck 110 5 "NoTrayItemsDisplay" "NoTrayItemsDisplay" "[explorer]:Dword:NoTrayItemsDisplay" $tab_0_Controls.TabPages[2]
    $NoRightClickTray_box = make-UserCheck 130 5 "NoTrayContextMenur" "No System Tray (Right-Click) Context Menu" "[explorer]:Dword:NoTrayContextMenu" $tab_0_Controls.TabPages[2]
    

#####################
#  UserBrowser Tab  #
#####################

    $noIEPassCache_box = make-UserCheck 10 5 "DisablePasswordCaching" "Disable IE Password Caching" "[int_exp_cv]:Dword:DisablePasswordCaching" $tab_0_Controls.TabPages[3]
    $noIEFormSugPass1_box = make-UserCheck 30 5 "DisableFormSuggestPasswords1" "Disable IE FormSuggest Passwords (#1)" "[int_exp_main]:String:FormSuggest Passwords{no|yes}" $tab_0_Controls.TabPages[3]
    $noIEFormSugPWAsk_box = make-UserCheck 50 5 "DisableFormSuggestPWAsk" "Disable IE FormSuggest PW Ask" "[int_exp_main]:String:FormSuggest PW Ask{no|yes}" $tab_0_Controls.TabPages[3]
    $noIEFormSugPass2_box = make-UserCheck 70 5 "DisableFormSuggestPasswords2" "Disable IE FormSuggest Passwords (#2)" "[int_exp_cp]:Dword:FormSuggest Passwords{1|0}" $tab_0_Controls.TabPages[3]
    #$noIEAutoComp_box = make-UserCheck 30 5 "DisableAutoComplete" "Disable IE AutoComplete" "[int_exp]:String:AutoComplete" $tab_0_Controls.TabPages[3]
    
##################
#  Explorer Tab  #
##################

    $MediaButtons_box = make-UserGroupCheck 10 5 $(pop_MediaButtons) $tab_0_Controls.TabPages[4]
   #$HexCheck_box = make-UserCheck 30 5 "HexPolicy" "TestHexAdd" "[cp_power]:Hex:Policies{01 00 00 00 02 00 00 00 01 00 00 00 00 00 00 00 02 00 00 00 00|00}" $tab_0_Controls.TabPages[4]
    
   

##################
#  End User Tab  #
##################

Clear-Panel

# Create a dropdown list
$dropdown = Make-comboList 457 10 10 20 $tabControls.TabPages[0]
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

    $EdgeHomePage_box = make-TextBox 95 $blockEdgeList 360 "EdgeHomePage" "Homepage" "HKLM:\[edge_pol]:String:NewTabPageLocation" $tab_2_Controls.TabPages[0] -drop 25
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
$main.ShowDialog()

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