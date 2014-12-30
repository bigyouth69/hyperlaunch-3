MEmu = WinVICE
MEmuV = v2.4
MURL = http://vice-emu.sourceforge.net/
MAuthor = djvj,wahoobrian,brolly
MVersion = 2.0.4
MCRC = 2C342847
iCRC = DF0B4867
MID = 635038268966170754
MSystem = "Commodore 64","Commodore 16 & Plus4","Commodore VIC-20","Commodore 128"
;----------------------------------------------------------------------------
; Notes:
; Roms must be unzipped.
; You can turn off the exit confirmation box by unchecking Settings->Confirm on exit
; Turn on saving settings by checking Settings->Save settings on exit, this will create the vice.ini file this module needs.
;
; Default Joyport setting for C64 requires that you configure "Keyset A" as the default for JoyPort 1 and "Keyset B" as the 
; default for JoyPort 2.  This allows the module to use the ini settings and set the default joystick to Player 1 at startup
;
; If you want to use the StartTape and StopTape hotkeys make sure you edit the files C64\win_shortcuts.vsc or VIC20\win_shortcuts.vsc 
; (paths relative to the emulator install folder) and assign Alt+F7 as the StartTape shortcut and Alt+F8 as the StopTape shortcut, like this:
; ALT				0x76		IDM_DATASETTE_CONTROL_START		  F7
; ALT				0x77		IDM_DATASETTE_CONTROL_STOP		  F8
;
; WinVICE SDL:
; This module will also work with the SDL version of WinVICE even though it's not recommended to use it with it. If you do bare in mind that 
; some of the features might not work. For hotkeys to work you need to manually set them all in SDL VICE and make sure you save the settings. 
; To map the hotkeys navigate to any menu item (F12 shows the menu) press 'm' and then the key or key combo you want to use for the hotkey for that item.
; Don't forget to save your hotkeys before exiting the emulator before you exi or they will be lost. This is done in Settings management->Save hotkeys.
; You can find more info on the Readme-SDL.txt file that comes with this version of the emulator.
; The module will detect that you are using the SDL version by checking if the sdl-vice.ini file exists in your emulator folder, so make sure you 
; run the emulator once in order to create this file.
;
; WinVICE uses different executables for each machine so make sure you setup your emulators properly:
; x64.exe - Commodore 64
; xplus4.exe - Commodore 16 & Plus/4
; xvic.exe - Commodore VIC-20
; x128.exe - Commodore 128
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

mType := Object("Commodore 64","C64","Commodore 16 & Plus4","PLUS4","Commodore VIC-20","VIC20","Commodore 128", "C128") ;ident should be the section names used in VICE.ini
ident := mType[systemName]	; search object for the systemName identifier

IfExist, % modulePath . "\" . systemName . ".ini"	; use a custom systemName ini If it exists
	settingsFile := modulePath . "\" . systemName . ".ini"
Else
	settingsFile := modulePath . "\" . moduleName . ".ini"

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)				; If true, the module governs If the emulator launches fullscreen or not. Set to false when troubleshooting a module for launching problems.
WarpKey := IniReadCheck(settingsFile, "Settings", "WarpKey","F9",,1)						; toggle warp speed
JoySwapKey := IniReadCheck(settingsFile, "Settings", "JoySwapKey","F10",,1)					; swap joystick port
StartTapeKey := IniReadCheck(settingsFile, "Settings", "StartTapeKey","F7",,1)					; starts tape
StopTapeKey := IniReadCheck(settingsFile, "Settings", "StopTapeKey","F8",,1)					; stops tape

bezelTopOffset := IniReadCheck(settingsFile, "Settings", "bezelTopOffset",16,,1)
bezelBottomOffset := IniReadCheck(settingsFile, "Settings", "bezelBottomOffset",46,,1)
bezelLeftOffset := IniReadCheck(settingsFile, "Settings", "bezelLeftOffset",7,,1)
bezelRightOffset := IniReadCheck(settingsFile, "Settings", "bezelRightOffset",7,,1)

