; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Creating boot menu                             ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func GetKbdCode()
	Local $use_source,$return
	if ReadSetting("Advanced","skip_keyboard_detection") = "yes" Then
		SendReport("END-GetKbdCode : Keyboard detection will be skipped.")
	EndIf

	If StringRight(@KBLayout,4) <> "0000" Then
		$use_source=StringRight(@KBLayout,4)
	Elseif @MUILang <> "0000" Then
		$use_source=@MUILang
	Else
		$use_source=@OSLang
	EndIf
	Select
		Case StringInStr("040c,080c,140c,180c", $use_source)
			; FR
			$for_status = Translate("French (France)")
			$return = "bootkbd=fr-latin1 console-setup/layoutcode=fr console-setup/variantcode=nodeadkeys "
		Case StringInStr("0c0c", $use_source)
			; CA
			$for_status = Translate("Français (Canada)")
			$return = "bootkbd=fr-latin1 console-setup/layoutcode=ca console-setup/variantcode=nodeadkeys "
		Case StringInStr("100c", $use_source)
			; Suisse FR
			$for_status =  Translate("French (Swiss)")
			$return = "bootkbd=fr-latin1 console-setup/layoutcode=ch console-setup/variantcode=fr "
		Case StringInStr("0407,0807,0c07,1007,1407", $use_source)
			; German & dutch
			$for_status =  Translate("Dutch")
			$return = "bootkbd=de console-setup/layoutcode=de console-setup/variantcode=nodeadkeys "
		Case StringInStr("0816", $use_source)
			; Portugais
			$for_status =  Translate("Portuguese")
			$return =  "bootkbd=qwerty/br-abnt2 console-setup/layoutcode=br console-setup/variantcode=nodeadkeys "
		Case StringInStr("0410,0810", $use_source)
			; Italien
			$for_status = Translate("Italian")
			 $return = "bootkbd=it console-setup/layoutcode=it console-setup/variantcode=nodeadkeys "
		Case Else
			; US
			$for_status =  Translate("US or other (qwerty)")
			$return =  "bootkbd=us console-setup/layoutcode=en_US console-setup/variantcode=nodeadkeys "
	EndSelect
	UpdateLog(Translate("Detecting keyboard layout") & " : " &$for_status&" (code="&$use_source&")")
	Return $return
EndFunc   ;==>GetKbdCode


Func GetLangCode()
	Local $use_source
	If @MUILang <> "0000" Then
		$use_source=@MUILang
	Else
		$use_source=@OSLang
	EndIf

	Select
		Case StringInStr("040c,080c,140c,180c", $use_source)
			; FR
			$lang_code = "fr_FR"
		Case StringInStr("0c0c", $use_source)
			; CA
			$lang_code = "fr_CA"
		Case StringInStr("100c", $use_source)
			; Suisse FR
			$lang_code = "fr_FR"
		Case StringInStr("0407,0807,0c07,1007,1407", $use_source)
			; German & dutch
			$lang_code = "de_DE"
		Case StringInStr("0816", $use_source)
			; Portugais
			$lang_code = "pt_BR"
		Case StringInStr("0410,0810", $use_source)
			; Italien
			$lang_code= "it_IT"
		Case Else
			; US
			$lang_code= "us_us"
	EndSelect
	$full_return="locale="&$lang_code&" "
	SendReport("Generated Lang Code : "&$full_return&" (code="&$use_source&")")
	Return $full_return
EndFunc   ;==>GetLang

Func TinyCore_WriteTextCFG()
	SendReport("Start-TinyCore_WriteTextCFG")
	Local $boot_text = "", $uuid
	$uuid = Get_Disk_UUID($usb_letter)
$boot_text="display boot.msg" _
	& @LF & "default tinycore" _
	& @LF & "label tinycore" _
	& @LF & "	kernel /boot/bzImage" _
	& @LF & "	append initrd=/boot/tinycore.gz max_loop=200 waitusb=5 tce=UUID="&$uuid&" restore=UUID="&$uuid&" home=UUID="&$uuid&" opt=UUID="&$uuid _
	& @LF & "label live" _
	& @LF & "	kernel /boot/bzImage" _
	& @LF & "	append initrd=/boot/tinycore.gz quiet max_loop=255" _
	& @LF & "implicit 0" _
	& @LF & "prompt 1" _
	& @LF & "timeout 300" _
	& @LF & "F1 boot.msg" _
	& @LF & "F2 f2" _
	& @LF & "F3 f3"
	FileOverWrite($usb_letter & "\boot\syslinux\syslinux.cfg", $boot_text)
	SendReport("End-TinyCore_WriteTextCFG")
EndFunc

Func Sidux_WriteTextCFG()
	SendReport("Start-Sidux_WriteTextCFG")
	Local $boot_text = ""
	if FileExists($usb_letter&"\boot\vmlinuz0.686") Then
		$arch="686"
	Else
		$arch="amd"
	EndIf
	$boot_text="UI gfxboot bootlogo"

	if FileExists($usb_letter&"\sidux\sidux-rw") Then
		$boot_text &=@LF & "LABEL " & Translate("Persistent Mode") _
		& @LF & "	KERNEL /boot/vmlinuz0."&$arch _
		& @LF & "	APPEND boot=fll persist=/sidux/sidux-rw" _
		& @LF & "	INITRD /boot/initrd0."&$arch
	EndIf

	$boot_text&= @LF & "LABEL " & Translate("Live Mode") _
	& @LF & "	KERNEL /boot/vmlinuz0."&$arch _
	& @LF & "	APPEND boot=fll " _
	& @LF & "	INITRD /boot/initrd0."&$arch _
	& @LF & "LABEL Boot_from_Hard_Disk" _
	& @LF & "	localboot 0x80" _
	& @LF & "LABEL "& Translate("Memory Test") _
	& @LF & "	KERNEL /boot/memtest"
	FileOverWrite($usb_letter & "\boot\syslinux\syslinux.cfg", $boot_text)
	SendReport("End-Sidux_WriteTextCFG")
EndFunc


Func Aptosid_WriteTextCFG()
	SendReport("Start-Aptosid_WriteTextCFG")
	Local $boot_text = ""
	if FileExists($usb_letter&"\boot\vmlinuz0.686") Then
		$arch="686"
	Else
		$arch="amd"
	EndIf
	$boot_text="UI gfxboot bootlogo"

	if FileExists($usb_letter&"\aptosid\aptosid-rw") Then
		$boot_text &=@LF & "LABEL " & Translate("Persistent Mode") _
		& @LF & "	KERNEL /boot/vmlinuz0."&$arch _
		& @LF & "	APPEND initrd=/boot/initrd0."&$arch&" boot=fll persist=/aptosid/aptosid-rw"
	EndIf

	$boot_text&= @LF & "LABEL " & Translate("Live Mode") _
	& @LF & "	KERNEL /boot/vmlinuz0."&$arch _
	& @LF & "	APPEND initrd=/boot/initrd0."&$arch&" boot=fll " _
	& @LF & "LABEL Boot_from_Hard_Disk" _
	& @LF & "	localboot 0x80" _
	& @LF & "LABEL "& Translate("Memory Test") _
	& @LF & "	KERNEL /boot/memtest"
	FileOverWrite($usb_letter & "\boot\syslinux\syslinux.cfg", $boot_text)
	SendReport("End-Aptosid_WriteTextCFG")
EndFunc


