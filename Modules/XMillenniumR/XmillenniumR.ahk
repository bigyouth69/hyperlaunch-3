MEmu = XMillenniumR
MEmuV = v1.2
MURL = http://www.jcec.co.uk/x1emu.html
MAuthor = brolly
MVersion = 2.0
MCRC = 909146C2
iCRC = 381666D6
mId = 635255894590132125
MSystem = "Sharp X1"
;----------------------------------------------------------------------------
; Notes:
; This module will NOT work with vanilla Xmillennium so do not attempt to use it with it
; This version of the emulator supports tape games in .tap format
;
; Make sure you set all your .tap files to Read Only under windows as the emulator has the nasty 
; habit of storing the tape position on them after each run which means you will need to manually 
; rewind a tape every time after playing
;
;----------------------------------------------------------------------------

StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
xmillIniFile := emuPath . "\Xmil106R.ini"

Fullscreen := IniReadCheck(settingsFile, "Settings", "fullscreen","true",,1)
DualDiskLoad := IniReadCheck(settingsFile, romName, "DualDiskLoad","true",,1)
MultipleDiskSlot := IniReadCheck(settingsFile, romName, "MultipleDiskSlot","0",,1)

BezelStart()

hideEmuObj := Object("ahk_class Xmil106R",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

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

If romExtension = .tap
{
	;PostMessage, 0x111, 40056,,,ahk_class Xmil106R ; Open tape
	IniWrite,%romPath%\%romName%%romExtension%, %xmillIniFile%, EXP, CAS0
	IniWrite, %A_Space%, %xmillIniFile%, EXP, FDD0
	IniWrite, %A_Space%, %xmillIniFile%, EXP, FDD1
} Else {
	;PostMessage, 0x111, 40035,,,ahk_class Xmil106R ; Open floppy0
	IniWrite,%A_Space%, %xmillIniFile%, EXP, CAS0
	IniWrite, %romPath%\%romName%%romExtension%, %xmillIniFile%, EXP, FDD0
	If (romName2) 
		IniWrite, %romName2%, %xmillIniFile%, EXP, FDD1
	Else
		IniWrite, %A_Space%, %xmillIniFile%, EXP, FDD1
}

HideEmuStart()
Run(executable,emuPath)
WinWait("ahk_class Xmil106R")

If (Fullscreen = "true")
	PostMessage, 0x111, 40030,,, ahk_class Xmil106R ; Fullscreen

WinWait("ahk_class Xmil106R")
WinWaitActive("ahk_class Xmil106R")

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)                                                                                                     
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


HaltEmu:
Return
RestoreEmu:
Return

MultiGame:
	Control := If MultipleDiskSlot = "1" ? "40037" : "40035"
	PostMessage, 0x111, %Control%,,, ahk_class Xmil106R ; Open correct floppy
	OpenROM("ahk_class #32770", selectedRom)
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class Xmil106R")
Return
