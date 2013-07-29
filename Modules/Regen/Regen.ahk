MEmu = Regen
MEmuV =  v0.97
MURL = http://aamirm.hacking-cult.org/www/regen.html
MAuthor = djvj
MVersion = 2.0.1
MCRC = 542AEC82
iCRC = 1E716C97
MID = 635038268921698714
MSystem = "Sega Genesis","Sega Mega Drive"
;----------------------------------------------------------------------------
; Notes:
; Set your fullscreen resolution by going to Video->Fullscreen Resolution
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

7z(romPath, romName, romExtension, 7zExtractPath)

regenINI := CheckFile(emuPath . "\regen.ini")

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("Regen ahk_class Regen")
WinWaitActive("Regen ahk_class Regen")

 ; Go fullscreen
If Fullscreen = true
{	Sleep, 100 ; just in case some lag is needed
	WinMenuSelectItem, Regen ahk_class Regen,,Video,Enter Fullscreen
	; Send !{Enter} ; alt method to go fullscreen
}

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


HaltEmu:
	Send, !{Enter}
Return
RestoreEmu:
	WinActivate, ahk_id  %emulatorID%
	Send, !{Enter}
Return

CloseProcess:
	FadeOutStart()
	WinClose("Regen ahk_class Regen")
Return
