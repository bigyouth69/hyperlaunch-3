MEmu = Ootake
MEmuV = v2.62
MURL = http://www.ouma.jp/ootake/
MAuthor = djvj
MVersion = 2.0.1
MCRC = 67565930
iCRC = 1E716C97
MID = 635038268911079873
MSystem = "NEC PC Engine","NEC PC Engine-CD","NEC SuperGrafx","NEC TurboGrafx-16","NEC TurboGrafx-CD"
;----------------------------------------------------------------------------
; Notes:
; Place your SYSCARD.PCE file in the same folder as the emu. If your bios is called SYSCARD3.PCE, rename it to SYSCARD.PCE
; If you want to use built-in zip support, you need to d/l UNZIP32.DLL and put it in the emu folder. Otherwise, use 7z support to unzip your rom
; To go fullscreen, set in the emulator's options to "Start Window Mode". HyperLaunch sends fullscreen on launch so it can be controlled via HLHQ and the module
;.
; CD systems:
; Make sure your DAEMON_Tools_Path in Settings\Global HyperLaunch.ini is correct
; Run the emu and goto CD-ROM on the menubar and set the Drive Letter you use for Daemon Tools
;----------------------------------------------------------------------------
StartModule()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

CheckFile(emuPath . "\SYSCARD.pce")

FadeInStart()
7z(romPath, romName, romExtension, 7zExtractPath)

If systemName contains CD	; your system name must have "CD" in it's name
{	DaemonTools("mount",romPath . "\" . romName . romExtension)
	Run(executable . " /CD", emuPath)
} Else
	Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("Ootake ahk_class Ootake")
WinWaitActive("Ootake ahk_class Ootake")

If Fullscreen = true
{	Send, {F12}
	Sleep, 2000 ; could not find a way to detect when emu is loaded and fullscreen, using a sleep instead
}

FadeInExit()
Process("WaitClose", executable)

If systemName contains CD
	DaemonTools("unmount")

7zCleanUp()
FadeOutExit()
ExitModule()


HaltEmu:
	Send, {F12}
Return
RestoreEmu:
	Send, {F12}
Return

CloseProcess:
	FadeOutStart()
	WinClose("Ootake ahk_class Ootake")
Return
