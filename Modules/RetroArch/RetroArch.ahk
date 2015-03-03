MEmu = RetroArch
MEmuV =  v12-25-2014 Nightly
MURL = http://themaister.net/retroarch.html
MAuthor = djvj,zerojay
MVersion = 2.2.4
MCRC = C2915E51
iCRC = A130BB6E
MID = 635038268922229162
MSystem = "Acorn Archimedes","Acorn BBC Micro Model A","Acorn BBC Micro Model B","Acorn BBC Micro","AAE","Amstrad CPC","Amstrad GX4000","APF Imagination Machine","Apogee BK-01","Atari 2600","Atari 5200","Atari 7800","Atari Jaguar","Atari Lynx","Atari ST","Bally Astrocade","Bandai Gundam RX-78","Bandai Super Vision 8000","Bandai Wonderswan","Bandai Wonderswan Color","Casio PV-1000","Casio PV-2000","ColecoVision","Commodore Amiga","Creatronic Mega Duck","Dragon 64","Emerson Arcadia 2001","Entex Adventure Vision","Epoch Game Pocket Computer","Epoch Super Cassette Vision","Exidy Sorcerer","Fairchild Channel F","Final Burn Alpha","Funtech Super Acan","GamePark 32","GCE Vectrex","Hartung Game Master","JungleTac Sport Vii","MAME","Magnavox Odyssey 2","Microsoft MSX","Microsoft MSX2","Matra & Hachette Alice","Mattel Aquarius","Mattel Intellivision","NEC PC-8801","NEC PC-9801","NEC PC Engine","NEC PC Engine-CD","NEC PC-FX","NEC TurboGrafx-16","NEC SuperGrafx","NEC TurboGrafx-CD","Nintendo 64","Nintendo Arcade Systems","Nintendo DS","Nintendo Entertainment System","Nintendo Famicom","Nintendo Famicom Disk System","Nintendo Game Boy","Nintendo Game Boy Color","Nintendo Game Boy Japan","Nintendo Game Boy Advance","Nintendo Super Game Boy","Nintendo Pokemon Mini","Nintendo Virtual Boy","Nintendo Super Famicom","Nintendo Super Famicom Satellaview","Panasonic 3DO","Elektronska Industrija Pecom 64","Philips CD-i","Philips Videopac","RCA Studio II","Sega 32X","Sega SC-3000","Sega SG-1000","Sega CD","Sega Game Gear","Sega Genesis","Sega Master System","Sega Mega Drive","Sega Pico","Sega Saturn","Sega Saturn Japan","Sega VMU","Sega ST-V","Sinclair ZX Spectrum","Sony PlayStation","Sony PocketStation","Sony PSP","Sord M5","SNK Neo Geo","SNK Neo Geo MVS","SNK Neo Geo AES","SNK Neo Geo Pocket","SNK Neo Geo CD","SNK Neo Geo Pocket Color","Spectravideo","Super Nintendo Entertainment System","Tandy TRS-80 Color Computer","Texas Instruments TI 99-4A","Thomson MO5","Tomy Tutor","VTech CreatiVision","Watara Supervision"
;----------------------------------------------------------------------------
; Notes:
; If the emu doesn't load and you get no error, usually this means the LibRetro DLL is not working!
; Devs stated they will never add support for mounted images (like via DT)
; Fullscreen is controlled via the module setting in HLHQ
; This module uses the CLI version of RetroArch (retroarch.exe), not the GUI (retroarch-phoenix.exe).
; The emu may make a mouse cursor appear momentarily during launch, MouseMove and hide_cursor seem to have no effect
; Enable 7z support for archived roms
; Available CLI options: https://github.com/PyroFilmsFX/iOS/blob/master/docs/retroarch.1
;
; LibRetro DLLs:
; LibRetro DLLs come with the emu, but here is another source for them: http://forum.themaister.net/
; Whatever cores you decide to use, make sure they are extracted anywhere in your Emu_Path\cores folder. The module will find and load the default core unless you choose a custom one for each system.
; You can find supported cores that Retroarch supports simply by downloading them from the "retroarch-phoenix.exe" or by visiting here: https://github.com/libretro/libretro.github.com/wiki/Supported-cores
; Some good discussion on cores and filters: http://forum.themaister.net/viewtopic.php?id=270
;
; SRM files:
; srm are stored in a "srm" dir in the emu folder. Each system ran through retroarch gets its own folder inside srm
;
; Save states:
; Save states are stored in a "save" dir in the emu folder. Each system ran through retroarch gets its own folder inside save
;
; Config files:
; RetroArch will use per-system cfg files named to match your System Name. The global one is "retroarch.cfg" but the module will search for cfg files in any of the emu's subfolders. If system ones exist, they take precedence over retroarch.cfg.
; This allows different settings for each system you use this emulator for. If you want all systems to use the same retroarch.cfg, do not have any system named cfg files, or just create ones for the systems you want custom settings.
;
; MESS:
; MESS BIOS roms should be placed in the system\mess folder
;
; System Specific Notes:
; Microsoft MSX/MSX2: Launch an MSX game and in the core options, set the console to be an MSX2 and it will play both just fine.
; Nintendo Famicom Disk System - Requires disksys.rom be placed in the folder you define as system_directory in the RetroArch's cfg.
; Sega CD - Requires "bios_CD_E.bin", "bios_CD_J.bin", "bios_CD_U.bin" all be placed in the folder you define as system_directory in the RetroArch's cfg.
; Super Nintendo Entertainment System - requires split all 10 dsp# & st### roms all be placed in the folder you define as system_directory in the RetroArch's cfg. Many games, like Super Mario Kart require these.
; NEC TurboGrafx-CD - Requires "syscard3.pce" be placed in the folder you define as system_directory in the RetroArch's cfg.
; Nintendo Super Game Boy - Set the Module setting in HLHQ SuperGameBoy to true to enable a system or only a rom to use SGB mode. This is not needed if your systemName is set to the official name of "Nintendo Super Game Boy". Requires "sgb.boot.rom" and "Super Game Boy (World).sfc" to be placed in the folder you define as system_directory in the RetroArch's cfg. This is needed if you want to use Super game boy mode and color palettes. Also requires using the latest bsnes core. Not all games support SGB mode.
; MAME: Turn off the nag screen by running a game, then press F1 and go to core options and switch off the nag screen there.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

