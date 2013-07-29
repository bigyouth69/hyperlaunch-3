MEmu = AAE
MEmuV = v12/13/08
MURL = http://pages.suddenlink.net/aae/
MAuthor = djvj
MVersion = 2.0
MCRC = B4F2E1C5
iCRC = CF058B02
MID = 635038268873928953
MSystem = "AAE"
;----------------------------------------------------------------------------
; Notes:
; To apply the updates, first extract the aae092808.zip to its own folder. Then extract aaeu1.zip (10/26/08 build) on top of it overwriting existing files. Do this again for aaeu2.zip (12/13/08 build)
; 12/13/08 release crashes on launch if you have joysticks plugged in or virtual joystick drivers like VJoy installed. If you cannot change this, use AAE from 10/26/08.
; Open your aae.log if it crashes and if it's filled with joystick control info, you need to unplug one joystick at a time until it stops happening.
; Make sure to set your rompath in the aae.ini. If mame_rom_path has a # before it, remove it.
; To set fullscreen, set the variable below to true
; You can also start the emu and press TAB to set options.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
bezelMode := IniReadCheck(settingsFile, "Settings", "BezelMode","Layout",,1)	; "Layout" or "FixResMode"
Fullscreen := IniReadCheck(settingsFile, "settings", "Fullscreen","true",,1)

aaeINI := CheckFile(emuPath . "\aae.ini")
IniRead, currentFullScreen, %aaeINI%, main, windowed

;Enabling Bezel components 
If bezelEnabled = true
{	If bezelMode = FixResMode
	{	IniWrite, 0, %aaeINI%, main, bezel
		IniWrite, 0, %aaeINI%, main, artwork
		IniWrite, 0, %aaeINI%, main, overlay
		BezelStart("FixResMode")
	} Else {
		IniWrite, 1, %aaeINI%, main, bezel
		IniWrite, 1, %aaeINI%, main, artwork
		IniWrite, 1, %aaeINI%, main, overlay
	}
} Else {
	IniWrite, 0, %aaeINI%, main, bezel
	IniWrite, 0, %aaeINI%, main, artwork
	IniWrite, 0, %aaeINI%, main, overlay
}

; Setting Fullscreen setting in ini if it doesn't match what user wants above
If ( Fullscreen != "true" And currentFullScreen = 0 )
	IniWrite, 1, %aaeINI%, main, windowed
Else If ( Fullscreen = "true" And currentFullScreen = 1 )
	IniWrite, 0, %aaeINI%, main, windowed


7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable . A_Space . romName,emuPath)

WinWait("ahk_class AllegroWindow")
WinWaitActive("ahk_class AllegroWindow")

BezelDraw()
FadeInExit()
Process("WaitClose",executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("ahk_class AllegroWindow")
Return
