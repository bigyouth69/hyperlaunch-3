GamePath=D:\PC Games\Fix-It Felix Jr\Game\FixitFelixJr.exe		; the full path and exe of FixitFelixJr.exe
BezelPath=D:\PC Games\Fix-It Felix Jr\Game\bezel.png		; the full path and extension to bezel file
zoom=200		; Frame Resolution-Only 33,50,100,200 are supported
YAdjust=0	; adjusts vertically how far off center from the middle of the screen, 0=center, negative value moves up, positive value moves down
XAdjust=0 	; adjusts horizontally how far off center from the middle of the screen, 0=center, negative value moves to left, positive value moves to right
title=ahk_class FOCAL Test Shell
ShowBezel=true
BackgroundColor=yellow	; changes background color, see here for available colors: http://www.autohotkey.com/docs/commands/Progress.htm#colors
HideTaskBar=true
; rotation=90	;	still need to rotate monitor, no point in having enabled
;----------------------------------------------------------------------------------------------------
IfNotExist, %GamePath%
{	MsgBox,, Error, Cannot find %GamePath%`nPlease edit the GamePath in %A_ScriptName% to point to the game and recompile it., 8
	Goto, Exit
}
If HideTaskBar = true
{	WinHide ahk_class Shell_TrayWnd
	WinHide, ahk_class Button
}
SplitPath, GamePath, fileName, fileDir

Gui, Felix1: New, -Caption +ToolWindow +OwnDialogs
Gui, Felix1: Color, %BackgroundColor%
If ShowBezel = true
{	IfNotExist, %BezelPath%
	{	MsgBox,, Error, Cannot find %BezelPath%`nPlease edit the BezelPath in %A_ScriptName% to point to your bezel and recompile it., 8
		Goto, Exit
	}
	Gui, Felix1: Add, Picture, W%A_ScreenWidth% H%A_ScreenHeight%, %BezelPath%
}
Gui, Felix1: Show, x0 y0 h%A_ScreenHeight% w%A_ScreenWidth%
 
; rotation := If (rotation=90 || rotation=180 || rotation=270) ? " -rotate=" . rotation . " fullscreen" : ""
zoom := If (zoom=33 || zoom=50 || zoom=100 || zoom=200) ? " -zoom=" . zoom : ""

Run, %fileName% %zoom% %rotation%, %fileDir%
WinWait, %title%
WinActivate, %title%
winHwnd:=WinActive(title)
WinSet,AlwaysOnTop, On, %title%
WinSet, Style, -0xC00000, %title% ; Remove border and titlebar
DllCall("SetMenu", uint, winHwnd, uint, 0) ; Remove the MenuBar
CenterWindow(title)
Process, WaitClose, %fileName%
WinClose, ahk_class FOCAL Test Shell

Exit:

If HideTaskBar = true
{	WinShow, ahk_class Shell_TrayWnd
	WinShow, ahk_class Button
}
ExitApp


;-----Control Remaps-----
;~3::c ;Insert Coin
;~?::1 ;Start Player 1
;~?::2 ;Start Player 2
;?::{Left} ;Move Left
;?::{Right} ;Move Right
;?::{Up} ;Jump Up a Level
;?::{Down} ;Jump Down a Level
;?::x ;Fix-It
;?::{LButton} ;Jump
;?::{Shift} ;Fix-It
;?::{F5} ;save
;?::{F6} ;FrameSkip
;?::{F7} ;ScreenShot
;?::{scrlk} ;lock mouse crosshairs to center of screen
;------------------------


CenterWindow(class) {
	Global YAdjust
	Global XAdjust
	WinGetPos, appX, appY, appWidth, appHeight, %class%
	appXPos := ( A_ScreenWidth / 2 ) - ( appWidth / 2 )
	appYPos := ( A_ScreenHeight / 2 ) - ( appHeight / 2 )
	WinMove, %class%,, % (appXPos+XAdjust), % (appYPos+YAdjust), appWidthNew, appHeightNew
}