; This object controls how the module reacts to different systems. RetroArch can play a lot of systems, but needs to know what system you want to run, so this module has to adapt.
mType := Object("Acorn Archimedes","LibRetro_AARCH","Acorn BBC Micro Model A","LibRetro_BBCA","Acorn BBC Micro Model B","LibRetro_BBCB","Acorn BBC Micro","LibRetro_BBCB","AAE","LibRetro_AAE","Amstrad CPC","LibRetro_CPC","Amstrad GX4000","LibRetro_GX4K","APF Imagination Machine","LibRetro_APF","Apogee BK-01","LibRetro_APOG","Atari 2600","LibRetro_2600","Atari 5200","LibRetro_5200","Atari 7800","LibRetro_7800","Atari Jaguar","LibRetro_JAG","Atari Lynx","LibRetro_LYNX","Atari ST","LibRetro_ST","Bally Astrocade","LibRetro_BAST","Bandai Gundam RX-78","LibRetro_BGRX","Bandai Super Vision 8000","LibRetro_SV8K","Bandai Wonderswan","LibRetro_WSAN","Bandai Wonderswan Color","LibRetro_WSANC","Casio PV-1000","LibRetro_CAS1K","Casio PV-2000","LibRetro_CAS2K","ColecoVision","LibRetro_COLEC","Commodore Amiga","LibRetro_PUAE","Creatronic Mega Duck","LibRetro_DUCK","Dragon 64","LibRetro_DRAG64","Emerson Arcadia 2001","LibRetro_A2001","Entex Adventure Vision","LibRetro_AVISION","Epoch Game Pocket Computer","LibRetro_GPCKET","Epoch Super Cassette Vision","LibRetro_SCV","Exidy Sorcerer","LibRetro_SORCR","Fairchild Channel F","LibRetro_CHANF","Final Burn Alpha","LibRetro_FBA","Funtech Super Acan","LibRetro_SACAN","GamePark 32","LibRetro_GP32","GCE Vectrex","LibRetro_VECTX","Hartung Game Master","LibRetro_GMASTR","JungleTac Sport Vii","LibRddetro_SPORTV","MAME","LibRetro_MAME","Magnavox Odyssey 2","LibRetro_ODYS2","Mattel Aquarius","LibRetro_AQUA","Mattel Intellivision","LibRetro_INTV","MGT Sam Coupe","LibRetro_SAMCP","Microsoft MS-DOS","LibRetro_MSDOS","Microsoft MSX","LibRetro_MSX","Microsoft MSX2","LibRetro_MSX2","Microsoft Windows 3.x","LibRetro_WIN3X","Matra & Hachette Alice","LibRetro_ALICE","NEC PC-8801","LibRetro_PC8801","NEC PC-9801","LibRetro_PC9801","NEC PC Engine","LibRetro_PCE","NEC PC Engine-CD","LibRetro_PCECD","NEC PC-FX","LibRetro_PCFX","NEC SuperGrafx","LibRetro_SGFX","NEC TurboGrafx-16","LibRetro_TG16","NEC TurboGrafx-CD","LibRetro_TGCD","Nintendo 64","LibRetro_N64","Nintendo Arcade Systems","LibRetro_NINARC","Nintendo DS","LibRetro_DS","Nintendo Entertainment System","LibRetro_NES","Nintendo Famicom","LibRetro_NFAM","Nintendo Famicom Disk System","LibRetro_NFDS","Nintendo Game Boy","LibRetro_GB","Nintendo Game Boy Color","LibRetro_GBC","Nintendo Game Boy Japan","LibRetro_GBJ","Nintendo Game Boy Advance","LibRetro_GBA","Nintendo Pokemon Mini","LibRetro_POKE","Nintendo Super Famicom","LibRetro_NSF","Nintendo Super Famicom Satellaview","LibRetro_NSFS","Nintendo Super Game Boy","LibRetro_SGB","Nintendo Virtual Boy","LibRetro_NVB","Panasonic 3DO","LibRetro_3DO","Elektronska Industrija Pecom 64","LibRetro_P64","Philips CD-i","LibRetro_CDI","Philips Videopac","LibRetro_PVID","RCA Studio II","LibRetro_STUD2","SCUMMVM","LibRetro_SCUMM","Sega 32X","LibRetro_32X","Sega CD","LibRetro_SCD","Sega Game Gear","LibRetro_GG","Sega Genesis","LibRetro_GEN","Sega Mega Drive","LibRetro_GEN","Sega Master System","LibRetro_SMS","Sega Pico","LibRetro_PICO","Sega VMU","LibRetro_SVMU","Sony PlayStation","LibRetro_PSX","Sony PocketStation","LibRetro_POCKS","Sony PSP","LibRetro_PSP","Sega Saturn","LibRetro_SAT","Sega Saturn Japan","LibRetro_SAT","Sega SG-1000","LibRetro_SG1K","Sega SC-3000","LibRetro_SC3K","Sega ST-V","LibRetro_STV","SNK Neo Geo","LibRetro_NEO","SNK Neo Geo AES","LibRetro_NEOAES","SNK Neo Geo MVS","LibRetro_NEOMVS","SNK Neo Geo Pocket","LibRetro_NGP","SNK Neo Geo Pocket Color","LibRetro_NGPC","SNK Neo Geo CD","LibRetro_NEOCD","Sord M5","LibRetro_SORD","Spectravideo","LibRetro_SV328","Super Nintendo Entertainment System","LibRetro_SNES","Sinclair ZX Spectrum","LibRetro_SPECZX","Tandy TRS-80 Color Computer","LibRetro_TRS80","Texas Instruments TI 99-4A","LibRetro_TI99","Thomson MO5","LibRetro_MO5","Tomy Tutor","LibRetro_TOMY","VTech CreatiVision","LibRetro_VTECH","Watara Supervision","LibRetro_SUPRV")
ident := mType[systemName]	; search object for the systemName identifier Retroarch uses for its cores
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this " . MEmu . " module: " . moduleName)

