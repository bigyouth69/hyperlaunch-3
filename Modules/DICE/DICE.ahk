MEmu = Dice
MEmuV = v0.8
MURL = http://adamulation.blogspot.com/
MAuthor = djvj
MVersion = 2.0.1
MCRC = C5F266C7
iCRC = 1E716C97
MID = 635038268883967308
MSystem = "DICE"
;----------------------------------------------------------------------------
; Notes:
; Create 4 txt files in the emu dir, one each for Gotcha, Pong, Rebound and SpaceRace.
; romExtension should be txt
; Point both emu and rom dirs to the dir that contains Dice.exe
; Dice stores its config in your user dir: C:\Users\username\AppData\Roaming\dice
; Bezels do not work yet, emu has a statusbar at the bottom that even when removed, still shows up in windowed mode
;----------------------------------------------------------------------------
StartModule()
; BezelGui()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

; BezelStart()
7z(romPath, romName, romExtension, 7zExtractPath)

StringLower, romName, romName ; the rom's name must be passed lowercase to the emu otherwise it doesn't work

fullscreen := If fullscreen = "true" ? "" : " -window"

Run(executable . " " . romName . fullscreen, emuPath, "Hide") ; need Hide here otherwise the app pops into view over our GUI

WinWait("DICE ahk_class phoenix_window")

Control, Hide, , msctls_statusbar321, DICE ahk_class phoenix_window ; Removes the StatusBar

WinActivate, DICE ahk_class phoenix_window ; dice 0.8 does not give focus properly, this ensures it gets focus
WinWaitActive("DICE ahk_class phoenix_window")	; dice 0.8 has a status bar at the bottom 
Control, Hide, , msctls_statusbar321, DICE ahk_class phoenix_window ; Removes the StatusBar
; BezelDraw()
; Sleep, 1000 ; small sleep required ottherwise Hyperspin flashes back into view

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
; BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("DICE ahk_class phoenix_window")
Return