Func BackTrack_WriteTextCFG()
	SendReport("Start-BackTrack_WriteTextCFG")
	If FileExists($usb_letter&"\casper-rw") Then
		$file = FileOpen($usb_letter & "\syslinux\syslinux.cfg", 0)
		If $file = -1 Then
			SendReport("End-BackTrack_WriteTextCFG : could not open file "&$usb_letter & "\syslinux\syslinux.cfg for reading")
			Return 0
		EndIf
		$content=FileRead($file)
		FileClose($file)
	Else
		$content=""
	EndIf


	if StringInStr($content,"label STEALTH" )>0 Then
		$persistence_menu="label PERSIST" _
					&@LF&"  menu label BackTrack Persistent - Persistent mode" _
					&@LF&"  kernel /casper/vmlinuz" _
					&@LF&"  append  file=/cdrom/preseed/custom.seed boot=casper initrd=/casper/initrd.gz persistent cdrom-detect/try-usb=true text splash vga=791--" _
					&@LF&@LF&"label STEALTH"
		$new_content=StringReplace($content,"label STEALTH",$persistence_menu)
		FileOverWrite($usb_letter & "\syslinux\syslinux.cfg", $new_content)
	EndIf

	SendReport("End-BackTrack_WriteTextCFG")
EndFunc

Func CDLinux_WriteTextCFG()
	; Option 9 to create the folder if does not exist
	FileCopy2(@ScriptDir&"\tools\boot-menus\cdlinux-syslinux.cfg",$usb_letter&"\syslinux\syslinux.cfg",9)
EndFunc

Func ReactOS_WriteTextCFG()
	; Option 9 to create the folder if does not exist
	FileCopy2(@ScriptDir&"\tools\boot-menus\reactos-syslinux.cfg",$usb_letter&"\syslinux.cfg",9)
EndFunc

