MEmu = OpenBOR
MEmuV = N/A
MURL = http://sourceforge.net/projects/openbor/
MAuthor = djvj
MVersion = 2.0
MCRC = BA2F0E06
iCRC = 99F6CD8A
MID = 635038268911600315
MSystem = "OpenBOR"
;----------------------------------------------------------------------------
; Notes:
; Default location to launch the games will be in your romPath with a subfolder for each game (named after the rom in the xml).
; In each game's folder, should contain an OpenBOR.exe

; If you don't want to use the above path/exe, create an ini in the folder of this module with the same name as this module.
; Place each game in it using the example below. gamePath should start from your romPath and end with the exe to the game.
; moduleName ini contains an entry for each game, pointing to the OpenBOR.exe
; example:
;
; [Battle Toads]
; gamePath = Battle Toads\OpenBOR.exe
; [MegaMan - War of the Past]
; gamePath = MegaMan - War of the Past\OpenBOR.exe
;
; emuPath and exe need to point to a dummy exe, like PCLauncher.exe
; romPath needs to point to the dir with all the blank txt files and the settings.ini
; Escape will only close the game from the main menu, it is needed for in-game menu usage otherwise.
; Fullscreen and controls are done via in-game options for each game. To speed up configuring of games, configure one game then save its settings to a default.cfg and paste it into each game's Saves folder.
; Then in the next game, goto Options->System Options->Config Settings->Load settings from default.cfg
; Larger games are inherently slower to load, this is OpenBOR, nothing you can do about it but get a faster HD.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
remapWinKeys := IniReadCheck(settingsFile, "Settings", "remapWinKeys","true",,1)		; This remaps windows Start keys to Return to prevent accidental leaving of game
gamePath := IniReadCheck(settingsFile, romName, "gamePath",,,1) 

gamePath := romPath . "\" . (If (!gamePath or gamePath = "ERROR") ? (romName . "\OpenBOR.exe") : (gamePath))
CheckFile(gamePath,"Could not find " . gamePath . "`nPlease place your game in it's own folder in your Rom_Path or define a custom gamePath in " . SettingsFile)
SplitPath, gamePath, gExe, gPath,

7z(romPath, romName, romExtension, 7zExtractPath)

; This remaps windows Start keys to Return to prevent accidental leaving of game
If remapWinKeys = true
{	Hotkey, RWin, WinRemap
	Hotkey, LWin, WinRemap
}

Run(gExe, gPath, "UseErrorLevel", game_PID)
If ErrorLevel
	ScriptError("Failed to launch " . romName)

WinWait("ahk_pid " . game_PID)
WinWaitActive("ahk_pid " . game_PID)

WinGetTitle, gameTitle, ahk_pid %game_PID%

FadeInExit()
Process("WaitClose", game_PID)

Process("Close", executable) ;on some machines/games, openbor doesn't close itself properly, this is the work around to make sure it does

7zCleanUp()
FadeOutExit()
ExitModule()

WinRemap:
Return

CloseProcess:
	FadeOutStart()
	WinClose(gameTitle . " ahk_pid " . game_PID)
Return
