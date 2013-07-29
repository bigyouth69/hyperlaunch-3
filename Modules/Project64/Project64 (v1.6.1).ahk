MEmu = Project64
MEmuV =  v1.6.1
MURL = http://www.pj64-emu.com/
MAuthor = djvj
MVersion = 2.0.1
MCRC = 8443D8D9
iCRC = E1D76B23
MID = 635038268917505226
MSystem = "Nintendo 64"
;----------------------------------------------------------------------------
; Notes:
; Make sure you apply the 1.6.1 patch found here: http://www.jabosoft.com/index.php?articleid=114
; It applies many of the v1.7 updates but keeps the stability of the v1.6 emu
; CLI loading doesn't work, script opens roms manually
; Set SelectGameMode if you have any problems with the emu opening the game
; Run the emu manually and hit Ctrl+T to enter Settings. On the Options tab, check "On loading a ROM, go to full screen"
; Also enable CPU 
; If roms don't start automatically, enabled advanced settings, reopen Settings window, go to the Advanced tab and check "Start Emulation when rom is opened?"
; I like to turn off the Rom Browser by going to Settings->Rom Selection and uncheck "Use Rom Browser" (advanced settings needs to be on to see this tab)
; If you use Esc as your exit key, it seems to crash the emu because it also takes the emu out of fullscree,n and it need to be closed in Task Manager. It doesn't happen if you leave fullscreen first
; If you do not have an English windows, set the language you use for the MLanguage setting in HLHQ. Currently only Portuguese is supported.
;
; Project64 stores its config in the registry @ HKEY_CURRENT_USER\Software\JaboSoft\Project64 DLL
; and also @ HKEY_CURRENT_USER\Software\N64 Emulation
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)				;	Controls if emu launches fullscreen or windowed
FullscreenMethod := IniReadCheck(settingsFile, "Settings", "FullscreenMethod","reg",,1)		; reg = registry, hotkey = alt+enter. Windows 8 does not seem to work with the registry method as the key is not even there to change, Use hotkey if reg doesn't set fullscreen for you.
HideLoading := IniReadCheck(settingsFile, "Settings", "HideLoading","false",,1)		;	This speeds up loading roms but can cause some PCs to get stuck at the Open Rom window or cause HS to flicker through. Disable it if you have this issue
SelectGameMode := IniReadCheck(settingsFile, "Settings", "SelectGameMode","1",,1)	;	1 = Uses a loop to detect the Edit Box has the romname and path in it. This doesn't work on all PCs, so if you get stuck at the open rom window, use mode 2. 2 = Uses a simple Ctrl+v to paste the romname and path, then press Enter to load the game.
ControlDelay := IniReadCheck(settingsFile, "Settings", "ControlDelay","20",,1)		;	Raise this if the module is getting stuck somewhere
KeyDelay := IniReadCheck(settingsFile, "Settings", "KeyDelay","-1",,1)				;	Raise this if the module is getting stuck using SelectGameMode 2
MDebug := IniReadCheck(settingsFile, "Settings", "MDebug","false",,1)						; Set to true to get some MDebug tooltips to help with debugging problems with loading
MLanguage := IniReadCheck(settingsFile, "Settings", "MLanguage","English",,1)		; If English, dialog boxes look for the word "Open" and if Spanish/Portuguese, looks for "Abrir"

