MEmu = Gambatte
MEmuV =  v0.5.0 wip2
MURL = http://gambatte.sourceforge.net/
MAuthor = djvj
MVersion = 2.0.1
MCRC = E1C43318
iCRC = 1D7189D6
MID = 635038268894976488
MSystem = "Nintendo Game Boy","Nintendo Game Boy Color"
;----------------------------------------------------------------------------
; Notes:
; Gambatte stores it's config in the registry @ HKEY_CURRENT_USER\Software\gambatte
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
bezelTopOffset := IniReadCheck(settingsFile, "Settings", "bezelTopOffset","22",,1)
bezelLeftOffset := IniReadCheck(settingsFile, "Settings", "bezelLeftOffset","11",,1)
bezelRightOffset := IniReadCheck(settingsFile, "Settings", "bezelRightOffset","11",,1)

BezelStart()
7z(romPath, romName, romExtension, 7zExtractPath)

fullscreen := (If Fullscreen = "true" ? ("-full") : (""))

; This allows us to send variables, that when empty, are not sent to the Run command
Run(executable . " " . fullscreen . " """ . romPath . "\" . romName . romExtension . """", emuPath) ;, "Min")

WinWait("Gambatte ahk_class QWidget")
WinWaitActive("Gambatte ahk_class QWidget")

BezelDraw()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("Gambatte ahk_class QWidget")
Return

