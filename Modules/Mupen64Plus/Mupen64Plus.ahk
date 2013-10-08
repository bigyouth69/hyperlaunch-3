MEmu = Mupen64Plus
MEmuV = v2.0
MURL = https://code.google.com/p/mupen64plus/
MAuthor = djvj & ghutch92
MVersion = 2.0.1
MCRC = 43DEC6C4
iCRC = 232C6716
MID = 635163407878625424
MSystem = "Nintendo 64"
;----------------------------------------------------------------------------
; Notes:
; CLI options: https://code.google.com/p/mupen64plus/wiki/UIConsoleUsage
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1) ;enable/disable fullscreen
resolution := IniReadCheck(settingsFile, "Settings", "Resolution",A_ScreenWidth . "x" . A_ScreenHeight,,1) ;display resolution (640x480, 800x600, 1024x768, etc)
gfxPlugin := IniReadCheck(settingsFile, "Settings|" . romName, "gfx_plugin",,,1) ;use this gfx plugin full path to dll (relative path ok)
audioPlugin := IniReadCheck(settingsFile, "Settings|" . romName, "audio_plugin",,,1) ;use this audio plugin full path to dll (relative path ok)
inputPlugin := IniReadCheck(settingsFile, "Settings|" . romName, "input_plugin",,,1) ;use this input plugin full path to dll (relative path ok)
rspPlugin := IniReadCheck(settingsFile, "Settings|" . romName, "rsp_plugin",,,1) ;use this rsp plugin full path to dll (relative path ok)
emuMode := IniReadCheck(settingsFile, "Settings|" . romName, "emu_mode",2,,1) ;set emu mode to: 0=Pure Interpreter 1=Interpreter 2=DynaRec
disableExtraMemory := IniReadCheck(settingsFile, "Settings|" . romName, "ExtraMemory","false",,1) ;Disable 4MB expansion RAM pack. May be necessary for some games
cheatsEnabled := IniReadCheck(settingsFile, "Settings|" . romName, "CheatsEnabled","false",,1) ;enable/disable cheats
otherOptions := IniReadCheck(settingsFile, "Settings|" . romName, "OtherOptions",,,1) ;set other command line options here
cheats := IniReadCheck(settingsFile, romName, "Cheats",,,1) ;comma delimited list of cheats to enable ex: 0,1,2

; Check for and convert to absolute all path vars
gfxPlugin := If gfxPlugin ? CheckFile(GetFullName(gfxPlugin)) : ""
audioPlugin := If audioPlugin ? CheckFile(GetFullName(audioPlugin)) : ""
inputPlugin := If inputPlugin ? CheckFile(GetFullName(inputPlugin)) : ""
rspPlugin := If rspPlugin ? CheckFile(GetFullName(rspPlugin)) : ""

BezelStart()

;decide what settings to use 
fullscreen := If (fullscreen = "true") ? " --fullscreen" : " --windowed"
resolution := " --resolution " . resolution
gfxPlugin := If gfxPlugin ? " --gfx " . gfxPlugin : ""
audioPlugin := If audioPlugin ? " --audio " . audioPlugin : ""
inputPlugin := If inputPlugin ? " --input " . rspPlugin : ""
rspPlugin := If rspPlugin ? " --rsp " . gfxPlugin : ""
emuMode := If emuMode ? " --emumode " . emuMode : ""
disableExtraMemory := If disableExtraMemory ? " --set Core[DisableExtraMem]=" . disableExtraMemory : ""
cheats := If cheatsEnabled ? " --cheats all"  : ""
otherOptions := If otherOptions ? " " . otherOptions : ""
cheats := If (cheatsEnabled = "true" && cheats != "") ? (" --cheats " . Cheats) : ""

7z(romPath, romName, romExtension, 7zExtractPath)

If romExtension in .zip,.7z,.rar
	ScriptError(MEmu . " does not support compressed roms. Please enable 7z support in HLHQ to use this module/emu.")

Run(executable . " --noosd" . fullscreen . resolution . gfxPlugin . audioPlugin . inputPlugin . rspPlugin . emuMode . disableExtraMemory . cheats . otherOptions . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("AHK_class SDL_app")
WinSet, Transparent, On, ahk_class ConsoleWindowClass	; makes the console window transparent so you don't see it on exit
WinWaitActive("AHK_class SDL_app")
WinSet, Transparent, On, ahk_class SDL_app	; hide emu so we don't as much of it being resized, can't get rid of it completely however.

BezelDraw()
FadeInExit()

WinSet, Transparent, Off, ahk_class SDL_app	; make emu visible

Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("ahk_class SDL_app")
Return
