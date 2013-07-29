MEmu = BlueMSX
MEmuV = v2.8.2
MURL = http://www.bluemsx.com/
MAuthor = djvj
MVersion = 2.0
MCRC = C4C70FB5
iCRC = 6DC9C5DF
MID = 635038268875990669
MSystem = "ColecoVision","Microsoft MSX","Microsoft MSX2"
;----------------------------------------------------------------------------
; Notes:
; Set your fullscreen res manually in the emu by clicking Options->Performance->Fullscreen Resolution
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "settings", "Fullscreen","true",,1)
Stretch := IniReadCheck(settingsFile, "settings", "Stretch","false",,1)

bluemsxINI := CheckFile(emuPath . "\bluemsx.ini")

IniRead, currentFullscreen, %bluemsxINI%, config, video.windowSize
IniRead, currentStretch, %bluemsxINI%, config, video.horizontalStretch

; Setting Fullscreen setting in ini if it doesn't match what user wants above
If ( Fullscreen != "true" And currentFullScreen = "fullscreen" )
	IniWrite, normal, %bluemsxINI%, config, video.windowSize
Else If ( Fullscreen = "true" And currentFullScreen = "normal" )
	IniWrite, fullscreen, %bluemsxINI%, config, video.windowSize

; Setting Stretch setting in ini if it doesn't match what user wants above
If ( Stretch != "true" And currentStretch = "yes" )
	IniWrite, no, %bluemsxINI%, config, video.horizontalStretch
Else If ( Stretch = "true" And currentStretch = "no" )
	IniWrite, yes, %bluemsxINI%, config, video.horizontalStretch

7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("blueMSX ahk_class blueMSX")
WinWaitActive("blueMSX ahk_class blueMSX")

Sleep, 2000 ; need this otherwise Hyperspin flashes back in during fade

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("blueMSX ahk_class blueMSX")
Return
