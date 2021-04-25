; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Launching third party tools                       ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func Run7zip($cmd, $taille)
	Local $percentage, $line
	$initial = DriveSpaceFree($selected_drive)
	SendReport("Start-Run7zip ( Command :" & $cmd & " - Size:" & $taille & " )")

	UpdateLog($cmd)
	If ProcessExists("7z.exe") > 0 Then ProcessClose("7z.exe")
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	$line = ""

	While ProcessExists($foo) > 0
		$percentage = Round((($initial - DriveSpaceFree($selected_drive)) * 100 / $taille), 0)
		If $percentage > 0 And $percentage < 101 Then
			UpdateStatusNoLog(Translate("Extracting ISO file on key") & " ( " & $percentage & "% )")
		EndIf
		Sleep(500)
		$line &= StdoutRead($foo)
		If @error Then ExitLoop
		$line &= StderrRead($foo)
		If @error Then ExitLoop
	WEnd
	UpdateLog($line)
	SendReport("End-Run7zip")
EndFunc   ;==>Run7zip

; Create a list of files in ISO
Func InitializeFilesInISO($iso_to_list)
	Local $line="",$error=""
	SendReport("Start-InitializeFilesInISO ( " & $iso_to_list &")")

	FileDelete(@ScriptDir & "\tools\filelist.txt")
	;$cmd='7z.exe' & ' l -slt "' & $iso_to_list
	$cmd='"' & @ScriptDir & '\tools\7z.exe" l -y -slt "' & $iso_to_list & '"'
	SendReport("IN-InitializeFilesInISO : executing command -> " &@CRLF& $cmd)
	If ProcessExists("7z.exe") > 0 Then ProcessClose("7z.exe")
	$output=_RunReadStd($cmd)

	Switch $output[0]
		Case 0
			UpdateLog("7zip error code 0 : No error")
			FileWrite(@ScriptDir & "\tools\filelist.txt",$output[1])
		Case 2
			UpdateLog("7zip error code 2 : Fatal Error")
			if StringInStr($output[1],"Can not open file as archive") OR StringInStr($output[1],"Cannot open file as archive") Then
				UpdateStatus(Translate("Your file is corrupted")&@CRLF&Translate("Please download it again"))
				UpdateLog($output[1])
				Return -1
			Else
				UpdateStatus(Translate("Your file is corrupted")&@CRLF&Translate("Read the log for more information")&".")
				UpdateLog($output[1])
				Return -1
			EndIf

		Case 1
			UpdateLog("7zip error code 1 : Warning (Non fatal error(s)). For example, one or more files were locked by some other application")
		Case 7
			UpdateLog("7zip error code 7 : Command line error")
		Case 8
			UpdateLog("7zip error code 8 : Not enough memory for operation")
		Case 255
			UpdateLog("7zip error code 255 : User stopped the process")
		Case Else
			FileWrite(@ScriptDir & "\tools\filelist.txt",$output[1])
	EndSwitch
	AnalyzeFileList()
	SendReport("End-InitializeFilesInISO")
	Return 0
EndFunc   ;==>InitializeFilesInISO

