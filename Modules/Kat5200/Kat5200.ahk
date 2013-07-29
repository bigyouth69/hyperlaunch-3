MEmu = Kat5200
MEmuV =  v0.6.2
MURL = http://kat5200.jillybunch.com/
MAuthor = djvj
MVersion = 2.0.1
MCRC = 3FDEE537
MID = 635038268901251702
MSystem = "Atari 5200"
;----------------------------------------------------------------------------
; Notes:
; In you emu dir, create a subdir named bios and place the 5200.rom there extracted.
; When you first start kat5200, you will be presented with a Wizard. Set the bios folder you created as your "Atari 8-bit Image Directory" and leave Scan for BIOS? checked.
; While in the wizard, check the Fullscreen box to enable it and set Video Zoom to 2x.
; CLI is supported but doesn't seem to work. So for now, set your video options from the GUI.
; Settings are stored in the kat5200.db3 file.
; Roms must be extracted, zip is not supported
;----------------------------------------------------------------------------
StartModule()
FadeInStart()
7z(romPath, romName, romExtension, 7zExtractPath)

If romExtension in %7zFormats%
	ScriptError("Kat5200 only supports extracted roms. Please extract your roms or turn on 7z for this system as the emu is being sent this extension: """ . romExtension . """")

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("kat5200 ahk_class SDL_app")
WinWaitActive("kat5200 ahk_class SDL_app")

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("kat5200 ahk_class SDL_app")
Return
