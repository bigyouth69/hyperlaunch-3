MEmu = PPSSPP
MEmuV =  v0.7.6-15
MURL = http://www.ppsspp.org/
MAuthor = djvj
MVersion = 2.0.1
MCRC = 38E1B00D
iCRC = 86DE2C7A
MID = 635038268916444338
MSystem = "Sony PSP"
;----------------------------------------------------------------------------
; Notes:
; CLI options: http://forums.ppsspp.org/showthread.php?tid=339&pid=17117#pid17117
; Compatibility List: http://forums.ppsspp.org/showthread.php?tid=1473
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
bezelSleep := IniReadCheck(settingsFile, "Settings", "bezelSleep","1500",,1) ; in miliseconds, if you are using the bezel view and your screen does not fit correctly in the bezel, try to increase this value.

BezelStart()
7z(romPath, romName, romExtension, 7zExtractPath)

ppssppINI := CheckFile(emuPath . "\ppsspp.ini")
iniRead, currentFullScreen, %ppssppINI%, Graphics, FullScreen

; Setting Fullscreen setting in ini if it doesn't match what user wants above
If ( Fullscreen != "true" And currentFullScreen = "True" )
	IniWrite, False, %ppssppINI%, Graphics, FullScreen
Else If ( Fullscreen = "true" And currentFullScreen = "False" )
	IniWrite, True, %ppssppINI%, Graphics, FullScreen

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emupath)

WinActivate, PPSSPP ahk_class PPSSPPWnd
WinWaitActive("PPSSPP ahk_class PPSSPPWnd")

If bezelPath
	Sleep, %bezelSleep%

BezelDraw()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("PPSSPP ahk_class PPSSPPWnd")
Return
