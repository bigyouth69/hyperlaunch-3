MEmu = eSC-3000
MEmuV = v2014/05/01
MURL = http://homepage3.nifty.com/takeda-toshiya/sc3000/
MAuthor = brolly
MVersion = 2.0
MCRC = 9126E5C4
iCRC = 38BDB108
mId = 635535878342504674
MSystem = "Sega SC-3000"
;----------------------------------------------------------------------------
; Notes:
; Make sure you run the emulator at least once outside HyperLaunch and verify 
; that a file named sc3000.ini is created after exiting
; To play tape games make sure you have the BASIC Level 3 roms in your emulator folder and named 
; Sega SC-3000 BASIC Level 3 (Japan).bin
;
; The emulator will only accept roms with .bin or .rom extensions from the command line, If your 
; roms have the .sg extension simply rename them to .bin otherwise they won't work as they will be feed 
; to the emulator through CLI
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
FullscreenResolution := IniReadCheck(settingsFile, "Settings", "FullscreenResolution","8",,1)
StretchScreen := IniReadCheck(settingsFile, "Settings", "StretchScreen","true",,1)
WindowedResolution := IniReadCheck(settingsFile, "Settings", "WindowedResolution","2",,1)
BasicLoadingTime := IniReadCheck(settingsFile, "Settings", "BasicLoadingTime","6000",,1)
TapeLoadingTime := IniReadCheck(settingsFile, "Settings", "TapeLoadingTime","4000",,1)
WaveShaper := IniReadCheck(settingsFile, romname, "WaveShaper","1",,1)

iniFile := CheckFile(emuPath . "\sc3000.ini")

BezelStart()

Resolution := If Fullscreen = "true" ? FullscreenResolution : WindowedResolution
IniWrite, %Resolution%, %iniFile%, Screen, WindowMode
IniWrite, %WaveShaper%, %iniFile%, Control, WaveShaper

If (StretchScreen = "true")
	IniWrite, 1, %iniFile%, Screen, StretchScreen
Else
	IniWrite, 0, %iniFile%, Screen, StretchScreen

hideEmuObj := Object("SEGA SC-3000",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

If (romExtension = ".wav")
	BasicRomPath := CheckFile(emuPath . "\Sega SC-3000 BASIC Level 3 (Japan).bin")

CartToRun := If romExtension = ".wav" ? BasicRomPath : romPath . "\" . romName . romExtension

HideEmuStart()
Run(executable . " """ . CartToRun . """", emuPath)

WinWait("SEGA SC-3000")
WinWaitActive("SEGA SC-3000")

If (romExtension = ".wav")
{
	SetKeyDelay(50)
	Sleep, %BasicLoadingTime%
	PostMessage, 0x111, 40941,,,SEGA SC-3000 ;Play Tape
	OpenROM("Data Recorder Tape ahk_class #32770",romPath . "\" . romName . romExtension)
	;Wait for main window to become active again
	WinWait("SEGA SC-3000")
	WinWaitActive("SEGA SC-3000")
	Sleep, %TapeLoadingTime%
	SendCommand("LOAD{Enter}")
	Loop 
	{ 
		;looping until tape is done loading, it will show Stop in the window title
		Sleep, 200
		WinGetTitle, winTitle, SEGA SC-3000
		If winTitle contains Stop
			Break
	}
	SendCommand("RUN{Enter}")
}

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
	WinClose("SEGA SC-3000")
Return
