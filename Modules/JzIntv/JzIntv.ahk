MEmu = JzIntv
MEmuV = v1.0 beta 4
MURL = http://spatula-city.org/~im14u2c/intv/
MAuthor = brolly
MVersion = 1.0
MCRC = E4949269
iCRC = 4F987CB4
MID = 635038268959868838
MSystem = "Mattel Intellivision"
;----------------------------------------------------------------------------
; Notes:
; Run jzintv.exe --help to get all the supported command line switches
; This emulator will only run at 640x480, 320x240 or 320x200
;----------------------------------------------------------------------------
StartModule()
BezelGui()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
Resolution := IniReadCheck(settingsFile, "Settings", "Resolution","1",,1)
EcsEnabled := IniReadCheck(settingsFile, RomName, "ECS","false",,1)
IntellivoiceEnabled := IniReadCheck(settingsFile, RomName, "Intellivoice","false",,1)

BezelStart("fixResMode")

Params := "-q -z" ;Resolution;-q is quiet mode

If (Fullscreen = "true")
	Params := Params . " -f1"
Else
	Params := Params . " -f0"

If (EcsEnabled = "true")
	Params := Params . " -s1"
Else
	Params := Params . " -s0"

If (IntellivoiceEnabled = "true")
	Params := Params . " -v1"
Else
	Params := Params . " -v0"

hideEmuObj := Object("jzintv ahk_class SDL_app",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

HideEmuStart()
Run(executable . " " . Params . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("jzintv ahk_class SDL_app")
WinWaitActive("jzintv ahk_class SDL_app")

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()

CloseProcess:
	FadeOutStart()
	WinClose("jzintv ahk_class SDL_app")
Return
