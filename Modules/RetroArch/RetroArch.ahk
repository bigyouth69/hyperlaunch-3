MEmu = RetroArch
MEmuV =  v12-25-2014 Nightly
MURL = http://themaister.net/retroarch.html
MAuthor = djvj,zerojay
MVersion = 2.2.0
MCRC = 9C0576F0
iCRC = B33E9394
MID = 635038268922229162
MSystem = "Amstrad CPC","Amstrad GX4000","APF Imagination Machine","Atari 2600","Atari 5200","Atari 7800","Atari Jaguar","Atari Lynx","Atari ST","Bally Astrocade","Bandai Wonderswan","Bandai Wonderswan Color","Casio PV-1000","Casio PV-2000","ColecoVision","Commodore Amiga","Creatronic Mega Duck","Emerson Arcadia 2001","Entex Adventure Vision","Epoch Game Pocket Computer","Epoch Super Cassette Vision","Exidy Sorcerer","Fairchild Channel F","Final Burn Alpha","Funtech Super Acan","GCE Vectrex","Hartung Game Master","JungleTac Sport Vii","MAME","Magnavox Odyssey 2","Microsoft MSX","Microsoft MSX2","Matra & Hachette Alice","Mattel Aquarius","NEC PC Engine","NEC PC Engine-CD","NEC PC-FX","NEC TurboGrafx-16","NEC SuperGrafx","NEC TurboGrafx-CD","Nintendo 64","Nintendo Arcade Systems","Nintendo DS","Nintendo Entertainment System","Nintendo Famicom","Nintendo Famicom Disk System","Nintendo Game Boy","Nintendo Game Boy Color","Nintendo Game Boy Japan","Nintendo Game Boy Advance","Nintendo Super Game Boy","Nintendo Pokemon Mini","Nintendo Virtual Boy","Nintendo Super Famicom","Nintendo Super Famicom Satellaview","Panasonic 3DO","Philips CD-i","Philips Videopac","Sega 32X","Sega SC-3000","Sega SG-1000","Sega CD","Sega Game Gear","Sega Genesis","Sega Master System","Sega Mega Drive","Sega Pico","Sega VMU","Sinclair ZX Spectrum","Sony PlayStation","Sony PocketStation","Sony PSP","Sord M5","Sega Saturn","Sega SG-1000","SNK Neo Geo","SNK Neo Geo MVS","SNK Neo Geo AES","SNK Neo Geo Pocket","SNK Neo Geo CD","SNK Neo Geo Pocket Color","Super Nintendo Entertainment System","Tandy TRS-80 Color Computer 3","Texas Instruments TI 99-4A","Tomy Tutor","VTech CreatiVision","Watara Supervision"
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
; Whatever cores you decide to use, make sure they are extracted anywhere in your Emu_Path folder (place them in a LibRetros subfolder if you like). The module will find and load the core you choose for each system.
; You can find supported cores that Retroarch supports simply by downloading them from the "retroarch-phoenix.exe" or by visiting here: https://github.com/libretro/libretro.github.com/wiki/Supported-cores
; Some good discussion on cores and filters: http://forum.themaister.net/viewtopic.php?id=270
; The module's LibRetro settings in HLHQ need to match the name of that core for each system you use this emu. Read the tooltips to see the default one used when they are not customized by you.
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
mType := Object("Amstrad CPC","LibRetro_CPC","Amstrad GX4000","LibRetro_GX4K","APF Imagination Machine","LibRetro_APF","Atari 2600","LibRetro_2600","Atari 5200","LibRetro_5200","Atari 7800","LibRetro_7800","Atari Jaguar","LibRetro_JAG","Atari Lynx","LibRetro_LYNX","Atari ST","LibRetro_ST","Bally Astrocade","LibRetro_BAST","Bandai Wonderswan","LibRetro_WSAN","Bandai Wonderswan Color","LibRetro_WSANC","Casio PV-1000","LibRetro_CAS1K","Casio PV-2000","LibRetro_CAS2K","ColecoVision","LibRetro_COLEC","Commodore Amiga","LibRetro_PUAE","Creatronic Mega Duck","LibRetro_DUCK","Emerson Arcadia 2001","LibRetro_A2001","Entex Adventure Vision","LibRetro_AVISION","Epoch Game Pocket Computer","LibRetro_GPCKET","Epoch Super Cassette Vision","LibRetro_SCV","Exidy Sorcerer","LibRetro_SORCR","Fairchild Channel F","LibRetro_CHANF","Final Burn Alpha","LibRetro_FBA","Funtech Super Acan","LibRetro_SACAN","GamePark 32","LibRetro_GP32","GCE Vectrex","LibRetro_VECTX","Hartung Game Master","LibRetro_GMASTR","JungleTac Sport Vii","LibRetro_SPORTV","MAME","LibRetro_MAME","Magnavox Odyssey 2","LibRetro_ODYS2","Mattel Aquarius","LibRetro_AQUA","Mattel Intellivision","LibRetro_INTV","MGT Sam Coupe","LibRetro_SAMCP","Microsoft MSX","LibRetro_MSX","Microsoft MSX2","LibRetro_MSX2","Matra & Hachette Alice","LibRetro_ALICE","NEC PC Engine","LibRetro_PCE","NEC PC Engine-CD","LibRetro_PCECD","NEC PC-FX","LibRetro_PCFX","NEC SuperGrafx","LibRetro_SGFX","NEC TurboGrafx-16","LibRetro_TG16","NEC TurboGrafx-CD","LibRetro_TGCD","Nintendo 64","LibRetro_N64","Nintendo Arcade Systems","LibRetro_NINARC","Nintendo DS","LibRetro_DS","Nintendo Entertainment System","LibRetro_NES","Nintendo Famicom","LibRetro_NFAM","Nintendo Famicom Disk System","LibRetro_NFDS","Nintendo Game Boy","LibRetro_GB","Nintendo Game Boy Color","LibRetro_GBC","Nintendo Game Boy Japan","LibRetro_GBJ","Nintendo Game Boy Advance","LibRetro_GBA","Nintendo Pokemon Mini","LibRetro_POKE","Nintendo Super Famicom","LibRetro_NSF","Nintendo Super Famicom Satellaview","LibRetro_NSFS","Nintendo Super Game Boy","LibRetro_SGB","Nintendo Virtual Boy","LibRetro_NVB","Panasonic 3DO","LibRetro_3DO","Philips CD-i","LibRetro_CDI","Philips Videopac","LibRetro_PVID","RCA Studio II","LibRetro_STUD2","SCUMMVM","LibRetro_SCUMM","Sega 32X","LibRetro_32X","Sega CD","LibRetro_SCD","Sega Game Gear","LibRetro_GG","Sega Genesis","LibRetro_GEN","Sega Mega Drive","LibRetro_GEN","Sega Master System","LibRetro_SMS","Sega Pico","LibRetro_PICO","Sega VMU","LibRetro_SVMU","Sony PlayStation","LibRetro_PSX","Sony PocketStation","LibRetro_POCKS","Sony PSP","LibRetro_PSP","Sega Saturn","LibRetro_SAT","Sega SG-1000","LibRetro_SG1K","Sega SC-3000","LibRetro_SC3K","SNK Neo Geo","LibRetro_NEO","SNK Neo Geo AES","LibRetro_NEOAES","SNK Neo Geo Pocket","LibRetro_NGP","SNK Neo Geo Pocket Color","LibRetro_NGPC","SNK Neo Geo CD","LibRetro_NEOCD","Sord M5","LibRetro_SORD","Super Nintendo Entertainment System","LibRetro_SNES","Sinclair ZX Spectrum","LibRetro_SPECZX","Tandy TRS-80 Color Computer 3","LibRetro_TRS80","Texas Instruments TI 99-4A","LibRetro_TI99","Tomy Tutor","LibRetro_TOMY","VTech CreatiVision","LibRetro_VTECH","Watara Supervision","LibRetro_SUPRV")
ident := mType[systemName]	; search object for the systemName identifier Retroarch uses for its cores
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this " . MEmu . " module: " . moduleName)

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
hideConsole := IniReadCheck(settingsFile, "Settings", "HideConsole","true",,1)
; SystemConfigs := IniReadCheck(settingsFile, "Settings", "SystemConfigs","true",,1)			; If true, 
messRomPath := IniReadCheck(settingsFile, "Settings", "MESS_BIOS_Roms_Folder",,,1)
libRetroFolder := IniReadCheck(settingsFile, "Settings", "LibRetroFolder", emuPath,,1)
LibRetro_2600 := IniReadCheck(settingsFile, "Settings", "LibRetro_2600","stella_libretro",,1)
LibRetro_5200 := IniReadCheck(settingsFile, "Settings", "LibRetro_5200","mess_libretro",,1)
LibRetro_7800 := IniReadCheck(settingsFile, "Settings", "LibRetro_7800","prosystem_libretro",,1)
LibRetro_32X := IniReadCheck(settingsFile, "Settings", "LibRetro_32X","picodrive_libretro",,1)	; picodrive is the 32x core, not genesis plus
LibRetro_3DO := IniReadCheck(settingsFile, "Settings", "LibRetro_3DO","4do_libretro",,1)
LibRetro_A2001 := IniReadCheck(settingsFile, "Settings", "LibRetro_A2001","mess_libretro",,1)
LibRetro_ALICE := IniReadCheck(settingsFile, "Settings", "LibRetro_ALICE","mess_libretro",,1)
LibRetro_APF := IniReadCheck(settingsFile, "Settings", "LibRetro_APF","mess_libretro",,1)
LibRetro_AQUA := IniReadCheck(settingsFile, "Settings", "LibRetro_AQUA","mess_libretro",,1)
LibRetro_AVISION := IniReadCheck(settingsFile, "Settings", "LibRetro_AVISION","mess_libretro",,1)
LibRetro_BAST := IniReadCheck(settingsFile, "Settings", "LibRetro_BAST","mess_libretro",,1)
LibRetro_CAS1K := IniReadCheck(settingsFile, "Settings", "LibRetro_CAS1K","mess_libretro",,1)
LibRetro_CAS2K := IniReadCheck(settingsFile, "Settings", "LibRetro_CAS2K","mess_libretro",,1)
LibRetro_CDI := IniReadCheck(settingsFile, "Settings", "LibRetro_CDI","mess_libretro",,1)
LibRetro_CHANF := IniReadCheck(settingsFile, "Settings", "LibRetro_CHANF","mess_libretro",,1)
LibRetro_COLEC := IniReadCheck(settingsFile, "Settings", "LibRetro_COLEC","mess_libretro",,1)
LibRetro_CPC := IniReadCheck(settingsFile, "Settings", "LibRetro_CPC","mess_libretro",,1)
LibRetro_DS := IniReadCheck(settingsFile, "Settings", "LibRetro_DS","desmume_libretro",,1)
LibRetro_DUCK := IniReadCheck(settingsFile, "Settings", "LibRetro_DUCK","mess_libretro",,1)
LibRetro_FBA := IniReadCheck(settingsFile, "Settings", "LibRetro_FBA","fb_alpha_libretro",,1)
LibRetro_GB := IniReadCheck(settingsFile, "Settings", "LibRetro_GB","gambatte_libretro",,1)
LibRetro_GBC := IniReadCheck(settingsFile, "Settings", "LibRetro_GBC","gambatte_libretro",,1)
LibRetro_GBA := IniReadCheck(settingsFile, "Settings", "LibRetro_GBA","vba_next_libretro",,1)
LibRetro_GBJ := IniReadCheck(settingsFile, "Settings", "LibRetro_GBJ","gambatte_libretro",,1)
LibRetro_GEN := IniReadCheck(settingsFile, "Settings", "LibRetro_GEN","genesis_plus_gx_libretro",,1)
LibRetro_GG := IniReadCheck(settingsFile, "Settings", "LibRetro_GG","genesis_plus_gx_libretro",,1)
LibRetro_GMASTR := IniReadCheck(settingsFile, "Settings", "LibRetro_GMASTR","mess_libretro",,1)
LibRetro_GP32 := IniReadCheck(settingsFile, "Settings", "LibRetro_GP32","mess_libretro",,1)
LibRetro_GPCKET := IniReadCheck(settingsFile, "Settings", "LibRetro_GPCKET","mess_libretro",,1)
LibRetro_GX4K := IniReadCheck(settingsFile, "Settings", "LibRetro_GX4K","mess_libretro",,1)
LibRetro_INTV := IniReadCheck(settingsFile, "Settings", "LibRetro_INTV","mess_libretro",,1)
LibRetro_JAG := IniReadCheck(settingsFile, "Settings", "LibRetro_JAG","virtualjaguar_libretro",,1)
LibRetro_LYNX := IniReadCheck(settingsFile, "Settings", "LibRetro_LYNX","handy_libretro",,1)
LibRetro_MAME := IniReadCheck(settingsFile, "Settings", "LibRetro_MAME","mame_libretro",,1)
LibRetro_MSX := IniReadCheck(settingsFile, "Settings", "LibRetro_MSX","bluemsx_libretro",,1)
LibRetro_MSX2 := IniReadCheck(settingsFile, "Settings", "LibRetro_MSX2","bluemsx_libretro",,1)
LibRetro_N64 := IniReadCheck(settingsFile, "Settings", "LibRetro_N64","mupen64plus_libretro",,1)
LibRetro_NEO := IniReadCheck(settingsFile, "Settings", "LibRetro_NEO","fb_alpha_libretro",,1)
LibRetro_NEOCD := IniReadCheck(settingsFile, "Settings", "LibRetro_NEO","mess_libretro",,1)
LibRetro_NEOAES := IniReadCheck(settingsFile, "Settings", "LibRetro_NEOAES","mess_libretro",,1)
LibRetro_NES := IniReadCheck(settingsFile, "Settings", "LibRetro_NES","nestopia_libretro",,1)
LibRetro_NFAM := IniReadCheck(settingsFile, "Settings", "LibRetro_NFAM","nestopia_libretro",,1)
LibRetro_NFDS := IniReadCheck(settingsFile, "Settings", "LibRetro_NFDS","nestopia_libretro",,1)
LibRetro_NSF := IniReadCheck(settingsFile, "Settings", "LibRetro_NSF","bsnes_balanced_libretro",,1)
LibRetro_NSFS := IniReadCheck(settingsFile, "Settings", "LibRetro_NSFS","snes9x_libretro",,1)
LibRetro_NVB := IniReadCheck(settingsFile, "Settings", "LibRetro_NVB","mednafen_vb_libretro",,1)
LibRetro_NGP := IniReadCheck(settingsFile, "Settings", "LibRetro_NGP","mednafen_ngp_libretro",,1)
LibRetro_NGPC := IniReadCheck(settingsFile, "Settings", "LibRetro_NGPC","mednafen_ngp_libretro",,1)
LibRetro_NINARC := IniReadCheck(settingsFile, "Settings", "LibRetro_NINARC","mame_libretro",,1)
LibRetro_ODYS2 := IniReadCheck(settingsFile, "Settings", "LibRetro_ODYS2","mess_libretro",,1)
LibRetro_PCE := IniReadCheck(settingsFile, "Settings", "LibRetro_PCE","mednafen_pce_fast_libretro",,1)
LibRetro_PCECD := IniReadCheck(settingsFile, "Settings", "LibRetro_PCECD","mednafen_pce_fast_libretro",,1)
LibRetro_PCFX := IniReadCheck(settingsFile, "Settings", "LibRetro_PCFX","mednafen_pcfx_libretro",,1)
LibRetro_PICO := IniReadCheck(settingsFile, "Settings", "LibRetro_PICO","picodrive_libretro",,1)
LibRetro_POCKS := IniReadCheck(settingsFile, "Settings", "LibRetro_POCKS","mess_libretro",,1)
LibRetro_POKE := IniReadCheck(settingsFile, "Settings", "LibRetro_POKE","mess_libretro",,1)
LibRetro_PSP := IniReadCheck(settingsFile, "Settings", "LibRetro_PSP","ppsspp_libretro",,1)
LibRetro_PSX := IniReadCheck(settingsFile, "Settings", "LibRetro_PSX","mednafen_psx_libretro",,1)
LibRetro_PUAE := IniReadCheck(settingsFile, "Settings", "LibRetro_PUAE","puae_libretro",,1)
LibRetro_PVID := IniReadCheck(settingsFile, "Settings", "LibRetro_PVID","mess_libretro",,1)
LibRetro_SACAN := IniReadCheck(settingsFile, "Settings", "LibRetro_SACAN","mess_libretro",,1)
LibRetro_SAMCP := IniReadCheck(settingsFile, "Settings", "LibRetro_SAMCP","mess_libretro",,1)
LibRetro_SAT := IniReadCheck(settingsFile, "Settings", "LibRetro_SAT","yabause_libretro",,1)
LibRetro_SC3K := IniReadCheck(settingsFile, "Settings", "LibRetro_SC3K","mess_libretro",,1)
LibRetro_SCD := IniReadCheck(settingsFile, "Settings", "LibRetro_SCD","genesis_plus_gx_libretro",,1)
LibRetro_SCV := IniReadCheck(settingsFile, "Settings", "LibRetro_SCV","mess_libretro",,1)
LibRetro_SCUMM := IniReadCheck(settingsFile, "Settings", "LibRetro_SCUMM","scummvm_libretro",,1)
LibRetro_SG1K := IniReadCheck(settingsFile, "Settings", "LibRetro_SG1K","genesis_plus_gx_libretro",,1)
LibRetro_SGB := IniReadCheck(settingsFile, "Settings", "LibRetro_SGB","bsnes_balanced_libretro",,1)
LibRetro_SGFX := IniReadCheck(settingsFile, "Settings", "LibRetro_SGFX","mednafen_supergrafx_libretro",,1)
LibRetro_SMS := IniReadCheck(settingsFile, "Settings", "LibRetro_SMS","genesis_plus_gx_libretro",,1)
LibRetro_SNES := IniReadCheck(settingsFile, "Settings", "LibRetro_SNES","bsnes_balanced_libretro",,1)
LibRetro_SORCR := IniReadCheck(settingsFile, "Settings", "LibRetro_SORCR","mess_libretro",,1)
LibRetro_SORD := IniReadCheck(settingsFile, "Settings", "LibRetro_SORD","mess_libretro",,1)
LibRetro_SPECZX := IniReadCheck(settingsFile, "Settings", "LibRetro_SPECZX","mess_libretro",,1)
LibRetro_SPORTV := IniReadCheck(settingsFile, "Settings", "LibRetro_SPORTV","mess_libretro",,1)
LibRetro_ST := IniReadCheck(settingsFile, "Settings", "LibRetro_ST","hatari_libretro",,1)
LibRetro_STUD2 := IniReadCheck(settingsFile, "Settings", "LibRetro_STUD2","mess_libretro",,1)
LibRetro_SVMU := IniReadCheck(settingsFile, "Settings", "LibRetro_SVMU","mess_libretro",,1)
LibRetro_SUPRV := IniReadCheck(settingsFile, "Settings", "LibRetro_SUPRV","mess_libretro",,1)
LibRetro_TG16 := IniReadCheck(settingsFile, "Settings", "LibRetro_TG16","mednafen_pce_fast_libretro",,1)
LibRetro_TGCD := IniReadCheck(settingsFile, "Settings", "LibRetro_TGCD","mednafen_pce_fast_libretro",,1)
LibRetro_TI99 := IniReadCheck(settingsFile, "Settings", "LibRetro_TI99","mess_libretro",,1)
LibRetro_TOMY := IniReadCheck(settingsFile, "Settings", "LibRetro_TOMY","mess_libretro",,1)
LibRetro_TRS80 := IniReadCheck(settingsFile, "Settings", "LibRetro_TRS80","mess_libretro",,1)
LibRetro_VECTX := IniReadCheck(settingsFile, "Settings", "LibRetro_VECTX","mess_libretro",,1)
LibRetro_VTECH := IniReadCheck(settingsFile, "Settings", "LibRetro_VTECH","mess_libretro",,1)
LibRetro_WSAN := IniReadCheck(settingsFile, "Settings", "LibRetro_WSAN","mednafen_wswan_libretro",,1)
LibRetro_WSANC := IniReadCheck(settingsFile, "Settings", "LibRetro_WSANC","mednafen_wswan_libretro",,1)
superGB := IniReadCheck(settingsFile, systemName . "|" . romName, "SuperGameBoy", "false",,1)
messRomPath := GetFullName(messRomPath)
libRetroFolder := GetFullName(libRetroFolder)