; Install Syslinux boot sectors
Func InstallSyslinux($version=4,$syslinux_menu_folder="")
	Local $line="",$error="",$executable="syslinux.exe"
	SendReport("Start-InstallSyslinux on " & $usb_letter &" (version "&$version&" / Folder "&$syslinux_menu_folder&")")

	; Installing Syslinux to custom directory, format has to be -d \HBCD for example
	if $syslinux_menu_folder <> "" Then
		$syslinux_menu_folder_arg="-d " &$syslinux_menu_folder&" "
	Else
		$syslinux_menu_folder_arg=""
	EndIf

	$executable="syslinux"&$version&".exe"

	If Not FileExists(@ScriptDir & '\tools\'&$executable) Then
		SendReport("End-InstallSyslinux : FATAL ERROR detected ("&$executable&" NOT FOUND)")
		Return -1
	EndIf

	$cmd='"' & @ScriptDir & '\tools\'&$executable&'" -maf ' & $syslinux_menu_folder_arg & $usb_letter
	SendReport("IN-InstallSyslinux : executing command -> " &@CRLF& $cmd)
	$output=_RunReadStd($cmd)
	SendReport("Return code : "&$output[0]&@CRLF&"Output : "&$output[1]&@CRLF&"Error : "&$output[2])

	If StringInStr($output[2],"Did not successfully") OR StringInStr($output[2],"Error : ") Then
		SendReport("End-InstallSyslinux : FATAL ERROR detected ("&StringReplace($output[2],@CRLF,"")&")")
		Return -1
	EndIf
	SendReport("End-InstallSyslinux")
	Return 0
EndFunc   ;==>InstallSyslinux

; Install Windows boot sectors
Func InstallWindowsBootSectors($drive_letter)
	Local $line="",$error=""
	SendReport("Start-InstallWindowsBootSectors on " & $drive_letter)

	$cmd='"' & $drive_letter & '\boot\bootsect.exe" /nt60 ' & $drive_letter& " /force"
	SendReport("IN-InstallWindowsBootSectors : executing command -> " &@CRLF& $cmd)
	$output=_RunReadStd($cmd)
	SendReport("Return code : "&$output[0]&@CRLF&"Output : "&$output[1]&@CRLF&"Error : "&$output[2])
	; Sleeping 500ms because /force unmount the disk
	Sleep(500)
	; Add check for success
	SendReport("End-InstallWindowsBootSectors")
	Return 0
EndFunc   ;==>InstallWindowsBootSectors


Func Run7zip2($cmd, $taille)
	Local $percentage, $line
	$initial = DriveSpaceFree($selected_drive)
	SendReport("Start-Run7zip2 ( Command :" & $cmd & " - Size:" & $taille & " )")
	UpdateLog($cmd)
	If ProcessExists("7z.exe") > 0 Then ProcessClose("7z.exe")
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	$line = ""
	While ProcessExists($foo) > 0
		$percentage = Round((($initial - DriveSpaceFree($selected_drive)) * 100 / $taille), 0)
		If $percentage > 0 And $percentage < 101 Then
			UpdateStatusNoLog(Translate("Extracting VirtualBox on key") & " ( ± " & $percentage & "% )")
		EndIf
		;If @error Then ExitLoop
		;UpdateStatus2($line)
		Sleep(500)
		$line &= StdoutRead($foo)
		If @error Then ExitLoop
		$line &= StderrRead($foo)
		If @error Then ExitLoop
	WEnd
	UpdateLog($line)
	SendReport("End-Run7zip2")
EndFunc   ;==>Run7zip2

Func Create_Empty_File($file_to_create, $size)
	SendReport("Start-Create_Empty_File (file : " & $file_to_create & " - Size:" & $size & " )")
	Local $cmd, $line
	$cmd = @ScriptDir & '\tools\dd.exe if=/dev/zero of=' & $file_to_create & ' count=' & $size & ' bs=1024k'
	UpdateLog($cmd)
	If ProcessExists("dd.exe") > 0 Then ProcessClose("dd.exe")
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	$line = ""
	While 1

		UpdateStatusNoLog(Translate("Creating file for persistence") & " ( " & Round(FileGetSize($file_to_create) / 1048576, 0) & "/" & Round($size, 0) & " Mo )")
		$line &= StdoutRead($foo)
		If @error Then ExitLoop
		$line &= StderrRead($foo)
		If @error Then ExitLoop
		Sleep(500)
	WEnd
	UpdateLog($line)
	SendReport("End-Create_Empty_File")
EndFunc   ;==>Create_Empty_File


Func EXT2_Format_File($persistence_file)
	Local $line,$line_temp,$errors=""
	If ProcessExists("mke2fs.exe") > 0 Then ProcessClose("mke2fs.exe")
	$cmd = @ScriptDir & '\tools\mke2fs.exe ' & $persistence_file
	SendReport("Start-EXT2_Format_File ( " & $cmd & " )")
	UpdateLog($cmd)
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD + $STDIN_CHILD)
	$line_temp = ""
	$line=""
	While 1
		$line_temp = StdoutRead($foo)
		If @error Then ExitLoop
		;$line_temp &= StderrRead($foo)
		;If @error Then ExitLoop
		;$parse_percent = StringRegExp($line_temp, '[0-9]{1,3}%', 1)
		;if Ubound($parse_percent)>0 Then UpdateStatusNoLog(Translate("Formating persistence file") & " "& $parse_percent[0])
		$line &=$line_temp
		StdinWrite($foo, "{ENTER}")
		If @error Then ExitLoop
		Sleep(500)
	WEnd
	UpdateLog($line)
	While 1
		$errors &= StderrRead($foo)
		If @error Then ExitLoop
	WEnd
	UpdateLog($errors)
	SendReport("End-EXT2_Format_File")
EndFunc   ;==>EXT2_Format_File

Func RunWait3($soft, $workingdir=@ScriptDir, $flag=@SW_HIDE)
	SendReport("Start-RunWait3 ( " & $soft & " )")
	$output = _RunReadStd($soft,0,$workingdir,$flag)
	SendReport("Output : "&$output[1]&@CRLF&"Return code : "&$output[0]&@CRLF&"Error : "&$output[2])
	SendReport("End-RunWait3")
EndFunc   ;==>RunWait3


