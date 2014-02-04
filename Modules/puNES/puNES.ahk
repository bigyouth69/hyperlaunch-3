MEmu = puNES
MEmuV =  v0.68
MURL = http://forums.nesdev.com/viewtopic.php?t=6928
MAuthor = djvj
MVersion = 2.0.1
MCRC = 32567FEE
iCRC = 1E716C97
MID = 635038268920657843
MSystem = "Nintendo Entertainment System","Nintendo Famicom"
;----------------------------------------------------------------------------
; Notes:
; Rename the executable to punes32.exe or punes64.exe which makes the emulator run in portable mode and all settings will be stored within the emulator directory
; If your Exit_Emulator_Key is set to Esc, the emu will leave fullscreen before closing. Try to use a different exit key for a more graceful exit.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

7z(romPath, romName, romExtension, 7zExtractPath)

fullscreen := If Fullscreen = "true" ? " -u yes " : " "

Run(executable . fullscreen . """" . romPath . "\" . romName . romExtension . """", emuPath, "Hide")

WinWait("puNES ahk_class FHWindowClass")
WinWaitActive("puNES ahk_class FHWindowClass")

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()

CloseProcess:
	FadeOutStart()
	WinClose("puNES ahk_class FHWindowClass")
Return