coreTypes := Object("LibRetro_2600","stella_libretro","LibRetro_5200","mess_libretro","LibRetro_7800","prosystem_libretro","LibRetro_32X","picodrive_libretro","LibRetro_3DO","4do_libretro","LibRetro_A2001","mess_libretro","LibRetro_AARCH","mess_libretro","LibRetro_AAE","mame_libretro","LibRetro_ALICE","mess_libretro","LibRetro_APF","LibRetro_APOG","mess_libretro""mess_libretro","LibRetro_AQUA","mess_libretro","LibRetro_AVISION","mess_libretro","LibRetro_BAST","mess_libretro","LibRetro_BBCA","mess_libretro","LibRetro_BBCB","mess_libretro","LibRetro_BGRX","mess_libretro","LibRetro_CAS1K","mess_libretro","LibRetro_CAS2K","mess_libretro","LibRetro_CDI","mess_libretro","LibRetro_CHANF","mess_libretro","LibRetro_COLEC","mess_libretro","LibRetro_CPC","mess_libretro","LibRetro_DRAG64","mess_libretro","LibRetro_DS","desmume_libretro","LibRetro_DUCK","mess_libretro","LibRetro_FBA","fb_alpha_libretro","LibRetro_GB","gambatte_libretro","LibRetro_GBC","gambatte_libretro","LibRetro_GBA","vba_next_libretro","LibRetro_GBJ","gambatte_libretro","LibRetro_GEN","genesis_plus_gx_libretro","LibRetro_GG","genesis_plus_gx_libretro","LibRetro_GMASTR","mess_libretro","LibRetro_GP32","mess_libretro","LibRetro_GPCKET","mess_libretro","LibRetro_GX4K","mess_libretro","LibRetro_INTV","mess_libretro","LibRetro_JAG","virtualjaguar_libretro","LibRetro_LYNX","handy_libretro","LibRetro_MAME","mame_libretro","LibRetro_MO5","mess_libretro","LibRetro_MSDOS","dosbox_libretro","LibRetro_MSX","bluemsx_libretro","LibRetro_MSX2","bluemsx_libretro","LibRetro_N64","mupen64plus_libretro","LibRetro_NEO","fb_alpha_libretro","LibRetro_NEOCD","mess_libretro","LibRetro_NEOAES","mess_libretro","LibRetro_NEOMVS","mame_libretro","LibRetro_NES","nestopia_libretro","LibRetro_NFAM","nestopia_libretro","LibRetro_NFDS","nestopia_libretro","LibRetro_NSF","bsnes_balanced_libretro","LibRetro_NSFS","snes9x_libretro","LibRetro_NVB","mednafen_vb_libretro","LibRetro_NGP","mednafen_ngp_libretro","LibRetro_NGPC","mednafen_ngp_libretro","LibRetro_NINARC","mame_libretro","LibRetro_ODYS2","mess_libretro","LibRetro_P64","mess_libretro","LibRetro_PC8801","mess_libretro","LibRetro_PC9801","mess_libretro","LibRetro_PCE","mednafen_pce_fast_libretro","LibRetro_PCECD","mednafen_pce_fast_libretro","LibRetro_PCFX","mednafen_pcfx_libretro","LibRetro_PICO","picodrive_libretro","LibRetro_POCKS","mess_libretro","LibRetro_POKE","mess_libretro","LibRetro_PSP","ppsspp_libretro","LibRetro_PSX","mednafen_psx_libretro","LibRetro_PUAE","puae_libretro","LibRetro_PVID","mess_libretro","LibRetro_SACAN","mess_libretro","LibRetro_SAMCP","mess_libretro","LibRetro_SAT","yabause_libretro","LibRetro_SC3K","mess_libretro","LibRetro_SCD","genesis_plus_gx_libretro","LibRetro_SCV","mess_libretro","LibRetro_SCUMM","scummvm_libretro","LibRetro_SG1K","genesis_plus_gx_libretro","LibRetro_SGB","bsnes_balanced_libretro","LibRetro_SGFX","mednafen_supergrafx_libretro","LibRetro_SMS","genesis_plus_gx_libretro","LibRetro_SNES","bsnes_balanced_libretro","LibRetro_SORCR","mess_libretro","LibRetro_SORD","mess_libretro","LibRetro_SPECZX","mess_libretro","LibRetro_SPORTV","mess_libretro","LibRetro_ST","hatari_libretro","LibRetro_STUD2","mess_libretro","LibRetro_STV","mame_libretro","LibRetro_SV328","mess_libretro","LibRetro_SV8K","mess_libretro","LibRetro_SVMU","mess_libretro","LibRetro_SUPRV","mess_libretro","LibRetro_TG16","mednafen_pce_fast_libretro","LibRetro_TGCD","mednafen_pce_fast_libretro","LibRetro_TI99","mess_libretro","LibRetro_TOMY","mess_libretro","LibRetro_TRS80","mess_libretro","LibRetro_VECTX","mess_libretro","LibRetro_VTECH","mess_libretro","LibRetro_WIN3X","dosbox_libretro","LibRetro_WSAN","mednafen_wswan_libretro","LibRetro_WSANC","mednafen_wswan_libretro")
libRetroCore := coreTypes[ident]	; search object for the default core for this ident
If !libRetroCore
	ScriptError("Your Core ID is: " . ident . "`nCould not find a default core to use. Please update the module with a default core.")

