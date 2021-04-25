#include <Array.au3>
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Managing the releases list                    ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; Set the list for compatibility
; Global variables for releases attributes
Global Const $R_CODE = 0,$R_NAME=1,$R_DISTRIBUTION=2, $R_DISTRIBUTION_VERSION=3,$R_FILENAME=4,$R_FILE_MD5=5,$R_RELEASE_DATE=6,$R_WEB=7,$R_DOWNLOAD_PAGE=8,$R_DOWNLOAD_SIZE=9,$R_INSTALL_SIZE=10,$R_DESCRIPTION=11
Global Const $R_MIRROR1=12,$R_MIRROR2=13,$R_MIRROR3=14,$R_MIRROR4=15,$R_MIRROR5=16,$R_MIRROR6=17,$R_MIRROR7=18,$R_MIRROR8=19,$R_MIRROR9=20,$R_MIRROR10=21,$R_VARIANT=22,$R_VARIANT_VERSION=23,$R_VISIBLE=24,$R_FEATURES=25
Global $releases[5][30],$compatible_md5[5],$compatible_filename[5],$codenames_list[5]
Global $current_compatibility_list_version
Global $sections

Func Get_Compatibility_List()
	SendReport("Start-Get_Compatibility_List")
	$current_compatibility_list_version=IniRead($compatibility_ini, "Compatibility_List", "Version","none")
	$sections = IniReadSectionNames($compatibility_ini)
	If (Not IsArray($sections)) Or (Not FileExists($compatibility_ini)) Then
		MsgBox(32,"Error","Compatibility file "&$compatibility_ini&" was not found.")
		SendReport("END-Get_Compatibility_List : ERROR, Compatibility file not found")
		GUI_Exit()
	EndIf

	Global $releases[$sections[0]+1][30],$compatible_md5[$sections[0]+1],$compatible_filename[$sections[0]+1],$codenames_list[$sections[0]+1]
	$timer=TimerInit()

	For $i=1 to $sections[0]
		$releases[$i][$R_CODE]=$sections[$i]
		$codenames_list[$i]=$sections[$i]

		$sec=IniReadSection($compatibility_ini, $sections[$i])
		For $j = 1 To $sec[0][0]
			Switch $sec[$j][0]
				case "Name"
					$releases[$i][$R_NAME]=$sec[$j][1]
				case "Distribution"
					$releases[$i][$R_DISTRIBUTION]=$sec[$j][1]
				case "Distribution_Version"
					$releases[$i][$R_DISTRIBUTION_VERSION]=$sec[$j][1]
				case "Variant"
					$releases[$i][$R_VARIANT]=$sec[$j][1]
				case "Variant_Version"
					$releases[$i][$R_VARIANT_VERSION]=$sec[$j][1]
				case "Supported_Features"
					$releases[$i][$R_FEATURES]=$sec[$j][1]
				case "Filename"
					$releases[$i][$R_FILENAME]=$sec[$j][1]
					$compatible_filename[$i]=$sec[$j][1]
				case "File_MD5"
					$releases[$i][$R_FILE_MD5]=$sec[$j][1]
					$compatible_md5[$i]=$sec[$j][1]
			case "Release_Date"
				$releases[$i][$R_RELEASE_DATE]=$sec[$j][1]
			case "Web"
				$releases[$i][$R_WEB]=$sec[$j][1]
			case "Download_page"
				$releases[$i][$R_DOWNLOAD_PAGE]=$sec[$j][1]
			case "Download_Size"
				$releases[$i][$R_DOWNLOAD_SIZE]=$sec[$j][1]
			case "Install_Size"
				$releases[$i][$R_INSTALL_SIZE]=$sec[$j][1]
			case "Description"
				$releases[$i][$R_DESCRIPTION]=$sec[$j][1]
			case "Mirror1"
				$releases[$i][$R_MIRROR1]=$sec[$j][1]
			case "Mirror2"
				$releases[$i][$R_MIRROR2]=$sec[$j][1]
			case "Mirror3"
				$releases[$i][$R_MIRROR3]=$sec[$j][1]
			case "Mirror4"
				$releases[$i][$R_MIRROR4]=$sec[$j][1]
			case "Mirror5"
				$releases[$i][$R_MIRROR5]=$sec[$j][1]
			case "Mirror6"
				$releases[$i][$R_MIRROR6]=$sec[$j][1]
			case "Mirror7"
				$releases[$i][$R_MIRROR7]=$sec[$j][1]
			case "Mirror8"
				$releases[$i][$R_MIRROR8]=$sec[$j][1]
			case "Mirror9"
				$releases[$i][$R_MIRROR9]=$sec[$j][1]
			case "Mirror10"
				$releases[$i][$R_MIRROR10]=$sec[$j][1]
			case "Visible"
				$releases[$i][$R_VISIBLE]=$sec[$j][1]
			EndSwitch
		Next
	Next
	if IsArray($releases) Then
		SendReport("END-Get_Compatibility_List : Loaded "&$sections[0]&" items in "&Round(TimerDiff($timer)/1000,3)&" seconds")
	Else
		SendReport("END-Get_Compatibility_List : ERROR, could not load releases")
	EndIf
	Return $releases
