MEmu = UniPlayer
MEmuV =  v1.34
MURL = http://www.nibiirosoft.com/Product/UniPlayer_en.html
MAuthor = bleasby
MVersion = 1.0.0
MCRC = 35CDEDDA
iCRC = 1E716C97
mId = 635259501630439538
MSystem = "Unity3D"
;----------------------------------------------------------------------------
; Notes:
; This program requires install of the Unity Web Player in advance. http://unity3d.com/webplayer
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

BezelStart()
7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("ahk_class UniPlayer 1.34")
WinWaitActive("ahk_class UniPlayer 1.34")

If (fullscreen = "true")
	ControlSend,, {F11}, ahk_class UniPlayer 1.34

BezelDraw()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("ahk_class UniPlayer 1.34")
Return
