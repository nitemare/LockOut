#################################
#           LockOut             #
#      File: funcForms          #
#        By Scott Lyon          #
#         SubVer:  v1.1         #
#          Oct 17,2023          #
#################################
Function Add-comboList {
    Param($inList, $width, $height, $x, $y, $main_form)

    $comboBox = New-Object System.Windows.Forms.ComboBox
    foreach ($item in $inList) {
        $comboBox.Items.Add([string]$item.runKeySubKey + "\" + [string]$item.SetKey) | Out-Null
    }
    $comboBox.Width = $width
    $comboBox.Height = $height
    $comboBox = Add-Ident -obj $comboBox
    $comboBox.Location  = New-Object System.Drawing.Point($x,$y)
    $main_form.Controls.Add($comboBox)
}
Function Make-comboList {
    Param($width, $height, $x, $y, $main_form)

    $comboBox = New-Object System.Windows.Forms.ComboBox
    $comboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $comboBox.Width = $width
    $comboBox.Height = $height
    $comboBox = Add-Ident -obj $comboBox
    $comboBox.Location  = New-Object System.Drawing.Point($x,$y)
    $main_form.Controls.Add($comboBox)
    return $comboBox
}
Function Add-ResizeButton{
    param($main_form)
    $resizeGrip = New-Object Windows.Forms.Panel
    $resizeGrip.Size = New-Object Drawing.Size(16, 16)
    $resizeGrip.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    $resizeGrip.BackColor = [System.Drawing.Color]::Transparent
    $resizeGrip.Location = New-Object Drawing.Point($($main_form.ClientSize.Width - $resizeGrip.Width), $($main_form.ClientSize.Height - $resizeGrip.Height))
    $main_form.Controls.Add($resizeGrip)
    return $resizeGrip
}
Function Make-listBox {
    Param($width, $height, $x, $y, $main_form)
    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Width = $width
    $listBox.Height = $height
    $listBox.Location  = New-Object System.Drawing.Point($x,$y)
    $main_form.Controls.Add($listBox)
    return $listBox
}
Function Add-listBox {
    Param($inList, $width, $height, $x, $y, $main_form)

    $listBox = New-Object System.Windows.Forms.checkedListBox
    foreach ($item in $inList) {
        $listBox.Items.Add([string]$item.runKeySubKey + "\" + [string]$item.SetKey) | Out-Null
    }
    $listBox.Width = $width
    $listBox = Add-Ident -obj $listBox
    $listBox.Height = $height
    $listBox.Location  = New-Object System.Drawing.Point($x,$y)
    $main_form.Controls.Add($listBox)
}
Function Add-Button {
    Param($Text, $width, $height, $x, $y, $main_form)

    $Button = New-Object System.Windows.Forms.Button
    $Button.Width = $width
    $Button.Height = $height
    $Button.Text = $Text
    $button = Add-Ident -obj $button
    $Button.Location  = New-Object System.Drawing.Point($x,$y)
    $main_form.Controls.Add($Button)
    return $Button
}
function Add-Optionbox{
    param($X, $y, $width, $boxName, $TextField, $main_form, $checkRadio = "check") 
    if ($checkRadio -eq "radio"){
        $RadioBtn = New-Object System.Windows.Forms.RadioButton
    } else {
        $RadioBtn = New-Object System.Windows.Forms.CheckBox
    }
    $RadioBtn.Text = $TextField
    $RadioBtn.Name = $boxName
    $RadioBtn = Add-Ident -obj $RadioBtn -uniqueID $boxName
    $RadioBtn.Location  = New-Object System.Drawing.Point(($x),$y)
    $RadioBtn.Font = New-Object System.Drawing.Font("Lucida Console",12,[System.Drawing.FontStyle]::Bold)
    $RadioBtn.AutoSize = $true
    $main_form.Controls.Add($RadioBtn)
    return $RadioBtn
}
function Add-Label{
    param($text, $x, $y, $font_size, $width, $main_form) 
    $labelTemp = New-Object System.Windows.Forms.Label
    $labelTemp.Text = $text
    $labelTemp.width = $width
    
    $labelTemp = Add-Ident -obj $labelTemp
    $labelTemp.Location  = New-Object System.Drawing.Point($x, $y)
    $labelTemp.Font = New-Object System.Drawing.Font("Lucida Console",$font_size,[System.Drawing.FontStyle]::Bold)
    # $Label.AutoSize = $true
    #$labelTemp.TextAlign = "MiddleRight"
    $main_form.Controls.Add($labelTemp)
    #$labelTemp.BringToFront()
    return $labelTemp
    $labelTemp = $null
}
function Add-TextBox{
    param($X, $y, $width, $boxName, $main_form, $Default = "", $prompt = "") 
    if ($prompt -ne ""){  
        $Label = New-Object System.Windows.Forms.Label
        $Label.Text = $prompt
        $label.width = $($prompt.length * 11)
        $Label.Location  = New-Object System.Drawing.Point($($x - $($prompt.length * 11)), $y)
        $Label.Font = New-Object System.Drawing.Font("Lucida Console",12,[System.Drawing.FontStyle]::Bold)
       # $Label.AutoSize = $true
        $Label.TextAlign = "MiddleRight"
        $main_form.Controls.Add($Label)
        $label.BringToFront()
    }
    $TextBox = New-Object System.Windows.Forms.TextBox
    $TextBox.Text = $Default
    $TextBox.Tag = $TextBox.Text
    $TextBox.Name = $boxName
    $TextBox = Add-Ident -obj $TextBox -uniqueID $boxName
    $TextBox.Location  = New-Object System.Drawing.Point(($x),($y))
    $TextBox.Width = $width
    $TextBox.Font = New-Object System.Drawing.Font("Lucida Console",12,[System.Drawing.FontStyle]::Bold)
    $TextBox.AutoSize = $true
    $main_form.Controls.Add($TextBox)
    $textBox.BringToFront()
    return $TextBox
}
function Add-Ident {
    param($obj, $uniqueID = $null)

    if ($uniqueID -eq $null) {
        #Write-Debug "1: $($obj.Name -ne $null)"
        #Write-Debug "2: $($obj.Name -ne '')"
        if ($obj.Name -ne $null -and $obj.Name -ne ""){
            $uniqueID = $obj.Name
        }else{
            $controlType = $obj.GetType().Name
            $controlCount = 1

            # Helper function to recursively check controls within tab controls
            function CountControls($controls) {
                $controls | ForEach-Object {
                    if ($_.GetType().Name -eq $controlType) {
                        $controlCount++
                    }

                    # Check for nested tab controls
                    if ($_.Controls.Count -gt 0) {
                        CountControls $_.Controls
                    }
                }
            }

            CountControls $main.Controls

            $uniqueID = "$controlType$controlCount"
        }
    }
    if ($uniqueID -eq ""){
        write-warning $obj.GetType().Name
    }
    if ($obj.PSObject.Properties["UID"] -eq $null) {
        Add-Member -InputObject $obj -MemberType NoteProperty -Name "UID" -Value $uniqueID
    }
    return $obj
}
function Add-OrigIdent{
    param($obj, $uniqueID)

    if ($obj.PSObject.Properties["UID"] -eq $null){
        Add-Member -InputObject $obj -MemberType NoteProperty -Name "UID" -Value $uniqueID
    }
    return $obj

}
function Ask-Question{
    param($Prompt, $X, $y, $OptionArray, $main_form, $checkRadio = "radio")
    $Label = New-Object System.Windows.Forms.Label
    $Label.Text = $Prompt
    $Label.Location  = New-Object System.Drawing.Point($x, $y)
    $Label.Font = New-Object System.Drawing.Font("Lucida Console",12,[System.Drawing.FontStyle]::Bold)
    $Label.AutoSize = $true
    $questionY = $y 
    $main_form.Controls.Add($Label)

    if ($OptionArray.Gettype().name -eq "String"){
            $TextBox = New-Object System.Windows.Forms.TextBox
            #$TextBox.Text = $_[0]
            $TextBox.Name = $OptionArray
            $TextBox.Location  = New-Object System.Drawing.Point(($x + 20),($y + 30))
            $TextBox.Width = 400
            $TextBox.Font = New-Object System.Drawing.Font("Lucida Console",12,[System.Drawing.FontStyle]::Bold)
            $TextBox.AutoSize = $true
            $main_form.Controls.Add($TextBox)
    }else{
        $OptionArray | ForEach-Object{
            $questionY += 25
            if ($checkRadio -eq "radio"){
                $RadioBtn = New-Object System.Windows.Forms.RadioButton
            } else {
                $RadioBtn = New-Object System.Windows.Forms.CheckBox
            }
            $RadioBtn.Text = $_[0]
            $RadioBtn.Name = $_[1]
            $RadioBtn.Location  = New-Object System.Drawing.Point(($x + 20),$questionY)
            $RadioBtn.Font = New-Object System.Drawing.Font("Lucida Console",12,[System.Drawing.FontStyle]::Bold)
            $RadioBtn.AutoSize = $true
            $main_form.Controls.Add($RadioBtn)
       }
    }
    $OkBtn = New-Object System.Windows.Forms.Button
    $OkBtn.Text = "Okay"
    $OkBtn.Location  = New-Object System.Drawing.Point(($main_form.Width - 185),($main_form.Height - 75))
    $OkBtn.AutoSize = $true
    $main_form.Controls.Add($OkBtn)
    
    $OkBtn.Add_Click({
        #Get-SelectedRadioButton
        Get-AllForm
    })

    $CnlBtn = New-Object System.Windows.Forms.Button
    $CnlBtn.Text = "Cancel"
    $CnlBtn.Location  = New-Object System.Drawing.Point(($main_form.Width - 100),($main_form.Height - 75))
    $CnlBtn.AutoSize = $true
    $main_form.Controls.Add($CnlBtn)
       
    $CnlBtn.Add_Click({
        ExitApp
    })

}
Function Add-ProgressBar{
    Param($Progress, $width, $x, $y, $main_form, $total=100, $height=20, $cName = "ProgBar")
    
    $progBar = New-Object System.Windows.Forms.ProgressBar
    $progBar.Value = (([Int]$Progress / [Int]$total ) * 100)
    $progBar.Name = $cName
    $progBar = Add-Ident -obj $progBar -uniqueID $cName
    $progBar.Width = $width
    $progBar.Height = $height
    $progBar.Location  = New-Object System.Drawing.Point($x,$y)
    $main_form.Controls.Add($progBar)
    return $progBar
}
Function Set-ProgressBar{
    param($Name, $val, $main_form, $change = "=")
    $Control = Find-Control "HostLoad"
        if ($Control.Name -eq $Name) { 
            $Control.Value = Switch -Wildcard ($change) {
                '=' { $val }
                '+' { 
                        if (($Control.Value + $val) -le $Control.Maximum){
                            $Control.Value + $val 
                        }else{
                            $Control.Maximum
                        }
                    }
                '-' { 
                    if (($Control.Value - $val) -ge $Control.Minimum){
                            $Control.Value - $val 
                        }else{
                            $Control.Minimum
                        }
                    }
            }
        }

}
Function Get-ProgressBar{
    param($Name, $main_form)
    ($main_form.Controls | Foreach-Object {
        if ($_.Name -eq $Name) { 
            return $_.Value
        }
    })

}
function Get-AllForm {
    $form = [PSCustomObject]@{ Submit=$true }
    $main.Controls | ForEach-Object{
        $parObj = $_
        #write-host $_.GettYpe().Name
        switch ($_.GettYpe().Name){        
            {'TextBox' -eq $_} {
                Add-Member -InputObject $form -MemberType NoteProperty -Name $parObj.Name -Value $parObj.Text
                Write-Host $parObj.Name ":" $parObj.checked
                break
            }
            {'RadioButton','CheckBox' -eq $_} {
                Add-Member -InputObject $form -MemberType NoteProperty -Name $parObj.Name -Value $parObj.checked
                Write-Host $parObj.Name ":" $parObj.checked
                break
            }
        }
    }
    Write-Host $form
}
function Get-SelectedRadioButton {
    Write-Host "Test"
    $selectedRadioButton = $main.Controls | Where-Object { $_.GetType().Name -eq "RadioButton" -and $_.Checked }
    if ($selectedRadioButton) {
        $selectedValue = $selectedRadioButton.Text
        Write-Host "Selected Radio: $selectedValue"
    }
}
function Add-ToolTip{
    param($inControl, $InText)
    $tooltip = New-Object Windows.Forms.ToolTip
    $toolTip.SetToolTip($inControl, $InText)
}
