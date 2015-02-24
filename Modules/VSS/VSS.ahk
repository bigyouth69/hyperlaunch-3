MEmu = VSS
MEmuV = v0.82
MURL = http://atarihq.com/danb/a5200.shtml
MAuthor = brolly
MVersion = 2.0.0
MCRC = E27B5F0D
iCRC = 7C4BE9E2
MID = 635038268888731281
MSystem = "Atari 5200"
;----------------------------------------------------------------------------
; Notes:
; VSS only works on DOS, so you must use DOSBox to run it. On the DOSBox folder create a folder called VSS and copy all VSS 
; emulator files into it.
; Create a dosbox configuration file called vss.conf on the dosbox root folder. At the bottom, create a section called 
; autoexec and add the following lines to it:
; [autoexec]
; @mount c "PATH_TO_YOUR_VSS_FOLDER"
; @mount d .
; @c:
; @vss.bat
;
; Replace PATH_TO_YOUR_VSS_FOLDER by the path to your VSS folder (the one that contains 5200.exe) like C:\Emulators\VSS
; This will mount your roms folder as drive D: in DOSBox and it's all you need to run the games.
; You can also use DFend instead, but it will require you to create one single configuration file per game which isn't 
; necessary with this script that only uses DOSBox.
;
; Your Emulator path should be pointing to DOSBox.exe and not to 5200.exe!
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
scaler := IniReadCheck(settingsFile, "Settings", "Scaler", "none",,1)
aspect := IniReadCheck(settingsFile, "Settings", "Aspect", "false",,1)
output := IniReadCheck(settingsFile, "Settings", "Output", "surface",,1)
fullscreenResolution := IniReadCheck(settingsFile, "Settings|" . romName, "Fullscreen_Resolution", "original",,1)
windowedResolution := IniReadCheck(settingsFile, "Settings|" . romName, "Windowed_Resolution", "original",,1)

confFile := CheckFile(emuPath . "\vss.conf")

BezelStart("fixResMode")

params := "-conf " . confFile . " -scaler " . scaler . " -noconsole -exit"

If (fullscreen = "true")
	fullscreen := " -fullscreen"
Else {
	fullscreen :=
	IniRead, currentfullscreen, %confFile%, sdl, fullscreen
	If (currentfullscreen != fullscreen)
		IniWrite, false, %confFile%, sdl, fullscreen
}

;Edit DOSBox conf file if necessary
IniRead, currentaspect, %confFile%, render, aspect
IniRead, currentoutput, %confFile%, sdl, output
IniRead, currentfsresolution, %confFile%, sdl, fullresolution
IniRead, currentwindresolution, %confFile%, sdl, windowresolution

If (currentaspect != aspect)
	IniWrite, %aspect%, %confFile%, render, aspect
If (currentoutput != output)
	IniWrite, %output%, %confFile%, sdl, output
If (currentfsresolution != fullscreenResolution)
	IniWrite, %fullscreenResolution%, %confFile%, sdl, fullresolution
If (currentwindresolution != windowedResolution)
	IniWrite, %windowedResolution%, %confFile%, sdl, windowresolution

7z(romPath, romName, romExtension, 7zExtractDir)

;VSS is a DOS emulator so paths must be in 8.3 format
dosrompath := GetShortPath(rompath . "\" . romname . romextension)
SplitPath, dosrompath, dosromname

;Let's create a dynamic batch file that will be run on DOSBox startup
FileDelete, %emuPath%\VSS\VSS.bat
FileAppend, 5200.exe "D:\%dosromname%"`n, %emuPath%\VSS\VSS.bat

Run("""" . emuPath . "\" . executable . """ """ . emuPath . "\VSS"" " . params, romPath)

WinWait("DOSBox ahk_class SDL_app")
WinWaitActive("DOSBox ahk_class SDL_app")

Sleep 2500 ;Wait for the press Enter message to appear, increase this value if game isn't starting
Send {Enter}
Sleep, 100 ;To allow the command to go through and window to get resized on game load

BezelDraw()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("DOSBox ahk_class SDL_app")
Return

GetShortPath(path)
{
	Static ShortPath
	VarSetCapacity(ShortPath,260)
	DllCall("GetShortPathName","Str",Path,"Str",ShortPath,"Uint",260)
	Return ShortPath
}
