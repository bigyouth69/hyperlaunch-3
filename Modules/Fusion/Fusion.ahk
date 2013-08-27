MEmu = Fusion
MEmuV =  v3.64
MURL = http://www.eidolons-inn.net/tiki-index.php?page=Kega
MAuthor = djvj
MVersion = 2.0.2
MCRC = E561A2BA
iCRC = 99F6170B
MID = 635038268893895568
MSystem = "Samsung Gam Boy","Sega 32X","Sega CD","Sega Game Gear","Sega Genesis","Sega Master System","Sega Mega Drive","Sega Mega-CD","Sega SC-3000","Sega SG-1000"
;----------------------------------------------------------------------------
; Notes:
; Don't forget to setup your bios or you might just get a black screen.
; Set your fullscreen resolution by going to Video->Full Screen Resolution
; Fusion only supports 4 different windowed resolutions. If you don't use fullscreen, set the one you want by going to Video->Window Size
; Esc is Fusion's default key to go Fullscreen/Windowed mode. This cannot be changed, but this module will still close if you use Esc to exit. You may see the emu leave fullscreen first though.
; For Sega CD, make sure your cues are correctly pointing to all the tracks or else you will not get sound. Also turn off auto-play for CDs
;
; Sega CD
; Configure your Sega CD bios first by going to Options -> Set Config -> Sega CD
;
; Defining per-game controller types:
; In the module ini, set Controller_Reassigning_Enabled to true
; Default_P1_Controller and Default_P2_Controller should be set to the controller type you normally use for games not listed in the ini
; Make a new ini section with the name of your rom in your database, for example [Super Scope 6 (USA)]
; Under this section you can have 2 keys, P1_Controller and P2_Controller
; For P1_Controller - 0=None, 1=Gamepad, 2=Multitap, 3=Mouse, 4=Serial USART
; For P2_Controller - 0=None, 1=Gamepad, 2=Multitap, 3=Mouse, 4=Super Scope, 5=Justifier, 6=Dual Justifiers, 7=Serial USART
;----------------------------------------------------------------------------
StartModule()
; BezelGUI()
FadeInStart()

; The object controls how the module reacts to different systems. Fusion can play a lot of systems, but changes itself slightly so this module has to adapt 
mType := Object("Samsung Gam Boy","sms","Sega 32X","32X","Sega CD","scd","Sega Mega-CD","scd","Sega Game Gear","gg","Sega Genesis","gen","Sega Mega Drive","gen","Sega Master System","sms","Sega SC-3000","sms","Sega SG-1000","sms")
ident := mType[systemName]	; search 1st array for the systemName identifier mednafen uses
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this Fusion module: " . moduleName)

