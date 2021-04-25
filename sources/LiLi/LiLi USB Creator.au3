#cs/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////// About this software                           ///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Author           : Robert Maehl, forked from Thibaut Lauzièreppa
License          : GPL v3.0
Website          : https://github.com/rcmaehl/LinuxLiveUSBCreator, original at http://www.linuxliveusb.com
Compiled with    : AutoIT v3.3.14.5

///////////////////////////////// Descriptions of AU3 files                      ///////////////////////////////////////////////////////////////////////////////

	LiLi USB Creator.au3 : To compile. Contains initialization of GUI, Variables and Includes. Used AdLib loops to manage hovering
	Automatic_Bug_Report.au3 : Second process for error and crash handling based on _Error Handler.au3 of jennico, @MrCreatoR and MadExcept
	Boot_Menus.au3 : Manage the different boot menus for each Linux distributions
	Checking_And_Recognizing.au3 : Check hash and try to match with a supported Linux based on Hash, filename and keywords
	Disks.au3 : Manage disks operations such as free space calculations, fetching physical disk numbers / Partition Signature / MBR Signature
	External_Tools.au3 : Run external tools (7zip, syslinux, bootsect, fat32format, mke2fs.exe) and get results. Also contains generic run functions
	Files.au3 : Files operations (Delete, Hide, Move) + SmartClean feature + AutoDetection of Syslinux version
	Graphics.au3 : Contains some low-level GDI+ graphic functions  + ProgressBars based on Prog@ndy work but integrated in AdLib
	GUI_Actions.au3 : Actions of each buttons
	Languages.au3 : Locales and translation management
	LiLis_heart.au3 : Functions creating the Live USB such as Format, Uncompress, Clean, converting isolinux config to syslinux, renaming and hide files ....
	Logs_And_Status.au3 :  Manage logging/reporting and traffic lights
	Options_Menu.au3 : contain the Options Menu (Menu.kxf is the Koda file for options menu)
	Releases.au3 : functions to parse and cache the compatibility list (list of supported linux) and get each value. Also fills the combo-box.
	ResourcesEx.au3: Functions to set needed images as resources internally instead of external files that clutter a directory
	Settings.au3 : Read and Write settings. Abstraction layer to read/write from registry or from file depending on lili's mode (portable or standard)
	Statistics.au3 : Send anonymous usage statistics to Universal Analytics (can be disabled by users with skip_stats advanced value)
	VirtualBox.au3 : Manage Portable-VirtualBox settings
	Updates.au3 : check for software updates + functions to compare version numbers
	WinHTTP.au3 : Manage POST request for sending crash logs (based on trancexx and ProgAndy work)

///////////////////////////////// Descriptions of uncompiled structure           ///////////////////////////////////////////////////////////////////////////////

	sources : contains all the sources
		-> Bonus: contains sources for MD5, SHA1 and CRC32 easy hashers
		-> LiLi: contains sources for LiLi
	tools :
		-> boot-menus : some pre-created boot menus
		-> img : images for all the GUI
		-> languages : ini files containing translations
		-> settings :
			-> black_list.ini : black listing of distributions not working for sure with lili
			-> common_mirrors.ini : most common mirrors used in compatibility list (to avoid repeating same values 200 times)
			-> compatibility_list.ini : contains the list of compatible ISO (with extended details such as MD5 Hash, Name, Filename, Release date, mirrors ....)
			-> settings.ini : settings of LiLi (duplicated in registry when not in portable mode)
			-> updates.ini : latest update description file automatically downloaded from LiLi's servers
		-> syslinux modules : all modules for each syslinux version (because they need to be replaced with the good one) in each Live USB
		-> VirtualBox (optional) : contains the latest Portable-VirtualBox pack uncompressed
		-> All the other files : external tools and licences

///////////////////////////////// Compilation                                    ///////////////////////////////////////////////////////////////////////////////

	Git Clone rcmaehl/LinuxLiveUSBCreator
	Install the right AutoIT version mentionned in this header
	(Recommended) Install the complete SciTE Editor
	To be able to see Console logging in real time : Browse to "C:\Program Files (x86)\AutoIt3\SciTE\SciTE.exe" / Right-Click -> Properties -> Compatibility -> Run as Admin
	Navigate to sources/lili/
	Open "LiLi USB Creator.au3" and press F5 to give it a go

#ce/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


#NoTrayIcon
#RequireAdmin

; Required for the Automatic Bug Reporting process
#pragma compile(AutoItExecuteAllowed, True)

