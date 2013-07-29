MEmu = RetroArch
MEmuV =  v0.9.9
MURL = http://themaister.net/retroarch.html
MAuthor = djvj
MVersion = 2.0.5
MCRC = 6AAD16D
iCRC = 5C431F2F
MID = 635038268922229162
MSystem = "Atari 2600","Bandai Wonderswan","Bandai Wonderswan Color","Final Burn Alpha","NEC PC Engine","NEC PC Engine-CD","NEC TurboGrafx-16","NEC SuperGrafx","NEC TurboGrafx-CD","Nintendo Entertainment System","Nintendo Famicom","Nintendo Famicom Disk System","Nintendo Game Boy","Nintendo Game Boy Color","Nintendo Game Boy Advance","Nintendo Virtual Boy","Nintendo Super Famicom","Sega CD","Sega Game Gear","Sega Genesis","Sega Master System","Sega Mega Drive","Sony PlayStation","Sega SG-1000","SNK Neo Geo Pocket","SNK Neo Geo Pocket Color","Super Nintendo Entertainment System"
;----------------------------------------------------------------------------
; Notes:
; If the emu doesn't load and you get no error, usually this means the LibRetro DLL is not working!
; Look here for the latest LibRetro DLLs: http://forum.themaister.net/
; 
; Fullscreen is controlled via the variable below
; This module uses the CLI version of RetroArch (retroarch.exe), not the GUI (retroarch-phoenix.exe).
; srm are stored in a srm dir in the emu folder
; save states are stored in a save dir in the emu folder
; The emu may make a mouse cursor appear momentarily during launch, MouseMove and hide_cursor seem to have no effect
; Enable 7z support for archived roms
; By default this module is set to use per-system cfg files. This allows different settings for each system you use this emulator for. If you want all systems to use the same retroarch.cfg, set SystemConfigs to false below.
; You can find supported cores that Retroarch supports simply by downloading them from the "retroarch-phoenix.exe" or by visiting here: https://github.com/libretro/libretro.github.com/wiki/Supported-cores
; Some good discussion on cores and filters: http://forum.themaister.net/viewtopic.php?id=270
; Whatever cores you decide to use, make sure they are extracted anywhere in your Emu_Path folder (place them in a LibRetros subfolder if you like). The module will find and load the core you choose for each system.
; The module LibRetro options need to match the name of that core for each system you use this emu.
;
; Nintendo Famicom Disk System - Requires disksys.rom be placed in the folder you define as system_directory in the RetroArch's cfg.
; Sega CD - Requires "bios_CD_E.bin", "bios_CD_J.bin", "bios_CD_U.bin" all be placed in the folder you define as system_directory in the RetroArch's cfg.
; Super Nintendo Entertainment System - requires split all 10 dsp# & st### roms all be placed in the folder you define as system_directory in the RetroArch's cfg. Many games, like Super Mario Kart require these.
; Nintendo Game Boy - Requires "sgb.boot.rom" and "Super Game Boy (World).sfc"to be placed in the folder you define as system_directory in the RetroArch's cfg. This is needed if you want to use Super game boy mode and color palettes. Also requires using the latest bsnes core. Not all games support SGB mode.
; NEC TurboGrafx-CD - Requires "syscard3.pce" be placed in the folder you define as system_directory in the RetroArch's cfg.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

