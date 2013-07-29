MEmu = Fceux
MEmuV =  r2699
MURL = http://www.fceux.com/web/home.html
MAuthor = djvj
MVersion = 2.0
MCRC = D4C79C64
iCRC =
MID = 635038268889762139
MSystem = "Nintendo Entertainment System","Nintendo Famicom","Nintendo Famicom Disk System"
;----------------------------------------------------------------------------
; Notes:
; To set fullscreen, goto Config->Video and check Enter full screen mode after game is loaded. Leave Full Screen unchecked.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()
7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("ahk_class FCEUXWindowClass")
WinWaitActive("ahk_class FCEUXWindowClass")

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("ahk_class FCEUXWindowClass")
Return