#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\tools\img\lili.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Comment=Enjoy !
#AutoIt3Wrapper_Res_Description=Easily create a Linux Live USB
#AutoIt3Wrapper_Res_Fileversion=2.9.88.95
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=Y
#AutoIt3Wrapper_Res_LegalCopyright=CopyLeft Thibaut Lauziere a.k.a Slÿm
#AutoIt3Wrapper_Res_SaveSource=y
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#AutoIt3Wrapper_Res_Field=AutoIt Version|%AutoItVer%
#AutoIt3Wrapper_Res_Field=Compile Date|%date% %time%
#AutoIt3Wrapper_Res_Field=Site|https://github.com/rcmaehl/LinuxLiveUSBCreator
#AutoIt3Wrapper_Add_Constants=n
#AutoIt3Wrapper_AU3Check_Parameters=-w 4
#AutoIt3Wrapper_Res_File_Add=..\..\tools\img\logo.jpg, RT_RCDATA, JPG_1, 0
#AutoIt3Wrapper_Res_File_Add=..\..\tools\img\close.png, RT_RCDATA, PNG_1, 0
#AutoIt3Wrapper_Res_File_Add=..\..\tools\img\close_hover.png, RT_RCDATA, PNG_2, 0
#AutoIt3Wrapper_Res_File_Add=..\..\tools\img\min.png, RT_RCDATA, PNG_3, 0
#AutoIt3Wrapper_Res_File_Add=..\..\tools\img\min_hover.png, RT_RCDATA, PNG_4, 0
#AutoIt3Wrapper_Res_File_Add=..\..\tools\img\bad.png, RT_RCDATA, PNG_5, 0
#AutoIt3Wrapper_Res_File_Add=..\..\tools\img\warning.png, RT_RCDATA, PNG_6, 0
#AutoIt3Wrapper_Res_File_Add=..\..\tools\img\good.png, RT_RCDATA, PNG_7, 0
#AutoIt3Wrapper_Res_File_Add=..\..\tools\img\help.png, RT_RCDATA, PNG_8, 0
#AutoIt3Wrapper_Res_File_Add=..\..\tools\img\cd.png, RT_RCDATA, PNG_9, 0
#AutoIt3Wrapper_Res_File_Add=..\..\tools\img\cd_hover.png, RT_RCDATA, PNG_10, 0
#AutoIt3Wrapper_Res_File_Add=..\..\tools\img\iso.png, RT_RCDATA, PNG_11, 0
#AutoIt3Wrapper_Res_File_Add=..\..\tools\img\iso_hover.png, RT_RCDATA, PNG_12, 0
#AutoIt3Wrapper_Res_File_Add=..\..\tools\img\download.png, RT_RCDATA, PNG_13, 0
#AutoIt3Wrapper_Res_File_Add=..\..\tools\img\download_hover.png, RT_RCDATA, PNG_14, 0
#AutoIt3Wrapper_Res_File_Add=..\..\tools\img\launch.png, RT_RCDATA, PNG_15, 0
#AutoIt3Wrapper_Res_File_Add=..\..\tools\img\launch_hover.png, RT_RCDATA, PNG_16, 0
#AutoIt3Wrapper_Res_File_Add=..\..\tools\img\refresh.png, RT_RCDATA, PNG_17, 0
#AutoIt3Wrapper_Res_File_Add=..\..\tools\img\back.png, RT_RCDATA, PNG_18, 0
#AutoIt3Wrapper_Res_File_Add=..\..\tools\img\back_hover.png, RT_RCDATA, PNG_19, 0
#AutoIt3Wrapper_Res_File_Add=..\..\tools\img\gui.png, RT_RCDATA, PNG_20, 0
#AutoIt3Wrapper_Res_File_Add=..\..\tools\img\progress_background.png, RT_RCDATA, progress_background, 0
#AutoIt3Wrapper_Res_File_Add=..\..\tools\img\progress_green.png, RT_RCDATA, progress_green, 0
#AutoIt3Wrapper_Res_File_Add=..\..\tools\img\lili.ico, RT_RCDATA, ICO_1, 0
#AutoIt3Wrapper_Res_Icon_Add=..\..\tools\img\lili.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Software constants and variables              ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; Global constants
Global Const $software_version = "2.9"
Global $DISPLAY_VERSION = ""
Global $lang_folder = @ScriptDir & "\tools\languages\"
Global $lang_ini
Global $verbose_logging
Global Const $settings_ini = @ScriptDir & "\tools\settings\settings.ini"
Global Const $compatibility_ini = @ScriptDir & "\tools\settings\compatibility_list.ini"
Global Const $updates_ini = @ScriptDir & "\tools\settings\updates.ini"
Global Const $blacklist_ini = @ScriptDir & "\tools\settings\black_list.ini"
Global Const $common_mirrors_ini = @ScriptDir&"\tools\settings\common_mirrors.ini"
Global Const $log_dir = @ScriptDir & "\logs\"
Global $logfile = $log_dir & @YEAR & "-" & @MON & "-" & @MDAY & ".log"
Global Const $check_updates_url = "https://www.linuxliveusb.com/updates/"
Global $virtualbox_size = 140 ; default size but will update automatically
Global Const $max_persistent_size = 4090

; Auto-Clean feature (relative to the usb drive path)
Global Const $autoclean_file = "Remove_LiLi.bat"
Global Const $autoclean_settings = "SmartClean.ini"

; Global that will be set up later
Global $lang, $lang_code, $anonymous_id

; Updater Variables
Global $last_stable="", $last_beta="", $what_is_new=""

Global $DEBUG_TIMER

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Gui Buttons and Label                         ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; General GUI
Global $GUI, $CONTROL_GUI, $EXIT_BUTTON, $MIN_BUTTON
Global $combo
Global $previous_hovered_control

; Step 1 Graphics
Global $DRAW_CHECK_STEP1, $DRAW_REFRESH, $HELP_STEP1

; Step 2 Graphics
Global $DRAW_CHECK_STEP2, $DRAW_ISO, $DRAW_CD, $DRAW_DOWNLOAD, $DRAW_BACK, $DRAW_BACK_HOVER, $HELP_STEP2, $label_iso, $label_cd, $label_download, $label_step2_status, $download_label2, $OR_label, $ISO_AREA, $CD_AREA, $DOWNLOAD_AREA, $BACK_AREA
Global $combo_linux, $label_step2_status, $label_step2_status2, $download_manual, $download_auto, $progress_bar

; Step 3 Graphics
Global $DRAW_CHECK_STEP3, $HELP_STEP3, $live_mode_label
Global $slider, $slider_visual, $label_max, $label_min, $slider_visual_Mo, $slider_visual_mode

; Step 4 Graphics
Global $HELP_STEP4
Global $virtualbox, $formater, $hide_files

