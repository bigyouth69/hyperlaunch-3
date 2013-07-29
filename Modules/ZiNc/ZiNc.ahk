MEmu = Zinc
MEmuV = v1.1
MURL = http://www.emulator-zone.com/doc.php/arcade/zinc.html
MAuthor = djvj
MVersion = 2.0.1
MCRC = 3993C28F
iCRC = DD494A5C
MID = 635038268938302527
MSystem = "ZiNc"
;----------------------------------------------------------------------------
; Notes:
; Script relies on a zinc.cfg in the emu dir which contains all the parameters sent to the emu
; This is made for you by using Aldo's ZiNc Front-End v2.2.
; Zinc uses numbers, not romnames to choose what game to load. Your database's game names should reflect this.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

rendFile := CheckFile(emuPath . "\renderer.cfg")
FileRead, rendCFG, %rendFile%

; Setting Fullscreen setting in cfg if it doesn't match what user wants above
currentFullScreen := (InStr(rendCFG, "FullScreen = 1") ? ("true") : ("false"))
If ( Fullscreen != "true" And currentFullScreen = "true" ) {
	StringReplace, rendCFG, rendCFG, FullScreen = 1, FullScreen = 0
	StringReplace, rendCFG, rendCFG, StartFullScreen = true, StartFullScreen = false
	Save = 1
} Else If ( Fullscreen = "true" And currentFullScreen = "false" ) {
	StringReplace, rendCFG, rendCFG, FullScreen = 0, FullScreen = 1
	StringReplace, rendCFG, rendCFG, StartFullScreen = false, StartFullScreen = true
	Save = 1
}

If Save
	SaveFile(rendCFG, rendFile)

Run(executable . " " . romName . " ""--use-config-file=zinc.cfg""",emuPath) ;, Hide
WinWait("ZiNc ahk_class WinZincWnd")
WinWaitActive("ZiNc ahk_class WinZincWnd")
WinHide, ZiNc ahk_class ConsoleWindowClass ; prevents the console window from popping into view

FadeInExit()
Process("WaitClose", executable)
FadeOutExit()
ExitModule()


SaveFile(text,file) {
	FileDelete, %file%
	FileAppend, %text%, %file%
}

HaltEmu:
	disableSuspendEmu = true
	Send, {End down}{End up}
Return
RestoreEmu:
	WinActivate, ahk_id  %emulatorID%
	Sleep, 200
	Send, {End down}{End up}
Return

CloseProcess:
	FadeOutStart()
	WinClose("ZiNc ahk_class WinZincWnd")
Return