settingsFile := modulePath . "\" . moduleName . ".ini"
core := IniReadCheck(settingsFile, systemName, "LibRetro_Core",libRetroCore,,1)
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
configFolder := IniReadCheck(settingsFile, "Settings", "ConfigFolder",emuPath . "\config",,1)
messRomPath := IniReadCheck(settingsFile, "Settings", "MESS_BIOS_Roms_Folder",,,1)
hideConsole := IniReadCheck(settingsFile, "Settings", "HideConsole","true",,1)
superGB := IniReadCheck(settingsFile, systemName . "|" . romName, "SuperGameBoy","false",,1)
enableNetworkPlay := IniReadCheck(settingsFile, "Network|" . romName, "Enable_Network_Play","false",,1)
overlay := IniReadCheck(settingsFile, systemName . "|" . romName, "Overlay",,,1)
videoShader := IniReadCheck(settingsFile, systemName . "|" . romName, "VideoShader",,,1)
aspectRatioIndex := IniReadCheck(settingsFile, systemName . "|" . romName, "AspectRatioIndex",,,1)
customViewportWidth := IniReadCheck(settingsFile, systemName . "|" . romName, "CustomViewportWidth",,,1)
customViewportHeight := IniReadCheck(settingsFile, systemName . "|" . romName, "CustomViewportHeight",,,1)
customViewportX := IniReadCheck(settingsFile, systemName . "|" . romName, "CustomViewportX",,,1)
customViewportY := IniReadCheck(settingsFile, systemName . "|" . romName, "CustomViewportY",,,1)
rotateScreen := IniReadCheck(settingsFile, systemName . "|" . romName, "Rotation",0,,1)
cropOverscan := IniReadCheck(settingsFile, systemName . "|" . romName, "CropOverscan",,,1)
threadedVideo := IniReadCheck(settingsFile, systemName . "|" . romName, "ThreadedVideo",,,1)
vSync := IniReadCheck(settingsFile, systemName . "|" . romName, "VSync",,,1)
integerScale := IniReadCheck(settingsFile, systemName . "|" . romName, "IntegerScale",,,1)
configFolder := GetFullName(configFolder)
messRomPath := GetFullName(messRomPath)
overlay := GetFullName(overlay)
videoShader := GetFullName(videoShader)

retroArchSystem := systemName

If (ident = "LibRetro_SGB" || superGB = "true")	; if system or rom is set to use Super Game Boy
{	superGB = true	; setting this just in case it's false and the system is Nintendo Super Game Boy
	sgbRomPath := CheckFile(emuPath . "\system\Super Game Boy (World).sfc","Could not find the rom required for Super Game Boy support. Make sure the rom ""Super Game Boy (World).sfc"" is located in: " . emuPath . "\system")
	CheckFile(emuPath . "\system\sgb.boot.rom","Could not find the bios required for Super Game Boy support. Make sure the bios ""sgb.boot.rom"" is located in: " . emuPath . "\system")
	ident := "LibRetro_SGB"	; switching to Super Game Boy mode
	retroArchSystem := "Nintendo Super Game Boy"
}

