MEmu = XM6 type G
MEmuV = v3.10 20131107
MURL = http://www.geocities.jp/kugimoto0715/
MAuthor = djvj
MVersion = 2.0.1
MCRC = B3C4D4D2
iCRC = 264C221C
MID = 635038268937221635
MSystem = "Sharp X68000"
;----------------------------------------------------------------------------
; Notes:
; Make sure the cgrom.dat & iplrom.dat roms exist in the emu dir or else you will get an error "Initializing the Virtual Machine is failed"
; Extensions should at least include 7z|dim|hdf
; Set your resolution by going to Tools->Options->Display->Full screen resolution
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

xm6gINI := CheckFile(emuPath . "\XM6g.ini")

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

; WinWait("XM6 TypeG ahk_class AfxFrameOrView80")
; WinWaitActive("XM6 TypeG ahk_class AfxFrameOrView80")
WinWait("XM6 TypeG ahk_class AfxFrameOrView110")
WinWaitActive("XM6 TypeG ahk_class AfxFrameOrView110")

; Works in windowed mode only
;WinMenuSelectItem, XM6 TypeG ahk_class AfxFrameOrView80,, View, Stretch, 2.0

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	; WinClose("XM6 TypeG ahk_class AfxFrameOrView80")
	WinClose("XM6 TypeG ahk_class AfxFrameOrView110")
Return
