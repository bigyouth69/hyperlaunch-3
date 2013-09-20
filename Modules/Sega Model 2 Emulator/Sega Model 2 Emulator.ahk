MEmu = Sega Model 2 Emulator
MEmuV = v1.0
MURL = http://nebula.emulatronia.com/
MAuthor = djvj
MVersion = 2.0.3
MCRC = 4739F503
iCRC = DCAB129
MID = 635038268923290039
MSystem = "Sega Model 2"
;----------------------------------------------------------------------------
; Notes:
; Oustide of Hyperspin, open the Sega Model 2 Emulator. 
; Under Video enable "auto switch to fullscreen".
; model2.zip must exist in your rom path which contains the needed bios files for the system.
; Module settings overwrite what you have set in the emulator itself.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
fullScreenWidth := IniReadCheck(settingsFile, "Settings", "FullScreenWidth",A_ScreenWidth,,1)
fullScreenHeight := IniReadCheck(settingsFile, "Settings", "FullScreenHeight",A_ScreenHeight,,1)

CheckFile(romPath . "\model2.zip","Could not locate ""model2.zip"" which contains the bios files for this emulator. Please make sure it exists in the same folder as your roms.")
m2Ini := CheckFile(emuPath . "\EMULATOR.INI")
romDir1 := IniReadCheck(m2Ini, "RomDirs", "Dir1",,,1)
If (romDir1 != romPath)
	IniWrite, %romPath%, %m2Ini%, RomDirs, Dir1	; write the correct romPath to the emu's ini so the user does not need to define this

BezelStart()

; Write settings to m2's ini file
IniWrite, % (If fullscreen = "true" ? 1 : 0), %m2Ini%, Renderer, AutoFull
IniWrite, %fullScreenWidth%, %m2Ini%, Renderer, FullScreenWidth
IniWrite, %fullScreenHeight%, %m2Ini%, Renderer, FullScreenHeight

Run(executable . A_Space . romName, emuPath, "Hide")	; Hides the emulator on launch. When bezel is enabled, this helps not show the emu before the rom is loaded

WinWait("ahk_class MYWIN",,,"Model 2 Emulator")
WinWaitActive("ahk_class MYWIN",,,"Model 2 Emulator")
Sleep, 1000 ; Increase if Hyperspin is getting a quick flash in before the game loads

BezelDraw()
FadeInExit()

WinShow, ahk_class MYWIN	; Show the emulator

Process("WaitClose", executable)
BezelExit()
FadeOutExit()
ExitModule()


RestoreEmu:
	If fullscreen = true
	{	SetKeyDelay,,100
		Send !{Enter}
		Send !{Enter}
	}
Return

CloseProcess:
	FadeOutStart()
	WinClose("AHK_class MYWIN")
Return