; Step 5 Graphics
Global $DRAW_LAUNCH, $HELP_STEP5
Global $label_step5_status

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Gui Images                                    ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; General
Global $ZEROGraphic, $EXIT_NORM, $EXIT_OVER, $MIN_NORM, $MIN_OVER, $PNG_GUI, $HELP, $BAD, $GOOD, $WARNING
Global $cleaner, $cleaner2

; Step 1 images
Global $REFRESH_AREA

; Step 2 images
Global $CD_PNG, $CD_HOVER_PNG, $ISO_PNG, $ISO_HOVER_PNG, $DOWNLOAD_PNG, $DOWNLOAD_HOVER_PNG, $BACK_PNG, $BACK_HOVER_PNG

; images for step 3 & 4 are integrated into main GUI

; Step 5 images
Global $LAUNCH_PNG, $LAUNCH_HOVER_PNG

; Font size (8.5 is default value)
Global $font_size = 8.5

; Areas for drawing
Global $EXIT_AREA, $MIN_AREA,$ISO_AREA,$CD_AREA,$DOWNLOAD_AREA,$LAUNCH_AREA,$BACK_AREA,$REFRESH_AREA


; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Other Global Variables                        ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; Offset alignment for different steps
Global $offsetx0, $offsetx3, $offsetx4
Global $offsety0, $offsety3, $offsety4

; $step2_display_menu = 0 when displaying default menu, 1 when displaying download menu, 2 when displaying checking.
Global $step2_display_menu = 0

; Others Global vars
Global $best_mirror, $iso_size, $filename, $temp_filename
Global $MD5_ISO = "", $compatible_md5, $compatible_filename, $release_number = -1, $files_in_source, $prefetched_linux_list, $prefetched_linux_list_full, $current_compatibility_list_version
Global $foo
Global $for_winactivate
Global $current_download, $temp_filename
Global $ping_result = ""

Global $selected_drive, $virtualbox_check, $downloaded_virtualbox_filename,$recommended_ram
Global $persistence_file = ""
Global $initrd_file, $vmlinuz_file
Global $STEP1_OK, $STEP2_OK, $STEP3_OK
Global $MD5_ISO, $version_in_file
Global $variante
Global $already_create_a_key = 0

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Global Variables for selected USB device      ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Global $usb_letter="->"
Global $usb_filesystem=""
Global $usb_space_total=0
Global $usb_space_free=""
Global $usb_space_after_lili_MB=0
Global $usb_isvalid_filesystem=false


; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Global Variables for selected distribution     ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Global $release_number=0
Global $release_codename=""
Global $release_name=""
Global $release_distribution=""
Global $release_distribution_version=""
Global $release_variant=""
Global $release_variant_version=""
Global $release_supported_features=""
Global $release_filename=""
Global $release_file_md5=""
Global $release_release_date=""
Global $release_web=""
Global $release_download_page=""
Global $release_download_size=0
Global $release_install_size=0
Global $release_description=""
Global $release_mirrors=""
Global $release_mirrors_status=0
Global $release_recognition_method=""
Global $release_detectedarch="32-bit"
Global $release_arch="32-bit"

$selected_drive = "->"
$file_set = 0
$file_set_mode = "none"
$annuler = 0
$combo_updated = 0

$STEP1_OK = 0
$STEP2_OK = 0
$STEP3_OK = 0

$MD5_ISO = "none"
$version_in_file = "none"

Opt("GUIOnEventMode", 1)

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Checking folders / Set up Anonymous ID and Language                       ///////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; Checking if Tools folder exists (contains tools and settings)
If DirGetSize(@ScriptDir & "\tools\", 2) <> -1 Then

	If Not FileExists($compatibility_ini) Then
		; If something went bad with auto-updating the compatibility list => trying to put back the old one
		FileMove(@ScriptDir & "\tools\settings\old_compatibility_list.ini", $compatibility_ini)
		If Not FileExists($compatibility_ini) Then
			MsgBox(48, "ERROR", "Compatibility list not found !!!")
			Exit
		EndIf
	EndIf

	If Not FileExists($settings_ini) Then
		MsgBox(48, "ERROR", "Settings file not found !!!")
		Exit
	Else
		; Generate an unique ID for anonymous crash reports and stats
		$anonymous_id = RegRead("HKEY_CURRENT_USER\SOFTWARE\LinuxLive\General", "unique_ID")
		If $anonymous_id = "" Or @error Then
			$anonymous_id = IniRead($settings_ini, "General", "unique_ID", "")
			If $anonymous_id = "" Then
				; Unique ID found in settings.ini
				$anonymous_id = Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) _
						 & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) _
						 & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1))
				IniWrite($settings_ini, "General", "unique_ID", $anonymous_id)
			EndIf
			If IniRead($settings_ini, "Advanced", "lili_portable_mode", "") <> "yes" Then RegWrite("HKEY_CURRENT_USER\SOFTWARE\LinuxLive\General", "unique_ID", "REG_SZ", $anonymous_id)
		Else
			IniWrite($settings_ini, "General", "unique_ID", $anonymous_id)
		EndIf

	EndIf
Else
	MsgBox(48, "ERROR", "Please put the 'tools' directory back")
	Exit
EndIf

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Includes     															  ///////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#include-once

; AutoIT native includes
#include <Date.au3>
#include <File.au3>
#include <INet.au3>
#include <Misc.au3>
#include <Array.au3>
#include <Crypt.au3>
#include <String.au3>
#include <WinAPI.au3>
#include <WinHTTP.au3>
#include <GDIPlus.au3>
#include <Constants.au3>
#include <GUIListBox.au3>
#include <GUITreeView.au3>
#include <WinAPIFiles.au3>
#include <GuiListView.au3>
#include <TabConstants.au3>
#include <GUIImageList.au3>
#include <GUIConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <ComboConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ProgressConstants.au3>


