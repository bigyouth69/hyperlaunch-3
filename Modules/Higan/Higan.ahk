MEmu = Higan
MEmuV =  v0.92
MURL = http://byuu.org/higan/
MAuthor = djvj
MVersion = 2.0
MCRC = 7FBE8F6A
iCRC = A3607D8A
MID = 635038268899159961
MSystem = "Nintendo Entertainment System","Nintendo Famicom""Nintendo Game Boy","Nintendo Game Boy Color","Nintendo Satellaview","Nintendo Super Famicom","Super Nintendo Entertainment System"
;----------------------------------------------------------------------------
; Notes:
; You can set your Exit key in the emu by going to Settings->Configuration Settings->Input->Hotkeys->Exit Emulator (not needed for this script)
; If you want to use xpadder, or joy2key, goto Settings->Advanced Settings and change Input to DirectInput
; Fullscreen is controlled via GUi when running the module directly
; Sram Support is controlled via GUi when running the module directly - If true, the module will backup srm files into a backup folder and copy them back to the 7z_Extract_Path so higan can load them upon launch. You really only need this if you use 7z support (and 7z_Delete_Temp is true) or your romPath is read-only.
; If you use 7z support, the games that require special roms (dsp/cx4), the roms needs to be inside the 7z with the game. Otherwise you will get an error about the missing rom.
; You can find the dsp roms needed for some games here: http://www.caitsith2.com/snes/dsp/ and a list of what games use what chip here: http://www.pocketheaven.com/ph/wiki/SNES_games_with_special_chips
; higan stores its config @ C:\Users\%USER%\AppData\Roaming\higan
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
sramSupport := IniReadCheck(settingsFile, "Settings", "SRAM_Support","true",,1)
bezelTopOffset := IniReadCheck(settingsFile, "Settings", "bezelTopOffset","51",,1)
bezelBottomOffset := IniReadCheck(settingsFile, "Settings", "bezelBottomOffset","31",,1)
bezelLeftOffset := IniReadCheck(settingsFile, "Settings", "bezelLeftOffset","7",,1)
bezelRightOffset := IniReadCheck(settingsFile, "Settings", "bezelRightOffset","7",,1)

BezelStart()

7z(romPath, romName, romExtension, 7zExtractPath)

; Set desired fullscreen mode
higanFile := CheckFile(A_AppData . "\higan\settings.cfg")
FileRead, higanCfg, %higanFile%
currentFullScreen := (InStr(higanCfg, "Video::StartFullScreen = true") ? ("true") : ("false"))
If ( Fullscreen != "true" And currentFullScreen = "true" ) {
	; StringReplace, higanCfg, higanCfg, Video::FullScreenMode = 1, Video::FullScreenMode = 0
	StringReplace, higanCfg, higanCfg, Video::StartFullScreen = true, Video::StartFullScreen = false
	SaveFile(higanCfg, higanFile)
} Else If ( Fullscreen = "true" And currentFullScreen = "false" ) {
	; StringReplace, higanCfg, higanCfg, Video::FullScreenMode = 0, Video::FullScreenMode = 1
	StringReplace, higanCfg, higanCfg, Video::StartFullScreen = false, Video::StartFullScreen = true
	SaveFile(higanCfg, higanFile)
}

 ; copy backed-up srm files to folder where rom is located
If sramSupport = true
	IfExist, %emuPath%\srm\%romName%.srm
		FileCopy, %emuPath%\srm\%romName%.srm, %romPath%, 1 ; overwriting existing srm with backup if it exists in destination folder

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("higan ahk_class phoenix_window")
WinWaitActive("higan ahk_class phoenix_window")

BezelDraw()
FadeInExit()

; WinMove, 0, 0 ; when going from fullscreen to window, higan still has its menubar hidden, uncomment this to access it
; WinMenuSelectItem,ahk_class phoenix_window,,Super Famicom, Port 2, Justifier
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
