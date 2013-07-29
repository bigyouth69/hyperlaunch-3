MEmu = JNes
MEmuV =  v1.1
MURL = http://www.jabosoft.com/categories/1
MAuthor = djvj
MVersion = 2.0
MCRC = 828E1757
MID = 635038268900200827
MSystem = "Nintendo Entertainment System","Nintendo Famicom"
;----------------------------------------------------------------------------
; Notes:
; To set fullscreen, goto Options->Video->Display and check Enter full screen mode after game is loaded. Leave Full Screen unchecked.
; If you have any issues with the emu not showing up, remove the Hide at the end of the run line. It's there to give the emu a cleaner launch
;----------------------------------------------------------------------------
StartModule()
FadeInStart()
7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("ahk_class Jnes Window")
WinWaitActive("ahk_class Jnes Window")

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class Jnes Window")
Return
