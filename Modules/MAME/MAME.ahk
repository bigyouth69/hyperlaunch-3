MEmu = MAME
MEmuV =  v0.159
MURL = http://www.mame.net/
MAuthor = djvj
MVersion = 2.1.7
MCRC = E8475B4E
iCRC = FE693AAF
MID = 635038268903403479
MSystem = "AAE","Cave","Capcom","LaserDisc","MAME","Nintendo Arcade Systems","Sega Model 1","Sega ST-V","SNK Neo Geo","SNK Neo Geo AES","SNK Neo Geo MVS"
;----------------------------------------------------------------------------
; Notes:
; No need to edit mame.ini and set your rom folder, module sends the rompath for you.
; Command Line Options - http://easyemu.mameworld.info/mameguide/mameguide-options.html
; High Scores DO NOT SAVE when cheats are enabled!
; HLSL Documentation: http://mamedev.org/source/docs/hlsl.txt.html
; If you use MAME for AAE, create a vector.ini in mame's ini subfolder and paste these HLSL settings in there: http://www.mameworld.info/ubbthreads/showflat.php?Cat=&Number=309968&page=&view=&sb=5&o=&vc=1
;
; Bezels:
; Module settings control whether HyperLaunch or MAME bezels are shown
; In the bezel normal mode only HyperLaunch Bezels will be show and the MAME use_bezels option will be forced disbaled
; In the bezel layout mode, HyperLaunch Bezels will be drawn only when you do not have a layout file on your MAME folders for the current game
;
; ServoStik:
; The module will automatically control any connected ServoStiks found on the system.
; It does this by reading the xml info from MAME. If that XML info has directional info at 4 or less, 4-way mode will be enabled. All others get 8-way mode.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
legacyMode := IniReadCheck(settingsFile, "Settings|" . systemName . "|" . romName, "LegacyMode","false",,1)
hlsl := IniReadCheck(settingsFile, "Settings|" . systemName . "|" . romName, "HLSL","false",,1)
bezelMode := IniReadCheck(settingsFile, "Settings|" . systemName . "|" . romName, "BezelMode","layout",,1)	; "layout" or "normal"
Videomode := IniReadCheck(settingsFile, "Settings", "Videomode","d3d",,1)
pauseMethod := IniReadCheck(settingsFile, "Settings", "PauseMethod",1,,1)	; set the pause method that works better on your machine (preferred methods 1 and 2) 1 = Win7 and Win8 OK - Problems with Win XP, 2 = preferred method for WinXP - Problems in Win7, 3 and 4 = same as 1 and 2, 5 = only use If you have a direct input version of mame, 6 = suspend mame process method, it could crash mame in some computers
cheatMode := IniReadCheck(settingsFile, "Settings", "CheatMode","false",,1)
cheatModeKey := IniReadCheck(settingsFile, "Settings", "CheatModeKey",A_Space,,1)	; user defined key to be held down before launching a mame rom.
sysParams := IniReadCheck(settingsFile, systemName, "Params", A_Space,,1)
romParams := IniReadCheck(settingsFile, romName, "Params", A_Space,,1)
mameRomName := IniReadCheck(settingsFile, romName, "MameRomName", A_Space,,1)
Artwork_Crop := IniReadCheck(settingsFile, systemName . "|" . romName, "Artwork_Crop", "true",,1)
Use_Bezels := IniReadCheck(settingsFile, systemName . "|" . romName, "Use_Bezels", "false",,1)
Use_Overlays := IniReadCheck(settingsFile, systemName . "|" . romName, "Use_Overlays", "true",,1)
Use_Backdrops := IniReadCheck(settingsFile, systemName . "|" . romName, "Use_Backdrops", "true",,1)
Use_Cpanels := IniReadCheck(settingsFile, systemName . "|" . romName, "Use_Cpanels", "false",,1)
Use_Marquees := IniReadCheck(settingsFile, systemName . "|" . romName, "Use_Marquees", "false",,1)
autosave := IniReadCheck(settingsFile, systemName . "|" . romName, "Autosave", "false",,1)
volume := IniReadCheck(settingsFile, "Settings|" . systemName . "|" . romName, "Volume",,,1)

artworkCrop := If (Artwork_Crop = "true") ? " -artwork_crop" : " -noartwork_crop"
useBezels := If (Use_Bezels = "true") ? " -use_bezels" : " -nouse_bezels"
useOverlays := If (Use_Overlays = "true") ? " -use_overlays" : " -nouse_overlays"
useBackdrops := If (Use_Backdrops = "true") ? " -use_backdrops" : " -nouse_backdrops"
UseCpanels := If (Use_Cpanels = "true") ? " -use_cpanels" : " -nouse_cpanels"
UseMarquees := If (Use_Marquees = "true") ? " -use_marquees" : " -nouse_marquees"