Log("Module - Started reading module ini")
settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
hideTitleBar := IniReadCheck(settingsFile, "Settings", "hideTitleBar","true",,1)	; Removes the border, titlebar, menubar, and centers the emu on your screen. Only need this if fullscreen is false
controllerReassigningEnabled := IniReadCheck(settingsFile, systemName, "Controller_Reassigning_Enabled","false",,1)
defaultGenP1Controller := IniReadCheck(settingsFile, systemName, "Default_Genesis_P1_Controller",2,,1)
defaultGenP1bController := IniReadCheck(settingsFile, systemName, "Default_Genesis_P1b_Controller",2,,1)
defaultGenP1cController := IniReadCheck(settingsFile, systemName, "Default_Genesis_P1c_Controller",2,,1)
defaultGenP1dController := IniReadCheck(settingsFile, systemName, "Default_Genesis_P1d_Controller",2,,1)
defaultGenP2Controller := IniReadCheck(settingsFile, systemName, "Default_Genesis_P2_Controller",2,,1)
defaultGenP2bController := IniReadCheck(settingsFile, systemName, "Default_Genesis_P2b_Controller",2,,1)
defaultGenP2cController := IniReadCheck(settingsFile, systemName, "Default_Genesis_P2c_Controller",2,,1)
defaultGenP2dController := IniReadCheck(settingsFile, systemName, "Default_Genesis_P2d_Controller",2,,1)
defaultSMSP1Controller := IniReadCheck(settingsFile, systemName, "Default_SMS_P1_Controller",1,,1)
defaultSMSP2Controller := IniReadCheck(settingsFile, systemName, "Default_SMS_P2_Controller",1,,1)
defaultGenP1Use := IniReadCheck(settingsFile, systemName, "Default_Genesis_P1_Use",1,,1)
defaultGenP1bUse := IniReadCheck(settingsFile, systemName, "Default_Genesis_P1b_Use",1,,1)
defaultGenP1cUse := IniReadCheck(settingsFile, systemName, "Default_Genesis_P1c_Use",1,,1)
defaultGenP1dUse := IniReadCheck(settingsFile, systemName, "Default_Genesis_P1d_Use",1,,1)
defaultGenP2Use := IniReadCheck(settingsFile, systemName, "Default_Genesis_P2_Use",1,,1)
defaultGenP2bUse := IniReadCheck(settingsFile, systemName, "Default_Genesis_P2b_Use",1,,1)
defaultGenP2cUse := IniReadCheck(settingsFile, systemName, "Default_Genesis_P2c_Use",1,,1)
defaultGenP2dUse := IniReadCheck(settingsFile, systemName, "Default_Genesis_P2d_Use",1,,1)
defaultSMSP1Use := IniReadCheck(settingsFile, systemName, "Default_SMS_P1_Use",1,,1)
defaultSMSP2Use := IniReadCheck(settingsFile, systemName, "Default_SMS_P2_Use",1,,1)
genP1Controller := IniReadCheck(settingsFile, romName, "Genesis_P1_Controller",,,1)
genP1bController := IniReadCheck(settingsFile, romName, "Genesis_P1b_Controller",,,1)
genP1cController := IniReadCheck(settingsFile, romName, "Genesis_P1c_Controller",,,1)
genP1dController := IniReadCheck(settingsFile, romName, "Genesis_P1d_Controller",,,1)
genP2Controller := IniReadCheck(settingsFile, romName, "Genesis_P2_Controller",,,1)
genP2bController := IniReadCheck(settingsFile, romName, "Genesis_P2b_Controller",,,1)
genP2cController := IniReadCheck(settingsFile, romName, "Genesis_P2c_Controller",,,1)
genP2dController := IniReadCheck(settingsFile, romName, "Genesis_P2d_Controller",,,1)
smsP1Controller := IniReadCheck(settingsFile, romName, "SMS_P1_Controller",,,1)
smsP2Controller := IniReadCheck(settingsFile, romName, "SMS_P2_Controller",,,1)
genP1Use := IniReadCheck(settingsFile, romName, "Genesis_P1_Use",,,1)
genP1bUse := IniReadCheck(settingsFile, romName, "Genesis_P1b_Use",,,1)
genP1cUse := IniReadCheck(settingsFile, romName, "Genesis_P1c_Use",,,1)
genP1dUse := IniReadCheck(settingsFile, romName, "Genesis_P1d_Use",,,1)
genP2Use := IniReadCheck(settingsFile, romName, "Genesis_P2_Use",,,1)
genP2bUse := IniReadCheck(settingsFile, romName, "Genesis_P2b_Use",,,1)
genP2cUse := IniReadCheck(settingsFile, romName, "Genesis_P2c_Use",,,1)
genP2dUse := IniReadCheck(settingsFile, romName, "Genesis_P2d_Use",,,1)
smsP1Use := IniReadCheck(settingsFile, romName, "SMS_P1_Use",,,1)
smsP2Use := IniReadCheck(settingsFile, romName, "SMS_P2_Use",,,1)
Log("Module - Finished reading module ini")

BezelStart("fixResMode")

fusionFile := CheckFile(emuPath . "\fusion.ini")
FileRead, fusionIni, %fusionFile%

7z(romPath, romName, romExtension, 7zExtractPath)

If romExtension in .7z,.rar
	ScriptError(MEmu . " only supports uncompressed or zip compressed roms. Please enable 7z support in HLHQ to use this module/emu.")

; Setting Fullscreen setting in cfg if it doesn't match what user wants above
currentFullScreen := (InStr(fusionIni, "FullScreen=1") ? ("true") : ("false"))