; LiLi's components
#include "Languages.au3"
#include "Updates.au3"
#include "Settings.au3"
#include "Files.au3"
#include "Logs_And_Status.au3"
#include "Statistics.au3"
#include "Automatic_Bug_Report.au3"
#include "Graphics.au3"
#include "External_Tools.au3"
#include "Disks.au3"
#include "Boot_Menus.au3"
#include "Checking_And_Recognizing.au3"
#include "Releases.au3"
#include "ResourcesEx.au3"
#include "LiLis_heart.au3"
#include "GUI_Actions.au3"
#include "Options_Menu.au3"
#include "VirtualBox.au3"
; Too early => crashes on Vista
; #include "ITaskBarList.au3"



$DISPLAY_VERSION = GetDisplayVersion()

;SplashImageOn("LiLi Splash Screen", @ScriptDir & "\tools\img\logo.jpg",344, 107, -1, -1, 1)
$splash_gui = GUICreate("Loading LiLi", 348, 130, -1, -1, $WS_POPUP)
GUISetFont($font_size)
GUISetBkColor(0x000000)
If @Compiled Then
	GUICtrlCreatePic("", 2, 2, 344, 107)
	_Resource_SetToCtrlID(-1, 'JPG_1')
Else
	GUICtrlCreatePic("..\..\tools\img\logo.jpg", 2, 2, 344, 107)
EndIf
$splash_status = GUICtrlCreateLabel("   " & Translate("Starting LinuxLive USB Creator") & " " & $DISPLAY_VERSION, 2, 109, 344, 19)
GUICtrlSetBkColor($splash_status, 0xFFFFFF)
GUISetState(@SW_SHOW)

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Proxy settings                                                            ///////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; Apply proxy settings
$proxy_mode = ReadSetting("Proxy", "proxy_mode")
$proxy_url = ReadSetting("Proxy", "proxy_url")
$proxy_port = ReadSetting("Proxy", "proxy_port")
$proxy_username = ReadSetting("Proxy", "proxy_username")
$proxy_password = ReadSetting("Proxy", "proxy_password")

If $proxy_mode = 2 Then
	If $proxy_url <> "" And $proxy_port <> "" Then
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
Else
	HttpSetProxy($proxy_mode)
EndIf

_SetAsReceiverNoCallback("lili-main")
_SetReceiverFunction("ReceiveFromSecondary")

; Initializing log file for verbose logging
$verbose_logging = ReadSetting("General", "verbose_logging")
If $verbose_logging = "yes" Then InitLog()

SendReport("Starting LiLi USB Creator " & $DISPLAY_VERSION)


If ReadSetting("Updates", "check_for_updates") = "yes" Then

	If GetLastUpdateIni() = 1 Then
		; Checking for updates
		GUICtrlSetData($splash_status, "   " & Translate("Checking for main software updates"))
		CheckForSoftwareUpdate()

		; Checking for new Portable-VirtualBox version
		GUICtrlSetData($splash_status, "   " & Translate("Checking for Portable-VirtualBox updates"))
		CheckForVirtualBoxUpdate()

	EndIf
EndIf

GUICtrlSetData($splash_status, "   " & Translate("Reading compatibility list"))
; initialize list of compatible releases (load the compatibility_list.ini)

Get_Compatibility_List()
$prefetched_linux_list = Print_For_ComboBox()
$prefetched_linux_list_full = Print_For_ComboBox_Full()

If _Crypt_Startup() Then
	SendReport("Crypto Library started up successfully")
Else
	SendReport("[ERROR] : Crypto Library did not start !!! (errorcode : "&@error&")")
EndIf


If _GDIPlus_Startup() Then
	SendReport("GDI+ started up successfully")
Else
	SendReport("[ERROR] : GDI+ did not start !!! (errorcode : "&@error&")")
EndIf

GUICtrlSetData($splash_status, "   " & Translate("Loading interface"))

; Loading PNG Files
If Not @Compiled Or FileExists("theme") Then
	$path = "..\..\tools\img\"
	If FileExists("theme") Then $path = "theme\"
	$EXIT_NORM = _GDIPlus_ImageLoadFromFile($path & "close.PNG")
	$EXIT_OVER = _GDIPlus_ImageLoadFromFile($path & "close_hover.PNG")
	$MIN_NORM = _GDIPlus_ImageLoadFromFile($path & "min.PNG")
	$MIN_OVER = _GDIPlus_ImageLoadFromFile($path & "min_hover.PNG")
	$BAD = _GDIPlus_ImageLoadFromFile($path & "bad.png")
	$WARNING = _GDIPlus_ImageLoadFromFile($path & "warning.png")
	$GOOD = _GDIPlus_ImageLoadFromFile($path & "good.png")
	$HELP = _GDIPlus_ImageLoadFromFile($path & "help.png")
	$CD_PNG = _GDIPlus_ImageLoadFromFile($path & "cd.png")
	$CD_HOVER_PNG = _GDIPlus_ImageLoadFromFile($path & "cd_hover.png")
	$ISO_PNG = _GDIPlus_ImageLoadFromFile($path & "iso.png")
	$ISO_HOVER_PNG = _GDIPlus_ImageLoadFromFile($path & "iso_hover.png")
	$DOWNLOAD_PNG = _GDIPlus_ImageLoadFromFile($path & "download.png")
	$DOWNLOAD_HOVER_PNG = _GDIPlus_ImageLoadFromFile($path & "download_hover.png")
	$LAUNCH_PNG = _GDIPlus_ImageLoadFromFile($path & "launch.png")
	$LAUNCH_HOVER_PNG = _GDIPlus_ImageLoadFromFile($path & "launch_hover.png")
	$REFRESH_PNG = _GDIPlus_ImageLoadFromFile($path & "refresh.png")
	$BACK_PNG = _GDIPlus_ImageLoadFromFile($path & "back.png")
	$BACK_HOVER_PNG = _GDIPlus_ImageLoadFromFile($path & "back_hover.png")
	$PNG_GUI = _GDIPlus_ImageLoadFromFile($path & "GUI.png")
