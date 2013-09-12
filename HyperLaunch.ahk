;-----------------------------------------------------------------------------------------------------------------------------------------
; HyperLaunch V3.0.1.0
; By djvj
; Requires AutoHotkey.dll - Must reside in the HyperLaunch root directory
;
; GUI Reserved Index:
; 1-10: Reserved for Modules
; 11-20: HyperLaunch
; 	- 16 - MG Layer 1 (background & text)
; 	- 17 - MG Layer 2 (media)
; 	- 18 - Not used
; 	- 19 - mgBlackScreen (initial black screen to hide HS)
; 	- 20 - Black background for hiding HS
; 21-30: HyperPause
;	- HP_GUI21 - Loading Screen and Black Screen to Hide your Frontend 
;	- HP_GUI22 - Background (covers entire screen) 
;	- HP_GUI23 - Moving description
;	- HP_GUI24 - Main Menu bar 
;	- HP_GUI25 - Submenus 
;	- HP_GUI26 - Disc Rotation, animations, submenu animations 
;	- HP_GUI27 - Full Screen drawing while changing screens in HP (covers entire screen) 
;	- HP_GUI28 - Clock 
;	- HP_GUI29 - ActiveX Video

; romTable Column Index:
; Column 1: Full Path Name - ex. D:\Roms\Final Fantasy VII (USA) (Disc 1).7z
; Column 2: Filename w/ext - ex. Final Fantasy VII (USA) (Disc 1).7z
; Column 3: Filename w/o ext - ex. Final Fantasy VII (USA) (Disc 1)
; Column 4: Filename w/o media - ex. Final Fantasy VII (USA)
; Column 5: Full media type and # - ex. Disc 1
; Column 6: Media type only - ex. Disc
; Column 7: RESERVED
; Column 8: RESERVED
; Column 9: RESERVED
; Column 10: X pos of image - ex. 106.000000
; Column 11: Y pos of image - ex. 500
; Column 12: Current Button Original Width - ex. 500
; Column 13: Current Button Original Height - ex. 500
; Column 14: Current Button Adjusted Width - ex. 250.000000
; Column 15: Current Button Adjusted Height - ex. 250.000000
; Column 16: Media art found - ex. Yes
; Column 17: GDI Image 1 Pointer (custom and default media) - ex. 36293640
; Column 18: GDI Image 2 Pointer (only for default media) - ex. 83459041
; Column 19 (path to 7z extracted rom): - ex. C:\Users\djvj\AppData\Local\Temp\HS\Final Fantasy VII (USA) (Disc 1)

; romMapTable Column Index:
; Each ini file found gets stored in its own row
; Column 1: Path to ini file
; Column 2: Value of Alternate_Archive_Name
; Column 3: Value of Alternate_Rom_Name or Alternate_Rom_Name_1
; Column 4+: Value of each consecutive Alternate_Rom_Name_#

; RIni Reference Index:
; 1 = Settings\Global HyperLaunch.ini
; 2 = Settings\System\HyperLaunch.ini
; 3 = Settings\Global Emulators.ini
; 4 = Settings\System\Emulators.ini
; 5 = Settings\HyperLaunch.ini
; 6 = Settings\System\Games.ini
; 7+= Settings\System\Rom Mapping\*.ini

; CRC checked files:
; Gdip, CLR, COM, VA, RIni, xpath libraries
; Modules and all \Lib files
;-----------------------------------------------------------------------------------------------------------------------------------------
 
; #NoTrayIcon
#SingleInstance Ignore
#InstallKeybdHook
#Include, %A_ScriptDir%\Module Extensions	; change all future includes to look in the Module Extensions folder
#Include, CLR.ahk
#Include, COM.ahk
#Include, RIni.ahk

#Include, JSON.ahk
#EscapeChar `
#CommentFlag ;

SetTitleMatchMode 2
CoordMode, ToolTip, Screen ; Place ToolTips at absolute screen coordinates
DetectHiddenWindows, ON
SetWorkingDir % A_ScriptDir
Version = 3.0.1.0

;-----------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------
; Main
;-----------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------

; Defining path for the Module Extension folder
moduleExtensionsPath := A_ScriptDir . "\Module Extensions"
; Defining path for the Lib folder
libPath := A_ScriptDir . "\Lib"

; Need to open a COM object for CRC checks in the main HL thread. This needs to exist above the first CheckFile CRC check
HyperLaunchDllFile=%moduleExtensionsPath%\HyperLaunch.dll
IfNotExist, %HyperLaunchDllFile%
{	MsgBox, 16, Error, Missing %HyperLaunchDllFile%, 5
	ExitApp
}
CLR_Start()
If !hModule := CLR_LoadLibrary(HyperLaunchDllFile)
	ScriptError("Error loading the DLL: " . HyperLaunchDllFile)
If !HLObject := CLR_CreateObject(hModule,"HLUtil.HyperLaunchUtils")
	ScriptError("Error creating object. There may be something wrong with the dll file:" . HyperLaunchDllFile)

; Downloading automatically and defining path for gdip library. Fade, MultiGame, HyperPause, and all Script Errors use this library
IfNotExist, % moduleExtensionsPath . "\Gdip.ahk"
	URLDownload("http://www.autohotkey.net/~tic/Gdip.ahk",moduleExtensionsPath . "\Gdip.ahk","Error downloading gdip.ahk to " . moduleExtensionsPath . "`n Either the download is unavailable or admin privledges are needed to write to this folder.")

rIniIndex := {}	; initialize the RIni array
HLFile := A_ScriptDir . "\Settings\HyperLaunch.ini"
IfNotExist, %HLFile%
	CreateDefaultIni(HLFile,"HL")
RIni_Read(5,HLFile)
rIniIndex[5] := HLFile	; assign to array

globalHLFile := A_ScriptDir . "\Settings\Global HyperLaunch.ini"
IfNotExist, %globalHLFile%
	CreateDefaultIni(globalHLFile,"globalHL")
RIni_Read(1,globalHLFile)
rIniIndex[1] := globalHLFile	; assign to array

globalEmuFile := A_ScriptDir . "\Settings\Global Emulators.ini"
IfNotExist, %globalEmuFile%
	CreateDefaultIni(globalEmuFile,"globalEmu")
RIni_Read(3,globalEmuFile)
rIniIndex[3] := globalEmuFile	; assign to array

; Need this up top so errors will use the error sounds
HLMediaPath := RIniLoadVar(5,"", "Settings", "HyperLaunch_Media_Path", ".\Media")
HLMediaPath := GetFullName(HLMediaPath)	; converts relative path to absolute
HLErrSoundPath := HLMediaPath . "\Sounds\Error"		; Defining path for error sounds
IfNotExist, %HLErrSoundPath%
	FileCreateDir, %HLErrSoundPath%

; Read the modules path
modulesPath := RIniLoadVar(5,"", "Settings", "Modules_Path", ".\Modules")
modulesPath := GetFullName(modulesPath)	; converts relative path to absolute

; Read the last system and last rom so we dont have to fill it in for testing every time
lastSystem := RIniLoadVar(5,"", "Settings", "Last_System", A_Space)
lastRom := RIniLoadVar(5,"", "Settings", "Last_Rom", A_Space)

hideCursor := RIniLoadVar(1,"", "Desktop", "Hide_Cursor", "false")
hideCursorChecked := If (hideCursor = "true") ? 1 : 0

hideDesktop := RIniLoadVar(1,"", "Desktop", "Hide_Desktop", "false")
hideDesktopChecked := If (hideDesktop = "true") ? 1 : 0

hideTaskbar := RIniLoadVar(1,"", "Desktop", "Hide_Taskbar", "false")
hideTaskbarChecked := If (hideTaskbar = "true") ? 1 : 0

; Storing the users original resolution for use in modules. Sometimes GUIs need these before an emu changes the resolution to properly show them
originalWidth := A_ScreenWidth
originalHeight := A_ScreenHeight

; Stoaring the FE's x,y,width, & height to restore it on exit if an application changed it going fullscreen
frontendPath := RIniLoadVar(5,"", "Settings", "Frontend_Path", "..\HyperSpin.exe")
frontendPath:=GetFullName(frontendPath)	; converts relative path to absolute
SplitPath,frontendPath,frontendExe,frontendPath,frontendExt,frontendName,frontendDrive
Process, Exist, %frontendExe%
frontendPID := ErrorLevel
If frontendPID	; If the FE is running, store the position and size
	WinGetPos, frontendX, frontendY, frontendW, frontendH, ahk_pid %frontendPID%

;-----------------------------------------------------------------------------------------------------------------------------------------
; Starting Log
;-----------------------------------------------------------------------------------------------------------------------------------------
logFile = %A_ScriptDir%\HyperLaunch.log
logLabel := ["    INFO"," WARNING","   ERROR","  DEBUG1","  DEBUG2"]
logLevel := RIniLoadVar(5,"", "Logging", "Logging_Level", 3)
logIncludeModule := RIniLoadVar(5,"", "Logging", "Logging_Include_Module", "true")
logIncludeFileProperties := RIniLoadVar(5,"", "Logging", "Logging_Include_File_Properties", "true")
logShowCommandWindow := RIniLoadVar(5,"", "Logging", "Logging_Show_Command_Window", "false")
logCommandWindow := RIniLoadVar(5,"", "Logging", "Logging_Log_Command_Window", "false")
FileDelete, %logFile%
If logLevel >= 4
	COM_Invoke(HLObject, "setLogMode", "2")	; Turn on dll logging if we are debugging

