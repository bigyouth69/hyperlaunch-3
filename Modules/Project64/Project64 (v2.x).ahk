MEmu = Project64
MEmuV =  v2.1.0.1
MURL = http://www.pj64-emu.com/
MAuthor = djvj
MVersion = 2.0.1
MCRC = 880A4F
iCRC = 1E716C97
MID = 635038268918025653
MSystem = "Nintendo 64"
;----------------------------------------------------------------------------
; Notes:
; Run the emu manually and hit Ctrl+T to enter Settings. On Options, check "On loading a ROM go to full screen"
; If roms don't start automatically, enabled advanced settings, and go to the Advanced and check "Start Emulation when rom is opened?"
; I like to turn off the Rom Browser by going to Settings->Rom Selection and uncheck "Use Rom Browser" (advanced settings needs to be on to see this tab)
; If you use Esc as your exit key, it could crash the emu because it also takes the emu out of fullscreen,
; You can remove Esc as a key to change fullscreen mode in the Settings->Keyboard Shortcuts, change CPU State to Game Playing (fullscreen) then Options->Full Screen and remove Esc from Current Keys
; Suggested to use Glide64 Final plugin as your graphics plugin (it does not crash on exit): https://code.google.com/p/glidehqplusglitch64/downloads/detail?name=Glide64_Final.zip&can=2&q=

; Project64 Plugins stores their settings in the registry @ HKEY_CURRENT_USER\Software\JaboSoft\Project64 DLL or HKEY_CURRENT_USER\Software\N64 Emulation

; Known Plugin issues:
; Video - Rice: crashes with annoying msgbox on exiting from fullscreen
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)				;	Controls if emu launches fullscreen or windowed

hideEmuObj := Object("ahk_class Project64 2.0",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

BezelStart("FixResMode")

emuCfg := CheckFile(emuPath . "\Config\Project64.cfg")	; check for emu's settings file
currentFullScreen := IniReadCheck(emuCfg,"default","Auto Full Screen")
If ( Fullscreen != "true" And currentFullScreen = 1 )
	IniWrite, 0, %emuCfg%, default, Auto Full Screen
Else If ( Fullscreen = "true" And currentFullScreen = 0 )
	IniWrite, 1, %emuCfg%, default, Auto Full Screen

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait
Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("ahk_class Project64 2.0")
WinWaitActive("ahk_class Project64 2.0")

If (bezelEnabled = "true")
	Control, Hide,, msctls_statusbar321, ahk_class Project64 2.0 ; Removes the StatusBar

Sleep, 1000	; required otherwise bezels don't get drawn correctly

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


HaltEmu:
	PostMessage, 0x111, 4152,,, ahk_class %EmulatorClass%	; Pause/Resume emulation
	If (fullscreen  = "true") {
		PostMessage, 0x111, 4172,,, ahk_class %EmulatorClass%	; fullscreen part1
		PostMessage, 0x111, 4173,,, ahk_class %EmulatorClass%	; fullscreen part2
	}
Return
RestoreEmu:
	Winrestore, ahk_class %EmulatorClass%
	If (fullscreen  = "true") {
		Sleep, 1000	; couple required sleeps otherwise the emu doesn't always return to Fullscreen state
		PostMessage, 0x111, 4172,,, ahk_class %EmulatorClass%	; fullscreen part1
		Sleep, 500
		PostMessage, 0x111, 4173,,, ahk_class %EmulatorClass%	; fullscreen part2
	}
	PostMessage, 0x111, 4152,,, ahk_class %EmulatorClass%	; Pause/Resume emulation
Return

CloseProcess:
	FadeOutStart()
	PostMessage, 0x111, 4003,,, ahk_class Project64 2.0	; End emulation
	Sleep, 500
	; WinClose("ahk_class Project64 2.0")	; Often leaves the process running
	PostMessage, 0x111, 4006,,, ahk_class Project64 2.0	; Exit Emu
Return
