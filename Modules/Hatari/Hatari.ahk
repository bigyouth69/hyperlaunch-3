MEmu = Hatari
MEmuV =  v1.6.2
MURL = http://hatari.tuxfamily.org/
MAuthor = djvj
MVersion = 2.0
MCRC = 3F677781
iCRC = B597B222
MID = 635038268898109078
MSystem = "Atari ST"
;----------------------------------------------------------------------------
; Notes:
; Some games require you to open the A floppy drive and double click the prg inside to launch
; Extract this USA bios into the root of your emupath: http://steem.atari.st/tos_us.zip
; Extract this UK bios into the root of your emupath: http://steem.atari.st/tos_uk.zip
; Launch the hatari.exe manually and press F12->Rom and select TOS206 us or uk rom
; Now back at the F12 screen, click Save config and save it wherever you like.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
Monitor := IniReadCheck(settingsFile, "Settings", "Monitor","vga",,1)			; choices are mono, rgb, vga and tv
StatusBar := IniReadCheck(settingsFile, "Settings", "StatusBar","false",,1)		; show floppy status bar at bottom of emu window
Borders := IniReadCheck(settingsFile, "Settings", "Borders","false",,1)			; ST/STE only - show screen borders (for low/med resolution overscan demos), false will help stretch the game to fullscreen
Zoom := IniReadCheck(settingsFile, "Settings", "Zoom","false",,1)				; zoom low resolution
DesktopST := IniReadCheck(settingsFile, "Settings", "DesktopST","false",,1)		; Whether fullscreen mode uses desktop resolution to avoid: messing multi-screen setups, several seconds delay needed by LCD monitors resolution switching and the resulting sound break. As Hatari ST/E display code doesn't support zooming (except low-rez doubling), it doesn't get scaled (by Hatari or monitor) when this is enabled. Therefore this is mainly useful only if you suffer from the described effects, but still want to grab mouse and remove other distractions from the screen just by toggling fullscreen mode.

7z(romPath, romName, romExtension, 7zExtractPath)

rom := "--disk-a """ . romPath . "\" . romName . romExtension . """"
fs := (If Fullscreen = "true" ? ("-f") : ("-w"))
monitor := "--monitor " . Monitor
sb := (If StatusBar  = "true" ? ("--statusbar true") : ("--statusbar false"))
borders := (If Borders  = "true" ? ("--borders true") : ("--borders false"))
desktopST := (If desktop-st  = "true" ? ("--desktop-st true") : ("--desktop-st false"))
zoom := (If Zoom  = "true" ? ("-z 2") : (""))
quit = --confirm-quit false

Run(executable . " " . fs . " " . monitor . " " . sb . " " . borders . " " . desktopST . " " . zoom . " " . quit . " " . rom, emuPath) ;, "Min")

WinWait("Hatari ahk_class SDL_app")
WinWaitActive("Hatari ahk_class SDL_app")

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("Hatari ahk_class SDL_app")
Return