Func Run2($soft, $arg1, $arg2)
	SendReport("Start-Run2 ( " & $soft & " )")
	Local $line
	UpdateLog($soft)
	$foo = Run($soft, @ScriptDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	$line = ""
	While True
		$line &= StdoutRead($foo)
		If @error Then ExitLoop
		$line &= StderrRead($foo)
		If @error Then ExitLoop
		StdinWrite($foo, @CR & @LF & @CRLF)
		If @error Then ExitLoop
		Sleep(300)
	WEnd
	UpdateLog("                   " & $line)
	SendReport("End-Run2")
EndFunc   ;==>Run2

;===============================================================================
;
; Function Name:   _RunReadStd()
;
; Description::    Run a specified command, and return the Exitcode, StdOut text and
;                  StdErr text from from it. StdOut and StdErr are @tab delimited,
;                  with blank lines removed.
;
; Parameter(s):    $doscmd: the actual command to run, same as used with Run command
;                  $timeoutSeconds: maximum execution time in seconds, optional, default: 0 (wait forever),
;                  $workingdir: directory in which to execute $doscmd, optional, default: @ScriptDir
;                  $flag: show/hide flag, optional, default: @SW_HIDE
;                  $sDelim: stdOut and stdErr output deliminter, optional, default: @TAB
;                  $nRetVal: return single item from function instead of array, optional, default: -1 (return array)
;
;
; Return Value(s): An array with three values, Exit Code, StdOut and StdErr
;
; Author(s):       lod3n
;                  (Thanks to mrRevoked for delimiter choice and non array return selection)
;                  (Thanks to mHZ for _ProcessOpenHandle() and _ProcessGetExitCode())
;                  (MetaThanks to DaveF for posting these DllCalls in Support Forum)
;                  (MetaThanks to JPM for including CloseHandle as needed)
;
;===============================================================================

func _RunReadStd($doscmd,$timeoutSeconds=0,$workingdir=@ScriptDir,$flag=@SW_HIDE,$nRetVal = -1, $sDelim = @CRLF)
    local $aReturn,$i_Pid,$h_Process,$i_ExitCode,$sStdOut,$sStdErr,$runTimer
    dim $aReturn[3]

    ; run process with StdErr and StdOut flags
    $runTimer = TimerInit()
    $i_Pid = Run($doscmd, $workingdir, $flag, 6) ; 6 = $STDERR_CHILD+$STDOUT_CHILD

    ; Get process handle
    sleep(100) ; or DllCall may fail - experimental
    $h_Process = DllCall('kernel32.dll','ptr', 'OpenProcess','int', 0x400,'int', 0,'int', $i_Pid)

    ; create tab delimited string containing StdOut text from process
    $aReturn[1] = ""
    $sStdOut = ""
    While 1
        $sStdOut &= StdoutRead($i_Pid)
        If @error Then ExitLoop
    Wend
    $sStdOut = StringReplace($sStdOut,@cr,@tab)
    $sStdOut = StringReplace($sStdOut,@lf,@tab)
    $aStdOut = StringSplit($sStdOut,@tab,1)
    for $i = 1 to $aStdOut[0]
        $aStdOut[$i] = StringStripWS($aStdOut[$i],3)
        if StringLen($aStdOut[$i]) > 0 then
            $aReturn[1] &= $aStdOut[$i] & $sDelim
        EndIf
    Next
    $aReturn[1] = StringTrimRight($aReturn[1],1)

    ; create tab delimited string containing StdErr text from process
    $aReturn[2] = ""
    $sStderr = ""
    While 1
        $sStderr &= StderrRead($i_Pid)
        If @error Then ExitLoop
    Wend
    $sStderr = StringReplace($sStderr,@cr,@tab)
    $sStderr = StringReplace($sStderr,@lf,@tab)
    $aStderr = StringSplit($sStderr,@tab,1)
    for $i = 1 to $aStderr[0]
        $aStderr[$i] = StringStripWS($aStderr[$i],3)
        if StringLen($aStderr[$i]) > 0 then
            $aReturn[2] &= $aStderr[$i] & $sDelim
        EndIf
    Next
    $aReturn[2] = StringTrimRight($aReturn[2],1)

    ; kill the process if it exceeds $timeoutSeconds
    if $timeoutSeconds > 0 Then
        if TimerDiff($runTimer)/1000 > $timeoutSeconds Then
            ProcessClose($i_Pid)
        EndIf
    EndIf

    ; fetch exit code and close process handle
    If IsArray($h_Process) Then
        Sleep(100) ; or DllCall may fail - experimental
        $i_ExitCode = DllCall('kernel32.dll','ptr', 'GetExitCodeProcess','ptr', $h_Process[0],'int*', 0)
        if IsArray($i_ExitCode) Then
            $aReturn[0] = $i_ExitCode[2]
        Else
            $aReturn[0] = -1
        EndIf
        Sleep(100) ; or DllCall may fail - experimental
        DllCall('kernel32.dll','ptr', 'CloseHandle','ptr', $h_Process[0])
    Else
        $aReturn[0] = -2
    EndIf

    ; return single item if correctly specified with with $nRetVal
    If $nRetVal <> -1 And $nRetVal >= 0 And $nRetVal <= 2 Then Return $aReturn[$nRetVal]

    ; return array with exit code, stdout, and stderr
    return $aReturn
EndFunc