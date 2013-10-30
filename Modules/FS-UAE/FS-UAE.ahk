MEmu = FS-UAE
MEmuV = v2.2.3
MURL = http://fs-uae.net/
MAuthor = djvj
MVersion = 2.0.1
MCRC = D05A46DF
iCRC = 381AA8E
MID = 635038268893375138
MSystem = "Commodore Amiga","Commodore Amiga CD32","Commodore CDTV"
;----------------------------------------------------------------------------
; Notes:
; Command Line Options - http://fs-uae.net/options
; Be sure to set the paths to the BIOS roms in the module settings in HLHQ.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

; This object controls how the module reacts to different systems. FS-UAE can play a lot of systems, but needs to know what system you want to run, so this module has to adapt.
mType := Object("Commodore Amiga","A1200","Commodore Amiga CD32","CD32/FMV","Commodore CDTV","CDTV")
ident := mType[systemName]	; search object for the systemName identifier FS-UAE uses
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this " . MEmu . " module: " . moduleName)

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
fullscreenRes := IniReadCheck(settingsFile, "Settings", "FullscreenResolution",,,1)
windowedRes := IniReadCheck(settingsFile, "Settings", "WindowedResolution",,,1)
a1200Rom := IniReadCheck(settingsFile, "Settings", "A1200_Rom",,,1)
cd32Rom := IniReadCheck(settingsFile, "Settings", "CD32_Rom",,,1)
cd32ExtRom := IniReadCheck(settingsFile, "Settings", "CD32_Ext_Rom",,,1)
cdTVRom := IniReadCheck(settingsFile, "Settings", "CDTV_Rom",,,1)
cdTVExtRom := IniReadCheck(settingsFile, "Settings", "CDTV_Ext_Rom",,,1)
; amigaModel := IniReadCheck(settingsFile, "Settings", "AmigaModel","A1200",,1)		; possible choices are A500+,A600,A1000,A1200,A1200/020,A3000,A4000/040,CD32,CDTV
; autoResume := IniReadCheck(settingsFile, "Settings", "autoResume","true",,1)		; if true, will automatically save your game's state on exit and reload it on the next launch of the same game.

BezelStart()

If ident = A1200
{	a1200Rom := CheckFile(GetFullName(a1200Rom), "Could not find your A1200_Rom. " . systemName . " first requires the ""A1200_Rom"" to be set in HLHQ's module settings for " . MEmu . ".")
	kickstartBios := " --kickstart_file=""" . a1200Rom . """"
}Else if ident = CD32/FMV
{	cd32Rom := CheckFile(GetFullName(cd32Rom), "Could not find your CD32_Rom. " . systemName . " first requires the ""CD32_Rom"" to be set in HLHQ's module settings for " . MEmu . ".")
	cd32ExtRom := CheckFile(GetFullName(cd32ExtRom), "Could not find your CD32_Ext_Rom. " . systemName . " first requires the ""CD32_Ext_Rom"" to be set in HLHQ's module settings for " . MEmu . ".")
	kickstartBios := " --kickstart_file=""" . cd32Rom . """"
	kickstartExtBios := " --kickstart_ext_file=""" . cd32ExtRom . """"
}Else if Ident = CDTV
{	cdTVRom := CheckFile(GetFullName(cdTVRom), "Could not find your CDTV_Rom. " . systemName . " first requires the ""CDTV_Rom"" to be set in HLHQ's module settings for " . MEmu . ".")
	cdTVExtRom := CheckFile(GetFullName(cdTVExtRom), "Could not find your CDTV_Ext_Rom. " . systemName . " first requires the ""CDTV_Ext_Rom"" to be set in HLHQ's module settings for " . MEmu . ".")
	kickstartBios := " --kickstart_file=""" . cdTVRom . """"
	kickstartExtBios := " --kickstart_ext_file=""" . cdTVExtRom . """"
}
amigaModel := " --amiga_model=" . ident
fullscreenMode := " --fullscreen_mode=fullscreen-window"	; sets fullscreen windowed rather than true fullscreen
If (fullscreen = "true" && fullscreenRes != "") {
	Loop, Parse, fullscreenRes, x
		If A_index = 1
			fsuaeW := A_LoopField
		Else
			fsuaeH := A_LoopField
	width := " --fullscreen_width=" . fsuaeW
	height := " --fullscreen_height=" . fsuaeH
} Else If (fullscreen != "true" && windowedRes != "") {
	Loop, Parse, windowedRes, x
		If A_index = 1
			fsuaeW := A_LoopField
		Else
			fsuaeH := A_LoopField
	width := " --window_width=" . fsuaeW
	height := " --window_height=" . fsuaeH
}
fullscreen := " --fullscreen=" . (If Fullscreen = "true" ? 1 : 0)

7z(romPath, romName, romExtension, 7zExtractPath)

; stateName := emuPath . "\states\" . romName . ".uss"

If romExtension = .adf
	gamePathMethod := "floppy_drive_0"
Else If romExtension = .hdf
	gamePathMethod := "hard_drive_0"
Else if romExtension in .cue,.iso
    gamePathMethod := "cdrom_drive_0"
Else
	ScriptError("Unsupported extension supplied: """ . romExtension . """. Only extracted files are supported in this module. Turn on 7z support or extract your roms first.")	; no support for zipped roms because without looking inside the archive first, there is no way of knowing if the game is a floppy or hard drive image.
gamePath := " --" . gamePathMethod . "=""" . romPath . "\" . romName . romExtension . """"
; can we mount in deamon and set CLI path to DT drive ???
; MG support might only work if sending multiple cd images on launch by using cdrom_image_1, 2, 3, etc. Need to verify this.

Run(executable . amigaModel . fullscreen . fullscreenMode . width . height . kickstartBios . kickstartExtBios . gamePath, emuPath)

; If (FileExist(stateName) and autoResume="true") {
	; clipboard = %stateName%
	; WinWait("ahk_class AmigaPowah")
	; Send {F7}	; open load state window
	; WinWait("Restore a WinUAE snapshot file")
	; Send ^v
	; Send {Enter}
; }

WinWait("FS-UAE ahk_class SDL_app")
WinWaitActive("FS-UAE ahk_class SDL_app")

BezelDraw()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()

; GroupAdd,DIE,DIEmWin
; GroupClose, DIE, A

ExitModule()


CloseProcess:
	; If (FileExist(stateName) and autoResume="true")
		; Send {F5}	; open save state window
	FadeOutStart()
	; If (FileExist(stateName) and autoResume="true") {
		; clipboard = %stateName%	; just in case something happened to clipboard in between start of module to now
		; WinWait("Save a WinUAE snapshot file")
		; Send ^v
		; Send {Enter}
		; Sleep, 50	; always give time for a file operation to occur before closing an app
	; }
	WinClose("FS-UAE ahk_class SDL_app")
Return
