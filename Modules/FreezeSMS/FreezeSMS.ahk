MEmu = FreezeSMS
MEmuV =  v4.6
MURL = http://freezesms.emuunlim.com/
MAuthor = djvj
MVersion = 2.0.1
MCRC = A5FA51FD
iCRC = 1E716C97
mId = 635115863426031003
MSystem = "ColecoVision","Nintendo Entertainment System","Sega Game Gear","Sega Game Gear","Sega Master System","Sega SG-1000"
;----------------------------------------------------------------------------
; Notes:
; FreezeSMS stores its config in the registry @ HKEY_CURRENT_USER\Software\Freeze software\FreezeSMS
; Emu will probably not work in fullscreen mode (it cannot initialize directX on modern computers because it requires a very old directX).
; To use this emu, turn on bezel mode.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

BezelStart()

; Setting Fullscreen setting in registry if it doesn't match what user wants
currentFullscreen := ReadReg("Video", "Fullscreen")
If ( fullscreen != "true" And currentFullscreen = 1 )
	WriteReg("Video", "Fullscreen", 0)
Else If ( fullscreen = "true" And currentFullscreen = 0 )
	WriteReg("Video", "Fullscreen", 1)


7z(romPath, romName, romExtension, 7zExtractPath)

IfNotExist, %emuPath%\core.exe
{	Log("Module - core.exe not found, attempting to copy core.dat to core.exe",2)
	IfExist, %emuPath%\core.dat
		FileCopy, %emuPath%core.dat, %emuPath%\core.exe
		If ErrorLevel
			ScriptError("There was a problem renaming ""core.dat"" to ""core.exe"" in the emuPath. There might be a permission issue. Please do this manually")
	Else
		ScriptError("Could not locate ""core.dat"" in your emuPath. Please make sure it exists and rename it to ""core.exe"" so HyperLaunch can launch " . MEmu)
}

If romExtension not in .zip,.col,.gg,.nes,.sg,.sms
	ScriptError(MEmu . " only supports uncompressed or zip compressed roms. Please enable 7z support in HLHQ to use this module/emu.")
If executable = FreezeSMS.exe
	ScriptError("FreezeSMS requires core.exe to be set as your executable, not FreezeSMS.exe. Rename core.dat to core.exe.")

Run(executable . A_Space . romPath . "\" . romName . romExtension, emuPath)	; rompath and name must not be in quotes otherwise emu errors with "system not supported"

WinWait("FreezeSMS ahk_class FreezeSMS")
WinWaitActive("FreezeSMS ahk_class FreezeSMS")

BezelDraw()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


ReadReg(regFolder, var1) {
	RegRead, regValue, HKEY_CURRENT_USER, Software\Freeze software\FreezeSMS\%regFolder%, %var1%
	Return %regValue%
}

WriteReg(regFolder, var1, var2) {
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Freeze software\FreezeSMS\%regFolder%, %var1%, %var2%
}

CloseProcess:
	FadeOutStart()
	WinClose("FreezeSMS ahk_class FreezeSMS")
Return
