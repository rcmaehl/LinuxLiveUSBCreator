; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Gui Buttons handling                        ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func Disable_Persistent_Mode($mode="Live Mode")
	GUICtrlSetState($slider, $GUI_HIDE)
	GUICtrlSetState($slider_visual, $GUI_HIDE)
	GUICtrlSetState($label_max, $GUI_HIDE)
	GUICtrlSetState($label_min, $GUI_HIDE)
	GUICtrlSetState($slider_visual_Mo, $GUI_HIDE)
	GUICtrlSetState($slider_visual_mode, $GUI_HIDE)
	GUICtrlSetData($live_mode_label,Translate($mode))
	GUICtrlSetState($live_mode_label,$GUI_SHOW)
	Step3_Check("good")
EndFunc   ;==>Disable_Persistent_Mode

Func Enable_Persistent_Mode()
	GUICtrlSetState($live_mode_label, $GUI_HIDE)
	GUICtrlSetState($slider, $GUI_SHOW)
	GUICtrlSetState($slider_visual, $GUI_SHOW)
	GUICtrlSetState($label_max, $GUI_SHOW)
	GUICtrlSetState($label_min, $GUI_SHOW)
	GUICtrlSetState($slider_visual_Mo, $GUI_SHOW)
	GUICtrlSetState($slider_visual_mode, $GUI_SHOW)
EndFunc   ;==>Enable_Persistent_Mode

Func Disable_VirtualBox_Option()
	SetLastStateVirtualization()
	GUICtrlSetState($virtualbox, $GUI_DISABLE)
EndFunc   ;==>Disable_VirtualBox_Option

Func Enable_VirtualBox_Option()
	SetLastStateVirtualization()
	GUICtrlSetState($virtualbox, $GUI_ENABLE)
EndFunc   ;==>Enable_VirtualBox_Option

Func Disable_Hide_Option()
	SetLastStateHideFiles()
	GUICtrlSetState($hide_files, $GUI_DISABLE)
EndFunc   ;==>Disable_Hide_Option

Func Enable_Hide_Option()
	SetLastStateHideFiles()
	GUICtrlSetState($hide_files, $GUI_ENABLE)
EndFunc   ;==>Enable_Hide_Option

Func SetLastStateHideFiles()
	if ReadSetting("Last_State","hide_files")="yes" Then
		GUICtrlSetState($hide_files, $GUI_CHECKED)
	Else
		GUICtrlSetState($hide_files, $GUI_UNCHECKED)
	EndIf
EndFunc

Func SetLastStateVirtualization()
	if ReadSetting("Last_State","virtualization")="yes" Then
		GUICtrlSetState($virtualbox, $GUI_CHECKED)
	Else
		GUICtrlSetState($virtualbox, $GUI_UNCHECKED)
	EndIf
EndFunc


; Clickable parts of images
Func GUI_Exit()
	Global $current_download
		SendCloseStats()
		SendReport("Start-GUI_Exit")
		InetClose($current_download)
		If $foo Then ProcessClose($foo)
		GUIDelete($CONTROL_GUI)
		GUIDelete($GUI)
		if $progress_bar Then _ProgressDelete($progress_bar)
		_GDIPlus_GraphicsDispose($ZEROGraphic)
		_GDIPlus_ImageDispose($EXIT_NORM)
		_GDIPlus_ImageDispose($EXIT_OVER)
		_GDIPlus_ImageDispose($MIN_NORM)
		_GDIPlus_ImageDispose($MIN_OVER)
		_GDIPlus_ImageDispose($PNG_GUI)
		_GDIPlus_ImageDispose($CD_PNG)
		_GDIPlus_ImageDispose($CD_HOVER_PNG)
		_GDIPlus_ImageDispose($ISO_PNG)
		_GDIPlus_ImageDispose($ISO_HOVER_PNG)
		_GDIPlus_ImageDispose($DOWNLOAD_PNG)
		_GDIPlus_ImageDispose($DOWNLOAD_HOVER_PNG)
		_GDIPlus_ImageDispose($LAUNCH_PNG)
		_GDIPlus_ImageDispose($LAUNCH_HOVER_PNG)
		_GDIPlus_ImageDispose($HELP)
		_GDIPlus_ImageDispose($BAD)
		_GDIPlus_ImageDispose($GOOD)
		_GDIPlus_ImageDispose($WARNING)
		_GDIPlus_ImageDispose($BACK_PNG)
		_GDIPlus_ImageDispose($BACK_HOVER_PNG)
		_GDIPlus_Shutdown()
		_Crypt_Shutdown()
		SendReport("End-GUI_Exit")
		Exit
EndFunc   ;==>GUI_Exit


Func GUI_MoveUp()
	If WinActive("LinuxLive USB Creator") Or WinActive("LiLi USB Creator") Then
		$position = WinGetPos("LiLi USB Creator")
		WinMove("LiLi USB Creator", "", $position[0], $position[1] - 10)
		;Fix the focus issue
		ControlFocus("LinuxLive USB Creator", "", $REFRESH_AREA)
	Else
		HotKeySet("{UP}")
		Send("{UP}")
		HotKeySet("{UP}", "GUI_MoveUp")
	EndIf
EndFunc   ;==>GUI_MoveUp

Func GUI_MoveDown()
	If WinActive("LinuxLive USB Creator") Or WinActive("LiLi USB Creator") Then
		$position = WinGetPos("LiLi USB Creator")
		WinMove("LiLi USB Creator", "", $position[0], $position[1] + 10)
		ControlFocus("LinuxLive USB Creator", "", $REFRESH_AREA)
	Else
		HotKeySet("{DOWN}")
		Send("{DOWN}")
		HotKeySet("{DOWN}", "GUI_MoveDown")
	EndIf
EndFunc   ;==>GUI_MoveDown

Func GUI_MoveLeft()
	If WinActive("LinuxLive USB Creator") Or WinActive("LiLi USB Creator") Then
		$position = WinGetPos("LiLi USB Creator")
		WinMove("LiLi USB Creator", "", $position[0] - 10, $position[1])
		ControlFocus("LinuxLive USB Creator", "", $REFRESH_AREA)
	Else
		HotKeySet("{LEFT}")
		Send("{LEFT}")
		HotKeySet("{LEFT}", "GUI_MoveLeft")
	EndIf
EndFunc   ;==>GUI_MoveLeft

Func GUI_MoveRight()
	If WinActive("LinuxLive USB Creator") Or WinActive("LiLi USB Creator") Then
		$position = WinGetPos("LiLi USB Creator")
		WinMove("LiLi USB Creator", "", $position[0] + 10, $position[1])
		ControlFocus("LinuxLive USB Creator", "", $REFRESH_AREA)
	Else
		HotKeySet("{RIGHT}")
		Send("{RIGHT}")
		HotKeySet("{RIGHT}", "GUI_MoveRight")
	EndIf
