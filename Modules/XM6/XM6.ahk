MEmu = XM6 type G
MEmuV = v3.10 20131123
MURL = http://www.geocities.jp/kugimoto0715/
MAuthor = djvj & faahrev
MVersion = 2.0.2
MCRC = 1FF7FBB5
iCRC = B03F114C
mId = 635242714072518055
MSystem = "Sharp X68000"
;----------------------------------------------------------------------------
; Notes:
; Make sure the cgrom.dat & iplrom.dat roms exist in the emu dir or else you will get an error "Initializing the Virtual Machine is failed"
; Extensions should at least include 7z|dim|hdf|xdf|hdm
; Set your resolution by going to Tools->Options->Misc->Full screen resolution
; Set the multiplication by going to View->Stretch
;
; Be sure to use the correct format for naming the discs
; and set MutiGame to "True"
;
; Settings in HQ:
; - Fullscreen
; per ROM:
; - Option to load the second disc in floppy station 1 at boot (first disc in station 0 is default)
; - Option to configure in which floppy station discs should be changed (0 or 1)
;----------------------------------------------------------------------------
StartModule()
; BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
DualDiskLoad := IniReadCheck(settingsFile, romName, "DualDiskLoad",,,1)
MultipleDiskSlot := IniReadCheck(settingsFile, romName, "MultipleDiskSlot",,,1)
xm6gINI := CheckFile(emuPath . "\XM6g.ini")

; BezelStart("FixResMode")

fullscreen := (If fullscreen = "true" ? ("1") : ("0"))

; Setting Fast Floppy mode because it speeds up loading floppy games a bit.
; Setting Resume Window mode, it is needed to so we can launch fullscreen
; Turning off status bar because it is on by default
; Adding a SASI drive if it is turned off for hdf games
; Now let's update all our keys if they differ in the ini
iniLookup =
( ltrim c
   Window, Full, %fullscreen%
   Misc, FloppySpeed, 1
   Resume, Screen, 1
   Window, StatusBar, 0
   SASI, Drives, 1
)
Loop, Parse, iniLookup, `n
{	StringSplit, split, A_LoopField, `,, %A_Space%%A_Tab%
	IniRead, tempVar, %xm6gINI%, %split1%, %split2%
	If ( tempVar != split3 )
		IniWrite, % split3, %xm6gINI%, %split1%, %split2%
}

7z(romPath, romName, romExtension, 7zExtractPath)

; If the rom is a SASI HD Image, this updates the emu ini to the path of the image
If romExtension = .hdf
	IniWrite, %romPath%\%romName%%romExtension%, %xm6gINI%, SASI, File0

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)
WinWait("XM6 TypeG ahk_class AfxFrameOrView110")

; Opening second disc if needed
If (DualDiskLoad = "true") {
	RomTableCheck()	; make sure romTable is created already so the next line works
	romName2 := romTable[2,2]
	PostMessage, 0x111, 40050,,, XM6 TypeG ahk_class AfxFrameOrView110	; Open floppy1
	WinWaitActive("ahk_class #32770")
	Loop {
		ControlGetText, edit1Text, Edit1, A
		If (edit1Text = romPath . "\" . romName2)
			Break
		Sleep, 100
		ControlSetText, Edit1, %romPath%\%romName2%, A
	}
	PostMessage, 0x111, 1,,, A	; Select Open
}

WinWait("XM6 TypeG ahk_class AfxFrameOrView110")
WinWaitActive("XM6 TypeG ahk_class AfxFrameOrView110")

; BezelDraw()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
; BezelExit()
FadeOutExit()
ExitModule()

HaltEmu:
Return

MultiGame:
Return

RestoreEmu:
	Control := If MultipleDiskSlot = "1" ? "40050" : "40020"
	PostMessage, 0x111, %Control%,,, XM6 TypeG ahk_class AfxFrameOrView110	; Open correct floppy
	WinWaitActive("ahk_class #32770")
		Loop {
			ControlGetText, edit1Text, Edit1, A
			If (edit1Text = selectedRom)
				Break
			Sleep, 100
			ControlSetText, Edit1, %selectedRom%, A
		}
	PostMessage, 0x111, 1,,, A	; Select Open
Return

CloseProcess:
	FadeOutStart()
	WinClose("XM6 TypeG ahk_class AfxFrameOrView110")
Return
