MEmu = Steem SSE
MEmuV =  v3.6.4
MURL = http://sourceforge.net/projects/steemsse/
MAuthor = ghutch92
MVersion = 2.0.1
MCRC = 55672341
iCRC = F07D360E
MID = 635038268925531896
MSystem = "Atari ST"
;----------------------------------------------------------------------------
; Notes:
; This is for the updated SSE edition, not the original Steem which ended at v3.2
; You must manually set a TOS using the emulator first. The UK version is preferred. 
; If a game does not work properly check to see if there is a patch available.
; Be sure to read the controller options very carefully since sometimes your controls 
; might only work if Scroll Lock is on or Num Lock is off. This needs to be set from 
; within the emulator.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
bezelTopOffset := IniReadCheck(settingsFile, "Settings", "bezelTopOffset",20,,1)
bezelBottomOffset := IniReadCheck(settingsFile, "Settings", "bezelBottomOffset",0,,1)
bezelLeftOffset := IniReadCheck(settingsFile, "Settings", "bezelLeftOffset",0,,1)
bezelRightOffset := IniReadCheck(settingsFile, "Settings", "bezelRightOffset",10,,1)

hideEmuObj := Object("ahk_class Steem Window",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

BezelStart()
HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait
Run(executable . (fullscreen = "true" ? " -fullscreen" : "") . " -nonotifyinit """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("ahk_class Steem Window")
WinWaitActive("ahk_class Steem Window")
BezelDraw()
HideEmuEnd()
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
	BezelExit()
	WinClose("ahk_class Steem Window")
Return