EndFunc

Func DisplayRelease($release_in_list)
	Global $releases
	if $release_in_list>0 Then
		Msgbox(4096,"Release Details" ,  "Name : " & $releases[$release_in_list][$R_NAME]  & @CRLF  _
		& "Distribution : " & ReleaseGetDistribution($release_in_list) & @CRLF  _
		& "Distribution Version : " & ReleaseGetDistributionVersion($release_in_list) & @CRLF  _
		& "Variant : " & ReleaseGetVariant($release_in_list) & @CRLF  _
		& "Variant Version : " & ReleaseGetVariantVersion($release_in_list) & @CRLF  _
		& "Supported Features : " & ReleaseGetSupportedFeatures($release_in_list) & @CRLF  _
		& "Filename : " & $releases[$release_in_list][$R_FILENAME] & @CRLF  _
		& "MD5 : " & $releases[$release_in_list][$R_FILE_MD5] & @CRLF  _
		& "Release Date : " & $releases[$release_in_list][$R_RELEASE_DATE] & @CRLF  _
		& "WebSite : " & $releases[$release_in_list][$R_WEB] & @CRLF  _
		& "Download Page : " & $releases[$release_in_list][$R_DOWNLOAD_PAGE] & @CRLF _
		& "Download Size : " & $releases[$release_in_list][$R_DOWNLOAD_SIZE] & @CRLF _
		& "Installed Size : " & $releases[$release_in_list][$R_INSTALL_SIZE] & @CRLF  _
		& "Description : " & $releases[$release_in_list][$R_DESCRIPTION] & @CRLF  _
		& "Mirror 1 :"  & $releases[$release_in_list][$R_MIRROR1] & @CRLF  _
		& "Mirror 2 : " & $releases[$release_in_list][$R_MIRROR2] & @CRLF  _
		& "Mirror 3 : " & $releases[$release_in_list][$R_MIRROR3] & @CRLF  _
		& "Mirror 4 : " & $releases[$release_in_list][$R_MIRROR4] & @CRLF  _
		& "Mirror 5 : " & $releases[$release_in_list][$R_MIRROR5] & @CRLF  _
		& "Mirror 6 : " & $releases[$release_in_list][$R_MIRROR6] & @CRLF  _
		& "Mirror 7 : " & $releases[$release_in_list][$R_MIRROR7] & @CRLF  _
		& "Mirror 8 : " & $releases[$release_in_list][$R_MIRROR8] & @CRLF  _
		& "Mirror 9 : " & $releases[$release_in_list][$R_MIRROR9] & @CRLF  _
		& "Mirror 10 : " & $releases[$release_in_list][$R_MIRROR10])
	EndIf
EndFunc

Func Print_For_ComboBox()
	Global $releases,$sections
	Local $temp=""
	For $release_in_list=1 to $sections[0]
		if $releases[$release_in_list][$R_VISIBLE]="yes" Then $temp &=  ReleaseGetDescription($release_in_list)&"|"
			;& "// Size : " & $releases[$release_in_list][$R_DOWNLOAD_SIZE] _
			;& " (" & $releases[$release_in_list][$R_RELEASE_DATE] & ") |"
		Next
	Return $temp
EndFunc

