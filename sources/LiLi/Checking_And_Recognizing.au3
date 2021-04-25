; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Checking ISO/File MD5 Hashes + recognizing source ///////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Global $MD5_ISO, $compatible_md5, $compatible_filename, $temp_index = -1

Func Check_source_integrity($linux_live_file)
	SendReport("Start-Check_source_integrity (LinuxFile : " & $linux_live_file & " )")

	; Used to avoid redrawing the old elements of Step 2 (ISO, CD and download)
	if $step2_display_menu=0 Then GUI_Hide_Step2_Default_Menu()
	if $step2_display_menu=1 Then GUI_Hide_Step2_Download_Menu()


	$step2_display_menu = 2
	GUI_Show_Back_Button()

	GUICtrlSetState($label_step2_status,$GUI_HIDE)
	$cleaner = GUICtrlCreateLabel("", 38 + $offsetx0, 238 + $offsety0, 300, 90)
	GUICtrlSetState($cleaner, $GUI_SHOW)
	GUICtrlDelete($cleaner)

	$shortname = CleanFilename(path_to_name($linux_live_file))

	; Pre-Checking
	If get_extension($linux_live_file) = "img" AND ReadSetting("Advanced","force_iso_mode")="no" Then

		Disable_Persistent_Mode()
		Disable_VirtualBox_Option()
		Disable_Hide_Option()

		Step2_Check("good")
		$file_set_mode = "img"

		If $usb_space_total > Round(FileGetSize($linux_live_file)/(1024*1024)) Then
			Step1_Check("good")
		Else
			Step1_Check("bad")
		EndIf

		GUI_Show_Check_status(Translate("Support for .IMG files is experimental") & @CRLF & Translate("Only Live mode is currently available in step 3, virtualization option has been disabled"))
		SendReport("IN-Check_Source (img selected :" & $linux_live_file & ")")

	Else

		Disable_Persistent_Mode()
		Enable_VirtualBox_Option()
		Enable_Hide_Option()

		SendReport("IN-Check_Source (iso selected :" & $linux_live_file & ")")
		$file_set_mode = "iso"
	EndIf

	; If user already select to force some install parameters
	If ReadSetting("Install_Parameters","automatic_recognition")<>"yes" Then
		$forced_description=ReadSetting("Install_Parameters","use_same_parameter_as")
		$temp_index = FindReleaseFromDescription($forced_description)
		$release_recognition_method="Forced as '"&$forced_description&"'"
		if $temp_index <> -1 Then
			Step2_Check("good")
			Sleep(100)
			ReleaseInitializeVariables($temp_index)
			GUI_Show_Check_status(Translate("Verifying") & " OK"&@CRLF& Translate("This version is compatible and its integrity was checked")&@CRLF&Translate("Recognized Linux")&" : "&@CRLF& @CRLF & @TAB &$release_description)
			Check_If_Default_Should_Be_Used()
		EndIf
		SendReport("IN-Check_source_integrity (forced install parameters to : "&$forced_description&" - Release # :"&$temp_index&")")
		Return ""
	Else
		$release_recognition_method="Automatic"
	EndIf

	; No check if it's an img file or if the user do not want to
	If ReadSetting( "Advanced", "skip_recognition") == "yes" OR $file_set_mode="img" Then
		Step2_Check("good")
		$temp_index = FindReleaseFromCodeName("default")
		ReleaseInitializeVariables($temp_index)
		Disable_Persistent_Mode()
		SendReport("IN-Check_source_integrity (skipping recognition, using default mode)")
		$release_recognition_method="None (Skipped)"
		Return ""
	EndIf

	SendReport("IN-Check_source_integrity -> Checking if non grata")
	If isBlackListed($shortname) Then Return ""


	; Some files do not need to be checked by MD5 ( Alpha releases ...). Only trusting filename
	$temp_index = FindReleaseFromFileName($shortname)

	If $temp_index > 0 Then
		SendReport("IN-Check_source_integrity -> Found matching release with filename "&$shortname&" : "&ReleaseGetDescription($temp_index))
		If ReleaseGetMD5($temp_index) = "ANY" Then
			;MsgBox(4096, Translate("Verifying") & " OK", Translate("This version is compatible and its integrity was checked"))
			ReleaseInitializeVariables($temp_index)
			GUI_Show_Check_status(Translate("This version is compatible and its integrity was checked")&@CRLF&Translate("Recognized Linux")&" : "&@CRLF& @CRLF & @TAB &$release_description)
			Check_If_Default_Should_Be_Used()
			SendReport("IN-Check_source_integrity (MD5 set to any, using : " & $release_codename & " )")
			$release_recognition_method="Automatic - Filename matched - MD5 set to any"
			Return ""
		Else
			$temp_index = 0
		EndIf
	EndIf

	If ReadSetting( "Advanced", "skip_md5") <> "yes" Then
		$MD5_ISO = Check_ISO($linux_live_file)
		SendReportNoLog("distrib-" & $shortname&"#"&$MD5_ISO)
		$temp_index = FindReleaseFromMD5($MD5_ISO)
	Else
		$MD5_ISO = "123"
		$temp_index = -1
	EndIf

	SendReport("IN-Check_source_integrity- Intelligent Processing")
	If $temp_index > 0 Then
		; Good version -> COMPATIBLE
		ReleaseInitializeVariables($temp_index)
		GUI_Show_Check_status(Translate("Verifying") & " OK"&@CRLF& Translate("This version is compatible and its integrity was checked")&@CRLF&Translate("Recognized Linux")&" : "&@CRLF& @CRLF & @TAB &$release_description)
		Step2_Check("good")
		SendReport("IN-Check_source_integrity (Compatible version found with MD5 : " & $release_description & " )")
		$release_recognition_method="Automatic - MD5 matched"

	Else
		$temp_index = FindReleaseFromFileName($shortname)
		If $temp_index > 0 Then
			; Filename is known but MD5 not OK -> COMPATIBLE BUT ERROR
			ReleaseInitializeVariables($temp_index)
			GUI_Show_Check_status(Translate("You have the right ISO file but it is corrupted or was altered") &". "&Translate("Please download it again")&"."&@CRLF&Translate("However, LinuxLive USB Creator will try to use same install parameters as for") & @CRLF & @TAB & @TAB& $release_description)
			Step2_Check("warning")
			SendReport("IN-Check_source_integrity (MD5 not found but filename found : " & $release_filename & " )")
			$release_recognition_method="Automatic - Filename matched - MD5 corrupted"
		Else
			; Filename is not known but trying to find what it is with its name => INTELLIGENT PROCESSING
			SendReport("IN-Check_source_integrity (start intelligent processing)")
			if ((StringInStr($shortname, "alternate") OR StringInStr($shortname, "server") OR StringInStr($shortname, "ubuntu-studio") ) AND NOT StringInStr($shortname, "live") AND NOT StringInStr($shortname, "windows") AND NOT StringInStr($shortname, "esx") AND NOT StringInStr($shortname, "rhel") AND NOT StringInStr($shortname, "vmware")  ) Then
					; Any Server versions and alternate
					$temp_index = FindReleaseFromCodeName( "default")
			ElseIf StringInStr($shortname, "archbang") Then
				; ArchBang
				$temp_index = FindReleaseFromCodeName( "archbang-last")
			ElseIf StringInStr($shortname, "archlinux") Then
				; Arch Linux
				$temp_index = FindReleaseFromCodeName( "archlinux-last")
			ElseIf StringInStr($shortname, "xbmc") Then
				; XBMC
				$temp_index = FindReleaseFromCodeName( "xbmc-last")
			ElseIf StringInStr($shortname, "buntu") Then
				if StringInStr($shortname, "15.04") OR StringInStr($shortname, "vivid") OR StringInStr($shortname, "vervet") Then
					$ubuntu_version = "15.04"
				Elseif StringInStr($shortname, "14.10") OR StringInStr($shortname, "utopic") OR StringInStr($shortname, "unicorn") Then
					$ubuntu_version = "14.10"
				Elseif StringInStr($shortname, "14.04") OR StringInStr($shortname, "trusty") OR StringInStr($shortname, "tahr") Then
					$ubuntu_version = "14.04"
				Elseif StringInStr($shortname, "13.10") OR StringInStr($shortname, "saucy") OR StringInStr($shortname, "salam") Then
					$ubuntu_version = "13.10"
				Elseif StringInStr($shortname, "13.04") OR StringInStr($shortname, "rari") OR StringInStr($shortname, "ring") Then
					$ubuntu_version = "13.04"
				Elseif StringInStr($shortname, "12.10") OR StringInStr($shortname, "quant") OR StringInStr($shortname, "quet") Then
					$ubuntu_version = "12.10"
				Elseif StringInStr($shortname, "12.04") OR StringInStr($shortname, "preci") OR StringInStr($shortname, "pang") Then
					$ubuntu_version = "12.04"
				Elseif StringInStr($shortname, "11.10") OR StringInStr($shortname, "onei") OR StringInStr($shortname, "ocel") Then
					$ubuntu_version = "11.10"
				Elseif StringInStr($shortname, "11.04") OR StringInStr($shortname, "natty") OR StringInStr($shortname, "narw") Then
					$ubuntu_version = "11.04"
				Elseif StringInStr($shortname, "10.10") OR StringInStr($shortname, "mave") OR StringInStr($shortname, "meer") Then
					$ubuntu_version = "10.10"
				Elseif StringInStr($shortname, "10.04") OR StringInStr($shortname, "lucid") OR StringInStr($shortname, "lynx") Then
					$ubuntu_version = "10.04"
				Else
					$ubuntu_version = ""
				EndIf

				;if (StringInStr($shortname, "beta") OR StringInStr($shortname, "alpha") OR StringInStr($shortname, "-rc"))Then
					; Betas
				;	$temp_index = FindReleaseFromCodeName( "ubuntubeta-last")
				;Else

				if (StringInStr($shortname, "xubuntu")) Then
					; Xubuntu
					$ubuntu_variant = "xubuntu"
				Elseif (StringInStr($shortname, "mythbuntu")) Then
					; Mythbuntu
					$ubuntu_variant = "mythbuntu"
				Elseif (StringInStr($shortname, "gnome")) Then
					; Ubuntu Gnome
					$ubuntu_variant = "ubuntu-gnome"
				Elseif (StringInStr($shortname, "lubuntu")) Then
					; Lubuntu
					$ubuntu_variant = "lubuntu"
				Elseif StringInStr($shortname, "kubuntu") Then
					; Kubuntu Desktop
					$ubuntu_variant = "kubuntu"
				Elseif StringInStr($shortname, "kylin") Then
					; Kubuntu Desktop
					$ubuntu_variant = "ubuntu-kylin"
				Elseif (StringInStr($shortname, "studio")) Then
					; Ubuntu studio
					$ubuntu_variant = "ubuntustudio"
				Elseif (StringInStr($shortname, "mate")) Then
					; Ubuntu mate
					$ubuntu_variant = "ubuntu-mate"
				Else
					; Falls back to Ubuntu Desktop
					$ubuntu_variant = "ubuntu"
				EndIf

				$temp_index = FindReleaseFromCodeName( $ubuntu_variant&$ubuntu_version&"-last")
				if ReleaseGetCodename($temp_index)="default" Then
					$temp_index = FindReleaseFromCodeName( $ubuntu_variant&"-last")
					if ReleaseGetCodename($temp_index)="default" Then
						$temp_index = FindReleaseFromCodeName("ubuntu-last")
					EndIf
				EndIf
			ElseIf StringInStr($shortname, "grml") Then
				; Grml
				$temp_index = FindReleaseFromCodeName( "grml-last")
			ElseIf StringInStr($shortname, "knoppix") Then
				; Knoppix
				$temp_index = FindReleaseFromCodeName( "knoppix-last")
			ElseIf StringInStr($shortname, "jolicloud") OR StringInStr($shortname, "joli-os") Then
				; Jolicloud (Ubuntu)
				$temp_index = FindReleaseFromCodeName( "jolicloud-last")
			ElseIf StringInStr($shortname, "elementa") Then
				; Elementary OS (Ubuntu)
				$temp_index = FindReleaseFromCodeName( "elementary-last")
			ElseIf StringInStr($shortname, "voyage") Then
				; Elementary OS (Ubuntu)
				$temp_index = FindReleaseFromCodeName( "voyager-last")
			ElseIf StringInStr($shortname, "element") Then
				; Element (Ubuntu)
				$temp_index = FindReleaseFromCodeName( "element-last")
			ElseIf StringInStr($shortname, "Super_OS") Then
				; Super OS (Ubuntu)
				$temp_index = FindReleaseFromCodeName( "superos-last")
			ElseIf StringInStr($shortname, "uberstudent") Then
				; UberStudent (Ubuntu)
				$temp_index = FindReleaseFromCodeName( "uberstudent-last")
			ElseIf StringInStr($shortname, "aptosid") OR StringInStr($shortname, "sidux") Then
				; Aptosid (ex-Sidux)
				if StringInStr($shortname, "xfce") Then
					$temp_index = FindReleaseFromCodeName( "aptosid-xfce-last")
				Else
					$temp_index = FindReleaseFromCodeName( "aptosid-kdelite-last")
				EndIf
			ElseIf StringInStr($shortname, "android-x86") Then
				; Android x86
				$temp_index = FindReleaseFromCodeName( "androidx86-last")
			ElseIf StringInStr($shortname, "guada") Then
				; Guadalinex (Ubuntu)
				$temp_index = FindReleaseFromCodeName( "guadalinex-last")
			ElseIf StringInStr($shortname, "trisquel") Then
				; Trisquel (Ubuntu)
				$temp_index = FindReleaseFromCodeName( "trisquel-last")
			ElseIf StringInStr($shortname, "ultimate-edition") Then
				; Ultimate Edition (Ubuntu)
				$temp_index = FindReleaseFromCodeName( "ultimate-last")
			ElseIf StringInStr($shortname, "ylmf") Then
				; Ylmf (Ubuntu)
				$temp_index = FindReleaseFromCodeName( "ylmf-last")
			ElseIf StringInStr($shortname, "plop") Then
				if StringInStr($shortname, "-X") Then
					; PLoP Linux with X
					$temp_index = FindReleaseFromCodeName( "plopx-last")
				Else
					; PLoP Linux without X
					$temp_index = FindReleaseFromCodeName( "plop-last")
				EndIf
			ElseIf StringInStr($shortname, "fedora") Then
				; Fedora Based
				if StringInStr($shortname, "20") Then
					$temp_index = FindReleaseFromCodeName( "fedora20-last")
				Elseif StringInStr($shortname, "19") Then
					$temp_index = FindReleaseFromCodeName( "fedora19-last")
				Elseif StringInStr($shortname, "18") Then
					$temp_index = FindReleaseFromCodeName( "fedora18-last")
				Elseif StringInStr($shortname, "17") Then
					$temp_index = FindReleaseFromCodeName( "fedora17-last")
				Elseif StringInStr($shortname, "16") Then
					$temp_index = FindReleaseFromCodeName( "fedora16-last")
				Elseif StringInStr($shortname, "15") Then
					$temp_index = FindReleaseFromCodeName( "fedora15-last")
				Elseif StringInStr($shortname, "14") Then
					$temp_index = FindReleaseFromCodeName( "fedora14-last")
				Elseif StringInStr($shortname, "13") Then
					$temp_index = FindReleaseFromCodeName( "fedora13-last")
				Else
					$temp_index = FindReleaseFromCodeName( "fedora-last")
				EndIf
				if ReleaseGetCodename($temp_index)="default" Then
					$temp_index = FindReleaseFromCodeName( "fedora-last")
				EndIf
			ElseIf StringInStr($shortname, "soas") Then
				; Sugar on a stick
				$temp_index = FindReleaseFromCodeName( "fedorasoas-last")
			ElseIf StringInStr($shortname, "peppermint") Then
				; PepperMint
				if StringInStr($shortname, "ice") Then
					$temp_index = FindReleaseFromCodeName( "peppermint-ice-last")
				Else
					$temp_index = FindReleaseFromCodeName( "peppermint-one-last")
				EndIf
			ElseIf StringInStr($shortname, "mint") Then
				; Mint variants
				if StringInStr($shortname, "KDE") Then
					$temp_index = FindReleaseFromCodeName( "mintkdedvd-last")
				elseif StringInStr($shortname, "LXDE") Then
					$temp_index = FindReleaseFromCodeName( "mintlxde-last")
				elseif StringInStr($shortname, "Xfce") Then
					$temp_index = FindReleaseFromCodeName( "mintxfce-last")
				elseif StringInStr($shortname, "debian") Then
					$temp_index = FindReleaseFromCodeName( "mintdebian-last")
				elseif StringInStr($shortname, "flux") Then
					$temp_index = FindReleaseFromCodeName( "mintfluxbox-last")
				else
					$temp_index = FindReleaseFromCodeName( "mint-last")
				EndIf
			ElseIf StringInStr($shortname, "gnewsense") Then
				; gNewSense Based
				$temp_index = FindReleaseFromCodeName( "gnewsense-last")
			ElseIf StringInStr($shortname, "tails") Then
				; Tails
				$temp_index = FindReleaseFromCodeName( "tails-last")
			ElseIf StringInStr($shortname, "clonezilla") Then
				; Clonezilla
				$temp_index = FindReleaseFromCodeName( "clonezilla-last")
			ElseIf StringInStr($shortname, "gparted-live") Then
				; Gparted
				$temp_index = FindReleaseFromCodeName( "gpartedlive-last")
			ElseIf StringInStr($shortname, "hiren") Then
				; Hiren's Boot CD
				$temp_index = FindReleaseFromCodeName( "hiren-last")
			ElseIf StringInStr($shortname, "debian") Then
				; Debian Variants
				if StringInStr($shortname, "live") Then
					if StringInStr($shortname,"6.") OR StringInStr($shortname,"sq") Then
						$debian_version=6
					Else
						; last version
						$debian_version=""
					EndIf

					if StringInStr($shortname, "KDE") Then
						$temp_index = FindReleaseFromCodeName( "debianlivekde"&$debian_version&"-last")
					elseif StringInStr($shortname, "LXDE") Then
						$temp_index = FindReleaseFromCodeName( "debianlivelxde"&$debian_version&"-last")
					elseif StringInStr($shortname, "Xfce") Then
						$temp_index = FindReleaseFromCodeName( "debianlivexfce"&$debian_version&"-last")
					elseif StringInStr($shortname, "gnome") Then
						$temp_index = FindReleaseFromCodeName( "debianlivegnome"&$debian_version&"-last")
					elseif StringInStr($shortname, "standard") Then
						$temp_index = FindReleaseFromCodeName( "debianlivestandard"&$debian_version&"-last")
					else
						$temp_index = FindReleaseFromCodeName( "debianlivegnome"&$debian_version&"-last")
					EndIf
				EndIf
			ElseIf StringInStr($shortname, "toutou") Then
				; Toutou Linux
				$temp_index = FindReleaseFromCodeName( "toutou-last")
			ElseIf StringInStr($shortname, "mandri") OR StringInStr($shortname, "driva") Then
				; OpenMandriva
				$temp_index = FindReleaseFromCodeName( "openmandriva-last")
			ElseIf StringInStr($shortname, "doudou") Then
				; Doudou Linux
				$temp_index = FindReleaseFromCodeName( "doudoulinux-last")
			ElseIf StringInStr($shortname, "qrky") Or StringInStr($shortname, "quirky") Then
				; Quirky Linux
				$temp_index = FindReleaseFromCodeName( "quirky-last")
			ElseIf StringInStr($shortname, "slax") Then
				; Slax
				$temp_index = FindReleaseFromCodeName( "slax-last")
			ElseIf StringInStr($shortname, "centos") Then
				; CentOS
				$temp_index = FindReleaseFromCodeName( "centos-last")
			ElseIf StringInStr($shortname, "pmagic") Then
				; Parted Magic
				$temp_index = FindReleaseFromCodeName( "pmagic-last")
			ElseIf StringInStr($shortname, "pclinuxos") Then
				; PCLinuxOS (default to KDE)
				if StringInStr($shortname, "e17") OR StringInStr($shortname, "enlight") Then
					$temp_index = FindReleaseFromCodeName( "pclinuxose17-last")
				elseif StringInStr($shortname, "LXDE") Then
					$temp_index = FindReleaseFromCodeName( "pclinuxoslxde-last")
				elseif StringInStr($shortname, "Xfce") Then
					$temp_index = FindReleaseFromCodeName( "pclinuxosxfce-last")
				elseif StringInStr($shortname, "gnome") Then
					$temp_index = FindReleaseFromCodeName( "pclinuxosgnome-last")
				else
					$temp_index = FindReleaseFromCodeName( "pclinuxoskde-last")
				EndIf
			ElseIf StringInStr($shortname, "slitaz") Then
				; Slitaz
				$temp_index = FindReleaseFromCodeName( "slitaz-last")
			ElseIf StringInStr($shortname, "vinux") Then
				; Vinux
				$temp_index = FindReleaseFromCodeName( "vinux-last")
			ElseIf StringInStr($shortname, "core") AND StringInStr($shortname, "tiny") Then
				; Tiny Core
				$temp_index = FindReleaseFromCodeName( "tinycore-last")
			ElseIf StringInStr($shortname, "core") AND StringInStr($shortname, "plus") Then
				; CorePlus
				$temp_index = FindReleaseFromCodeName( "coreplus-last")
			ElseIf StringInStr($shortname, "ophcrack") Then
				; OphCrack
				if StringInStr($shortname, "vista") Then
					$temp_index = FindReleaseFromCodeName( "ophcrackxp-last")
				Else
					$temp_index = FindReleaseFromCodeName( "ophcrackvista-last")
				EndIf
			ElseIf StringInStr($shortname, "chakra") Then
				; Chakra
				$temp_index = FindReleaseFromCodeName( "chakra-last")
			ElseIf StringInStr($shortname, "manjaro") Then
				; Manjaro
				if StringInStr($shortname, "xfce") Then
					$temp_index = FindReleaseFromCodeName( "manjaro-xfce-last")
				Else
					$temp_index = FindReleaseFromCodeName( "manjaro-openbox-last")
				EndIf
			ElseIf StringInStr($shortname, "crunch") Then
				; CrunchBang Based
				if StringInStr($shortname, "openbox") Then
					$temp_index = FindReleaseFromCodeName( "crunchbang-openbox-last")
				Else
					$temp_index = FindReleaseFromCodeName( "crunchbang-xfce-last")
				EndIf
			ElseIf StringInStr($shortname, "sabayon") Then
				; Sabayon Linux
				if StringInStr($shortname, "_K") OR StringInStr($shortname, "KDE") Then
					$temp_index = FindReleaseFromCodeName( "sabayonK-last")
				elseif StringInStr($shortname, "_G") OR StringInStr($shortname, "Gnome") Then
					$temp_index = FindReleaseFromCodeName( "sabayonG-last")
				;elseif StringInStr($shortname, "LXDE") Then
				;	$temp_index = FindReleaseFromCodeName( "sabayonL-last")
				elseif StringInStr($shortname, "Xfce") Then
					$temp_index = FindReleaseFromCodeName( "sabayonX-last")
				elseif StringInStr($shortname, "MATE") Then
					$temp_index = FindReleaseFromCodeName( "sabayonM-last")
				else
					$temp_index = FindReleaseFromCodeName( "sabayonK-last")
				EndIf
			ElseIf StringInStr($shortname, "SystemRescue") Then
				; System Rescue CD
				$temp_index = FindReleaseFromCodeName( "systemrescue-last")
			ElseIf StringInStr($shortname, "xange") Then
				; Xange variants
				$temp_index = FindReleaseFromCodeName( "openxange-last")
			ElseIf StringInStr($shortname, "puredyne") Then
				; Puredyne
				$temp_index = FindReleaseFromCodeName( "puredyne-last")
			ElseIf StringInStr($shortname, "64studio") Then
				; 64studio
				$temp_index = FindReleaseFromCodeName( "64studio-last")
			ElseIf StringInStr($shortname, "antix") OR StringInStr($shortname, "MEPIS") Then
				; Antix MEPIS variants
				$temp_index = FindReleaseFromCodeName( "antix-last")
			ElseIf StringInStr($shortname, "ylmf") Then
				; Ylmf OS
				$temp_index = FindReleaseFromCodeName( "ylmf-last")
			ElseIf StringInStr($shortname, "ipfire") Then
				; IPFire
				$temp_index = FindReleaseFromCodeName( "ipfire-last")
			ElseIf StringInStr($shortname, "untangle") Then
				; Untangle
				$temp_index = FindReleaseFromCodeName( "untangle-last")
			ElseIf StringInStr($shortname, "redobackup") Then
				; Redo Backup
				$temp_index = FindReleaseFromCodeName( "redobackup-last")
			ElseIf StringInStr($shortname, "opensuse") Then
				; OpenSUSE
				if StringInStr($shortname, "11.") Then
					$append=""
				Else
					$append="12.1"
				EndIf

				if StringInStr($shortname, "KDE") Then
					$temp_index = FindReleaseFromCodeName( "opensusekde"&$append&"-last")
				Else
					$temp_index = FindReleaseFromCodeName( "opensuse"&$append&"-last")
				EndIf
			ElseIf StringInStr($shortname, "geex") Then
				; GeexBox
				$temp_index = FindReleaseFromCodeName( "geexbox-last")
			ElseIf StringInStr($shortname, "Pinguy") Then
				; PinguyOS
				$temp_index = FindReleaseFromCodeName( "pinguyos-last")
			ElseIf StringInStr($shortname, "avira") Then
				; Avira Antivir
				$temp_index = FindReleaseFromCodeName( "antivir-last")
			ElseIf StringInStr($shortname, "bodhi") Then
				; Bodhi Linux
				$temp_index = FindReleaseFromCodeName( "bodhi-last")
			ElseIf StringInStr($shortname, "tangostudio") Then
				; TangoStudio
				$temp_index = FindReleaseFromCodeName( "tangostudio-last")
			ElseIf StringInStr($shortname, "sms") Then
				; Superb Mini Server
				$temp_index = FindReleaseFromCodeName( "sms-last")
			ElseIf StringInStr($shortname, "zorin") Then
				; Zorin OS
				$temp_index = FindReleaseFromCodeName( "zorin-last")
			ElseIf StringInStr($shortname, "backbox") Then
				; BackBox
				$temp_index = FindReleaseFromCodeName( "backbox-last")
			ElseIf StringInStr($shortname, "finnix") Then
				; Finnix
				$temp_index = FindReleaseFromCodeName( "finnix-last")
			ElseIf StringInStr($shortname, "puppeee") OR StringInStr($shortname, "fluppy") Then
				; Puppeee
				if StringInStr($shortname,"atom") Then
					$temp_index = FindReleaseFromCodeName( "puppeee-atom-last")
				Else
					$temp_index = FindReleaseFromCodeName( "puppeee-celeron-last")
				EndIf
			ElseIf StringInStr($shortname, "vmware") OR StringInStr($shortname, "VMvisor")  OR StringInStr($shortname, "esx") Then
				$clean_name=StringReplace($shortname,".iso","")
				$clean_name=StringReplace($clean_name,".x86_64","")
				; VMware vSphere Hypervisor (ESXi)
				if  StringInStr($clean_name, "6.0") > 0 Then
					$temp_index = FindReleaseFromCodeName( "esxi6.0-last")
				Elseif  StringInStr($clean_name, "5.5") > 0 Then
					$temp_index = FindReleaseFromCodeName( "esxi5.5-last")
				Elseif StringInStr($clean_name, "5.1") > 0 Then
					$temp_index = FindReleaseFromCodeName( "esxi5.1-last")
				Elseif  StringInStr($clean_name, "5.0") > 0 Then
					$temp_index = FindReleaseFromCodeName( "esxi5.0-last")
				Else
					$temp_index = FindReleaseFromCodeName( "esxi4-last")
				EndIf
			ElseIf StringInStr($shortname, "matriux") Then
				; Matriux
				$temp_index = FindReleaseFromCodeName( "matriux-last")
			ElseIf StringInStr($shortname, "dban") Then
				; Darik's Boot And Nuke (DBAN)
				$temp_index = FindReleaseFromCodeName( "dban-last")
			ElseIf StringInStr($shortname, "Gnome_3") Then
				; Gnome 3
				$temp_index = FindReleaseFromCodeName( "gnome3-last")
			ElseIf StringInStr($shortname, "pear") Then
				; Pear Linux
				$temp_index = FindReleaseFromCodeName( "pearlinux-last")
			ElseIf StringInStr($shortname, "macpup") Then
				; MacPup
				$temp_index = FindReleaseFromCodeName( "macpup-last")
			ElseIf StringInStr($shortname, "fuduntu") Then
				; Fuduntu
				$temp_index = FindReleaseFromCodeName( "fuduntu-last")
			ElseIf StringInStr($shortname, "netrun") Then
				; Netrunner
				$temp_index = FindReleaseFromCodeName( "netrunner-last")
			ElseIf StringInStr($shortname, "cdlinux") Then
				; CDLinux
				$temp_index = FindReleaseFromCodeName( "cdlinux-last")
			ElseIf StringInStr($shortname, "rhel") OR (StringInStr($shortname, "red") AND StringInStr($shortname, "hat")) Then
				; Red Hat Enterprise Linux
				$temp_index = FindReleaseFromCodeName( "rhel-last")
			ElseIf StringInStr($shortname, "xen") Then
				; XenServer
				$temp_index = FindReleaseFromCodeName( "xenserver-last")
			Elseif StringInStr($shortname, "deepin") Then
				; Deepin Linux
				$temp_index = FindReleaseFromCodeName( "deepin-last")
			ElseIf StringInStr($shortname, "gentoo") OR StringInStr($shortname, "livedvd-") Then
				; Gentoo
				$temp_index = FindReleaseFromCodeName( "gentoo-last")
			Elseif StringInStr($shortname, "calculate") OR StringInStr($shortname, "cds-") OR StringInStr($shortname, "cld-") or StringInStr($shortname, "cldg-") OR StringInStr($shortname, "cldx-") OR StringInStr($shortname, "cmc-") OR StringInStr($shortname, "css-") Then
				; Calculate Linux
				$temp_index = FindReleaseFromCodeName( "calculate-last")
			Elseif StringInStr($shortname, "scientific") OR StringInStr($shortname, "SL-") Then
				; Scientific Linux
				$temp_index = FindReleaseFromCodeName( "scientific-last")
			ElseIf StringInStr($shortname, "lps") Then
				; Lightweight Portable Security
				$temp_index = FindReleaseFromCodeName( "lps-last")
			ElseIf StringInStr($shortname, "backtrack") OR StringInStr($shortname, "bt") Then
				; BackTrack
				if StringInStr($shortname, "5") AND NOT StringInStr($shortname, "bt4") Then
					$temp_index = FindReleaseFromCodeName( "backtrack-last")
				Else
					$temp_index = FindReleaseFromCodeName( "backtrack4-last")
				EndIf
			ElseIf StringInStr($shortname, "kali") Then
				; Kali
				$temp_index = FindReleaseFromCodeName( "kali-last")
			ElseIf StringInStr($shortname, "lxle") Then
				; LXLE
				$temp_index = FindReleaseFromCodeName( "lxle-last")
			ElseIf StringInStr($shortname, "react") Then
				; ReactOS
				$temp_index = FindReleaseFromCodeName("reactos-last")
			ElseIf StringInStr($shortname, "porteus") Then
				; Porteus
				$temp_index = FindReleaseFromCodeName("porteus-last")
			ElseIf StringInStr($shortname, "linuxlite") Then
				; LinuxLite
				$temp_index = FindReleaseFromCodeName("linuxlite-last")
			ElseIf StringInStr($shortname, "nitrux") Then
				; LinuxLite
				$temp_index = FindReleaseFromCodeName("nitrux-last")
			ElseIf StringInStr($shortname, "watt") Then
				; Watt OS
				$temp_index = FindReleaseFromCodeName( "wattos-last")
			ElseIf StringInStr($shortname, "puppy") Or StringInStr($shortname, "pup-") Or StringInStr($shortname, "wary") OR  StringInStr($shortname, "lupu-") OR  StringInStr($shortname, "precise-") Then
				; Puppy Linux
				if StringInStr($shortname, "precise-") Then
					; Puppy Ubuntu variants
					$temp_index = FindReleaseFromCodeName( "puppyU-last")
				Else
					$temp_index = FindReleaseFromCodeName( "puppy-last")
				EndIf
			ElseIf StringInStr($shortname, "win") OR StringInStr($shortname, "microsoft") OR StringInStr($shortname, "seven") OR StringInStr($shortname, "vista") OR StringInStr($shortname, "eight") Then
				if StringInStr($shortname, "2012") and StringInStr($shortname, "R2") Then
					$temp_index = FindReleaseFromCodeName( "windows2012r2")
				Elseif StringInStr($shortname, "2012") Then
					$temp_index = FindReleaseFromCodeName( "windows2012")
				Elseif StringInStr($shortname, "2008") and StringInStr($shortname, "R2") Then
					$temp_index = FindReleaseFromCodeName( "windows2008r2")
				Elseif StringInStr($shortname, "2008") Then
					$temp_index = FindReleaseFromCodeName( "windows2008")
				Elseif StringInStr($shortname, "vis") Then
					$temp_index = FindReleaseFromCodeName( "windowsvista")
				Elseif  StringInStr($shortname, "windows7") OR StringInStr($shortname, "seven") OR StringInStr($shortname, "win7") Then
					$temp_index = FindReleaseFromCodeName( "windows7")
				Elseif  StringInStr($shortname, "windows8") OR StringInStr($shortname, "eight") OR StringInStr($shortname, "win8") Then
					$temp_index = FindReleaseFromCodeName( "windows8")
				Elseif  StringInStr($shortname, "windows10") OR StringInStr($shortname, "preview") OR StringInStr($shortname, "win10") Then
					$temp_index = FindReleaseFromCodeName( "windows10")
				Else
					$temp_index = FindReleaseFromCodeName( "windows8.1")
				EndIf
			Else
				; Any Linux, except those known not to work in Live mode
				$temp_index = FindReleaseFromCodeName( "default")
			EndIf
			ReleaseInitializeVariables($temp_index)
			GUI_Show_Check_status(Translate("This Linux is not in the compatibility list")& "." & @CRLF &Translate("However, LinuxLive USB Creator will try to use same install parameters as for") & @CRLF & @CRLF & @TAB & $release_description)
			if ReleaseGetCodename($temp_index)<>"default" Then
				SendReport("IN-Check_source_integrity (MD5 not found but keyword found)")
				$release_recognition_method="Automatic - Intelligent recognition matched - Keyword matched"
			Else
				SendReport("IN-Check_source_integrity (MD5 not found AND keyword not found -> using DEFAULT mode")
				$release_recognition_method="Automatic - Intelligent recognition no match"
			EndIf

			SendReport("IN-Check_source_integrity (end intelligent processing)")
		EndIf
	EndIf
	Check_If_Default_Should_Be_Used()
	SendReport("End-Check_source_integrity")