EndFunc   ;==>GUI_MoveRight

Func GUI_Minimize()
	GUISetState(@SW_MINIMIZE, $GUI)
EndFunc   ;==>GUI_Minimize

Func GUI_Restore()
	GUISetState(@SW_SHOW, $GUI)
	GUISetState(@SW_SHOW, $CONTROL_GUI)
	GUIRegisterMsg($WM_PAINT, "DrawAll")
	ControlFocus("LinuxLive USB Creator", "", $REFRESH_AREA)
EndFunc   ;==>GUI_Restore

Func GUI_Choose_Drive()
	SendReport("Start-GUI_Choose_Drive")
	USBInitializeVariables(StringLeft(GUICtrlRead($combo), 2))
	If ( ($usb_isvalid_filesystem And $usb_space_after_lili_MB > 0) OR GUICtrlRead($formater) == $GUI_CHECKED ) Then
		; State is OK ( FAT32 or FAT format and 700MB+ free)
		Step1_Check("good")

		If GUICtrlRead($slider) > 0 Then
			GUICtrlSetData($label_max, $usb_space_after_lili_MB & " " & Translate("MB"))
			GUICtrlSetLimit($slider, Round($usb_space_after_lili_MB / 10), 0)
			; State is OK ( FAT32 or FAT format and 700MB+ free) and warning for live mode only on step 3
			Step3_Check("good")
		Else
			GUICtrlSetData($label_max, $usb_space_after_lili_MB & " " & Translate("MB"))
			GUICtrlSetLimit($slider, Round($usb_space_after_lili_MB / 10), 0)
			; State is OK but warning for live mode only on step 3
			Step3_Check("warning")
		EndIf
	ElseIf ( $usb_isvalid_filesystem And GUICtrlRead($formater) <> $GUI_CHECKED) Then

		MsgBox(4096, "", Translate("Please choose a FAT32 or FAT formated key or check the formating option"))

		; State is NOT OK (no selected key)
		GUICtrlSetData($label_max, "?? " & Translate("MB"))
		Step1_Check("bad")

		; State for step 3 is NOT OK according to step 1
		GUICtrlSetData($label_max, "?? " & Translate("MB"))
		GUICtrlSetLimit($slider, 0, 0)
		Step3_Check("bad")
	ElseIf $file_set_mode = "img" Then
		Step3_Check("good")
		GUICtrlSetState($slider, $GUI_DISABLE)
		GUICtrlSetState($slider_visual, $GUI_DISABLE)
		If DriveSpaceTotal($usb_letter) > Round(FileGetSize($file_set)/1048576,1) Then
			Step1_Check("good")
		Else
			Step1_Check("bad")
		EndIf
	Else
		If ( $usb_filesystem = "") Then
			MsgBox(4096, "", Translate("No disk selected"))
		EndIf
		; State is NOT OK (no selected key)
		GUICtrlSetData($label_max, "?? " & Translate("MB"))
		Step1_Check("bad")

		; State for step 3 is NOT OK according to step 1
		GUICtrlSetData($label_max, "?? " & Translate("MB"))
		GUICtrlSetLimit($slider, 0, 0)
		Step3_Check("bad")

	EndIf
	SendReport("End-GUI_Choose_Drive")
EndFunc   ;==>GUI_Choose_Drive

Func GUI_Refresh_Drives()
	Refresh_DriveList()
EndFunc   ;==>GUI_Refresh_Drives

Func GUI_Dropped_File($hWnd, $msgID, $wParam, $lParam)
    Local $nSize, $pFileName,$dropped_drive, $dropped_dir, $dropped_filename, $dropped_extension
    Local $nAmt = DllCall("shell32.dll", "int", "DragQueryFile", "hwnd", $wParam, "int", 0xFFFFFFFF, "ptr", 0, "int", 255)
    For $i = 0 To $nAmt[0] - 1
        $nSize = DllCall("shell32.dll", "int", "DragQueryFile", "hwnd", $wParam, "int", $i, "ptr", 0, "int", 0)
        $nSize = $nSize[0] + 1
        $pFileName = DllStructCreate("char[" & $nSize & "]")
        DllCall("shell32.dll", "int", "DragQueryFile", "hwnd", $wParam, "int", $i, "ptr", DllStructGetPtr($pFileName), "int", $nSize)
        $dropped_file = DllStructGetData($pFileName, 1)
		$dropped_extension = get_extension($dropped_file)
		If $dropped_extension = ".iso" OR $dropped_extension = ".img" OR $dropped_extension = ".zip" then
			SendReport("GUI_Dropped_File : Dropped file "&$dropped_file&" (extension is OK)")
			Sleep(200)
			GUI_Show_Step2_Default_Menu()
			GUI_Hide_Back_Button()
			Sleep(100)
			GUI_Choose_ISO($dropped_file)
			Return ""
		EndIf
        $pFileName = 0
    Next
EndFunc


Func GUI_Choose_ISO_From_GUI()
	GUI_Choose_ISO(0)
EndFunc

Func GUI_Choose_ISO($source_file)
	SendReport("Start-GUI_Choose_ISO")
	if $source_file==0 Then
		$source_file = FileOpenDialog(Translate("Please choose an ISO image of LinuxLive CD"), "", "ISO / IMG / ZIP (*.iso;*.img;*.zip)", 1,"",$CONTROL_GUI)
		; FileOpenDialog is slow to return sometimes
		If @error Then
			if IsString($file_set) Then
				Return ""
			Else
				SendReport("IN-ISO_AREA (no iso)")
				MsgBox(4096, "", Translate("No file selected"))
				$file_set = 0;
				Step2_Check("bad")
				GUI_Show_Step2_Default_Menu()
			EndIf
		Else
			$file_set = $source_file
			if get_extension($source_file) = "zip" Then
				; This will check if it's a ZIP file containing only an ISO
				InitializeFilesInISO($source_file)
				if isArray($files_in_source) Then
					If Ubound($files_in_source)=1 AND get_extension($files_in_source[0])= "iso" Then
						SendReport("The ZIP file contains only an ISO => it will be uncompressed")
						MsgBox(64,Translate("Please read"),Translate("This ZIP file contains only an ISO")&"."&Translate("Please unzip it and retry with this ISO instead")&".")
						Return 0
					EndIf
				EndIf
			EndIf
			$release_arch = AutoDetectArchitecture($file_set)
			Check_source_integrity($file_set)
		EndIf
	EndIf

	SendAppviewStats(get_extension($source_file)&" as source")

	SendReport("End-GUI_Choose_ISO")
