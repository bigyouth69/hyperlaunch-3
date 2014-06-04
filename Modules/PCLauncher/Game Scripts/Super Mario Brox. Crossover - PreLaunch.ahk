mTest = true

; Author: djvj
; Game: Super Mario Bros. Crossover
;
; Purpose: 	1) Watches the game window and attempts to send the fullscreen hotkey until the game's size or position changes.
;					2) Opens a PHP server to host a file required by the game locally on your computer so you don;t need to be online
;
; Instructions:	1) Edit your "C:\Windows\System32\Drivers\etc\hosts" file in notepad as admin, and add this entry at the bottom:
;								127.0.0.1 data.explodingrabbit.com
;						2) In your "PCLauncher\Game Scripts" folder, create a new folder called "php" and extract the provided php archive into it.
;						3) Place the file the game downloads from online in the same folder with php.exe and make sure its name matches the gameLookupFile defined below.
;						4) Set the gameWindow setting below to match the FadeTitile you used in PCLauncher's settings so this script knows when the game has launched.
;						5) Make sure you are using the game packaged as an exe which allows the fullscreen hotkey to work. You cannot go fullscreen using just the swf version of the game.
;
; See here for the file required by the game: http://data.explodingrabbit.com/super-mario-bros-crossover/data.txt.gz
;----------------------------------------------------------------------------
; Game Specific Settings:
; gameWindow should be the window information from the game itself (aka your FadeTitle)
gameWindow = Adobe Flash Player ahk_class ShockwaveFlash
gameLookupFile = data.txt.gz			; The file the game is looking for when it accesses the website
key = {Ctrl down}{F down}{F up}{Ctrl up}
phpParam = -S 127.0.0.1:80
phpContents=
( LTrim
	<?php
	$homepage = file_get_contents('%gameLookupFile%');
	echo $homepage;
	?>
)
;----------------------------------------------------------------------------

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetKeyDelay, 50

phpFullPath := A_ScriptDir . "\php\php.exe"	; define path to php.exe
SplitPath, phpFullPath, phpExe, phpPath
SplitPath, A_ScriptName,,,, scriptNameNoExt
phpLaunchFileFullPath := phpPath . "\" . scriptNameNoExt . ".php"	; the php file that will be used as your root index when accessing the server
SplitPath, phpLaunchFileFullPath, phpLaunchFile, phpLaunchFilePath

IfNotExist, %phpLaunchFileFullPath%
	FileAppend, %phpContents%, %phpLaunchFileFullPath%	; Create the php launch file if it doesn't exist

Run, %phpExe% %phpParam% "%phpLaunchFile%", %phpPath%, Hide, phpPID	; Start php server using the phpLaunchFile and hide it

WinWait, %gameWindow%,,10	; waiting 10 seconds for the game's window to show. This checks to see if we are in game.
If ErrorLevel
	Goto, ExitScript

WinGetPos, x, y, w, h, %gameWindow%
; msgbox %x%`n%y%`n%w%`n%h%
Loop {
	; tooltip, %x%`n%y%`n%w%`n%h%
	ControlSend,, %key%, %gameWindow%
	Sleep, 100
	WinGetPos, nx, ny, nw, nh, %gameWindow%
	If (x != nx || y != ny || w != nw || h != nh || A_Index > 100)	; if x/y/w/h has changed, or the loop occured 100 times, break out and exit script
		Break
}
WinActivate, %gameWindow%

ExitScript:
	Sleep, 10000	; sleeping 10 seconds to give time for the game to find the file and download it before exiting and closing the php server. If your game takes longer or is not finding the file, increase this time
	Process, Close, %phpPID%	; Close the php server
	ExitApp
