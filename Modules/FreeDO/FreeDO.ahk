MEmu = FreeDO
MEmuV = v2.1.1 alpha
MURL = http://www.freedo.org/
MAuthor = djvj
MVersion = 2.0.1
MCRC = 6F2E1419
iCRC = 7C16552E
MID = 635038268892864713
MSystem = "Panasonic 3DO"
;------------------------------------------------------------------------
; Notes:
; The emu does not support CLI or a way of launching fullscreen by default. This is all done manually in the script.
; Supported images are iso, cdi, nrg, bin, img. Cues are not supported. Set your extensions appropriately.
; If your bios file is called fz10_rom.bin, rename it to fz10.rom, it should be placed in the same dir as the emu exe.
; On first launch, FreeDO will ask you to point it to the fz10.rom. After you do that, exit the emu and select a game in HS and it should work.
; If the Menu bar at top is present on launch, Hit F9 and exit to save.
; If you do not have an English windows, set the language you use for the MLanguage setting in HLHQ. Currently only Spanish/Portuguese is supported.
;
; Create a restore.xml or follow the next line. For info on how to do this, go here http://www.hyperspin-fe.com/forum/showpost.php?p=58411&postcount=12
; In the emu dir, rename config.xml to restore.xml then open it in notepad. Remove the entire section including <cdrom> and </cdrom> (this fixes not being able to play the game twice in a row)
; If you change inputs or make any other changes, make sure to copy the changes from the config.xml into your restore.xml
;------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
SelectGameMode := IniReadCheck(settingsFile, "Settings", "SelectGameMode","1",,1)	; 1 = Uses a loop to detect the Edit Box has the romname and path in it. This doesn't work on all PCs, so if you get stuck at the open rom window, use mode 2. 2 = Uses a simple Ctrl+v to paste the romname and path, then press Enter to load the game.
ToolbarWait := IniReadCheck(settingsFile, "Settings", "ToolbarWait","300",,1) ; increase this if toolbar is staying visible
MLanguage := IniReadCheck(settingsFile, "Settings", "MLanguage","English",,1)		; If English, dialog boxes look for the word "Open" and if Spanish/Portuguese, looks for "Abrir"

mLang := Object("English","Open","Spanish/Portuguese","Abrir")
winLang := mLang[MLanguage]	; search object for the MLanguage associated to the user's language
If !winLang
	ScriptError("Your chosen language is: """ . MLanguage . """. It is not one of the known supported languages for this module: " . moduleName)

freeDOFile := CheckFile(emuPath . "\config.xml","Cannot find " . emuPath . "\config.xml`nPlease run FreeDO manually first so it is created for you.")

7z(romPath, romName, romExtension, 7zExtractPath)

If romExtension in .7z,.rar,.zip,.cue
	ScriptError("Pheonix does not support archived or cue files. Only ""iso, cdi, nrg, bin & img"" files can be loaded. Either enable 7z support, or extract your games first.")

; restoring a proper config.xml
FileDelete, %emuPath%\config.xml
FileCopy, %emuPath%\restore.xml, %emuPath%\config.xml

Run(executable, emuPath)
DetectHiddenWindows, on
; Sleep, 500
WinWait("FreeDO ahk_class TForm1")
IfWinNotActive, FreeDO ahk_class TForm1
	WinActivate, FreeDO ahk_class TForm1
WinWaitActive("FreeDO ahk_class TForm1")
Send, {ALTDOWN}{ALTUP}{UP}{ENTER} ; open ISO
WinWait(winLang)
IfWinNotActive, %winLang% ahk_class #32770, , WinActivate, %winLang% ahk_class #32770
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
	Sleep, 100
	Send, ^v{Enter}
} Else
	ScriptError("You did not choose a valid SelectGameMode.`nOpen the module and set the mode at the top.")

WinWait("FreeDO ahk_class TForm1")
WinWaitActive("FreeDO ahk_class TForm1")

If Fullscreen = true
	Send, {F11}

Sleep, %ToolbarWait%	; increase this if toolbar is staying visible
Send, {F9}	; disable toolbar

WinWait("FreeDO ahk_class TForm1")
WinWaitActive("FreeDO ahk_class TForm1")

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()

 
CloseProcess:
	WinClose("FreeDO ahk_class TForm1")
Return
 
