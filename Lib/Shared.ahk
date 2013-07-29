MCRC=AFE99C63
MVersion=1.0.9

StartModule(){
	Global gameSectionStartTime,gameSectionStartHour,dbName,romPath,romName,romExtension,systemName,MEmu,MEmuV,MURL,MAuthor,MVersion,MCRC,iCRC,MSystem,romMapTable,romMappingLaunchMenuEnabled,romMenuRomName,7zEnabled
	Log("StartModule - Started")
	Log("StartModule - MEmu: " . MEmu . "`r`n`t`t`t`t`tMEmuV: " . MEmuV . "`r`n`t`t`t`t`tMURL: " . MURL . "`r`n`t`t`t`t`tMAuthor: " . MAuthor . "`r`n`t`t`t`t`tMVersion: " . MVersion . "`r`n`t`t`t`t`tMCRC: " . MCRC . "`r`n`t`t`t`t`tiCRC: " . iCRC . "`r`n`t`t`t`t`tMID: " . MID . "`r`n`t`t`t`t`tMSystem: " . MSystem)
	If InStr(MSystem,systemName)
		Log("StartModule - You have a supported System Name for this module: """ . systemName . """")
	Else
		Log("StartModule - You have an unsupported System Name for this module: """ . systemName . """. Only the following System Names are suppported: """ . MSystem . """",2)
	If (romMappingLaunchMenuEnabled = "true" && romMapTable.MaxIndex()) ; && romMapMultiRomsFound)
		CreateRomMappingLaunchMenu(romMapTable)
	If (skipChecks != "false" && romMenuRomName && 7zEnabled = "false")	; this is to support the scenario where Rom Map Launch Menu can send a rom that does not exist on disk or in archive (mame clones)
	{	Log("StartModule - Setting romName to the game picked from the Launch Menu: " . romMenuRomName,4)
		romName := romMenuRomName
	} Else If romName
	{	Log("StartModule - Leaving romName as is because Rom Mapping filled it with an Alternate_Rom_Name: " . romName,4)
		romName := romName	; When Rom Mapping is used but no Alternate_Archive_Name key exists yet Alternate_Rom_Name key(s) were used.
	} Else If romMapTable.MaxIndex()
	{	Log("StartModule - Not setting romName because Launch Menu was used and 7z will take care of it.",4)
		romName := 	; If a romMapTable exists with roms, do not fill romName yet as 7z will take care of that.
	} Else
	{	Log("StartModule - Setting romName to the dbName sent to HyperLaunch: " . romMenuRomName,4)
		romName := dbName	; Use dbName if previous checks are false
	}
	; romName := If romName ? romName : If romMapTable.MaxIndex() ? "" : dbName	; OLD METHOD, keeping this here until the split apart conditionals have been tested enough. ; if romName was filled at some point, use it, else if a romMapTable exists with roms, do not fill romName yet as 7z will take care of that. Use dbName if previous checks are false
	gameSectionStartTime := A_TickCount
	gameSectionStartHour := A_Now
	; msgbox % "romPath: " . romPath . "`nromName: " . romName . "`nromExtension: " . romExtension . "`nromMenuRomName: " . romMenuRomName . "`nromMapTable.MaxIndex(): " . romMapTable.MaxIndex()
	Log("StartModule - Ended")
}

; ExitModule function in case we need to call anything on the module's exit routine, like UpdateStatistics for HyperPause or UnloadKeymapper
ExitModule(){
	Global statisticsEnabled,keymapperEnabled,keymapper,logShowCommandWindow,zz
	Log("ExitModule - Started")
	If statisticsEnabled = true
		Gosub, UpdateStatistics
	If keymapperEnabled = true
		RunKeyMapper%zz%("unload",keymapper)
	If logShowCommandWindow = true
		Process("Close", "cmd.exe")
	Log("ExitModule - Ended")
	Log("End of Module Logs",,,1)
	ExitApp
}

WinWait(winTitle,winText="",secondsToWait=30,excludeTitle="",excludeText=""){
	Global detectFadeErrorEnabled, logLevel
	If logLevel > 3
		GetActiveWindowStatus()
	Log("Module WinWait - Waiting for " . winTitle)
	WinWait, %winTitle% ,%winText% , %secondsToWait% , %excludeTitle% ,%excludeText%
	curErr := ErrorLevel	; have to store this because GetActiveWindowStatus will reset it
	If logLevel > 3
		GetActiveWindowStatus()
	If (curErr and detectFadeErrorEnabled = "true")
		ScriptError("There was an error waiting for the window """ . winTitle . """. Please check you have the correct version emulator installed for this module, followed any notes in the module, and have this emulator working outside your Frontend first. Also turn off Fade to see if you are hiding your problem.",10)
	Else If (curErr and detectFadeErrorEnabled != "true")
		Log("There was an error waiting for the window """ . winTitle . """. Please check you have the correct version emulator installed for this module, followed any notes in the module, and have this emulator working outside your Frontend first. Also turn off Fade to see if you are hiding your problem.",3)
	Return curErr
}

WinWaitActive(winTitle,winText="",secondsToWait=30,excludeTitle="",excludeText=""){
	Global detectFadeErrorEnabled, logLevel
	If logLevel > 3
		GetActiveWindowStatus()
	Log("Module WinWaitActive - Waiting for """ . winTitle . """")
	WinWaitActive, %winTitle% ,%winText% , %secondsToWait% , %excludeTitle% ,%excludeText%
	curErr := ErrorLevel	; have to store this because GetActiveWindowStatus will reset it
	If logLevel > 3
		GetActiveWindowStatus()
	If (curErr and detectFadeErrorEnabled = "true")
		ScriptError("There was an error waiting for the window """ . winTitle . """ to become active. Please check you have the correct version emulator installed for this module, followed any notes in the module, and have this emulator working outside your Frontend first. Also turn off Fade to see if you are hiding your problem.",10)
	Else If (curErr and detectFadeErrorEnabled != "true")
		Log("There was an error waiting for the window """ . winTitle . """ to become active. Please check you have the correct version emulator installed for this module, followed any notes in the module, and have this emulator working outside your Frontend first. Also turn off Fade to see if you are hiding your problem.",3)
	Return curErr
}

WinWaitClose(winTitle,winText="",secondsToWait="",excludeTitle="",excludeText=""){
	Log("Module WinWaitClose - Waiting for """ . winTitle . """ to close")
	WinWaitClose, %winTitle% ,%winText% , %secondsToWait% , %excludeTitle% ,%excludeText%
	Return ErrorLevel
}

WinClose(winTitle,winText="",secondsToWait="",excludeTitle="",excludeText=""){
	Log("Module WinClose - Closing: " . winTitle)
	WinClose, %winTitle%, %winText% , %secondsToWait%, %excludeTitle%, %excludeText%
	If (secondsToWait = "" || !secondsToWait)
		secondsToWait := 2	; need to always have some timeout for this command otherwise it will wait forever
	WinWaitClose, %winTitle%, %winText% , %secondsToWait%, %excludeTitle%, %excludeText%	; only WinWaitClose reports an ErrorLevel
	Return ErrorLevel
}

Run(target,workingDir="",useErrorLevel="",ByRef outputVarPID=""){
	Global logShowCommandWindow,logCommandWindow
	Log("Module Run - Running: " . workingDir . "\" . target)
	If logShowCommandWindow = true
	{	Run, %ComSpec% /k , %workingDir% ,,outputVarPID
		curErr := ErrorLevel
		Log("Module Run - Showing Command Window to troubleshoot launching. ProcessID: " . outputVarPID)
		WinWait, ahk_pid %outputVarPID%
		WinActivate, ahk_pid %outputVarPID%
		WinWaitActive, ahk_pid %outputVarPID%,,2
		If ErrorLevel {
			WinSet, AlwaysOnTop, On, ahk_pid %outputVarPID%
			WinActivate, ahk_pid %outputVarPID%
			WinWaitActive, ahk_pid %outputVarPID%,,2
			If ErrorLevel
				ScriptError("Could not put focus onto the command window. Please try turning off Fade In if you have it enabled in order to see it")
		}
		If logCommandWindow = true
			SendInput, {Raw}%target% 1>"%A_ScriptDir%\command_output.log" 2>"%A_ScriptDir%\command_error.log"	; send the text to the command window and log the output to file
		Else
			SendInput, {Raw}%target%	; send the text to the command window and run it
		Send, {Enter}
	} Else {
		Run, %target%, %workingDir%, %useErrorLevel%, outputVarPID
		curErr := ErrorLevel
	}
	Log("Module Run - """ . target . """ Process ID: " . outputVarPID, 4)
	Return curErr
}

Process(cmd,name,param=""){
	Log("Module Process - " . cmd . A_Space . name . A_Space . param)
	Process, %cmd%, %name%, %param%
	Return ErrorLevel
}

GetActiveWindowStatus(){
	dWin := A_DetectHiddenWindows	; store current value to return later
	DetectHiddenWindows, On
	activeWinHWND := WinExist("A")
	WinGet, procPath, ProcessPath, ahk_id %activeWinHWND%
	WinGet, procID, PID, ahk_id %activeWinHWND%
	WinGet, winState, MinMax, ahk_id %activeWinHWND%
	WinGetClass, winClass, ahk_id %activeWinHWND%
	WinGetTitle, winTitle, ahk_id %activeWinHWND%
	WinGetPos, X, Y, W, H, ahk_id %activeWinHWND%
	Log("GetActiveWindowStatus - Title: " . winTitle . " | Class: " . winClass . " | State: " . winState . " | X: " . X . " | Y: " . Y . " | Width: " . W . " | Height: " . H . " | Window HWND: " . activeWinHWND . " | Process ID: " . procID . " | Process Path: " . procPath, 4)
	DetectHiddenWindows, %dWin%	; restore prior state
}

; CheckFile Usage:
; file = file to be checked if it exists
; msg = the error msg you want displayed on screen if you don't want the default "file not found"
; timeout = gets passed to ScriptError(), the amount of time you want the error to show on screen
; crc = If this is a an AHK library only, provide a crc so it can be validated
; crctype = default empty and crc is not checked. Use 0 for AHK libraries and HyperLaunch extension files. Use 1 for module crc checks..
; logerror = default empty will give a log error instead of stopping with a scripterror
CheckFile(file,msg="",timeout=6,crc="",crctype="",logerror=""){
	Global HLObject,logIncludeFileProperties
	exeFileInfo=
	( LTrim
	FileDescription
	FileVersion
	InternalName
	LegalCopyright
	OriginalFilename
	ProductName
	ProductVersion
	CompanyName
	PrivateBuild
	SpecialBuild
	LegalTrademarks
	)

	Log("CheckFile - Checking if " . file . " exists")
	IfNotExist, %file%
		If msg
			ScriptError(msg, timeout)
		Else
			ScriptError("Cannot find " . file, timeout)

	If (crctype = 0 Or crctype = 1) {
		CRCResult := COM_Invoke(HLObject, "checkModuleCRC", "" . file . "",crc,crctype)
		If CRCResult = -1
			Log("CRC Check - " . (If crctype=1 ? "Module" : If (crctype=0 && crc) ? "Library" : "Extension") . " file not found.",3)
		Else If CRCResult = 0
			If crctype = 1
				Log("CRC Check - CRC does not match official module and will not be supported. Continue using at your own risk.",2)
			Else If logerror
				Log("CRC Check - CRC does not match for this " . (If (crctype=0 && crc) ? "Library" : "Extension") . ". Please re-download this file to continue using HyperLaunch: " . file,3)
			Else
				ScriptError("CRC Check - CRC does not match for this " . (If (crctype=0 && crc) ? "Library" : "Extension") . ". Please re-download this file to continue using HyperLaunch: " . file)
		Else If CRCResult = 1
			Log("CRC Check - CRC matches, this is an official unedited " . (If crctype=1 ? "Module" : If (crctype=0 && crc) ? "Library" : "Extension") . ".",4)
		Else If CRCResult = 2
			Log("CRC Check - No CRC defined on the header for: " . file,3)
	}

	If logIncludeFileProperties = true
	{	If exeAtrib := FileGetVersionInfo_AW( file, exeFileInfo, "`n"  )
			Loop, Parse, exeAtrib, `n
				logTxt .= (If A_Index=1 ? "":"`n") . "`t`t`t`t`t" . A_LoopField
		FileGetSize, fileSize, %file%
		FileGetTime, fileTimeC, %file%, C
		FormatTime, fileTimeC, %fileTimeC%, M/d/yyyy - h:mm:ss tt
		FileGetTime, fileTimeM, %file%, M
		FormatTime, fileTimeM, %fileTimeM%, M/d/yyyy - h:mm:ss tt
		logTxt .= (If logTxt ? "`r`n":"") . "`t`t`t`t`tFile Size:`t`t`t" . fileSize . " bytes"
		logTxt .= "`r`n`t`t`t`t`tCreated:`t`t`t" . fileTimeC
		logTxt .= "`r`n`t`t`t`t`tModified:`t`t`t" . fileTimeM
		Log("CheckFile - Attributes:`r`n" . logTxt,4)
	}
	Return %file%
}

; ScriptError usage:
; error = error text
; timeout = duration in seconds error will show
; w = width of error box
; h = height of error box
; txt = font size
ScriptError(error,timeout=6,w=600,h=150,txt=15){
	Global HLMediaPath,exitScriptKey,HLFile,HLErrSoundPath

	XHotKeywrapper(exitEmulatorKey,"CloseProcess","OFF")
	XHotKeywrapper(exitEmulatorKey,"CloseError","ON")
	Hotkey, Esc, CloseError
	Hotkey, Enter, CloseError
	
	If !pToken := Gdip_Startup(){	; Start gdi+
		MsgBox % "Gdiplus failed to start. Please ensure you have gdiplus on your system"
		ExitApp
	}

	timeout *= 1000	; converting to seconds
	sf := A_ScreenWidth/1280	; sf = Scalling Factor
	vsf := A_ScreenHeight/800	; vsf = Vertical Scalling Factor
	If sf > vsf
		sf := vsf 

	hbm10 := CreateDIBSection(A_ScreenWidth,A_ScreenHeight)	; create background canvas the size of the desktop
	hdc10 := CreateCompatibleDC(), obm10 := SelectObject(hdc10, hbm10)
	G10 := Gdip_GraphicsFromhdc(hdc10), Gdip_SetInterpolationMode(G10, 7), Gdip_SetSmoothingMode(G10, 4)
	Gui, ErrorGUI_10: New, +HwndError10_ID +E0x80000 +ToolWindow -Caption +AlwaysOnTop +OwnDialogs, Error Layer 1	; E0x80000 required for UpdateLayeredWindow to work. Is always on top, has no taskbar entry, no caption, and msgboxes will appear on top of the GUI
	Gui, ErrorGUI_10: Show

	pBrush := Gdip_BrushCreateSolid("0xFF000000")	; Painting the background color
	Gdip_FillRectangle(G10, pBrush, -1, -1, A_ScreenWidth+1, A_ScreenHeight+1)	; draw the background first on layer 1 first, layer order matters!!

	brushWarningBackground := Gdip_CreateLineBrushFromRect(0, 0, round(w*sf), round(h*sf), 0xff555555, 0xff050505)
	penWarningBackground := Gdip_CreatePen(0xffffffff, round(5*sf))
	Gdip_FillRoundedRectangle(G10, brushWarningBackground, (A_ScreenWidth - w*sf)//2, (A_ScreenHeight - h*sf)//2, round(w*sf), round(h*sf), round(25*sf))
	Gdip_DrawRoundedRectangle(G10, penWarningBackground, (A_ScreenWidth - w*sf)//2, (A_ScreenHeight - h*sf)//2, round(w*sf), round(h*sf), round(25*sf))
	WarningBitmap := Gdip_CreateBitmapFromFile(HLMediaPath . "\Menu Images\HyperLaunch\Warning.png")
	Gdip_DrawImage(G10,WarningBitmap, round((A_ScreenWidth - w*sf)//2 + 25*sf),round((A_ScreenHeight - h*sf)//2 + 25*sf),round(100*sf),round(100*sf))
	Gdip_TextToGraphics(G10, error, "x" round((A_ScreenWidth-w*sf)//2+125*sf) " y" round((A_ScreenHeight-h*sf)//2+25*sf) " Left vCenter cffffffff r4 s" round(txt*sf) " Bold",, round((w - 50 - 100)*sf) , round((h - 50)*sf))

	startTime := A_TickCount
	Loop{	; fade in
		t := ((TimeElapsed := A_TickCount-startTime) < 300) ? (255*(timeElapsed/300)) : 255
		UpdateLayeredWindow(Error10_ID,hdc10, 0, 0, A_ScreenWidth, A_ScreenHeight,t)
		If t >= 255
			Break
	}

	; Generate a random sound to play on a script error
	erSoundsAr:=[]	; initialize the array to store error sounds
	Loop, %HLErrSoundPath%\error*.mp3
		erSoundsAr.Insert(A_LoopFileName)	; insert each found error sound into an array
	Random, erRndmSound, 1, % erSoundsAr.MaxIndex()	; randomize what sound to play
	Log("ScriptError - Playing error sound: " . erSoundsAr[erRndmSound],4)
	SoundPlay % If erSoundsAr.MaxIndex() ? (HLErrSoundPath . "\" . erSoundsAr[erRndmSound]):("*-64"), wait	; play the random sound if any exist, or default to the Asterisk windows sound
	Sleep, %timeout%

	CloseError:
		endTime := A_TickCount
		Loop{	; fade out
			t := ((TimeElapsed := A_TickCount-endTime) < 300) ? (255*(1-timeElapsed/300)) : 0
			UpdateLayeredWindow(Error10_ID,hdc10, 0, 0, A_ScreenWidth, A_ScreenHeight,t)
			If t <= 0
				Break
		}

		XHotKeywrapper(exitEmulatorKey,"CloseError","OFF")
		XHotKeywrapper(exitEmulatorKey,"CloseProcess","ON")
		Gdip_DeleteBrush(pBrush)
		Gdip_DisposeImage(WarningBitmap), SelectObject(hdc10, obm10), DeleteObject(hbm10), DeleteDC(hdc10), Gdip_DeleteGraphics(G10)
		Gui, ErrorGUI_10: Destroy
		Gdip_Shutdown(pToken)
		Log(error,3)
		ExitApp
	Return
}

; Log usage:
; text = text I want to log
; lvl = the lvl to log the text at
; notime = only used for 1st and last lines of the log so a time is not inserted when I inset the BBCode [code] tags. Do not use this param
; dump = tells the function to write the log file at the end. Do not use this param
; firstLog = tells the function to not insert a time when the first log is made, instead puts an N/A. Do not use this param
; Log() in the module thread requires `r`n at the end of each line, where it's not needed in the HL thread
Log(text,lvl=1,notime="",dump="",firstLog=""){
	Static log
	Static lastLog
	Global logFile,logLevel,logLabel
	; Global executable
	If logLevel>0
	{
		If (lvl<=logLevel || lvl=3){	; ensures errors are always logged
			logDiff := A_TickCount - lastLog
			lastLog := A_TickCount
			log:=log . (If notime?"" : A_Hour . ":" . A_Min ":" . A_Sec ":" . A_MSec . " | MD | " . logLabel[lvl] . A_Space . " | +" . AlignColumn(If firstLog ? "N/A" : logDiff) . "" . " | ") . text . "`r`n"
		}
		If (logLevel>=10 || dump){
			FileAppend,%log%,%logFile%
			log:=
		}
		; Process, Exist, %executable%
		; If ErrorLevel
			; Log .= "mame exists`r`n"
		Return log
	}
}

; Inserts extra characters/spaces into sections of the Log file to keep it aligned.
; Usage: inserts char x number of times on the end of txt until pad is reached.
AlignColumn(txt,pad=9,char=" "){
	x := If char=" "?2:1	; if char is a space, let's only insert half as many so it looks slightly more even in notepad++
	Loop {
		n := StrLen(txt)
		If (n*x >= pad)
			Break
		txt := txt . char
	}
	Return txt
}

IniReadCheck(file,section,key,defaultvalue="",errorMsg="",logType="") {
	IniRead, iniVar, %file%, %section%, %key%, %defaultvalue%
	If IniVar = ERROR	; if key does not exist, delete ERROR as the value
		iniVar :=
	If (iniVar = ""  and !logType) {
		If errorMsg
			ScriptError(errorMsg)
		Else
			IniWrite, %defaultValue%, %file%, %section%, %key%
		Return defaultValue
	}
	If (logType and iniVar) {	; only log if a key exists and logType set
		logAr := ["Module","Bezel"]
		Log(logAr[logType] . " Setting - " . key . ": " . iniVar)
	}
	Return iniVar
}

; Toggles hiding/showing a MenuBar
; Usage: Provide the window's PID of the window you want to toggle the MenuBar
; used in nulldc module and bezel
ToggleMenu( hWin ){
	Static hMenu, visible
	If hMenu =
		hMenu := DllCall("GetMenu", "uint", hWin)	; store the menubar ID so it can be restored later
	hMenuCur := DllCall("GetMenu", "uint", hWin)
	timeout := A_TickCount
	If !hMenuCur
		Loop {
			;ToolTip, menubar is hidden`, bringing it back`nhMenuCur: %hMenuCur%`n%A_Index%
			hMenuCur := DllCall("GetMenu", "uint", hWin)
			If hMenuCur
				Break	; menubar is now visible, break out
			DllCall("SetMenu", "uint", hWin, "uint", hMenu)
			If (timeout < A_TickCount - 500)	; prevents an infinite loop and breaks after 2 seconds
				Break
		}
	Else Loop {	; menubar is visible
		;ToolTip, menubar is visible`, hiding it`nhMenuCur: %hMenuCur%`n%A_Index%
		hMenuCur := DllCall("GetMenu", "uint", hWin)
		If !hMenuCur
			Break	; menubar is now hidden, break out
		DllCall("SetMenu", "uint", hWin, "uint", 0)
		If (timeout < A_TickCount - 500)	; prevents an infinite loop and breaks after 2 seconds
			Break
	}
}
; Original function but somestimes does not work, which is why the new function loops above
ToggleMenuOld( hWin ){
	Static hMenu, visible
	If hMenu =
		hMenu := DllCall("GetMenu", "uint", hWin)
	If !visible
			DllCall("SetMenu", "uint", hWin, "uint", hMenu)
	Else
		DllCall("SetMenu", "uint", hWin, "uint", 0)
	visible := !visible
}

; Inject a shared function for HP and Fade which adjusts the background image positioning
; Usage, params 1-4 are byref so supply the var you want to be filled with the calculated positions and size. Next 2 are the original pics width and height. Last is the position the user wants.
GetBGPicPosition(ByRef retX,ByRef retY,ByRef retW,ByRef retH,w,h,pos){
	widthMaxPercent := ( A_ScreenWidth / w )	; get the percentage needed to maximumise the image so it reaches the screen's width
	heightMaxPercent := ( A_ScreenHeight / h )
	If (pos = "Stretch and Keep Aspect") {	; image is stretched to Center screen, keeping aspect
		percentToEnlarge := If (widthMaxPercent < heightMaxPercent) ? widthMaxPercent : heightMaxPercent	; this basicallys says if the width's max reaches the screen's width first, use the width's percentage instead of the height's
		retW := Round(w * percentToEnlarge)	; multiply width by the percentage from above to reach as close to the edge as possible
		retH := Round(h * percentToEnlarge)	; multiply height by the percentage from above to reach as close to the edge as possible
		retX := ( A_ScreenWidth / 2 ) - ( retW / 2 )	; find where to place the X of the image
		retY := ( A_ScreenHeight / 2 ) - ( retH / 2 )	; find where to place the Y of the image
	} Else If (pos = "Center Width") {	; image is stretched to Center screen's width, keeping aspect
		percentToEnlarge := widthMaxPercent	; increase the image size by the percentage it takes to reaches the screen's width, cropping may occur on top and bottom
		retW := Round(w * percentToEnlarge)	; multiply width by the percentage from above to reach as close to the edge as possible
		retH := Round(h * percentToEnlarge)	; multiply height by the percentage from above to reach as close to the edge as possible
		retX := ( A_ScreenWidth / 2 ) - ( retW / 2 )	; find where to place the X of the image
		retY := ( A_ScreenHeight / 2 ) - ( retH / 2 )	; find where to place the Y of the image
	} Else If (pos = "Center Height") {	; image is stretched to Center screen's height, keeping aspect
		percentToEnlarge := heightMaxPercent	; increase the image size by the percentage it takes to reaches the screen's height, cropping may occur on left and right
		retW := Round(w * percentToEnlarge)	; multiply width by the percentage from above to reach as close to the edge as possible
		retH := Round(h * percentToEnlarge)	; multiply height by the percentage from above to reach as close to the edge as possible
		retX := ( A_ScreenWidth / 2 ) - ( retW / 2 )	; find where to place the X of the image
		retY := ( A_ScreenHeight / 2 ) - ( retH / 2 )	; find where to place the Y of the image
	} Else If (pos = "Center") {	; original image size and aspect
		retX := ( A_ScreenWidth / 2 ) - ( w / 2 )	; find where to place the X of the image
		retY := ( A_ScreenHeight / 2 ) - ( h / 2 )	; find where to place the Y of the image
	} Else If (pos = "Align to Bottom Left") {	; place the pic so the bottom left corner matches the screen's bottom left corner
		retH := A_ScreenHeight
		retW := Round( w / ( h / A_ScreenHeight ))
		If ( retW < A_ScreenWidth ){
			retW := A_ScreenWidth
			retH := Round( h / ( w / retW ))
		}
		retY := A_ScreenHeight - retH
	} Else If (pos = "Align to Bottom Right") {	; place the pic so the bottom right corner matches the screen's bottom right corner
		retH := A_ScreenHeight
		retW := Round( w / ( h / A_ScreenHeight ))
		If ( retW < A_ScreenWidth ){
			retW := A_ScreenWidth
			retH := Round( h / ( w / retW ))
		}
		retX := A_ScreenWidth - retW
		retY := A_ScreenHeight - retH
	} Else If (pos = "Align to Top Right") {	; place the pic so the top right corner matches the screen's top right corner
		retH := A_ScreenHeight
		retW := Round( w / ( h / A_ScreenHeight ))
		If ( retW < A_ScreenWidth ){
			retW := A_ScreenWidth
			retH := Round( h / ( w / retW ))
		}
		retX := A_ScreenWidth - retW
	} Else {	; place the pic so the top left corner matches the screen's top left corner, also the default
		retH := A_ScreenHeight
		retW := Round( w / ( h / A_ScreenHeight ))
		If ( retW < A_ScreenWidth ){
			retW := A_ScreenWidth
			retH := Round( h / ( w / retW ))
		}
	}
}

; Function to pause and wait for a user to press any key to continue.
; IdleCheck usage:
; t = timeout in ms to break out of function
; m = the method - can be "P" (physical) or "L" (logical)
; s = sleep or how fast the function checks for idle state
; Exits when state is no longer idle or times out
IdleCheck(t="",m="L",s=200){
	timeIdlePrev := 0
	startTime := A_TickCount
	While timeIdlePrev < (If m = "L" ? A_TimeIdle : A_TimeIdlePhysical){
		timeIdlePrev := If m = "L" ? A_TimeIdle : A_TimeIdlePhysical
		If (t && A_TickCount-startTime >= t)
			Return "Timed Out"
		Sleep s
	}
	Return A_PriorKey
}

; Shared romTable function and label for HP and MG which calculates what roms have multiple discs. Now available on every launch to support some custom uses for loading multiple disks on some older computer systems
CreateMGRomTable:
	Log("CreateMGRomTable - Started")
	If !IsObject(romTable)
	{	Log("CreateMGRomTable - romTable does not exist, creating one for """ . dbName . """",4)
		romTable := CreateRomTable(dbName)
	} Else
		Log("CreateMGRomTable - romTable already exists, skipping table creation.",4)
	Log("CreateMGRomTable - Ended")
Return

CreateRomTable(table) {
	Log("CreateRomTable - Started")
	Global romPathFromIni,dbName,romExtensionOrig,7zEnabled
	romCount := 0	; initialize the var and reset it, needed in case GUI is used more then once in a session
	table := []	; initialize and empty the table
	typeArray := ["(Disc","(Disk","(Cart","(Tape","(Cassette","(Part","(Side"]
	regExCheck = i)\s\(Disc\s[^/]*|\s\(Disk\s[^/]*|\s\(Cart\s[^/]*|\s\(Tape\s[^/]*\s\(Cassette\s[^/]*\s\(Part\s[^/]*\s\(Side\s[^/]*
	dbNamePre := RegExReplace(dbName, regExCheck)	; removes the last set of parentheses if Disc,Tape, etc is in them. A Space must exist before the "(" and after the word Disc or Tape, followed by the number. This is the HS2 standard
	Loop % typeArray.MaxIndex() ; loop each item in our array
	{	If matchedRom	; Once we matched our game to the typeArray, no need to search for another. This allows the loop to break out.
			Break
		indexTotal ++
		Log("CreateRomTable - Checking for match: """ . dbName . """ and """ . typeArray[A_Index] . """",4)
		If dbName contains % typeArray[A_Index]	; find the item in our array that matches our rom
		{	Log("CreateRomTable - """ . dbName . """ contains """ . typeArray[A_Index] . """",4)
			typeArrayIndex := A_Index
			Loop, Parse, romPathFromIni, |
			{	indexTotal ++
				currentPath := A_LoopField 
				Log("CreateRomTable - Checking New Rom path: " . currentPath,4)
				Log("CreateRomTable - Now looping in: " . currentPath  . "\" . dbNamePre . A_Space . typeArray[typeArrayIndex] . "*",4)
				Loop, % currentPath . "\" . dbNamePre . A_Space . typeArray[typeArrayIndex] . "*", 1,1	; we now know to only look for files & folders that have our rom & media type in them.
				{	indexTotal ++
					Log(A_LoopFileFullPath,4)
					Log("CreateRomTable - Looking for: " . currentPath . "\" . dbNamePre . A_Space . typeArray[typeArrayIndex] . A_LoopFileExt,4)
					If romExtensionOrig contains % A_LoopFileExt	; Now we narrow down to all matching files using our original extension. Next we use this data to build an array of our files to populate the GUI.
					{	romCount += 1
						matchedRom := 1	; Allows to break out of the loops once we matched our rom
						table[romCount,1] := A_LoopFileFullPath	; Store A_LoopFileFullPath in column 1
						table[romCount,2] := A_LoopFileName	; Store A_LoopFileName in column 2
						table[romCount,3] := RegExReplace(table[romCount, 2], "\..*")	; Store the filename with mediatype # but w/o an extension in column 3
						pos := RegExMatch(table[romCount,2], regExCheck)	; finds position of our multi media type so we can trim away and generate the imageText and check if rom is part of a set. This pulls only the filenames out of the table in column 2.
						uncleanTxt:= SubStr(table[romCount,2], pos + 1)	; remove everything but the media type and # and ext from our file name
						table[romCount,4] := dbNamePre	; store dbName w/o the media type, used for HP and updating statistics
						table[romCount,5] := RegExReplace(uncleanTxt, "\(|\)|\..*")	; clean the remainder, removing () and ext, then store it as column 4 in our table to be used for our imageText
						table[romCount,6] := SubStr(table[romCount,5],1,4)	; copies the imagetype to be used to column 5
						Log("CreateRomTable - Adding found game to Rom Table: " . A_LoopFileFullPath,4)
					}
				}
			}
		}
	}
	Log("CreateRomTable - Ended`, " . IndexTotal . " Loops to create table.")
	Return table
}

; Label used by HP and Fade animation to read the Hyperspin's XML 
ReadHyperSpinXML:
	Log("ReadHyperSpinXML - Started")
	FileRead, xmlDescription, %frontendPath%\Databases\%systemName%\%systemName%.xml
	tempDbName := dbName
	StringReplace, tempDbName, tempDbName, \, \\, All
	replace :=   {"&":"&amp;","'":"&apos;",".":"\.","*":"\*","?":"\?","+":"\+","[":"\[","{":"\{","|":"\|","(":"\(",")":"\)","^":"\^","$":"\$"}
	For what, with in replace
	StringReplace, tempDbName, tempDbName, %what%, %with%, All
	TempSearchString1 = i)"%tempDbName%"
	FoundPos1 := RegExMatch(xmlDescription, TempSearchString1, SearchString1)
	if !FoundPos1
		{
		xmlDescription := dbName
		Log("Database name " . tempDbName . " not found on " . systemName . ".xml", 2)
		Log("ReadHyperSpinXML - Ended")
		return
	}
	RegExMatch(xmlDescription, "i)</game>", SearchString2, FoundPos1)
	GameXMLInfo := StrX(xmlDescription,SearchString1,1,0,SearchString2,1,0)
	ListofXMLInfo = Description|Cloneof|Crc|Manufacturer|Year|Genre|Rating
	Loop, parse, ListofXMLInfo, |
	{
		FoundPos1 := RegExMatch(GameXMLInfo, "i)<" . a_loopfield . ">", SearchString1)
		FoundPos2 :=RegExMatch(GameXMLInfo, "i)</" . a_loopfield . ">", SearchString2)
		FinalPos1 := FoundPos1 + StrLen(SearchString1)
		If(FinalPos1 = FoundPos2){
			XML%a_loopfield% := 
		} Else {
			RegExMatch(GameXMLInfo, "i)</" . a_loopfield . ">", SearchString2, FoundPos1)
			XML%a_loopfield% := StrX(GameXMLInfo,SearchString1,1,StrLen(SearchString1),SearchString2,1,StrLen(SearchString2))
			StringReplace, XML%a_loopfield%, XML%a_loopfield%, &amp;, &, All
			StringReplace, XML%a_loopfield%, XML%a_loopfield%, &apos;, ', All
			XML%a_loopfield% := RegexReplace( XML%a_loopfield%, "^\s+|\s+$" )
		}
	}
	Log("ReadHyperSpinXML - Ended")
Return

; Function to measure the size of text so HP and Fade can create their canvas's only as big as they have to be
MeasureText(hwnd,text,Font,size,style){
	hdc_MeasureText := GetDC(hwnd)
	G_MeasureText := Gdip_GraphicsFromHDC(hdc_MeasureText)
	hFamily_MeasureText := Gdip_FontFamilyCreate(Font)
	hFont_MeasureText := Gdip_FontCreate(hFamily_MeasureText, size, style)
	hFormat_MeasureText := Gdip_StringFormatCreate(0x4000)
	CreateRectF(RectF_MeasureText, 0, 0, 0, 0)
	RECTF_STR := Gdip_MeasureString(G_MeasureText, text, hFont_MeasureText, hFormat_MeasureText, RectF_MeasureText)
	StringSplit,RCI,RECTF_STR, |
	Width := round(RCI3)
	Gdip_DeleteFont(hFont_MeasureText),Gdip_DeleteStringFormat(hFormat_MeasureText)
	DeleteDC(hdc_MeasureText), Gdip_DeleteGraphics(G_MeasureText)
	Return, Width
}

; Function that allows making applications transparent so they can be hidden completely w/o moving them
FadeApp(title,direction,time=0){
	startTime := A_TickCount
	Loop{
		t := ((TimeElapsed := A_TickCount-startTime) < time) ? (If direction="in" ? 255*(timeElapsed/time) : 255*(1-(timeElapsed/time))) : (If direction="in" ? 255 : 0)
		WinSet, Transparent, %t%, %title%
		If (direction = "in" && t >= 255) or (direction = "out" && t <= 0) {
			If direction = in
				WinSet, Transparent, Off, %title%
			Break
		}
	}
	Log("HideFE - " . (If direction = "out" ? "Hiding Frontend by making it transparent" : "Showing Frontend and removing transparency"))
}

; This function converts a relative path to absolute
GetFullName( fn ) {
; http://msdn.microsoft.com/en-us/library/Aa364963
	Static buf ;, i	; removing i from static because it needs to be reset from one call to the next
	; If !i
	i := VarSetCapacity(buf, 512)
	DllCall("GetFullPathNameA", "str", fn, "uint", 512, "str", buf, "str*", 0)
	Return buf
}

; FileGetVersionInfo_AW which gets file attributes
FileGetVersionInfo_AW( peFile="", StringFileInfo="", Delimiter="|") {
	Static CS, HexVal, Sps="                        ", DLL="Version\"
	If ( CS = "" )
		CS := A_IsUnicode ? "W" : "A", HexVal := "msvcrt\s" (A_IsUnicode ? "w": "" ) "printf"
	If ! FSz := DllCall( DLL "GetFileVersionInfoSize" CS , Str,peFile, UInt,0 )
		Return "", DllCall( "SetLastError", UInt,1 )
	VarSetCapacity( FVI, FSz, 0 ), VarSetCapacity( Trans,8 * ( A_IsUnicode ? 2 : 1 ) )
	DllCall( DLL "GetFileVersionInfo" CS, Str,peFile, Int,0, UInt,FSz, UInt,&FVI )
	If ! DllCall( DLL "VerQueryValue" CS, UInt,&FVI, Str,"\VarFileInfo\Translation", UIntP,Translation, UInt,0 )
		Return "", DllCall( "SetLastError", UInt,2 )
	If ! DllCall( HexVal, Str,Trans, Str,"%08X", UInt,NumGet(Translation+0) )
		Return "", DllCall( "SetLastError", UInt,3 )
	Loop, Parse, StringFileInfo, %Delimiter%
	{ subBlock := "\StringFileInfo\" SubStr(Trans,-3) SubStr(Trans,1,4) "\" A_LoopField
		If ! DllCall( DLL "VerQueryValue" CS, UInt,&FVI, Str,SubBlock, UIntP,InfoPtr, UInt,0 )
			Continue
		Value := DllCall( "MulDiv", UInt,InfoPtr, Int,1, Int,1, "Str"  )
		Info  .= Value ? ( ( InStr( StringFileInfo,Delimiter ) ? SubStr( A_LoopField Sps,1,24 ) . A_Tab : "" ) . Value . Delimiter ) : ""
	} StringTrimRight, Info, Info, 1
	Return Info
}

; StrX function because some modules use it and HyperPause needs it
StrX( H,  BS="",BO=0,BT=1,   ES="",EO=0,ET=1,  ByRef N="" ) {
	Return SubStr(H,P:=(((Z:=StrLen(ES))+(X:=StrLen(H))+StrLen(BS)-Z-X)?((T:=InStr(H,BS,0,((BO
	 <0)?(1):(BO))))?(T+BT):(X+1)):(1)),(N:=P+((Z)?((T:=InStr(H,ES,0,((EO)?(P+1):(0))))?(T-P+Z
	 +(0-ET)):(X+P)):(X)))-P)
}

; Function to hide/unhide the mouse cursor
SystemCursor(OnOff=1)   ; INIT = "I","Init"; OFF = 0,"Off"; TOGGLE = -1,"T","Toggle"; ON = others
{
	Static AndMask, XorMask, $, h_cursor
		,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13 ; system cursors
		, b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13   ; blank cursors
		, h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11,h12,h13   ; handles of default cursors
	If (OnOff = "Init" or OnOff = "I" or $ = "")	   ; init when requested or at first call
	{
		$ = h	; active default cursors
		VarSetCapacity( h_cursor,4444, 1 )
		VarSetCapacity( AndMask, 32*4, 0xFF )
		VarSetCapacity( XorMask, 32*4, 0 )
		system_cursors = 32512,32513,32514,32515,32516,32642,32643,32644,32645,32646,32648,32649,32650
		StringSplit c, system_cursors, `,
		Loop %c0%
		{
			h_cursor   := DllCall( "LoadCursor", "uint",0, "uint",c%A_Index% )
			h%A_Index% := DllCall( "CopyImage",  "uint",h_cursor, "uint",2, "int",0, "int",0, "uint",0 )
			b%A_Index% := DllCall("CreateCursor","uint",0, "int",0, "int",0
				, "int",32, "int",32, "uint",&AndMask, "uint",&XorMask )
		}
	}
	If (OnOff = 0 or OnOff = "Off" or $ = "h" and (OnOff < 0 or OnOff = "Toggle" or OnOff = "T")){
		$ = b	; use blank cursors
		Log("Hiding mouse cursor")
		CoordMode, Mouse	; Also lets move it to the side since some emu's flash a cursor real quick even if we hide it.
		MouseMove, 0, 0, 0
	}Else{
		$ = h	; use the saved cursors
		SPI_SETCURSORS := 0x57	; Emergency restore cursor, just in case something goes wrong
		DllCall( "SystemParametersInfo", UInt,SPI_SETCURSORS, UInt,0, UInt,0, UInt,0 )
		Log("Restoring mouse cursor")
	}
	
	Loop %c0%
	{
		h_cursor := DllCall( "CopyImage", "uint",%$%%A_Index%, "uint",2, "int",0, "int",0, "uint",0 )
		DllCall( "SetSystemCursor", "uint",h_cursor, "uint",c%A_Index% )
	}
}

;-------------------------------------------------------------------------------------------------------------
;------------------ Read and Write Wrapper Functions for IniFileEdit ------------------
;-------------------------------------------------------------------------------------------------------------

; Usage - Read and Write to config files that are not valid inis with [sections], like RetroArch's cfg

; cfgFile - path to the file to read, only need to send this once, it stays in memory until SavePropertiesCfg is used
; Returns a reference number to the array where the cfg is stored in memory so multiple files can be edited at once
LoadProperties(cfgFile) {
	Log("LoadProperties - Started and loading this cfg into memory: " . cfgFile,4)
	cfgtable := Object()
	Loop, Read, %cfgFile% ; This loop retrieves each line from the file, one at a time.
		cfgtable.Insert(A_LoopReadLine) ; Append this line to the array.
	Log("LoadProperties - Ended",4)
	Return cfgtable
}

; cfgFile - path to the file to read, only need to send this once, it stays in memory until SavePropertiesCfg is used
; cfgArray - reference number of array in memory that should be saved to the cfgFile
SaveProperties(cfgFile,cfgArray) {
	Log("SaveProperties - Started and saving this cfg to disk: " . cfgFile,4)
	FileDelete, %cfgFile%
	Loop % cfgArray.MaxIndex()
	{	element := cfgArray[A_Index]
		trimmedElement := LTrim(element)
		FileAppend, %trimmedElement%`n, %cfgFile%
	}
	Log("SaveProperties - Ended",4)
}

; cfgArray - reference number of array in memory that you want to read
; keyName = key whose value you want to read
ReadProperty(cfgArray,keyName) {
	Log("ReadProperty - Started",4)
	Loop % cfgArray.MaxIndex()
	{	element := cfgArray[A_Index]
		trimmedElement := Trim(element)
		;MsgBox % "Element number " . A_Index . " is " . element

		StringGetPos, pos, trimmedElement, [
		If (pos = 0)
			Break	; Section was found, do not search anymore, global section has ended

		If element contains =
		{	StringSplit, keyValues, element, =
			CfgValue := Trim(keyValues1)
			If (CfgValue = keyName)
				Return Trim(keyValues2)	; Found it & trim any whitespace
		}
	}
	Log("ReadProperty - Ended",4)
}

; cfgArray - reference number of array in memory that you want to read
; keyName = key whose value you want to write
; Value = value that you want to write to the keyName
; AddSpaces = If the seperator (=) has spaces on either side, set this parameter to 1 and it will wrap the seperator in spaces
; AddQuotes = If the Value needs to be wrapped in double quotes (like in retroarch's config), set this parameter to 1
WriteProperty(cfgArray,keyName,Value,AddSpaces=0,AddQuotes=0) {
	Log("WriteProperty - Started",4)
	added = 0
	Loop % cfgArray.MaxIndex()
	{	lastIndex := A_Index
		element := cfgArray[A_Index]
		trimmedElement := Trim(element)

		StringGetPos, pos, trimmedElement, [
		If (pos = 0)
		{	lastIndex := lastIndex - 1	; Section was found, do not search anymore
			Break
		}

		If element contains =
		{	StringSplit, keyValues, element, =
			CfgValue := Trim(keyValues1)
			If (CfgValue = keyName)
			{	cfgArray[A_Index] := CfgValue . (If AddSpaces=1 ? " = " : "=") . (If AddQuotes=1 ? ("""" . Value . """") : Value)	; Found it
				added = 1
				Break
			}
		}
	}
	If added = 0
		cfgArray.Insert(lastIndex+1, keyName . (If AddSpaces=1 ? " = " : "=") . (If AddQuotes=1 ? ("""" . Value . """") : Value))	; Add the new entry to the file
	Log("WriteProperty - Ended",4)
}

;-------------------------------------------------------------------------------------------------------------
;------------------------------------- Daemon Tools Function -------------------------------------
;-------------------------------------------------------------------------------------------------------------

DaemonTools(action,file="",type="",drive=0){
	Log("DaemonTools - Started - action is " . action)
	Global dtPath,dtUseSCSI,dtAddDrive,dtDriveLetter,7zFormatsNoP
	dtMap:=Object(0,"A",1,"B",2,"C",3,"D",4,"E",5,"F",6,"G",7,"H",8,"I",9,"J",10,"K",11,"L",12,"M",13,"N",14,"O",15,"P",16,"Q",17,"R",18,"S",19,"T",20,"U",21,"V",22,"W",23,"X",24,"Y",25,"Z")
	If file	; only log file when one is used
		Log("DaemonTools - Received file: " . file,4)
	SplitPath, file,,,ext
	file := (If file ? ("`, """ . file . """") : (""))
	IfNotExist % dtPath
		ScriptError("Could not find " . dtPath . "`nPlease fix the DAEMON_Tools_Path key in your Settings\Global HyperLaunch.ini to point to your DTLite installation.",8)
	If action not in get,mount,unmount
		ScriptError(action . " is an unsupported use of daemontools. Only mount and unmount actions are supported.")
	If action = mount
	{	If ext in %7zFormatsNoP%
			ScriptError("DaemonTools was sent an archive extension """ . ext . """ which is not a mountable file type. Turn on 7z support or uncompress this game in order to mount it.")
		Else If ext not in mds,mdx,b5t,b6t,bwt,ccd,cue,isz,nrg,cdi,iso,ape,flac
			ScriptError("DaemonTools was sent the extension """ . ext . " which is not a mountable file type.")
	}
	type := If type ? (type):(If dtUseSCSI = "true" ? ("scsi") : ("dt"))
	If type not in dt,scsi
		ScriptError(type . " is an unsupported use of daemontools. Only dt and scsi drives are supported.")
	If drive not in 0,1,2,3,4
		ScriptError(drive . " is an invalid virtual device number. Only 0 through 4 are supported.")
	If action != unmount
	{	RunWait, %dtPath% -get_count %type%
		If (ErrorLevel = 0 && dtAddDrive = "true"){
			Log("DaemonTools - Did not find a " . type . " drive, creating one now",4)
			RunWait, %dtPath% -add %type%
			Sleep, 500
		}Else If ErrorLevel = 0
				ScriptError("You are trying to mount to a " . type . " virtual drive, yet one does not exist.")
		If action = get
		{	RunWait, %dtPath% -get_letter %type%`, %drive%
			dtDriveLetter:=dtMap[ErrorLevel]
			If !ErrorLevel
				ScriptError("A error occured finding the drive letter associated to your " . type . " drive. Please make sure you are using the latest Daemon Tools Lite.")
			Log("DaemonTools ended - Retrieved your " . type . " drive letter: " . dtDriveLetter,4)
			Return
		}
	}
	Log("DaemonTools - Running DT with: " . dtPath . " -" . action . " " . type . ", " .  drive . file)
	RunWait, %dtPath% -%action% %type%`, %drive%%file%
	Log("DaemonTools - Ended")
}

;-------------------------------------------------------------------------------------------------------------
;--------------------------------------------- 7z Functions ---------------------------------------------
;-------------------------------------------------------------------------------------------------------------

7z(ByRef 7zP, ByRef 7zN, ByRef 7zE, ByRef 7zExP){
	Global 7zEnabled,7zFormats,7zFormatsNoP,7zPath,7zAttachSystemName,romExtensions,skipchecks,romMatchExt,systemName,dbName,MEmu
	Global fadeIn,fadeLyr37zAnimation,fadeLyr3Animation ,fadeLyr3Type,HLObject,7zTempRomExists,used7z,romExSize,7z1stRomPath,7zRomPath
	Global romMapTable,romMappingFirstMatchingExt,romMenuRomName ;,romMappingEnabled
	Static 7z1stUse
	If 7zEnabled = true
	{	;If ( romMapTable.MaxIndex() && !7zN )	; if romMapTable contains a rom and romName not passed
			; msgbox Rom map table exists`nNo rom name passed to 7z`nrom must be in map table so parse all archive types in table and check contents for the alt archive name or for the alt rom named if defined
		; Else If ( romMapTable.MaxIndex() && 7zN )	; if romMapTable contains a rom and romName passed
			; msgbox Rom map table exists`nRom name passed to 7z`nignore map table as rom was passed`, but if archive type`, handle it`, otherwise run rom as is`nNO CHANGES NEEDED TO HANDLE THIS SCENARIO
		; Else If ( !romMapTable.MaxIndex() && 7zN )	; if romMapTable does not contain a rom and romName passed
			; msgbox Rom map table does not exist`nRom name passed to 7z`nHandle rom`, if archive type pass further into 7z else if not`, skip 7z and run rom as is`nNO CHANGES NEEDED TO HANDLE THIS SCENARIO
		; Else If ( !romMapTable.MaxIndex() && !7zN )	; if romMapTable does not contain a rom and romName not passed
			; msgbox Rom map table does not exist`nNo rom name passed to 7z`nShould never see this error because no rom exists else if we are going to have to error out
		Log("7z - Started, received " . 7zP . "\" . 7zN . 7zE . ". If rom is an archive, it will extract to " . 7zExP)
		7z1stUse ++	; increasing var each time 7z is used

		Loop, Parse, romExtensions, |	; parse out 7zFormat extensions from romExtensions so the dll doesn't have to parse as many
		{	If A_LoopField not in %7zFormatsNoP%
			{	extIndex ++	; index only increases on valid rom type extensions
				romExtFound = 1
				romTypeExtensions .= (If extIndex > 1 ? "|":"") . A_LoopField
			}
		}
		If (!romExtFound and skipChecks = "false")
			ScriptError("You did not supply any valid rom extensions to search for in your compressed roms. Please turn off 7z support or add at least one rom extension to Rom_Extension: """ . romExtensions . """. If this archive has no roms with a standard romName inside, you may need to set Skip Checks to ""Rom Extension.""",10)
; msgbox romMenuRomName: %romMenuRomName%`nromFromDLL: %romFromDLL%`ndllRomPath: %dllRomPath%`ndllName: %dllName%`ndllExt: %dllExt%`n7zExP: %7zExP%`n7zAttachSystemName: %7zAttachSystemName%`n7zP: %7zP%`n7zN: %7zN%`n7zE: %7zE%`n7zExPCheck: %7zExPCheck%`nromExSize: %romExSize%`n7zExPCheckSize: %7zExPCheckSize%`nromFound: %romFound%
; ExitApp
		If ( romMapTable.MaxIndex() && !7zN ) {	; if romMapTable contains a rom and romName not passed, we must search the rom map table for known roms (defined from map ini or same as archive name) and stop on first found. This method is from a mapped rom not from the Rom Launch Menu.
			Log("7z - Using romTable method because a romTable exists and no romName provided",4)
			7zUsed = 1	; flag that we used 7z for this launch
			Loop % romMapTable.MaxIndex()	; Loop through all found rom map inis
			{	altArchiveFullPath := romMapTable[A_Index,2], romMapIni := romMapTable[A_Index,1] ;, romMapKey := "Alternate_Rom_Name"
				IniRead, altRomName, %romMapIni%, %dbName%, Alternate_Rom_Name
				If (altRomName = "" || altRomName = "ERROR")	; if multiple alt roms were defined, do a check if user defined the key with "_1"
					IniRead, altRomName, %romMapIni%, %dbName%, Alternate_Rom_Name_1
				SplitPath, altArchiveFullPath,, 7zP, 7zE, 7zN	; assign vars to what is needed for the rest of 7z. This is where we define romPath, romName, and romExtension when none were provided to 7z because we used a map table instead.
				7zE := "." . 7zE
				If romFromDLL := COM_Invoke(HLObject, "findFileInZip", altArchiveFullPath, If (altRomName != "" && altRomName != "ERROR") ? altRomName : 7zN, romTypeExtensions)	; if altRomName is a valid name, search for it, otherwise search for the 7zN
				{	Log("7z - DLL found rom inside archive using ""findFileInZip"": """ . romFromDLL . """",4)
					foundRom = 1
					Break
				} Else If romMappingFirstMatchingExt = true		; if we didn't find an exact romName, settle on finding one that at least matches the first matching extension
				{	If romFromDLL := COM_Invoke(HLObject, "findByExtension", altArchiveFullPath, romTypeExtensions)
					{	foundRom = 1
						Break	; break on first found rom and move on
					}
				}
			}
			If foundRom {
				Log("7z - Loading Mapped Rom: """ . romFromDLL . """ found inside """ . 7zP . "\" . 7zN . 7zE . """")
				romFromRomMap = 1
				romIn7z = true	; avoid a duplicate check later
			} Else
				ScriptError("Scanned all defined ""Alternate_Archive_Name"" and no defined ""Alternate_Rom_Name"" found in any provided Rom Map ini files for """ . dbName . """")

		} Else If romMenuRomName {	; if rom came from the rom map menu
			Log("7z - Using Rom Map Menu method because the Launch Menu was used for this rom: """ . romMenuRomName . """",4)
			7zUsed = 1	; flag that we used 7z for this launch
			SplitPath, romMenuRomName,,,rmExt, rmName	; roms in map table do not always have an extension, like when showing roms from the map ini instead of all in the archive. If it does, use it to find the rom in the archive faster, if it doesn't, search all defined romExtensions
			If romFromDLL := COM_Invoke(HLObject, "findFileInZip", 7zP . "\" . 7zN . 7zE, rmName, If rmExt ? rmExt : romTypeExtensions)	; If rmExt exists, search for it, otherwise search for the all romTypeExtensions. Only searching for rmExt will speed up finding our rom
			{	Log("7z - DLL found rom inside archive using ""findFileInZip"": """ . romFromDLL . """",4)
				romFromRomMap = 1
				romIn7z = true	; avoid a duplicate check later
			} Else	; if rom was not found in archive
				ScriptError("Scanned all defined ""Alternate_Archive_Name"" and could not find the selected game " . romMenuRomName . " in any provided Rom Map ini files for " . dbName)

		} Else If 7zE in %7zFormats%	; Not using Rom Mapping and if provided extension is an archive type
		{	Log("7z - Using Standard method to extract this rom",4)
			7zUsed = 1	; flag that we used 7z for this launch
			Log("7z - """ . 7zE . """ found in " . 7zFormats,4)
			If !romFromRomMap {	; do not need to check for rom extensions if alt rom was already scanned in the above dll "findFileInZip"
				CheckFile(7zP . "\" . 7zN . 7zE,"7z could not find this file, please check it exists:`n" . 7zP . "\" . 7zN . 7zE)
				If skipChecks != Rom Extension	; the following extension checks are bypassed with setting skipChecks to skip Rom Extension
				{	If romFromDLL := COM_Invoke(HLObject, "findFileInZip", 7zP . "\" . 7zN . 7zE, 7zN, romTypeExtensions)	; check for 7zN inside the archive
					{	romIn7z = true	; avoid a duplicate check later
						Log("7z - Archive name matches rom name`; DLL found rom inside archive using ""findFileInZip"": """ . romFromDLL . """")
					} Else If romMatchExt != true
						ScriptError("Could not find """ . 7zN . """ inside the archive with any defined Rom Extensions. Check if you are missing the correct Rom Extension for this rom for " . MEmu . "'s Extensions`, enable Rom_Match_Extension`, or correct the file name inside the archive.")
					If !romIn7z {	; if we didn't find an exact romName, settle on finding one that at least matches the first matching extension
						If romFromDLL := COM_Invoke(HLObject, "findByExtension", 7zP . "\" . 7zN . 7zE, romTypeExtensions)
						{	romIn7z = true	; avoid a duplicate check later
							Log("7z - Archive name DOES NOT MATCH rom name`; DLL found rom inside archive using ""findByExtension"": " . romFromDLL,2)
						}
					}
				}
			}
		}

		If (romIn7z = "true" || (skipchecks != "false" && 7zUsed))
		{	SplitPath, romFromDLL,,dllRomPath,dllExt,dllName
			7zRomPath := 7zExP . "\" . (If 7zAttachSystemName = "true" ? systemName . "\" : "") . 7zN	; 7zRomPath reflects the 7zExtractPath + the rom folder our rom will be extracted into. This is used for cleanup later so HL knows what folder to remove
			7zExPCheck := 7zRomPath . (If dllRomPath ? "\" . dllRomPath : "")	; If the archive contains a path/subfolder to the rom we are looking for, add that to the path to check

			romExSize := COM_Invoke(HLObject, "getZipExtractedSize", 7zP . "\" . 7zN . 7zE)	; Get extracted Size of rom for Fade so we know when it's done being extracted or so we can verify the rom size of extracted folders with multiple roms
			Log("7z - Invoked COM Object, ROM extracted size: " . romExSize . " bytes",4)

			IfExist, %7zExPCheck%	; Check if the rom has already been extracted and break out to launch it
			{	Loop, %7zExPCheck%\*.*, , 1
					7zExPCheckSize += %A_LoopFileSize%
				Log("7z - File already exists in 7z_Extract_Path with a size of: " . 7zExPCheckSize . " bytes",4)
			} Else
				Log("7z - File does not already exist in 7z_Extract_Path`, proceeding to extract it.",4)

			; msgbox romMenuRomName: %romMenuRomName%`nromFromDLL: %romFromDLL%`ndllRomPath: %dllRomPath%`ndllName: %dllName%`ndllExt: %dllExt%`n7zExP: %7zExP%`n7zAttachSystemName: %7zAttachSystemName%`n7zP: %7zP%`n7zN: %7zN%`n7zE: %7zE%`n7zExPCheck: %7zExPCheck%`nromExSize: %romExSize%`n7zExPCheckSize: %7zExPCheckSize%`nromFound: %romFound%
			If (romExSize and 7zExPCheckSize and romExSize = 7zExPCheckSize)	; If total size of rom in archive matches the size on disk, good guess the extracted rom is complete and we don't need to re-extract it again
			{	7zP := 7zExPCheck
				7zE = .%dllExt%
				If romMenuRomName		; only need this when rom map launch menu was used
					7zN := dllName				; set romName to the found rom from the dll
				romFound = true					; telling rest of function rom found so it exists successfully and to skip to end
				7zTempRomExists = true	; telling the animation that the rom already exists so it doesn't try to show a 7z animation
				Log("7z - File already exists in """ . 7zExPCheck . """. Breaking out of 7z to load existing file",4)
				If fadeIn = true
				{	Log("7z - FadeIn is true, but no extraction needed as it already exists in 7z_Extract_Path. Using Fade_Layer_3_Animation instead.",4)
					GoSub, %fadeLyr3Animation%	; still need to provide an animation because the 7z one won't trigger below
				}
			}
		} Else If 7zE in %7zFormats%	; only need this condition if using the standard 7z method
		{	Log("7z - Provided rom extension """ . 7zE . """ is not an archive type, turning off 7z and running rom directly.")
			7zEnabled = false	; need to tell the animation to load a non-7z animation
			If fadeIn = true
				GoSub, %fadeLyr3Animation%	; still need to provide an animation because the we are already passed the FadeInStart GoSub
		}

		; This section is seperate because I use a couple methods in the above block of code and the below code would be duplicated it it was moved up.
		; If ((romIn7z = "true" || skipchecks != "false") && !romFound) { ; we found the rom in the archive or we are skipping looking alltogether
		If ((romIn7z = "true" || (skipchecks != "false" && 7zUsed)) && romFound != "true") {
			Log("7z - " . (If romIn7z = "true" ? "File found in archive" : "Skipchecks is enabled`, and set to " . skipChecks . " continuing to extract rom."),4)
			; 7zExP := 7zExP . "\" . (If 7zAttachSystemName = "true" ? systemName . "\" : "") . 7zN	; unsure what this was for but its causing 7zExPCheck to keep adding on path names on each loop

			pathLength := StrLen(7zExPCheck . "\" . dllName . "." . dllExt)	; check length and error if there will be a problem.
			If pathLength > 255
				ScriptError("If you extract this rom, the path length will be " . pathLength . "`, exceeding 255 characters`, a Windows limitation. Please choose a shorter 7z_Extract_Path or shorten the name of your rom.")
			Else
				Log("7z - Extracted path of rom will be " . pathLength . " in length and within the 255 character limit.")

			If fadeIn = true
			{	Log("7z - FadeIn is true, starting timer to update Layer 3 animation with 7z.exe statistics",4)
				SetTimer, UpdateFadeFor7z, -1	; Create a new timer to start updating Layer 3 of fade
			}

			Log("7z - Starting 7z extraction of " . 7zP . "\" . 7zN . 7zE . "  to " . 7zRomPath,4)
			RunWait, %7zPath% x "%7zP%\%7zN%%7zE%" -aoa -o"%7zRomPath%",,Hide ; perform the extraction and overwrite all
			If ErrorLevel
			{	If ErrorLevel = 1
					Error = Non fatal error, file may be in use by another application
				Else If ErrorLevel = 2
					Error = Fatal Error. Possibly out of space on drive.
				Else If ErrorLevel = 7
					Error = Command line error
				Else If ErrorLevel = 8
					Error = Not enough memory for operation
				Else If ErrorLevel = 255
					Error = User stopped the process
				Else
					Error = Unknown 7zip Error
				ScriptError("7zip.exe Error: " . Error)
			}
			Log("7z - Finished 7z extraction",4)
			If (FileExist(7zExPCheck . "\" . dllName . "." . dllExt) || skipchecks != "false") { ; after extracting, if the rom now exists in our temp dir, or we are skipping looking, update 7zE, and break out
				7zP := 7zExPCheck
				7zE = .%dllExt%
				If skipChecks != Rom Extension
					7zN := dllName	; update the romName just in case it was different from the name supplied to 7z, never update 7zN if skipChecks is set to Rom Extension
				used7z = true	; this will tell 7zCleanup that 7z was used to extract a rom
				romFound = true
				; 7zN := dllName
				If skipChecks not in Rom Only,Rom and Emu
					Log("7z - Found file in " . 7zExPCheck . "\" . dllName . "." . dllExt,4)
			} Else { ; after extraction, rom was not found in the temp dir, something went wrong...
				romFound = false
				foundExt := "." . dllExt
			}
		}
		If 7zUsed {
			If !romFound	; no need to error that a rom is not found if we are not supplying a rom to 7z
				ScriptError("No valid roms found in the archive " . 7zN . 7zE . "`n Please make sure Rom_Extension contains a rom extension inside the archive: " . romExtensions,10)
			Else If romFound = false	; no need to error that a rom is not found if we are not supplying a rom to 7z
				ScriptError("No extracted files found in " . 7zExP . "`nCheck that you are not exceeding the 255 character limit and this file is in the root of your archive:`n" . 7zN . foundExt,10)
			If 7z1stUse = 1	; If this is the first time 7z was used (rom launched from FE), set this var so that 7zCleanup knows where to find it for deletion. MultiGame extractions will be stored in the romTable for deletion.
				7z1stRomPath := 7zRomPath
		} Else
			Log("7z - This rom type does not need 7z: """ . 7zE . """")
		Log("7z - Ended")
	}
}

7zCleanUp() {
	Global romTable,dbName,mgEnabled
	Global 7zEnabled,7zDelTemp,7zCanceled,7z1stRomPath
	If (7zEnabled = "true" && (7zDelTemp = "true" or 7zCanceled))	; if user wants to delete temp files or user canceled a 7z extraction
	{	Log("7zCleanUp - Started")
		romTableExists := IsObject(romTable)	; if romTable was ever created, it would be an object, which is what this checks for
		If (mgEnabled = "true"  && romTableExists)
		{	Log("7zCleanUp - romTable exists and MG is enabled. Parsing the table to delete any roms that were extracted",4)
			for index, element in romTable
				If % romTable[A_Index, 19]
				{	FileRemoveDir, % romTable[A_Index, 19], 1	; remove each game that was extracted with 7z
					Log("7zCleanUp - Deleted " . romTable[A_Index, 19],4)
				}
				FileRemoveDir, %7z1stRomPath%, 1 ; still have to remove the rom we launched from HS
				Log("7zCleanUp - Deleted " . 7z1stRomPath,4)
		} Else {
			FileRemoveDir, %7z1stRomPath%, 1
			Log("7zCleanUp - Deleted " . 7z1stRomPath,4)
		}
		Log("7zCleanUp - Ended")
	}
}

; http://www.autohotkey.com/forum/post-509873.html#509873
StdoutToVar_CreateProcess(sCmd, bStream = False, sDir = "", sInput = "")
{
	DllCall("CreatePipe", "UintP", hStdInRd , "UintP", hStdInWr , "Uint", 0, "Uint", 0)
	DllCall("CreatePipe", "UintP", hStdOutRd, "UintP", hStdOutWr, "Uint", 0, "Uint", 0)
	DllCall("SetHandleInformation", "Uint", hStdInRd , "Uint", 1, "Uint", 1)
	DllCall("SetHandleInformation", "Uint", hStdOutWr, "Uint", 1, "Uint", 1)
	VarSetCapacity(pi, 16, 0)
	NumPut(VarSetCapacity(si, 68, 0), si)	; size of si
	NumPut(0x100	, si, 44)		; STARTF_USESTDHANDLES
	NumPut(hStdInRd	, si, 56)		; hStdInput
	NumPut(hStdOutWr, si, 60)		; hStdOutput
	NumPut(hStdOutWr, si, 64)		; hStdError
	If Not	DllCall("CreateProcess", "Uint", 0, "Uint", &sCmd, "Uint", 0, "Uint", 0, "int", True, "Uint", 0x08000000, "Uint", 0, "Uint", sDir ? &sDir : 0, "Uint", &si, "Uint", &pi)	; bInheritHandles and CREATE_NO_WINDOW
		ExitApp
	DllCall("CloseHandle", "Uint", NumGet(pi,0))
	DllCall("CloseHandle", "Uint", NumGet(pi,4))
	DllCall("CloseHandle", "Uint", hStdOutWr)
	DllCall("CloseHandle", "Uint", hStdInRd)
	If	sInput <>
	DllCall("WriteFile", "Uint", hStdInWr, "Uint", &sInput, "Uint", StrLen(sInput), "UintP", nSize, "Uint", 0)
	DllCall("CloseHandle", "Uint", hStdInWr)
	bStream ? (bAlloc:=DllCall("AllocConsole"),hCon:=DllCall("CreateFile","str","CON","Uint",0x40000000,"Uint",bAlloc ? 0 : 3,"Uint",0,"Uint",3,"Uint",0,"Uint",0)) : ""
	VarSetCapacity(sTemp, nTemp:=bStream ? 64-nTrim:=1 : 4095)
	Loop
		If	DllCall("ReadFile", "Uint", hStdOutRd, "Uint", &sTemp, "Uint", nTemp, "UintP", nSize:=0, "Uint", 0)&&nSize
		{
			NumPut(0,sTemp,nSize,"Uchar"), VarSetCapacity(sTemp,-1), sOutput.=sTemp
			If	bStream&&hCon+1
				Loop
					If	RegExMatch(sOutput, "[^\n]*\n", sTrim, nTrim)
						DllCall("WriteFile", "Uint", hCon, "Uint", &sTrim, "Uint", StrLen(sTrim), "UintP", nSize:=0, "Uint", 0)&&nSize ? nTrim+=nSize : ""
					Else	Break
		}
		Else	Break
	DllCall("CloseHandle", "Uint", hStdOutRd)
	bStream ? (DllCall("Sleep","Uint",1000),hCon+1 ? DllCall("CloseHandle","Uint",hCon) : "",bAlloc ? DllCall("FreeConsole") : "") : ""
	Return	sOutput
}

; CheckForRomExt() {
	; Global romExtensions,7zFormatsNoP,skipChecks
	; If skipChecks not in Rom Only,Rom and Emu
	; {	Log("CheckForRomExt - Started")
		; Loop, Parse, romExtensions, |
		; {	If A_LoopField in %7zFormatsNoP%
			; {	notFound = 1
				; Continue
			; } Else {
				; Log("CheckForRomExt - Ended - Rom extensions found in " . romExtensions)
				; Return
			; }
		; }
		; If notFound = 1
			; ScriptError("You did not supply any valid rom extensions to search for in your compressed roms. Please turn off 7z support or add at least one rom extension to Rom_Extension: " . romExtensions)
	; }
; }

GetTimeString(time)
{
    if(time<0)
        return time
    if time is not number
        return time
	Days := time // 86400
	Hours := Mod(time, 86400) // 3600
	Minutes := Mod(time, 3600) // 60
	Seconds := Mod(time, 60)
	if(Days<>0){
		If Strlen(Hours) = 1
		Hours = 0%Hours%
		If Strlen(Minutes) = 1
		Minutes = 0%Minutes%
		If Strlen(Seconds) = 1
		Seconds = 0%Seconds%
		TimeString = %Days% d %Hours% h %Minutes% m %Seconds% s
	} else if(Hours<>0){
		If Strlen(Minutes) = 1
		Minutes = 0%Minutes%
		If Strlen(Seconds) = 1
		Seconds = 0%Seconds%
		TimeString = %Hours% h %Minutes% m %Seconds% s
	} else if(Minutes<>0) {
        If Strlen(Seconds) = 1
		Seconds = 0%Seconds%
		TimeString = %Minutes% m %Seconds% s
    } else if(Seconds<>0) {
        TimeString = %Seconds% s
    } else {
	    TimeString = 
    }
	return TimeString
}

; Display Resolution functions
; http://www.autohotkey.com/forum/topic8355.html
ChangeDisplaySettings( sW, sH, cD, rR ) { ; Change Screen Resolution
	VarSetCapacity(dM,156,0), NumPut(156,dM,36)
	DllCall( "EnumDisplaySettingsA", UInt,0, UInt,-1, UInt,&dM ), NumPut(0x5c0000,dM,40)
	NumPut(cD,dM,104),  NumPut(sW,dM,108),  NumPut(sH,dM,112),  NumPut(rR,dM,120)
	Return DllCall( "ChangeDisplaySettingsA", UInt,&dM, UInt,0 )
}

; Acquire display "index" screen resolution (index=0,1,...)
GetDisplaySettings(Index) {
	VarSetCapacity(device_mode,156,0)
	success:=DllCall("EnumDisplaySettings","uint",0,"uint",Index-1,"uint",&device_mode)
	If (ErrorLevel or !success)
		Return "Break"
	Out_1:=NumGet(&device_mode,108,"uint4")	;width
	Out_2:=NumGet(&device_mode,112,"uint4")	;height
	Out_3:=NumGet(&device_mode,104,"uint4")	;quality
	Out_4:=NumGet(&device_mode,120,"uint4")	;frequency
	Return Out_1 "|" Out_2 "|" Out_3 "|" Out_4
} ; out "Break"

; Acquire current display screen resolution (1=width	2=height	3=quality	4=frequency)
CurrentDisplaySettings(in=0) {
	VarSetCapacity(device_mode,156,0),NumPut(156,2,&device_mode,36)
	success := DllCall("EnumDisplaySettings","uint",0,"uint",-1,"uint",&device_mode)
	Out_1:=NumGet(&device_mode,108,"uint4")	;width
	Out_2:=NumGet(&device_mode,112,"uint4")	;height
	Out_3:=NumGet(&device_mode,104,"uint4")	;quality
	Out_4:=NumGet(&device_mode,120,"uint4")	;frequency
	If in = 0
		Return Out_1 "|" Out_2 "|" Out_3 "|" Out_4
	Else Return (Out_%in%)
}

; Enumerate Supported Screen Resolutions
 EnumDisplaySettings() {
	VarSetCapacity(DM,156,0), NumPut(156,&DM,36, "UShort")
	DllCall( "EnumDisplaySettings", UInt,0, UInt,-1, UInt,&DM )
	CS:=NumGet(DM,108) "|" NumGet(DM,112) "|" NumGet(DM,104) "|" NumGet(DM,120)
	Loop
		If DllCall( "EnumDisplaySettings", UInt,0, UInt,A_Index-1, UInt,&DM )
		{	EDS:=NumGet(DM,108) "|" NumGet(DM,112) "|" NumGet(DM,104) "|" NumGet(DM,120)
			DS.=(!InStr(DS,EDS) ? "," EDS : "")
		} Else
			Break
	StringReplace, DS, DS, %CS%|, %CS%||, All
Return SubStr(DS,2)
}

; Check if a given screen resolution is supported by the monitor, and if not chooses the nearest one that is
CheckForNearestSupportedRes(resVar){
	listOfSupportedRes := EnumDisplaySettings()
	If res in %listOfSupportedRes%
		Return supportedRes
	Stringsplit, desiredResArray, resVar,|
	ResArray := []
	Loop, parse, listOfSupportedRes, `,
		{
		currentRes := a_index
		ResArray[currentRes,1] := A_LoopField
		Loop, parse, A_LoopField, |
			{
			ResArray[currentRes,a_index+1] := A_LoopField
		}
		ResArray[currentRes,6] := ResArray[currentRes,2] - desiredResArray1
		ResArray[currentRes,7] := ResArray[currentRes,3] - desiredResArray2 
		ResArray[currentRes,8] := ResArray[currentRes,4] - desiredResArray3
		ResArray[currentRes,9] := ResArray[currentRes,5] - desiredResArray4
	}
	previousDeviation := 10**9
	Loop, %currentRes%
		{
		currentDeviation := 100*ResArray[a_index,6]*ResArray[a_index,6] + 100*ResArray[a_index,7]*ResArray[a_index,7] + 10*ResArray[a_index,8]*ResArray[a_index,8] + ResArray[a_index,9]*ResArray[a_index,9]
		If (currentDeviation < previousDeviation) {
			previousDeviation := currentDeviation
			supportedRes := ResArray[a_index,2] . "|" ResArray[a_index,3] . "|" ResArray[a_index,4] . "|" ResArray[a_index,5]
		}
	}
Return supportedRes
}