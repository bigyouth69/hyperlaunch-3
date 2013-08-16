MEmu = PokeMini SDL
MEmuV =  v0.5.2
MURL = https://code.google.com/p/pokemini/
MAuthor = djvj
MVersion = 2.0
MCRC = 2B2E44AD
iCRC = 9DAE6F8
MID = 635038268915913898
MSystem = "Nintendo Pokemon Mini"
;------------------------------------------------------------------------
; Notes:
; This will only work with the windows SDL port. The win32 port did not work for me.
; Place bios.min in the emu dir if you have it, otherwise the emu resorts to Pokemon-Mini FreeBIOS
; Emu requires zlib1.dll to be installed or exist in the emu folder, get it here if you don't have it: http://sourceforge.net/projects/libpng/?source=dlp
;------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
BatteryState := IniReadCheck(settingsFile, "Settings", "BatteryState","full",,1)		; Options are full and low
Joystick := IniReadCheck(settingsFile, "Settings", "Joystick","true",,1)			; True enables joystick support
bezelTopOffset := IniReadCheck(settingsFile, "Settings", "bezelTopOffset","37",,1)
bezelBottomOffset := IniReadCheck(settingsFile, "Settings", "bezelBottomOffset","16",,1)
bezelLeftOffset := IniReadCheck(settingsFile, "Settings", "bezelLeftOffset","16",,1)
bezelRightOffset := IniReadCheck(settingsFile, "Settings", "bezelRightOffset","16",,1)

BezelStart("fixResMode")
7z(romPath, romName, romExtension, 7zExtractPath)

fullscreen := (If Fullscreen = "true" ? ("-fullscreen") : (""))

battery := (If BatteryState = "full" ? ("-fullbattery") : ("-lowbattery"))
joystick := (If Joystick = "true" ? ("-joystick") : (""))

Run(executable . " " . fullscreen . " " . battery . " " . joystick . " """ . romPath . "\" . romName . romExtension . """",emuPath)

WinWait("PokeMini ahk_class SDL_app")
WinActivate, PokeMini ahk_class SDL_app

If Fullscreen = true
	MouseMove, %A_ScreenWidth%, %A_ScreenHeight%

BezelDraw()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()

BezelLabel:
	disableHideTitleBar := true
	disableHideToggleMenu := true
	disableHideBorder := true
Return

CloseProcess:
	FadeOutStart()
	WinClose("PokeMini ahk_class SDL_app")
Return
