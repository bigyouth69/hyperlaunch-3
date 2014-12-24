MEmu = Project Tempest
MEmuV =  v0.95
MURL = http://pt.emuunlim.com/
MAuthor = djvj/faahrev
MVersion = 2.0.2
MCRC = 976AFE87
iCRC = 109E182B
mId = 635224813748790881
MSystem = "Atari Jaguar","Atari Jaguar CD"
;----------------------------------------------------------------------------
; Notes:
; Fullscreen mode controlled in HQ
; In the emu's gui, keep fullscreen off, otherwise the module will put it to windowed on launch.
; Emu stores joypad config in registry (64-bit OS) @ HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Project Tempest
; Some games may not work correctly with PT and will popup with an address box. If this happens, try a different emu like Virtual Jaguar.
;----------------------------------------------------------------------------
StartModule()
BezelGui()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
ControlDelay := IniReadCheck(settingsFile, "Settings", "ControlDelay","40",,1)		; raise this if the module is getting stuck using SelectGameMode 1
KeyDelay := IniReadCheck(settingsFile, "Settings", "KeyDelay","-1",,1)				; raise this if the module is getting stuck using SelectGameMode 2

dialogOpen := i18n("dialog.open")	; Looking up local translation

BezelStart()

hideEmuObj := Object("ROM",0,"download",0,"Project Tempest ahk_class PT",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

SetControlDelay, %ControlDelay%	
SetKeyDelay(KeyDelay)

SetWinDelay, 10

Run(executable,emuPath)

WinWait("Project Tempest ahk_class PT")
WinWaitActive("Project Tempest ahk_class PT")

If (romExtension = ".cdi") {
	WinMenuSelectItem, Project Tempest ahk_class PT,, File, Open CD Image
	HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait
	WindowText := "Open CD Image"
	WinWaitActive("Open CD Image ahk_class #32770")
} Else {
	WinMenuSelectItem, Project Tempest ahk_class PT,, File, Open ROM
	HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait
	WindowText := "Open ROM File"
	WinWaitActive("Open ROM File ahk_class #32770")
}

OpenROM(dialogOpen . " ahk_class #32770", romPath . "\" . romName . romExtension)
WinWaitActive("Project Tempest ahk_class PT")

HideEmuEnd()

;Some roms might display download screen
IfWinActive, download
{	ControlClick, Cancel, download
	Goto Error
}

If Fullscreen = true
	Send, {Esc}

BezelDraw()
FadeInExit()
Process("WaitClose", executable)                                                                                                     
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


Error:
    Log("There was an error. Try running outside HL to see error.",3)
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
