MEmu = 1964
MEmuV =  v1.1
MURL = http://www.emucr.com/2009/06/1964-11.html
MAuthor = djvj
MVersion = 2.0
MCRC = D8AF984F
iCRC = B76B5CD
MID = 635038268873418528
MSystem = "Nintendo 64"
;----------------------------------------------------------------------------
; Notes:
; On first run the emu requires you to set your rom folder, so do so.
; To set fullscreen, edit the Fullscreen variable below
; Also in the emu's options, enable the option to start fullscreen on startup
; The Rom Browser is disabled for you below
;
; Emu stores its config in the registry @ HKEY_CURRENT_USER\Software\1964emu_099\GUI
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "settings", "Fullscreen","true",,1)
FullscreenMethod := IniReadCheck(settingsFile, "settings", "FullscreenMethod","reg",,1)
SelectGameMode := IniReadCheck(settingsFile, "settings", "SelectGameMode","1",,1)
MDebug := IniReadCheck(settingsFile, "settings", "MDebug","false",,1)

exitEmulatorKey := xHotKeyVarEdit("Esc","exitEmulatorKey","~","Remove")
; If exitEmulatorKey contains ~Esc	; sending Esc to the emu when in fullscreen causes it to crash on exit , this prevents Esc from reaching the emu
; {
	; Hotkey, %exitEmulatorKey%, Off
	; exitEmulatorKey:=RegExReplace(exitEmulatorKey,"~Esc","Esc")
	; Hotkey, %exitEmulatorKey%, CloseProcess, On
; }
	
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

7z(romPath, romName, romExtension, 7zExtractPath)

SetKeyDelay, 50
Run(executable, emuPath, "Hide")
If MDebug = true
	ToolTip, Waiting for "1964 ahk_class WinGui" to appear
WinWait("1964 ahk_class WinGui")
If MDebug = true
	ToolTip, Waiting for "1964 ahk_class WinGui" to become active
WinWaitActive("1964 ahk_class WinGui")
Send, ^o ; Open Rom
If MDebug = true
	ToolTip, Waiting for "Open ROM ahk_class #32770" to appear
WinWait("Open ROM ahk_class #32770")
If MDebug = true
	ToolTip, Waiting for "Open ROM ahk_class #32770" to become active
WinWaitActive("Open ROM ahk_class #32770")

If ( SelectGameMode = 1 ) {
	Loop {
		ControlGetText, edit1Text, Edit1, Open ahk_class #32770
		If ( edit1Text = romPath . "\" . romName . romExtension )
			Break
		If MDebug = true
		{
			WinGetActiveTitle, currentActiveWin
			ToolTip, Active Window: %currentActiveWin%`nCurrent Edit1 Text: %edit1Text%
		}
		Sleep, 100
		ControlSetText, Edit1, %romPath%\%romName%%romExtension%, Open ahk_class #32770
	}
	ControlSend, Button1, {Enter}, Open ahk_class #32770 ; Select Open
} Else If ( SelectGameMode = 2 ) {
	Clipboard := romPath . "\" . romName . romExtension
	Send, ^v{Enter}
} Else
	ScriptError("You did not choose a valid SelectGameMode.`nOpen the module and set the mode at the top.")

If MDebug = true
	ToolTip, Waiting for "1964 ahk_class WinGui" to become active again after loading rom
WinWaitActive("1964 ahk_class WinGui")

ControlGetPos, x, y, w, h, msctls_statusbar321, 1964 ahk_class WinGui
Loop {
	Sleep, 200
	If Fullscreen = true ; looping until 1964 is done loading rom and it goes fullscreen. The x position will change then, which is when this loop will break.
		ControlGetPos, x2, y2, w2, h2, msctls_statusbar321, 1964 ahk_class WinGui
	Else {	; looping until 1964 is done loading rom and it starts showing frames if in windowed mode, then this loop will break.
		ControlGetText, cText, msctls_statusbar321, 1964 ahk_class WinGui	; get text of statusbar which shows emulation stats
		StringSplit, cTextAr, cText, : `%	; split text to find the video % which will update constantly as emulation is active
		Tooltip, %cText%`ncTextAr5: %cTextAr5%
		If cTextAr5 > 0	; Break out when video % is greater then 0
			Break
	}
	If MDebug = true
		ToolTip, Waiting for "1964 ahk_class WinGui" to go fullscreen or to start showing frames if using windowed mode after loading rom`nWhen x does not equal x2 (in windowed mode)`, script will continue:`nx=%x%`nx2=%x2%`ny=%y%`ny2=%y2%`nw=%w%`nw2=%w2%`nh=%h%`nh2=%h2%`nStatus Bar Text: %cText%`nLoop #: %A_Index%`nVideo `%: %cTextAr5%
	If ( x != x2 or A_Index >= 30) { ; x changes when emu goes fullscreen, so we will break here and destroy the GUI. Break out if loop goes on too long, something is wrong then.
		If A_Index >= 30
			Log(MEmu . " had a problem detecting when it was done loading the rom. Please try different options inside the module to find what is compatible with your system.")
		Break
	}
}

If (Fullscreen = "true" && FullscreenMethod = "hotkey")
	Send, !{Enter}

If MDebug = true
	ToolTip	; turn off tooltips

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
	SetKeyDelay, 50
	PostMessage, 0x12,,,, 1964 ahk_class WinGui	; 0x12 = WM_QUIT, this is the only method that works for me with the new fade and doesn't cause a crash
	; ControlSend,, {alt down}{F4 down}{F4 up}{alt up}, 1964 ahk_class WinGui	; v1.1 this works, WinClose crashes it
	; Send {alt down}{F4 down}{F4 up}{alt up}	; v1.1 this works, WinClose crashes it
	; Send !{F4}	; v1.1 this works, WinClose crashes it
	; WinClose, 1964 ahk_class WinGui
Return
