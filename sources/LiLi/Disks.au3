; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Disks Management                              ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func USBInitializeVariables($drive_letter)
	Global $usb_letter=$drive_letter
	Global $usb_filesystem=DriveGetFileSystem($usb_letter)
	Global $usb_space_total=DriveSpaceTotal($usb_letter)
	Global $usb_space_free=DriveSpaceFree($usb_letter)
	Global $usb_space_after_lili_MB=SpaceAfterLinuxLiveMB($usb_letter)
	Global $usb_isvalid_filesystem=isValidFilesystem($usb_filesystem)
EndFunc


Func Refresh_DriveList()
	SendReport("Start-Refresh_DriveList")
	$system_letter = StringLeft(@SystemDir, 2)
	; récupére la liste des disques
	$drive_list = DriveGetDrive("REMOVABLE")
	$all_drives = "|-> " & Translate("Choose a USB Key") & "|"
	If Not @error Then
		Dim $description[100]
		If IsArray($drive_list) AND UBound($drive_list) > 1 Then
			For $i = 1 To $drive_list[0]
				$label = DriveGetLabel($drive_list[$i])
				$fs = DriveGetFileSystem($drive_list[$i])
				$space = DriveSpaceTotal($drive_list[$i])
				If Not (($fs = "") Or ($space = 0) Or ($drive_list[$i] = $system_letter)) Then
					$all_drives &= StringUpper($drive_list[$i]) & " " & $label & " - " & $fs & " - " & Round($space / 1024, 1) & " " & Translate("GB") & "|"
				EndIf
			Next
		EndIf
	EndIf
	SendReport("Start-Refresh_DriveList-Removable Listed")
	$drive_list = DriveGetDrive("FIXED")
	If Not @error Then
		$all_drives &= "-> " & Translate("Hard drives") & " -------------|"
		Dim $description[100]
		If IsArray($drive_list) AND UBound($drive_list) > 1 Then
			For $i = 1 To $drive_list[0]
				$label = DriveGetLabel($drive_list[$i])
				$fs = DriveGetFileSystem($drive_list[$i])
				$space = DriveSpaceTotal($drive_list[$i])
				If Not (($fs = "") Or ($space = 0) Or ($drive_list[$i] = $system_letter)) Then
					$all_drives &= StringUpper($drive_list[$i]) & " " & $label & " - " & $fs & " - " & Round($space / 1024, 1) & " " & Translate("GB") & "|"
				EndIf
			Next
		EndIf
	EndIf
	SendReport("Start-Refresh_DriveList-2")
	If $all_drives <> "|-> " & Translate("Choose a USB Key") & "|" Then
		GUICtrlSetData($combo, $all_drives, "-> " & Translate("Choose a USB Key"))
		GUICtrlSetState($combo, $GUI_ENABLE)
	Else
		GUICtrlSetData($combo, "|-> " & Translate("No key found"), "-> " & Translate("No key found"))
		GUICtrlSetState($combo, $GUI_DISABLE)
	EndIf
	SendReport("End-Refresh_DriveList")
EndFunc   ;==>Refresh_DriveList

Func SpaceAfterLinuxLiveMB($disk)
	SendReport("Start-SpaceAfterLinuxLiveMB (Disk: " & $disk & " )")

	#cs
	If ReleaseGetCodename($release_number) = "default" Then
		$install_size = Round(FileGetSize($file_set) / 1048576) + 20
	Else
		$install_size = ReleaseGetInstallSize($release_number)
	EndIf
	#ce
	if get_extension($file_set)="iso" Then
		$install_size = Round(FileGetSize($file_set) / 1048576)+10
		SendReport("Install size from FileGetSize")
	Else
		$install_size = ReleaseGetInstallSize($release_number)
		SendReport("Install size from ReleaseGetSize")
	EndIf


	SendReport("Install size = "&$install_size&" - vbox size = "&$virtualbox_size)

	If GUICtrlRead($virtualbox) == $GUI_CHECKED Then
		; Need some MB for VirtualBox
		$install_size = $install_size + $virtualbox_size
	EndIf

	SendReport("Install size (with vbox added)= "&$install_size)


	If GUICtrlRead($formater) == $GUI_CHECKED Then
		$spacefree = DriveSpaceTotal($disk) - $install_size
		If $spacefree >= 0 And $spacefree <= $max_persistent_size Then
			SendReport("Space free = "&$spacefree&" - rounded spacefree = "&Round($spacefree / 10, 0) * 10)
			Return Round($spacefree / 10, 0) * 10
		ElseIf $spacefree >= 0 And $spacefree > $max_persistent_size Then
			SendReport("End-SpaceAfterLinuxLiveMB (Free : "&$max_persistent_size&"MB )")
			Return $max_persistent_size
		Else
			SendReport("End-SpaceAfterLinuxLiveMB (Free : 0MB )")
			Return 0
		EndIf
	Else
		$previous_installsize=GetPreviousInstallSizeMB($disk)
		$spacefree = DriveSpaceFree($disk) + $previous_installsize - $install_size
		SendReport("Space free = "&$spacefree&" (drivespacefree = "&DriveSpaceFree($disk)& " + $previous_installsize = "&$previous_installsize&" ---- $install_size ="&$install_size )
		If $spacefree >= 0 And $spacefree <= $max_persistent_size Then
			$rounded=Round($spacefree / 10, 0) * 10
			SendReport("End-SpaceAfterLinuxLiveMB (Free : "&$rounded&"MB - Previous install : "&$previous_installsize&"MB)")
			Return $rounded
		ElseIf $spacefree >= 0 And $spacefree > $max_persistent_size Then
			SendReport("End-SpaceAfterLinuxLiveMB (Free : "&$max_persistent_size&"MB )")
			Return $max_persistent_size
		Else
			SendReport("End-SpaceAfterLinuxLiveMB (Free : 0MB )")
			Return 0
		EndIf
	EndIf
