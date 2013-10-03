MEmu = Mupen64Plus
MEmuV = v2.0
MURL = https://code.google.com/p/mupen64plus/
MAuthor = djvj
MVersion = 2.0
MCRC = 7B89D4B3
iCRC = 1E716C97
mId = 635163407878625424
MSystem = "Nintendo 64"
;----------------------------------------------------------------------------
; Notes:
; CLI options: https://code.google.com/p/mupen64plus/wiki/UIConsoleUsage
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
; potential options
; res
; cheats

BezelStart()

fullscreen := If (Fullscreen = "true") ? "--fullscreen --noosd" : "--windowed"
osd := "--noosd"	; removes the osd from screen

7z(romPath, romName, romExtension, 7zExtractPath)
Run(executable . " " . fullscreen . " " . osd . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("AHK_class SDL_app")
WinSet, Transparent, On, ahk_class ConsoleWindowClass	; makes the console window transparent so you don't see it on exit
WinWaitActive("AHK_class SDL_app")
WinSet, Transparent, On, ahk_class SDL_app	; hide emu so we don't as much of it being resized, can't get rid of it completely however.

BezelDraw()
FadeInExit()

WinSet, Transparent, Off, ahk_class SDL_app	; make emu visible

Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("AHK_class SDL_app")
Return
