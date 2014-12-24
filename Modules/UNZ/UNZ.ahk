MEmu = UNZ
MEmuV = v0.5L30
MURL = http://townsemu.world.coocan.jp/
MAuthor = djvj
MVersion = 2.0
MCRC = 2405E572
iCRC = 1E716C97
MID = 635038268929715384
MSystem = "Fujitsu FM Towns"
;----------------------------------------------------------------------------
; Notes:
; Make sure your Daemontools_Path in Settings\HyperLaunch.ini is correct
; In Settings->Property->CD-ROM1->Emulation Type->Select drive, set your daemontools drive letter
; There is no way of launching the game automatically from the FM-Towns OS window.
; To launch the game, double click the game's name once you are in the FM-Towns OS
; View->Fullscreen to enable fullscreen
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

7z(romPath, romName, romExtension, 7zExtractPath)

fullscreen := If (Fullscreen = "true")?"-fs":""

DaemonTools("mount",romPath . "\" . romName . romExtension)

Run(executable . " " . fullscreen,emuPath)

WinWait("UNZ ahk_class Unz")
WinWaitActive("UNZ ahk_class Unz")

FadeInExit()
Process("WaitClose",executable)

If ( romExtension = ".cue" && dtEnabled = "true" )
	DaemonTools("unmount")

7zCleanUp()
FadeOutExit()
ExitModule()


HaltEmu: 
	Send, {F11} 
	Sleep, 200 
Return 

RestoreEmu: 
	WinRestore, ahk_ID %emulatorID% 
	IfWinNotActive, ahk_class %EmulatorClass%,,Hyperspin 
		Loop {
			Sleep, 50 
			WinActivate, ahk_class %EmulatorClass%,,Hyperspin 
			IfWinActive, ahk_class %EmulatorClass%,,Hyperspin 
			Break 
		} 
	Send, {F11} 
Return

CloseProcess:
	FadeOutStart()
	WinClose("UNZ ahk_class Unz")
Return
