MEmu = MakaronEX
MEmuV = v4.01
MURL = http://www.emu-land.net/consoles/dreamcast/emuls/windows
MAuthor = djvj
MVersion = 2.0
MCRC = 9D280D62
iCRC = F81CB862
MID = 635038268902883049
MSystem = "Sega Dreamcast","Sega Naomi"
;----------------------------------------------------------------------------
; Notes:
; Set fullscreen via the variable below
; Set SelectGameMode if you have any problems with the emu opening the game
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
HideLoading := IniReadCheck(settingsFile, "Settings", "HideLoading","true",,1)				;	This speeds up loading roms but can cause some PCs to get stuck at the Open Rom window. Disable it if you have this issue
SelectGameMode := IniReadCheck(settingsFile, "Settings", "SelectGameMode","1",,1)		;	1 = Uses a loop to detect the Edit Box has the romname and path in it. This doesn't work on all PCs, so if you get stuck at the open rom window, use mode 2. 2 = Uses a simple Ctrl+v to paste the romname and path, then press Enter to load the game.
ControlDelay := IniReadCheck(settingsFile, "Settings", "ControlDelay","40",,1)			; raise this if the module is getting stuck using SelectGameMode 1
KeyDelay := IniReadCheck(settingsFile, "Settings", "KeyDelay","-1",,1)					; raise this if the module is getting stuck using SelectGameMode 2

SetControlDelay, %ControlDelay%	; raise this if the module is getting stuck using SelectGameMode 1
SetKeyDelay, %KeyDelay%		; raise this if the module is getting stuck using SelectGameMode 2

If systemName contains naomi
	makINI := CheckFile(emuPath . "\Naomi\Naomi.ini")
Else If systemName contains dreamcast,dc
	makINI := CheckFile(emuPath . "\Dreamcast\Makaron.ini")
Else
	ScriptError(systemName . " is not a recognized (aka supported) System Name for this module")

IniRead, currentFullScreen, %makINI%, Settings, fullscreen

; Setting Fullscreen setting in ini if it doesn't match what user wants above
If ( Fullscreen != "true" And currentFullScreen = 1 )
	IniWrite, 0, %makINI%, Settings, fullscreen
Else If ( Fullscreen = "true" And currentFullScreen = 0 )
	IniWrite, 1, %makINI%, Settings, fullscreen

Run(executable, emuPath, (If InStr(systemName,"naomi") ? "hide":""))

If HideLoading = true
	SetTimer, WaitForDialogEmu, 2

WinWait("MakaronEX ahk_class TForm1")
WinWaitActive("MakaronEX ahk_class TForm1")
If systemName contains naomi
{	; ControlClick, TToolBar1, MakaronEX ahk_class TForm1,, L,1,x240 y5 ; Click Naomi on Toolbar
	Control, Check,, TToolBar1, MakaronEX ahk_class TForm1 ; Somehow this selects Naomi on Toolbar... mmkay
	WinMenuSelectItem, MakaronEX ahk_class TForm1,, File, Open Rom, 2& ; Open Naomi T12.7 roms
	makEXTitle = NAOMI - PVR ahk_class PVR2
} Else If systemName contains dreamcast,dc
{	WinMenuSelectItem, MakaronEX ahk_class TForm1,, File, Open Image ; Open Image for dreamcast
	makEXTitle = Makaron - PVR ahk_class PVR2
}

;This fully ensures dialogs are completely hidden even faster than winwait
If HideLoading = true
	SetTimer, WaitForDialog, 2

WinWait("Open ahk_class #32770")
WinWaitActive("Open ahk_class #32770")

If ( SelectGameMode = 1 ) {
	Loop {
		ControlGetText, edit1Text, Edit1, Open ahk_class #32770
		If ( edit1Text = romPath . "\" . romName . romExtension )
			Break
		Sleep, 100
		ControlSetText, Edit1, %romPath%\%romName%%romExtension%, Open ahk_class #32770
	}
	ControlSend, Button2, {Enter}, Open ahk_class #32770 ; Select Open
} Else If ( SelectGameMode = 2 ) {
	Clipboard := romPath . "\" . romName . romExtension
	Send, ^v{Enter}
} Else
	ScriptError("You did not choose a valid SelectGameMode.`nOpen the module and set the mode at the top.")

If HideLoading = true
{	SetTimer, WaitForDialog, Off
	SetTimer, WaitForDialogEmu, Off
}

WinWait(makEXTitle)
WinWaitActive(makEXTitle)

FadeInExit()
Process("WaitClose", executable)
FadeOutExit()
ExitModule()


WaitForDialogEmu:
	IfWinNotExist, MakaronEX ahk_class TForm1
		Return
	Else
		WinSet, Transparent, 0, MakaronEX ahk_class TForm1
Return
WaitForDialog:
	IfWinNotExist, Open ahk_class #32770
		Return
	Else
		WinSet, Transparent, 0, Open ahk_class #32770
Return

HaltEmu:
	If fullscreen = true
		disableActivateBlackScreen = true
Return

CloseProcess:
	FadeOutStart()
	If WinActive("MakaronEX ahk_class TForm1")
		WinClose("MakaronEX ahk_class TForm1")
	Else {
		ControlSend,, {F8}, %makEXTitle%
		WinWait("MakaronEX ahk_class TForm1")
		WinActivate, MakaronEX ahk_class TForm1
		WinClose("MakaronEX ahk_class TForm1")
	}
Return
