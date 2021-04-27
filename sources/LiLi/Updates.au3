; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// New Update Checker                            ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func _GetLatestRelease($sCurrent, $bBeta = False)

	Local $dAPIBin
	Local $sAPIJSON

	$dAPIBin = InetRead("https://api.fcofix.org/repos/rcmaehl/LinuxLiveUSBCreator/releases")
	If @error Then Return SetError(1, 0, 0)
	$sAPIJSON = BinaryToString($dAPIBin)
	If @error Then Return SetError(2, 0, 0)

	Local $aReleases = _StringBetween($sAPIJSON, '"tag_name": "', '",')
	If @error Then Return SetError(3, 0, 0)
	Local $aRelTypes = _StringBetween($sAPIJSON, '"prerelease": ', ',')
	If @error Then Return SetError(3, 1, 0)
	Local $aCombined[UBound($aReleases)][2]

	For $iLoop = 0 To UBound($aReleases) - 1 Step 1
		$aCombined[$iLoop][0] = $aReleases[$iLoop]
		$aCombined[$iLoop][1] = $aRelTypes[$iLoop]
	Next

	If $bBeta Then
		Return _VersionCompare($aCombined[0][0], $sCurrent)
	Else
		For $iLoop = 0 To UBound($aReleases) - 1 Step 1
			If $aCombined[$iLoop][1] = "true" Then ContinueLoop
			Return _VersionCompare($aCombined[$iLoop][0], $sCurrent)
		Next
	EndIf

EndFunc

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Updates management                            ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


Func GetLastUpdateIni()
	If ReadSetting("Updates", "check_for_updates") <> "yes" Then Return 0

	FileDelete($updates_ini)
	; Downloading the info for updates
	if (ReadSetting( "Updates", "check_for_beta_versions") = "yes") Then
		$append_query="&include_beta=1"
	Else
		$append_query=""
	EndIf
	;$server_response = INetGet($check_updates_url & "?&current_version="&$software_version&$append_query,$updates_ini,3)
	$server_response = INetGet($check_updates_url & "?from_version="&$software_version&$append_query,$updates_ini,3)

	If Not @error Then
		$last_stable=IniRead($updates_ini,"Software","last_stable","")
		;$last_stable_update=IniRead($updates_ini,"Software","last_stable_update","")
		$last_beta=IniRead($updates_ini,"Software","last_beta","")
		;$last_beta_update=IniRead($updates_ini,"Software","last_beta_update","")
		$what_is_new=StringReplace(IniRead($updates_ini,"Software","what_is_new",""),"/#/",@CRLF&"  ")

		$features_count=IniRead($updates_ini,"Software","features_count","")
		$improvements_count=IniRead($updates_ini,"Software","improvements_count","")
		$fixed_bugs_count=IniRead($updates_ini,"Software","fixed_bugs_count","")
		$known_bugs_count=IniRead($updates_ini,"Software","known_bugs_count","")
		$new_distributions_count=IniRead($updates_ini,"Software","new_distributions_count","")
		$new_isos_count=IniRead($updates_ini,"Software","new_isos_count","")
		$features=StringReplace(IniRead($updates_ini,"Software","features",""),"/#/",@CRLF&"  ")
		$improvements=StringReplace(IniRead($updates_ini,"Software","improvements",""),"/#/",@CRLF&"  ")
		$bugfixes=StringReplace(IniRead($updates_ini,"Software","bugfixes",""),"/#/",@CRLF&"  ")
		$new_distributions=StringReplace(IniRead($updates_ini,"Software","new_distributions",""),"/#/",@CRLF&"  ")

		$virtualbox_pack=IniRead($updates_ini,"VirtualBox","version","")
		$virtualbox_in_pack=IniRead($updates_ini,"VirtualBox","vbox_version","")

		if $last_stable="" Then
			UpdateLog("Checking for update, update.ini downloaded but format is incorrect !")
			Return 0
		Else
			UpdateLog("Checking for update, LiLi's server answer = Last stable : "&$last_stable&" / Last Beta : "&$last_beta&" / Last Virtualbox : "&$virtualbox_pack&" ("&$virtualbox_in_pack&")")
			Return 1
		EndIf
	Else
		UpdateLog("WARNING : Could not check for updates (no connection ?)")
		Return 0
	EndIf
