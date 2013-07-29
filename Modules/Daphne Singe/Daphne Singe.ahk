MEmu = Daphne Singe
MEmuV =  v1.14
MURL = http://www.singeengine.com/cms/
MAuthor = djvj
MVersion = 2.0
MCRC = 886E604E
iCRC = 3F762B18
MID = 635038268880264228
MSystem = "American Laser Games","WoW Action Max"
;----------------------------------------------------------------------------
; Notes:
; Rom_Extension should be singe
; Your framefiles need to exist in the same dir as your Rom_Path, in each game's subfolder, and have a txt extension. The filename should match the name in your xml.

; American Laser Games
; For example,  If you rompath is C:Hyperspin\Games\American Laser Games\, the drugwars game would be found in C:Hyperspin\Games\American Laser Games\maddog\
; and the framefile would be in C:Hyperspin\Games\American Laser Games\maddog\maddog.txt
; To change the dir you want to run your games from:
; 1. Backup all your /daphne/singe/ROMNAME/ROMNAME.singe, cdrom-globals.singe, and service.singe files, most games all three in each romdir
; 2. Move all the folders in your /daphne/singe/ folder to the new location you want. You should have one folder for each game.
; 3. Open each ROMNAME.singe, cdrom-globals.singe, and service.singe in notepad and do a find/replace of all instances shown below. For example using an SMB share:
; Old
; ("singe/
; New:
; ("//BLACKPC/Hyperspin/Games/American Laser Games/
;
; If using a local drive, it would look something like this C:/Hyperspin/Games/American Laser Games/

; WoW Action Max
; Emu_Path should be something like this C:\HyperSpin\Emulators\WoW Action Max\daphne-singe\
; Rom_Path has to point to where all the m2v video files are kept
; Rom_Extension should be singe
; Your framefiles need to exist in the same dir as your rompath and all have txt extensions. The filename should match the name in your xml.
; To change the dir you want to run your games from:
; 1. Backup your /daphne/singe/Action Max/Emulator.singe file
; 2. Move all the files (except Emulator.singe) in your /daphne/singe/Action Max/ folder to the new location you want.
; 3. Open Emulator.singe in notepad and do a find/replace of all instances shown below. For example using an SMB share:
; Old
; "singe/Action Max/
; New:
; "//BLACKPC/Hyperspin/Games/WoW Action Max/
;
; If using a local drive, it would look something like this C:/Hyperspin/Games/WoW Action Max/
;
; There should be 18 instances that need replacing.
; 4. The only file that should be in your /daphne/singe/Action Max/ dir should be the edited Emulator.singe file (and your backup).
;
; If you are upgrading from the old daphne-singe-v1.0 to 1.14, don't forget to copy the old singe dir to the new emu folder, it doesn't come with the contents of that folder that you need.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "settings", "Fullscreen","true",,1)
daphneWidth := IniReadCheck(settingsFile, "settings", "daphneWidth","1024",,1)
daphneHeight := IniReadCheck(settingsFile, "settings", "daphneHeight","768",,1)

; Emptying variables if they are not set
fs := (If Fullscreen = "true" ? ("-fullscreen_window") : ("")) ; fullscreen_window mode allows guncon and aimtraks to work
w := (daphneWidth ? ("-x " . daphneWidth) : (""))
h := (daphneHeight ? ("-y " . daphneHeight) : (""))

7z(romPath, romName, romExtension, 7zExtractPath)

; This allows us to send variables, that when empty, are not sent to the Run command
Run(executable . " singe vldp " . w . A_Space . h . A_Space . fs . A_Space . "-framefile """ . romPath . "\" . romName . ".txt""" . A_Space . "-script """ . romPath . "\" . romName . ".singe""", emuPath)

WinWait("DAPHNE ahk_class SDL_app")
WinWaitActive("DAPHNE ahk_class SDL_app")

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()

HaltEmu:
	Send, {P}
Return
RestoreEmu:
	Winrestore, AHK_class %EmulatorClass%
	Send, {P}
Return

CloseProcess:
	FadeOutStart()
	WinClose("DAPHNE ahk_class SDL_app")
	;Process, Close, %executable% ; WoW Action Max module used this
Return