Func Print_For_ComboBox_Full()
	Global $releases,$sections
	Local $temp=""
	For $release_in_list=1 to $sections[0]
		$temp &=  ReleaseGetDescription($release_in_list)&"|"
			;& "// Size : " & $releases[$release_in_list][$R_DOWNLOAD_SIZE] _
			;& " (" & $releases[$release_in_list][$R_RELEASE_DATE] & ") |"
		Next
	Return $temp
EndFunc

Func FindReleaseFromDescription($description)
	Global $releases,$sections
	Local $found=-1
	If StringInStr($description,"Regular Linux") Then Return FindReleaseFromCodeName("default")
	For $i=1 to $sections[0]
		If ReleaseGetDescription($i) = $description Then $found = $i
	Next
	Return $found
EndFunc

Func FindReleaseFromMD5($MD5_to_find)
	Global $releases,$sections
	Local $found=-1
	For $i=1 to $sections[0]
		If StringInStr(ReleaseGetMD5($i),$MD5_to_find,2)>0 Then $found = $i
	Next
	Return $found
EndFunc

Func FindReleaseFromFileName($filename_to_find)
	Global $releases,$sections
	Local $found=-1
	For $i=1 to $sections[0]
		If StringInStr(ReleaseGetFilename($i),$filename_to_find,2)>0  Then $found = $i
	Next
	Return $found
EndFunc

Func FindReleaseFromCodeName($codename_to_find)
	Global $releases,$sections
	Local $found=-1
	SendReport("FindReleaseFromCodeName : Tring to find "&$codename_to_find)
	For $i=1 to $sections[0]
		If $sections[$i] = $codename_to_find Then $found = $i
	Next
	if $found=-1 Then
		SendReport("FindReleaseFromCodeName : Warning, release codename not found, falling back to default")
		return FindReleaseFromCodeName("default")
	EndIf
	Return $found
EndFunc

Func DisplayAllReleases()
	Global $sections
	For $i=1 to $sections[0]
		DisplayRelease($i)
	Next
EndFunc

Func ReleaseGetCodename($release_in_list)
	if $release_in_list <=0 Then Return "default"
	Return StringStripWS($releases[$release_in_list][$R_CODE],3)
EndFunc

Func ReleaseGetName($release_in_list)
	if $release_in_list <=0 Then Return "NotFound"
	Return StringStripWS($releases[$release_in_list][$R_NAME],3)
EndFunc

Func ReleaseGetFilename($release_in_list)
	if $release_in_list <=0 Then Return "NotFound"
	Return StringStripWS($releases[$release_in_list][$R_FILENAME],3)
EndFunc

Func ReleaseGetMD5($release_in_list)
	if $release_in_list <=0 Then Return "NotFound"
	Return StringStripWS($releases[$release_in_list][$R_FILE_MD5],3)
EndFunc

Func ReleaseGetDistribution($release_in_list)
	if $release_in_list <=0 Then Return "NotFound"
	Return StringStripWS($releases[$release_in_list][$R_DISTRIBUTION],3)
EndFunc

Func ReleaseGetDistributionVersion($release_in_list)
	if $release_in_list <=0 Then Return "NotFound"
	Return StringStripWS($releases[$release_in_list][$R_DISTRIBUTION_VERSION],3)
EndFunc

Func ReleaseGetVariant($release_in_list)
	if $release_in_list <=0 Then Return "NotFound"
	Return StringStripWS($releases[$release_in_list][$R_VARIANT],3)
EndFunc

Func ReleaseGetVariantVersion($release_in_list)
	if $release_in_list <=0 Then Return "NotFound"
	Return StringStripWS($releases[$release_in_list][$R_VARIANT_VERSION],3)
EndFunc

Func ReleaseGetWebsite($release_in_list)
	if $release_in_list <=0 Then Return "NotFound"
	Return StringStripWS($releases[$release_in_list][$R_WEB],3)
EndFunc

Func ReleaseGetDownloadPage($release_in_list)
	if $release_in_list <=0 Then Return "NotFound"
	Return StringStripWS($releases[$release_in_list][$R_DOWNLOAD_PAGE],3)
EndFunc

