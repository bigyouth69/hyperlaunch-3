MEmu = UberNES
MEmuV =  v2011.0
MURL = http://www.ubernes.com/
MAuthor = ghutch92
MVersion = 2.0
MCRC = 79ED8216
iCRC = 
MID = 635038268929184951
MSystem = "Nintendo Entertainment System","Nintendo Famicom"
;----------------------------------------------------------------------------
; Notes:
; All emulator settings will be have to set through the emulator by opening it manually.
; If you want fullscreen you will need to enable it manually through the emulator options in the gui.
; The Settings in the emulator can be found under tools -> options.
; It's recommended thate fade be enabled for this emulator.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()
7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("ahk_class UberNESClass")
WinWaitActive("ahk_class UberNESClass")
Sleep, 2000 ; prevent window from flashing into view (only works with fade)

FadeInExit()
Process("WaitClose",executable)
7zCleanUp()
FadeOutExit()
ExitModule()


HaltEmu: 
	Send, !{Enter} 
Return 
RestoreEmu: 
	WinActivate, ahk_class UberNESClass 
	Sleep, 200 
	Send, !{Enter} 
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class UberNESClass")
Return