retroArchSystem := systemName

If (ident = "LibRetro_SGB" || If superGB = "true")	; if system or rom is set to use Super Game Boy
{	superGB = true	; setting this just in case it's false and the system is Nintendo Super Game Boy
	sgbRomPath := CheckFile(emuPath . "\system\Super Game Boy (World).sfc","Could not find the rom required for Super Game Boy support. Make sure the rom ""Super Game Boy (World).sfc"" is located in: " . emupath . "\system")
	CheckFile(emuPath . "\system\sgb.boot.rom","Could not find the bios required for Super Game Boy support. Make sure the bios ""sgb.boot.rom"" is located in: " . emupath . "\system")
	ident := "LibRetro_SGB"	; switching to Super Game Boy mode
	retroArchSystem := "Nintendo Super Game Boy"
}

; Find the cfg file to use
Loop, %emuPath%\*.cfg,,1 ; loop through all folder in emuPath
	If (A_LoopFileName = retroArchSystem . ".cfg") {
		sysRetroCfg := A_LoopFileLongPath
		Break	; retroArchSystem configs are preferred, so break after one is found
	} Else If (A_LoopFileName = "retroarch.cfg")
		globalRetroCfg := A_LoopFileLongPath
retroCFGFile := If sysRetroCfg ? sysRetroCfg : globalRetroCfg
Log(MEmu . " is using " . retroCFGFile . " as it's config file.")

