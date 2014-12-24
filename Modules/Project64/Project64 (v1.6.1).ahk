MEmu = Project64
MEmuV =  v1.6.1
MURL = http://www.pj64-emu.com/
MAuthor = djvj
MVersion = 2.0.2
MCRC = 24DC8492
iCRC = 384E4082
MID = 635038268917505226
MSystem = "Nintendo 64"
;----------------------------------------------------------------------------
; Notes:
; Make sure you apply the 1.6.1 patch found here: http://www.jabosoft.com/index.php?articleid=114
; It applies many of the v1.7 updates but keeps the stability of the v1.6 emu
; CLI loading doesn't work, script opens roms manually
; Run the emu manually and hit Ctrl+T to enter Settings. On the Options tab, check "On loading a ROM, go to full screen"
; Also enable CPU 
; If roms don't start automatically, enabled advanced settings, reopen Settings window, go to the Advanced tab and check "Start Emulation when rom is opened?"
; I like to turn off the Rom Browser by going to Settings->Rom Selection and uncheck "Use Rom Browser" (advanced settings needs to be on to see this tab)
; If you use Esc as your exit key, it seems to crash the emu because it also takes the emu out of fullscree,n and it need to be closed in Task Manager. It doesn't happen if you leave fullscreen first
;
; Project64 stores its config in the registry @ HKEY_CURRENT_USER\Software\JaboSoft\Project64 DLL
; and also @ HKEY_CURRENT_USER\Software\N64 Emulation
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)				;	Controls if emu launches fullscreen or windowed
FullscreenMethod := IniReadCheck(settingsFile, "Settings", "FullscreenMethod","reg",,1)		; reg = registry, hotkey = alt+enter. Windows 8 does not seem to work with the registry method as the key is not even there to change, Use hotkey if reg doesn't set fullscreen for you.
HideLoading := IniReadCheck(settingsFile, "Settings", "HideLoading","false",,1)		;	This speeds up loading roms but can cause some PCs to get stuck at the Open Rom window or cause HS to flicker through. Disable it if you have this issue
ControlDelay := IniReadCheck(settingsFile, "Settings", "ControlDelay","20",,1)		;	Raise this if the module is getting stuck somewhere
KeyDelay := IniReadCheck(settingsFile, "Settings", "KeyDelay","-1",,1)				;	Raise this if the module is getting stuck using SelectGameMode 2

dialogOpen := i18n("dialog.open")	; Looking up local translation

exitEmulatorKey := xHotKeyVarEdit("Esc","exitEmulatorKey","~","Remove")	; sending Esc to the emu when in fullscreen causes it to crash on exit , this prevents Esc from reaching the emu

SetControlDelay, %ControlDelay%
SetKeyDelay(KeyDelay)

hideEmuObj := Object(dialogOpen . " ahk_class #32770",0,"ahk_class Project64 Version 1.6",1,"Project64",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

; Setting Fullscreen setting in registry if it doesn't match what user wants above
currentFullScreen := ReadReg("On open rom go full screen")
If (Fullscreen != "true" And currentFullScreen = 1)
	WriteReg("On open rom go full screen", 0)
Else If (Fullscreen = "true" And currentFullScreen = 0)
	WriteReg("On open rom go full screen", 1)

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

Run(executable, emuPath) ;, Hide

WinWait("ahk_class Project64 Version 1.6")
WinWaitActive("ahk_class Project64 Version 1.6")
Send, ^o ; Open Rom

OpenROM(dialogOpen . " ahk_class #32770", romPath . "\" . romName . romExtension)

WinWaitActive("ahk_class Project64 Version 1.6")

; Sleep, 4000 ; giving time for emu to load rom so Hyperspin doesn't pop into view

ControlGetPos, x, y, w, h, msctls_statusbar321, ahk_class Project64 Version 1.6
Loop {
		Sleep, 200
		If Fullscreen = true ; looping until 1964 is done loading rom and it goes fullscreen. The x position will change then, which is when this loop will break.
			ControlGetPos, x2, y2, w2, h2, msctls_statusbar321, ahk_class Project64 Version 1.6
		Else {	; looping until Project64 is done loading rom and it starts showing frames if in windowed mode, then this loop will break.
			StatusBarGetText, cText, 2, ahk_class Project64 Version 1.6	; get text of statusbar which shows emulation stats
			StringSplit, cTextAr, cText, .:	; split text to find the FPS which will update constantly as emulation is active
			If cTextAr2 > 0	; Break out when FPS is greater then 0
				Break
		}
		; ToolTip, Waiting for "Project64 Version 1.6" to go fullscreen or to start showing frames if using windowed mode after loading rom`nWhen x does not equal x2 (in windowed mode)`, script will continue:`nx=%x%`nx2=%x2%`ny=%y%`ny2=%y2%`nw=%w%`nw2=%w2%`nh=%h%`nh2=%h2%`nStatus Bar Text: %cText%`nLoop #: %A_Index%`nVideo `%: %cTextAr2%
		If ( x != x2 or A_Index >= 30) { ; x changes when emu goes fullscreen, so we will break here and destroy the GUI. Break out if loop goes on too long, something is wrong then.
			If A_Index >= 30
				Log(MEmu . " had a problem detecting when it was done loading the rom. Please try different options inside the module to find what is compatible with your system.")
			Break
		}
	}

If (Fullscreen = "true" && FullscreenMethod = "hotkey") {
	Sleep, 2000	; required otherwise keys get sent too early
	Send, !{Enter}
}

HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


ReadReg(var1) {
	RegRead, regValue, HKEY_CURRENT_USER, Software\N64 Emulation\Project64 Version 1.6, %var1%
	Return %regValue%
}

WriteReg(var1, var2) {
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\N64 Emulation\Project64 Version 1.6, %var1%, %var2%
}

HaltEmu:
	ControlSend, ,{Esc}, ahk_class %EmulatorClass%
Return
RestoreEmu:
	Winrestore, ahk_class %EmulatorClass%
	Send, !{Enter}
	Sleep, 500
Return

CloseProcess:
	FadeOutStart()
		IfInString, exitEmulatorKey, Esc
		{	Send, !{Enter}
			Sleep, 500
		}
		WinClose("ahk_class Project64 Version 1.6")
Return
