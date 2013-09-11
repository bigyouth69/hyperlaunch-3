MEmu = Handy
MEmuV = v0.95 hack
MURL = http://handy.sourceforge.net/
MAuthor = djvj
MVersion = 2.0
MCRC = A4312829
iCRC = 1BCEE76A
MID = 635038268897588652
MSystem = "Atari Lynx"
;----------------------------------------------------------------------------
; Notes:
; This module is for the Hacked version of the emu, NOT the normal release as it will not work. http://www.hyperspin-fe.com/forum/showthread.php?14262-Emulator-Handy-0-95-Hack
; Make sure lynxboot.img is in the dir with the emu.
; 
; Set the variables in HLHQ to your liking

; Command Line Options for Hacked version:
; Screen options:
; -d=1 .....Normal Mode (Windowed)
; -d=2 .....Normal Mode (Full Screen)
; -d=3 .....Lynx LCD (Windowed)
; -d=4 .....Lynx LCD (Full Screen)
; -d=5 .....Eagle (Windowed)
; -d=6 .....Eagle (Full Screen)
; -d=7 .....GDI Mode (Windowed)
;
; Zoom options:
; -z=1 .....zoom in 1X
; -z=2 .....zoom in 2X
; -z=3 .....zoom in 3X
; -z=4 .....zoom in 4X
;
; Rotate options:
; -r=0 .....No rotation, normal
; -r=1 .....Rotate Left
; -r=2 .....Rotate Right
;
; Settings are stored in the registry @ HKEY_CURRENT_USER\Software\Irwell Expert Systems\handy\Version 1.0
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

7z(romPath, romName, romExtension, 7zExtractPath)

settingsFile := modulePath . "\" . moduleName . ".ini"
ScreenMode := IniReadCheck(settingsFile, "Settings", "ScreenMode","2",,1)
ZoomLevel := IniReadCheck(settingsFile, "Settings", "ZoomLevel","4",,1)
bezelTopOffset := IniReadCheck(settingsFile, "Settings", "bezelTopOffset","29",,1)
bezelBottomOffset := IniReadCheck(settingsFile, "Settings", "bezelBottomOffset","30",,1)
bezelLeftOffset := IniReadCheck(settingsFile, "Settings", "bezelLeftOffset","10",,1)
bezelRightOffset := IniReadCheck(settingsFile, "Settings", "bezelRightOffset","10",,1)
rotateScreen := IniReadCheck(settingsFile, romName, "RotateScreen",A_Space,,1)	; Options are Left, Right, or not defined (per-game option)

rotateScreen := If rotateScreen = "Left" ? 1 : rotateScreen = "Right" ? 2 : 0

BezelStart("fixResMode",,(If rotateScreen ? 1:""))

If bezelPath
	ScreenMode = 3

CheckFile(emuPath . "\lynxboot.img")

Run(executable . " -r=" . rotateScreen . " -d=" . ScreenMode . " -z=" . zoomLevel . " ""-g=" romPath . "\" . romName . romExtension . """", emuPath)

WinWait("ahk_class AfxFrameOrView100sd")
WinWaitActive("ahk_class AfxFrameOrView100sd")

BezelDraw()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


HaltEmu:
	disableActivateBlackScreen = true
Return

BezelLabel:
	disableHideTitleBar = true
	disableHideBorder = true
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class AfxFrameOrView100sd")
Return
