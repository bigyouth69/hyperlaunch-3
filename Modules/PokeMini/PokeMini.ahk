MEmu = PokeMini SDL
MEmuV =  v0.5.2
MURL = https://code.google.com/p/pokemini/
MAuthor = djvj
MVersion = 2.0
MCRC = C7513DCA
iCRC = 7AE78479
MID = 635038268915383452
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

7z(romPath, romName, romExtension, 7zExtractPath)

fullscreen := (If Fullscreen = "true" ? ("-fullscreen") : (""))
battery := (If BatteryState = "full" ? ("-fullbattery") : ("-lowbattery"))
joystick := (If Joystick = "true" ? ("-joystick") : (""))

Run(executable . " " . fullscreen . " " . battery . " " . joystick . " """ . romPath . "\" . romName . romExtension . """",emuPath)

WinWait("PokeMini ahk_class POKEMINIWIN")
WinActivate, PokeMini ahk_class POKEMINIWIN

MouseMove, %A_ScreenWidth%, %A_ScreenHeight%

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("PokeMini ahk_class POKEMINIWIN")
Return
