MEmu = XMillennium
MEmuV =  v0.26d
MURL = http://www.jcec.co.uk/x1emu.html
MAuthor = faahrev
MVersion = 2.0
MCRC = 804B26B4
iCRC = AE3CC329
mId = 635255939932081217
MSystem = "Sharp X1"
;----------------------------------------------------------------------------
; Notes:
; Fullscreen, Fade-in/out, Bezel and Multidisc supported
;
; Multiple disc roms must be named [RomName]<space>[Disk]<space>[number].[RomExt] for options to work
;
; Settings in HLHQ:
; - Fullscreen
; Per ROM:
; - Option to load the second disc in floppy station 1 at boot (first disc in station 0 is default)
; - Option to configure in which floppy station discs should be changed (0 or 1)
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "fullscreen","true",,1)
dualDiskLoad := IniReadCheck(settingsFile, romName, "DualDiskLoad",,,1)
multipleDiskSlot := IniReadCheck(settingsFile, romName, "MultipleDiskSlot",,,1)

BezelStart()

7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable,emuPath)
WinWait("X millennium ahk_class Xmill-MainWindow")
	
If (fullscreen = "true")
	PostMessage, 0x111, 40030,,,X millennium ahk_class Xmill-MainWindow ; Fullscreen

PostMessage, 0x111, 40035,,,X millennium ahk_class Xmill-MainWindow ; Open floppy0

WinWaitActive("ahk_class #32770")
Loop {
		ControlGetText, edit1Text, Edit1, A
		If (edit1Text = romPath . "\" . romName . romExtension)
			Break
		Sleep, 100
		ControlSetText, Edit1, %romPath%\%romName%%romExtension%, A
	}
PostMessage, 0x111, 1,,, A ; Select Open
	
If (dualDiskLoad = "true") {
	RomTableCheck()	  ; make sure romTable is created already so the next line works
	romName2 := romTable[2,2]
	PostMessage, 0x111, 40037,,,X millennium ahk_class Xmill-MainWindow ; Open floppy1
	WinWaitActive("ahk_class #32770")
	Loop {
		ControlGetText, edit1Text, Edit1, A
		If (edit1Text = romPath . "\" . romName2)
			Break
		Sleep, 100
		ControlSetText, Edit1, %romPath%\%romName2%, A
	}
	PostMessage, 0x111, 1,,, A ; Select Open
}
	
WinWait("X millennium ahk_class Xmill-MainWindow")
WinWaitActive("X millennium ahk_class Xmill-MainWindow")

BezelDraw()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()

HaltEmu:
Return

MultiGame:
	Control := If multipleDiskSlot = 1 ? "40037" : "40035"
	PostMessage, 0x111, %Control%,,,X millennium ahk_class Xmill-MainWindow ; Open correct floppy
	WinWaitActive("ahk_class #32770")
		Loop {
			ControlGetText, edit1Text, Edit1, A
			If ( edit1Text = selectedRom )
				Break
			Sleep, 100
			ControlSetText, Edit1, %selectedRom%, A
		}
	PostMessage, 0x111, 1,,, A ; Select Open
Return

RestoreEmu:
Return

CloseProcess:
	FadeOutStart()
	WinClose("X millennium ahk_class Xmill-MainWindow")
Return
