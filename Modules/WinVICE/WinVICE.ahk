MEmu = WinVICE
MEmuV = v2.4
MURL = http://vice-emu.sourceforge.net/
MAuthor = djvj,wahoobrian,brolly
MVersion = 2.1
MCRC = 65BCB02B
iCRC = 623C6A46
MID = 635038268966170754
MSystem = "Commodore 64","Commodore 16 & Plus4","Commodore VIC-20"
;----------------------------------------------------------------------------
; Notes:
; Roms must be unzipped.
; You can turn off the exit confirmation box by unchecking Settings->Confirm on exit
; Turn on saving settings by checking Settings->Save settings on exit, this will create the vice.ini file this module needs.
;
; If you want to use the StartTape and StopTape hotkeys make sure you edit the files C64\win_shortcuts.vsc or VIC20\win_shortcuts.vsc 
; (paths relative to the emulator install folder) and assign Alt+F7 as the StartTape shortcut and Alt+F8 as the StopTape shortcut, like this:
; ALT				0x76		IDM_DATASETTE_CONTROL_START		  F7
; ALT				0x77		IDM_DATASETTE_CONTROL_STOP		  F8
;
; WinVICE uses different executables for each machine so make sure you setup your emulators properly:
; x64.exe - Commodore 64
; xplus4.exe - Commodore 16 & Plus/4
; xvic.exe - Commodore VIC-20
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

mType := Object("Commodore 64","C64","Commodore 16 & Plus4","PLUS4","Commodore VIC-20","VIC20") ;ident should be the section names used in VICE.ini
ident := mType[systemName]	; search object for the systemName identifier

IfExist, % modulePath . "\" . systemName . ".ini"	; use a custom systemName ini if it exists
	settingsFile := modulePath . "\" . systemName . ".ini"
Else
	settingsFile := modulePath . "\" . moduleName . ".ini"

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)				; If true, the module governs if the emulator launches fullscreen or not. Set to false when troubleshooting a module for launching problems.
WarpKey := IniReadCheck(settingsFile, "Settings", "WarpKey","F9",,1)						; toggle warp speed
JoySwapKey := IniReadCheck(settingsFile, "Settings", "JoySwapKey","F10",,1)					; swap joystick port
StartTapeKey := IniReadCheck(settingsFile, "Settings", "StartTapeKey","F7",,1)					; starts tape
StopTapeKey := IniReadCheck(settingsFile, "Settings", "StopTapeKey","F8",,1)					; stops tape

SelectGameMode := IniReadCheck(settingsFile, "Settings", "SelectGameMode","1",,1)			;	1 = Uses a loop to detect the Edit Box has the romname and path in it. This doesn't work on all PCs, so if you get stuck at the open rom window, use mode 2. 2 = Uses a simple Ctrl+v to paste the romname and path, then press Enter to load the game.
; DiskSwapKey = F11		; swaps disk or tape - Do not need this key anymore with multigame support

UsePaddles := IniReadCheck(settingsFile, romName, "UsePaddles", "false",,1)
AutostartPrgMode := IniReadCheck(settingsFile, romName, "AutostartPrgMode", "2",,1)

7z(romPath, romName, romExtension, 7zExtractPath)

viceINI := CheckFile(emuPath . "\vice.ini")
IniRead, currentFullScreen, %viceINI%, %ident%, FullscreenEnabled
IniRead, currentAutostartPrgMode, %viceINI%, %ident%, AutostartPrgMode

; Setting Fullscreen setting in ini if it doesn't match what user wants above
If ( Fullscreen != "true" And currentFullScreen = 1 )
	IniWrite, 0, %viceINI%, %ident%, FullscreenEnabled
Else If ( Fullscreen = "true" And currentFullScreen = 0 )
	IniWrite, 1, %viceINI%, %ident%, FullscreenEnabled

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

params := "+confirmexit"

