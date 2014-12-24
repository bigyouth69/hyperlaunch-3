MEmu = ePV-1000
MEmuV = v2014/05/01
MURL = http://homepage3.nifty.com/takeda-toshiya/pv1000/
MAuthor = brolly & djvj
MVersion = 2.0.1
MCRC = C61F7256
iCRC = 367BE938
mId = 635540192498909112
MSystem = "Casio PV-1000"
;----------------------------------------------------------------------------
; Notes:
; Make sure you run the emulator at least once outside HyperLaunch and verify 
; that a file named pv1000.ini is created after exiting.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
FullscreenResolution := IniReadCheck(settingsFile, "Settings", "FullscreenResolution","8",,1)
StretchScreen := IniReadCheck(settingsFile, "Settings", "StretchScreen","true",,1)
WindowedResolution := IniReadCheck(settingsFile, "Settings", "WindowedResolution","2",,1)

iniFile := CheckFile(emuPath . "\pv1000.ini")

BezelStart()

Resolution := If Fullscreen = "true" ? FullscreenResolution : WindowedResolution
IniWrite, %Resolution%, %iniFile%, Screen, WindowMode

If (StretchScreen = "true")
	IniWrite, 1, %iniFile%, Screen, StretchScreen
Else
	IniWrite, 0, %iniFile%, Screen, StretchScreen

hideEmuObj := Object("CASIO PV-1000",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

HideEmuStart()
Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("CASIO PV-1000")
WinWaitActive("CASIO PV-1000")

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
	WinClose("CASIO PV-1000")
Return