EndFunc   ;==>Check_source_integrity


Func Check_If_Default_Should_Be_Used()
	SendReport("Start-Check_If_Default_Should_Be_Used (release : " & $release_number & " )")
	#cs $codename= ReleaseGetCodename($release_in_list)
	If StringInStr($variants_using_default_mode,$codename)>0 Then
		Disable_Persistent_Mode()
		SendReport("IN-Check_If_Default_Should_Be_Used ( Disable persistency for " & $codename& " )")
	EndIf
	#ce
	if StringInStr($release_supported_features,"persistence") Then
		if StringInStr($release_supported_features,"builtin") Then
			Disable_Persistent_Mode("Built-in Persistency")
			SendReport("IN-Check_If_Default_Should_Be_Used ( Built-in persistency for " & $release_codename& " )")
		Else
			Enable_Persistent_Mode()
			Refresh_Persistence()
			SendReport("IN-Check_If_Default_Should_Be_Used ( Enable persistency for " & $release_codename& " )")
		EndIf
		Step2_Check("good")
	ElseIf StringInStr($release_supported_features,"install-only") Then
		Disable_Persistent_Mode("Install only (no Live)")
		Step2_Check("good")
		SendReport("IN-Check_If_Default_Should_Be_Used ( Install only (no Live) for " & $release_codename& " )")
	Else
		Disable_Persistent_Mode()
		Step2_Check("good")
		SendReport("IN-Check_If_Default_Should_Be_Used ( Disable persistency for " & $release_codename& " )")
	EndIf
	SendReport("End-Check_If_Default_Should_Be_Used")
