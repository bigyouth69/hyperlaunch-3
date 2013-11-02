MEmu = DeSmuME
MEmuV =  v0.9.9
MURL = http://www.desmume.com/
MAuthor = djvj
MVersion = 2.0.2
MCRC = 2186DE30
iCRC = A5A00A8F
MID = 635038268882946453
MSystem = "Nintendo DS"
;----------------------------------------------------------------------------
; Notes:
; Grab the settings.ini from my user folder on the ftp. It is needed to support vertical games.
; Uncheck View->Show Toolbar
; Set View->Screen seperation to black, also choose your border (I prefer 5px)
; Open the desmume.ini and add "Show Console=0" anywhere to stop the console window from showing up
; Add a game to settings.ini if you need it to be rotated
; Fullscreen is controlled from the module's .ini
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
bezelTopOffset := IniReadCheck(settingsFile, "Settings", "Bezel_Top_Offset","29",,1)
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
vertical := IniReadCheck(settingsFile, romName, "vertical","false",,1)

desmumeIni := CheckFile(emuPath . "\desmume.ini")
rotate := IniReadCheck(desmumeIni, "Video", "Window Rotate","0",,1)
rotateSet := IniReadCheck(desmumeIni, "Video", "Window Rotate Set","0",,1)

If ( vertical = "true"  And ( rotate = 0 Or rotateSet = 0 )) {
	IniWrite, 270, %desmumeIni%, Video, Window Rotate
	IniWrite, 270, %desmumeIni%, Video, Window Rotate Set
} Else If ( vertical != "true"  And ( rotate != 0 Or rotateSet != 0 )) {
	IniWrite, 0, %desmumeIni%, Video, Window Rotate
	IniWrite, 0, %desmumeIni%, Video, Window Rotate Set
}

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

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("ahk_class DeSmuME")
WinWaitActive("ahk_class DeSmuME")
BezelDraw()

If Fullscreen = true
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