Func ReleaseGetMirror($release_in_list,$mirror_number=0)
	if $release_in_list <=0 Then Return "NotFound"
	if StringInStr($releases[$release_in_list][$R_MIRROR1],"::") Then
		$split=StringSplit($releases[$release_in_list][$R_MIRROR1],"::",3)
		if Ubound($split)==2 Then
			$common_mirror_path = IniRead($common_mirrors_ini,$split[0],"Mirror"&($mirror_number+1),"")
			Return StringStripWS($common_mirror_path&$split[1],3)
		Else
			Return ""
		EndIf
	Else
		Return StringStripWS($releases[$release_in_list][$R_MIRROR1+$mirror_number],3)
	EndIf
EndFunc

Func ReleaseGetMirrors($release_in_list)
	if $release_in_list <=0 Then Return "NotFound"
	$all_mirrors=""
	For $i = 0 To 9
		$all_mirrors &= ReleaseGetMirror($release_in_list,$i)&"##"
	Next
	Return StringSplit(StringTrimRight($all_mirrors,2),"##",1)
EndFunc

Func ReleaseGetMirrorStatus($release_in_list)
	if $release_in_list <=0 Then Return 0
	$available_mirrors=0
	For $m = 0 To 9
		if  ReleaseGetMirror($release_in_list,$m) <> "" Then
			$available_mirrors+=1
		EndIf
	Next
	Return $available_mirrors
EndFunc

Func ReleaseGetReleaseDate($release_in_list)
	if $release_in_list <=0 Then Return "NotFound"
	Return StringStripWS($releases[$release_in_list][$R_RELEASE_DATE],3)
EndFunc

Func ReleaseGetDownloadSize($release_in_list)
	if $release_in_list <=0 Then Return 800
	Return StringStripWS($releases[$release_in_list][$R_DOWNLOAD_SIZE],3)
EndFunc

Func ReleaseGetInstallSize($release_in_list)
	if $release_in_list <=0 Then Return 800
	Return StringStripWS($releases[$release_in_list][$R_INSTALL_SIZE],3)
EndFunc

Func ReleaseGetDescription($release_in_list)
	if $release_in_list <=0 Then Return "NotFound"
	if StringInStr(ReleaseGetCodename($release_in_list),"separator")>0 Then
		; This is a separator description
		Return ">>>>>>>>>> "&Translate(StringStripWS($releases[$release_in_list][$R_DESCRIPTION],3))&" <<<<<<<<<<"
	Else
		; This is Linux description
		Return Translate(StringStripWS($releases[$release_in_list][$R_DESCRIPTION],3))
	Endif
EndFunc

Func ReleaseGetSupportedFeatures($release_in_list)
	if $release_in_list <=0 Then Return "NotFound"
	Return StringStripWS($releases[$release_in_list][$R_FEATURES],3)
EndFunc


Func ReleaseInitializeVariables($release_in_list)
	if $release_in_list <=0 Then Return "NotFound"
	Global $release_arch = AutoDetectArchitecture($file_set)
	if ($release_arch = "64-bit") Then
		$append_to_description=" (64-bit)"
	Else
		$append_to_description=""
	EndIf

	Global $release_number=$release_in_list
	Global $release_codename=ReleaseGetCodename($release_number)
	Global $release_name=ReleaseGetDescription($release_number)
	Global $release_distribution=ReleaseGetDistribution($release_number)
	Global $release_distribution_version=ReleaseGetDistributionVersion($release_number)
	Global $release_variant=ReleaseGetVariant($release_number)
	Global $release_variant_version=ReleaseGetVariant($release_number)
	Global $release_supported_features=ReleaseGetSupportedFeatures($release_number)
	Global $release_filename=ReleaseGetFilename($release_number)
	Global $release_file_md5=ReleaseGetMD5($release_number)
	Global $release_release_date=ReleaseGetReleaseDate($release_number)
	Global $release_web=ReleaseGetWebsite($release_number)
	Global $release_download_page=ReleaseGetDownloadPage($release_number)
	Global $release_download_size=ReleaseGetDownloadSize($release_number)
	Global $release_install_size=ReleaseGetInstallSize($release_number)
	Global $release_description=ReleaseGetDescription($release_number)&$append_to_description
	Global $release_mirrors=ReleaseGetMirrors($release_number)
	Global $release_mirrors_status=ReleaseGetMirrorStatus($release_number)
