MEmu = Fusion
MEmuV =  v3.64
MURL = http://www.eidolons-inn.net/tiki-index.php?page=Kega
MAuthor = djvj
MVersion = 2.0.5
MCRC = 38645830
iCRC = 7A5BD6E2
MID = 635038268893895568
MSystem = "Samsung Gam Boy","Sega 32X","Sega CD","Sega Game Gear","Sega Genesis","Sega Master System","Sega Mega Drive","Sega Mega-CD","Sega SC-3000","Sega SG-1000"
;----------------------------------------------------------------------------
; Notes:
; Don't forget to setup your bios or you might just get a black screen.
; Set your fullscreen resolution by going to Video->Full Screen Resolution
; Fusion only supports 4 different windowed resolutions. If you don't use fullscreen, set the one you want by going to Video->Window Size
; Esc is Fusion's default key to go Fullscreen/Windowed mode. This cannot be changed, but this module will still close if you use Esc to exit. You may see the emu leave fullscreen first though.
; Esc can also cause Fusion to change its fullscreen mode on exit, causing it to lockup for 5-10 seconds. The only fix for this is to not use Esc as your exit key.
; For Sega CD, make sure your cues are correctly pointing to all the tracks or else you will not get sound. Also turn off auto-play for CDs
;
; Sega CD
; Configure your Sega CD bios first by going to Options -> Set Config -> Sega CD
; Set the scsi drive you want to use manually by going to Options -> CD Drive and seleting the one that corresponds to your scsi drive in DT. A dt drive is not supported by the emu, it must be scsi.
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
BezelGUI()
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
useRamCarts := IniReadCheck(settingsFile, "Settings", "UseRamCarts","true",,1)
fluxAudioCD := IniReadCheck(settingsFile, "Settings", "FluxAudioCD",,,1)	; audio CD for use when Flux is ran
fluxAudioCD := GetFullName(fluxAudioCD)	; convert relative path to absolute
DTWaitTime := IniReadCheck(settingsFile, systemName, "DTWaitTime","0",,1)
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
perfectSync := IniReadCheck(settingsFile, romName, "PerfectSync","false",,1)
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

BezelStart()

fusionFile := CheckFile(emuPath . "\fusion.ini")
fusionIni := LoadProperties(fusionFile)	; load the config into memory
currentFullScreen := ReadProperty(fusionIni,"FullScreen")	; read current fullscreen state
currentPerfectSync := ReadProperty(fusionIni,"PerfectSync")	; read current PerfectSync state

7z(romPath, romName, romExtension, 7zExtractPath)

