MEmu = PCSX2
MEmuV =  1.1.0.r5695
MURL = http://pcsx2.net/
MAuthor = djvj
MVersion = 2.0.3
MCRC = DCF98E76
iCRC = 87DB5AB2
MID = 635038268913291718
MSystem = "Sony PlayStation 2"
;----------------------------------------------------------------------------
; Notes:
; This module has many settings that can be controlled via HyperLaunchHQ
; If you want to customize settings per game, add the game to the module's ini using HyperLaunchHQ
; If you use Daemon Tools, make sure you have a SCSI virtual drive setup. Not a DT one.
; Tested DT support with the cdvdGigaherz CDVD plugin. Make sure you set it to use your SCSI drive letter.
; Module will set the CdvdSource to Plugin or Iso depending on if you have Daemon Tools enabled or not.
; If you have any problems closing the emulator, make sure noGUI module setting in HLHQ is set to default or false.
;
; Per-game memory cards
; This module supports per-game memory cards to prevent them from ever becoming full
; To use this feature, set the PerGameMemoryCards to true in HLHQ
; You need to create a default blank memory card in the path you have defined in pcsx's ini found in section [Folders], key MemoryCards.
; Make sure one of the current memory cards are blank, then copy it in that folder and rename it to "default.ps2". The module will copy this file to a romName.ps2 for each game launched.
; The module will only insert memory cards into Slot 1. So save your games there.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
noGUI := IniReadCheck(settingsFile, "Settings", "noGUI","false",,1)
fullboot := IniReadCheck(settingsFile, "Settings", "fullboot","false",,1)
perGameMemCards := IniReadCheck(settingsFile, "Settings", "PerGameMemoryCards","true",,1)
hideConsole := IniReadCheck(settingsFile, "Settings", "HideConsole","true",,1)	; Hides console window from view if it shows up
nohacks := IniReadCheck(settingsFile, romName, "nohacks","false",,1)
gamefixes := IniReadCheck(settingsFile, romName, "gamefixes",A_Space,,1)
cfg := IniReadCheck(settingsFile, romName, "cfg",A_Space,,1)
cfgpath := IniReadCheck(settingsFile, romName, "cfgpath",A_Space,,1)
gs := IniReadCheck(settingsFile, romName, "gs",A_Space,,1)
pad := IniReadCheck(settingsFile, romName, "pad",A_Space,,1)
spu2 := IniReadCheck(settingsFile, romName, "spu2",A_Space,,1)
cdvd := IniReadCheck(settingsFile, romName, "cdvd",A_Space,,1)
usb := IniReadCheck(settingsFile, romName, "usb",A_Space,,1)
fw := IniReadCheck(settingsFile, romName, "fw",A_Space,,1)
dev9 := IniReadCheck(settingsFile, romName, "dev9",A_Space,,1)

BezelStart()

Fullscreen := (If Fullscreen = "true" ? ("--fullscreen") : (""))
noGUI := (If noGUI = "true" ? ("--nogui") : (""))
If noGUI = true
	Log("Module - noGUI is set to true, THIS MAY PREVENT PCSX2 FROM CLOSING PROPERLY. If you have any issues, set it to false or default in HLHQ.",2)
