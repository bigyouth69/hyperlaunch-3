MEmu = Phoenix
MEmuV = v1.1
MURL = http://arts-union.my1.ru/
MAuthor = djvj
MVersion = 2.0.3
MCRC = C07F4A93
iCRC = 109E182B
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
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
ControlDelay := IniReadCheck(settingsFile, "Settings", "ControlDelay","20",,1) ; raise this if the module is getting stuck somewhere
KeyDelay := IniReadCheck(settingsFile, "Settings", "KeyDelay","-1",,1) ; raise this if the module is getting stuck using SelectGameMode 2

dialogOpen := i18n("dialog.open")	; Looking up local translation

If bezelEnabled
	BezelStart(If Fullscreen = "true" ? "" : "fixResMode")

hideEmuObj := Object(dialogOpen . " ahk_class #32770",0,"Phoenix ahk_class Mainframe",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

SetControlDelay, %ControlDelay%
SetKeyDelay(KeyDelay)

If romExtension in .7z,.rar,.zip,.cue
	ScriptError("Pheonix does not support archived or cue files. Only ""iso"" files can be loaded. Either enable 7z support, or extract your games first.")

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

Run(executable, emuPath)

WinWait("Phoenix ahk_class Mainframe")
WinWaitActive("Phoenix ahk_class Mainframe")
WinMenuSelectItem, Phoenix ahk_class Mainframe,, File, Open ISO

OpenROM(dialogOpen . " ahk_class #32770", romPath . "\" . romName . romExtension)

WinWait("Phoenix ahk_class Mainframe")
WinWaitActive("Phoenix ahk_class Mainframe")
WinMenuSelectItem, Phoenix ahk_class Mainframe,, CPU, Start

If Fullscreen = true
	Send, {F4} ; fullscreen

Sleep, 1000

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


RestoreEmu:
	Send, !{Enter}
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class Mainframe")	; Removing Phoenix from the title because the emulator shows statistics in the title while a game is playing
Return
