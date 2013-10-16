MEmu = ScummVM
MEmuV = v1.5.0
MURL = http://scummvm.org/
MAuthor = djvj
MVersion = 2.0.5
MCRC = F6546CEF
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
;
; Launch Method 1 - Rom_Path has archived games inside a zip, 7z, rar, etc
; Set Skipchecks to Rom Extension and enable 7z
; Launch Method 2 - Rom_Path has each game inside its own folder and uncompressed
; Set Skipchecks to Rom Only and disable 7z
; Launch Method 3 - Rom_Path has archived games inside a zip, 7z, rar, etc, all named from the scummvm torrent that does not match the names on your xml
; Set Skipchecks to Rom Extension, enable 7z, enable Rom Mapping. Make sure a proper mapping ini exists in the appropriate settings Rom Mapping folder and it contains all the correct mapping info.
;----------------------------------------------------------------------------
StartModule()
BezelGui()
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

BezelStart()

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

StringReplace, romNameChanged, romName, %A_Space%, _, All	; replace all spaces in the name we lookup in ScummVM's ini because ScummVM does not support spaces in the section name
romNameChanged := RegExReplace(romNameChanged, "\(|\)", "_")	; replaces all parenthesis with underscores
If (romName != romNameChanged)
	Log("Module - Removed all unsupported characters from """ . romName . """ and using this to search for a section in ScummVM's ini: """ . romNameChanged . """")
scummRomPath := IniReadCheck(configFile, romNameChanged, "path",,,1)	; Grab the path in ScummVM's config
; msgbox % scummRomPath
If (SubStr(scummRomPath, 0, 1) = "\")	; scummvm doesn't like sending it paths with a \ as the last character. If it exists, remove it.
	StringTrimRight, scummRomPath, scummRomPath, 1
; msgbox % scummRomPath
If !scummRomPath {
	Log("Module - Could not locate a path in ScummVM's ini for section """ . romNameChanged . """. Checking if a path exists for the dbName instead: """ . dbName . """")
	scummRomPath := IniReadCheck(configFile, dbName, "path",,,1)	; If the romName, after removing all unsupporting characters to meet ScummVM's section name requirements, could not be found, try looking up the dbName instead
}
If !FileExist(scummRomPath)	; if user does not have a path set to this game in the ScummVM ini or the path does not exist that is set, attempt to send a proper one in CLI
{	Log("Module - " . (If !scummRomPath ? "No path defined in ScummVM's ini" : "The path defined in ScummVM's ini does not exist") . ". Attempting to find a correct path to your rom and sending that to ScummVM.")
	If (InStr(romPath, romName) && FileExist(romPath)) {	; if the romName is already in the path of the romPath and that path exists, attempt to set that as the path we send to ScummVM
		scummRomPath := romPath
		Log("Module - Changing " . romName . " path to: " . scummRomPath,2)
	} Else If (FileExist(romPath . "\" . romName)) {	; if the romPath doesn't have the romName in the path, let's add it to check if that exists and send that.
		scummRomPath := romPath . "\" . romName
		Log("Module - Changing " . romName . " path to: " . scummRomPath,2)
	} Else
		ScriptError("The path to """ . romName . """ was not found. Please set it correctly by manually launching ScummVM and editing this rom's path to where it can be found.")
}

configFile := If customConfigFile ? """-c" . configFile . """" : ""	; if user set a path to a custom config file
fullscreen := If Fullscreen = "true" ? "-f" : "-F"
scummRomPath := """-p" . scummRomPath . """"

Run(executable . " " . fullscreen . " " . configFile . " " . scummRomPath . " " . romNameChanged, emuPath)

WinWait("ahk_class SDL_app")
WinWaitActive("ahk_class SDL_app")
Sleep, 700 ; Necessary otherwise the HyperSpin window flashes back into view
BezelDraw()

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
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