UsePaddles := IniReadCheck(settingsFile, romName, "UsePaddles", "false",,1)
AutostartPrgMode := IniReadCheck(settingsFile, romName, "AutostartPrgMode", "2",,1)
RequiresReset := IniReadCheck(settingsFile, romName, "RequiresReset", "false",,1)
RequiresHardReset := IniReadCheck(settingsFile, romName, "RequiresHardReset", "false",,1)
TrueDriveEmulation := IniReadCheck(settingsFile, romName, "TrueDriveEmulation", "false",,1)
LoadFile := IniReadCheck(settingsFile, romName, "LoadFile", "",,1)
DefaultJoyPort := IniReadCheck(settingsFile, romName, "DefaultJoyPort", "1",,1)
ColumnMode := IniReadCheck(settingsFile, romName, "ColumnMode", "80",,1)

; DiskSwapKey = F11		; swaps disk or tape - Do not need this key anymore with multigame support

7z(romPath, romName, romExtension, 7zExtractPath)

;Detect if SDL VICE is being used
SdlViceIniPath := emuPath . "\sdl-vice.ini"
IfExist, %SdlViceIniPath%
	SdlVice := "true"
Else
	SdlVice := "false"

Log("Module - SDL mode is set to " . SdlVice)

viceINIPath := If SdlVice = "true" ? SdlViceIniPath : (emuPath . "\vice.ini")
viceINIFullscreenKey := "FullscreenEnabled"
If (SdlVice = "true")
{
	If (ident = "C64")
		viceINIFullscreenKey := "VICIIFullscreen"
	If (ident = "PLUS4")
		viceINIFullscreenKey := "TEDFullscreen"
	If (ident = "VIC20")
		viceINIFullscreenKey := "VICFullscreen"
	If (ident = "C128")
		viceINIFullscreenKey := "VICIIFullscreen"
}
viceINI := CheckFile(viceINIPath)

IniRead, currentFullScreen, %viceINI%, %ident%, %viceINIFullscreenKey%
IniRead, currentAutostartPrgMode, %viceINI%, %ident%, AutostartPrgMode
IniRead, currentDriveTrueEmulation, %viceINI%, %ident%, DriveTrueEmulation
IniRead, currentJoyDevice1, %viceINI%, %ident%, JoyDevice1
IniRead, currentJoyDevice2, %viceINI%, %ident%, JoyDevice2

