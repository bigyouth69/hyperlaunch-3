MEmu = ScummVM
MEmuV = v1.5.0
MURL = http://scummvm.org/
MAuthor = djvj
MVersion = 2.0.3
MCRC = D6E2C617
iCRC = B2D94E9B
MID = 635038268922749586
MSystem = "ScummVM"
;----------------------------------------------------------------------------
; Notes:
; If your games are compressed archives, set your Rom_Path to the folder with all your games and Rom_Extension to just the archive type.
; Set Skipchecks to "Rom Extension" for this system if your roms are compressed archives and also turn on 7z support.
; If your games are already uncompressed into their own folders, set Skipchecks to "Rom Only" so HL knows not to look for rom files.
;
; You can set your Save/Load/Menu hotkeys below to access them in game.
; The hotkeys will be processed by xHotkey, so they can be defined just like you would your Exit_Emulator_Key (like with delays or multiple sets of keys)
;
; If you prefer a portable ScummVM, place your scummvm.ini somewhere else, like in the emulator's folder and set CustomConfig's path to this file. It will work with the ini from there instead of your appdata folder.
; http://www.hyperspin-fe.com/forum/showpost.php?p=52295&postcount=81
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
scummDefaultConfigFile := A_AppData . "\ScummVM\scummvm.ini"	; ScummVM's default ini file it creates on first launch
customConfigFile := IniReadCheck(settingsFile, "Settings", "CustomConfig","",,1)	; Set the path to a custom config file and the module will use this instead of the ScummVM's default one
customConfigFile := GetFullName(customConfigFile)	; convert relative path to absolute
configFile := CheckFile(If customConfigFile ? customConfigFile : scummDefaultConfigFile)	; checks if either the default config file or the custom one exists

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
SaveKey := IniReadCheck(settingsFile, "Settings", "SaveKey","1",,1)					; hotkey to save state
LoadKey := IniReadCheck(settingsFile, "Settings", "LoadKey","2",,1)						; hotkey to load state
MenuKey := IniReadCheck(settingsFile, "Settings", "MenuKey","p",,1)					; hotkey to access the ScummVM menu

If (7zEnabled = "true" && skipChecks != "false")
	ScriptError("You have 7z and SkipChecks enabled. This scenario will not work with the ScummVM module and how the emu requires paths sent to it. All your games must be compressed with 7z enabled and no SkipChecks, or uncompressed with Rom Only SkipChecks and 7z disabled.")

If 7zEnabled != true
	If romExtension in %7zFormats%
		ScriptError("Your rom """ . romName . """ is a compressed archive`, but you have 7z support disabled. ScummVM does not support launching compressed roms directly. Enable 7z or extract your rom.",8)

7z(romPath, romName, romExtension, 7zExtractPath)

; Send ScummVM hotkeys through xHotkey so they are linked to the labels below
SaveKey := xHotKeyVarEdit(SaveKey,"SaveKey","~","Add")
LoadKey := xHotKeyVarEdit(LoadKey,"LoadKey","~","Add")
MenuKey := xHotKeyVarEdit(MenuKey,"MenuKey","~","Add")
xHotKeywrapper(SaveKey,"ScummvmSave")
xHotKeywrapper(LoadKey,"ScummvmLoad")
xHotKeywrapper(MenuKey,"ScummvmMenu")

If (7zEnabled != "true") {
	scummRomPath := IniReadCheck(configFile, romName, "path",,,1)	; Grab the path in ScummVM's config
	If !FileExist(scummRomPath)
		ScriptError("The path to """ . romName . """ was not found. Please set it correctly by manually launching ScummVM and editing this rom's path to where it can be found.")
}

If scummRomPath
configFile := """-c" . configFile . """"
fullscreen := If Fullscreen = "true" ? "-f" : "-F"
scummRomPath := If 7zEnabled = "true" ? """-p" . romPath . """" : ""

Run(executable . " " . fullscreen . " " . configFile . " " . scummRomPath . " " . romName, emuPath)

WinWait("ahk_class SDL_app")
WinWaitActive("ahk_class SDL_app")
Sleep, 700 ; Necessary otherwise the HyperSpin window flashes back into view

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


ScummvmSave:
	Send, !1
Return
ScummvmLoad:
	Send, ^1
Return
ScummvmMenu:
	Send, ^{F5}
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class SDL_app")
Return
