MEmu = PCSX2
MEmuV =  1.1.0.r5695
MURL = http://pcsx2.net/
MAuthor = djvj
MVersion = 2.1.1
MCRC = 9FC47775
iCRC = E6A9BAD3
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
;
; Linuz cdvd plugin stores its settings in the registry @ HKEY_CURRENT_USER\Software\PS2Eplugin\CDVD\CDVDiso
;
; Run pcsx2 with the --help option to see current CLI parameters
;
; Known CLI options not currently supported by this module:
;  --console        	forces the program log/console to be visible
;  --portable       	enables portable mode operation (requires admin/root access)
;  --elf=<str>      	executes an ELF image
;  --forcewiz       	forces PCSX2 to start the First-time Wizard
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

; PCSX2_ui.ini = default ini that contains memory card info and general settings
If FileExist(emuPath . "\portable.ini") {	; portable install
	Log("Module - PCSX2 is operating in a portable mode")
	pcsx2IniFile := CheckFile(emuPath . "\inis\PCSX2_ui.ini", "Could not find the default PCSX2_ui.ini file. Please manually run and configure PCSX2 first so this file is created with all your default settings.")
} Else {	; default not portable install
	Log("Module - PCSX2 is operating in a standard installation mode")
	RegRead, pcsx2IniFolder, HKCU, Software\PCSX2, SettingsFolder
	pcsx2IniFile := CheckFile(pcsx2IniFolder . "\PCSX2_ui.ini", "Could not find the default PCSX2_ui.ini file. Please manually run and configure PCSX2 first so this file is created with all your default settings.")
}
settingsFile := modulePath . "\" . moduleName . ".ini"

; global settings
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
noGUI := IniReadCheck(settingsFile, "Settings", "noGUI","false",,1)	; disables display of the gui while running games
fullboot := IniReadCheck(settingsFile, "Settings", "fullboot","false",,1)	; disables the quick boot feature, forcing you to sit through the PS2 startup splash screens
perGameMemCards := IniReadCheck(settingsFile, "Settings", "PerGameMemoryCards","true",,1)
hideConsole := IniReadCheck(settingsFile, "Settings", "HideConsole","true",,1)	; Hides console window from view if it shows up
cfgPath := IniReadCheck(settingsFile, "Settings", "cfgpath", emuPath . "\Game Configs",,1)	; specifies the config folder; applies to pcsx2 + plugins
gs := IniReadCheck(settingsFile, "Settings|" . romName, "gs",,,1)	; override for the GS plugin
pad := IniReadCheck(settingsFile, "Settings|" . romName, "pad",,,1)	; override for the PAD plugin
spu2 := IniReadCheck(settingsFile, "Settings|" . romName, "spu2",,,1)	; override for the SPU2 plugin
cdvd := IniReadCheck(settingsFile, romName, "cdvd",,,1)	; override for the CDVD plugin
usb := IniReadCheck(settingsFile, "Settings|" . romName, "usb",,,1)	; override for the USB plugin
fw := IniReadCheck(settingsFile, "Settings|" . romName, "fw",,,1)	; override for the FW plugin
dev9 := IniReadCheck(settingsFile, "Settings|" . romName, "dev9",,,1)	; override for the DEV9 plugin
dtOveride := IniReadCheck(settingsFile, romName, "DTOveride",,,1)
nohacks := IniReadCheck(settingsFile, romName, "nohacks","false",,1)	; disables all speedhacks
gamefixes := IniReadCheck(settingsFile, romName, "gamefixes",,,1)	; Enable specific gamefixes for this session. Use the specified comma or pipe-delimited list of gamefixes: VuAddSub,VuClipFlag,FpuCompare,FpuMul,FpuNeg,EETiming,SkipMpeg,OPHFlag,DMABusy,VIFFIFO,VI,FMVinSoftware

cfgPath := GetFullName(cfgPath)
IfNotExist % cfgPath
	FileCreateDir, %cfgPath%	; create the cfg folder if it does not exist

BezelStart()

Fullscreen := If Fullscreen = "true" ? " --fullscreen" : ""
noGUI := If noGUI = "true" ? " --nogui" : ""
If (noGUI != "")
	Log("Module - noGUI is set to true, THIS MAY PREVENT PCSX2 FROM CLOSING PROPERLY. If you have any issues, set it to false or default in HLHQ.",2)