EndFunc   ;==>GUI_Choose_ISO

Func GUI_Choose_CD()
	SendReport("Start-GUI_Choose_CD")
	SendAppviewStats("CD/folder as source")
	#cs
		TODO : Recode support for CD
		MsgBox(16, "Sorry", "Sorry but CD Support is broken. Please use ISO or Download button.")
		Step2_Check("bad")
		$file_set = 0;
		Return ""
	#ce

	$folder_file = FileSelectFolder(Translate("Please choose a CD of LinuxLive Live or its folder"), "")
	If @error Then
		SendReport("IN-CD_AREA (no CD)")
		MsgBox(4096, "", Translate("No folder or CD selected"))
		Step2_Check("bad")
		$file_set = 0;
	Else
		SendReport("IN-CD_AREA (CD selected :" & $folder_file & ")")
		$file_set = $folder_file;
		$file_set_mode = "folder"

		; If user already select to force some install parameters
		If ReadSetting("Install_Parameters","automatic_recognition")<>"yes" Then
			$forced_description=ReadSetting("Install_Parameters","use_same_parameter_as")
			$release_number = FindReleaseFromDescription($forced_description)
			if $release_number <> -1 Then
				Step2_Check("good")
				$step2_display_menu = 1
				GUI_Hide_Step2_Default_Menu()
				GUI_Show_Back_Button()
				Sleep(100)
				GUI_Show_Check_status(Translate("Verifying") & " OK"&@CRLF& Translate("This version is compatible and its integrity was checked")&@CRLF&Translate("Recognized Linux")&" : "&@CRLF& @CRLF & @TAB &ReleaseGetDescription($release_number))
				Check_If_Default_Should_Be_Used()
			EndIf
			SendReport("IN-GUI_Choose_CD (forced install parameters to : "&$forced_description&" - Release # :"&$release_number&")")
			Return ""
		EndIf

		Disable_Persistent_Mode()

		;Check_folder_integrity($folder_file)

		; Used to avoid redrawing the old elements of Step 2 (ISO, CD and download)
		$step2_display_menu = 1
		GUI_Hide_Step2_Default_Menu()
		GUI_Show_Back_Button()
		$temp_index = FindReleaseFromCodename("default")
		$release_number = $temp_index
		GUI_Show_Check_status(Translate("This Linux is not in the compatibility list")& "." & @CRLF &Translate("However, LinuxLive USB Creator will try to use same install parameters as for") & @CRLF & @CRLF & @TAB & ReleaseGetDescription($release_number))
		Step2_Check("good")
	EndIf
	SendReport("End-GUI_Choose_CD")
EndFunc   ;==>GUI_Choose_CD

Func GUI_Download()
	SendReport("Start-GUI_Download")
	$file_set = 0
	; Used to avoid redrawing the old elements of Step 2 (ISO, CD and download)
	$step2_display_menu = 1
	GUI_Hide_Step2_Default_Menu()

	;$cleaner = GUICtrlCreateLabel("", 38 + $offsetx0, 238 + $offsety0, 300, 30)
	;GUICtrlSetState($cleaner, $GUI_SHOW)
	;GUICtrlSetState($cleaner,$GUI_HIDE)

	if NOT $combo_linux Then
		$combo_linux = GUICtrlCreateCombo(">> " & Translate("Select your favourite Linux"), 38 + $offsetx0, 240 + $offsety0, 300, -1, BitOR($CBS_DROPDOWNLIST, $WS_VSCROLL))
		GUICtrlSetOnEvent(-1, "GUI_Select_Linux")
		GUICtrlSetState($combo_linux, $GUI_SHOW)

		GUICtrlSetData($combo_linux, $prefetched_linux_list)

		$download_label2 = GUICtrlCreateLabel(Translate("Download"), 38 + $offsetx0 + 110, 210 + $offsety0 + 55, 150)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		GUICtrlSetColor(-1, 0xFFFFFF)
		GUICtrlSetFont(-1, 10)

		$download_manual = GUICtrlCreateButton(Translate("Manually"), 38 + $offsetx0 + 20, 235 + $offsety0 + 50, 110)
		GUICtrlSetOnEvent(-1, "GUI_Download_Manually")
		GUICtrlSetState(-1, $GUI_DISABLE)

		$OR_label = GUICtrlCreateLabel(Translate("OR"), 38 + $offsetx0 + 135, 235 + $offsety0 + 55, 20)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		GUICtrlSetColor(-1, 0xFFFFFF)
		GUICtrlSetFont(-1, 10)
		$download_auto = GUICtrlCreateButton(Translate("Automatically"), 38 + $offsetx0 + 160, 235 + $offsety0 + 50, 110)
		GUICtrlSetOnEvent(-1, "GUI_Download_Automatically")
		GUICtrlSetState(-1, $GUI_DISABLE)
	Else
		GUI_Show_Step2_Download_Menu()
		GUICtrlSetState($combo_linux, $GUI_SHOW)
	Endif

	GUI_Show_Back_Button()

	SendReport("End-GUI_Download")
EndFunc   ;==>GUI_Download

Func GUI_Show_Back_Button()
	GUICtrlDelete($cleaner2)
	$BACK_AREA = GUICtrlCreateLabel("", 5 + $offsetx0, 300 + $offsety0, 32, 32)
	$DRAW_BACK = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BACK_PNG, 0, 0, 32, 32, 5 + $offsetx0, 300 + $offsety0, 32, 32)
	GUICtrlSetCursor($BACK_AREA, 0)
	GUICtrlSetOnEvent($BACK_AREA, "GUI_Back_Download")
EndFunc

Func GUI_Hide_Back_Button()
	;GUICtrlDelete($BACK_AREA)
	GUICtrlSetState($BACK_AREA, $GUI_HIDE)
	$cleaner2 = GUICtrlCreateLabel("", 5 + $offsetx0, 300 + $offsety0, 32, 32)
EndFunc

Func GUI_Show_Step2_Download_Menu()
	GUICtrlSetState($download_manual, $GUI_SHOW)
	GUICtrlSetState($download_auto, $GUI_SHOW)
	GUICtrlSetState($label_step2_status, $GUI_HIDE)
	GUICtrlSetState($download_label2, $GUI_SHOW)
	GUICtrlSetState($OR_label, $GUI_SHOW)
	GUICtrlSetState($combo_linux, $GUI_SHOW)
EndFunc