If romExtension in .7z,.rar
	ScriptError(MEmu . " only supports uncompressed or zip compressed roms. Please enable 7z support in HLHQ to use this module/emu for this extension: """ . romExtension . """")

If ( Fullscreen != "true" And currentFullScreen = "1" ) {
	WriteProperty(fusionIni,"FullScreen", 0)
	If controllerReassigningEnabled != true	; no need to save file if it's going to be written later
		SaveProperties(fusionFile,fusionIni)	; save fusionFile to disk
} Else If ( Fullscreen = "true" And currentFullScreen = "0" ) {
	WriteProperty(fusionIni,"FullScreen", 1)
	If controllerReassigningEnabled != true	; no need to save file if it's going to be written later
		SaveProperties(fusionFile,fusionIni)	; save fusionFile to disk
}

If ( perfectSync != "true" And currentPerfectSync = "1" ) {
	WriteProperty(fusionIni,"PerfectSync", 0)
	If controllerReassigningEnabled != true	; no need to save file if it's going to be written later
		SaveProperties(fusionFile,fusionIni)	; save fusionFile to disk
} Else If ( perfectSync = "true" And currentPerfectSync = "0" ) {
	WriteProperty(fusionIni,"PerfectSync", 1)
	If controllerReassigningEnabled != true	; no need to save file if it's going to be written later
		SaveProperties(fusionFile,fusionIni)	; save fusionFile to disk
}

hideEmu := (If Fullscreen = "true" ? ("Hide") : (""))
fullscreen := (If Fullscreen = "true" ? ("-fullscreen") : (""))

If bezelPath ; Setting windowed mode resolution
{	WriteProperty(fusionIni,"GameGearZoom", 1) ; disabling emulator default bezel
	If controllerReassigningEnabled != true	; no need to save file if it's going to be written later
		SaveProperties(fusionFile,fusionIni)	; save fusionFile to disk
}

 ; Allows you to set on a per-rom basis the controller type plugged into controller ports 1 and 2
If controllerReassigningEnabled = true
{	Log("Module - Started reassigning Fusion's ini controls")
	WriteProperty(fusionIni,"Joystick1Type", If genP1Controller ? genP1Controller : defaultGenP1Controller)	; sets controls for P1 to rom's P1 control type if exists, else sets to default P1 control type
	WriteProperty(fusionIni,"Joystick1bType", If genP1bController ? genP1bController : defaultGenP1bController)	; sets controls for P1b to rom's P1b control type if exists, else sets to default P1b control type
	WriteProperty(fusionIni,"Joystick1cType", If genP1cController ? genP1cController : defaultGenP1cController)	; sets controls for P1c to rom's P1c control type if exists, else sets to default P1c control type
	WriteProperty(fusionIni,"Joystick1dType", If genP1dController ? genP1dController : defaultGenP1dController)	; sets controls for P1d to rom's P1d control type if exists, else sets to default P1d control type
	WriteProperty(fusionIni,"Joystick2Type", If genP2Controller ? genP2Controller : defaultGenP2Controller)	; sets controls for P2 to rom's P2 control type if exists, else sets to default P2 control type
	WriteProperty(fusionIni,"Joystick2bType", If genP2bController ? genP2bController : defaultGenP2bController)	; sets controls for P2b to rom's P2b control type if exists, else sets to default P2b control type
	WriteProperty(fusionIni,"Joystick2cType", If genP2cController ? genP2cController : defaultGenP2cController)	; sets controls for P2c to rom's P2c control type if exists, else sets to default P2c control type
	WriteProperty(fusionIni,"Joystick2dType", If genP2dController ? genP2dController : defaultGenP2dController)	; sets controls for P2d to rom's P2d control type if exists, else sets to default P2d control type
	WriteProperty(fusionIni,"Joystick1MSType", If smsP1Controller ? smsP1Controller : defaultSMSP1Controller)	; sets controls for sms P1 to rom's sms P1 control type if exists, else sets to default sms P1 control type
	WriteProperty(fusionIni,"Joystick2MSType", If smsP2Controller ? smsP2Controller : defaultSMSP2Controller)	; sets controls for sms P2 to rom's sms P2 control type if exists, else sets to default sms P2 control type
	WriteProperty(fusionIni,"Joystick1Using", If genP1Use ? genP1Use : defaultGenP1Use)	; sets controls for P1 to rom's P1 control using if exists, else sets to default P1 control using
	WriteProperty(fusionIni,"Joystick1bUsing", If genP1bUse ? genP1bUse : defaultGenP1bUse)	; sets controls for P1b to rom's P1b control using if exists, else sets to default P1b control using
	WriteProperty(fusionIni,"Joystick1cUsing", If genP1cUse ? genP1cUse : defaultGenP1cUse)	; sets controls for P1c to rom's P1c control using if exists, else sets to default P1c control using
	WriteProperty(fusionIni,"Joystick1dUsing", If genP1dUse ? genP1dUse : defaultGenP1dUse)	; sets controls for P1d to rom's P1d control using if exists, else sets to default P1d control using
	WriteProperty(fusionIni,"Joystick2Using", If genP2Use ? genP2Use : defaultGenP2Use)	; sets controls for P2 to rom's P2 control using if exists, else sets to default P2 control using
	WriteProperty(fusionIni,"Joystick2bUsing", If genP2bUse ? genP2bUse : defaultGenP2bUse)	; sets controls for P2b to rom's P2b control using if exists, else sets to default P2b control using
	WriteProperty(fusionIni,"Joystick2cUsing", If genP2cUse ? genP2cUse : defaultGenP2cUse)	; sets controls for P2c to rom's P2c control using if exists, else sets to default P2c control using
	WriteProperty(fusionIni,"Joystick2dUsing", If genP2dUse ? genP2dUse : defaultGenP2dUse)	; sets controls for P2d to rom's P2d control using if exists, else sets to default P2d control using
	WriteProperty(fusionIni,"Joystick1MSUsing", If smsP1Use ? smsP1Use : defaultSMSP1Use)	; sets controls for sms P1 to rom's sms P1 control using if exists, else sets to default sms P1 control using
	WriteProperty(fusionIni,"Joystick2MSUsing", If smsP2Use ? smsP2Use : defaultSMSP2Use)	; sets controls for sms P2 to rom's sms P2 control using if exists, else sets to default sms P2 control using
	SaveProperties(fusionFile,fusionIni)	; save fusionFile to disk
	Log("Module - Finished reassigning Fusion's ini controls")
}

fluxRom := InStr(romName, "flux")	; test if this game is Flux, a special case game that requires an Audio CD to be mounted
If fluxRom {
	Log("Module - Mounting the Audio CD because """ . romName . """ requires one to function.")
	ident := "gen"	; change ident to gen because Flux has to be mounted as a Genesis rom
	DaemonTools("mount", fluxAudioCD)	; mount the Audio CD the user has set in the module settings
}

scdExtension := InStr(".cue|.bin|.iso", romExtension)	; the sega cd extensions supported by fusion

If (ident = "scd" && dtEnabled = "true" && scdExtension) {
	If dtUseSCSI = false
		Log("Module - Daemon Tools drive type is set to ""dt"" but only ""scsi"" is supported for Fusion. Forcing scsi drive.", 2)
	DaemonTools("mount", romPath . "\" . romName . romExtension, (If dtUseSCSI = "false" ? "scsi" : ""))
	Sleep, DTWaitTime
	Run(executable . " -auto -" . ident . " " . fullscreen, emuPath, hideEmu)
} Else {
	If (ident = "scd" && dtEnabled = "true" && !scdExtension)
		Log("Module - " . romExtension . " is not a supported cd image extension for Fusion. Launching Fusion without DT support.", 2)
	Run(executable . " -auto -" . ident . " " . fullscreen . " """ . romPath . "\" . romName . romExtension . """", emuPath, hideEmu)
}

WinWait("Fusion ahk_class KegaClass")
WinWaitActive("Fusion ahk_class KegaClass")

If fluxRom
	PostMessage, 0x111, 40009,,,ahk_class KegaClass	; Runs the Boot Sega-CD command to load the Audio CD that should be mounted in DT already

If (ident = "scd" && useRamCarts = "true")	; Sega CD or Mega CD only
{	brmPath := ReadProperty(fusionIni,"BRMFiles")		; read BRM path
	IfNotExist, %brmPath%
		FileCreateDir, %brmPath%	; create brmPath if it does not exist
	selectRamWin := "Select RAM Cart Size ahk_class #32770"
	createRamWin := "Create RAM Cart ahk_class #32770"
	loadRamWin := "Load RAM Cart ahk_class #32770"
	; Create New Ram Cart if it doesn't exist already
	IfNotExist, %brmPath%\%romName%.crm
	{	PostMessage, 0x111, 40036,,,ahk_class KegaClass	; Open Create New Ram Cart Window
		WinWait, %selectRamWin%
		WinSet, Transparent, On, %selectRamWin%
		Control, Check,, Button7, %selectRamWin%
		ControlSend, Button1, {Enter}, %selectRamWin%
		WinWait, %createRamWin%
		WinSet, Transparent, On, %createRamWin%
		WinWaitActive, %createRamWin%
		Loop {
			ControlGetText, edit1Text, Edit1, %createRamWin%
			If ( edit1Text = brmPath . "\" . romName . ".crm" )
				Break
			Sleep, 100
			ControlSetText, Edit1, %brmPath%\%romName%.crm, %createRamWin%
		}
		ControlSend, Button1, {Enter}, %createRamWin% ; Select Save
	}
	; Now load the Ram Cart
	PostMessage, 0x111, 40035,,,ahk_class KegaClass	; Open Load Ram Cart Window
	WinWait, %loadRamWin%
	WinSet, Transparent, On, %loadRamWin%
	WinWaitActive, %loadRamWin%
	Loop {
		ControlGetText, edit1Text, Edit1, %loadRamWin%
		If ( edit1Text = brmPath . "\" . romName . ".crm" )
			Break
		Sleep, 100
		ControlSetText, Edit1, %brmPath%\%romName%.crm, %loadRamWin%
	}
	ControlSend, Button1, {Enter}, %loadRamWin% ; Select Open
}

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
	If bezelEnabled != true
		Center(Fusion ahk_class KegaClass)
}

BezelDraw()
FadeInExit()
Process("WaitClose", executable)

If (fluxRom || (ident = "scd" && dtEnabled = "true" && scdExtension))
	DaemonTools("unmount")

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

MultiGame:
	; msgbox % "selectedRom = " . selectedRom . "`nselected game = " . currentButton . "`nmgRomPath = " . mgRomPath . "`nmgRomExt = " . mgRomExt . "`nmgRomName = "  . mgRomName
	; Unmount the CD from DaemonTools
	If ( scdExtension && dtEnabled = "true" )
		DaemonTools("unmount")
	Sleep, 500	; Required to prevent  DT from bugging
	; Mount the CD using DaemonTools
	If ( scdExtension && dtEnabled = "true" )
		DaemonTools("mount", selectedRom)
Return

CloseProcess:
	FadeOutStart()
	WinClose("Fusion ahk_class KegaClass")
	; PostMessage, 0x111, 40039,,,ahk_class KegaClass	; Tells Fusion to Power Off
	; Sleep, 100	; giving time for Fusion to unload rom
	; PostMessage, 0x111, 40005,,,ahk_class KegaClass	; Tells Fusion to exit
Return