EndFunc   ;==>Check_If_Default_Should_Be_Used

; Check the ISO against black list
Func isBlackListed($version_name)
	SendReport("Start-isBlackListed (Version : " & $version_name & " )")

	Local $non_grata = 0

	$blacklist = IniRead($blacklist_ini, "Black_List", "black_keywords", "")
	$blacklist_array = StringSplit($blacklist, ',')

	For $i = 1 To $blacklist_array[0]
		If StringInStr($version_name, $blacklist_array[$i]) Then
			$non_grata = 1
			ExitLoop
		EndIf
	Next

	If $non_grata = 1 Then
		GUI_Show_Check_status(Translate("This ISO is not compatible") &"."& @CRLF & Translate("Please read the compatibility list in user guide"))
		Step2_Check("warning")
		SendReport("End-isBlackListed : YES")
		Return 1
	EndIf
	SendReport("End-isBlackListed : NO")
EndFunc   ;==>isBlackListed

Func Check_ISO($FileToHash)
	SendReport("Start-Check_ISO ( File : " & $FileToHash & " )")

	; Used to avoid redrawing the old elements of Step 2 (ISO, CD and download)
	if $step2_display_menu=0 Then GUI_Hide_Step2_Default_Menu()
	if $step2_display_menu=1 Then GUI_Hide_Step2_Download_Menu()

	; Check if present in cache
	$hexa_hash=Check_cache($FileToHash)
	if $hexa_hash <> ""  Then
		GUI_Show_Back_Button()
		Return $hexa_hash
	EndIf

	Local $filehandle = FileOpen($FileToHash, 16)
	Local $buffersize=0x20000,$final=0,$hash=""

	If $FileToHash = "" Then
		SendReport("End-Check_ISO (no iso)")
		Return "no iso"
	EndIf


	$progress_bar = _ProgressCreate(38 + $offsetx0, 238 + $offsety0, 300, 30)
	_ProgressDelete($progress_bar)
	Sleep(200)
	$progress_bar = _ProgressCreate(38 + $offsetx0, 238 + $offsety0, 300, 30)
	_ProgressSetImages($progress_bar, "progress_green.jpg", "progress_background.jpg")
	_ProgressSetImages($progress_bar, "progress_green.jpg", "progress_background.jpg")
	_ProgressSetFont($progress_bar, "", -1, -1, 0x000000, 0)

	; _ITaskBar_SetProgressState($GUI, 2)

	$label_step2_status = GUICtrlCreateLabel(Translate("Checking file")&" : "&path_to_name($FileToHash), 38 + $offsetx0, 231 + $offsety0 + 50, 300, 80)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, 0xFFFFFF)

	; Crypto library Startup has been moved to initialization of LiLi
	$iterations = Ceiling(FileGetSize($FileToHash) / $buffersize)

	For $i = 1 To $iterations
		if $i=$iterations Then $final=1
		$hash=_Crypt_HashData(FileRead($filehandle, $buffersize),0x00008003,$final,$hash)
		$percent_md5 = Round(100 * $i / $iterations)
		$return1 = _ProgressSet($progress_bar,$percent_md5 )
		$return2 = _ProgressSetText($progress_bar, $percent_md5&"%" )
		;_ITaskBar_SetProgressValue($GUI, $percent_md5)
	Next
	FileClose($filehandle)

	SendReport("IN-Check_ISO : Closed Crypto Library, hash computed")
	_ProgressSet($progress_bar,100 )
	_ProgressSetText($progress_bar, "100%" )
	;_ITaskBar_SetProgressState($GUI)
	Sleep(200)
	_ProgressDelete($progress_bar)
	if @error Then
		SendReport("Could not delete progress bar, trying again")
		_ProgressDelete($progress_bar)
		if @error Then
			SendReport("ERROR Could not delete progress bar (even after retrying!!!)")
		EndIf
	EndIf
	GUI_Show_Back_Button()
	$hexa_hash = StringTrimLeft($hash, 2)
	WriteSetting("Cached_MD5",CleanPathForCache($FileToHash),$hexa_hash&"||"&FileGetSize($FileToHash)&"||"&FileGetTime($FileToHash,0,1)&"||"&FileGetTime($FileToHash,1,1))
	SendReport("End-Check_ISO ( Hash : " & $hexa_hash & " )")
	Return $hexa_hash