If ( Fullscreen != "true" And currentFullScreen = "true" ) {
	StringReplace, fusionIni, fusionIni, FullScreen=1, FullScreen=0
	If controllerReassigningEnabled != true	; no need to save file if it's going to be written later
		SaveFile(fusionIni, fusionFile)
} Else If ( Fullscreen = "true" And currentFullScreen = "false" ) {
	StringReplace, fusionIni, fusionIni, FullScreen=0, FullScreen=1
	If controllerReassigningEnabled != true	; no need to save file if it's going to be written later
		SaveFile(fusionIni, fusionFile)
}

hideEmu := (If Fullscreen = "true" ? ("Hide") : (""))
fullscreen := (If Fullscreen = "true" ? ("-fullscreen") : (""))

If bezelPath ; Setting windowed mode resolution
{	fusionini := regexreplace(fusionini,"GameGearZoom=0","GameGearZoom=1") ; disabling emulator default bezel
	If controllerReassigningEnabled != true	; no need to save file if it's going to be written later
		SaveFile(fusionIni, fusionFile)
}

 ; Allows you to set on a per-rom basis the controller type plugged into controller ports 1 and 2
If controllerReassigningEnabled = true
{	Log("Module - Started reassigning Fusion's ini controls")
	Loop, Parse, fusionIni, `n
		If InStr(A_LoopField,"Joystick1Type")
			newCfg .= "Joystick1Type=" . (If genP1Controller ? genP1Controller : defaultGenP1Controller) . "`r`n"	; sets controls for P1 to rom's P1 control type if exists, else sets to default P1 control type
		Else If InStr(A_LoopField,"Joystick1bType")
			newCfg .= "Joystick1bType=" . (If genP1bController ? genP1bController : defaultGenP1bController) . "`r`n"	; sets controls for P1b to rom's P1b control type if exists, else sets to default P1b control type
		Else If InStr(A_LoopField,"Joystick1cType")
			newCfg .= "Joystick1cType=" . (If genP1cController ? genP1cController : defaultGenP1cController) . "`r`n"	; sets controls for P1c to rom's P1c control type if exists, else sets to default P1c control type
		Else If InStr(A_LoopField,"Joystick1dType")
			newCfg .= "Joystick1dType=" . (If genP1dController ? genP1dController : defaultGenP1dController) . "`r`n"	; sets controls for P1d to rom's P1d control type if exists, else sets to default P1d control type
		Else If InStr(A_LoopField,"Joystick2Type")
			newCfg .= "Joystick2Type=" . (If genP2Controller ? genP2Controller : defaultGenP2Controller) . "`r`n"	; sets controls for P2 to rom's P2 control type if exists, else sets to default P2 control type
		Else If InStr(A_LoopField,"Joystick2bType")
			newCfg .= "Joystick2bType=" . (If genP2bController ? genP2bController : defaultGenP2bController) . "`r`n"	; sets controls for P2b to rom's P2b control type if exists, else sets to default P2b control type
		Else If InStr(A_LoopField,"Joystick2cType")
			newCfg .= "Joystick2cType=" . (If genP2cController ? genP2cController : defaultGenP2cController) . "`r`n"	; sets controls for P2c to rom's P2c control type if exists, else sets to default P2c control type
		Else If InStr(A_LoopField,"Joystick2dType")
			newCfg .= "Joystick2dType=" . (If genP2dController ? genP2dController : defaultGenP2dController) . "`r`n"	; sets controls for P2d to rom's P2d control type if exists, else sets to default P2d control type
		Else If InStr(A_LoopField,"Joystick1MSType")
			newCfg .= "Joystick1MSType=" . (If smsP1Controller ? smsP1Controller : defaultSMSP1Controller) . "`r`n"	; sets controls for sms P1 to rom's sms P1 control type if exists, else sets to default sms P1 control type
		Else If InStr(A_LoopField,"Joystick2MSType")
			newCfg .= "Joystick2MSType=" . (If smsP2Controller ? smsP2Controller : defaultSMSP2Controller) . "`r`n"	; sets controls for sms P2 to rom's sms P2 control type if exists, else sets to default sms P2 control type
		Else If InStr(A_LoopField,"Joystick1Using")
			newCfg .= "Joystick1Using=" . (If genP1Use ? genP1Use : defaultGenP1Use) . "`r`n"	; sets controls for P1 to rom's P1 control using if exists, else sets to default P1 control using
		Else If InStr(A_LoopField,"Joystick1bUsing")
			newCfg .= "Joystick1bUsing=" . (If genP1bUse ? genP1bUse : defaultGenP1bUse) . "`r`n"	; sets controls for P1b to rom's P1b control using if exists, else sets to default P1b control using
		Else If InStr(A_LoopField,"Joystick1cUsing")
			newCfg .= "Joystick1cUsing=" . (If genP1cUse ? genP1cUse : defaultGenP1cUse) . "`r`n"	; sets controls for P1c to rom's P1c control using if exists, else sets to default P1c control using
		Else If InStr(A_LoopField,"Joystick1dUsing")
			newCfg .= "Joystick1dUsing=" . (If genP1dUse ? genP1dUse : defaultGenP1dUse) . "`r`n"	; sets controls for P1d to rom's P1d control using if exists, else sets to default P1d control using
		Else If InStr(A_LoopField,"Joystick2Using")
			newCfg .= "Joystick2Using=" . (If genP2Use ? genP2Use : defaultGenP2Use) . "`r`n"	; sets controls for P2 to rom's P2 control using if exists, else sets to default P2 control using
		Else If InStr(A_LoopField,"Joystick2bUsing")
			newCfg .= "Joystick2bUsing=" . (If genP2bUse ? genP2bUse : defaultGenP2bUse) . "`r`n"	; sets controls for P2b to rom's P2b control using if exists, else sets to default P2b control using
		Else If InStr(A_LoopField,"Joystick2cUsing")
			newCfg .= "Joystick2cUsing=" . (If genP2cUse ? genP2cUse : defaultGenP2cUse) . "`r`n"	; sets controls for P2c to rom's P2c control using if exists, else sets to default P2c control using
		Else If InStr(A_LoopField,"Joystick2dUsing")
			newCfg .= "Joystick2dUsing=" . (If genP2dUse ? genP2dUse : defaultGenP2dUse) . "`r`n"	; sets controls for P2d to rom's P2d control using if exists, else sets to default P2d control using
		Else If InStr(A_LoopField,"Joystick1MSUsing")
			newCfg .= "Joystick1MSUsing=" . (If smsP1Use ? smsP1Use : defaultSMSP1Use) . "`r`n"	; sets controls for sms P1 to rom's sms P1 control using if exists, else sets to default sms P1 control using
		Else If InStr(A_LoopField,"Joystick2MSUsing")
			newCfg .= "Joystick2MSUsing=" . (If smsP2Use ? smsP2Use : defaultSMSP2Use) . "`r`n"	; sets controls for sms P2 to rom's sms P2 control using if exists, else sets to default sms P2 control using
		Else
			newCfg .= If A_LoopField = "" ? "" : A_LoopField . "`n"
	SaveFile(newCfg,fusionFile)
	Log("Module - Finished reassigning Fusion's ini controls")
}