Else
	$EXIT_NORM = _Resource_GetAsImage("PNG_1", $RT_RCDATA)
	$EXIT_OVER = _Resource_GetAsImage("PNG_2", $RT_RCDATA)
	$MIN_NORM = _Resource_GetAsImage("PNG_3", $RT_RCDATA)
	$MIN_OVER = _Resource_GetAsImage("PNG_4", $RT_RCDATA)
	$BAD = _Resource_GetAsImage("PNG_5", $RT_RCDATA)
	$WARNING = _Resource_GetAsImage("PNG_6", $RT_RCDATA)
	$GOOD = _Resource_GetAsImage("PNG_7", $RT_RCDATA)
	$HELP = _Resource_GetAsImage("PNG_8", $RT_RCDATA)
	$CD_PNG = _Resource_GetAsImage("PNG_9", $RT_RCDATA)
	$CD_HOVER_PNG = _Resource_GetAsImage("PNG_10", $RT_RCDATA)
	$ISO_PNG = _Resource_GetAsImage("PNG_11", $RT_RCDATA)
	$ISO_HOVER_PNG = _Resource_GetAsImage("PNG_12", $RT_RCDATA)
	$DOWNLOAD_PNG = _Resource_GetAsImage("PNG_13", $RT_RCDATA)
	$DOWNLOAD_HOVER_PNG = _Resource_GetAsImage("PNG_14", $RT_RCDATA)
	$LAUNCH_PNG = _Resource_GetAsImage("PNG_15", $RT_RCDATA)
	$LAUNCH_HOVER_PNG = _Resource_GetAsImage("PNG_16", $RT_RCDATA)
	$REFRESH_PNG = _Resource_GetAsImage("PNG_17", $RT_RCDATA)
	$BACK_PNG = _Resource_GetAsImage("PNG_18", $RT_RCDATA)
	$BACK_HOVER_PNG = _Resource_GetAsImage("PNG_19", $RT_RCDATA)
	$PNG_GUI = _Resource_GetAsImage("PNG_20", $RT_RCDATA)
EndIf

;create hotkeyset for opening the helppage
HotKeySet("{F1}", "GUI_Help")

SendReport("Creating GUI")

$GUI = GUICreate("LiLi USB Creator", 450, 750, -1, -1, $WS_POPUP, $WS_EX_LAYERED + $WS_EX_ACCEPTFILES)
GUISetFont($font_size)
GUISetOnEvent($GUI_EVENT_CLOSE, "GUI_Events")
GUISetOnEvent($GUI_EVENT_MINIMIZE, "GUI_Minimize")
GUISetOnEvent($GUI_EVENT_RESTORE, "GUI_Restore")
GUISetOnEvent($GUI_EVENT_MAXIMIZE, "GUI_Restore")

GUIRegisterMsg($WM_LBUTTONDOWN, "moveGUI")
GUIRegisterMsg ($WM_DROPFILES, "GUI_Dropped_File")

SetBitmap($GUI, $PNG_GUI, 255)
GUIRegisterMsg($WM_NCHITTEST, "WM_NCHITTEST")

;_ITaskBar_CreateTaskBarObj()

$CONTROL_GUI = GUICreate("LinuxLive USB Creator", 450, 750, 5, 7, $WS_POPUP, BitOR($WS_EX_LAYERED, $WS_EX_MDICHILD), $GUI)
GUISetFont($font_size)

; Offset applied on every items
$offsetx0 = 27
$offsety0 = 42

If $font_size >= 12 Then
	$offsety0 = $offsety0 - 3
EndIf

; Label of Step 1
GUICtrlCreateLabel(Translate("STEP 1 : CHOOSE YOUR KEY"), 28 + $offsetx0, 108 + $offsety0, 400, 30)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, $font_size + 1.5, 400, 0, "Tahoma")