; Modify boot menu for Arch Linux (applied to every default Linux) but will modify only if Arch Linux detected
Func Default_WriteTextCFG()
	SendReport("Start-Default_WriteTextCFG")
	Local $uuid

	if FileExists($usb_letter & "\boot\syslinux\syslinux.cfg") Then
		$syslinux_file = $usb_letter & "\boot\syslinux\syslinux.cfg"
		$syslinux_folder=$usb_letter & "\boot\syslinux\"
	Elseif FileExists($usb_letter & "\syslinux\syslinux.cfg") Then
		$syslinux_file = $usb_letter & "\syslinux\syslinux.cfg"
		$syslinux_folder=$usb_letter & "\syslinux\"
	Elseif FileExists($usb_letter & "\syslinux.cfg") Then
		$syslinux_file = $usb_letter & "\syslinux.cfg"
		$syslinux_folder=$usb_letter & "\"
	Else
		Return 0
		SendReport("End-Default_WriteTextCFG (No syslinux file found)")
	EndIf
	SendReport("IN-Default_WriteTextCFG (syslinux file found at "&$syslinux_file&", start scanning folder to apply default tweaks)")

	$search = FileFindFirstFile($syslinux_folder&"*.cfg")
	If $search <> -1 Then
		While 1
			$foundfile = FileFindNextFile($search)
			If @error Then ExitLoop
			DefaultBootTweaks($syslinux_folder&$foundfile)
		WEnd
		FileClose($search)
	EndIf

	$search = FileFindFirstFile($syslinux_folder&"*.txt")
	If $search <> -1 Then
		While 1
			$foundfile = FileFindNextFile($search)
			If @error Then ExitLoop
			DefaultBootTweaks($syslinux_folder&$foundfile)
		WEnd
		FileClose($search)
	EndIf

	; ArchLinux > 2011.08.19
	$search = FileFindFirstFile($usb_letter&"\arch\boot\syslinux\*.cfg")
	If $search <> -1 Then
		While 1
			$foundfile = FileFindNextFile($search)
			If @error Then ExitLoop
			DefaultBootTweaks($usb_letter&"\arch\boot\syslinux\"&$foundfile)
			SendReport("Found file : "&$usb_letter&"\arch\boot\syslinux\"&$foundfile)
		WEnd
		FileClose($search)
	EndIf

	; Manjaro
	$search = FileFindFirstFile($usb_letter&"\manjaro\boot\i686\syslinux\*.cfg")
	If $search <> -1 Then
		While 1
			$foundfile = FileFindNextFile($search)
			If @error Then ExitLoop
			DefaultBootTweaks($usb_letter&"\manjaro\boot\i686\syslinux\"&$foundfile)
			SendReport("Found file : "&$usb_letter&"\manjaro\boot\i686\syslinux\"&$foundfile)
		WEnd
		FileClose($search)
	EndIf

	; Manjaro x64
	$search = FileFindFirstFile($usb_letter&"\manjaro\boot\x86_64\syslinux\*.cfg")
	If $search <> -1 Then
		While 1
			$foundfile = FileFindNextFile($search)
			If @error Then ExitLoop
			DefaultBootTweaks($usb_letter&"\manjaro\boot\x86_64\syslinux\"&$foundfile)
			SendReport("Found file : "&$usb_letter&"\manjaro\boot\x86_64\syslinux\"&$foundfile)
		WEnd
		FileClose($search)
	EndIf

EndFunc

Func DefaultBootTweaks($filename)
	$file = FileOpen($filename, 0)
	If $file = -1 Then
		SendReport("End-DefaultBootTweaks : could not open file "&$filename)
		Return 0
	EndIf

	$content=FileRead($file)
	FileClose($file)

	if StringInStr($content,"cdroot_type=udf" )>0 Then
		; Modifying Boot menu for Gentoo/Sabayon
		; changing root type from UDF (DVD) to vfat (USB)
		SendReport("IN-DefaultBootTweaks => Gentoo/Sabayon variant detected in file "&$filename)
		$file = FileOpen($filename, 2)
		; Check if file opened for writing OK
		If $file = -1 Then
			SendReport("IN-DefaultBootTweaks => ERROR : cannot write to file "&$filename)
		Else
			SendReport("IN-DefaultBootTweaks => setting cdroot_type=vfat slowusb in file "&$filename)
			FileWrite($file,StringReplace($content,"cdroot_type=udf","cdroot_type=vfat slowusb"))
			FileClose($file)
		EndIf
	Elseif StringInStr($content,"live-media=removable" )>0 Then
		; Modifying Boot menu for Tails
		; removing media type
		SendReport("IN-DefaultBootTweaks => Tails or Debian variant detected in file "&$filename&" (live-media=removable)")
		$file = FileOpen($filename, 2)
		; Check if file opened for writing OK
		If $file = -1 Then
			SendReport("IN-DefaultBootTweaks => ERROR : cannot write to file "&$filename)
		Else
			SendReport("IN-DefaultBootTweaks => removing live-media=removable in file "&$filename)
			FileWrite($file,StringReplace($content," live-media=removable",""))
			FileClose($file)
		EndIf
	Elseif StringInStr($content,"pmedia=cd" )>0 Then
		; Modifying Boot menu for Puppy Variants
		; changing media from CD to USB
		SendReport("IN-DefaultBootTweaks => Puppy variant detected in file "&$filename)
		$file = FileOpen($filename, 2)
		; Check if file opened for writing OK
		If $file = -1 Then
			SendReport("IN-DefaultBootTweaks => ERROR : cannot write to file "&$filename)
		Else
			SendReport("IN-DefaultBootTweaks => setting pmedia=usb in file "&$filename)
			FileWrite($file,StringReplace($content,"pmedia=cd","pmedia=usb"))
			FileClose($file)
		EndIf
	Elseif StringInStr($content,"antix" )>0 Then
		; Modifying Boot menu for AntiX
		; adding a delay in order to work
		SendReport("IN-DefaultBootTweaks => AntiX variant detected in file "&$filename)
		$file = FileOpen($filename, 2)
		; Check if file opened for writing OK
		If $file = -1 Then
			SendReport("IN-DefaultBootTweaks => ERROR : cannot write to file "&$filename)
		Else
			SendReport("IN-DefaultBootTweaks => setting rootdelay=15 and from=hd,usb,cd  in file "&$filename)
			$new_append="from=hd,usb,cd "
			if Not StringInStr($content,"rootdelay") Then
				$new_append &= "rootdelay=15 "
			EndIf
			FileWrite($file,StringReplace($content,"APPEND ","APPEND "&$new_append))
			FileClose($file)
		EndIf
	Elseif StringInStr($content,"ESXi-" )>0 Then
		if StringInStr($content,"ESXi-5" )>0 Then
			$esxi_version="5"
		elseif StringInStr($content,"ESXi-6" )>0 Then
			$esxi_version="6"
		EndIf

		; Modifying Boot menu for VMware vSphere ESXi > 5.X
		if $filename = $usb_letter&"\syslinux.cfg" Then
			SendReport("IN-DefaultBootTweaks => ESXi "&$esxi_version&".x variant detected in file "&$filename)
			FileMove($filename,$filename&".lili-bak",1)
			HideFile($filename&".lili-bak")
			FileCopy(@ScriptDir&"\tools\boot-menus\esxi"&$esxi_version&"-syslinux.cfg",$usb_letter&"\syslinux.cfg",1)
			If Not FileExists($usb_letter&"\ks.cfg") Then
				FileCopy(@ScriptDir&"\tools\boot-menus\esxi"&$esxi_version&"-ks.cfg",$usb_letter&"\ks.cfg")
			EndIf
		EndIf
	Elseif StringInStr($content,"vmkboot.gz" )>0 Then
		; Modifying Boot menu for VMware vSphere ESXi > 4.1
		; adding a ks=usb
		SendReport("IN-DefaultBootTweaks => ESXi 4.x variant detected in file "&$filename)
		$file = FileOpen($filename, 2)
		; Check if file opened for writing OK
		If $file = -1 Then
			SendReport("IN-DefaultBootTweaks => ERROR : cannot write to file "&$filename)
		Else
			SendReport("IN-DefaultBootTweaks => setting vmkboot.gz in file "&$filename)
			FileWrite($file,StringReplace($content,"vmkboot.gz","vmkboot.gz ks=usb "))
			FileClose($file)
		EndIf

		If Not FileExists($usb_letter&"\ks.cfg") Then
			FileCopy(@ScriptDir&"\tools\boot-menus\esxi-ks.cfg",$usb_letter&"\ks.cfg")
		EndIf
	Elseif StringInStr($content,"isolabel" )>0 Then
		; Modifying Boot menu for ArchLinux / Chakra / Manjaro
		; setting boot device UUID
		if StringInStr($content,"archisolabel" )>0 Then
			$isolabel_text="archisolabel="
			$isolabel_replacement = "archisodevice="
		Elseif StringInStr($content,"chakraisolabel" )>0 Then
			$isolabel_text="chakraisolabel="
			$isolabel_replacement = "chakraisodevice="
		Elseif StringInStr($content,"misolabel" )>0 Then
			; Manjaro
			$isolabel_text="misolabel="
			$isolabel_replacement = "misodevice="
		Else
			SendReport("IN-DefaultBootTweaks => Warning : Found an unknown isolabel setting.")
			Return 0
		EndIf
		SendReport("IN-DefaultBootTweaks => Found isolabel setting : "&$isolabel_text)
		$array1 = _StringBetween($content, $isolabel_text, ' ')
		; Won't work if at the end of the line so double checking
		If @error Then
			$array1 = _StringBetween($content, $isolabel_text, @LF)
		EndIf
		if NOT @error Then
			SendReport("IN-DefaultBootTweaks => isolabel detected in file "&$filename)
			$uuid = Get_Disk_UUID($usb_letter)
			$new_content=StringReplace($content,$isolabel_text&$array1[0],$isolabel_replacement&"/dev/disk/by-uuid/"&$uuid)
			$file = FileOpen($filename, 2)
			; Check if file opened for writing OK
			If $file = -1 Then
				SendReport("IN-DefaultBootTweaks => ERROR : cannot write to file "&$filename)
			Else
				SendReport("IN-DefaultBootTweaks => "&$isolabel_replacement&" UUID set to "&$uuid&" in file "&$filename)
				FileWrite($file,$new_content)
				FileClose($file)
			EndIf
		EndIf
	EndIf
EndFunc


Func Ubuntu_WriteTextCFG()
	SendReport("Start-Ubuntu_WriteTextCFG")

	AutoDetectINITRD($usb_letter&"\casper\")
	AutoDetectVMLINUZ($usb_letter&"\casper\")

	#cs
	------------ Old BackTrack compatibility mode
	If $release_variant = "backtrack" Then
		DirCreate($usb_letter &"\syslinux\")
		FileCopy(@ScriptDir & "\tools\vesamenu.c32", $usb_letter & "\syslinux\vesamenu.c32", 1)
		FileCopy(@ScriptDir & "\tools\bt4-splash.jpg", $usb_letter & "\syslinux\splash.jpg", 1)
		FileCopy(@ScriptDir & "\tools\bt4-isolinux.txt", $usb_letter & "\syslinux\syslinux.cfg", 1)
		Return ""
	EndIf
	#ce

	#cs
	UpdateLog("Type of initrd file : " &$initrd_file &"( for Generic Version Code ="&GenericVersionCode($release_distribution_version)&" )" )
	 Old method => using version number instead of autodetection
	If GenericVersionCodeWithoutMinor($release_distribution_version) >= 910 Then
		$initrd_file = "initrd.lz"
	Else
		$initrd_file = "initrd.gz"
	EndIf

	if $release_variant = "ylmfos" Then $initrd_file="initrd.img"
	UpdateLog("Type of initrd file : " &$initrd_file &"( for Generic Version Code ="&GenericVersionCode($release_distribution_version)&" )" )
	#ce

	; For Mint, only syslinux.cfg need to be modified
	If $release_variant = "mint" Then

		; Mint KDE uses a splash.png image
		if StringInStr($release_codename,"mintkde") AND $release_distribution_version = 9 Then
			$splash_img="splash.png"
		Else
			$splash_img="splash.jpg"
		EndIf

		$boot_text = "default vesamenu.c32" _
				 & @LF & "timeout 100" _
				 & @LF & "menu background "&$splash_img _
				 & @LF & "menu title Welcome to Linux Mint" _
				 & @LF & "menu color border 0 #00eeeeee #00000000" _
				 & @LF & "menu color sel 7 #ffffffff #33eeeeee" _
				 & @LF & "menu color title 0 #ffeeeeee #00000000" _
				 & @LF & "menu color tabmsg 0 #ffeeeeee #00000000" _
				 & @LF & "menu color unsel 0 #ffeeeeee #00000000" _
				 & @LF & "menu color hotsel 0 #ff000000 #ffffffff" _
				 & @LF & "menu color hotkey 7 #ffffffff #ff000000" _
				 & @LF & "menu color timeout_msg 0 #ffffffff #00000000" _
				 & @LF & "menu color timeout 0 #ffffffff #00000000" _
				 & @LF & "menu color cmdline 0 #ffffffff #00000000" _
				 & @LF & "menu hidden" _
				 & @LF & "menu hiddenrow 5"

		$boot_text &= Ubuntu_BootMenu("mint")

		UpdateLog("Creating syslinux.cfg file for Mint :" & @CRLF & $boot_text)
		FileOverWrite($usb_letter & "\syslinux\syslinux.cfg", $boot_text)
		SendReport("End-Ubuntu_WriteTextCFG")
		Return 1
	EndIf

	If $release_variant = "crunchbang" OR $release_variant = "kuki"  OR $release_variant = "element" Then
		$boot_text=Ubuntu_BootMenu("custom") & @LF & "DISPLAY isolinux.txt"& @LF &"TIMEOUT 300"& @LF &"PROMPT 1" & @LF & "default persist"
		UpdateLog("Creating syslinux.cfg file for "&$release_variant&" :" & @CRLF & $boot_text)
		FileOverWrite($usb_letter & "\syslinux\syslinux.cfg",$boot_text)
		;FileCopy($usb_letter & "\syslinux\isolinux.txt",$usb_letter & "\syslinux\isolinux-orig.txt")
		;FileCopy(@ScriptDir & "\tools\boot-menus\"&$release_variant&"-isolinux.txt", $usb_letter & "\syslinux\isolinux.txt", 1)
		SendReport("End-Ubuntu_WriteTextCFG")
		Return 1
	EndIf


	if $release_variant = "uberstudent" Then
		$boot_text= @LF &"default vesamenu.c32" _
		& @LF &"prompt 0" _
		& @LF &"timeout 300" _
		& @LF &"menu title UberStudent" _
		& @LF &"menu background splash.png" _
		& @LF &"menu color title 1;37;44 #c0ffffff #00000000 std"&Ubuntu_BootMenu("custom")
		UpdateLog("Creating syslinux.cfg file for "&$release_variant&" :" & @CRLF & $boot_text)
		FileOverWrite($usb_letter & "\syslinux\syslinux.cfg",$boot_text)
		SendReport("End-Ubuntu_WriteTextCFG")
		Return 1
	EndIf

	; Not used for the moment because CAINE does not find live partition
	if $release_variant = "caine" Then
		$boot_text=@LF &"default vesamenu.c32" _
		& @LF &"prompt 0" _
		& @LF &"timeout 300" _
		& @LF &"menu title Caine 2.0 Live " _
		& @LF &"menu AUTOBOOT Booting in # seconds..." _
		& @LF &"menu TABMSG  http://www.caine-live.net" _
		& @LF &"menu background splash.png" _
		& @LF &"menu color sel	7;37;40  #e0000000 #f0ff8000 all" _
		& @LF &"menu color title 1;37;24 #c0ffffff #00000000 std" &Ubuntu_BootMenu("custom")
		UpdateLog("Creating syslinux.cfg file for "&$release_variant&" :" & @CRLF & $boot_text)
		FileOverWrite($usb_letter & "\syslinux\syslinux.cfg",$boot_text)
		SendReport("End-Ubuntu_WriteTextCFG")
		Return 1
	EndIf

	; For official Ubuntu variants and most others, only text.cfg need to be modified
	$boot_text = Ubuntu_BootMenu(AutomaticPreseed($release_variant))
	UpdateLog("Creating text.cfg file for Ubuntu variants :" & @CRLF & $boot_text)

	If GenericVersionCodeWithoutMinor($release_distribution_version) >= 1010  Then
		; Special code for lubuntu 10.10
		if $release_variant = "lubuntu" AND GenericVersionCodeWithoutMinor($release_distribution_version) = 1010 Then
			$text_file="text.cfg"
		Else
			$text_file="txt.cfg"
		EndIf
	Else
		$text_file="text.cfg"
	EndIf
	SendReport("IN-Ubuntu_WriteTextCFG : writing to "&$text_file)
	FileOverWrite($usb_letter & "\syslinux\"&$text_file,$boot_text)
	SendReport("End-Ubuntu_WriteTextCFG")
EndFunc   ;==>Ubuntu_WriteTextCFG


Func Debian_WriteTextCFG()
	SendReport("Start-Debian_WriteTextCFG")


	AutoDetectINITRD($usb_letter&"\live\")
	AutoDetectVMLINUZ($usb_letter&"\live\")

	If $release_variant="mint" Then
			$boot_text = "default vesamenu.c32" _
				 & @LF & "timeout 100" _
				 & @LF & "menu background splash.jpg" _
				 & @LF & "menu title Welcome to Linux Mint Debian" _
				 & @LF & "menu color border 0 #00eeeeee #00000000" _
				 & @LF & "menu color sel 7 #ffffffff #33eeeeee" _
				 & @LF & "menu color title 0 #ffeeeeee #00000000" _
				 & @LF & "menu color tabmsg 0 #ffeeeeee #00000000" _
				 & @LF & "menu color unsel 0 #ffeeeeee #00000000" _
				 & @LF & "menu color hotsel 0 #ff000000 #ffffffff" _
				 & @LF & "menu color hotkey 7 #ffffffff #ff000000" _
				 & @LF & "menu color timeout_msg 0 #ffffffff #00000000" _
				 & @LF & "menu color timeout 0 #ffffffff #00000000" _
				 & @LF & "menu color cmdline 0 #ffffffff #00000000" _
				 & @LF & "menu hidden" _
				 & @LF & "menu hiddenrow 6"

		$boot_text &= MintDebian_BootMenu()

		UpdateLog("Creating syslinux.cfg file for Mint :" & @CRLF & $boot_text)
		FileOverWrite($usb_letter & "\syslinux\syslinux.cfg",$boot_text)
	Elseif $release_variant="crunchbang" Then
		If FileExists($usb_letter&"\live-rw") Then

			$prepend = "label persist" _
			& @LF & "menu label Persistent" _
			& @LF & "kernel /live/"&$vmlinuz_file _
			& @LF & "append initrd=/live/"&$initrd_file&" boot=live config persistent quiet"

			; read original boot menu
			$original_boot=FileRead($usb_letter & "\syslinux\live.cfg")

			; Backup original boot menu
			FileMove($usb_letter & "\syslinux\live.cfg",$usb_letter & "\syslinux\live.cfg-orig")

			; Append Persistence if necessary
			FileWrite($usb_letter & "\syslinux\live.cfg",$prepend& @LF & @LF &$original_boot)
		EndIf
	Else
		Local $kbd_code,$boot_text="",$append_debian="",$prepend="",$boot_menu=""
		$append_debian="boot=live initrd=/casper/initrd.lz live-media-path=/casper quiet splash --"
		If FileExists($usb_letter&"\live-rw") Then
			$prepend = @LF& "label persist" & @LF & "menu label ^Persistent" _
				& @LF & "  kernel /live/"&$vmlinuz_file _
				& @LF & "  append initrd=/live/"&$initrd_file&" boot=live config persistent quiet"

			if FileExists($usb_letter&"\live\vmlinuz1") AND FileExists($usb_letter&"\live\initrd1.img") Then
				$prepend &= @LF&"label persist2" _
				& @LF & "menu label Persistent (486)" _
				& @LF & "kernel /live/vmlinuz1" _
				& @LF & "append initrd=/live/initrd1.img boot=live config persistent quiet"
			EndIf

		EndIf

		$boot_menu=FileRead($usb_letter & "\syslinux\live.cfg")
		FileMove($usb_letter & "\syslinux\live.cfg",$usb_letter & "\syslinux\live-orig.cfg")
		FileWrite($usb_letter & "\syslinux\live.cfg",$prepend& @LF & @LF &$boot_menu)

		UpdateLog("Creating live.cfg file for Debian :" &@CRLF& $prepend& @LF & @LF &$boot_menu)
	EndIf
	SendReport("End-Debian_WriteTextCFG")
EndFunc

Func Kali_WriteTextCFG()
	SendReport("Start-Kali_WriteTextCFG")

	AutoDetectINITRD($usb_letter&"\live\")
	AutoDetectVMLINUZ($usb_letter&"\live\")

	If FileExists($usb_letter&"\live-rw") Then

		$append = "boot=live noconfig=sudo username=root hostname=kali"

		$add_to_menu = "label persist" _
			& @LF & "menu label Persistent" _
			& @LF & "kernel /live/"&$vmlinuz_file _
			& @LF & "initrd /live/"&$initrd_file _
			& @LF & "append "&$append&" persistence" _
			& @LF & "label persist-forensic" _
			& @LF & "menu label Persistent" &" (^forensic mode)" _
			& @LF & "kernel /live/"&$vmlinuz_file _
			& @LF & "initrd /live/"&$initrd_file _
			& @LF & "append "&$append&" persistence noswap noautomount"

		; read original boot menu
		$original_boot=FileRead($usb_letter & "\syslinux\live.cfg")

		; Backup original boot menu
		FileMove($usb_letter & "\syslinux\live.cfg",$usb_letter & "\syslinux\live.cfg-orig")

		; Append Persistence if necessary
		FileWrite($usb_letter & "\syslinux\live.cfg",$original_boot& @LF & @LF &$add_to_menu)
	EndIf


EndFunc

Func AutomaticPreseed($preseed_variant)
	SendReport("Start-AutomaticPreseed( "& $usb_letter&" , "& $preseed_variant&" )")

	if FileExists($usb_letter&"\preseed\"&$preseed_variant&".seed") Then
		SendReport("IN-AutomaticPreseed : preseed file same as variant name ( "&$preseed_variant&" )")
		Return StringLower($preseed_variant)
	Else
		SendReport("IN-AutomaticPreseed -> Starting automatic search")
		$content = FileRead("G:\syslinux\text.cfg")
		$content &=  FileRead("G:\syslinux\syslinux.cfg")
		$content &=  FileRead("G:\syslinux\isolinux.cfg")
		$content &=  FileRead("G:\syslinux\isolinux.txt")

		Local $preseed="",$found_preseed = _StringBetween($content, 'seed/', '.seed')
		if NOT @error Then
			if IsArray($found_preseed) AND UBound($found_preseed) > 0 Then
				SendReport("IN-AutomaticPreseed -> automatic search found preseed : "&$found_preseed[0])
				Return $found_preseed[0]
			EndIf
		EndIf
		if FileExists($usb_letter&"\preseed\cli.seed") Then $preseed="cli"
		if FileExists($usb_letter&"\preseed\ubuntu.seed") Then $preseed="ubuntu"
		if FileExists($usb_letter&"\preseed\ubuntu-netbook.seed") Then $preseed="ubuntu-netbook"
		if $preseed="" Then $preseed="custom"
		SendReport("IN-AutomaticPreseed -> preseed selected : "&$preseed)
		Return $preseed
	EndIf
EndFunc

Func Ubuntu_BootMenu($seed_name)
	Local $kbd_code,$boot_text="",$append_ubuntu
	$kbd_code = GetKbdCode()
	$lang_code = GetLangCode()

	$append_ubuntu="noprompt cdrom-detect/try-usb=true file=/cdrom/preseed/" & $seed_name & ".seed boot=casper initrd=/casper/" & $initrd_file & " splash --"

	If FileExists($usb_letter&"\casper-rw") Then
		$boot_text = @LF& "label persist" & @LF & "menu label ^" & Translate("Persistent Mode") _
			& @LF & "  kernel /casper/" & $vmlinuz_file _
			& @LF & "  append  " & $kbd_code & $lang_code & " persistent "&$append_ubuntu
	EndIf
	$boot_text&= @LF & "label live" _
		& @LF & "  menu label ^" & Translate("Live Mode") _
		& @LF & "  kernel /casper/" & $vmlinuz_file _
		& @LF & "  append   " & $kbd_code & $lang_code & $append_ubuntu _
		& @LF & "label live-install" _
		& @LF & "  menu label ^" & Translate("Install") _
		& @LF & "  kernel /casper/" & $vmlinuz_file _
		& @LF & "  append   " & $kbd_code & $lang_code & " only-ubiquity "& $append_ubuntu _
		& @LF & "label check" _
		& @LF & "  menu label ^" & Translate("File Integrity Check") _
		& @LF & "  kernel /casper/" & $vmlinuz_file _
		& @LF & "  append   " & $kbd_code & $lang_code &  "noprompt boot=casper integrity-check initrd=/casper/" & $initrd_file & " splash --" _
		& @LF & "label memtest" _
		& @LF & "  menu label ^" & Translate("Memory Test") _
		& @LF & "  kernel /install/mt86plus"
	Return $boot_text
EndFunc

Func MintDebian_BootMenu()
	Local $kbd_code,$boot_text="",$append_debian
	$kbd_code = GetKbdCode()
	$lang_code = GetLangCode()

	$append_debian="boot=live config initrd=/live/"&$initrd_file&" live-media-path=/live quiet splash --"
	If FileExists($usb_letter&"\live-rw") Then
		$boot_text = @LF& "label persist" & @LF & "menu label ^" & Translate("Persistent Mode") _
			& @LF & "  kernel /live/" & $vmlinuz_file _
			& @LF & "  append  " & $kbd_code & $lang_code & " persistent "&$append_debian
	EndIf

	$boot_text&= @LF & "label live" _
		& @LF & "  menu label ^" & Translate("Live Mode") _
		& @LF & "  kernel /live/"&$vmlinuz_file _
		& @LF & "  append   " & $kbd_code & $lang_code & $append_debian _
		& @LF & "label check" _
		& @LF & "  menu label ^" & Translate("File Integrity Check") _
		& @LF & "  kernel /live/"&$vmlinuz_file _
		& @LF & "  append   " & $kbd_code & $lang_code & " integrity-check "&StringReplace($append_debian,"quiet splash","") _
		& @LF & "label memtest" _
		& @LF & "  menu label ^" & Translate("Memory Test") _
		& @LF & "  kernel memtest"
	Return $boot_text

EndFunc

Func Fedora_WriteTextCFG()
	SendReport("Start-Fedora_WriteTextCFG")
	Local $boot_text = "", $uuid

	$uuid = Get_Disk_UUID($usb_letter)

	AutoDetectINITRD($usb_letter&"\syslinux\")
	AutoDetectVMLINUZ($usb_letter&"\syslinux\")

	if GenericVersionCode($release_distribution_version) <= 15 Then
		; Boot menus for Fedora <= 15
		$boot_text &= @LF & "default vesamenu.c32" _
				 & @LF & "timeout 100" _
				 & @LF & "menu background splash.jpg" _
				 & @LF & "menu title Welcome to your LinuxLive Key !" _
				 & @LF & "menu color border 0 #ffffffff #00000000" _
				 & @LF & "menu color sel 7 #ffffffff #ff000000" _
				 & @LF & "menu color title 0 #ffffffff #00000000" _
				 & @LF & "menu color tabmsg 0 #ffffffff #00000000" _
				 & @LF & "menu color unsel 0 #ffffffff #00000000" _
				 & @LF & "menu color hotsel 0 #ff000000 #ffffffff" _
				 & @LF & "menu color hotkey 7 #ffffffff #ff000000" _
				 & @LF & "menu color timeout_msg 0 #ffffffff #00000000" _
				 & @LF & "menu color timeout 0 #ffffffff #00000000" _
				 & @LF & "menu color cmdline 0 #ffffffff #00000000" _
				 & @LF & "menu hidden" _
				 & @LF & "menu hiddenrow 5" _
				 & @LF & "label live" _
				 & @LF & "  menu label " & Translate("Live Mode") _
				 & @LF & "  kernel "&$vmlinuz_file _
				 & @LF & "  append initrd="&$initrd_file&" root=UUID=" & $uuid & " rootfstype=vfat ro liveimg quiet selinux=0 rhgb  rd_NO_LUKS rd_NO_MD noiswmd" _
				 & @LF & "  menu default"

			If FileExists($usb_letter & '\LiveOS\overlay-' & StringReplace(DriveGetLabel($usb_letter)," ", "_") & '-' & $uuid) Then
				 $boot_text&= @LF & "label persist" _
				 & @LF & "  menu label " & Translate("Persistent Mode") _
				 & @LF & "  kernel "&$vmlinuz_file _
				 & @LF & "  append initrd="&$initrd_file&" root=UUID=" & $uuid & " rootfstype=vfat rw liveimg overlay=UUID=" & $uuid & " quiet selinux=0 rhgb  rd_NO_LUKS rd_NO_MD noiswmd"
			EndIf
				$boot_text&=@LF &"label check0" _
				 & @LF & "  menu label " & Translate("File Integrity Check") _
				 & @LF & "  kernel "&$vmlinuz_file _
				 & @LF & "  append initrd="&$initrd_file&" root=UUID=" & $uuid & " rootfstype=vfat ro liveimg quiet  rhgb check" _
				 & @LF & "label memtest" _
				 & @LF & " menu label " & Translate("Memory Test") _
				 & @LF & "  kernel memtest" _
				 & @LF & "label local" _
				 & @LF & "  menu label Boot from local drive" _
				 & @LF & "  localboot 0xffff"
			 Else

				if GenericVersionCode($release_distribution_version) >= 18 Then
					$liveimg_text="rd.live.image"
				Else
					$liveimg_text="liveimg"
				Endif
				; Boot menus for superior versions
				$boot_text &= @LF & "default vesamenu.c32" _
				 & @LF & "timeout 100" _
				 & @LF & "menu background splash.png" _
				 & @LF & "menu title Welcome to your LinuxLive Key !" _
				 & @LF & "menu clear" _
				 & @LF & "menu vshift 8" _
				 & @LF & "menu rows 18" _
				 & @LF & "menu margin 8" _
				 & @LF & "menu helpmsgrow 15" _
				 & @LF & "menu tabmsgrow 13" _
				 & @LF & "menu color border * #00000000 #00000000 none" _
				 & @LF & "menu color sel 0 #ffffffff #00000000 none" _
				 & @LF & "menu color title 0 #ff7ba3d0 #00000000 none" _
				 & @LF & "menu color tabmsg 0 #ff3a6496 #00000000 none" _
				 & @LF & "menu color unsel 0 #84b8ffff #00000000 none" _
				 & @LF & "menu color hotsel 0 #84b8ffff #00000000 none" _
				 & @LF & "menu color hotkey 0 #ffffffff #00000000 none" _
				 & @LF & "menu color help 0 #ffffffff #00000000 none" _
				 & @LF & "menu color scrollbar 0 #ffffffff #ff355594 none" _
				 & @LF & "menu color timeout 0 #ffffffff #00000000 none" _
				 & @LF & "menu color timeout_msg 0 #ffffffff #00000000 none" _
				 & @LF & "menu color cmdmark 0 #84b8ffff #00000000 none" _
				 & @LF & "menu color cmdline 0 #ffffffff #00000000 none" _
				 & @LF & "label live" _
				 & @LF & "  menu label " & Translate("Live Mode") _
				 & @LF & "  kernel "&$vmlinuz_file _
				 & @LF & "  append initrd="&$initrd_file&" root=UUID=" & $uuid & " rootfstype=vfat ro "&$liveimg_text&" quiet rhgb rd.luks=0 rd.md=0 rd.dm=0" _
				 & @LF & "  menu default"

			If FileExists($usb_letter & '\LiveOS\overlay-' & StringReplace(DriveGetLabel($usb_letter)," ", "_") & '-' & $uuid) Then
				 $boot_text&= @LF & "label persist" _
				 & @LF & "  menu label " & Translate("Persistent Mode") _
				 & @LF & "  kernel "&$vmlinuz_file _
				 & @LF & "  append initrd="&$initrd_file&" root=UUID=" & $uuid & " rootfstype=vfat rw "&$liveimg_text&" overlay=UUID=" & $uuid & " quiet rhgb rd.luks=0 rd.md=0 rd.dm=0"
			EndIf
				$boot_text&=@LF &"menu begin ^Troubleshooting" _
				 & @LF & "    menu title Troubleshooting" _
				 & @LF & "  label basic0" _
				 & @LF & "    menu label Start in ^basic graphics mode." _
				 & @LF & "    kernel "&$vmlinuz_file _
				 & @LF & "    append initrd="&$initrd_file&" root=UUID=" & $uuid & " rootfstype=vfat ro "&$liveimg_text&" quiet  rhgb rd.luks=0 rd.md=0 rd.dm=0 xdriver=vesa nomodeset" _
 				 & @LF & "   text help" _
				 & @LF & "        Try this option out if you're having trouble installing Fedora 16." _
 				 & @LF & "   endtext" _
				 & @LF & "  label check0" _
				 & @LF & "    menu label "& Translate("File Integrity Check") _
				 & @LF & "    kernel "&$vmlinuz_file _
				 & @LF & "    append initrd="&$initrd_file&" root=UUID=" & $uuid & " rootfstype=vfat ro "&$liveimg_text&" quiet  rhgb rd.luks=0 rd.md=0 rd.dm=0 rd.live.check" _
				 & @LF & "  label memtest" _
				 & @LF & "    menu label "& Translate("Memory Test") _
				 & @LF & "    text help" _
				 & @LF & "      If your system is having issues, a problem with your" _
				 & @LF & "      system's memory may be the cause. Use this utility to " _
 				 & @LF & "     see if the memory is working correctly." _
				 & @LF & "    endtext" _
				 & @LF & "    kernel memtest" _
				 & @LF & "  menu separator" _
				 & @LF & "  label local" _
				 & @LF & "    menu label Boot from ^local drive" _
 				 & @LF & "   localboot 0xffff" _
				 & @LF & "  menu separator" _
				 & @LF & "  label returntomain" _
				 & @LF & "    menu label Return to ^main menu." _
				 & @LF & "    menu exit" _
				 & @LF & "  menu end	"
			 EndIf
	FileOverWrite($usb_letter & "\syslinux\syslinux.cfg",$boot_text)
	UpdateLog("IN-Fedora_WriteTextCFG : Creating '"&$usb_letter & "\syslinux\syslinux.cfg"&"' config file :" & @CRLF & $boot_text)
	SendReport("End-Fedora_WriteTextCFG")
EndFunc   ;==>Fedora_WriteTextCFG


Func CentOS_WriteTextCFG()
	SendReport("Start-CentOS_WriteTextCFG")
	Local $boot_text = "", $uuid
	$uuid = Get_Disk_UUID($usb_letter)

	AutoDetectINITRD($usb_letter&"\syslinux\")
	AutoDetectVMLINUZ($usb_letter&"\syslinux\")

	$boot_text &= @LF & "default vesamenu.c32" _
			 & @LF & "timeout 100" _
			 & @LF & "menu background splash.jpg" _
			 & @LF & "menu title Welcome to CentOS !" _
			 & @LF & "menu color border 0 #ffffffff #00000000" _
			 & @LF & "menu color sel 7 #ffffffff #ff000000" _
			 & @LF & "menu color title 0 #ffffffff #00000000" _
			 & @LF & "menu color tabmsg 0 #ffffffff #00000000" _
			 & @LF & "menu color unsel 0 #ffffffff #00000000" _
			 & @LF & "menu color hotsel 0 #ff000000 #ffffffff" _
			 & @LF & "menu color hotkey 7 #ffffffff #ff000000" _
			 & @LF & "menu color timeout_msg 0 #ffffffff #00000000" _
			 & @LF & "menu color timeout 0 #ffffffff #00000000" _
			 & @LF & "menu color cmdline 0 #ffffffff #00000000" _
			 & @LF & "menu hidden" _
			 & @LF & "menu hiddenrow 5"

	If FileExists($usb_letter & '\LiveOS\overlay-' & StringReplace(DriveGetLabel($usb_letter)," ", "_") & '-' & $uuid) Then
			 $boot_text&= @LF & "label persist" _
			 & @LF & "  menu label " & Translate("Persistent Mode") _
			 & @LF & "  kernel "&$vmlinuz_file _
			 & @LF & "  append initrd="&$initrd_file&" root=UUID=" & $uuid & " rootfstype=vfat rw liveimg quiet overlay=UUID="&$uuid
	EndIf

  $boot_text&= @LF & "label live" _
			 & @LF & "  menu label " & Translate("Live Mode") _
			 & @LF & "  kernel "&$vmlinuz_file _
			 & @LF & "  append initrd="&$initrd_file&" root=UUID=" & $uuid & " rootfstype=vfat rw liveimg quiet " _
			 & @LF & "menu default" _
			 & @LF & "label installer" _
			 & @LF & "  menu label Network Installation" _
			 & @LF & "  kernel vminst" _
			 & @LF & "  append initrd=install.img text" _
			 & @LF & "label memtest" _
			 & @LF & " menu label " & Translate("Memory Test") _
			 & @LF & "  kernel memtest" _
			 & @LF & "label local" _
			 & @LF & "  menu label Boot from local drive" _
			 & @LF & "  localboot 0xffff"
	FileOverWrite($usb_letter & "\syslinux\syslinux.cfg",$boot_text)
	UpdateLog("IN-CentOS_WriteTextCFG : Creating CentOS syslinux config file :" & @CRLF & $boot_text)
	SendReport("End-CentOS_WriteTextCFG")
EndFunc   ;==>CentOS_WriteTextCFG

Func Mandriva_WriteTextCFG()
	SendReport("Start-Mandriva_WriteTextCFG")
	Local $boot_text = ""
	$uuid = Get_Disk_UUID($usb_letter)

	AutoDetectINITRD($usb_letter&"\syslinux\")
	AutoDetectVMLINUZ($usb_letter&"\syslinux\")

	$boot_text &= @LF & "default vesamenu.c32" _
			 & @LF & "font cyra8x16.psf" _
			 & @LF & "timeout 100" _
			 & @LF & "menu background splash.jpg" _
			 & @LF & "menu title Welcome to Mandriva" _
			 & @LF & "menu tabmsg Press [Tab] to edit options" _
			 & @LF & "menu passprompt Password required" _
			 & @LF & "menu autoboot Automatic boot in # second{,s}..." _
			 & @LF & "menu color border 0 #ffffffff #00000000" _
			 & @LF & "menu color sel 7 #ffffffff #ff000000" _
			 & @LF & "menu color title 0 #ffffffff #00000000" _
			 & @LF & "menu color tabmsg 0 #ffffffff #00000000" _
			 & @LF & "menu color unsel 0 #ffffffff #00000000" _
			 & @LF & "menu color hotsel 0 #ff000000 #ffffffff" _
			 & @LF & "menu color hotkey 7 #ffffffff #ff000000" _
			 & @LF & "menu color timeout_msg 0 #ffffffff #00000000" _
			 & @LF & "menu color timeout 0 #ffffffff #00000000" _
			 & @LF & "menu color cmdline 0 #ffffffff #00000000" _
			 & @LF & "label live" _
			 & @LF & "  menu label " & Translate("Live Mode") _
			 & @LF & "  kernel "&$vmlinuz_file _
			 & @LF & "  append initrd="&$initrd_file&" root=UUID=" & $uuid & " rootfstype=auto ro liveimg overlay=UUID=" & $uuid & " vga=788 desktop nopat rd_NO_LUKS rd_NO_MD noiswmd splash=silent" _
			 & @LF & "menu default"
	If FileExists($usb_letter & '\LiveOS\overlay-' & StringReplace(DriveGetLabel($usb_letter)," ", "_") & '-' & $uuid) Then
		$boot_text &= @LF & "label persist" _
			 & @LF & "  menu label " & Translate("Persistent Mode") _
			 & @LF & "  kernel "&$vmlinuz_file _
			 & @LF & "  append initrd="&$initrd_file&" root=UUID=" & $uuid & " rootfstype=auto rw liveimg overlay=UUID=" & $uuid & " vga=788 desktop nopat rd_NO_LUKS rd_NO_MD noiswmd splash=silent"
	EndIf
		$boot_text &= @LF & "label install" _
			 & @LF & "  menu label " & Translate("Install") _
			 & @LF & "  kernel "&$vmlinuz_file _
			 & @LF & "  append initrd="&$initrd_file&" root=UUID=" & $uuid & " rootfstype=auto ro liveimg install overlay=UUID=" & $uuid & " vga=788 desktop nopat rd_NO_LUKS rd_NO_MD noiswmd splash=silent" _
			 & @LF & "label local" _
			 & @LF & "  menu label Boot from local drive" _
			 & @LF & "  localboot 0xffff"

	FileOverWrite($usb_letter & "\syslinux\syslinux.cfg",$boot_text)
	SendReport("End-Mandriva_WriteTextCFG")
EndFunc   ;==>Mandriva_WriteTextCFG

Func Crunchbang_WriteTextCFG()
	UpdateLog("Start-Crunchbang_WriteTextCFG")


	AutoDetectINITRD($usb_letter&"\live\")
	AutoDetectVMLINUZ($usb_letter&"\live\")

	If StringInStr($release_supported_features,"debian-persistence") Then
		$prepend = "label persist" _
		& @LF & "menu label Persistent" _
		& @LF & "kernel /live/"&$vmlinuz_file _
		& @LF & "append initrd=/live/"&$initrd_file&" boot=live config persistent quiet"

		; read original boot menu
		$original_boot=FileRead($usb_letter & "\syslinux\live.cfg")

		; Backup original boot menu
		FileMove($usb_letter & "\syslinux\live.cfg",$usb_letter & "\syslinux\live.cfg-orig")

		; Append Persistence if necessary
		FileWrite($usb_letter & "\syslinux\live.cfg",$prepend& @LF & @LF &$original_boot)
	EndIf
	SendReport("End-Crunchbang_WriteTextCFG")
EndFunc

Func XBMC_WriteTextCFG()
	UpdateLog("Start-XBMC_WriteTextCFG")

	AutoDetectINITRD($usb_letter&"\live\")
	AutoDetectVMLINUZ($usb_letter&"\live\")

	$prepend = "default 0" _
		& @LF & "timeout 30" _
		& @LF & "foreground e3e3e3" _
		& @LF & "background 303030"


	If StringInStr($release_supported_features,"debian-persistence") Then
		$prepend &= @LF & @LF & "title XBMCLive Persistent" _
			& @LF & "kernel /live/"&$vmlinuz_file&" video=vesafb boot=live persistent xbmc=autostart,nodiskmount splash quiet loglevel=0 persistent quickreboot quickusbmodules notimezone noaccessibility noapparmor noaptcdrom noautologin noxautologin noconsolekeyboard nofastboot nognomepanel nohosts nokpersonalizer nolanguageselector nolocales nonetworking nopowermanagement noprogramcrashes nojockey nosudo noupdatenotifier nouser nopolkitconf noxautoconfig noxscreensaver nopreseed union=aufs" _
			& @LF & "initrd /live/"&$initrd_file

		; Default to Live (non persistent)
		$prepend = StringReplace($prepend,"default 0","default 1")
	EndIf

	$boot_menu=FileRead(@ScriptDir & "\tools\boot-menus\xbmc-menu.lst")
	FileWrite($usb_letter & "\boot\grub\menu.lst",$prepend& @LF & @LF &$boot_menu)

	SendReport("End-XBMC_WriteTextCFG")
EndFunc

Func Set_OpenSuse_MBR_ID($usb_letter,$clean_trailing_zeroes=1)
	SendReport("Start-Set_OpenSuse_MBR_ID")
	Local $mbr_id = "0x"&Get_MBR_ID($usb_letter,$clean_trailing_zeroes)
	FileMove($usb_letter&"\boot\grub\mbrid",$usb_letter&"\boot\grub\backup-mbrid")
	$file = FileOpen($usb_letter&"\boot\grub\mbrid", 10)

	; Check if file opened for writing OK
	If $file = -1 Then
		SendReport("IN-Set_OpenSuse_MBR_ID : Could not open MBRID file")
		Return "ERROR"
	EndIf
	FileWrite($usb_letter&"\boot\grub\mbrid",$mbr_id)
	SendReport("End-Set_OpenSuse_MBR_ID : Successfully set MBR ID file to "&$mbr_id)
EndFunc

Func AutoDetectINITRD($base_path_initrd)
	; Default value of initrd
	$initrd_file="initrd.lz"
	$autodetect_initrd_success=1

	if ReleaseHasFeature("initrd-location") AND ReleaseGetFeatureValue("initrd-location") <> "" Then
		$base_path_initrd=ReleaseGetFeatureValue("initrd-location")
		SendReport("INITRD Autodetection : Forced with initrd-location ( "&$base_path_initrd&" )")
	EndIf

	; Autodetection of initrd file (Ubuntu versions > 9.10 use an initrd.lz instead of initrd.gz file)
	If FileExists($base_path_initrd & "initrd.gz") == 1 Then
		$initrd_file = "initrd.gz"
	Elseif FileExists($base_path_initrd & "initrd.lz") == 1 Then
		$initrd_file = "initrd.lz"
	Elseif FileExists($base_path_initrd & "initrd.img") == 1 Then
		$initrd_file = "initrd.img"
	Elseif FileExists($base_path_initrd & "initrd2.img") == 1 Then
		$initrd_file = "initrd2.img"
	Elseif FileExists($base_path_initrd & "initrd1.img") == 1 Then
		$initrd_file = "initrd1.img"
	Elseif FileExists($base_path_initrd & "initrd0.img") == 1 Then
		$initrd_file = "initrd0.img"
	Elseif FileExists($base_path_initrd & "initrd1") == 1 Then
		$initrd_file = "initrd1"
	Elseif FileExists($base_path_initrd & "initrd0") == 1 Then
		$initrd_file = "initrd0"
	Elseif FileExists($base_path_initrd & "initrd") == 1 Then
		$initrd_file = "initrd"
	Else
		$search = FileFindFirstFile($base_path_initrd & "initr*")
		; Check if the search was successful
		If $search = -1 Then
			$autodetect_initrd_success=0
		Else
			$initrd_file = FileFindNextFile($search)
		EndIf
	EndIf

	; Log autodetection result
	if $autodetect_initrd_success==1 then
		SendReport("INITRD Autodetection : OK ( found file : "&$base_path_initrd&$initrd_file&" )")
	Else
		SendReport("INITRD Autodetection : ERROR ( using default file : "&$base_path_initrd&$initrd_file&" )")
	EndIf

	Return $initrd_file
EndFunc

Func AutoDetectVMLINUZ($base_path_vmlinuz)

	; Default value of vmlinuz
	$vmlinuz_file = "vmlinuz"
	$autodetect_vmlinuz_success=1

	if ReleaseHasFeature("vmlinuz-location") AND ReleaseGetFeatureValue("vmlinuz-location") <> "" Then
		$base_path_vmlinuz=ReleaseGetFeatureValue("vmlinuz-location")
		SendReport("VMLINUZ Autodetection : Forced with vmlinuz-location ( "&$base_path_vmlinuz&" )")
	EndIf

	; Autodetection of vmlinuz file (Ubuntu 13.04 and 12.04.2 x64 has an EFI compatible vmlinuz file)
	If FileExists($base_path_vmlinuz & "vmlinuz.efi") == 1 Then
		$vmlinuz_file = "vmlinuz.efi"
	Elseif FileExists($base_path_vmlinuz & "vmlinuz") == 1 Then
		$vmlinuz_file = "vmlinuz"
	Elseif FileExists($base_path_vmlinuz & "vmlinuz2") == 1 Then
		$vmlinuz_file = "vmlinuz2"
	Elseif FileExists($base_path_vmlinuz & "vmlinuz1") == 1 Then
		$vmlinuz_file = "vmlinuz1"
	Elseif FileExists($base_path_vmlinuz & "vmlinuz0") == 1 Then
		$vmlinuz_file = "vmlinuz0"
	Else
		$search = FileFindFirstFile($base_path_vmlinuz & "vmlinuz*")
		; Check if the search was successful
		If $search = -1 Then
			$autodetect_vmlinuz_success=0
		 Else
			 $vmlinuz_file = FileFindNextFile($search)
		EndIf
	EndIf

	; Log autodetection result
	if $autodetect_vmlinuz_success==1 then
		SendReport("VMLINUZ Autodetection : OK ( found file : "&$base_path_vmlinuz&$vmlinuz_file&" )")
	Else
		SendReport("VMLINUZ Autodetection : ERROR ( using default file : "&$base_path_vmlinuz&$vmlinuz_file&" )")
	EndIf

	Return $vmlinuz_file
EndFunc



