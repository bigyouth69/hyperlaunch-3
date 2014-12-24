MEmu = Future Pinball
MEmuV = v1.9.1.20101231
MURL = http://www.futurepinball.com/
MAuthor = djvj,brolly,bleasby
MVersion = 2.0.1
MCRC = D29236A2
iCRC = F3A73C54
MID = 635038268894446032
MSystem = "Future Pinball"
;----------------------------------------------------------------------------
; Notes:
; Thanks to the FPLaunch author for some of the code
; To set fullscreen, open the emu and goto Preferences->Video / Rendering Options and set your resolution and check fullscreen.
; To prevent crashes disable "Load Image into Table Editor" under Preferences->Editor Options
; AHK is not 100% reliable with its focusing. If coin/start/flipper buttons don't function when you start a table, try clicking your left mouse button.
; The script will fail If you have any errors or missing files for your tables. Make sure every table is working before you turn on the LoadingScreen.
; If you use Esc as your exit_emulator_key, you may see the table editor flash in when you exit a game. This is because Esc is the default fixed key for FP so it's closing the game before ahk does.
; If you get script errors or no tables seem to work, try running FP as admin and it will probably fix it.
; If you need to run FP as admin, you can try this trick http://www.zdnet.com/blog/bott/fixing-windows-vista-part-2-taming-uac/436?pg=4 and use the other Run command commented below
; Future Pinball stores its config in the registry @ HKEY_CURRENT_USER\Software\Future Pinball\GamePlayer
; For tables with custom game rooms you can see the fine details by pressing F11 to enable manual camera, then using WASD and your mouse to move around. Press F1 through F5 to cycle the camera views.
; If you are using BAM together with Future Pinball, make sure you point your emulator executable to the FPLoader.exe file and do not rename this file to anything else.
; You can download BAM here : http://www.ravarcade.pl/
;
;Fade:
;If you want to hide the future pinball loading screen behind fade, you just need to set the fullscreen option to false.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
ArcadeRenderer := IniReadCheck(settingsFile, "Settings|" . romName, "ArcadeRenderer", "false",,1)
RenderGameRoom := IniReadCheck(settingsFile, "Settings|" . romName, "RenderGameRoom", "false",,1)
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
WindowedResolution := IniReadCheck(settingsFile, "Settings", "Windowed_Resolution",A_ScreenWidth . "x" . A_ScreenHeight,,1)

BezelStart()

If bezelPath
	WindowedResolution := % Round(bezelScreenWidth) . "x" . Round(bezelScreenHeight)

If (executable = "FPLoader.exe")
	StayInRAM := IniReadCheck(settingsFile, "Settings|" . romName, "StayInRAM", "false",,1) ;Only applicable with BAM

If (ArcadeRenderer = "true")
	ParamsEnd := "/arcaderender"
If (StayInRAM = "true")
	ParamsBegin := "/STAYINRAM"

If (Fullscreen = "true")
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Future Pinball\GamePlayer, FullScreen, 1
Else {
	StringSplit, WindowedResolution, WindowedResolution, x
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Future Pinball\GamePlayer, Width, %WindowedResolution1%
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Future Pinball\GamePlayer, Height, %WindowedResolution2%
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Future Pinball\GamePlayer, FullScreen, 0
}

;Setting RenderGameRoom option on registry If needed
RegRead, currentGameRoom, HKEY_CURRENT_USER, Software\Future Pinball\GamePlayer, RenderGameRoom
If (currentGameRoom != RenderGameRoom)
{	NewValue := If RenderGameRoom = "true" ? "1" : "0"
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Future Pinball\GamePlayer, RenderGameRoom, %NewValue%
}

hideEmuObj := Object("ahk_class Ghost",0,"ahk_class SPLASH",0,"ahk_class ScriptEditorClass",0,"ahk_class FuturePinballOpenGLSecondary",0,"ahk_class FuturePinballOpenGL",1,"ahk_class FuturePinball",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)
HideEmuStart()

Run(executable . " " . ParamsBegin . " /open """ . romPath . "\" . romName . romExtension . """ /play /exit" . " " . ParamsEnd, emupath, "Hide")
;Run, "schtasks /run /tn �Future Pinball�", C:\Windows\system32 ; this runs FP via Task Scheduler If you need to run as admin and don't want to see a UAC popup

WinWait("ahk_class FuturePinball")
WinWait("ahk_class FuturePinballOpenGL")
WinActivate, ahk_class FuturePinballOpenGL
WinWaitActive("ahk_class FuturePinballOpenGL")
WinWait, ahk_class FuturePinballOpenGLSecondary,,1	; do not use the function because it will ScriptError after 1 second
WinActivate, ahk_class FuturePinballOpenGLSecondary
WinWaitActive, ahk_class FuturePinballOpenGLSecondary,,1	; do not use the function because it will ScriptError after 1 second
WinWaitClose("ahk_class Ghost",,5)	; this doesn't always get picked up by ahk, so we need a timeout
Loop {
	IfWinActive, Future Pinball ahk_class FuturePinballOpenGL
		Break
	WinActivate, Future Pinball ahk_class FuturePinballOpenGL
	Sleep, 50
}
WinWaitActive("Future Pinball ahk_class FuturePinballOpenGL")

If (Fullscreen = "false"){
	If !bezelPath {
		WinGet emulatorID, ID, A
		WinSet, Style, -0xC00000, A
		;ToggleMenu(emulatorID)
		WinSet, Style, -0xC40000, A
		WinMove, ahk_id %emulatorID%, , 0, 0
		timeout := A_TickCount
		Sleep, 200
		Loop {
			Sleep, 50
			WinGetPos, X, Y, W, H, ahk_id %emulatorID%
			If (X=0) and (Y=0)
				Break
			If (timeout < A_TickCount - 3000)
				Break
			Sleep, 50
			WinMove, ahk_id %emulatorID%, , 0, 0
		}
	}
}

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
BezelExit()
7zCleanUp()
FadeOutExit()
ExitModule()

CloseProcess:
	FadeOutStart()
	WinHide, ahk_class FuturePinball	; need these 2 lines otherwise the table editor flashes over the GUI
	WinMinimize, ahk_class FuturePinball
	WinClose("ahk_class FuturePinball")
	WinWaitClose("ahk_class FuturePinball")	; this helps eliminate the slight flicker when you exit the table
Return