; Find the dll for this system
libDll := CheckFile(emuPath . "\cores\" . core . ".dll", "Your " . ident . " dll is set to " . core . " but could not locate this file:`n" . emuPath . "\cores\" . core . ".dll")

; Find the cfg file to use
If !FileExist(configFolder)
	ScriptError("You need to make sure ""ConfigFolder"" is pointing to your RetroArch config folder. By default it is looking here: """ . configFolder . """")
globalRetroCfg := emuPath . "\retroarch.cfg"
systemRetroCfg := configFolder . "\" . retroArchSystem . ".cfg"
coreRetroCfg := configFolder . "\" . core . ".dll.cfg"
Log("Module - Global cfg should be: " . globalRetroCfg,4)
Log("Module - System cfg should be: " . systemRetroCfg,4)
Log("Module - Core cfg should be: " . coreRetroCfg,4)
foundCfg :=
If FileExist(systemRetroCfg) {	; check for system cfg first
	retroCFGFile := systemRetroCfg
	foundCfg := 1
	Log("Module - Found a System cfg!",4)
} Else If FileExist(coreRetroCfg) {	; 2nd option is a core config
	retroCFGFile := coreRetroCfg
	foundCfg := 1
	Log("Module - Found a Core cfg!",4)
} Else If FileExist(globalRetroCfg) {	; 3rd is global cfg
	retroCFGFile := globalRetroCfg
	foundCfg := 1
	Log("Module - Found a Global cfg!",4)
}
If !foundCfg
	Log("Module - Could not find a cfg file to update settings. RetroArch will make one for you.",2)
Else
	Log("Module - " . MEmu . " is using " . retroCFGFile . " as its config file.")

If foundCfg {
	retroCFG := LoadProperties(retroCFGFile)	; load the config into memory
	raCfgHasChanges :=
	WriteRetroProperty("input_overlay", overlay)
	WriteRetroProperty("video_shader", videoShader)
	WriteRetroProperty("aspect_ratio_index", aspectRatioIndex)
	WriteRetroProperty("custom_viewport_width", customViewportWidth)
	WriteRetroProperty("custom_viewport_height", customViewportHeight)
	WriteRetroProperty("custom_viewport_x", customViewportX)
	WriteRetroProperty("custom_viewport_y", customViewportY)
	WriteRetroProperty("video_rotation", rotateScreen)
	WriteRetroProperty("video_crop_overscan", cropOverscan)
	WriteRetroProperty("video_threaded", threadedVideo)
	WriteRetroProperty("video_vsync", vSync)
	WriteRetroProperty("video_scale_integer", integerScale)

	If InStr(ident, "LibRetro_PSX") {
		Loop, 8	; loop 8 times for 8 controllers
		{	p%A_Index%ControllerType := IniReadCheck(sysSettingsFile, systemName . "|" . romName, "P" . A_Index . "_Controller_Type", 517,,1)
			WriteRetroProperty("input_libretro_device_p" . A_Index, p%A_Index%ControllerType)
		}
	}

	If raCfgHasChanges {
		Log("Module - Saving changed settings to: """ . retroCFGFile . """")
		SaveProperties(retroCFGFile, retroCFG)
	}
}

If RegExMatch(ident, "LibRetro_NFDS|LibRetro_SCD|LibRetro_TGCD|LibRetro_PCECD|LibRetro_PCFX") {		; these systems require the retroarch settings to be read
	retroSysDir := ReadProperty(retroCFG,"system_directory")	; read value
	retroSysDir := ConvertRetroCFGKey(retroSysDir)	; remove dbl quotes
	StringLeft, retroSysDirLeft, retroSysDir, 2
	If (retroSysDirLeft = ":\") {	; if retroarch is set to use a default folder
		StringTrimLeft, retroSysDir, retroSysDir, 1
		Log("Module - RetroArch is using a relative system path: """ . retroSysDir . """")
		retroSysDir := emuPath . retroSysDir
	}
	If !retroSysDir
		ScriptError("RetroArch requires you to set your system_directory and place bios rom(s) in there for """ . retroArchSystem . """ to function. Please do this first by running ""retroarch-phoenix.exe"" manually.")
	StringRight, checkForSlash, retroSysDir, 1
	If (checkForSlash = "\")	; check if a backslash is the last character. If it is, remove it, as this is non-standard method to define folders
		StringTrimRight, retroSysDir, retroSysDir, 1
}

If (RegExMatch(ident, "LibRetro_N64|LibRetro_NES|LibRetro_LYNX|LibRetro_PSX") || RegExMatch(ident, "LibRetro_NES") && (InStr(core, "nestopia_libretro"))) {	; these systems will use an ini to store game specific settings
	sysSettingsFile := CheckSysFile(modulePath . "\" . systemName . ".ini")	; create the ini if it does not exist
	coreOptionsCFGFile := CheckFile(emuPath . "\retroarch-core-options.cfg", "Could not find retroarch-core-options.cfg in retroarch directory: """ . emuPath . """")
	coreOptionsCFG := LoadProperties(coreOptionsCFGFile)
	If InStr(ident, "LibRetro_N64") {	; Nintendo 64
		mupenGfx := IniReadCheck(sysSettingsFile, systemName . "|" . romName, "Mupen_Gfx_Plugin", "auto",,1)
		mupenRsp := IniReadCheck(sysSettingsFile, systemName . "|" . romName, "Mupen_RSP_Plugin", "auto",,1)
		mupenCpu := IniReadCheck(sysSettingsFile, systemName . "|" . romName, "Mupen_CPU_Core", "dynamic_recompiler",,1)
		mupenPak1 := IniReadCheck(sysSettingsFile, systemName . "|" . romName, "Mupen_Pak_1", "memory",,1)
		mupenPak2 := IniReadCheck(sysSettingsFile, systemName . "|" . romName, "Mupen_Pak_2", "memory",,1)
		mupenPak3 := IniReadCheck(sysSettingsFile, systemName . "|" . romName, "Mupen_Pak_3", "memory",,1)
		mupenPak4 := IniReadCheck(sysSettingsFile, systemName . "|" . romName, "Mupen_Pak_4", "memory",,1)
		mupenGfxAccur := IniReadCheck(sysSettingsFile, systemName . "|" . romName, "Mupen_Gfx_Accuracy", "high",,1)
		mupenExpMem := IniReadCheck(sysSettingsFile, systemName . "|" . romName, "Mupen_Disable_Exp_Memory", "no",,1)
		mupenTexturFilt := IniReadCheck(sysSettingsFile, systemName . "|" . romName, "Mupen_Texture_Filtering", "nearest",,1)
		mupenViRefresh := IniReadCheck(sysSettingsFile, systemName . "|" . romName, "Mupen_VI_Refresh", "2200",,1)
		mupenFramerate := IniReadCheck(sysSettingsFile, systemName . "|" . romName, "Mupen_Framerate", "fullspeed",,1)
		mupenResolution := IniReadCheck(sysSettingsFile, systemName . "|" . romName, "Mupen_Resolution", "640x480",,1)
		mupenPolyOffstFctr := IniReadCheck(sysSettingsFile, systemName . "|" . romName, "Mupen_Polygon_Offset_Factor", "-3.0",,1)
		mupenPolyOffstUnts := IniReadCheck(sysSettingsFile, systemName . "|" . romName, "Mupen_Polygon_Offset_Units", "-3.0",,1)
		mupenViOverlay := IniReadCheck(sysSettingsFile, systemName . "|" . romName, "Mupen_VI_Overlay", "disabled",,1)
		mupenAnalogDzone := IniReadCheck(sysSettingsFile, systemName . "|" . romName, "Mupen_Analog_Deadzone", "15",,1)

		WriteProperty(coreOptionsCFG, "mupen64-gfxplugin", mupenGfx, 1)
		WriteProperty(coreOptionsCFG, "mupen64-rspplugin", mupenRsp, 1)
		WriteProperty(coreOptionsCFG, "mupen64-cpucore", mupenCpu, 1)
		WriteProperty(coreOptionsCFG, "mupen64-pak1", mupenPak1, 1)
		WriteProperty(coreOptionsCFG, "mupen64-pak2", mupenPak2, 1)
		WriteProperty(coreOptionsCFG, "mupen64-pak3", mupenPak3, 1)
		WriteProperty(coreOptionsCFG, "mupen64-pak4", mupenPak4, 1)
		WriteProperty(coreOptionsCFG, "mupen64-gfxplugin-accuracy", mupenGfxAccur, 1)
		WriteProperty(coreOptionsCFG, "mupen64-disableexpmem", mupenExpMem, 1)
		WriteProperty(coreOptionsCFG, "mupen64-filtering", mupenTexturFilt, 1)
		WriteProperty(coreOptionsCFG, "mupen64-virefresh", mupenViRefresh, 1)
		WriteProperty(coreOptionsCFG, "mupen64-framerate", mupenFramerate, 1)
		WriteProperty(coreOptionsCFG, "mupen64-screensize", mupenResolution, 1)
		WriteProperty(coreOptionsCFG, "mupen64-polyoffset-factor", mupenPolyOffstFctr, 1)
		WriteProperty(coreOptionsCFG, "mupen64-polyoffset-units", mupenPolyOffstUnts, 1)
		WriteProperty(coreOptionsCFG, "mupen64-angrylion-vioverlay", mupenViOverlay, 1)
		WriteProperty(coreOptionsCFG, "mupen64-astick-deadzone", mupenAnalogDzone, 1)
	} Else If InStr(ident, "LibRetro_NES") {		; these systems will use an ini to store game specific settings
		If InStr(core, "nestopia_libretro") {	; Nestopia
			nestopiaBlargg := IniReadCheck(sysSettingsFile, "Nestopia" . "|" . romName, "Nestopia_Blargg_NTSC_Filter", "disabled",,1)
			nestopiaPalette := IniReadCheck(sysSettingsFile, "Nestopia" . "|" . romName, "Nestopia_Palette", "canonical",,1)
			nestopiaNoSprteLimit := IniReadCheck(sysSettingsFile, "Nestopia" . "|" . romName, "Nestopia_Remove_Sprites_Limit", "disabled",,1)
			
			WriteProperty(coreOptionsCFG, "nestopia_blargg_ntsc_filter", nestopiaBlargg, 1)
			WriteProperty(coreOptionsCFG, "nestopia_palette", nestopiaPalette, 1)
			WriteProperty(coreOptionsCFG, "nestopia_nospritelimit", nestopiaNoSprteLimit, 1)
		}
	} Else If InStr(ident, "LibRetro_LYNX") {	; Atari Lynx
		If InStr(core, "handy_libretro") {   ; Handy
			handyRotate := IniReadCheck(sysSettingsFile, systemName . "|" . romName, "Handy_Rotation", "None",,1)
			WriteProperty(coreOptionsCFG, "handy_rot", handyRotate, 1)
		}
	} Else If InStr(ident, "LibRetro_PSX") {	; Sony PlayStation
		psxCdImageCache := IniReadCheck(sysSettingsFile, systemName . "|" . romName, "PSX_CD_Image_Cache", """enabled""",,1)
		psxMemcardHandling := IniReadCheck(sysSettingsFile, systemName . "|" . romName, "PSX_Memcard_Handling", """libretro""",,1)
		psxDualshockAnalogToggle := IniReadCheck(sysSettingsFile, systemName . "|" . romName, "PSX_Dualshock_Analog_Toggle", """enabled""",,1)
		
		WriteProperty(coreOptionsCFG, "beetle_psx_cdimagecache", psxCdImageCache, 1)
		WriteProperty(coreOptionsCFG, "beetle_psx_use_mednafen_memcard0_method", psxMemcardHandling, 1)
		WriteProperty(coreOptionsCFG, "beetle_psx_analog_toggle", psxDualshockAnalogToggle, 1)
	}
	SaveProperties(coreOptionsCFGFile, coreOptionsCFG)	
}

hideEmuObj := Object("ahk_class ConsoleWindowClass",0,"RetroArch ahk_class RetroArch",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

; MESS core options
messIdent :=
messParam1 :=
messParam2 :=
messParam3 :=
If InStr(core, "mess") {	; if a mess core is used
	Log("Module - Retroarch MESS mode enabled")
	; the messType object links the system name to the name mess recognizes
	messType := Object("Amstrad CPC","cpc464","Amstrad GX4000","gx4000","APF Imagination Machine","apfimag","Apple IIGS","apple2gs","Atari 8-bit","a800","Atari 2600","a2600","Atari 5200","a5200","Atari 7800","a7800","Atari Jaguar","jaguar","Atari Lynx","lynx","Bally Astrocade","astrocde","Bandai Super Vision 8000","sv8000","Bandai WonderSwan","wswan","Bandai WonderSwan Color","wscolor","Casio PV-1000","pv1000","Casio PV-2000","pv2000","Coleco ADAM","adam","ColecoVision","coleco","Creatronic Mega Duck","megaduck","Dragon 64","dragon64","Emerson Arcadia 2001","arcadia","Entex Adventure Vision","advision","Epoch Game Pocket Computer","gamepock","Epoch Super Cassette Vision","scv","Exidy Sorcerer","sorcerer","Fairchild Channel F","channelf","Funtech Super Acan","supracan","GCE Vectrex","vectrex","Hartung Game Master","gmaster","GamePark 32","gp32","Interton VC 4000","vc4000","JungleTac Sport Vii","vii","Magnavox Odyssey 2","odyssey2","Matra & Hachette Alice","alice32","Mattel Aquarius","aquarius","Mattel Intellivision","intv","NEC PC Engine","pce","NEC PC Engine-CD","pce","NEC SuperGrafx","sgx","NEC TurboGrafx-16","tg16","NEC TurboGrafx-CD","tg16","Nintendo 64","n64","Nintendo Entertainment System","nes","Nintendo Famicom Disk System","famicom","Nintendo Game Boy","gameboy","Nintendo Game Boy Advance","gba","Nintendo Game Boy Color","gbcolor","Nintendo Game Boy Japan","gameboy","Nintendo Pokemon Mini","pokemini","Nintendo Virtual Boy","vboy","Elektronska Industrija Pecom 64","pecom64","Philips CD-i","cdimono1","Philips Videopac","videopac","RCA Studio II","studio2","Sega 32X","32x","Sega SC-3000","sc3000","Sega CD","segacd","Sega Game Gear","gamegear","Sega Genesis","genesis","Sega Master System","sms","Sega Mega Drive","megadriv","Sega VMU","svmu","Sinclair ZX Spectrum","spectrum","SNK Neo Geo AES","aes","SNK Neo Geo CD","neocdz","SNK Neo Geo Pocket","ngp","SNK Neo Geo Pocket Color","ngpc","Sony PlayStation","psx","Sony PocketStation","pockstat","Sord M5","m5","Spectravideo","svi328n","Super Nintendo Entertainment System","snes","Tandy TRS-80 Color Computer","coco3","Texas Instruments TI 99-4A","ti99_4a","Tiger Game.com","gamecom","Thomson MO5","mo5","Tomy Tutor","tutor","VTech CreatiVision","crvision","Watara Supervision","svision")
	messIdent := messType[systemName]	; search object for the systemName identifier Retroarch uses for its cores
	If !messIdent
		ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for the MESS LibRetro core")
	Else
		Log("Module - MESS mode using a known ident: " . messIdent)

	If !messRomPath
		ScriptError("Please set the RetroArch module setting ""MESS_BIOS_Roms_Folder"" to the folder that contains your MESS BIOS roms to use MESS with RetroArch.")
	
	messParam1 :=
	messParam2 := " -rompath \" . """" . messRomPath . "\" . """"

	; Build a key/value object containing the different messParam3 choices
	messP3 := Object("alice32","cass1","gp32","memc","cpc464","cass","spectrum","cass","dragon64","cass","cdimono1","cdrom","neocd","cdrom","neocdz","cdrom","svi328n","cass","pecom64","cass","svmu","quik")
	messParam3 := messP3[messIdent]	; search object for the messIdent pair
	messParam3 := " -" . (If messParam3 ? messParam3 : "cart") . " \" . """" . romPath . "\" . romName . romExtension . "\" . """"
	
	fullRomPath := messParam1 . messParam2 . messParam3
} Else If (superGB = "true") {
	Log("Module - Retroarch Super Game Boy mode enabled")
	fullRomPath := " """ . sgbRomPath . """ --subsystem sgb """ . romPath . "\" . romName . romExtension . """"
} Else {
	Log("Module - Retroarch standard mode enabled")
	fullRomPath := " """ . romPath . "\" . romName . romExtension . """"
}

If ident = LibRetro_NFDS	; Nintendo Famicom Disk System
{	IfNotExist, %retroSysDir%\disksys.rom
		ScriptError("RetroArch requires ""disksys.rom"" for " . retroArchSystem . " but could not find it in your system_directory: """ . retroSysDir . """")
} Else If ident = LibRetro_SCD	; Sega CD
{	If romExtension Not In .bin,.cue,.iso
		ScriptError("RetroArch only supports Sega CD games in bin|cue|iso format. It does not support:`n" . romExtension)
	IfNotExist, %retroSysDir%\bios_CD_E.bin
		ScriptError("RetroArch requires ""bios_CD_E.bin"" for " . retroArchSystem . " but could not find it in your system_directory: """ . retroSysDir . """")
	IfNotExist, %retroSysDir%\bios_CD_U.bin
		ScriptError("RetroArch requires ""bios_CD_U.bin"" for " . retroArchSystem . " but could not find it in your system_directory: """ . retroSysDir . """")
	IfNotExist, %retroSysDir%\bios_CD_J.bin
		ScriptError("RetroArch requires ""bios_CD_J.bin"" for " . retroArchSystem . " but could not find it in your system_directory: """ . retroSysDir . """")
} Else If ident in LibRetro_PCECD,LibRetro_TGCD	; NEC PC Engine-CD and NEC TurboGrafx-CD
{	If romExtension Not In .ccd,.cue
		ScriptError("RetroArch only supports " . retroArchSystem . " games in ccd or cue format. It does not support:`n" . romExtension)
	IfNotExist, %retroSysDir%\syscard3.pce
		ScriptError("RetroArch requires ""syscard3.pce"" for " . retroArchSystem . " but could not find it in your system_directory: """ . retroSysDir . """")
} Else If ident = LibRetro_PCFX
{	If romExtension Not In .ccd,.cue
		ScriptError("RetroArch only supports " . retroArchSystem . " games in ccd or cue format. It does not support:`n" . romExtension)
	IfNotExist, %retroSysDir%\pcfxbios.bin
		ScriptError("RetroArch requires ""pcfxbios.bin"" for " . retroArchSystem . " but could not find it in your system_directory: """ . retroSysDir . """")
}


networkSession :=
If (enableNetworkPlay = "true") {
	Log("Module - Network Multi-Player is an available option for " . dbName,4)

	netplayNickname := IniReadCheck(settingsFile, "Network", "NetPlay_Nickname","Player",,1)
	getWANIP := IniReadCheck(settingsFile, "Network", "Get_WAN_IP","false",,1)

	If (getWANIP = "true")
		myPublicIP := GetPublicIP()

	Log("Module - CAREFUL WHEN POSTING THIS LOG PUBLICLY AS IT CONTAINS YOUR IP ON THE NEXT LINE",2)
	defaultServerIP := IniReadCheck(settingsFile, "Network", "Default_Server_IP", myPublicIP,,1)
	defaultServerPort := IniReadCheck(settingsFile, "Network", "Default_Server_Port",,,1)
	lastIP := IniReadCheck(settingsFile, "Network", "Last_IP", defaultServerIP,,1)	; does not need to be on the ISD
	lastPort := IniReadCheck(settingsFile, "Network", "Last_Port", defaultServerPort,,1)	; does not need to be on the ISD

	mpMenuStatus := MultiPlayerMenu(lastIP,lastPort,networkType,,0)
	If (mpMenuStatus = -1) {	; if user exited menu early
		Log("Module - Cancelled MultiPlayer Menu. Exiting module.",2)
		ExitModule()
	}
	If networkSession {
		Log("Module - Using a Network for " . dbName,4)
		IniWrite, %networkPort%, %settingsFile%, Network, Last_Port
		; msgbox lastIP: %lastIP%`nlastPort: %lastPort%`nnetworkIP: %networkIP%`nnetworkPort: %networkPort%
		If (networkType = "client") {
			IniWrite, %networkIP%, %settingsFile%, Network, Last_IP	; Save last used IP and Port for quicker launching next time
			netCommand := " -C " . networkIP . " --port " . networkPort . " --nick """ . netplayNickname . """"	; -C = connect as client
		} Else {	; server
			netCommand := " -H --port " . networkPort . " --nick """ . netplayNickname . """"	; -H = host as server
		}
		Log("Module - CAREFUL WHEN POSTING THIS LOG PUBLICLY AS IT CONTAINS YOUR IP ON THE NEXT LINE",2)
		Log("Module - Starting a network session using the IP """ . networkIP . """ and PORT """ . networkPort . """",4)
	} Else
		Log("Module - User chose Single Player mode for this session",4)
}

BezelStart()

fullscreen := If fullscreen = "true" ? " -f" : ""
srmPath := emuPath . "\srm\" . retroArchSystem	; path for this system's srm files
saveStatePath := emuPath . "\save\" . retroArchSystem	; path for this system's save state files
retroCFGFile := If foundCfg ? " -c """ . retroCFGFile . """" : ""

IfNotExist, %srmPath%
	FileCreateDir, %srmPath% ; creating srm dir if it doesn't exist
IfNotExist, %saveStatePath%
	FileCreateDir, %saveStatePath% ; creating save dir if it doesn't exist

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

If InStr(core, "mess") {	; if a mess core is used
	Run(executable . " """ . (messIdent ? messIdent : "") . fullRomPath . """ " . fullscreen . retroCFGFile . " -L """ . libDll . """ -s """ . srmPath . "\" . romName . ".srm"" -S """ . saveStatePath . "\" . romName . ".state""" . netCommand, emuPath, "Hide")
} Else If (ident = "LibRetro_SGB" || If superGB = "true") { ; For some reason, the order of our command line matters in this particular case.
	Run(executable . " " . fullscreen . retroCFGFile . " -L """ . libDll . """ -s """ . srmPath . "\" . romName . ".srm"" -S """ . saveStatePath . "\" . romName . ".state""" . fullRomPath . netCommand, emuPath, "Hide")
} Else {
	Run(executable . " " . fullRomPath . fullscreen . retroCFGFile . " -L """ . libDll . """ -s """ . srmPath . "\" . romName . ".srm"" -S """ . saveStatePath . "\" . romName . ".state""" . netCommand, emuPath, "Hide")
}

