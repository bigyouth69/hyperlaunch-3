MEmu = No$GBA & No$Zoomer
MEmuV =  v2.6a & v2.3.0.2
MURL = http://www.nogba.com/
MAuthor = brolly & djvj
MVersion = 2.0
MCRC = 86183B05
iCRC = 1B02DE88
MID = 635038268909338425
MSystem = "Nintendo DS","Nintendo Game Boy Advance"
;----------------------------------------------------------------------------
; Notes:
; On first run make sure you right click the game window during gameplay and select fullscreen and always on top
;
; For Nintendo DS support only:
; Create a separate entry in your Global Emulators or Emulators.ini for this same module as the GBA entry (if none exists already)
; Requires No$Zoomer.exe
; Point your exe to No$Zoomer.exe
; On first run No$Zoomer you will ask you to point to the No$GBA executable
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
bezelTopOffset := IniReadCheck(settingsFile, "Settings", "bezelTopOffset","50",,1)
bezelBottomOffset := IniReadCheck(settingsFile, "Settings", "bezelBottomOffset","7",,1)
bezelLeftOffset := IniReadCheck(settingsFile, "Settings", "bezelLeftOffset","7",,1)
bezelRightOffset := IniReadCheck(settingsFile, "Settings", "bezelRightOffset","7",,1)

BezelStart()
7z(romPath, romName, romExtension, 7zExtractPath)

zoomEmu := Instr(executable,"zoom")	; if executable is No$Zoomer.exe
emuTitle := If zoomEmu ? "NO$Zoomer ahk_class HT_MainWindowClass" : "No$gba Emulator ahk_class No$dlgClass"

gbaINI := CheckFile(emuPath . "\" . (If zoomEmu ? "NO$Zoomer.ini" : "NO$GBA.INI"))
IniRead, currentFullScreen, %gbaINI%, NO$ZOOMER, ExecFullscreen

; Setting Fullscreen setting in ini if it doesn't match what user wants above
If zoomEmu {
	If ( Fullscreen != "true" And currentFullScreen = 1 )
		IniWrite, 0, %gbaINI%, NO$ZOOMER, ExecFullscreen
	Else If ( Fullscreen = "true" And currentFullScreen = 0 )
		IniWrite, 1, %gbaINI%, NO$ZOOMER, ExecFullscreen
}

If bezelPath	; defining bezel game window size for Nintendo DS
{	
	bezelScreenX := round(bezelScreenX) , bezelScreenY := round(bezelScreenY), bezelScreenWidth := round(bezelScreenWidth) , bezelScreenHeight := round(bezelScreenHeight)
	IniWrite, %bezelScreenX%, %gbaINI%, NO$ZOOMER, PosX
	IniWrite, %bezelScreenY%, %gbaINI%, NO$ZOOMER, PosY
	scaleGameScreen := bezelScreenWidth/256
	IniWrite, %scaleGameScreen%, %gbaINI%, NO$ZOOMER, Zoom
}

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait(emuTitle)
WinWaitActive(emuTitle)

If (!zoomEmu && Fullscreen = "true") {	; only want this for GBA mode
	; These do not work :-(
	; WinSet, Style, -0x40000, % emuTitle ; Removes the border of the game window
	; WinSet, Style, -0xC00000, %emuTitle% ; Removes the TitleBar
	DllCall("SetMenu", uint, WinActive( "A" ), uint, 0) ; Removes the MenuBar
	MaximizeWindow(emuTitle)
}

BezelDraw()
FadeInExit()
Process("WaitClose", "NO$GBA.exe")
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


MaximizeWindow(class) {
	WinGetPos, appX, appY, appWidth, appHeight, %class%
	widthMaxPercenty := ( A_ScreenWidth / appWidth )
	heightMaxPercenty := ( A_ScreenHeight / appHeight )

	If  ( widthMaxPercenty < heightMaxPercenty )
		percentToEnlarge := widthMaxPercenty
	Else
		percentToEnlarge := heightMaxPercenty

	appWidthNew := appWidth * percentToEnlarge
	appHeightNew := appHeight * percentToEnlarge
	Transform, appX, Round, %appX%
	Transform, appY, Round, %appY%
	Transform, appWidthNew, Round, %appWidthNew%, 2
	Transform, appHeightNew, Round, %appHeightNew%, 2
	appXPos := ( A_ScreenWidth / 2 ) - ( appWidthNew / 2 )
	appYPos := ( A_ScreenHeight / 2 ) - ( appHeightNew / 2 )
	WinMove, %class%,, appXPos, appYPos, appWidthNew, appHeightNew
}

BezelLabel:
	disableHideTitleBar = true
	disableHideToggleMenu = true
	disableHideBorder = true
	if zoomEmu   ; only want this for No$Zoomer
		disableWinMove = true
Return

CloseProcess:
	FadeOutStart()
	WinClose(emuTitle)
Return
