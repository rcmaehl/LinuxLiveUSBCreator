
#Region ### START Koda GUI section ### Form=Menu.kxf
;GUI_Options_Menu()

Global $proxy_modes[3],$proxy_status,$available_languages[50]

Global $check_for_updates,$stable_only,$all_release,$hTreeView,$treeview_items

Global $tab_options,$automatic_recognition,$force_install_parameters,$combo_use_setting,$force_default_mode

Func GUI_Options_Menu()
	Opt("GUIOnEventMode", 0)
	$main_menu = GUICreate(Translate("Options"), 401, 436, -1, -1,-1, -1,$CONTROL_GUI)
	GUISetFont($font_size)
	$ok_button = GUICtrlCreateButton(Translate("OK"), 304, 408, 81, 23)
	$Tabs = GUICtrlCreateTab(8, 8, 385, 393)
	GUICtrlSetResizing(-1, $GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
	$tab_general = GUICtrlCreateTabItem(Translate("General"))
	If @Compiled Then
		$logo = GUICtrlCreatePic("", 32, 45, 344, 107)
		_Resource_SetToCtrlID(-1, 'JPG_1')
	Else
		$logo = GUICtrlCreatePic(@ScriptDir & "\tools\img\logo.jpg", 32, 45, 344, 107)
	EndIf
	$version = GUICtrlCreateLabel(Translate("Current version")&" : "&GetDisplayVersion(), 88, 196, 250, 25)
	GUICtrlSetFont($version, 14)
	$last_version_available = GUICtrlCreateLabel(Translate("Last version")&" : "&GetLastAvailableVersion(), 88, 231, 250, 25)
	GUICtrlSetFont($last_version_available, 14)
	$group_version = GUICtrlCreateGroup(Translate("Versions"), 56, 160, 307, 123)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$donate = GUICtrlCreateButton(Translate("Make a donation"), 32, 319, 153, 33, $WS_GROUP)
	$contact = GUICtrlCreateButton(Translate("Contact me"), 212, 319, 153, 33, $WS_GROUP)
	$copyright = GUICtrlCreateLabel(Translate("CopyLeft by")&" Thibaut Lauzière - ",  15, 380, 185, 17,$SS_RIGHT)
	$licence=GUICtrlCreateLabel(Translate("GPL v3 License"), 206, 379, 360, 17)
	;GUICtrlSetFont(-1,-1,-1,4)
	GUICtrlSetColor(-1,0x0000cc)
	GUICtrlSetCursor(-1,4)

	$tab_options = GUICtrlCreateTabItem(Translate("Options"))

	$Group3 = GUICtrlCreateGroup(Translate("Install parameters"), 24, 48, 353, 160)

	$automatic_recognition = GUICtrlCreateRadio(Translate("Use LiLi automatic recognition")&" ("&Translate("highly recommended")&")", 44, 72, 330, 17)
	$force_default_mode = GUICtrlCreateRadio(Translate("Force using default mode (works with most Linuxes)"), 44, 104, 330, 17)
	$force_install_parameters = GUICtrlCreateRadio(Translate("Force using same parameters as")&" :", 44, 136, 330, 17)
	$combo_use_setting = GUICtrlCreateCombo("", 88, 168, 250, -1, BitOR($CBS_DROPDOWNLIST, $WS_VSCROLL))
	GUICtrlSetData($combo_use_setting, ">> " & Translate("Select a Linux")&$prefetched_linux_list_full)
	UpdateRecognition()

	$tab_language = GUICtrlCreateTabItem(Translate("Language"))
	$language_list = GUICtrlCreateList("English", 80, 136, 180, 200,$WS_BORDER+$WS_VSCROLL)
	GUICtrlSetData(-1, Available_Languages())

	$forced_lang=ReadSetting("General","force_lang")
	if $forced_lang="" Then
		_GUICtrlListBox_SelectString($language_list,"Automatic")
	Else
		_GUICtrlListBox_SelectString($language_list,$forced_lang)
	EndIf

	$label_languages = GUICtrlCreateLabel(Translate("Available languages"), 32, 88, 323, 25)
	GUICtrlSetFont($label_languages, 14)


	$tab_proxy = GUICtrlCreateTabItem(Translate("Proxy"))


	$group_proxy_settings = GUICtrlCreateGroup(Translate("Proxy settings"), 24, 46, 353, 260)
	GUICtrlSetFont(-1, 10)
	;$prox = GUICtrlCreateCheckbox("Check for updates", 56, 70, 297, 17)

	$no_proxy = GUICtrlCreateRadio(Translate("No proxy"), 46, 70, 297, 17)

	$text_for_system=Translate("Use system settings")
	$current_proxy=RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyServer")
	if $current_proxy<>"" AND RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyEnable")=1 Then
		$text_for_system&=" ("&$current_proxy&")"
	EndIf
	$system_proxy = GUICtrlCreateRadio($text_for_system, 46, 100, 297, 17)
	$custom_proxy = GUICtrlCreateRadio(Translate("Use custom settings"), 46, 130, 297, 17)

	$proxy_modes[0]=$system_proxy
	$proxy_modes[1]=$no_proxy
	$proxy_modes[2]=$custom_proxy

	GUICtrlSetState($proxy_modes[ReadSetting("Proxy", "proxy_mode")],$GUI_CHECKED)

	$label_proxy_url = GUICtrlCreateLabel(Translate("Proxy URL")&" : ", 30, 173, 110, 21, $WS_GROUP+$SS_RIGHT)

	$proxy_url_input = GUICtrlCreateInput(ReadSetting( "Proxy", "proxy_url"), 150, 170, 217, 22, $WS_GROUP+$ES_AUTOHSCROLL)

	$label_proxy_port = GUICtrlCreateLabel(Translate("Port")&" : ", 30, 206, 110, 21, $WS_GROUP+$SS_RIGHT)

	$proxy_port_input = GUICtrlCreateInput(ReadSetting( "Proxy", "proxy_port"), 150, 203, 49, 22, $WS_GROUP+$ES_NUMBER+$ES_AUTOHSCROLL)

	$label_proxy_user = GUICtrlCreateLabel(Translate("Username")&" : ", 30, 236, 110, 21, $WS_GROUP+$SS_RIGHT)

	$proxy_username_input = GUICtrlCreateInput(ReadSetting( "Proxy", "proxy_username"), 150, 233, 160, 22, $WS_GROUP+$ES_AUTOHSCROLL)

	$label_proxy_password = GUICtrlCreateLabel(Translate("Password")&" : ", 30, 272, 110, 21, $WS_GROUP+$SS_RIGHT)

	$proxy_password_input = GUICtrlCreateInput(ReadSetting( "Proxy", "proxy_password"), 150, 269, 160, 22, $WS_GROUP+$ES_PASSWORD+$ES_AUTOHSCROLL)


	$group_status = GUICtrlCreateGroup(Translate("Status"), 22, 323, 353, 65)
	GUICtrlSetFont(-1, 10)
	$test_proxy = GUICtrlCreateButton(Translate("Test settings"), 204, 348, 161, 25, $WS_GROUP)
	$proxy_status = GUICtrlCreateLabel(Translate("Not tested yet"), 32, 351, 164, 26,$WS_GROUP)
	GUICtrlSetColor($proxy_status,0xFF9104)
	GUICtrlSetFont($proxy_status, 12)


;RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyEnable")


	#cs
	$label_proxy_url = GUICtrlCreateLabel("Proxy URL", 46, 120, 87, 21)
	GUICtrlSetFont($label_proxy_url, 11)
	$proxy_url = GUICtrlCreateInput(IniRead($settings_ini, "Proxy", "proxy_url", ""), 130, 120, 225, 21)

	$label_proxy_port = GUICtrlCreateLabel("Port", 46, 153, 71, 21)
	GUICtrlSetFont($label_proxy_port, 11)
	$proxy_port = GUICtrlCreateInput(IniRead($settings_ini, "Proxy", "proxy_port", ""), 130, 153, 49, 21)

	$label_proxy_user = GUICtrlCreateLabel("Username", 46, 191, 84, 21)
	GUICtrlSetFont($label_proxy_user, 11)
	$proxy_username = GUICtrlCreateInput(IniRead($settings_ini, "Proxy", "proxy_username", ""), 130, 191, 160, 21)

	$label_proxy_password = GUICtrlCreateLabel("Password", 46, 219, 82, 21)
	GUICtrlSetFont($label_proxy_password, 11)
	$proxy_password = GUICtrlCreateInput(IniRead($settings_ini, "Proxy", "proxy_password", ""), 130, 219, 160, 21)
	$test_proxy = GUICtrlCreateButton("Test settings", 120, 264, 161, 25)
	#ce

	$tab_updates = GUICtrlCreateTabItem(Translate("Update"))
	$check_for_updates = GUICtrlCreateCheckbox(Translate("Check for updates"), 56, 70, 297, 17)
	GUICtrlSetFont($check_for_updates, 12)
	$stable_only = GUICtrlCreateRadio(Translate("Stable releases only"), 87, 115, 180, 17)
	$all_release = GUICtrlCreateRadio(Translate("Stable and beta releases"), 88, 146, 180, 17)
	$group_updates = GUICtrlCreateGroup("", 72, 96, 220, 89)
	InitUpdateTab()


	$tab_advanced = GUICtrlCreateTabItem(Translate("Advanced"))
	$label_warning = GUICtrlCreateLabel(Translate("Do not modify these options unless you know what you are doing")&" !",20, 43, 350, 30)
	GUICtrlSetColor($label_warning,0xAA0000)
	;Display_Options()
	;-------------------------

	$iStyle = BitOR($TVS_HASBUTTONS, $TVS_DISABLEDRAGDROP,$TVS_CHECKBOXES, $TVS_SHOWSELALWAYS)

	$hTreeView = GUICtrlCreateTreeView(16, 74, 369, 319,$iStyle)
	Populate_Treeview($hTreeView)



	;-----------------------

	;$tab_help = GUICtrlCreateTabItem(Translate("Help")°

	GUICtrlCreateTabItem("")

	;$tab_credits = GUICtrlCreateTabItem("Credits")
	;GUICtrlCreateTabItem("")

	;Check_Internet_Status()
	;GUISetState(@SW_DISABLE, $GUI)
	GUISetState(@SW_DISABLE, $CONTROL_GUI)
	AdlibUnRegister("Control_Hover")
	GUISetState(@SW_SHOW, $main_menu)
	If ReadSetting("Internal","restart_language") ="yes" Then
		GuiCtrlSetState($tab_language,$GUI_SHOW)
		WriteSetting("Internal","restart_language","no")
	EndIf
	#EndRegion ### END Koda GUI section ###

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				WriteAdvancedSettings()
				if CheckCustomRecognition() Then
					Opt("GUIOnEventMode", 1)
					GUIDelete($main_menu)
					AdlibRegister("Control_Hover", 150)
					GUISetState(@SW_ENABLE, $CONTROL_GUI)
					ControlFocus("LinuxLive USB Creator", "", $REFRESH_AREA)
					GUISwitch($CONTROL_GUI)
					SendReport("=========> File Set = "&$file_set)
					if $file_set <> 0 Then
						SendReport("=========> running detection again")
						if $step2_display_menu=1 Then
							GUI_Hide_Step2_Download_Menu()
						EndIf
						GUI_Show_Step2_Default_Menu()
						Check_source_integrity($file_set)
					EndIf
					Return ""
				EndIf

			Case $ok_button
				WriteAdvancedSettings()
				if CheckCustomRecognition() Then
					Opt("GUIOnEventMode", 1)
					GUIDelete($main_menu)
					AdlibRegister("Control_Hover", 150)
					GUISetState(@SW_ENABLE, $CONTROL_GUI)
					ControlFocus("LinuxLive USB Creator", "", $REFRESH_AREA)
					GUISwitch($CONTROL_GUI)
					SendReport("=========> File Set = "&$file_set)
					if $file_set <> "0" Then
						SendReport("=========> running detection again")
						if $step2_display_menu=1 Then
							GUI_Hide_Step2_Download_Menu()
						EndIf
						GUI_Show_Step2_Default_Menu()
						Check_source_integrity($file_set)
					EndIf
					Return ""
				EndIf
			Case $contact
				ShellExecute("http://www.linuxliveusb.com/contact")
			Case $licence
				ShellExecute("http://www.linuxliveusb.com/about/license")
			Case $donate
				ShellExecute("http://www.linuxliveusb.com/donations")
			Case $language_list
				$language_selected=GUICtrlRead($language_list)
				if $language_selected="Automatic" OR StringInStr($language_selected,"—")>0 Then
					WriteSetting("General", "force_lang","")
				Else
					WriteSetting("General", "force_lang",$language_selected)
					WriteSetting("Internal","restart_language","yes")
				EndIf
				_ScriptRestart()
			Case $check_for_updates
				Checkbox_To_Setting($check_for_updates,"Updates","check_for_updates")
			Case $all_release
				Checkbox_To_Setting($all_release,"Updates","check_for_beta_versions")
			Case $stable_only
				Checkbox_To_Setting_Reverse($stable_only,"Updates","check_for_beta_versions")
			Case $no_proxy
				WriteSetting("Proxy", "proxy_mode",1)
				HttpSetProxy(1)
			Case $system_proxy
				WriteSetting("Proxy", "proxy_mode",0)
				HttpSetProxy(0)
			Case $custom_proxy
				WriteSetting("Proxy", "proxy_mode",2)
				; Apply proxy settings
				$proxy_url = ReadSetting( "Proxy", "proxy_url")
				$proxy_port = ReadSetting( "Proxy", "proxy_port")
				$proxy_username = ReadSetting( "Proxy", "proxy_username")
				$proxy_password = ReadSetting( "Proxy", "proxy_password")

				If $proxy_url <> "" AND  $proxy_port <> "" Then
					$proxy_url &= ":" & $proxy_port
					If $proxy_username <> "" Then
						If $proxy_password <> "" Then
							HttpSetProxy(2, $proxy_url, $proxy_username, $proxy_password)
						Else
							HttpSetProxy(2, $proxy_url, $proxy_username)
						EndIf
					Else
						HttpSetProxy(2, $proxy_url)
					EndIf
				EndIf

			Case $proxy_url_input
				WriteSetting("Proxy", "proxy_url",GUICtrlRead($proxy_url_input))
			Case $proxy_port_input
				WriteSetting("Proxy", "proxy_port",GUICtrlRead($proxy_port_input))
			Case $proxy_username_input
				WriteSetting("Proxy", "proxy_username",GUICtrlRead($proxy_username_input))
			Case $proxy_password_input
				WriteSetting("Proxy", "proxy_password",GUICtrlRead($proxy_password_input))
			Case $test_proxy

				if GuiCtrlRead($custom_proxy) = $GUI_CHECKED Then
					WriteSetting("Proxy", "proxy_mode",2)
					; Apply proxy settings
					$proxy_url = ReadSetting( "Proxy", "proxy_url")
					$proxy_port = ReadSetting( "Proxy", "proxy_port")
					$proxy_username = ReadSetting( "Proxy", "proxy_username")
					$proxy_password = ReadSetting( "Proxy", "proxy_password")

					If $proxy_url <> "" AND  $proxy_port <> "" Then
						$proxy_url &= ":" & $proxy_port
						If $proxy_username <> "" Then
							If $proxy_password <> "" Then
								HttpSetProxy(2, $proxy_url, $proxy_username, $proxy_password)
							Else
								HttpSetProxy(2, $proxy_url, $proxy_username)
							EndIf
						Else
							HttpSetProxy(2, $proxy_url)
						EndIf
					EndIf
				Elseif GuiCtrlRead($no_proxy) = $GUI_CHECKED Then
					WriteSetting("Proxy", "proxy_mode",1)
					HttpSetProxy(1)
				Else
					WriteSetting("Proxy", "proxy_mode",0)
					HttpSetProxy(0)
				EndIf
				Check_Internet_Status()

			Case $automatic_recognition
				WriteSetting("Install_Parameters","automatic_recognition","yes")
				UpdateRecognition()
			Case $force_default_mode
				WriteSetting("Install_Parameters","automatic_recognition","no")
				WriteSetting("Install_Parameters","use_same_parameter_as","Regular Linux (works with most linuxes)")
				UpdateRecognition()
			Case $force_install_parameters
				WriteSetting("Install_Parameters","automatic_recognition","no")
				WriteSetting("Install_Parameters","use_same_parameter_as","")
				UpdateRecognition()
			Case $combo_use_setting
				CheckCustomRecognition()
		EndSwitch
		Sleep(10)
	WEnd
	GUIDelete($main_menu)
EndFunc


Func CheckCustomRecognition()
	If ReadSetting("Install_Parameters","automatic_recognition")="no" AND ReadSetting("Install_Parameters","use_same_parameter_as")<>"Regular Linux (works with most linuxes)" Then
		$forced_linux_selected=GUICtrlRead($combo_use_setting)
		If StringInStr($forced_linux_selected, ">>") = 0 Then
			WriteSetting("Install_Parameters","use_same_parameter_as",$forced_linux_selected)
			UpdateRecognition()
			$need_to_recheck=1
			Return 1
		Else
			WriteSetting("Install_Parameters","use_same_parameter_as","")
			GUICtrlSetState($tab_options,$GUI_SHOW)
			MsgBox(48, Translate("Please read"), Translate("Please select a linux to continue"))
			Return 0
		EndIf
	Else
		Return 1
	EndIf
EndFunc

Func UpdateRecognition()
	If ReadSetting("Install_Parameters","automatic_recognition")="no" Then
		if ReadSetting("Install_Parameters","use_same_parameter_as")<>"Regular Linux (works with most linuxes)" Then
			GUICtrlSetState($force_install_parameters,$GUI_CHECKED)
			GUICtrlSetState($combo_use_setting,$GUI_ENABLE)
				if ReadSetting("Install_Parameters","use_same_parameter_as") Then
					GUICtrlSetData($combo_use_setting,ReadSetting("Install_Parameters","use_same_parameter_as"))
				Else
					GUICtrlSetData($combo_use_setting,">> " & Translate("Select a Linux"))
				EndIf
		Else
			GUICtrlSetState($force_default_mode,$GUI_CHECKED)
			GUICtrlSetState($combo_use_setting,$GUI_DISABLE)
		EndIf
	Else
		GUICtrlSetState($automatic_recognition,$GUI_CHECKED)
		GUICtrlSetState($combo_use_setting,$GUI_DISABLE)
	EndIf


EndFunc

Func WriteAdvancedSettings()
	for $i=1 To Ubound($treeview_items)-1
		$item_text = _GUICtrlTreeView_GetText($hTreeView,$treeview_items[$i])
		if $item_text<>"" Then
			If _GUICtrlTreeView_GetChecked($hTreeView, $treeview_items[$i]) Then
				WriteSetting("Advanced",$item_text,"yes")
			Else
				WriteSetting("Advanced",$item_text,"no")
			EndIf
		EndIf
	Next
EndFunc

Func Setting_To_Checkbox($checkbox,$setting_category,$setting_key)
	If ReadSetting($setting_category,$setting_key)="yes" Then
		GUICtrlSetState($checkbox,$GUI_CHECKED)
	Else
		GUICtrlSetState($checkbox,$GUI_UNCHECKED)
	EndIf
EndFunc

Func Setting_To_Checkbox_Reverse($checkbox,$setting_category,$setting_key)
	If ReadSetting($setting_category,$setting_key)="yes" Then
		GUICtrlSetState($checkbox,$GUI_UNCHECKED)
	Else
		GUICtrlSetState($checkbox,$GUI_CHECKED)
	EndIf
EndFunc

Func Checkbox_To_Setting($checkbox,$setting_category,$setting_key)
	If GUICtrlRead($checkbox)==$GUI_CHECKED Then
		WriteSetting( $setting_category,$setting_key , "yes")
	Else
		WriteSetting( $setting_category, $setting_key, "no")
	EndIf
EndFunc

Func Checkbox_To_Setting_Reverse($checkbox,$setting_category,$setting_key)
	If GUICtrlRead($checkbox)==$GUI_CHECKED Then
		WriteSetting( $setting_category,$setting_key , "no")
	Else
		WriteSetting( $setting_category, $setting_key, "yes")
	EndIf
EndFunc


Func Available_Languages()
	Local $language_list="|Automatic|————————————————————|English"
	$available_languages[0]="English"
	; Shows the filenames of all files in the current directory.
	$search = FileFindFirstFile(@ScriptDir&"\tools\languages\*.ini")

	; Check if the search was successful
	If $search = -1 Then
		MsgBox(0, "Error", "No files/directories matched the search pattern")
		Exit
	EndIf
	$i=1
	While 1
		$file = FileFindNextFile($search)
		If @error Then ExitLoop
		$language_list&="|"&StringReplace($file,".ini","")
		$available_languages[$i]=StringReplace($file,".ini","")
		$i+=1
	WEnd
	;MsgBox(4096, "File:", $language_list)
	;$language_list&="|"
	; Close the search handle
	FileClose($search)
	Return $language_list
EndFunc

Func InitUpdateTab()

	Setting_To_Checkbox($check_for_updates,"Updates", "check_for_updates")

	if (ReadSetting( "Updates", "check_for_beta_versions") = "yes") Then
		GUICtrlSetState($all_release,$GUI_CHECKED)
	Else
		GUICtrlSetState($stable_only,$GUI_CHECKED)
	EndIf
EndFunc

Func Display_Options()

	$var = IniReadSection($settings_ini, "Advanced")
	If @error Then
		MsgBox(4096, "", "Error occurred, probably no INI file.")
	Else
		For $i = 1 To $var[0][0]
			$current_checkbox = GUICtrlCreateCheckbox($var[$i][0],100, 50+$i*23, 260, 17);=$var[$i][1]
			Setting_To_Checkbox($current_checkbox, "Advanced",$var[$i][0])
			;if ReadSetting( "Advanced", $var[$i][0])="yes" Then GUICtrlSetState(-1,$GUI_CHECKED)
			;MsgBox(4096, "", "Key: " & $var[$i][0] & @CRLF & "Value: " & $var[$i][1])
		Next
	EndIf
EndFunc

Func Populate_Treeview($htree)

	$var = IniReadSection($settings_ini, "Advanced")
	Global $treeview_items[$var[0][0]+1]
	If @error Then
		MsgBox(4096, "", "Error occurred, probably no INI file.")
	Else
		_GUICtrlTreeView_BeginUpdate($htree)
		For $i = 1 To $var[0][0]
			$treeview_items[$i] = _GUICtrlTreeView_Add($htree, 0,$var[$i][0])
			;Setting_To_Checkbox($current_item, "Advanced",$var[$i][0])
			if ReadSetting( "Advanced", $var[$i][0])="yes" Then _GUICtrlTreeView_SetChecked($htree,$treeview_items[$i],true)
		Next
		_GUICtrlTreeView_EndUpdate($htree)
	EndIf
EndFunc

Func Check_Internet_Status()
	if OnlineStatus()=1 Then
		GUICtrlSetColor($proxy_status,0x007f00)
		GUICtrlSetData($proxy_status,Translate("You are connected"))
	Else
		GUICtrlSetColor($proxy_status,0xAA0000)
		GUICtrlSetData($proxy_status,Translate("You are disconnected"))
	EndIf
EndFunc

Func OnlineStatus()
	GUICtrlSetColor($proxy_status,0xFF9104)
	GUICtrlSetData($proxy_status,Translate("Testing"))
	$inet = InetGet("http://www.google.com", @TempDir & "\connectivity-test.tmp",3,0)
    If @error OR $inet=0 Then
		return 0
    Else
		return 1
    EndIf
EndFunc

Global $__Restart = False
; #FUNCTION# ====================================================================================================================
; Name...........: _ScriptRestart
; Description....: Initiates a restart of the current script.
; Syntax.........: _ScriptRestart ( [$fExit] )
;                  $fExit  - Specifies whether terminates the current script, valid values:
;                  |TRUE   - Terminates script. (Default)
;                  |FALSE  - Does not terminates script.
; Return values..: Success - 1 ($fExit = TRUE)
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........:
; Related .......:
; Link...........:
; Example........: Yes
; ===============================================================================================================================
Func _ScriptRestart($fExit = 1)
	Local $Pid
	If Not $__Restart Then
		If @compiled Then
			$Pid = Run(@ScriptFullPath & ' ' & $CmdLineRaw, @ScriptDir, Default, 1)
		Else
			$Pid = Run(@AutoItExe & ' "' & @ScriptFullPath & '" ' & $CmdLineRaw, @ScriptDir, Default, 1)
		EndIf
		If @error Then
			Return SetError(@error, 0, 0)
		EndIf
		StdinWrite($Pid, @AutoItPID)
	EndIf
	$__Restart = 1
	If $fExit Then
		Sleep(50)
		Exit
	EndIf
	Return 1
EndFunc   ;==>_ScriptRestart

