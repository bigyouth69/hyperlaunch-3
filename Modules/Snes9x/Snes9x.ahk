MEmu = Snes9X
MEmuV =  v1.53
MURL = http://www.snes9x.com/
MAuthor = djvj
MVersion = 2.0.1
MCRC = 34FD2149
iCRC = FD5A1CE
MID = 635038268923820476
MSystem = "Nintendo Super Famicom","Super Nintendo Entertainment System"
;----------------------------------------------------------------------------
; Notes:
; Fullscreen is controlled via the variable below
; snes9x adjusts the windowed resolutions in the ini automatically based on the settings you choose below.
; Bezels work, but if you notice a black bar along the bottom, change this option to false in snes9x.conf: ExtendHeight
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
EmulateFullscreen := IniReadCheck(settingsFile, "Settings", "EmulateFullscreen","true",,1)		; This helps fading look better and work better on exit. You cannot use this with a normal fullscreen so one has to be false
WindowMaximized := IniReadCheck(settingsFile, "Settings", "WindowMaximized","true",,1)
Stretch := IniReadCheck(settingsFile, "Settings", "Stretch","true",,1)
MaintainAspectRatio := IniReadCheck(settingsFile, "Settings", "MaintainAspectRatio","true",,1)
HideMenu := IniReadCheck(settingsFile, "Settings", "HideMenu","true",,1)
FullScreenWidth := IniReadCheck(settingsFile, "Settings", "FullScreenWidth","1024",,1)
FullScreenHeight := IniReadCheck(settingsFile, "Settings", "FullScreenHeight","768",,1)

snes9xConf := CheckFile(emuPath . "\snes9x.conf")

BezelStart()

; Now let's update all our keys if they differ in the ini
iniLookup =
( ltrim c
   Display\Win, Fullscreen:Enabled, %Fullscreen%
   Display\Win, Fullscreen:EmulateFullscreen, %EmulateFullscreen%
   Display\Win, Window:Maximized, %WindowMaximized%
   Display\Win, Stretch:Enabled, %Stretch%
   Display\Win, Stretch:MaintainAspectRatio, %MaintainAspectRatio%
   Display\Win, Fullscreen:Width, %FullScreenWidth%
   Display\Win, Fullscreen:Height, %FullScreenHeight%
   Display\Win, HideMenu, %HideMenu%
)
Loop, Parse, iniLookup, `n
{	StringSplit, split, A_LoopField, `,, %A_Space%%A_Tab%
	IniRead, tempVar, %snes9xConf%, %split1%, %split2%
	If ( tempVar != split3 )
		IniWrite, % split3, %snes9xConf%, %split1%, %split2%
}

7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("Snes9X ahk_class Snes9X: WndClass")
WinWaitActive("Snes9X ahk_class Snes9X: WndClass")

BezelDraw()
FadeInExit()
Process("WaitClose", executable)
BezelExit()
7zCleanUp()
FadeOutExit()
ExitModule()

CloseProcess:
	FadeOutStart()
	WinClose("Snes9X ahk_class Snes9X: WndClass")
Return