; This object controls how the module reacts to different systems. RetroArch can play a lot of systems, but needs to know what system you want to run, so this module has to adapt.
mType := Object("Atari 2600","LibRetro_2600","Bandai Wonderswan","LibRetro_WSAN","Bandai Wonderswan Color","LibRetro_WSANC","Final Burn Alpha","LibRetro_FBA","NEC PC Engine","LibRetro_PCE","NEC PC Engine-CD","LibRetro_PCECD","NEC SuperGrafx","LibRetro_SGFX","NEC TurboGrafx-16","LibRetro_TG16","NEC TurboGrafx-CD","LibRetro_TGCD","Nintendo Entertainment System","LibRetro_NES","Nintendo Famicom","LibRetro_NFAM","Nintendo Famicom Disk System","LibRetro_NFDS","Nintendo Game Boy","LibRetro_GB","Nintendo Game Boy Color","LibRetro_GBC","Nintendo Game Boy Advance","LibRetro_GBA","Nintendo Super Famicom","LibRetro_NSF","Nintendo Virtual Boy","LibRetro_NVB","Sega Game Gear","LibRetro_GG","Sega CD","LibRetro_SCD","Sega Genesis","LibRetro_GEN","Sega Mega Drive","LibRetro_GEN","Sega Master System","LibRetro_SMS","Sony PlayStation","LibRetro_PSX","Sega SG-1000","LibRetro_SG1K","SNK Neo Geo Pocket","LibRetro_NGP","SNK Neo Geo Pocket Color","LibRetro_NGPC","Super Nintendo Entertainment System","LibRetro_SNES")
ident := mType[systemName]	; search object for the systemName identifier Retroarch uses for its cores
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this " . MEmu . " module: " . moduleName)

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
SystemConfigs := IniReadCheck(settingsFile, "Settings", "SystemConfigs","true",,1)			; If true, RetroArch will use per-system cfg files named to match your System Name. If false, it looks for a retroarch.cfg.
LibRetro_2600 := IniReadCheck(settingsFile, "Settings", "LibRetro_2600","stella_libretro_x86_64_20130629",,1)
LibRetro_FBA := IniReadCheck(settingsFile, "Settings", "LibRetro_FBA","fb_alpha_libretro_x86_64_20130629",,1)
LibRetro_GB := IniReadCheck(settingsFile, "Settings", "LibRetro_GB","bsnes_libretro_balanced_x86_64_20130629",,1)
LibRetro_GBC := IniReadCheck(settingsFile, "Settings", "LibRetro_GBC","gambatte_libretro_x86_64_20130629",,1)
LibRetro_GBA := IniReadCheck(settingsFile, "Settings", "LibRetro_GBA","vba_next_libretro_x86_64_20130629",,1)
LibRetro_GEN := IniReadCheck(settingsFile, "Settings", "LibRetro_GEN","genesis_plus_gx_libretro_x86_64_20130629",,1)
LibRetro_GG := IniReadCheck(settingsFile, "Settings", "LibRetro_GG","genesis_plus_gx_libretro_x86_64_20130629",,1)
LibRetro_NES := IniReadCheck(settingsFile, "Settings", "LibRetro_NES","nestopia_libretro_x86_64_20130629",,1)
LibRetro_NFAM := IniReadCheck(settingsFile, "Settings", "LibRetro_NFAM","nestopia_libretro_x86_64_20130629",,1)
LibRetro_NFDS := IniReadCheck(settingsFile, "Settings", "LibRetro_NFDS","nestopia_libretro_x86_64_20130629",,1)
LibRetro_NSF := IniReadCheck(settingsFile, "Settings", "LibRetro_NSF","bsnes_libretro_balanced_x86_64_20130629",,1)
LibRetro_NVB := IniReadCheck(settingsFile, "Settings", "LibRetro_NVB","mednafen_vb_libretro_x86_64_20130629",,1)
LibRetro_NGP := IniReadCheck(settingsFile, "Settings", "LibRetro_NGP","mednafen_ngp_libretro_x86_64_20130629",,1)
LibRetro_NGPC := IniReadCheck(settingsFile, "Settings", "LibRetro_NGPC","mednafen_ngp_libretro_x86_64_20130629",,1)
LibRetro_PCE := IniReadCheck(settingsFile, "Settings", "LibRetro_PCE","mednafen_pce_fast_libretro_x86_64_20130629",,1)
LibRetro_PCECD := IniReadCheck(settingsFile, "Settings", "LibRetro_PCECD","mednafen_pce_fast_libretro_x86_64_20130629",,1)
LibRetro_PSX := IniReadCheck(settingsFile, "Settings", "LibRetro_PSX","mednafen_psx_libretro_x86_64_20130629",,1)
LibRetro_SCD := IniReadCheck(settingsFile, "Settings", "LibRetro_SCD","genesis_plus_gx_libretro_x86_64_20130629",,1)
LibRetro_SG1K := IniReadCheck(settingsFile, "Settings", "LibRetro_SG1K","genesis_plus_gx_libretro_x86_64_20130629",,1)
LibRetro_SMS := IniReadCheck(settingsFile, "Settings", "LibRetro_SMS","genesis_plus_gx_libretro_x86_64_20130629",,1)
LibRetro_SNES := IniReadCheck(settingsFile, "Settings", "LibRetro_SNES","bsnes_libretro_balanced_x86_64_20130629",,1)
LibRetro_SGFX := IniReadCheck(settingsFile, "Settings", "LibRetro_SGFX","mednafen_pce_fast_libretro_x86_64_20130629",,1)
LibRetro_TG16 := IniReadCheck(settingsFile, "Settings", "LibRetro_TG16","mednafen_pce_fast_libretro_x86_64_20130629",,1)
LibRetro_TGCD := IniReadCheck(settingsFile, "Settings", "LibRetro_TGCD","mednafen_pce_fast_libretro_x86_64_20130629",,1)
LibRetro_WSAN := IniReadCheck(settingsFile, "Settings", "LibRetro_WSAN","mednafen_wswan_libretro_x86_64_20130629",,1)
LibRetro_WSANC := IniReadCheck(settingsFile, "Settings", "LibRetro_WSANC","mednafen_wswan_libretro_x86_64_20130629",,1)

