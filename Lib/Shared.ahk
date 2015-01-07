MCRC=6B4F9212
MVersion=1.2.1

StartModule(){
	Global gameSectionStartTime,gameSectionStartHour,skipChecks,dbName,romPath,romName,romExtension,systemName,moduleName,MEmu,MEmuV,MURL,MAuthor,MVersion,MCRC,iCRC,MSystem,romMapTable,romMappingLaunchMenuEnabled,romMenuRomName,7zEnabled,hideCursor,toggleCursorKey,winVer,zz
	Global mgEnabled,mgOnLaunch,mgCandidate,mgLaunchMenuActive,MultiGame_Running
	Global rIniIndex,globalPluginsFile,sysPluginsFile
	Log("StartModule - Started")
	Log("StartModule - MEmu: " . MEmu . "`r`n`t`t`t`t`tMEmuV: " . MEmuV . "`r`n`t`t`t`t`tMURL: " . MURL . "`r`n`t`t`t`t`tMAuthor: " . MAuthor . "`r`n`t`t`t`t`tMVersion: " . MVersion . "`r`n`t`t`t`t`tMCRC: " . MCRC . "`r`n`t`t`t`t`tiCRC: " . iCRC . "`r`n`t`t`t`t`tMID: " . MID . "`r`n`t`t`t`t`tMSystem: " . MSystem)
	If InStr(MSystem,systemName)
		Log("StartModule - You have a supported System Name for this module: """ . systemName . """")
	Else
		Log("StartModule - You have an unsupported System Name for this module: """ . systemName . """. Only the following System Names are suppported: """ . MSystem . """",2)
		
	winVer := If A_Is64bitOS ? "64" : "32"	; get windows version
	
	;-----------------------------------------------------------------------------------------------------------------------------------------
	 ; Plugin Specific Settings from Settings \ Global Plugins.ini and Settings \ %systemName% \ Plugins.ini
	;-----------------------------------------------------------------------------------------------------------------------------------------
	rIniIndex := {}	; initialize the RIni array
	globalPluginsFile := A_ScriptDir . "\Settings\Global Plugins.ini"
	IfNotExist, %globalPluginsFile%
		FileAppend,, %globalPluginsFile%	; create blank ini
	RIni_Read(8,globalPluginsFile)
	rIniIndex[8] := globalPluginsFile	; assign to array

	sysPluginsFile := A_ScriptDir . "\Settings\" . systemName . "\Plugins.ini"
	IfNotExist, %sysPluginsFile%
		FileAppend,, %sysPluginsFile%	; create blank ini
	RIni_Read(9,sysPluginsFile)
	rIniIndex[9] := sysPluginsFile	; assign to array

	Gosub, PluginInit	; initialize plugin vars
	; Gosub, ReadFEGameInfo	; read plugin data
	;-----------------------------------------------------------------------------------------------------------------------------------------

	If (mgEnabled = "true" && mgOnLaunch = "true" && mgCandidate) {	; only if user has mgOnLaunch enabled
		mgLaunchMenuActive := true
		Log("StartModule - MultiGame_On_Launch execution started.",4)
		Gosub, StartMulti
		Sleep, 200
		Loop {
			If !MultiGame_Running
				Break
		}
		mgLaunchMenuActive := false
		Log("StartModule - MultiGame_On_Launch execution ended.",4)
	}
	If (romMappingLaunchMenuEnabled = "true" && romMapTable.MaxIndex()) ; && romMapMultiRomsFound)
		CreateRomMappingLaunchMenu%zz%(romMapTable)
; msgbox dbName: %dbName%`nromName: %romName%`nromMenuRomName: %romMenuRomName%`n7zEnabled: %7zEnabled%`nskipChecks: %skipChecks%
	If (skipChecks != "false" && romMenuRomName && 7zEnabled = "false")	; this is to support the scenario where Rom Map Launch Menu can send a rom that does not exist on disk or in the archive (mame clones)
	{	Log("StartModule - Setting romName to the game picked from the Launch Menu: " . romMenuRomName,4)
		romName := romMenuRomName
	} Else If romName && romMapTable.MaxIndex()
	{	Log("StartModule - Leaving romName as is because Rom Mapping filled it with an Alternate_Rom_Name: " . romName,4)
		romName := romName	; When Rom Mapping is used but no Alternate_Archive_Name key exists yet Alternate_Rom_Name key(s) were used.
	} Else If romMapTable.MaxIndex()
	{	Log("StartModule - Not setting romName because Launch Menu was used and 7z will take care of it.",4)
		romName := 	; If a romMapTable exists with roms, do not fill romName yet as 7z will take care of that.
	} Else
	{	Log("StartModule - Setting romName to the dbName sent to HyperLaunch: " . dbName,4)
		romName := dbName	; Use dbName if previous checks are false
	}
	If (moduleName != "PCLauncher") {	; PCLauncher has its own cursor control so we do not control the cursor here
		If (hideCursor = "true")	; PCLauncher controls its own cursor hiding so HL should never touch this
			SystemCursor("Off")
		Else If (hideCursor = "custom") {
			cursor := GetHLMediaFiles("Cursors","cur|ani") ;load cursor file for the system if they exist
			If cursor
				SetSystemCursor(Cursor) ; replace system cursors
		}
	}
	If toggleCursorKey
		XHotKeywrapper(toggleCursorKey,"ToggleCursor")
	; romName := If romName ? romName : If romMapTable.MaxIndex() ? "" : dbName	; OLD METHOD, keeping this here until the split apart conditionals have been tested enough. ; if romName was filled at some point, use it, else if a romMapTable exists with roms, do not fill romName yet as 7z will take care of that. Use dbName if previous checks are false
	gameSectionStartTime := A_TickCount
	gameSectionStartHour := A_Now
	; msgbox % "romPath: " . romPath . "`nromName: " . romName . "`nromExtension: " . romExtension . "`nromMenuRomName: " . romMenuRomName . "`nromMapTable.MaxIndex(): " . romMapTable.MaxIndex()
	Log("StartModule - Ended")
}

; ExitModule function in case we need to call anything on the module's exit routine, like UpdateStatistics for HyperPause or UnloadKeymapper
ExitModule(){
	Global statisticsEnabled,keymapperEnabled,keymapper,keymapperAHKMethod,logShowCommandWindow,pToken,cmdWindowObj,mouseCursorHidden,cursor,hideCursor,hyperlaunchIsExiting,servoStikEnabled,zz
	Log("ExitModule - Started")
	hyperlaunchIsExiting := 1	; notifies rest of the thread that the exit routine was triggered
	If statisticsEnabled = true
		Gosub, UpdateStatistics
	If keymapperEnabled = true
		RunKeyMapper%zz%("unload",keymapper)
	If keymapperAHKMethod = External
		RunAHKKeymapper%zz%("unload")
	If ((hideCursor = "custom") and cursor)
		RestoreCursors()	; retore default system cursors
	If mouseCursorHidden	; just in case
		SystemCursor("On")
	If (servoStikEnabled = 4 || servoStikEnabled = 8)
		ServoStik(servoStikEnabled)	; handle servostiks on exit
	If logShowCommandWindow = true
		Loop {
			If !cmdWindowObj[A_Index,"Name"]
				Break
			Else {
				Log("ExitModule - Closing command window: " . cmdWindowObj[A_Index,"Name"] . " PID: " . cmdWindowObj[A_Index,"PID"],4)
				Process("Close", cmdWindowObj[A_Index,"Name"])	; close each opened cmd.exe
			}
		}
	Gdip_Shutdown(pToken)	; gdi+ may now be shutdown on exiting the thread
	Log("ExitModule - Ended")
	Log("End of Module Logs",,,1)
	ExitApp
}

WinWait(winTitle,winText="",secondsToWait=30,excludeTitle="",excludeText=""){
	Global detectFadeErrorEnabled, logLevel
	If logLevel > 3
		GetActiveWindowStatus()
	Log("WinWait - Waiting for """ . winTitle . """")
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
	Global detectFadeErrorEnabled, logLevel, emulatorProcessID, emulatorVolumeObject, emulatorInitialMuteState, fadeMuteEmulator, fadeIn
	If logLevel > 3
		GetActiveWindowStatus()
	Log("WinWaitActive - Waiting for """ . winTitle . """")
	WinWaitActive, %winTitle% ,%winText% , %secondsToWait% , %excludeTitle% ,%excludeText%
	curErr := ErrorLevel	; have to store this because GetActiveWindowStatus will reset it
	If logLevel > 3
		GetActiveWindowStatus()
	If (curErr and detectFadeErrorEnabled = "true")
		ScriptError("There was an error waiting for the window """ . winTitle . """ to become active. Please check you have the correct version emulator installed for this module, followed any notes in the module, and have this emulator working outside your Frontend first. Also turn off Fade to see if you are hiding your problem.",10)
	Else If (curErr and detectFadeErrorEnabled != "true")
		Log("There was an error waiting for the window """ . winTitle . """ to become active. Please check you have the correct version emulator installed for this module, followed any notes in the module, and have this emulator working outside your Frontend first. Also turn off Fade to see if you are hiding your problem.",3)
	if !curErr
		{
		WinGet emulatorProcessID, PID, %winTitle%
		emulatorVolumeObject := GetVolumeObject(emulatorProcessID)
		if ((fadeMuteEmulator = "true") and (fadeIn = "true")){
			getMute(emulatorInitialMuteState, emulatorVolumeObject)
			setMute(1, emulatorVolumeObject)
		}
	}
	Return curErr
}

WinWaitClose(winTitle,winText="",secondsToWait="",excludeTitle="",excludeText=""){
	Log("WinWaitClose - Waiting for """ . winTitle . """ to close")
	WinWaitClose, %winTitle% ,%winText% , %secondsToWait% , %excludeTitle% ,%excludeText%
	Return ErrorLevel
}

WinClose(winTitle,winText="",secondsToWait="",excludeTitle="",excludeText=""){
	Log("WinClose - Closing: " . winTitle)
	WinClose, %winTitle%, %winText% , %secondsToWait%, %excludeTitle%, %excludeText%
	If (secondsToWait = "" || !secondsToWait)
		secondsToWait := 2	; need to always have some timeout for this command otherwise it will wait forever
	WinWaitClose, %winTitle%, %winText% , %secondsToWait%, %excludeTitle%, %excludeText%	; only WinWaitClose reports an ErrorLevel
	Return ErrorLevel
}

; To disable inputBlocker on a specific Run call, set inputBlocker to 0, or to force it a specified amount of seconds (upto 30), set it to that amount.
; By default, options will enable all calls of Run() to return errorlevel within the function. However, it will only be returned if errorLevelReporting is true
; bypassCmdWindow - some apps will never work with the command window, like xpadder. enable this argument on these Run calls so it doesn't get caught here
Run(target,workingDir="",options=1,ByRef outputVarPID="",inputBlocker=1,bypassCmdWindow=0){
	Static cmdWindowCount
	Global logShowCommandWindow,logCommandWindow,cmdWindowObj,blockInputTime,blockInputFile,errorLevelReporting
	options := If useErrorLevel = 1 ? "useErrorLevel" : options	; enable or disable error level
	Log("Run - Running: " . workingDir . "\" . target)
	If (blockInputTime && inputBlocker = 1)	; if user set a block time, use the user set length
		blockTime := blockInputTime
	Else If inputBlocker > 1	; if module called for a block, use that amount
		blockTime := inputBlocker
	Else	; do not block input
		blockTime :=
	If blockTime
	{	Log("Run - Blocking Input for: " . blockTime . " seconds")
		Run, %blockInputFile% %blockTime%
	}
	If !cmdWindowObj
		cmdWindowObj := Object()	; initialize object, this is used so all the command windows can be properly closed on exit
	If (logShowCommandWindow = "true" && !bypassCmdWindow) {
		Run, %ComSpec% /k, %workingDir%, %options%, outputVarPID	; open a command window (cmd.exe), starting in the directory of the target executable
		curErr := ErrorLevel	; store error level immediately
		If errorLevelReporting = true
		{	Log("Run - Error Level for " . ComSpec . " reported as: " . curErr, 4)
			errLvl := curErr	; allows the module to handle the error level
		}
		Log("Run - Showing Command Window to troubleshoot launching. ProcessID: " . outputVarPID)
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
		WinGet, procName, ProcessName, ahk_pid %outputVarPID%	; get the name of the process (which should usually be cmd.exe)
		mapObjects[currentObj,"type"] := "database"
		cmdWindowCount++
		cmdWindowObj[cmdWindowCount,"Name"] := procName	; store the ProcessName being ran
		cmdWindowObj[cmdWindowCount,"PID"] := outputVarPID	; store the PID of the application being ran
		If logCommandWindow = true
			SendInput, {Raw}%target% 1>"%A_ScriptDir%\command_%cmdWindowCount%_output.log" 2>"%A_ScriptDir%\command_%cmdWindowCount%_error.log"	; send the text to the command window and log the output to file
		Else
			SendInput, {Raw}%target%	; send the text to the command window and run it
		Send, {Enter}
	} Else {
		Run, %target%, %workingDir%, %options%, outputVarPID
		curErr := ErrorLevel	; store error level immediately
		If errorLevelReporting = true
		{	Log("Run - Error Level for " . target . " reported as: " . curErr, 4)
			errLvl := curErr	; allows the module to handle the error level
		}
	}
	Log("Run - """ . target . """ Process ID: " . outputVarPID, 4)
	Return errLvl
}

Process(cmd,name,param=""){
	Log("Process - " . cmd . A_Space . name . A_Space . param)
	Process, %cmd%, %name%, %param%
	Return ErrorLevel
}

SetKeyDelay(delay="",pressDur="",play="") {
	Global pressDuration
	If (delay = "")	; -1 is the default delay for play mode and 10 for event mode when none is supplied
		delay := (If play = "" ? 10 : -1)
	If (pressDur = "")	; -1 is the default pressDur when none is supplied
		pressDur := -1

	Log("SetKeyDelay - Current delay is " . A_KeyDelay  . ". Current press duration is " . pressDuration . ". Delay will now be set to """ . delay . """ms for a press duration of """ . pressDur . """", 4)
	SetKeyDelay, %delay%, %pressDur%, %play%
	pressDuration := pressDur	; this is so the current pressDuration can be monitored outside the function
}

; Purpose: Handle an emulators Open Rom window when CLI is not an option
; Returns 1 when successful
OpenROM(windowName,selectedRomName) {
	Log("OpenROM - Started")
	Global MEmu,moduleName
	WinWait(windowName)
	WinWaitActive(windowName)
	state := 0
	Loop, 150	; 15 seconds
	{	ControlSetText, Edit1, %selectedRomName%, %windowName%
		ControlGetText, edit1Text, Edit1, %windowName%
		If (edit1Text = selectedRomName) {
			state := 1
			Log("OpenROM - Successfully set romName into """ . windowName . """ in " . A_Index . " " . (If A_Index = 1 ? "try." : "tries."),4)
			Break
		}
		Sleep, 100
	}
	If (state != 1)
		ScriptError("Tried for 15 seconds to send the romName to " . MEmu . " but was unsuccessful. Please try again with Fade and Bezel disabled and put the " . moduleName . " in windowed mode to see if the problem persists.", 10)
	PostMessage, 0x111, 1,,, %windowName% ; Select Open
	Log("OpenROM - Ended")
	Return %state%
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
; allowFolder = allows folders or files w/o an extension to be checked. By default a file must have an extension.
CheckFile(file,msg="",timeout=6,crc="",crctype="",logerror="",allowFolder=0){
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
	SplitPath, file, fileName, filePath, fileExt, fileNameNoExt
	If !FileExist(filePath . "\" . fileName)
		If msg
			ScriptError(msg, timeout)
		Else
			ScriptError("Cannot find " . file, timeout)
	If (!fileExt && !allowFolder)
		ScriptError("This is a folder and must point to a file instead: " . file, timeout)

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

CheckFolder(folder,msg="",timeout=6,crc="",crctype="",logerror="") {
   Return CheckFile(folder,msg,timeout,crc,crctype,logerror,1)
}

; ScriptError usage:
; error = error text
; timeout = duration in seconds error will show
; w = width of error box
; h = height of error box
; txt = font size
ScriptError(error,timeout=6,w=800,h=225,txt=20){
	Global HLMediaPath,exitScriptKey,HLFile,HLErrSoundPath,logShowCommandWindow,cmdWindowObj
	Global screenRotationAngle,baseScreenWidth,baseScreenHeight,xTranslation,yTranslation,XBaseRes,YBaseRes

	XHotKeywrapper(exitEmulatorKey,"CloseProcess","OFF")
	XHotKeywrapper(exitEmulatorKey,"CloseError","ON")
	Hotkey, Esc, CloseError
	Hotkey, Enter, CloseError
	
	If !pToken := Gdip_Startup(){	; Start gdi+
		MsgBox % "Gdiplus failed to start. Please ensure you have gdiplus on your system"
		ExitApp
	}

	timeout *= 1000	; converting to seconds
	;Acquiring screen info for dealing with rotated menu drawings
	Gdip_Alt_GetRotatedDimensions(A_ScreenWidth, A_ScreenHeight, screenRotationAngle, baseScreenWidth, baseScreenHeight)
	Gdip_GetRotatedTranslation(baseScreenWidth, baseScreenHeight, screenRotationAngle, xTranslation, yTranslation)
	xTranslation:=round(xTranslation), yTranslation:=round(yTranslation)
		XBaseRes := 1920, YBaseRes := 1080
	If (((A_screenWidth < A_screenHeight) and ((screenRotationAngle=0) or (screenRotationAngle=180))) or ((A_screenWidth > A_screenHeight) and ((screenRotationAngle=90) or (screenRotationAngle=270))))
		XBaseRes := 1080, YBaseRes := 1920
	if !errorXScale 
		errorXScale := baseScreenWidth/XBaseRes
	if !errorYScale
		errorYScale := baseScreenHeight/YBaseRes
	Error_Warning_Width := w
    Error_Warning_Height := h
    Error_Warning_Pen_Width := 7
    Error_Warning_Rounded_Corner := 30
    Error_Warning_Margin := 30
    Error_Warning_Bitmap_Size := 125
    Error_Warning_Text_Size := txt
    OptionScale(Error_Warning_Width, errorXScale)
    OptionScale(Error_Warning_Height, errorYScale)
    OptionScale(Error_Warning_Pen_Width, errorXScale)    
    OptionScale(Error_Warning_Rounded_Corner, errorXScale)  
    OptionScale(Error_Warning_Margin, errorXScale)    
    OptionScale(Error_Warning_Bitmap_Size, errorXScale)
    OptionScale(Error_Warning_Text_Size, errorYScale)

	;Create error GUI
	Gui, Error_GUI: +Disabled -Caption +E0x80000 +OwnDialogs +LastFound +ToolWindow +AlwaysOnTop
	Gui, Error_GUI: Margin,0,0
	Gui, Error_GUI: Show,, ErrorLayer
	Error_hwnd := WinExist()
	Error_hbm := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
	Error_hdc := CreateCompatibleDC()
	Error_obm := SelectObject(Error_hdc, Error_hbm)
	Error_G := Gdip_GraphicsFromhdc(Error_hdc)
	Gdip_SetSmoothingMode(Error_G, 4)
	Gdip_TranslateWorldTransform(Error_G, xTranslation, yTranslation)
	Gdip_RotateWorldTransform(Error_G, screenRotationAngle)
	pGraphUpd(Error_G,baseScreenWidth, baseScreenHeight)

	;Create GUI elements
	pBrush := Gdip_BrushCreateSolid("0xFF000000")	; Painting the background color
	Gdip_Alt_FillRectangle(Error_G, pBrush, -1, -1, baseScreenWidth+1, baseScreenHeight+1)	; draw the background first on layer 1 first, layer order matters!!
	brushWarningBackground := Gdip_CreateLineBrushFromRect(0, 0, Error_Warning_Width, Error_Warning_Height, 0xff555555, 0xff050505)
	penWarningBackground := Gdip_CreatePen(0xffffffff, Error_Warning_Pen_Width)
	Gdip_Alt_FillRoundedRectangle(Error_G, brushWarningBackground, (baseScreenWidth - Error_Warning_Width)//2, (baseScreenHeight - Error_Warning_Height)//2, Error_Warning_Width, Error_Warning_Height, Error_Warning_Rounded_Corner)
	Gdip_Alt_DrawRoundedRectangle(Error_G, penWarningBackground, (baseScreenWidth - Error_Warning_Width)//2, (baseScreenHeight - Error_Warning_Height)//2, Error_Warning_Width, Error_Warning_Height, Error_Warning_Rounded_Corner)
	WarningBitmap := Gdip_CreateBitmapFromFile(HLMediaPath . "\Menu Images\HyperLaunch\Warning.png")
	Gdip_Alt_DrawImage(Error_G,WarningBitmap, round((baseScreenWidth - Error_Warning_Width)//2 + Error_Warning_Margin),round(baseScreenHeight/2 - Error_Warning_Bitmap_Size/2),Error_Warning_Bitmap_Size,Error_Warning_Bitmap_Size)
	Gdip_Alt_TextToGraphics(Error_G, error, "x" round((baseScreenWidth-Error_Warning_Width)//2+Error_Warning_Bitmap_Size+Error_Warning_Margin) " y" round((baseScreenHeight-Error_Warning_Height)//2+Error_Warning_Margin) " Left vCenter cffffffff r4 s" Error_Warning_Text_Size " Bold",, round((Error_Warning_Width - 2*Error_Warning_Margin - Error_Warning_Bitmap_Size)) , round((Error_Warning_Height - 2*Error_Warning_Margin)))

	startTime := A_TickCount
	Loop{	; fade in
		t := ((TimeElapsed := A_TickCount-startTime) < 300) ? (255*(timeElapsed/300)) : 255
		Alt_UpdateLayeredWindow(Error_hwnd,Error_hdc, 0, 0, baseScreenWidth, baseScreenHeight,t)
		If t >= 255
			Break
	}

	; Generate a random sound to play on a script error
	erSoundsAr:=[]	; initialize the array to store error sounds
	Loop, %HLErrSoundPath%\error*.mp3
		erSoundsAr.Insert(A_LoopFileName)	; insert each found error sound into an array
	Random, erRndmSound, 1, % erSoundsAr.MaxIndex()	; randomize what sound to play
	Log("ScriptError - Playing error sound: " . erSoundsAr[erRndmSound],4)
	setMute(0,emulatorVolumeObject)
	SoundPlay % If erSoundsAr.MaxIndex() ? (HLErrSoundPath . "\" . erSoundsAr[erRndmSound]):("*-64"), wait	; play the random sound if any exist, or default to the Asterisk windows sound
	Sleep, %timeout%

	CloseError:
		endTime := A_TickCount
		Loop {	; fade out
			t := ((TimeElapsed := A_TickCount-endTime) < 300) ? (255*(1-timeElapsed/300)) : 0
			Alt_UpdateLayeredWindow(Error_hwnd,Error_hdc, 0, 0, baseScreenWidth, baseScreenHeight,t)
			If t <= 0
				Break
		}

		XHotKeywrapper(exitEmulatorKey,"CloseError","OFF")
		XHotKeywrapper(exitEmulatorKey,"CloseProcess","ON")
		Gdip_DeleteBrush(pBrush)
		Gdip_DisposeImage(WarningBitmap), SelectObject(Error_hdc, Error_obm), DeleteObject(Error_hbm), DeleteDC(Error_hdc), Gdip_DeleteGraphics(Error_G)
		Gui, ErrorGUI_10: Destroy
		Gdip_Shutdown(pToken)	; gdi+ may now be shutdown on exiting the program
		Log(error,3)
		
		ExitModule()	; attempting to use this method which has the small chance to cause an infinite ScriptError loop, but no need to duplicate code to clean up on errors
		; Below cleanup exists because we can't call other functions that may cause additional scripterrors and put the thread in an infinite loop
		; If logShowCommandWindow = true
		; {	for index, element in cmdWindowObj
				; Process, Close, % cmdWindowObj[A_Index,1]	; close each opened cmd.exe
		; }
		; ExitApp
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
	Global logFile,logLevel,logLabel,logShowDebugConsole
	; Global executable
	If logLevel>0
	{
		If (lvl<=logLevel || lvl=3){	; ensures errors are always logged
			logDiff := A_TickCount - lastLog
			lastLog := A_TickCount
			log:=log . (If notime?"" : A_Hour . ":" . A_Min ":" . A_Sec ":" . A_MSec . " | MD | " . logLabel[lvl] . A_Space . " | +" . AlignColumn(If firstLog ? "N/A" : logDiff) . "" . " | ") . text . "`r`n"
		}
		If logShowDebugConsole = true
			DebugMessage(log)
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

; section: Allows | separated values so multiple sections can be checked.
IniReadCheck(file,section,key,defaultvalue="",errorMsg="",logType="") {
	Loop, Parse, section, |
	{	section%A_Index% := A_LoopField	; keep each parsed section in its own var
		If iniVar != ""	; if last loop's iniVar has a value, update this loop's default value with it
			defaultValue := If A_Index = 1 ? defaultValue : iniVar	; on first loop, default value will be the one sent to the function, on following loops it gets the value from the previous loop
		IniRead, iniVar, %file%, % section%A_Index%, %key%, %defaultvalue%
		If (IniVar = "ERROR" || iniVar = A_Space)	; if key does not exist or is a space, delete ERROR as the value
			iniVar :=
		If (A_Index = 1 && iniVar = ""  and !logType) {
			If errorMsg
				ScriptError(errorMsg)
			Else
				IniWrite, %defaultValue%, %file%, % section%A_Index%, %key%
			Return defaultValue
		}
		If logType	; only log if logType set
		{	logAr := ["Module","Bezel"]
			Log(logAr[logType] . " Setting - [" . section%A_Index% . "] - " . key . ": " . iniVar)
		}
		If iniVar != ""	; if IniVar contains a value, update the lastIniVar
			lastIniVar := iniVar
	}
	If defaultValue = %A_Space%	; this prevents the var from existing when it's actually blank
		defaultValue :=
	Return If A_Index = 1 ? iniVar : If lastIniVar != "" ? lastIniVar : defaultValue	; if this is the first loop, always return the iniVar. If any other loop, return the lastinivar if it was filled, otherwise send the last updated defaultvalue
}

; Rini returns -2 if section does not exist
; Rini returns -3 if key does not exist
; Rini returns -10 if an invalid reference var for the ini file was used
; Rini returns empty value if key exists with no value
; rIniIndex := Object(1,globalHLFile,2,sysHLFile,3,globalEmuFile,4,sysEmuFile,5,HLFile,6,gamesFile)
; preferDefault - On rare occasions we may want to set a default value w/o wanting rini to return an error value of -2 or -3. Used for JoyIDs_Preferred_Controllers
RIniLoadVar(gRIniVar,sRIniVar,section,key,gdefaultvalue="",sdefaultvalue="use_global",preferDefault="") {
	Global rIniIndex
	If gRIniVar != 6	; do not create missing sections or keys for games.ini
	{	gValue := RIni_GetKeyValue(gRIniVar,section,key,If preferDefault ? gdefaultvalue : "")
		gValue = %gValue%	; trims whitespace
		If gValue in -2,-3	; if global ini key does not exist, create the key
		{	RIni_SetKeyValue(gRIniVar,section,key,gdefaultvalue)
			RIni_Write(gRIniVar,rIniIndex[gRIniVar],"`r`n",1,1,1)
			gValue := gdefaultvalue	; set to default value because it did not exist
			Log("RIniLoadVar - Created missing Global ini key: """ . key . """ in section: """ . section . """ in """ . rIniIndex[gRIniVar] . """",2)
		}
		If sRIniVar	; != ""	; only create system sections or keys for inis that use them
		{	sValue := RIni_GetKeyValue(sRIniVar,section,key,If preferDefault ? sdefaultvalue : "")
			sValue = %sValue%	; trims whitespace
			If sValue in -2,-3	; if system ini key does not exist, create the key
			{	RIni_SetKeyValue(sRIniVar,section,key,sdefaultvalue)
				RIni_Write(sRIniVar,rIniIndex[sRIniVar],"`r`n",1,1,1)
				sValue := sdefaultvalue	; set to default value because it did not exist
				Log("RIniLoadVar - Created missing System ini key: """ . key . """ in section: """ . section . """ in """ . rIniIndex[sRIniVar] . """",2)
			}
			Return If sValue = "use_global" ? gValue : sValue	; now compare global & system keys to get final value
		}
		Return gValue	; return gValue when not using globa/system inis, like HLFile (rIniIndex 5)
	}
	iniVar := RIni_GetKeyValue(gRIniVar,section,key,gdefaultvalue)	; lookup key from ini and return it
	iniVar = %iniVar%	; trims whitespace
	Return iniVar
}

RIniReadCheck(rIniVar,section,key,defaultvalue="",errorMsg="") {
	Global rIniIndex
	iniVar := RIni_GetKeyValue(rIniVar,section,key)	; lookup key from ini and return it
	iniVar = %iniVar%	; trims whitespace
	If (iniVar = -2 or iniVar = -3 or iniVar = "") {
		If (iniVar != "") {	; with rini, no need write to ini file if value is returned empty, we already know the section\key exists with no value
			Log("RIniReadCheck - Created missing HyperLaunch ini key: """ . key . """ in section: """ . section . """ in """ . rIniIndex[rIniVar] . """",2)
			RIni_SetKeyValue(rIniVar,section,key,defaultvalue)
			RIni_Write(rIniVar,rIniIndex[rIniVar],"`r`n",1,1,1)	; write blank section, blank key, and space between sections
		}
		If errorMsg
			ScriptError(errorMsg)
		Return defaultValue
	}
	Return iniVar
}

CheckFont(font) {
	If !(Gdip_FontFamilyCreate(font))
		ScriptError("The Font """ . font . """ is not installed on your system. Please install the font or change it in HyperLaunchHQ.")
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
	Global baseScreenWidth, baseScreenHeight 
	widthMaxPercent := ( baseScreenWidth / w )	; get the percentage needed to maximumise the image so it reaches the screen's width
	heightMaxPercent := ( baseScreenHeight / h )
	If (pos = "Stretch and Lose Aspect") {	; image is stretched to screen, loosing aspect
		retW := baseScreenWidth
		retH := baseScreenHeight
		retX := 0
		retY := 0
	} Else If (pos = "Stretch and Keep Aspect") {	; image is stretched to Center screen, keeping aspect
		percentToEnlarge := If (widthMaxPercent < heightMaxPercent) ? widthMaxPercent : heightMaxPercent	; this basicallys says if the width's max reaches the screen's width first, use the width's percentage instead of the height's
		retW := Round(w * percentToEnlarge)	; multiply width by the percentage from above to reach as close to the edge as possible
		retH := Round(h * percentToEnlarge)	; multiply height by the percentage from above to reach as close to the edge as possible
		retX := ( baseScreenWidth / 2 ) - ( retW / 2 )	; find where to place the X of the image
		retY := ( baseScreenHeight / 2 ) - ( retH / 2 )	; find where to place the Y of the image
	} Else If (pos = "Center Width") {	; image is stretched to Center screen's width, keeping aspect
		percentToEnlarge := widthMaxPercent	; increase the image size by the percentage it takes to reaches the screen's width, cropping may occur on top and bottom
		retW := Round(w * percentToEnlarge)	; multiply width by the percentage from above to reach as close to the edge as possible
		retH := Round(h * percentToEnlarge)	; multiply height by the percentage from above to reach as close to the edge as possible
		retX := ( baseScreenWidth / 2 ) - ( retW / 2 )	; find where to place the X of the image
		retY := ( baseScreenHeight / 2 ) - ( retH / 2 )	; find where to place the Y of the image
	} Else If (pos = "Center Height") {	; image is stretched to Center screen's height, keeping aspect
		percentToEnlarge := heightMaxPercent	; increase the image size by the percentage it takes to reaches the screen's height, cropping may occur on left and right
		retW := Round(w * percentToEnlarge)	; multiply width by the percentage from above to reach as close to the edge as possible
		retH := Round(h * percentToEnlarge)	; multiply height by the percentage from above to reach as close to the edge as possible
		retX := ( baseScreenWidth / 2 ) - ( retW / 2 )	; find where to place the X of the image
		retY := ( baseScreenHeight / 2 ) - ( retH / 2 )	; find where to place the Y of the image
	} Else If (pos = "Center") {	; original image size and aspect
		retX := ( baseScreenWidth / 2 ) - ( w / 2 )	; find where to place the X of the image
		retY := ( baseScreenHeight / 2 ) - ( h / 2 )	; find where to place the Y of the image
	} Else If (pos = "Align to Bottom Left") {	; place the pic so the bottom left corner matches the screen's bottom left corner
		retH := baseScreenHeight
		retW := Round( w / ( h / baseScreenHeight ))
		If ( retW < baseScreenWidth ){
			retW := baseScreenWidth
			retH := Round( h / ( w / retW ))
		}
		retY := baseScreenHeight - retH
	} Else If (pos = "Align to Bottom Right") {	; place the pic so the bottom right corner matches the screen's bottom right corner
		retH := baseScreenHeight
		retW := Round( w / ( h / baseScreenHeight ))
		If ( retW < baseScreenWidth ){
			retW := baseScreenWidth
			retH := Round( h / ( w / retW ))
		}
		retX := baseScreenWidth - retW
		retY := baseScreenHeight - retH
	} Else If (pos = "Align to Top Right") {	; place the pic so the top right corner matches the screen's top right corner
		retH := baseScreenHeight
		retW := Round( w / ( h / baseScreenHeight ))
		If ( retW < baseScreenWidth ){
			retW := baseScreenWidth
			retH := Round( h / ( w / retW ))
		}
		retX := baseScreenWidth - retW
	} Else {	; place the pic so the top left corner matches the screen's top left corner, also the default
		retH := baseScreenHeight
		retW := Round( w / ( h / baseScreenHeight ))
		If ( retW < baseScreenWidth ){
			retW := baseScreenWidth
			retH := Round( h / ( w / retW ))
		}
	}
}

; Usage, params 1&2 are byref so supply the var you want to be filled with the calculated positions. Next 4 are the original pics xy,w,h. Last is the position the user wants.
GetFadePicPosition(ByRef retX, ByRef retY,x,y,w,h,pos){
	Global baseScreenWidth, baseScreenHeight 
	If (pos = "Stretch and Lose Aspect"){   ; image is stretched to screen, loosing aspect
		retX := 0
		retY := 0
	} Else If (pos = "Stretch and Keep Aspect")  {	; image is stretched to screen, keeping aspect
		retX := round(( baseScreenWidth / 2 ) - ( w / 2 ))	
		retY := round(( baseScreenHeight / 2 ) - ( h / 2 ))
	} Else If (pos = "Center") {
		retX := round(( baseScreenWidth / 2 ) - ( w / 2 ))
		retY := round(( baseScreenHeight / 2 ) - ( h / 2 ))
	} Else If (pos = "Top Left Corner") {
		retX := 0
		retY := 0
	} Else If (pos = "Top Right Corner") {
		retX := baseScreenWidth - w
		retY := 0
	} Else If (pos = "Bottom Left Corner") {
		retX := 0
		retY := baseScreenHeight - h
	} Else If (pos = "Bottom Right Corner") {
		retX := baseScreenWidth - w
		retY := baseScreenHeight - h
	} Else If (pos = "Top Center") {
		retX := round(( baseScreenWidth / 2 ) - ( w / 2 ))
		retY := 0
	} Else If (pos = "Bottom Center") {
		retX := round(( baseScreenWidth / 2 ) - ( w / 2 ))
		retY := baseScreenHeight - h
	} Else If (pos = "Left Center") {
		retX := 0
		retY := round(( baseScreenHeight / 2 ) - ( h / 2 ))
	} Else If (pos = "Right Center") {
		retX := baseScreenWidth - w
		retY := round(( baseScreenHeight / 2 ) - ( h / 2 ))
	} Else {
		retX := x
		retY := y
	}
}

GetHLMediaFiles(mediaType,supportedFileTypes,returnArray=0) {
	Log("GetHLMediaFiles - Started",4)
	Global HLMediaPath,dbName,systemName,romTable,mgCandidate
	If (!romTable && mgCandidate)
		romTable:=CreateRomTable(dbName)
	DescriptionNameWithoutDisc := romTable[1,4]
	romFolder := HLMediaPath . "\" . mediaType . "\" . systemName . "\" . dbName . "\"
	romDisckLessFolder := HLMediaPath . "\" . mediaType . "\" . systemName . "\" . DescriptionNameWithoutDisc . "\"
	systemFolder := HLMediaPath . "\" . mediaType . "\" . systemName . "\_Default\"
	globalFolder := HLMediaPath . "\" . mediaType . "\_Default\"
	imagesArray := []
	Loop, Parse, supportedFileTypes, |
		If FileExist(romFolder . "*." . A_LoopField) {
			Loop % romFolder . "*." . A_LoopField
				imagesArray[A_Index] := A_LoopFileFullPath
		}
	If imagesArray.MaxIndex() <= 0
		Loop, Parse, supportedFileTypes, |
			If FileExist(romDisckLessFolder . "*." . A_LoopField) {
				Loop % romDisckLessFolder . "*." . A_LoopField
					imagesArray[A_Index] := A_LoopFileFullPath
			}
	If imagesArray.MaxIndex() <= 0
		Loop, Parse, supportedFileTypes, |
			If FileExist(systemFolder . "*." . A_LoopField) {
				Loop % systemFolder . "*." . A_LoopField
					imagesArray[A_Index] := A_LoopFileFullPath
			}
	If imagesArray.MaxIndex() <= 0 
		Loop, Parse, supportedFileTypes, |
			If FileExist(globalFolder . "*." . A_LoopField) {
				Loop % globalFolder . "*." . A_LoopField
					imagesArray[A_Index] := A_LoopFileFullPath
			}
	If returnArray {
		Log("GetHLMediaFiles - Ended, returning array",4)
		Return imagesArray
	}
	Else {
		Random, RndmImagePic, 1, % imagesArray.MaxIndex()
		file := imagesArray[RndmImagePic]
		Log("GetHLMediaFiles - Ended, randomized HyperLaunch " . mediaType . " file selected: " . file)
		Return file
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

; This function looks through all defined romPaths and romExtensions for the provided rom file
; Returns a path to the rom where it was found
; Returns nothing if not found
RomNameExistCheck(file,archivesOnly="") {
	Global romPathFromIni,romExtensions,7zFormats
	Loop, Parse,  romPathFromIni, |	; for each rom path defined
	{	tempRomPath:=A_LoopField	; assigning this to a var so it can be accessed in the next loop
		Loop, parse, romExtensions, |	; for each extension defined
		{	If (archivesOnly != "")
				If !InStr(7zFormats,A_LoopField)	; if rom extension is not an archive type, skip this rom
					Continue
			; msgbox % tempRomPath . "\" . file . "." . tempRomExtension
			Log("RomNameExistCheck - Looking for rom: " . tempRomPath . "\" . file . "." . A_LoopField,4)
			If FileExist( tempRomPath . "\" . file . "." . A_LoopField ) {
				Log("RomNameExistCheck - Found rom: " . tempRomPath . "\" . file . "." . A_LoopField)
				Return tempRomPath . "\" . file . "." . A_LoopField	; return path if file exists
			}
			Log("RomNameExistCheck - Looking for rom: " . tempRomPath . "\" . file . "\" . file . "." . A_LoopField,4)
			If FileExist( tempRomPath . "\" . file . "\" . file . "." . A_LoopField ) {	; check one folder deep of the rom's name in case user keeps each rom in a folder
				Log("RomNameExistCheck - Found rom: " . tempRomPath . "\" . file . "\" . file . "." . A_LoopField)
				Return tempRomPath . "\" . file . "\" . file . "." . A_LoopField	; return path if file exists
			}
		}
	}
	Log("RomNameExistCheck - Could not find """ . file . """ in any of your Rom Paths with any defined Rom Extensions",2)
	Return
}

; Shared romTable function and label for HP and MG which calculates what roms have multiple discs. Now available on every launch to support some custom uses for loading multiple disks on some older computer systems
CreateMGRomTable:
	Log("CreateMGRomTable - Started")
	If !mgCandidate {
		Log("CreateMGRomTable - Ended - This rom does not qualify for MultiGame")
		Return
	}
	If !IsObject(romTable)
	{	Log("CreateMGRomTable - romTable does not exist, creating one for """ . dbName . """",4)
		romTable := CreateRomTable(dbName)
	} Else
		Log("CreateMGRomTable - romTable already exists, skipping table creation.",4)
	Log("CreateMGRomTable - Ended")
Return

CreateRomTable(table) {
	Global romPathFromIni,dbName,romExtensionOrig,7zEnabled,romTableStarted,romTableComplete,romTableCanceled,hyperlaunchIsExiting,mgCandidate
	romTableStarted := 1
	romTableCanceled :=
	romTableComplete :=
	If hyperlaunchIsExiting {
		romTableCanceled := 1	; set this so the RomTableCheck is canceled and doesn't get stuck in an infinite loop
		Log("CreateRomTable - HyperLaunch is currently exiting, skipping romTable creation")
		Return
	}
	If !mgCandidate {
		romTableCanceled := 1	; set this so the RomTableCheck is canceled and doesn't get stuck in an infinite loop
		Log("CreateRomTable - This rom does not qualify for MultiGame")
		Return
	}
	Log("CreateRomTable - Started")

	romCount := 0	; initialize the var and reset it, needed in case GUI is used more then once in a session
	table := []	; initialize and empty the table
	typeArray := ["(Disc","(Disk","(Cart","(Tape","(Cassette","(Part","(Side"]
	regExCheck = i)\s\(Disc\s[^/]*|\s\(Disk\s[^/]*|\s\(Cart\s[^/]*|\s\(Tape\s[^/]*|\s\(Cassette\s[^/]*|\s\(Part\s[^/]*|\s\(Side\s[^/]*
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
					Log("CreateRomTable - Looking for: " . currentPath . "\" . dbNamePre . A_Space . typeArray[typeArrayIndex] . "*." . A_LoopFileExt,4)
					If romExtensionOrig contains % A_LoopFileExt	; Now we narrow down to all matching files using our original extension. Next we use this data to build an array of our files to populate the GUI.
					{	romCount += 1
						matchedRom := 1	; Allows to break out of the loops once we matched our rom
						table[romCount,1] := A_LoopFileFullPath	; Store A_LoopFileFullPath (full file path and file) in column 1
						table[romCount,2] := A_LoopFileName	; Store A_LoopFileName (the full filename and extension) in column 2
						table[romCount,3] := RegExReplace(table[romCount, 2], "\..*")	; Store the filename with media type # but w/o an extension in column 3
						pos := RegExMatch(table[romCount,2], regExCheck)	; finds position of our multi media type so we can trim away and generate the imageText and check if rom is part of a set. This pulls only the filenames out of the table in column 2.
						uncleanTxt:= SubStr(table[romCount,2], pos + 1)	; remove everything but the media type and # and ext from our file name
						table[romCount,4] := dbNamePre	; store dbName w/o the media type and #, used for HP and updating statistics in column 4
						table[romCount,5] := RegExReplace(uncleanTxt, "\(|\)|\..*")	; clean the remainder, removing () and ext, then store it as column 5 in our table to be used for our imageText, this is the media type and #
						table[romCount,6] := SubStr(table[romCount,5],1,4)	; copies just the media type to column 6
						Log("CreateRomTable - Adding found game to Rom Table: " . A_LoopFileFullPath,4)
					}
				}
			}
		}
	}
	romTableComplete := 1	; flag to tell the RomTableCheck the function is complete in case no romTable was created for non-MG games
	romTableStarted :=
	Log("CreateRomTable - Ended`, " . IndexTotal . " Loops to create table.")
	Return table
}

; Function that gets called in some modules to wait for romTable creation if the module bases some conditionals off whether this table exists or not
RomTableCheck() {
	Global systemName,mgEnabled,hpEnabled,romTable,romTableStarted,romTableComplete,romTableCanceled,mgCandidate,dbName
	If mgCandidate { ; && (hpEnabled = "true" || mgEnabled = "true")) {
		; If (!romTableStarted && !IsObject(romTable))
			; romTable := CreateRomTable(dbName)
			
		Log("RomTableCheck - Started")
		; HPGlobalIni := A_ScriptDir . "\Settings\Global HyperPause.ini"		; HP keys have not been read into memory yet, so they must be read here so HL knows whether to run the below loop or not
		; HPSystemIni := A_ScriptDir . "\Settings\" . systemName . "\HyperPause.ini" 
		; IniRead, changeDiscMenuG, %HPGlobalIni%, General Options, ChangeDisc_Menu_Enabled
		; IniRead, changeDiscMenuS, %HPSystemIni%, General Options, ChangeDisc_Menu_Enabled
		; changeDiscMenu := If changeDiscMenuS = "use_global" ? changeDiscMenuG : changeDiscMenuS	; calculate to use system or global setting

		; If (mgEnabled = "true" || changeDiscMenu = "true") {
			; Log("RomTableCheck - MultiGame and/or HyperPause's Change Disc Menu is enabled so checking if romTable exists yet.",4)
			If !romTable.MaxIndex()
				Log("RomTableCheck - romTable does not exist yet, waiting until it does to continue loading the module.",4)
			Loop {
				If romTableComplete {	; this var gets created when CreateRomTable is complete in case this is not an MG game
					Log("RomTableCheck - Detected CreateRomTable is finished processing. Continuing with module thread.",4)
					Break
				} Else If romTableCanceled {	; this var gets created when CreateRomTable is cancelled in cases it is no longer needed
					Log("RomTableCheck - Detected CreateRomTable is no longer needed. Continuing with module thread.",4)
					Break
				} Else	If (A_Index > 200) {	; if 20 seconds pass by, log there was an issue and continue w/o romTable
				Log("RomTableCheck - Creating the romTable took longer than 20 seconds. Continuing with module thread without waiting for the table's creation.",3)
					Break
				} Else
					Sleep, 100
			}
		; }
		Log("RomTableCheck - Ended")
	} Else
		Log("RomTableCheck - This game is not a candidate for MG or Change DIsc menu.")
}

; Allows changing of LEDBlinky's active profile
; mode can be HL or Rom which tells LEDBlinky what profile to load
LEDBlinky(mode) {
	Global ledblinkyEnabled,ledblinkyFullPath,ledblinkyProfilePath,ledblinkyHLProfile,dbName
	If ledblinkyEnabled = true
	{
		Log("LEDBlinky - Started")
		SplitPath,ledblinkyFullPath,ledblinkyExe,ledblinkyPath
		
		If mode = HL
			Run(ledblinkyExe . " HyperLaunch HyperLaunch", ledblinkyPath)	; Load HyperLaunch profile
		Else
			Run(ledblinkyExe . " " . dbName, ledblinkyPath)	; return to rom profile

		Log("LEDBlinky - Ended")
	}
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

; Function to measure the size of an text
MeasureText(Text,Options,Font="Arial",Width="", Height="", ReturnMode="W", ByRef H="", ByRef W="", ByRef X="", ByRef Y="", ByRef Chars="", ByRef Lines=""){
	hdc_MeasureText := GetDC("MeasureText_hwnd")
	G_MeasureText := Gdip_GraphicsFromHDC(hdc_MeasureText)
	RECTF_STR := Gdip_TextToGraphics(G_MeasureText, Text, Options, Font, Width, Height, 1)
	StringSplit,RCI,RECTF_STR, |
	W := Ceil(RCI3)
	H := Ceil(RCI4) 
	X := Ceil(RCI1)
	Y := Ceil(RCI2)
	Chars := Ceil(RCI5)
	Lines := Ceil(RCI6)
	DeleteDC(hdc_MeasureText), Gdip_DeleteGraphics(G_MeasureText)
	Return (ReturnMode="X") ? X : (ReturnMode="Y") ? Y :(ReturnMode="W") ? W :(ReturnMode="H") ? H : (ReturnMode="Chars") ? Chars : Lines
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

; SplitPath function with support for roms that contain multiple periods in their name. AHK SplitPath does not support this.
SplitPath(in,Byref outFileName,Byref outPath,Byref outExt,Byref outNameNoExt) {
	regx := "(\\{2}|(^[\w]:\\))([\w].+\w\\)"	; return path on regexmath and file on regexreplace
	regext := "((\.[^.\s]+)+)$"	; return extension with period (match literal period, match one or more at beginning any character and white space, one or more of all previous, and entire match must appear at end)
	in := RegExReplace(in,"/","\")	; replace all occurences of / with \
	RegExMatch(in, regx, outPathBSlash)	; path with backslash
	pathLen := StrLen(outPathBSlash)	; get length of path with slash
	outPath := SubStr(outPathBSlash, 1, pathLen - 1)	; grab path w/o slash
	RegExMatch(in, regext, outExtP)	; get ext with period
	outExt := SubStr(outExtP, 2)	; get ext and remove period
	outFileName := RegExReplace(in, regx)	; get name with ext
	nameLen := StrLen(outFileName)	; get length of name
	extLen := StrLen(outExt)	; get length of ext
	outNameNoExt := SubStr(outFileName, 1, nameLen - extLen - 1)	; get name w/o ext
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

; Converts a relative path to an absolute one after providing the base path
AbsoluteFromRelative(MasterPath, RelativePath)
{
	VarSetCapacity(AbsP,260,0)
	DllCall( "shlwapi\PathCombineA", Str,AbsP, Str,MasterPath, Str,RelativePath )
	Return AbsP
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

; StrX function because some modules use it and HyperPause needs it for ReadHyperSpinXML
StrX( H,  BS="",BO=0,BT=1,   ES="",EO=0,ET=1,  ByRef N="" ) {
	Return SubStr(H,P:=(((Z:=StrLen(ES))+(X:=StrLen(H))+StrLen(BS)-Z-X)?((T:=InStr(H,BS,0,((BO
	 <0)?(1):(BO))))?(T+BT):(X+1)):(1)),(N:=P+((Z)?((T:=InStr(H,ES,0,((EO)?(P+1):(0))))?(T-P+Z
	 +(0-ET)):(X+P)):(X)))-P)
}

i18n(key, defaultLocale = "English_United_States", p0 = "-0", p1 = "-0", p2 = "-0", p3 = "-0", p4 = "-0", p5 = "-0", p6 = "-0", p7 = "-0", p8 = "-0", p9 = "-0") {
	Global sysLang,langFile
	Log("i18n - Started",4)
	IniRead, phrase, %langFile%, %sysLang%, %key%
	If (phrase = "ERROR" || phrase = "")
	{
		; Nothing found, test with generic language
		StringSplit, keyArray, sysLang, _
		Log("i18n - Section """ . sysLang . """ & key """ . key . """ not found, trying section """ . keyArray1 . """",4)
		IniRead, phrase, %langFile% , %keyArray1%, %key%
		If (phrase = "ERROR" || phrase = "")
		{
			Log("i18n - Section """ . keyArray1 . """ & key """ . key . """ not found, trying section """ . defaultLocale . """",4)
			; Nothing found, test with default locale if one is provided
			If (defaultLocale != "")
			{
				IniRead, phrase, %langFile% , %defaultLocale%, %key%
				If (phrase = "ERROR" || phrase = "")
				{
					; Nothing found, test with generic language for default locale as well
					StringSplit, keyArray, defaultLocale, _
					Log("i18n - Section """ . defaultLocale . """ & key """ . key . """ not found, trying section """ . keyArray1 . """",4)
					IniRead, phrase, %langFile% , %keyArray1%, %key%
				}
			}
			; Nothing found return original value
			If (defaultLocale = "" || phrase = "ERROR" || phrase = "") {
				Log("i18n - Ended, no phrase found for """ . key . """ in language """ . sysLang . """. Using default """ . key . """",2)
				Return % key
			}
		}
	}

	StringReplace, phrase, phrase, `\n, `r`n, ALL
	StringReplace, phrase, phrase, `\t, % A_Tab, ALL
	Loop 10
	{
		idx := A_Index - 1
		IfNotEqual, p%idx%, -0
			phrase := RegExReplace(phrase, "\{" . idx . "\}", p%idx%)
	}
	Log("i18n - Ended, using """ . phrase . """ for """ . key . """",4)
	Return % phrase
}

; Debug console handler
DebugMessage(str) {
	Global hlTitle,hlVersion,hlDebugConsoleStdout
	If !hlDebugConsoleStdout
		DebugConsoleInitialize(hlDebugConsoleStdout, hlTitle . " v" . hlVersion . " Debug Console")	; start console window if not yet started
	str .= "`n"		; add line feed
	FileAppend %str%, CONOUT$
	; FileAppend  %str%`n, *	; Works with SciTE and similar editors.
	; OutputDebug %str%`n	; Works with Visual Studio and DbgView.
	WinSet, Bottom,, ahk_id %hlDebugConsoleStdout%	; keep console on bottom
}

DebugConsoleInitialize(ByRef handle, title="") {
	; two calls to open, no error check (it's debug, so you know what you are doing)
	DllCall("AttachConsole", int, -1, int)
	DllCall("AllocConsole", int)

	DllCall("SetConsoleTitle", "str", (If title ? title : a_scriptname))		; Set the title
	handle := DllCall("GetStdHandle", "int", -11)		; get the handle
	WinSet, Bottom,, ahk_id %handle%		; make sure it's on the bottom
	Return
}

;Sends a command to the active window using AHK key names. It will always send down/up keypresses for better compatibility
;A special command {Wait} can be used to force a sleep of the time defined by WaitTime
SendCommand(Command, SendCommandDelay=2000, WaitTime=500, WaitBetweenSends=0, Delay=50, PressDuration=-1) {
	Log("SendCommand - Started")
	Log("SendCommand - Command: " . Command . "`r`n`t`t`t`t`tSendCommandDelay: " . SendCommandDelay . "`r`n`t`t`t`t`tWaitTime: " . WaitTime . "`r`n`t`t`t`t`tWaitBetweenSends: " . WaitBetweenSends,4)
	ArrayCount = 0 ;Keeps track of how many items are in the array.
	InsideBrackets = 0 ;If 1 it means the current array item starts with {
	SavedKeyDelay := A_KeyDelay ;Saving previous key delay and setting the new one
	SetKeyDelay, %Delay%, %PressDuration%
	Sleep, %SendCommandDelay% ;Wait before starting to send any command

	;Create an array with each command as an array element
	Loop, % StrLen(Command)
	{	StringMid, StrValue, Command, A_Index, 1
		If (StrValue != A_Space)
		{	If InsideBrackets = 0
				ArrayCount += 1  
			If (StrValue = "{")
			{	If (InsideBrackets = "1")
					ScriptError("Non-Matching brackets detected in the SendCommand parameter, please correct it")
				Else
					InsideBrackets = 1
			} Else If (StrValue = "}")
			{	If (InsideBrackets = "0")
					ScriptError("Non-Matching brackets detected in the SendCommand parameter, please correct it")
				Else
					InsideBrackets = 0
			}
			Array%ArrayCount% := Array%ArrayCount% . StrValue ;Update the array data
		}
	}

	;Loop through the array and send the commands
	Loop %ArrayCount%
	{	element := Array%A_Index%

		If (WaitBetweenSends = 1)
			Sleep, %WaitTime%

		;Particular cases check if the commands already come with down or up suffixes on them and if so send the commands directly without appending Up/Down
		If element contains Down}
		{	If (element != "{Down}")
			{	Send, %element%
				continue
			}
		}
		Else If elemnent contains Up}
		{	If (element != "{Up}")
			{	Send, %element%
				Continue
			}
		}
		Else If (element = "{Wait}") ;Special non-ahk tag to issue a sleep
		{	Sleep, %WaitTime%
			Continue
		}
		Else If element contains {Wait:
		{	;Wait for a specified amount of time {Wait:xxx}
			StringMid, NewWaitTime, element, 7, StrLen(element) - 7
			Sleep, %NewWaitTime%
			Continue
		}

		;the rest of the commands, send a keypress with down and up suffixes
		If element contains }
		{	StringLeft, StrElement, element, StrLen(element) - 1
			Send, %StrElement% down}%StrElement% up}
		} Else
			Send, {%element% down}{%element% up}
	}
	;Restore key delay values
	SetKeyDelay(SavedKeyDelay, -1)
	Log("SendCommand - Ended")
}

; Purpose: Tell a ServoStik to transition to 4 or 8-way mode
; Parameters:
; 	direction = Can be 4 or 8, self-explanatory
ServoStik(direction) {
	Log("ServoStik - Started")
	Global PacDriveDllFile
	If direction Not In 4,8
		ScriptError("Not a supported direction for ServoSticks. Only 4 and 8 are supported!")
	pacDriveLoadModule := DllCall("LoadLibrary", "Str", PacDriveDllFile)  ; Avoids the need for ahk to load and free the dll's library multiple times
	pacInitialize := DllCall(PacDriveDllFile . "\PacInitialize")	; Initialize all PacDrive, PacLED64 and U-HID Devices and return the amount connected to system
	If !pacInitialize {
		Log("ServoStik - No devices found on system",2)
		Log("ServoStik - Ended")
		Return
	} Else
		Log("ServoStik - " . pacInitialize . " devices found on system. If you have multiple devices, this should list more than one and may not specifically mean a ServoStik was found")

	result := DllCall(PacDriveDllFile . "\PacSetServoStik" . direction . "Way")	; Tell ServoStiks to change to desired direction
	If !result
		Log("ServoStik - There was a problem telling your ServoStik(s) to go " . direction . "-Way",3)
	Else
		Log("ServoStik - ServoStik(s) were told to go " . direction . "-Way")
	; pacDriveUnloadModule := DllCall("FreeLibrary", "UInt", pacDriveLoadModule)  ; To conserve memory, the DLL is unloaded after using it.
	Log("ServoStik - Ended")
}

;-------------------------------------------------------------------------------------------------------------
;----------------------------------------- DXWnd Functions -----------------------------------------
;-------------------------------------------------------------------------------------------------------------

; If you provide a value, DxwndIniRW assumes you want to write to the ini
; If no value is provided, DxwndIniRW assumes you want to read from the ini and returns the value
DxwndIniRW(sec="",key="",val="", default="", cTarget="") {
	Log("DxwndIniRW - Started")
	Global dxwndIni,romName
	Static pos
	If !pos {	; the current romName or cTarget position has not been found, loop through the ini to find it first
		targetGame := If cTarget ? cTarget : romName
		Loop {
			pos := a_index-1
			IniRead, dxwndName, %dxwndIni%, target, title%pos%
			If (dxwndName = targetGame)
				Break
			If (dxwndName = "ERROR")
				ScriptError("There was a problem finding """ . targetGame . """ in the DXWnd Ini. Please make sure you have added this game to DXWnd before attempting to launch DXWnd through it.")
		}
	}
	errLvl := Process("Exist", "dxwnd.exe")	; Make sure dxwnd is not running first so settings don't get reverted
	If errLvl {
		DxwndClose()
		Process("WaitClose", "dxwnd.exe")
	}
	If val {
		IniWrite, %val%, %dxwndIni%, %sec%, %key%%pos%
		Log("DxwndIniRW - Wrote """ . val . """ to game #" . pos,4)
	} Else {
		IniRead, val, %dxwndIni%, %sec%, %key%%pos%
		Log("DxwndIniRW - Read """ . val . """",4)
		Log("DxwndIniRW - Ended")
		Return val
	}
	Log("DxwndIniRW - Ended")
}

DxwndRun(ByRef outPID="") {
	Log("DxwndRun - Started")
	Global dxwndFullPath,dxwndExe,dxwndPath
	If !dxwndExe
		SplitPath, dxwndFullPath, dxwndExe, dxwndPath
	Run(dxwndExe, dxwndPath, "Min", outPID)
	errLvl := Process("Wait", dxwndExe, 10)	; waiting 10 seconds for dxwnd to start
	If (errLvl = "")
		ScriptError("DXWnd did not start after waiting for 10 seconds. Please check you can run it manually and try again.")
	Else
		Log("DxwndRun - DxwndRun is now running")
	Log("DxwndRun - Ended")
}

DxwndClose() {
	Log("DxwndClose - Started")
	Global dxwndFullPath,dxwndExe,dxwndPath
	If !dxwndExe
		SplitPath, dxwndFullPath, dxwndExe, dxwndPath
	PostMessage, 0x111, 32810,,,ahk_exe %dxwndExe%	; this tells dxwnd to close itself
	Process("WaitClose", dxwndExe, 1)	; waits 1 second for dxwnd to close
	errLvl := Process("Exist", dxwndExe)	; checks if dxwnd is still running
	If errLvl
		Process("Close", dxwndExe)	; only needed when HL is not ran as admin or HL cannot close dxwnd for some reason
	Log("DxwndClose - Ended")
}

;-------------------------------------------------------------------------------------------------------------
;----------------------------------- Cursor Control Functions ------------------------------------
;-------------------------------------------------------------------------------------------------------------

ToggleCursor:
	Log("ToggleCursor - Hotkey """ . toggleCursorKey . """ pressed, toggling cursor visibility")
	SystemCursor("Toggle")
Return

; Function to hide/unhide the mouse cursor
SystemCursor(OnOff=1)   ; INIT = "I","Init"; OFF = 0,"Off"; TOGGLE = -1,"T","Toggle"; ON = others
{	Global mouseCursorHidden
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
		mouseCursorHidden := 1	; track current status of mouse cursor
	} Else {
		$ = h	; use the saved cursors
		SPI_SETCURSORS := 0x57	; Emergency restore cursor, just in case something goes wrong
		DllCall( "SystemParametersInfo", UInt,SPI_SETCURSORS, UInt,0, UInt,0, UInt,0 )
		mouseCursorHidden :=
		Log("Restoring mouse cursor")
	}
	
	Loop %c0%
	{
		h_cursor := DllCall( "CopyImage", "uint",%$%%A_Index%, "uint",2, "int",0, "int",0, "uint",0 )
		DllCall( "SetSystemCursor", "uint",h_cursor, "uint",c%A_Index% )
	}
}

SetSystemCursor( Cursor = "", cx = 0, cy = 0 ) {
	BlankCursor := 0, SystemCursor := 0, FileCursor := 0 ; init

	SystemCursors = 32512IDC_ARROW,32513IDC_IBEAM,32514IDC_WAIT,32515IDC_CROSS
	,32516IDC_UPARROW,32640IDC_SIZE,32641IDC_ICON,32642IDC_SIZENWSE
	,32643IDC_SIZENESW,32644IDC_SIZEWE,32645IDC_SIZENS,32646IDC_SIZEALL
	,32648IDC_NO,32649IDC_HAND,32650IDC_APPSTARTING,32651IDC_HELP

	If Cursor = ; empty, so create blank cursor
	{
		VarSetCapacity( AndMask, 32*4, 0xFF ), VarSetCapacity( XorMask, 32*4, 0 )
		BlankCursor = 1 ; flag for later
	}
	Else If SubStr( Cursor,1,4 ) = "IDC_" ; load system cursor
	{
		Loop, Parse, SystemCursors, `,
		{
			CursorName := SubStr( A_Loopfield, 6, 15 ) ; get the cursor name, no trailing space with substr
			CursorID := SubStr( A_Loopfield, 1, 5 ) ; get the cursor id
			SystemCursor = 1
			If ( CursorName = Cursor ) {
				CursorHandle := DllCall( "LoadCursor", Uint,0, Int,CursorID )   
				Break               
			}
		}   
		If CursorHandle = ; invalid cursor name given
		{
			Msgbox,, SetCursor, Error: Invalid cursor name
			CursorHandle = Error
		}
	}   
	Else If FileExist( Cursor )
	{
		SplitPath, Cursor,,, Ext ; auto-detect type
		If Ext = ico
			uType := 0x1   
		Else If Ext in cur,ani
			uType := 0x2      
		Else ; invalid file ext
		{
			Msgbox,, SetCursor, Error: Invalid file type
			CursorHandle = Error
		}      
		FileCursor = 1
	}
	Else
	{   
		Msgbox,, SetCursor, Error: Invalid file path or cursor name
		CursorHandle = Error ; raise for later
	}
	If CursorHandle != Error
	{
		Loop, Parse, SystemCursors, `,
		{
			If BlankCursor = 1
			{
				Type = BlankCursor
				%Type%%A_Index% := DllCall( "CreateCursor", Uint,0, Int,0, Int,0, Int,32, Int,32, Uint,&AndMask, Uint,&XorMask )
				CursorHandle := DllCall( "CopyImage", Uint,%Type%%A_Index%, Uint,0x2, Int,0, Int,0, Int,0 )
				DllCall( "SetSystemCursor", Uint,CursorHandle, Int,SubStr( A_Loopfield, 1, 5 ) )
			}         
			Else If SystemCursor = 1
			{
				Type = SystemCursor
				CursorHandle := DllCall( "LoadCursor", Uint,0, Int,CursorID )   
				%Type%%A_Index% := DllCall( "CopyImage", Uint,CursorHandle, Uint,0x2, Int,cx, Int,cy, Uint,0 )      
				CursorHandle := DllCall( "CopyImage", Uint,%Type%%A_Index%, Uint,0x2, Int,0, Int,0, Int,0 )
				DllCall( "SetSystemCursor", Uint,CursorHandle, Int,SubStr( A_Loopfield, 1, 5 ) )
			}
			Else If FileCursor = 1
			{
				Type = FileCursor
				%Type%%A_Index% := DllCall( "LoadImage", UInt,0, Str,Cursor, UInt,uType, Int,cx, Int,cy, UInt,0x10 )
				DllCall( "SetSystemCursor", Uint,%Type%%A_Index%, Int,SubStr( A_Loopfield, 1, 5 ) )         
			}         
		}
	}   
}

RestoreCursors() {
	SPI_SETCURSORS := 0x57
	DllCall( "SystemParametersInfo", UInt,SPI_SETCURSORS, UInt,0, UInt,0, UInt,0 )
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
; Separator = the separator to use, defaults to =
ReadProperty(cfgArray,keyName,Separator="=") {
	Log("ReadProperty - Started",4)
	Loop % cfgArray.MaxIndex()
	{	element := cfgArray[A_Index]
		trimmedElement := Trim(element)
		;MsgBox % "Element number " . A_Index . " is " . element

		StringGetPos, pos, trimmedElement, [
		If (pos = 0)
			Break	; Section was found, do not search anymore, global section has ended

		If element contains %Separator%
		{	StringSplit, keyValues, element, %Separator%
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
; Separator = the separator to use, defaults to =
WriteProperty(cfgArray,keyName,Value,AddSpaces=0,AddQuotes=0,Separator="=") {
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

		If element contains %Separator%
		{	StringSplit, keyValues, element, %Separator%
			CfgValue := Trim(keyValues1)
			If (CfgValue = keyName)
			{	cfgArray[A_Index] := CfgValue . (If AddSpaces=1 ? (" " . Separator . " ") : Separator) . (If AddQuotes=1 ? ("""" . Value . """") : Value)	; Found it
				added = 1
				Break
			}
		}
	}
	If added = 0
		cfgArray.Insert(lastIndex+1, keyName . (If AddSpaces=1 ? (" " . Separator . " ") : Separator) . (If AddQuotes=1 ? ("""" . Value . """") : Value))	; Add the new entry to the file
	Log("WriteProperty - Ended",4)
}

;-------------------------------------------------------------------------------------------------------------
;------------------------------------- Daemon Tools Function -------------------------------------
;-------------------------------------------------------------------------------------------------------------

; Action: Can be get (get's the drive letter associated to the chosen drive type), mount (mount a disc), unmount (unmount a disc)
; File: Full path to file you want to mount (only need to provide this when using action type "mount"
; Type: Leave blank to use auto mode or what the user has chosen in HLHQ for that system. To force a specific drive type, send "dt" or "scsi" in the module
; Drive: A drive number for DT can be sent in the scenario a user has multiple dt or scsi drives and prefers to not use the first one (0). This is not used in any module to date.

DaemonTools(action,file="",type="",drive=0){
	Log("DaemonTools - Started - action is " . action)
	Global dtPath,dtUseSCSI,dtAddDrive,dtDriveLetter,7zFormatsNoP,HLObject,DTAllowGDIQuotes
	dtMap:=Object(0,"A",1,"B",2,"C",3,"D",4,"E",5,"F",6,"G",7,"H",8,"I",9,"J",10,"K",11,"L",12,"M",13,"N",14,"O",15,"P",16,"Q",17,"R",18,"S",19,"T",20,"U",21,"V",22,"W",23,"X",24,"Y",25,"Z")
	If file	; only log file when one is used
		Log("DaemonTools - Received file: " . file,4)
	SplitPath, file,,,ext
	dtFile := (If file ? ("`, """ . file . """") : (""))
	IfNotExist % dtPath
		ScriptError("Could not find " . dtPath . "`nPlease fix the DAEMON_Tools_Path key in your Settings\HyperLaunch.ini to point to your DTLite installation.",8)
	If action not in get,mount,unmount
		ScriptError(action . " is an unsupported use of daemontools. Only mount and unmount actions are supported.")
	If action = mount
	{	If ext in %7zFormatsNoP%
			ScriptError("DaemonTools was sent an archive extension """ . ext . """ which is not a mountable file type. Turn on 7z support or uncompress this game in order to mount it.")
		Else If ext not in mds,mdx,b5t,b6t,bwt,ccd,cue,isz,nrg,cdi,iso,ape,flac
			ScriptError("DaemonTools was sent the extension """ . ext . " which is not a mountable file type.")
		If ext in cue,gdi
		{	cueHasMp3s := COM_Invoke(HLObject, "findCUETracksByExtension", file, "mp3")	; 0 = no mp3s, 1 = found mp3s, 2 = cant find cue, 3 = cue invalid. Multiple extensions can be | serparated
			If !cueHasMp3s {
				Log("DaemonTools - This " . ext . " does not contain any mp3s.",4)
				If (ext = "cue") {
					validateCUE := COM_Invoke(HLObject, "validateCUE", file)	; 0 = cue is invalid, 1 = cue is valid, 2 = cant find cue
					If validateCUE = 1
						Log("DaemonTools - This " . ext . " was found valid.",4)
					Else
						ScriptError("You have an invalid " . ext . " file. Please check it for errors.")
				} Else If (ext = "gdi") {
					If !DTAllowGDIQuotes	; by default, gdi files can contain double quotes. If a module contains "DTAllowGDIQuotes = false" it will be sent to the dll to error if they exist anywhere in the gdi.
						DTAllowGDIQuotes := "true"
					Else If DTAllowGDIQuotes not in true,false
						ScriptError(DTAllowGDIQuotes . " is an invalid option for DTAllowGDIQuotes. It must either be true or false.")
					validateGDI := COM_Invoke(HLObject, "validateGDI", file, DTAllowGDIQuotes)	; 0 = gdi is invalid, 1 = gsi is valid, 2 = cant find gdi, 3 = invalid double quotes were found. DTAllowGDIQuotes when true tells the dll that the GDI can have double quotes. False it cannot have quotes.
					If validateGDI = 1
						Log("DaemonTools - This " . ext . " was found valid.",4)
					Else If !validateGDI
						ScriptError("You have an invalid " . ext . " file. Please check it for errors.")
					Else If validateGDI = 3
						ScriptError("Invalid double quotes were found in " . ext . " file.")
				}
			} Else If cueHasMp3s = 1
				ScriptError("Your " . ext . " file contains links to mp3 files which is not supported by Daemon Tools. Please download another version of this game without MP3s or turn off Daemon Tools support to use the emulator's built-in image handler if supported.")
			Else If cueHasMp3s = 2
				ScriptError("There was a problem finding your " . ext . " file. Please check it exists at: " . file)
			Else If cueHasMp3s = 3
				ScriptError("You have an invalid " . ext . " file. Please check it for errors.")
		}
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
	Log("DaemonTools - Running DT with: " . dtPath . " -" . action . " " . type . ", " .  drive . dtFile)
	RunWait, %dtPath% -%action% %type%`, %drive%%dtFile%
	Log("DaemonTools - Ended")
}

;-------------------------------------------------------------------------------------------------------------
;--------------------------------------------- 7z Functions ---------------------------------------------------
;-------------------------------------------------------------------------------------------------------------

7z(ByRef 7zP, ByRef 7zN, ByRef 7zE, ByRef 7zExP,call="", AttachRomName=true, AllowLargerFolders=false){
	Global 7zEnabled,7zFormats,7zFormatsNoP,7zPath,7zAttachSystemName,romExtensions,skipchecks,romMatchExt,systemName,dbName,MEmu,logLevel
	Global fadeIn,fadeLyr37zAnimation,fadeLyr3Animation ,fadeLyr3Type,HLObject,7zTempRomExists,use7zAnimation,romExSize,7z1stRomPath,7zRomPath,7zPID,7zStatus
	Global romMapTable,romMappingFirstMatchingExt,romMenuRomName ;,romMappingEnabled
	Global altArchiveNameOnly,altRomNameOnly,altArchiveAndRomName,altArchiveAndManyRomNames,altRomNamesOnly
	Static 7z1stUse
	If 7zEnabled = true
	{	old7zP:=7zP,old7zN:=7zN,old7zE:=7zE	; store values sent to 7z for logging
		;If ( romMapTable.MaxIndex() && !7zN )	; if romMapTable contains a rom and romName not passed
			; msgbox Rom map table exists`nNo rom name passed to 7z`nrom must be in map table so parse all archive types in table and check contents for the alt archive name or for the alt rom named if defined
		; Else If ( romMapTable.MaxIndex() && 7zN )	; if romMapTable contains a rom and romName passed
			; msgbox Rom map table exists`nRom name passed to 7z`nignore map table as rom was passed`, but if archive type`, handle it`, otherwise run rom as is`nNO CHANGES NEEDED TO HANDLE THIS SCENARIO
		; Else If ( !romMapTable.MaxIndex() && 7zN )	; if romMapTable does not contain a rom and romName passed
			; msgbox Rom map table does not exist`nRom name passed to 7z`nHandle rom`, if archive type pass further into 7z else if not`, skip 7z and run rom as is`nNO CHANGES NEEDED TO HANDLE THIS SCENARIO
		; Else If ( !romMapTable.MaxIndex() && !7zN )	; if romMapTable does not contain a rom and romName not passed
			; msgbox Rom map table does not exist`nNo rom name passed to 7z`nShould never see this error because no rom exists else if we are going to have to error out
		Log("7z - Started, " . (If 7zN ? "received " . 7zP . "\" . 7zN . 7zE . ". If rom is an archive, it will extract to " . 7zExP : "but no romName was received"))
		7z1stUse ++	; increasing var each time 7z is used
		7zStatus :=	; this var keeps track of where 7z is inside this function. This is needed so other parts of HL stay in sync and don't rush through their own routines
		7zRunning :=
		7zFinished :=

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
			{	altArchiveFullPath := romMapTable[A_Index,"romPath"] . "\" . romMapTable[A_Index,"romName"] . "." . romMapTable[A_Index,"romExtension"], romMapIni := romMapTable[A_Index,1] ;, romMapKey := "Alternate_Rom_Name"
				firstAltArchiveFullPath := altArchiveFullPath	; storing this so it can be used if skipchecks is enabled and there are multiple paths found, we only want to send the first in this scenario
				Log("7z - Found a path to a previously found rom in romMapTable: """ . altArchiveFullPath . """",4)
				IniRead, altRomName, %romMapIni%, %dbName%, Alternate_Rom_Name
				If (altRomName = "" || altRomName = "ERROR")	; if multiple alt roms were defined, do a check if user defined the key with "_1"
					IniRead, altRomName, %romMapIni%, %dbName%, Alternate_Rom_Name_1
				If !(altRomName = "" || altRomName = "ERROR")
					Log("7z - Mapping ini contains an Alternate_Rom_Name of """ . altRomName . """",4)
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
			} Else if skipChecks != false	; this scenario is when a rom map is used to load an archive with no valid  rom name or extension, like scummvm compressed roms, and relinking those roms to a different name
			{	SplitPath, firstAltArchiveFullPath,, 7zP, 7zE, 7zN	; assign vars to what is needed for the rest of 7z. This is where we define romPath, romName, and romExtension when none were provided to 7z because we used a map table instead.
				7zE := "." . 7zE
				Log("7z - A matching rom was not found inside the archive, but skipChecks is set to " . skipChecks . ", so continuing with extraction of the first found rom in the table: " . firstAltArchiveFullPath,4)
			} Else
				ScriptError("Scanned all defined ""Alternate_Archive_Name"" and no defined ""Alternate_Rom_Name"" found in any provided Rom Map ini files for """ . dbName . """")

		} Else If romMenuRomName {	; if rom came from the rom map menu
			Log("7z - Using Rom Map Menu method because the Launch Menu was used for this rom: """ . romMenuRomName . """",4)
			7zUsed = 1	; flag that we used 7z for this launch
			SplitPath, romMenuRomName,,,rmExt, rmName	; roms in map table do not always have an extension, like when showing roms from the map ini instead of all in the archive. If it does, use it to find the rom in the archive faster, if it doesn't, search all defined romExtensions
			IfNotInString, romTypeExtensions, %rmExt%
			{	Log("7z - The rom Ext """ . rmExt . """ was not found in """ . romTypeExtensions . """",4)
				rmName := rmName . "." . rmExt	; If rom "extension" don't match romTypeExtension, this is probably not an extension but part of the romname
				rmExt := ""
			}
			; msgbox % 7zP . "\" . 7zN . 7zE
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
			; msgbox
				CheckFile(7zP . "\" . 7zN . 7zE,"7z could not find this file, please check it exists:`n" . 7zP . "\" . 7zN . 7zE)
				If skipChecks = false	; the following extension checks are bypassed with setting skipChecks to any option that will skip Rom Extensions (all of them except when skipchecks is disabled)
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
			7zRomPath := 7zExP . (If 7zAttachSystemName = "true" ? "\" . systemName : "") . (If AttachRomName ? "\" . 7zN : "")	; 7zRomPath reflects the 7zExtractPath + the rom folder our rom will be extracted into. This is used for cleanup later so HL knows what folder to remove
			7zExPCheck := 7zRomPath . (If dllRomPath ? "\" . dllRomPath : "")	; If the archive contains a path/subfolder to the rom we are looking for, add that to the path to check
			romExSize := COM_Invoke(HLObject, "getZipExtractedSize", 7zP . "\" . 7zN . 7zE)	; Get extracted Size of rom for Fade so we know when it's done being extracted or so we can verify the rom size of extracted folders with multiple roms
			Log("7z - Invoked COM Object, ROM extracted size: " . romExSize . " bytes",4)

			If (skipchecks != "false")
				Log("7z - Following paths in log entries may not be accurate because SkipChecks is enabled! Do not be alarmed if you see invalid looking paths when Skip Checks is required for this system.",2)
			
			If (AttachRomName || dllRomPath) {
				7zExSizeCheck := 7zExPCheck
			} Else {	; AttachRomName=false AND dllRomPath is empty (rom not found inside the archive)
				Log("7z - Checking for root folder in archive " . 7zP . "\" . 7zN . 7zE,4)
				rootFolder := COM_Invoke(HLObject, "getZipRootFolder", 7zP . "\" . 7zN . 7zE) ; Check if compressed archive only contains a single folder as the root and if so use that for checking the extraction size, if we don't do this size of the whole 7z_Extract_Path folder will be calculated which means the file will always be extracted as the next loop will produce the wrong file size
				Log("7z - Root folder checking returned """ . rootFolder . """",4)
				7zExSizeCheck := If rootFolder ? 7zExPCheck . "\" . rootFolder : 7zExPCheck
				; msgbox 7zRomPath: %7zRomPath%`n7zExP: %7zExP%`n7zExPCheck: %7zExPCheck%`nrootFolder: %rootFolder%`n7zExSizeCheck: %7zExSizeCheck%`n7zExSizeCheck: %7zExSizeCheck%`nromFromDLL: %dllRomPath%`ndllName: %dllName%`ndllExt: %dllExt%`ndllRomPath: %dllRomPath%`nAttachRomName: %AttachRomName%`n7zAttachSystemName: %7zAttachSystemName%
			}

			Log("7z - Checking if this archive has already been extracted in " . 7zExSizeCheck,4)
			IfExist, %7zExSizeCheck%	; Check if the rom has already been extracted and break out to launch it
			{	Loop, %7zExSizeCheck%\*.*, , 1
					7zExPCheckSize += %A_LoopFileSize%
				Log("7z - File already exists in " . 7zExSizeCheck . " with a size of: " . 7zExPCheckSize . " bytes",4)
			} Else
				Log("7z - File does not already exist in " . 7zExSizeCheck . "`, proceeding to extract it.",4)

			; msgbox romMenuRomName: %romMenuRomName%`nromFromDLL: %romFromDLL%`ndllRomPath: %dllRomPath%`ndllName: %dllName%`ndllExt: %dllExt%`n7zExP: %7zExP%`n7zAttachSystemName: %7zAttachSystemName%`n7zP: %7zP%`n7zN: %7zN%`n7zE: %7zE%`n7zExPCheck: %7zExPCheck%`nromExSize: %romExSize%`n7zExPCheckSize: %7zExPCheckSize%`nromFound: %romFound%
			; difference:=7zExPCheckSize-romExSize
			; msgbox, rom: %7zP%\%7zN%%7zE%`nrom size from dll getZipExtractedSize: %romExSize%`nrom size alread on disk: %7zExPCheckSize%`ndifference: %difference%
			If (romExSize && 7zExPCheckSize && (If AllowLargerFolders ? (romExSize <= 7zExPCheckSize) : (romExSize = 7zExPCheckSize)))	; If total size of rom in archive matches the size on disk, good guess the extracted rom is complete and we don't need to re-extract it again. If the system allows for larger extract path than the currently extracting game, like in dos games where there may be saved info made in the folder, allow the already extracted game to be larger than the archived game. AllowLargerFolders must be set to allow this behavior.
			{	7zP := 7zExPCheck
				7zE = .%dllExt%
				If romMenuRomName		; only need this when rom map launch menu was used
					7zN := dllName				; set romName to the found rom from the dll
				romFound = true					; telling rest of function rom found so it exists successfully and to skip to end
				7zTempRomExists = true	; telling the animation that the rom already exists so it doesn't try to show a 7z animation
				; Log("7z - TESTING 1 -- 7zP: " . 7zP)
				; Log("7z - TESTING 1 -- 7zN: " . 7zN)
				; Log("7z - TESTING 1 -- 7zE: " . 7zE)
				Log("7z - Breaking out of 7z to load existing file",4)
				If fadeIn = true
				{	Log("7z - FadeIn is true, but no extraction needed as it already exists in 7z_Extract_Path. Using Fade_Layer_3_Animation instead.",4)
					useNon7zAnimation = 1
				}
			}
		} Else If 7zE in %7zFormats%	; only need this condition if using the standard 7z method and provided rom doesnt need 7z to load
		{	Log("7z - Provided rom extension """ . 7zE . """ is not an archive type, turning off 7z and running rom directly.")
			7zEnabled = false	; need to tell the animation to load a non-7z animation
			If fadeIn = true
			{	Log("7z - FadeIn is true, but no extraction needed for this rom. Using Fade_Layer_3_Animation instead.",4)
				useNon7zAnimation = 1
			}
		}

		; This section is seperate because I use a couple unique conditions in the above block of code, where the below code would be duplicated if it was moved up.
		; If ((romIn7z = "true" || skipchecks != "false") && !romFound) { ; we found the rom in the archive or we are skipping looking alltogether
		If ((romIn7z = "true" || (skipchecks != "false" && 7zUsed)) && romFound != "true") {
			Log("7z - " . (If romIn7z = "true" ? "File found in archive" : "Skipchecks is enabled`, and set to " . skipChecks . " continuing to extract rom."),4)
			; 7zExP := 7zExP . "\" . (If 7zAttachSystemName = "true" ? systemName . "\" : "") . 7zN	; unsure what this was for but its causing 7zExPCheck to keep adding on path names on each loop

			pathLength := StrLen(7zExPCheck . "\" . dllName . "." . dllExt)	; check length and error if there will be a problem.
			If pathLength > 255
				ScriptError("If you extract this rom, the path length will be " . pathLength . "`, exceeding 255 characters`, a Windows limitation. Please choose a shorter 7z_Extract_Path or shorten the name of your rom.")
			Else
				Log("7z - Extracted path of rom will be " . pathLength . " in length and within the 255 character limit.")

			If !InStr(7zRomPath,"\\") {
				SplitPath, 7zRomPath,,outDir,,,outDrive	; grabbing the outDrive because sometimes supplying just the 7zRomPath or outDir to check for space doesn't always return a number
				If !FileExist(7zRomPath) {
					FileCreateDir, %7zRomPath%
					If ErrorLevel
						ScriptError("There was a problem creating this folder to extract your archive to. Please make sure the drive " . outDrive . " exists and can be written to: """ . 7zRomPath . """")
				}
				DriveSpaceFree, 7zFreeSpace, %outDrive%	; get free space in MB of this drive/folder
				If ((7zFreeSpace * 1000000) < romExSize)	; if the free space on the drive is less than the extracted game's size, error out
					ScriptError("You do not have enough free space in """ . outdir . """ to extract this game. Please choose a different folder or free up space on the drive. Free: " . 7zFreeSpace . " MB / Need: " . (romExSize // 1000000) . " MB")
				Else
					Log("7z - The 7zExtractPath has " . 7zFreeSpace . " MB of free space which is enough to extract this game: " . (romExSize // 1000000) . " MB")
			} Else
				Log("7z - The 7zExtractPath is a network folder and free space cannot be determined: " . 7zRomPath,2)
				
			If (fadeIn = "true" && !call)
			{	Log("7z - FadeIn is true, starting timer to update Layer 3 animation with 7z.exe statistics",4)
				use7zAnimation = true	; this will tell the Fade animation (so progress bar is shown) that 7z is being used to extract a rom
				;SetTimer, UpdateFadeFor7z%zz%, -1	; Create a new timer to start updating Layer 3 of fade. This needs to be a settimer otherwise progress bar gets stuck at 0 during extraction because the thread is waiting for that loop to finish and 7z never starts.
				Gosub, UpdateFadeFor7z%zz%	; Create a new timer to start updating Layer 3 of fade
			} Else if (call="mg") {	; If 7z was called from MG, we need start updating its progress bar
				Log("7z - MG triggered 7z, starting the MG Progress Bar",4)
				SetTimer, UpdateMGFor7z%zz%, -1
			} Else if (call="hp") {	; If 7z was called from HyperPause, we need start updating its progress bar
				Log("7z - HyperPause triggered 7z, starting the HyperPause Progress Bar",4)
				SetTimer, HyperPause_UpdateFor7z%zz%, -1
			}
			If (logLevel >= 4) {	; all debug levels will dump extraction info to log
				Log("7z - Logging is debug or higher, dumping 7z Extraction info to log",4)
				SetTimer, DumpExtractionToLog, -1
			}
			Log("7z - Starting 7z extraction of " . 7zP . "\" . 7zN . 7zE . "  to " . 7zExSizeCheck,4)
			7zRunning := 1
			RunWait, %7zPath% x "%7zP%\%7zN%%7zE%" -aoa -o"%7zRomPath%", 7zPID,Hide ; perform the extraction and overwrite all
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
			7zRunning :=
			7zFinished := 1
			Log("7z - Finished 7z extraction",4)
			7zPID:=	; clear the PID because 7z is not running anymore
			If (FileExist(7zExPCheck . "\" . dllName . "." . dllExt) || skipchecks != "false") { ; after extracting, if the rom now exists in our temp dir, or we are skipping looking, update 7zE, and break out
				7zP := 7zExPCheck
				7zE = .%dllExt%
				If skipChecks != Rom Extension
					7zN := dllName	; update the romName just in case it was different from the name supplied to 7z, never update 7zN if skipChecks is set to Rom Extension
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
				ScriptError("No valid roms found in the archive " . 7zN . 7zE . "`nPlease make sure Rom_Extension contains a rom extension inside the archive: """ . romExtensions . """`nIf this is an arcade rom archive with no single definable extension, please try setting Settings->Skip Checks to Rom Only for this system.",10)
			Else If romFound = false	; no need to error that a rom is not found if we are not supplying a rom to 7z
				ScriptError("No extracted files found in " . 7zExP . "`nCheck that you are not exceeding the 255 character limit and this file is in the root of your archive:`n" . 7zN . foundExt,10)
			If 7z1stUse = 1	; If this is the first time 7z was used (rom launched from FE), set this var so that 7zCleanup knows where to find it for deletion. MultiGame extractions will be stored in the romTable for deletion.
				7z1stRomPath := 7zExSizeCheck
		} Else {
			Log("7z - This rom type does not need 7z: """ . 7zE . """")
			useNon7zAnimation = 1
		}
		If (useNon7zAnimation && !mg)		; this got flagged above if 7z is on, but 7z was not used or needed for the current rom. Since the 7z call is after FadeInStart in the module, we need to start call the animation here now.
		{	Log("7z - Starting non-7z FadeIn animation.",4)
			; SetTimer, UpdateFadeForNon7z%zz%, -1	; Create a new timer to start fade non-7z animation because jumping out of a function via gosub does not work
			Gosub, UpdateFadeForNon7z%zz%	; Create a new timer to start fade non-7z animation because jumping out of a function via gosub does not work
			; GoSub, %fadeLyr3Animation%	; still need to provide an animation because the 7z animation won't trigger above
		}
		Log("7z - romPath changed from """ . old7zP . """ to """ . 7zP . """",4)
		Log("7z - romName changed from """ . old7zN . """ to """ . 7zN . """",4)
		Log("7z - romExtension changed from """ . old7zE . """ to """ . 7zE . """",4)
		Log("7z - Ended")
	}
	Return
	
	DumpExtractionToLog:			
	Process("Wait", "7z.exe", 2)
		Loop {
			; Updating 7z extraction info
			SetFormat, Float, 3	; don't want to show decimal places in the percentage
			romExPercentageAndFile := COM_Invoke(HLObject, "getExtractionSize", 7zExSizeCheck, 0)	; Get the current file being extracted and size of the 7z Extract Path - (Extraction Progress (Accurate Method))
			Loop, Parse, romExPercentageAndFile, |	; StringSplit oddly doesn't work for some unknown reason, must resort to a parsing Loop instead
			{
				If A_Index = 1
				{
					romExCurSize := A_LoopField									; Store bytes extracted
					romExPercentage := (A_LoopField / romExSize) * 100	; Calculate percentage extracted
			; tooltip % romExPercentage
				} Else If A_Index = 2
					romExFile := A_LoopField
			}

			; Defining text to be shown
			outputDebugPercentage := % "Extracting file:`t" . romExFile . "`t|`tPercentage Extracted: " . romExPercentage . "%" 
			Log(outputDebugPercentage,4)

			; Breaking Loop
			Process, Exist, 7z.exe	; This breaks out of 7z.exe If it's no longer running. Sometimes an extraction was very quick or there was an error and we don't want to be stuck in an infinite Loop
			If (!ErrorLevel || romExPercentage >= 100) {	; bar is at 100% or 7z is already closed, so break out
				Log("7z - " . (If romExPercentage >= 100 ? "7z.exe returned a percentage >= 100, assuming extraction is done" : "7z.exe is no longer running, assuming extraction is complete"),4)
				Break
			}
			Sleep, 100
		}
	Return
}

7zCleanUp(ExtractedFolder="") {
	Global romTable,dbName,mgEnabled,hpEnabled
	Global 7zEnabled,7zDelTemp,7zCanceled,7z1stRomPath
	7zDeleteFolder := If ExtractedFolder = "" ? 7z1stRomPath : ExtractedFolder
	If (7zEnabled = "true" && (7zDelTemp = "true" or 7zCanceled))	; if user wants to delete temp files or user canceled a 7z extraction
	{	Log("7zCleanUp - Started")
		romTableExists := IsObject(romTable)	; if romTable was ever created, it would be an object, which is what this checks for
		If ((mgEnabled = "true" || hpEnabled = "true") && romTableExists)
		{	Log("7zCleanUp - romTable exists and MG or HP is enabled. Parsing the table to delete any roms that were extracted",4)
			for index, element in romTable
				If % romTable[A_Index, 19]
				{	FileRemoveDir, % romTable[A_Index, 19], 1	; remove each game that was extracted with 7z
					Log("7zCleanUp - Deleted " . romTable[A_Index, 19],4)
				}
				FileRemoveDir, %7zDeleteFolder%, 1 ; still have to remove the rom we launched from HS
				Log("7zCleanUp - Deleted " . 7zDeleteFolder,4)
		} Else {
			FileRemoveDir, %7zDeleteFolder%, 1
			Log("7zCleanUp - Deleted " . 7zDeleteFolder,4)
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

;-------------------------------------------------------------------------------------------------------------
;----------------------------------------- Player Select Menu --------------------------------------
;-------------------------------------------------------------------------------------------------------------

; function to create a small menu with the number of players option
NumberOfPlayersSelectionMenu(maxPlayers=4) {
	Global screenRotationAngle,baseScreenWidth,baseScreenHeight,xTranslation,yTranslation
	Global navSelectKey,navUpKey,navDownKey,navP2SelectKey,navP2UpKey,navP2DownKey,exitEmulatorKey,exitEmulatorKey
	Global keymapper,keymapperEnabled,keymapperHyperLaunchProfileEnabled
	If !pToken
		pToken := Gdip_Startup()
	Gdip_Alt_GetRotatedDimensions(A_ScreenWidth, A_ScreenHeight, screenRotationAngle, baseScreenWidth, baseScreenHeight)
	Gdip_GetRotatedTranslation(baseScreenWidth, baseScreenHeight, screenRotationAngle, xTranslation, yTranslation)
	xTranslation:=round(xTranslation), yTranslation:=round(yTranslation)
	Loop, 2 {
		Gui, playersMenu_GUI%A_Index%: +Disabled -Caption +E0x80000 +OwnDialogs +LastFound +ToolWindow +AlwaysOnTop 
		Gui, playersMenu_GUI%A_Index%: Margin,0,0
		Gui, playersMenu_GUI%A_Index%: Show,, playersMenuLayer%A_Index%
		playersMenu_hwnd%A_Index% := WinExist()
		playersMenu_hbm%A_Index% := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
		playersMenu_hdc%A_Index% := CreateCompatibleDC()
		playersMenu_obm%A_Index% := SelectObject(playersMenu_hdc%A_Index%, playersMenu_hbm%A_Index%)
		playersMenu_G%A_Index% := Gdip_GraphicsFromhdc(playersMenu_hdc%A_Index%)
		Gdip_SetSmoothingMode(playersMenu_G%A_Index%, 4)
		Gdip_TranslateWorldTransform(playersMenu_G%A_Index%, xTranslation, yTranslation)
		Gdip_RotateWorldTransform(playersMenu_G%A_Index%, screenRotationAngle)
	}
	;Initializing parameters
	playersMenuTextFont := "Bebas Neue" 
	CheckFont(playersMenuTextFont)
	playersMenuSelectedTextSize := 50
	playersMenuSelectedTextColor := "FFFFFFFF"
	playersMenuDisabledTextColor := "FFAAAAAA"
	playersMenuDisabledTextSize := 30
	playersMenuMargin := 50
	playersMenuSpaceBtwText := 30
	playersMenuCornerRadius := 10
	;menu scalling factor
	XBaseRes := 1920, YBaseRes := 1080
    If (((A_screenWidth < A_screenHeight) and ((screenRotationAngle=0) or (screenRotationAngle=180))) or ((A_screenWidth > A_screenHeight) and ((screenRotationAngle=90) or (screenRotationAngle=270))))
        XBaseRes := 1080, YBaseRes := 1920
    If !playersMenuXScale 
		playersMenuXScale := baseScreenWidth/XBaseRes
    If !playersMenuYScale
		playersMenuYScale := baseScreenHeight/YBaseRes
	OptionScale(playersMenuSelectedTextSize, playersMenuYScale)
	OptionScale(playersMenuDisabledTextSize, playersMenuYScale)
	OptionScale(playersMenuMargin, playersMenuXScale)
	OptionScale(playersMenuSpaceBtwText, playersMenuYScale)
	OptionScale(playersMenuCornerRadius, playersMenuXScale)	
	playersMenuW := MeasureText("X Players", "Left r4 s" . playersMenuSelectedTextSize . " Bold",playersMenuTextFont) + 2*playersMenuMargin
	playersMenuH := maxPlayers*playersMenuSelectedTextSize + (maxPlayers-1)*playersMenuSpaceBtwText + 2*playersMenuMargin
	playersMenuX := (baseScreenWidth-playersMenuW)//2
	playersMenuY := (baseScreenHeight-playersMenuH)//2
	playersMenuBackgroundBrush := Gdip_BrushCreateSolid("0xDD000000")
	pGraphUpd(playersMenu_G1,playersMenuW,playersMenuH)
	pGraphUpd(playersMenu_G2,playersMenuW,playersMenuH)
	;Drawing Background
	Gdip_Alt_FillRoundedRectangle(playersMenu_G1, playersMenuBackgroundBrush, 0, 0, playersMenuW, playersMenuH,playersMenuCornerRadius)
	Alt_UpdateLayeredWindow(playersMenu_hwnd1, playersMenu_hdc1, playersMenuX, playersMenuY, playersMenuW, playersMenuH)
    ;Drawing choice list   
	SelectedNumberofPlayers := 1
	gosub, DrawPlayersSelectionMenu
	;Enabling Keys
	If (keymapperEnabled = "true") and (keymapperHyperLaunchProfileEnabled = "true")
        RunKeymapper%zz%("menu",keymapper)
	If keymapperAHKMethod = External
		RunAHKKeymapper%zz%("menu")
	Gosub, EnablePlayersMenuKeys
	;Waiting for menu to exit
	Loop
	{	If PlayersMenuExit
			Break
		Sleep, 100
	}
	Return SelectedNumberofPlayers
	;labels to treat menu changes
	DrawPlayersSelectionMenu:
		currentY := 0
		Gdip_GraphicsClear(playersMenu_G2)
		Loop, % maxPlayers
		{
			If (a_index=SelectedNumberofPlayers) {
				currentTextSize := playersMenuSelectedTextSize
				currentTextColor := playersMenuSelectedTextColor
				currentTextStyle := "bold"
			} Else {
				currentTextSize := playersMenuDisabledTextSize
				currentTextColor := playersMenuDisabledTextColor
				currentTextStyle := "normal"
			}
			If (a_index=1)
				currentText := "1 Player"
			Else
				currentText := a_index . " Players"
			currentY := playersMenuMargin + (a_index-1)*(playersMenuSelectedTextSize+playersMenuSpaceBtwText)+(playersMenuSelectedTextSize-currentTextSize)//2
			Gdip_Alt_TextToGraphics(playersMenu_G2, currentText, "x0 y" . currentY . " Center c" . currentTextColor . " r4 s" . currentTextSize . " " . currentTextStyle, playersMenuTextFont, playersMenuW, playersMenuSelectedTextSize)
		}
		Alt_UpdateLayeredWindow(playersMenu_hwnd2, playersMenu_hdc2, playersMenuX, playersMenuY, playersMenuW, playersMenuH)
	Return
	EnablePlayersMenuKeys:
		XHotKeywrapper(navSelectKey,"PlayersMenuSelect","ON") 
		XHotKeywrapper(navUpKey,"PlayersMenuUP","ON")
		XHotKeywrapper(navDownKey,"PlayersMenuDown","ON")
		XHotKeywrapper(navP2SelectKey,"PlayersMenuSelect","ON") 
		XHotKeywrapper(navP2UpKey,"PlayersMenuUP","ON")
		XHotKeywrapper(navP2DownKey,"PlayersMenuDown","ON")
		XHotKeywrapper(exitEmulatorKey,"CloseProcess","OFF")
		XHotKeywrapper(exitEmulatorKey,"ClosePlayersMenu","ON")
	Return
	DisablePlayersMenuKeys:
		XHotKeywrapper(navSelectKey,"PlayersMenuSelect","OFF") 
		XHotKeywrapper(navUpKey,"PlayersMenuUP","OFF")
		XHotKeywrapper(navDownKey,"PlayersMenuDown","OFF")
		XHotKeywrapper(navP2SelectKey,"PlayersMenuSelect","OFF") 
		XHotKeywrapper(navP2UpKey,"PlayersMenuUP","OFF")
		XHotKeywrapper(navP2DownKey,"PlayersMenuDown","OFF")
		XHotKeywrapper(exitEmulatorKey,"ClosePlayersMenu","OFF")
		XHotKeywrapper(exitEmulatorKey,"CloseProcess","ON")
	Return
	PlayersMenuUP:
		SelectedNumberofPlayers--
		If (SelectedNumberofPlayers<1)
			SelectedNumberofPlayers:=maxPlayers
		gosub, DrawPlayersSelectionMenu
	Return
	PlayersMenuDown:
		SelectedNumberofPlayers++
		If (SelectedNumberofPlayers>maxPlayers)
			SelectedNumberofPlayers:=1
		gosub, DrawPlayersSelectionMenu
	Return
	ClosePlayersMenu:
		ClosedPlayerMenu := true
	PlayersMenuSelect:
		Gosub, DisablePlayersMenuKeys
		Gdip_DeleteBrush(playersMenuBackgroundBrush)
		Loop, 2 {
			SelectObject(playersMenu_hdc%A_Index%, playersMenu_obm%A_Index%)
			DeleteObject(playersMenu_hbm%A_Index%)
			DeleteDC(playersMenu_hdc%A_Index%)
			Gdip_DeleteGraphics(playersMenu_G%A_Index%)
			Gui, playersMenu_GUI%A_Index%: Destroy
		}
		If ClosedPlayerMenu
		{	Log("User cancelled the launch at the Player Select Menu")
			PlayersMenuExit := true
			ExitModule()
		} Else
			Log("Number of Players Selected: " . SelectedNumberofPlayers)
		If (keymapperEnabled = "true") and (keymapperHyperLaunchProfileEnabled = "true")
			RunKeymapper%zz%("load", keymapper)
		If keymapperAHKMethod = External
			RunAHKKeymapper%zz%("load")
		PlayersMenuExit := true
	Return
}


;-------------------------------------------------------------------------------------------------------------
;----------------------------------------- HideEmu Functions ---------------------------------------
;-------------------------------------------------------------------------------------------------------------

; Default is 2ms so it picks up windows as soon as possible
HideEmuStart(ms=2) {
	Global hideEmu
	Global hideEmuObj
	If hideEmu = true
	{	Log("HideEmuStart - Starting HideEmuTimer, scanning for windows defined in hideEmuObj every " . ms . "ms")
		; First rebuild the single line object into a better one that's easier to track and work with
		newObject := Object()
		For key, value in hideEmuObj
		{	currentObj++
			newObject[currentObj,"window"] := key
			newObject[currentObj,"method"] := value
			newObject[currentObj,"status"] :=	; default is 0 (0 = not hidden yet, 1 = hidden already)
		}
		hideEmuObj := newObject	; overwrite hideEmuObj with the updated one
		SetTimer, HideEmuTimer, %ms%
		Log("HideEmuStart - Ended")
	}
}

HideEmuEnd() {
	Global hideEmu
	Global hideEmuObj
	If hideEmu = true
	{	Log("HideEmuEnd - Stopping HideEmuTimer and unhiding flagged windows",4)
		SetTimer, HideEmuTimer, Off
		For key, value in hideEmuObj
			If (hideEmuObj[A_Index,"method"] && hideEmuObj[A_Index,"status"]) { 	; if one of the windows was hidden and needs to be unhidden
				WinSet, Transparent, Off, % hideEmuObj[A_Index,"window"]
				Log("HideEmu - Revealed window: " . hideEmuObj[A_Index,"window"],4)
			}
		Log("HideEmuEnd - Ended",4)
	}
}

HideEmuTimer:
	For key, value in hideEmuObj
	{	If !hideEmuObj[A_Index,"status"]	; if one of the windows was not hidden yet
			IfWinExist, % hideEmuObj[A_Index,"window"]
			{	WinSet, Transparent, 0, % hideEmuObj[A_Index,"window"]
				hideEmuObj[A_Index,"status"] := 1	; update object that this window is now hidden
				Log("HideEmu - Found a new window to hide: " . hideEmuObj[A_Index,"window"],4)
			}
	}
Return


;-------------------------------------------------------------------------------------------------------------
;---------------------------------------- Decryption Functions -------------------------------------
;-------------------------------------------------------------------------------------------------------------

Decrypt(T,key)                   ; Text, key-name
{
   Local p, i, L, u, v, k5, a, c

   StringLeft p, T, 8
   If p is not xdigit            ; if no IV: Error
   {
      ErrorLevel = 1
      Return
   }
   StringTrimLeft T, T, 8        ; remove IV from text (no separator)
   k5 = 0x%p%                    ; set new IV
   p = 0                         ; counter to be Encrypted
   i = 9                         ; pad-index, force restart
   L =                           ; processed text
   k0 := %key%0
   k1 := %key%1
   k2 := %key%2
   k3 := %key%3
   Loop % StrLen(T)
   {
      i++
      IfGreater i,8, {           ; all 9 pad values exhausted
         u := p
         v := k5                 ; IV
         p++                     ; increment counter
         TEA(u,v, k0,k1,k2,k3)
         Stream9(u,v)            ; 9 pads from Encrypted counter
         i = 0
      }
      StringMid c, T, A_Index, 1
      a := Asc(c)
      if a between 32 and 126
      {                          ; chars > 126 or < 31 unchanged
         a -= s%i%
         IfLess a, 32, SetEnv, a, % a+95
         c := Chr(a)
      }
      L = %L%%c%                 ; attach Encrypted character
   }
   Return L
}

TEA(ByRef y,ByRef z,k0,k1,k2,k3) ; (y,z) = 64-bit I/0 block
{                                ; (k0,k1,k2,k3) = 128-bit key
   IntFormat = %A_FormatInteger%
   SetFormat Integer, D          ; needed for decimal indices
   s := 0
   d := 0x9E3779B9
   Loop 32
   {
      k := "k" . s & 3           ; indexing the key
      y := 0xFFFFFFFF & (y + ((z << 4 ^ z >> 5) + z  ^  s + %k%))
      s := 0xFFFFFFFF & (s + d)  ; simulate 32 bit operations
      k := "k" . s >> 11 & 3
      z := 0xFFFFFFFF & (z + ((y << 4 ^ y >> 5) + y  ^  s + %k%))
   }
   SetFormat Integer, %IntFormat%
   y += 0
   z += 0                        ; Convert to original ineger format
}

Stream9(x,y)                     ; Convert 2 32-bit words to 9 pad values
{                                ; 0 <= s0, s1, ... s8 <= 94
   Local z                       ; makes all s%i% global
   s0 := Floor(x*0.000000022118911147) ; 95/2**32
   Loop 8
   {
      z := (y << 25) + (x >> 7) & 0xFFFFFFFF
      y := (x << 25) + (y >> 7) & 0xFFFFFFFF
      x  = %z%
      s%A_Index% := Floor(x*0.000000022118911147)
   }
}


;-------------------------------------------------------------------------------------------------------------
;------------------------------------ Registry Access Functions ----------------------------------
;-------------------------------------------------------------------------------------------------------------

RegRead(RootKey, SubKey, ValueName = "", RegistryVersion="32") 
{	Global winVer
	Log("RegRead - Reading from Registry : RootKey=" . RootKey . ", SubKey=" . SubKey . ", ValueName=" . ValueName . ",RegistryVersion=" . RegistryVersion, 4)
        If (RegistryVersion = "Auto") ;Try finding the correct registry reading based on the windows version
        {
            If (winVer = "64")
                If !OutputVar := RegRead(RootKey, SubKey, ValueName, "64")
                OutputVar := RegRead(RootKey, SubKey, ValueName, "32")
            Else
                OutputVar := RegRead(RootKey, SubKey, ValueName)
        }
	Else If (RegistryVersion = "32")
		RegRead, OutputVar, %RootKey%, %SubKey%, %ValueName%
	Else
		OutputVar := RegRead64(RootKey, SubKey, ValueName)
	Log("RegRead - Registry Read finished, returning " . OutputVar, 4)
	Return OutputVar
}

RegWrite(ValueType, RootKey, SubKey, ValueName = "", Value = "", RegistryVersion="32")
{
	Log("RegWrite - Writing to Registry : RootKey=" . RootKey . ", SubKey=" . SubKey . ", ValueName=" . ValueName . ",Value=" . Value . ",ValueType=" . ValueType . ",RegistryVersion=" . RegistryVersion, 4)
	If (RegistryVersion = "32")
		RegWrite, %ValueType%, %RootKey%, %SubKey%, %ValueName%, %Value%
	Else
		RegWrite64(ValueType, RootKey, SubKey, ValueName, Value)
	Log("RegWrite - Registry Write finished", 4)
}

; --------------------------------------------------

GetTimeString(time) {
	If (time<0)
		Return time
	If time is not number
		Return time
	Days := time // 86400
	Hours := Mod(time, 86400) // 3600
	Minutes := Mod(time, 3600) // 60
	Seconds := Mod(time, 60)
	If (Days<>0) {
		If Strlen(Hours) = 1
			Hours = 0%Hours%
		If Strlen(Minutes) = 1
			Minutes = 0%Minutes%
		If Strlen(Seconds) = 1
			Seconds = 0%Seconds%
		TimeString = %Days%d %Hours%h %Minutes%m %Seconds%s
	} Else If (Hours<>0) {
		If Strlen(Minutes) = 1
			Minutes = 0%Minutes%
		If Strlen(Seconds) = 1
			Seconds = 0%Seconds%
		TimeString = %Hours%h %Minutes%m %Seconds%s
	} Else If (Minutes<>0) {
		If Strlen(Seconds) = 1
			Seconds = 0%Seconds%
		TimeString = %Minutes%m %Seconds%s
	} Else If (Seconds<>0)
		TimeString = %Seconds%s
	Else
		TimeString = 
	Return TimeString
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

OptionScale(ByRef option, scale){ ;selects portrait specifc option value if needed and scales variable to adjust to screen resolution
    Global screenRotationAngle
    if InStr(option,"|")
        {
        StringSplit, opt, option, |
        if ((opt2) and (((A_screenWidth < A_screenHeight) and ((screenRotationAngle=0) or (screenRotationAngle=180))) or ((A_screenWidth > A_screenHeight) and ((screenRotationAngle=90) or (screenRotationAngle=270)))))
            option := if (SubStr(opt2, 0)="p") ? opt2 : round(opt2 * scale)
        else
            option := if (SubStr(opt1, 0)="p") ? opt1 : round(opt1 * scale)
    } else
        option := if (SubStr(option, 0)="p") ? option : round(option * scale)
} 



TextOptionScale(ByRef Option,XScale, YScale){
	RegExMatch(Option, "i)X([\-\d\.]+)(p*)\|([\-\d\.]+)(p*)|X([\-\d\.]+)(p*)", xpos)
	RegExMatch(Option, "i)Y([\-\d\.]+)(p*)\|([\-\d\.]+)(p*)|Y([\-\d\.]+)(p*)", ypos)
	RegExMatch(Option, "i)W([\-\d\.]+)(p*)\|([\-\d\.]+)(p*)|W([\-\d\.]+)(p*)", Width)
	RegExMatch(Option, "i)H([\-\d\.]+)(p*)\|([\-\d\.]+)(p*)|H([\-\d\.]+)(p*)", Height)
	RegExMatch(Option, "i)S([\-\d\.]+)(p*)\|([\-\d\.]+)(p*)|S([\-\d\.]+)", Size)
	xposValue := SubStr(xpos, 2), yposValue := SubStr(ypos, 2), WidthValue := SubStr(Width, 2), HeightValue := SubStr(Height, 2), SizeValue := SubStr(Size, 2)
	OptionScale(xposValue, XScale)
	OptionScale(yposValue, YScale)
	OptionScale(WidthValue, XScale)
	OptionScale(HeightValue, YScale)
	OptionScale(SizeValue, YScale)
	Option := RegExReplace(Option, "i)X([\-\d\.]+)(p*)\|([\-\d\.]+)(p*)|X([\-\d\.]+)(p*)", "x" .  xposValue)
	Option := RegExReplace(Option, "i)Y([\-\d\.]+)(p*)\|([\-\d\.]+)(p*)|Y([\-\d\.]+)(p*)", "y" .  yposValue)
	Option := RegExReplace(Option, "i)W([\-\d\.]+)(p*)\|([\-\d\.]+)(p*)|W([\-\d\.]+)(p*)", "w" .  WidthValue)
	Option := RegExReplace(Option, "i)H([\-\d\.]+)(p*)\|([\-\d\.]+)(p*)|H([\-\d\.]+)(p*)", "h" .  HeightValue)
	Option := RegExReplace(Option, "i)S([\-\d\.]+)(p*)\|([\-\d\.]+)(p*)|S([\-\d\.]+)", "s" .  SizeValue)
}

GetOSVersion() {
    VarSetCapacity(v,148), NumPut(148,v)
    DllCall("GetVersionEx", "uint", &v)
    ; Return formatted version string similar to A_AhkVersion.
    ; Assume build number will never be more than 4 characters.
    return    NumGet(v,4) ; major
        . "." NumGet(v,8) ; minor
        . "." SubStr("0000" NumGet(v,12), -3) ; build
}

;-------------------------------------------------------------------------------------------------------------
;---------------------------- Open And Close Process Functions ----------------------------
;-------------------------------------------------------------------------------------------------------------

ProcSus(PID_or_Name) {
	Log("ProcSus -  Started",4)
	If InStr(PID_or_Name, ".") {
		Process, Exist, %PID_or_Name%
		PID_or_Name := ErrorLevel
	}
	If !(h := DllCall("OpenProcess", "uInt", 0x1F0FFF, "Int", 0, "Int", PID_or_Name)) {
		Log("ProcSus - Ended, process """ . PID_or_Name . """ not found")
		Return -1
	}
	Log("ProcSus -  Suspending Process: " . PID_or_Name)
	DllCall("ntdll.dll\NtSuspendProcess", "Int", h), DllCall("CloseHandle", "Int", h)
	Log("ProcSus -  Ended",4)
}

ProcRes(PID_or_Name) {
	Log("ProcRes -  Started",4)
	If InStr(PID_or_Name, ".") {
		Process, Exist, %PID_or_Name%
		PID_or_Name := ErrorLevel
	}
	If !(h := DllCall("OpenProcess", "uInt", 0x1F0FFF, "Int", 0, "Int", PID_or_Name)) {
		Log("ProcRes - Ended, process """ . PID_or_Name . """ not found")
		Return -1
	}
	Log("ProcRes -  Resuming Process: " . PID_or_Name)
	DllCall("ntdll.dll\NtResumeProcess", "Int", h), DllCall("CloseHandle", "Int", h)
	Log("ProcRes -  Ended",4)
}

;-------------------------------------------------------------------------------------------------------------
;--------------------------------------- Validate IP Functions ---------------------------------------
;-------------------------------------------------------------------------------------------------------------

ValidIP(a) {
   Loop, Parse, a, .
   {
      If A_LoopField is digit
         If A_LoopField between 0 and 255
            e++
      c++
   }
   Return, e = 4 AND c = 4
}

ValidPort(a) {
	If a is digit
		If a between 0 and 65535
			e++
   Return e
}

GetPublicIP() {
	UrlDownloadToFile, http://www.hyperlaunch.net/ipcheck/myip.php, %A_Temp%\myip.txt
	FileRead, extIP, %A_Temp%\myip.txt
	Return extIP
}

GetLocalIP() {
	array := []
	objWMIService := ComObjGet("winmgmts:{impersonationLevel = impersonate}!\\.\root\cimv2")
	colItems := objWMIService.ExecQuery("Select * from Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")._NewEnum
	while colItems[objItem]
	{
		array[A_Index,1] := objItem.Description[0]
		array[A_Index,2] := objItem.IPAddress[0]
		array[A_Index,3] := objItem.IPSubnet[0]
		array[A_Index,4] := objItem.DefaultIPGateway[0]
		array[A_Index,5] := objItem.DNSServerSearchOrder[0]
		array[A_Index,6] := objItem.MACAddress[0]
		array[A_Index,7] := objItem.DHCPEnabled[0]
	}
	Return array
}


;-------------------------------------------------------------------------------------------------------------
;------------------------------------------- Rotate Screen Functions -------------------------------------------
;-------------------------------------------------------------------------------------------------------------

; Options:
; method = irotate, display, or shortcut
; degrees = 0, 90, 180, 270

Rotate(method="irotate", degrees=0) {
	Log("Rotate -  Started")
	Global moduleExtensionsPath
	arrowKeys := { 0: "Up", 1: "Right", 2: "Down", 3: "Left" }
	If method not in irotate,display,shortcut
		ScriptError("""" . method . """ is not a valid rotate method, Please choose either ""irotate"" or ""display""")
	If degrees not in 0,90,180,270
		ScriptError("""" . degrees . """ is not a valid degree to rotate to, Please choose either 0, 90, 180, or 270")
	rotateExe := CheckFile(moduleExtensionsPath . "\" . method . ".exe")	; check If the exe to our RotateMethod method exists
	If (method = "irotate") {
		Log("Rotate -  Rotating display using irotate.exe to " . degrees . " degrees",4)
		Run(rotateExe . " /rotate=" degrees " /exit", moduleExtensionsPath)
	} Else If (method = "display") {
		Log("Rotate -  Rotating display using display.exe to " . degrees . " degrees",4)
		Run(rotateExe . " /rotate:" degrees, moduleExtensionsPath)
	} Else If (method = "shortcut") {
		Log("Rotate -  Rotating display using shortcut keys to " . degrees . " degrees",4)
		Send, % "{LControl Down}{LAlt Down}{"	. arrowKeys[degrees // 90] . " Down}{LControl Up}{LAlt Up}{"	. arrowKeys[degrees // 90] . " Up}" 
	}
	Log("Rotate -  Ended")
}


;-------------------------------------------------------------------------------------------------------------
;-------------------------------------------- Database Asset Building ------------------------------------------
;-------------------------------------------------------------------------------------------------------------

; Builds an object filled with the FE's assets

BuildAssetsTable(list,label,AssetType,extensions=""){
	Log("BuildAssetsTable - Started - Building Table for: " . label,4)
	Global logLevel
	StringReplace, extensions, extensions, |, `,,All
	obj:={}
	stringSplit, labelArray, label, |,
	stringSplit, AssetTypeArray, AssetType, |,
	loop, parse, list,|, 
	{
		if !(labelArray%A_index% = "#disabled#")
		{
			Log("BuildAssetsTable - Searching for: " . A_LoopField,4)
			currentLabel := labelArray%A_index%
			currentAssetType := AssetTypeArray%A_index% 
			RASHNDOCT := FileExist(A_LoopField)
			if InStr(RASHNDOCT, "D") { ; it is a folder
				folderName := A_LoopFileName
				Loop, % A_LoopField . "\*.*"
				{   If A_LoopFileExt in %extensions%
					{	currentobj := {}
						if (currentLabel="keepFileName")
							currentobj["Label"] := folderName
						else
							currentobj["Label"] := currentLabel
						if obj[currentLabel].Label
						{   currentobj := obj[currentLabel]
							currentobj.TotalItems := currentobj.TotalItems+1
						} else {
							currentobj.TotalItems := 1
							obj.TotalLabels := if obj.TotalLabels ? obj.TotalLabels + 1 : 1
							obj[obj.TotalLabels] := currentobj.Label
						}
						currentobj["Path" . currentobj.TotalItems] := A_LoopFileLongPath
						currentobj["Ext" . currentobj.TotalItems] := A_LoopFileExt
						currentobj["AssetType"] := currentAssetType
						currentobj["Type"] := "ImageGroup"
						obj.Insert(currentobj["Label"], currentobj)
					}
				}
			} else if InStr(RASHNDOCT, "A") { ; it is a file
				SplitPath, A_LoopField, , currentDir,, FileNameWithoutExtension
				loop, parse, extensions,`,, 
				{
					If FileExist(currentDir . "\" . FileNameWithoutExtension . "." . A_LoopField)
					{	currentobj := {}
						if (currentLabel="keepFileName")
							currentobj["Label"] := FileNameWithoutExtension
						else
							currentobj["Label"] := currentLabel
						if obj[FileNameWithoutExtension].Label
						{   currentobj := obj[FileNameWithoutExtension]
							currentobj.TotalItems := currentobj.TotalItems+1
						} else {
							currentobj.TotalItems := 1
							obj.TotalLabels := if obj.TotalLabels ? obj.TotalLabels + 1 : 1
							obj[obj.TotalLabels] := currentobj.Label
						}
						currentobj["Path" . currentobj.TotalItems] := currentDir . "\" . FileNameWithoutExtension . "." . A_LoopField
						currentobj["Ext" . currentobj.TotalItems] := A_LoopField
						currentobj["AssetType"] := currentAssetType
						obj.Insert(currentobj["Label"], currentobj)  
					}	
				}
		}	}			
	}		
	if (logLevel>=5){
		for index, element in obj
		{	loop, % obj[element.Label].TotalItems
				mediaAssetsLog := % mediaAssetsLog . "`r`n`t`t`t`t`tAsset Label: " . element.Label . " | Asset Path" . a_index . ":  " . element["Path" . a_index] . " | Asset Extension" . a_index . ":  " . element["Ext" . a_index] . " | Asset Type" . a_index . ":  " . element["AssetType"]
		}
		if mediaAssetsLog
            Log("BuildAssetsTable - Media assets found: " . mediaAssetsLog,5)
	}
	Log("BuildAssetsTable - Ended",4)
	Return obj
}
