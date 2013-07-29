MEmu = CDiEmu
MEmuV = v0.5.2 or v0.5.3 beta
MURL = http://www.cdiemu.org/
MAuthor = djvj
MVersion = 2.0
MCRC = 4BE8C9A5
iCRC = EB44FC76
MID = 635038268878712944
MSystem = "Philips CD-i"
;----------------------------------------------------------------------------
; Notes:
; Place your bios in the rom subfolder. I think cdi910.rom is the latest revision.
; Games cannot be zipped. 0.5.2 supports bin, cdi, img, iso, nrg, raw, tao. 0.5.3 adds support for chd
; Network paths for games are not supported from CLI, yet they work when using the built-in file browser. For some reason \\REMOTEPC\games\ gets translated to C:\REMOTEPC\games\
; The script will manually turn off the toolbar, and enable stretch and fullscreen. The emulator does not support saving these between games. Emulator also doesn't support remapping of keys.
; Press Alt+W if you need to get the toolbar back.
; Change -ntsc to -pal if you prefer 50hz instad of 60hz
; -savenvram is so the emu doesn't annoy you about saving nvram when exiting. It is only supported in v0.5.2, so if you are running the 0.5.3 beta, leave it commented, otherwise uncomment it.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "settings", "Fullscreen","true",,1)

Params = -start -playcdi -ntsc ; -savenvram

7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable . " """ . romPath . "\" . romName . romExtension . """  " . Params, emuPath)

WinWait("CD-i Emulator ahk_class CdiWndClass")
WinWaitActive("CD-i Emulator ahk_class CdiWndClass")

WinMenuSelectItem, CD-i Emulator ahk_class CdiWndClass,, Window, Toolbar ; disable toolbar
WinMenuSelectItem, CD-i Emulator ahk_class CdiWndClass,, Window, Stretch ; enable stretch

If Fullscreen = true
	WinMenuSelectItem, CD-i Emulator ahk_class CdiWndClass,, Window, Fullscreen ; enable fullscreen

FadeInExit()
Process("WaitClose", executable)

7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("CD-i Emulator ahk_class CdiWndClass")
Return