windowTitle := (If SdlVice = "true" ? "VICE ahk_class SDL_app" : "ahk_class VICE")
hideEmuObj := Object("Select cartridge file ahk_class #32770",0,windowTitle,1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later

BezelStart()

; Setting Fullscreen setting in ini If it doesn't match what user wants above
If ( Fullscreen != "true" And currentFullScreen = 1 )
	IniWrite, 0, %viceINI%, %ident%, %viceINIFullscreenKey%
Else If ( Fullscreen = "true" And currentFullScreen = 0 )
	IniWrite, 1, %viceINI%, %ident%, %viceINIFullscreenKey%

If ( currentAutostartPrgMode != AutostartPrgMode )
	IniWrite, %AutostartPrgMode%, %viceINI%, %ident%, AutostartPrgMode

WarpKey := xHotKeyVarEdit(WarpKey,"WarpKey","~","Add")
JoySwapKey := xHotKeyVarEdit(JoySwapKey,"JoySwapKey","~","Add")
StartTapeKey := xHotKeyVarEdit(StartTapeKey,"StartTapeKey","~","Add")
StopTapeKey := xHotKeyVarEdit(StopTapeKey,"StopTapeKey","~","Add")
xHotKeywrapper(WarpKey,"Warp")
xHotKeywrapper(JoySwapKey,"JoySwap")
xHotKeywrapper(StartTapeKey,"StartTape")
xHotKeywrapper(StopTapeKey,"StopTape")

If romName contains (USA),(Canada)
	DefaultVideoMode = NTSC
Else
	DefaultVideoMode = PAL

VideoMode := IniReadCheck(settingsFile, romName, "VideoMode", DefaultVideoMode,,1)

params := (If SdlVice = "true" ? " " : " +confirmexit")

; Setting video mode depending on rom, default NTSC	
If (VideoMode = "NTSC") {
	params := params . " -ntsc"
	;IniWrite, -2, %viceINI%, %ident%, MachineVideoStandard  ;NTSC
} Else {
	params := params . " -pal"
	;IniWrite, -1, %viceINI%, %ident%, MachineVideoStandard  ;PAL
}

;Enable/Disable paddles as needed, leave these checks in-place because mouse CLI and Ini options aren't supported in VICE 1.22 and this way it will also work with it.
IniRead, currentUsePaddles, %viceINI%, %ident%, Mouse
If ( UsePaddles = "true" And currentUsePaddles != 1)
	params := params . " -mouse -mousetype 3"
If ( UsePaddles = "false" And currentUsePaddles = 1)
	params := params . " +mouse"

If (ident = "C64") {
	If romExtension not in .d64,.d71,.d80,.d81,.d82,.g64,.g41,.x64,.t64,.tap,.crt,.prg,.vsf
		ScriptError("Your rom has an extension of " . romExtension . ", only these extensions are supported:`nd64,d71,d80,d81,d82,g64,g41,x64,t64,tap,crt")

	If ( romExtension = ".crt" ) {
		IniWrite, %romPath%\%romName%%romExtension%, %viceINI%, C64, CartridgeFile
		IniWrite, 0, %viceINI%, C64, CartridgeType
	} Else {
		IniWrite, "", %viceINI%, C64, CartridgeFile
		IniWrite, -1, %viceINI%, C64, CartridgeType
	}
	; Setting TrueDriveEmulation setting in ini If it doesn't match what user wants above
	If ( TrueDriveEmulation != "true" And currentDriveTrueEmulation = 1 ) {
		;MsgBox, update ini = 0
		IniWrite, 0, %viceINI%, %ident%, DriveTrueEmulation
		IniWrite, 0, %viceINI%, %ident%, Drive8Type
	}
	Else If ( TrueDriveEmulation = "true" And currentDriveTrueEmulation = 0 ) {
		;MsgBox, update ini = 1
		IniWrite, 1, %viceINI%, %ident%, DriveTrueEmulation
		IniWrite, 1541, %viceINI%, %ident%, Drive8Type
	}
	
	; Setting Default JoyPort to Player 1 If needed
	If ( DefaultJoyPort = "1" And currentJoyDevice1 != 2 ) {
		IniWrite, 2, %viceINI%, %ident%, JoyDevice1
		IniWrite, 3, %viceINI%, %ident%, JoyDevice2
	}
	Else If ( DefaultJoyPort = "2" And currentJoyDevice1 != 3 ) {
		IniWrite, 3, %viceINI%, %ident%, JoyDevice1
		IniWrite, 2, %viceINI%, %ident%, JoyDevice2
	}
	
	HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

	If romExtension in .d64,.d71,.d80,.d81,.d82,.g64,.g41,.x64,.prg,.vsf
		Run(executable . params . " -autostart """ . romPath . "\" . romName . romExtension . ":" . LoadFile . """", emuPath)
	Else If romExtension in .t64,.tap
		Run(executable . params . " """ . romPath . "\" . romName . romExtension . """", emuPath)
	Else If romExtension = .crt
		Run(executable . params . " -cartcrt """ . romPath . "\" . romName . romExtension . """", emuPath)

	If (RequiresReset = "true") 
	{
		WinWaitActive(windowTitle)
		Sleep, 1000 ; increase if command is not appearing in the emu window or some just some letters
		Send !r
	}
}
Else If (ident = "PLUS4") {
	If romExtension not in .prg,.d64,.t64,.tap,.crt,.g64
		ScriptError("Your rom has an extension of " . romExtension . ", only these extensions are supported:`nprg,d64,t64,tap,crt,g64")

	SendCommandDelay := IniReadCheck(settingsFile, "Settings", "SendCommandDelay", "1500",,1)
	Model := IniReadCheck(settingsFile, romName, "Model", "Commodore Plus/4",,1)

	; Setting model
	If (Model = "Commodore Plus/4") { ;Commodore Plus/4
		IniWrite, "3plus1lo", %viceINI%, %ident%, FunctionLowName
		IniWrite, "3plus1hi", %viceINI%, %ident%, FunctionHighName
		IniWrite, 64, %viceINI%, %ident%, RamSize
		IniWrite, 1, %viceINI%, %ident%, Acia1Enable
	} Else {	; Commodore 16
		IniWrite, "", %viceINI%, %ident%, FunctionLowName
		IniWrite, "", %viceINI%, %ident%, FunctionHighName
		IniWrite, 16, %viceINI%, %ident%, RamSize
		IniWrite, 0, %viceINI%, %ident%, Acia1Enable
	}

	Command := IniReadCheck(settingsFile, romName, "Command", "",,1)
	StringLower, Command, Command ;Command MUST be in lower case so let's force it

	HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

	If romExtension in .d64,.g64,.prg
		Run(executable . params . " """ . romPath . "\" . romName . romExtension . """", emuPath)
	Else If romExtension in .t64,.tap
		Run(executable . params . " """ . romPath . "\" . romName . romExtension . """", emuPath)
	Else If (romExtension = .crt)
	{
		If (SdlVice = "true")
		{
			Run(executable . params . " """ . romPath . "\" . romName . romExtension . """", emuPath)
		}
		Else
		{
			;CLI does not seem to work for carts for Plus4, use GUI instead
			;Run(executable . params . " -cartcrt """ . romPath . "\" . romName . romExtension . """", emuPath)
			Run(executable, emuPath)
			WinWait(windowTitle)
			WinWaitActive(windowTitle)

			;Following keystrokes open up dialog for smart-attach cartridge image
			Sleep, 500
			WinMenuSelectItem, %windowTitle%,, File, Attach cartridge image, 1&

			OpenROM("Select cartridge file ahk_class #32770",romPath . "\" . romName . romExtension)
		}
	}

	If (RequiresReset = "true") 
	{
		WinWaitActive(windowTitle)
		Sleep, 1000 ; increase If command is not appearing in the emu window or some just some letters
		Send !r
	}

	If (RequiresHardReset = "true") 
	{
		WinWaitActive(windowTitle)
		Sleep, 1000 ; increase If command is not appearing in the emu window or some just some letters
		Send ^!r
	}
	If %Command% 
	{
		WinWaitActive(windowTitle)
		;Sleep, %SendCommandDelay% ; increase If command is not appearing in the emu window or some just some letters

		If romExtension in .t64,.tap
		{
			;Tape loading time will vary greatly so we can't type this automatically, user must do it using a hotkey
			RunTapeKey := IniReadCheck(settingsFile, romname, "RunTapeKey","Ctrl&F12",,1)						; run tape key
			RunTapeKey := xHotKeyVarEdit(RunTapeKey,"RunTapeKey","~","Add")
			xHotKeywrapper(RunTapeKey,"RunTape")
		} Else
			SendCommand(Command . "{Enter}", SendCommandDelay)
	}
}
Else If (ident = "VIC20") {
	If romExtension not in .prg,.d64,.t64,.tap,.crt
		ScriptError("Your rom has an extension of " . romExtension . ", only these extensions are supported:`nprg,d64,t64,tap,crt")

	SendCommandDelay := IniReadCheck(settingsFile, "Settings", "SendCommandDelay", "1500",,1)

	CartAddress := IniReadCheck(settingsFile, romName, "CartLoadingAddress", "X000",,1)
	MemoryExpansion := IniReadCheck(settingsFile, romName, "MemoryExpansion", "none",,1)
	Command := IniReadCheck(settingsFile, romName, "Command", "",,1)
	RequiresReset := IniReadCheck(settingsFile, romName, "RequiresReset", "false",,1)

	StringLower, Command, Command ;Command MUST be in lower case so let's force it

	If ( romExtension = ".crt" ) {
		;Sleep, 100 ;Without this romtable comes empty (thread related?)
		RomTableCheck()	; make sure romTable is created already so the next line can calculate correctly

		;MultiPart carts can only be run If the MultiGame feature is enabled
		If romName contains (Part 
		{
			If (mgEnabled = "false")
				ScriptError("You cannot run multipart games with MultiGame disabled")
		}

		romCount = % romtable.MaxIndex()

		If (romCount > 1) {
			;multipart carts - need to build custom CLI parameters to invoke multipart cartridges.  Multipart cartridges are loaded in more than one 
			;                  memory address, so we interrogate each part, and determine its loading address, and build the CLI parameters.
			;				   Once all the cartridge parts have been processed, the emulator with the custom CLI parameters are invoked.
			;				
			;                  Using Lunaar Leeper as an example, it has two parts, one loaded in $2000, and one in $A000
			;	               "xvic.exe -cart2 "D:\Games\Commodore VIC-20\Lunar Leeper (USA) (Part 1).crt" -cartA "D:\Games\Commodore VIC-20\Lunar Leeper (USA) (Part 2).crt"			

			multipartCLI = %executable%%params%

			for index, element in romtable {
				currentCart := romtable[A_Index,1]
				SplitPath, currentCart,,,, OutFileName
				currentCartAddress := IniReadCheck(settingsFile, OutFileName, "CartLoadingAddress", "X000",,1)
				
				If (currentCartAddress = "A000")
					cartSlot := " -cartA"
				Else If (currentCartAddress = "B000")
					cartSlot := " -cartB"
				Else If (currentCartAddress = "2000")
					cartSlot := " -cart2"
				Else If (currentCartAddress = "4000")
					cartSlot := " -cart4"
				Else If (currentCartAddress = "6000")
					cartSlot := " -cart6"
				Else
					ScriptError("Invalid Cart Address Specified: " . CartAddress)

				multipartCLI = %multipartCLI% %cartSlot% "%currentCart%"
			}
			Run(multipartCLI, emuPath)
		}	
		Else {
			;singlepart carts - unlike multipart carts, we can directly run the emulator with a single CLI parameter

			If (CartAddress = "A000")
				cartSlot := " -cartA"
			Else If (CartAddress = "B000")
				cartSlot := " -cartB"
			Else If (CartAddress = "2000")
				cartSlot := " -cart2"
			Else If (CartAddress = "4000")
				cartSlot := " -cart4"
			Else If (CartAddress = "6000")
				cartSlot := " -cart6"
			Else
				ScriptError("Invalid Cart Address Specified: " . CartAddress)

			HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

			Run(executable . params . cartSlot . " """ . romPath . "\" . romName . romExtension . """", emuPath)
		}
	} Else {
		;for non cartridges, update the vice.ini with the proper memory expansion values (If needed) prior to calling the emulator.
		varBlock0 = 0
		varBlock1 = 0
		varBlock2 = 0
		varBlock3 = 0
		varBlock5 = 0
		
		If (MemoryExpansion = "3k") { 
			varBlock0 = 1
		} Else If (MemoryExpansion = "8k") { 
			varBlock1 = 1
		} Else If (MemoryExpansion = "16k") { 
			varBlock1 = 1
			varBlock2 = 1
		} Else If (MemoryExpansion = "24k") { 
			varBlock1 = 1
			varBlock2 = 1
			varBlock3 = 1		
		} Else If (MemoryExpansion = "all") { 
			varBlock0 = 1
			varBlock1 = 1
			varBlock2 = 1
			varBlock3 = 1
			varBlock5 = 1
		} Else If (MemoryExpansion = "3,5") { 
			varBlock3 = 1
			varBlock5 = 1		
		} Else If (MemoryExpansion = "5") { 
			varBlock5 = 1		
		} Else If (MemoryExpansion = "1,5") { 
			varBlock1 = 1
			varBlock5 = 1		
		} Else If (MemoryExpansion = "1,2,5") { 
			varBlock1 = 1
			varBlock2 = 1
			varBlock5 = 1		
		}
		IniWrite, %varBlock0%, %viceINI%, VIC20, RAMBlock0
		IniWrite, %varBlock1%, %viceINI%, VIC20, RAMBlock1
		IniWrite, %varBlock2%, %viceINI%, VIC20, RAMBlock2
		IniWrite, %varBlock3%, %viceINI%, VIC20, RAMBlock3
		IniWrite, %varBlock5%, %viceINI%, VIC20, RAMBlock5

		HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

		Run(executable . params . " """ . romPath . "\" . romName . romExtension . """" , emuPath )
	}

	If (RequiresReset = "true") 
	{
		WinWaitActive(windowTitle)
		Sleep, 1000 ; increase If command is not appearing in the emu window or some just some letters
		Send !r
	}

	If %Command% 
	{
		WinWaitActive(windowTitle)
		SetKeyDelay(50)
		SendCommand(Command . "{Enter}", SendCommandDelay)
	}	
}
Else If (ident = "C128") {
	If romExtension not in .prg,.d64,.d81
		ScriptError("Your rom has an extension of " . romExtension . ", only these extensions are supported:`nprg,d64,d81")

	SendCommandDelay := IniReadCheck(settingsFile, "Settings", "SendCommandDelay", "1500",,1)

	; Setting TrueDriveEmulation setting in ini If it doesn't match what user wants above
	If ( TrueDriveEmulation != "true" And currentDriveTrueEmulation = 1 ) {
		IniWrite, 0, %viceINI%, %ident%, DriveTrueEmulation
		IniWrite, 0, %viceINI%, %ident%, Drive8Type
	}
	Else If ( TrueDriveEmulation = "true" And currentDriveTrueEmulation = 0 ) {
		IniWrite, 1, %viceINI%, %ident%, DriveTrueEmulation
		IniWrite, 1570, %viceINI%, %ident%, Drive8Type
	}
	
	Command := IniReadCheck(settingsFile, romName, "Command", "",,1)
	Commodore64Mode := IniReadCheck(settingsFile, romName, "Commodore64Mode", "false",,1)
	StringLower, Command, Command ;Command MUST be in lower case so let's force it

	;set 80/40 col param
	If ( ColumnMode = "40" ) {
		params := params . " -40col"
	}
	Else {
		params := params . " -80col"
	}

	; Force either C64 mode (-go64) or C128 mode (+go64)
	If ( Commodore64Mode = "true" ) {
		params := params . " -go64"
	}
	Else {
		params := params . " +go64"
	}
	
	params := params . " +reu +autostart-warp "
		
	HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait
	Run(executable . params . " """ . romPath . "\" . romName . romExtension . """" , emuPath )

	Sleep,1000
	WinGet, id, list, %windowTitle%
	MaxWidth := 0
	MinWidth := 10000
	Loop, %id% {
		this_id := id%A_Index%
		WinActivate, ahk_id %this_id%
		WinGetClass, this_class, ahk_id %this_id%
		WinGetTitle, this_title, ahk_id %this_id%
		WinGetPos, X, Y, Width, Height, ahk_id %this_id%
		If (Width > MaxWidth) {
			Win80Col = ahk_id %this_id%
			MaxWidth := Width
		}
		If (Width < MinWidth) {
			Win40Col = ahk_id %this_id%
			MinWidth := Width 
		}
	}

	If ( ColumnMode = "40" ) {
		WinHide, %Win80Col%	
	} Else {
		WinHide, %Win40Col%	
	}	
	
	;Activate the desired window since you might have hidden the active one above
	WinActivate, %windowTitle%
	WinWaitActive(windowTitle)
	WinSet, Redraw, , A ;Without this line bezel will always draw below the emulator window!

	Sleep, 1000

	If %Command% {
		WinWaitActive(windowTitle)
		SetKeyDelay(50)
		SendCommand(Command . "{Enter}", SendCommandDelay)
	}	
}

WinWait(windowTitle)
WinWaitActive(windowTitle)
BezelDraw()
HideEmuEnd()

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


JoySwap:
	Send !j
Return

Warp:
	Send !w
Return

StartTape:
	Send !{F7}
Return

StopTape:
	Send !{F8}
Return

RunTape:
	SetKeyDelay(50)
	Loop, parse, Command
		Send, {%A_LoopField% down}{%A_LoopField% up}
	Send, {Enter down}{Enter up}
Return

HaltEmu:
	If (Fullscreen = "true")
		Send !{Enter}
Return

MultiGame:
	Log("MultiGame Label was run!")
	If romExtension in .d64,.d71,.d80,.d81,.d82,.g64,.g41,.x64,.prg
	{	Send !8 ; swaps a Disk
		wvTitle:="Attach disk image ahk_class #32770"
	} Else If romExtension in .t64,.tap
	{	Send !t ; swaps a Tape
		wvTitle:="Attach tape image ahk_class #32770"
	} Else
		ScriptError(romExtension . " is an invalid multi-game extension")
	OpenROM(wvTitle, selectedRom)
	Log("Module - WinWaitActive`, " . windowTitle . "`, `, 5")
	WinWaitActive(windowTitle,,5)
	WinActivate, %windowTitle%
Return

RestoreEmu:
	If (Fullscreen = "true")
		Send !{Enter}
Return

CloseProcess:
	FadeOutStart()
	BezelExit()
	WinClose(windowTitle)
Return
