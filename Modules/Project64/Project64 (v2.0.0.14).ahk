MEmu = Project64
MEmuV =  v2.0.0.14
MURL = http://www.pj64-emu.com/
MAuthor = djvj
MVersion = 2.0
MCRC = 6B2D54D3
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
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)				;	Controls if emu launches fullscreen or windowed

7z(romPath, romName, romExtension, 7zExtractPath)

emuCfg := CheckFile(emuPath . "\Config\Project64.cfg")	; check for emu's settings file

; Setting Fullscreen setting in registry if it doesn't match what user wants above
currentFullScreen := IniReadCheck(emuCfg,"default","Auto Full Screen")
If ( Fullscreen != "true" And currentFullScreen = 1 )
	IniWrite, 0, %emuCfg%, default, Auto Full Screen
Else If ( Fullscreen = "true" And currentFullScreen = 0 )
	IniWrite, 1, %emuCfg%, default, Auto Full Screen

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("ahk_class Project64 2.0")
WinWaitActive("ahk_class Project64 2.0")

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


HaltEmu:
	ControlSend,,{Esc}, ahk_class %EmulatorClass%
Return
RestoreEmu:
	Winrestore, ahk_class %EmulatorClass%
	Send, !{Enter}
	Sleep, 500
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class Project64 2.0")
Return
