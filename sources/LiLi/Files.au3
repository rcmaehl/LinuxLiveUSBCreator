; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Files management                      ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func DirRemove2($arg1, $arg2)
	Local $status="Deleting folder : " & $arg1
	If DirRemove($arg1, $arg2) Then
		$status &=" -> " & "Deleted successfully"
	Else
		If DirGetSize($arg1) >= 0 Then
			$status &=" -> " & "Not deleted"
		Else
			Return 1
		EndIf
	EndIf
	UpdateLog($status)
EndFunc   ;==>DirRemove2

Func FileDelete2($arg1)
	Local $status="Deleting file : " & $arg1
	If FileDelete($arg1) == 1 Then
		$status &=" -> " & "Deleted successfully"
	Else
		If FileExists($arg1) Then
			$status &=" -> " & "Not Deleted"
		Else
			Return 1
		EndIf
	EndIf
	UpdateLog($status)
EndFunc   ;==>FileDelete2

Func HideFilesInDir($list_of_files)
	SendReport("Start-HideFilesInDir")
	if Not IsArray($list_of_files) Then
		SendReport("End-HideFilesInDir : list of files is not an array !")
		return "ERROR"
	Else
		SendReport("IN-HideFilesInDir : "&Ubound($list_of_files)&" files/folders will be hidden")
	EndIf
	For $file In $list_of_files
		UpdateLog("hiding file "&$usb_letter & "\" & $file)
		HideFile($usb_letter & "\" & $file)
	Next
	SendReport("End-HideFilesInDir")
EndFunc   ;==>HideFilesInDir

Func isDir($file_to_test)
	Return StringInStr(FileGetAttrib($file_to_test), "D")
EndFunc   ;==>isDir

Func DeleteFilesInDir($list_of_files)
	SendReport("Start-DeleteFilesInDir")
	if (Ubound($list_of_files)=0) Then
		SendReport("End-DeleteFilesInDir : list of files is not an array !")
		return "ERROR"
	EndIf
	For $file In $list_of_files
		If isDir($usb_letter & "\" & $file) Then
			DirRemove2($usb_letter & "\" & $file, 1)
		Else
			FileDelete2($usb_letter & "\" & $file)
		EndIf
	Next
	SendReport("End-DeleteFilesInDir")
EndFunc   ;==>DeleteFilesInDir

Func HideFile($file_or_folder)
	Local $status="Hiding file : " & $file_or_folder

	If FileSetAttrib($file_or_folder, "+SH") == 1 Then
		$status &=" -> " &"Hided successfully"
	Else
		If FileExists($file_or_folder) Then
			$status &=" -> " & "Not hided"
		Else
			return 1
		EndIf
	EndIf
	UpdateLog($status)
EndFunc   ;==>HideFile

Func ShowFile($file_or_folder)
	Local $status="Unhiding file : " & $file_or_folder
	If FileSetAttrib($file_or_folder, "-SH") == 1 Then
		$status &=" -> " &"Unhided successfully"
	Else
		If FileExists($file_or_folder) Then
			$status &=" -> " & "Not hided"
		Else
			return 1
		EndIf
	EndIf
	UpdateLog($status)
EndFunc   ;==>ShowFile

Func FileRename($file1, $file2)
	Local $status="Renaming File : " & $file1 & " in " & $file2
	If FileMove($file1, $file2, 1) == 1 Then
		$status &=" -> " & "File renamed successfully"
	Else
		if FileExists($file1) Then
			$status &=" -> " & "Not renamed"
		Else
			Return 1
		EndIf
	EndIf
	UpdateLog($status)
EndFunc   ;==>FileRename

Func FileCopyShell($fromFile, $tofile)
	SendReport("Start-_FileCopyShell (" & $fromFile & " -> " & $tofile & " )")
	Local $FOF_RESPOND_YES = 16
	Local $FOF_SIMPLEPROGRESS = 256
	$winShell = ObjCreate("shell.application")
	$winShell.namespace($tofile).CopyHere($fromFile, $FOF_RESPOND_YES)
	SendReport("End-_FileCopyShell")
EndFunc   ;==>_FileCopy

Func FileCopy2($arg1, $arg2 , $advanced=1)
	Local $status="Copying File : " & $arg1 & " to " & $arg2 & "(options = "&$advanced&")"
	If FileCopy($arg1, $arg2,$advanced) Then
		$status &=" -> " &"Copied successfully"
	Else
		if NOT FileExists($arg1) Then
			$status &=" -> " & "Not copied (source file does not exist)"
		Else
			$status &=" -> " & "Not copied (error)"
			UpdateLog($status)
			Return 1
		EndIf
	EndIf
	UpdateLog($status)
EndFunc   ;==>_FileCopy2

Func GetPreviousInstallSizeMB($drive_letter)
	SendReport("Start-GetPreviousInstallSizeMB for drive "&$drive_letter)
	Local $array,$array2,$chrono=TimerInit()
	if FileExists($drive_letter&"\"&$autoclean_settings) Then
		$array=IniReadSection($drive_letter&"\"&$autoclean_settings,"Files")
		$total=0
		if Ubound($array) > 1 Then
			for $i=1 To Ubound($array)-1
				$total+=IniRead($drive_letter&"\"&$autoclean_settings,"Files",$array[$i][0],"0")
				; Real size is too long to be computed  FileGetSize($drive_letter&"\"&$array[$i][0])
			Next
		EndIf

		$array2=IniReadSection($drive_letter&"\"&$autoclean_settings,"Folders")
		if Ubound($array2) > 1 Then
			for $i=1 To Ubound($array2)-1
				$total+=IniRead($drive_letter&"\"&$autoclean_settings,"Folders",$array2[$i][0],"0")
				; Real size is too long to be computed DirGetSize($drive_letter&"\"&$array2[$i][0]&"\")
			Next
		EndIf
		SendReport("End-GetPreviousInstallSizeMB ( Previous install : "&Round($total/(1024*1024),1)& " MB computed in "&Round(TimerDiff($chrono)/1000,1)&"sec) ")
		Return Round($total/(1024*1024),0)
	Else
		Return 0
	EndIf
EndFunc

Func AddToSmartClean($drive_letter,$file_to_smartclean)
	if FileExists($drive_letter&"\"&$file_to_smartclean) AND _ArraySearch($files_in_source,$file_to_smartclean)=-1  Then _ArrayAdd($files_in_source,$file_to_smartclean)
EndFunc

Func SmartCleanPreviousInstall($drive_letter)
	SendReport("Start-AutoCleanPreviousInstall for drive "&$drive_letter)
	Local $array,$i
	if FileExists($drive_letter&"\"&$autoclean_settings) Then
		$installed_linux=IniRead($drive_letter&"\"&$autoclean_settings,"General","Installed_Linux","NotFound")
		$linux_codename=IniRead($drive_letter&"\"&$autoclean_settings,"General","Installed_Linux_Codename","NotFound")
		$install_size=GetPreviousInstallSizeMB($drive_letter)
		$array=IniReadSection($drive_letter&"\"&$autoclean_settings,"Files")
		SendReport("Found a previous install of "&$install_size&"MB to SmartClean : "&$installed_linux&"("&$linux_codename&")")
		SendReport("Found "&(Ubound($array)-1)&" files to delete")
		if Ubound($array) > 1 Then
			for $i=1 To Ubound($array)-1
				if $array[$i][0] <> $autoclean_settings Then FileDelete2($drive_letter&"\"&$array[$i][0])
			Next
		EndIf

		$array=IniReadSection($drive_letter&"\"&$autoclean_settings,"Folders")
		SendReport("Found "&(Ubound($array)-1)&" folders to delete")
		if Ubound($array) > 1 Then
			for $i=1 To Ubound($array)-1
				DirRemove2($drive_letter&"\"&$array[$i][0],1)
			Next
		EndIf
		FileDelete2($drive_letter&"\"&$autoclean_settings)
		SendReport("End-AutoCleanPreviousInstall (found autoclean.ini)")
		Return 1
	Elseif Ubound($files_in_source>0) Then
		DeleteFilesInDir($files_in_source)
		SendReport("End-AutoCleanPreviousInstall (no autoclean.ini -> deleting listed files)")
		Return 0
	Else
		SendReport("End-AutoCleanPreviousInstall : WARNING (no autoclean.ini and no file list)")
		Return 0
	EndIf
EndFunc

Func InitializeFilesInSource($path)
	If isDir($path) == 1 Then
		return InitializeFilesInCD($path)
	Else
		return InitializeFilesInISO($path)
	EndIf
EndFunc   ;==>InitializeFilesInSource


; Analyze the listfile and only select files and folders at the root (will be used to clean previous installs and hide the newly created)
Func AnalyzeFileList()
	SendReport("Start-AnalyzeFileList")
	Local $line, $filelist, $files[1]
	$filelist = FileOpen(@ScriptDir & "\tools\filelist.txt", 0)
	While 1
		$line = FileReadLine($filelist)
		If @error = -1 Then ExitLoop
		If StringRegExp($line, "^Path = ", 0) And StringInStr($line, "\") == 0 And StringInStr($line, "[BOOT]") == 0 Then
			_ArrayAdd($files, StringReplace($line, "Path = ", ""))
			SendReport("IN-AnalyzeFileList :  Found file : "&StringReplace($line, "Path = ", ""))
		EndIf
	WEnd
	FileClose($filelist)
	FileDelete(@ScriptDir & "\tools\filelist.txt")
	_ArrayDelete($files, 0)
	$files_in_source = $files
	SendReport("End-AnalyzeFileList")
EndFunc   ;==>AnalyzeFileList

Func InitializeFilesInCD($searchdir)
	Local $files[1]
	If StringRight($searchdir, 1) <> "\" Then $searchdir = $searchdir & "\"

	$search = FileFindFirstFile($searchdir & "*")
	If isDir($searchdir & $search) Then _ArrayAdd($files, $search)

	; Check if the search was successful
	If $search = -1 Then
		SendReport("IN-InitializeFilesInCD : No files/directories matched the search pattern")
		FileClose($search)
		Return ""
	EndIf

	$attrib = ""
	While 1
		$file = FileFindNextFile($search)
		If @error Then ExitLoop
		_ArrayAdd($files, $file)
	WEnd
	; Close the search handle
	FileClose($search)
	_ArrayDelete($files, 0)
	$files_in_source = $files
EndFunc   ;==>InitializeFilesInCD

Func AutoDetectSyslinuxVersion($fallback_version)
	if FileExists($usb_letter&"\boot\syslinux\syslinux.bin") Then
		$isolinux_bin = $usb_letter&"\boot\syslinux\syslinux.bin"
	ElseIf FileExists($usb_letter&"\syslinux\syslinux.bin") Then
		$isolinux_bin = $usb_letter&"\syslinux\syslinux.bin"
	ElseIf FileExists($usb_letter&"\isolinux\syslinux.bin") Then
		$isolinux_bin = $usb_letter&"\isolinux\syslinux.bin"
	ElseIf FileExists($usb_letter&"\boot\isolinux\syslinux.bin") Then
		$isolinux_bin = $usb_letter&"\boot\isolinux\syslinux.bin"
	ElseIf FileExists($usb_letter&"\syslinux.bin") Then
		$isolinux_bin = $usb_letter&"\syslinux.bin"
	ElseIf FileExists($usb_letter&"\hbcd\syslinux.bin") Then
		$isolinux_bin = $usb_letter&"\hbcd\syslinux.bin"
	ElseIf FileExists($usb_letter&"\hbcd\isolinux.bin") Then
		$isolinux_bin = $usb_letter&"\hbcd\isolinux.bin"
	Elseif FileExists($usb_letter&"\boot\syslinux\isolinux.bin") Then
		$isolinux_bin = $usb_letter&"\boot\syslinux\isolinux.bin"
	ElseIf FileExists($usb_letter&"\syslinux\isolinux.bin") Then
		$isolinux_bin = $usb_letter&"\syslinux\isolinux.bin"
	ElseIf FileExists($usb_letter&"\isolinux\isolinux.bin") Then
		$isolinux_bin = $usb_letter&"\isolinux\isolinux.bin"
	ElseIf FileExists($usb_letter&"\boot\isolinux\isolinux.bin") Then
		$isolinux_bin = $usb_letter&"\boot\isolinux\isolinux.bin"
	ElseIf FileExists($usb_letter&"\slax\boot\isolinux.bin") Then
		$isolinux_bin = $usb_letter&"\slax\boot\isolinux.bin"
	ElseIf FileExists($usb_letter&"\isolinux.bin") Then
		$isolinux_bin = $usb_letter&"\isolinux.bin"
	Else
		UpdateLog("WARNING : Could not detect syslinux version (no isolinux.bin or syslinux.bin found), default to v"&$fallback_version)
		Return $fallback_version
	EndIf
	Return DetectSyslinuxVersionInBin($isolinux_bin,$fallback_version)
EndFunc


Func DetectSyslinuxVersionInBin($file,$fallback_version)
	If StringInStr($file,"syslinux.bin") Then
		$detection_mode = "SYSLINUX"
	Else
		$detection_mode = "ISOLINUX"
	EndIf

	$filehandle = FileOpen($file)
	If $filehandle = -1 Then
		UpdateLog("Could not open syslinux.bin to detect syslinux version")
		Return -1
	EndIf
	$content = FileRead($filehandle)
	FileClose($filehandle)

	$match = StringRegExp($content, '(?i)'&$detection_mode&'.(\d)\.(\d*)\s', 2)
	If @error=0 AND Ubound($match)=3 Then
		$major_revision=$match[1]
		$minor_revision=$match[2]
		UpdateLog("Syslinux "&$major_revision&"."&$minor_revision&" detected in file "&$file)
		Return $major_revision
	Else
		UpdateLog("Syslinux version could not be detected in file "&$file& " => Falling back to the old method")
		$detected_version=DetectSyslinuxVersionInBinold($file)
		if $detected_version == 0 Then
			return $fallback_version
		Else
			return $detected_version
		EndIf
	EndIf
EndFunc

Func DetectSyslinuxVersionInBinold($file)
	$filehandle = FileOpen($file, 16)
	If $filehandle = -1 Then
		UpdateLog("Could not open syslinux.bin to detect syslinux version")
		Return -1
	EndIf
	$content = FileRead($filehandle)
	FileClose($filehandle)
	if StringInStr($content,"49534F4C494E555820362E",2)>0 Then
		UpdateLog("Syslinux 6.X detected in file "&$file)
		Return 6
	Elseif StringInStr($content,"49534F4C494E555820352E",2)>0 Then
		UpdateLog("Syslinux 5.X detected in file "&$file)
		Return 5
	Elseif StringInStr($content,"49534F4C494E555820342E",2)>0 Then
		UpdateLog("Syslinux 4.X detected in file "&$file)
		Return 4
	Elseif StringInStr($content,"49534F4C494E555820332E",2)>0 Then
		UpdateLog("Syslinux 3.X detected in file "&$file)
		Return 3
	Elseif StringInStr($content,"49534F4C494E555820322E",2)>0 Then
		UpdateLog("Syslinux 2.X detected in file "&$file)
		Return 2
	Elseif StringInStr($content,"49534F4C494E555820312E",2)>0 Then
		UpdateLog("Syslinux 1.X detected in file "&$file)
		Return 2
	Else
		UpdateLog("[WARNING] Syslinux version could not be detected in file "&$file)
		Return 0
	EndIf
EndFunc

Func CleanFilename($filename_to_clean)
	$filename_to_clean = StringRegExpReplace($filename_to_clean, '(?i)\(.\)|\[.\]',"")
	$filename_to_clean = StringRegExpReplace($filename_to_clean, "(?i)\s*\.iso",".iso")
	$filename_to_clean = StringRegExpReplace($filename_to_clean, "(?i)\s*-\s*Cópia|"&"\s*-\s*Copie|"&"\s*-\s*Copy|"&"\s*-\s*Kopie|"&"\s*-\s*Copia|"&"\s*-\s*êîïèÿ","")
	return $filename_to_clean
EndFunc

; Mode can be 128 for example to use UTF8
Func FileOverWrite($filename,$content,$mode=0)
	$file = FileOpen($filename, (2+$mode))
	If $file = -1 Then
		SendReport("Could not overwrite file "&$filename)
		return -1
	EndIf
	FileWrite($file,$content)
	FileClose($file)
EndFunc

Func FileReplaceBetween($file,$start,$end,$new_value)
	UpdateLog("Start-FileReplaceBetween : Replacing "&$start&"%VALUE%"&$end&" with value : "&$new_value)
	$file_content = FileRead($file)
	if @error Then
		UpdateLog("End-FileReplaceBetween : Warning, Could not open "&$file&" in read mode ")
		Return 0
	EndIf
	$old_value = _StringBetween ($file_content, $start, $end)

	If NOt @error AND isArray($old_value) Then
		UpdateLog("Start-FileReplaceBetween : value to be replaced is "&$old_value[0])
		$new_content=StringReplace ($file_content, $start & $old_value[0] & $end,$start & $new_value &$end)
		if @extended > 0 Then
			FileOverWrite($file,$new_content)
			SendReport("End-FileReplaceBetween : SUCCESS")
		Else
			SendReport("End-FileReplaceBetween : WARNING (no match found to be replaced)")
		EndIf
	Else
		SendReport("End-FileReplaceBetween : ERROR => No value found")
	EndIf
EndFunc

Func unix_path_to_extension($filepath)
	$extension = StringSplit($filepath, '.')
	If Not @error And IsArray($extension) Then
		Return ($extension[$extension[0]])
	Else
		Return "ERROR"
	EndIf
EndFunc   ;==>unix_path_to_extension

Func HumanSize($size_in_bytes)
	$value = $size_in_bytes
	$suffix = "B"
	If $value < 2 ^ 10 Then
		Return $value & " " & $suffix
	ElseIf $value < 2 ^ 20 Then
		Return Round($value / 2 ^ 10, 2) & " k" & $suffix
	ElseIf $value < 2 ^ 30 Then
		Return Round($value / 2 ^ 20, 2) & " M" & $suffix
	ElseIf $value < 2 ^ 40 Then
		Return Round($value / 2 ^ 30, 2) & " G" & $suffix
	Else
		Return Round($value / 2 ^ 40, 2) & " T" & $suffix
	EndIf
EndFunc

Func UnZip($sZipFile, $sDestFolder)
	If Not FileExists($sZipFile) Then Return SetError (1) ; source file does not exists
	If Not FileExists($sDestFolder) Then
		If Not DirCreate($sDestFolder) Then Return SetError (2) ; unable to create destination
	Else
		If Not StringInStr(FileGetAttrib($sDestFolder), "D") Then Return SetError (3) ; destination not folder
	EndIf
	Local $oShell = ObjCreate("shell.application")
	Local $oZip = $oShell.NameSpace($sZipFile)
	Local $iZipFileCount = $oZip.items.Count
	If Not $iZipFileCount Then Return SetError (4) ; zip file empty
	For $oFile In $oZip.items
		$oShell.NameSpace($sDestFolder).copyhere($ofile)
	Next
EndFunc   ;==>UnZip