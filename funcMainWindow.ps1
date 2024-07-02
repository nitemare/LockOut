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
        $base64ImageString = "iVBORw0KGgoAAAANSUhEUgAAAEAAAAA3CAYAAAC8TkynAAAABmJLR0QA/wD/AP+gvaeTAAAHvUlEQVRo3u1beUyURxQfLkUUsSDgxVUEi21A0URUaoyaVFME9Y+KRy0aLBCxJCotnqg0xRopXrWxhxeQ0AgaDZhai1rrkRIREgGJCRG8RVFAQcr1+nvjfl8Wj4VFlrJsX/JLNvO9efPeb968mW92VwghJvUVosJViKrRQlSaAtwQK8fMsQt8qD4iBFWaGI4CHLsIEeJppQkSwAhG7OJLIVpMlQCOnQkgEyaAXkvAASCmh+FAewnIBlwdHMgBEKygheHDh9OKFStoy5Yt3RIRERE0ePDgV/z28fEhDycnymoPAT8ATjY2smNAQADl5ORI4/3795dtVlZWtG7dOmppaaHuIs+ePaOFCxeSmZmZ9HHo0KG0d+9e2r9/PzkhcG7zAjF72ktAP8DX15eePHmiDnLv3j0KCwtTB0lOTu42BISGhkqfevfuTatXr6anT5+qzy5fvky2trYyJr0IuHnzZqtB7t+/Tw8ePKAJEybIwYKCgjrk7Llz5yhi0SLyxozYIJsYXoMGUfiCBTLbOiIDBgyQPsXGxkof6+vrWz0/dOiQ/gRs27aNmpqapIHbt29Tnz59yNramuzs7ORga9eulc9yc3Np9+7dlJaWJvXeJHfu3KHpgYHk1bcvJZmbUxFs1GpQDGxHZr3Xrx9Nw7J7mXxtKS0tlWOlp6dLmywTJ05UU98ctv38/FT92tpaCg8P158ANsiGzp49S8+fP6fg4OBWhWXnzp00c+bMVm08+NSpU2nfvn1yYEWKiorIBUX1a0tLaoAelKkGyAfygGpNWyPwLXSGYEbz8/PV/o8ePaJdu3bJmqQ9Hqd8QkICRUZGqm28RHkZcI1iklxcXGS7XgRM8venIUOGqEZ5YFdXV/nZwsKilRO8W2zevJlmzZolHVLaWb+4uFg6/66zM6XAMQ6yFJiLLLBDNo3y8CB/T0/5eTZmv0RDxK/QdXN0lMvu+PHjaorLQKA3f/58io6OfsUXpT6NHz+e/BGD0j5y5EiZfe0mYEFIiCwka9asIXt7ezXw6dOnU1lZGa1atarVoFFRUXKmHj9+LKuv4nAI7EQtXkwxIIYD+xsYhB3mG8xaTU1NqzRNTkqSu0+OhoTYXr1oybx5ahUfMWIEpaamyopfXV1NM2bMUH1g3/gZ1xBPEKq08yTu2LGDGhsb6dPZs/UjQBEuKLzuKisr1bZAsKksEUukrAdmklOuvLxcFpw5c+bI5zwLDqgdbPcJr1EEmJWV9cb1zcvNGTr3NcvCEX2VWeZUz8zMpLq6Orp27RrZQK8vMknZ99evX6/a4ecFBQVqDWPpMAEvS0NDg1zrPOjJkyfp4cOHskawKDuEgtGjRtEncJRnNAFEcaVvS1YitVdpMmYJCHDWZICCuLg4qVdRUSEnJT4+XrZzIdQlnUYAy9ixY+WgvCPw6Yu3Ns4AnkGl6CiwAuYAniDi9OnTbRJw6dIl8kBNIM3xtZ+WLV7bXFc4pU+cOCEPP0rdWbZsWdcRUFJS8spsc9FjB7km8LLglByIWmCmpePt7a3T7q1bt+SJ0wK6LcDvgDtsLEDmcH9OeT5/OL2UFbzktA9tBidAEd6quCAOGzZMdYbrwbFjx+Tzj8aNozS0fQdYYtko6fsm4WLIATJpzcCfvCPhRNrc3CwJtdEc0RUyN27cSNevX2+XrwYhQFt4d7hx40arNibgN01Vt0OqVlVVtcuWObJImwBFuABeuXJFjqWvGJyA10lnE/A20qUE8J5srjmUqASgLrz8mqoLCgGykGIrPHjwoPEQwGszXhN4Z2AjEL9hw/8E9CgCmoC/NGgyNQLqgQ+xp4/x8pIIxOd6UyLgZ76Tx2sznx4ZIdOm0Y+mRMBW7BCxMTGqftzKlZSIg5LJEMDv/c5I+wsXLlBeXh4Nwp1dYU/KAL5F/gr7vq7CFoP3/STcAezZs4c+x1ufLt3VOAckJiYaDwEpKSk0D7OqK6gVWgREtUEA2+J7BqMhgC81nRBUg46g4pAhmzdtoq1bt6o3Rq8D22Bbui5Ku+W7gLyD01HY+ELUGe/9TkCuDqK+hw22ZVTvAixXr14lJxS6gjYOQ406nnNftlFYWGh8BLBkHD4s7/iOduD4m8kZgr6ZGRnG9zaoLbzVve/mRgEoZEnY//kLylNvAD/bBp1x0P3A3Z0uXrzYaX78ZwSw8O1sdnY2ReMbmo9xeTkNt8WvQxDW+vKlS6Wu9o1ulxLwC3/vN3ky9TQJnjJFHsHbJIC/uRmDb1/0ubwwBvgjptL2/kLE5H8iY1IERAnRYKoEcOximBA1d00weI6ZYxd2QmT64QeDP6HhiAFxXg/nzhvYF47VFzEj9gwUSGGGr6LC7IXIdhQizxDoI8TdSCEa20sA63IfQ/nzjhBZiPkzjl10hfQXInW7HhmQDKBPiugpgmDK/9CDgFMvCCjrKfH7OQjx7JEeBLAulmQt9+0Js5+9SYgmfas07gGbuK9RB49CEzoUs3+7A9sU9+G+sDHXWIOfjV931J55i736zItfiNTCVogxxe6B1E0f+JbBa5PAttgmbLt358Cn4GBRbCtE3RdC/HOrE09tN4HlQtQjG+p4DB6r22W8NdbrYThaYcDjK9vmMaz5ry5CmHcrBjDzBT5CPDb0P754DGRBfmf5/S8gegf08/gOtAAAAABJRU5ErkJggg=="
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