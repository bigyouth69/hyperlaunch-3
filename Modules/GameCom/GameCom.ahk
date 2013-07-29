MEmu = GameCom
MEmuV = v29/12/1998
MURL =
MAuthor = djvj
MVersion = 2.0.1
MCRC = BE94305
iCRC = CCF77D79
MID = 635038268895496903
MSystem = "Tiger Game.com"
;----------------------------------------------------------------------------
; Notes:
; Make sure you have ALL the roms on the emulator dir and also the following files: BITMAP2.BIN, MAIN.HEX, MAIN0.HEX, & MAIN0S.HEX
; Roms must be unzipped
; If you do not have an English windows, set the language you use for the MLanguage setting in HLHQ. Currently only Spanish/Portuguese is supported.
;
; Keys:
; A,S,Z,X - A,B,C,D (like the console layout)
; F2 - Reset
; F3 - Mute
; F4 - Pause (this seems to reboot the console also)
; Arrows - Digital pad
; Aiming in Resident Evil 2 goes with Z. Then A is shooting
;----------------------------------------------------------------------------
StartModule()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
ShowIntro := IniReadCheck(settingsFile, "Settings", "ShowIntro","false",,1)				; Show the Tiger Logo before the main menu, cannot autostart games if true
AutoStartGame := IniReadCheck(settingsFile, "Settings", "AutoStartGame","true",,1)			; Will only work if ShowIntro is false
BlockInput := IniReadCheck(settingsFile, "Settings", "BlockInput","false",,1)				; Set to true if the module works for you and you don't want foreign key presses disturbing the launch process
errorFix := IniReadCheck(settingsFile, "Settings", "errorFix","false",,1)						; Set to true if you get a windows no disk error after the emu starts. It has been reported to happen on 32-bit OSes. This adds 2 seconds to launch if you don't get the error, so set to false for a quicker launch if you never see the error.
MLanguage := IniReadCheck(settingsFile, "Settings", "MLanguage","English",,1)		; If English, dialog boxes look for the word "Open" and if Spanish/Portuguese, looks for "Abrir"