fullboot := (fullboot = "true" ? ("--fullboot") : (""))
nohacks := (nohacks = "true" ? ("--nohacks") : (""))
gamefixes := (gamefixes ? ("--gamefixes=" . gamefixes) : (""))
cfg := (cfg ? ("--cfg=""" . cfg . """") : (""))
cfgpath := (cfgpath ? ("--cfgpath=""" . cfgpath . """") : (""))
gs := (gs ? ("--gs=""" . gs . """") : (""))
pad := (pad ? ("--pad=""" . pad . """") : (""))
spu2 := (spu2 ? ("--spu2=""" . spu2 . """") : (""))
cdvd := (cdvd ? ("--cdvd=""" . cdvd . """") : (""))
usb := (usb ? ("--usb=""" . usb . """") : (""))
fw := (fw ? ("--fw=""" . fw . """") : (""))
dev9 := (dev9 ? ("--dev9=""" . dev9 . """") : (""))

pcsx2IniFile := CheckFile(emuPath . "\inis\PCSX2_ui.ini")	; ini that contains memory card info and general settings

; Memory Cards
If perGameMemCards = true
{	IniRead, currentMemCard1, %pcsx2IniFile%, MemoryCards, Slot1_Filename
	IniRead, memCardPath, %pcsx2IniFile%, Folders, MemoryCards	; folder where memory cards are stored
	StringLeft, memCardPathLeft, memCardPath, 3
	memCardPathIsAbsolute := If (RegExMatch(memCardPathLeft, "[a-zA-Z]:\\") && (StrLen(memCardPath) >= 3))	; this is 1 only when path looks like this "C:\"
	memCardPath := If memCardPathIsAbsolute ? memCardPath : emuPath . "\" . memCardPath	; if only a folder name is defined for the memory card path, tack on the emuPath to find the memory cards, otherwise leave the full path as is
	defaultMemCard := memCardPath . "\default.ps2"	; defining default blank memory card for slot 1
	Log("Module - Default memory card for Slot 1 should be: " . defaultMemCard,4)
	romMemCard1 := memCardPath . "\" . romName . ".ps2"	; defining name for rom's memory card for slot 1
	Log("Module - Rom memory card for Slot 1 should be: " . romMemCard1,4)
	Log("Module - Current memory card inserted in PCSX2's ini in Slot 1 is: " . currentMemCard1)

	If (currentMemCard1 != romName . ".ps2") {	; if current memory card in slot 1 does not match this romName, switch to one that does if exist or load a default one
		IfNotExist, %romMemCard1%	; first check if romName.ps2 memory card exists
			IfNotExist, %defaultMemCard%
				Log("Module - A default memory card for Slot 1 was not found in """ . memCardPath . """. Please create an empty memory card called ""default.ps2"" in this folder for per-game memory card support.",3)
			Else {
				FileCopy, %defaultMemCard%, %romMemCard1%	; create a new blank memory card for this game
				Log("Module - Creating a new blank memory card for this game in Slot 1: " . romMemCard1)
			}
		IniWrite, %romName%.ps2, %pcsx2IniFile%, MemoryCards, Slot1_Filename	; update the ini to use this rom's card
		Log("Module - Switched memory card in Slot 1 to: " . romMemCard1)
	}
}

7z(romPath, romName, romExtension, 7zExtractPath)

pcsx2Ini := LoadProperties(pcsx2IniFile)	; load the config into memory
dvdSource := ReadProperty(pcsx2Ini,"CdvdSource")	; read value

; Mount the CD using DaemonTools
If ( dtEnabled = "true" ) { ; romExtension = ".cue" && 
	If dvdSource != Plugin
	{	Log("Module - CdvdSource was not set to ""Plugin"", changing it so PCSX2 can read from Daemon Tools.")
		WriteProperty(pcsx2Ini,"CdvdSource","Plugin")	; write a new value to the pcsx2IniFile
		SaveProperties(pcsx2IniFile,pcsx2Ini)	; save pcsx2IniFile to disk
	}
	DaemonTools("mount",romPath . "\" . romName . romExtension)
	Err := Run(executable . " --usecd" . " " . noGUI . " " . Fullscreen . " " . fullboot . " " . nohacks . " " . gamefixes . " " . cfg . " " . cfgpath . " " . gs . " " . pad . " " . spu2 . " " . cdvd . " " . usb . " " . fw . " " . dev9, emuPath,  "UseErrorLevel")
} Else If romExtension in .iso,.mdf,.nrg,.bin,.img	; the only formats PCSX2 supports loading directly
{	If dvdSource != Iso
	{	Log("Module - CdvdSource was not set to ""Iso"", changing it so PCSX2 can launch Isos directly")
		WriteProperty(pcsx2Ini,"CdvdSource","Iso")	; write a new value to the pcsx2IniFile
		SaveProperties(pcsx2IniFile,pcsx2Ini)	; save pcsx2IniFile to disk
	}
	Err := Run(executable . " """ . romPath . "\" . romName . romExtension . """ " . noGUI . " " . Fullscreen . " " . fullboot . " " . nohacks . " " . gamefixes . " " . cfg . " " . cfgpath . " " . gs . " " . pad . " " . spu2 . " " . cdvd . " " . usb . " " . fw . " " . dev9, emuPath,  "UseErrorLevel")
} Else
	ScriptError("You are trying to run a rom type of """ . romExtension . """ but PCSX2 only supports loading iso|mdf|nrg|bin|img directly. Please turn on Daemon Tools and/or 7z support instead.")

If(Err != 0){
	ScriptError("Error launching emulator, closing script.")
	ExitApp
}

WinWait("ahk_class wxWindowClassNR",,, "PCSX2")
WinWaitActive("ahk_class wxWindowClassNR",,, "PCSX2")

BezelDraw()

If hideConsole = true
	SetTimer, HideConsole, 10

Loop { ; looping until pcsx2 is done loading game
	; tooltip, loop %A_Index%,0,0
	Sleep, 200
	WinGetTitle, winTitle, ahk_class wxWindowClassNR,, PCSX2 ; excluding the title of the GUI window so we can read the title of the game window instead
	StringSplit, winTextSplit, winTitle, |, %A_Space%
	If ( winTextSplit10 != "" ) ; 10th position in the array is empty until game actually starts
		break
}

FadeInExit()
Process("WaitClose", executable)

If ( dtEnabled = "true" )
	DaemonTools("unmount")

7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


MultiGame:
	; msgbox % "selectedRom = " . selectedRom . "`nselected game = " . currentButton . "`nmgRomPath = " . mgRomPath . "`nmgRomExt = " . mgRomExt . "`nmgRomName = "  . mgRomName
	; Unmount the CD from DaemonTools
	If dtEnabled = true
		DaemonTools("unmount")
	Sleep, 500	; Required to prevent  DT from bugging
	; Mount the CD using DaemonTools
	If dtEnabled = true
		DaemonTools("mount",selectedRom)
Return

HideConsole:
	hideConsoleTimer++
	IfWinExist, Booting ahk_class wxWindowClassNR
	{	Log("Module - HideConsole - Console window found, hiding it out of view.")
		WinSet, Transparent, 0, Booting ahk_class wxWindowClassNR,,fps:,fps:	; hiding the console window
		WinSet, Transparent, 0, PCSX2 ahk_class wxWindowClassNR,,fps:,fps:	; hiding the GUI window with the menubar
		SetTimer, HideConsole, Off
	} Else If hideConsoleTimer >= 200
		SetTimer, HideConsole, Off
Return

CloseProcess:
	FadeOutStart()
	WinClose("PCSX2 ahk_class wxWindowClassNR") ; sending command to the GUI window to properly close the entire emu
Return

