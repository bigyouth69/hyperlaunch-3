MEmu = FS-UAE
MEmuV = v2.22
MURL = http://fs-uae.net/
MAuthor = djvj
MVersion = 2.0
MCRC = 5BE94207
iCRC =
MID = 635038268893375138
MSystem = "Commodore Amiga","Commodore Amiga CD32","Commodore CDTV"
;----------------------------------------------------------------------------
; Notes:
; MODULE IS NOT COMPLETE, STILL NEED TO ADD CD32 AND CDTV SUPPORT
; NEED IDENT SUPPORT FOR AUTOMATICALLY SETTING MODEL BASED ON SSYTEMNAME
; Command Line Options - http://fs-uae.net/options
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
; model := IniReadCheck(settingsFile, "Settings", "AmigaModel","A4000/040",,1)
fullscreenWidth := IniReadCheck(settingsFile, "Settings", "FullscreenWidth","1024",,1)
fullscreenHeight := IniReadCheck(settingsFile, "Settings", "FullscreenHeight","768",,1)
windowWidth := IniReadCheck(settingsFile, "Settings", "WindowWidth","1024",,1)
windowHeight := IniReadCheck(settingsFile, "Settings", "WindowHeight","768",,1)
; resolution := IniReadCheck(settingsFile, "Settings", "Resolution","1024x768",,1)	; Set resolution of WinUAE's window. Depending on Fullscreen value, there are different resolutions supported by WinUAE.
; autoResume := IniReadCheck(settingsFile, "Settings", "autoResume","true",,1)		; if true, will automatically save your game's state on exit and reload it on the next launch of the same game.

model = A4000/040
amigaModel := "--amiga_model=" . model	; choices are A500+,A600,A1000,A1200,A1200/020,A3000,A4000/040,CD32,CDTV
fullscreen := "--fullscreen=" . (If Fullscreen = "true" ? 1 : 0)
fullscreenMode := "--fullscreen_mode=fullscreen-window"	; sets fullscreen windowed rather than fullscreen
If fullscreen =true
{	width := "--fullscreen_width=" . fullscreenWidth
	height := "--fullscreen_height=" . fullscreenHeight
} Else {
	width := "--window_width=" . windowWidth
	height := "--window_height=" . windowHeight
}

7z(romPath, romName, romExtension, 7zExtractPath)

; stateName := emuPath . "\states\" . romName . ".uss"

If romExtension = .adf
	gamePath := "--floppy_drive_0=""" . romPath . "\" . romName . romExtension . """"
Else If romExtension = .hdf
	gamePath := "--hard_drive_0=""" . romPath . "\" . romName . romExtension . """"
; Else if romExtension in .cue,.iso
	; mount in deamon and set CLI path to DT drive

Run(executable . A_Space . amigaModel . A_Space . fullscreen . A_Space . fullscreenMode . A_Space . width . A_Space . height . A_Space . gamePath, emuPath)

; If (FileExist(stateName) and autoResume="true") {
	; clipboard = %stateName%
	; WinWait("ahk_class AmigaPowah")
	; Send {F7}	; open load state window
	; WinWait("Restore a WinUAE snapshot file")
	; Send ^v
	; Send {Enter}
; }

WinWait("Amiga ahk_class SDL_app")
WinWaitActive("Amiga ahk_class SDL_app")

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
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
	WinClose("Amiga ahk_class SDL_app")
Return
