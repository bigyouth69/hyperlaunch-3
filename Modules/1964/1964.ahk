MEmu = 1964
MEmuV =  v1.1
MURL = http://www.emulator-zone.com/doc.php/n64/1964.html
MAuthor = djvj
MVersion = 2.0.1
MCRC = FECFF63D
iCRC = 2A538F1F
MID = 635038268873418528
MSystem = "Nintendo 64"
;----------------------------------------------------------------------------
; Notes:
; On first run the emu requires you to set your rom folder, so do so.
; In the emu's options, enable the option to start fullscreen on startup
; The Rom Browser is disabled for you.
;
; Emu stores its config in the registry @ HKEY_CURRENT_USER\Software\1964emu_099\GUI
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "settings", "Fullscreen","true",,1)
FullscreenMethod := IniReadCheck(settingsFile, "settings", "FullscreenMethod","reg",,1)

dialogOpen := i18n("dialog.open")	; Looking up local translation

exitEmulatorKey := xHotKeyVarEdit("Esc","exitEmulatorKey","~","Remove")	; sending Esc to the emu when in fullscreen causes it to crash on exit , this prevents Esc from reaching the emu

; Disabling ROM Browser if it is active
currentBrowser := ReadReg("DisplayRomList")
If ( currentBrowser = 1 )
	WriteReg("DisplayRomList", 0)

; Setting Fullscreen setting in registry if it doesn't match what user wants above
If FullscreenMethod = reg
{
	currentFullScreen := ReadReg("AutoFullScreen")
	If ( Fullscreen != "true" And currentFullScreen = 1 )
		WriteReg("AutoFullScreen", 0)
	Else If ( Fullscreen = "true" And currentFullScreen = 0 )
		WriteReg("AutoFullScreen", 1)
}

hideEmuObj := Object(dialogOpen . " ROM ahk_class #32770",0,"1964 ahk_class WinGui",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

Run(executable, emuPath, "Hide")
WinWait("1964 ahk_class WinGui")
WinWaitActive("1964 ahk_class WinGui")
SetKeyDelay(50)
Send, ^o ; Open Rom

OpenROM(dialogOpen . " ROM ahk_class #32770", romPath . "\" . romName . romExtension)

WinWaitActive("1964 ahk_class WinGui")

ControlGetPos, x, y, w, h, msctls_statusbar321, 1964 ahk_class WinGui
Loop {
	Sleep, 200
	If Fullscreen = true ; looping until 1964 is done loading rom and it goes fullscreen. The x position will change then, which is when this loop will break.
		ControlGetPos, x2, y2, w2, h2, msctls_statusbar321, 1964 ahk_class WinGui
	Else {	; looping until 1964 is done loading rom and it starts showing frames if in windowed mode, then this loop will break.
		ControlGetText, cText, msctls_statusbar321, 1964 ahk_class WinGui	; get text of statusbar which shows emulation stats
		StringSplit, cTextAr, cText, : `%	; split text to find the video % which will update constantly as emulation is active
		; Tooltip, %cText%`ncTextAr5: %cTextAr5%
		If cTextAr5 > 0	; Break out when video % is greater then 0
			Break
	}
	; ToolTip, Waiting for "1964 ahk_class WinGui" to go fullscreen or to start showing frames if using windowed mode after loading rom`nWhen x does not equal x2 (in windowed mode)`, script will continue:`nx=%x%`nx2=%x2%`ny=%y%`ny2=%y2%`nw=%w%`nw2=%w2%`nh=%h%`nh2=%h2%`nStatus Bar Text: %cText%`nLoop #: %A_Index%`nVideo `%: %cTextAr5%
	If ( x != x2 or A_Index >= 30) { ; x changes when emu goes fullscreen, so we will break here and destroy the GUI. Break out if loop goes on too long, something is wrong then.
		If A_Index >= 30
			Log(MEmu . " had a problem detecting when it was done loading the rom. Please try different options inside the module to find what is compatible with your system.")
		Break
	}
}

If (Fullscreen = "true" && FullscreenMethod = "hotkey")
	Send, !{Enter}

HideEmuEnd()
FadeInExit()
Process("WaitClose",executable)
7zCleanUp()
FadeOutExit()
ExitModule()


ReadReg(var1) {
	RegRead, regValue, HKEY_CURRENT_USER, Software\1964emu_099\GUI, %var1%
	Return %regValue%
}

WriteReg(var1, var2) {
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\1964emu_099\GUI, %var1%, %var2%
}


HaltEmu:
	disableSuspendEmu = true
	Send, !{Enter}
	Send, {F3}
	Sleep, 200
Return
RestoreEmu:
	WinActivate, ahk_id  %emulatorID%
	Send, !{Enter}
Return

CloseProcess:
	FadeOutStart()
	SetKeyDelay(50)
	PostMessage, 0x12,,,, 1964 ahk_class WinGui	; 0x12 = WM_QUIT, this is the only method that works for me with the new fade and doesn't cause a crash
	; ControlSend,, {alt down}{F4 down}{F4 up}{alt up}, 1964 ahk_class WinGui	; v1.1 this works, WinClose crashes it
	; Send {alt down}{F4 down}{F4 up}{alt up}	; v1.1 this works, WinClose crashes it
	; Send !{F4}	; v1.1 this works, WinClose crashes it
	; WinClose, 1964 ahk_class WinGui
Return