If (FileExist(emuPath . "\" . systemName . ".cfg") && SystemConfigs = "true" )
	retroCFGFile := emuPath . "\" . systemName . ".cfg"
Else
	retroCFGFile := emuPath . "\retroarch.cfg"
Log(MEmu . " is using " . retroCFGFile . " as it's config file.")

Loop, %emuPath%\*.dll,,1 ; loop through all folder in emuPath looking for the ident dll
	If (A_LoopFileName = %ident% . ".dll") {
		libDll := A_LoopFileLongPath
		Break
	}
If !libDll
	ScriptError("Your " . ident . " dll is set to " . %ident% . " but could not locate this file in any folder inside your Emu_Path folder:`n" . emuPath)

If ident In LibRetro_NFDS,LibRetro_SCD,LibRetro_TGCD,LibRetro_PCECD
{	retroCFG := LoadProperties(retroCFGFile)	; load the config into memory
	retroSysDir := ReadProperty(retroCFG,"system_directory")	; read value
	retroSysDir := ConvertRetroCFGKey(retroSysDir)	; remove dbl quotes
	If !retroSysDir
		ScriptError("RetroArch requires you to set your system_directory and place bios rom(s) in there for """ . systemName . """ to function. Please do this first by running ""retroarch-phoenix.exe"" manually.")
}

7z(romPath, romName, romExtension, 7zExtractPath)

If ident = LibRetro_NFDS	; Nintendo Famicom Disk System
{	IfNotExist, %retroSysDir%disksys.rom
		ScriptError("RetroArch requires ""disksys.rom"" for " . systemName . " but could not find it in your system_directory: """ . retroSysDir . """")
} Else If ident = LibRetro_SCD	; Sega CD
{	If romExtension Not In .bin,.cue,.iso
		ScriptError("RetroArch only supports Sega CD games in bin|cue|iso format. It does not support:`n" . romExtension)
	IfNotExist, %retroSysDir%bios_CD_E.bin
		ScriptError("RetroArch requires ""bios_CD_E.bin"" for " . systemName . " but could not find it in your system_directory: """ . retroSysDir . """")
	IfNotExist, %retroSysDir%bios_CD_U.bin
		ScriptError("RetroArch requires ""bios_CD_U.bin"" for " . systemName . " but could not find it in your system_directory: """ . retroSysDir . """")
	IfNotExist, %retroSysDir%bios_CD_J.bin
		ScriptError("RetroArch requires ""bios_CD_J.bin"" for " . systemName . " but could not find it in your system_directory: """ . retroSysDir . """")
} Else If ident in LibRetro_PCECD,LibRetro_TGCD	; NEC PC Engine-CD and NEC TurboGrafx-CD
{	If romExtension != .cue
		ScriptError("RetroArch only supports " . systemName . " games in cue format. It does not support:`n" . romExtension)
	IfNotExist, %retroSysDir%syscard3.pce
		ScriptError("RetroArch requires ""syscard3.pce"" for " . systemName . " but could not find it in your system_directory: """ . retroSysDir . """")
}

; WriteProperty(retroCFGFile,"system_directory","""D:\test""")	; write a new value to the RetroArch cfg file
; SaveProperty()	; save RetroArch cfg file to disk

BezelStart()

fullscreen := (If fullscreen = "true" ? ("-f") : (""))

IfNotExist, %emuPath%\srm
	FileCreateDir, %emuPath%\srm ; creating srm dir if it doesn't exist
IfNotExist, %emuPath%\save
	FileCreateDir, %emuPath%\save ; creating save dir if it doesn't exist

Run(executable . " """ . romPath . "\" . romName . romExtension . """ " . fullscreen . " -c """ . retroCFGFile . """ -L """ . libDll . """ -s srm -S save", emuPath, "Hide")

WinWait("RetroArch ahk_class RetroArch")
WinWaitActive("RetroArch ahk_class RetroArch")

BezelDraw()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


; Used to convert between RetroArch keys and usable data
ConvertRetroCFGKey(txt,direction="read"){
	If direction = read
	{	StringTrimLeft,newtxt,txt,1	; removes the " from the left of the txt
		StringTrimRight,newtxt,newtxt,1	; removes the " from the right of the txt
		If InStr(newtxt,"/")
			StringReplace,newtxt,newtxt,/,\,1	; replaces all forward slashes with backslashes
	} Else If direction = write
	{	newtxt = "%txt%"	; wraps the txt with ""
		If InStr(newtxt,"\")
			StringReplace,newtxt,newtxt,\,/,1	; replaces all backslashes with forward slashes
	} Else
		ScriptError("Not a valid use of ConvertRetroCFGKey. Only ""read"" or ""write"" are supported.")
	Log("ConvertRetroCFGKey - Converted " . txt . " to " . newtxt,4)
	Return newtxt
}

CloseProcess:
	FadeOutStart()
	; Send !{F4}
	WinClose("RetroArch ahk_class RetroArch")
Return
