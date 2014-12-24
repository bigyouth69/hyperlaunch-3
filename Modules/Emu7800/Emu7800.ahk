MEmu = Emu7800
MEmuV =  v1.3
MURL = http://emu7800.sourceforge.net/
MAuthor = brolly & djvj
MVersion = 2.0.1
MCRC = 147FAEBD
iCRC = 1E716C97
MID = 635038268887690414
MSystem = "Atari 7800"
;----------------------------------------------------------------------------
; Notes:
; Emu does not support zipped roms through CLI. So enable 7z or keep your roms uncompressed.
; To enable fullscreen, run emu manually and goto Settings and set Host Select  to DirectX (DX9 Fullscreen)
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

BezelStart()
hideEmuObj := Object("EMU7800 ahk_class EMU7800.DirectX.HostingWindow",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait
Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("EMU7800 ahk_class EMU7800.DirectX.HostingWindow")
WinWaitActive("EMU7800 ahk_class EMU7800.DirectX.HostingWindow")

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("EMU7800 ahk_class EMU7800.DirectX.HostingWindow")
Return
