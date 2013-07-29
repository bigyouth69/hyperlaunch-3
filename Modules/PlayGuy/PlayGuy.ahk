MEmu = PlayGuy
MEmuV =  v1.03b
MURL = http://www.emulator-zone.com/doc.php/gameboy/playguy.html
MAuthor = djvj
MVersion = 2.0
MCRC = 49BA2B61
iCRC = 381FED8F
MID = 635038268914853018
MSystem = "Nintendo Game Boy","Nintendo Game Boy Color"
;----------------------------------------------------------------------------
; Notes:
; Playguy stores its settings in an encrypted ini file which prevents editing it to control fullscreen on launch. So we need to rely on sending the alt+enter hotkey instead.
; Leave the emu in windowed mode and the module will control going fullscreen from the HLHQ module setting.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
bezelBottomOffset := IniReadCheck(settingsFile, "Settings", "bezelBottomOffset","21",,1)

BezelStart()
7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("PlayGuy ahk_class PLAYGUY")
WinWaitActive("PlayGuy ahk_class PLAYGUY")

If Fullscreen = true
	Send !{Enter}

DllCall("SetMenu", uint, WinActive( "A" ), uint, 0) ; Removes the MenuBar

BezelDraw()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()

CloseProcess:
	FadeOutStart()
	WinClose("PlayGuy ahk_class PLAYGUY")
Return
