MEmu = DeSmuME
MEmuV =  v0.9.9
MURL = http://www.desmume.com/
MAuthor = djvj
MVersion = 2.0.5
MCRC = 67395915
iCRC = ACC0671E
MID = 635038268882946453
MSystem = "Nintendo DS"
;----------------------------------------------------------------------------
; Notes:
; The example module ini from GIT comes with some of the vertical games already configured for vertical mode.
; Uncheck View->Show Toolbar
; Set View->Screen seperation to black, also choose your border (I prefer 5px)
; Open the desmume.ini and add "Show Console=0" anywhere to stop the console window from showing up
; Per-game vertical/rotation settings can be controlled via the module settings in HLHQ
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
vertical := IniReadCheck(settingsFile, "Settings|" . romName, "Vertical","false",,1)
lcdsLayout := IniReadCheck(settingsFile, "Settings|" . romName, "LCDs_Layout",0,,1)
lcdsSwap := IniReadCheck(settingsFile, "Settings|" . romName, "LCDs_Swap",0,,1)

; X432R support
SplitPath, executable,,,,exeNoExt
x432rIni := emuPath . "\" . exeNoExt . ".ini"	; this fork always names the ini after the executable name
x432riniFound :=
If FileExist(x432rIni) {
	Log("Module - Found X432R DeSmuME Emu")
	desmumeIni := x432rIni
	x432riniFound := true
} Else
	desmumeIni := CheckFile(emuPath . "\desmume.ini")

currentRotate := IniReadCheck(desmumeIni, "Video", "Window Rotate",0,,1)
currentRotateSet := IniReadCheck(desmumeIni, "Video", "Window Rotate Set",0,,1)
currentLCDsLayout := IniReadCheck(desmumeIni, "Video", "LCDsLayout",0,,1)
currentLCDsSwap := IniReadCheck(desmumeIni, "Video", "LCDsSwap",0,,1)

If (vertical = "true"  && (currentRotate = 0 || currentRotateSet = 0)) {
	IniWrite, 270, %desmumeIni%, Video, Window Rotate
	IniWrite, 270, %desmumeIni%, Video, Window Rotate Set
} Else If (vertical != "true"  && (currentRotate != 0 || currentRotateSet != 0)) {
	IniWrite, 0, %desmumeIni%, Video, Window Rotate
	IniWrite, 0, %desmumeIni%, Video, Window Rotate Set
}
If (currentLCDsLayout != lcdsLayout)
	IniWrite, %lcdsLayout%, %desmumeIni%, Video, LCDsLayout
If (currentLCDsSwap != lcdsSwap)
	IniWrite, %lcdsLayout%, %desmumeIni%, Video, LCDsSwap

hideEmuObj := Object("ahk_class ConsoleWindowClass",0,"ahk_class DeSmuME",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

BezelStart()

If bezelPath {	; defining xscale and yscale relative to the bezel windowed mode
	IniWrite, 0, %desmumeIni%, Display, Window Split Border Drag
	If vertical = true
		screenGapPixels := (bezelScreenWidth - 2*192*bezelScreenHeight/256 ) // 2
	Else
		screenGapPixels := (bezelScreenHeight - 2*192*bezelScreenWidth/256 ) // 2
	IniWrite, %screenGapPixels%, %desmumeIni%, Display, ScreenGap
}

If (bezelEnabled = "true" || fullscreen = "true")
	IniWrite, 0, %desmumeIni%, Display, Show Toolbar	; turn off the toolbar

If x432riniFound {
	IniRead, currentWindowFS, %desmumeIni%, X432R, WindowFullScreen
	If (currentWindowFS != 1 && fullscreen = "true")
		IniWrite, 1, %desmumeIni%, X432R, WindowFullScreen
	Else If (currentWindowFS != 0 && fullscreen != "true")
		IniWrite, 0, %desmumeIni%, X432R, WindowFullScreen
}

HideEmuStart()

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("ahk_class DeSmuME")
WinWaitActive("ahk_class DeSmuME")
BezelDraw()

If (Fullscreen = "true" && !x432riniFound)
{	WinGetPos, x, y, w, h, ahk_class DeSmuME ; Getting original position of the emu, so we know when it goes Fullscreen
	Send, !{Enter} ; Go Fullscreen, DeSmuME does not support auto-fullscreen yet
	Loop { ; looping so we know when to destroy the GUI
		Sleep, 200
		WinGetPos, x2, y2, w2, h2, ahk_class DeSmuME
		;ToolTip, x=%x%`ny=%y%`nw=%w%`nh=%h%`nx2=%x2%`ny2=%y2%`nw2=%w2%`nh2=%h2%
		If ( x != x2 ) ; x changes when emu goes fullscreen, so we will break here and destroy the GUI
			Break
	}
	Sleep, 200 ; Need a moment for the emu to finish going Fullscreen, otherwise we see the background briefly
}

HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


BezelLabel:
	disableHideTitleBar := true
	WinSet, Transparent, 0, ahk_class ConsoleWindowClass
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class DeSmuME")
Return