EndFunc

Func ReleaseHasFeature($feature_to_check)
	if StringInStr($release_supported_features,$feature_to_check,0) <> 0 Then
		Return True
	Else
		Return False
	EndIf
EndFunc

; Get value for a feature such as copy-module:value
; if same option specified multiple times, returns a string with format value1|value2|value3
Func ReleaseGetFeatureValue($feature_to_check)
	$feature_value=""
	$features_array=StringSplit($release_supported_features,",",2)
	FOR $feature IN $features_array
		if StringInStr($feature,$feature_to_check&":")<>0 Then
			$feature_value &= StringReplace($feature,"keep-module:","")&"|"
		EndIf
	Next
	If StringRight($feature_value,1) == "|" Then $feature_value=StringTrimRight($feature_value,1)
	Return $feature_value
EndFunc

Func ReleaseGetVBoxRAM($release_in_list)
	$features=ReleaseGetSupportedFeatures($release_in_list)
	$feature_list = StringSplit($features,",")
	For $feature IN $feature_list
		if StringInStr($feature,"vboxram-") Then
			$vboxram=StringSplit($feature,"-")
			if IsArray($vboxram) AND $vboxram[0]=2 Then Return $vboxram[2]
		EndIf
	Next
	Return "384"
EndFunc

Func ReleaseGetVBoxOSType($release_in_list)
	$features=ReleaseGetSupportedFeatures($release_in_list)
	$feature_list = StringSplit($features,",")
	For $feature IN $feature_list
		if StringInStr($feature,"vboxostype-") Then
			$vboxostype=StringSplit($feature,"-")
			if IsArray($vboxostype) AND $vboxostype[0]=2 Then Return $vboxostype[2]
		EndIf
	Next
	Return "256"
EndFunc

Func ReleaseGetVBoxStorageController($release_in_list)
	$features=ReleaseGetSupportedFeatures($release_in_list)
	if StringInStr($features,"vboxdisk-piix4") Then
		Return "PIIX4"
	Elseif StringInStr($features,"vboxdisk-ich6") Then
		Return "ICH6"
	Elseif StringInStr($features,"vboxdisk-piix3") Then
		Return "PIIX3"
	Elseif StringInStr($features,"vboxdisk-ide") Then
		Return "PIIX4"
	Elseif StringInStr($features,"vboxdisk-lsilogicsas") Then
		Return "LsiLogicSas"
	Elseif StringInStr($features,"vboxdisk-sas") Then
		Return "LsiLogicSas"
	Elseif StringInStr($features,"vboxdisk-ahci") Then
		Return "AHCI"
	Elseif StringInStr($features,"vboxdisk-sata") Then
		Return "AHCI"
	Elseif StringInStr($features,"vboxdisk-buslogic") Then
		Return "BusLogic"
	Else
		; Default value is SCSI (LsiLogic)
		Return "LsiLogic"
	EndIf
EndFunc


Func URLToHostname($url)
	if StringInStr($url,"/") >= 3 Then
		$temp = StringSplit($url,"/")
		if NOt @error AND IsArray($temp) AND $temp[0]>3 Then
			Return $temp[3]
		Else
			Return "ERROR"
		EndIf
	Else
		Return "ERROR"
	EndIf
EndFunc

Func path_to_name($filepath)
	$short_name = StringSplit($filepath, '\')
	if NOt @error AND IsArray($short_name) Then
		Return ($short_name[$short_name[0]])
	Else
		Return "ERROR"
	EndIf
EndFunc   ;==>path_to_name

Func unix_path_to_name($filepath)
	$short_name = StringSplit($filepath, '/')
	if NOt @error AND IsArray($short_name) Then
		Return ($short_name[$short_name[0]])
	Else
		Return "ERROR"
	EndIf
EndFunc   ;==>unix_path_to_name

Func get_extension($filepath)
	$short_name = StringSplit($filepath, '.')
	if NOt @error AND IsArray($short_name) Then
		Return ($short_name[$short_name[0]])
	Else
		Return "ERROR"
	EndIf
EndFunc   ;==>unix_path_to_name