EndFunc



; Check for LiLi's updates
Func CheckForSoftwareUpdate()
	If $last_stable = "" Or $last_beta = "" Then Return 0

	$DISPLAY_VERSION = GetDisplayVersion()

	Switch _GetLatestRelease(GetDisplayVersion(), ReadSetting("Updates", "check_for_beta_versions") = "yes")
		Case -1
			; MsgBox($MB_OK+$MB_ICONWARNING+$MB_TOPMOST, "Test Build?", "You're running a newer build than publically available!", 10)
			Return 0
		Case 0
			Switch @error
				Case 0
					; MsgBox($MB_OK+$MB_ICONINFORMATION+$MB_TOPMOST, "Up to Date", "You're running the latest build!", 10)
					UpdateLog("Current software version is up to date")
				Case 1
					; MsgBox($MB_OK+$MB_ICONWARNING+$MB_TOPMOST, "Unable to Check for Updates", "Unable to load release data.", 10)
				Case 2
					; MsgBox($MB_OK+$MB_ICONWARNING+$MB_TOPMOST, "Unable to Check for Updates", "Invalid Data Received!", 10)
				Case 3
					Switch @extended
						Case 0
							; MsgBox($MB_OK+$MB_ICONWARNING+$MB_TOPMOST, "Unable to Check for Updates", "Invalid Release Tags Received!", 10)
						Case 1
							; MsgBox($MB_OK+$MB_ICONWARNING+$MB_TOPMOST, "Unable to Check for Updates", "Invalid Release Types Received!", 10)
					EndSwitch
			EndSwitch
			Return 0
		Case 1
			UpdateLog("New version available")
			If MsgBox($MB_YESNO+$MB_ICONINFORMATION+$MB_TOPMOST, Translate("Your LiLi's version is not up to date"), Translate("Do you want to download it")& "?", 10) = $IDYES Then
				ShellExecute("https://fcofix.org/LinuxLiveUSBCreator/releases")
				GUI_Exit()
			EndIf
			Return 1
	EndSwitch
#cs
	; Checking for software update
	if (ReadSetting( "Updates", "check_for_beta_versions") = "yes") AND VersionCompare($last_beta, $DISPLAY_VERSION) = 1  And Not $last_beta ="" Then
		UpdateLog("New beta version available")
		$return = MsgBox(68, Translate("There is a new Beta version available"), Translate("Your LiLi's version is not up to date")&"." & @CRLF & @CRLF & Translate("Last beta version is") & " : " & $last_beta & @CRLF & Translate("Your version is") & " : " & $software_version & @CRLF & @CRLF & Translate("Do you want to download it")&" ?")
		If $return = 6 Then
			ShellExecute("http://www.linuxliveusb.com/more-downloads")
			GUI_Exit()
		EndIf
		Return 1
	ElseIf Not $last_stable = 0 And Not $last_stable ="" And VersionCompare($last_stable, $DISPLAY_VERSION) = 1 Then
		UpdateLog("New stable version available")
		$return = MsgBox(68, Translate("There is a new version available"), Translate("Your LiLi's version is not up to date") &"."& @CRLF & @CRLF & Translate("Last version is") & " : " & $last_stable & @CRLF & Translate("Your version is") & " : " & $software_version & @CRLF & @CRLF & Translate("Do you want to download it")&" ?")
		If $return = 6 Then
			ShellExecute("http://www.linuxliveusb.com/update")
			GUI_Exit()
		EndIf
		Return 1
	Else
		UpdateLog("Current software version is up to date")
		Return 0
	EndIf
