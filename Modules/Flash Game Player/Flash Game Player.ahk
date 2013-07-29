MEmu = Flash Game Player
MEmuV = v1.0
MURL =
MAuthor = brolly & djvj
MVersion = 2.0
MCRC = A9E0C5A8
iCRC = 
MID = 635038268890803010
MSystem = "Flash Games"
;----------------------------------------------------------------------------
; Flash Game Player by Krum
; Notes:
; Make sure you configure the exit key on the Game.ini file that resides on the player's folder
;----------------------------------------------------------------------------
StartModule()
FadeInStart()
7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable . " """ . romPath . "\" . romName . romExtension . """ -ini """ . emuPath . "\Game.ini""", emuPath, "Hide")
WinWait("Form1")
WinWaitActive("Form1")

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("Form1")
Return