hideEmuObj := Object(dialogOpen . " ahk_class ConsoleWindowClass",0,"ahk_class MAME",1)	;Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later

; Process mame's ListXML for certain features
If (bezelEnabled = "true" || servoStikEnabled != "false") {
	ListXMLObject := Object()
	ListXMLObject := ListXMLInfo(romName)
	If (bezelEnabled = "true") {
		If (bezelMode = "layout"){
			BezelStart("layout",ListXMLObject["Parent"].Value,ListXMLObject["Angle"].Value,romName)
		} Else { ;bezel mode = normal
			useBezels := " -nouse_bezels"   ; force disabling MAME built-in bezels
			BezelStart(,,ListXMLObject["Angle"].Value)
		}
	}
	If (servoStikEnabled != "false") {
		ServoStik(If ListXMLObject["Ways"].Value <= 4 ? 4 : 8)	; If "ways" in the xml is set to 4 or less, the servo will go into 4-way mode, else 8-way mode will be enabled
	}
}

; -romload part of 147u2 that shows what roms were checked when missing roms
winstate := If (Fullscreen = "true") ? "Hide UseErrorLevel" : "UseErrorLevel"
fullscreen := If (Fullscreen = "true") ? " -nowindow" : " -window"
hlsl := If hlsl = "true" ? " -hlsl_enable" : " -nohlsl_enable"
videomode := If (Videomode != "" ) ? " -video " . videomode : ""
sysParams := If sysParams != ""  ? A_Space . sysParams : ""
romParams := If romParams != ""  ? A_Space . romParams : ""
autosave := If autosave = "true"  ? " -autosave" : ""
volume := If volume != ""  ? " -volume " . volume : ""

