MEmu = ScummVM
MEmuV = v1.7.0
MURL = http://scummvm.org/
MAuthor = djvj, brolly
MVersion = 2.0.7
MCRC = 94CC13AF
iCRC = 3ADCD646
MID = 635038268922749586
MSystem = "ScummVM","Microsoft MS-DOS"
;----------------------------------------------------------------------------
; Notes:
; If your games are compressed archives, set your Rom_Path to the folder with all your games and Rom_Extension to just the archive type.
; Set Skipchecks to "Rom Extension" for this system If your roms are compressed archives and also turn on 7z support.
; If your games are already uncompressed into their own folders, set Skipchecks to "Rom Only" so HL knows not to look for rom files.
;
; You can set your Save/Load/Menu hotkeys below to access them in game.
; The hotkeys will be processed by xHotkey, so they can be defined just like you would your Exit_Emulator_Key (like with delays or multiple sets of keys)
;
; If you prefer a portable ScummVM, place your scummvm.ini somewhere Else, like in the emulator's folder and set CustomConfig's path to this file. It will work with the ini from there instead of your appdata folder.
; http://www.hyperspin-fe.com/forum/showpost.php?p=52295&postcount=81
;
; You can manually map your database rom names to archive files If you keep your games compressed and have the files named differently from your database by putting a file named ZipMapping.ini in the modules folder (or ZipMapping - SystemName.ini), this file contents should be as follows:
; [mapping]
; romName=zipFileName
;
; Launch Method 1 - Rom_Path has archived games inside a zip, 7z, rar, etc
; Set Skipchecks to Rom Extension and enable 7z
; Launch Method 2 - Rom_Path has each game inside its own folder and uncompressed
; Set Skipchecks to Rom Only and disable 7z
; Launch Method 3 - Rom_Path has archived games inside a zip, 7z, rar, etc, all named from the scummvm torrent that does not match the names on your xml
; Set Skipchecks to Rom Extension, enable 7z, enable Rom Mapping. Make sure a proper mapping ini exists in the appropriate settings Rom Mapping folder and it contains all the correct mapping info.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . (If FileExist(modulePath . "\" . systemName . ".ini") ? systemName : moduleName) . ".ini"		; use a custom systemName ini If it exists
scummDefaultConfigFile := A_AppData . "\ScummVM\scummvm.ini"	; ScummVM's default ini file it creates on first launch
customConfigFile := IniReadCheck(settingsFile, "Settings", "CustomConfig","",,1)	; Set the path to a custom config file and the module will use this instead of the ScummVM's default one
customConfigFile := GetFullName(customConfigFile)	; convert relative path to absolute
configFile := CheckFile(If customConfigFile ? customConfigFile : scummDefaultConfigFile)	; checks If either the default config file or the custom one exists
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
LaunchMode := IniReadCheck(settingsFile, "Settings|" . romName, "LaunchMode", "Auto",,1)
TargetName := IniReadCheck(settingsFile, romName, "Target", romName,,1)
ForceExtractionToRomPath := IniReadCheck(settingsFile, "Settings" . "|" . romName, "ForceExtractionToRomPath", "false",,1)

SaveKey := IniReadCheck(settingsFile, "Settings", "SaveKey","1",,1)					; hotkey to save state
LoadKey := IniReadCheck(settingsFile, "Settings", "LoadKey","2",,1)						; hotkey to load state
MenuKey := IniReadCheck(settingsFile, "Settings", "MenuKey","p",,1)					; hotkey to access the ScummVM menu

BezelStart()

If 7zEnabled != true
	If romExtension in %7zFormats%
		ScriptError("Your rom """ . romName . """ is a compressed archive`, but you have 7z support disabled. ScummVM does not support launching compressed roms directly. Enable 7z or extract your rom.",8)

;Find the zip filename by looking it up in the ZipMapping.ini file or ZipMapping - SystemName.ini If one exists
IfExist, % modulePath . "\ZipMapping - " . systemName ".ini"
	ZipMappingFile := modulePath . "\ZipMapping - " . systemName ".ini"
Else
	ZipMappingFile := modulePath . "\ZipMapping.ini"

ZipName := IniReadCheck(ZipMappingFile, "mapping", romname, romname . (If romExtension ? romExtension : ".zip"),,1)

If (LaunchMode = "eXoDOS") {
	;Find and set the romPath in case we have several
	romPathFound := "false"
	If (7zEnabled = "true")
	{
		Loop, Parse, romPath, |
		{
			currentPath := A_LoopField
			Log("Module - Searching for rom " . ZipName . " in " . currentPath,4)
			If FileExist(currentPath . "\" . ZipName)
			{
				romPath := currentPath
				romPathFound := "true"
			}
		}
		If (romPathFound != "true")
			ScriptError("Couldn't find rom " . ZipName . " in any of the defined rom paths")
	} Else {
		Loop, Parse, romPath, |
		{
			currentPath := A_LoopField
			Log("Module - Searching for rom " . romname . " in " . currentPath,4)
			If InStr(FileExist(currentPath . "\" . romname), "D")
			{
				romPath := currentPath
				romPathFound := "true"
			}
		}
		If (romPathFound != "true")
			ScriptError("Couldn't find rom " . romname . " in any of the defined rom paths")
	}
	
	If (ForceExtractionToRomPath = "true") {
		Log("Module - ForceExtractionToRomPath is set to true, setting 7zExtractPath to " . romPath . ". Careful when using this setting!",4)
		7zExtractPath := romPath
	}
}

;Lets split filename and extension
SplitPath, ZipName,,,zipExtension,zipFileName

hideEmuObj := Object("ahk_class SDL_app",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
;7z(romPath, romName, romExtension, 7zExtractPath)
7z(romPath,zipFileName,"." . zipExtension,7zExtractPath,,If LaunchMode = "eXoDOS" ? "false" : "true")

; Send ScummVM hotkeys through xHotkey so they are linked to the labels below
SaveKey := xHotKeyVarEdit(SaveKey,"SaveKey","~","Add")
LoadKey := xHotKeyVarEdit(LoadKey,"LoadKey","~","Add")
MenuKey := xHotKeyVarEdit(MenuKey,"MenuKey","~","Add")
xHotKeywrapper(SaveKey,"ScummvmSave")
xHotKeywrapper(LoadKey,"ScummvmLoad")
xHotKeywrapper(MenuKey,"ScummvmMenu")

If (LaunchMode = "ParseIni")
{	Log("Module - Launch mode: ParseIni")
	;Try parsing the scummvm config ini file for the path
	StringReplace, romNameChanged, TargetName, %A_Space%, _, All	; replace all spaces in the name we lookup in ScummVM's ini because ScummVM does not support spaces in the section name
	romNameChanged := RegExReplace(romNameChanged, "\(|\)", "_")	; replaces all parenthesis with underscores
	If (TargetName != romNameChanged)
		Log("Module - Removed all unsupported characters from """ . TargetName . """ and using this to search for a section in ScummVM's ini: """ . romNameChanged . """")

	scummRomPath := IniReadCheck(configFile, romNameChanged, "path",,,1)	; Grab the path in ScummVM's config
	; msgbox % scummRomPath
	If (SubStr(scummRomPath, 0, 1) = "\")	; scummvm doesn't like sending it paths with a \ as the last character. If it exists, remove it.
		StringTrimRight, scummRomPath, scummRomPath, 1
	; msgbox % scummRomPath
	If !scummRomPath {
		Log("Module - Could not locate a path in ScummVM's ini for section """ . romNameChanged . """. Checking If a path exists for the dbName instead: """ . dbName . """",2)
		scummRomPath := IniReadCheck(configFile, dbName, "path",,,1)	; If the romName, after removing all unsupporting characters to meet ScummVM's section name requirements, could not be found, try looking up the dbName instead
	}
	If !FileExist(scummRomPath)	; If user does not have a path set to this game in the ScummVM ini or the path does not exist that is set, attempt to send a proper one in CLI
	{	Log("Module - " . (If !scummRomPath ? "No path defined in ScummVM's ini" : ("The path defined in ScummVM's ini does not exist : " . scummRomPath)) . ". Attempting to find a correct path to your rom and sending that to ScummVM.",2)
		If (InStr(romPath, romName) && FileExist(romPath)) {	; If the romName is already in the path of the romPath and that path exists, attempt to set that as the path we send to ScummVM
			scummRomPath := romPath
			Log("Module - Changing " . romName . " path to: " . scummRomPath,2)
		} Else If (FileExist(romPath . "\" . romName)) {	; If the romPath doesn't have the romName in the path, let's add it to check If that exists and send that.
			scummRomPath := romPath . "\" . romName
			Log("Module - Changing " . romName . " path to: " . scummRomPath,2)
		} Else
			ScriptError("The path to """ . romName . """ was not found. Please set it correctly by manually launching ScummVM and editing this rom's path to where it can be found.")
	}
} Else If (LaunchMode = "eXoDOS") {
	Log("Module - Launch mode: eXoDOS")
	;On eXoDOS sets game MUST be at this folder
	scummRomPath := CheckFile(romPath . "\" . romName)
	romNameChanged := TargetName
} Else {
	Log("Module - Launch mode: Standard")
	;Auto mode, scummRomPath will be empty here as everything will be read from the scummvm config ini file
	romNameChanged := TargetName
}

options := " --no-console"
configFile := If customConfigFile ? " -c""" . configFile . """" : ""		; If user set a path to a custom config file
fullscreen := If Fullscreen = "true" ? " -f" : " -F"
scummRomPath := If scummRomPath ? " -p""" . scummRomPath . """" : ""

HideEmuStart()
Run(executable . options . fullscreen . configFile . scummRomPath . " " . romNameChanged, emuPath)

WinWait("ahk_class SDL_app")
WinWaitActive("ahk_class SDL_app")

Sleep, 700 ; Necessary otherwise the HyperSpin window flashes back into view

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp(If LaunchMode = "eXoDOS" ? 7zExtractPath . "\" . romName : "")
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