; Find the dll for this system
Loop, %libRetroFolder%\*.dll,,1 ; loop through all folder in emuPath looking for the ident dll
	If (A_LoopFileName = %ident% . ".dll") {
		libDll := A_LoopFileLongPath
		Break
	}
If !libDll
	ScriptError("Your " . ident . " dll is set to " . %ident% . " but could not locate this file in any folder inside:`n" . libRetroFolder)

If ident In LibRetro_NFDS,LibRetro_SCD,LibRetro_TGCD,LibRetro_PCECD,LibRetro_PCFX
{	retroCFG := LoadProperties(retroCFGFile)	; load the config into memory
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

If InStr(ident, "LibRetro_N64") {		; these systems will use an ini to store game specific settings
	sysSettingsFile := CheckSysFile(modulePath . "\" . systemName . ".ini")	; create the ini if it does not exist
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

		coreOptionsCFGFile := CheckFile(emuPath . "\retroarch-core-options.cfg", "Could not find retroarch-core-options.cfg in retroarch directory")
		coreOptionsCFG := LoadProperties(coreOptionsCFGFile)
		
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
		
		SaveProperties(coreOptionsCFGFile, coreOptionsCFG)	
	}
}

hideEmuObj := Object("ahk_class ConsoleWindowClass",0,"RetroArch ahk_class RetroArch",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

; MESS core options
messIdent :=
messParam1 :=
messParam2 :=
messParam3 :=
If InStr(%ident%, "mess") {	; if a mess core is used
	Log("Module - Retroarch MESS mode enabled")
	; the messType object links the system name to the name mess recognizes
	messType := Object("Amstrad CPC","cpc464","Amstrad GX4000","gx4000","APF Imagination Machine","apfimag","Apple IIGS","apple2gs","Atari 8-bit","a800","Atari 2600","a2600","Atari 5200","a5200","Atari 7800","a7800","Atari Jaguar","jaguar","Atari Lynx","lynx","Bally Astrocade","astrocde","Bandai WonderSwan","wswan","Bandai WonderSwan Color","wscolor","Casio PV-1000","pv1000","Casio PV-2000","pv2000","Coleco ADAM","adam","ColecoVision","coleco","Creatronic Mega Duck","megaduck","Emerson Arcadia 2001","arcadia","Entex Adventure Vision","advision","Epoch Game Pocket Computer","gamepock","Epoch Super Cassette Vision","scv","Exidy Sorcerer","sorcerer","Fairchild Channel F","channelf","Funtech Super Acan","supracan","GCE Vectrex","vectrex","Hartung Game Master","gmaster","GamePark 32","gp32","Interton VC 4000","vc4000","JungleTac Sport Vii","vii","Magnavox Odyssey 2","odyssey2","Matra & Hachette Alice","alice32","Mattel Aquarius","aquarius","Mattel Intellivision","intv","NEC PC Engine","pce","NEC PC Engine-CD","pce","NEC SuperGrafx","sgx","NEC TurboGrafx-16","tg16","NEC TurboGrafx-CD","tg16","Nintendo 64","n64","Nintendo Entertainment System","nes","Nintendo Famicom Disk System","famicom","Nintendo Game Boy","gameboy","Nintendo Game Boy Advance","gba","Nintendo Game Boy Color","gbcolor","Nintendo Game Boy Japan","gameboy","Nintendo Pokemon Mini","pokemini","Nintendo Virtual Boy","vboy","Philips CD-i","cdimono1","Philips Videopac","videopac","RCA Studio II","studio2","Sega 32X","32x","Sega SC-3000","sc3000","Sega CD","segacd","Sega Game Gear","gamegear","Sega Genesis","genesis","Sega Master System","sms","Sega Mega Drive","megadriv","Sega VMU","svmu","Sinclair ZX Spectrum","spectrum","SNK Neo Geo AES","aes","SNK Neo Geo CD","neocd","SNK Neo Geo Pocket","ngp","SNK Neo Geo Pocket Color","ngpc","Sony PlayStation","psx","Sony PocketStation","pockstat","Sord M5","m5","Super Nintendo Entertainment System","snes","Tandy TRS-80 Color Computer 3","coco3","Texas Instruments TI 99-4A","ti99_4a","Tiger Game.com","gamecom","Tomy Tutor","tutor","VTech CreatiVision","crvision","Watara Supervision","svision")
	messIdent := messType[systemName]	; search object for the systemName identifier Retroarch uses for its cores
	If !messIdent
		ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for the MESS LibRetro core")
	Else
		Log("Module - MESS mode using a known ident: " . messIdent)

	If !messRomPath
		ScriptError("Please set the RetroArch module setting ""MESS_BIOS_Roms_Folder"" to the folder that contains your MESS BIOS roms to use MESS with RetroArch.")
		
	messParam1 :=
	messParam2 := " -rompath \" . """" . messRomPath . "\" . """"
	If messIdent = alice32
		messParam3 := " -cass1 \" . """" . romPath . "\" . romName . romExtension . "\" . """"
	Else If messIdent = cpc464
		messParam3 := " -cass \" . """" . romPath . "\" . romName . romExtension . "\" . """"
	Else If messIdent = spectrum
		messParam3 := " -cass \" . """" . romPath . "\" . romName . romExtension . "\" . """"
	Else If messIdent = cdimono1
		messParam3 := " -cdrom \" . """" . romPath . "\" . romName . romExtension . "\" . """"
	Else If messIdent = neocd
		messParam3 := " -cdrom \" . """" . romPath . "\" . romName . romExtension . "\" . """"
	Else If messIdent = neocdz
		messParam3 := " -cdrom \" . """" . romPath . "\" . romName . romExtension . "\" . """"
	Else If messIdent = svmu
		messParam3 := " -quik \" . """" . romPath . "\" . romName . romExtension . "\" . """"
	Else 
		messParam3 := " -cart \" . """" . romPath . "\" . romName . romExtension . "\" . """"
	
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

BezelStart()

fullscreen := If fullscreen = "true" ? " -f" : ""
srmPath := emuPath . "\srm\" . retroArchSystem	; path for this system's srm files
saveStatePath := emuPath . "\save\" . retroArchSystem	; path for this system's save state files

IfNotExist, %srmPath%
	FileCreateDir, %srmPath% ; creating srm dir if it doesn't exist
IfNotExist, %saveStatePath%
	FileCreateDir, %saveStatePath% ; creating save dir if it doesn't exist

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

If InStr(%ident%, "mess") {	; if a mess core is used
	Run(executable . " """ . (messIdent ? messIdent : "") . fullRomPath . """" . A_Space . fullscreen . " -c """ . retroCFGFile . """ -L """ . libDll . """ -s """ . srmPath . "\" . romName . ".srm"" -S """ . saveStatePath . "\" . romName . ".state""", emuPath, "Hide")
} Else If (ident = "LibRetro_SGB" || If superGB = "true") { ; For some reason, the order of our command line matters in this particular case.
	Run(executable . " " . fullscreen . " -c """ . retroCFGFile . """ -L """ . libDll . """ -s """ . srmPath . "\" . romName . ".srm"" -S """ . saveStatePath . "\" . romName . ".state""" . fullRomPath , emuPath, "Hide")
} Else {
	Run(executable . " " . fullRomPath . fullscreen . " -c """ . retroCFGFile . """ -L """ . libDll . """ -s """ . srmPath . "\" . romName . ".srm"" -S """ . saveStatePath . "\" . romName . ".state""", emuPath, "Hide")
}

WinWait("RetroArch ahk_class RetroArch")
WinWaitActive("RetroArch ahk_class RetroArch")

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

CloseProcess:
	FadeOutStart()
	; Send !{F4}
	WinClose("RetroArch ahk_class RetroArch")
Return
