MEmu = BizHawk
MEmuV =  v1.5.1
MURL = http://tasvideos.org/Bizhawk.html
MAuthor = djvj
MVersion = 2.0
MCRC = 5433166
iCRC = F035C9E4
MID = 635146140449648195
MSystem = "Atari 2600","Atari 7800","ColecoVision","NEC PC Engine","NEC PC Engine-CD","NEC SuperGrafx","NEC TurboGrafx-16","NEC TurboGrafx-CD","Nintendo 64","Nintendo Entertainment System","Nintendo Famicom","Nintendo Famicom Disk System","Nintendo Game Boy","Nintendo Game Boy Color","Nintendo Super Game Boy","Sega Game Gear","Sega Genesis","Sega SG-1000","Sega Master System","Sega Saturn","Super Nintendo Entertainment System","Texas Instruments TI-83"
;----------------------------------------------------------------------------
; Notes:
; CLI support only allows launching a rom, nothing else
; Tried all known methods of automating emu to go fullscreen and nothing works, (Send, ControlSend, WinMenuSelectItem, Winspector Spy msgs)
; Emu does not save fullscreen state so it must be toggled on each launch
;----------------------------------------------------------------------------
StartModule()
; BezelGUI()
FadeInStart()

; This object controls how the module reacts to different systems. BizHawk can play a lot of systems, and each system changes the window title. Without knowing this title, the module doesn't know when the emu finished loading
mType := Object("Atari 2600","Atari 2600","Atari 7800","Atari 7800","ColecoVision","ColecoVision","NEC PC Engine","TurboGrafx-16","NEC PC Engine-CD","TurboGrafx-16 (CD)","NEC SuperGrafx","SuperGrafx","NEC TurboGrafx-16","TurboGrafx-16","NEC TurboGrafx-CD","TurboGrafx-16 (CD)","Nintendo 64","Nintendo 64","Nintendo Entertainment System","NES","Nintendo Famicom","NES","Nintendo Famicom Disk System","NES","Nintendo Game Boy","Game Boy","Nintendo Game Boy Color","Game Boy Color","Nintendo Super Game Boy","Game Boy","Sega Game Gear","Game Gear","Sega Genesis","Genesis","Sega Master System","Sega Master System","Sega Mega Drive","Genesis","Sega Saturn","Saturn","Sega SG-1000","SG-1000","Super Nintendo Entertainment System","SNES","Texas Instruments TI-83","TI-83")
ident := mType[systemName]	; search object for the systemName identifier MESS uses
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this MESS module: " . moduleName)

settingsFile := modulePath . "\" . moduleName . ".ini"

7z(romPath, romName, romExtension, 7zExtractPath)

If (romExtension != ".cue" && (systemName = "Sega Saturn" || systemName = "NEC PC Engine-CD" || systemName = "NEC PC Engine-CD"))
	ScriptError("You are trying to send a """ . romExtension . """ to " . MEmu . " when it only supports ""cue"" extensions")

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
sgbMode := IniReadCheck(settingsFile, systemName . "|" . romName, "SuperGameBoyMode","false",,1)

; BezelStart()

If (systemName = "Nintendo Super Game Boy" || systemName = "Nintendo Game Boy")
{	bizhawkFile := CheckFile(emuPath . "\config.ini")
	FileRead, bizhawkCfg, %bizhawkFile%
	sgbTrue := "GB_AsSGB"": true"	; this is required otherwise ahk complains about invalid variable because of the odd search string needed to find this setting
	sgbFalse := "GB_AsSGB"": false"
	currentSGBMode := (InStr(bizhawkCfg, sgbTrue) ? ("true") : ("false"))
	If ( sgbMode != "true" And currentSGBMode = "true" ) {
		StringReplace, bizhawkCfg, bizhawkCfg, %sgbTrue%, %sgbFalse%
		SaveFile(bizhawkCfg, bizhawkFile)
	} Else If ( sgbMode = "true" And currentSGBMode = "false" ) {
		StringReplace, bizhawkCfg, bizhawkCfg, %sgbFalse%, %sgbTrue%
		SaveFile(bizhawkCfg, bizhawkFile)
	}
	If sgbMode = true	; When SGB is enabled, BizHawk uses "SNES" in the win title instead of "Game Boy"
		ident = SNES
}

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait(ident)

If systemName = Nintendo 64	; for some reasn this system doesn't activate correctly and causes Fade to get hung up, forcing activation prevents it
	WinActivate, %ident%

WinWaitActive(ident)

If fullscreen = true
	WinMenuSelectItem, %ident%,, View, Switch to Fullscreen

; BezelDraw()
FadeInExit()

Process("WaitClose", executable)

7zCleanUp()
; BezelExit()
FadeOutExit()
ExitModule()


SaveFile(text,file) {
	FileDelete, %file%
	FileAppend, %text%, %file%
}

; BezelLabel:
	; disableHideTitleBar = true
	; disableHideToggleMenu = true
	; disableHideBorder = true
; Return

CloseProcess:
	FadeOutStart()
	WinClose(ident)
Return
