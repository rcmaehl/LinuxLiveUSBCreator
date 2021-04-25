; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Graphical Part                                ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; For Drag and Drop
;Global Const $WM_DROPFILES = 0x233
Global $gaDropFiles[1]
Global $ghGDIPdll

Func WM_NCHITTEST($hWnd, $iMsg, $iwParam, $ilParam)
	If ($hWnd = $GUI) And ($iMsg = $WM_NCHITTEST) Then
		Return $HTCAPTION
	EndIf
EndFunc   ;==>WM_NCHITTEST

Func SetBitmap($hGUI, $hImage, $iOpacity)
	Local $hScrDC, $hMemDC, $hBitmap, $hOld, $pSize, $tSize, $pSource, $tSource, $pBlend, $tBlend,$AC_SRC_ALPHA = 1

	$hScrDC = _WinAPI_GetDC(0)
	$hMemDC = _WinAPI_CreateCompatibleDC($hScrDC)
	$hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
	$hOld = _WinAPI_SelectObject($hMemDC, $hBitmap)
	$tSize = DllStructCreate($tagSIZE)
	$pSize = DllStructGetPtr($tSize)
	DllStructSetData($tSize, "X", _GDIPlus_ImageGetWidth($hImage))
	DllStructSetData($tSize, "Y", _GDIPlus_ImageGetHeight($hImage))
	$tSource = DllStructCreate($tagPOINT)
	$pSource = DllStructGetPtr($tSource)
	$tBlend = DllStructCreate($tagBLENDFUNCTION)
	$pBlend = DllStructGetPtr($tBlend)
	DllStructSetData($tBlend, "Alpha", $iOpacity)
	DllStructSetData($tBlend, "Format", $AC_SRC_ALPHA)
	_WinAPI_UpdateLayeredWindow($hGUI, $hScrDC, 0, $pSize, $hMemDC, $pSource, 0, $pBlend, $ULW_ALPHA)
	_WinAPI_ReleaseDC(0, $hScrDC)
	_WinAPI_SelectObject($hMemDC, $hOld)
	_WinAPI_DeleteObject($hBitmap)
	_WinAPI_DeleteDC($hMemDC)
EndFunc   ;==>SetBitmap

;############# EndExample #########

;===============================================================================
;
; Function Name: _WinAPI_SetLayeredWindowAttributes
; Description:: Sets Layered Window Attributes:) See MSDN for more informaion
; Parameter(s):
; $hwnd - Handle of GUI to work on
; $i_transcolor - Transparent color
; $Transparency - Set Transparancy of GUI
; $isColorRef - If True, $i_transcolor is a COLORREF( 0x00bbggrr ), else an RGB-Color
; Requirement(s): Layered Windows
; Return Value(s): Success: 1
; Error: 0
; @error: 1 to 3 - Error from DllCall
; @error: 4 - Function did not succeed - use
; _WinAPI_GetLastErrorMessage or _WinAPI_GetLastError to get more information
; Author(s): Prog@ndy
;
; Link : @@MsdnLink@@ SetLayeredWindowAttributes
; Example : Yes
;===============================================================================
#cs
Func _WinAPI_SetLayeredWindowAttributes($hWnd, $i_transcolor, $Transparency = 255, $dwFlages = 0x03, $isColorRef = False)
	; #############################################
	; You are NOT ALLOWED to remove the following lines
	; Function Name: _WinAPI_SetLayeredWindowAttributes
	; Author(s): Prog@ndy
	; #############################################
	If $dwFlages = Default Or $dwFlages = "" Or $dwFlages < 0 Then $dwFlages = 0x03

	If Not $isColorRef Then
		$i_transcolor = Hex(String($i_transcolor), 6)
		$i_transcolor = Execute('0x00' & StringMid($i_transcolor, 5, 2) & StringMid($i_transcolor, 3, 2) & StringMid($i_transcolor, 1, 2))
	EndIf
	Local $Ret = DllCall("user32.dll", "int", "SetLayeredWindowAttributes", "hwnd", $hWnd, "long", $i_transcolor, "byte", $Transparency, "long", $dwFlages)
	Select
		Case @error
			Return SetError(@error, 0, 0)
		Case $Ret[0] = 0
			Return SetError(4, _WinAPI_GetLastError(), 0)
		Case Else
			Return 1
	EndSelect
EndFunc   ;==>_WinAPI_SetLayeredWindowAttributes

