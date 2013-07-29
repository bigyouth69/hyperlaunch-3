MEmu = Nintendulator
MEmuV =  v0.975 Beta
MURL = http://www.qmtpro.com/~nes/nintendulator/
MAuthor = djvj
MVersion = 2.0.1
MCRC = 4B77673B
iCRC = 1E716C97
MID = 635038268908817987
MSystem = "Nintendo Entertainment System","Nintendo Famicom"
;----------------------------------------------------------------------------
; Notes:
; Roms must be unzipped as .nes/.fds/.unif/.unf files, zips are not supported
; Turn on Auto-Run under the File menu
; Emulator stores its config in the registry and the rest in C:\Users\%USER%\AppData\Roaming\Nintendulator
; In the registry @ HKEY_USERS\S-1-5-21-440413192-1003725550-97281542-1001\Software\Nintendulator
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

7z(romPath, romName, romExtension, 7zExtractPath)

If romExtension in .zip,.7z,.rar
	ScriptError(MEmu . " does not support compressed roms. Please enable 7z support in HLHQ to use this module/emu.")

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath, "Hide")

WinWait("ahk_class NINTENDULATOR")
WinWaitActive("ahk_class NINTENDULATOR")

If Fullscreen = true
	Send !{ENTER} ; go fullscreen

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


HaltEmu:
	disableSuspendEmu = true
	Send, !{Enter}
	Sleep, 200
	Send, {F3}
	Sleep, 200
Return
RestoreEmu:
	WinActivate, ahk_id  %emulatorID%
	Send, !{Enter}
	Send, {F2}
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class NINTENDULATOR")
Return
