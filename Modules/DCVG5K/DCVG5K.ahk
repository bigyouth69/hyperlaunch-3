MEmu = DCVG5K
MEmuV = v1.5
MURL = http://dcvg5k.free.fr/
MAuthor = djvj
MVersion = 2.0.1
MCRC = F01E031C
iCRC = 800B124B
MID = 635038268880784660
MSystem = "Philips VG 5000"
;------------------------------------------------------------------------
; Notes:
; Roms must be unzipped
; US Rally game looks frozen, but it's a side effect of going fullscreen and the emu not redrawing the game select screen. Just press 1 or 2 and it will launch
; Emu doesnt work right and is very slow in Win8. Also sometimes takes awhile to close.
;------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "settings", "Fullscreen","true",,1)
RestoreTaskbar := IniReadCheck(settingsFile, "settings", "RestoreTaskbar","true",,1)
SelectGameMode := IniReadCheck(settingsFile, "settings", "SelectGameMode","1",,1)
MLanguage := IniReadCheck(settingsFile, "Settings", "MLanguage","English",,1)		; If English, dialog boxes look for the word "Open" and if Spanish/Portuguese, looks for "Abrir"

mLang := Object("English","Open","Spanish/Portuguese","Abrir")
winLang := mLang[MLanguage]	; search object for the MLanguage associated to the user's language
If !winLang
	ScriptError("Your chosen language is: """ . MLanguage . """. It is not one of the known supported languages for this module: " . moduleName)

hideEmuObj := Object("Open ahk_class #32770",0,"ahk_class VG5000",1)	;Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable, emuPath)

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

WinWait("ahk_class VG5000")
WinActivate, ahk_class VG5000
Send, {ALT}{DOWN}{ENTER}

Sleep, 50
WinWait(winLang . " ahk_class #32770")
WinWaitActive(winLang . " ahk_class #32770")
Sleep, 100

If ( SelectGameMode = 1 ) {
	Loop {
		ControlGetText, edit1Text, Edit1, %winLang% ahk_class #32770
		If ( edit1Text = romPath . "\" . romName . romExtension )
			Break
		Sleep, 100
		ControlSetText, Edit1, %romPath%\%romName%%romExtension%, %winLang% ahk_class #32770
	}
	ControlSend, Button1, {Enter}, %winLang% ahk_class #32770 ; Select Open
} Else If ( SelectGameMode = 2 ) {
	Clipboard := romPath . "\" . romName . romExtension
	Send, ^v{Enter}
} Else
	ScriptError("You did not choose a valid SelectGameMode.`nOpen the module and set the mode at the top.")

WinWaitActive("ahk_class VG5000")
Sleep, 1200 ; increase if CLOAD is not appearing in the emu window or some just some letters
SetKeyDelay, 50
Send, {C down}{C up}{L down}{L up}{O down}{O up}{Q down}{Q up}{D down}{D up}{ENTER down}{ENTER up} ; necessary for the emu to pick up on the key presses
Sleep, 1000 ; increase if you see the blue emu screen while you are in fullscreen

HideEmuEnd()

If Fullscreen = true
	Send, {PGUP}

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()

If RestoreTaskbar = true
	WinShow, ahk_class Shell_TrayWnd

ExitModule()


HaltEmu:
	Send, {Alt down}{Alt up}
Return
RestoreEmu:
	WinRestore, ahk_class VG5000
	WinActivate, ahk_class VG5000
	If Fullscreen = true
		Send, {PGUP}
Return

CloseProcess:
	FadeOutStart()
	Send, {Alt down}{Alt up}
	WinClose("ahk_class VG5000")
Return
