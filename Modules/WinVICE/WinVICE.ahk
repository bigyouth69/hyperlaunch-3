MEmu = WinVICE
MEmuV = v2.3.25
MURL = http://vice-emu.sourceforge.net/
MAuthor = djvj
MVersion = 2.0
MCRC = E628762B
iCRC = 3F38FBB2
MID = 635038268936170754
MSystem = "Commodore 64"
;----------------------------------------------------------------------------
; Notes:
; Roms must be unzipped.
; This will not work with WinVice v2.3.9 for all rom formats. It's CLI options are different from v2.2.
; Turn off the exit confirmation box by unchecking Settings->Confirm on exit
; Turn on saving settings by checking Settings->Save settings on exit, this will create the vice.ini file this module needs.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)				; If true, the module governs if the emulator launches fullscreen or not. Set to false when troubleshooting a module for launching problems.
WarpKey := IniReadCheck(settingsFile, "Settings", "WarpKey","F9",,1)						; toggle warp speed
JoySwapKey := IniReadCheck(settingsFile, "Settings", "JoySwapKey","F10",,1)					; swap joystick port
SelectGameMode := IniReadCheck(settingsFile, "Settings", "SelectGameMode","1",,1)			;	1 = Uses a loop to detect the Edit Box has the romname and path in it. This doesn't work on all PCs, so if you get stuck at the open rom window, use mode 2. 2 = Uses a simple Ctrl+v to paste the romname and path, then press Enter to load the game.
; DiskSwapKey = F11		; swaps disk or tape - Do not need this key anymore with multigame support

7z(romPath, romName, romExtension, 7zExtractPath)

If romExtension not in .d64,.d71,.d80,.d81,.d82,.g64,.g41,.x64,.t64,.tap,.crt
	ScriptError("Your rom has an extension of " . romExtension . ", only these extensions are supported:`nd64,d71,d80,d81,d82,g64,g41,x64,t64,tap,crt")

viceINI := CheckFile(emuPath . "\vice.ini")
IniRead, currentFullScreen, %viceINI%, C64, FullscreenEnabled

If ( romExtension = ".crt" ) {
		IniWrite, %romPath%\%romName%%romExtension%, %viceINI%, C64, CartridgeFile
		IniWrite, 0, %viceINI%, C64, CartridgeType
	} Else
		IniWrite, -1, %viceINI%, C64, CartridgeType

WarpKey := xHotKeyVarEdit(WarpKey,"WarpKey","~","Add")
JoySwapKey := xHotKeyVarEdit(JoySwapKey,"JoySwapKey","~","Add")
xHotKeywrapper(WarpKey,"Warp")
xHotKeywrapper(JoySwapKey,"JoySwap")
; Hotkey, ~%DiskSwapKey%, MultiGame

; Setting Fullscreen setting in ini if it doesn't match what user wants above
If ( Fullscreen != "true" And currentFullScreen = 1 )
	IniWrite, 0, %viceINI%, C64, FullscreenEnabled
Else If ( Fullscreen = "true" And currentFullScreen = 0 )
	IniWrite, 1, %viceINI%, C64, FullscreenEnabled

If romExtension in .d64,.d71,.d80,.d81,.d82,.g64,.g41,.x64
	Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)
Else If romExtension in .t64,.tap
	Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)
Else If romExtension = .crt
	Run(executable . " -cartcrt """ . romPath . "\" . romName . romExtension . """", emuPath)

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

HaltEmu:
	Send !{Enter}
Return
MultiGame:
	If romExtension in .d64,.d71,.d80,.d81,.d82,.g64,.g41,.x64
	{	Send !8 ; swaps a Disk
		wvTitle:="Attach disk image ahk_class #32770"
	} Else If romExtension in .t64,.tap
	{	Send !t ; swaps a Tape
		wvTitle:="Attach tape image ahk_class #32770"
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
	Send !{Enter}
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class VICE")
Return