; Clickable parts of images
$EXIT_AREA = GUICtrlCreateLabel("", 335 + $offsetx0, -20 + $offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Exit")
$MIN_AREA = GUICtrlCreateLabel("", 305 + $offsetx0, -20 + $offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Minimize")
$REFRESH_AREA = GUICtrlCreateLabel("", 300 + $offsetx0, 145 + $offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Refresh_Drives")
$ISO_AREA = GUICtrlCreateLabel("", 38 + $offsetx0, 231 + $offsety0, 75, 75)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Choose_ISO_From_GUI")
$CD_AREA = GUICtrlCreateLabel("", 146 + $offsetx0, 231 + $offsety0, 75, 75)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Choose_CD")
$DOWNLOAD_AREA = GUICtrlCreateLabel("", 260 + $offsetx0, 230 + $offsety0, 75, 75)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Download")
$LAUNCH_AREA = GUICtrlCreateLabel("", 35 + $offsetx0, 600 + $offsety0, 22, 43)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Launch_Creation")
$HELP_STEP1_AREA = GUICtrlCreateLabel("", 335 + $offsetx0, 105 + $offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Help_Step1")
$HELP_STEP2_AREA = GUICtrlCreateLabel("", 335 + $offsetx0, 201 + $offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Help_Step2")
$HELP_STEP3_AREA = GUICtrlCreateLabel("", 335 + $offsetx0, 339 + $offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Help_Step3")
$HELP_STEP4_AREA = GUICtrlCreateLabel("", 335 + $offsetx0, 451 + $offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Help_Step4")
;$HELP_STEP5_AREA = GUICtrlCreateLabel("", 335 + $offsetx0, 565 + $offsety0, 20, 20)
;GUICtrlSetCursor(-1, 0)
;GUICtrlSetOnEvent(-1, "GUI_Help_Step5")

GUISetBkColor(0x121314)

_WinAPI_SetLayeredWindowAttributes($CONTROL_GUI, 0x121314)

$ZEROGraphic = _GDIPlus_GraphicsCreateFromHWND($CONTROL_GUI)

; Firt display (initialization) of images
$PNG_DISPLAY = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $PNG_GUI, 0, 0, 450, 750, 0, 0, 450, 750)
$EXIT_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $EXIT_NORM, 0, 0, 20, 20, 335 + $offsetx0, -20 + $offsety0, 20, 20)
$MIN_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $MIN_NORM, 0, 0, 20, 20, 305 + $offsetx0, -20 + $offsety0, 20, 20)
$DRAW_REFRESH = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $REFRESH_PNG, 0, 0, 20, 20, 300 + $offsetx0, 145 + $offsety0, 20, 20)
$DRAW_ISO = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $ISO_PNG, 0, 0, 75, 75, 38 + $offsetx0, 231 + $offsety0, 75, 75)
$DRAW_CD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $CD_PNG, 0, 0, 75, 75, 146 + $offsetx0, 231 + $offsety0, 75, 75)
$DRAW_DOWNLOAD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $DOWNLOAD_PNG, 0, 0, 75, 75, 260 + $offsetx0, 230 + $offsety0, 75, 75)
$DRAW_LAUNCH = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $LAUNCH_PNG, 0, 0, 22, 43, 35 + $offsetx0, 600 + $offsety0, 22, 43)
$HELP_STEP1 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335 + $offsetx0, 105 + $offsety0, 20, 20)
$HELP_STEP2 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335 + $offsetx0, 201 + $offsety0, 20, 20)
$HELP_STEP3 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335 + $offsetx0, 339 + $offsety0, 20, 20)
$HELP_STEP4 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335 + $offsetx0, 451 + $offsety0, 20, 20)
;$HELP_STEP5 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335 + $offsetx0, 565 + $offsety0, 20, 20)

; Put the state for the first 3 steps
Step1_Check("bad")
Step2_Check("bad")
Step3_Check("bad")

SendReport("Creating GUI (buttons)")

; Hovering Buttons
AdlibRegister("Control_Hover", 150)

; Text for step 2
GUICtrlCreateLabel(Translate("STEP 2 : CHOOSE A SOURCE"), 28 + $offsetx0, 204 + $offsety0, 400, 30)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, $font_size + 1.5, 400, 0, "Tahoma")

$label_iso = GUICtrlCreateLabel("ISO / IMG / ZIP", 40 + $offsetx0, 302 + $offsety0, 110, 50)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)


$label_cd = GUICtrlCreateLabel("CD", 175 + $offsetx0, 302 + $offsety0, 40, 50)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

$label_download = GUICtrlCreateLabel(Translate("Download"), 262 + $offsetx0, 302 + $offsety0, 70, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

; Text and controls for step 3
$offsetx3 = 60
$offsety3 = 150

GUICtrlCreateLabel(Translate("STEP 3 : PERSISTENCE"), 28 + $offsetx0, 194 + $offsety3 + $offsety0, 400, 30)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, $font_size + 1.5, 400, 0, "Tahoma")