Func GUI_Hide_Step2_Download_Menu()
	;_ProgressDelete($progress_bar)
	GUICtrlSetState($combo_linux, $GUI_HIDE)
	GUICtrlSetState($download_manual, $GUI_HIDE)
	GUICtrlSetState($download_auto, $GUI_HIDE)
	GUICtrlSetState($label_step2_status, $GUI_HIDE)
	GUICtrlSetState($download_label2, $GUI_HIDE)
	GUICtrlSetState($OR_label, $GUI_HIDE)
	$cleaner = GUICtrlCreateLabel("", 38 + $offsetx0, 238 + $offsety0, 300, 30)
	GUICtrlSetState($cleaner, $GUI_SHOW)
	GUICtrlDelete($cleaner)
EndFunc

Func GUI_Show_Step2_Default_Menu()
	GUICtrlSetState($ISO_AREA, $GUI_SHOW)
	GUICtrlSetState($CD_AREA, $GUI_SHOW)
	GUICtrlSetState($DOWNLOAD_AREA, $GUI_SHOW)
	GUICtrlSetState($label_cd, $GUI_SHOW)
	GUICtrlSetState($label_download, $GUI_SHOW)
	GUICtrlSetState($label_iso, $GUI_SHOW)
	GUICtrlSetState($cleaner, $GUI_HIDE)
	GUICtrlSetState($cleaner2, $GUI_HIDE)
	$step2_display_menu = 0
	$DRAW_CD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $CD_PNG, 0, 0, 75, 75, 146 + $offsetx0, 231 + $offsety0, 75, 75)
	$DRAW_DOWNLOAD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $DOWNLOAD_PNG, 0, 0, 75, 75, 260 + $offsetx0, 230 + $offsety0, 75, 75)
	$DRAW_ISO = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $ISO_PNG, 0, 0, 75, 75, 38 + $offsetx0, 231 + $offsety0, 75, 75)
	GUICtrlSetState($cleaner2, $GUI_SHOW)
EndFunc

Func GUI_Hide_Step2_Default_Menu()
	; hiding old elements
	GUICtrlSetState($ISO_AREA, $GUI_HIDE)
	GUICtrlSetState($CD_AREA, $GUI_HIDE)
	GUICtrlSetState($DOWNLOAD_AREA, $GUI_HIDE)
	GUICtrlSetState($label_cd, $GUI_HIDE)
	GUICtrlSetState($label_download, $GUI_HIDE)
	GUICtrlSetState($label_iso, $GUI_HIDE)
EndFunc


Func GUI_Back_Download()
	SendReport("Start-GUI_Back_Download")
	Global $label_step2_status,$label_step2_status2
	Global $current_download,$progress_bar
	InetClose($current_download)
	GUI_Hide_Step2_Download_Menu()
	GUI_Hide_Back_Button()
	GUICtrlSetState($label_step2_status,$GUI_HIDE)
	GUICtrlSetState($label_step2_status2,$GUI_HIDE)
	_ProgressDelete($progress_bar)
	; Showing old elements again
	GUI_Show_Step2_Default_Menu()
	SendReport("End-GUI_Back_Download")
EndFunc   ;==>GUI_Back_Download

Func GUI_Select_Linux()
	SendReport("Start-GUI_Select_Linux")
	$selected_linux = GUICtrlRead($combo_linux)

	If StringInStr($selected_linux, ">>") = 0 Then
		$release_in_list = FindReleaseFromDescription($selected_linux)
		if ReleaseGetMirrorStatus($release_in_list)> 0 Then
			GUICtrlSetState($download_manual, $GUI_ENABLE)
			GUICtrlSetState($download_auto, $GUI_ENABLE)
		Else
			GUICtrlSetState($download_manual, $GUI_ENABLE)
			GUICtrlSetState($download_auto, $GUI_DISABLE)
		EndIf
	Else
		MsgBox(48, Translate("Please read"), Translate("Please select a linux to continue"))
		GUICtrlSetState($download_manual, $GUI_DISABLE)
		GUICtrlSetState($download_auto, $GUI_DISABLE)
	EndIf
	SendReport("End-GUI_Select_Linux")
EndFunc   ;==>GUI_Select_Linux

Func GUI_Download_Automatically()
	$selected_linux = GUICtrlRead($combo_linux)
	SendReport("Start-GUI_Download_Automatically (Downloading : "&$selected_linux&" )")
	SendAppviewStats("Downloading ISO (Automatic)")
	$release_in_list = FindReleaseFromDescription($selected_linux)
	DownloadRelease($release_in_list, 1)
	SendReport("End-GUI_Download_Automatically")
EndFunc   ;==>GUI_Download_Automatically

Func GUI_Download_Manually()
	$selected_linux = GUICtrlRead($combo_linux)
	SendReport("Start-GUI_Download_Manually (Downloading "&$selected_linux&" )")
	SendAppviewStats("Downloading ISO (Manually)")
	$release_in_list = FindReleaseFromDescription($selected_linux)
	if ReleaseGetMirrorStatus($release_in_list)> 0 Then
		DownloadRelease($release_in_list, 0)
	Else
		ShellExecute(ReleaseGetDownloadPage($release_in_list))
	EndIf
	SendReport("End-GUI_Download_Manually")
EndFunc   ;==>GUI_Download_Manually

