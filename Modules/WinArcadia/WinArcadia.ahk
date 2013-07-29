MEmu = WinArcadia
MEmuV =  v18.70
MURL = http://amigan.1emu.net/releases/
MAuthor = brolly
MVersion = 2.0
MCRC = 6F41045
MID = 635038268934589449
MSystem = "Emerson Arcadia 2001","Interton VC4000"
;----------------------------------------------------------------------------
; Notes:
; You must start the emulator oustide HS and set it fullscreen there or fullscreen mode might not work 
; The settings are saved on a file named WA.CFG inside the Configs folder.
; You can also create different config files per game in that folder 
; and name them to match the roms and those will be used instead of the default WA.CFG one.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()
7z(romPath, romName, romExtension, 7zExtractPath)

mType := Object("Emerson Arcadia 2001","ARCADIA","Interton VC4000","INTERTON")
ident := mType[systemName]	; search object for the systemName identifier WinArcadia uses
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this WinArcadia module: " . moduleName)

romNameCfgFile := %emuPath%\Configs\%romName%.cfg
cfgFile := (If FileExist(romNameCfgFile) ? romName : "WA") . ".cfg"

Run(executable . """ MACHINE=" . ident . " SETTINGS=""" . cfgFile . """ FULLSCREEN=ON STRETCH=ON FILE=""" . romPath . "\" . romName . romExtension . """", emuPath)

WinTitle := (If ident = "INTERTON" ? "WinInterton" : "WinArcadia") . " ahk_class WinArcadia"

WinWait(WinTitle)
WinWaitActive(WinTitle)

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose(WinTitle)
Return
