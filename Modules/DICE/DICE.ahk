MEmu = Dice
MEmuV = v0.6
MURL = http://adamulation.blogspot.com/
MAuthor = djvj
MVersion = 2.0
MCRC = 1A16A8D1
iCRC =
MID = 635038268883967308
MSystem = "DICE"
;----------------------------------------------------------------------------
; Notes:
; Create 4 txt files in the emu dir, one each for Gotcha, Pong, Rebound and SpaceRace.
; romExtension should be txt
; Point both emu and rom dirs to the dir that contains Dice.exe
; Dice stores its config in your user dir: C:\Users\username\AppData\Roaming\dice
;----------------------------------------------------------------------------
; Fullscreen = true ; fullscreen is automatic in Dice when launched from CLI, cannot control it
;----------------------------------------------------------------------------
StartModule()
FadeInStart()
7z(romPath, romName, romExtension, 7zExtractPath)

StringLower, romName, romName ; the rom's name must be passed lowercase to the emu otherwise it doesn't work

Run(executable . " " . romName, emuPath, "Hide") ; need Hide here otherwise the app pops into view over our GUI

WinWait("DICE ahk_class phoenix_window")
WinWaitActive("DICE ahk_class phoenix_window")
; Sleep, 1000 ; small sleep required ottherwise Hyperspin flashes back into view

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("DICE ahk_class phoenix_window")
Return
