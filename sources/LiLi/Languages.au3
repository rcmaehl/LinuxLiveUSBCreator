; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Locales management                            ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func _Language()
	SendReport("Start-_Language")
	Local $use_source

	$force_lang = ReadSetting("General", "force_lang")
	If $force_lang <> "" And (FileExists($lang_folder & $force_lang & ".ini") Or $force_lang = "English") Then
		$lang_ini = $lang_folder & $force_lang & ".ini"
		$font_size=IniRead($lang_ini,$force_lang,"font_size",$font_size)
		$lang_code = "forced-"&$force_lang
		SendReport("End-_Language (Force Lang=" & $force_lang & ")")
		Return $force_lang
	EndIf

	If @MUILang <> "0000" Then
		$use_source=@MUILang
	Else
		$use_source=@OSLang
	EndIf

; Find codes in http://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
	Select
		Case StringInStr("0409,0809,0c09,1009,1409,1809,1c09,2009,2409,2809,2c09,3009,3409", $use_source)
			$lang_found = "English"
			$lang_code = "en"
		Case StringInStr("040c,080c,0c0c,100c,140c,180c", $use_source)
			$lang_found = "French"
			$lang_code="fr"
		Case StringInStr("040a,080a,0c0a,100a,140a,180a,1c0a,200a,240a,280a,2c0a,300a,340a,380a,3c0a,400a,440a,480a,4c0a,500a", $use_source)
			$lang_found = "Spanish"
			$lang_code="es"
		Case StringInStr("0425", $use_source)
			$lang_found = "Estonian"
			$lang_code = "et"
		Case StringInStr("0407,0807,0c07,1007,1407", $use_source)
			$lang_found = "German"
			$lang_code="de"
		Case StringInStr("0429", $use_source)
			$lang_found = "Persian"
			$lang_code="fa" ; == Farsi of Iran
		Case StringInStr("0416", $use_source)
			$lang_found = "Portuguese (Brazilian)"
			$lang_code="pt"
		Case StringInStr("0816", $use_source)
			$lang_found = "Portuguese (Standard)"
			$lang_code="pt"
		Case StringInStr("0410,0810", $use_source)
			$lang_found = "Italian"
			$lang_code="it"
		Case StringInStr("0414,0814", $use_source)
			$lang_found = "Norwegian"
			$lang_code="no"
		Case StringInStr("0403", $use_source)
			$lang_found = "Catalan"
			$lang_code="ca-es"
		Case StringInStr("0404,0804,0c04,1004,1404", $use_source)
			$lang_found = "Chinese"
			$lang_code="zh-cn"
		Case StringInStr("041a", $use_source)
			$lang_found = "Croatian"
			$lang_code="hr"
		Case StringInStr("0406", $use_source)
			$lang_found = "Danish"
			$lang_code="da"
		Case StringInStr("0418", $use_source)
			$lang_found = "Romanian"
			$lang_code="ro"
		Case StringInStr("0405", $use_source)
			$lang_found = "Czech"
			$lang_code="cs"
		Case StringInStr("040e", $use_source)
			$lang_found = "Hungarian"
			$lang_code="hu"
		Case StringInStr("0411", $use_source)
			$lang_found = "Japanese"
			$lang_code="ja"
		Case StringInStr("042b", $use_source)
			$lang_found = "Armenian"
			$lang_code="hy"
		Case StringInStr("0412", $use_source)
			$lang_found = "Korean"
			$lang_code="ko"
		Case StringInStr("041d,081d", $use_source)
			$lang_found = "Swedish"
			$lang_code="sv"
		Case StringInStr("041b", $use_source)
			$lang_found = "Slovak"
			$lang_code="sk"
		Case StringInStr("0419", $use_source)
			$lang_found = "Russian"
			$lang_code="ru"
		Case StringInStr("0413,0813", $use_source)
			$lang_found = "Dutch"
			$lang_code="nl"
		Case StringInStr("041B", $use_source)
			$lang_found = "Bulgarian"
			$lang_code="bg"
		Case StringInStr("0421", $use_source)
			$lang_found = "Indonesian"
			$lang_code="id"
		Case StringInStr("043e", $use_source)
			$lang_found = "Malay"
			$lang_code="ms"
		Case StringInStr("0422", $use_source)
			$lang_found = "Ukrainian"
			$lang_code="uk"
		Case StringInStr("041f", $use_source)
			$lang_found = "Turkish"
			$lang_code="tr"
		Case StringInStr("0449", $use_source)
			$lang_found = "Tamil"
			$lang_code="ta"
		Case StringInStr("0092,7c92,0492", $use_source)
			$lang_found = "Kurdish"
			$lang_code="ku"
		Case StringInStr("042a", $use_source)
			$lang_found = "Vietnamese"
			$lang_code="vi"
		Case Else
			$lang_found = "English"
			$lang_code="en"
	EndSelect
	$lang_ini = $lang_folder & $lang_found & ".ini"
	$font_size=IniRead($lang_ini,$lang_found,"font_size",$font_size)
	SendReport("End-_Language " & $lang_found)
	Return $lang_found
EndFunc   ;==>_Language

Func Translate($txt)
	Return IniRead($lang_ini, $lang, $txt, $txt)
EndFunc   ;==>Translate