EndFunc

Func Check_cache($FileToHash)
	SendReport("Start-Check_Cache for file "&$FileToHash)
	$cached_md5=ReadSetting("Cached_MD5",CleanPathForCache($FileToHash))

	if $cached_md5 = "" Then
		SendReport("End-Check_Cache : no cache for this file")
		Return ""
	Else
		$cached_settings=StringSplit($cached_md5,"||",1)

		if IsArray($cached_settings) AND Ubound($cached_settings)=5 Then
			$file_settings=FileGetSize($FileToHash)&"||"&FileGetTime($FileToHash,0,1)&"||"&FileGetTime($FileToHash,1,1)
			$cache_settings_nomd5=$cached_settings[2]&"||"&$cached_settings[3]&"||"&$cached_settings[4]

			if $file_settings=$cache_settings_nomd5 Then
				SendReport("End-Check_Cache : Hash found ="&$cached_settings[1])
				Return $cached_settings[1]
			Else
				SendReport("End-Check_Cache : file modified "&$file_settings&" <> "&$cache_settings_nomd5)
				Return ""
			EndIf

		Else
			SendReport("End-Check_Cache -> Warning cache error (wrong number of parameters)")
			Return ""
		EndIf
	EndIf
EndFunc

Func CleanPathForCache($filepath)
	; Cleaning leading+ trailing spaces and equal signs
	Return StringStripWS(StringReplace($filepath,"=","--"),3)