Func DownloadRelease($release_in_list, $automatic_download)
	SendReport("Start-DownloadRelease")
	Local $latency[50], $i, $mirror, $available_mirrors = 0, $tested_mirrors = 0

	GUI_Hide_Step2_Download_Menu()

	GUI_Show_Back_Button()
	;$BACK_AREA = GUICtrlCreateLabel("", 5 + $offsetx0, 300 + $offsety0, 32, 32)
	;$DRAW_BACK = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BACK_PNG, 0, 0, 32, 32, 5 + $offsetx0, 300 + $offsety0, 32, 32)
	;GUICtrlSetCursor($BACK_AREA, 0)
	;GUICtrlSetOnEvent($BACK_AREA, "GUI_Back_Download")

	$progress_bar = _ProgressCreate(38 + $offsetx0, 238 + $offsety0, 300, 30)
	_ProgressSetImages($progress_bar, "progress_green.jpg", "progress_background.jpg")
	_ProgressSetFont($progress_bar, "", -1, -1, 0x000000, 0)

	;_ITaskBar_SetProgressState($GUI, 2)

	$label_step2_status = GUICtrlCreateLabel(Translate("Looking for the fastest mirror"), 38 + $offsetx0, 231 + $offsety0 + 50, 300, 80)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, 0xFFFFFF)
	UpdateStatusStep2("Looking for the fastest mirror")

	$available_mirrors = ReleaseGetMirrorStatus($release_in_list)

	SendReport($available_mirrors&" mirrors are available for testing")

	if IsArray($_Progress_Bars) Then _Paint_Bars_Procedure2()

	For $i=0 To 9
		$mirror = ReleaseGetMirror($release_in_list,$i)
		If $mirror <> "" Then
			$percent_tested = Round($tested_mirrors * 100 / $available_mirrors,0)
			_ProgressSet($progress_bar, $percent_tested)
			_ProgressSetText($progress_bar, Translate("Testing mirror") & " : " & URLToHostname($mirror))
			;_ITaskBar_SetProgressValue($GUI, $percent_tested)
			; Old Method
			;$temp_latency = Ping(URLToHostname($mirror))
			;$command="ping-"&$mirror
			;SendReport($command)

			$tested_mirrors = $tested_mirrors + 1
			$timeout=TimerInit()

			;While StringInStr($ping_result,$command)<=0 AND TimerDiff($timeout)<12000
			;	Sleep(30)
			;Wend
			Local $timer_init,$temp_size=0
			$timer_init = TimerInit()
			$temp_size = InetGetSize($mirror,3)
			$ping_latency=TimerDiff($timer_init)
			$temp_size = Round($temp_size / 1048576)
			If $temp_size < 5 Or $temp_size > 8000 Then
				$temp_latency = 10000
			Else
				$temp_latency=Int($ping_latency)
			EndIf

			#cs Old method
			if StringInStr($ping_result,$command)<=0 Then
				$temp_latency = 10000
			Else
				$result = StringReplace($ping_result,$command&"=","")
				$temp_latency=Int($result)
			Endif
			#ce
		Else
			$temp_latency = 10000
		EndIf
		$latency[$i] = $temp_latency
	Next

	SendReport("Before _ArrayMin on latencies")
	$arraymin = _ArrayMin($latency, 1, 0, 9)
	SendReport("After _ArrayMin on latencies")

	_ProgressSet($progress_bar, 100)
	;_ITaskBar_SetProgressState($GUI)

	If $arraymin = 10000 Then
		UpdateStatusStep2(Translate("No online mirror found") & " !" & @CRLF & Translate("Please check your internet connection or try with another linux"))
		Sleep(3000)
	Else
		SendReport("Before _ArrayMinIndex on latencies")
		$arrayminindex = _ArrayMinIndex($latency, 1, 0, 9)
		SendReport("After _ArrayMinIndex on latencies")
		$best_mirror = ReleaseGetMirror($release_in_list,$arrayminindex)
		If $automatic_download = 0 Then
			; Download manually
			UpdateStatusStep2("Select this file as the source when download will be completed")
			DisplayMirrorList($latency, $release_in_list)
		Else
			; Download automatically
			$iso_size = InetGetSize($best_mirror,3)
			$filename = unix_path_to_name($best_mirror)

			Do
				$download_folder = FileSelectFolder ( "Please select destination folder for this download", "",-1,"",$CONTROL_GUI)
				if @error OR StringInStr(FileGetAttrib($download_folder),"D")>0 then ExitLoop
			Until 0

			;AND StringInStr($download_folder,":")>0

			$temp_filename = $download_folder&"\"&$filename&".lili-download"
			SendReport("Downloading Linux to "&$download_folder&"\"&$filename)

			$current_download = InetGet($best_mirror, $temp_filename, 3, 1)
			If InetGetInfo($current_download, 4)=0 Then
				UpdateStatusStep2(Translate("Downloading") & " " & $filename & @CRLF & Translate("from") & " " & URLToHostname($best_mirror))
				Download_State()
			Else
				UpdateStatusStep2(Translate("Error while trying to download") & @CRLF & Translate("Please check your internet connection or try with another linux"))
				Sleep(3000)
				_ProgressDelete($progress_bar)
				GUI_Back_Download()
			EndIf
		EndIf
	EndIf

	SendReport("End-DownloadRelease")
EndFunc   ;==>DownloadRelease

; Let the user select a mirror
Func DisplayMirrorList($latency_table, $release_in_list)
	Local $hImage, $hListView

	; Create GUI
	Opt("GUIOnEventMode", 0)
	AdlibUnRegister("Control_Hover")
	$gui_mirrors = GUICreate("Select the mirror", 350, 250)
	$hListView = GUICtrlCreateListView("  " & Translate("Latency") & "  |  " & Translate("Server Name") & "  | ", 0, 0, 350, 200)
	_GUICtrlListView_SetColumnWidth($hListView, 0, 80)
	_GUICtrlListView_SetColumnWidth($hListView, 1, 230)
	$hImage = _GUIImageList_Create()
	$copy_it = GUICtrlCreateButton(Translate("Copy link"), 30, 210, 120, 30)
	$launch_it = GUICtrlCreateButton(Translate("Launch in my browser"), 180, 210, 150, 30)


	Local $latency_server[10][3]
	For $i = 0 To 9
		$mirror = ReleaseGetMirror($release_in_list,$i)
		If $mirror <> "NotFound" AND $mirror <> "" Then
			$latency_server[$i][0] = $latency_table[$i]
			$latency_server[$i][1] = URLToHostname($mirror)
			$latency_server[$i][2] = $mirror
		EndIf
	Next

	_GUICtrlListView_EnableGroupView($hListView)
	_GUICtrlListView_InsertGroup($hListView, -1, 1, Translate("Best mirrors"))
	_GUICtrlListView_InsertGroup($hListView, -1, 2, Translate("Good mirrors"))
	_GUICtrlListView_InsertGroup($hListView, -1, 3, Translate("Bad mirrors"))
	_GUICtrlListView_InsertGroup($hListView, -1, 4, Translate("Dead mirrors"))

	_ArraySort($latency_server, 0, 0, 0, 0)

	; Add items
	$item = 0
	For $i = 0 To 9
		If $latency_server[$i][2] Then
			$latency = $latency_server[$i][0]
			GUICtrlCreateListViewItem($latency & " | " & $latency_server[$i][1] & " |" & $latency_server[$i][2], $hListView)
			If $latency < 60 Then
				_GUICtrlListView_SetItemGroupID($hListView, $item, 1)
				_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($hListView, 0x00FF00, 16, 16))
			ElseIf $latency < 150 Then
				_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($hListView, 0x00FF00, 16, 16))
				_GUICtrlListView_SetItemGroupID($hListView, $item, 2)
			ElseIf $latency < 10000 Then
				_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($hListView, 0xFF0000, 16, 16))
				_GUICtrlListView_SetItemGroupID($hListView, $item, 3)
			Else
				_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($hListView, 0x000000, 16, 16))
				_GUICtrlListView_SetItemGroupID($hListView, $item, 4)
			EndIf
			$item = $item + 1
		EndIf
	Next

	_GUICtrlListView_SetImageList($hListView, $hImage, 1)
	_GUICtrlListView_HideColumn($hListView, 2)
	GUISetState(@SW_SHOW,$gui_mirrors)

	; Loop until user exits
	while 1
		$msg = GUIGetMsg()
		If $msg = $GUI_EVENT_CLOSE Then ExitLoop

		If $msg = $copy_it Then
			If GUICtrlRead($hListView) Then
				$item_selected = GUICtrlRead(GUICtrlRead($hListView))
				$url_for_download_temp = StringSplit($item_selected, "|")
				$url_for_download = $url_for_download_temp[UBound($url_for_download_temp) - 2]
				ClipPut(StringStripWS($url_for_download, 3))
			Else
				ClipPut($best_mirror)
			EndIf
		ElseIf $msg = $launch_it Then
			If GUICtrlRead($hListView) Then
				$item_selected = GUICtrlRead(GUICtrlRead($hListView))
				$url_for_download_temp = StringSplit($item_selected, "|")
				$url_for_download = $url_for_download_temp[UBound($url_for_download_temp) - 2]
				ShellExecute(StringStripWS($url_for_download, 3))
			Else
				ShellExecute($best_mirror)
			EndIf
		EndIf

	wend
	Opt("GUIOnEventMode", 1)
	GUIDelete($gui_mirrors)
	AdlibRegister("Control_Hover", 150)
	GUIRegisterMsg($WM_PAINT, "DrawAll")
	WinActivate($for_winactivate)
	GUISetState($GUI_SHOW, $CONTROL_GUI)
