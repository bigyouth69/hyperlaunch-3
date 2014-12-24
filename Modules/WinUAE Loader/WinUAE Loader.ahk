MEmu = WinUAE Loader
MEmuV = v1.74
MURL = http://headsoft.com.au/index.php?category=winuaeloader
MAuthor = djvj
MVersion = 2.0.1
MCRC = 5CA46EB
iCRC = 4E0EC826
MID = 635038268935640326
MSystem = "Commodore Amiga"
;----------------------------------------------------------------------------
; Notes:
; Requires WinUAE v2.4.0+
; You can configure WinUAE from the built-in GUI or use another loader that makes things a bit simpler
; To configure WinUAE settings using WinUAE Loader v1.72 or later
; Paths->WinUAE Exe->WinUAE Exe should point to your winuae.exe
; Paths->Rom Folders->WHDLoad should point to your roms dir
; Input->Exit Options->Global Exit Key should be 27 (if you use ESC). Check "Force WHDLoad Close" and set "Close Timeout" to 0 for the fastest exit
; Settings->Display Options set Full Screen and all the check boxes
;
; Don't forget to open WinUAE directly and goto Paths and set your System ROMs dir. WinAUE will scan all your roms and enables what it finds
;
; Set emupath to your WinUAELoader dir and the exe to WinUAELoader.exe
; autoResume additions courtesy of: http://www.hyperspin-fe.com/forum/showthread.php?24702-Amiga-Whdloader-module-with-auto-save-load-state
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
resolution := IniReadCheck(settingsFile, "Settings", "Resolution","1024x768",,1)	; Set resolution of WinUAE's window. Depending on Fullscreen value, there are different resolutions supported by WinUAE.
autoResume := IniReadCheck(settingsFile, "Settings", "autoResume","true",,1)		; if true, will automatically save your game's state on exit and reload it on the next launch of the same game.

loaderINI := CheckFile(emuPath . "\Data\WinUAELoader.ini")
IniRead, currentFullScreen, %loaderINI%, Display, Windowed

fullscreenResAr := Object("640x480",0,"720x480",1,"720x576",2,"800x600",3,"1024x768",4,"1152x864",5,"1280x720",6,"1280x756",7,"1280x800",8,"1280x960",9,"1280x1024",10,"1360x768",11,"1366x768",12,"1600x900",13,"1600x1024",14,"1600x1200",15,"1680x1050",16,"1900x1080",17,"1920x1200",18)
windowedResAr := Object("320x256",0,"640x512",1,"720x576",2)

BezelStart()

If fullscreen = true	; get value to set in WinUAELoader's ini
	resolution := fullscreenResAr[resolution]
Else
	resolution := windowedResAr[resolution]

If (fullscreen != "true" && resolution >= 3) || !resolution	; if user switched from fullscreen to windowed and did not set a valid windowed resolution, or the array lookup failed, we will default to 720x576 because the default 1024x768 res is not valid in windowed mode
	resolution := 2

; Setting Fullscreen setting in ini if it doesn't match what user wants above. Because the key is "Windowed" set values are opposite normal emus
If ( Fullscreen != "true" And currentFullScreen = "false" ) {	; want windowed mode
	IniWrite, True, %loaderINI%, Display, Windowed
	IniWrite, %resolution%, %loaderINI%, Display, Screen
} Else If ( Fullscreen = "true" And currentFullScreen = "true" ) {	; want fullscreen mode
	IniWrite, False, %loaderINI%, Display, Windowed
	IniWrite, %resolution%, %loaderINI%, Display, Screen
}

winUAELoaderClass := If fullscreen = "true" ? "AmigaPowah" : "PCsuxRox"

hideEmuObj := Object("Restore a WinUAE snapshot file",0,"ahk_class " . winUAELoaderClass,1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

stateName := emuPath . "\states\" . romName . ".uss"

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait
Run(executable  . " -mode whdload -game """ . romPath . "\" . romName . romExtension . """", emuPath)

If (FileExist(stateName) and autoResume="true") {
	clipboard = %stateName%
	WinWait("ahk_class AmigaPowah")
	Send {F7}	; open load state window
	WinWait("Restore a WinUAE snapshot file")
	Send ^v
	Send {Enter}
}

WinWait("ahk_class " . winUAELoaderClass)	; window class name changes if in windowed or fullscreen
WinWaitActive("ahk_class " . winUAELoaderClass)

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()

GroupAdd,DIE,DIEmWin
GroupClose, DIE, A

ExitModule()


CloseProcess:
	If (FileExist(stateName) and autoResume="true")
		Send {F5}	; open save state window
	FadeOutStart()
	If (FileExist(stateName) and autoResume="true") {
		clipboard = %stateName%	; just in case something happened to clipboard in between start of module to now
		WinWait("Save a WinUAE snapshot file")
		Send ^v
		Send {Enter}
		Sleep, 50	; always give time for a file operation to occur before closing an app
	}
	WinClose("ahk_class " . winUAELoaderClass)
Return