#ce
EndFunc   ;==>Check_for_updates


Func CheckForVirtualBoxUpdate()
	; Setting VirtualBox size
	$current_vbox_version=IniRead(@ScriptDir&"\tools\VirtualBox\Portable-VirtualBox\linuxlive\settings.ini","General","pack_version","ERROR")
	$lastupdate_vbox_version=IniRead($updates_ini,"VirtualBox","version","0.0.0.0")
	if $current_vbox_version==$lastupdate_vbox_version Then
		; Downloaded version is equal to the one described in VirtualBox.ini => using real size set in VirtualBox.ini
		$virtualbox_size=IniRead($updates_ini,"VirtualBox","realsize",$virtualbox_size)
		SendReport("VirtualBox folder exists, version is "&$current_vbox_version&" and is the latest. Its size is "&$virtualbox_size&"MB")
	Elseif FileExists(@ScriptDir&"\tools\VirtualBox\") Then
		; No match, computing size directly
		$virtualbox_size =Round(DirGetSize(@ScriptDir&"\tools\VirtualBox\")/(1024*1024))
		SendReport("VirtualBox folder exists but does not match version of last update ( "&$current_vbox_version&"!="&$lastupdate_vbox_version&" ). Its size is "&$virtualbox_size&"MB")
	Else
		; No match and no downloaded version, default size is set to default size
		SendReport("No VirtualBox folder. Default size is "&$virtualbox_size&"MB")
	EndIf
EndFunc

Func GetLastAvailableVersion()

	$DISPLAY_VERSION=GetDisplayVersion()

	; Get the latest version available (taking into account whether the user want to see betas too)
	if (ReadSetting( "Updates", "check_for_beta_versions") = "yes") AND $last_stable <> "" AND $last_beta <> "" Then
		If VersionCompare($last_stable, $last_beta) = 1 Then
			$last_version = $last_stable
		Else
			$last_version = $last_beta
		EndIf
	Elseif $last_stable <> "" Then
		$last_version = $last_stable
	Else
		$last_version = $DISPLAY_VERSION
	EndIf

	; Last version has to be more recent than the one you have ...
	if VersionCompare($last_version,$DISPLAY_VERSION) = 1 Then
		Return $last_version
	Else
		Return $DISPLAY_VERSION
	EndIf
EndFunc

; Compare 2 versions
;	0 =  Versions are equals
;	1 =  Version 1 is higher
;   2 =  Version 2 is higher
Func VersionCompare($version1, $version2)
	If VersionCode($version1) = VersionCode($version2) Then
		Return 0
	ElseIf VersionCode($version1) > VersionCode($version2) Then
		Return 1
	Else
		Return 2
	EndIf
EndFunc   ;==>VersionCompare

; Transform a label to a number
Func SortVersionLabel($version_label)
	; Without spaces and lower case
	Switch StringStripWS(StringLower($version_label),8)
		Case "alpha"
			Return 0
		Case "beta"
			Return 1
		Case "beta1"
			Return 2
		Case "beta2"
			Return 3
		Case "beta3"
			Return 4
		Case "rc1"
			Return 5
		Case "releasecandidate1"
			Return 5
		Case "rc2"
			Return 6
		Case "releasecandidate2"
			Return 6
		Case "rc3"
			Return 7
		Case "releasecandidate3"
			Return 7
		Case Else
			Return 8
	EndSwitch
EndFunc   ;==>SortVersionLabel

; Transform a version name to a version code to be compared up to 3 digits like "2.3.1 Beta" or "3" or "2.3"
Func VersionCode($version)
	$parse_version = StringSplit($version, " ",3)

	$numbers = StringSplit($parse_version[0], ".",3)
	$version_number=""

	; Each digit can go up to 99
	For $number IN $numbers
		if $number < 10 Then
			$version_number &= "0"&$number
		Else
			$version_number &= $number
		EndIf
	Next

	if Ubound($numbers) = 1 Then
		; 3 => 30000
		$version_number &= "0000"
	Elseif Ubound($numbers) = 2 Then
		; 2.9 => 20900
		$version_number &= "00"
	EndIf

	If Ubound($parse_version) >= 2 Then
		; It must be a beta => will need a code to compare
		$version_number &= SortVersionLabel($parse_version[1])
	Else
		; It must be a stable => code is 8
		$version_number &= "8"
	EndIf
	Return Int($version_number)
EndFunc   ;==>VersionCode

Func isBeta()
	If StringInStr($software_version, "RC") Or StringInStr($software_version, "Beta") Or StringInStr($software_version, "Alpha") Or StringInStr($software_version, "Rele") Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc   ;==>isBeta

Func GetDisplayVersion()
	Global $current_compatibility_list_version
	if isBeta() Then
		return $software_version
	Else
		$current_compatibility_list_version = IniRead($compatibility_ini, "Compatibility_List", "Version", $software_version & ".0")
		return $current_compatibility_list_version
	EndIf
EndFunc

; Return the last number of compatibility list version (ie 2.6.10 will return 10)
Func VersionCodeForCompatList($version)
	$parse_version = StringSplit($version, ".")
	Return Int($parse_version[Ubound($parse_version)-1])
EndFunc   ;==>VersionCode

; Return Major version code for compatibility list version (ie 2.6.10 will return 26)
Func MajorVersionCode($version)
	Return Int(StringReplace(StringLeft($version,3),".",""))
EndFunc



; Return a generic version code for some Linuxes (Ubuntu mostly)
Func GenericVersionCode($version)
	Return Int(StringReplace($version,".",""))
EndFunc

; Return a generic version code without minor (10.10.2 will return 10.10) for some Linuxes (Ubuntu mostly)
Func GenericVersionCodeWithoutMinor($version)
	$splitted = StringSplit($version,".",2)
	if Ubound($splitted) >= 2 Then
		$major = $splitted[0]&$splitted[1]
		Return Int($major)
	Else
		Return Int(StringReplace($version,".",""))
	EndIf
EndFunc


Func CompareHuman($version1,$version2)
	$result = CompareVersion($version1,$version2)
	if $result=0 Then
		return $version1&" is equal to "&$version2
	Elseif $result = 1 Then
		return $version1&" is greater than "&$version2
	Elseif $result = 2 Then
		return $version2&" is greater than "&$version1
	EndIf
EndFunc

#cs
	Can compare any version using X.X.X.X format (with X = 1-10 / A-F)
	Return :
		0 if equal
		1 if var > var2 (var is newer)
		2 if var < var 2 (var2 is newer)
#ce
Func CompareVersion($var, $var2)
    $aVar1 = StringSplit($var,".")
    $aVar2 = StringSplit($var2,".")
    If $aVar1[0] > $aVar2[0] Then
        $length = $aVar2[0]
    Else
        $length =$aVar1[0]
    EndIf
    For $i = 1 to $length
        $ret = 0
		if StringIsAlpha($aVar1[$i]) AND StringIsXDigit($aVar1[$i]) Then
			$number1 = Dec($aVar1[$i])
		Else
			$number1 = number($aVar1[$i])
		EndIf

		if StringIsAlpha($aVar2[$i]) AND StringIsXDigit($aVar2[$i]) Then
			$number2 = Dec($aVar2[$i])
		Else
			$number2 = number($aVar2[$i])
		EndIf

        If $number1 >  $number2 Then
            $ret = 1
            ExitLoop
        ElseIf $number1 = $number2 Then
            If $aVar1[0] > $aVar2[0] Then
                $ret = 1
            ElseIf $aVar1[0] < $aVar2[0] Then
                $ret = 2;
            EndIf
        Else
            $ret = 2
            ExitLoop
        EndIf
    Next
    Return $ret
EndFunc
