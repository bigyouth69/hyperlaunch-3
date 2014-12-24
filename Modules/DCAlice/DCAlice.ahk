MEmu = DCAlice
MEmuV = v2014.01.23
MURL = http://alice32.free.fr/
MAuthor = brolly
MVersion = 2.0.0
MCRC = 67E9CD38
iCRC = 96B57889
mId = 635535810894136267
MSystem = "Matra & Hachette Alice"
;------------------------------------------------------------------------
; Notes:
; The emu will be in french until you click Options -> Parametres -> Langue -> Anglais, then hit OK.
; Roms must be unzipped
;------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "settings", "Fullscreen","true",,1)
RestoreTaskbar := IniReadCheck(settingsFile, "settings", "RestoreTaskbar","true",,1)
Model := IniReadCheck(settingsFile, "Settings" . "|" . romName, "Model", "alice32",,1)
Command := IniReadCheck(settingsFile, romName, "Command", "CLOAD+RUN",,1)

DefaultAliceModelIni := emuPath . "\dcalice.ini"
AliceModelIni := emuPath . "\dcalice_" . Model . ".ini"

If FileExist(AliceModelIni)
	FileCopy, %AliceModelIni%, %DefaultAliceModelIni%, 1
Else
	Log("Module - Couldn't find file : " . AliceModelIni . " using dcalice.ini instead")

dialogOpen := i18n("dialog.open")	; Looking up local translation

BezelStart()

hideEmuObj := Object(dialogOpen . " ahk_class #32770",0,"ahk_class DCAlice",1)	;Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

HideEmuStart()
Run(executable, emuPath)

WinWait("ahk_class DCAlice")
WinActivate, ahk_class DCAlice
Sleep, 100

PostMessage, 0x111, 9001,,,ahk_class DCAlice
OpenROM(dialogOpen . " ahk_class #32770", romPath . "\" . romName . romExtension)

WinWaitActive("ahk_class DCAlice")
Sleep, 500 ; increase If CLOAD is not appearing in the emu window or some just some letters

If (Model == "mc10")
	StartCommand := If Command = "CLOAD+RUN" ? "cload{Enter}run{Enter}" : "cloadm{Enter}{Wait:1500}exec{Enter}"
Else
	StartCommand := If Command = "CLOAD+RUN" ? "cloqd{Enter}run{Enter}" : "cloqd{vkC0sc027}{Enter}{Wait:1500}exec{Enter}"

SetKeyDelay(50)
SendCommand(StartCommand) ;This will type CLOAD in the screen (french systems are AZERTY so q=a)

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
	WinRestore, ahk_class DCAlice
	WinActivate, ahk_class DCAlice
	If Fullscreen = true
		Send, {PGUP} ;PgDown gets back to windowed mode
Return

CloseProcess:
	FadeOutStart()
	Send, {Alt down}{Alt up}
	WinClose("ahk_class DCAlice")
Return
