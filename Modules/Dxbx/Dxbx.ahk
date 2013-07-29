MEmu = Dxbx
MEmuV = r1651
MURL = http://dxbx-emu.com/
MAuthor = djvj
MVersion = 2.0
MCRC = E101CEFD
iCRC = 1E716C97
MID = 635038268886069056
MSystem = "Microsoft XBOX"
;----------------------------------------------------------------------------
; Notes:
; This emu is only known to play these games: Turok Evolution, Smashing Drive, Futurama, Robotech: Battlecry, Whacked!
; The emu does not run iso directly, it runs the default.xbe found inside. You must extract the iso using an app like xIso or wx360. NEED TO VERIFY THIS ON A 32BIT OS
; Dxbx does not support 64-bit OSes, clicking play does nothing. More info here: http://forums.ngemu.com/showthread.php?t=134748
; Dxbx stores some settings in the registry @ HKEY_CURRENT_USER\Software\Cxbx
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

7z(romPath, romName, romExtension, 7zExtractDir)

; Setting Fullscreen setting in registry if it doesn't match what user wants above
currentFullScreen := ReadReg("Fullscreen")
If ( Fullscreen != "true" And currentFullScreen = 1 )
	WriteReg("Fullscreen", 0)
Else If ( Fullscreen = "true" And currentFullScreen = 0 )
	WriteReg("Fullscreen", 1)

; Run, "%executable%" "%romPath%\%romName%%romExtension%", %emuPath%
Run(executable . " """ . romPath . "\default.xbe""", emuPath)

WinWait("Dxbx ahk_class Tfrm_Main")
WinWaitActive("Dxbx ahk_class Tfrm_Main")

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


ReadReg(var1) {
	RegRead, regValue, HKEY_CURRENT_USER, Software\Cxbx\XBVideo, %var1%
	Return %regValue%
}

WriteReg(var1, var2) {
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Cxbx\XBVideo, %var1%, %var2%
}

CloseProcess:
	FadeOutStart()
	WinClose("Dxbx ahk_class Tfrm_Main")
Return