fullboot := If fullboot = "true" ? " --fullboot" : ""
nohacks := If nohacks = "true" ? " --nohacks" : ""
gamefixes := If gamefixes ? " --gamefixes=" . gamefixes : ""
gs := If gs ? " --gs=""" . GetFullName(gs) . """" : ""
pad := If pad ? " --pad=""" . GetFullName(pad) . """" : ""
spu2 := If spu2 ? " --spu2=""" . GetFullName(spu2) . """" : ""
usb := If usb ? " --usb=""" . GetFullName(usb) . """" : ""
fw := If fw ? " --fw=""" . GetFullName(fw) . """" : ""
dev9 := If dev9 ? " --dev9=""" . GetFullName(dev9) . """" : ""

cfgRomPath := cfgPath . "\" . romName
cfgPathCLI := If FileExist(cfgRomPath) ? " --cfgpath=""" . GetFullName(cfgRomPath) . """" : ""

; Specify what main ini PCSX2 should use
If (cfgPathCLI && FileExist(cfgRomPath . "\PCSX2_ui.ini")) {
	;We can't set both cfgpath and cfg CLI switches, so if only PCSX2_ui.ini file exists we use cfg otherwise we use cfgpath
	;--cfg specifies a custom configuration file to use instead of PCSX2.ini (does not affect plugins)
	filecount := 0 
	Loop, %cfgRomPath%\*.ini
		filecount++
	If (filecount == 1)
	{
		;Only PCSX2_ui.ini found
		pcsx2IniFile := cfgRomPath . "\PCSX2_ui.ini"
		Log("Module - Found a game-specific PCSX2_ui.ini in the cfgPath. Telling PCSX2 to use this one instead: " . pcsx2IniFile)
		cfg := " --cfg=""" . pcsx2IniFile . """"
		cfgPathCLI := ""
	}
}
Log("Module - " . (If cfgPathCLI != "" ? "Setting PCSX2's config path to """ . cfgRomPath . """" : "Using PCSX2's default configuration folder: """ . emuPath . "\inis"""))

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

