MEmu = Flash Player Projector
MEmuV = v14.0.0.125
MURL = http://www.adobe.com/support/flashplayer/downloads.html#fp14
MAuthor = djvj
MVersion = 2.0.1
MCRC = C2B756A8
iCRC = BB98EE64
MID = 635038268891323433
MSystem = "Flash Games"
;----------------------------------------------------------------------------
; Notes:
; Fullscreen can be controlled for the entire system or per-game via HLHQ.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()
hideEmuObj := Object("ahk_class #32770",0,"ahk_class ShockwaveFlash",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings|" . romName, "Fullscreen","true",,1)

BezelStart()
HideEmuStart()
Run(executable, emuPath)

WinWait("ahk_class ShockwaveFlash")
WinActivate, ahk_class ShockwaveFlash	; occasionally does not activate automatically
WinWaitActive("ahk_class ShockwaveFlash")

PostMessage, 0x111, 20002,,,ahk_class ShockwaveFlash	; Open

OpenROM("ahk_class #32770", romPath . "\" . romName . romExtension)
WinWaitActive("ahk_class ShockwaveFlash")

WinSet, Style, -0xC00000, AHK_class ShockwaveFlash ; Removes the titlebar of the game window
WinSet, Style, -0x40000, AHK_class ShockwaveFlash ; Removes the border of the game window
DllCall("SetMenu", uint, WinActive( "A" ), uint, 0) ; Removes the MenuBar

; Go Fullscreen
PostMessage, 0x111, 20034,,,ahk_class ShockwaveFlash	; Show All - makes sure all games fill the player's window when stretched
If fullscreen = true
	PostMessage, 0x111, 20048,,,ahk_class ShockwaveFlash	; Fullscreen
Else
	Center("ahk_class ShockwaveFlash")

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
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
	WinClose("ahk_class ShockwaveFlash")
Return

; PostMessage, 0x111, 20002,,,ahk_class ShockwaveFlash	; Open
; PostMessage, 0x111, 20007,,,ahk_class ShockwaveFlash	; Exit
; PostMessage, 0x111, 20034,,,ahk_class ShockwaveFlash	; Show All
; PostMessage, 0x111, 20046,,,ahk_class ShockwaveFlash	; 100%
; PostMessage, 0x111, 20048,,,ahk_class ShockwaveFlash	; Fullscreen
; PostMessage, 0x111, 20050,,,ahk_class ShockwaveFlash	; Exit Fullscreen
