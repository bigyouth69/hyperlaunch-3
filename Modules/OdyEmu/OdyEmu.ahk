MEmu = OdyEmu
MEmuV = v1.0
MURL = http://www.pong-story.com/odyemu.htm
MAuthor = brolly
MVersion = 2.0
MCRC = 1393BEFD
iCRC = 990A9468
mId = 635532592271397990
MSystem = "Magnavox Odyssey"
;----------------------------------------------------------------------------
; Notes:
; OdyEmu is a MS-DOS emulator, so you must use DOSBox to run it.
; On the DOSBox folder create a folder called OdyEmu and copy all OdyEmu files into it.
; Create a dosbox configuration file called odyemu.conf on the dosbox root folder (You can simply copy the default dosbox.conf file).
; For the overlay to work the SDL output of DOSBox must be set to direct3d. The module will do this for you. This isn't supported by 
; vanilla DOSBox so you must use the Taewoong's build instead:
; http://ykhwong.x-y.net/
;
; This module was tested with Taewoong's DOSBox SVN Daum build 2014.01.17
; 
; Emulator Path should point to the DOSBox executable. Set the path to the overlay tool executable in the module settings file
;
; OdyEmu won't work (black screen) if you set keyboardlayout to auto in DOSBox, it needs to be set to default. Module will also enforce this
;
; This requires the Overlay tool by xttx so make sure you set the correct path to it in the module settings, you can find that tool here:
; http://www.hyperspin-fe.com/forum/showthread.php?11994/page10
; Version used for this module was u5
;
; Put all your overlay files in an Overlays sub-folder inside the Overlay tool folder. Overlays must have a .png extension and need to be named 
; after the names used in your XML file.
;
; OdyEmy has built-in support for overlay files, but it only supports 320 x 200 x 8 bit colour BMP files which look terrible, thus the need 
; for an external overlay tool. Make sure you remove the built-in overlay support for Tennis, to do this simply open the tennis.mo1 file in your 
; text editor and delete the @TENNIS.BO1 line.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
ShowOverlay := IniReadCheck(settingsFile, "Settings", "ShowOverlay","true",,1)
Aspect := IniReadCheck(settingsFile, "Settings", "Aspect","false",,1)
Scaler := IniReadCheck(settingsFile, "Settings", "Scaler","normal2x",,1)
AutoFit := IniReadCheck(settingsFile, "Settings", "AutoFit","true",,1)
OverlayToolExe := IniReadCheck(settingsFile, "Settings", "OverlayToolExe","",,1)
OverlayAlphaChannel := IniReadCheck(settingsFile, "Settings", "OverlayAlphaChannel","45",,1)
ConfigureKeys := IniReadCheck(settingsFile, "Settings", "ConfigureKeys","",,"false")
ShowScoreBoard := IniReadCheck(settingsFile, romname, "ShowScoreBoard","",,"false")

dosboxcfgFile := emuPath . "\odyemu.conf"
CheckFile(dosboxcfgFile)
CheckFile(emuPath . "\OdyEmu\OdyEmu.exe")

;force direct3d mode and keyboardlayout
IniWrite, direct3d, %dosboxcfgFile%, sdl, output
IniWrite, default, %dosboxcfgFile%, dos, keyboardlayout

;update aspect and other options
IniWrite, %Aspect%, %dosboxcfgFile%, render, aspect
IniWrite, %AutoFit%, %dosboxcfgFile%, render, autofit

;BezelStart("fixResMode")
BezelStart()

7z(romPath, romName, romExtension, 7zExtractDir)

IniDelete, %dosboxcfgFile%, autoexec

;Add autoexec section to odyemu.conf
FileAppend, [autoexec]`n, %dosboxcfgFile%
FileAppend, @mount c "%emuPath%\OdyEmu"`n, %dosboxcfgFile%
FileAppend, @mount d "%rompath%"`n, %dosboxcfgFile%
FileAppend, @c:`n, %dosboxcfgFile%
FileAppend, @odyemu.bat`n, %dosboxcfgFile%

;OdyEmu is a DOS emulator so paths used internally must be in 8.3 format
dosrompath := GetShortPath(rompath . "\" . romname . romextension)
SplitPath, dosrompath, dosromname

;Let's create a dynamic batch file that will be run on DOSBox startup
FileDelete, %EmuPath%\OdyEmu\OdyEmu.bat
If (ConfigureKeys = "true")
	FileAppend, setkey.exe`n, %EmuPath%\OdyEmu\OdyEmu.bat
Else
	FileAppend, odyemu.exe D:\%dosromname%`n, %EmuPath%\OdyEmu\OdyEmu.bat

params = -scaler %Scaler% -noconsole -exit
If (Fullscreen = "true" )
{
	params = -fullscreen %params%
}
params = -conf "%dosboxcfgFile%" %params%

Run(executable . " " . params, emuPath)

WinWait("DOSBox ahk_class SDL_app")
WinWaitActive("DOSBox ahk_class SDL_app")

SetTitleMatchMode 2

;We need to wait until the game/emulator is loaded
WinWait("ODYEMU ahk_class SDL_app")
WinWaitActive("ODYEMU ahk_class SDL_app")

If (ShowOverlay = "true" && If ConfigureKeys != "true")
{
	OverlayToolExe:=GetFullName(OverlayToolExe)
	CheckFile(OverlayToolExe)
	SplitPath,OverlayToolExe,OverlayToolName,OverlayToolPath,OverlayToolExt

	overlayFile = %OverlayToolPath%\Overlays\%romName%.png
	If (FileExist(overlayFile))
	{
		;Start the Overlay
		overlayOpts := "-nogui -overlay=""" . overlayFile . """ -alpha=" . OverlayAlphaChannel
		If (ShowScoreBoard = "true")
			overlayOpts := overlayOpts . " -showscore"
		Run(OverlayToolName . " " . overlayOpts, OverlayToolPath)
		WinWait("Test DirectX overlay")
		WinWaitActive("Test DirectX overlay")
	}
	Else
		Log("Overlay File couldn't be found at " . overlayFile)

	WinActivate, DOSBox ahk_class SDL_app ;DOSBox window will no longer be active after displaying the overlay
}

BezelDraw()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


GetShortPath(path)
{
	static ShortPath
	VarSetCapacity(ShortPath,260)
	DllCall("GetShortPathName","Str",Path,"Str",ShortPath,"Uint",260)
	return ShortPath
}

CloseProcess:
	FadeOutStart()
	WinClose("DOSBox ahk_class SDL_app")
	WinClose("Test DirectX overlay")
Return
