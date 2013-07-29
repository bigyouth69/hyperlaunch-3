MEmu = ParaJVE
MEmuV = v0.7.0
MURL = http://www.vectrex.fr/ParaJVE/
MAuthor = djvj
MVersion = 2.0
MCRC = 9F3B40DC
iCRC = DC6FE5FD
MID = 635038268912130749
MSystem = "GCE Vectrex"
;----------------------------------------------------------------------------
; Notes:
; ParaJVE requires Java Runtime Environment 1.5.0+ - Get it here: http://java.com/en/download/index.jsp
; Roms are not needed for this system, they come with the emu
; You must use the official database from HyperList for this module to work
; In order to use the built-in overlays, the romName is being converted to the emu's built in game id found in the configuration.xml. This avoids having to edit the xml manually to change it to HS naming standards. We also don't have to setup overlay files this way too!
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := CheckFile(modulePath . "\" . moduleName . ".ini")
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
Menu := IniReadCheck(settingsFile, "Settings", "Menu","false",,1)
Sound := IniReadCheck(settingsFile, "Settings", "Sound","true",,1)
gameID := IniReadCheck(settingsFile, romName, "gameID",A_Space,,1)

If !gameID
	ScriptError("Rom not found in " . moduleName . ".ini`nPlease use the official database from HyperList" )

fullscreen := (If Fullscreen = "true" ? ("-Fullscreen=TRUE") : ("-Fullscreen=FALSE"))
menu := (If Menu = "true" ? ("-Menu=ON") : ("-Menu=OFF"))
sound := (If Sound = "true" ? ("-Sound=ON") : ("-Sound=OFF"))

Run(executable . " -game=" . gameID . " " . Fullscreen . " " . Menu . " " . Sound, emuPath) ;, "Min")

WinWait("ParaJVE ahk_class SunAwtFrame")
WinWaitActive("ParaJVE ahk_class SunAwtFrame")

FadeInExit()
Process("WaitClose", "javaw.exe")
FadeOutExit()
ExitModule()

CloseProcess:
	FadeOutStart()
	WinClose("ParaJVE ahk_class SunAwtFrame")
Return
