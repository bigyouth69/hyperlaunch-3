MEmu = Jaguar Tempest 2000 Emulator
MEmuV =  v0.06b
MURL = http://www.yakyak.org/viewtopic.php?f=5&t=41691
MAuthor = djvj
MVersion = 2.0
MCRC = C601B5E5
iCRC = 1E716C97
MID = 635038268899690393
MSystem = "Atari Jaguar"
;----------------------------------------------------------------------------
; Notes:
; This emulator emulates Tempest 2000 much better than Project Tempest
; Set Fullscreen via the variable below
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable . " " . romPath . "\" . romName . romExtension, emuPath, (If (Fullscreen = "true") ? "Hide" : ""))

errorLvl := WinWait("Tempest 2000 ahk_class SampleClass",,5)
If errorLvl
	ScriptError("There was a problem launching " . MEmu . ".`nPlease try again as sometimes the emulator doesn't start.")
WinWaitActive("Tempest 2000 ahk_class SampleClass")

If Fullscreen = true
	Send, {F1} ; this sets fullscreen

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()

CloseProcess:
	FadeOutStart()
	WinClose("Tempest 2000 ahk_class SampleClass")
Return
