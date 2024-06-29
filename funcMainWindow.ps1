#################################
#           LockOut             #
#      File: funcMainWindow     #
#        By Scott Lyon          #
#         SubVer:  v1.5         #
#          Feb 09,2024          #
#################################
Function Create-Window{
    param($height=400, $width=600, $title = "New Window", $bannerTxt = "Default", $StartPosition = "CenterScreen")
    $main_form = New-Object System.Windows.Forms.Form
    $main_form = Add-Ident -obj $main_form -uniqueID "MainForm"
    $main_form.Text = $title
    $main_form.Width = $width
    $main_form.Height = $height
    $main_form.AutoSize = $false
    $main_form.Icon = [System.Drawing.Icon]::FromHandle($(Set-Icon -InputFile $AboutInfo.Icon).GetHicon())

    $main_form.StartPosition = $StartPosition
    $main_form.KeyPreview = $true
    # KeyDown 'Esc' to Exit event handler
    $main_form.Add_KeyDown({ param($sender, $e) if ($e.KeyCode -eq 'Escape') {ExitApp} })
    $resizeGrip = Add-ResizeButton $main_form
    $main_form.Add_Resize({ param($sender, $e) 
        Foreach($TabControl in $TabControlList){
            Size-Tabs $TabControl
             }
    })
    #$Banner = New-Object System.Windows.Forms.Label
    #$Banner.Text = $bannerTxt
    #$Banner.Location  = New-Object System.Drawing.Point(10,30)
    #$Banner.Font = New-Object System.Drawing.Font("Lucida Console",20,[System.Drawing.FontStyle]::Bold)
    #$Banner.AutoSize = $true
    $main_form.Controls.Add($Banner)
    return  $main_form
}
Function Size-Tabs{
    param($inObj)
    #Tag = ($tabParentUID, $SizeRefCtrlUID, $xbuffer, $ybuffer)
    $break = $false
    $SizeRefCtrl = Find-Control $inObj.Tag[1]
    $width = $SizeRefCtrl.width - $inObj.Tag[2]
    $height = $SizeRefCtrl.height - $inObj.Tag[3]
    $(Find-Control $inObj.Tag[0]).Controls | ForEach-Object{
        if ($_.GettYpe().Name -eq 'MenuStrip' -and $break -eq $false){
            $height -= $_.height + 14
            $break = $true
        }
    }
    if( $break -eq $false){ $height -= 25 }
    $inObj.Location = New-Object System.Drawing.Point(0, $inObj.Tag[3])
    $inObj.Size = New-Object System.Drawing.Size($width, $height)  # Adjust the height
    return $inObj

}
Function Setup-Tabs{
    param($TabNames, $TabParent, $ybuffer = 65, $xbuffer = 0, $SizeRefCtrl = $TabParent, $xBuff = 0, $TabID = $null)
    if ($TabParent.GetType().Name -eq "TabPage"){ $tabParentUID = "$($TabParent.Parent.UID)" }else{ $tabParentUID = "$($TabParent.UID)" }
    if ($SizeRefCtrl.GetType().Name -eq "TabPage"){ $SizeRefCtrlUID = "$($SizeRefCtrl.Parent.UID)" }else{ $SizeRefCtrlUID = "$($SizeRefCtrl.UID)" }
    $tabControl = New-Object System.Windows.Forms.TabControl
    $tabControl = Add-Ident -obj $tabControl -uniqueID $TabID
    $tabControl.Tag = ($tabParentUID, $SizeRefCtrlUID, $xbuffer, $ybuffer)
    $tabControl = Size-Tabs $tabControl
    foreach($tab in $TabNames){
        $tabItem = New-Object System.Windows.Forms.TabPage
        $tabItem.Text = $tab
        $tabControl.TabPages.Add($tabItem)
        $tabItem = $null
    }
    
    $TabParent.Controls.Add($tabControl)
    $TabControlList.Add($tabControl)
    return $tabControl
}
Function Setup-OldTabs{
    param($TabNames, $main_form, $buffer = 65, $width = $main_form.Width, $height = $main_form.Height)
    $tabControl = New-Object System.Windows.Forms.TabControl
    $tabControl.Location = New-Object System.Drawing.Point(0, $buffer)
    $tabControl.Size = New-Object System.Drawing.Size($width, ($height - $buffer))  # Adjust the height
    #$tabControl.Dock = 'Fill'  # Dock the tab control to fill the form
    #$tabControl.Top = 100
    foreach($tab in $TabNames){
        $tabItem = New-Object System.Windows.Forms.TabPage
        $tabItem.Text = $tab
        $tabControl.TabPages.Add($tabItem)
        $tabItem = $null
    }
    
    $main_form.Controls.Add($tabControl)
    return $tabControl
}
function Add-DefaultMenus{

    param($main_form)
    
    $menuMain   = [System.Windows.Forms.MenuStrip]@{}
    $menuFile   = [System.Windows.Forms.ToolStripMenuItem]@{ Text = "File"  }
    $menuReset  = [System.Windows.Forms.ToolStripMenuItem]@{ Text = "Reset" }
    $menuExit   = [System.Windows.Forms.ToolStripMenuItem]@{ Text = "Exit"  }
    $menuMode   = [System.Windows.Forms.ToolStripMenuItem]@{ Text = "Mode"  }
    $Script:menuNormal = [System.Windows.Forms.ToolStripMenuItem]@{ Text = "Normal"
                                                             Checked = $($BasePathMode -eq $false)}
    $Script:menuSpoof  = [System.Windows.Forms.ToolStripMenuItem]@{ Text = "Spoof"
                                                             Checked = $BasePathMode }
    $Script:menuTarget   = [System.Windows.Forms.ToolStripMenuItem]@{ Text = "Remote"  }
    $Script:menuTarget.Enabled = $false
    $menuLogoff  = [System.Windows.Forms.ToolStripMenuItem]@{ Text = "Logoff" }
    $menuRestart  = [System.Windows.Forms.ToolStripMenuItem]@{ Text = "Restart" }
    $menuShutdown  = [System.Windows.Forms.ToolStripMenuItem]@{ Text = "Shutdown" }
    $menuHelp   = [System.Windows.Forms.ToolStripMenuItem]@{ Text = "Help"  }
    $menuAbout  = [System.Windows.Forms.ToolStripMenuItem]@{ Text = "About" }

    $menuReset.Add_Click({Reset-Script})
    $menuExit.Add_Click({ExitApp})
    $Script:menuNormal.Add_Click({Set-PathMode $false})
    $Script:menuSpoof.Add_Click({Set-PathMode $true})
    $menuAbout.Add_Click({AboutApp})
    $menuLogoff.Add_Click({LogoffTarget})
    $menuRestart.Add_Click({RestartTarget})
    $menuShutdown.Add_Click({ShutdownTarget})

    [void]$menuFile.DropDownItems.Add($menuReset)
    [void]$menuFile.DropDownItems.Add($menuExit)
    [void]$menuMode.DropDownItems.Add($Script:menuNormal)
    [void]$menuMode.DropDownItems.Add($Script:menuSpoof)
    [void]$Script:menuTarget.DropDownItems.Add($menuLogoff)
    [void]$Script:menuTarget.DropDownItems.Add($menuRestart)
    [void]$Script:menuTarget.DropDownItems.Add($menuShutdown)
    [void]$menuHelp.DropDownItems.Add($menuAbout)

    [void]$menuMain.Items.Add($menuFile)
    [void]$menuMain.Items.Add($menuMode)
    [void]$menuMain.Items.Add($Script:menuTarget)
    [void]$menuMain.Items.Add($menuHelp)
    $main_form.MainMenuStrip = $menuMain
    [void]$main_Form.Controls.Add($menuMain)
}
Function Confirm-Choise{

    $aboutWin = [System.Windows.Forms.Form]@{
        ClientSize      = [System.Drawing.Point]::new(350, 150)
        KeyPreview      = $true
        FormBorderStyle = 'FixedToolWindow'
        ControlBox      = $false
        StartPosition   = 'CenterScreen'
    }
    $aboutWin.Add_KeyDown({ param($sender, $e) if ($e.KeyCode -eq 'Escape') { $aboutWin.close() } })
    $labelsData = @(
        @{ Text = $AboutInfo.Title; Title = $true; Desc = $false; Below = 25; Left = 10 },
        @{ Text = $AboutInfo.Author; Title = $false; Desc = $false; Below = 55; Left = 10 },
        @{ Text = $AboutInfo.Description; Title = $false; Desc = $true;  Below = 80; Left = 10 },
        @{ Text = $AboutInfo.Version; Title = $false; Desc = $false; Below = 55; Left = 160 }
    )
    $line_start = [Int]0
    foreach ($labelData in $labelsData) {
        $label = New-Object System.Windows.Forms.Label
        $label.Text = $labelData.Text
        $font_size = if ($labelData.Title -eq $true) { 16 } else { 10 }
        $label.BackColor = [System.Drawing.Color]::Transparent
        $label.Font = New-Object System.Drawing.Font("Lucida Console",$font_size,[System.Drawing.FontStyle]::Regular)
        $label.Location = New-Object System.Drawing.Point($labelData.Left, [Int] ($line_start + [Int]$labelData.Below) )
        if ($labelData.Desc -eq $false){
            $label.Autosize = $true
        }else{
            $label.width = 175
            $label.height = 60
        }
        $aboutWin.Controls.Add($label)
    }
    $img = Set-Icon -InputFile $AboutInfo.Icon
    $pictureBox_logo = [Windows.Forms.PictureBox]@{
                Location      = [System.Drawing.Size]::new(225,25)
                Size          = [System.Drawing.Size]::new(100,100)
                Image         = $img
                SizeMode      = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
    }
    $aboutWin.controls.add($pictureBox_logo)
    $aboutWin.Add_MouseClick({ $aboutWin.close() })
    foreach ($childControl in $aboutWin.controls){
        $childControl.Add_MouseClick({ $aboutWin.close() })
    }
    $aboutWin.ShowDialog()
}
function Add-DefaultOldMenus{

    param($main_form)
    $menuMain         = New-Object System.Windows.Forms.MenuStrip
    $mainToolStrip    = New-Object System.Windows.Forms.ToolStrip
    $menuFile         = New-Object System.Windows.Forms.ToolStripMenuItem
    $menuReset        = New-Object System.Windows.Forms.ToolStripMenuItem
    $menuExit         = New-Object System.Windows.Forms.ToolStripMenuItem
    $menuHelp         = New-Object System.Windows.Forms.ToolStripMenuItem
    $menuAbout        = New-Object System.Windows.Forms.ToolStripMenuItem
    #$toolStripReset   = New-Object System.Windows.Forms.ToolStripButton
    #$toolStripAbout   = New-Object System.Windows.Forms.ToolStripButton
    #$toolStripExit    = New-Object System.Windows.Forms.ToolStripButton

    # Menu: File
    $menuFile.Text = "File"
    
    # Menu: File -> Reset
    $menuReset.Text = "Reset"
    $menuReset.Add_Click({Reset-Script})

    # Menu: File -> Exit
    $menuExit.Text = "Exit"
    $menuExit.Add_Click({ExitApp})

    # Menu: Help
    $menuHelp.Text = "Help"

    # Menu: Help -> About
    $menuAbout.Text = "About"
    $menuAbout.Add_Click({AboutApp})
    
    #[void]$mainToolStrip.Items.Add($toolStripReset)

    
    [void]$menuFile.DropDownItems.Add($menuReset)
    [void]$menuFile.DropDownItems.Add($menuExit)
    [void]$menuHelp.DropDownItems.Add($menuAbout)

    
    [void]$menuMain.Items.Add($menuFile)
    [void]$menuMain.Items.Add($menuHelp)

    
    $main_form.MainMenuStrip = $menuMain

    # Show Menu Bar
   # [void]$main_Form.Controls.Add($mainToolStrip)
    [void]$main_Form.Controls.Add($menuMain)
    #$main_form.Controls.Add($menuMain)

}
function Set-PathMode{
    param($mode = $true)

    $Script:BasePathMode = $mode
    $Script:menuNormal.Checked = $($mode -eq $false)
    $Script:menuSpoof.Checked = $mode
    write-debug "Mode: $Script:BasePathMode"
    Pull-Host
}
function Set-Icon{
    param($InputFile)
    if ($InputFile -ne ""){
        $file = $InputFile #(get-item $AboutInfo.Icon) #
        #Write-Host $file
        $img = [System.Drawing.Image]::Fromfile($file);
    }else{
        $base64ImageString = "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"
        $imageBytes = [Convert]::FromBase64String($base64ImageString)
        $ms = New-Object IO.MemoryStream($imageBytes, 0, $imageBytes.Length)
        $ms.Write($imageBytes, 0, $imageBytes.Length);
        $img = [System.Drawing.Image]::FromStream($ms, $true)
    }
    return $img
}
function AboutApp {
    ShowAbout
#[void] [System.Windows.MessageBox]::Show( "My simple PowerShell GUI script with dialog elements and menus v1.0", "About script", "OK", "Information" )

}
Function ShowAbout{

    $aboutWin = [System.Windows.Forms.Form]@{
        ClientSize      = [System.Drawing.Point]::new(350, 150)
        KeyPreview      = $true
        FormBorderStyle = 'FixedToolWindow'
        ControlBox      = $false
        StartPosition   = 'CenterScreen'
    }
    $aboutWin.Add_KeyDown({ param($sender, $e) if ($e.KeyCode -eq 'Escape') { $aboutWin.close() } })
    $labelsData = @(
        @{ Text = $AboutInfo.Title; Title = $true; Desc = $false; Below = 25; Left = 10 },
        @{ Text = $AboutInfo.Author; Title = $false; Desc = $false; Below = 55; Left = 10 },
        @{ Text = $AboutInfo.Description; Title = $false; Desc = $true;  Below = 80; Left = 10 },
        @{ Text = $AboutInfo.Version; Title = $false; Desc = $false; Below = 55; Left = 160 }
    )
    $line_start = [Int]0
    foreach ($labelData in $labelsData) {
        $label = New-Object System.Windows.Forms.Label
        $label.Text = $labelData.Text
        $font_size = if ($labelData.Title -eq $true) { 16 } else { 10 }
        $label.BackColor = [System.Drawing.Color]::Transparent
        $label.Font = New-Object System.Drawing.Font("Lucida Console",$font_size,[System.Drawing.FontStyle]::Regular)
        $label.Location = New-Object System.Drawing.Point($labelData.Left, [Int] ($line_start + [Int]$labelData.Below) )
        if ($labelData.Desc -eq $false){
            $label.Autosize = $true
        }else{
            $label.width = 175
            $label.height = 60
        }
        $aboutWin.Controls.Add($label)
    }
    $img = Set-Icon -InputFile $AboutInfo.Icon
    $pictureBox_logo = [Windows.Forms.PictureBox]@{
                Location      = [System.Drawing.Size]::new(225,25)
                Size          = [System.Drawing.Size]::new(100,100)
                Image         = $img
                SizeMode      = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
    }
    $aboutWin.controls.add($pictureBox_logo)
    $aboutWin.Add_MouseClick({ $aboutWin.close() })
    foreach ($childControl in $aboutWin.controls){
        $childControl.Add_MouseClick({ $aboutWin.close() })
    }
    $aboutWin.ShowDialog()
}
function Reset-Script {
    # Clear all variables
    Get-Variable | Where-Object { $_.Name -ne "Reset-Script" } | ForEach-Object {
        Remove-Variable -Name $_.Name -ErrorAction SilentlyContinue
    }
    ExitApp
    # Reload the script
    . $PSCommandPath
}
function ExitApp {
    # Exit App
    #Stop-Script
    
    $main.hide()
    $main.Close()
    
}
function Show-InputBox {
    param (
        [string]$Prompt = "Enter a value:",
        [string]$Title = "Input Box",
        [string]$Default = ""
    )

    $objForm = New-Object Windows.Forms.Form
    $objForm.Text = $Title
    $objForm.Size = New-Object Drawing.Size(300,125)
    $objForm.StartPosition = "CenterScreen"

    $objLabel = New-Object Windows.Forms.Label
    $objLabel.Location = New-Object Drawing.Point(10,6)
    $objLabel.Size = New-Object Drawing.Size(280,20)
    $objLabel.Text = $Prompt

    $objTextBox = New-Object Windows.Forms.TextBox
    $objTextBox.Location = New-Object Drawing.Point(10,26)
    $objTextBox.Size = New-Object Drawing.Size(260,20)
    $objTextBox.Text = $Default

    $objForm.Controls.Add($objLabel)
    $objForm.Controls.Add($objTextBox)

    $OKButton = New-Object Windows.Forms.Button
    $OKButton.Location = New-Object Drawing.Point(75,55)
    $OKButton.Size = New-Object Drawing.Size(75,23)
    $OKButton.Text = "OK"
    $OKButton.DialogResult = [Windows.Forms.DialogResult]::OK

    $CancelButton = New-Object Windows.Forms.Button
    $CancelButton.Location = New-Object Drawing.Point(150,55)
    $CancelButton.Size = New-Object Drawing.Size(75,23)
    $CancelButton.Text = "Cancel"
    $CancelButton.DialogResult = [Windows.Forms.DialogResult]::Cancel

    $objForm.Controls.Add($OKButton)
    $objForm.Controls.Add($CancelButton)
    $objForm.Topmost = $true
    $objForm.Add_Shown({$objForm.Activate()})
    # Handle Enter and Esc keys
    $objForm.KeyPreview = $true
    $objForm.Add_KeyDown({
        param($sender, $e)
        if ($e.KeyCode -eq [System.Windows.Forms.Keys]::Enter) {
            $objForm.DialogResult = [Windows.Forms.DialogResult]::OK
            $objForm.Close()
        } elseif ($e.KeyCode -eq [System.Windows.Forms.Keys]::Escape) {
            $objForm.DialogResult = [Windows.Forms.DialogResult]::Cancel
            $objForm.Close()
        }
    })

    $result = $objForm.ShowDialog()

    return $(if ($result -eq [Windows.Forms.DialogResult]::OK) { $objTextBox.Text }else{ $null })
}
function Cleanup {
    Write-Information "Script ending. Cleaning up variables..."
    $main.Dispose()
    Remove-Variable main
    $tabControls = $null
    $tabUser = $null
    $tabLocal = $null
    $tabLogin = $null
    Unregister-Event -SourceIdentifier ScriptExit | Out-Null
}
function dummy_tutorial{
    #Add-comboList $TestArr 200 10 70 $main
    #Add-listBox $TestArr 200 100 10 140 $main

    #Add-comboListBox $TestArr 600 100 10 70 $main
    #Ask-Question "My Question" 10 70 $Answers $main "check"
    #Add-ProgressBar 45 510 30 200 $main
    #$main.ShowDialog()
}