; This allows us to send variables, that when empty, are not sent to the Run command
Run(executable . " -auto -" . ident . " " . fullscreen . " """ . romPath . "\" . romName . romExtension . """", emuPath, hideEmu)

WinWait("Fusion ahk_class KegaClass")
WinWaitActive("Fusion ahk_class KegaClass")

Loop { ; looping until Fusion is done loading game
	Sleep, 200
	WinGetTitle, winTitle, Fusion ahk_class KegaClass
	StringSplit, T, winTitle, %A_Space%
	If ( T3 = "-" )
		Break
}

If hideTitleBar = true
{	WinSet, Style, -0x40000, Fusion ahk_class KegaClass ; Removes the border of the game window
	WinSet, Style, -0xC00000, Fusion ahk_class KegaClass ; Removes the TitleBar
	DllCall("SetMenu", uint, WinActive( "A" ), uint, 0) ; Removes the MenuBar
	Center(Fusion ahk_class KegaClass)
}

BezelDraw()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


Center(title) {
	WinGetPos, X, Y, width, height, %title%
	x := ( A_ScreenWidth / 2 ) - ( width / 2 )
	y := ( A_ScreenHeight / 2 ) - ( height / 2 )
	WinMove, %title%, , x, y
}

SaveFile(text,file) {
	FileDelete, %file%
	FileAppend, %text%, %file%
}

CloseProcess:
	FadeOutStart()
	WinClose("Fusion ahk_class KegaClass")
Return
