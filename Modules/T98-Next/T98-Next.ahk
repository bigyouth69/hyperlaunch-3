iCRC = 1E716C97
MEmu = T98-Next
MEmuV = v13.1th Beta
MURL = http://www.geocities.jp/t98next/
MAuthor = djvj
MVersion = 2.0.2
MCRC = 34CB9135
MID = 635038268927083194
MSystem = "NEC PC-9801","Touhou"
;----------------------------------------------------------------------------
; Notes:
; This is only needed for games 1th through 5th, so make sure in your Games.ini, you have this Emulator set to load this module
; In order to autolaunch the game, we have to write the game's name in the MAIN.ini before launching the emu
; 3th - Phantasmagoria of Dim Dream uses different keys then the other 4 games. We need to remap keys to get 2-players working, so make sure you setup a keymapper profile to change them
; 
; Default PC-98 keys are:
;	player 1
;		RTY
;		FGH
;		VBN
;		shot - z
;		bomb - X
;	player 2
;		789
;		456
;		123
;		shot - left arrow
;		bomb - right arrow
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

7z(romPath, romName, romExtension, 7zExtractPath)

; Setting Fullscreen setting in ini if it doesn't match what user wants above
IniRead, currentFullScreen, %t98INI%, CRT, FULLSCREEN
If (Fullscreen != "true" && currentFullScreen = 1)
	fullscreen, 0, %t98INI%, CRT, FULLSCREEN
Else If (fullscreen = "true" && currentFullScreen = 0)
	IniWrite, 1, %t98INI%, CRT, FULLSCREEN

IniWrite, %romPath%\%romName%%romExtension%, %emuPath%\MAIN.INI, DISK, DISK02
IniWrite, 1, %emuPath%\MAIN.INI, Control, AutoRun	; required for games to start on emu launch
Run(executable, emuPath, "Hide")

WinWait("Emulation Window ahk_class T98-Next")
WinWaitActive("Emulation Window ahk_class T98-Next")
Sleep, 1000	; need this otherwise mouse doesn't move off screen
MouseMove 0,2000,0  ;Move mouse off screen

; If romName = 3th - Phantasmagoria of Dim Dream
	; Run, remap_keys.exe, %modulePath%

FadeInExit()
Process("WaitClose", executable)
; Process, Close, remap_keys.exe

7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	Process("Close", executable)	; WinClose exits fullscreen, but does not close emu
Return