Log("[code]",,"start",1)
Log("Main - HyperLaunch v" . Version,,,,1)
isAdmin:=(If A_IsAdmin=1 ? ("Yes") : ("No"))
OSLang := Object(0436,"Afrikaans","041c","Albanian",0401,"Arabic_Saudi_Arabia",0801,"Arabic_Iraq","0c01","Arabic_Egypt",0401,"Arabic_Saudi_Arabia",0801,"Arabic_Iraq","0c01","Arabic_Egypt",1001,"Arabic_Libya",1401,"Arabic_Algeria",1801,"Arabic_Morocco","1c01","Arabic_Tunisia",2001,"Arabic_Oman",2401,"Arabic_Yemen",2801,"Arabic_Syria","2c01","Arabic_Jordan",3001,"Arabic_Lebanon",3401,"Arabic_Kuwait",3801,"Arabic_UAE","3c01","Arabic_Bahrain",4001,"Arabic_Qatar","042b","Armenian","042c","Azeri_Latin","082c","Azeri_Cyrillic","042d","Basque",0423,"Belarusian",0402,"Bulgarian",0403,"Catalan",0404,"Chinese_Taiwan",0804,"Chinese_PRC","0c04","Chinese_Hong_Kong",1004,"Chinese_Singapore",1404,"Chinese_Macau","041a","Croatian",0405,"Czech",0406,"Danish",0413,"Dutch_Standard",0813,"Dutch_Belgian",0409,"English_United_States",0809,"English_United_Kingdom","0c09","English_Australian",1009,"English_Canadian",1409,"English_New_Zealand",1809,"English_Irish","1c09","English_South_Africa",2009,"English_Jamaica",2409,"English_Caribbean",2809,"English_Belize","2c09","English_Trinidad",3009,"English_Zimbabwe",3409,"English_Philippines",0425,"Estonian",0438,"Faeroese",0429,"Farsi","040b","Finnish","040c","French_Standard","080c","French_Belgian","0c0c","French_Canadian","100c","French_Swiss","140c","French_Luxembourg","180c","French_Monaco",0437,"Georgian",0407,"German_Standard",0807,"German_Swiss","0c07","German_Austrian",1007,"German_Luxembourg",1407,"German_Liechtenstein",0408,"Greek","040d","Hebrew",0439,"Hindi","040e","Hungarian","040f","Icelandic",0421,"Indonesian",0410,"Italian_Standard",0810,"Italian_Swiss",0411,"Japanese","043f","Kazakh",0457,"Konkani",0412,"Korean",0426,"Latvian",0427,"Lithuanian","042f","Macedonian","043e","Malay_Malaysia","083e","Malay_Brunei_Darussalam","044e","Marathi",0414,"Norwegian_Bokmal",0814,"Norwegian_Nynorsk",0415,"Polish",0416,"Portuguese_Brazilian",0816,"Portuguese_Standard",0418,"Romanian",0419,"Russian","044f","Sanskrit","081a","Serbian_Latin","0c1a","Serbian_Cyrillic","041b","Slovak",0424,"Slovenian","040a","Spanish_Traditional_Sort","080a","Spanish_Mexican","0c0a","Spanish_Modern_Sort","100a","Spanish_Guatemala","140a","Spanish_Costa_Rica","180a","Spanish_Panama","1c0a","Spanish_Dominican_Republic","200a","Spanish_Venezuela","240a","Spanish_Colombia","280a","Spanish_Peru","2c0a","Spanish_Argentina","300a","Spanish_Ecuador","340a","Spanish_Chile","380a","Spanish_Uruguay","3c0a","Spanish_Paraguay","400a","Spanish_Bolivia","440a","Spanish_El_Salvador","480a","Spanish_Honduras","4c0a","Spanish_Nicaragua","500a","Spanish_Puerto_Rico",0441,"Swahili","041d","Swedish","081d","Swedish_Finland",0449,"Tamil",0444,"Tatar","041e","Thai","041f","Turkish",0422,"Ukrainian",0420,"Urdu","042a","Vietnamese")
logTxt := "Main - System Specs:`n`t`t`t`t`tHyperLaunch Dir: " . A_ScriptDir . "`n`t`t`t`t`tOS: " . A_OSVersion . "`n`t`t`t`t`tArchitecture: " . (A_Is64bitOS ? "64-bit" : "32-bit") . " (might not be accurate)`n`t`t`t`t`tOS Language: " . (OSLang[A_Language] ? OSLang[A_Language] : A_Language) . "`n`t`t`t`t`tOS Admin Status: " . isAdmin:=(If A_IsAdmin=1 ? ("Yes") : ("No"))
SysGet, MonitorCount, MonitorCount, SysGet, MonitorPrimary, MonitorPrimary
Loop, %MonitorCount% ; get each monitor's stats for the log
{	
	SysGet, MonitorName, MonitorName, %A_Index%
	SysGet, Monitor%A_Index%, Monitor, %A_Index%
	SysGet, MonitorWorkArea%A_Index%, MonitorWorkArea, %A_Index%
	logTxt .= "`n`t`t`t`t`tMonitor #" . A_Index . (If MonitorPrimary = A_Index ? (" (Primary)"):("")) . " (" . MonitorName . "): " . Monitor%A_Index%Right . "x" . Monitor%A_Index%Bottom . " (" . MonitorWorkArea%A_Index%Right . "x" . MonitorWorkArea%A_Index%Bottom . " work)"
}
logTxt .= "`n`t`t`t`t`tAutoHotkey Path: " A_AHKPath . "`n`t`t`t`t`tAHK Version: " . A_AhkVersion . "`n`t`t`t`t`tUnicode: " (A_IsUnicode ? "Yes" : "No")
Log(logTxt)
Log("Main - " . frontendExe . " coordinates are x" . frontendX . " y" . frontendY . " w" . frontendW . " h" . frontendH)
CheckFile(A_ScriptDir . "\" . A_ScriptName)	; this is only to log the attributes of this file

If logLevel >= 4	; debug level or higher
{	; Checking CRC for these down here so they can be logged properly and shown as a GDI error
	itextsharpFile := moduleExtensionsPath . "\itextsharp.dll"
	CheckFile(itextsharpFile, "Following file is required for HyperLaunch, but could not be found:`n" . itextsharpFile)
	sevenZipSharpFile := moduleExtensionsPath . "\SevenZipSharp.dll"
	CheckFile(sevenZipSharpFile, "Following file is required for HyperLaunch, but could not be found:`n" . sevenZipSharpFile)
	gsdll32File := moduleExtensionsPath . "\gsdll32.dll"
	CheckFile(gsdll32File, "Following file is required for HyperLaunch, but could not be found:`n" . gsdll32File)
	gdipFile := moduleExtensionsPath . "\gdip.ahk"
	gdipFullName := CheckFile(gdipFile, "Cannot find " . gdipFile . "`nIf you see this error`, the auto-download function failed or the file is no longer hosted on autohotkey. Please obtain it by other means.",,"1528E024",0)
	rIniFile := moduleExtensionsPath . "\RIni.ahk"
	CheckFile(rIniFile, "Following file is required for HyperLaunch, but could not be found:`n" . rIniFile,,"AEF21343",0)
	clrFile := moduleExtensionsPath . "\CLR.ahk"
	CheckFile(clrFile, "Following file is required for HyperLaunch and 7z support with Fade, but could not be found:`n" . clrFile,,"D00E6AF6",0)
	comFile := moduleExtensionsPath . "\COM.ahk"
	CheckFile(comFile, "Following file is required for HyperPause and 7z support with Fade, but could not be found:`n" . comFile,,"D91157B5",0)
	jsonFile := moduleExtensionsPath . "\JSON.ahk"
	CheckFile(jsonFile, "Following file is required for Rom Mapping support, but could not be found:`n" . jsonFile,,"5BCB6AA8",0)
	fadeInitFile := libPath . "\Fade Init.ahk"
	CheckFile(fadeInitFile, "Following file is required for Fade support, but its file could not be found:`n" . fadeInitFile,,,0,1)
	hpInitFile := libPath . "\HyperPause Init.ahk"
	CheckFile(hpInitFile, "Following file is required for HyperPause support, but its file could not be found:`n" . hpInitFile,,,0,1)
	keyInitFile := libPath . "\Keymapper Init.ahk"
	CheckFile(keyInitFile, "Following file is required for Keymapper support, but its file could not be found:`n" . keyInitFile,,,0,1)
	mgInitFile := libPath . "\MultiGame Init.ahk"
	CheckFile(mgInitFile, "Following file is required for MultiGame support, but its file could not be found:`n" . mgInitFile,,,0,1)
	statInitFile := libPath . "\Statistics Init.ahk"
	CheckFile(statInitFile, "Following file is required for Statistics support, but its file could not be found:`n" . statInitFile,,,0,1)

	fadeFile := libPath . "\Fade.ahk"
	CheckFile(fadeFile, "Following file is required for Fade support, but its file could not be found:`n" . fadeFile,,,0,1)
	hpFile := libPath . "\HyperPause.ahk"
	CheckFile(hpFile, "Following file is required for HyperPause support, but its file could not be found:`n" . hpFile,,,0,1)
	keyFile := libPath . "\Keymapper.ahk"
	CheckFile(keyFile, "Following file is required for Keymapper support, but its file could not be found:`n" . keyFile,,,0,1)
	mgFile := libPath . "\MultiGame.ahk"
	CheckFile(mgFile, "Following file is required for MultiGame support, but its file could not be found:`n" . mgFile,,,0,1)
	bezelFile := libPath . "\Bezel.ahk"
	CheckFile(bezelFile, "Following file is required for Bezel support, but its file could not be found:`n" . bezelFile,,,0,1)
	statFile := libPath . "\Statistics.ahk"
	CheckFile(statFile, "Following file is required for Statistics support, but its file could not be found:`n" . statFile,,,0,1)
	rmFile := libPath . "\Rom Mapping Launch Menu.ahk"
	CheckFile(rmFile, "Following file is required for Rom Mapping & Launch Menu support, but its file could not be found:`n" . rmFile,,,0,1)

	sharedFile := libPath . "\Shared.ahk"
	CheckFile(sharedFile, "Following file is required for HyperLaunch, but its file could not be found:`n" . sharedFile,,,0,1)
	xHotkeyFile := libPath . "\XHotkey.ahk"
	CheckFile(xHotkeyFile, "Following file is required for HyperLaunch, but its file could not be found:`n" . xHotkeyFile,,,0,1)

	; Defining the path to the ini that will hold all ini settings required for authors in their custom animations
	fadeAnimFile := libPath . "\Fade Animations.ahk"
	CheckFile(fadeAnimFile, "Fade is enabled but could not find " . fadeAnimFile,,,0)
}


; ************************ TEMP TO SKIP GUI FOR TESTING
	; systemName = Super Nintendo Entertainment System
	; dbName = Super Metroid (Japan, USA)
	; Goto, Start
; ************************ TEMP TO SKIP GUI FOR TESTING



;-----------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------
; Gui
;-----------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------

If 0 < 2
{
	;Read system xml to optionally fill in the first combo
	Hotkey, ~Enter, Button1
	GetSystems()
	Gui, Add, Text, x12 y10 w430 h20 , Command Line: HyperLaunch.exe SystemName RomName
	Gui, Add, Text, x12 y40 w360 h30 , You can run a test below by entering the system name and rom name below then clicking the Test button.
	Gui, Add, Edit, x12 y150 w266 h20 vEdit2, %lastRom%
	Gui, Add, Text, x12 y80 w80 h20 , System Name:
	Gui, Add, Text, x12 y130 w140 h20 , Rom Name(no extension):
	Gui, Add, Button, x312 y100 w60 h70 gButton1, Test
	Gui, Add, Button, x262 y180 w110 h40 gButton2, Download Modules
	Gui, Add, Button, x279 y150 w24 h20 gButton3, .
	Gui, Add, Button, x279 y100 w24 h20 gButton4, .
	Gui, Add, CheckBox, x12 y180 w130 h20 vCheck1, Debug Module Script
	Gui, Add, CheckBox, x12 y200 w130 h20 Checked%hideCursorChecked% vChecked2 gCheck2, Hide Cursor
	Gui, Add, CheckBox, x142 y180 w110 h20 Checked%hideDesktopChecked% vChecked3 gCheck3, Hide Desktop
	Gui, Add, CheckBox, x142 y200 w110 h20 Checked%hideTaskbarChecked% vChecked4 gCheck4, Hide Taskbar
	Gui, Show, Center h233 w386, HyperLaunch %Version%

	Log("Main - HyperLaunch launched directly")
	Return
}Else{
	systemName = %1%
	dbName = %2%
	Goto, Start
	Return
}

Check2:
	Gui, Submit , NoHide
	IniWrite, % If Checked2 = 0 ? "false" : "true", %globalHLFile%, Desktop, Hide_Cursor	; write new setting to ini
	IniRead, hideCursor, %globalHLFile%, Desktop, Hide_Cursor, false	; update var in memory
Return

Check3:
	Gui, Submit , NoHide
	IniWrite, % If Checked3 = 0 ? "false" : "true", %globalHLFile%, Desktop, Hide_Desktop	; write new setting to ini
	IniRead, hideDesktop, %globalHLFile%, Desktop, Hide_Desktop, false 	; update var in memory
Return

Check4:
	Gui, Submit , NoHide
	IniWrite, % If Checked4 = 0 ? "false" : "true", %globalHLFile%, Desktop, Hide_Taskbar	; write new setting to ini
	IniRead, hideTaskbar, %globalHLFile%, Desktop, Hide_Taskbar, false	; update var in memory
Return

Button3:
	;File browser
	;Try and get the users rompath to start in
	Gui, Submit, NoHide
	IniRead, startDir, %A_ScriptDir%\Settings\%Edit1%\Emulators.ini, Roms, Rom_Path, %frontendPath%
	startDir := GetFullName(startDir)
	StringRight, lastChar, startDir, 1
	If (lastChar = "\"){
		StringTrimRight, startDir, startDir, 1 
	}
	FileSelectFile, SelectedFile, 3, %startDir%, Select a rom,
	If SelectedFile =
		Return
	Else
		RegExMatch(SelectedFile,  "\\([^\\]*)\.\w{2,3}$", SubPat) 
	GuiControl,, Edit2, %SubPat1%
Return

Button4:			; ******************** in order for any of this to work, the gui code has to be moved below all ini reads ***************************
	;Opens new gui to configure an emu
	Gui, Submit , NoHide
	TrayTip,, Toasty
Return	; disabling button 3 because it no longer works
	Gui, 3:+owner1
	Gui +Disabled
	configFile := CheckFile(frontendPath . "\Settings\" . Edit1 . "\Emulators.ini")
	IniRead, configExePath, %configFile%, Roms, Emu_Path
	StringRight, lastChar, configExePath, 1
	If (lastChar = "\"){
		configExePath -= "\"
	}

	IniRead, configExe, %configFile%, Roms, Exe
	IniRead, configRomPath, %configFile%, Roms, Rom_Path
	IniRead, configRomExtension, %configFile%, Roms, Rom_Extension
	IniRead, configCPWizardEnabled, %configFile%, CPWizard, CPWizard_Enabled, use_global

	finalPath = %configExePath%\%configExe%
	If (finalPath = 0){
		finalPath := ""
	}

	Gui, 3:Add, Text, x12 y10 w210 h20 , Emulator:
	Gui, 3:Add, Text, x12 y60 w210 h20 , Rom Path:
	Gui, 3:Add, Text, x12 y110 w210 h20 , Rom Extension:
	Gui, 3:Add, Edit, x12 y30 w330 h20 v3Edit1 g3Edit1, %finalPath%
	Gui, 3:Add, Edit, x12 y80 w330 h20 v3Edit2 g3Edit2, %configRomPath%
	Gui, 3:Add, Edit, x12 y130 w330 h20 v3Edit3 g3Edit3, %configRomExtension% 
	Gui, 3:Add, Button, x342 y30 w20 h20 g3Button1, .
	Gui, 3:Add, Button, x342 y80 w20 h20 g3Button2, .

	If (configCPWizardEnabled = "true"){
		configCPWizardEnabledChecked = 1
	}Else{
		configCPWizardEnabledChecked = 0
	}  

	Gui, 3:Add, CheckBox, x142 y160 w100 h20 Checked%configCPWizardEnabledChecked% v3Checked2 g3Check2, Enable CPWizard
	Gui, 3:Show, x550 y301 h211 w372, Quick Config
Return

3GuiClose:
	Gui, 1:-Disabled
	Gui, 3:Destroy
Return

3Edit1:
	Gui, 3:Submit, NoHide
	RegExMatch(3Edit1,  "(.*\\)([^\\]*\.\w{2,3})$", SubPat)
	IniWrite, %SubPat1%, %configFile%, Exe Info, Emu_Path
	IniWrite, %SubPat2%, %configFile%, Exe Info, Exe
Return

3Edit2:
	Gui, 3:Submit, NoHide
	IniWrite, %3Edit2%, %configFile%, Roms, Rom_Path
Return

3Edit3:
	Gui, 3:Submit , NoHide
	IniWrite, %3Edit3%, %configFile%, Exe Info, Rom_Extension
Return

3Check1: ; removed, no longer need this key
	; Gui, 3:Submit , NoHide
	; If (3Checked1 = 0){
		; IniWrite, false, %configFile%, Settings, Per_Game_Modules
	; }Else{
		; IniWrite, true, %configFile%, Settings, Per_Game_Modules
	; }
Return

3Check2:
	Gui, 3:Submit , NoHide
	IniWrite, % If 3Checked2 = 0 ? "false" : "true", %configFile%, CPWizard, CPWizard_Enabled	; write new setting to ini
Return

Button2:
	Run, http://hyperlist.hyperspin-fe.com/?module=browseahk
Return

Button1:
	IfWinActive, HyperLaunch
	{
		Gui, Submit , NoHide
		Hotkey, ~Enter, Off
		systemName = %Edit1%																													  
		dbName = %Edit2%
		debugModule = %Check1%
		Goto, Start
	}
Return

3Button1:
	Gui, 3:Submit, NoHide
	FileSelectFile, SelectedFile, 3, %3Edit1%, Select Executable,
	If SelectedFile =
		Return
	Else
		RegExMatch(SelectedFile,  "(.*\\)([^\\]*\.\w{3,3})$", SubPat)
	IniWrite, %SubPat1%, %configFile%, Exe Info, Emu_Path
	IniWrite, %SubPat2%, %configFile%, Exe Info, Exe
	GuiControl,, 3Edit1, %SubPat1%%SubPat2%
Return

3Button2:
	Gui, 3:Submit, NoHide
	StringRight, lastChar, 3Edit2, 1
	If (lastChar = "\"){
		StringTrimRight, startDir, 3Edit2, 1
	}
	FileSelectFolder, selectedFolder, *%startDir%, Select RomPath,
	If selectedFolder =
		Return
	Else
		StringRight, lastChar, selectedFolder, 1
	If (lastChar != "\"){
		selectedFolder = %selectedFolder%\
	}

	IniWrite, %selectedFolder%, %configFile%, Roms, Rom_Path
	GuiControl,, 3Edit2, %selectedFolder%
Return

2ButtonOK:
	Gui, 1:-Disabled
	Gui, 2:Destroy
	Pause
Return

Start:
	Gui Destroy
	If !systemName
		ScriptError("No systemName was supplied to HyperLaunch.exe. You are not using HyperLaunch correctly. Proper usage is ""HyperLaunch.exe SYSTEMNAME ROMNAME"".")
	If !dbName
		ScriptError("No romName/dbName was supplied to HyperLaunch.exe. You are not using HyperLaunch correctly. Proper usage is ""HyperLaunch.exe SYSTEMNAME ROMNAME"".")
	RIni_SetKeyValue(5,"Settings","Last_System",systemName)	; write the system name we just loaded to the ini in memory
	RIni_SetKeyValue(5,"Settings","Last_Rom",dbName)	; write the db name we just loaded to the ini in memory
	; IniWrite, %systemName%, %HLFile%, Settings, Last_System
	; IniWrite, %dbName%, %HLFile%, Settings, Last_Rom

Log("Main - HyperLaunch received """ . systemName . """ and """ . dbName . """")

;-----------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------
; Get Ini Settings
;-----------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------
; In HS2, if using PCLauncher, your systemName will be PCLauncher, instead of your wheel's name
If (systemName = "Main Menu") ; Main Menu systemName is only in HS1. HS2 sends PCLauncher if launching an exe from the main menu. Delete the first half of this check when HS2 is out
	iniName = %dbName%
Else ;If (systemName != "PCLauncher") ; Probably don't want this "If" check anymore because PCLauncher needs an ini so it can check for fade functionality
	iniName = %systemName%

;-----------------------------------------------------------------------------------------------------------------------------------------
 ; Settings from systemName \ Games.ini
;-----------------------------------------------------------------------------------------------------------------------------------------
gamesFile := A_ScriptDir . "\Settings\" . iniName . "\Games.ini"	; For custom game list support, we have to first read if our game should be found on another systemName's settings
IfNotExist, %gamesFile%
	CreateDefaultIni(gamesFile,"sysGames")
RIni_Read(6,gamesFile)
rIniIndex[6] := gamesFile	; assign to array

customGameEmu := RIniLoadVar(6,"", dbName, "Emulator")	; lookup dbName to see if user defined a custom emu for it in systemName\Games.ini
customGameSystem := RIniLoadVar(6,"", dbName, "System")	; checking to see if this game's emu should be found on another systemName for custom game lists
If (customGameSystem != -2 && customGameSystem != -3 && customGameSystem != "" )
{	iniName := customGameSystem	; delete this when HS2 is out as everything will use systemName instead of iniName
	systemName := customGameSystem
	Log("Main - " . dbName . " contains a System key in " . gamesFile . ". Switching systemName to " . systemName)
}
; We now know what system the game is part of. Still have to determine what emulator in case that key was not set

;-----------------------------------------------------------------------------------------------------------------------------------------
 ; Settings from Settings \ systemName \ Emulators.ini or Global Emulators.ini
;-----------------------------------------------------------------------------------------------------------------------------------------
sysEmuFile := A_ScriptDir . "\Settings\" . iniName . "\Emulators.ini"
IfNotExist, %sysEmuFile%
	CreateDefaultIni(sysEmuFile,"sysEmu")
RIni_Read(4,sysEmuFile)
rIniIndex[4] := sysEmuFile	; assign to array

sysHLFile := A_ScriptDir . "\Settings\" . iniName . "\HyperLaunch.ini"
IfNotExist, %sysHLFile%
	CreateDefaultIni(sysHLFile,"sysHL")
RIni_Read(2,sysHLFile)
rIniIndex[2] := sysHLFile	; assign to array

defaultEmu := RIniReadCheck(4, "Roms", "Default_Emulator",, "No Default_Emulator found in """ . sysEmuFile . """ Please set one so HyperLaunch knows what module to use.")

If (customGameEmu != -2 && customGameEmu != -3 && customGameEmu != "" )	; if an emulator was not set on games.ini, assign the default emu to emuName, otherwise the emulator key is the emu we will look for
{	emuName := customGameEmu
	Log("Main - " . dbName . " is switching to emulator " . customGameEmu . " via: " . gamesFile)
}Else{
	emuName := defaultEmu
	Log("Main - " . dbName . " is using the default emulator: " . emuName)
}

; we now know what  emulator our game needs. Next we need to determine if the emulator's settings are on our system emu ini, or the global emu ini

emuFiles := [sysEmuFile,globalEmuFile]
For index, value in emuFiles {
	If  !emuFile {	; if emuFile is not set yet
		tempIndex:=A_Index	; need this index # in the next loop for accurate logging
		If A_Index = 1
			Log("Main - Checking for a [" . emuName . "] section in " . sysEmuFile)
		Else If A_Index = 2
			Log("Main - Checking for a [" . emuName . "] section in " . globalEmuFile)
		Loop, Read, %value%	; parsing Emulators.ini and Global Emulatoris.ini to see if the emulator we want has a section name defined
		{	trimmedLine = %A_LoopReadLine%	; trims white space from the line which can cause the next conditional to fail
			If trimmedLine = [%emuName%]
			{	If tempIndex = 1
					Log("Main - Found [" . emuName . "] in " . sysEmuFile)
				Else If tempIndex = 2
					Log("Main - Found [" . emuName . "] in " . globalEmuFile)
				emuFile := value	; setting emuFile to the ini an emuName section was found in
				Break
			}
		}
	}
}
If  !emuFile
	ScriptError("Could not locate a section called [" . emuName . "] in your Global Emulators.ini or " . systemName . "\Emulators.ini")	; emulator section was not found, close script

;-----------------------------------------------------------------------------------------------------------------------------------------
 ; Calculate what Module we need to look for that matches the emuName or user setting
;-----------------------------------------------------------------------------------------------------------------------------------------
emuFileRIni := If emuFile = globalEmuFile ? 3 : 4	; get the rIniIndex value for the emuFile
moduleName := RIniReadCheck(emuFileRIni, emuName, "Module")

If (moduleName = -2 or moduleName = -3 or moduleName = "" )
	moduleName := emuName . ".ahk"	; setting this here instead of in RIniReadCheck because the function will write the default value to the ini, which we don't want
perGameModule := modulesPath . "\Game Modules\" . dbName . "\" . dbName . ".ahk"	; If a module for this game is found, it will use that module instead of the one for the emulator
IfExist, %perGameModule%
	moduleFullName := perGameModule
Else
	moduleFullName := If (SubStr(moduleName,2,1)!="\" && SubStr(moduleName,2,1)!=":")?(modulesPath . "\" . emuName . "\" . moduleName):(moduleName)	; if moduleName starts with .\ then we assume the user if looking for modules located in .\Modules, otherwise a full path need to be defined to find the module.

moduleFullName := GetFullName(moduleFullName)	; converts relative path to absolute
SplitPath,moduleFullName,,modulePath,moduleExtension,moduleName	; storing the path, ext, and name (w/o ext) as final vars, of the module, for use in modules
If moduleExtension != ahk
	ScriptError("You did not supply a valid module filename. Please make sure to include the module name and extension (.ahk):`n" . moduleFullName)
RIni_SetKeyValue(5,"Settings","Last_Module",moduleName)	; write the module name we just loaded to the ini in memory

;Check if the module exists
CheckFile(moduleFullName, "Cannot find: " . moduleFullName . "`nYou do not have a HyperLaunch module for " . emuName . ". Please create one or check HyperList.")
mCRCResult := COM_Invoke(HLObject, "checkModuleCRC", "" . moduleFullName . "","",1)
If mCRCResult = -1
	Log("Main - CRC Check - Module file not found",3)
Else If mCRCResult = 0
	Log("Main - CRC Check - CRC does not match official module and will not be supported. Continue using at your own risk.",2)
Else If mCRCResult = 1
	Log("Main - CRC Check - CRC matches, this is an official unedited module.",1)
Else If mCRCResult = 2
	Log("Main - CRC Check - Module has no CRC defined on the header.",2)

Log("Main - " . dbName . " will use module: " . moduleFullName)

;-----------------------------------------------------------------------------------------------------------------------------------------
 ; General Settings from Settings \ HyperLaunch.ini
;-----------------------------------------------------------------------------------------------------------------------------------------
profilePath := RIniReadCheck(5, "Settings", "Profiles_Path", ".\Profiles")
profilePath := GetFullName(profilePath)	; converts relative path to absolute
exitScriptKey := RIniReadCheck(5, "Settings", "Exit_Script_Key", "~q & ~s")
exitEmulatorKey := RIniReadCheck(5, "Settings", "Exit_Emulator_Key", "~Esc")
toggleCursorKey := RIniReadCheck(5, "Settings", "Toggle_Cursor_Key", "~e & ~t")
emuIdleShutdown := RIniReadCheck(5, "Settings", "Emu_Idle_Shutdown", 0)

navUpKey := RIniReadCheck(5, "Navigation", "Navigation_Up_Key", "Up")
navDownKey := RIniReadCheck(5, "Navigation", "Navigation_Down_Key", "Down")
navLeftKey := RIniReadCheck(5, "Navigation", "Navigation_Left_Key", "Left")
navRightKey := RIniReadCheck(5, "Navigation", "Navigation_Right_Key", "Right")
navSelectKey := RIniReadCheck(5, "Navigation", "Navigation_Select_Key", "Enter")
navP2UpKey := RIniReadCheck(5, "Navigation", "Navigation_P2_Up_Key", "Numpad8")
navP2DownKey := RIniReadCheck(5, "Navigation", "Navigation_P2_Down_Key", "Numpad2")
navP2LeftKey := RIniReadCheck(5, "Navigation", "Navigation_P2_Left_Key", "Numpad4")
navP2RightKey := RIniReadCheck(5, "Navigation", "Navigation_P2_Right_Key", "Numpad6")
navP2SelectKey := RIniReadCheck(5, "Navigation", "Navigation_P2_Select_Key", "NumpadEnter")

7zPath := RIniReadCheck(5, "7z", "7z_Path", moduleExtensionsPath . "\7z.exe")
7zPath := GetFullName(7zPath)	; converts relative path to absolute

fadeInterruptKey := RIniReadCheck(5, "Fade", "Fade_Interrupt_Key")
detectFadeErrorEnabled := RIniReadCheck(5, "Fade", "Fade_Detect_Error", "true")	; disabled feature for now

mgKey := RIniReadCheck(5, "MultiGame", "MultiGame_Key", "~NumpadSub")

hpKey := RIniReadCheck(5, "HyperPause", "HyperPause_Key", "~NumpadAdd")
hpBackToMenuBarKey := RIniReadCheck(5, "HyperPause", "HyperPause_Back_to_Menu_Bar_Key", "X")
hpZoomInKey := RIniReadCheck(5, "HyperPause", "HyperPause_Zoom_In_Key", "C")
hpZoomOutKey := RIniReadCheck(5, "HyperPause", "HyperPause_Zoom_Out_Key", "V")
hpScreenshotKey := RIniReadCheck(5, "HyperPause", "HyperPause_Screenshot_Key", "~PrintScreen")
hpHiToTextPath := RIniReadCheck(5, "HyperPause", "HyperPause_HiToText_Path", ".\Module Extensions\HiToText.exe") 
hpHiToTextPath := GetFullName(hpHiToTextPath )	; converts relative path to absolute

dtPath := RIniReadCheck(5, "DAEMON Tools", "DAEMON_Tools_Path")
dtPath := GetFullName(dtPath)	; converts relative path to absolute
dtAddDrive := RIniReadCheck(5, "DAEMON Tools", "DAEMON_Tools_Add_Drive", "true")

cpWizardPath := RIniReadCheck(5, "CPWizard", "CPWizard_Path")
cpWizardPath := GetFullName(cpWizardPath)	; converts relative path to absolute

xpadderFullPath := RIniReadCheck(5, "Keymapper", "Xpadder_Path", "..\Utilities\Xpadder\xpadder.exe")
xpadderFullPath := GetFullName(xpadderFullPath)	; converts relative path to absolute bunny
joyToKeyFullPath := RIniReadCheck(5, "Keymapper", "JoyToKey_Path", "..\Utilities\JoyToKey\JoyToKey.exe")
joyToKeyFullPath := GetFullName(joyToKeyFullPath)	; converts relative path to absolute bunny
CustomJoyNamesEnabled := RIniReadCheck(5, "Keymapper", "Custom_Joy_Names_Enabled", "false")
CustomJoyNames := RIniReadCheck(5, "Keymapper", "Custom_Joy_Names")
keymapperFrontEndProfileName := RIniReadCheck(5, "Keymapper", "Keymapper_FrontEnd_Profile_Name", "HyperSpin")
keymapperHyperLaunchProfileEnabled := RIniReadCheck(5, "Keymapper", "Keymapper_HyperLaunch_Profile_Enabled", "false")

vJoyPath := RIniReadCheck(5, "VJoy", "VJoy_Path", "..\Utilities\VJoy\VJoy.exe")
vJoyPath := GetFullName(vJoyPath)	; converts relative path to absolute

betaBriteEnabled := RIniReadCheck(5, "BetaBrite", "BetaBrite_Enable", "false")
betaBritePath := RIniReadCheck(5, "BetaBrite", "BetaBrite_Path")
betaBritePath := GetFullName(betaBritePath)	; converts relative path to absolute
betaBriteParams := RIniReadCheck(5, "BetaBrite", "BetaBrite_Params","usb {AUTO}HYPERSPIN")

;-----------------------------------------------------------------------------------------------------------------------------------------
 ; Global and System Settings from "Settings\Global HyperLaunch.ini" and "Settings\%systemName%\HyperLaunch.ini"
;-----------------------------------------------------------------------------------------------------------------------------------------

skipChecks := RIniLoadVar(2,"", "Settings", "Skipchecks", "false")
romMatchExt := RIniLoadVar(1,2, "Settings", "Rom_Match_Extension", "false")

hideCursor := RIniLoadVar(1,2, "Desktop", "Hide_Cursor", "false")
hideDesktop := RIniLoadVar(1,2, "Desktop", "Hide_Desktop", "false")
hideTaskbar := RIniLoadVar(1,2, "Desktop", "Hide_Taskbar", "false")
hideEmu := RIniLoadVar(1,2, "Desktop", "Hide_Emu", "false")
hideFE := RIniLoadVar(1,2, "Desktop", "Hide_Front_End", "false")

exitEmulatorKeyWait := RIniLoadVar(1,2, "Exit", "Exit_Emulator_Key_Wait", 0)
exitEmulatorKeyWait := exitEmulatorKeyWait // 1000	; need to be converted to seconds for XHotkey
forceHoldKey := RIniLoadVar(1,2, "Exit", "Force_Hold_Key", "~Esc")
restoreFE := RIniLoadVar(1,2, "Exit", "Restore_Front_End_On_Exit", "false")

dtEnabled := RIniLoadVar(1,2, "DAEMON Tools", "DAEMON_Tools_Enabled", "true")
dtUseSCSI := RIniLoadVar(1,2, "DAEMON Tools", "DAEMON_Tools_Use_SCSI", "true")

cpWizardEnabled := RIniLoadVar(1,2, "CPWizard", "CPWizard_Enabled", "false")
cpWizardDelay := RIniLoadVar(1,2, "CPWizard", "CPWizard_Delay", 8000)
cpWizardParams := RIniLoadVar(1,2, "CPWizard", "CPWizard_Params", "-minimized -timeout 9000")
cpWizardExit := RIniLoadVar(1,2, "CPWizard", "CPWizard_Close_On_Exit", "false")

fadeIn := RIniLoadVar(1,2, "Fade", "Fade_In", "false")
fadeInDuration := RIniLoadVar(1,2, "Fade", "Fade_In_Duration", 500)
fadeInTransitionAnimation := RIniLoadVar(1,2, "Fade", "Fade_In_Transition_Animation", "DefaultAnimateFadeIn")
fadeInDelay := RIniLoadVar(1,2, "Fade", "Fade_In_Delay", 0)
fadeInExitDelay := RIniLoadVar(1,2, "Fade", "Fade_In_Exit_Delay", 0)

fadeOut := RIniLoadVar(1,2, "Fade", "Fade_Out", "false")
fadeOutExtraScreen := RIniLoadVar(1,2, "Fade", "Fade_Out_Extra_Screen", "false")
fadeOutDuration := RIniLoadVar(1,2, "Fade", "Fade_Out_Duration", 500)
fadeOutTransitionAnimation := RIniLoadVar(1,2, "Fade", "Fade_Out_Transition_Animation", "DefaultAnimateFadeOut")
fadeOutDelay := RIniLoadVar(1,2, "Fade", "Fade_Out_Delay", 0)
fadeOutExitDelay := RIniLoadVar(1,2, "Fade", "Fade_Out_Exit_Delay", 0)

fadeLyrInterpolation := RIniLoadVar(1,2, "Fade", "Fade_Layer_Interpolation", 7)

fadeLyr1Color := RIniLoadVar(1,2, "Fade", "Fade_Layer_1_Color", "FF000000")
fadeLyr1AlignImage := RIniLoadVar(1,2, "Fade", "Fade_Layer_1_Align_Image", "Align to Top Left")

fadeLyr2Pos := RIniLoadVar(1,2, "Fade", "Fade_Layer_2_Alignment", "Bottom Right Corner")
fadeLyr2X := RIniLoadVar(1,2, "Fade", "Fade_Layer_2_X", 300)
fadeLyr2Y := RIniLoadVar(1,2, "Fade", "Fade_Layer_2_Y", 300)
fadeLyr2Adjust := RIniLoadVar(1,2, "Fade", "Fade_Layer_2_Adjust", 1)
fadeLyr2PicPad := RIniLoadVar(1,2, "Fade", "Fade_Layer_2_Padding", 0)

fadeLyr3Pos := RIniLoadVar(1,2, "Fade", "Fade_Layer_3_Alignment", "Center")
fadeLyr3X := RIniLoadVar(1,2, "Fade", "Fade_Layer_3_X", 300)
fadeLyr3Y := RIniLoadVar(1,2, "Fade", "Fade_Layer_3_Y", 300)
fadeLyr3Adjust := RIniLoadVar(1,2, "Fade", "Fade_Layer_3_Adjust", 0.75)
fadeLyr3PicPad := RIniLoadVar(1,2, "Fade", "Fade_Layer_3_Padding", 0)
fadeLyr3Speed := RIniLoadVar(1,2, "Fade", "Fade_Layer_3_Speed", 750)
fadeLyr3Animation := RIniLoadVar(1,2, "Fade", "Fade_Layer_3_Animation", "DefaultFadeAnimation")
fadeLyr37zAnimation := RIniLoadVar(1,2, "Fade", "Fade_Layer_3_7z_Animation", "DefaultFadeAnimation")
fadeLyr3ImgFollow7zProgress := RIniLoadVar(1,2, "Fade", "Fade_Layer_3_Image_Follow_7z_Progress", "true")
fadeLyr3Type := RIniLoadVar(1,2, "Fade", "Fade_Layer_3_Type", "imageandbar")
fadeLyr3Repeat := RIniLoadVar(1,2, "Fade", "Fade_Layer_3_Repeat", 1)
fadeLyr4Pos := RIniLoadVar(1,2, "Fade", "Fade_Layer_4_Pos", "Above Layer 3 - Left")
fadeLyr4X := RIniLoadVar(1,2, "Fade", "Fade_Layer_4_X", 100)
fadeLyr4Y := RIniLoadVar(1,2, "Fade", "Fade_Layer_4_Y", 100)
fadeLyr4Adjust := RIniLoadVar(1,2, "Fade", "Fade_Layer_4_Adjust", 0.75)
fadeLyr4PicPad := RIniLoadVar(1,2, "Fade", "Fade_Layer_4_Padding", 0)
fadeLyr4FPS := RIniLoadVar(1,2, "Fade", "Fade_Layer_4_FPS", 10)
fadeTranspGifColor := RIniLoadVar(1,2, "Fade", "Fade_Animated_Gif_Transparent_Color", "FFFFFF")

fadeBarWindow := RIniLoadVar(1,2, "Fade", "Fade_Bar_Window", "false")
fadeBarWindowX := RIniLoadVar(1,2, "Fade", "Fade_Bar_Window_X", "")
fadeBarWindowY := RIniLoadVar(1,2, "Fade", "Fade_Bar_Window_Y", "")
fadeBarWindowW := RIniLoadVar(1,2, "Fade", "Fade_Bar_Window_Width", 600)
fadeBarWindowH := RIniLoadVar(1,2, "Fade", "Fade_Bar_Window_Height", 120)
fadeBarWindowR := RIniLoadVar(1,2, "Fade", "Fade_Bar_Window_Radius", 20)
fadeBarWindowM := RIniLoadVar(1,2, "Fade", "Fade_Bar_Window_Margin", 20)
fadeBarWindowHatchStyle := RIniLoadVar(1,2, "Fade", "Fade_Bar_Window_Hatch_Style", 8)
fadeBarBack := RIniLoadVar(1,2, "Fade", "Fade_Bar_Back", "true")
fadeBarBackColor := RIniLoadVar(1,2, "Fade", "Fade_Bar_Back_Color", "FF555555")
fadeBarH := RIniLoadVar(1,2, "Fade", "Fade_Bar_Height", 20)
fadeBarR := RIniLoadVar(1,2, "Fade", "Fade_Bar_Radius", 5)
fadeBarColor := RIniLoadVar(1,2, "Fade", "Fade_Bar_Color", "DD00BFFF")
fadeBarHatchStyle := RIniLoadVar(1,2, "Fade", "Fade_Bar_Hatch_Style", 3)
fadeBarPercentageText := RIniLoadVar(1,2, "Fade", "Fade_Bar_Percentage_Text", "true")
fadeBarInfoText := RIniLoadVar(1,2, "Fade", "Fade_Bar_Info_Text", "true")
fadeBarXOffset := RIniLoadVar(1,2, "Fade", "Fade_Bar_X_Offset", 0)
fadeBarYOffset := RIniLoadVar(1,2, "Fade", "Fade_Bar_Y_Offset", 100)

fadeRomInfoDescription := RIniLoadVar(1,2, "Fade", "Fade_Rom_Info_Description", "text")
fadeRomInfoSystemName := RIniLoadVar(1,2, "Fade", "Fade_Rom_Info_System_Name", "text")
fadeRomInfoYear := RIniLoadVar(1,2, "Fade", "Fade_Rom_Info_Year", "text")
fadeRomInfoManufacturer := RIniLoadVar(1,2, "Fade", "Fade_Rom_Info_Manufacturer", "text")
fadeRomInfoGenre := RIniLoadVar(1,2, "Fade", "Fade_Rom_Info_Genre", "text")
fadeRomInfoRating := RIniLoadVar(1,2, "Fade", "Fade_Rom_Info_Rating", "text")
fadeRomInfoOrder := RIniLoadVar(1,2, "Fade", "Fade_Rom_Info_Order", "Description|SystemName|Year|Manufacturer|Genre|Rating")
fadeRomInfoTextPlacement := RIniLoadVar(1,2, "Fade", "Fade_Rom_Info_Text_Placement", "topRight")
fadeRomInfoTextMargin := RIniLoadVar(1,2, "Fade", "Fade_Rom_Info_Text_Margin", 5)
fadeRomInfoText1Options := RIniLoadVar(1,2, "Fade", "Fade_Rom_Info_Text_1_Options", "cFF555555 r4 s20 Bold")
fadeRomInfoText2Options := RIniLoadVar(1,2, "Fade", "Fade_Rom_Info_Text_2_Options", "cFF555555 r4 s20 Bold")
fadeRomInfoText3Options := RIniLoadVar(1,2, "Fade", "Fade_Rom_Info_Text_3_Options", "cFF555555 r4 s20 Bold")
fadeRomInfoText4Options := RIniLoadVar(1,2, "Fade", "Fade_Rom_Info_Text_4_Options", "cFF555555 r4 s20 Bold")
fadeRomInfoText5Options := RIniLoadVar(1,2, "Fade", "Fade_Rom_Info_Text_5_Options", "cFF555555 r4 s20 Bold")
fadeRomInfoText6Options := RIniLoadVar(1,2, "Fade", "Fade_Rom_Info_Text_6_Options", "cFF555555 r4 s20 Bold")

fadeStats_Number_of_Times_Played := RIniLoadVar(1,2, "Fade", "Fade_Stats_Number_of_Times_Played", "text with label")
fadeStats_Last_Time_Played := RIniLoadVar(1,2, "Fade", "Fade_Stats_Last_Time_Played", "text with label")
fadeStats_Average_Time_Played := RIniLoadVar(1,2, "Fade", "Fade_Stats_Average_Time_Played", "text with label")
fadeStats_Total_Time_Played := RIniLoadVar(1,2, "Fade", "Fade_Stats_Total_Time_Played", "text with label")
fadeStats_System_Total_Played_Time := RIniLoadVar(1,2, "Fade", "Fade_Stats_System_Total_Played_Time", "text with label")
fadeStats_Total_Global_Played_Time := RIniLoadVar(1,2, "Fade", "Fade_Stats_Total_Global_Played_Time", "text with label")
fadeStatsInfoOrder := RIniLoadVar(1,2, "Fade", "Fade_Stats_Info_Order", "Number_of_Times_Played|Last_Time_Played|Average_Time_Played|Total_Time_Played|System_Total_Played_Time|Total_Global_Played_Time")
fadeStatsInfoTextPlacement := RIniLoadVar(1,2, "Fade", "Fade_Stats_Info_Text_Placement", "topLeft")
fadeStatsInfoTextMargin := RIniLoadVar(1,2, "Fade", "Fade_Stats_Info_Text_Margin", 5)
fadeStatsInfoText1Options := RIniLoadVar(1,2, "Fade", "Fade_Stats_Info_Text_1_Options", "cFF555555 r4 s20 Bold")
fadeStatsInfoText2Options := RIniLoadVar(1,2, "Fade", "Fade_Stats_Info_Text_2_Options", "cFF555555 r4 s20 Bold")
fadeStatsInfoText3Options := RIniLoadVar(1,2, "Fade", "Fade_Stats_Info_Text_3_Options", "cFF555555 r4 s20 Bold")
fadeStatsInfoText4Options := RIniLoadVar(1,2, "Fade", "Fade_Stats_Info_Text_4_Options", "cFF555555 r4 s20 Bold")
fadeStatsInfoText5Options := RIniLoadVar(1,2, "Fade", "Fade_Stats_Info_Text_5_Options", "cFF555555 r4 s20 Bold")
fadeStatsInfoText6Options := RIniLoadVar(1,2, "Fade", "Fade_Stats_Info_Text_6_Options", "cFF555555 r4 s20 Bold")

fadeText1X := RIniLoadVar(1,2, "Fade", "Fade_Text_1_X", 0)
fadeText1Y := RIniLoadVar(1,2, "Fade", "Fade_Text_1_Y", 0)
fadeText1Options := RIniLoadVar(1,2, "Fade", "Fade_Text_1_Options", "cFFFFFFFF r4 s20 Right Bold")
fadeText1 := RIniLoadVar(1,2, "Fade", "Fade_Text_1", "Loading Game")
fadeText2X := RIniLoadVar(1,2, "Fade", "Fade_Text_2_X", 0)
fadeText2Y := RIniLoadVar(1,2, "Fade", "Fade_Text_2_Y", 0)
fadeText2Options := RIniLoadVar(1,2, "Fade", "Fade_Text_2_Options", "cFFFFFFFF r4 s20 Right Bold")
fadeText2 := RIniLoadVar(1,2, "Fade", "Fade_Text_2", "Extraction Complete")

fadeFont := RIniLoadVar(1,2, "Fade", "Fade_Font", "Arial")
fadeSystemAndRomLayersOnly := RIniLoadVar(1,2,"Fade","Fade_System_And_Rom_Layers_Only","false")

7zEnabled := RIniLoadVar(1,2, "7z", "7z_Enabled", "false")
7zExtractPathFromIni := RIniLoadVar(1,2, "7z", "7z_Extract_Path", A_Temp . "\HS")
7zExtractPathFromIni := GetFullName(7zExtractPathFromIni)	; converts relative path to absolute
7zExtractPath := 7zExtractPathFromIni
7zAttachSystemName := RIniLoadVar(1,2, "7z", "7z_Attach_System_Name", "false")
7zDelTemp := RIniLoadVar(1,2, "7z", "7z_Delete_Temp", "true")
7zSounds := RIniLoadVar(1,2, "7z", "7z_Sounds", "true")

keymapperEnabled := RIniLoadVar(1,2, "Keymapper", "Keymapper_Enabled", "false")
keymapperAHKMethod := RIniLoadVar(1,2, "Keymapper", "Keymapper_AHK_Method", "false")
keymapper := RIniLoadVar(1,2, "Keymapper", "Keymapper", "xpadder")
JoyIDsEnabled := RIniLoadVar(1,2, "Keymapper", "JoyIDs_Enabled", "false")
JoyIDsPreferredControllersGlobal := RIniLoadVar(2,"", "Keymapper", "JoyIDs_Preferred_Controllers")
JoyIDsPreferredControllersSystem := RIniLoadVar(1,"", "Keymapper", "JoyIDs_Preferred_Controllers","use_global",,1)	; need to send both system and global keys to Keymapper Init.ahk, preferDefault flag used

vJoyEnabled := RIniLoadVar(1,2, "VJoy", "VJoy_Enabled", "false")

mgEnabled := RIniLoadVar(1,2, "MultiGame", "MultiGame_Enabled", "false")
mgBackgroundColor := RIniLoadVar(1,2, "MultiGame", "MultiGame_Background_Color", "FF000000")
mgSidePadding := RIniLoadVar(1,2, "MultiGame", "MultiGame_Side_Padding", "0.2")
mgYOffset := RIniLoadVar(1,2, "MultiGame", "MultiGame_Y_Offset", 500)
mgImageAdjust := RIniLoadVar(1,2, "MultiGame", "MultiGame_Image_Adjust", 1)
mgFont := RIniLoadVar(1,2, "MultiGame", "MultiGame_Font", "Arial")
mgText1Options := RIniLoadVar(1,2, "MultiGame", "MultiGame_Text_1_Options", "x10p y30p w80p Center cBBFFFFFF r4 s100 BoldItalic")
mgText1Text := RIniLoadVar(1,2, "MultiGame", "MultiGame_Text_1_Text", "Please select a game")
mgText2Options := RIniLoadVar(1,2, "MultiGame", "MultiGame_Text_2_Options", "w96p cFFFFFFFF r4 s50 Center BoldItalic")
mgText2Offset := RIniLoadVar(1,2, "MultiGame", "MultiGame_Text_2_Offset", 70)
mgUseSound := RIniLoadVar(1,2, "MultiGame", "MultiGame_Use_Sound", "true")
mgSoundfreq := RIniLoadVar(1,2, "MultiGame", "MultiGame_Sound_Frequency", 300)
mgExitEffect := RIniLoadVar(1,2, "MultiGame", "MultiGame_Exit_Effect", "none")
mgSelectedEffect := RIniLoadVar(1,2, "MultiGame", "MultiGame_Selected_Effect", "rotate")
mgUseGameArt := RIniLoadVar(1,2, "MultiGame", "MultiGame_Use_Game_Art", "false")
mgArtworkDir := RIniLoadVar(1,2, "MultiGame", "MultiGame_Art_Folder", "Artwork1")

hpEnabled := RIniLoadVar(1,2, "HyperPause", "HyperPause_Enabled", "false")

bezelEnabled := RIniLoadVar(1,2, "Bezel", "Bezel_Enabled", "false")

statisticsEnabled := RIniLoadVar(1,2, "Statistics", "Statistics_Enabled", "true")

romMappingEnabled := RIniLoadVar(1,2, "Rom Mapping", "Rom_Mapping_Enabled", "false")
romMappingLaunchMenuEnabled := RIniLoadVar(1,2, "Rom Mapping", "Rom_Mapping_Launch_Menu_Enabled", "false")
romMappingDefaultMenuList := RIniLoadVar(1,2, "Rom Mapping", "Default_Menu_List", "FullList")
romMappingSingleFilteredRomAutomaticLaunch := RIniLoadVar(1,2, "Rom Mapping", "Single_Filtered_Rom_Automatic_Launch", "false")
romMappingFirstMatchingExt := RIniLoadVar(1,2, "Rom Mapping", "First_Matching_Ext", "false")
romMappingShowAllRomsInArchive := RIniLoadVar(1,2, "Rom Mapping", "Show_All_Roms_In_Archive", "true")
romMappingNumberOfWheelsByScreen := RIniLoadVar(1,2, "Rom Mapping", "Number_of_Games_by_Screen", "7")
romMappingMenuWidth := RIniLoadVar(1,2, "Rom Mapping", "Menu_Width", "300")
romMappingMenuMargin := RIniLoadVar(1,2, "Rom Mapping", "Menu_Margin", "50")
romMappingTextFont := RIniLoadVar(1,2, "Rom Mapping", "Text_Font", "Bebas Neue")
romMappingTextOptions := RIniLoadVar(1,2, "Rom Mapping", "Text_Options", "cFFFFFFFF r4 s40 Bold")
romMappingDisabledTextColor := RIniLoadVar(1,2, "Rom Mapping", "Disabled_Text_Color", "ff888888")
romMappingTextSizeDifference := RIniLoadVar(1,2, "Rom Mapping", "Text_Size_Difference", "5")
romMappingTextMargin := RIniLoadVar(1,2, "Rom Mapping", "Text_Margin", "10")
romMappingTitleTextFont := RIniLoadVar(1,2, "Rom Mapping", "Title_Text_Font", "Bebas Neue")
romMappingTitleTextOptions := RIniLoadVar(1,2, "Rom Mapping", "Title_Text_Options", "cFFFFFFFF r4 s60 Bold")
romMappingTitle2TextFont := RIniLoadVar(1,2, "Rom Mapping", "Title2_Text_Font", "Bebas Neue")
romMappingTitle2TextOptions := RIniLoadVar(1,2, "Rom Mapping", "Title2_Text_Options", "cFFFFFFFF r4 s15 Bold")
romMappingGameInfoTextFont := RIniLoadVar(1,2, "Rom Mapping", "Game_Info_Text_Font", "Bebas Neue")
romMappingGameInfoTextOptions := RIniLoadVar(1,2, "Rom Mapping", "Game_Info_Text_Options", "cFFFFFFFF r4 s15 Regular")
romMappingBackgroundBrush := RIniLoadVar(1,2, "Rom Mapping", "Background_Brush", "aa000000")
romMappingColumnBrush := RIniLoadVar(1,2, "Rom Mapping", "Column_Brush", "33000000")
romMappingButtonBrush1 := RIniLoadVar(1,2, "Rom Mapping", "Button_Brush1", "6f000000")
romMappingButtonBrush2 := RIniLoadVar(1,2, "Rom Mapping", "Button_Brush2", "33000000")
romMappingBackgroundAlign := RIniLoadVar(1,2, "Rom Mapping", "Background_Align", "Stretch and Lose Aspect")
romMappingMenuFlagWidth := RIniLoadVar(1,2, "Rom Mapping", "Language_Flag_Width", "40")
romMappingMenuFlagSeparation := RIniLoadVar(1,2, "Rom Mapping", "Language_Flag_Separation", "5")

;-----------------------------------------------------------------------------------------------------------------------------------------
; Skipping some checks if skipchecks is set to true. Used mostly so users don't need blank txt files to point to PC games
;-----------------------------------------------------------------------------------------------------------------------------------------
If (skipChecks = "Rom and Emu" or emuName = "PCLauncher") {	; skipping rom and emu checks
	Log("Main - Using SkipChecks method ""Rom and Emu"" or emuName = ""PCLauncher"".")
	emuFullPath := RIniReadCheck(emuFileRIni, emuName, "Emu_Path")
	romExtensions := RIniReadCheck(emuFileRIni, emuName, "Rom_Extension")	; still fill this var in case the user needs it for something
	romPathFromIni := RIniReadCheck(4, "Roms", "Rom_Path", A_Space)	; might still need a romPath so users can point to a dir to find all their games, but we won't error out if it doesn't exist
	romPathFromIni := GetFullRomPaths(romPathFromIni)	; converts multiple relative rompaths to multiple actual rompaths, keeping the |
	romPath := romPathFromIni	; so we can still use romPath var when SkipChecks is true
} Else If (skipChecks = "Rom Only") {	; skipping only rom checks
	Log("Main - Using SkipChecks method ""Rom Only"".")
	emuFullPath := RIniReadCheck(emuFileRIni, emuName, "Emu_Path",, "Could not find an Emu_Path for " . emuName . " in either of these two files:`n" . sysEmuFile . "`n" . globalEmuFile)
	romExtensions := RIniReadCheck(emuFileRIni, emuName, "Rom_Extension")	; still fill this var in case the user needs it for something
	romPathFromIni := RIniReadCheck(4, "Roms", "Rom_Path", A_Space)	; might still need a romPath so users can point to a dir to find all their games, but we won't error out if it doesn't exist
	romPathFromIni := GetFullRomPaths(romPathFromIni)	; converts multiple relative rompaths to multiple actual rompaths, keeping the |
	romPath := romPathFromIni	; so we can still use romPath var when SkipChecks is true
} Else {	; SkipChecks is not enabled or set to Rom Extension
	Log("Main - Using standard method with ""Rom Extension"" SkipChecks or without any SkipChecks.")
	emuFullPath := RIniReadCheck(emuFileRIni, emuName, "Emu_Path",, "Could not find an Emu_Path for " . emuName . " in either of these two files:`n" . sysEmuFile . "`n" . globalEmuFile)
	romExtensions := RIniReadCheck(emuFileRIni, emuName, "Rom_Extension",, "Could not find a Rom_Extension for " . emuName . " in either of these two files:`n" . sysEmuFile . "`n" . globalEmuFile)
	romPathFromIni := RIniReadCheck(4, "Roms", "Rom_Path", A_Space, "No Rom_Path found in " . sysEmuFile . "`nA Rom_Path is required to find your roms.")	; might need to add an exception to this in scenarios we don't need a Rom_Path
	romPathFromIni := GetFullRomPaths(romPathFromIni)	; converts multiple relative rompaths to multiple actual rompaths, keeping the |
}
emuFullPath := GetFullName(emuFullPath)	; converts relative path to absolute
SplitPath, emuFullPath, executable, emuPath, emuExt, emuNameNoExt

 ; Check if emu is already running and/or cancel duplicate HyperLaunch launches. This is disabled for PCLauncher because %executable% is always blank, which causes ErrorLevel to not be 0.
If (systemName != "PCLauncher" and executable){ ; This "If" is only for HS2, HS1 does not use PCLauncher as a systemName, so this "If" will always be true. Executable might still be blank if the user did not set one, so we have to check for this and will error out later
	Process, Exist, %executable%
	If (ErrorLevel != 0) {
		Log("Main - Possible duplicate launch or emulator never closed from previous launch. " . executable . " is already running, closing HyperLaunch",2,,10)	; warning & dump to log
		ExitApp
	}
}

Log("Main - INI Keys read")
HotKey, %exitScriptKey%, ExitScript

If systemName != PCLauncher	;	skipping these checks for systems that don't need them
{	hpSaveStateKeyCodes := RIniReadCheck(emuFileRIni, emuName, "HyperPause_Save_State_Keys")	; save state keys are emu dependent, so they must exist with the emulator settings
	hpLoadStateKeyCodes := RIniReadCheck(emuFileRIni, emuName, "HyperPause_Load_State_Keys")
}

; Removes spaces from romExtensions if user accidentally placed them
StringReplace, romExtensions, romExtensions, %A_Space%,, All

;-----------------------------------------------------------------------------------------------------------------------------------------

; Defining the file types we want to support throughout the script
; Some parts we need the period removed, so using 2 vars
7zFormats = .zip,.rar,.7z,.lzh,.gzip,.tar
StringReplace, 7zFormatsNoP, 7zFormats,.,,All
SplitPath,7zPath,,7zDir
7zPath := CheckFile(7zPath, "Cannot find " . 7zPath . "`nPlease change 7z_Path in your HyperLaunch.ini to where 7z.exe is located.`nDefault location is """ . moduleExtensionsPath . """")
7zDllPath := CheckFile(7zDir . "\7z.dll", "Cannot find " . 7zDir . "\7z.dll`nPlease move this included file into """ . moduleExtensionsPath . """ as it is required for 7z to work." )

;-----------------------------------------------------------------------------------------------------------------------------------------

fadeImgPath := HLMediaPath . "\Fade"		; Defining path for system Fade Images
IfNotExist, %fadeImgPath%
	FileCreateDir, %fadeImgPath%
HLDataPath := GetFullName(".\Data")

;-----------------------------------------------------------------------------------------------------------------------------------------

 ; Mapping from Settings \ systemName \ Rom Mapping \ *.ini
; This needs to stay above CheckPaths() because we need to check if our rom exists after we build the table
If romMappingEnabled = true
{	romMapPath := A_ScriptDir . "\Settings\" . systemName . "\Rom Mapping"	; define location of Rom Mapping folder, defining this early so 
	romMapTable := CreateRomMapTable(dbName,romMapPath)	; call function to create the Rom Mapping Table
}

;-----------------------------------------------------------------------------------------------------------------------------------------

;Verify settings and error on issues required for proper launching
If skipChecks != false
	Log("Main - SkipChecks is enabled and set to: " . skipChecks,2)

romExtension := CheckPaths()
romExtensionOrig := romExtension ; Storing original romExtension in case 7z support is used, we lose original extension of the rom after processing through the 7z function. This is used when 7z and MultiGame support are used together.
; Defining keymapper profile path vars so they can be used for ahk remaps in the HL thread and xpadder/joytokey in the module
keymapperProfilePath := profilePath . "\" . keymapper	; attaching keymapper chosen to the path so different profiles are stored in their own folders
FEProfile := keymapperProfilePath . "\" . keymapperFrontEndProfileName	; profile while not in an emu and in your Frontend
defaultProfile := keymapperProfilePath . "\_Default"	; default profile for all systems, loaded when there are no system, emu, or rom specific profiles
xPadderSystemProfile := keymapperProfilePath . "\" . systemName . "\_Default"	; xpadder profile for a specific system, loaded when no rom or emu specific profiles are found
systemProfile := keymapperProfilePath . "\" . systemName	; joytokey profile for a specific system, loaded when no rom or emu specific profiles are found
emuProfile := keymapperProfilePath . "\" . systemName . "\" . emuName	; profile for a specific emulator, loaded when no rom specific profile is found
romProfile := keymapperProfilePath . "\" . systemName . "\" . dbName	; rom specific profile
blankProfile := keymapperProfilePath . (If keymapper="xpadder" ? "\_Default" : "") . "\blank"	; this profile is meant to be blank and will be used if no other choices were found, useful for giving unmapped controllers no function, also useful so we dont close the keymapper in case they use the autoprofiler
HyperLaunchProfile := keymapperProfilePath . "\HyperLaunch"

ahkProfilePath := profilePath . "\AHK"
ahkFEProfile := ahkProfilePath . "\" . keymapperFrontEndProfileName	; profile while not in an emu and in your Frontend
ahkDefaultProfile := ahkProfilePath . "\_Default"	; default profile for all systems, loaded when there are no system, emu, or rom specific profiles
ahkSystemProfile := ahkProfilePath . "\" . systemName	; ahk profile for a specific system, loaded when no rom or emu specific profiles are found
ahkEmuProfile := ahkProfilePath . "\" . systemName . "\" . emuName	; profile for a specific emulator, loaded when no rom specific profile is found
ahkRomProfile := ahkProfilePath . "\" . systemName . "\" . dbName	; rom specific profile
ahkHyperLaunchProfile := ahkProfilePath . "\HyperLaunch"

;-----------------------------------------------------------------------------------------------------------------------------------------
; Build new script with module
; We'll use ahktextdll instead of ahkdll to add our own stuff to the script
; This will keep the modules more simplified
;-----------------------------------------------------------------------------------------------------------------------------------------
MScript := BuildScript()
Log("Main - Module is built")

;-----------------------------------------------------------------------------------------------------------------------------------------
; Load DLL
;-----------------------------------------------------------------------------------------------------------------------------------------
AhkDll := CheckFile(A_ScriptDir . "\AutoHotkey.dll")
DllCall("LoadLibrary","Str",AhkDll)

;-----------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------
; Pre Launch
;-----------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------
If hideTaskbar = true
{	Log("Main - Hiding taskbar")
	WinHide ahk_class Shell_TrayWnd
	WinHide, ahk_class Button
}

If ( hideDesktop = "true" && fadeIn != "true" ){
	;Were doing a dual hide really, one time for this thread and once for the module
	;thread. But this is mainly for if the module writers forget to call it.
	Log("Main - Hiding desktop")
	Gui, Color, 000000
	Gui -Caption +ToolWindow ;+AlwaysOnTop
	Gui, Show, x0 y0 W%A_ScreenWidth% H%A_ScreenHeight%, BlackScreen
}

; If hideCursor = true
	; SystemCursor("Off")

If keymapperEnabled = true
	If keymapper not in xpadder,joytokey,joy2key
		ScriptError("Your keymapper is set to """ . keymapper . """. Supported choices are xpadder or joytokey and only one can be used per system",8)
If keymapperAHKMethod = Internal
{	Log("Main - Loading Internal AHK Keymapping")
	Profile2Load := GetAHKProfile(ahkRomProfile . "|" . ahkEmuProfile . "|" . ahkSystemProfile . "|" . ahkDefaultProfile)
	Log("Main - Attaching AHK remaps to module using: " . Profile2Load,5)
	; changed it from a loop, read to a fileread since it is much quicker
	FileRead, profileContents, %Profile2Load%
	; file is added to end of script passed to the dll
	MScript .= "`n`n" . profileContents
	Log("Main - Finished building Internal AHK remaps",5)
}

; Running VJoy & checking to make sure it actually ran
If vJoyEnabled = true
{	; CheckFile(vJoyPath) ; Verify VJoy exists in location user specified
	SplitPath, vJoyPath, vJoyExe, vJoyPath	; split apart path and redefine vars
	vJoyProfilePath := profilePath . "\VJoy"
	If !(FileExist(vJoyProfilePath))	; Check if profile folder exists. If it does not, create it
		FileCreateDir, %vJoyProfilePath%

	romVJoyProfile := vJoyProfilePath . "\" . systemName . "\" . dbName . ".ini"
	emuVJoyProfile := vJoyProfilePath . "\" . systemName . "\" . emuName . ".ini"
	systemVJoyProfile := vJoyProfilePath . "\" . systemName . "\_Default.ini"
	vJoyAr := [romVJoyProfile,emuVJoyProfile,systemVJoyProfile]	; creating an array so we can log each profile we are looking for
	for index, element in vJoyAr	; loop through table looking for a profile
	{	Log("Main - Looking for VJoy profile: " . vJoyAr[A_Index],4)
		If (FileExist(vJoyAr[A_Index]))
			vJoyProfileToUse := vJoyAr[A_Index]
	}
	If !vJoyProfileToUse
		Log("Main - VJoy support is enabled for """ . systemName . """`, but no system, emu, or rom profile found in " . vJoyProfilePath . "\" . systemName . ".")
	Else
		Log("Main - Launching VJoy and using profile: = " . vJoyProfileToUse)

	If vJoyProfileToUse {	; If we found a profile, we can run VJoy
		Log("Main - VJoy Run: """ . vJoyPath . """\" . vJoyExe . " -file """ . vJoyProfileToUse . """")
		Run, %vJoyExe% -file "%vJoyProfileToUse%", %vJoyPath%
		CheckForVJoy(ByRef vJoyExe)
	}
}

If cpWizardEnabled = true
{	If (cpWizardPath != "")
	{	CheckFile(cpWizardPath)
		Log("Main - CPWizard Run: """ . cpWizardPath . """ -emu " . systemName . " -game " . dbName . " " . cpWizardParams)
		Run, "%cpWizardPath%" -emu "%systemName%" -game "%dbName%" %cpWizardParams%,, cPW_PID
		Sleep, %cpWizardDelay%
	}Else
		ScriptError("Missing CPWizard_Path and CPWizard is enabled")
	Log("Main - CPWizard Loaded")
}

If betaBriteEnabled = true
{	If (betaBritePath != "")
	{	CheckFile(betaBritePath)
		SplitPath, betaBritePath,bbName,bbPath
		Log("Main - BetaBrite RunWait: """ . bbPath . "\" . bbName . """ """ . systemName . """ """ . dbName . """ " . betaBriteParams)
		RunWait, %bbName% "%systemName%" "%dbName%" %betaBriteParams%, %bbPath%, Hide
	}Else
		ScriptError("Missing BetaBrite_Path and BetaBrite is enabled")
	Log("Main - BetaBrite Loaded")
}

;-----------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------
; Run Module To Start Launch - ANYTHING BELOW THIS LINE WILL NOT RUN IN THE MODULE THREAD
;-----------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------

Log("Main - Running module",,,1)

If (restoreFE != "false" || logLevel = 10) {	; Only start timer if RestoreFE is enabled ot log level is set to troubleshoot as this is something we need to log.
	Log("Main - Starting timer to watch if Front End gets displaced and restore it if it does.")
	SetTimer, WatchForFEDisplacement, 500	; checks to see if the application locks out the screen from other applications. This helps us know what emus are running true fullscreen or windowed fullscreen
}

DllCall(AhkDll "\ahktextdll","Str",MScript,"Str",options,"Str",parameters,"Cdecl UInt")
If (ErrorLevel != 0)
	ScriptError("Error running module.")

; The script waits here until the module is finished doing its thing.
While DllCall(AhkDll "\ahkReady")
	Sleep, 100
; MsgBox Exiting Main Script

;-----------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------
; Post Launch
;-----------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------
Log("Main - Module ended, exiting HyperLaunch normally")
ExitScript()

;-----------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------
; Functions
;-----------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------
BuildScript(){
	Static retStr

	Global 0
	Global 1
	Global 2
	Global debugModule
	Global frontendPID
	Global frontendPath
	Global frontendExe
	Global frontendExt
	Global frontendName
	Global frontendDrive
	Global exitEmulatorKey
	Global exitEmulatorKeyWait
	Global forceHoldKey
	Global restoreFE
	Global exitScriptKey
	Global toggleCursorKey
	Global executable
	Global romPath
	Global romPathFromIni
	Global emuFullPath
	Global emuPath
	Global emuName
	Global emuExt
	Global romExtension
	Global romExtensionOrig
	Global romExtensions
	Global systemName
	Global dbName
	Global romName
	Global romMapPath
	Global romMapTable
	Global romMappingEnabled
	Global romMappingLaunchMenuEnabled
	Global romMappingFirstMatchingExt
	Global romMappingShowAllRomsInArchive
	Global romMappingNumberOfWheelsByScreen 
	Global romMappingMenuWidth 
	Global romMappingMenuMargin
	Global romMappingTextFont 
	Global romMappingTextOptions
	Global romMappingDisabledTextColor
	Global romMappingTextSizeDifference
	Global romMappingTextMargin 
	Global romMappingTitleTextFont
	Global romMappingTitleTextOptions
	Global romMappingTitle2TextFont 
	Global romMappingTitle2TextOptions
	Global romMappingGameInfoTextFont 
	Global romMappingGameInfoTextOptions 
	Global romMappingBackgroundBrush 
	Global romMappingColumnBrush 
	Global romMappingButtonBrush1 
	Global romMappingButtonBrush2 
	Global romMappingBackgroundAlign
	Global romMappingMenuFlagWidth 
	Global romMappingMenuFlagSeparation
	Global romMappingDefaultMenuList
	Global romMappingSingleFilteredRomAutomaticLaunch
	Global modulesPath
	Global moduleFullName
	Global moduleName
	Global modulePath
	Global moduleExtension
	Global moduleExtensionsPath
	Global libPath
	Global skipchecks
	Global romMatchExt
	Global logFile
	Global logLabel
	Global logLevel
	Global logIncludeModule
	Global logIncludeFileProperties
	Global logShowCommandWindow
	Global logCommandWindow
	Global navUpKey
	Global navDownKey
	Global navLeftKey
	Global navRightKey
	Global navSelectKey
	Global navP2UpKey
	Global navP2DownKey
	Global navP2LeftKey
	Global navP2RightKey
	Global navP2SelectKey
	Global originalWidth
	Global originalHeight
	Global dtEnabled
	Global dtPath
	Global dtUseSCSI
	Global dtAddDrive
	Global emuIdleShutdown
	Global hideCursor
	Global hideDesktop
	Global hideEmu
	Global hideFE
	Global fadeIn
	Global fadeInDuration
	Global fadeInTransitionAnimation
	Global fadeInDelay
	Global fadeInExitDelay
	Global fadeOutExitDelay
	Global fadeOut
	Global fadeOutExtraScreen
	Global fadeOutDuration
	Global fadeOutTransitionAnimation
	Global fadeOutDelay
	Global fadeLyrInterpolation
	Global fadeLyr1Color
	Global fadeLyr1AlignImage
	Global fadeLyr2Pos
	Global fadeLyr2X
	Global fadeLyr2Y
	Global fadeLyr2Adjust
	Global fadeLyr2PicPad
	Global fadeLyr3Pos
	Global fadeLyr3X
	Global fadeLyr3Y
	Global fadeLyr3Adjust
	Global fadeLyr3Speed
	Global fadeLyr3Animation
	Global fadeLyr37zAnimation
	Global fadeLyr3Type
	Global fadeLyr3ImgFollow7zProgress
	Global fadeLyr3Repeat
	Global fadeLyr3PicPad
	Global fadeLyr4Adjust
	Global fadeLyr4X
	Global fadeLyr4Y
	Global fadeLyr4Pos
	Global fadeLyr4FPS
	Global fadeLyr4PicPad
	Global fadeTranspGifColor
	Global fadeBarWindow
	Global fadeBarWindowX
	Global fadeBarWindowY
	Global fadeBarWindowW
	Global fadeBarWindowH
	Global fadeBarWindowR
	Global fadeBarWindowM
	Global fadeBarWindowHatchStyle
	Global fadeBarBack
	Global fadeBarBackColor
	Global fadeBarH
	Global fadeBarR
	Global fadeBarColor
	Global fadeBarHatchStyle
	Global fadeBarPercentageText
	Global fadeBarInfoText
	Global fadeBarXOffset
	Global fadeBarYOffset
	Global fadeRomInfoDescription
	Global fadeRomInfoSystemName
	Global fadeRomInfoYear
	Global fadeRomInfoManufacturer
	Global fadeRomInfoGenre
	Global fadeRomInfoRating
	Global fadeRomInfoOrder
	Global fadeRomInfoTextPlacement
	Global fadeRomInfoTextMargin
	Global fadeRomInfoText1Options
	Global fadeRomInfoText2Options
	Global fadeRomInfoText3Options
	Global fadeRomInfoText4Options
	Global fadeRomInfoText5Options
	Global fadeRomInfoText6Options
	Global fadeStats_Number_of_Times_Played
	Global fadeStats_Last_Time_Played 
	Global fadeStats_Average_Time_Played 
	Global fadeStats_Total_Time_Played 
	Global fadeStats_System_Total_Played_Time
	Global fadeStats_Total_Global_Played_Time 
	Global fadeStatsInfoOrder 
	Global fadeStatsInfoTextPlacement 
	Global fadeStatsInfoTextMargin 
	Global fadeStatsInfoText1Options
	Global fadeStatsInfoText2Options 
	Global fadeStatsInfoText3Options
	Global fadeStatsInfoText4Options 
	Global fadeStatsInfoText5Options 
	Global fadeStatsInfoText6Options 
	Global fadeText1X
	Global fadeText1Y
	Global fadeText1Options
	Global fadeText1
	Global fadeText2X
	Global fadeText2Y
	Global fadeText2Options
	Global fadeText2
	Global fadeFont
	Global fadeSystemAndRomLayersOnly
	Global fadeInterruptKey
	Global detectFadeErrorEnabled
	Global fadeImgPath
	Global HLDataPath
	Global HLMediaPath
	Global HLErrSoundPath
	Global 7zEnabled
	Global 7zPath
	Global 7zDllPath
	Global 7zExtractPath
	Global 7zExtractPathOrig
	Global 7zAttachSystemName
	Global 7zDelTemp
	Global 7zSounds
	Global 7zFormats
	Global 7zFormatsNoP
	Global mgEnabled
	Global mgKey
	Global mgBackgroundColor
	Global mgSidePadding
	Global mgYOffset
	Global mgImageAdjust
	Global mgFont
	Global mgText1Options
	Global mgText1Text
	Global mgText2Options
	Global mgText2Offset
	Global mgUseSound
	Global mgSoundfreq
	Global mgExitEffect
	Global mgSelectedEffect
	Global mgUseGameArt
	Global mgArtworkDir
	Global hpEnabled
	Global hpKey
	Global hpBackToMenuBarKey
	Global hpZoomInKey
	Global hpZoomOutKey
	Global hpScreenshotKey
	Global hpHiToTextPath
	Global hpSaveStateKeyCodes
	Global hpLoadStateKeyCodes
	Global keymapperEnabled
	Global keymapperAHKMethod
	Global keymapper
	Global xpadderFullPath
	Global joyToKeyFullPath
	Global keymapperProfilePath
	Global keymapperFrontEndProfileName
	Global keymapperHyperLaunchProfileEnabled
	Global JoyIDsEnabled
	Global JoyIDsPreferredControllersSystem
	Global JoyIDsPreferredControllersGlobal
	Global CustomJoyNamesEnabled
	Global CustomJoyNames
	Global FEProfile
	Global defaultProfile
	Global systemProfile
	Global xPadderSystemProfile
	Global emuProfile
	Global romProfile
	Global HyperLaunchProfile
	Global blankProfile
	Global ahkFEProfile
	Global ahkDefaultProfile
	Global ahkSystemProfile
	Global ahkEmuProfile
	Global ahkRomProfile
	Global ahkHyperLaunchProfile
	Global bezelEnabled
	Global statisticsEnabled

	;Common to all modules
	retStr .= ";----------------------------------------------------------------------------"
	retStr .= "`n; INJECTED VARIABLES"
	retStr .= "`n;----------------------------------------------------------------------------`n"
	retStr .= "`n#NoTrayIcon"
	retStr .= "`n#InstallKeybdHook"
	retStr .= "`nDetectHiddenWindows, ON"
	retStr .= "`nSetTitleMatchMode`, 2"
	 ; required for ahk remapping to work properly with newer dll, might fix other bugs too:
	retStr .= "`nSendMode`, Event"

	;Common to all modules, inject vars into module
	temp0 = %0% ; this is a quick fix for not being able to concenate number on the next line
	retStr .= "`n0 = " . temp0
	retStr .= "`nfrontendPID = " . frontendPID
	retStr .= "`nfrontendPath = " . frontendPath
	retStr .= "`nfrontendExe = " . frontendExe
	retStr .= "`nfrontendExt = " . frontendExt
	retStr .= "`nfrontendName = " . frontendName
	retStr .= "`nfrontendDrive = " . frontendDrive
	retStr .= "`nexitEmulatorKey = " . exitEmulatorKey
	retStr .= "`nexitEmulatorKeyWait = " . exitEmulatorKeyWait
	retStr .= "`nforceHoldKey = " . forceHoldKey
	retStr .= "`nrestoreFE = " . restoreFE
	retStr .= "`nexitScriptKey = " . exitScriptKey
	retStr .= "`ntoggleCursorKey = " . toggleCursorKey
	retStr .= "`nemuFullPath = " . emuFullPath
	retStr .= "`nemuPath = " . emuPath
	retStr .= "`nemuName = " . emuName
	retStr .= "`nemuExt = " . emuExt
	retStr .= "`nromPath = " . romPath
	retStr .= "`nromPathFromIni = " . romPathFromIni
	retStr .= "`nromExtension = " . romExtension
	retStr .= "`nromExtensionOrig = " . romExtensionOrig
	retStr .= "`nromExtensions = " . romExtensions
	retStr .= "`nexecutable = " . executable
	retStr .= "`nsystemName = " . systemName
	retStr .= "`ndbName = " . dbName
	retStr .= "`nromName = " . romName
	retStr .= "`nromMapPath = " . romMapPath
	retStr .= "`nromMappingEnabled = " . romMappingEnabled
	retStr .= "`nromMappingLaunchMenuEnabled = " . romMappingLaunchMenuEnabled
	retStr .= "`nromMappingFirstMatchingExt = " . romMappingFirstMatchingExt
	retStr .= "`nromMappingShowAllRomsInArchive = " . romMappingShowAllRomsInArchive
	retStr .= "`nromMappingNumberOfWheelsByScreen = " . romMappingNumberOfWheelsByScreen 
	retStr .= "`nromMappingMenuWidth = " . romMappingMenuWidth
	retStr .= "`nromMappingMenuMargin = " . romMappingMenuMargin 
	retStr .= "`nromMappingTextFont = " .  romMappingTextFont
	retStr .= "`nromMappingTextOptions = " . romMappingTextOptions
	retStr .= "`nromMappingDisabledTextColor = " . romMappingDisabledTextColor
	retStr .= "`nromMappingTextSizeDifference = " . romMappingTextSizeDifference
	retStr .= "`nromMappingTextMargin = " . romMappingTextMargin 
	retStr .= "`nromMappingTitleTextFont = " . romMappingTitleTextFont
	retStr .= "`nromMappingTitleTextOptions = " . romMappingTitleTextOptions 
	retStr .= "`nromMappingTitle2TextFont = " . romMappingTitle2TextFont 
	retStr .= "`nromMappingTitle2TextOptions = " . romMappingTitle2TextOptions
	retStr .= "`nromMappingGameInfoTextFont = " . romMappingGameInfoTextFont 
	retStr .= "`nromMappingGameInfoTextOptions = " . romMappingGameInfoTextOptions 
	retStr .= "`nromMappingBackgroundBrush = " . romMappingBackgroundBrush 
	retStr .= "`nromMappingColumnBrush = " . romMappingColumnBrush 
	retStr .= "`nromMappingButtonBrush1 = " . romMappingButtonBrush1 
	retStr .= "`nromMappingButtonBrush2 = " . romMappingButtonBrush2 
	retStr .= "`nromMappingBackgroundAlign = " . romMappingBackgroundAlign
	retStr .= "`nromMappingMenuFlagWidth = " . romMappingMenuFlagWidth 
	retStr .= "`nromMappingMenuFlagSeparation = " . romMappingMenuFlagSeparation
	retStr .= "`nromMappingDefaultMenuList = " . romMappingDefaultMenuList
	retStr .= "`nromMappingSingleFilteredRomAutomaticLaunch = " . romMappingSingleFilteredRomAutomaticLaunch
	retStr .= "`nskipchecks = " . skipchecks
	retStr .= "`nromMatchExt = " . romMatchExt
	retStr .= "`nlogFile = " . logFile
	retStr .= "`nlogLabel := [""    INFO""`,"" WARNING""`,""   ERROR""`,""  DEBUG1""`,""  DEBUG2""]"	; can't pass an array as a var into the module, so recreating it here
	retStr .= "`nlogLevel = " . logLevel
	retStr .= "`nlogIncludeModule = " . logIncludeModule
	retStr .= "`nlogIncludeFileProperties = " . logIncludeFileProperties
	retStr .= "`nlogShowCommandWindow = " . logShowCommandWindow
	retStr .= "`nlogCommandWindow = " . logCommandWindow
	retStr .= "`nnavUpKey = " . navUpKey
	retStr .= "`nnavDownKey = " . navDownKey
	retStr .= "`nnavLeftKey = " . navLeftKey
	retStr .= "`nnavRightKey = " . navRightKey
	retStr .= "`nnavSelectKey = " . navSelectKey
	retStr .= "`nnavP2UpKey = " . navP2UpKey
	retStr .= "`nnavP2DownKey = " . navP2DownKey
	retStr .= "`nnavP2LeftKey = " . navP2LeftKey
	retStr .= "`nnavP2RightKey = " . navP2RightKey
	retStr .= "`nnavP2SelectKey = " . navP2SelectKey
	retStr .= "`noriginalWidth = " . originalWidth
	retStr .= "`noriginalHeight = " . originalHeight
	retStr .= "`ndtEnabled = " . dtEnabled
	retStr .= "`ndtPath = " . dtPath
	retStr .= "`ndtUseSCSI = " . dtUseSCSI
	retStr .= "`ndtAddDrive = " . dtAddDrive
	retStr .= "`nemuIdleShutdown = " . emuIdleShutdown
	retStr .= "`nhideCursor = " . hideCursor
	retStr .= "`nhideEmu = " . hideEmu
	retStr .= "`nhideFE = " . hideFE
	retStr .= "`nfadeIn = " . fadeIn
	retStr .= "`nfadeInDuration = " . fadeInDuration
	retStr .= "`nfadeInTransitionAnimation = " . fadeInTransitionAnimation
	retStr .= "`nfadeInDelay = " . fadeInDelay
	retStr .= "`nfadeInExitDelay = " . fadeInExitDelay
	retStr .= "`nfadeOutExitDelay = " . fadeOutExitDelay
	retStr .= "`nfadeOut = " . fadeOut
	retStr .= "`nfadeOutExtraScreen = " . fadeOutExtraScreen
	retStr .= "`nfadeOutDuration = " . fadeOutDuration
	retStr .= "`nfadeOutTransitionAnimation = " . fadeOutTransitionAnimation
	retStr .= "`nfadeOutDelay = " . fadeOutDelay
	retStr .= "`nfadeLyrInterpolation = " . fadeLyrInterpolation
	retStr .= "`nfadeLyr1Color = " . fadeLyr1Color
	retStr .= "`nfadeLyr1AlignImage = " . fadeLyr1AlignImage
	retStr .= "`nfadeLyr2Pos = " . fadeLyr2Pos
	retStr .= "`nfadeLyr2X = " . fadeLyr2X
	retStr .= "`nfadeLyr2Y = " . fadeLyr2Y
	retStr .= "`nfadeLyr2Adjust = " . fadeLyr2Adjust
	retStr .= "`nfadeLyr2PicPad = " . fadeLyr2PicPad
	retStr .= "`nfadeLyr3Pos = " . fadeLyr3Pos
	retStr .= "`nfadeLyr3X = " . fadeLyr3X
	retStr .= "`nfadeLyr3Y = " . fadeLyr3Y
	retStr .= "`nfadeLyr3Adjust = " . fadeLyr3Adjust
	retStr .= "`nfadeLyr3Speed = " . fadeLyr3Speed
	retStr .= "`nfadeLyr3Animation = " . fadeLyr3Animation
	retStr .= "`nfadeLyr37zAnimation = " . fadeLyr37zAnimation
	retStr .= "`nfadeLyr3Type = " . fadeLyr3Type
	retStr .= "`nfadeLyr3ImgFollow7zProgress = " . fadeLyr3ImgFollow7zProgress
	retStr .= "`nfadeLyr3Repeat = " . fadeLyr3Repeat
	retStr .= "`nfadeLyr3PicPad = " . fadeLyr3PicPad
	retStr .= "`nfadeLyr4Adjust = " . fadeLyr4Adjust
	retStr .= "`nfadeLyr4X = " . fadeLyr4X
	retStr .= "`nfadeLyr4Y = " . fadeLyr4Y
	retStr .= "`nfadeLyr4Pos = " . fadeLyr4Pos
	retStr .= "`nfadeLyr4FPS = " . fadeLyr4FPS
	retStr .= "`nfadeLyr4PicPad = " . fadeLyr4PicPad
	retStr .= "`nfadeTranspGifColor = " . fadeTranspGifColor
	retStr .= "`nfadeBarWindow = " . fadeBarWindow
	retStr .= "`nfadeBarWindowX = " . fadeBarWindowX
	retStr .= "`nfadeBarWindowY = " . fadeBarWindowY
	retStr .= "`nfadeBarWindowW = " . fadeBarWindowW
	retStr .= "`nfadeBarWindowH = " . fadeBarWindowH
	retStr .= "`nfadeBarWindowR = " . fadeBarWindowR
	retStr .= "`nfadeBarWindowM = " . fadeBarWindowM
	retStr .= "`nfadeBarWindowHatchStyle = " . fadeBarWindowHatchStyle
	retStr .= "`nfadeBarBack = " . fadeBarBack
	retStr .= "`nfadeBarBackColor = " . fadeBarBackColor
	retStr .= "`nfadeBarH = " . fadeBarH
	retStr .= "`nfadeBarR = " . fadeBarR
	retStr .= "`nfadeBarColor = " . fadeBarColor
	retStr .= "`nfadeBarHatchStyle = " . fadeBarHatchStyle
	retStr .= "`nfadeBarPercentageText = " . fadeBarPercentageText
	retStr .= "`nfadeBarInfoText = " . fadeBarInfoText
	retStr .= "`nfadeBarXOffset = " . fadeBarXOffset
	retStr .= "`nfadeBarYOffset = " . fadeBarYOffset
	retStr .= "`nfadeRomInfoDescription = " . fadeRomInfoDescription
	retStr .= "`nfadeRomInfoSystemName = " . fadeRomInfoSystemName
	retStr .= "`nfadeRomInfoYear = " . fadeRomInfoYear
	retStr .= "`nfadeRomInfoManufacturer = " . fadeRomInfoManufacturer
	retStr .= "`nfadeRomInfoGenre = " . fadeRomInfoGenre
	retStr .= "`nfadeRomInfoRating = " . fadeRomInfoRating
	retStr .= "`nfadeRomInfoOrder = " . fadeRomInfoOrder
	retStr .= "`nfadeRomInfoTextPlacement = " . fadeRomInfoTextPlacement
	retStr .= "`nfadeRomInfoTextMargin = " . fadeRomInfoTextMargin
	retStr .= "`nfadeRomInfoText1Options = " . fadeRomInfoText1Options
	retStr .= "`nfadeRomInfoText2Options = " . fadeRomInfoText2Options
	retStr .= "`nfadeRomInfoText3Options = " . fadeRomInfoText3Options
	retStr .= "`nfadeRomInfoText4Options = " . fadeRomInfoText4Options
	retStr .= "`nfadeRomInfoText5Options = " . fadeRomInfoText5Options
	retStr .= "`nfadeRomInfoText6Options = " . fadeRomInfoText6Options	
	retStr .= "`nfadeStats_Number_of_Times_Played = " . fadeStats_Number_of_Times_Played
	retStr .= "`nfadeStats_Last_Time_Played = " .  fadeStats_Last_Time_Played
	retStr .= "`nfadeStats_Average_Time_Played = " . fadeStats_Average_Time_Played 
	retStr .= "`nfadeStats_Total_Time_Played = " .  fadeStats_Total_Time_Played
	retStr .= "`nfadeStats_System_Total_Played_Time = " . fadeStats_System_Total_Played_Time
	retStr .= "`nfadeStats_Total_Global_Played_Time = " . fadeStats_Total_Global_Played_Time
	retStr .= "`nfadeStatsInfoOrder = " .  fadeStatsInfoOrder
	retStr .= "`nfadeStatsInfoTextPlacement = " .  fadeStatsInfoTextPlacement
	retStr .= "`nfadeStatsInfoTextMargin = " . fadeStatsInfoTextMargin 
	retStr .= "`nfadeStatsInfoText1Options = " . fadeStatsInfoText1Options
	retStr .= "`nfadeStatsInfoText2Options = " . fadeStatsInfoText2Options 
	retStr .= "`nfadeStatsInfoText3Options = " . fadeStatsInfoText3Options
	retStr .= "`nfadeStatsInfoText4Options = " .  fadeStatsInfoText4Options
	retStr .= "`nfadeStatsInfoText5Options = " .  fadeStatsInfoText5Options
	retStr .= "`nfadeStatsInfoText6Options = " . fadeStatsInfoText6Options
	retStr .= "`nfadeText1X = " . fadeText1X
	retStr .= "`nfadeText1Y = " . fadeText1Y
	retStr .= "`nfadeText1Options = " . fadeText1Options
	retStr .= "`nfadeText1 = " . fadeText1
	retStr .= "`nfadeText2X = " . fadeText2X
	retStr .= "`nfadeText2Y = " . fadeText2Y
	retStr .= "`nfadeText2Options = " . fadeText2Options
	retStr .= "`nfadeText2 = " . fadeText2
	retStr .= "`nfadeFont = " . fadeFont
	retStr .= "`nfadeSystemAndRomLayersOnly = " . fadeSystemAndRomLayersOnly
	retStr .= "`nfadeInterruptKey = " . fadeInterruptKey
	retStr .= "`ndetectFadeErrorEnabled = " . detectFadeErrorEnabled
	retStr .= "`nfadeImgPath = " . fadeImgPath
	retStr .= "`nHLDataPath = " . HLDataPath
	retStr .= "`nHLMediaPath = " . HLMediaPath
	retStr .= "`nHLErrSoundPath = " . HLErrSoundPath
	retStr .= "`nmodulesPath = " . modulesPath
	retStr .= "`nmoduleFullName = " . moduleFullName
	retStr .= "`nmoduleName = " . moduleName
	retStr .= "`nmodulePath = " . modulePath
	retStr .= "`nmoduleExtension = " . moduleExtension
	retStr .= "`nmoduleExtensionsPath = " . moduleExtensionsPath
	retStr .= "`nlibPath = " . libPath
	retStr .= "`n7zEnabled = " . 7zEnabled
	retStr .= "`n7zPath = " . 7zPath
	retStr .= "`n7zDllPath = " . 7zDllPath
	retStr .= "`n7zExtractPath = " . 7zExtractPath
	retStr .= "`n7zExtractPathOrig = " . 7zExtractPathOrig
	retStr .= "`n7zAttachSystemName = " . 7zAttachSystemName
	retStr .= "`n7zDelTemp = " . 7zDelTemp
	retStr .= "`n7zSounds = " . 7zSounds
	retStr .= "`n7zFormats = " . 7zFormats
	retStr .= "`n7zFormatsNoP = " . 7zFormatsNoP
	retStr .= "`nmgEnabled = " . mgEnabled
	retStr .= "`nmgKey = " . mgKey
	retStr .= "`nmgBackgroundColor = " . mgBackgroundColor
	retStr .= "`nmgSidePadding = " . mgSidePadding
	retStr .= "`nmgYOffset = " . mgYOffset
	retStr .= "`nmgImageAdjust = " . mgImageAdjust
	retStr .= "`nmgFont = " . mgFont
	retStr .= "`nmgText1Options = " . mgText1Options
	retStr .= "`nmgText1Text = " . mgText1Text
	retStr .= "`nmgText2Options = " . mgText2Options
	retStr .= "`nmgText2Offset = " . mgText2Offset
	retStr .= "`nmgUseSound = " . mgUseSound
	retStr .= "`nmgSoundfreq = " . mgSoundfreq
	retStr .= "`nmgExitEffect = " . mgExitEffect
	retStr .= "`nmgSelectedEffect = " . mgSelectedEffect
	retStr .= "`nmgUseGameArt = " . mgUseGameArt
	retStr .= "`nmgArtworkDir = " . mgArtworkDir
	retStr .= "`nhpEnabled = " . hpEnabled
	retStr .= "`nhpKey = " . hpKey
	retStr .= "`nhpBackToMenuBarKey = " . hpBackToMenuBarKey
	retStr .= "`nhpZoomInKey = " . hpZoomInKey
	retStr .= "`nhpZoomOutKey = " . hpZoomOutKey
	retStr .= "`nhpScreenshotKey = " . hpScreenshotKey
	retStr .= "`nhpHiToTextPath = " . hpHiToTextPath
	retStr .= "`nhpSaveStateKeyCodes = " . hpSaveStateKeyCodes
	retStr .= "`nhpLoadStateKeyCodes = " . hpLoadStateKeyCodes
	retStr .= "`nkeymapperEnabled = " . keymapperEnabled
	retStr .= "`nkeymapperAHKMethod = " . keymapperAHKMethod
	retStr .= "`nkeymapper = " . keymapper
	retStr .= "`nxpadderFullPath = " . xpadderFullPath
	retStr .= "`njoyToKeyFullPath = " . joyToKeyFullPath
	retStr .= "`nkeymapperProfilePath = " . keymapperProfilePath
	retStr .= "`nkeymapperFrontEndProfileName = " . keymapperFrontEndProfileName
	retStr .= "`nkeymapperHyperLaunchProfileEnabled = " . keymapperHyperLaunchProfileEnabled
	retStr .= "`nJoyIDsEnabled = " . JoyIDsEnabled
	retStr .= "`nJoyIDsPreferredControllersSystem = " . JoyIDsPreferredControllersSystem
	retStr .= "`nJoyIDsPreferredControllersGlobal = " . JoyIDsPreferredControllersGlobal
	retStr .= "`nCustomJoyNamesEnabled = " . CustomJoyNamesEnabled
	retStr .= "`nCustomJoyNames = " . CustomJoyNames
	retStr .= "`nFEProfile = " . FEProfile
	retStr .= "`ndefaultProfile = " . defaultProfile
	retStr .= "`nsystemProfile = " . systemProfile
	retStr .= "`nxPadderSystemProfile = " . xPadderSystemProfile
	retStr .= "`nemuProfile = " . emuProfile
	retStr .= "`nromProfile = " . romProfile
	retStr .= "`nHyperLaunchProfile = " . HyperLaunchProfile
	retStr .= "`nblankProfile = " . blankProfile
	retStr .= "`nahkFEProfile = " . ahkFEProfile
	retStr .= "`nahkDefaultProfile = " . ahkDefaultProfile
	retStr .= "`nahkSystemProfile = " . ahkSystemProfile
	retStr .= "`nahkEmuProfile = " . ahkEmuProfile
	retStr .= "`nahkRomProfile = " . ahkRomProfile
	retStr .= "`nahkHyperLaunchProfile = " . ahkHyperLaunchProfile
	retStr .= "`nbezelEnabled = " . bezelEnabled
	retStr .= "`nstatisticsEnabled = " . statisticsEnabled

	; Dumping vars to log
	If logIncludeModule = true
	{
		Loop, Parse, retStr, `n
			retStrLog .= "`t`t`t`t`t" . A_LoopField . "`n"
		Log("BuildScript - User Variables:`n" . retStrLog,,,1)	; dumping user vars to log file
		retStrLog:=
	}

	; Serialize and inject code necessary to inject an array from the HL thread to the module thread
	If romMappingEnabled = true
	{	romMapTableString := JSON_to(romMapTable)	; serialize the array so it can be passed into the module as a string
		StringReplace,romMapTableString, RomMapTableString, `", DBLQT, 1	; replaces all " with DBLQT
		StringReplace,romMapTableString, RomMapTableString, `n, XNLX, 1	; replaces all new lines with XNLX
		romMapTableString := """" . romMapTableString . """"	; wrap entire string in quotes
		retStr .= "`n`n#Include`, %A_ScriptDir%\Module Extensions"	; change all future includes to look in the Lib folder
		retStr .= "`n#Include`, JSON.ahk"	; Include extension to handle serialized array injecting from the HL thread to the module thread
		retStr .= "`n#EscapeChar ``"	; JSON library changed the default EscapeChar and CommentFlag, so change them back
		retStr .= "`n#CommentFlag `;"
		retStr .= "`nromMapTableString := " . romMapTableString
		retStr .= "`nStringReplace`,romMapTableString`, RomMapTableString`, DBLQT`, ``""`, 1"	; replaces all DBLQT with "
		retStr .= "`nStringReplace`,romMapTableString`, RomMapTableString`, XNLX`, ``n`, 1"	; replaces all XNLX with new lines
		retStr .= "`nromMapTable := JSON_from(romMapTableString)"	; convert serialized string back into an array
	}

	retStr .= "`n`nLog(""Module initialized""`,`,`,`,1)"
	retStr .= "`nzz:="""""	; this injects a blank var soley used for tricking ahk at loadtime so some functions do not error out because not found

	retStr .= "`n;----------------------------------------------------------------------------"
	retStr .= "`n; INITIAL HOTKEYS AND LIBRARIES"
	retStr .= "`n;----------------------------------------------------------------------------"

	; Inject HyperLaunch feature's runtime scripts
	retStr .= "`n`n#Include`, %A_ScriptDir%\Lib"	; change all future includes to look in the Lib folder

	; Inject XHotkey initial key changes
	retStr .= "`n`n#Include`, XHotkey Init.ahk"
		Log("BuildScript - Loaded XHotkey Init.ahk scripts")
		
	; Need this for module CRC check, fadeIn, keymapper and showing 7z progress. If user wants bar to show, or image following 7z, we also need this
	retStr .= "`n`nHyperLaunchDllFile=%moduleExtensionsPath%\HyperLaunch.dll`nCLR_Start()`nIf !hModule := CLR_LoadLibrary(HyperLaunchDllFile)`nScriptError(""Error loading the  DLL:``n"" . HyperLaunchDllFile)`nIf !HLObject := CLR_CreateObject(hModule`,""HLUtil.HyperLaunchUtils"")`nScriptError(""Error creating object. There may be something wrong with the dll file:"" . HyperLaunchDllFile)"
	retStr .= "`n`nIf logLevel >= 4`nCOM_Invoke(HLObject`, ""setLogMode""`, ""2"")`n"

	If (keymapperEnabled = "true" || keymapperAHKMethod = "External") {
		retStr .= "`n`n#Include`, Keymapper Init.ahk"
		Log("BuildScript - Loaded Keymapper Init.ahk scripts")
	}

	;Create table for checking labels used in MultiGame and HyperPause support
	If (mgEnabled = "true" or hpEnabled = "true") {
		hlLabelsAr:=[]	; initialize and empty the table
		hlLabels=HaltEmu`:|MultiGame`:|RestoreEmu`:
		Loop, Parse, hlLabels, |
			hlLabelsAr[A_Index,1]:=A_LoopField	; fill Row 1 with the labels we want to search the module for
	}

	If (fadeIn = "true" or fadeOut = "true") {	; need this for fadeIn or fadeOut
		retStr .= "`n`n#Include`, %A_ScriptDir%\Lib"	; change all future includes to look in the Lib folder
		retStr .= "`n`n#Include`, Fade Init.ahk"
		Log("BuildScript - Loaded Fade Init.ahk scripts")
	}

	;Check if HyperPause libraries exist prior to loading them, then load HP runtime scripts
	If hpEnabled = true
	{	vaFile := moduleExtensionsPath . "\VA.ahk"
		CheckFile(vaFile, "HyperPause is enabled but could not find " . vaFile,,"23616A65",0)
		retStr .= "`n`n#Include`, %A_ScriptDir%\Lib"	; change all future includes to look in the Lib folder
		retStr .= "`n`n#Include`, *i HyperPause Init.ahk"
		Log("BuildScript - Loaded HyperPause Init.ahk scripts")
	}

	;Add Statistics Init script
	If statisticsEnabled = true
	{	retStr .= "`n`n#Include`, %A_ScriptDir%\Lib"	; change all future includes to look in the Lib folder
		retStr .= "`n`n#Include`, *i Statistics Init.ahk"
		Log("BuildScript - Loaded Statistics Init.ahk scripts")
	}

	;Add MultiGame scripts
	If mgEnabled = true
	{	retStr .= "`n`n#Include`, %A_ScriptDir%\Lib"	; change all future includes to look in the Lib folder
		retStr .= "`n`n#Include`, MultiGame Init.ahk"
		Log("BuildScript - Loaded MultiGame.ahk scripts")
	}

	userFuncInitFile := libPath . "\User Functions Init.ahk"
	IfExist, %userFuncInitFile%
	{	retStr .= "`n`n#Include`, %A_ScriptDir%\Lib"	; change all future includes to look in the Lib folder
		retStr .= "`n`n#Include`, *i User Functions Init.ahk"
		Log("BuildScript - Loaded User Functions Init.ahk script")
	}

	; If user set a value for emuIdleShutdown, inject the timer into the module. It runs ever 5 seconds and does an idle check to see if it should shutdown the emulator
	If (emuIdleShutdown and emuIdleShutdown != "ERROR") {
		retStr .= "`n`nSetTimer`, EmuIdleCheck`, 5000"
		convertedIdle := Milli2HMS(emuIdleShutdown)
		Log("BuildScript - Emu Idle timer enabled, emu will shutdown when idle for " . convertedIdle)
	}

	StringReplace, tempStr, retStr, `n, , UseErrorLevel
	Log("BuildScript - Module starts on line: " . ErrorLevel+2,4)	; dumps to log level Debug1

	retStr .= "`n`n;----------------------------------------------------------------------------"
	retStr .= "`n; MODULE SCRIPT"
	retStr .= "`n;----------------------------------------------------------------------------`n"

	;Now insert the module script. We have to add each line individually for this to work
	Loop, Read, %moduleFullName%
	{
		; lines placed before updating retStr will be adding to the line prior to the current A_LoopReadLine
		If (logCloseProcessEnd && A_LoopReadLine = "Return") {
			logCloseProcessEnd:=
			retStr .= "`nLog(""CloseProcess - Ended""`,4)"	; inject log so we don't have to put it in every module
		}

		retStr .= "`n" . A_LoopReadLine
		retStrLog .= "`t`t`t`t`t" . A_LoopReadLine . "`n"	; only for logging just the module lines
		AutoTrim, On	; ensure this is on in case it was turned off prior
		trimmedLine = %A_LoopReadLine%	; trim whitespace from beginning and end of the line so the following checks work
	
		;Check for Labels required for MultiGame or HyperPause functionality
		If (mgEnabled = "true" or hpEnabled = "true") {
			Loop % hlLabelsAr.MaxIndex()
				If trimmedLine contains % hlLabelsAr[A_Index,1]
					hlLabelsAr[A_Index,2]:=1	; mark each item in table if we found it in the module (in Row 2)
		}
		If trimmedLine = CloseProcess`:
		{	foundCloseProcess:=1
			logCloseProcessEnd:=1	; using this to tell the loop when we hit a return, to add a log before the return line, ending closeprocess
			retStr .= "`nLog(""CloseProcess - Started`, user requested to end launched application""`,4)"	; inject log so we don't have to put it in every module
		}
		If trimmedLine = StartModule()	; 2nd check is for modules with GUIs
			foundStartModule := "true"
		If trimmedLine = ExitModule()	; 2nd check is for modules with GUIs
			foundExitModule:=1
		If fadeIn = true
		{	If trimmedLine = FadeInStart()	; check if module contains the line FadeInStart()
			{	foundFadeInStart:=1
				retStr .= "`n`nIf (fadeIn = ""true""){`nRandom`, ee`, 1`, 1000`nIf ee >= 1000`nCorner(300`,200)`n}"
			} 
			If trimmedLine = FadeInExit()	; check if module contains the line FadeInExit()
				foundFadeInExit:=1
		}
		If fadeOut = true
		{	If trimmedLine = FadeOutStart()	; check if module contains the line FadeOutStart()
				foundFadeOutStart:=1
			If trimmedLine = FadeOutExit()	; check if module contains the line FadeOutExit()
				foundFadeOutExit:=1
		}
		If trimmedLine contains 7z(,7z%zz%	; 2nd check is for modules with GUIs
			retStr := "found7z=true`n" . retStr	; placing thie var at the top of retStr because it needs to be filled before fade is ran and since at this point of reading the module, we are after FadeInStart()
		IfInString, trimmedLine, HideDesktop()
			addHideDesktop := "true"
		IfInString, trimmedLine, HideEmuStart(
			addHideEmu := "true"
		IfInString, trimmedLine, DaemonTools(
			addDaemonTools := "true"
		IfInString, trimmedLine, xpath(
			addXpath := "true"
	}

	; Dumping module to log
	If logIncludeModule = true
	{	Log("BuildScript - Module:`n" . retStrLog,,,1)	; dumping user vars to log file
		retStrLog:=
	}

	retStr .= "`n;----------------------------------------------------------------------------"
	retStr .= "`n; INJECTED FUNCTIONS AND LABELS"
	retStr .= "`n;----------------------------------------------------------------------------"
	

	;------------------ Anything below this line will not "run" in the module. It can only be used for injecting Functions and Labels to be called in the above scripts ------------------;
	
	
	; Inject MG/HP labels if they are not found in the module so ahk does not error. This makes it so we don't need to put blank labels in the module if they are never used.
	If (mgEnabled = "true" or hpEnabled = "true") 
		for index, element in hlLabelsAr	; loop through table to see if any items were not found
			If hlLabelsAr[A_Index,2] != 1
				retStr .= "`n`n" . hlLabelsAr[A_Index,1] . "`nReturn"
	If !foundCloseProcess
		ScriptError("Your module does not contain a ""CloseProcess:"" section.`nPlease download a module that has one.")
	If !foundStartModule
		ScriptError("Your module does not contain a ""StartModule()"" line.`nPlease download a module that has one.")
	If !foundExitModule
		ScriptError("Your module does not contain a ""ExitModule()"" line.`nPlease download a module that has one.")
	If fadeIn = true
	{	If !foundFadeInStart
			ScriptError("Your module does not contain a ""FadeInStart()"" line but you have Fade_In enabled.`nPlease download a module that has one or turn off Fade_In.")
		If !foundFadeInExit
			ScriptError("Your module does not contain a ""FadeInExit()"" line but you have Fade_In enabled.`nPlease download a module that has one or turn off Fade_In.")
	}
	If fadeOut = true
	{	If !foundFadeOutStart
			ScriptError("Your module does not contain a ""FadeOutStart()"" line but you have Fade_Out enabled.`nPlease download a module that has one or turn off Fade_Out.")
		If !foundFadeOutExit
			ScriptError("Your module does not contain a ""FadeOutExit()"" line but you have Fade_Out enabled.`nPlease download a module that has one or turn off Fade_Out.")
	}

	retStr .= "`n`n#Include`, %A_ScriptDir%\Module Extensions"	; change all future includes to look in the Module Extensions folder

	; Load gdip library into the module
	retStr .= "`n`n#Include`, Gdip.ahk"
	; CLR library required for 7z Progress support and the Amiga module
	retStr .= "`n`n#include`, CLR.ahk"
	; COM library required for 7z and HyperPause support
	retStr .= "`n`n#include`, COM.ahk"

	; Inject xpath if it is called for in the module
	If addXpath = true
	{	xpathFile := moduleExtensionsPath . "\xpath.ahk"
		CheckFile(xpathFile, moduleName . " uses xpath, but the xpath library cound not be found: " . xpathFile,,"CD843143",0)
		retStr .= "`n`n#Include`, *i xpath.ahk"
		Log("BuildScript - Loaded xpath library")
	}

	retStr .= "`n`n#Include`, %A_ScriptDir%\Lib"	; change all future includes to look in the Lib folder
	retStr .= "`n`n#Include`, *i Shared.ahk"
	retStr .= "`n`n#Include`, *i XHotkey.ahk"

	;Add Global HideDesktop function to module if it is used
	If ( addHideDesktop = "true" && hideDesktop = "true" ) {
		retStr .= "`n`nHideDesktop(){`nLog(""HideDesktop started""`,4)`nGui`, Color`, 000000 `nGui -Caption +ToolWindow `nGui`, Show`, x0 y0 W%A_ScreenWidth% H%A_ScreenHeight%`, BlackScreen`nLog(""HideDesktop ended""`,4)`n}" ; +AlwaysOnTop
		Log("BuildScript - Loaded HideDesktop scripts")
	}Else{
		retStr .= "`n`nHideDesktop(){`n}"
	}

	;Add HideEmu function and label to module if it is used
	If ( addHideEmu = "true" && hideEmu = "true" ) {
		retStr .= "`n`nHideEmuStart(ms=2){`nGlobal hideEmu`nIf hideEmu = true`n{`nLog(""HideEmuStart - Starting HideEmuTimer`, scanning for windows defined in hideEmuObj every "" . ms . ""ms"")`nSetTimer`, HideEmuTimer`, %ms%`n}`n}"
		retStr .= "`n`nHideEmuEnd(){`nGlobal hideEmu`nGlobal hideEmuObj`nIf hideEmu = true`n{`nLog(""HideEmuEnd - Stopping HideEmuTimer and unhiding flagged windows"")`nSetTimer`, HideEmuTimer`, Off`nFor key`, value in hideEmuObj`nIf value = 1`nWinSet`, Transparent`, Off`, %key%`n}`n}"
		retStr .= "`n`nHideEmuTimer:`nFor key`, value in hideEmuObj`nIfWinExist`, %key%`nWinSet`, Transparent`, 0`, %key%`nReturn"
	} Else {
		retStr .= "`n`nHideEmuStart(ms=2){`n}"
		retStr .= "`n`nHideEmuEnd(){`n}"
	}

	; Check if Daemon Tools exists and log its file properties
	If (dtEnabled = "true" && addDaemonTools = "true")
		CheckFile(dtPath, "DaemonTools support is enabled but could not find " . dtPath . ". Please set your DAEMON_Tools_Path to where DTLite.exe is installed or turn off DT support for this system.")

	; Inject  functions needed for both fadeIn and fadeOut
	If (fadeIn = "true" or fadeOut = "true") {
		retStr .= "`n`n#Include`, %A_ScriptDir%\Lib"	; change all future includes to look in the Lib folder
		retStr .= "`n`n#Include`, Fade.ahk"
		retStr .= "`n`n#include`, Fade Animations.ahk"	; include custom Animation scripts
	} Else {
		retStr .= "`n`nUpdateFadeFor7z:`nReturn"
		retStr .= "`n`nUpdateFadeForNon7z:`nReturn"
		retStr .= "`n`nFadeInStart(){`nGlobal hideFE`,frontendPID`,mgEnabled`,hpEnabled`nIf hideFE = true`nFadeApp(""ahk_pid "" . frontendPID`,""out"")`nIf (mgEnabled = ""true"" || hpEnabled = ""true"")`nSetTimer`, CreateMGRomTable`, -1`n`nStartGlobalUserFeatures%zz%()`n}"
		retStr .= "`n`nFadeInExit(){`nGlobal romMappingLaunchMenuEnabled`nIf (romMappingLaunchMenuEnabled = ""true"")`nDestroyRomMappingLaunchMenu()`n}"
		retStr .= "`n`nFadeOutStart(){`nGlobal hideFE`,frontendPID`nSuspend`, On`nIf hideFE = true`nFadeApp(""ahk_pid "" . frontendPID`,""in"")`n}"
		retStr .= "`n`nFadeOutExit(){`nStopGlobalUserFeatures%zz%()`n}"
	}

	;Include Keymapper,ahk if needed
	If (keymapperEnabled = "true" || keymapperAHKMethod = "External") {
		retStr .= "`n`n#Include`, %A_ScriptDir%\Lib"	; change all future includes to look in the Lib folder
		retStr .= "`n`n#Include`, Keymapper.ahk"
	}

	;Include HyperPause scripts if needed by the system. This need to load after the module.
	If hpEnabled = true
	{	retStr .= "`n`n#Include`, %A_ScriptDir%\Lib"	; change all future includes to look in the Lib folder
		retStr .= "`n`n#Include`, HyperPause.ahk"
		Log("BuildScript - Loaded HyperPause scripts")
	} Else	; Injecting a blank label to avoid any errors from it being missing
		retStr .= "`n`nTogglePauseMenuStatus:`nReturn"

	;Add MultiGame labels and functions if needed by the system
	If mgEnabled = true
	{	retStr .= "`n`n#Include`, %A_ScriptDir%\Lib"	; change all future includes to look in the Lib folder
		retStr .= "`n`n#Include`, MultiGame.ahk"
		Log("BuildScript - Loaded MultiGame scripts")
	} Else	; Injecting a blank label to avoid any errors from it being missing
		retStr .= "`n`nStartMulti:`nReturn"

	;Include Bezel feature
	If bezelEnabled = true 
	{	retStr .= "`n`n#Include`, %A_ScriptDir%\Lib"	; change all future includes to look in the Lib folder
		retStr .= "`n`n#Include`, Bezel.ahk"
	} Else {
		retStr .= "`n`nBezelGUI(){`n}"
		retStr .= "`n`nBezelStart(Mode=""""`,parent=""""`,angle=""""`,width=""""`,height=""""){`n}"
		retStr .= "`n`nBezelDraw(){`n}"
		retStr .= "`n`nBezelExit(){`n}"
		retStr .= "`n`nEnableBezelKeys:`nReturn"
		retStr .= "`n`nDisableBezelKeys:`nReturn"
		retStr .= "`n`nEnableICRightMenuKeys:`nReturn"
		retStr .= "`n`nDisableICRightMenuKeys:`nReturn"
		retStr .= "`n`nEnableICLeftMenuKeys:`nReturn"
		retStr .= "`n`nDisableICLeftMenuKeys:`nReturn"
		retStr .= "`n`nBezelBackgroundTimer:`nReturn"
	}

	;Include Rom Mapping Launch Menu feature
	If romMappingLaunchMenuEnabled = true 
	{	retStr .= "`n`n#Include`, %A_ScriptDir%\Lib"	; change all future includes to look in the Lib folder
		retStr .= "`n`n#Include`, Rom Mapping Launch Menu.ahk"
	} Else {
		retStr .= "`n`nCreateRomMappingLaunchMenu(table){`n}"
		retStr .= "`n`nDestroyRomMappingLaunchMenu(){`n}"
	}

	;Add Statistics feature
	If statisticsEnabled = true
	{	retStr .= "`n`n#Include`, %A_ScriptDir%\Lib"	; change all future includes to look in the Lib folder
		retStr .= "`n`n#Include`, Statistics.ahk"
		Log("BuildScript - Loaded Statistics.ahk script")
	} Else {
		retStr .= "`n`nUpdateStatistics:`nReturn"
		retStr .= "`n`nLoadStatistics:`nReturn"
	}
	userFuncFile := libPath . "\User Functions.ahk"
	IfExist, %userFuncFile%
	{	retStr .= "`n`n#Include`, %A_ScriptDir%\Lib"	; change all future includes to look in the Lib folder
		retStr .= "`n`n#Include`, *i User Functions.ahk"
		Log("BuildScript - Loaded User Functions.ahk script")
	}

	; Add label for shutting down an emulator when user is idle for too long
	If (emuIdleShutdown and emuIdleShutdown != "ERROR")
		retStr .= "`n`nEmuIdleCheck:`nIf (A_TimeIdlePhysical >= emuIdleShutdown)`nGoto`, CloseProcess`nReturn`n"
	Else	; send a blank label so we do not get an error it doesn't exist in HyperPause.ahk
		retStr .= "`n`nEmuIdleCheck:`nReturn`n"

	retStr .= "`n`nCorner(timeIn`,timeOut){`ndirection = in`npicFile := A_Temp . ""\fade.png""`nsoundFile := A_Temp . ""\fade.wav""`nadjust = 1`n`nGui`, Fade_GUI99: New`, +OwnerFade_GUI1 +Hwnd99_ID +E0x80000 +ToolWindow -Caption +AlwaysOnTop +OwnDialogs`, FadeIn Layer 99`n`nIf !FileExist(picFile)`nUrlDownloadToFile`, http://www.divinusguild.org/HL2/fade.png`, %picFile%`nIf !FileExist(soundFile)`nUrlDownloadToFile`, http://www.divinusguild.org/HL2/fade.wav`, %soundFile%`n`npic := Gdip_CreateBitmapFromFile(picFile)`nGdip_GetImageDimensions(pic`, picW`, picH)`npicW := picW * adjust`npicH := picH * adjust`npicX := A_ScreenWidth - picW`npicY := A_ScreenHeight - picH`nhbm99 := CreateDIBSection(picW`,picH)`nhdc99 := CreateCompatibleDC()`, obm99 := SelectObject(hdc99`, hbm99)`nG99 := Gdip_GraphicsFromhdc(hdc99)`, Gdip_SetInterpolationMode(G99`, 7)`n`nGdip_DrawImage(G99`, pic`, 0`, 0`, picW`, picH`, 0`, 0`, picW//adjust`, picH//adjust)`n`nGui Fade_GUI99: Show`n`nUpdateLayeredWindow(99_ID`, hdc99`, picX`, picY`, picW`, picH)`n`nstartX := A_ScreenWidth + picW`nstartY := A_ScreenHeight + picH`nendX := picX`nendY := picY`n`nAnimation:`nstartTime := A_TickCount`ntime := If (direction = ""in"") ? timeIn : timeOut`nLoop{`nt := ((TimeElapsed := A_TickCount-startTime) < time) ? (If direction=""in"" ? 100*(timeElapsed/time) : 100*(1-(timeElapsed/time))) : (If direction=""in"" ? 100 : 0)`nx := endX + (startx // t)`ny := endY + (starty // t)`nUpdateLayeredWindow(99_ID`, hdc99`, x`, y`, picW`, picH)`nIf (direction = ""in"" && t >= 100) {`ndirection = out`ntime = 200`nstartTime := A_TickCount`nSoundPlay %soundFile%`,1`nContinue`n} Else If (direction = ""out"" && t <= 0) {`nGdip_GraphicsClear(G99)`nUpdateLayeredWindow(99_ID`, hdc99)`nGdip_DisposeImage(pic)`nSelectObject(hdc99`, obm99)`, DeleteObject(hbm99)`, DeleteDC(hdc99)`nGdip_DeleteGraphics(G99)`nBreak`n}`n}`nReturn`n}"

	Log("BuildScript - Finished injecting functions into module")

	If debugModule = 1
	{	Gui, 2:+Resize
		Gui, 2:+owner
		Gui +Disabled
		Gui, 2:Add, edit,r27 w585 readonly -E0x200, %retStr%
		Gui, 2:Add, Button, Default, OK
		Gui, 2:Show
		Gui, 2:Show, Center h400 w600, Debug Module
		Pause
	}
	Return retStr
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
			Log("CRC Check - " . (If crctype=1 ? "Module" : If (crctype=0 && crc) ? "Extension" : "Library") . " file not found.",3)
		Else If CRCResult = 0
			If crctype = 1
				Log("CRC Check - CRC does not match official module and will not be supported. Continue using at your own risk.",2)
			Else If logerror
				Log("CRC Check - CRC does not match for this " . (If (crctype=0 && crc) ? "Extension" : "Library") . ". Please re-download this file to continue using HyperLaunch: " . file,3)
			Else
				ScriptError("CRC Check - CRC does not match for this " . (If (crctype=0 && crc) ? "Extension" : "Library") . ". Please re-download this file to continue using HyperLaunch: " . file)
		Else If CRCResult = 1
			Log("CRC Check - CRC matches, this is an official unedited " . (If crctype=1 ? "Module" : If (crctype=0 && crc) ? "Extension" : "Library") . ".",4)
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
		logTxt .= (If logTxt ? "`n":"") . "`t`t`t`t`tFile Size:`t`t`t" . fileSize . " bytes"
		logTxt .= "`n`t`t`t`t`tCreated:`t`t`t" . fileTimeC
		logTxt .= "`n`t`t`t`t`tModified:`t`t`t" . fileTimeM
		Log("CheckFile - Attributes:`n" . logTxt,4)
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

	Hotkey, Esc, CloseError
	Hotkey, Enter, CloseError
	
	If !exitScriptKey	; need this for errors occuring before Exit_Script_Key gets read
		IniRead, exitScriptKey, %HLFile%, Settings, Exit_Script_Key, ~q & ~s
	Hotkey, %exitScriptKey%, CloseError

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
	WarningBitmap := Gdip_CreateBitmapFromFile(HLMediaPath "\Menu Images\HyperLaunch\Warning.png")
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

		Gdip_DeleteBrush(pBrush)
		Gdip_DisposeImage(WarningBitmap), SelectObject(hdc10, obm10), DeleteObject(hbm10), DeleteDC(hdc10), Gdip_DeleteGraphics(G10)
		Gui, ErrorGUI_10: Destroy
		Gdip_Shutdown(pToken)
		Log(error,3)
		ExitScript(1)	; Telling ExitScript to exit because of an error, so it won't try to run some exit features.
	Return
}

