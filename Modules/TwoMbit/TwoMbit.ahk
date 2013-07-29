MEmu = TwoMbit
MEmuV =  v1.0.5
MURL = http://sourceforge.net/projects/twombit/
MAuthor = djvj
MVersion = 2.0
MCRC = 867EC826
iCRC = E6F44714
MID = 635038268928134070
MSystem = "Sega Master System","Sega Game Gear"
;----------------------------------------------------------------------------
; Notes:
; Set fullscreen with the variable below
; Set your fullscreen resolution by starting the emu manually and going to Video->Fullscreen
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
bezelTopOffset := IniReadCheck(settingsFile, "Settings", "bezelTopOffset","51",,1)
bezelBottomOffset := IniReadCheck(settingsFile, "Settings", "bezelBottomOffset","8",,1)
bezelLeftOffset := IniReadCheck(settingsFile, "Settings", "bezelLeftOffset","8",,1)
bezelRightOffset := IniReadCheck(settingsFile, "Settings", "bezelRightOffset","8",,1)

BezelStart("FixResMode")
7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait(romName . " ahk_class QWidget")		; TwoMbit puts the emuPath and romName in the WinTitle 
WinWaitActive(romName . " ahk_class QWidget")

If Fullscreen = true
{	Sleep, 100
	Send, !{Enter}
}

BezelDraw()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


HaltEmu:
	Send, !{Enter}
	Sleep, 200
Return
RestoreEmu:
	Send, !{Enter}
Return

CloseProcess:
	FadeOutStart()
	WinClose(romName . " ahk_class QWidget")
Return

BezelLabel:
	disableHideTitleBar = true
	disableHideToggleMenu = true
	disableHideBorder = true
Return
