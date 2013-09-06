; Author: djvj
; Purpose: Handle launcher windows for PC Games. These windows pop up before the game and usually require some type of input or button you have to press to start the game.
; Notes: Super Mario Bros X does not respond to removing of the title bar or border with WinSet. It is suggested to leave KeepAspect set to false because the window will have these elements hidden.
;----------------------------------------------------------------------------------------------------
; Launcher Settings:
; this should be the window information from the launcher window where we need to intervene before the game launches
LauncherWindow = Super Mario Bros. X ahk_class ThunderRT6FormDC
; this should be the window information from the game itself so we know when to continue the script
GameWindow = Super Mario Bros. X ahk_class ThunderRT6FormDC
; Set to true if you want the script to make the game as big as possible
Fullscreen = true
; Set to true if you want the script to keep the aspect ratio of the game.
KeepAspect = false
; Set to true if you want the script to move the mouse off screen on launch to avoid the cursor from being seen.
MoveMouse = true
;----------------------------------------------------------------------------------------------------

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, -1	; script will run as fast as possible

WinWait, %LauncherWindow%,,10	; waiting 10 seconds for the launcher window to show
If !ErrorLevel
{	WinSet, Transparent, %LauncherWindow%
	WinActivate, %LauncherWindow%
	ControlClick, ThunderRT6CommandButton3, %LauncherWindow%
} Else {	; If window never showed, error and exit
	MsgBox,,PostLaunch Script, LauncherWindow may be set wrong in this script or it never appeared`, please edit this script's ahk`, recompile`, and try again.`n`nLauncherWindow: %LauncherWindow%,6	; showing msgbox for 6 seconds
	Goto, ExitScript
}

If Fullscreen = true
{	WinWait, %GameWindow%,,10	; waiting 10 seconds for the game window to show
	If !ErrorLevel
	{	WinWaitActive, %GameWindow%,,10	; need to wait until the window is active otherwise WinGetPos may return 0 for width and height
		If KeepAspect = true
			MaximizeWindow(GameWindow)
		Else
			PostMessage, 0x112, 0xF030,,, %GameWindow%	; maximize the game window
		WinActivate, %GameWindow%
	} Else	; If window never showed, error and exit
		MsgBox,,PostLaunch Script, GameWindow may be set wrong in this script or it never appeared`, please edit this script's ahk`, recompile`, and try again.`n`nGameWindow: %GameWindow%,6	; showing msgbox for 6 seconds
}

If MoveMouse = true
	MouseMove, %A_ScreenWidth%, %A_ScreenHeight%

ExitScript:
ExitApp


MaximizeWindow(class){
	WinSet, Style, -0xC00000, %class%	;Removes the titlebar of the game window
	WinSet, Style, -0x40000, %class%		;Removes the border of the game window
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
