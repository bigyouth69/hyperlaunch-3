MEmu = Phoenix
MEmuV = v1.1
MURL = http://arts-union.my1.ru/
MAuthor = djvj
MVersion = 2.0.1
MCRC = BC8FC08C
iCRC = 7C17F75F
MID = 635038268914342592
MSystem = "Panasonic 3DO"
;------------------------------------------------------------------------
; Notes:
; This emu only supports iso images
; Set SelectGameMode if you have any problems with the emu opening the game
; If your bios file is called fz10_rom.bin, rename it to fz10.rom, it should be placed in the same dir as the emu exe.
; On first launch, Phoenix will ask you to point it to the fz10.rom. After you do that, exit the emu and select a game in HS and it should work.
; If you do not have an English windows, set the language you use for the MLanguage setting in HLHQ. Currently only Spanish/Portuguese is supported.
;
; Phoenix stores its config in the registry @ HKEY_CURRENT_USER\Software\FreeDO\FreeDO Emulator
;------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
SelectGameMode := IniReadCheck(settingsFile, "Settings", "SelectGameMode","1",,1)	; 1 = Uses a loop to detect the Edit Box has the romname and path in it. This doesn't work on all PCs, so if you get stuck at the open rom window, use mode 2. 2 = Uses a simple Ctrl+v to paste the romname and path, then press Enter to load the game.
ControlDelay := IniReadCheck(settingsFile, "Settings", "ControlDelay","20",,1) ; raise this if the module is getting stuck somewhere
KeyDelay := IniReadCheck(settingsFile, "Settings", "KeyDelay","-1",,1) ; raise this if the module is getting stuck using SelectGameMode 2
MLanguage := IniReadCheck(settingsFile, "Settings", "MLanguage","English",,1)		; If English, dialog boxes look for the word "Open" and if Spanish/Portuguese, looks for "Abrir"

mLang := Object("English","Open","Spanish/Portuguese","Abrir")
winLang := mLang[MLanguage]	; search object for the MLanguage associated to the user's language
If !winLang
	ScriptError("Your chosen language is: """ . MLanguage . """. It is not one of the known supported languages for this module: " . moduleName)

7z(romPath, romName, romExtension, 7zExtractPath)

SetControlDelay, %ControlDelay%
SetKeyDelay, %KeyDelay%		

If romExtension in .7z,.rar,.zip,.cue
	ScriptError("Pheonix does not support archived or cue files. Only ""iso"" files can be loaded. Either enable 7z support, or extract your games first.")

Run(executable, emuPath)

WinWait("Phoenix ahk_class Mainframe")
WinWaitActive("Phoenix ahk_class Mainframe")
WinMenuSelectItem, Phoenix ahk_class Mainframe,, File, Open ISO
WinWait(winLang . " ahk_class #32770")
WinWaitActive(winLang . " ahk_class #32770")

If ( SelectGameMode = 1 ) {
	Loop {
		ControlGetText, edit1Text, Edit1, %winLang% ahk_class #32770
		If ( edit1Text = romPath . "\" . romName . romExtension )
			Break
		Sleep, 100
		ControlSetText, Edit1, %romPath%\%romName%%romExtension%, %winLang% ahk_class #32770
	}
	ControlSend, Button1, {Enter}, AHK_class #32770 ; Select Open
} Else If ( SelectGameMode = 2 ) {
	Clipboard := romPath . "\" . romName . romExtension
	Send, ^v{Enter}
} Else
	ScriptError("You did not choose a valid SelectGameMode.`nOpen the module and set the mode at the top.")

WinWait("Phoenix ahk_class Mainframe")
WinWaitActive("Phoenix ahk_class Mainframe")
WinMenuSelectItem, Phoenix ahk_class Mainframe,, CPU, Start

If Fullscreen = true
	Send, {F4} ; fullscreen

Sleep, 1000

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


RestoreEmu:
	Send, !{Enter}
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class Mainframe")	; Removing Phoenix from the title because the emulator shows statistics in the title while a game is playing
Return