mLang := Object("English","Open","Spanish/Portuguese","Abrir")
winLang := mLang[MLanguage]	; search object for the MLanguage associated to the user's language
If !winLang
	ScriptError("Your chosen language is: """ . MLanguage . """. It is not one of the known supported languages for this module: " . moduleName)

SetControlDelay, %ControlDelay%
SetKeyDelay, %KeyDelay%

7z(romPath, romName, romExtension, 7zExtractPath)

; Setting Fullscreen setting in registry if it doesn't match what user wants above
currentFullScreen := ReadReg("On open rom go full screen")
If (Fullscreen != "true" And currentFullScreen = 1)
	WriteReg("On open rom go full screen", 0)
Else If (Fullscreen = "true" And currentFullScreen = 0)
	WriteReg("On open rom go full screen", 1)

Run(executable, emuPath) ;, Hide

;This fully ensures dialogs are completely hidden even faster than winwait
If HideLoading = true
	SetTimer, WaitForDialogEmu, 2

If MDebug = true
	ToolTip, Waiting for "ahk_class Project64 Version 1.6" to appear
WinWait("ahk_class Project64 Version 1.6")
If MDebug = true
	ToolTip, Waiting for "ahk_class Project64 Version 1.6" to become active
WinWaitActive("ahk_class Project64 Version 1.6")
Send, ^o ; Open Rom

;This fully ensures dialogs are completely hidden even faster than winwait
If HideLoading = true
	SetTimer, WaitForDialog, 2

If MDebug = true
	ToolTip, Waiting for "%winLang% ahk_class #32770" to appear
WinWait(winLang . " ahk_class #32770")
If MDebug = true
	ToolTip, Waiting for "%winLang% ahk_class #32770" to become active
WinWaitActive(winLang . " ahk_class #32770")

If ( SelectGameMode = 1 ) {
	Loop {
		ControlGetText, edit1Text, Edit1, %winLang% ahk_class #32770
		If ( edit1Text = romPath . "\" . romName . romExtension )
			Break
		If MDebug = true
		{
			WinGetActiveTitle, currentActiveWin
			ToolTip, Active Window: %currentActiveWin%`nCurrent Edit1 Text: %edit1Text%
		}
		Sleep, 100
		ControlSetText, Edit1, %romPath%\%romName%%romExtension%, %winLang% ahk_class #32770
	}
	ControlSend, Button1, {Enter}, %winLang% ahk_class #32770 ; Select Open
} Else If ( SelectGameMode = 2 ) {
	Clipboard := romPath . "\" . romName . romExtension
	Send, ^v{Enter}
} Else
	ScriptError("You did not choose a valid SelectGameMode.`nOpen the module and set the mode at the top.")

If MDebug = true
	ToolTip, Waiting for "ahk_class Project64 Version 1.6" to become active again after loading rom
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
		If MDebug = true
			ToolTip, Waiting for "Project64 Version 1.6" to go fullscreen or to start showing frames if using windowed mode after loading rom`nWhen x does not equal x2 (in windowed mode)`, script will continue:`nx=%x%`nx2=%x2%`ny=%y%`ny2=%y2%`nw=%w%`nw2=%w2%`nh=%h%`nh2=%h2%`nStatus Bar Text: %cText%`nLoop #: %A_Index%`nVideo `%: %cTextAr2%
		If ( x != x2 or A_Index >= 30) { ; x changes when emu goes fullscreen, so we will break here and destroy the GUI. Break out if loop goes on too long, something is wrong then.
			If A_Index >= 30
				Log(MEmu . " had a problem detecting when it was done loading the rom. Please try different options inside the module to find what is compatible with your system.")
			Break
		}
	}

If HideLoading = true
{
	SetTimer, WaitForDialogEmu, Off
	SetTimer, WaitForDialog, Off
	Gosub, RestoreWindow
}

If (Fullscreen = "true" && FullscreenMethod = "hotkey") {
	Sleep, 2000	; required otherwise keys get sent too early
	Send, !{Enter}
}

If MDebug = true
	ToolTip	; turn off tooltips

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

WaitForDialogEmu:
	IfWinNotExist, ahk_class Project64 Version 1.6
		Return
	Else
		WinSet, Transparent, 0, ahk_class Project64 Version 1.6
Return
WaitForDialog:
	IfWinNotExist, %winLang% ahk_class #32770
		Return
	Else
		WinSet, Transparent, 0, %winLang% ahk_class #32770
Return
RestoreWindow:
	IfWinNotExist, Project64
		Return
	Else
		WinSet, Transparent, Off, Project64
Return

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
