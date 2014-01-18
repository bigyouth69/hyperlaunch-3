MEmu = XMillennium
MEmuV =  v0.26 T-Tune 1.43 + ikaTune r5
MURL = http://www.jcec.co.uk/x1emu.html
MAuthor = faahrev,brolly
MVersion = 2.0
MCRC = B118BD78
iCRC = 381666D6
mId = 635255894552751744
MSystem = "Sharp X1"
;----------------------------------------------------------------------------
; This module will also work with the standard XMillennium v0.26d, but that version doesn't 
; support tape files. So if you are using that version make sure you do not attempt to load .tap 
; files with it.
;
; Notes:
; Settings in HQ:
; - Fullscreen
; per ROM:
; - Option to load the second disc in floppy station 1 at boot (first disc in station 0 is default)
; - Option to configure in which floppy station discs should be changed (0 or 1)
;----------------------------------------------------------------------------

StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
xmillIniFile := emuPath . "\Xmillennium.ini"

Fullscreen := IniReadCheck(settingsFile, "Settings", "fullscreen","true",,1)
DualDiskLoad := IniReadCheck(settingsFile, romName, "DualDiskLoad","true",,1)
MultipleDiskSlot := IniReadCheck(settingsFile, romName, "MultipleDiskSlot","0",,1)
InfoToolBarVisible := IniReadCheck(xmillIniFile, "Xmillennium", "Info_Bar","",,1)

BezelStart()

7z(romPath, romName, romExtension, 7zExtractPath)

; Hiding the info toolbar
If (InfoToolBarVisible = "true")
	IniWrite, "false", %xmillIniFile%, Xmillennium, Info_Bar

If (DualDiskLoad = "true")
{
	If romName contains (Disk 1
	{
		;Sleep, 100 ;Without this romtable comes empty (thread related?)
		RomTableCheck()	; make sure romTable is created already so the next line can calculate correctly
		If (romtable.MaxIndex() > 1)
			romName2 := romtable[2,1] ;This should be disk 2
	}
}

Run(executable,emuPath)
WinWait("X millennium ahk_class Xmill-MainWindow")
	
If (Fullscreen = "true")
  PostMessage, 0x111, 40030,,,X millennium ahk_class Xmill-MainWindow ; Fullscreen

If romExtension = .tap
	PostMessage, 0x111, 40056,,,X millennium ahk_class Xmill-MainWindow ; Open tape
Else
	PostMessage, 0x111, 40035,,,X millennium ahk_class Xmill-MainWindow ; Open floppy0

WinWaitActive("ahk_class #32770")
Loop {
		ControlGetText, edit1Text, Edit1, A
		If ( edit1Text = romPath . "\" . romName . romExtension )
			Break
		Sleep, 100
		ControlSetText, Edit1, %romPath%\%romName%%romExtension%, A
	}
PostMessage, 0x111, 1,,, A ; Select Open

If romExtension != .tap
{
	If (romName2) 
	{
		PostMessage, 0x111, 40037,,,X millennium ahk_class Xmill-MainWindow ; Open floppy1
		WinWaitActive("ahk_class #32770")
		Loop {
			ControlGetText, edit1Text, Edit1, A
			If ( edit1Text = romName2 )
				Break
			Sleep, 100
			ControlSetText, Edit1, %romName2%, A
		}
		PostMessage, 0x111, 1,,, A ; Select Open
	}
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
Control := (If MultipleDiskSlot = "1" ? ("40037") : ("40035"))
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
