MEmu = Bsnes
MEmuV =  v0.87
MURL = http://byuu.org/bsnes/
MAuthor = djvj
MVersion = 2.0.1
MCRC = F4D39A7E
iCRC = 77DA7529
MID = 635038268877141627
MSystem = "Nintendo Entertainment System","Nintendo Famicom""Nintendo Game Boy","Nintendo Game Boy Color","Nintendo Satellaview","Nintendo Super Famicom","Super Nintendo Entertainment System"
;----------------------------------------------------------------------------
; Notes:
; You can set your Exit key in the emu by going to Settings->Configuration Settings->Input->Hotkeys->Exit Emulator (not needed for this script)
; If you want to use xpadder, or joy2key, goto Settings->Advanced Settings and change Input to DirectInput
; Fullscreen is controlled via GUi when running the module directly
; Sram Support is controlled via GUi when running the module directly - If true, the module will backup srm files into a backup folder and copy them back to the 7z_Extract_Path so bsnes can load them upon launch. You really only need this if you use 7z support (and 7z_Delete_Temp is true) or your romPath is read-only.
; If you use 7z support, the games that require special roms (dsp/cx4), the roms needs to be inside the 7z with the game. Otherwise you will get an error about the missing rom.
; You can find the dsp roms needed for some games here: http://www.caitsith2.com/snes/dsp/ and a list of what games use what chip here: http://www.pocketheaven.com/ph/wiki/SNES_games_with_special_chips
; bsnes stores its config @ C:\Users\%USER%\AppData\Roaming\bsnes
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

settingsFile := CheckFile(modulePath . "\" . moduleName . ".ini")

7z(romPath, romName, romExtension, 7zExtractPath)

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
sramSupport := IniReadCheck(settingsFile, "Settings", "sramSupport","false",,1)
controllerReassigningEnabled := IniReadCheck(settingsFile, "Settings", "Controller_Reassigning_Enabled","false",,1)
defaultP1Controller := IniReadCheck(settingsFile, "Settings", "Default_P1_Controller",1,,1)
defaultP2Controller := IniReadCheck(settingsFile, "Settings", "Default_P2_Controller",1,,1)
bezelTopOffset := IniReadCheck(settingsFile, "Settings", "bezelTopOffset",51,,1)
bezelBottomOffset := IniReadCheck(settingsFile, "Settings", "bezelBottomOffset",31,,1)
bezelLeftOffset := IniReadCheck(settingsFile, "Settings", "bezelLeftOffset",7,,1)
bezelRightOffset := IniReadCheck(settingsFile, "Settings", "bezelRightOffset",7,,1)
p1Controller := IniReadCheck(settingsFile, romName, "P1_Controller",,,1)
p2Controller := IniReadCheck(settingsFile, romName, "P2_Controller",,,1)

BezelStart()

; Set desired fullscreen mode
bsnesFile := CheckFile(A_AppData . "\bsnes\settings.cfg")
FileRead, bsnesCfg, %bsnesFile%
currentFullScreen := (InStr(bsnesCfg, "Video::FullScreenMode = 1") ? ("true") : ("false"))
If ( Fullscreen != "true" And currentFullScreen = "true" ) {
	StringReplace, bsnesCfg, bsnesCfg, Video::FullScreenMode = 1, Video::FullScreenMode = 0
	StringReplace, bsnesCfg, bsnesCfg, Video::StartFullScreen = true, Video::StartFullScreen = false
	SaveFile(bsnesCfg, bsnesFile)
} Else If ( Fullscreen = "true" And currentFullScreen = "false" ) {
	StringReplace, bsnesCfg, bsnesCfg, Video::FullScreenMode = 0, Video::FullScreenMode = 1
	StringReplace, bsnesCfg, bsnesCfg, Video::StartFullScreen = false, Video::StartFullScreen = true
	SaveFile(bsnesCfg, bsnesFile)
}

; copy backed-up srm files to folder where rom is located
If sramSupport = true
	IfExist, %emuPath%\srm\%romName%.srm
		FileCopy, %emuPath%\srm\%romName%.srm, %romPath%, 1 ; overwriting existing srm with backup if it exists in destination folder

 ; Allows you to set on a per-rom basis the controller type plugged into controller ports 1 and 2
If controllerReassigningEnabled = true
{	Loop, Parse, bsnesCfg, `n
		If InStr(A_LoopField,"SNES::Controller::Port1")
			newCfg .= "SNES::Controller::Port1 = " . (If p1Controller ? p1Controller : defaultP1Controller) . "`r`n"	; sets controls for P1 to rom's P1 control type if exists, else sets to default P1 controls
		Else If InStr(A_LoopField,"SNES::Controller::Port2")
			newCfg .= "SNES::Controller::Port2 = " . (If p2Controller ? p2Controller : defaultP2Controller) . "`r`n"	; sets controls for P2 to rom's P2 control type if exists, else sets to default P2 controls
		Else
			newCfg .= If A_LoopField = "" ? "" : A_LoopField . "`n"
	SaveFile(newCfg,bsnesFile)
}

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait(romName . " ahk_class phoenix_window")
WinWaitActive(romName . " ahk_class phoenix_window")

BezelDraw()
FadeInExit()

; WinMove, 0, 0 ; when going from fullscreen to window, bsnes still has its menubar hidden, uncomment this to access it
Process("WaitClose", executable)

 ; Back up srm file so it is available for next launch
If sramSupport = true
{	IfNotExist, %emuPath%\srm\
		FileCreateDir, %emuPath%\srm\ ; create srm folder if it doesn't exist
	FileCopy, %romPath%\%romName%.srm, %emuPath%\srm\, 1
}

7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


SaveFile(text,file) {
	FileDelete, %file%
	FileAppend, %text%, %file%
}

BezelLabel:
	disableHideTitleBar = true
	disableHideToggleMenu = true
	disableHideBorder = true
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class phoenix_window")
Return
