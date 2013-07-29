MEmu = Virtual Jaguar
MEmuV =  vGIT 20130209
MURL = http://icculus.org/virtualjaguar/
MAuthor = djvj
MVersion = 2.0
MCRC = C4C04CC1
iCRC = E71DFE48
MID = 635038268931827139
MSystem = "Atari Jaguar"
;----------------------------------------------------------------------------
; Notes:
; Fullscreen works but is not perfect until the emu dev allows hiding of the toolbar
; The emu stores its config in the registry @ HKEY_CURRENT_USER\Software\Underground Software\Virtual Jaguar
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
MouseClicks := IniReadCheck(settingsFile, "Settings", "MouseClicks","true",,1)	; By default this is true and the module clicks your mouse to hide the toolbar, but this may not be needed on all PCs. On win8, I do not need it.

; This is necessary so we can paste in the rom we want to run, yet doesn't work lol...
;currentFullScreen := ReadReg("showUnknownSoftware")
;If ( showUnknownSoftware != "true")
;	WriteReg("showUnknownSoftware", true)

; winset, disable,, HyperSpin_2_0 ahk_class ApolloRuntimeContentWindow

; Setting Fullscreen setting in registry if it doesn't match what user wants above
currentFullScreen := ReadReg("fullscreen")
If ( Fullscreen = "true" And currentFullScreen = "false" )
	WriteReg("fullscreen", "true")
Else If ( Fullscreen != "true" And currentFullScreen = "true" )
	WriteReg("fullscreen", "false")

7z(romPath, romName, romExtension, 7zExtractPath)
Run(executable . " """ . romPath . "\" . romName . romExtension, emuPath)

WinWait("Virtual Jaguar ahk_class QWidget")
WinWaitActive("Virtual Jaguar ahk_class QWidget")

If Fullscreen != true
	Center(ahk_class QWidget) ; center window

FadeInExit()

If Fullscreen = true	; if windowed mode, moving the control causes the game to never show
{	Sleep, 1	; necessary on some pcs
	If MouseClicks = true
	{	MouseClick Right, 1, 1
		MouseClick Left, 5, 5
	}
	ControlMove QGLWidget1, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, ahk_class QWidget	; hides the toolbar from view
	If MouseClicks != true
		ControlMove QWidget2, 0, 0, 0, 0, ahk_pid %App_PID%
}

Process("WaitClose",executable)
7zCleanUp()
FadeOutExit()
ExitModule()


ReadReg(var1) {
	RegRead, regValue, HKEY_CURRENT_USER, Software\Underground Software\Virtual Jaguar, %var1%
	Return %regValue%
}

WriteReg(var1, var2) {
	RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Underground Software\Virtual Jaguar, %var1%, %var2%
}

Center(title) {
	WinGetPos, X, Y, width, height, %title%
	x := ( A_ScreenWidth / 2 ) - ( width / 2 )
	y := ( A_ScreenHeight / 2 ) - ( height / 2 )
	WinMove, %title%, , x, y
}

CloseProcess:
	FadeOutStart()
	WinClose("Virtual Jaguar ahk_class QWidget")
Return
