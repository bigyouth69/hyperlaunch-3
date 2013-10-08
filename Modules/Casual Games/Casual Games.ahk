MEmu = Casual Games
MEmuV = N/A
MURL =
MAuthor = djvj
MVersion = 2.0.3
MCRC = A89B06A1
iCRC = B0DEF839
MID = 635038268877672071
MSystem = "PopCap","Big Fish Games"
;----------------------------------------------------------------------------
; Notes:
; Default location for all the games will be your Rom_Path\romName\romName.exe:
; Rom_Path needs to point to a folder that contains all subfolders, one for each game, named to match your xml:
;
; Example:
; Rom_Path = C:\Roms
; romName = Alchemy Deluxe
; The module will look in C:\Roms\Alchemy Deluxe\Alchemy Deluxe.exe
;
; In each of these folders, you should have an exe named after the rom name in your xml. This means you might have to rename the exes. If a game does not like this, utilize the module setting to define a gamePath like below.
; If you don't place your games like the above example by utilizing Rom_Path, use HLHQ to create per-game exectuable paths to each game like this:
;
; Example:
; [Alchemy Deluxe]
; gamePath = C:\Roms\Alchemy Deluxe\AlcDeluxe.exe
;
; You no longer use blank txt files with this module.
; Set SkipChecks to "Rom and Emu" when using this module.
; If you have a problem with Fade In not closing after the game is up, set the FadeTitle module setting in HLHQ for that game. It works the same as PCLauncher.
; Exit the games via their main menus to guarantee high score saving. If you use your exit key, it might not save correctly. Because of this, you can keep Fade Out disabled as it would never trigger when exiting.
; If you get a security warning when you launch a game, follow this guide to disable them:
; 1 - Open Internet explorere and click the gear icon, then Internet Options.
; 2 - Goto the Security tab, click Internet and then Custom Level
; 3 - Scroll down till you see "Launching applications and unsafe files" and set it to "Enable"
; 4 - Click OK and exit out of IE.
; Alternately you can follow additional options here: http://www.sevenforums.com/tutorials/182353-open-file-security-warning-enable-disable.html
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
remapWinKeys := IniReadCheck(settingsFile, "settings", "remapWinKeys", "true",,1)
gamePath := IniReadCheck(settingsFile, romName, "gamePath", A_Space,,1)
fadeTitle := IniReadCheck(settingsFile, romName, "FadeTitle", A_Space,,1)
forceCursor := IniReadCheck(settingsFile, "settings", "ForceCursor", true,,1)
forceCursor := IniReadCheck(settingsFile, romName, "ForceCursor", forceCursor,,1)

If romExtension in .zip.7z.rar
	ScriptError("Compressed games are not supported in this Casual Games Module. Please extract your games to their own folder and correctly configure a gamePath in the module's ini.")

If (gamePath != "" || gamePath != "ERROR")
	gamePath := GetFullName(gamePath)

If !FileExist(gamePath) {
	Log("Module - GamePath is not set or is not pointing to this game correctly. Attempting to find it for you by using your Rom Path.",2)
	gamePath := romPath . "\" . romName . ".exe"
	If FileExist(gamePath)
		Log("Module - Game was found at: " . gamePath,2)
	Else {
		gamePath := romPath . "\" . romName . "\" . romName . ".exe"
		If FileExist(gamePath)
			Log("Module - Game was found at: " . gamePath,2)
		Else
			ScriptError("Could not locate """ . romName . """ in your Rom Path or in the GamePath for this game. Please fix one or the other.")
	}
} Else
	Log("Module - Game was found in the user set GamePath at: " . gamePath)

SplitPath, gamePath,, gPath, gExt, gName

; This remaps windows Start keys to Return to prevent accidental leaving of game
If remapWinKeys = true
{	Hotkey, RWin, WinRemap
	Hotkey, LWin, WinRemap
}

errorLvl := Run(gName . "." . gExt, gPath, "UseErrorLevel", game_PID)
If errorLvl
	ScriptError("Failed to launch " . romName)

If fadeTitle {
	Log("Module - FadeTitle set by user, waiting for """ . fadeTitle . """")
	WinWait(fadeTitle)
	WinWaitActive(fadeTitle)
} Else {
	Log("Module - FadeTitle not set by user, waiting for AppPID: """ . AppPID . """")
	WinWait("ahk_pid " . game_PID)
	WinWaitActive("ahk_pid " . game_PID)
}
Process("Priority", game_PID, "High")

FadeInExit()

If forceCursor = true
	SystemCursor("On")

; These conditionals are here to resolve win7 compatibility issues with these games (their exes don't close when you exit the game)
If romName = Super Collapse 3
{	Sleep, 3000
	WinWaitNotActive, Super Collapse! 3
	Process("Close", "SuperCollapseIII.exe")
}
Else If romName = Typer Shark Deluxe
{	Sleep, 3000
	WinWaitNotActive, Typer Shark Deluxe 1.02
	Process("Close", "TyperShark.exe")
}
Else
	Process("WaitClose", game_PID)

FadeOutExit()
ExitModule()


WinRemap:
Return

CloseProcess:
	FadeOutStart()
	activeWin := WinExist("A")
	WinGet, procName, ProcessPath, ahk_id %activeWin%
	newPID := Process("Exist", gName . "." . gExt)
	Log("Module - DEBUG 5 (EXIT) - rom process: " . newPID . " - active window HWND ID is " . activeWin . " and is located at: " . procName,4)
	WinClose(If fadeTitle ? fadeTitle : "ahk_pid " . game_PID)	; If fadeTitle is set, use that to close the game, otherwise use the PID
Return
