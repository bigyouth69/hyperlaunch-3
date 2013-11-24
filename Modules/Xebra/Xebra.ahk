MEmu = Xebra
MEmuV =  v08/15/2013
MURL = http://drhell.web.fc2.com/ps1/
MAuthor = djvj
MVersion = 2.0.1
MCRC = 30A312BA
iCRC = AAB5A3D7
MID = 635038268936701199
MSystem = "Sony PlayStation"
;----------------------------------------------------------------------------
; Notes:
; Make sure you have a Playstation BIOS file in your emulator directory. The BIOS must be named OSROM with no extension.
; On first time use, 2 memory card files will be created (BU00 and BU01)
; Will load CUE and CCD files automatically, no Daemon Tools needed, but built-in image is buggy and not suggested to use it.
; Bios will load first, then the game (takes about 5 seconds)
; If you get nothing but a black screen at boot, make sure the OSROM file is an actual BIOS. If this file is not correct, no games will work.
; The suggested bios to rename to OSROM is SCPH7502 as it is the only bios that Legend of Dragoon works with.
;
; Press F12 to enable / disable gui, change video and controller settings
; F1 Save state
; F7 Load state
; If a game does not work for you, try a different RUN setting by adding it to the Settings.ini
;
; Per-Game Run setting:
; Use HyperLaunchHQ to set module and per-game settings.
;
; Per-Game XEBRA.INI setup:
; On first run of this module, it will create the GameINIPath defined below and copy your XEBRA.INI there as your Default
; If you want different emu settings for a specific game, play the game and make your changes. After you exit, copy the XEBRA.INI to your GameINIPath and rename it to match the gam name in your xml.
; Example, if your game name is Final Fantasy VII (USA) (Disc 1), then you will name it Final Fantasy VII (USA) (Disc 1).INI
; Next time you play the game, the module will overwrite your XEBRA,INI with the new ini you made.
; If you want to reset your default INI, just delete it. The next time you run the module, it will create a new default INI for you.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
GameINIPath := IniReadCheck(settingsFile, "Settings", "GameINIPath",emuPath . "\GameINIs",,1)		 ; This is the path to your per-game XEBRA.INI(s). (default is %emuPath%\GameINIs)
defXebraINI := IniReadCheck(settingsFile, "Settings", "defXebraINI","XEBRA.default.INI",,1)	 ; Your default XEBRA.INI you want to use
AutoGameINIs := IniReadCheck(settingsFile, "Settings", "AutoGameINIs","false",,1)		 ; If true, will auto-backup your XEBRA.INI to the GameINIPath and rename it to match your game. This aids in creating per-game modules quickly. WARNING, this WILL overwrite existing backed-up game INIs.
perGameMemCards := IniReadCheck(settingsFile, "Settings", "PerGameMemoryCards","true",,1)
vRun := IniReadCheck(settingsFile, romName, "run","1",,1)					 ; default is 1 (interprete)

BezelStart()

Fullscreen := If Fullscreen = "true" ? "-FULL" : ""
vRun := vRun=3 ? "-RUN3" : (vRun=2 ? "-RUN2" : "-RUN1")

; Per-Game INIs
IfNotExist, %GameINIPath%\%defXebraINI%
{	FileCreateDir, %GameINIPath%
	FileCopy, %emuPath%\XEBRA.INI, %GameINIPath%\%defXebraINI%, 1
}
gameINI := "-INI """ . GameINIPath . "\" . (If FileExist(GameINIPath . "\" . romName . ".INI") ? (romName . ".INI""") : (defXebraINI . """"))

; Memory Cards
If perGameMemCards = true
{	memCardPath := emuPath . "\memcards"
	defaultMemCard1 := memCardPath . "\_default.BU00"	; defining default blank memory card for slot 1
	defaultMemCard2 := memCardPath . "\_default.BU10"	; defining default blank memory card for slot 2
	romMemCard1 := memCardPath . "\" . romName . ".BU00"		; defining name for rom's memory card for slot 1
	romMemCard2 := memCardPath . "\" . romName . ".BU10"		; defining name for rom's memory card for slot 2
	memCard1 := emuPath . "\BU00"
	memCard2 := emuPath . "\BU10"
	IfNotExist, %memCardPath%
		FileCreateDir, %memCardPath%	; create memcard folder if it doesn't exist
	Loop 2 {
		IfNotExist, % defaultMemCard%A_Index%
			FileCopy, % memCard%A_Index%, % defaultMemCard%A_Index%	; if default cards do not exist, create them from the current memory cards
		IfExist, % romMemCard%A_Index%
		{	FileCopy, % romMemCard%A_Index%, % memCard%A_Index%		; if rom mem cards exist, copy them over to the emuPath so they can be used in game
			Log("Module - Switched memory card in Slot " . A_Index . " to: " . romMemCard%A_Index%)
		}
	}
}

7z(romPath, romName, romExtension, 7zExtractPath)

; Mount the CD using DaemonTools
If ((romExtension = ".cue" || romExtension = ".ccd") && dtEnabled = "true" ) {
	DaemonTools("get")
	DaemonTools("mount",romPath . "\" . romName . romExtension)
	usedDT := 1
	Run(executable . " " . gameINI . " " . Fullscreen . " -SPTI " . dtDriveLetter . " " . vRun, emuPath)
} Else
	Run(executable . " " . gameINI . " " . Fullscreen . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("XEBRA ahk_class #32770")
WinWaitActive("XEBRA ahk_class #32770")

BezelDraw()
FadeInExit()
Process("WaitClose",executable)

If usedDT
	DaemonTools("unmount")

If AutoGameINIs = true
	FileCopy, %emuPath%\XEBRA.INI, %GameINIPath%\%romName%.INI, 1

If perGameMemCards = true
	Loop 2
	{	FileCopy, % memCard%A_Index%, % romMemCard%A_Index%, 1		; Backup (overwrite) the mem cards to the mem card folder for next time this game is launched
		Log("Module - Backing up Slot " . A_Index . " memory card to: " . romMemCard%A_Index%)
	}

7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


MultiGame:
	; msgbox % "selectedRom = " . selectedRom . "`nselected game = " . currentButton . "`nmgRomPath = " . mgRomPath . "`nmgRomExt = " . mgRomExt . "`nmgRomName = "  . mgRomName
	; Unmount the CD from DaemonTools
	If usedDT
		DaemonTools("unmount")
	Sleep, 500	; Required to prevent DT from bugging
	; Mount the CD using DaemonTools
	If usedDT
		DaemonTools("mount",selectedRom)
Return

CloseProcess:
	FadeOutStart()
	; PostMessage, 0x111, 00276,,,XEBRA ahk_class #32770	; 2011 xebra uses this control
	PostMessage, 0x111, 00278,,,XEBRA ahk_class #32770	; if we don't pause it first, xebra does not know how to exit properly.
	Log("Module - Sent command to pause Xebra so it can exit cleanly")
	Sleep, 1000
	; PostMessage, 0x111, 00272,,,XEBRA ahk_class #32770	; 2011 xebra uses this control
	PostMessage, 0x111, 00273,,,XEBRA ahk_class #32770	; Exit
	Log("Module - Sent command to exit Xebra")
Return
