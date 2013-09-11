MEmu = JPcsp
MEmuV =  r3146
MURL = http://jpcsp.org/
MAuthor = djvj
MVersion = 2.0
MCRC = 12271185
iCRC = E0EFE80F
MID = 635038268900731264
MSystem = "Sony PSP"
;----------------------------------------------------------------------------
; Notes:
; Make sure you install the latest 32bit or 64bit Java JRE from http://java.sun.com, depending on what version emu you want to use.
; Open the emu manually and Press F12 to open the Options window
; Under File, set your UMD Path folder to your games
; Under Region, set your language to English, or whatever you prefer.
; Under Display, set your resolution to NATIVE and check the box to start fullscreen (custom resolutions cause a black screen at boot in fullscreen mode, only native does not)
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()
SetRegView, 64	; required to read 64-bit parts of the registry

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
emuBit := IniReadCheck(settingsFile, "Settings", "emuBit","32",,1)									; Which version of java do you want to run?
useRAM := IniReadCheck(settingsFile, "Settings", "useRAM","1024",,1)							; How much ram do you want to give the PSP to use? If you have 4GB, give it 1024
; emuResolution = 1920x1200	; **NOT WORKING YET causes a blackscreen at boot** The fullscreen resolution you want to use. It must look like widthxheight
bezelTopOffset := IniReadCheck(settingsFile, "Settings", "bezelTopOffset :","46",,1)

BezelStart()

SetKeyDelay 50
jpcspFile := CheckFile(emuPath . "\Settings.properties")
FileRead, jpcspSettings, %jpcspFile%

; Setting Fullscreen setting in cfg if it doesn't match what user wants above
currentFullScreen := (InStr(jpcspSettings, "gui.fullscreen=1") ? ("true") : ("false"))
If ( Fullscreen != "true" And currentFullScreen = "true" ) {
	StringReplace, jpcspSettings, jpcspSettings, gui.fullscreen=1, gui.fullscreen=0
	SaveSettings = 1
} Else If ( Fullscreen = "true" And currentFullScreen = "false" ) {
	StringReplace, jpcspSettings, jpcspSettings, gui.fullscreen=0, gui.fullscreen=1
	SaveSettings = 1
}

; Old method which causes a black screen at boot. resolution must be kept at native for now
; currentFullScreen := (InStr(jpcspSettings, "graphics.resolution=" . emuResolution) ? ("true") : ("false"))
; If ( Fullscreen != "true" And currentFullScreen = "true" ) {
		; StringReplace, jpcspSettings, jpcspSettings, graphics.resolution=%emuResolution%, graphics.resolution=Native
		; SaveSettings = 1
	; } Else If ( Fullscreen = "true" And currentFullScreen = "false" ) {
		; StringReplace, jpcspSettings, jpcspSettings, graphics.resolution=Native, graphics.resolution=%emuResolution%
		; SaveSettings = 1
	; }


; Forcing Native res beause custom resolutions cause a black screen in fullscreen mode. Deleting the key forces JPcsp to use Native
emuResolution := (InStr(jpcspSettings, "emu.graphics.resolution=Native") ? ("true") : ("false"))
If emuResolution = false
{	StringReplace, jpcspSettings, jpcspSettings, emu.graphics.resolution=, 
	SaveSettings = 1
}

; Checking to see if the UMD Browser is turned on. We need to shut this off so we can interact with a normal file browser window
umdBrowser := (InStr(jpcspSettings, "umdbrowser=1") ? ("true") : ("false"))
If ( umdBrowser = "true" ) {
	StringReplace, jpcspSettings, jpcspSettings, umdbrowser=1, umdbrowser=0
	SaveSettings = 1
}

; If we had to make any changes, save the jpcspFile to disk
If SaveSettings
	SaveFile(jpcspSettings, jpcspFile)

; This replaces the batch files the emu comes with and does it all in ahk instead
winVer := (InStr(ProgramFiles, "(x86)") ? ("64") : ("32")) ; check if windows is 32 or 64 bit
javaVer := FileExist(A_WinDir . "\SysWOW64") ; check if java is 32 or 64 bit
If ( emuBit = "64" && winVer = "32" )
	ScriptError("Unable to run a 64bit Java on a 32bit Windows. Install a 64bit version of Windows first or use a 32bit Java.")
If ( emuBit = "64" && !javaVer )
	ScriptError("Java 64bit is not installed.")
javaKey := ("SOFTWARE\" (If javaVer ? ("") : ("Wow6432Node\")) "JavaSoft\Java Runtime Environment") ; if true, we should have java 64bit installed, else 32bit, set appropriate reg location
RegRead, javaVersion, HKEY_LOCAL_MACHINE, %javaKey%, CurrentVersion ; read java's current version #
RegRead, javaDir, HKEY_LOCAL_MACHINE, %javaKey%\%javaVersion%, JavaHome ; read java's install location
javaExe = %javaDir%\bin\javaw.exe
CheckFile(javaExe,"Could not find javaw.exe. Try reinstalling the java version you want to use. Please make sure it exists here:`n" . javaExe)

7z(romPath, romName, romExtension, 7zExtractPath)

If ( emuBit = "32" )
	errorLvl := Run(javaExe . " -Xmx" . useRAM . "m -XX:MaxPermSize=128m -XX:ReservedCodeCacheSize=64m -Djava.library.path=lib/windows-x86 -jar bin/jpcsp.jar -u """ . romPath . "\" . romName . romExtension . """ -r", emupath, "UseErrorLevel")
Else if ( emuBit = "64" )
	errorLvl := Run(javaExe . " -Xmx" . useRAM . "m -Xss2m -XX:MaxPermSize=128m -XX:ReservedCodeCacheSize=64m -Djava.library.path=lib/windows-amd64 -jar bin/jpcsp.jar -u """ . romPath . "\" . romName . romExtension . """ -r", emupath, "UseErrorLevel")
Else
	ScriptError("Please set emuBit to either 32 or 64. This reflects the version of the emulator you want to run")

If errorLvl != 0
	ScriptError("Exe Error - Error launching emulator`, closing module.")

WinActivate, Jpcsp ahk_class SunAwtFrame
WinWaitActive("Jpcsp ahk_class SunAwtFrame")

BezelDraw()
FadeInExit()
Process("WaitClose", "javaw.exe")
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


SaveFile(text,file) {
	FileDelete, %file%
	FileAppend, %text%, %file%
}

CloseProcess:
	FadeOutStart()
	WinClose("Jpcsp ahk_class SunAwtFrame") ; sending command to the GUI window to properly close the entire emu
Return
