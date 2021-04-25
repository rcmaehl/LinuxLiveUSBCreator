; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Statistics                                  ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func SendInitialStats()
	SendReportNoLog("stats-t=appview&cd=Start&ul="&$lang_code&"&sr="&@DesktopWidth & "x" & @DesktopHeight&"&cd1="&_URIEncode(OSName())&"&cd2="&@CPUArch&"&cd3="&@OSArch)
EndFunc

Func SendDistribStats($distrib)
	SendReportNoLog("stats-t=event&ec=General&ea=create-usb&el=Create%20USB&cd4="&_URIEncode($distrib))
EndFunc

Func SendCreationSpeedStats($duration)
	SendReportNoLog("stats-t=timing&utv=usb-creation-time&utc=General&utt="&$duration&"&utl=USB%20Creation%20Speed")
EndFunc

Func SendAppviewStats($content_description,$customdata="")
	SendReportNoLog("stats-t=appview&cd="&_URIEncode($content_description)&$customdata)
EndFunc

Func SendEventStats($event_category,$event_action,$event_label,$customdata="")
	SendReportNoLog("stats-t=event&ec="&$event_category&"&ea="&$event_action&"&el="&_URIEncode($event_label)&$customdata)
EndFunc

Func SendCloseStats()
	SendReportNoLog("stats-sc=end")
EndFunc

Func _Language_for_stats()
	If @MUILang <> "0000" Then
		$use_source=@MUILang
	Else
		$use_source=@OSLang
	EndIf
	Return HumanOSLang($use_source)
EndFunc   ;==>_Language_for_stats

Func OSName()
	Switch @OSVersion
		Case "WIN_81"
			Return "Windows 8.1"
		Case "WIN_8"
			Return "Windows 8"
		Case "WIN_7"
			Return "Windows 7"
		Case "WIN_VISTA"
			Return "Windows Vista"
		Case "WIN_XP"
			Return "Windows XP"
		Case "WIN_XPe"
			Return "Windows XP Embedded"
		Case "WIN_2012R2"
			Return "Windows Server 2012 R2"
		Case "WIN_2012"
			Return "Windows Server 2012"
		Case "WIN_2008"
			Return "Windows Server 2008"
		Case "WIN_2008R2"
			Return "Windows Server 2008 R2"
		Case "WIN_2003"
			Return "Windows Server 2003"
		Case "WIN_2000"
			Return "Windows 2000"
		Case Else
			Return "Unknown ("&@OSVersion&")"
	EndSwitch
EndFunc

Func _URIEncode($sData)
    ; Prog@ndy
    Local $aData = StringSplit(BinaryToString(StringToBinary($sData,4),1),"")
    Local $nChar
    $sData=""
    For $i = 1 To $aData[0]
        ; ConsoleWrite($aData[$i] & @CRLF)
        $nChar = Asc($aData[$i])
        Switch $nChar
            Case 45, 46, 48 To 57, 65 To 90, 95, 97 To 122, 126
                $sData &= $aData[$i]
            Case 32
                $sData &= "+"
            Case Else
                $sData &= "%" & Hex($nChar,2)
        EndSwitch
    Next
    Return $sData
EndFunc
