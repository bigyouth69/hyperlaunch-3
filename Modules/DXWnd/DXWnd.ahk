MEmu = DXWnd
MEmuV = v2.01.90
MURL = http://sourceforge.net/projects/dxwnd/
MAuthor = djvj
MVersion = 2.0.4
MCRC = EE3E60A7
iCRC = CA9D3A93
MID = 635038268886599500
MSystem = "PC Games","Taito Type X"
;--------------------------------------------------------------------------------------------------------------------
; Notes:
; DXWnd is a windows hooker that intercepts DirectX calls to make fullscreen programs run within a window.
; It can be downloaded here: http://sourceforge.net/projects/dxwnd/
; Extract it to your "Module Extensions\dxwnd" folder
; You do not need to set an emulator for this module because HyperLaunch will always look in the above folder for dxwnd. Because of this, the module will need to be set as a Virtual Emulator in HLHQ.
; Read the notes in the ini for further settings to help with rotating your monitor for vertical games
; Vertical games are windowed, rotated, windows hidden (taskbar/start button/desktop), then the correct resolution is calculated and the game's window is maximized. This gives the look of a fullscreen game, but it's actually in a window.
; You may have to set Skipchecks to "Rom Only" or "Rom and Emu", otherwise HyperLaunch will error looking for a rom if your exe/bat/lnk is not the same name as you have in your xml.
;
; Taito Type X Instructions:
; 1. Backup your game.exe and typex_bindings.bin for each game (only if you want to have a backup)
; 2. In HyperHQ, use the Wizard to create a new wheel, name it Taito Type X
; 3. Download everything you see on the FTP, keeping dir names/structure and empty "sv" dirs.
;
; Taito Type X Notes:
; - IMPORTANT *** Requires files located in my user dir on the ftp at /Upload Here/djvj/Taito Type X/. I hacked every exe to save its config/logs into the sv subdir. If you use my exes, make sure you create an sv dir so the game can save its settings. ***
; - IMPORTANT *** Edit the dxwnd.ini file and update the dirs to where your games are located, or update the paths in dxwnd itself. ***
; - IMPORTANT *** Do not attempt to run TTX games off an SMB share, they won't work.
; - Make sure the game's folder and bat files in each game's dir are named the same as the database's game name
; - Every game, except Arcana Hearts, saves config and logs to a D or Z partition. Arcana saves everything in the registry . I hacked every game.exe so you do not need D or Z drives. Instead you just create an sv dir inside each game's root folder and it will save all configs/logs in there instead.
; - The controls bin only needs to be made once, then copy/paste your control bin into each game's dir, overwriting the existing one.
; - Arcana Hearts I had to hex edit the controls into the exe. I provided a txt with info where (in hex) and what the controls are (CHANGE KEYS.txt). (Note, with the updated loader this is no longer necessary and works as a standard game)
; - Taisen has no way to change the keys afaik, you are out of luck on this one until a solution surfaces.
; - Raiden 4 is very buggy, but I finally got it working 100% everytime on my PC. If it starts crashing when it worked prior, reboot your PC.
; - Raiden 4 requires a trick to get it to work correctly, otherwise it crashes everytime. I hope someone finds a better hack one day as the one I use I feel like it might not work everytime. There have been reports it doesn't work on every PC...
; - All the games should exit with the ESC key except for Arcana Hearts which the script will send Alt+F4
; - Some systems iRotate might not work, try commenting the iRotate.exe lines and uncomment the display.exe lines instead
;
; - Homura and Shikigami no Shiro III use custom d3d8 and d3d9 dll files, these fix the the games from going hyperfast. I did not make them and they create a wahwahwah.arc file when you launch the game. Edit this file in notepad and change InitProxyFunctions to 0 and PartOfENBSeries to localhost. Save the file, then change it to read-only so it doesn't get restored.
; - If SF4 is locking up during the intro movie, copy the 2 d3d dlls to your SF4 dir. This will fix it.
;
; - If your KOF98 UM came with d3d9.dll, d3d9d.dll, or d3dx9_36.dll in its root folder, remove all these for the game to work.
;
; - Lastly, every PC is different, so results will vary. Try playing with sleep timers if you think the script is working too fast for your PC.
; - Also if you have video issues or odd things are happening in game, play with vsync and try updating to the latest video card driver, or revert to an older one.
;
; - If you have any further issues, please consult the discussion thread at http://www.hyperspin-fe.com/forum/showthread.php?t=13627
;--------------------------------------------------------------------------------------------------------------------
StartModule()
FadeInStart()

 ; check for and load into memory the Settings.ini
