MEmu = Xebra
MEmuV =  v04/25/2011
MURL = http://drhell.web.fc2.com/ps1/
MAuthor = djvj
MVersion = 2.0
MCRC = 43AB3A51
iCRC = C3D8E48E
MID = 635038268936701199
MSystem = "Sony PlayStation"
;----------------------------------------------------------------------------
; Notes:
; Make sure you have a Playstation BIOS file in your emulator directory. The BIOS must be named OSROM with no extension.
; On first time use, 2 memory card files will be created (BU00 and BU01)
; Will load CUE and CCD files automatically, no Daemon Tools needed, but built-in image is buggy and not suggested to use it.
; Bios will load first, then the game (takes about 5 seconds)
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
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(emuSettingsFile, "Settings", "Fullscreen","true",,1)
GameINIPath := IniReadCheck(emuSettingsFile, "Settings", "GameINIPath",emuPath . "\GameINIs",,1)		 ; This is the path to your per-game XEBRA.INI(s). (default is %emuPath%\GameINIs)
defXebraINI := IniReadCheck(emuSettingsFile, "Settings", "defXebraINI","XEBRA.default.INI",,1)	 ; Your default XEBRA.INI you want to use
AutoGameINIs := IniReadCheck(emuSettingsFile, "Settings", "AutoGameINIs","false",,1)		 ; If true, will auto-backup your XEBRA.INI to the GameINIPath and rename it to match your game. This aids in creating per-game modules quickly. WARNING, this WILL overwrite existing backed-up game INIs.
vRun := IniReadCheck(settingsFile, romName, "run","1",,1)					 ; default is 1 (interprete)

Fullscreen := If (Fullscreen = "true") ? ("-FULL") : ("")
vRun := ((vRun=3) ? ("-RUN3") : ( ((vRun=2) ? ("-RUN2") : ("-RUN1"))))

; ******* Per-Game INI *******
IfNotExist, %GameINIPath%\%defXebraINI%
{	FileCreateDir, %GameINIPath%
	FileCopy, %emuPath%\XEBRA.INI, %GameINIPath%\%defXebraINI%, 1
}
gameINI := "-INI """ . GameINIPath . "\" . (If FileExist(GameINIPath . "\" . romName . ".INI") ? (romName . ".INI""") : (defXebraINI . """"))

7z(romPath, romName, romExtension, 7zExtractPath)

; Mount the CD using DaemonTools
If ( romExtension = ".cue" && dtEnabled = "true" ) {
	DaemonTools("get")
	DaemonTools("mount",romPath . "\" . romName . romExtension)
	Run(executable . " " . gameINI . " " . Fullscreen . " -SPTI " . dtDriveLetter . " " . vRun, emuPath)
} Else
	Run(executable . " " . gameINI . " " . Fullscreen . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("XEBRA ahk_class #32770")
WinWaitActive("XEBRA ahk_class #32770")

FadeInExit()
Process("WaitClose",executable)

If ( romExtension = ".cue" && dtEnabled = "true" )
	DaemonTools("unmount")

If AutoGameINIs = true
	FileCopy, %emuPath%\XEBRA.INI, %GameINIPath%\%romName%.INI, 1

7zCleanUp()
FadeOutExit()
ExitModule()


MultiGame:
	; msgbox % "selectedRom = " . selectedRom . "`nselected game = " . currentButton . "`nmgRomPath = " . mgRomPath . "`nmgRomExt = " . mgRomExt . "`nmgRomName = "  . mgRomName
	; Unmount the CD from DaemonTools
	If ( romExtension = ".cue" && dtEnabled = "true" )
		DaemonTools("unmount")
	Sleep, 500	; Required to prevent  DT from bugging
	; Mount the CD using DaemonTools
	If ( romExtension = ".cue" && dtEnabled = "true" )
		DaemonTools("mount",selectedRom)
Return

CloseProcess:
	FadeOutStart()
	WinClose("XEBRA ahk_class #32770")
	Sleep, 500
	errorLvl := Process("Exist", executable)
	If errorLvl
		WinMenuSelectItem, XEBRA ahk_class #32770,, File, Exit
Return
