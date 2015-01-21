MEmu = OpenBOR
MEmuV = N/A
MURL = http://sourceforge.net/projects/openbor/
MAuthor = djvj
MVersion = 2.0.1
MCRC = 471AA3B
iCRC = 42F15B8B
MID = 635038268911600315
MSystem = "OpenBOR"
;----------------------------------------------------------------------------
; Notes:
; If you keep your games archived, you need to at least set Skip Checks to Rom Extension because there is no rom extension like a normal rom would have.
; If you don't use a dummy executable as your OpenBOR emulator for this module, you need to set Skip Checks to Rom and Emu because these are technically PC games and have a unique exe for each game.
; Default location to launch the games will be in your romPath with a subfolder for each game (named after the rom in your database).
; In each game's folder, should contain an OpenBOR.exe

; If you don't want to use the above path/exe, change the rom's module settings in HLHQ and define a path for each game.
; Place each game you have in it using the example below. gamePath should start from your romPath and end with the exe to the game.
; The rom settings should contain an entry for each game, pointing to the OpenBOR.exe
; 	Example:
;
; 	[Battle Toads]
; 	gamePath = Battle Toads\OpenBOR.exe
; 	[MegaMan - War of the Past]
; 	gamePath = MegaMan - War of the Past\OpenBOR.exe
;
; If you don't use SkipChecks, the defined emulator for OpenBOR needs to point to a dummy exe, like Dummy.exe.
; Also your Rom Path needs to point to the folder with all blank txt files.
; Escape will only close the game from the main menu, it is needed for in-game menu usage otherwise. Using Escape as your HyperLaunch exit key is not advised as it is needed for in-game usage.
; Controls are done via in-game options for each game. To speed up configuring of games, configure one game then save its settings to a default.cfg and paste it into each game's Saves folder.
; Then in the next game, goto Options->System Options->Config Settings->Load settings from default.cfg
; Larger games are inherently slower to load, this is OpenBOR, nothing you can do about it but get a faster HDD.
; To use bezels or have the module control fullscreen, make sure a %romName%.cfg file exists in the Saves folder for each game.
; 	Example:
; 	C:\Games\OpenBOR\Battle Toads\Saves\Battle Toads.cfg
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
remapWinKeys := IniReadCheck(settingsFile, "Settings", "remapWinKeys","true",,1)		; This remaps windows Start keys to Return to prevent accidental leaving of game
altExitKey := IniReadCheck(settingsFile, "Settings|" . romName, "Alternate_Exit_Key",,,1)
gamePath := IniReadCheck(settingsFile, romName, "gamePath",,,1) 

BezelStart("FixResMode")

hideEmuObj := Object("OpenBOR ahk_class SDL_app",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath,,,1)		; allowing larger sized folders on 7zExtractPath

If FileExist(romPath . "\" . gamePath) && (gamePath && gamePath != "ERROR") {
	Log("Module - Found OpenBOR.exe using your defined gamePath setting in: " . romPath . "\" . gamePath)
	gamePath := romPath . "\" . gamePath
} Else If FileExist(romPath . "\" . romName . "\OpenBOR.exe") {
	Log("Module - Found OpenBOR.exe using in: " . romPath . "\" . romName . "\OpenBOR.exe")
	gamePath := romPath . "\" . romName . "\OpenBOR.exe"
} Else If FileExist(romPath . "\OpenBOR.exe") {
	Log("Module - Found OpenBOR.exe using in: " . romPath . "\OpenBOR.exe")
	gamePath := romPath . "\OpenBOR.exe"
} Else
	ScriptError("Could not find " . gamePath . "`nPlease place your game in its own folder in your Rom_Path or define a custom gamePath in HLHQ's module setting for OpenBOR")

SplitPath, gamePath, gExe, gPath

; This remaps windows Start keys to Return to prevent accidental leaving of game
If remapWinKeys = true
{	Hotkey, RWin, WinRemap
	Hotkey, LWin, WinRemap
}

; Update fullscreen setting
gameSaveCFG := gPath . "\Saves\" . romName . ".cfg"
backupGameSaveCFG := gPath . "\Saves\" . romName . ".cfg.bak"
If FileExist(gameSaveCFG) {
	If !FileExist(backupGameSaveCFG)	; make a backup just in case the next operation messes up the cfg
		FileCopy, %gameSaveCFG%, %backupGameSaveCFG%
	res := BinRead(gameSaveCFG,gameSaveData,1,235)	; read current fullscreen setting
	Bin2Hex(hexData,gameSaveData,res)
	If (fullscreen = "true" && hexData != "01")
		Hex2Bin(binData,"01"),BinWrite(gameSaveCFG,binData,1,235)
	Else If (fullscreen != "true" && hexData != "00")
		Hex2Bin(binData,"00"),BinWrite(gameSaveCFG,binData,1,235)
}

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

Run(gExe, gPath, "UseErrorLevel", game_PID)
If ErrorLevel
	ScriptError("Failed to launch " . romName)

WinWait("ahk_pid " . game_PID)
WinWaitActive("ahk_pid " . game_PID)

WinGetTitle, gameTitle, ahk_pid %game_PID%

BezelDraw()
HideEmuEnd()
FadeInExit()

If altExitKey {
	Log("Module - Using a custom Exit_Emulator_Key for this session: """ . altExitKey . """")
	XHotKeywrapper(exitEmulatorKey,"CloseProcess","OFF")
	altExitKey := xHotKeyVarEdit(altExitKey,"CloseProcess","~","Add")
	XHotKeywrapper(altExitKey,"CloseProcess", "ON")
}

Process("WaitClose", game_PID)

Process("Close", executable) ;on some machines/games, openbor doesn't close itself properly, this is the work around to make sure it does

7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


WinRemap:
Return

CloseProcess:
	FadeOutStart()
	WinClose(gameTitle . " ahk_pid " . game_PID)
	; WinClose("OpenBOR ahk_class SDL_app")
Return
