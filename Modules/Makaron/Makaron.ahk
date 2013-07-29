MEmu = Makaron
MEmuV =  T12-5
MURL = http://dknute.livejournal.com/tag/makaron
MAuthor = djvj
MVersion = 2.0.1
MCRC = 1E7C1142
iCRC = 8A6539FE
MID = 635038268902322593
MSystem = "Sega Dreamcast","Sega Naomi"
;----------------------------------------------------------------------------
; Notes:
; Required - control and nvram files can be found in my user dir on the FTP at /Upload Here/djvj/Sega Naomi\Emulators.
; Required - moduleName ini: in the same folder as this module
; GDI images must match mame zip names and be extracted and have a .dat extension
; Rom_Extensions should be dat|zip
; To set Makaron fullscreen, set fullscreen to true in the moduleName.ini 
; Set your desired res to MakaronWidth and MakaronHeight
; For HyperPause to work, you cannot have fullscreen enabled, keep it false, but make sure your makaron width/height is set to your desktop resolution.
; Set Hide_Taskbar to true in this system's HyperLaunch.ini (it hides few the top and bottom rows of pixels from showing through)
; Edit all the emuPath\Controls\XXXX_JVS.ini files with your specific controls (very tedious but required to fully appreciate the games and this script)
; Sometimes you will get a direct3d error when exiting demul. It will close after a second, but there has been no way to 100% prevent this from happening so far as I can tell.
; If you use Fade_Out, the module will force close Makaron because you cannot send ALT+F4 to Makaron if another GUI is covering it. Otherwise Makaron should close cleanly when Fade_Out is disabled. I suggest keeping Fade_Out disabled if you use this emu.
;
; NVRAM  and JVS files:
; For each game you want makaron to run, you need to make sure the game boots using proper BIOS settings from the test mode.
; Once you get it working, either by manually figuring out the correct combo yourself, or using my files included with this module, copy the NAOMI_NVRAM.bin to an NVRAM subfolder in your Emu_Path and prefix the name to match your rom.
; Do the same for the NAOMI_JVS.bin, but place it in a JVS subfolder
;
; Controls:
; Each game can have it's own custom controls by setting your controls in the emulator, then exiting and copying the JVS.ini to a Controls subfolder in your Emu_Path. Prefix the filename with the type of control you want to call it.
; Alternately, you can use the controls I already created, but edit each ini to match yours.
; This is the preferred method instead of storing the controls in the ini because Makaron uses backwards ini keys in JVS.ini. This method also allows you to use your x360 controller and have keys set for that in the JVS files too.
;
; How to run vertical games on a standard monitor:
; There are 2 methods supported by this module to rotate your desktop. One application is called display.exe, the other is irotate.exe. 
; They both do the same thing. But one may work on your pc and the other may not, so pick the one that does.
; Place either display.exe or irotate.exe in your Module Extensions folder. Edit the VerticalMethod in the moduleName ini to which you want to use
; Make sure a section exists in the ini for your romName and add a key Vertical and set it to true
;
; Sega Dreamcast
; Extract all your DC bios bins into the ROM subdir of your emu
; Open the Makaron.ini and set your resolution and remove the # in front of the lines you want enabled, including fullscreen.
; This script supports the following DC images: GDI, CDI
; vJoy is required for joystick input for Makaron DC games: http://headsoft.com.au/index.php?category=vjoy
;----------------------------------------------------------------------------
StartModule()

 ; check for all files needed by this module
