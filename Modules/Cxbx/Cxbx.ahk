MEmu = Cxbx
MEmuV = r174
MURL = http://sourceforge.net/projects/cxbx/
MAuthor = djvj
MVersion = 2.0
MCRC = 804B8359
iCRC = EB44FC76
MID = 635038268879243370
MSystem = "Microsoft XBOX"
;----------------------------------------------------------------------------
; Notes:
; This emu is only known to play these games: Turok Evolution, Smashing Drive, Futurama, Robotech: Battlecry, Whacked!
; The emu does not run iso directly, it runs the default.xbe found inside. You must extract the iso using an app like xIso or wx360. NEED TO VERIFY THIS ON A 32BIT OS
; Cxbx does not support 64-bit OSes, you will get an error "unable to start correctly (0xc000007b)". More info here: http://forums.ngemu.com/showthread.php?t=134748
; Cxbx stores some settings in the registry @ HKEY_CURRENT_USER\Software\Cxbx
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "settings", "Fullscreen","true",,1)

7z(romPath, romName, romExtension, 7zExtractPath)

; Setting Fullscreen setting in registry if it doesn't match what user wants above
currentFullScreen := ReadReg("Fullscreen")
If ( Fullscreen != "true" And currentFullScreen = 1 )
	WriteReg("Fullscreen", 0)
Else If ( Fullscreen = "true" And currentFullScreen = 0 )
	WriteReg("Fullscreen", 1)

Run(executable . """" . romPath . "\default.xbe""", emuPath)

WinWait("Cxbx ahk_class WndMain")
WinWaitActive("Cxbx ahk_class WndMain")

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
	WinClose("Cxbx ahk_class WndMain")
Return