mpMenuStatus :=
If networkSession {
	canceledServerWait := false
	multiplayerMenuExit := false
	SetTimer, NetworkConnectedCheck, 500

	If (networkType = "server") {
		Log("Module - Waiting for a client to connect to your server")
		mpMenuStatus := MultiPlayerMenu(,,,,,,,,"You are the server. Please wait for your client to connect.")
	} Else {	; client
		Log("Module - Trying to contact the server to establish a connection.")
		mpMenuStatus := MultiPlayerMenu(,,,,,,,,"Attempting to connect to the server...")
	}

	If (mpMenuStatus = -1) {	; if user exited menu early before a client connected
		Log("Module - Cancelled waiting for the " . If (networkType = "server") ? "client to connect" : "server to respond" . ". Exiting module.",2)
		If Process("Exist", executable)
			Process("Close", executable)	; must close process as the exe is waiting for a client to connect and no window was drawn yet
		ExitModule()
	} Else {	; blank response from MultiPlayerMenu, exited properly
		Log("Module - " . If (networkType = "server") ? "Client has connected" : "Connected to the server")
		WinWait("RetroArch ahk_class RetroArch")
		WinWaitActive("RetroArch ahk_class RetroArch")
	}
	SetTimer, NetworkConnectedCheck, Off
} Else {	; single player
	WinWait("RetroArch ahk_class RetroArch")
	WinWaitActive("RetroArch ahk_class RetroArch")
}

