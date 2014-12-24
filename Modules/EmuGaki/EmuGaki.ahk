MEmu = EmuGaki
MEmuV = v2014/05/01
MURL = http://homepage3.nifty.com/takeda-toshiya/pv2000/
MAuthor = brolly
MVersion = 2.0
MCRC = FD506EB4
iCRC = 367BE938
mId = 635535821187063242
MSystem = "Casio PV-2000"
;----------------------------------------------------------------------------
; Notes:
; Make sure you run the emulator at least once outside HyperLaunch and verify 
; that a file named pv2000.ini is created after exiting.
; The emulator requires a Bios file named IPL.ROM in its folder
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
FullscreenResolution := IniReadCheck(settingsFile, "Settings", "FullscreenResolution","8",,1)
StretchScreen := IniReadCheck(settingsFile, "Settings", "StretchScreen","true",,1)
WindowedResolution := IniReadCheck(settingsFile, "Settings", "WindowedResolution","2",,1)

iniFile := CheckFile(emuPath . "\IPL.ROM")
iniFile := CheckFile(emuPath . "\pv2000.ini")

BezelStart()

Resolution := If Fullscreen = "true" ? FullscreenResolution : WindowedResolution
IniWrite, %Resolution%, %iniFile%, Screen, WindowMode

If (StretchScreen = "true")
	IniWrite, 1, %iniFile%, Screen, StretchScreen
Else
	IniWrite, 0, %iniFile%, Screen, StretchScreen

hideEmuObj := Object("CASIO PV-2000",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

HideEmuStart()
Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("CASIO PV-2000")
WinWaitActive("CASIO PV-2000")

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
	WinClose("CASIO PV-2000")
Return