EndFunc   ;==>DisplayMirrorList

Func Download_State()
	SendReport("Start-Download_State")
	Global $current_download
	Local $begin, $oldgetbytesread, $estimated_time = ""

	if IsArray($_Progress_Bars) Then _Paint_Bars_Procedure2()

	$begin = TimerInit()
	$oldgetbytesread = InetGetInfo($current_download, 0)

	$iso_size_mb = RoundForceDecimal($iso_size / (1024 * 1024))
	;_ITaskBar_SetProgressState($GUI, 2)
	Do
		$percent_downloaded = Int((100 * InetGetInfo($current_download, 0) / $iso_size))
		_ProgressSet($progress_bar, $percent_downloaded)
		;_ITaskBar_SetProgressValue($GUI, $percent_downloaded)
		$dif = TimerDiff($begin)
		$newgetbytesread = InetGetInfo($current_download, 0)
		If $dif > 1000 Then
			$bytes_per_ms = ($newgetbytesread - $oldgetbytesread) / $dif
			$estimated_time = HumanTime(($iso_size - $newgetbytesread) / (1000 * $bytes_per_ms))
			$begin = TimerInit()
			$oldgetbytesread = $newgetbytesread
		EndIf
		_ProgressSetText($progress_bar, $percent_downloaded & "% ( " & RoundForceDecimal($newgetbytesread / (1024 * 1024)) & " / " & $iso_size_mb & " " & "MB" & " ) " & $estimated_time)
		Sleep(3000)
	Until InetGetInfo($current_download, 2)
	$file_set = StringReplace($temp_filename,".lili-download","")
	FileMove($temp_filename,$file_set)
	_ProgressSet($progress_bar, 100)
	_ProgressSetText($progress_bar, "100% ( " & Round($iso_size / (1024 * 1024)) & " / " & Round($iso_size / (1024 * 1024)) & " " & "MB" & " )")
	;_ITaskBar_SetProgressState($GUI)
	UpdateStatusStep2(Translate("Download complete") & @CRLF & Translate("Check will begin shortly"))
	Sleep(3000)
	_ProgressDelete($progress_bar)
	GUI_Hide_Step2_Download_Menu()


	Check_source_integrity($file_set)

	SendReport("End-Download_State")
EndFunc   ;==>Download_State

Func HumanTime($sec)
	If $sec <= 0 Then Return ""

	$hours = Floor($sec / 3600)
	If $hours > 5 Then Return ""

	$minutes = Floor($sec / 60) - $hours * 60
	$seconds = Floor($sec) - $minutes * 60

	; to avoid displaying bullshit
	If $minutes < 0 Or $hours < 0 Or $seconds < 0 Then Return ""

	If $sec > 3600 Then
		$human_time = $hours & "h " & $minutes & "m "
	ElseIf $sec <= 3600 And $sec > 60 Then
		$human_time = $minutes & "m " & $seconds & "s "
	ElseIf $sec <= 60 Then
		$human_time = $seconds & "s "
	EndIf
	Return $human_time
EndFunc   ;==>HumanTime


Func RoundForceDecimal($number)
	$rounded = Round($number, 1)
	If Not StringInStr($rounded, ".") Then
		Return $rounded & ".0"
	Else
		Return $rounded
	EndIf
EndFunc   ;==>RoundForceDecimal


Func GUI_Persistence_Slider()
	SendReport("Start-GUI_Persistence_Slider")
	If GUICtrlRead($slider) > 0 Then
		GUICtrlSetData($slider_visual, GUICtrlRead($slider) * 10)
		GUICtrlSetData($slider_visual_mode, Translate("(Persistent Mode)"))
		; State is OK (value > 0)
		Step3_Check("good")
	Else
		GUICtrlSetData($slider_visual, GUICtrlRead($slider) * 10)
		GUICtrlSetData($slider_visual_mode, Translate("(Live mode only)"))
		; State is OK but warning (value = 0)
		Step3_Check("warning")
	EndIf
	SendReport("End-GUI_Persistence_Slider")
EndFunc   ;==>GUI_Persistence_Slider

Func GUI_Persistence_Input()
	SendReport("Start-GUI_Persistence_Input")

	If StringIsInt(GUICtrlRead($slider_visual)) And GUICtrlRead($slider_visual) <= $usb_space_after_lili_MB And GUICtrlRead($slider_visual) > 0 Then
		GUICtrlSetData($slider, Round(GUICtrlRead($slider_visual) / 10))
		GUICtrlSetData($slider_visual_mode, Translate("(Persistent Mode)"))
		; State is  OK (persistent mode)
		Step3_Check("good")

	ElseIf StringIsInt(GUICtrlRead($slider_visual)) And GUICtrlRead($slider_visual) > $usb_space_after_lili_MB And GUICtrlRead($slider_visual) > 0 Then
		GUICtrlSetData($slider_visual, $usb_space_after_lili_MB)
		GUICtrlSetData($slider, $slider_visual)
		GUICtrlSetData($slider_visual_mode, Translate("(Persistent Mode)"))
		; State is  OK (persistent mode)
		Step3_Check("good")
	ElseIf GUICtrlRead($slider_visual) = 0 Then
		GUICtrlSetData($slider_visual_mode, Translate("(Live mode only)"))
		; State is WARNING (live mode only)
		Step3_Check("warning")
	Else
		GUICtrlSetData($slider, 0)
		GUICtrlSetData($slider_visual, 0)
		GUICtrlSetData($slider_visual_mode, Translate("(Live mode only)"))
		; State is WARNING (live mode only)
		Step3_Check("warning")
	EndIf
	SendReport("End-GUI_Persistence_Input")
