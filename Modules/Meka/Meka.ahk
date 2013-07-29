MEmu = Meka
MEmuV =  v0.73
MURL = http://www.smspower.org/meka/
MAuthor = djvj
MVersion = 2.0
MCRC = FC4CDF1
iCRC = FED1FAB2
MID = 635038268904964785
MSystem = "Samsung Gam Boy","Sega Game Gear","Sega Master System"
;----------------------------------------------------------------------------
; Notes:
; Use Meka Configurator 0.73 to configure Meka, it has options that you cannot access in Meka itself
; In Meka Configurator, set these options:
; Input->General, check "Cabinet Mode" (this makes ESC exit the emu instead of F10)
; GUI, uncheck "Start in GUI" so we don't see this when the rom loads
; Blitter->MekaW, fullscreen, check "Stretch" to make the use your entire screen (aspect stays correct on widescreen monitors). Set your Resolution and your Blitter mode while you are here
; Blitter->MekaW, windowed, check "Stretch" to make the emulator use your entire windowed screen (required when using a bezel)
; Emulation, uncheck "Show BIOS logo" if you don't want to see the BIOS everytime
; Messages, uncheck "Show messages in fullscreen mode" if you don't want to see the game's name when you launch a rom
; Emu requires msvcr71.dll to be installed or at least exist in the emu's folder. It is part of the Microsoft C Runtime library
;
; Note: Sound is slightly broken up compared to Fusion
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
bezelBottomOffset := IniReadCheck(settingsFile, "Settings", "bezelBottomOffset","28",,1)
bezelRightOffset := IniReadCheck(settingsFile, "Settings", "bezelRightOffset","6",,1)

BezelStart("fixResMode")
7z(romPath, romName, romExtension, 7zExtractPath)

mekaFile := CheckFile(emuPath . "\mekaW.cfg")
FileRead, mekaCfg, %mekaFile%

mekaCfg := regexreplace(mekaCfg,"video_game_blitter.*","video_game_blitter = " . (If Fullscreen = "true" ? "Fullscreen" : "Windowed")) ; setting fullscreen or windowed resolution
SaveFile(mekaCfg, mekaFile)

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath, "Hide")

WinWait("MEKA ahk_class AllegroWindow")
WinWaitActive("MEKA ahk_class AllegroWindow")

BezelDraw()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


SaveFile(text,file) {
		FileDelete, %file%
		FileAppend, %text%, %file%
	}
	
CloseProcess:
	FadeOutStart()
	WinClose("MEKA ahk_class AllegroWindow")
Return
