MEmu = Nostalgia
MEmuV = v5.0
MURL = http://www.intellivision.us/intvgames/nostalgia/nostalgia.php
MAuthor = djvj
MVersion = 2.0
MCRC = 16EB2977
iCRC = 1E716C97
MID = 635038268909868866
MSystem = "Mattel Intellivision"
;----------------------------------------------------------------------------
; Notes:
; If you want Hyperspin to fade out on launch, set LoadingScreen to true below and turn off hide_desktop in your Hyperspin\Settings\Settings.ini
; Place the exec.bin and grom.bin roms in the emu dir uncompressed. If you have the ECS.bin and IntelliVoice.bin roms, place them in there too.
; If you get a box popping up saying that the content in your roms dir has changed, run the emu exe manually and click yes then exit. It won't pop up again. There is no need to set a roms dir either.
; To enable fullscreen, set the variable below.
;
; Nostalgia stores its config in the registry @ HKEY_CURRENT_USER\Software\ShinyTechnologies\Nostalgia
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

; Setting Fullscreen setting in registry if it doesn't match what user wants above
currentFullScreen := ReadReg("Full Screen")
If ( Fullscreen != "true" And currentFullScreen = 1 ) {
	WriteReg("Full Screen", 0)
	WriteReg("Hide on Run", 0)
} Else If ( Fullscreen = "true" And currentFullScreen = 0 ) {
	WriteReg("Full Screen", 1)
	WriteReg("Hide on Run", 1)
}

7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("ahk_class NostalgiaGameClass")
WinWaitActive("ahk_class NostalgiaGameClass")

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


ReadReg(var1) {
	RegRead, regValue, HKEY_CURRENT_USER, Software\ShinyTechnologies\Nostalgia, %var1%
	Return %regValue%
}

WriteReg(var1, var2) {
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\ShinyTechnologies\Nostalgia, %var1%, %var2%
}

HaltEmu:
	Send, !{Enter}
	Sleep, 200
Return
RestoreEmu:
	Send, !{Enter}
	Sleep, 800
	Send, {F9 Down}{F9 Up}
Return

CloseProcess:
	FadeOutStart()
	WinKill, ahk_class NostalgiaGameClass,,2
Return
