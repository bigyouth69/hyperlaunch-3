MEmu = Emu7800
MEmuV =  v1.3
MURL = http://emu7800.sourceforge.net/
MAuthor = brolly & djvj
MVersion = 2.0
MCRC = 60A3144
iCRC =
MID = 635038268887690414
MSystem = "Atari 7800"
;----------------------------------------------------------------------------
; Notes:
; Emu does not support zipped roms through CLI. So enable 7z or keep your roms uncompressed.
; To enable fullscreen, run emu manually and goto Settings and set Host Select  to DirectX (DX9 Fullscreen)
;----------------------------------------------------------------------------
StartModule()
FadeInStart()
7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("EMU7800 ahk_class EMU7800.DirectX.HostingWindow")
WinWaitActive("EMU7800 ahk_class EMU7800.DirectX.HostingWindow")

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("EMU7800 ahk_class EMU7800.DirectX.HostingWindow")
Return
