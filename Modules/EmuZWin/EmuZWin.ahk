MEmu = EmuZWin
MEmuV =  v2.7
MURL = http://kolmck.net/apps/EmuZ/EmuZWin_Eng.htm
MAuthor = faahrev
MVersion = 1.0
MCRC = 8E791966
iCRC = 1E716C97
mId = 635224818053263550
MSystem = "Sinclair ZX Spectrum"
;----------------------------------------------------------------------------
; Notes:
; Game always starts in Fullscreen mode
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "fullscreen","true",,1)

BezelStart()

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("EmuZWin v2.7 ahk_class obj_Form")
WinWaitActive("EmuZWin v2.7 ahk_class obj_Form")

If (Fullscreen = "true") {
	WinActivate EmuZWin v2.7 ahk_class obj_Form
	PostMessage, 0x111, 4225,,, A
}

BezelDraw()
FadeInExit()
Process("WaitClose", executable)
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	; Reset All for next time start
	WinActivate EmuZWin v2.7 ahk_class obj_Form
	PostMessage, 0x111, 4125, 0, , A
	WinWait("EmuZWin v2.7 ahk_class obj_Form")
	FadeOutStart()
	WinClose("EmuZWin v2.7 ahk_class obj_Form")
Return