hideEmuObj := Object("ahk_class wxWindowClassNR",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

pcsx2Ini := LoadProperties(pcsx2IniFile)	; load the config into memory
dvdSource := ReadProperty(pcsx2Ini,"CdvdSource")	; read value

; Mount the CD using DaemonTools
If dtOveride	; this allows per-game DT support because some games boot to black when DT is enabled
	dtEnabled := dtOveride
If (dtEnabled = "true" && InStr(".mds|.mdx|.b5t|.b6t|.bwt|.ccd|.cue|.isz|.nrg|.cdi|.iso|.ape|.flac", romExtension)) {	; if DT enabled and using an image type DT can load
	If !cdvd {
		dtCDVDPlugin := IniReadCheck(settingsFile, "Settings", "DT_CDVD_Plugin",,,1)
		If dtCDVDPlugin
			cdvd := dtCDVDPlugin
	}
	cdvd := If cdvd ? " --cdvd=""" . GetFullName(cdvd) . """" : ""
	If dvdSource != Plugin
	{	Log("Module - CdvdSource was not set to ""Plugin"", changing it so PCSX2 can read from Daemon Tools.")
		WriteProperty(pcsx2Ini,"CdvdSource","Plugin")	; write a new value to the pcsx2IniFile
		SaveProperties(pcsx2IniFile,pcsx2Ini)	; save pcsx2IniFile to disk
	}
	DaemonTools("mount",romPath . "\" . romName . romExtension)
	HideEmuStart()
	errLvl := Run(executable . " --usecd" . noGUI . Fullscreen . fullboot . nohacks . gamefixes . cfg . cfgPathCLI . gs . pad . spu2 . cdvd . usb . fw . dev9, emuPath,  "UseErrorLevel")
	usedDT = 1	; tell the rest of the script to use DT methods
} Else If romExtension in .iso,.mdf,.nrg,.bin,.img	; the only formats PCSX2 supports loading directly
{
	If !cdvd {
		imageCDVDPlugin := IniReadCheck(settingsFile, "Settings", "Image_CDVD_Plugin",,,1)
		If imageCDVDPlugin
			cdvd := imageCDVDPlugin
	}
	cdvd := If cdvd ? " --cdvd=""" . GetFullName(cdvd) . """" : ""
	If dvdSource != Iso
	{	Log("Module - CdvdSource was not set to ""Iso"", changing it so PCSX2 can launch this " . romExtension . " image directly")
		WriteProperty(pcsx2Ini,"CdvdSource","Iso")	; write a new value to the pcsx2IniFile
		SaveProperties(pcsx2IniFile,pcsx2Ini)	; save pcsx2IniFile to disk
	}
	HideEmuStart()
	errLvl := Run(executable . " """ . romPath . "\" . romName . romExtension . """ " . noGUI . Fullscreen . fullboot . nohacks . gamefixes . cfg . cfgPathCLI . gs . pad . spu2 . cdvd . usb . fw . dev9, emuPath,  "UseErrorLevel")
} Else If romExtension in .bz2	; special case format that requires plugin mode and pcsx2 loads it directly
{
	If !cdvd {
		linuzCDVDPlugin := IniReadCheck(settingsFile, "Settings", "Linuz_CDVD_Plugin",,,1)
		If linuzCDVDPlugin
			cdvd := linuzCDVDPlugin
	}
	cdvd := If cdvd ? " --cdvd=""" . GetFullName(cdvd) . """" : ""
	If dvdSource != plugin
	{	Log("Module - CdvdSource was not set to ""Plugin"", changing it so PCSX2 can launch this " . romExtension . " image directly")
		WriteProperty(pcsx2Ini,"CdvdSource","Plugin")	; write a new value to the pcsx2IniFile
		SaveProperties(pcsx2IniFile,pcsx2Ini)	; save pcsx2IniFile to disk
	}
	oldHex := ReadReg("IsoFile")	; read last used bz2 image
	newHex := StrToHex(romPath . "\" . romName . romExtension)	; convert new bz2 image path to hex
	i := 512 - StrLen(newHex)	; get total amount of 0's to add to end of hex to make it 512 bytes
	Loop, %i%
		newHex := newHex . "0"	; add required bytes to end
	If (oldHex != newHex) {
		Log("Module - Writing new bz2 path to registry",4)
		WriteReg("IsoFile", newHex)	; write new bz2 path to registry
	}
	HideEmuStart()
	errLvl := Run(executable . " """ . romPath . "\" . romName . romExtension . """ " . noGUI . Fullscreen . fullboot . nohacks . gamefixes . cfg . cfgPathCLI . gs . pad . spu2 . cdvd . usb . fw . dev9, emuPath,  "UseErrorLevel")
} Else
	ScriptError("You are trying to run a rom type of """ . romExtension . """ but PCSX2 only supports loading iso|mdf|nrg|bin|img directly. Please turn on Daemon Tools and/or 7z support or put ""cue"" last in your rom extensions for " . MEmu . " instead.")

If errLvl
	ScriptError("Error launching emulator, closing script.")

WinWait("ahk_class wxWindowClassNR",,, "PCSX2")
WinWaitActive("ahk_class wxWindowClassNR",,, "PCSX2")

BezelDraw()

If hideConsole = true
	SetTimer, HideConsole, 10

SetTitleMatchMode 2 ;Wrong window might be detected in the next loop if we only use the class name for WinGetTitle so we will add fps to it
Loop { ; looping until pcsx2 is done loading game
	; tooltip, loop %A_Index%,0,0
	Sleep, 200
	WinGetTitle, winTitle, fps ahk_class wxWindowClassNR,, PCSX2 ; excluding the title of the GUI window so we can read the title of the game window instead
	Log("Detected Window Title is " . winTitle,4)
	StringSplit, winTextSplit, winTitle, |, %A_Space%
	If ( winTextSplit10 != "" ) ; 10th position in the array is empty until game actually starts
		break
	If A_Index > 150	; after 30 seconds, error out
		ScriptError("There was an error detecting when PCSX2 finished loading your game. Please report this so the module can be fixed.")
}

HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)

If usedDT
	DaemonTools("unmount")

7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


ReadReg(var1) {
	regValue := RegRead("HKEY_CURRENT_USER", "Software\PS2Eplugin\CDVD\CDVDiso", var1) 
	Return %regValue%
}

WriteReg(var1, var2, ValueType="REG_BINARY") {
	RegWrite(ValueType, "HKEY_CURRENT_USER", "Software\PS2Eplugin\CDVD\CDVDiso", var1, var2)
}

StrToHex(S) {
	Return S="" ? "":Chr((*&S>>4)+48) Chr((x:=*&S&15)+48+(x>9)*7) StrToHex(SubStr(S,2))
}

MultiGame:
	; msgbox % "selectedRom = " . selectedRom . "`nselected game = " . currentButton . "`nmgRomPath = " . mgRomPath . "`nmgRomExt = " . mgRomExt . "`nmgRomName = "  . mgRomName
	; Unmount the CD from DaemonTools
	If usedDT
		DaemonTools("unmount")
	Sleep, 500	; Required to prevent  DT from bugging
	; Mount the CD using DaemonTools
	If usedDT
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
	WinMenuSelectItem, PCSX2 ahk_class wxWindowClassNR,, System, Pause
	WinClose("PCSX2 ahk_class wxWindowClassNR") ; sending command to the GUI window to properly close the entire emu
Return
