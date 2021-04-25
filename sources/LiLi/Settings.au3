
Func WriteSetting($category,$key,$value)
	if IniRead($settings_ini, "Advanced", "lili_portable_mode", "no")="yes" OR NOT RegWrite("HKEY_CURRENT_USER\SOFTWARE\LinuxLive\"&$category, $key, "REG_SZ", $value) Then
		; Portable mode active : writing settings to INI file
		IniWrite($settings_ini, $category, $key, $value)
	Else
		; Writing to both in order to be more portable
		IniWrite($settings_ini, $category, $key, $value)
		RegWrite("HKEY_CURRENT_USER\SOFTWARE\LinuxLive\"&$category, $key, "REG_SZ", $value)
	EndIf
EndFunc

Func ReadSetting($category,$key)
	if IniRead($settings_ini, "Advanced", "lili_portable_mode", "no")="yes" OR (RegRead("HKEY_CURRENT_USER\SOFTWARE\LinuxLive\"&$category, $key)=="" AND @error) Then
		; Portable mode active : writing settings to INI file
		$val=IniRead($settings_ini, $category, $key,"")
	Else
		$val=RegRead("HKEY_CURRENT_USER\SOFTWARE\LinuxLive\"&$category, $key)
		IniWrite($settings_ini, $category, $key, $val)
	EndIf
	Return StringStripWS($val,3)
EndFunc