settingsFile := CheckFile(modulePath . "\" . moduleName . ".ini", "Could not find """ . modulePath . "\" . moduleName . ".ini"". HyperLaunchHQ will create this file when you configure your first game to be used with this " . MEmu . " module.")
verticalMethod := IniReadCheck(settingsFile, "settings", "VerticalMethod", rotateMethod,,1)
system := IniReadCheck(settingsFile, romName, "System","Standard",,1)
titleClass := IniReadCheck(settingsFile, romName, "TitleClass",A_Space,,1)
launchExe := IniReadCheck(settingsFile, romName, "LaunchExe",A_Space,,1)
AppExe := IniReadCheck(settingsFile, romName, "AppExe",A_Space,,1)

; Get HS's original size so we can restore it properly later
;WinGetPos, hsX, hsY, hsW, hsH, ahk_class ThunderRT6FormDC ; HS1
;WinGetPos, hsX, hsY, hsW, hsH, ahk_class ApolloRuntimeContentWindow ; HS2, shouldn't be needed for HS2 though as it fixes itself

Loop, Parse,  romPathFromIni, |
{	GetFullName(A_LoopField)	; converts relative path to absolute
	IfExist %A_LoopField%\%launchExe%
	{	romPath = %A_LoopField%
		romFound = true
		Break
	}Else IfExist %A_LoopField%\%romName%\%launchExe%
	{	romPath = %A_LoopField%\%romName%
		romFound = true
		Break
	}
}
If !romFound
	ScriptError("Could not find the executable """ . launchExe . """ in any paths defined in your Rom_Path:`n" . romPathFromIni)

WinMinimize, ahk_class ApolloRuntimeContentWindow ; fix for HS2 not minimizing
Sleep, 100
WinMinimizeAll ;If we don't minimize, parts of HS still show on our screen, doesn't work with HS2 for an unknown reason
DxwndRun("dxPID")	; launch dxwnd to force windowed mode

If system = Vertical
	Rotate(verticalMethod, 90)

;Making our own custom hideDesktop(), because upon rotation, coordinates get messed up and only part of the desktop is hidden
Gui 1: Color, 000000
Gui 1: -Caption +ToolWindow
Gui 1: Show, x0 y0 W%A_ScreenWidth% H%A_ScreenHeight%, BlackScreen	; experimental to hide entire desktop and windows

Gui 2: Color, 000000
Gui 2: -Caption +ToolWindow
Gui 2: Show, x0 y0 W%A_ScreenHeight% H%A_ScreenWidth%, BlackScreen2	; experimental to hide entire desktop and windows

Sleep, 200 ;DO NOT REMOVE THIS LINE, game will launch minimized if you do, increase sleep if this is still happening
Run(romPath . "\" . launchExe, romPath,, "AppPID")

WinWait(titleClass)
Sleep, 500 ;Some lag so we don't lose our custom hideDesktop which happens if this is too short
WinActivate, %titleClass%

MaximizeWindow(titleClass)
FadeInExit()

Gui 1: Destroy	; no longer needed after game is rotated. GUi 2 still covers the entire desktop

Process("WaitClose", (If AppExe ? AppExe : AppPID))

Gui 2: Color, 000000	; experimental to hide entire desktop and windows
Gui 2: -Caption +ToolWindow
Gui 2: Show, x0 y0 W%A_ScreenWidth% H%A_ScreenHeight%, BlackScreen2

If system = Vertical
	Rotate(verticalMethod, 0)

WinClose("DXWnd",,,"Notepad++")
Sleep, 200
IfWinExist, Warning ahk_class #32770	; dxwnd pops up a box asking to restore desktop settings and will not close until a selection is made. This selects no (button2)
	ControlSend,Button2,{Enter},Warning ahk_class #32770
errorLvl := Process("WaitClose", dxPID,"1")
If errorLvl	; if DXWnd did not close, force close it. This sometimes happens on exit.
	Process("Close", dxPID)

WinMinimizeAllUndo
Sleep, 500

; Settings for restoring Hyperspin from vertical games
;IniRead, system, %settingsFile%, Screen, Fullscreen, standard ; unsure I needed this, shouldn't be needed
;WinMove, ahk_class ThunderRT6FormDC,, hsX, hsY, hsW, hsH ; HS1
;WinMove, ahk_class ApolloRuntimeContentWindow,, hsX, hsY, hsW, hsH ; HS2, shouldn't be needed for HS2 though as it fixes itself

;	Sleep, 500 ;Uncomment these 2 lines if HS doesn't regain focus after closing a vertical game, sloppy but it works until something else is thought of
;	Send, {ALTDOWN}{TAB}{ALTUP}

Gui 1: Destroy	; experimental to hide entire desktop and windows
Gui 2: Destroy	; experimental to hide entire desktop and windows
FadeOutExit()
ExitModule()


MaximizeWindow(class){
	Global
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
	; Transform, appX, Round, %appX%
	Transform, appY, Round, %appY%
	Transform, appWidthNew, Round, %appWidthNew%, 2
	Transform, appHeightNew, Round, %appHeightNew%, 2

	; (Taito Type X game) This step is only necessary because this game resizes itself too wide, we need to bring it back to a normal vertical game ratio
	If romName = GigaWing Generations
		appHeightNew := ( A_ScreenWidth * 0.789316 ) ;Vertical games have a 0.789316 ratio (width/height) when first launched, so whatever the new A_ScreenWidth (when rotated) is, we should multiply by this ratio to find out the new appHeightNew

	; appXPos := ( A_ScreenWidth / 2 ) - ( appWidthNew / 2 )
	appYPos := ( A_ScreenHeight / 2 ) - ( appHeightNew / 2 )
	; WinMove, %class%,, appXPos, appYPos
	WinMove, %class%,, 0, appYPos, appWidthNew, appHeightNew
}

HaltEmu:
	If system = Vertical
	{	Rotate(verticalMethod, 0)
		Sleep, 200 
	}
Return
RestoreEmu:
	If system = Vertical
		Rotate(verticalMethod, 90)
Return

CloseProcess:
	FadeOutStart()
	WinClose(titleClass)
	; DxwndClose()
Return