; Setting video mode depending on rom, default NTSC	
if (VideoMode = "NTSC") {
	params := params . " -ntsc"
	;IniWrite, -2, %viceINI%, %ident%, MachineVideoStandard  ;NTSC
} else {
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
	If romExtension not in .d64,.d71,.d80,.d81,.d82,.g64,.g41,.x64,.t64,.tap,.crt
		ScriptError("Your rom has an extension of " . romExtension . ", only these extensions are supported:`nd64,d71,d80,d81,d82,g64,g41,x64,t64,tap,crt")

	If ( romExtension = ".crt" ) {
		IniWrite, %romPath%\%romName%%romExtension%, %viceINI%, C64, CartridgeFile
		IniWrite, 0, %viceINI%, C64, CartridgeType
	} Else {
		IniWrite, -1, %viceINI%, C64, CartridgeType
	}

	; Hotkey, ~%DiskSwapKey%, MultiGame

	If romExtension in .d64,.d71,.d80,.d81,.d82,.g64,.g41,.x64,.prg
		Run(executable . " " . params . " """ . romPath . "\" . romName . romExtension . """", emuPath)
	Else If romExtension in .t64,.tap
		Run(executable . " " . params . " """ . romPath . "\" . romName . romExtension . """", emuPath)
	Else If romExtension = .crt
		Run(executable . " " . params . " -cartcrt """ . romPath . "\" . romName . romExtension . """", emuPath)
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
	}
	Else { ;Commodore 16
		IniWrite, "", %viceINI%, %ident%, FunctionLowName
		IniWrite, "", %viceINI%, %ident%, FunctionHighName
		IniWrite, 16, %viceINI%, %ident%, RamSize
		IniWrite, 0, %viceINI%, %ident%, Acia1Enable
	}

	Command := IniReadCheck(settingsFile, romName, "Command", "",,1)
	StringLower, Command, Command ;Command MUST be in lower case so let's force it

	If romExtension in .d64,.g64,.prg
		Run(executable . " " . params . " """ . romPath . "\" . romName . romExtension . """", emuPath)
	Else If romExtension in .t64,.tap
		Run(executable . " " . params . " """ . romPath . "\" . romName . romExtension . """", emuPath)
	Else If romExtension = .crt
		Run(executable . " " . params . " -cartcrt """ . romPath . "\" . romName . romExtension . """", emuPath)

	if %Command% 
	{
		WinWaitActive("ahk_class VICE")
		Sleep, %SendCommandDelay% ; increase if command is not appearing in the emu window or some just some letters

		If romExtension in .t64,.tap
		{
			;Tape loading time will vary greatly so we can't type this automatically, user must do it using a hotkey
			RunTapeKey := IniReadCheck(settingsFile, romname, "RunTapeKey","Ctrl&F12",,1)						; run tape key
			RunTapeKey := xHotKeyVarEdit(RunTapeKey,"RunTapeKey","~","Add")
			xHotKeywrapper(RunTapeKey,"RunTape")
		}
		Else
		{
			SetKeyDelay, 50
			Loop, parse, Command
				Send, {%A_LoopField% down}{%A_LoopField% up}
			Send, {ENTER down}{ENTER up}
		}
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

		;MultiPart carts can only be run if the MultiGame feature is enabled
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

			multipartCLI = %executable% %params%

			for index, element in romtable {
				currentCart := romtable[A_Index,1]
				SplitPath, currentCart,,,, OutFileName
				currentCartAddress := IniReadCheck(settingsFile, OutFileName, "CartLoadingAddress", "X000",,1)
				
				If (currentCartAddress = "A000")
					cartSlot := "-cartA"
				Else If (currentCartAddress = "B000")
					cartSlot := "-cartB"
				Else If (currentCartAddress = "2000")
					cartSlot := "-cart2"
				Else If (currentCartAddress = "4000")
					cartSlot := "-cart4"
				Else If (currentCartAddress = "6000")
					cartSlot := "-cart6"
				Else
					ScriptError("Invalid Cart Address Specified: " . CartAddress)

				multipartCLI = %multipartCLI% %cartSlot% "%currentCart%"
			}
			Run(multipartCLI, emuPath)
		}	
		Else {
			;singlepart carts - unlike multipart carts, we can directly run the emulator with a single CLI parameter

			If (CartAddress = "A000")
				cartSlot := "-cartA"
			Else If (CartAddress = "B000")
				cartSlot := "-cartB"
			Else If (CartAddress = "2000")
				cartSlot := "-cart2"
			Else If (CartAddress = "4000")
				cartSlot := "-cart4"
			Else If (CartAddress = "6000")
				cartSlot := "-cart6"
			Else
				ScriptError("Invalid Cart Address Specified: " . CartAddress)

			Run(executable . " " . params . " " . cartSlot . " """ . romPath . "\" . romName . romExtension . """", emuPath)
		}
	}
	Else {
		;for non cartridges, update the vice.ini with the proper memory expansion values (if needed) prior to calling the emulator.
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

		Run(executable . " " . params . " """ . romPath . "\" . romName . romExtension . """" , emuPath )
	}

	if %Command% {
		WinWaitActive("ahk_class VICE")
		Sleep, %SendCommandDelay% ; increase if command is not appearing in the emu window or some just some letters
		SetKeyDelay, 50
		Loop, parse, Command
			Send, {%A_LoopField% down}{%A_LoopField% up}
		Send, {ENTER down}{ENTER up}
	}	
	
	if (RequiresReset = "true") {
		WinWaitActive("ahk_class VICE")
		Sleep, 1000 ; increase if command is not appearing in the emu window or some just some letters
		Send !r
	}	
}

WinWait("ahk_class VICE")
WinWaitActive("ahk_class VICE")

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
	SetKeyDelay, 50
	Loop, parse, Command
		Send, {%A_LoopField% down}{%A_LoopField% up}
	Send, {ENTER down}{ENTER up}
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
	{
		ScriptError(romExtension . " is an invalid multi-game extension")
	}

	WinWait(wvTitle)
	WinWaitActive(wvTitle)
	If ( SelectGameMode = 1 ) {
		Loop {
			ControlGetText, edit1Text, Edit1, %wvTitle%
			If ( edit1Text = selectedRom )
				Break
			Sleep, 100
			ControlSetText, Edit1, %selectedRom%, %wvTitle%
		}
		ControlSend, Button1, {Enter}, ahk_class #32770 ; Select Open
	} Else If ( SelectGameMode = 2 ) {
		Clipboard := selectedRom
		Send, ^v{Enter}
	} Else
		ScriptError("You did not choose a valid SelectGameMode.`nOpen the module and set the mode at the top.")
	Log("Module - WinWaitActive`, ahk_class VICE`, `, 5")
	WinWaitActive("ahk_class VICE",,5)
	WinActivate, ahk_class VICE
Return

RestoreEmu:
	If (Fullscreen = "true")
		Send !{Enter}
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class VICE")
Return