;===============================================================================
;
; Function Name: _WinAPI_GetLayeredWindowAttributes
; Description:: Gets Layered Window Attributes:) See MSDN for more informaion
; Parameter(s):
; $hwnd - Handle of GUI to work on
; $i_transcolor - Returns Transparent color ( dword as 0x00bbggrr or string "0xRRGGBB")
; $Transparency - Returns Transparancy of GUI
; $isColorRef - If True, $i_transcolor will be a COLORREF( 0x00bbggrr ), else an RGB-Color
; Requirement(s): Layered Windows
; Return Value(s): Success: Usage of LWA_ALPHA and LWA_COLORKEY (use BitAnd)
; Error: 0
; @error: 1 to 3 - Error from DllCall
; @error: 4 - Function did not succeed
; - use _WinAPI_GetLastErrorMessage or _WinAPI_GetLastError to get more information
; - @extended contains _WinAPI_GetLastError
; Author(s): Prog@ndy
;
; Link : @@MsdnLink@@ GetLayeredWindowAttributes
; Example : Yes
;===============================================================================
;
Func _WinAPI_GetLayeredWindowAttributes($hWnd, ByRef $i_transcolor, ByRef $Transparency, $asColorRef = False)
	; #############################################
	; You are NOT ALLOWED to remove the following lines
	; Function Name: _WinAPI_SetLayeredWindowAttributes
	; Author(s): Prog@ndy
	; #############################################
	$i_transcolor = -1
	$Transparency = -1
	Local $Ret = DllCall("user32.dll", "int", "GetLayeredWindowAttributes", "hwnd", $hWnd, "long*", $i_transcolor, "byte*", $Transparency, "long*", 0)
	Select
		Case @error
			Return SetError(@error, 0, 0)
		Case $Ret[0] = 0
			Return SetError(4, _WinAPI_GetLastError(), 0)
		Case Else
			If Not $asColorRef Then
				$Ret[2] = Hex(String($Ret[2]), 6)
				$Ret[2] = '0x' & StringMid($Ret[2], 5, 2) & StringMid($Ret[2], 3, 2) & StringMid($Ret[2], 1, 2)
			EndIf
			$i_transcolor = $Ret[2]
			$Transparency = $Ret[3]
			Return $Ret[4]
	EndSelect