settingsFile := modulePath . "\" . moduleName . ".ini"
If systemName contains Naomi	; Sega Naomi
{
	naomiFile := CheckFile(emuPath . "\NAOMI.ini")
	jvsFile := CheckFile(emuPath . "\JVS.ini")
	controlsPath := emuPath . "\Controls"	; the folder that holds the alternate control JVS files
	makNVRAM := CheckFile(emuPath . "\NVRAM\" . romName . "_NAOMI_NVRAM.bin")
	makJVS := CheckFile(emuPath . "\JVS\" . romName . "_NAOMI_JVS.bin")
}Else If systemName contains dreamcast,dc	; Sega Dreamcast
{
	makaronFile := CheckFile(emuPath . "\Makaron.ini")
	mapleFile := CheckFile(emuPath . "\Maple.ini")
	padFile := CheckFile(emuPath . "\MakaronPAD.ini")
}

; Read all the keys from the moduleName ini. Format is:
; Section, Key, Default Value, unique var
iniLookup =
( ltrim c
	Settings, Fullscreen, true
	Settings, LastControlUsed, standard
	Settings, MakaronWidth
	Settings, MakaronHeight
	Settings, VerticalMakaronWidth
	Settings, VerticalMakaronHeight
	Settings, VerticalMethod
	%romName%, Vertical
	%romName%, MakaronBios
	%romName%, Controls, Standard
	%romName%, WinCE, false
	%romName%, Cable, 0
	%romName%, Keyboard, false
	%romName%, DisablePlayerTwo, false
)
Loop, Parse, iniLookup, `n
{
	StringSplit, split, A_LoopField, `,, %A_Space%%A_Tab%
	If split4
		%split4% := IniReadCheck(settingsFile, split1, split2,split3,,1)
	Else
		%split2% := IniReadCheck(settingsFile, split1, split2,split3,,1)
	; need to empty the vars for the next loop otherwise they will still have values from the previous loop
	split3:=
	split4:=
}

If systemName contains Naomi	; Sega Naomi script
{
	If vertical = true
	{
		verticalExe := CheckFile(moduleExtensionsPath . "\" . VerticalMethod . ".exe")	; check if the exe to our vertical method exists and store it for later use
		IfExist, %moduleExtensionsPath%\LoadingScreen.exe
			Run, %moduleExtensionsPath%\LoadingScreen.exe
		Else
			FadeInStart()
	}Else
			FadeInStart()

	; This section writes your custom keys to the JVS.ini. Naomi games had many control panel layouts. The only way we can accomodate for these differing controls, is to keep track of them all and write them to the ini at the launch of each game.
	; First we check if the last controls used are the same as the game we want to play, so we don't waste time updating the ini if it is not necessary. For example playing 2 sfstyle type games in a row, we wouldn't need to write to the ini.

	If (MakaronBios != "" and MakaronBios != "ERROR")
		IniWrite, %MakaronBios%, %naomiFile%, Settings, region	; Setting MakaronBios user has set in moduleName ini
	Else
		IniWrite, 0, %naomiFile%, Settings, region	; Turns Makaron's bios back to 0 for Japanese/import

	If ( lastControlUsed != controls ) {	; If the last used control setting does not equal the new one, copy the new JVS file over the one makaron loads in the emu root folder
		newjvsFile := CheckFile(controlsPath . "\" . controls . "_JVS.ini")	; check if custom controls file exists first
		FileCopy, %newjvsFile%, %jvsFile%, 1
		IniWrite, %controls%, %settingsFile%, Settings, LastControlUsed
	}

	; Custom Gui, prevents emulator windows from being seen while loading
	Gui, 1: +AlwaysOnTop -Caption +ToolWindow
	Gui, 1: Color, Black
	Gui, 1: Show, x0 y0 h%A_ScreenHeight% w%A_ScreenWidth%
	Sleep, 500

	; Determine if we are changing the desktop's orientation or setting fullscreen in makaron.
	IniRead, curFullscreen, %naomiFile%, Settings, fullscreen
	If vertical = true	; **delete this conditional when makaron supports vertical rotation**
	{
		If curFullscreen = 1
			IniWrite, 0, %naomiFile%, Settings, fullscreen	; we need to turn fullscreen off otherwise windows sets itself back to 0�
		IniWrite, %verticalMakaronWidth%x%verticalMakaronHeight%, %naomiFile%, Settings, video_mode	; writing our desired res for vertical makaron games
		;WinMinimizeAll ;If we don't minimize, parts of HS still show on our screen

		If verticalMethod = irotate
			Run(verticalExe . " /rotate=90 /exit", moduleExtensionsPath) ; another option to rotate screen
		Else If  verticalMethod = display
			Run(verticalExe . " /rotate:90", moduleExtensionsPath) ; Switching to 90�
		Else
			ScriptError(verticalMethod . " is not a compatible VerticalMethod. Please choose either irotate or display.")
		Sleep, 200

		; Custom Gui, because upon rotation, coordinates get messed up and only part of the desktop is hidden. Using 2 Guis because some pcs don't work correctly with one and others work only with the second one. Gui 2 makes the little makaron window never show up.
		Gui, 2: -Caption +ToolWindow
		Gui, 2: Color, Black
		Gui, 2: Show, x0 y0 W%A_ScreenHeight% H%A_ScreenWidth%
		Gui, 3: +AlwaysOnTop -Caption +ToolWindow
		Gui, 3: Color, Black
		Gui, 3: Show, x0 y0 h%A_ScreenHeight% w%A_ScreenWidth%
		Sleep, 500
	} Else If (curFullscreen = "0"  and fullscreen = "true") {
		IniWrite, 1, %naomiFile%, Settings, fullscreen	; turning fullscreen on if it was previously set to off
		IniWrite, %makaronWidth%x%makaronHeight%, %naomiFile%, Settings, video_mode	; writing our desired res for standard orientation makaron games
	} Else If (curFullscreen = "1"  and fullscreen != "true") {
		IniWrite, 0, %naomiFile%, Settings, fullscreen	; turning fullscreen on if it was previously set to off
		IniWrite, %makaronWidth%x%makaronHeight%, %naomiFile%, Settings, video_mode	; writing our desired res for standard orientation makaron games
	}

	; Now lets run our emulator
	FileCopy, %makNVRAM%, %emuPath%\NAOMI_NVRAM.bin, 1	; copy NVRAM file for this romName to the makaron root folder
	FileCopy, %makJVS%, %emuPath%\NAOMI_JVS.bin, 1	; copy JVS file for this romName to the makaron root folder
}
Else If systemName contains dreamcast,dc	; Sega Dreamcast script
{
	FadeInStart()
	7z(romPath, romName, romExtension, 7zExtractPath)

	IniRead, MMU, %makaronFile%, SH4, MMU
	IniRead, makFS, %makaronFile%, Settings, fullscreen
	IniRead, currentCable, %makaronFile%, Settings, cable

	; Turning MMU on/off because WinCE games require this
	If ( MMU != 1 && winCE = "true" )
		IniWrite, 1, %makaronFile%, SH4, MMU
	Else If ( MMU != 0 && winCE = "false" )
		IniWrite, 0, %makaronFile%, SH4, MMU

	 ; Changing cable if it doesn't match current setting
	If ( currentCable != cable )
		IniWrite, %cable%, %makaronFile%, Settings, cable

	 ; Setting fullscreen on or off
	If ( makFS != 1 && Fullscreen = "true" )
		IniWrite, 1, %makaronFile%, Settings, fullscreen
	Else If ( makFS = 1 && Fullscreen != "true" )
		IniWrite, 0, %makaronFile%, Settings, fullscreen
	IniWrite, %makaronWidth%x%makaronHeight%, %makaronFile%, Settings, video_mode	; writing our desired res for standard orientation makaron games

	;Read Maple.ini into memory and plug/unplug the keyboard as necessary
	FileRead, mapleCFG, %mapleFile%

	currentKeyboard := (InStr(mapleCFG, "#Adres0x20 = MakaronKEY.dll") ? ("true") : ("false"))
	If ( keyboard = "true" And currentKeyboard = "true" ) {
		StringReplace, mapleCFG, mapleCFG, #Adres0x20 = MakaronKEY.dll, Adres0x20 = MakaronKEY.dll
		Save = 1
	} Else If ( keyboard = "false" And currentKeyboard = "false" ) {
		StringReplace, mapleCFG, mapleCFG, Adres0x20 = MakaronKEY.dll, #Adres0x20 = MakaronKEY.dll
		Save = 1
	}

	If Save
		SaveFile(mapleCFG,mapleFile)

	;Unplug controller from port 2 if needed
	IniRead, isPortBDisabled, %padFile%, Urzadzenia, PortB, %A_Space%
	isPortBDisabled := isPortBDisabled ? "false" : "true"

	If (isPortBDisabled = "true" && disableplayertwo = "false") {
		IfExist, %emuPath%\MakaronPAD_2P.ini
			FileCopy, %emuPath%\MakaronPAD_2P.ini, %emuPath%\MakaronPAD.ini, 1
	} Else If (isPortBDisabled = "false" && disableplayertwo = "true") {
		IfExist, %emuPath%\MakaronPAD_1P.ini
			FileCopy, %emuPath%\MakaronPAD_1P.ini, %emuPath%\MakaronPAD.ini, 1
	}
}

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath,, "emuPID")
WinWait("ahk_class Makaron")
WinHide, ahk_class Makaron ; stops the little window from flashing in right before game starts
Sleep, 3000 ; need a moment for makaron to launch, increase if yours takes longer and the loading screen is closing too soon
DetectHiddenWindows, Off

Loop { ; looping until makaron is done loading rom
	Sleep, 200
	;ToolTip, In Loop, 10, 10
	If WinExist("ahk_class Makaron")
		Continue
	Else If WinNotExist, ahk_class PVR2
		Continue
	Else
		Break
}
;ToolTip, loop free, 10, 10
WinSet, Style, -0xC00000, ahk_class PVR2	; Removes the titlebar of the game window
WinSet, Style, -0x40000, ahk_class PVR2	; Removes the border of the game window
WinWait("ahk_class PVR2")
WinActivate, ahk_class PVR2
Gui 1: Destroy 
Gui 3: Destroy 

; ** TESTING FLASH INTRO **
Process("Exist", "LoadingScreen.exe")
If ErrorLevel
	Process("Close", "LoadingScreen.exe")

FadeInExit()
Process("WaitClose", executable)

; Switching orientation back to normal
If vertical = true
{
	If verticalMethod = irotate
		Run(verticalExe . " /rotate=0 /exit", A_ScriptDir . "\Modules\" . systemName)	; another option to rotate screen
	Else If  verticalMethod = display
		Run(verticalExe . " /rotate:0", A_ScriptDir . "\Modules\" . systemName) ; Switching back to 0
	;WinMinimizeAllUndo
	Gui 2: Destroy 
}

; **this section will only work If you use alt+f4 to close the emu. It will error out makaron but will backup high scores
;Sleep, 500
;FileCopy, %emuPath%NAOMI_NVRAM.bin, %emuPath%NVRAM\%RomName%_NAOMI_NVRAM.bin, 1
;FileCopy, %emuPath%NAOMI_JVS_EEPROM.bin, %emuPath%JVS\%RomName%_NAOMI_JVS_EEPROM.bin, 1

7zCleanUp()
FadeOutExit()
ExitModule()


SaveFile(text,file) {
	FileDelete, %file%
	FileAppend, %text%, %file%
}

HaltEmu:
	If fullscreen = true
		disableActivateBlackScreen = true
Return

CloseProcess:
	FadeOutStart()
	If fadeOut = true	; cannot send ALT+F4 to a background window (controlsend doesn't work), so we have to force close instead.
		Process("Close", emuPID) ; we have to close this way otherwise Makaron crashes with WinClose
	Else {
		; Send, !{F4} ; May crash demul every so often
		Send, {F8} ; Stops emulation, use this instead to backup highscores in Makaron
		Sleep, 200
		Send, !{F4}
		Sleep, 200
		Process("WaitClose", emuPID, "1")
		If ErrorLevel	; if we timed out after 1 second and NAOMI.exe still did not close, end it's process
			Process("Close", emuPID)
	}
Return