EndFunc   ;==>GUI_Persistence_Input

Func GUI_Format_Key()
	SendReport("Start-GUI_Format_Key")

	GUICtrlSetData($label_max, $usb_space_after_lili_MB & " " & Translate("MB"))
	GUICtrlSetLimit($slider, $usb_space_after_lili_MB / 10, 0)

	If (( $usb_isvalid_filesystem Or GUICtrlRead($formater) == $GUI_CHECKED) And $usb_space_after_lili_MB > 0) Then
		; State is OK ( FAT32 or FAT format and 700MB+ free)
		GUICtrlSetData($label_max, $usb_space_after_lili_MB & " " & Translate("MB"))
		GUICtrlSetLimit($slider, Round($usb_space_after_lili_MB / 10), 0)
		Step1_Check("good")

	ElseIf (Not $usb_isvalid_filesystem And GUICtrlRead($formater) <> $GUI_CHECKED) Then
		MsgBox(4096, "", Translate("Please choose a FAT32 or FAT formated key or check the formating option"))
		GUICtrlSetData($label_max, "?? "&Translate("MB"))
		Step1_Check("bad")

	Else
		If ($usb_filesystem = "") Then
			MsgBox(4096, "", Translate("No disk selected"))
		EndIf
		;State is NOT OK (no selected key)
		GUICtrlSetData($label_max, "?? " & Translate("MB"))
		Step1_Check("bad")

	EndIf
	SendReport("End-GUI_Format_Key")
EndFunc   ;==>GUI_Format_Key

Func Refresh_Persistence()
	If (($usb_isvalid_filesystem Or GUICtrlRead($formater) == $GUI_CHECKED) And $usb_space_after_lili_MB > 0) Then
		; State is OK ( FAT32 or FAT format and 700MB+ free)
		GUICtrlSetData($label_max, $usb_space_after_lili_MB & " " & Translate("MB"))
		GUICtrlSetLimit($slider, Round($usb_space_after_lili_MB / 10), 0)

	ElseIf (NOT $usb_isvalid_filesystem And GUICtrlRead($formater) <> $GUI_CHECKED) Then
		GUICtrlSetData($label_max, "?? " & Translate("MB"))
	Else
		GUICtrlSetData($label_max, "?? " & Translate("MB"))
	EndIf
	GUI_Persistence_Slider()
EndFunc

Func GUI_Check_VirtualBox()
	If GUICtrlRead($virtualbox) == $GUI_CHECKED Then
		WriteSetting("Last_State","virtualization","yes")
	Else
		WriteSetting("Last_State","virtualization","no")
	EndIf
	Refresh_Persistence()
EndFunc

Func GUI_Check_HideFiles()
	If GUICtrlRead($hide_files) == $GUI_CHECKED Then
		WriteSetting("Last_State","hide_files","yes")
	Else
		WriteSetting("Last_State","hide_files","no")
	EndIf
EndFunc

