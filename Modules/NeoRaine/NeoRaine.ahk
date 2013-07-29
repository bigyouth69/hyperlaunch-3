MEmu = NeoRaine
MEmuV = v1.4.3
MURL = http://rainemu.swishparty.co.uk/
MAuthor = brolly & djvj
MVersion = 2.0.1
MCRC = 3AB8707F
iCRC = 1E716C97
MID = 635038268907767111
MSystem = "SNK Neo Geo CD"
;-------------------------------------------------------------------------
; Notes:
; To use fullscreen, set the variable below to true
; First time you run the emu, it will ask you to find the Neocd.bin bios, so place it in the folder with the emulator or a "bios" subfolder.
; If you get an error "Could not open IPL.TXT", then you have one of the below problems:
; Not using a real Neo-Geo CD game (which are cd images) that contain an IPL.TXT. Do not use MAME roms otherwise you will get this error.
; NeoRaine does not support zipped cd images, like cue/iso/bin. It does however support zipped games when these images are extracted with their contents inside the zip.
;-------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

neoINI := CheckFile(emuPath . "\config\raine32_sdl.cfg","Could not locate " . emuPath . "\config\raine32_sdl.cfg`nPlease run NeoRaine manually first so it is created for you.")
IniRead, currentFullScreen, %neoINI%, Display, fullscreen

BezelStart()

; Setting Fullscreen setting in ini if it doesn't match what user wants above
If ( Fullscreen != "true" And currentFullScreen = 1 )
	IniWrite, 0, %neoINI%, Display, fullscreen
Else If ( Fullscreen = "true" And currentFullScreen = 0 )
	IniWrite, 1, %neoINI%, Display, fullscreen

7z(romPath, romName, romExtension, 7zExtractPath)

If romExtension in .7z,.rar
	ScriptError("NeoRaine only supports zip archives. Either enable 7z support, or extract your games first.")

Run(executable . " -nogui """ . romPath . "\" . romName . romExtension . """", emuPath) ;qs, "Hide")

WinWait("ahk_class SDL_app")
WinWaitActive("ahk_class SDL_app")
BezelDraw()

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
FadeOutExit()
ExitModule()


RestoreEmu:
	Sleep, 500
	Send, {Tab}
	Sleep, 200
	Send, {Enter}
Return

CloseProcess:
	FadeOutStart()
	WinClose, ahk_class SDL_app
Return
