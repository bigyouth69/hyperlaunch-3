MEmu = ePV-1000
MEmuV = v2012/03/20
MURL = http://homepage3.nifty.com/takeda-toshiya/pv1000/
MAuthor = brolly & djvj
MVersion = 2.0
MCRC = 4E19C943
iCRC =
MID = 635038268888731281
MSystem = "Casio PV-1000"
;----------------------------------------------------------------------------
; Notes:
; To set fullscreen run the emulator once and press alt+enter to go fullscreen
; It will start fullscreen every time after that
;----------------------------------------------------------------------------
StartModule()
FadeInStart()
7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("CASIO PV-1000")
WinWaitActive("CASIO PV-1000")

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("CASIO PV-1000")
Return