EndFunc   ;==>SpaceAfterLinuxLiveMB

Func SpaceAfterLinuxLiveGB($disk)
	$space=Round(SpaceAfterLinuxLiveMB($disk)/1024,1)
	Return $space
EndFunc   ;==>SpaceAfterLinuxLiveGB

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Fetching Physical disks                       ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; returns the physical disk (\\.\PhysicalDiskX) corresponding to a drive letter
Func GiveMePhysicalDisk($drive_letter)
	UpdateLog("Start-GiveMePhysicalDisk of : "&$drive_letter)
	$drive_infos = _WinAPI_GetDriveNumber($drive_letter)
	If NOT @error AND IsArray($drive_infos) Then
		UpdateLog("End-GiveMePhysicalDisk ( SUCCESS : "&$drive_letter&" is on physical disk "&$drive_infos[1]&" )")
		Return $drive_infos[1]
	Else
		UpdateLog("IN-GiveMePhysicalDisk ( WARNING : Falling back to WMI Mode )")
		Return GiveMePhysicalDiskWMI($drive_letter)
	EndIf
EndFunc

Func GiveMePhysicalDiskWMI($drive_letter)
	Local $physical_drive,$g_eventerror

	UpdateLog("Start-GiveMePhysicalDiskWMI of : "&$drive_letter)

	Local $wbemFlagReturnImmediately, $wbemFlagForwardOnly, $objWMIService, $colItems, $objItem, $found_usb, $usb_model, $usb_size
	$wbemFlagReturnImmediately = 0x10
	$wbemFlagForwardOnly = 0x20
	$colItems = ""

	$objWMIService = ObjGet("winmgmts:\\.\root\CIMV2")
	if @error OR $g_eventerror OR NOT IsObj($objWMIService) Then
		UpdateLog("IN-GiveMePhysicalDiskWMI ( ERROR with WMI : Trying alternate method (WMI impersonation) )")
		$g_eventerror =0
		$objWMIService = ObjGet("winmgmts:{impersonationLevel=Impersonate}!//.")
	EndIf

	if @error OR $g_eventerror then
		UpdateLog("IN-GiveMePhysicalDiskWMI ( ERROR with WMI )")
	Elseif IsObj($objWMIService) Then
		UpdateLog("IN-GiveMePhysicalDiskWMI ( WMI seems to work )")

		$colItems = $objWMIService.ExecQuery("SELECT Caption, DeviceID FROM Win32_DiskDrive", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)

		For $objItem In $colItems

			$colItems2 = $objWMIService.ExecQuery("ASSOCIATORS OF {Win32_DiskDrive.DeviceID='" & $objItem.DeviceID & "'} WHERE AssocClass = Win32_DiskDriveToDiskPartition", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
			For $objItem2 In $colItems2
				$colItems3 = $objWMIService.ExecQuery("ASSOCIATORS OF {Win32_DiskPartition.DeviceID='" & $objItem2.DeviceID & "'} WHERE AssocClass = Win32_LogicalDiskToPartition", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
				For $objItem3 In $colItems3
					If $objItem3.DeviceID = $drive_letter Then
						$physical_drive = $objItem.DeviceID
					EndIf
				Next
			Next

		Next

	Else
		UpdateLog("IN-GiveMePhysicalDiskWMI ( ERROR with WMI : object not created, cannot find PhysicalDisk)")
	endif

	if $physical_drive Then
		$physical_drive_number=StringReplace($physical_drive,"\\.\PHYSICALDRIVE","")
		UpdateLog("End-GiveMePhysicalDiskWMI ( SUCCESS : "&$drive_letter&" is on physical disk "&$physical_drive_number&" )")
		Return $physical_drive_number
	Else
		UpdateLog("End-GiveMePhysicalDiskWMI ( ERROR : No physical disk found for: "& $drive_letter&" )")
		Return "ERROR"
	EndIf
EndFunc

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Fetching Signature of disks drive (a.k.a MBR ID in MBR mode)/////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func Get_MBR_ID($drive_letter,$clean_trailing_zeroes=1)
	UpdateLog("Start-Get_MBR_ID of : "&$drive_letter)
	$mbrid_temp = _WinAPI_GetDriveSignature($drive_letter)
	if Not @error Then
		if $mbrid_temp <> "0" AND $clean_trailing_zeroes = 1 Then
			$mbrid_temp = StringLower(CleanTrailingZeroes($mbrid_temp))
		EndIf
		UpdateLog("END-Get_MBR_ID ( SUCCESS : MBR ID of "&$drive_letter&" is "&$mbrid_temp&" )")
		Return $mbrid_temp
	Else
		UpdateLog("END-Get_MBR_ID ( WARNING : Falling back to WMI Mode )")
		Return Get_MBR_ID_WMI($drive_letter,$clean_trailing_zeroes=1)
	EndIf
EndFunc

Func _WinAPI_GetDriveSignature($sDrive)
	; Needs WinAPI.au3
	; Based on work from KaFu and JFX (http://www.autoitscript.com/forum/topic/136907-need-help-with-ioctl-disk-get-drive-layout-ex/)
	$_DRIVE_LAYOUT = DllStructCreate('dword PartitionStyle; dword PartitionCount; byte union[40]; byte PartitionEntry[8192]')
	$hDrive = _WinAPI_CreateFileEx('\\.\' & $sDrive, 2,0)
	if $hDrive = 0 Then Return "ERROR"

	Local $Ret = DllCall("kernel32.dll", "int", "DeviceIoControl", "hwnd", $hDrive, "dword", 0x00070050, "ptr", 0, "dword", 0, "ptr", DllStructGetPtr($_DRIVE_LAYOUT), "dword", DllStructGetSize($_DRIVE_LAYOUT), "dword*", 0, "ptr", 0)
	If __CheckErrorCloseHandle($Ret, $hDrive) Then Return "ERROR"

	Switch DllStructGetData($_DRIVE_LAYOUT, "PartitionStyle")
		Case 0 ; MBR
			$data = DllStructGetData($_DRIVE_LAYOUT, "union")
			$binaryStruct = DllStructCreate('byte[8192]')
			DllStructSetData($binaryStruct, 1, $data)
			$DriveMBRInfo = DllStructCreate('ULONG Signature;', DllStructGetPtr($binaryStruct))
			$mbr_signature = Hex(DllStructGetData($DriveMBRInfo, "Signature"), 8)
			Return $mbr_signature
		Case 1 ; GPT
			$data = DllStructGetData($_DRIVE_LAYOUT, "union")
			$binaryStruct = DllStructCreate('byte[8192]')
			DllStructSetData($binaryStruct, 1, $data)
			$DriveGPTInfo = DllStructCreate('byte Guid[16]; int64 StartingUsableOffset;int64 UsableLength;ulong MaxPartitionCount;', DllStructGetPtr($binaryStruct))
			$GUID = StringLower(DllStructGetData($DriveGPTInfo, "Guid"))
			If StringLeft($GUID, 2) = '0x' Then $GUID = StringTrimLeft($GUID, 2)
			Return $GUID
			; Use this code to format GUID like that : {11139dac-cc66-3247-be07-28480bbf}
			; Return '{' & StringLeft($GUID, 8) & '-' & StringMid($GUID, 9, 4) & '-' & StringMid($GUID, 13, 4) & '-' & StringMid($GUID, 17, 4) & '-' & StringRight($GUID, 8) & '}'
		Case 2 ; RAW (no signature / no letter ...)
			Return "RAW"
		Case Else
			Return "ERROR"
	EndSwitch
EndFunc

Func _WinAPI_GetDrivePartitionTableType($sDrive)
	; Needs WinAPI.au3
	; Based on work from KaFu and JFX (http://www.autoitscript.com/forum/topic/136907-need-help-with-ioctl-disk-get-drive-layout-ex/)
	$_DRIVE_LAYOUT = DllStructCreate('dword PartitionStyle; dword PartitionCount; byte union[40]; byte PartitionEntry[8192]')
	$hDrive = _WinAPI_CreateFileEx('\\.\' & $sDrive, 2,0)
	if $hDrive = 0 Then Return "ERROR"

	Local $Ret = DllCall("kernel32.dll", "int", "DeviceIoControl", "hwnd", $hDrive, "dword", 0x00070050, "ptr", 0, "dword", 0, "ptr", DllStructGetPtr($_DRIVE_LAYOUT), "dword", DllStructGetSize($_DRIVE_LAYOUT), "dword*", 0, "ptr", 0)
	If __CheckErrorCloseHandle($Ret, $hDrive) Then Return "ERROR"

	Switch DllStructGetData($_DRIVE_LAYOUT, "PartitionStyle")
		Case 0 ; MBR
			Return "MBR"
		Case 1 ; GPT
			Return "GPT"
		Case 2 ; RAW
			Return "RAW"
		Case Else ; RAW (no signature / no letter ...)
			Return "ERROR"
	EndSwitch
EndFunc

Func Get_MBR_ID_WMI($drive_letter,$clean_trailing_zeroes=1)
	Local $physical_drive,$g_eventerror

	UpdateLog("Get_MBR_identifier of : "&$drive_letter)

	Local $wbemFlagReturnImmediately, $wbemFlagForwardOnly, $objWMIService, $colItems, $objItem, $found_usb, $usb_model, $usb_size
	$wbemFlagReturnImmediately = 0x10
	$wbemFlagForwardOnly = 0x20
	$colItems = ""

	$objWMIService = ObjGet("winmgmts:\\.\root\CIMV2")
	if @error OR $g_eventerror OR NOT IsObj($objWMIService) Then
		UpdateLog("ERROR with WMI : Trying alternate method (WMI impersonation)")
		$g_eventerror =0
		$objWMIService = ObjGet("winmgmts:{impersonationLevel=Impersonate}!//.")
	EndIf

	if @error OR $g_eventerror then
		UpdateLog("ERROR with WMI")
	Elseif IsObj($objWMIService) Then
		UpdateLog("WMI seems to work")

		$colItems = $objWMIService.ExecQuery("SELECT Caption, DeviceID, Signature FROM Win32_DiskDrive", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
		$found=0
		For $objItem In $colItems

			$colItems2 = $objWMIService.ExecQuery("ASSOCIATORS OF {Win32_DiskDrive.DeviceID='" & $objItem.DeviceID & "'} WHERE AssocClass = Win32_DiskDriveToDiskPartition", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
			For $objItem2 In $colItems2
				$colItems3 = $objWMIService.ExecQuery("ASSOCIATORS OF {Win32_DiskPartition.DeviceID='" & $objItem2.DeviceID & "'} WHERE AssocClass = Win32_LogicalDiskToPartition", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
				For $objItem3 In $colItems3
					If $objItem3.DeviceID = $drive_letter Then
						$mbr_signature = $objItem.Signature
						$found=1
					EndIf
				Next
			Next

		Next

	Else
		UpdateLog("ERROR with WMI : object not created, cannot find MBR identifier")
	endif

	if $found=1 Then

		$mbr_hex = 	StringLower(Hex($mbr_signature))
		; Signature can be 0 when formatted using a Macintosh
		if $mbr_signature <> "0" AND $clean_trailing_zeroes = 1 Then
			$mbr_hex = CleanTrailingZeroes($mbr_hex)
		EndIf
		UpdateLog("MBR identifier of "&$drive_letter&" is : "& $mbr_signature&" ("&$mbr_hex&")")
		Return $mbr_hex
	Else
		UpdateLog("MBR identifier could not be found : no match in WMI")
		Return "ERROR"
	EndIf
EndFunc

Func CleanTrailingZeroes($to_clean)
	; Only clean the zeroes at the beginning
	While StringLeft($to_clean,1)="0"
		$to_clean=StringTrimLeft($to_clean,1)
	WEnd
	Return $to_clean
EndFunc

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Fetching Serial numbers of partitions (a.k.a UUID)          /////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func Get_Disk_UUID($drive_letter)
	UpdateLog("Start-Get_Disk_UUID of : "&$drive_letter)
	$uuid_temp = DriveGetSerial( $drive_letter )
	if Not @error Then
		$hex_number = Hex(Int($uuid_temp),8)
		$uuid = StringTrimRight($hex_number, 4) & "-" & StringTrimLeft($hex_number, 4)
		UpdateLog("End-Get_Disk_UUID ( SUCCESS : UUID of "&$drive_letter&" is "&$uuid&" )")
		Return $uuid
	Else
		$volume_infos = _WinAPI_GetVolumeInformation($drive_letter&"\")
		If Not @error AND isArray($volume_infos) Then
			$hex_number = Hex(Int($volume_infos[1]),8)
			$uuid = StringTrimRight($hex_number, 4) & "-" & StringTrimLeft($hex_number, 4)
			UpdateLog("End-Get_Disk_UUID ( SUCCESS : UUID of "&$drive_letter&" is "&$uuid&" )")
			Return $uuid
		Else
			UpdateLog("END-Get_Disk_UUID ( WARNING : Falling back to WMI Mode )")
			Return Get_Disk_UUID_WMI($drive_letter)
		EndIf
	EndIf
EndFunc

Func Get_Disk_UUID_WMI($drive_letter)
	UpdateLog("Start-Get_Disk_UUID_WMI ( Drive : " & $drive_letter & " )")
	Local $uuid = "EEEEEEEE"
	Local $g_eventerror
	Local $wbemFlagReturnImmediately, $wbemFlagForwardOnly, $objWMIService, $colItems, $objItem
	$wbemFlagReturnImmediately = 0x10
	$wbemFlagForwardOnly = 0x20
	$colItems = ""

	$objWMIService = ObjGet("winmgmts:\\.\root\CIMV2")
	if @error OR $g_eventerror OR NOT IsObj($objWMIService) Then
		UpdateLog("IN-Get_Disk_UUID_WMI ( ERROR with WMI : Trying alternate method (WMI impersonation) )")
		$g_eventerror =0
		$objWMIService = ObjGet("winmgmts:{impersonationLevel=Impersonate}!//.")
	EndIf

	if @error OR $g_eventerror then
		UpdateLog("IN-Get_Disk_UUID_WMI ( ERROR with WMI )")
		Return $uuid
	Elseif IsObj($objWMIService) Then
		$o_ColListOfProcesses = $objWMIService.ExecQuery("SELECT * FROM Win32_LogicalDisk WHERE Name = '" & $drive_letter & "'")
		For $o_ObjProcess In $o_ColListOfProcesses
			$uuid = $o_ObjProcess.VolumeSerialNumber
		Next
		If $uuid = "EEEEEEEE" Then
			UpdateLog("IN-Get_Disk_UUID_WMI ( ERROR : UUID was not found (EEEE-EEEE) )")
		Else
			$result=StringTrimRight($uuid, 4) & "-" & StringTrimLeft($uuid, 4)
			UpdateLog("End-Get_Disk_UUID_WMI ( SUCCESS : UUID of "&$drive_letter&" is "&$result&" )")
			Return $result
		EndIf

	EndIf
EndFunc   ;==>Get_Disk_UUID

Func isValidFilesystem($format)
		; Testing if FAT or FAT32 (not exfat)
		If StringStripWS($format,3) == "FAT" OR StringStripWS($format,3) == "FAT32" Then
				Return True
		Else
				Return False
		EndIf

EndFunc

Func FAT32Format($drive,$label)
	SendReport("Start-FAT32Format ( Drive : " & $drive & " )")
	Local $lines="",$errors="",$soft=""
	$soft='echo y | "'&@ScriptDir & '\tools\fat32format.exe" '&$drive
	UpdateLog($soft)
	$foo = Run(@ComSpec & " /c " &$soft, @ScriptDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	While 1
		$lines &= StdoutRead($foo)
		If @error Then ExitLoop
	WEnd
	UpdateLog($lines)
	While 1
		$errors &= StderrRead($foo)
		If @error Then ExitLoop
	WEnd
	UpdateLog($errors)

	$return=DriveSetLabel($drive,$label)
	if $return=0 Then UpdateLog("WARNING : Setting drive label failed on "&$drive)

	if StringInStr($lines,"Done") Then
		SendReport("End-FAT32Format ( Success )")
		Return 0
	Else
		SendReport("End-FAT32Format ( Error, see logs )")
		Return -1
	EndIf
EndFunc   ;==>RunWait3

func SetDriveLabel($drive,$label)
	SendReport("Start-SetDriveLabel ( Drive : " & $drive & " - Label : "&$label&" )")
	DriveSetLabel ( $drive, $label )
	if DriveGetLabel ( $drive ) = $label Then
		SendReport("END-SetDriveLabel ( success )")
		return 1
	Else
		SendReport("END-SetDriveLabel ( [ERROR] Could not set label on drive )")
		return "ERROR"
	EndIf
EndFunc
