MEmu = JavaGX4000
MEmuV = 2013-08-25 Alpha
MURL = http://sourceforge.net/projects/javagx4000/
MAuthor = Knewlife,brolly
MVersion = 1.0
MCRC = 6A98B2A2
iCRC = EBF2157A
mId = 635403946231649684
MSystem = "Amstrad GX4000"
;----------------------------------------------------------------------------
; Notes:
; Make sure you have Java installed on your machine (JRE):
; http://www.oracle.com/technetwork/java/javase/downloads/index.html
;
; This is a Java based emulator so executable isn't needed you can point it to anything, like
; for instance JavaGX4000.jar
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()
BezelStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "settings", "Fullscreen", "true",,1)
DetectJava := IniReadCheck(settingsFile, "settings", "DetectJava", "true",,1)
TrojanEnabled := IniReadCheck(settingsFile, "settings|" . romName, "TrojanEnabled", "false",,1)
Delay := IniReadCheck(settingsFile, "settings", "Delay", "50",,1)

hideEmuObj := Object("ahk_class SunAwtFrame",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

If (DetectJava = "true")
	javaExe := FindJava()
Else
	javaExe := "javaw.exe"

HideEmuStart()
Run(javaExe . " -jar JavaGX4000.jar", emuPath,, EmuPID)

WinWait("ahk_class SunAwtFrame")
BezelDraw()
WinWaitActive("ahk_class SunAwtFrame")

Sleep, 3500	; Wait for game to load
If (TrojanEnabled = "true")	; Enable Phase
	Send, {ScrollLock}

Sleep, 200
Send, {F2}		; Load Media
OpenROM("Load file",romPath . "\" . romName . romExtension)

If (Fullscreen = "true")
	Send, !{Enter}

Sleep, % Delay
HideEmuEnd()
FadeInExit()
Process("WaitClose", EmuPID)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	Process("Close", EmuPID)
Return

BezelLabel:
	disableHideTitleBar := false
	disableHideToggleMenu := false
	disableHideBorder := true
	disableWinMove := false
Return
