; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// VirtualBox Management                         ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


Global $vbox_settings_filepath = "\VirtualBox\Portable-VirtualBox\data\.VirtualBox\Machines\LinuxLive\LinuxLive.vbox"
Global $vboxwarn_return=0

Func VBox_CloseWarning()
	If ReadSetting("Advanced","skip_vboxwarning")="Yes" Then Return 0

	; If user click cancel the message won't appear again until lili is restarted
	if VBox_isRunning() AND $vboxwarn_return <> 2 Then
		$vboxwarn_return  = MsgBox(49,Translate("Please read"),Translate("VirtualBox is running and should be closed")&"."&@CRLF&@CRLF&"=> "&Translate("Close it then click OK")&"."&@CRLF&"=> "&Translate("Click cancel to ignore this warning")&".")
		if $vboxwarn_return==2 Then
			SendReport("Warning : VirtualBox is running and user has ignored it")
		Else
			SendReport("Warning : VirtualBox is running")
		EndIf
	EndIf
EndFunc

Func VBox_isRunning()
	if ProcessExists("VirtualBox.exe") Then
		Return True
	Else
		Return False
	EndIf
EndFunc

; Set recommended amount of RAM for LinuxLive VM
Func VBox_SetRam($recommended_ram)
	FileReplaceBetween($usb_letter&$vbox_settings_filepath,'Memory RAMSize="','"',$recommended_ram)
EndFunc

; Set specific storage controller for LinuxLive VM
Func VBox_SetStorageController($type_of_disk)
	FileReplaceBetween($usb_letter&$vbox_settings_filepath,'name="LILI-DISK" type="','"',$type_of_disk)
	FileReplaceBetween($usb_letter&$vbox_settings_filepath,'name="LILI-DISK" type="'&$type_of_disk&'" PortCount="','"',VBox_GetStorageControllerPortCount($type_of_disk))
EndFunc

; Set OS for LinuxLive (Mandatory for 64 bits OS !)
Func VBox_SetOSType($os_type)
	if $os_type="32-bit" Then
		$vbox_os_type="Linux"
	Elseif $os_type="64-bit" Then
		$vbox_os_type="Linux_64"
	Else
		$vbox_os_type=$os_type
	EndIf
	FileReplaceBetween($usb_letter&$vbox_settings_filepath,'OSType="','"',$vbox_os_type)
EndFunc

; Return default port count for storage controller type
Func VBox_GetStorageControllerPortCount($controller)
	if $controller = "PIIX4" Then
		Return 2
	Elseif $controller = "ICH6" Then
		Return 2
	Elseif $controller = "PIIX3" Then
		Return 2
	Elseif $controller = "LsiLogicSas" Then
		Return 8
	Elseif $controller = "AHCI" Then
		Return 16
	Else
		; For LsiLogic / BusLogic / SCSI
		Return 16
	EndIf
EndFunc