EndFunc

; Return architecture from filename
Func AutoDetectArchitecture($filepath)
	Global $release_detectedarch
	$release_detectedarch = GetArchitectureFromFilename($filepath)
	Switch $release_detectedarch
		Case "32-bit"
			Return "32-bit"
		Case "64-bit"
			Return "64-bit"
		Case "Both"
			; Dual arch default to 32 bit
			Return "32-bit"
		Case Else
			; Other default to 32 bit
			Return "32-bit"
	EndSwitch
EndFunc

Func GetArchitectureFromFilename($full_filename)
	$filename = path_to_name($full_filename)
	Local $keyword_64[] = ["86_64","64 bit","64_bit","64b","amd64","x64","-64","esxi"]
	Local $keyword_32[] = ["386","486","586","686","x32","-32","32_bit"]
	Local $keyword_dual[] = ["x86-amd64-32ul","dual"]

	if AnyStringInStr($keyword_dual,$filename) Then
		Return "Both"
	Else
		$cleaned=StringReplace($filename,"_","")
		$cleaned=StringReplace($cleaned,"-","")
		$cleaned=StringReplace($cleaned," ","")
		if StringInStr($cleaned,"x8664") Then
			Return "64-bit"
		Elseif StringInStr($cleaned,"x86") Then
			Return "32-bit"
		Else
			; Last Chance
			$found_64 = AnyStringInStr($keyword_64,$filename)
			$found_32 = AnyStringInStr($keyword_32,$filename)
			if $found_64 AND NOT $found_32 Then
				Return "64-bit"
			Elseif NOT $found_64 AND $found_32 Then
				Return "32-bit"
			Else
				Return "Unknown"
			Endif
		EndIf

	EndIf