EndFunc   ;==>_WinAPI_GetLayeredWindowAttributes
#ce
#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.2.12.0
	Author:         Prog@ndy
	after Script from nobbe ( 2008 in http://www.autoitscript.com/forum/index.php?s=&showtopic=64703&view=findpost&p=485031 )

	Script Function:  A UDF for colored Progressbars with GDIPlus

	Remarks: Theres an example from Line 22 to line 112 ( between the first #Region - #Endregion Tags

#ce ----------------------------------------------------------------------------

Global $_Progress_ahCallBack[3] = [-1, -1, 0], $_Progress_Bars[1][15] = [[-1]], $iPercent = 0;

#EndRegion EXAMPLE
;##################################################

;-------------------------------------------------------------------
#Region Colored Progressbar
;===============================================================================
;
; Function Name:   _ProgressCreate
; Description::    Creates a GDIplus Progressbar
; Parameter(s):    $x     : left
;                  $y     : top
;                  $w     : width
;                  $h     : height
;                  $Col     : [Optional] Top color of the foreground gradient
;                  $GradCol : [Optional] Bottom color of the foreground gradient
;                  $BG      : [Optional] Top color of the background gradient
;                  $GradBG  : [Optional] Bottom color of the background gradient
; Requirement(s):  GDIplus
; Return Value(s): Success: ID of Progressbar, Error: 0
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _ProgressCreate($x, $y, $w = 204, $h = 24, $Col = 0xFFFF00, $GradCol = 0x00FF00, $BG = 0xAAAA00, $GradBG = 0xFF0000)
	;__CheckForGDIPlus()
	$ID = UBound($_Progress_Bars)
	ReDim $_Progress_Bars[$ID + 1][15]
	$_Progress_Bars[$ID][0] = GUICtrlCreateLabel("", $x, $y, $w, $h)
	GUICtrlSetStyle(-1,0)
	GUICtrlSetBkColor($_Progress_Bars[$ID][0], -2) ; $GUI_BKCOLOR_TRANSPARENT = -2
	If @error Then Return SetError(@error, @extended, 0)
	If $Col = -1 Then $Col = 0xFFFF00
	If $BG = -1 Then $BG = 0xAAAA00
	If $GradCol = -1 Then $GradCol = 0x00FF00
	If $GradBG = -1 Then $GradBG = 0xFF0000
	;_GDIPlus_Startup()
	Local $graphic = _GDIPlus_GraphicsCreateFromHWND(GUICtrlGetHandle($_Progress_Bars[$ID][0]))
	Local $bitmap = _GDIPlus_BitmapCreateFromGraphics($w, $h, $graphic)
	Local $backbuffer = _GDIPlus_ImageGetGraphicsContext($bitmap)

	Local $bmpfront = _GDIPlus_BitmapCreateFromGraphics($w, $h, $graphic)
	_CreateGradientImg($bmpfront, $w - 1, $h - 1, $Col, $GradCol)
	$_Progress_Bars[$ID][11] = _GDIPlus_ImageGetWidth($bmpfront)
	$_Progress_Bars[$ID][12] = _GDIPlus_ImageGetHeight($bmpfront)

	Local $bmpBack = _GDIPlus_BitmapCreateFromGraphics($w, $h, $graphic)
	_CreateGradientImg($bmpBack, $w - 1, $h - 1, $BG, $GradBG)
	$_Progress_Bars[$ID][13] = _GDIPlus_ImageGetWidth($bmpBack)
	$_Progress_Bars[$ID][14] = _GDIPlus_ImageGetHeight($bmpBack)

	$_Progress_Bars[$ID][1] = $w
	$_Progress_Bars[$ID][2] = $h

	$_Progress_Bars[$ID][3] = $graphic
	$_Progress_Bars[$ID][4] = $bitmap
	$_Progress_Bars[$ID][5] = $backbuffer
	$_Progress_Bars[$ID][6] = $bmpfront
	$_Progress_Bars[$ID][7] = $bmpBack
	$_Progress_Bars[$ID][8] = 0
	$_Progress_Bars[$ID][9] = 1
	$_Progress_Bars[$ID][10] = "Arial|10|1|0xFF000000|0"
	_ProgressRefresh($ID, 0)
	Return SetError(0, 0, $ID)
EndFunc   ;==>_ProgressCreate

;===============================================================================
;
; Function Name:   _ProgressDelete
; Description::    Deletes a GDI+ Progressbar
; Parameter(s):    $ID      : ID of Progressbar
; Requirement(s):  GDIplus
; Return Value(s): Sucess: 1, Error: 0
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _ProgressDelete(ByRef $ID)
	If Not IsArray($_Progress_Bars) Or UBound($_Progress_Bars, 2) <> 15 Or $ID > (UBound($_Progress_Bars)-1) Then Return SetError(1, 0, 0)
	If $_Progress_Bars[$ID][0] = -1 Then Return SetError(-1,0,0)
	Local $temp[9],$i
	FoR $i = 0 To 8
		$temp[$i] = $_Progress_Bars[$ID][$i]
	Next
	$_Progress_Bars[$ID][0] = -1
	Local $ret = GUICtrlDelete($temp[0])
	If @error Then Return SetError(1,0,0)
	$_Progress_Bars[$ID][1] = -1
	$_Progress_Bars[$ID][2] = -1

	$_Progress_Bars[$ID][3] = -1
	_GDIPlus_GraphicsDispose($temp[3])
	Local $error = @error
	$_Progress_Bars[$ID][4] = -1
	_WinAPI_DeleteObject($temp[4])
	Local $error = @error
	$_Progress_Bars[$ID][5] = -1
	_GDIPlus_GraphicsDispose($temp[5])
	Local $error = @error
	$_Progress_Bars[$ID][6] = -1
	_WinAPI_DeleteObject($temp[6])
	Local $error = @error
	_GDIPlus_ImageDispose($temp[6])
	Local $error = @error
	$_Progress_Bars[$ID][7] = -1
	_WinAPI_DeleteObject($temp[7])
	Local $error = @error
	_GDIPlus_ImageDispose($temp[7])
	$_Progress_Bars[$ID][8] = -1
	;_GDIPlus_Shutdown()
	Return SetError($error, 0, $error=0)
EndFunc   ;==>_ProgressDelete

;===============================================================================
;
; Function Name:   _ProgressSetColors(
; Description::    Sets gradients as foreground and background
; Parameter(s):    $ID      : ID of Progressbar
;                  $Col     : Top color of the foreground gradient
;                  $GradCol : Bottom color of the foreground gradient
;                  $BG      : Top color of the background gradient
;                  $GradBG  : Bottom color of the background gradient
;             If $Col or $GradCol is -1, the foreground gradient isn't changed
;             If $BG or $GradBG is -1, the background gradient isn't changed
; Requirement(s):  Winapi.au3, GDIplus
; Return Value(s): Success: 1, Error: 0
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _ProgressSetColors(ByRef $ID, $Col = -1, $GradCol = -1, $BG = -1, $GradBG = -1)

	If Not IsArray($_Progress_Bars) Or UBound($_Progress_Bars, 2) <> 15 Or $ID > (UBound($_Progress_Bars)-1) Then Return SetError(1, 0, 0)
	If Execute($Col) > -1 And Execute($GradCol) > -1 Then
		_WinAPI_DeleteObject($_Progress_Bars[$ID][6])
		_GDIPlus_ImageDispose($_Progress_Bars[$ID][6])
		$_Progress_Bars[$ID][6] = _GDIPlus_BitmapCreateFromGraphics($_Progress_Bars[$ID][1], $_Progress_Bars[$ID][2], $_Progress_Bars[$ID][3])
		_CreateGradientImg($_Progress_Bars[$ID][6], $_Progress_Bars[$ID][1] - 1, $_Progress_Bars[$ID][2] - 1, $Col, $GradCol)
		$_Progress_Bars[$ID][11] = $_Progress_Bars[$ID][1]
		$_Progress_Bars[$ID][12] = $_Progress_Bars[$ID][2]
	EndIf
	If Execute($BG) > -1 And Execute($GradBG) > -1 Then
		_WinAPI_DeleteObject($_Progress_Bars[$ID][7])
		_GDIPlus_ImageDispose($_Progress_Bars[$ID][7])
		$_Progress_Bars[$ID][7] = _GDIPlus_BitmapCreateFromGraphics($_Progress_Bars[$ID][1], $_Progress_Bars[$ID][2], $_Progress_Bars[$ID][3])
		_CreateGradientImg($_Progress_Bars[$ID][7], $_Progress_Bars[$ID][1] - 1, $_Progress_Bars[$ID][2] - 1, $BG, $GradBG)
		$_Progress_Bars[$ID][13] = $_Progress_Bars[$ID][1]
		$_Progress_Bars[$ID][14] = $_Progress_Bars[$ID][2]
	EndIf
;~ 	_ProgressSet($ID, $_Progress_Bars[$ID][8])

	Return SetError(@error, 0, @error = 0)
EndFunc   ;==>_ProgressSetColors


;===============================================================================
;
; Function Name:   _ProgressSetImages(
; Description::    Sets images as foreground and background by Path
; Parameter(s):    $ID : ID of Progressbar
;                  $ForeBmp : Path to image , empty String "" To leave the old
;                             The foreground image
;                  $BackBmp : [Optional] Path to image , empty String "" To leave the old
;                             The background image
; Requirement(s):  Winapi.au3, GDIplus
; Return Value(s): Success: 1, Error: 0
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _ProgressSetImages(ByRef $ID, $ForeBmp = "", $backBMP = "")
	Local $bmp = ""
	If Not IsArray($_Progress_Bars) Or UBound($_Progress_Bars, 2) <> 15 Or $ID > (UBound($_Progress_Bars)-1) Then Return SetError(1, 0, 0)
	If GUICtrlGetHandle($_Progress_Bars[$ID][0]) = 0 Then Return SetError(2, 0, 0)
	If $ForeBmp <> "" And FileExists($ForeBmp) Then
		If @Compiled Then
			$bmp = _Resource_GetAsImage(StringReplace($ForeBmp, ".jpg", ""), "RT_RCDATA")
		Else
			$bmp = _GDIPlus_ImageLoadFromFile("..\..\tools\img\" & $ForeBmp)
		EndIf
		If Not @error Then
;~ 			_WinAPI_DeleteObject($_Progress_Bars[$ID][6])
			_GDIPlus_ImageDispose($_Progress_Bars[$ID][6])
			$_Progress_Bars[$ID][6] = $bmp
			$_Progress_Bars[$ID][11] = _GDIPlus_ImageGetWidth($_Progress_Bars[$ID][6])
			$_Progress_Bars[$ID][12] = _GDIPlus_ImageGetHeight($_Progress_Bars[$ID][6])
		EndIf
	EndIf
	If $backBMP <> "" And FileExists($backBMP) Then
		If @Compiled Then
			$bmp = _Resource_GetAsImage(StringReplace($backBMP, ".jpg", ""), "RT_RCDATA")
		Else
			$bmp = _GDIPlus_ImageLoadFromFile("..\..\tools\img\" & $backBMP)
		EndIf
		If Not @error Then
;~ 			_WinAPI_DeleteObject($_Progress_Bars[$ID][7])
			_GDIPlus_ImageDispose($_Progress_Bars[$ID][7])
			$_Progress_Bars[$ID][7] = $bmp
			$_Progress_Bars[$ID][13] = _GDIPlus_ImageGetWidth($_Progress_Bars[$ID][7])
			$_Progress_Bars[$ID][14] = _GDIPlus_ImageGetHeight($_Progress_Bars[$ID][7])
		EndIf
	EndIf
;~ 	_ProgressSet($ID, $_Progress_Bars[$ID][8])
	Return SetError(@error, 0, @error = 0)
EndFunc   ;==>_ProgressSetImages

;===============================================================================
;
; Function Name:   _ProgressSetHBitmaps(
; Description::    Sets previously loaded GDIplus Images / bitmaps as foreground and background
; Parameter(s):    $ID : ID of Progressbar
;                  $ForeBmp : Handle to GDIplus -image or -bitmap , -1 To leave the old
;                             The foreground image
;                  $BackBmp : [Optional] Handle to GDIplus -image or -bitmap , -1 To leave the old
;                             The background image
; Requirement(s):  Winapi.au3, GDIplus
; Return Value(s): Success: 1, Error: 0
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _ProgressSetHBitmaps(ByRef $ID, $ForeBmp = -1, $backBMP = -1)
	If Not IsArray($_Progress_Bars) Or UBound($_Progress_Bars, 2) <> 15 Or $ID > (UBound($_Progress_Bars)-1) Then Return SetError(1, 0, 0)
	If GUICtrlGetHandle($_Progress_Bars[$ID][0]) = 0 Then Return SetError(2, 0, 0)
	If $ForeBmp > -1 And _GDIPlus_ImageGetHeight($ForeBmp) Then
;~ 		_WinAPI_DeleteObject($_Progress_Bars[$ID][6])
		_GDIPlus_ImageDispose($_Progress_Bars[$ID][6])
		$_Progress_Bars[$ID][6] = $ForeBmp
		$_Progress_Bars[$ID][11] = _GDIPlus_ImageGetWidth($_Progress_Bars[$ID][6])
		$_Progress_Bars[$ID][12] = _GDIPlus_ImageGetHeight($_Progress_Bars[$ID][6])
	EndIf
	If $backBMP > -1 And _GDIPlus_ImageGetHeight($backBMP) Then
;~ 		_WinAPI_DeleteObject($_Progress_Bars[$ID][7])
		_GDIPlus_ImageDispose($_Progress_Bars[$ID][7])
		$_Progress_Bars[$ID][7] = $backBMP
		$_Progress_Bars[$ID][13] = _GDIPlus_ImageGetWidth($_Progress_Bars[$ID][7])
		$_Progress_Bars[$ID][14] = _GDIPlus_ImageGetHeight($_Progress_Bars[$ID][7])
	EndIf
;~ 	_ProgressSet($ID, $_Progress_Bars[$ID][8])
	Return SetError(@error, 0, @error = 0)
EndFunc   ;==>_ProgressSetHBitmaps

;===============================================================================
;
; Function Name:   _ProgressSetText(
; Description::    Sets the text to be shown
; Parameter(s):    $ID : ID of Progressbar
;                  $text:  -> TRUE : Show percent
;                          -> A string to be shown, %P% is replaced with Percentage
; Requirement(s):  This UDf
; Return Value(s): Success: 1, Error: 0
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _ProgressSetText(ByRef $ID, $text = True)
	If Not IsArray($_Progress_Bars) Or UBound($_Progress_Bars, 2) <> 15 Or $ID > (UBound($_Progress_Bars)-1) Then Return SetError(1, 0, 0)
	$_Progress_Bars[$ID][9] = $text
;~ 	_ProgressSet($ID, $_Progress_Bars[$ID][8])
	Return SetError(@error, 0, @error = 0)
EndFunc   ;==>_ProgressSetText

;===============================================================================
;
; Function Name:   _ProgressSetFont()
; Description::    Sets the Font and Color of the Text of the Progressbar
; Parameter(s):    $ID : ID of Progressbar
;                  $Font      : Name of the font (empty String "" to do not change)
;                  $size      : [Optional] size of the font ( 0 or negative to leave the old)
;                  $Styles    : [Optional] The style of the typeface. Can be a combination of the following:
;                                  0 - Normal weight or thickness of the typeface
;                                  1 - Bold typeface
;                                  2 - Italic typeface
;                                  4 - Underline
;                                  8 - Strikethrough
;                                  ( -1, negative to leave the old)
;                  $ARGBcolor : [Optional] the color of the font, can be RGB or ARGB (depending on  $isARGB)
;                                  (empty String "" to do not change)
;                  $InverseColor: [Optional] should the color be inversed when the bar is under the text?
;                  $isARGB    : [Optional] Sets, whether $ARGBcolor is RGB (False, default) or ARGB (True)
; Requirement(s):  This UDF
; Return Value(s): Success: 1, Error: 0
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _ProgressSetFont(ByRef $ID, $Font, $size = Default, $Styles = Default, $ARGBcolor = Default, $InverseColor=-1, $isARGB = False)
	If Not IsArray($_Progress_Bars) Or UBound($_Progress_Bars, 2) <> 15 Or $ID > (UBound($_Progress_Bars)-1) Then Return SetError(1, 0, 0)
	Local $array = StringSplit($_Progress_Bars[$ID][10], "|")
	If $Font <> "" And IsString($Font) And $Font <> Default Then $array[1] = $Font
	$size = Number($size)
	If $size > 0 And $size <> Default Then $array[2] = $size
	$Styles = Number($Styles)
	If $Styles > -1 And $Styles <> Default Then $array[3] = BitAND($Styles, 15)
	If Not $isARGB Then $ARGBcolor = "0xFF" & Hex($ARGBcolor, 6)
	If Not ($ARGBcolor == "") And Not ($ARGBcolor == Default) Then $array[4] = "0x" & Hex($ARGBcolor, 8)
	If $InverseColor > 0 Then $array[5] = "1"
	If $InverseColor = 0 Then $array[5] = "0"
	$_Progress_Bars[$ID][10] = $array[1] & "|" & $array[2] & "|" & $array[3] & "|" & $array[4] & "|" & $array[5]
;~ 	_ProgressSet($ID, $_Progress_Bars[$ID][8])
	Return SetError(@error, 0, @error = 0)
EndFunc   ;==>_ProgressSetFont

;===============================================================================
;
; Function Name:   _ProgressSet()
; Description::    Sets the percentage of the Progressbar
; Parameter(s):    $ID : ID of Progressbar
;                  $prc The percentage to set
; Requirement(s):  This UDF :)
; Return Value(s): If Progressbar odes not Exist: @error is set to 1
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _ProgressSet(ByRef $ID, $prc)
	If Not IsArray($_Progress_Bars) Or UBound($_Progress_Bars, 2) <> 15 Or $ID > (UBound($_Progress_Bars)-1) Then Return SetError(1, 0, 0)
	If $prc > 100 Then $prc = 100
	If $prc < 0 Then $prc = 0
	$_Progress_Bars[$ID][8] = $prc
	Return 1
EndFunc   ;==>_ProgressSet

Func _ProgressGet(ByRef $ID)
	If Not IsArray($_Progress_Bars) Or UBound($_Progress_Bars, 2) <> 15 Or $ID > (UBound($_Progress_Bars)-1) Then Return SetError(1, 0, 0)
	Return _WinAPI_LoWord($_Progress_Bars[$ID][8])
EndFunc
;===============================================================================
;
; Function Name:   _ProgressMarquee()
; Description::    Sets the
; Parameter(s):    $ID : ID of Progressbar
;                  $speed : The speed of the Marquee: 1 to 10, smaller as 1 turns it off
;                  $makeSmallFront : Crop the Front image to 1/10 of its former width
;                         If it was created by _ProgressSetColors, this is 1/10 of Progress Width :)
;                         If this is set to -1 and $speed is set to < 0 then the Front image size is
;                             set to the width of the Progressbar
; Requirement(s):  WinAPI
; Return Value(s): If Progressbar does not Exist: @error is set to 1
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _ProgressMarquee(ByRef $ID, $speed = 2, $makeSmallFront = 1)
	If Not IsArray($_Progress_Bars) Or UBound($_Progress_Bars, 2) <> 15 Or $ID > (UBound($_Progress_Bars)-1) Then Return SetError(1, 0, 0)
	If $speed < 0 Then
		$_Progress_Bars[$ID][8] = _WinAPI_LoWord($_Progress_Bars[$ID][8])
		If $makeSmallFront = -1 Then $_Progress_Bars[$ID][11] = $_Progress_Bars[$ID][1]
		Return 1
	EndIf
	If $speed > 10 Then $speed = 10
	If $speed < 1 Then $speed = 1
	$_Progress_Bars[$ID][8] = _WinAPI_MakeLong(_WinAPI_LoWord($_Progress_Bars[$ID][8]), Number($speed))
	If $makeSmallFront Then $_Progress_Bars[$ID][11] = Int($_Progress_Bars[$ID][11] / 10)
	Return 1
EndFunc   ;==>_ProgressMarquee

; Author(s):       Prog@ndy
Func _ProgressRefresh(ByRef $ID, $prc = Default)
	If Not IsArray($_Progress_Bars) Or UBound($_Progress_Bars, 2) <> 15 Or $ID > (UBound($_Progress_Bars)-1) Then Return SetError(1, 0, 0)
	If $_Progress_Bars[$ID][1] < 1 Then Return SetError(2, 0, 0)
	Local $bar_height = $_Progress_Bars[$ID][2]
	Local $bar_width = $_Progress_Bars[$ID][1]
	If $prc = Default Then $prc = $_Progress_Bars[$ID][8]
	If $_Progress_Bars[$ID][8] > 65535 Then Return _ProgressRefreshMarquee($ID)
	If $prc > 100 Then $prc = 100
	If $prc < 0 Then $prc = 0
	$_Progress_Bars[$ID][8] = $prc
;~     $iPercent = $prc
;~ ConsoleWrite($iPercent & @CRLF)
;~     GUICtrlSetData($Status_Label, $prc & "%")
	Local $position_in_bar = Int(($bar_width) / 100 * $prc) ;; or we move out the bar
	If $prc = 0 Then $position_in_bar = 0
	_GDIPlus_GraphicsClear($_Progress_Bars[$ID][5], 0xFFFFFFFF)

;~ 		; draw grey bar to right side
;~ 	_GDIPlus_GraphicsDrawImageRectRect($_Progress_Bars[$ID][5], $_Progress_Bars[$ID][7], Int(($_Progress_Bars[$ID][13] / 100) * $prc), 0, Int(($_Progress_Bars[$ID][13] / 100) * (100 - $prc)), $_Progress_Bars[$ID][14], _
;~ 			$position_in_bar , _
;~ 			0, _
;~ 			$bar_width - ($position_in_bar ), _
;~ 			$bar_height);
;~
		; draw grey bar to right side
	_GDIPlus_GraphicsDrawImageRectRect($_Progress_Bars[$ID][5], $_Progress_Bars[$ID][7], 0 , 0, $_Progress_Bars[$ID][13] , $_Progress_Bars[$ID][14], _
			0 , _
			0, _
			$bar_width , _
			$bar_height);

	;; draw blue bar from left
	If $position_in_bar > 0 Then _GDIPlus_GraphicsDrawImageRectRect($_Progress_Bars[$ID][5], $_Progress_Bars[$ID][6], _
			0, 0, Int(($_Progress_Bars[$ID][11] / 100) * $prc), $_Progress_Bars[$ID][12], _
			0, _
			0, _
			$position_in_bar, _
			$bar_height)


	If Not IsString($_Progress_Bars[$ID][9]) And $_Progress_Bars[$ID][9] = True Then
		_DrawStringCenter($_Progress_Bars[$ID][5], $prc & "%", $bar_width, $bar_height, $_Progress_Bars[$ID][10])
		If $position_in_bar Then _DrawStringCenter($_Progress_Bars[$ID][5], $prc & "%", $bar_width, $bar_height, $_Progress_Bars[$ID][10], $position_in_bar)
	ElseIf StringLen($_Progress_Bars[$ID][9]) > 0 Then
		_DrawStringCenter($_Progress_Bars[$ID][5], StringReplace($_Progress_Bars[$ID][9], "%P%", $prc), $bar_width, $bar_height, $_Progress_Bars[$ID][10])
		If $position_in_bar Then _DrawStringCenter($_Progress_Bars[$ID][5], StringReplace($_Progress_Bars[$ID][9], "%P%", $prc), $bar_width, $bar_height, $_Progress_Bars[$ID][10], $position_in_bar)
	EndIf
;~ 	_GDIPlus_GraphicsDrawString($_Progress_Bars[$ID][5],$prc & " %",Ceiling(($bar_width/2)-15),Ceiling(($bar_height/2)-5))
	_GDIPlus_GraphicsDrawImage($_Progress_Bars[$ID][3], $_Progress_Bars[$ID][4], 0, 0)
	GUIRegisterMsg($WM_PAINT, "DrawAll")
	ControlFocus("LinuxLive USB Creator", "", $REFRESH_AREA)
EndFunc   ;==>_ProgressRefresh

; Author(s):       Prog@ndy
Func _ProgressRefreshMarquee(ByRef $ID, $prc = Default)
	If Not IsArray($_Progress_Bars) Or UBound($_Progress_Bars, 2) <> 15 Or $ID > (UBound($_Progress_Bars)-1) Then Return SetError(1, 0, 0)
	If $_Progress_Bars[$ID][1] < 1 Then Return SetError(2, 0, 0)
	Local $bar_height = $_Progress_Bars[$ID][2]
	Local $bar_width = $_Progress_Bars[$ID][1]
	If $prc = Default Then $prc = _WinAPI_LoWord($_Progress_Bars[$ID][8])
	If $prc > 100 Then $prc = 0
	If $prc < 0 Then $prc = 0
	$_Progress_Bars[$ID][8] = _WinAPI_MakeLong($prc + _WinAPI_HiWord($_Progress_Bars[$ID][8]), _WinAPI_HiWord($_Progress_Bars[$ID][8]))
;~     $iPercent = $prc
;~ ConsoleWrite($iPercent & @CRLF)
;~     GUICtrlSetData($Status_Label, $prc & "%")
	Local $position_in_bar = Int(($bar_width + ($bar_height / $_Progress_Bars[$ID][12] * $_Progress_Bars[$ID][11])) / 100 * $prc) ;; or we move out the bar
	If $prc = 0 Then $position_in_bar = 0
	_GDIPlus_GraphicsClear($_Progress_Bars[$ID][5], 0xFFFFFFFF)
	; draw grey bar to right side
	_GDIPlus_GraphicsDrawImageRectRect($_Progress_Bars[$ID][5], $_Progress_Bars[$ID][7], 0, 0, $_Progress_Bars[$ID][13], $_Progress_Bars[$ID][14], _
			0, _
			0, _
			$bar_width, _
			$bar_height);
	;; draw blue bar from left
	If $position_in_bar > 0 Then _GDIPlus_GraphicsDrawImageRectRect($_Progress_Bars[$ID][5], $_Progress_Bars[$ID][6], _
			0, 0, $_Progress_Bars[$ID][11], $_Progress_Bars[$ID][12], _
			$position_in_bar - ($bar_height / $_Progress_Bars[$ID][12] * $_Progress_Bars[$ID][11]), _
			0, _
			$bar_height / $_Progress_Bars[$ID][12] * $_Progress_Bars[$ID][11], _
			$bar_height)
	If (Not IsString($_Progress_Bars[$ID][9])) And $_Progress_Bars[$ID][9] = True Then
		_DrawStringCenter($_Progress_Bars[$ID][5], StringReplace("	     	", " ", ".", Mod(@SEC, 5) + 1), $bar_width, $bar_height, $_Progress_Bars[$ID][10])
	ElseIf StringLen($_Progress_Bars[$ID][9]) > 0 Then
		_DrawStringCenter($_Progress_Bars[$ID][5], StringReplace($_Progress_Bars[$ID][9], "%P%", StringReplace("	     	", " ", ".", Mod(@SEC, 5) + 1)), $bar_width, $bar_height, $_Progress_Bars[$ID][10])
	EndIf
;~ 	_GDIPlus_GraphicsDrawString($_Progress_Bars[$ID][5],$prc & " %",Ceiling(($bar_width/2)-15),Ceiling(($bar_height/2)-5))
	_GDIPlus_GraphicsDrawImage($_Progress_Bars[$ID][3], $_Progress_Bars[$ID][4], 0, 0)
EndFunc   ;==>_ProgressRefreshMarquee


; Author(s):       Prog@ndy
Func _DrawStringCenter(ByRef $hGraphic, $sString, $bar_width, $bar_height, $FontFormat = "Arial|12|1|0xFF000000|0", $InverseStart = -1)
	$FontFormat = StringSplit($FontFormat, "|")
	If $InverseStart>-1 And $FontFormat[5]=1 Then
		DLLCall($ghGDIPdll, "int", "GdipSetClipRectI", "ptr", $hGraphic, "int", 0, "int", 0, "int", $InverseStart, "int", $bar_height, "int", 0)
		$FontFormat[4]= BitOr(0xFF000000,_InverseColor($FontFormat[4]))
	EndIf
	Local $hBrush = _GDIPlus_BrushCreateSolid($FontFormat[4])
	Local $hFormat = _GDIPlus_StringFormatCreate(0x0400)
	Local $hFamily = _GDIPlus_FontFamilyCreate($FontFormat[1])
	Local $hFont = _GDIPlus_FontCreate($hFamily, $FontFormat[2], $FontFormat[3])
	Local $tLayout = _GDIPlus_RectFCreate(0, 0, 0, 0)
	Local $aInfo = _GDIPlus_GraphicsMeasureString($hGraphic, $sString, $hFont, $tLayout, $hFormat)
	DllStructSetData($aInfo[0], "X", Int(($bar_width - DllStructGetData($aInfo[0], "Width")) / 2))
	DllStructSetData($aInfo[0], "Y", Int(($bar_height - DllStructGetData($aInfo[0], "Height")) / 2))
	_GDIPlus_GraphicsDrawStringEx($hGraphic, $sString, $hFont, $aInfo[0], $hFormat, $hBrush)
	If $InverseStart>-1 And $FontFormat[5]=1 Then DLLCall($ghGDIPdll, "int", "GdipSetClipRectI", "ptr", $hGraphic, "int", 0, "int", 0, "int", $bar_width, "int", $bar_height, "int", 0)
	_GDIPlus_FontDispose($hFont)
	_GDIPlus_FontFamilyDispose($hFamily)
	_GDIPlus_StringFormatDispose($hFormat)
	_GDIPlus_BrushDispose($hBrush)
EndFunc   ;==>_DrawStringCenter

; Modified _Max() Function, directly included
; Author(s):       Jeremy Landes <jlandes at landeserve dot com>
Func _MyMax($nNum1, $nNum2)

	If Number($nNum1) > Number($nNum2) Then
		Return Number($nNum1)
	Else
		Return Number($nNum2)
	EndIf
EndFunc   ;==>_MyMax

#EndRegion Colored Progressbar
;-------------------------------------------------------------------

;-------------------------------------------------------------------
#Region Gradient
;===============================================================================
;
; Function Name:   _Gradient($RGB_Color1 ,$RGB_Color2, $Count)
; Description::    Returns an Array of Gradient Colors
; Parameter(s):    $RGB_Color1 : The Start-Color in RGB Hexadecimal
;                  $RGB_Color2 : The End-Color in RGB Hexadecimal
;                  $Count :      The number of Colors in the Gradient
; Requirement(s):
; Return Value(s): An Array with the Colors
; Author(s):       Prog@ndy
;
;===============================================================================
;

Func _Gradient($RGB_Color1, $RGB_Color2, $Count, $ARGB = False)
	Local $Color1_R, $Color1_G, $Color1_B, $Color2_R, $Color2_G, $Color2_B, $NeuCol_R, $NeuCol_G, $NeuCol_B
	$ARGB = StringLeft("FF", 2 * $ARGB)
	$Color1_R = BitAND(BitShift($RGB_Color1, 16), 0xff)
	$Color1_G = BitAND(BitShift($RGB_Color1, 8), 0xff)
	$Color1_B = BitAND($RGB_Color1, 0xff)

	$Color2_R = BitAND(BitShift($RGB_Color2, 16), 0xff)
	$Color2_G = BitAND(BitShift($RGB_Color2, 8), 0xff)
	$Color2_B = BitAND($RGB_Color2, 0xff)

	$Count -= 1 ; 0-basiert !
	Dim $arColors[$Count + 1], $pos1

	For $i = 0 To $Count
		$pos1 = $Count - $i
		$NeuCol_R = ($Color1_R * $pos1 + $Color2_R * $i) / ($Count)
		$NeuCol_G = ($Color1_G * $pos1 + $Color2_G * $i) / ($Count)
		$NeuCol_B = ($Color1_B * $pos1 + $Color2_B * $i) / ($Count)
		$arColors[$i] = Execute('0x' & $ARGB & Hex($NeuCol_R, 2) & Hex($NeuCol_G, 2) & Hex($NeuCol_B, 2))
	Next
	Return $arColors
EndFunc   ;==>_Gradient


;Hilfsfunktion für doppelten Verlauf
; Author(s):       Prog@ndy
Func _ZwischenGrad($RGB_c, $ARGB = False)
	Local $c_R = BitAND(BitShift($RGB_c, 16), 0xff)
	Local $c_G = BitAND(BitShift($RGB_c, 8), 0xff)
	Local $c_B = BitAND($RGB_c, 0xff)
	$c_R = _MyMax(0, $c_R - 99)
	$c_G = _MyMax(0, $c_G - 99)
	$c_B = _MyMax(0, $c_B - 99)
	If $ARGB Then Return Dec("FF" & Hex($c_R, 2) & Hex($c_G, 2) & Hex($c_B, 2))
	Return Dec(Hex($c_R, 2) & Hex($c_G, 2) & Hex($c_B, 2))
EndFunc   ;==>_ZwischenGrad

; Author(s):       Prog@ndy
Func _CreateGradientImg(ByRef $bmpfront, $w, $h, $startRGB, $endRGB)
	Local $graph_front = _GDIPlus_ImageGetGraphicsContext($bmpfront)
	Local $hPen = _GDIPlus_PenCreate(0, 1)
	Local $Wechsel = Round((9 / 20) * $h)
	Local $temp = _Gradient($startRGB, $endRGB, 3)
	$temp = _ZwischenGrad($temp[1], 0)
	Local $Gradient = _Gradient($startRGB, $temp, $Wechsel, 1)
	Local $Gradient2 = _Gradient($temp, $endRGB, $h - $Wechsel, 1)
	Local $PenColor
	For $i = 0 To $h - 1
		If $i < $Wechsel Then
			$PenColor = $Gradient[$i]
		Else
			$PenColor = $Gradient2[$i - $Wechsel]
		EndIf
		_GDIPlus_PenSetColor($hPen, $PenColor)
		_GDIPlus_GraphicsDrawLine($graph_front, 0, $i, $w, $i, $hPen)
	Next
	_GDIPlus_PenSetColor($hPen, 0xFF666666)
	_GDIPlus_GraphicsDrawRect($graph_front, 0, 0, $w, $h, $hPen)
	_GDIPlus_PenDispose($hPen)
	_GDIPlus_GraphicsDispose($graph_front)
EndFunc   ;==>_CreateGradientImg

#EndRegion Gradient
;-------------------------------------------------------------------

;-------------------------------------------------------------------
#Region Internal

Func _Paint_Bars_Procedure2()
	AdlibUnRegister("Control_Hover")
	For $i = 1 To UBound($_Progress_Bars) - 1
		If Not ($_Progress_Bars[$i][0] = -1) Then _ProgressRefresh($i)
	Next
	AdlibRegister("Control_Hover", 150)
EndFunc   ;==>_Paint_Bars_Procedure


;~ Func _DebugPrint($s_text)
;~ 	$s_text = StringReplace($s_text, @LF, @LF & "-")
;~ 	ConsoleWrite($s_text & @LF); & _
;~ EndFunc   ;==>_DebugPrint

Func __CheckForGDIPlus($Fatal = True)
	Local $x = DllOpen("GDIPlus.dll")
	Local $ret = DllCall("Kernel32.dll", "dword", "GetModuleHandle", "str", "GDIPlus")
	DllClose($x)
	If $ret[0] = 0 And $Fatal Then _WinAPI_FatalAppExit("GDIplus not found. Please install GDIplus to use this application")
	Return ($ret[0] = 0)
EndFunc   ;==>__CheckForGDIPlus

#EndRegion Internal
;-------------------------------------------------------------------

Func _InverseColor($Col)
	$Col = Number($Col)
	Local $a = BitAND($Col,0xFF)
	Local $b = BitAND(BitShift($Col,8),0xFF)
	Local $c = BitAND(BitShift($Col,16),0xFF)
	Return BitOR(BitShift(255-$c,-16), BitShift(255-$b,-8), 255-$a)
EndFunc