Func GUI_Launch_Creation()
	GUICtrlSetState($combo,$GUI_DISABLE)
	Local $return=""

	if Not FileExists($usb_letter&"\") Then
		MsgBox(64,Translate("Please read"),Translate("Please insert your USB key back or select another one")&".")
		GUICtrlSetState($combo,$GUI_ENABLE)
		Return ""
	EndIf

	; to avoid to create the key twice in a row
	if $already_create_a_key >0 Then
		$return = MsgBox(33,Translate("Please read"),Translate("You have already created a key")&"."&@CRLF&Translate("Are you sure that you want to recreate one")&" ?")
		GUICtrlSetState($combo,$GUI_ENABLE)
		if $return == 2 Then Return ""
	EndIf

	SendReport("Start-GUI_Launch_Creation")
	InitLog()

	; Disable the controls and re-enable after creation
	; force cleaning old status (little bug fix)
	UpdateStatus("")
	Sleep(200)

	UpdateStatus("Start creation of LinuxLive USB")

	If $STEP1_OK >= 1 And $STEP2_OK >= 1 And $STEP3_OK >= 1 Then
		$annuler = 0
	Else
		$annuler = 2
		UpdateStatus("Please validate step 1 to 3")
	EndIf

	; Initializing log file, already initialized when using verbose_logging
	If ReadSetting( "General", "verbose_logging") <> "yes" Then InitLog()

	; Format option has been selected
	If (GUICtrlRead($formater) == $GUI_CHECKED) And $annuler <> 2 Then
		$annuler = 0
		$annuler = MsgBox(49, Translate("Please read") & "!!!", Translate("Are you sure you want to format this disk and lose your data") &" ?"& @CRLF & @CRLF & "       " & Translate("Label") & " : ( " & $usb_letter & " ) " & DriveGetLabel($usb_letter) & @CRLF & "       " & Translate("Size") & " : " & Round(DriveSpaceTotal($usb_letter) / 1024, 1) & " " & Translate("GB") & @CRLF & "       " & Translate("Formatted in") & " : " & DriveGetFileSystem($usb_letter) & @CRLF)
		If $annuler = 1 Then
			Format_FAT32()
			; Rechecking USB format
			USBInitializeVariables(StringLeft(GUICtrlRead($combo), 2))
			if NOT $usb_isvalid_filesystem Then
				UpdateStatus(Translate("Your device could not be formatted")&"."&@CRLF&Translate("Please close all open applications then try again")&".")
				GUICtrlSetState($combo,$GUI_ENABLE)
				return -1
			EndIf
		Else
			GUICtrlSetState($combo,$GUI_ENABLE)
		EndIf

	EndIf

	; Starting creation if not cancelled
	If $annuler <> 2 Then

		UpdateStatus("Step 1 to 3 OK")

		$options_stats=""
		$options_stats &= (GUICtrlRead($virtualbox) == $GUI_CHECKED) ? "&cd5=Yes" : "&cd5=No"
		$options_stats &= (GUICtrlRead($hide_files) == $GUI_CHECKED) ? "&cd6=Yes" : "&cd6=No"
		SendAppviewStats("Create Live USB",$options_stats)

		$usb_creation_timer=TimerInit()

		; Cleaning old installs only if needed
		If $file_set_mode <> "img" Then
			if InitializeFilesInSource($file_set)=-1 Then Return -1
			If GUICtrlRead($formater) <> $GUI_CHECKED Then Clean_old_installs()
		EndIf

		If GUICtrlRead($virtualbox) == $GUI_CHECKED Then $virtualbox_check = Download_virtualBox()

		; Uncompressing ou copying files on the key
		If $file_set_mode = "iso" Then
			Uncompress_ISO_on_key($file_set)
		ElseIf $file_set_mode = "folder" Then
			Create_Stick_From_CD($file_set)
		ElseIf $file_set_mode = "img" Then
			if Create_Stick_From_IMG($file_set)=-1 Then Return -1
		EndIf

		; If it's not an IMG file, we have to do all these things :
		If $file_set_mode <> "img" Then
			Rename_and_move_files()

			Create_persistence_file(GUICtrlRead($slider_visual), GUICtrlRead($hide_files))

			Create_boot_menu()

			Install_boot_sectors(GUICtrlRead($hide_files))

			; Create Autorun menu
			Create_autorun()

			CreateUninstaller()

			If GUICtrlRead($hide_files) == $GUI_CHECKED Then Hide_live_files()

			If GUICtrlRead($virtualbox) == $GUI_CHECKED And $virtualbox_check >= 1 Then

				If $virtualbox_check <> 2 Then Check_virtualbox_download()

				; maybe check downloaded file ?

				; Next step : installing vbox on the key

				Install_virtualbox_on_key()
				UpdateStatus("Applying VirtualBox settings")
				Setup_VBOX_for_VM()

				;Run($usb_letter & "\Portable-VirtualBox\Launch_usb.exe", @ScriptDir, @SW_HIDE)

			EndIf

		EndIf

		; Creation is now done
		UpdateStatus(Translate("Your LinuxLive key is now up and ready")&"!")
		$already_create_a_key+=1
		If GUICtrlRead($virtualbox) == $GUI_CHECKED And $virtualbox_check >= 1 Then Final_check()

		Sleep(1000)
		; Don't want it to show when using test builds
		if ReadSetting("General","unique_ID")<>"SVN" AND ReadSetting("Advanced","skip_finalhelp")="no" Then
			ShellExecute("http://www.linuxliveusb.com/help/guide/using-lili", "", "", "", 7)
		EndIf
		$usb_creation_duration = Round(TimerDiff($usb_creation_timer))
		SendCreationSpeedStats($usb_creation_duration)
		SendReport("Live USB Created in "&HumanTime(Round($usb_creation_duration/1000)))
	Else
		UpdateStatus("Please validate step 1 to 3")
		SendAppviewStats("Steps 1 to 3 not validated")
		GUICtrlSetState($combo,$GUI_ENABLE)
	EndIf
	SendReport("End-GUI_Launch_Creation")
	GUICtrlSetState($combo,$GUI_ENABLE)
EndFunc   ;==>GUI_Launch_Creation


Func GUI_Events()
	SendReport("Start-GUI_Events (GUI_CtrlID=" & @GUI_CtrlId & " )")
	Select
		Case @GUI_CtrlId = $GUI_EVENT_CLOSE
			GUI_Exit()
		Case @GUI_CtrlId = $GUI_EVENT_MINIMIZE
			GUISetState(@SW_MINIMIZE, @GUI_WinHandle)
			GUISetState(@SW_MINIMIZE, $GUI)
			GUISetState(@SW_MINIMIZE, $CONTROL_GUI)
		Case @GUI_CtrlId = $GUI_EVENT_RESTORE
			GUISetState($GUI_SHOW, @GUI_WinHandle)
			GUISetState($GUI_SHOW, $GUI)
			GUISetState($GUI_SHOW, $CONTROL_GUI)
			GUIRegisterMsg($WM_PAINT, "DrawAll")
			WinActivate($for_winactivate)
			ControlFocus("LiLi USB Creator", "", $REFRESH_AREA)
	EndSelect
	SendReport("End-GUI_Events")
EndFunc   ;==>GUI_Events

Func GUI_Events2()
	SendReport("Start-GUI_Events2 (GUI_CtrlID=" & @GUI_CtrlId & " )")
	Select
		Case @GUI_CtrlId = $GUI_EVENT_CLOSE
			GUIDelete(@GUI_WinHandle)
		Case @GUI_CtrlId = $GUI_EVENT_MINIMIZE
			GUISetState(@SW_MINIMIZE, @GUI_WinHandle)
		Case @GUI_CtrlId = $GUI_EVENT_RESTORE
			GUISetState(@SW_SHOW, @GUI_WinHandle)

	EndSelect
	SendReport("End-GUI_Events2")
EndFunc   ;==>GUI_Events2

Func GUI_Help()
	SendReport("Start-GUI_Help")
	If WinActive("LinuxLive USB Creator") Or WinActive("LiLi USB Creator") then
		ShellExecute("http://www.linuxliveusb.com/help")
	EndIf
	SendReport("End-GUI_Help")
EndFunc   ;==>GUI_Help_Step1

Func GUI_Help_Step1()
	SendReport("Start-GUI_Help_Step1")
	ShellExecute("http://www.linuxliveusb.com/help/guide/step1")
	SendReport("End-GUI_Help_Step1")
EndFunc   ;==>GUI_Help_Step1

Func GUI_Help_Step2()
	SendReport("Start-GUI_Help_Step2")
	ShellExecute("http://www.linuxliveusb.com/help/guide/step2")
	SendReport("End-GUI_Help_Step2")
EndFunc   ;==>GUI_Help_Step2

Func GUI_Help_Step3()
	SendReport("Start-GUI_Help_Step3")
	ShellExecute("http://www.linuxliveusb.com/help/guide/step3")
	SendReport("End-GUI_Help_Step3")
EndFunc   ;==>GUI_Help_Step3

Func GUI_Help_Step4()
	SendReport("Start-GUI_Help_Step4")
	ShellExecute("http://www.linuxliveusb.com/help/guide/step4")
	SendReport("End-GUI_Help_Step4")
EndFunc   ;==>GUI_Help_Step4

Func GUI_Help_Step5()
	SendReport("Start-GUI_Help_Step5")
	GUI_Options_Menu()
	;DebugOptions()
	SendReport("End-GUI_Help_Step5")
EndFunc   ;==>GUI_Help_Step5
