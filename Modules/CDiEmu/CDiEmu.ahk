MEmu = CDiEmu
MEmuV = v0.5.2 or v0.5.3 beta
MURL = http://www.cdiemu.org/
MAuthor = djvj & brolly
MVersion = 2.0.1
MCRC = 2CB9B930
iCRC = EFDCB23C
MID = 635038268878712944
MSystem = "Philips CD-i"
;----------------------------------------------------------------------------
; Notes:
; Place your bios in the rom subfolder. I think cdi910.rom is the latest revision.
; Games cannot be zipped. 0.5.2 supports bin, cdi, img, iso, nrg, raw, tao. 0.5.3 beta adds support for chd
; 0.5.3 beta won't work after January 2012, so make sure you activate the ChangeDate setting in HLHQ if you are using this version
; Network paths for games are not supported from CLI, yet they work when using the built-in file browser. For some reason \\REMOTEPC\games\ gets translated to C:\REMOTEPC\games\
; The module will automatically handle network paths for you and load games through the built-in browser
; The script will manually turn off the toolbar, and enable stretch and fullscreen. The emulator does not support saving these between games. Emulator also doesn't support remapping of keys.
; Press Alt+W if you need to get the toolbar back.
; Change -ntsc to -pal if you prefer 50hz instad of 60hz
; -savenvram is so the emu doesn't annoy you about saving nvram when exiting. It is only supported in v0.5.2, so if you are running the 0.5.3 beta, leave it commented, otherwise uncomment it.
; Bezels work fine, but emu runs at super fast speed...unsure how to fix so far...disabled for now.
;----------------------------------------------------------------------------
StartModule()
; BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "settings", "Fullscreen","true",,1)
ChangeDate := IniReadCheck(settingsFile, "settings", "ChangeDate","false",,1)
AutoPlayDisc := IniReadCheck(settingsFile, "settings", "AutoPlayDisc","true",,1)

dialogOpen := i18n("dialog.open")	; Looking up local translation

If (ChangeDate = "true")
{
	RunAsDate := ModuleExtensionsPath . "\RunAsDate.exe"
	CheckFile(RunAsDate)
}

networkGamePath :=
If RegExMatch(romPath,"\\\\[a-zA-Z0-9_]") {
	Log("Module - This is a network game path, which CDiEmu cannot load through CLI. Loading game through the emu's file browser instead.")
	networkGamePath := 1
}

If !networkGamePath {
	;Params = -start -playcdi -ntsc ; -savenvram
	Params = -start ; -savenvram
}

If (AutoPlayDisc = "true")
	Params := Params . " -playcdi"

If InStr(romName, "(USA)")
	Params := Params . " -ntsc"
Else
	Params := Params . " -pal"

; BezelStart()
hideEmuObj := Object(dialogOpen . " ahk_class #32770",0,"CD-i Emulator ahk_class CdiWndClass",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

If (ChangeDate = "true") ;Change visible date to the emulator using RunAsDate
	Run(RunAsDate . " 22\10\2011" . " """ . emuFullPath . """" . (If networkGamePath ? "" : " -disc """ . romPath . "\" . romName . romExtension . """") . " " . Params, ModuleExtensionsPath)
Else
	Run(executable . (If networkGamePath ? "" : " -disc """ . romPath . "\" . romName . romExtension . """") . " " . Params, emuPath)

WinWait("CD-i Emulator ahk_class CdiWndClass")
WinWaitActive("CD-i Emulator ahk_class CdiWndClass")

PostMessage, 0x111, 32796,,,CD-i Emulator ahk_class CdiWndClass ; disable toolbar
PostMessage, 0x111, 32794,,,CD-i Emulator ahk_class CdiWndClass ; enable stretch

If networkGamePath {
	PostMessage, 0x111, 32778,,,CD-i Emulator ahk_class CdiWndClass ; Open Browser
	OpenROM(dialogOpen . " ahk_class #32770", romPath . "\" . romName . romExtension)
	WinWaitActive("CD-i Emulator ahk_class CdiWndClass")
	PostMessage, 0x111, 32774,,,CD-i Emulator ahk_class CdiWndClass ; Start Emulation
}

If Fullscreen = true
	PostMessage, 0x111, 32797,,,CD-i Emulator ahk_class CdiWndClass ; enable Fullscreen
; PostMessage, 0x111, 32811,,,CD-i Emulator ahk_class CdiWndClass ; disable Fullscreen (restore)

; BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
; BezelExit()
FadeOutExit()
ExitModule()


HaltEmu:
	; If emulation is not paused internally, it sometimes skips scenes
	PostMessage, 0x111, 32775,,,CD-i Emulator ahk_class CdiWndClass ; Pause
Return
RestoreEmu:
	PostMessage, 0x111, 32779,,,CD-i Emulator ahk_class CdiWndClass ; Continue
Return

CloseProcess:
	FadeOutStart()
	WinClose("CD-i Emulator ahk_class CdiWndClass")
Return
