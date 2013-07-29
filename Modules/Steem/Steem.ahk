MEmu = Steem
MEmuV =  v3.4.1
MURL = http://sourceforge.net/projects/steemsse/
MAuthor = ghutch92
MVersion = 2.0
MCRC = 4DB34981
iCRC = 1E716C97
MID = 635038268925531896
MSystem = "Atari ST"
;----------------------------------------------------------------------------
; Notes:
; You must manually set a TOS using the emulator first. The UK version is preferred. 
; If a game does not work properly check to see if there is a patch available.
; Be sure to read the controller options very carefully since sometimes your controls 
; might only work if Scroll Lock is on or Num Lock is off. This needs to be set from 
; within the emulator.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable . " " . ((Fullscreen = "true") ? ("-fullscreen") : ("")) . " -nonotifyinit """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("ahk_class Steem Window")
WinWaitActive("ahk_class Steem Window")

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


RestoreEmu: 
	Send, {Pause} 
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class Steem Window")
Return