$label_min = GUICtrlCreateLabel("0 " & Translate("MB"), 30 + $offsetx3 + $offsetx0, 228 + $offsety3 + $offsety0, 30, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$label_max = GUICtrlCreateLabel("?? " & Translate("MB"), 250 + $offsetx3 + $offsetx0, 228 + $offsety3 + $offsety0, 50, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

$slider = GUICtrlCreateSlider(60 + $offsetx3 + $offsetx0, 225 + $offsety3 + $offsety0, 180, 20)
GUICtrlSetLimit($slider, 0, 0)
GUICtrlSetOnEvent(-1, "GUI_Persistence_Slider")
$slider_visual = GUICtrlCreateInput("0", 90 + $offsetx3 + $offsetx0, 255 + $offsety3 + $offsety0, 40, 20)
GUICtrlSetOnEvent(-1, "GUI_Persistence_Input")
$slider_visual_Mo = GUICtrlCreateLabel(Translate("MB"), 135 + $offsetx3 + $offsetx0, 258 + $offsety3 + $offsety0, 20, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$slider_visual_mode = GUICtrlCreateLabel(Translate("(Live mode only)"), 160 + $offsetx3 + $offsetx0, 258 + $offsety3 + $offsety0, 150, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

$live_mode_label = GUICtrlCreateLabel(Translate("Live Mode"), 55 + $offsetx0, 233 + $offsety3 + $offsety0, 280, 50)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetStyle(-1, $SS_CENTER)
GUICtrlSetFont($live_mode_label, 16)

Disable_Persistent_Mode()

; Text and controls for step 4
$offsetx4 = 10
$offsety4 = 195

GUICtrlCreateLabel(Translate("STEP 4 : OPTIONS"), 28 + $offsetx0, 259 + $offsety4 + $offsety0, 400, 30)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, $font_size + 1.5, 400, 0, "Tahoma")

$hide_files = GUICtrlCreateCheckbox("", 30 + $offsetx4 + $offsetx0, 285 + $offsety4 + $offsety0, 13, 13)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
SetLastStateHideFiles()
GUICtrlSetOnEvent(-1, "GUI_Check_HideFiles")

$hide_files_label = GUICtrlCreateLabel(Translate("Hide created files on key"), 50 + $offsetx4 + $offsetx0, 285 + $offsety4 + $offsety0, 300, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

$formater = GUICtrlCreateCheckbox("", 30 + $offsetx4 + $offsetx0, 305 + $offsety4 + $offsety0, 13, 13)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetOnEvent(-1, "GUI_Format_Key")

$formater_label = GUICtrlCreateLabel(Translate("Format the key in FAT32 (this will erase your data !!)"), 50 + $offsetx4 + $offsetx0, 305 + $offsety4 + $offsety0, 320, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

$virtualbox = GUICtrlCreateCheckbox("", 30 + $offsetx4 + $offsetx0, 325 + $offsety4 + $offsety0, 13, 13)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetOnEvent(-1, "GUI_Check_VirtualBox")
; Setting back last state
SetLastStateVirtualization()

$virtualbox_label = GUICtrlCreateLabel(Translate("Enable launching LinuxLive in Windows (requires internet to install)"), 50 + $offsetx4 + $offsetx0, 325 + $offsety4 + $offsety0, 300, 50)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)


; Text and controls for step 5
GUICtrlCreateLabel(Translate("STEP 5 : CREATE"), 28 + $offsetx0, 371 + $offsety4 + $offsety0, 250, 30)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, $font_size + 1.5, 400, 0, "Tahoma")

GUICtrlCreateButton(StringUpper(Translate("Options")), 220 + 28 + $offsetx0, 369 + $offsety4 + $offsety0, 100, 20)
;GUICtrlSetFont(-1, $font_size, 400, 0, "Tahoma")
GUICtrlSetOnEvent(-1, "GUI_Help_Step5")

$label_step5_status = GUICtrlCreateLabel("<- " & Translate("Click the lightning icon to start the installation"), 50 + $offsetx4 + $offsetx0, 410 + $offsety4 + $offsety0, 300, 80)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont($label_step5_status, $font_size + 0.5, 800, 0, "Arial")

; Filling the combo box with drive list
$combo = GUICtrlCreateCombo("-> " & Translate("Choose a USB Key"), 90 + $offsetx0, 145 + $offsety0, 200, -1, 3)
GUICtrlSetOnEvent(-1, "GUI_Choose_Drive")

GUICtrlSetData($splash_status, "   " & Translate("Getting drive list"))
Refresh_DriveList()

; Logging system configuration
GUICtrlSetData($splash_status, "   " & Translate("Logging system configuration"))
InitLog()

SendInitialStats()

GUIRegisterMsg($WM_PAINT, "DrawAll")
WinActivate($for_winactivate)
GUISetState($GUI_SHOW, $CONTROL_GUI)

; Starting to check for updates in the secondary LiLi's process
;GUICtrlSetData($splash_status,"   "&Translate("Checking for updates"))
;SendReport("check_for_updates")

GUIDelete($splash_gui)
Sleep(100)
GUISetState(@SW_SHOW, $GUI)
GUISetState(@SW_SHOW, $CONTROL_GUI)

Sleep(100)
; LiLi has been restarted due to a language change
If ReadSetting("Internal", "restart_language") = "yes" Then
	GUI_Options_Menu()
EndIf

; Netbook warning (interface too big). Warning will only appear once
If @DesktopHeight <= 600 Then
	HotKeySet("{UP}", "GUI_MoveUp")
	HotKeySet("{DOWN}", "GUI_MoveDown")
	HotKeySet("{LEFT}", "GUI_MoveLeft")
	HotKeySet("{RIGHT}", "GUI_MoveRight")
	if ReadSetting("Advanced", "skip_netbook_warning") <> "yes" Then
		$return = MsgBox(64, Translate("Netbook screen detected"), Translate("Your screen vertical resolution is less than 600 pixels") & "." & @CRLF & Translate("Please use the arrow keys (up and down) of your keyboard to move the interface") & ".")
		WriteSetting("Advanced", "skip_netbook_warning", "yes")
	EndIf
EndIf

; Main part
While 1
	; Force retracing the combo box (bugfix)
	If $combo_updated <> 1 Then
		GUICtrlSetData($combo, GUICtrlRead($combo))
		$combo_updated = 1
	EndIf
	Sleep(1000)
	;DrawAll()
WEnd

Func MoveGUI($hW)
	_SendMessage($GUI, $WM_SYSCOMMAND, 0xF012, 0)
	ControlFocus("LinuxLive USB Creator", "", $REFRESH_AREA)
EndFunc   ;==>MoveGUI

Func DrawAll()
	_WinAPI_RedrawWindow($CONTROL_GUI, 0, 0, $RDW_UPDATENOW)

	$EXIT_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $EXIT_NORM, 0, 0, 20, 20, 335 + $offsetx0, -20 + $offsety0, 20, 20)
	$MIN_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $MIN_NORM, 0, 0, 20, 20, 305 + $offsetx0, -20 + $offsety0, 20, 20)
	$DRAW_REFRESH = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $REFRESH_PNG, 0, 0, 20, 20, 300 + $offsetx0, 145 + $offsety0, 20, 20)
	If $step2_display_menu = 0 Then
		$DRAW_CD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $CD_PNG, 0, 0, 75, 75, 146 + $offsetx0, 231 + $offsety0, 75, 75)
		$DRAW_DOWNLOAD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $DOWNLOAD_PNG, 0, 0, 75, 75, 260 + $offsetx0, 230 + $offsety0, 75, 75)
		$DRAW_ISO = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $ISO_PNG, 0, 0, 75, 75, 38 + $offsetx0, 231 + $offsety0, 75, 75)
	Else
		$DRAW_BACK = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BACK_PNG, 0, 0, 32, 32, 5 + $offsetx0, 300 + $offsety0, 32, 32)
	EndIf
	$DRAW_LAUNCH = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $LAUNCH_PNG, 0, 0, 22, 43, 35 + $offsetx0, 600 + $offsety0, 22, 43)

	$HELP_STEP1 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335 + $offsetx0, 105 + $offsety0, 20, 20)
	$HELP_STEP2 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335 + $offsetx0, 201 + $offsety0, 20, 20)
	$HELP_STEP3 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335 + $offsetx0, 339 + $offsety0, 20, 20)
	$HELP_STEP4 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335 + $offsetx0, 451 + $offsety0, 20, 20)
	;$HELP_STEP5 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335 + $offsetx0, 565 + $offsety0, 20, 20)
	Redraw_Traffic_Lights()
	_WinAPI_RedrawWindow($CONTROL_GUI, 0, 0, $RDW_VALIDATE) ; then force no-redraw of GUI
	Return $GUI_RUNDEFMSG