StringReplace,mameRomPaths,romPathFromIni,|,`"`;`",1	; replace all instances of | to ; in the Rom_Path from Emulators.ini so mame knows where to find your roms
mameRomPaths := " -rompath """ .  (If mameRomName ? romPath : mameRomPaths) . """"	; if using an alt rom, only supply mame with the path to that rom so it doesn't try to use the original rom

If InStr(romParams,"-rompath")
	ScriptError("""-rompath"" is defined as a parameter for " . romName . ". The MAME module fills this automatically so please remove this from Params in the module's settings.")
If InStr(sysParams,"-rompath")
	ScriptError("""-rompath"" is defined as a parameter for " . systemName . ". The MAME module fills this automatically so please remove this from Params in the module's settings.")

If mameRomName {
	FileMove, %romPath%\%romName%%romExtension%, %romPath%\%mameRomName%%romExtension%	; rename rom to match what mame needs
	originalRomName := romName	; store romName from database so we know what to rename it back to later
	romName := mameRomName
	If ErrorLevel
		ScriptError("There was a problem renaming " . romName . "  to " . mameRomName . " in " . romPath . ". Please check you have write permission to this folder/file and you don't already have a file named """ . mameRomName . """ in your rom folder.",8)
	Else	; if rename was successful, set var so we know to move it back later
		fileRenamed = 1
}

If cheatMode = true
{	If (!FileExist(emuPath . "\cheat.zip") && !FileExist(emuPath . "\cheat.7z"))
		ScriptError("You have cheats enabled for " . MEmu . " but could not locate a ""cheat.zip"" or ""cheat.7z"" in " . emuPath)
	If cheatModeKey	; if user wants to use a key to enable CheatMode
		cheatEnabled := If XHotkeyAllKeysPressed(cheatModeKey) ? " -cheat" : ""	; only enables cheatMode when key is held down on launch
	Else	; no cheat mode key defined
		cheatEnabled := " -cheat"
}

HideEmuStart()

If legacyMode = true
	errLvl := Run(executable . A_Space . romName . fullscreen . cheatEnabled . volume . mameRomPaths . sysParams . romParams, emuPath, winstate)
Else
	errLvl := Run(executable . A_Space . romName . fullscreen . hlsl . cheatEnabled . volume . videomode . artworkCrop . useBezels . useOverlays . useBackdrops . UseCpanels . UseMarquees . mameRomPaths . sysParams . romParams . autosave, emuPath, winstate)

If errLvl {
	If (errLvl = 1)
		Error = Failed Validity
	Else If(errLvl = 2)
		Error = Missing Files
	Else If(errLvl = 3)
		Error = Fatal Error
	Else If(errLvl = 4)
		Error = Device Error
	Else If(errLvl = 5)
		Error = Game Does Not Exist
	Else If(errLvl = 6)
		Error = Invalid Config
	Else If errLvl in 7,8,9
		Error = Identification Error
	Else
		Error = MAME Error
	Log("MAME Error - " . Error,3)
}

WinWait("ahk_class MAME")
WinWaitActive("ahk_class MAME")

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
BezelExit()

If fileRenamed {	; rename file back to alternate name for next launch
	FileMove, %romPath%\%romName%%romExtension%, %romPath%\%originalRomName%%romExtension%
	If ErrorLevel	; if rename was successful, set var so we know to move it back later
		ScriptError("There was a problem renaming " . romName . " back to " . originalRomName)
}

FadeOutExit()
ExitModule()


ListXMLInfo(rom){ ; returns MAME/MESS info about parent rom, orientation angle, resolution
	Global emuFullPath, emuPath
	ListXMLObject := Object()
	listXMLVarLog :=
	RunWait, % comspec . " /c " . """" . emuFullPath . """" . " -listxml " . rom . " > tempBezel.txt", %emuPath%, Hide
	Fileread, ListxmlContents, %emuPath%\tempBezel.txt
	RegExMatch(ListxmlContents, "s)<game.*name=" . """" . rom . """" . ".*" . "cloneof=" . """" . "[^""""]*", parent)
	RegExMatch(parent,"cloneof=" . """" . ".*", parent)
	RegExMatch(parent,"""" . ".*", parent)
	StringTrimLeft, parent, parent, 1
	RegExMatch(ListxmlContents, "s)<display.*rotate=" . """" . "[0-9]+" . """", angle)
	RegExMatch(angle,"[0-9]+", angle, "-6")
	RegExMatch(ListxmlContents, "s)<display.*width=" . """" . "[0-9]+" . """", width)
	RegExMatch(width,"[0-9]+", width, "-6")
	RegExMatch(ListxmlContents, "s)<display.*height=" . """" . "[0-9]+" . """", Height)
	RegExMatch(Height,"[0-9]+", Height, "-6")
	RegExMatch(ListxmlContents, "s)<control.*ways=" . """" . "[0-9]+" . """", Ways)
	RegExMatch(Ways,"[0-9]+", Ways, "-6")
	logVars := "Parent|Angle|Height|Width|Ways"
	Loop, Parse, logVars, |
	{
		currentobj:={}
		currentobj.Label := A_Loopfield
		currentobj.Value := %A_Loopfield%
		ListXMLObject.Insert(currentobj["Label"], currentobj)
		listXMLLog .= "`r`n`t`t`t`t`t" . currentobj["Label"] . " = " . currentobj["Value"]
	}
	Log("Module - MAME ListXML values: " . listXMLLog,5)
	If (ListXMLObject["Height"].Value > ListXMLObject["Width"].Value) {
		ListXMLObject["Angle"].Value := true
		Log("Module - This game's height is greater than its width, forcing vertical mode",5)
	}
	FileDelete, %emuPath%\tempBezel.txt
	Return ListXMLObject	
}

HaltEmu:
	If pauseMethod = 1
	{	disableSuspendEmu = true
		disableRestoreEmu = true
		PostMessage,0x211, 1, , , ahk_class MAME
	} Else If pauseMethod = 2
	{	disableSuspendEmu = true
		PostMessage,0x211, 1, , , ahk_class MAME
	} Else If pauseMethod = 3
	{	disableSuspendEmu = true
		disableRestoreEmu = true
		PostMessage,% 0x0400+6, 1, , , ahk_class MAME
	} Else If pauseMethod = 4
	{	disableSuspendEmu = true
		PostMessage,% 0x0400+6, 1, , , ahk_class MAME
	} Else If pauseMethod = 5
	{	disableSuspendEmu = true
		Send, {P down}
		Sleep, 1000
		Send, {P up} 
	}
Return
RestoreEmu:
	If pauseMethod = 1
	{	PostMessage,0x212, 1, , , ahk_class MAME
		WinActivate, ahk_class MAME
	} Else If pauseMethod = 2
	{	PostMessage,0x212, 1, , , ahk_class MAME
		WinActivate, ahk_class MAME
	} Else If pauseMethod = 3
	{	PostMessage,% 0x0400+6, 0, , , ahk_class MAME
		WinActivate, ahk_class MAME
	} Else If pauseMethod = 4
	{	PostMessage,% 0x0400+6, 0, , , ahk_class MAME
		WinActivate, ahk_class MAME
	} Else If pauseMethod = 5
	{	disableSuspendEmu = true
		Send, {P down}
		Sleep, 1000
		Send, {P up} 
		WinActivate, ahk_class MAME
	} Else If pauseMethod = 6
		WinActivate, ahk_class MAME
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class MAME")
Return
