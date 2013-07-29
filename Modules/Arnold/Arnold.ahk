MEmu = Arnold
MEmuV = v04012004
MURL = http://arnold.emuunlim.com/
MAuthor = djvj
MVersion = 2.0
MCRC = 947F73FF
iCRC = EB44FC76
MID = 635038268874439390
MSystem = "Amstrad GX4000"
;----------------------------------------------------------------------------
; Notes:
; Roms must be unzipped
; Only cpr roms (cartridges) are supported for now
; On first run, when you exit, make sure to uncheck the box to show the warning next time
; Fullscreen is controlled via the variable below
; Emu doesn't work well with win8 and fullscreen, it's slow and doesn't exit properly
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "settings", "Fullscreen","true",,1)

7z(romPath, romName, romExtension, 7zExtractPath)

If romName contains No Exit
{
	Run(executable . A_Space . emuPath)
	WinWait("ahk_class ArnoldEmu")
	WinWaitActive("ahk_class ArnoldEmu")
	WinMenuSelectItem, ahk_class ArnoldEmu,, File, Cartridge, Insert Cartridge
	WinWait("Open Cartridge ahk_class #32770")
	WinWaitActive("Open Cartridge ahk_class #32770")
	Control, EditPaste, %romPath%\%romName%%romExtension%, Edit1, Open Cartridge ahk_class #32770
	Send {Enter}
} Else
	If romExtension = .cpr
		Run(executable . " -cart """ . romPath . "\" . romName . romExtension . """", emuPath,, EmuPID)
	Else If romExtension in .tzx,.cdt 
		Run(executable . " -tape """ . romPath . "\" . romName . romExtension . """", emuPath)
	Else
		ScriptError("Rom extension %romExtension% is not supported")

WinWait("ahk_class ArnoldEmu")
WinWaitActive("ahk_class ArnoldEmu")

If Fullscreen = true
	WinMenuSelectItem, ahk_class ArnoldEmu,, View, Full screen

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("ahk_class ArnoldEmu,,0.5")	; waiting 500ms for emu to close
	IfWinExist, ahk_class ArnoldEmu	; if emu didn't close in 500ms, force closing it
		Process("Close", EmuPID)
Return
