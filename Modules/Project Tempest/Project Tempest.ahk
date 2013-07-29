MEmu = Project Tempest
MEmuV =  v0.95
MURL = http://pt.emuunlim.com/
MAuthor = djvj
MVersion = 2.0
MCRC = F7CD0D
iCRC = 6FD26605
MID = 635038268916964773
MSystem = "Atari Jaguar"
;----------------------------------------------------------------------------
; Notes:
; Fullscreen mode controlled in HQ
; In the emu's gui, keep fullscreen off, otherwise the module will put it to windowed on launch.
; Set SelectGameMode if you have any problems with the emu opening the game
; Emu stores joypad config in registry (64-bit OS) @ HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Project Tempest
; Some games may not work correctly with PT and will popup with an address box. If this happens, try a different emu like Virtual Jaguar.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
SelectGameMode := IniReadCheck(settingsFile, "Settings", "SelectGameMode","1",,1)		;	1 = Uses a loop to detect the Edit Box has the romname and path in it. This doesn't work on all PCs, so if you get stuck at the open rom window, use mode 2. 2 = Uses a simple Ctrl+v to paste the romname and path, then press Enter to load the game.
ControlDelay := IniReadCheck(settingsFile, "Settings", "ControlDelay","40",,1)		; raise this if the module is getting stuck using SelectGameMode 1
KeyDelay := IniReadCheck(settingsFile, "Settings", "KeyDelay","-1",,1)				; raise this if the module is getting stuck using SelectGameMode 2

hideEmuObj := Object("ROM",0,"download",0)	;Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

SetControlDelay, %ControlDelay%	
SetKeyDelay, %KeyDelay%		

SetWinDelay, 10

Run(executable,emuPath)

WinWait("Project Tempest ahk_class PT")
WinWaitActive("Project Tempest ahk_class PT")

WinMenuSelectItem, Project Tempest ahk_class PT,, File, Open ROM

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

WinWaitActive("Open ROM File ahk_class #32770")

;Sleep just to ensure controls are accessible                      
Sleep,1000

If ( SelectGameMode = 1 ) {
	Loop {
		ControlGetText, edit1Text, Edit1, Open ROM File ahk_class #32770
		; ControlGet, Txt, Line, 1, Edit1, Open ROM File ahk_class #32770
		If ( edit1Text = romPath . "\" . romName . romExtension )
			Break
		Sleep, 100
		ControlSetText, Edit1, %romPath%\%romName%%romExtension%, Open ahk_class #32770
		; WinActivate, Open ROM File ahk_class #32770
	}
	ControlSend, Button2, {Enter}, Open ahk_class #32770 ; Select Open
} Else If ( SelectGameMode = 2 ) {
	Clipboard := romPath . "\" . romName . romExtension
	Send, ^v{Enter}
} Else
	ScriptError("You did not choose a valid SelectGameMode.`nOpen the module and set the mode at the top.")

Sleep, 1000

HideEmuEnd()

;Some roms might display download screen
IfWinActive, download
{	ControlClick, Cancel, download
	Goto Error
}

If Fullscreen = true
	Send, {Esc}

FadeInExit()
Process("WaitClose", executable)                                                                                                     
7zCleanUp()
FadeOutExit()
ExitModule()


Error:
    MsgBox, 0, Error, There was an error.`nTry running outside HL to see error., 2
    Goto CloseProcess
Return                                                                                

HaltEmu:
	Send, {Esc}
	Sleep, 200
Return
RestoreEmu:
	WinActivate, ahk_id  %emulatorID%
	Send, {Esc}
Return

CloseProcess:
	FadeOutStart()
	WinClose("Project Tempest ahk_class PT")
Return