EndFunc   ;==>DrawAll

Func Redraw_Traffic_Lights()
	; Re-checking step (to retrace traffic lights)
	Select
		Case $STEP1_OK = 0
			Step1_Check("bad")
		Case $STEP1_OK = 1
			Step1_Check("good")
		Case $STEP1_OK = 2
			Step1_Check("warning")
	EndSelect
	Select
		Case $STEP2_OK = 0
			Step2_Check("bad")
		Case $STEP2_OK = 1
			Step2_Check("good")
		Case $STEP2_OK = 2
			Step2_Check("warning")
	EndSelect
	Select
		Case $STEP3_OK = 0
			Step3_Check("bad")
		Case $STEP3_OK = 1
			Step3_Check("good")
		Case $STEP3_OK = 2
			Step3_Check("warning")
	EndSelect
EndFunc   ;==>Redraw_Traffic_Lights


Func Control_Hover()
	Local $CursorCtrl
	If WinActive("LinuxLive USB Creator") Or WinActive("LiLi USB Creator") Then
		$CursorCtrl = GUIGetCursorInfo()
		If Not @error And IsArray($CursorCtrl) Then
			Switch $previous_hovered_control
				Case $EXIT_AREA
					$EXIT_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $EXIT_NORM, 0, 0, 20, 20, 335 + $offsetx0, -20 + $offsety0, 20, 20)
				Case $MIN_AREA
					$MIN_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $MIN_NORM, 0, 0, 20, 20, 305 + $offsetx0, -20 + $offsety0, 20, 20)
				Case $ISO_AREA
					If $step2_display_menu = 0 Then $DRAW_ISO = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $ISO_PNG, 0, 0, 75, 75, 38 + $offsetx0, 231 + $offsety0, 75, 75)
				Case $CD_AREA
					If $step2_display_menu = 0 Then $DRAW_CD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $CD_PNG, 0, 0, 75, 75, 146 + $offsetx0, 231 + $offsety0, 75, 75)
				Case $DOWNLOAD_AREA
					If $step2_display_menu = 0 Then $DRAW_DOWNLOAD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $DOWNLOAD_PNG, 0, 0, 75, 75, 260 + $offsetx0, 230 + $offsety0, 75, 75)
				Case $LAUNCH_AREA
					$DRAW_LAUNCH = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $LAUNCH_PNG, 0, 0, 22, 43, 35 + $offsetx0, 600 + $offsety0, 22, 43)
				Case $BACK_AREA
					If $step2_display_menu >= 1 Then $DRAW_BACK = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BACK_PNG, 0, 0, 32, 32, 5 + $offsetx0, 300 + $offsety0, 32, 32)
			EndSwitch

			Switch $CursorCtrl[4]
				Case $EXIT_AREA
					$EXIT_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $EXIT_OVER, 0, 0, 20, 20, 335 + $offsetx0, -20 + $offsety0, 20, 20)
					If $CursorCtrl[2] = 1 Then
						GUI_Exit()
					EndIf
				Case $MIN_AREA
					$MIN_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $MIN_OVER, 0, 0, 20, 20, 305 + $offsetx0, -20 + $offsety0, 20, 20)
					If $CursorCtrl[2] = 1 Then GUI_Minimize()
				Case $ISO_AREA
					If $step2_display_menu = 0 Then $DRAW_ISO = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $ISO_HOVER_PNG, 0, 0, 75, 75, 38 + $offsetx0, 231 + $offsety0, 75, 75)
				Case $CD_AREA
					If $step2_display_menu = 0 Then $DRAW_CD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $CD_HOVER_PNG, 0, 0, 75, 75, 146 + $offsetx0, 231 + $offsety0, 75, 75)
				Case $DOWNLOAD_AREA
					If $step2_display_menu = 0 Then $DRAW_DOWNLOAD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $DOWNLOAD_HOVER_PNG, 0, 0, 75, 75, 260 + $offsetx0, 230 + $offsety0, 75, 75)
				Case $LAUNCH_AREA
					$DRAW_LAUNCH = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $LAUNCH_HOVER_PNG, 0, 0, 22, 43, 35 + $offsetx0, 600 + $offsety0, 22, 43)
				Case $BACK_AREA
					If $step2_display_menu >= 1 Then $DRAW_BACK_HOVER = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BACK_HOVER_PNG, 0, 0, 32, 32, 5 + $offsetx0, 300 + $offsety0, 32, 32)
			EndSwitch
			$previous_hovered_control = $CursorCtrl[4]
		EndIf
	EndIf
	If IsArray($_Progress_Bars) Then
		_Paint_Bars_Procedure2()
	EndIf
	_CALLBACKQUEUE()
EndFunc   ;==>Control_Hover


; Received a message from the secondary lili's process
Func ReceiveFromSecondary($message)
	If StringLeft($message, 5) = "ping-" Then
		$ping_result = $message
	Else
		UpdateLog("Received message from secondary process (" & $message & ")")
	EndIf
EndFunc   ;==>ReceiveFromSecondary