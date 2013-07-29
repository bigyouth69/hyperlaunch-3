MEmu = GEST
MEmuV =  v1.1.1
MURL = http://koti.mbnet.fi/gest_emu/
MAuthor = djvj
MVersion = 2.0
MCRC = 2D1F94A1
iCRC = 5B61E7F
MID = 635038268897058207
MSystem = "Nintendo Game Boy","Nintendo Game Boy Color"
;----------------------------------------------------------------------------
; Notes:
; Emu has no fullscreen, so this module will make it look fullscreen for you
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
SGBMode := IniReadCheck(settingsFile, "Settings", "SGBMode","true",,1)		; if true, games will use Super Game Boy colors for games that support them. Set false if you prefer no colors on original Game Boy games

BezelStart()

If Fullscreen = true
{	Gui 5: -AlwaysOnTop -Caption +ToolWindow
	Gui 5: Color, 000000
	Gui 5: Show, x0 y0 h%A_ScreenHeight% w%A_ScreenWidth%	
}

; Hide Taskbar and Start Button
WinHide, ahk_class Shell_TrayWnd
WinHide, Start ahk_class Button

7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("ahk_class GESTclass")
WinWaitActive("ahk_class GESTclass")

BezelDraw()

If (SGBMode = "true" or systemName = "Nintendo Game Boy Color")
	WinMenuSelectItem, AHK_class GESTclass,,System,System Type, GB Color	; sets Gest to use GB Color mode

WinSet, Style, -0xC00000, AHK_class GESTclass ; Removes the TitleBar
WinSet, Style, -0x40000, AHK_class GESTclass ; Removes the border of the game window
DllCall("SetMenu", uint, WinActive( "A" ), uint, 0) ; Removes the MenuBar

If Fullscreen = true
	MaximizeWindow("AHK_class GESTclass")

FadeInExit()
Process("WaitClose", executable)

; Restore Taskbar and Start Button
WinShow, ahk_class Shell_TrayWnd
WinShow, Start ahk_class Button

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

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class GESTclass")
Return
