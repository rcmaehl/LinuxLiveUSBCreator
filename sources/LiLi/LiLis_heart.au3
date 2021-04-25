
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Format a specified drive letter to FAT32
	Input :
		$usb_letter = Letter of the drive (pre-formated like "E:" )
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func Format_FAT32()
	SendReport("Start-Format_FAT32 ( Drive : "& $usb_letter &" )")
	UpdateStatus("Formating the key")
	$usb_size_GB=Round($usb_space_total/1024,1)
	if $usb_size_GB<32 AND ReadSetting( "Advanced", "force_3rdparty_format") <> "yes" Then
		UpdateLog("Drive is smaller than 32GB ("&$usb_size_GB&"GB)-> LiLi will use the Windows Format utility")
		; default Method, will force work even when some applications are locking the drive
		RunWait3('cmd /c format /Q /X /y /V:MyLinuxLive /FS:FAT32 ' & $usb_letter)
	Else
		; Alternative method using fat32format for filesystems bigger than 32GB
		if ReadSetting( "Advanced", "force_3rdparty_format") = "yes" Then
			UpdateLog("force_3rdparty_format="&ReadSetting( "Advanced", "force_3rdparty_format")&" -> LiLi will use the Third party format utility")
		Else
			UpdateLog("Drive is bigger than 32GB ("&$usb_size_GB&"GB) and force_3rdparty_format="&ReadSetting( "Advanced", "force_3rdparty_format")&"-> LiLi will use the Third party format utility")
		EndIf
		$format_try=0
		Do
			SendReport("Trying to format (retry #"&$format_try&")")
			$format_result = FAT32Format($usb_letter,"MyLinuxLive")
			$format_try+=1
			Sleep(5000)
		Until ($format_result>=0 OR $format_try=5)

		If ($format_result=-1 AND $format_try>=5 ) Then SendReport("End-Format_FAT32 : ERROR, Could not format disk even after 5 retries")
	EndIf

	SendReport("End-Format_FAT32")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Clean previous Linux Live installs
	Input :
		$usb_letter = Letter of the drive (pre-formated like "E:" )
		$release_number = number of the release in the compatibility list (-1 if not present)
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func Clean_old_installs()
	If ReadSetting( "Advanced", "skip_cleaning") = "yes" Then Return 0
	SendReport("Start-Clean_old_installs ( Drive : "& $usb_letter &" - Release : "& $release_number &" )")
	UpdateStatus("Cleaning previous installations ( 2min )")

	if SmartCleanPreviousInstall($usb_letter)=1 Then
		SendReport("End-Clean_old_installs -> Autocleaning successful")
		Return 1
	Else
		SendReport("IN-Clean_old_installs -> Autocleaning not working, now using the old alertnative method")
	EndIf


	If FileExists($usb_letter & "\autorun.inf") AND NOT FileExists($usb_letter & "\autorun.inf.orig") Then FileMove($usb_letter & "\autorun.inf",$usb_letter & "\autorun.inf.orig",1)
	FileDelete2($usb_letter & "\autorun.inf")
	FileDelete2($usb_letter & "\lili.ico")

	FileDelete2($usb_letter&"\"&$autoclean_settings)
	FileDelete2($usb_letter&"\"&$autoclean_file)

	if ReadSetting( "Advanced", "skip_full_cleaning") <> "yes" Then

		; Common Linux Live files
		DirRemove2($usb_letter & "\isolinux\", 1)
		DirRemove2($usb_letter & "\syslinux\", 1)
		FileDelete2($usb_letter & "\autorun.inf")
		FileDelete2($usb_letter & "\ldlinux.sys")

		; Classic Ubuntu files
		DirRemove2($usb_letter & "\.disk\", 1)
		DirRemove2($usb_letter & "\casper\", 1)
		DirRemove2($usb_letter & "\preseed\", 1)
		DirRemove2($usb_letter & "\dists\", 1)
		DirRemove2($usb_letter & "\install\", 1)
		DirRemove2($usb_letter & "\pics\", 1)
		DirRemove2($usb_letter & "\pool\", 1)
		FileDelete2($usb_letter & "\wubi.exe")
		FileDelete2($usb_letter & "\ubuntu")
		FileDelete2($usb_letter & "\umenu.exe")
		FileDelete2($usb_letter & "\casper-rw")
		FileDelete2($usb_letter & "\md5sum.txt")
		FileDelete2($usb_letter & "\README.diskdefines")

		; Mint files
		FileDelete2($usb_letter & "\lmmenu.exe")
		FileDelete2($usb_letter & "\mint4win.exe")
		DirRemove2($usb_letter & "\drivers\",1)
		FileDelete2($usb_letter & "\.disc_id")

		; Mandriva files
		FileDelete2($usb_letter & "\README.pdf")
		FileDelete2($usb_letter & "\LISEZMOI.pdf")

		DirRemove2($usb_letter & "\loopbacks\",1)
		DirRemove2($usb_letter & "\isolinux\",1)
		DirRemove2($usb_letter & "\autorun\",1)
		DirRemove2($usb_letter & "\boot\",1)

		; Fedora files
		FileDelete2($usb_letter & "\README")
		FileDelete2($usb_letter & "\GPL")
		DirRemove2($usb_letter & "\LiveOS\",1)
		DirRemove2($usb_letter & "\EFI\",1)

		; other files
		FileDelete2($usb_letter & "\Clonezilla-Live-Version")
		FileDelete2($usb_letter & "\COPYING")
		DirRemove2($usb_letter & "\KNOPPIX\",1)
		DirRemove2($usb_letter & "\lamppix\",1)
		DirRemove2($usb_letter & "\ntpasswd\",1)
		DirRemove2($usb_letter & "\bootprog\",1)
		DirRemove2($usb_letter & "\bootdisk\",1)
		FileDelete2($usb_letter & "\sysrcd.dat")
		FileDelete2($usb_letter & "\sysrcd.md5")
		FileDelete2($usb_letter & "\usbstick.htm")
		FileDelete2($usb_letter & "\grldr")
		FileDelete2($usb_letter & "\menu.lst")
		FileDelete2($usb_letter & "\BootCD.txt")
		DirRemove2($usb_letter & "\HBCD\",1)
	EndIf
	SendReport("End-Clean_old_installs")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Check for VirtualBox update online
	Input :
		No input
	Output :
		None
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func Check_VirtualBox_Update()
	SendReport("Start-Check_VirtualBox_Update")
	; Checking online for an update
	$vbox_last_version=IniRead($updates_ini,"VirtualBox","version","")
	$cached_version=IniRead(@ScriptDir&"\tools\VirtualBox\Portable-VirtualBox\linuxlive\settings.ini","General","pack_version","0")
	$compare = CompareVersion($vbox_last_version,$cached_version)
	if $compare=1 Then
		SendReport("END-Check_VirtualBox_Update : Online version is newer, need to download the update")
		Return "UPDATE-AVAILABLE"
	elseif $compare=2 Then
		SendReport("END-Check_VirtualBox_Update : Online version is older (SVN repo ?), nothing to do ")
		return "NO-UPDATE"
	Else
		SendReport("END-Check_VirtualBox_Update : They are equal, nothing to do")
		return "NO-UPDATE"
	EndIf

EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Download last Portable-VirtualBox as a background task
	Input :
		No input
	Output :
		0 = No Vbox install can be done
		1 = Vbox is being downloaded
		2 = Vbox is already downloaded
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func Download_virtualBox()
	Global $current_download
	SendReport("Start-Download_virtualBox")

	if Check_VirtualBox_Update() <> "UPDATE-AVAILABLE" Then
		SendReport("END-Download_virtualBox : no update to download")
		Return 2
	EndIf

	UpdateStatus("Setting up virtualization software")
	$no_internet = 0
	$virtualbox_size = IniRead($updates_ini,"VirtualBox","filesize",0)
	If $virtualbox_size=0 Then
		SendReport("END-Download_virtualBox : could not check update size")
		Return 2
	EndIf

	$mirrors_nbr=10
	$i=1

	Dim $vbox_mirrors[10]
	Do
		$vbox_mirrors[$i-1]=IniRead($updates_ini,"VirtualBox","Mirror"&$i,"")
		$i+=1
	Until $i>$mirrors_nbr

	$i=0
	Do
		$size=InetGetSize($vbox_mirrors[$i],3)
		$i+=1
	Until ($size=$virtualbox_size OR $i=10)

	if NOT $size=$virtualbox_size Then
		SendReport("END-Download_virtualBox : could not find an online mirror")
		Return 2
	Else
		$downloaded_virtualbox_filename = "VirtualBox.zip"
		$online_mirror=$vbox_mirrors[$i-1]
		SendReport("IN-Download_virtualBox : using online mirror "&$online_mirror)
	EndIf




					UpdateStatus("A new version of VirtualBox is available")
					Sleep(700)
					UpdateStatus("Downloading VirtualBox as a background task")
					Sleep(700)
					FileDelete(@ScriptDir & "\tools\" & $downloaded_virtualbox_filename)
					$current_download = InetGet($online_mirror, @ScriptDir & "\tools\" & $downloaded_virtualbox_filename, 3, 1)
					If InetGetInfo($current_download, 4)=0 Then
						UpdateStatus("Download started succesfully")
						$check_vbox = 1
					Else
						UpdateStatus("Download failed to start")
						Sleep(1000)
						UpdateStatus("VirtualBox will not be installed")
						$check_vbox = 0
					EndIf

				Sleep(2000)
				SendReport("End-Download_virtualBox")
				Return $check_vbox
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Uncompress ISO directly on the key
	Input :
		$usb_letter =  Letter of the drive (pre-formated like "E:" )
		$iso_file = path to the iso file of a Linux Live CD
		$release_number = number of the release in the compatibility list (-1 if not present)
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func Uncompress_ISO_on_key($iso_file)
	If ReadSetting("Advanced", "skip_copy") = "yes" Then Return 0
	SendReport("Start-Uncompress_ISO_on_key ( Drive : "& $usb_letter &" - File : "& $iso_file &" - Release : "& $release_number &" )")

	If ProcessExists("7z.exe") > 0 Then ProcessClose("7z.exe")
	UpdateStatus(Translate("Extracting ISO file on key") & " ( 5-10" & Translate("min") & " )")

	#cs
	if ReleaseGetCodename($release_number)="default" Then
		$install_size=Round(FileGetSize($iso_file)/1048576)
	Else
		$install_size = ReleasegetInstallSize($release_number)
	EndIf
	#ce
	if get_extension($iso_file)="iso" Then
		$install_size=Round(FileGetSize($iso_file)/1048576)
	Else
		$install_size = $release_install_size
	EndIf

	; Just in case ...
	If $install_size < 5 Then $install_size = 730
	$uncompress_timer = TimerInit()
	Run7zip('"' & @ScriptDir & '\tools\7z.exe" x "' & $iso_file & '" -x![BOOT]* -r -y -aoa -o' & $usb_letter, $install_size)
	$uncompress_duration_sec = Round(TimerDiff($uncompress_timer)/1000,2)
	$uncompress_speed = Round($install_size/$uncompress_duration_sec,1)
	SendReport("ISO of "&$install_size&" MB uncompressed in approximately "&HumanTime($uncompress_duration_sec)&" @ "&$uncompress_speed&" MB/sec")
	SendReport("End-Uncompress_ISO_on_key")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Creates a bootable USB stick from a CD
	Input :
		$usb_letter = Letter of the drive (pre-formated like "E:" )
		$path_to_cd = path to the CD or folder containing the Linux Live CD files
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func Create_Stick_From_CD($path_to_cd)
	If ReadSetting("Advanced", "skip_copy") = "yes" Then Return 0
	SendReport("Start-Create_Stick_From_CD ( Drive : "& $usb_letter &" - CD Folder : "& $path_to_cd &" )")
	FileCopyShell($path_to_cd & "\*.*", $usb_letter & "\")
	SendReport("End-Create_Stick_From_CD")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Copy already uncompressed iso or CD files on the key
	Input :
		$usb_letter = Letter of the drive (pre-formated like "E:" )
		$img_file = pimg file containing a USB stick image
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func Create_Stick_From_IMG($img_file)
	SendReport("Start-Create_Stick_From_IMG ( Drive : "& $usb_letter &" - File : "& $img_file & " )")
	Local $cmd, $foo, $line,$lines="",$errors="", $img_size,$physical_disk_number

	$physical_disk_number=GiveMePhysicalDisk($usb_letter)

	if NOT ($physical_disk_number <> "ERROR" AND $physical_disk_number >0 AND $physical_disk_number <> GiveMePhysicalDisk("C:")) Then
		MsgBox(16,"Error","There was an error while trying to write IMG file to USB."&@CRLF&@CRLF&"Please contact debug-img@linuxliveusb.com."&@CRLF&@CRLF&"Thank You")
		Return -1
	EndIf

	$img_size= Ceiling(FileGetSize($img_file)/1048576)
	$cmd = @ScriptDir & '\tools\dd.exe if="'&$img_file&'" of=\\.\'& $usb_letter&' bs=1M --progress'
	UpdateLog($cmd)
	If ProcessExists("dd.exe") > 0 Then ProcessClose("dd.exe")
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDIN_CHILD + $STDOUT_CHILD + $STDERR_CHILD)
	While 1
		$line &= StdoutRead($foo)
		If @error Then ExitLoop
		$lines&=$line
		; Regular Expression to parse progression
		$str = StringRight($line,20)
		$is = StringRegExp($line, '\r([0-9]{1,4}\,[0-9]{1,3}\,[0-9]{1,3})\r', 0)
		if $is =1 Then
			$array= StringRegExp($line, '\r([0-9]{1,4}\,[0-9]{1,3}\,[0-9]{1,3})\r', 3)
				$mb_written = Ceiling(StringReplace($array[UBound($array)-1],",","")/1048576)
				$percent_written = Ceiling(100*$mb_written/$img_size)
				ProgressSet( $percent_written , $mb_written & " MB / "&$img_size& "MB ( "&$percent_written&"% )")
				UpdateStatusNoLog(Translate("Writing image to the usb stick") & " " & $mb_written & " " & Translate("MB") &" / "&$img_size& Translate("MB") &" ( "&$percent_written&"% )")
				$line=""
		EndIf
		Sleep(500)
	Wend
	While 1
		$errors &= StderrRead($foo)
		If @error Then ExitLoop
	WEnd
	UpdateLog($lines&$errors)
	if StringInStr($errors,"error") Then
		UpdateStatus(Translate("An error occurred")&"."&@CRLF&Translate("Please close any application accessing your key and try again")&".")
		Return -1
	EndIf
	SendReport("End-Create_Stick_From_IMG")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func isolinux2syslinux($syslinux_path)
	SendReport("Start-isolinux2syslinux on path :"&$syslinux_path)
	; Replacing references to isolinux/ by syslinux/ in *.cfg files
	$search = FileFindFirstFile($syslinux_path&"*.cfg")
	If $search <> -1 Then
		While 1
			$file = FileFindNextFile($search)
			If @error Then ExitLoop
			$content = FileRead($syslinux_path&$file)
			if StringInStr($content,"isolinux/")>0 Then
				SendReport("Found a file ("&$syslinux_path&$file&") with a reference to 'isolinux/' => replacing with 'syslinux/'")
				FileOverwrite($syslinux_path&$file,StringReplace($content,"isolinux/","syslinux/"))
			EndIf
		WEnd
		FileClose($search)
	EndIf

	; Replacing references to isolinux/ by syslinux/ in *.txt files
	$search = FileFindFirstFile($syslinux_path&"*.txt")
	If $search <> -1 Then
		While 1
			$file = FileFindNextFile($search)
			If @error Then ExitLoop
			$content = FileRead($syslinux_path&$file)
			if StringInStr($content,"isolinux/")>0 Then
				SendReport("Found a file ("&$syslinux_path&$file&") with a reference to 'isolinux/' => replacing with 'syslinux/'")
				FileOverwrite($syslinux_path&$file,StringReplace($content,"isolinux/","syslinux/"))
			EndIf
		WEnd
		FileClose($search)
	EndIf
	FileCopy($syslinux_path&"isolinux.cfg",$syslinux_path&"syslinux.cfg")
	SendReport("End-isolinux2syslinux")
EndFunc


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Rename and move some file in order to work on an USB key
	Input :
		$usb_letter = Letter of the drive (pre-formated like "E:" )
		$release_number = number of the release in the compatibility list (-1 if not present)
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func Rename_and_move_files()
	If ReadSetting("Advanced", "skip_moving_renaming") = "yes" Then Return 0
	SendReport("Start-Rename_and_move_files")
	UpdateStatus(Translate("Renaming some files"))


	;RunWait3("cmd /c rename " & $usb_letter & "\isolinux syslinux", @ScriptDir, @SW_HIDE)
	FileCopy2( $usb_letter & "\syslinux\text.cfg", $usb_letter & "\syslinux\text-orig.cfg")

		; Default Linux processing, no intelligence
		if Not FileExists($usb_letter & "\boot\syslinux") AND Not FileExists($usb_letter & "\syslinux") then
			DirMove($usb_letter & "\isolinux",$usb_letter & "\syslinux",1)
			DirMove($usb_letter & "\boot\isolinux",$usb_letter & "\boot\syslinux",1)
		EndIf


		;RunWait3("cmd /c rename " & $usb_letter & "\boot\isolinux syslinux", @ScriptDir, @SW_HIDE)
		;RunWait3("cmd /c rename " & $usb_letter & "\isolinux syslinux", @ScriptDir, @SW_HIDE)
		;RunWait3("cmd /c rename " & $usb_letter & "\HBCD\isolinux syslinux", @ScriptDir, @SW_HIDE)

		FileCopy2( $usb_letter & "\syslinux\isolinux.cfg", $usb_letter & "\syslinux\isolinux-orig.cfg")

		if FileExists($usb_letter & "\boot\syslinux\isolinux.cfg") Then
			$syslinux_path = $usb_letter & "\boot\syslinux\"
		Elseif FileExists($usb_letter & "\syslinux\isolinux.cfg") Then
			$syslinux_path = $usb_letter & "\syslinux\"
		Elseif FileExists($usb_letter & "\isolinux.cfg") Then
			$syslinux_path = $usb_letter & "\"
		Elseif FileExists($usb_letter & "\BOOT\SYSLINUX\syslinux.cfg") Then
			$syslinux_path = $usb_letter & "\BOOT\SYSLINUX\"
		Elseif FileExists($usb_letter & "\HBCD\isolinux.cfg") Then
			$syslinux_path = $usb_letter & "\HBCD\"
		Elseif FileExists($usb_letter & "\boot\i386\loader\isolinux.cfg") AND (ReleaseGetVariant($release_number)="opensuse" OR StringInStr(ReleaseGetSupportedFeatures($release_number),"opensuse-mbrid")>0 ) Then
			FileDelete($usb_letter&"\syslinux.cfg")
			DirMove($usb_letter & "\boot\i386\loader", $usb_letter & "\boot\syslinux",1)
			$syslinux_path = $usb_letter & "\boot\syslinux\"
		Else
			$syslinux_path = $usb_letter & "\"
		EndIf
		isolinux2syslinux($syslinux_path)

	; Fix for Parted Magic > 4.6 (support is discontinued for 4.6)
	If $release_variant = "pmagic"  Then
		$search = FileFindFirstFile($usb_letter&"\pmagic-usb-*")
		$search2 = FileFindFirstFile($usb_letter&"\pmagic-pxe-*")
		; Check if the search was successful
		If $search <> -1 Then
			$pmagic_folder = FileFindNextFile($search)
			SendReport("IN-Rename_and_move_files : Found pmagic USB folder (automatic) = "&$pmagic_folder)
		ElseIf $search2 <> -1 Then
			$pmagic_folder = FileFindNextFile($search2)
			SendReport("IN-Rename_and_move_files : Found pmagic PXE folder (automatic) = "&$pmagic_folder)
		Else
			if GenericVersionCode($release_variant_version) > "52" Then
				$look_for="pxe"
			Else
				$look_for="usb"
			EndIf
			$pmagic_folder="pmagic-"&$look_for&"-"&$release_variant_version
			SendReport("IN-Rename_and_move_files : Found pmagic folder (manual)= "&$pmagic_folder)
		EndIf

		DirMove( $usb_letter & "\"&$pmagic_folder&"\boot", $usb_letter,1)
		DirMove( $usb_letter & "\"&$pmagic_folder&"\pmagic", $usb_letter,1)
		FileSetAttrib($usb_letter & "\"&$pmagic_folder, "-R-A-H", 1)
		DirRemove( $usb_letter & "\"&$pmagic_folder&"\",1)
	EndIf

	; fix for bootlogo too big of PCLinuxOS 2010
	if NOT StringInStr($release_supported_features,"fix-bootlogo") = 0 Then
		SendReport("Fixing bootlogo too big")
		FileCopy2(@ScriptDir&"\tools\boot-menus\small-bootlogo",$usb_letter & "\syslinux\bootlogo")
	EndIf

	SendReport("End-Rename_and_move_files")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Create files for custom boot menu (including persistence options)
	Input :
		$usb_letter = Letter of the drive (pre-formated like "E:" )
		$release_number = number of the release in the compatibility list (-1 if not present)
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func Create_boot_menu()
	If ReadSetting("Advanced","skip_boot_text") = "yes" Then Return 0
	SendReport("Start-Create_boot_menu")
	if StringInStr($release_supported_features,"default") = 0 Then
		If $release_variant ="CentOS" Then
			if $release_variant_version > 6.9 Then
				SendReport("IN-Create_boot_menu for CentOS 6.9 and previous")
				CentOS_WriteTextCFG()
			Else
				SendReport("IN-Create_boot_menu for CentOS 7.0 and later (using Fedora menu)")
				Fedora_WriteTextCFG()
			EndIf
		Elseif $release_distribution = "Fedora" Then
			if $release_variant = "Mandriva" Then
				SendReport("IN-Create_boot_menu for Mandriva")
				Mandriva_WriteTextCFG()
			Else
				SendReport("IN-Create_boot_menu for Fedora")
				Fedora_WriteTextCFG()
			EndIf
		Elseif $release_variant = "TinyCore" Then
			SendReport("IN-Create_boot_menu for TinyCore")
			TinyCore_WriteTextCFG()
		Elseif $release_variant = "ReactOS" Then
			SendReport("IN-Create_boot_menu for ReactOS")
			ReactOS_WriteTextCFG()
		Elseif $release_variant = "Aptosid" Then
			SendReport("IN-Create_boot_menu for Aptosid")
			Aptosid_WriteTextCFG()
		Elseif $release_variant = "Sidux" Then
			SendReport("IN-Create_boot_menu for Sidux")
			Sidux_WriteTextCFG()
		Elseif $release_variant="XBMC" Then
			SendReport("IN-Create_boot_menu for XBMC")
			XBMC_WriteTextCFG()
		Elseif $release_variant = "backtrack" Then
			SendReport("IN-Create_boot_menu for BackTrack")
			BackTrack_WriteTextCFG()
		Elseif $release_distribution = "ubuntu" Then
			SendReport("IN-Create_boot_menu for Ubuntu")
			Ubuntu_WriteTextCFG()
		Elseif $release_distribution = "debian" Then
			SendReport("IN-Create_boot_menu for Debian")
			Debian_WriteTextCFG()
		Elseif $release_variant="Crunchbang" Then
			SendReport("IN-Create_boot_menu for CrunchBang")
			Crunchbang_WriteTextCFG()
		EndIf
	Elseif $release_variant="CDLinux" Then
		SendReport("IN-Create_boot_menu for CDLinux")
		CDLinux_WriteTextCFG()
	Elseif $release_variant="kali" Then
		SendReport("IN-Create_boot_menu for Kali")
		Kali_WriteTextCFG()
	Elseif $release_variant = "opensuse" Then
		If $release_variant_version = "11.3" Then
			SendReport("IN-Create_boot_menu for OpenSuse : Setting MBR ID (without trailing zeroes)")
			Set_OpenSuse_MBR_ID($usb_letter,1)
		Else
			SendReport("IN-Create_boot_menu for OpenSuse : Setting MBR ID (with trailing zeroes)")
			Set_OpenSuse_MBR_ID($usb_letter,0)
		EndIf
	ElseIf StringInStr($release_supported_features,"opensuse-mbrid-trailing")>0 then
			SendReport("IN-Create_boot_menu for OpenSuse variant: Setting MBR ID (with trailing zeroes)")
			Set_OpenSuse_MBR_ID($usb_letter,0)
	ElseIf StringInStr($release_supported_features,"opensuse-mbrid")>0 then
			SendReport("IN-Create_boot_menu for OpenSuse variant: Setting MBR ID (without trailing zeroes)")
			Set_OpenSuse_MBR_ID($usb_letter,1)

	Else
		SendReport("IN-Create_boot_menu for Regular Linux")
		Default_WriteTextCFG()
	EndIf
	SendReport("End-Create_boot_menu")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Hide files if user choose to
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func Hide_live_files()
	If ReadSetting("Advanced", "skip_hiding") = "yes" Then return 0
	SendReport("Start-Hide_live_files")
	Global $files_in_source
	UpdateStatus("Hiding files")
	HideFilesInDir($files_in_source)
	HideFile($usb_letter & "\syslinux\")
	HideFile($usb_letter & "\syslinux.cfg")

	HideFile($usb_letter & "\autorun.bak")
	HideFile($usb_letter & "\lili.ico")
	HideFile($usb_letter & "\autorun.inf")

	HideFile($usb_letter & "\" & $autoclean_settings)

	; Fix for Parted Magic 4.6
	If $release_variant="pmagic" Then
			HideFile($usb_letter & "\pmagic\")
			HideFile($usb_letter & "\readme.txt")
			HideFile( $usb_letter & "\boot\")
	EndIf

	#cs
	; Common Linux Live files
	HideFile($usb_letter & "\isolinux\")
	HideFile($usb_letter & "\syslinux\")
	HideFile($usb_letter & "\autorun.inf")

	; Classic Ubuntu files
	HideFile($usb_letter & "\.disk\")
	HideFile($usb_letter & "\casper\")
	HideFile($usb_letter & "\preseed\")
	HideFile($usb_letter & "\dists\")
	HideFile($usb_letter & "\install\")
	HideFile($usb_letter & "\pics\")
	HideFile($usb_letter & "\pool\")
	HideFile($usb_letter & "\wubi.exe")
	HideFile($usb_letter & "\ubuntu")
	HideFile($usb_letter & "\umenu.exe")
	HideFile($usb_letter & "\casper-rw")
	HideFile($usb_letter & "\md5sum.txt")
	HideFile($usb_letter & "\README.diskdefines")

	; Mint files
	HideFile($usb_letter & "\lmmenu.exe")
	HideFile($usb_letter & "\mint4win.exe")
	HideFile($usb_letter & "\drivers\")
	HideFile($usb_letter & "\.disc_id")

	; Fedora files
	HideFile($usb_letter & "\README")
	HideFile($usb_letter & "\GPL")
	HideFile($usb_letter & "\LiveOS\")
	HideFile($usb_letter & "\EFI\")

	; Mandriva files
	HideFile($usb_letter & "\README.pdf")
	HideFile($usb_letter & "\LISEZMOI.pdf")
	HideFile($usb_letter & "\autorun.inf")
	HideFile($usb_letter & "\loopbacks\")
	HideFile($usb_letter & "\isolinux\")
	HideFile($usb_letter & "\autorun\")
	HideFile($usb_letter & "\boot\")

	; Other distribs

	#ce

EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Create a persistence file
	Input :
		$usb_letter = Letter of the drive (pre-formated like "E:" )
		$release_number = number of the release in the compatibility list (-1 if not present)
		$persistence_size = size of persistence file in MB
		$hide_it = state of user checkbox about hiding file or not
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func Create_persistence_file($persistence_size,$hide_it)
	Global $persistence_file
	If ReadSetting( "Advanced", "skip_persistence") = "yes" Then Return 0
	SendReport("Start-Create_persistence_file")

	; Checking if persistence is supported for this Linux
	if StringInStr($release_supported_features,"persistence")=0 Then
		SendReport("End-Create_persistence_file : No persistence for release "&$release_codename)
		Return 0
	EndIf

	If $persistence_size > 0 Then
		UpdateStatus("Creating file for persistence")
		Sleep(1000)

		if StringInStr($release_supported_features,"ubuntu-persistence")<>0 Then
			; Ubuntu
			$persistence_file= 'casper-rw'
			UpdateLog("Found feature ubuntu-persistence, persistence file will be "&$persistence_file)
		Elseif StringInStr($release_supported_features,"backtrack-persistence")<>0 Then
			; BackTrack > v5
			$persistence_file= 'casper-rw'
			UpdateLog("Found feature backtrack-persistence, persistence file will be "&$persistence_file)
		Elseif StringInStr($release_supported_features,"sidux-persistence")<>0 Then
			; Sidux
			$persistence_file= "sidux\sidux-rw"
			UpdateLog("Found feature sidux-persistence, persistence file will be "&$persistence_file)
		Elseif StringInStr($release_supported_features,"aptosid-persistence")<>0 Then
			; Aptosid (ex-Sidux)
			$persistence_file= "aptosid\aptosid-rw"
			UpdateLog("Found feature aptosid-persistence, persistence file will be "&$persistence_file)
		Elseif StringInStr($release_supported_features,"fedora-persistence")<>0 OR StringInStr($release_supported_features,"mandriva-persistence")<>0 Then
			; Fedora and Mandriva
			$persistence_file= 'LiveOS\overlay-' & StringReplace(DriveGetLabel($usb_letter)," ", "_") & '-' & Get_Disk_UUID($usb_letter)
			UpdateLog("Found feature fedora-persistence (or mandriva-persistence), persistence file will be "&$persistence_file)
		Elseif StringInStr($release_supported_features,"debian-persistence")<>0 Then
			; Debian > 6.0 and CrunchBang 10 and XBMC Live
			$persistence_file= 'live-rw'
			UpdateLog("Found feature debian-persistence, persistence file will be "&$persistence_file)
		Elseif StringInStr($release_supported_features,"custom-persistence")<>0 Then
			; Custom persistence filename
			$features_array=StringSplit ($release_supported_features,",",2)
			FOR $feature IN $features_array
				if StringInStr($feature,"custom-persistence")<>0 Then
					$persistence_file=StringReplace($feature,"custom-persistence:","")
				EndIf
			Next
			if $persistence_file <> "" Then
				UpdateLog("Found feature custom-persistence, persistence file will be "&$persistence_file)
			Else
				$persistence_file= 'casper-rw'
				UpdateLog("Found feature custom-persistence but no persistence file set. Falling back to default file name ("&$persistence_file&")")
			EndIf

		Else
			; Default mode is Ubuntu
			$persistence_file= 'casper-rw'
			UpdateLog("Found feature  default persistence ??, persistence file will be "&$persistence_file)
		Endif

		Create_Empty_File($usb_letter&"\"&$persistence_file, $persistence_size)

		If ( $hide_it = $GUI_CHECKED) Then HideFile($usb_letter&"\"&$persistence_file)
		$time_to_format=3
		if ($persistence_size >= 1000) Then $time_to_format=6
		if ($persistence_size >= 2000) Then $time_to_format=10
		if ($persistence_size >= 3000) Then $time_to_format=15
		UpdateStatus(Translate("Formating persistence file") & " ( ~"& $time_to_format & " " & Translate("min") & " )")
		EXT2_Format_File($usb_letter&"\"&$persistence_file)
	Else
		UpdateStatus("Live mode : no persistence file")
	EndIf
	SendReport("End-Create_persistence_file")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : return True if a syslinux config file is found
	Input :
		$usb_letter = Letter of the drive (pre-formated like "E:" )
	Output :
		0 = syslinux not found (GRUB compatibility mode)
		1 = syslinux config found (use syslinux)
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func isSyslinuxCfgPresent()
	SendReport("Start-isSyslinuxCfgPresent")
	$config_found = (FileExists($usb_letter&"\boot\syslinux\syslinux.cfg") OR FileExists($usb_letter&"\syslinux\syslinux.cfg") OR FileExists($usb_letter&"\syslinux.cfg") OR FileExists($usb_letter & "\HBCD\syslinux.cfg") OR FileExists($usb_letter & "\slax\boot\syslinux.cfg"))
	SendReport("End-isSyslinuxCfgPresent : Found = "&$config_found)
	Return $config_found
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Build and install boot sectors in order to make the key bootable
	Input :
		$usb_letter = Letter of the drive (pre-formated like "E:" )
		$release_number = number of the release in the compatibility list (-1 if not present)
		$hide_it = state of user checkbox about hiding file or not
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func Install_boot_sectors($hide_it)
	If ReadSetting( "Advanced", "skip_bootsector") = "yes" Then Return 0
	SendReport("Start-Install_boot_sectors")
	UpdateStatus("Installing boot sectors")

	if StringInStr($release_supported_features,"windows-bootsect") > 0 Then
		; Windows mode
		If FileExists($usb_letter & "\boot\bootsect.exe") Then
			SendReport("IN-Install_boot_sectors : Found bootsect.exe, installing windows boot sectors")
			; Could not implement retries because bootsect does not return anything on STDIN/STDOUT ?!!
			InstallWindowsBootSectors($usb_letter)

			SendReport("End-Install_boot_sectors")
			return 0
		Else
			SendReport("IN-Install_boot_sectors : ERROR, bootsect.exe not found to satisfy windows-bootsect mode")
		EndIf
	Elseif StringInStr($release_supported_features,"grub") > 0 OR NOT isSyslinuxCfgPresent() Then
		; GRUB Mode
		UpdateLog("Variant is using GRUB loader")

		; Syslinux will chainload GRUB loader
		DirCreate($usb_letter &"\syslinux")
		FileCopy2(@ScriptDir & '\tools\grub.exe',$usb_letter & "\syslinux\grub.exe")
		FileCopy2(@ScriptDir & '\tools\boot-menus\grub-syslinux.cfg',$usb_letter & "\syslinux\syslinux.cfg")

		if NOT (FileExists($usb_letter&"\menu.lst") OR FileExists($usb_letter&"\boot\menu.lst") OR FileExists($usb_letter&"\boot\grub\menu.lst")) Then
			SendReport("IN-Install_boot_sectors :  ERROR, syslinux.cfg and menu.lst not found ")
		EndIf
	EndIf

	If FileExists($usb_letter & "\HBCD\syslinux.cfg") Then
		SendReport("IN-Install_boot_sectors :  Hiren's boot CD detected, using syslinux folder HBCD\ ")
		$syslinux_menu_folder = "/HBCD"
	ElseIf FileExists($usb_letter & "\slax\boot\syslinux.cfg") Then
		SendReport("IN-Install_boot_sectors :  Slax > 7 detected, using syslinux folder slax\boot\ ")
		$syslinux_menu_folder = "/slax/boot"
	Else
		$syslinux_menu_folder = 0
	EndIf


	; Selecting syslinux version
	if StringInStr($release_supported_features,"syslinux6") > 0 Then
		$fallback_version = 6
	Elseif StringInStr($release_supported_features,"syslinux5") > 0 Then
		$fallback_version = 5
	Elseif StringInStr($release_supported_features,"syslinux4") > 0 Then
		$fallback_version = 4
	Elseif StringInStr($release_supported_features,"syslinux3") > 0 Then
		$fallback_version = 3
	Else
		$fallback_version=4
	EndIf

	SendReport("IN-Install_boot_sectors :  Using syslinux fallback version : v"&$fallback_version)

	if StringInStr($release_supported_features,"force-syslinux") >0 Then
		; Not just a fallback version but a forced version instead
		$found_syslinux_version = AutoDetectSyslinuxVersion(4)
		SendReport("IN-Install_boot_sectors :  Syslinux version forced to v"&$fallback_version&" (found = v"&$found_syslinux_version&")")
		$syslinux_version=$fallback_version
	Else
		$syslinux_version = AutoDetectSyslinuxVersion($fallback_version)
	EndIf

	; Syslinux 3.X or superior
	if $syslinux_version < 3 Then
		$syslinux_version = 3
	EndIf


	if FileExists($usb_letter & "\boot\syslinux\syslinux.cfg") Then
		$syslinux_folder=$usb_letter & "\boot\syslinux\"
	Elseif FileExists($usb_letter & "\syslinux\syslinux.cfg") Then
		$syslinux_folder=$usb_letter & "\syslinux\"
	Elseif FileExists($usb_letter & "\hbcd\syslinux.cfg") Then
		$syslinux_folder=$usb_letter & "\hbcd\"
	Elseif FileExists($usb_letter & "\slax\boot\syslinux.cfg") Then
		$syslinux_folder=$usb_letter & "\slax\boot\"
	Elseif FileExists($usb_letter & "\syslinux.cfg") Then
		$syslinux_folder=$usb_letter & "\"
	Else
		SendReport("IN-Install_boot_sectors :  syslinux.cfg disappeared ?!!, trying with folder = "&$usb_letter & "\syslinux\")
		$syslinux_folder=$usb_letter & "\syslinux\"
	EndIf

	; Copying syslinux modules before creating boot sectors or it will not find mboot.c32 (reactos)
	SendReport("IN-Install_boot_sectors : checking syslinux modules to copy/keep")

	$modules_to_keep=""
	$modules_to_copy=""
	$features_array=StringSplit($release_supported_features,",",2)
	FOR $feature IN $features_array
		if StringInStr($feature,"keep-module:")<>0 Then
			$modules_to_keep&=StringReplace($feature,"keep-module:","")&"|"
		Elseif StringInStr($feature,"copy-module:")<>0 Then
			$modules_to_copy&=StringReplace($feature,"copy-module:","")&"|"
		EndIf
	Next
	If StringRight($modules_to_keep,1) == "|" Then $modules_to_keep=StringTrimRight($modules_to_keep,1)
	If StringRight($modules_to_copy,1) == "|" Then $modules_to_copy=StringTrimRight($modules_to_copy,1)

	SendReport("IN-Install_boot_sectors :  modules to keep='"&$modules_to_keep&"' and modules to copy='"&$modules_to_copy&"'")

	If $modules_to_copy <> "" Then
		$modules_to_copy_array=StringSplit($modules_to_copy,"|",3)
		FOR $modulename_to_copy IN $modules_to_copy_array
			FileCopy2(@ScriptDir&"\tools\syslinux-modules\v"&$syslinux_version&"\"&$modulename_to_copy,$syslinux_folder,9)
			; Hiding modules when in the root folder
			If ( ($syslinux_folder=($usb_letter&"\")) AND ( $hide_it == $GUI_CHECKED)) Then HideFile($usb_letter&"\"&$modulename_to_copy)
		Next
	EndIf
	; Replacing Syslinux modules by the good ones
	$search = FileFindFirstFile($syslinux_folder&"*.c32")
	; Check if the search was successful
	If $search <> -1 Then
		$found_modules=""
		While 1
			$file = FileFindNextFile($search)
			If @error Then ExitLoop
			$found_modules&=$file&"|"
		WEnd

		$found_modules=StringSplit(StringTrimRight($found_modules,1),"|",2)
		If Ubound($found_modules) > 0 Then
			For $module IN $found_modules
				if $module = "gfxboot.c32" Then
					SendReport("IN-Install_boot_sectors : Skip replacement of module "&$module&" to keep Ubuntu variants working")
				Elseif StringInStr($module,$modules_to_keep) Then
					SendReport("IN-Install_boot_sectors : Skip replacement of module "&$module&" because of parameter keep-module")
				Else
					$new_module=@ScriptDir&"\tools\syslinux-modules\v"&$syslinux_version&"\"&$module
					If FileExists($new_module) Then
						SendReport("IN-Install_boot_sectors : Replacing syslinux "&$syslinux_version&" module "&$module&" by the matching one")
						FileCopy2($new_module,$syslinux_folder)
						; Hiding modules when in the root folder
						If ( ($syslinux_folder=($usb_letter&"\")) AND ( $hide_it == $GUI_CHECKED)) Then HideFile($usb_letter&"\"&$module)
					Else
						SendReport("IN-Install_boot_sectors : WARNING, Could not replace syslinux "&$syslinux_version&" module "&$module&" by the matching one")
					EndIf
				EndIf
			Next
		Else
			SendReport("IN-Install_boot_sectors : No syslinux module to replace")
		Endif
	EndIf
	FileClose($search)




	$bootsectors_try=0
	Do
		SendReport("Trying to install syslinux boot sectors (retry #"&$bootsectors_try&")")
		$bootsectors_result = InstallSyslinux($syslinux_version,$syslinux_menu_folder)
		$bootsectors_try+=1
		Sleep(5000)
	Until ($bootsectors_result>=0 OR $bootsectors_try=5)

	if ($bootsectors_result=-1 AND $bootsectors_try>=5 ) Then SendReport("End-Install_boot_sectors : ERROR, Could not install syslinux boot sectors even after 5 retries")

	;RunWait3('"' & @ScriptDir & '\tools\syslinux.exe" -maf -d ' & $usb_letter & '\syslinux ' & $usb_letter, @ScriptDir, @SW_HIDE)
	If ( $hide_it <> $GUI_CHECKED) Then ShowFile($usb_letter & '\ldlinux.sys')
	SendReport("End-Install_boot_sectors")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Check if VirtualBox download is OK
	Input :
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func Check_virtualbox_download()
	SendReport("Start-Check_virtualbox_download")
	Global $virtualbox_size, $current_download
	Do
		$prog = Int((100 * InetGetInfo($current_download,0) / $virtualbox_size))
		UpdateStatusNoLog(Translate("Downloading VirtualBox") & "  : " & $prog & "% ( " & Round(InetGetInfo($current_download,0) / (1024 * 1024), 1) & "/" & Round($virtualbox_size / (1024 * 1024), 1) & " " & Translate("MB") & " )")
		Sleep(300)
	Until InetGetInfo($current_download, 2)

	UpdateStatus("Download complete")
	$control_md5=IniRead($updates_ini,"VirtualBox","file_md5","")
	$FileToHash=@ScriptDir & "\tools\" & $downloaded_virtualbox_filename

	Local $filehandle = FileOpen($FileToHash, 16)
	Local $buffersize=0x20000,$final=0,$hash=""

	UpdateStatus(Translate("Checking VirtualBox archive integrity"))
	SendReport("IN-Check_virtualbox_download : Crypto Library Startup")
	_Crypt_Startup()
	$iterations = Ceiling(FileGetSize($FileToHash) / $buffersize)
	For $i = 1 To $iterations
		if $i=$iterations Then $final=1
		$hash=_Crypt_HashData(FileRead($filehandle, $buffersize),0x00008003,$final,$hash)
		$percent_md5 = Round(100 * $i / $iterations)
		UpdateStatusNoLog(Translate("Checking VirtualBox archive integrity")&" ("&$percent_md5&"%)" )
	Next
	FileClose($filehandle)
	_Crypt_Shutdown()
	SendReport("IN-Check_virtualbox_download : Crypto Library shutdown. Hash is "&$hash)
	$hexa_hash = StringTrimLeft($hash, 2)

	If StringStripWS($hexa_hash,3)=$control_md5 Then
		UpdateStatus(Translate("VirtualBox archive integrity checked"))
		Sleep(1500)
		UpdateStatus(Translate("Unzipping VirtualBox archive to disk"))
		DirRemove(@ScriptDir&"\tools\VirtualBox\",1)
		RunWait3('"' & @ScriptDir & '\tools\7z.exe" x -y "' & @ScriptDir & "\tools\" & $downloaded_virtualbox_filename,@ScriptDir & "\tools\")
		if IniRead(@ScriptDir&"\tools\VirtualBox\Portable-VirtualBox\linuxlive\settings.ini","General","pack_version","ERROR")<> "ERROR" Then
			FileDelete(@ScriptDir & "\tools\" & $downloaded_virtualbox_filename)
			$virtualbox_size=IniRead($updates_ini,"VirtualBox","realsize",$virtualbox_size)
		EndIf
	Else
		UpdateStatus(Translate("VirtualBox archive is corrupted"))
		Return "ERROR"
	EndIf

	SendReport("End-Check_virtualbox_download")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Uncompress Portable-Virtualbox directly to the key
	Input :
		$usb_letter = Letter of the drive (pre-formated like "E:" )
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func Install_virtualbox_on_key()
	SendReport("Start-Install_virtualbox_on_key")
	Local $downloaded_version,$installed_version

	if FileExists(@ScriptDir&"\tools\VirtualBox\Portable-VirtualBox\linuxlive\settings.ini") Then
		$cached_version=IniRead(@ScriptDir&"\tools\VirtualBox\Portable-VirtualBox\linuxlive\settings.ini","General","pack_version","3.0.0.0")
		$installed_version=IniRead($usb_letter&"\VirtualBox\Portable-VirtualBox\linuxlive\settings.ini","General","pack_version","0")
		SendReport("IN-Install_virtualbox_on_key (downloaded pack="&$cached_version&" - installed pack="&$installed_version&")")

		$compare = CompareVersion($cached_version,$installed_version)
		if $compare=1 Then
			; Cached version is newer, need to update the installed one
			SendReport("IN-Install_virtualbox_on_key (Pack needs to be updated)")
		Else
			SendReport("End-Install_virtualbox_on_key (Pack is up to date)")
			Return "1"
		EndIf
	Else
		SendReport("END-Install_virtualbox_on_key (Warning : settings.ini not found, error while uncompressing ?)")
		Return "1"
	EndIf
	VBox_CloseWarning()
	; Cleaning previous install of VBox
	UpdateStatus("Updating Portable-VirtualBox pack")
	DirRemove2($usb_letter & "\VirtualBox\", 1)

	; Unzipping to the key
	UpdateStatus(Translate("Extracting VirtualBox on key") & " ( 4" & Translate("min") & " )")
	;Run7zip2('"' & @ScriptDir & '\tools\7z.exe" x "' & @ScriptDir & "\tools\" & $downloaded_virtualbox_filename & '" -r -aoa -y -o' & $usb_letter, 140)
	DirRemove($usb_letter & "\VirtualBox",1)
	DirCopy(@ScriptDir & "\tools\VirtualBox",$usb_letter & "\VirtualBox",1)

	if IniRead($usb_letter&"\VirtualBox\Portable-VirtualBox\linuxlive\settings.ini","General","pack_version","3.0.0.0") = $cached_version Then
		SendReport("End-Install_virtualbox_on_key : Pack "&$cached_version&" successfully installed to key")
	Else
		SendReport("End-Install_virtualbox_on_key : ERROR - pack not installed ?")
	EndIf

EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Create Autorun.inf
	Input :
		$usb_letter = Letter of the drive (pre-formated like "E:" )
		$release_number = number of the release in the compatibility list (-1 if not present)
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func Create_autorun()
	If ReadSetting( "Advanced", "skip_autorun") = "yes" Then Return 0

	SendReport("Start-Create_autorun")
	If FileExists($usb_letter & "\autorun.inf") Then FileMove($usb_letter & "\autorun.inf",$usb_letter & "\autorun.bak",1)

	; Using LiLi icon
	FileCopy2(@ScriptDir & "\tools\img\lili.ico", $usb_letter & "\lili.ico")

	$icon = "lili.ico"

	;Writing autorun to a temporary file to try to fix an odd bug (FS#304)
	$temp_ini = @ScriptDir&"\tools"

	IniWrite($temp_ini & "\autorun.inf", "autorun", "icon", $icon)
	IniWrite($temp_ini & "\autorun.inf", "autorun", "open", "")
	IniWrite($temp_ini & "\autorun.inf", "autorun", "label", "LinuxLive Key")

	; If virtualbox is installed
	if FileExists($usb_letter & "\VirtualBox\Virtualize_This_Key.exe") OR FileExists($usb_letter & "VirtualBox\VirtualBox.exe") OR GUICtrlRead($virtualbox) = $GUI_CHECKED Then
		IniWrite($temp_ini & "\autorun.inf", "autorun", "shell\linuxlive", "----> LinuxLive!")
		IniWrite($temp_ini & "\autorun.inf", "autorun", "shell\linuxlive\command", "VirtualBox\Virtualize_This_Key.exe")
		IniWrite($temp_ini &"\autorun.inf", "autorun", "shell\linuxlive2", "----> VirtualBox Interface")
		IniWrite($temp_ini & "\autorun.inf", "autorun", "shell\linuxlive2\command", "VirtualBox\VirtualBox.exe")
	EndIf

	$i=3
	if UBound($files_in_source)>0 Then
		for $file in $files_in_source
			if get_extension($file) = "exe" Then
				if $i=3 Then
					IniWrite($temp_ini  & "\autorun.inf", "autorun", "shell\linuxlive"&$i, "----> CD Menu ("& $file &")")
				Else
					IniWrite($temp_ini  & "\autorun.inf", "autorun", "shell\linuxlive"&$i, "----> CD Menu ("& $file &")")
				EndIf
				IniWrite($temp_ini & "\autorun.inf", "autorun", "shell\linuxlive"&$i&"\command", $usb_letter&"\"&$file)
				$i=$i+1
			EndIf
		Next
	EndIf

	FileMove($temp_ini & "\autorun.inf",$usb_letter& "\autorun.inf")

	SendReport("End-Create_autorun")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Creates The uninstaller
	Input :
		$usb_letter = Letter of the drive (pre-formated like "E:" )
		$release_number = number of the release in the compatibility list (-1 if not present)
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func CreateUninstaller()
	If ReadSetting( "Advanced", "skip_uninstaller") = "yes" Then Return 0
	SendReport("Start-CreateUninstaller")
	Global $files_in_source
	$description = ReleaseGetDescription($release_number)

	if Not IsArray($files_in_source) Then
		SendReport("End-CreateUninstaller : list of files is not an array !")
		return "ERROR"
	EndIf

	AddToSmartClean($usb_letter,$persistence_file)

	AddToSmartClean($usb_letter,"lili.ico")
	AddToSmartClean($usb_letter,"autorun.inf")
	AddToSmartClean($usb_letter,"autorun.inf.orig")
	AddToSmartClean($usb_letter,"ldlinux.sys")
	AddToSmartClean($usb_letter,"syslinux")
	AddToSmartClean($usb_letter,"syslinux.cfg")
	AddToSmartClean($usb_letter,"ldlinux.c32")
	AddToSmartClean($usb_letter,"mboot.c32")
	AddToSmartClean($usb_letter,"syslinux.cfg.lili-bak")

	if ReleaseGetVariant($release_number)="pmagic" Then
		AddToSmartClean($usb_letter,"pmagic")
		AddToSmartClean($usb_letter,"boot")
	EndIf
	_ArrayAdd($files_in_source,$autoclean_settings)
	_ArrayAdd($files_in_source,$autoclean_file)

	$handle=FileOpen($usb_letter&"\"&$autoclean_file,2)

	$intro="@echo off" _
	&@CRLF&"rem This batch file was created by Thibaut Lauziere for LinuxLive USB Creator" _
	&@CRLF&"rem More infos available at www.linuxliveusb.com" _
	&@CRLF&"cls" _
	&@CRLF&"echo -----------------------------------------------------------------" _
	&@CRLF&"echo ----------- Welcome to LinuxLive Uninstaller --------------------" _
	&@CRLF&"echo -----------------------------------------------------------------" _
	&@CRLF&"echo." _
	&@CRLF&"echo." _
	&@CRLF&"echo." _
	&@CRLF&"echo --------------------- WARNING! ---------------------------------" _
	&@CRLF&"echo." _
	&@CRLF&"echo This batch file will permanently remove LinuxLive from your key" _
	&@CRLF&"echo." _
	&@CRLF&"echo -----------------------------------------------------------------" _
	&@CRLF&"echo." _
	&@CRLF&"echo." _
	&@CRLF&'set /P userchoice="Are you sure you want to remove Linux Live from your key (Y/N) ?"' _
	&@CRLF&'if /i NOT "%userchoice%"=="y" goto:eof' _
	&@CRLF&"cls" _
	&@CRLF&"echo -----------------------------------------------------------------" _
	&@CRLF&"echo -----------        Removal of LinuxLive      --------------------" _
	&@CRLF&"echo -----------------------------------------------------------------" _
	&@CRLF&"echo."&@CRLF
	FileWrite($handle,$intro)

	Local $total=0
	For $file In $files_in_source
		$current_file=$usb_letter & "\" & $file
		$size_to_add=0
		If isDir($current_file) Then
			$size_to_add=DirGetSize($current_file)
			IniWrite($usb_letter&"\"&$autoclean_settings,"Folders",$file,$size_to_add)
			FileWriteLine($handle,"echo Removing folder : "&$file )
			FileWriteLine($handle,"RMDIR /S /Q "&$file)
		Elseif FileExists($current_file) Then
			$size_to_add=FileGetSize($current_file)
			IniWrite($usb_letter&"\"&$autoclean_settings,"Files",$file,$size_to_add)

			; The Auto-Clean batch needs to be removed at the end
			if $file <> $autoclean_file Then
				FileWriteLine($handle,"echo Removing file : "&$file )
				FileWriteLine($handle,"ATTRIB -H -S "&$file)
				FileWriteLine($handle,"DEL /F /Q "&$file)
			EndIf
		EndIf
		$total+=$size_to_add
	Next

	$outro="cls" _
	&@CRLF&"echo -----------------------------------------------------------------" _
	&@CRLF&"echo." _
	&@CRLF&"echo." _
	&@CRLF&"echo." _
	&@CRLF&"echo." _
	&@CRLF&"echo." _
	&@CRLF&"echo." _
	&@CRLF&"echo --------- LinuxLive USB has been removed from your key  ----------" _
	&@CRLF&"echo." _
	&@CRLF&"echo." _
	&@CRLF&"echo." _
	&@CRLF&"echo." _
	&@CRLF&"echo." _
	&@CRLF&"echo." _
	&@CRLF&"echo -----------------------------------------------------------------" _
	&@CRLF&"pause" _
	&@CRLF&"Removing uninstaller : "&$autoclean_file _
	&@CRLF&"ATTRIB -H -S "&$autoclean_file _
	&@CRLF&"DEL /F /Q "&$autoclean_file _
	&@CRLF&":End"

	FileWrite($handle,$outro)
	FileCLose($handle)

	IniWrite($usb_letter&"\"&$autoclean_settings,"General","Total_Size",$total)
	IniWrite($usb_letter&"\"&$autoclean_settings,"General","Installed_Linux",$release_description)
	IniWrite($usb_letter&"\"&$autoclean_settings,"General","Installed_Linux_Codename",$release_codename)
	SendReport("End-CreateUninstaller")
EndFunc   ;==>DeleteFilesInDir

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Set the Virtual Machine with the right amount of RAM (=minimum requirement)  for a specific version of Linux
	Input :
		$usb_letter = Letter of the drive (pre-formated like "E:" )
		$release_number = number of the release in the compatibility list (-1 if not present)
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func Setup_VBOX_for_VM()
	If ReadSetting( "Advanced", "skip_vbox_setup") = "yes" Then Return 0
	SendReport("Start-Setup_VBOX_for_VM")
	VBox_CloseWarning()

	; Replacing RAM value with recommended setting =======================================
	VBox_SetRam(ReleaseGetVBoxRAM($release_number))


	; Replacing Storage controller with recommended setting =======================================
	VBox_SetStorageController(ReleaseGetVBoxStorageController($release_number))

	; Setting OS Type (mandatory for x64 OSes)
	VBox_SetOSType($release_arch)
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Post-install check, will alert user if some requirements are not met
	Input :
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func Final_check()
	SendReport("Start-Final_check")
	Local $avert_mem = ""
	$mem = MemGetStats()

	; If not enough RAM => WARNING
	If Round($mem[2] / 1024) < $recommended_ram Then $avert_mem = Translate("Free memory is below the recommended value for your Linux to run in Windows") & "( "&$recommended_ram & Translate("MB")&" )" & @CRLF & Translate("This is not enough to launch LinuxLive in Windows")&"."

	If $avert_mem <> "" Then MsgBox(64, Translate("Please read"), $avert_mem)
	SendReport("End-Final_check : "&@CRLF&$avert_mem)
EndFunc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Open a GUI with the final help
	Input :
		$usb_letter = Letter of the drive (pre-formated like "E:" )
		$linux_version = Pre-formated version of linux (like ubuntu_8.10)
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func Finish_Help()
	SendReport("Start-Finish_Help")
	Opt("GUIOnEventMode", 1)
	SendReport("End-Finish_Help")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
