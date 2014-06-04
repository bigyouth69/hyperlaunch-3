mTest = true

; Author: djvj
; Purpose: Handle launcher windows for PC Games. These windows pop up before the game and usually require some type of input or button you have to press to start the game.
;----------------------------------------------------------------------------------------------------
; Launcher Settings:
; this should be the window information from the launcher window where we need to intervene before the game launches
launcherWindow = Sonic & All-Stars Racing Transformed - Steam
; this should be the window information from the game itself so we know it is safe to exit this script w/o erroring
gameWindow = Sonic & All-Stars Racing Transformed ahk_class ASN
; this is the window information of your Frontend to be used on exit if there was an error with this script
frontendTitle=Hyperspin
;----------------------------------------------------------------------------------------------------

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

WinWait, %launcherWindow%,,10	; waiting 10 seconds for the launcher window to show
If !ErrorLevel
	Goto, FoundLauncherWindow	; we found the launcher window we were looking for, now let's handle it
Else	; if window never showed, set var
	noLauncherWindow=1

WinWait, %gameWindow%,,2	; waiting 2 seconds for the game's window to show. Maybe the launcher window didn't show, so this checks to see if we are in game.
If !ErrorLevel
	Goto, ExitScript
Else	; if window never showed, we must not be in game
	noGameWindow=1

If (noLauncherWindow && noGameWindow) {	; neither window showed up, let's close HyperLaunch because there was a problem loading the game
	Process, Close, HyperLaunch.exe
	MsgBox,,PostLaunch Script, Problem running game or launcherWindow or gameWindow set wrong in this script`, please fix and try again. Closing HyperLaunch.`n`nlauncherWindow: %launcherWindow%`ngameWindow: %gameWindow%,6	; showing msgbox for 6 seconds
	WinActivate, %frontendTitle%
	Goto, ExitScript
} Else If !noGameWindow
	Goto, ExitScript	; if noGameWindow isn't set, then we know we are in game or our gameWindow is set wrong up top

FoundLauncherWindow:
	WinActivate, %launcherWindow%
	Send, {Enter}

ExitScript:
	ExitApp