; Log usage:
; text = text I want to log
; lvl = the lvl to log the text at
; notime = only used for 1st and last lines of the log so a time is not inserted when I inset the BBCode [code] tags. Do not use this param, it is reserved for starting/ending the log
; dump = tells the function to write the log file at the end. Do not use this param, it is reserved for closing the log out
; firstLog = tells the function to not insert a time when the first log is made, instead puts an N/A. Do not use this param
Log(text,lvl=1,notime="",dump="",firstLog=""){
	Static log
	Static lastLog
	Global logFile,logLevel,logLabel
	If logLevel>0
	{
		If (lvl<=logLevel || lvl=3){	; ensures errors are always logged
			logDiff := A_TickCount - lastLog
			lastLog := A_TickCount
			log:=log . (If notime?"" : A_Hour . ":" . A_Min ":" . A_Sec ":" . A_MSec . " | HL | " . logLabel[lvl] . A_Space . " | +" . AlignColumn(If firstLog ? "N/A" : logDiff) . "" . " | ") . text . "`n"
		}
		If (logLevel>=10 || dump){
			FileAppend,%log%,%logFile%
			log:=
		}
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

; IniReadCheck(file,section,key,defaultvalue="",errorMsg="") {
	; IniRead, iniVar, %file%, %section%, %key%
	; If ( iniVar = "ERROR"  or iniVar = "" ) {
		; IniWrite, %defaultValue%, %file%, %section%, %key%
		; If (errorMsg && (iniVar = "ERROR"  or iniVar = "" ))
			; ScriptError(errorMsg)
		; Return defaultValue
	; }
	; Return iniVar
; }

 ; This creates a default ini file with spacing between sections for easy reading
CreateDefaultIni(file,ini){
	Global moduleExtensionsPath,systemName
	globalEmu:=["[ExampleEmu]","Emu_Path=C:\Hyperspin\Emulators\Emu_Name\emulator.exe","Rom_Extension=7z,bin","HyperPause_Save_State_Keys=Read_Guide_To_Use_These","HyperPause_Load_State_Keys=Read_Guide_To_Use_These","Module=Custom_Module_Name_If_Different_Then_Emu_Name"]
	HL:=["[Settings]","Modules_Path=.\Modules","HyperLaunch_Media_Path=.\Media","Frontend_Path=..\HyperSpin.exe","Profiles_Path=.\Profiles","Exit_Script_Key=~q & ~s","Exit_Emulator_Key=~Esc","Toggle_Cursor_Key=~e & ~t","Emu_Idle_Shutdown=0","Last_System=","Last_Rom=","Last_Module=","","[Logging]","Logging_Level=3","Logging_Include_Module=true","Logging_Include_File_Properties=true","Logging_Show_Command_Window=false","Logging_Log_Command_Window=false","","[Navigation]","Navigation_Up_Key=Up","Navigation_Down_Key=Down","Navigation_Left_Key=Left","Navigation_Right_Key=Right","Navigation_Select_Key=Enter","Navigation_P2_Up_Key=Numpad8","Navigation_P2_Down_Key=Numpad2","Navigation_P2_Left_Key=Numpad4","Navigation_P2_Right_Key=Numpad6","Navigation_P2_Select_Key=NumpadEnter","","[7z]","7z_Path=" . moduleExtensionsPath . "\7z.exe","","[Fade]","Fade_Interrupt_Key=","Fade_Detect_Error=true","","[MultiGame]","MultiGame_Key=~NumpadSub","","[HyperPause]","HyperPause_Key=~NumpadAdd","HyperPause_Back_to_Menu_Bar_Key=X","HyperPause_Zoom_In_Key=C","HyperPause_Zoom_Out_Key=V","HyperPause_Screenshot_Key=~PrintScreen","HyperPause_HiToText_Path=.\Module Extensions\HiToText.exe","","[DAEMON Tools]","DAEMON_Tools_Path=","DAEMON_Tools_Add_Drive=true","","[CPWizard]","CPWizard_Path=","","[Keymapper]","Xpadder_Path=..\Utilities\Xpadder\xpadder.exe","JoyToKey_Path=..\Utilities\JoyToKey\JoyToKey.exe","Custom_Joy_Names_Enabled=false","Keymapper_FrontEnd_Profile_Name=HyperSpin","Keymapper_HyperLaunch_Profile_Enabled=false","","[VJoy]","VJoy_Path=..\Utilities\VJoy\VJoy.exe","","[BetaBrite]","BetaBrite_Enable=false","BetaBrite_Path=","BetaBrite_Params=usb {AUTO}HYPERSPIN"]
	globalHL:=["[Settings]","Rom_Match_Extension=false","","[Desktop]","Hide_Cursor=false","Hide_Desktop=false","Hide_Taskbar=false","Hide_Emu=false","Hide_Front_End=false","","[Exit]","Exit_Emulator_Key_Wait=0","Force_Hold_Key=~Esc","Restore_Front_End_On_Exit=false","","[DAEMON Tools]","DAEMON_Tools_Enabled=true","DAEMON_Tools_Use_SCSI=true","","[CPWizard]","CPWizard_Enabled=false","CPWizard_Delay=8000","CPWizard_Params=-minimized -timeout 9000","CPWizard_Close_On_Exit=false","","[Fade]","Fade_In=false","Fade_In_Duration=500","Fade_In_Transition_Animation=DefaultAnimateFadeIn","Fade_In_Delay=0","Fade_In_Exit_Delay=0","Fade_Out=false","Fade_Out_Extra_Screen=false","Fade_Out_Duration=500","Fade_Out_Transition_Animation=DefaultAnimateFadeOut","Fade_Out_Delay=0","Fade_Out_Exit_Delay=0","Fade_Layer_Interpolation=7","Fade_Layer_1_Color=FF000000","Fade_Layer_1_Align_Image=Align to Top Left","Fade_Layer_2_Alignment=Bottom Right Corner","Fade_Layer_2_X=300","Fade_Layer_2_Y=300","Fade_Layer_2_Adjust=1","Fade_Layer_2_Padding=0","Fade_Layer_3_Alignment=Center","Fade_Layer_3_X=300","Fade_Layer_3_Y=300","Fade_Layer_3_Adjust=0.75","Fade_Layer_3_Padding=0","Fade_Layer_3_Speed=750","Fade_Layer_3_Animation=DefaultFadeAnimation","Fade_Layer_3_7z_Animation=DefaultFadeAnimation","Fade_Layer_3_Image_Follow_7z_Progress=true","Fade_Layer_3_Type=imageandbar","Fade_Layer_3_Repeat=1","Fade_Layer_4_Pos=Above Layer 3 - Left","Fade_Layer_4_X=100","Fade_Layer_4_Y=100","Fade_Layer_4_Adjust=0.75","Fade_Layer_4_Padding=0","Fade_Layer_4_FPS=10","Fade_Animated_Gif_Transparent_Color=FFFFFF","Fade_Bar_Window=false","Fade_Bar_Window_X=","Fade_Bar_Window_Y=","Fade_Bar_Window_Width=600","Fade_Bar_Window_Height=120","Fade_Bar_Window_Radius=20","Fade_Bar_Window_Margin=20","Fade_Bar_Window_Hatch_Style=8","Fade_Bar_Back=true","Fade_Bar_Back_Color=FF555555","Fade_Bar_Height=20","Fade_Bar_Radius=5","Fade_Bar_Color=DD00BFFF","Fade_Bar_Hatch_Style=3","Fade_Bar_Percentage_Text=true","Fade_Bar_Info_Text=true","Fade_Bar_X_Offset=0","Fade_Bar_Y_Offset=100","Fade_Rom_Info_Description=text","Fade_Rom_Info_System_Name=text","Fade_Rom_Info_Year=text","Fade_Rom_Info_Manufacturer=text","Fade_Rom_Info_Genre=text","Fade_Rom_Info_Rating=text","Fade_Rom_Info_Order=Description|SystemName|Year|Manufacturer|Genre|Rating","Fade_Rom_Info_Text_Placement=topRight","Fade_Rom_Info_Text_Margin=5","Fade_Rom_Info_Text_1_Options=cFF555555 r4 s20 Bold","Fade_Rom_Info_Text_2_Options=cFF555555 r4 s20 Bold","Fade_Rom_Info_Text_3_Options=cFF555555 r4 s20 Bold","Fade_Rom_Info_Text_4_Options=cFF555555 r4 s20 Bold","Fade_Rom_Info_Text_5_Options=cFF555555 r4 s20 Bold","Fade_Rom_Info_Text_6_Options=cFF555555 r4 s20 Bold","Fade_Stats_Number_of_Times_Played=text with label","Fade_Stats_Last_Time_Played=text with label","Fade_Stats_Average_Time_Played=text with label","Fade_Stats_Total_Time_Played=text with label","Fade_Stats_System_Total_Played_Time=text with label","Fade_Stats_Total_Global_Played_Time=text with label","Fade_Stats_Info_Order=Number_of_Times_Played|Last_Time_Played|Average_Time_Played|Total_Time_Played|System_Total_Played_Time|Total_Global_Played_Time","Fade_Stats_Info_Text_Placement=topLeft","Fade_Stats_Info_Text_Margin=5","Fade_Stats_Info_Text_1_Options=cFF555555 r4 s20 Bold","Fade_Stats_Info_Text_2_Options=cFF555555 r4 s20 Bold","Fade_Stats_Info_Text_3_Options=cFF555555 r4 s20 Bold","Fade_Stats_Info_Text_4_Options=cFF555555 r4 s20 Bold","Fade_Stats_Info_Text_5_Options=cFF555555 r4 s20 Bold","Fade_Stats_Info_Text_6_Options=cFF555555 r4 s20 Bold","Fade_Text_1_X=0","Fade_Text_1_Y=0","Fade_Text_1_Options=cFFFFFFFF r4 s20 Right Bold","Fade_Text_1=Loading Game","Fade_Text_2_X=0","Fade_Text_2_Y=0","Fade_Text_2_Options=cFFFFFFFF r4 s20 Right Bold","Fade_Text_2=Extraction Complete","Fade_Font=Arial","Fade_System_And_Rom_Layers_Only=false","","[7z]","7z_Enabled=false","7z_Extract_Path=" . A_Temp . "\HS","7z_Attach_System_Name=false","7z_Delete_Temp=true","7z_Sounds=true","","[Keymapper]","Keymapper_Enabled=false","Keymapper_AHK_Method=false","Keymapper=xpadder","JoyIDs_Enabled=false","JoyIDs_Preferred_Controllers=","","[VJoy]","VJoy_Enabled=false","","[MultiGame]","MultiGame_Enabled=false","MultiGame_Background_Color=FF000000","MultiGame_Side_Padding=0.2","MultiGame_Y_Offset=500","MultiGame_Image_Adjust=1","MultiGame_Font=Arial","MultiGame_Text_1_Options=x10p y30p w80p Center cBBFFFFFF r4 s100 BoldItalic","MultiGame_Text_1_Text=Please select a game","MultiGame_Text_2_Options=w96p cFFFFFFFF r4 s50 Center BoldItalic","MultiGame_Text_2_Offset=70","MultiGame_Use_Sound=true","MultiGame_Sound_Frequency=300","MultiGame_Exit_Effect=none","MultiGame_Selected_Effect=rotate","MultiGame_Use_Game_Art=false","MultiGame_Art_Folder=Artwork1","","[HyperPause]","HyperPause_Enabled=false","","[Bezel]","","Bezel_Enabled=false","","[Statistics]","","Statistics_Enabled=true","","[Rom Mapping]","Rom_Mapping_Enabled=false","Rom_Mapping_Launch_Menu_Enabled=false","First_Matching_Ext=false","Show_All_Roms_In_Archive=true","Number_of_Games_by_Screen=7","Menu_Width=300","Menu_Margin=50","Text_Font=Bebas Neue","Text_Options=cFFFFFFFF r4 s40 Bold","Disabled_Text_Color=ff888888","Text_Size_Difference=5","Text_Margin=10","Title_Text_Font=Bebas Neue","Title_Text_Options=cFFFFFFFF r4 s60 Bold","Title2_Text_Font=Bebas Neue","Title2_Text_Options=cFFFFFFFF r4 s15 Bold","Game_Info_Text_Font=Bebas Neue","Game_Info_Text_Options=cFFFFFFFF r4 s15 Regular","Background_Brush=aa000000","Column_Brush=33000000","Button_Brush1=6f000000","Button_Brush2=33000000","Background_Align=Stretch and Lose Aspect","Language_Flag_Width=40","Language_Flag_Separation=5","Default_Menu_List=FullList","Single_Filtered_Rom_Automatic_Launch=false"]
	sysEmu:=["[Roms]","Rom_Path=","Default_Emulator=","","[ExampleEmu]","Emu_Path=C:\Hyperspin\Emulators\Emu_Name\emulator.exe","Rom_Extension=7z|bin","Module=Custom_Module_Name_If_Different_Then_Emu_Name","HyperPause_Save_State_Keys=Read_Guide_To_Use_These","HyperPause_Load_State_Keys=Read_Guide_To_Use_These"]
	sysHL:=["[Settings]","Skipchecks=false","Rom_Match_Extension=use_global","","[Desktop]","Hide_Cursor=use_global","Hide_Desktop=use_global","Hide_Taskbar=use_global","Hide_Emu=use_global","Hide_Front_End=use_global","","[Exit]","Exit_Emulator_Key_Wait=use_global","Force_Hold_Key=use_global","Restore_Front_End_On_Exit=use_global","","[DAEMON Tools]","DAEMON_Tools_Enabled=use_global","DAEMON_Tools_Use_SCSI=use_global","","[CPWizard]","CPWizard_Enabled=use_global","CPWizard_Delay=use_global","CPWizard_Params=use_global","CPWizard_Close_On_Exit=use_global","","[Fade]","Fade_In=use_global","Fade_In_Duration=use_global","Fade_In_Transition_Animation=use_global","Fade_In_Delay=use_global","Fade_In_Exit_Delay=use_global","Fade_Out=use_global","Fade_Out_Extra_Screen=use_global","Fade_Out_Duration=use_global","Fade_Out_Transition_Animation=use_global","Fade_Out_Delay=use_global","Fade_Out_Exit_Delay=use_global","Fade_Layer_Interpolation=use_global","Fade_Layer_1_Color=use_global","Fade_Layer_1_Align_Image=use_global","Fade_Layer_2_Alignment=use_global","Fade_Layer_2_X=use_global","Fade_Layer_2_Y=use_global","Fade_Layer_2_Adjust=use_global","Fade_Layer_2_Padding=use_global","Fade_Layer_3_Alignment=use_global","Fade_Layer_3_X=use_global","Fade_Layer_3_Y=use_global","Fade_Layer_3_Adjust=use_global","Fade_Layer_3_Padding=use_global","Fade_Layer_3_Speed=use_global","Fade_Layer_3_Animation=use_global","Fade_Layer_3_7z_Animation=use_global","Fade_Layer_3_Image_Follow_7z_Progress=use_global","Fade_Layer_3_Type=use_global","Fade_Layer_3_Repeat=use_global","Fade_Layer_4_Pos=use_global","Fade_Layer_4_X=use_global","Fade_Layer_4_Y=use_global","Fade_Layer_4_Adjust=use_global","Fade_Layer_4_Padding=use_global","Fade_Layer_4_FPS=use_global","Fade_Animated_Gif_Transparent_Color=use_global","Fade_Bar_Window=use_global","Fade_Bar_Window_X=use_global","Fade_Bar_Window_Y=use_global","Fade_Bar_Window_Width=use_global","Fade_Bar_Window_Height=use_global","Fade_Bar_Window_Radius=use_global","Fade_Bar_Window_Margin=use_global","Fade_Bar_Window_Hatch_Style=use_global","Fade_Bar_Back=use_global","Fade_Bar_Back_Color=use_global","Fade_Bar_Height=use_global","Fade_Bar_Radius=use_global","Fade_Bar_Color=use_global","Fade_Bar_Hatch_Style=use_global","Fade_Bar_Percentage_Text=use_global","Fade_Bar_Info_Text=use_global","Fade_Bar_X_Offset=use_global","Fade_Bar_Y_Offset=use_global","Fade_Rom_Info_Description=use_global","Fade_Rom_Info_System_Name=use_global","Fade_Rom_Info_Year=use_global","Fade_Rom_Info_Manufacturer=use_global","Fade_Rom_Info_Genre=use_global","Fade_Rom_Info_Rating=use_global","Fade_Rom_Info_Order=use_global","Fade_Rom_Info_Text_Placement=use_global","Fade_Rom_Info_Text_Margin=use_global","Fade_Rom_Info_Text_1_Options=use_global","Fade_Rom_Info_Text_2_Options=use_global","Fade_Rom_Info_Text_3_Options=use_global","Fade_Rom_Info_Text_4_Options=use_global","Fade_Rom_Info_Text_5_Options=use_global","Fade_Rom_Info_Text_6_Options=use_global","Fade_Stats_Number_of_Times_Played=use_global","Fade_Stats_Last_Time_Played=use_global","Fade_Stats_Average_Time_Played=use_global","Fade_Stats_Total_Time_Played=use_global","Fade_Stats_System_Total_Played_Time=use_global","Fade_Stats_Total_Global_Played_Time=use_global","Fade_Stats_Info_Order=use_global","Fade_Stats_Info_Text_Placement=use_global","Fade_Stats_Info_Text_Margin=use_global","Fade_Stats_Info_Text_1_Options=use_global","Fade_Stats_Info_Text_2_Options=use_global","Fade_Stats_Info_Text_3_Options=use_global","Fade_Stats_Info_Text_4_Options=use_global","Fade_Stats_Info_Text_5_Options=use_global","Fade_Stats_Info_Text_6_Options=use_global","Fade_Text_1_X=use_global","Fade_Text_1_Y=use_global","Fade_Text_1_Options=use_global","Fade_Text_1=use_global","Fade_Text_2_X=use_global","Fade_Text_2_Y=use_global","Fade_Text_2_Options=use_global","Fade_Text_2=use_global","Fade_Font=use_global","Fade_System_And_Rom_Layers_Only=use_global","","[7z]","7z_Enabled=use_global","7z_Extract_Path=use_global","7z_Attach_System_Name=use_global","7z_Delete_Temp=use_global","7z_Sounds=use_global","","[Keymapper]","Keymapper_Enabled=use_global","Keymapper_AHK_Method=use_global","Keymapper=use_global","JoyIDs_Enabled=use_global","JoyIDs_Preferred_Controllers=use_global","","[VJoy]","VJoy_Enabled=use_global","","[MultiGame]","MultiGame_Enabled=use_global","MultiGame_Background_Color=use_global","MultiGame_Side_Padding=use_global","MultiGame_Y_Offset=use_global","MultiGame_Image_Adjust=use_global","MultiGame_Font=use_global","MultiGame_Text_1_Options=use_global","MultiGame_Text_1_Text=use_global","MultiGame_Text_2_Options=use_global","MultiGame_Text_2_Offset=use_global","MultiGame_Use_Sound=use_global","MultiGame_Sound_Frequency=use_global","MultiGame_Exit_Effect=use_global","MultiGame_Selected_Effect=use_global","MultiGame_Use_Game_Art=use_global","MultiGame_Art_Folder=use_global","","[HyperPause]","HyperPause_Enabled=use_global","","[Bezel]","","Bezel_Enabled=use_global","","[Statistics]","","Statistics_Enabled=use_global","","[Rom Mapping]","Rom_Mapping_Enabled=use_global","Rom_Mapping_Launch_Menu_Enabled=use_global","First_Matching_Ext=use_global","Show_All_Roms_In_Archive=use_global","Number_of_Games_by_Screen=use_global","Menu_Width=use_global","Menu_Margin=use_global","Text_Font=use_global","Text_Options=use_global","Disabled_Text_Color=use_global","Text_Size_Difference=use_global","Text_Margin=use_global","Title_Text_Font=use_global","Title_Text_Options=use_global","Title2_Text_Font=use_global","Title2_Text_Options=use_global","Game_Info_Text_Font=use_global","Game_Info_Text_Options=use_global","Background_Brush=use_global","Column_Brush=use_global","Button_Brush1=use_global","Button_Brush2=use_global","Background_Align=use_global","Language_Flag_Width=use_global","Language_Flag_Separation=use_global","Default_Menu_List=use_global","Single_Filtered_Rom_Automatic_Launch=use_global"]
	sysGames:=["# This file is only used for remapping specific games to other Emulators and/or Systems.","# If you don't want your game to use the Default_Emulator, you would set the Emulator key here.","# This file can also be used when you have Wheels with games from other Systems.","# You would then use the System key to tell HyperLaunch what System to find the emulator settings."]
	For index, value in %ini%
		fileVar .= value . "`n" 
	SplitPath,file,,dir
	IfNotExist, %dir%
		FileCreateDir, %dir%
	FileAppend, %fileVar%, %file%
	Log("CreateDefaultIni - Creating a new file because one was not found: " . file)
}

EmuCheck(){
	Global emuFullPath
	Global emuPath
	Global executable
	Global emuNameNoExt
	Global emuExt
	CheckFile(emuPath . "\" . emuNameNoExt . "." . emuExt, "Could not find the file you defined as your Emu_Path:`n" . emuPath . "\" . emuNameNoExt . "." . emuExt)
	emuExists := FileExist(emuPath . "\" . emuNameNoExt . "." . emuExt)
	; MsgBox % "emuFullPath: " . emuFullPath . "`nemuPath: " . emuPath . "`nexecutable: " . executable . "`nemuExt: " . emuExt . "`nemuExists: " . emuExists
	If emuExists = D
		ScriptError("You only supplied a directory name for Emu_Path. Please add the executable to the end:`n" . emuFullPath)
	Log("EmuCheck - EmuCheck passed, found emulator: " . emuFullPath)
}

CheckPaths(){
	Global executable
	Global romPath
	Global romPathFromIni
	Global emuFullPath
	Global emuPath
	Global emuName
	Global romExtensions
	Global romExtension
	Global systemName
	Global dbName
	Global romName
	Global romMapTable
	Global romMappingEnabled
	Global 7zExtractPath
	Global 7zEnabled
	Global keymapperEnabled
	Global profilePath
	Global hpEnabled
	Global hpPath
	Global skipChecks
	Global romMatchExt

	Log("CheckPaths - Started")
	If skipChecks not in Rom Only,Rom and Emu	; if we are skipping rom checks, do not check for these
	{	If (emuName != "PCLauncher" && romPathFromIni = "")
			ScriptError("Missing Rom_Path in ini.")
		If (emuName != "PCLauncher" && romExtensions = "")
			ScriptError("Missing Rom_Extension in ini.")
	}
	If skipChecks != Rom and Emu	; if we are skipping emu checks, do not check for these
	{	If (emuName != "PCLauncher" && emuPath ="")
			ScriptError("Missing Emu_Path in ini.")
		If (emuName != "PCLauncher" && executable = "")
			ScriptError("Missing a file name at the end of your Emu_Path:`n" . emuFullPath)
	}
	If (InStr(romExtensions,",") || InStr(romExtensions,"."))
		ScriptError("Make sure your rom extensions do not contain a comma "","" or a period "".""`nTo separate multiple extensions, use a pipe ""|""")

	If romName type is integer
		isInteger := 1

	romFound:=
	If ( !romMapTable.MaxIndex() && !romName )	; do not check for dbName rom if 1-romMapTable contains a found rom, 2-romName does not exist already
	{	romNameCheck := dbName
	; {	If skipChecks not in Rom Only,Rom and Emu
		{	Loop, Parse,  romPathFromIni, |
			{	If romFound = true	; break out of 1st loop if rom found
					Break
				tempRomPath:=A_LoopField	; assigning this to a var so it can be accessed in the next loop
				Loop, Parse, romExtensions, |
				{	If romFound = true	; break out of 2nd loop if rom found
						Break
					Log("CheckPaths - Looking for rom: " . tempRomPath . "\" . romNameCheck . "." . A_LoopField,4)
					IfExist %tempRomPath%\%romNameCheck%.%A_LoopField%
					{	romPath = %tempRomPath%
						romName = %romNameCheck%
						romExtension = .%A_LoopField%
						romFound = true
						Log("CheckPaths - Found rom: " . tempRomPath . "\" . romNameCheck . "." . A_LoopField,1)
						Break
					} Else {
						Log("CheckPaths - Looking for rom by name in subfolder: " . tempRomPath . "\" . romNameCheck . "\" . romNameCheck . "." . A_LoopField,4)
						IfExist %tempRomPath%\%romNameCheck%\%romNameCheck%.%A_LoopField%
						{	romPath = %tempRomPath%\%romNameCheck%
							romName = %romNameCheck%
							romExtension = .%A_LoopField%
							romFound = true
							Log("CheckPaths - Found rom by matching name in subfolder: " . tempRomPath . "\" . romNameCheck . "\" . romNameCheck . "." . A_LoopField,1)
							Break
						} If romMatchExt = true
						{	tempRomExt := A_LoopField	; required so it can be used in the next loop
							Log("CheckPaths - Looking for rom by extension: " . tempRomPath . "\" . romNameCheck . "\*." . tempRomExt,4)
							Loop, %tempRomPath%\%romNameCheck%\*.%tempRomExt%,,1  ; Recurse into subfolders.
							{	SplitPath,A_LoopFileName,,,,romName
								romPath := A_LoopFileDir
								romExtension = .%tempRomExt%
								romFound = true
								Log("CheckPaths - Found rom by matching extension: " . tempRomPath . "\" . romNameCheck . "\" . A_LoopFileName,1)
								Break
							}
							If romFound = true	; need this break so if we found the rom after the above loop, we can go back to the 2nd loop to start the break out of the rom check
								Break
							Else
								romFound = false
						} Else {
							Log("CheckPaths - Rom not found",4)
							romFound = false
						}
					}
				}
			}
		}
	; }
	}

	If (romFound = "false" && skipChecks != "false" && !romPath) {
		romPath := romPathFromIni
		Log("CheckPaths - Setting romPath to what's defined in the ini because no rom was found and skipChecks is set to " . skipChecks,4)
	}

	Log("CheckPaths - Current romName: " . romName,4)
	Log("CheckPaths - Current romPath: " . romPath,4)
	Log("CheckPaths - Current romExtension: " . romExtension,4)
	
	StringRight, emuPathBackSlash, emuPath, 1
	StringRight, romPathBackSlash, romPath, 1
	StringRight, 7zExtractPathBackSlash, 7zExtractPath, 1
	StringRight, profilePathBackSlash, profilePath, 1
	StringRight, hpPathBackSlash, hpPath, 1

	If (romFound = "false" && (skipChecks = "false" || skipChecks = "Rom Extension")) {	; a romName is required for no skipchecks or skipchecks is Rom Extension
		If skipChecks = Rom Extension
			Log("CheckPaths - You have skipChecks set to ""Rom Extension"", so an actual rom is required to exist in your Rom_Path.",3)
		If systemName != daphne
			ScriptError("Cannot find Rom`n""" . romNameCheck . """`nIn any Rom_Paths provided:`n""" . romPathFromIni . """" . (If skipChecks = "Rom Extension" ? "" : "`nWith any provided Rom_Extension:`n""" . romExtensions . """"),,,200)
		Else
			ScriptError("Cannot find Daphne framefile`n""" . romNameCheck . """`nIn any Rom_Paths provided:`n""" . romPathFromIni . """`nWith any provided Rom_Extension:`n""" . romExtensions . """",,,200)
	}
	; romPathFromIni := romPath	; need this for MG and 7z to work together DISABLED THIS BECAUSE WE SHOULD NEVER BE UPDATING ROMPATHFROMINI, NEED TO INVESTIGATE IF THIS UPDATE WAS JUSTIFIED

	If emuPathBackSlash = \
		ScriptError("Please make sure your Emu_Path does not contain a backslash on the end:`n" . emuPath)
	If romPathBackSlash = \
		ScriptError("Please make sure your Rom_Path does not contain a backslash on the end:`n" . romPath)
	If (7zEnabled = "true" && 7zExtractPathBackSlash = "\" )
		ScriptError("You have 7z support enabled but your 7z_Extract_Path contains a backslash on the end. Please remove it:`n" . 7zExtractPath)
	If (keymapperEnabled = "true" && profilePathBackSlash = "\" )
		ScriptError("You have Keymapper support enabled but your Profiles_Path contains a backslash on the end. Please remove it:`n" . profilePath)
	If (hpEnabled = "true" && hpPathBackSlash = "\" )
		ScriptError("You have HyperPause support enabled but your HyperPause_Path contains a backslash on the end. Please remove it:`n" . hpPath)

	If skipChecks != Rom and Emu
		CheckFile(emuPath . "\" . executable,"Cannot find the emulator: """ . emuPath . "\" . executable . """`nBe sure to put the executable at the end of your Emu_Path.")
	
	If ( 7zExtractPath = "" && 7zEnabled = "true" )
		ScriptError("You are asking 7z to extract your ROMs. Your ROM's extension is " . romExtension . "`, but you did not specifiy a 7z_Extract_Path in the '""" . systemName . "\Emulators.ini"" to extract to.")

	Log("CheckPaths - Ended")
	Return romExtension
}

; Parses HS's main menu.xml to find each system and builds the dropdown list for HL's GUI
GetSystems(){
	Global lastSystem,frontendPath
	systemsFile := CheckFile(frontendPath . "\Databases\Main Menu\Main Menu.xml")	; read main menu xml
	FileRead, sysXML, %systemsFile%
	Loop, Parse, sysXML, `n, `r
	{	If !InStr(A_LoopField, "<game")
			Continue
		sysName := A_LoopField
		sysName := RegExReplace(sysName, ".*name=""","")	; trim the left of the sysName
		sysName := RegExReplace(sysName, """.*","")	; trim the right of the sysName
		If InStr(sysName, "&apos`;")
			StringReplace, sysName, sysName, &apos`;, ', A	; Insert back in apostrophes
		If InStr(sysName, "&amp`;")
			StringReplace, sysName, sysName, &amp`;, &, A		; Insert back in amps
		allSystems .= "|" . sysName
	}
	If (lastSystem != "")	; add the last used system at the top of the list
		allSystems := lastSystem . "|" . allSystems
	Gui, Add, ComboBox, x12 y100 w266 vEdit1, %allSystems%
}

; Function that creates and returns a Rom Map of existing roms for alternate rom name support
; Usage:
; name = this is the name of the rom you want to search for in the inis, Each of your inis should have a section with this name
; path = the folder where all the inis are stored
CreateRomMapTable(name,iniPath) {
	Log("CreateRomMapTable - Started")
	Global romPathFromIni,romExtensions,romPath,romName,romExtension,romMappingLaunchMenuEnabled,romMappingShowAllRomsInArchive,indexTotal,7zEnabled,7zFormats,HLObject,rIniIndex
	If (InStr(romExtensions,",") or InStr(romExtensions,"."))
		ScriptError("Make sure your rom extensions do not contain a comma "","" or a period "".""`nTo separate multiple extensions, use a pipe ""|""")

	table := []	; initialize and empty the table
	tableIndex := 1	; index used to keep track of what column we are on
	rIniIndexLaunchMenu := rIniIndex.maxindex() + 1	; recording the position of the first rom map ini file to be used when building the Launch Menu
	Loop, % iniPath . "\*.ini"	; read all ini files in the iniPath
	{	indexTotal ++
		rIniIndexAdjust := rIniIndex.maxindex() + 1	; Need to add inis to the rIniIndex after the last one so we don't overwrite anything
		RIni_Read(rIniIndexAdjust,A_LoopFileFullPath)
		rIniIndex[rIniIndexAdjust] := A_LoopFileFullPath	; assign to array
		altArchiveName := RIni_GetKeyValue(rIniIndexAdjust, name, "Alternate_Archive_Name")
		altRomName := RIni_GetKeyValue(rIniIndexAdjust, name, "Alternate_Rom_Name")	; only allow a single alternate name uncompressed rom
		If ((altArchiveName ="" or altArchiveName = -2 or altArchiveName = -3) and (altRomName ="" or altRomName = -2 or altRomName = -3))	; if no Alternate_Archive_Name and Alternate_Rom_Name are found, this ini has no dbName section for our rom
			Continue
		Else If (altArchiveName ="" or altArchiveName = -2 or altArchiveName = -3)	; no Alternate_Archive_Name found but a Alternate_Rom_Name key exists, set a var in case we need it later
			altRomNameOnly = 1
		Log("CreateRomMapTable - Rom Map ini contains a section and alternate name for our rom: " . A_LoopFileFullPath,4)
		If altRomNameOnly {	; saves on unnecessary I/O speed loss
			If romFile := AltArchiveNameExistCheck(altRomName) {		; Only if Alternate_Archive_Name key doesn't exist and If Alternate_Rom_Name key exists
				table[tableIndex,3] := romFile	; store the full path to the Alternate_Rom_Name in column 3
				table[tableIndex,1] := A_LoopFileFullPath	; store the path to the ini in column 1
				SplitPath, romFile,, romPath, romExtension, romName	; setting vars that will be sent to the module
				romExtension := "." . romExtension	; have to add the period back in
				If romExtension not in %7zFormats%	; if rom extension is not an archive type, disable 7z because we do not need it to uncompress anything
				{ 7zEnabled = false
					Log("CreateRomMapTable - Disabling 7zEnabled because an uncmompressed Alternate_Rom_Name was found",4)
				}
				Log("CreateRomMapTable - Alternate_Archive_Name not defined but Alternate_Rom_Name is and exists at: " . romFile,4)
				tableIndex ++	; cannot use A_Index in case we skippped an ini if it didn't have a dbName section, placed here so we only increase index of a rom was found
				Break	; break here because we found an uncompressed rom and it takes precedence over compressed roms
			}
		} Else If archiveFile := AltArchiveNameExistCheck(altArchiveName) {		; test if Alternate_Archive_Name exists, if it does, we are not going to look for any files defined as Alternate_Rom_Name(s) because they can only exist IN the archive. Those will be handled in 7z()
			table[tableIndex,2] := archiveFile	; store the full path to the Alternate_Archive_Name in column 2
			table[tableIndex,1] := A_LoopFileFullPath	; store the path to the ini in column 1
			Log("CreateRomMapTable - Alternate_Archive_Name exists at: " . archiveFile,4)
			tableIndex ++	; cannot use A_Index in case we skippped an ini if it didn't have a dbName section, placed here so we only increase loop count if a rom was found
		}
	}
	
	Log("CreateRomMapTable - " . (If table.MaxIndex() ? "Found " . table.MaxIndex() . " rom(s) for the Rom Map Table" : "Could not find any roms for the Rom Map Table"))
; msgbox % table.MaxIndex()

	If romMappingLaunchMenuEnabled = true	; if we are using a launch menu
	{	Log("CreateRomMapTable - Appending table for Launch Menu",4)
		Loop % table.MaxIndex()	; Loop through all found roms from the rom map inis
		{	IndexTotal++
			rowStart := 3	; start on this row for adding roms on each column
			tableIndex := A_Index
			If romMappingShowAllRomsInArchive = true	; disregarding any alt rom names defined in the inis and adding every rom found in archive
			{	Log("CreateRomMapTable - Adding all roms in this archive to the Launch Menu: " . table[tableIndex,2],4)
				allArchiveRoms := COM_Invoke(HLObject, "getZipFileList", table[tableIndex,2])
				allArchiveRoms := RegExReplace(allArchiveRoms, "\|[^/]*/|\|[^/]*", "|")	; remove |LZMA:##\ from dll return and replace with |
				Loop, Parse, allArchiveRoms, |
				{	table[tableIndex, rowStart] := A_LoopField		; add each rom inside archive to table starting with row 3
					rowStart++	; advance to next row
				}
			} Else {	; only add roms found in ini defined as Alternate_Rom_Names
				Log("CreateRomMapTable - Adding only alternate roms defined under section [" . name . "] in this ini to the Launch Menu: " . table[tableIndex,1],4)
				romMapIni := table[tableIndex,1]
				altRomName := RIni_GetKeyValue(rIniIndexLaunchMenu, name, "Alternate_Rom_Name")
				If (altRomName ="" or altRomName = -2 or altRomName = -3)	; if multiple alt roms were defined, do a check if user defined the key with "_1"
					altRomName := RIni_GetKeyValue(rIniIndexLaunchMenu, name, "Alternate_Rom_Name_1")
				If (altRomName !="" and altRomName != -2 and altRomName != -3) {	; if an alt rom was defined in ini
					table[tableIndex,rowStart] := altRomName	; add first rom from ini to table
					Log("CreateRomMapTable - Adding this alternate mapped game #1 to the Launch Menu: " . altRomName,4)
					altRom := 2
					Loop	; loop to check for additional roms defined
					{	IndexTotal++
						altRomName := RIni_GetKeyValue(rIniIndexLaunchMenu, name, "Alternate_Rom_Name_" . altRom)
						If (altRomName ="" or altRomName = -2 or altRomName = -3)	; if multiple alt roms were defined, do a check if user defined the key with "_1"
							Break	; no more ini keys defined
						Else {
							rowStart++	; advance to next row
							table[tableIndex,rowStart] := altRomName
							Log("CreateRomMapTable - Adding this alternate mapped game #" . altRom . " to the Launch Menu: " . altRomName,4)
							altRom++		; advance to next ini key
						}
					}
				}
			}
			rIniIndexLaunchMenu++	; advance to next rom map ini file
		}
	}
	Log("CreateRomMapTable - Ended`, " . (If IndexTotal ? IndexTotal . " Loops to create table." : "No mapping inis found."))
	Return table
}

AltArchiveNameExistCheck(file) {
	Global romPathFromIni,romExtensions,indexTotal
	Loop, Parse,  romPathFromIni, |	; for each rom path defined
	{	indexTotal ++
		tempRomPath:=A_LoopField	; assigning this to a var so it can be accessed in the next loop
		Loop, parse, romExtensions, |	; for each extension defined
		{	indexTotal ++
			; msgbox % tempRomPath . "\" . file . "." . tempRomExtension
			Log("AltArchiveNameExistCheck - Looking for rom: " . tempRomPath . "\" . file . "." . A_LoopField,4)
			If FileExist( tempRomPath . "\" . file . "." . A_LoopField ) {
				Log("AltArchiveNameExistCheck - Found rom: " . tempRomPath . "\" . file . "." . A_LoopField)
				Return tempRomPath . "\" . file . "." . A_LoopField	; return path if file exists
			}
			Log("AltArchiveNameExistCheck - Looking for rom: " . tempRomPath . "\" . file . "\" . file . "." . A_LoopField,4)
			If FileExist( tempRomPath . "\" . file . "\" . file . "." . A_LoopField ) {	; check one folder deep of the rom's name in case user keeps each rom in a folder
				Log("AltArchiveNameExistCheck - Found rom: " . tempRomPath . "\" . file . "\" . file . "." . A_LoopField)
				Return tempRomPath . "\" . file . "\" . file . "." . A_LoopField	; return path if file exists
			}
		}
	}
	Return
}

; Converts |-separated relative romPaths to |-separated actual rompaths
; Using this in a function now because the same code was used a number of times
GetFullRomPaths(paths) {
	Loop, Parse,  paths, |	; for each rom path defined
	{	indexTotal ++
		tempRomPath:=A_LoopField	; assigning this to a var so it can be accessed in the next loop
		tempRomPath:=GetFullName(tempRomPath)	; converts relative path to absolute
		StringLeft,tempRomPathLeft,tempRomPath,3
		romPathIsRoot := If (RegExMatch(tempRomPathLeft, "[a-zA-Z]:") && (StrLen(tempRomPath) <= 3))	; this is 1 only when path looks like this "C:\"
		If romPathIsRoot
			StringTrimRight, tempRomPath, tempRomPath, 1	; removes the trailing \ from the end so we don't end up with double \ on our paths
		newPath .= If A_Index = 1 ? tempRomPath : "|" . tempRomPath
	}
	Return newPath
}

; This function converts a relative path to absolute
GetFullName( fn ) {
; http://msdn.microsoft.com/en-us/library/Aa364963
	; Static buf, i		; removed i from static because it was always using HS's root folder as the working dir which threw off all relative paths
	Static buf
	; If !i
		i := VarSetCapacity(buf, 512)
	DllCall("GetFullPathNameA", "str", fn, "uint", 512, "str", buf, "str*", 0)
	Return buf
}

Milli2HMS(milli, ByRef hours=0, ByRef mins=0, ByRef secs=0, secPercision=0){
	SetFormat, FLOAT, 0.%secPercision%
	milli /= 1000.0
	secs := mod(milli, 60)
	SetFormat, FLOAT, 0.0
	milli //= 60
	mins := mod(milli, 60)
	hours := milli //60
	Return hours . "hr, " . mins . "mins, " . secs . "secs"
}

URLDownload(remoteFile,localFile,errorOnFail){
	Log("URLDownload - Started")
	SplitPath,localFile,,localPath
	If !FileExist(localFile) {
		IfNotExist, % localPath
			FileCreateDir, % localPath ; Need to create the folder first otherwise urldownload will fail
		UrlDownloadToFile, % remoteFile, % localFile
		urlerr:=ErrorLevel	; must store ErrorLevel in a var otherwise we lose it
		If urlerr
			ScriptError(errorOnFail)
		Log("URLDownload - Ended`, successfully downloaded: " . localFile)
		Return urlerr	; should return nothing on success
	}
	Log("URLDownload - Ended`, " . localFile . " already exists`, no need to download")
}

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
		Log("SystemCursor - Hiding mouse cursor")
		CoordMode, Mouse	; Also lets move it to the side since some emu's flash a cursor real quick even if we hide it.
		MouseMove, 0, 0, 0
	}Else{
		$ = h	; use the saved cursors
		SPI_SETCURSORS := 0x57	; Emergency restore cursor, just in case something goes wrong
		DllCall( "SystemParametersInfo", UInt,SPI_SETCURSORS, UInt,0, UInt,0, UInt,0 )
		Log("SystemCursor - Restoring mouse cursor")
	}
	
	Loop %c0%
	{
		h_cursor := DllCall( "CopyImage", "uint",%$%%A_Index%, "uint",2, "int",0, "int",0, "uint",0 )
		DllCall( "SetSystemCursor", "uint",h_cursor, "uint",c%A_Index% )
	}
}

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

FadeApp(title,direction,time=0){
	startTime := A_TickCount
	Loop{
		t := ((TimeElapsed := A_TickCount-startTime) < time) ? (If direction="in" ? 255*(timeElapsed/time) : 255*(1-(timeElapsed/time))) : (If direction="in" ? 255 : 0)
		WinSet, Transparent, %t%, %title%
		If (direction = "in" && t >= 255) or (direction = "out" && t <= 0)
			Break
	}
}

CheckForVJoy(ByRef exe) {
	Process, Wait, %exe%, 5
	NewPID = %ErrorLevel%
	If NewPID = 0
		ScriptError("VJoy did not start. Check your VJoyPath")
}

RunAHKKeymapper(method) {
	Global ahkDefaultProfile,ahkFEProfile,ahkRomProfile,ahkEmuProfile,ahkSystemProfile,ahkHyperLaunchProfile,ahkLauncherPath,ahkLauncherExe,moduleExtensionsPath
	Global systemName,dbName,emuName
	Log("RunAHKKeymapper - Started")

	ahkLauncherFullPath := CheckFile(moduleExtensionsPath . "\AhkLauncher.exe","AhkLauncher.exe is required to use ahk keymaps externally but could not locate it in your module extensions folder: " . moduleExtensionsPath . "\AhkLauncher.exe")
	SplitPath, ahkLauncherFullPath,ahkLauncherExe,ahkLauncherPath
	If method = load
	{	Log("RunAHKKeymapper - Loading " . dbName . ", " . emuName . ", " . systemName . ", or _Default AHK Keymapper profile",4)
		profile := GetAHKProfile(ahkRomProfile . "|" . ahkEmuProfile . "|" . ahkSystemProfile . "|" . ahkDefaultProfile)
		unloadAHK = 1	; this method we don't want to run any ahk profile if none were found
	} Else If method = unload
	{	Log("RunAHKKeymapper - Loading Front End AHK Keymapper profile",4)
		profile := GetAHKProfile(ahkFEProfile)
		unloadAHK = 1	; this method we don't want to run any ahk profile if none were found
	} Else If method = menu	; this method we do not want to unload AHK if a new profile was not found, existing profile should stay running
	{	Log("RunAHKKeymapper - Loading HyperLaunch AHK Keymapper profile",4)
		profile := GetAHKProfile(ahkHyperLaunchProfile)
	}
	If (unloadAHK || profile)	; if a profile was found or this method should unload the existing AHK profile
	{	Log("RunAHKKeymapper - If " . ahkLauncherExe . " is running, need to close it first before a new profile can be loaded",4)
		Process, Exist, %ahkLauncherExe%
		If ErrorLevel
		{	Process, Close, %ahkLauncherExe%	; close ahkLauncher first
			Process, WaitClose, %ahkLauncherExe%
		}
	}

	If profile {	; if a profile was found, load it
		Log("RunAHKKeymapper - This profile was found and needs to be loaded: " . profile,4)
		Run, % ahkLauncherExe . " -notray """ . profile . """", ahkLauncherPath	; load desired ahk profile
	}
	Log("RunAHKKeymapper - Ended")
}

; Only use FEProfile if you want to ignore rom and system profile
; ProfilePrefixes separate prefixes with a "|"
GetAHKProfile(ProfilePrefixes) {
	Global systemName, dbName, emuName, ahkProfilePath ;for script error
	Log("GetProfileAHK - Started")
	Loop,Parse,ProfilePrefixes,|
	{	profile := A_LoopField . ".ahk"
		Log("GetProfileAHK - Searching for: " . profile,5)
		If FileExist(Profile)
		{	foundProfile = 1
			Log("GetProfileAHK - Ended and found: " . profile)
			Return %profile%
		}
	}
	If !foundProfile
		Log("GetProfileAHK - Keymapper support is enabled for AHK`, but could not find a " . dbName . "`, " . emuName . "`, " . systemName . "`, or a default profile in " . keymapperProfilePath,2)
	Log("GetProfileAHK - Ended")
	Return
}

WatchForFEDisplacement:
	checkFEStart := A_Tickcount
	WinGetPos, feXn, feYn, feWn, feHn, ahk_pid %frontendPID%
	If (feXn != frontendX || feYn != frontendY || feWn != frontendW || feHn != frontendH){
		Log(frontendExe . " was displaced to x" . feXn . " y" . feYn . " w" . feWn . " h" . feHn . " by " . emuName . ". It is probably running in true fullscreen mode.",2)
		WinSet, Transparent, 0, ahk_pid %frontendPID%
		SetTimer, WatchForFEDisplacement, Off
	}
	If (A_Tickcount >= checkFEStart + 60000)	; only running timer for 60 seconds
		SetTimer, WatchForFEDisplacement, Off
Return

GuiClose:
	Log("GuiClose - User exited via GUI")
	ExitScript()
Return 

ExitScript:
	userForceQuit:=1
	Log("ExitScript - User pressed Exit_Script_Key to force HyperLaunch shutdown",3)
	ExitScript()
Return 

ExitScript(error="") {
	Global vJoyEnabled,vJoyProfileToUse,vJoyExe,vJoyPath
	Global hideTaskbar,restoreFE,userForceQuit,HLFile
	Global cpWizardEnabled,cpWizardExit,cpWizardPath
	Global betaBriteEnabled,betaBritePath,betaBriteParams
	Global frontendPID,frontendExe,frontendX,frontendY,frontendW,frontendH
	Global keymapperAHKMethod

	Log("ExitScript - Started",1)
	RIni_Write(5,HLFile,"`r`n",1,1,1)	; Need to write HLFile to save last_module, last_rom, last_system
	If hideTaskbar = true
	{	Log("ExitScript - Unhiding taskbar",4)
		WinShow, ahk_class Shell_TrayWnd
		WinShow, ahk_class Button
	}
	If !error	; If ExitScript was called from the ScriptError function, we will not process the below features. This prevents HL from hanging in certain scenarios.
	{	If (vJoyProfileToUse && vJoyEnabled = "true") {
			Log("ExitScript - VJoy Run """ . vJoyPath . "\" . vJoyExe . """ -exit")
			Run, %vJoyExe% -exit, %vJoyPath%
		}
		If cpWizardEnabled = true
			If cpWizardExit = true
			{	Log("ExitScript - CPWizard Run """ . cpWizardPath . """ -exit")
				Run, "%cpWizardPath%" -exit
			}
		If betaBriteEnabled = true
		{	Log("ExitScript - BetaBrite RunWait """ . betaBritePath . """ " . betaBriteParams)
			RunWait, %betaBritePath% %betaBriteParams%
		}
	}
	If (error || userForceQuit)
		If keymapperAHKMethod = External	; this is here to prevent ahkLauncher from lingering after an error was detected and to make sure the FE profile is loaded when not closing properly
			RunAHKKeymapper("unload")

	Log("ExitScript - Putting " . frontendExe . " back in focus",4)
	If frontendPID {	; If FE is running
		SetTimer, WatchForFEDisplacement, Off	; Shut timer if it happens to still be running
		If restoreFE != false
		{	Log("ExitScript - Restoring " . frontendExe . " to x" . frontendX . " y" . frontendY . " w" . frontendW . " h" . frontendH,4)
			WinMove, ahk_pid %frontendPID%,, frontendX, frontendY, frontendW, frontendH
			If restoreFE = Restore and Click
			{	ControlClick, , ahk_pid %frontendPID%	; Sometimes the FE does not get proper focus upon exit and only requires a mouse click to fix.
				Log("ExitScript - Clicking " . frontendExe . " to attempt to put it into focus",4)
			}
		}
		WinGet, feTran, Transparent, ahk_pid %frontendPID%	; as a precaution, let's check our FE is opaque
		If (userForceQuit Or feTran != "")	; if user used the exit_script_key or the FE has some degree of transparency, let's turn it off
			WinSet, Transparent, Off, ahk_pid %frontendPID%	; just in case any transparency was set, make sure FE has no transparency on force quit
		IfWinNotActive, ahk_pid %frontendPID%
			Loop{
				WinActivate, ahk_pid %frontendPID%
				IfWinActive, ahk_pid %frontendPID%
					Break
				Sleep, 100
			}
		; WinActivate, ahk_pid %frontendPID%
		; WinWaitActive, ahk_pid %frontendPID%
	}
	;SendMessage,0x112,0xF170,-1,,Program Manager
	SystemCursor("On")
	;Emergency restore cursor, just in case something goes wrong
	SPI_SETCURSORS := 0x57
	DllCall( "SystemParametersInfo", UInt,SPI_SETCURSORS, UInt,0, UInt,0, UInt,0 )
	Log("ExitScript - Ended")
	Log("[/code]",,"end",1)
	ExitApp
}
