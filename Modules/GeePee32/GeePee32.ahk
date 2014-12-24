MEmu = GeePee32
MEmuV = v0.43
MURL = http://users.skynet.be/firefly/gp32/
MAuthor = djvj
MVersion = 2.0.2
MCRC = 8FBC03D8
iCRC = 93050FEB
MID = 635038268896027346
MSystem = "GamePark 32"
;----------------------------------------------------------------------------
; Notes:
; This emu has no sound
; Roms must be unzipped
; Turn the splash screen off by setting splash=0 in the geepee32.ini
; CLI is broken in the latest v.043. Script launches games manually instead
; There is no maximize or fullscreen option, so the script handles it manually
; If you have GeePee32 controls set up to use the keyboard with QWERTY keyboard type, the A button is *always* assigned to the Q key on your keyboard no matter what you do.
; Even if you make the change in the emulator's ini file, the emulator will always set it to Q due to a bug in it. If you use Q for anything else in your usual setup, you will need to make a custom xpadder profile to handle this properly.

;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
SelectGameMode := IniReadCheck(settingsFile, "Settings", "SelectGameMode","1",,1)	; 1 = Uses a loop to detect the Edit Box has the romname and path in it. This doesn't work on all PCs, so if you get stuck at the open rom window, use mode 2. 2 = Uses a simple Ctrl+v to paste the romname and path, then press Enter to load the game.

hideEmuObj := Object("AHK_class #32770",0,"AHK_class TFormMain",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

SetKeyDelay(50)
Run(executable, emuPath)
WinWait("AHK_class TFormMain")
WinWaitActive("AHK_class TFormMain")

If romExtension = .smc
	Send, {Alt}fls ; Open File for .smc
Else
	Send, {Alt}flb ; Open file for .gxb, .fxe, .elf, .axf

WinWait("AHK_class #32770")
WinWaitActive("AHK_class #32770")
If ( SelectGameMode = 1 ) {
	Loop {
		ControlGetText, edit1Text, Edit1, Open ahk_class #32770
		If ( edit1Text = romPath . "\" . romName . romExtension )
			Break
		Sleep, 100
		ControlSetText, Edit1, %romPath%\%romName%%romExtension%, Open ahk_class #32770
	}
	ControlSend, Button2, {Enter}, AHK_class #32770 ; Select Open
} Else If ( SelectGameMode = 2 ) {
	Clipboard := romPath . "\" . romName . romExtension
	Send, ^v{Enter}
} Else
	ScriptError("You did not choose a valid SelectGameMode.`nOpen the module and set the mode at the top.")

WinWaitActive("AHK_class TFormMain")
Send, {F5} ; Start emulation

WinSet, Style, -0xC00000, AHK_class TFormMain ; Removes the titlebar of the game window
WinSet, Style, -0x40000, AHK_class TFormMain ; Removes the border of the game window
Control, Hide, , TActionMainMenuBar1, AHK_class TFormMain ; Removes the MenuBar
Control, Hide, , TStatusBar1, AHK_class TFormMain ; Removes the StatusBar
Control, Hide, , TActionToolBar1, AHK_class TFormMain ; Removes the ActionToolBar

; Go Fullscreen
If fullscreen = true
{	Sleep, 300
	MaximizeWindow("AHK_class TFormMain")
}

HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


Center(title) {
	WinGetPos, x, y, width, height, %title%
	x := ( A_ScreenWidth / 2 ) - ( width / 2 )
	y := ( A_ScreenHeight / 2 ) - ( height / 2 )
	WinMove, %title%, , x, y
}

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
	Log("Module - Sending ALT+F4 to close emu")
	Send, !{F4}
	Sleep, 200
	IfWinExist, AHK_class TMessageForm ; some games will ask to save settings, this selects No. Change to TButton2 to select Yes if you prefer.
		ControlSend, TButton1, {Enter}, AHK_class TMessageForm
Return