mLang := Object("English","Open","Spanish/Portuguese","Abrir")
winLang := mLang[MLanguage]	; search object for the MLanguage associated to the user's language
If !winLang
	ScriptError("Your chosen language is: """ . MLanguage . """. It is not one of the known supported languages for this module: " . moduleName)

hideEmuObj := Object("Game.Com Emulator ahk_class #32770",1,"Windows - No Disk ahk_class #32770",0,"Disassemble Window ahk_class #32770",0,winLang . " ahk_class #32770",0,"Input ahk_class #32770",0)	;Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later

If fadeIn = true
{
	FadeInStart()
	Gui 5: +LastFound
	WinGet GUI_ID5, ID
	Gui 5: -AlwaysOnTop -Caption +ToolWindow
	StringTrimLeft,fadeColor,fadeLyr1Color,2
	Gui 5: Color, %fadeColor%
	Gui 5: Show, x0 y0 h%A_ScreenHeight% w%A_ScreenWidth%
}

7z(romPath, romName, romExtension, 7zExtractPath)

errorLvl := Run(executable, emuPath, "UseErrorLevel")

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

If errorLvl != 0
{	MsgBox, 48, Exe Error, Error launching emulator`, closing script., 5
	ExitModule()
}

If BlockInput = true
	BlockInput, On

If errorFix = true
{	DetectHiddenWindows, on
	WinWait("Windows - No Disk ahk_class #32770",,,2)
	ControlClick, Button3, Windows - No Disk ahk_class #32770
}

WinWait("Game.Com Emulator ahk_class #32770")
Loop { ; What window is active at launch determines how the script will react
	IfWinActive, Game.Com Emulator ahk_class #32770
		Break
	IfWinActive Disassemble Window ahk_class #32770
		Goto DisWindow
}

; If disassembly window didn't open, lets open it
IfWinNotExist, Disassemble Window ahk_class #32770
	WinMenuSelectItem, Game.Com Emulator ahk_class #32770,, Window, Open Disasm Window

DisWindow:
WinWait("Disassemble Window ahk_class #32770") ; waiting for disassemble window to open
WinWaitActive("Disassemble Window ahk_class #32770")
WinMenuSelectItem, Disassemble Window ahk_class #32770,, File, Load BIN File
WinWait(winLang . " ahk_class #32770") ; Waiting for window to open to select the rom
WinWaitActive(winLang . " ahk_class #32770")
Loop { ; looping this so we don't need a sleep timer, usually 2nd loop text gets pasted in correctly
	ControlGetText, edit1Text, Edit1, %winLang% ahk_class #32770
	If ( edit1Text = romPath . "\" . romName . romExtension )
		Break
	Sleep, 100
	ControlSetText, Edit1, %romPath%\%romName%%romExtension%, %winLang% ahk_class #32770
}
Send {Enter}
WinWait("Input ahk_class #32770") ; waiting for input box to appear
WinWaitActive("Input ahk_class #32770")
Send {Enter}
WinWait("Disassemble Window ahk_class #32770") ; waiting for disassemble window to come back into focus
WinWaitActive("Disassemble Window ahk_class #32770")
If ShowIntro = true
	WinMenuSelectItem, Disassemble Window ahk_class #32770,, File, Load Kernel., Full Kernel
Else
	WinMenuSelectItem, Disassemble Window ahk_class #32770,, File, Load Kernel., Test Kernel
Control, Check,, Button4, Disassemble Window ahk_class #32770
WinHide, Disassemble Window ahk_class #32770 ; hide the disassemble window so we don't see it in the background

; Remove window elements
If Fullscreen = true
{	WinSet, Style, -0xC00000, Game.Com Emulator ahk_class #32770 ; Removes the TitleBar
	DllCall("SetMenu", uint, WinActive( "A" ), uint, 0) ; Removes the MenuBar
	WinSet, Style, -0x40000, Game.Com Emulator ahk_class #32770 ; Removes the border of the game window
	Sleep, 600 ; Need this otherwise the game window snaps back to size, increase if this occurs
}

If AutoStartGame = true
{	SetKeyDelay 200 ; increase if keys are not being sent to the main menu
	Sleep, 500 ; increase if keys are being sent to early
	Send {Right Down}{Right Up}{a Down}{a Up}
}

If Fullscreen = true
	MaximizeWindow("Game.Com Emulator ahk_class #32770")

HideEmuEnd()
FadeInExit()

BlockInput, Off
Process("WaitClose", executable)

7zCleanUp()
FadeOutExit()
ExitModule()


MaximizeWindow(class) {
	WinGetPos, appX, appY, appWidth, appHeight, %class%
	widthMaxPercenty := ( A_ScreenWidth / appWidth )
	heightMaxPercenty := ( A_ScreenHeight / appHeight )

	If  ( widthMaxPercenty < heightMaxPercenty )
		percentToEnlarge := widthMaxPercenty
	Else
		percentToEnlarge := heightMaxPercenty

	appWidthNew := appWidth * percentToEnlarge
	appHeightNew := appHeight * percentToEnlarge
	Transform, appX, Round, %appX%
	Transform, appY, Round, %appY%
	Transform, appWidthNew, Round, %appWidthNew%, 2
	Transform, appHeightNew, Round, %appHeightNew%, 2
	appXPos := ( A_ScreenWidth / 2 ) - ( appWidthNew / 2 )
	appYPos := ( A_ScreenHeight / 2 ) - ( appHeightNew / 2 )
	WinMove, %class%,, appXPos, appYPos, appWidthNew, appHeightNew
}

CloseProcess:
	FadeOutStart()
	WinClose("Game.Com Emulator ahk_class #32770")
Return