EndFunc

; return 1 if found , -1 not found
Func AnyStringInStr($keyword_array,$string)
	for $keyword in $keyword_array
		If StringInStr($string,$keyword) Then
			;ConsoleWrite(@CRLF&"Found '"&$keyword&"' in string")
			Return true
		EndIf
	Next
	;ConsoleWrite(@CRLF&"No keyword found")
	Return false
EndFunc
#cs
	Func Check_folder_integrity($folder)
	SendReport("Start-Check_folder_integrity ( Folder : " & $folder & " )")
	Global $version_in_file, $MD5_FOLDER
	If ReadSetting( "Advanced", "skip_checking") = "yes" Then
	Step2_Check("good")
	SendReport("End-Check_folder_integrity (skip)")
	Return ""
	EndIf

	$info_file = FileOpen($folder & "\.disk\info", 0)
	If $info_file <> -1 Then
	$version_in_file = FileReadLine($info_file)
	FileClose($info_file)
	If isBlackListed($version_in_file) Then
	SendReport("End-Check_folder_integrity (version non grata)")
	Return ""
	EndIf
	EndIf

	Global $progression_foldermd5
	$file = FileOpen($folder & "\md5sum.txt", 0)
	If $file = -1 Then
	MsgBox(0, Translate("Error"), Translate("Unable to open MD5SUM.txt"))
	FileClose($file)
	Step2_Check("warning")
	SendReport("End-Check_folder_integrity (Cannot open MD5SUM.txt)")
	Return ""
	EndIf
	$progression_foldermd5 = ProgressOn(Translate("Verifying"), Translate("Checking integrity"), "0 %", -1, -1, 16)
	$corrupt = 0
	While 1
	$line = FileReadLine($file)
	If @error = -1 Then ExitLoop
	$array_hash = StringSplit($line, '  .', 1)
	$file_to_hash = $folder & StringReplace($array_hash[2], "/", "\")
	$file_md5 = MD5_FOLDER($file_to_hash)
	If ($file_md5 <> $array_hash[1]) Then
	ProgressOff()
	FileClose($file)
	MsgBox(48, Translate("Error"), Translate("This file is corrupted") & " : " & $file_to_hash)
	Step2_Check("warning")
	$corrupt = 1
	$MD5_FOLDER = "bad file :" & $file_to_hash
	ExitLoop
	EndIf
	WEnd
	ProgressSet(100, "100%", Translate("Check completed"))
	Sleep(500)
	ProgressOff()
	If $corrupt = 0 Then
	MsgBox(4096, Translate("Check completed"), Translate("All files have been successfully checked")&".")
	Step2_Check("good")
	$MD5_FOLDER = "Good"
	EndIf
	FileClose($file)
	SendReport("End-Check_folder_integrity")
	EndFunc   ;==>Check_folder_integrity


	Func MD5_FOLDER($FileToHash)
	SendReport("Start-MD5_FOLDER ( Folder : " & $FileToHash & " )")
	Global $progression_foldermd5
	Global $BufferSize = 0x20000

	If $FileToHash = "" Then
	SendReport("End-MD5_FOLDER (no folder)")
	Return "no iso"
	EndIf

	Global $FileHandle = FileOpen($FileToHash, 16)

	$MD5CTX = _MD5Init()
	$iterations = Ceiling(FileGetSize($FileToHash) / $BufferSize)
	For $i = 1 To $iterations
	_MD5Input($MD5CTX, FileRead($FileHandle, $BufferSize))
	$percent_md5 = Round(100 * $i / $iterations)
	ProgressSet($percent_md5, Translate("Checking file") & " " & path_to_name($FileToHash) & " (" & $percent_md5 & " %)")
	Next
	$hash = _MD5Result($MD5CTX)
	FileClose($FileHandle)
	$folder_hash = StringTrimLeft($hash, 2)
	SendReport("Start-MD5_FOLDER ( Hash : " & $folder_hash & " )")
	Return
	EndFunc   ;==>MD5_FOLDER
#ce
