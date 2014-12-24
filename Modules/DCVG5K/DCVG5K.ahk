MEmu = DCVG5K
MEmuV = v2012.04.13
MURL = http://dcvg5k.free.fr/
MAuthor = djvj
MVersion = 2.0.2
MCRC = A207DE3B
iCRC = 523A2AEE
mId = 635535817998209107
MSystem = "Philips VG 5000"
;------------------------------------------------------------------------
; Notes:
; The emu will be in french until you click Options -> Parametres -> Langue -> Anglais, then hit OK.
; Roms must be unzipped
; US Rally game looks frozen, but it's a side effect of going fullscreen and the emu not redrawing the game select screen. Just press 1 or 2 and it will launch
; Emu doesnt work right and is very slow in Win8. Also sometimes takes awhile to close.
;------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "settings", "Fullscreen","true",,1)
RestoreTaskbar := IniReadCheck(settingsFile, "settings", "RestoreTaskbar","true",,1)
RequiresRun := IniReadCheck(settingsFile, romName, "RequiresRun","false",,1)

dialogOpen := i18n("dialog.open")	; Looking up local translation

BezelStart()

hideEmuObj := Object(dialogOpen . " ahk_class #32770",0,"ahk_class VG5000",1)	;Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

HideEmuStart()
Run(executable, emuPath)

WinWait("ahk_class VG5000")
WinActivate, ahk_class VG5000
Sleep, 100

PostMessage, 0x111, 9001,,,ahk_class VG5000
OpenROM(dialogOpen . " ahk_class #32770", romPath . "\" . romName . romExtension)

WinWaitActive("ahk_class VG5000")
Sleep, 1200 ; increase If CLOAD is not appearing in the emu window or some just some letters
SetKeyDelay(50)
SendCommand("CLOQD{Enter}") ;This will type CLOAD in the screen

If (RequiresRun = "true") ; Sending RUN is required for some homebrew games to boot
{
	Sleep, 500
	Send, {R down}{R up}{U down}{U up}{N down}{N up}
	Send, {ENTER}
}
Sleep, 1000 ; increase If you see the blue emu screen while you are in fullscreen

If Fullscreen = true
	Send, {PGUP}

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()

If RestoreTaskbar = true
	WinShow, ahk_class Shell_TrayWnd

ExitModule()


HaltEmu:
	Send, {Alt down}{Alt up}
Return
RestoreEmu:
	WinRestore, ahk_class VG5000
	WinActivate, ahk_class VG5000
	If Fullscreen = true
		Send, {PGUP}
Return

CloseProcess:
	FadeOutStart()
	Send, {Alt down}{Alt up}
	WinClose("ahk_class VG5000")
Return
