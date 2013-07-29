MEmu = Spectaculator
MEmuV = v7.51
MURL = http://www.spectaculator.com/
MAuthor = djvj & brolly
MVersion = 2.0
MCRC = 362CCA69
iCRC = 68AADBE
MID = 635038268924350920
MSystem = "Sinclair ZX Spectrum"
;----------------------------------------------------------------------------
; Notes:
; Install Spectaculator, on first run put in your registration info and uncheck the box on the Welcome to Spectaculator window.
; On your first exit, uncheck the box to show warning next time and click Yes.
;
; Games are run on 48k model by default, if you want to use a different model for a specific game you can set it on the %moduleName%.ini file that 
; is on the same dir as this script, Configuration example (the key names MUST match your rom name):
;
; [Fish! (Europe)]
; model=plus3
; [3D Space Wars (Europe)]
; model=16k
; [Xybots (Europe)]
; model=128k
;
; To set your res and ratio, goto Tools->Options->Advanced->Display
; To enable fullscreen, set the Fullscreen variable below to true

; Spectaculator stores its settings in the registry @ HKEY_CURRENT_USER\Software\spectaculator.com\Spectaculator\Settings
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

; Read current ini & registry values so we know if they need to be updated for the chosen game
currentFullScreen := ReadReg("Full Screen")
currentModel := ReadReg("Model v6+")
iniModel := IniReadCheck(settingsFile, romName, "model","1",,1) ; 1 is the default value, which is the 48k ZX Spectrum model

; Updating registry with desired model number if it is different
If ( currentModel != iniModel ) {
	If ( iniModel = "128k" )
		WriteReg("Model v6+", 2)
	Else If (iniModel = "16k")
		WriteReg("Model v6+", 0)
	Else If (iniModel = "plus3")
		WriteReg("Model v6+", 5)
	Else
		WriteReg("Model v6+", 1) ; model 48k
}

; Setting Fullscreen setting in registry if it doesn't match what user wants above
If ( Fullscreen != "true" And currentFullScreen = 1 )
	WriteReg("Full Screen", 0)
Else If ( Fullscreen = "true" And currentFullScreen = 0 )
	WriteReg("Full Screen", 1)

7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("ahk_class SpectaculatorClass")
WinWaitActive("ahk_class SpectaculatorClass")

; Detect when our emulator is fullscreen and then continue
If Fullscreen = true
	While ( FS_Active != 1 && WinActive(ahk_class SpectaculatorClass) ) {
		CheckFullscreen()
		Sleep, 50
	}

DllCall("SetMenu", uint, WinActive( "A" ), uint, 0) ; Removes the MenuBar

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


ReadReg(var1) {
	RegRead, regValue, HKEY_CURRENT_USER, Software\spectaculator.com\Spectaculator\Settings, %var1%
	Return %regValue%
}

WriteReg(var1, var2) {
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\spectaculator.com\Spectaculator\Settings, %var1%, %var2%
}

CheckFullscreen() {
	FS_ABM := DllCall( "RegisterWindowMessage", Str,"AppBarMsg" ), VarSetCapacity( FS_AppBarData,36,0 )
	FS_Off := NumPut(36,FS_AppBarData), FS_Off := NumPut( WinExist(A_ScriptFullPath " - AutoHotkey"), FS_Off+0 )
	FS_Off := NumPut(FS_ABM, FS_Off+0), FS_Off := NumPut( 1,FS_Off+0 ) , FS_Off :=  NumPut( 1, FS_Off+0 )
	DllCall( "Shell32.dll\SHAppBarMessage", UInt, 0x0, UInt,&FS_APPBARDATA )
	OnMessage( FS_ABM, "FS_Notify" )
}

FS_Notify( wParam, LParam, Msg, HWnd ) {
	Global FS_Active
	FS_Active := LParam
}

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class SpectaculatorClass")
Return
