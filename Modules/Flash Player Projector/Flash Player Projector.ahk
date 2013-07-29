MEmu = Flash Player Projector
MEmuV = v11.6.602.168
MURL = http://www.adobe.com/support/flashplayer/downloads.html#fp11
MAuthor = djvj
MVersion = 2.0
MCRC = EAE5BFAE
iCRC = 233B583F
MID = 635038268891323433
MSystem = "Flash Games"
;----------------------------------------------------------------------------
; Notes:
; If you want a game to go fullscreen, define it in the Setting.ini
; If you forget to define your game in the ini, a section for it will be created for you when you first run it.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()
7z(romPath, romName, romExtension, 7zExtractPath)

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, romName, "Fullscreen","false",,1)

If fullscreen != true
	WinMinimizeAll

SetControlDelay, 50
Run(executable, emuPath)
WinWait("AHK_class ShockwaveFlash")
Send, ^o ; Open File
WinWait("AHK_class #32770")
ControlSetText, Edit1, %romPath%\%romName%%romExtension%, AHK_class #32770
ControlSend, Button1, {Enter}, AHK_class #32770

WinSet, Style, -0xC00000, AHK_class ShockwaveFlash ; Removes the titlebar of the game window
WinSet, Style, -0x40000, AHK_class ShockwaveFlash ; Removes the border of the game window
DllCall("SetMenu", uint, WinActive( "A" ), uint, 0) ; Removes the MenuBar

; Go Fullscreen
If fullscreen = true
{	Sleep, 500
	Send, ^f
	Sleep, 500
} Else
	Center("AHK_class ShockwaveFlash")

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()

If fullscreen != true
	WinMinimizeAllUndo

FadeOutExit()
ExitModule()


Center(title) {
	WinGetPos, x, y, width, height, %title%
	x := ( A_ScreenWidth / 2 ) - ( width / 2 )
	y := ( A_ScreenHeight / 2 ) - ( height / 2 )
	WinMove, %title%, , x, y
}

CloseProcess:
	FadeOutStart()
	WinClose("AHK_class ShockwaveFlash")
Return
