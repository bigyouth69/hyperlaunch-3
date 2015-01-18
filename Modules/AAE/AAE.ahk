MEmu = AAE
MEmuV = v12/13/08
MURL = http://pages.suddenlink.net/aae/
MAuthor = djvj
MVersion = 2.0.3
MCRC = DF9EEF89
iCRC = 3EAF94CD
MID = 635038268873928953
MSystem = "AAE"
;----------------------------------------------------------------------------
; Notes:
; To apply the updates, first extract the aae092808.zip to its own folder. Then extract aaeu1.zip (10/26/08 build) on top of it overwriting existing files. Do this again for aaeu2.zip (12/13/08 build)
; 12/13/08 release crashes on launch if you have joysticks plugged in or virtual joystick drivers like VJoy installed. If you cannot change this, use AAE from 10/26/08.
; Open your aae.log if it crashes and if it's filled with joystick control info, you need to unplug one joystick at a time until it stops happening.
; In the aae.ini, If mame_rom_path has a # before it, remove it.
; To set fullscreen, set the variable below to true
; You can also start the emu and press TAB to set options.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "settings", "Fullscreen","true",,1)	; true (fake full screen), false (Windowed mode) and Fullscreen (normal fullscreen. Do not work with HyperPause.)  
bezelMode := IniReadCheck(settingsFile, "Settings" . "|" . romName, "BezelMode","Layout",,1)	; "Layout" or "FixResMode"
Artwork_Crop := IniReadCheck(settingsFile, "Settings" . "|" . romName, "Artwork_Crop", "true",,1)
Use_Artwork := IniReadCheck(settingsFile, "Settings" . "|" . romName, "Use_Artwork", "true",,1)
Use_Overlays := IniReadCheck(settingsFile, "Settings" . "|" . romName, "Use_Overlays", "true",,1)

aaeINI := CheckFile(emuPath . "\aae.ini")

; Enabling Bezel components
If bezelEnabled = true
{	If bezelMode = FixResMode
	{	IniWrite, 0, %aaeINI%, main, bezel
		IniWrite, %Use_Artwork%, %aaeINI%, main, artwork
		IniWrite, %Use_Overlays%, %aaeINI%, main, overlay
		IniWrite, %Artwork_Crop%, %aaeINI%, main, artcrop
		BezelStart("FixResMode")
	} Else {
		IniWrite, 1, %aaeINI%, main, bezel
		IniWrite, %Use_Artwork%, %aaeINI%, main, artwork
		IniWrite, %Use_Overlays%, %aaeINI%, main, overlay
		IniWrite, %Artwork_Crop%, %aaeINI%, main, artcrop
	}
} Else {
	IniWrite, 0, %aaeINI%, main, bezel
	IniWrite, %Use_Artwork%, %aaeINI%, main, artwork
	IniWrite, %Use_Overlays%, %aaeINI%, main, overlay
	IniWrite, %Artwork_Crop%, %aaeINI%, main, artcrop
}

; Creating fake fullscreen mode if fullscreen is true because HyperPause is not compatible with AAE fullscreen mode.
IniRead, currentFullScreen, %aaeINI%, main, windowed
If (currentFullScreen = 0) and (Fullscreen != "Fullscreen")
	IniWrite, 1, %aaeINI%, main, windowed
Else If (currentFullScreen = 1) and (Fullscreen = "Fullscreen")
	IniWrite, 0, %aaeINI%, main, windowed
If  (Fullscreen = "true"){
	IniWrite, %A_ScreenWidth%, %aaeINI%, main, screenw 
	IniWrite, %A_ScreenHeight%, %aaeINI%, main, screenh 
} 

7z(romPath, romName, romExtension, 7zExtractPath)

IniWrite, %romPath%, %aaeINI%, main, mame_rom_path	; update AAE's rom path so it's always correct and also works with 7z

Run(executable . A_Space . romName,emuPath)

WinWait("ahk_class AllegroWindow")
WinWaitActive("ahk_class AllegroWindow")

If (Fullscreen = "true"){
	Sleep, 200
	WinSet, Style, -0xC00000, A
}

BezelDraw()
FadeInExit()
Process("WaitClose",executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


RestoreEmu:
	timeout := A_TickCount
	Loop {
		WinClose("ahk_class #32770", "Crap")
		If (!ErrorLevel || timeout < A_TickCount - 3000)
			Break
		Sleep, 50
	}
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class AllegroWindow")
Return
