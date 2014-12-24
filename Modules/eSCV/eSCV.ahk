MEmu = ePV-1000
MEmuV = v2014/05/01
MURL = http://homepage3.nifty.com/takeda-toshiya/scv/
MAuthor = brolly
MVersion = 2.0
MCRC = 3BFE89A1
iCRC = 367BE938
mId = 635535878311879170
MSystem = "Epoch Super Cassette Vision"
;----------------------------------------------------------------------------
; Notes:
; Make sure you run the emulator at least once outside HyperLaunch and verify 
; that a file named scv.ini is created after exiting
; The emulator requires a Bios file named BIOS.ROM in its folder
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
FullscreenResolution := IniReadCheck(settingsFile, "Settings", "FullscreenResolution","8",,1)
StretchScreen := IniReadCheck(settingsFile, "Settings", "StretchScreen","true",,1)
WindowedResolution := IniReadCheck(settingsFile, "Settings", "WindowedResolution","2",,1)

iniFile := CheckFile(emuPath . "\BIOS.ROM")
iniFile := CheckFile(emuPath . "\scv.ini")

BezelStart()

Resolution := (If Fullscreen = "true" ? FullscreenResolution : WindowedResolution)

IniWrite, %Resolution%, %iniFile%, Screen, WindowMode
If (StretchScreen = "true")
	IniWrite, 1, %iniFile%, Screen, StretchScreen
Else
	IniWrite, 0, %iniFile%, Screen, StretchScreen

hideEmuObj := Object("EPOCH SCV",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

HideEmuStart()
Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("EPOCH SCV")
WinWaitActive("EPOCH SCV")

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
	WinClose("EPOCH SCV")
Return
