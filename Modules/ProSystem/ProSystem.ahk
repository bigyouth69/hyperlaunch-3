MEmu = ProSystem
MEmuV =  v1.3
MURL = http://home.comcast.net/~gscottstanton/
MAuthor = djvj & brolly
MVersion = 2.0
MCRC = 820B91D9
iCRC = 215426C3
MID = 635038268919086546
MSystem = "Atari 7800"
;----------------------------------------------------------------------------
; Notes:
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
StartWindowed := IniReadCheck(settingsFile, "Settings", "StartWindowed","true",,1)	; When launching ROMs from the command line, the sound is a second or two behind the action, regardless of the sound latency setting, set this to true if you want to fix it

proSysINI := CheckFile(emuPath . "\ProSystem.ini")

IniRead, currentFullScreen, %proSysINI%, Display, Fullscreen
IniRead, Menu, %proSysINI%, Display, MenuEnabled

; Setting Fullscreen setting in ini if it doesn't match what user wants above
If ( Fullscreen = "true" And currentFullScreen = "false" And StartWindowed != "true")
	IniWrite, true, %proSysINI%, Display, Fullscreen
Else If ( StartWindowed = "true" Or (Fullscreen != "true" And currentFullScreen = "true") )
	IniWrite, false, %proSysINI%, Display, Fullscreen

; Disable the emu's menu if it's active
If Menu != false
	IniWrite, false, %proSysINI%, Display, MenuEnabled

7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("ahk_class ProSystem Emulator")
WinWaitActive("ahk_class ProSystem Emulator")

If ( Fullscreen = "true" And StartWindowed = "true")
{	;Make it fullscreen
	Sleep, 200
	Send, ^f
}

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class ProSystem Emulator")
Return