If hideConsole = true
	WinSet, Transparent, On, ahk_class ConsoleWindowClass	; makes the console window transparent so you don't see it on exit

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


; Writes new properties into the retroCFG if defined by user
WriteRetroProperty(key,value="") {
	If (value != "") {
		Global retroCFG,raCfgHasChanges
		WriteProperty(retroCFG, key, value,1,1)
		raCfgHasChanges := 1
	}
}

; Used to convert between RetroArch keys and usable data
ConvertRetroCFGKey(txt,direction="read"){
	Global emuPath
	If direction = read
	{	StringTrimLeft,newtxt,txt,1	; removes the " from the left of the txt
		StringTrimRight,newtxt,newtxt,1	; removes the " from the right of the txt
		If InStr(newtxt,":") {	; if the path contains a ":" then it is a relative path
			Log("ConvertRetroCFGKey - " . newtxt . " is a relative path",4)
			StringTrimLeft,newtxt,newtxt,1	; removes the : from the left of the txt
			newtxt := AbsoluteFromRelative(emuPath, "." . newtxt)	; convert relative to absolute
		}
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

; This will simply create a new blank ini if one does not exist
CheckSysFile(file){
	IfNotExist, %file%
		FileAppend,, %file%
	Return file
}

NetworkConnectedCheck:
	If clientConnected
		multiplayerMenuExit := true
	Else If WinExist("RetroArch ahk_class RetroArch") {
		Log("Module - RetroArch session started, closing the MultiPlayer menu",4)
		multiplayerMenuExit := true
	}
Return

CloseProcess:
	FadeOutStart()
	WinClose("RetroArch ahk_class RetroArch")
Return
