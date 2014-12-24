iCRC = 1E716C97
MEmu = PSXfin
MEmuV =  v1.13
MURL = http://psxemulator.gazaxian.com/
MAuthor = brolly & djvj
MVersion = 2.0.2
MCRC = 7D7FF096
MID = 635038268919606980
MSystem = "Sony PlayStation"
;----------------------------------------------------------------------------
; Notes:
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

If dtEnabled = true
	DaemonTools("get")	; populates the dtDriveLetter variable with the drive letter to your scsi or dt virtual drive

BezelStart()
hideEmuObj := Object("ahk_class ConsoleWindowClass",0,"pSX ahk_class pSX",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

fullscreen := If fullscreen = "true" ? " -f" : ""

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

; Mount the CD using DaemonTools
If ( romExtension = ".cue" && dtEnabled = "true" ) 
{	DaemonTools("mount",romPath . "\" . romName . romExtension)
	Run(executable . fullscreen . " " . dtDriveLetter . ":", emuPath)
} Else {
	Log("Module RunWait - " . emuPath "\" . executable . " -f """ . romPath . "\" . romName . romExtension . """")
	Run(executable . fullscreen . " """ . romPath . "\" . romName . romExtension . """", emuPath)
}

SetTitleMatchMode, slow
WinWait("pSX ahk_class pSX")
WinWaitActive("pSX ahk_class pSX")

If fullscreen = true
{	SetKeyDelay(50)
	Send, {Alt Down}{Enter Down}{Enter Up}{Alt Up}
}

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)

If ( romExtension = ".cue" && dtEnabled = "true" )
	DaemonTools("unmount")

7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


MultiGame:
	; msgbox % "selectedRom = " . selectedRom . "`nselected game = " . currentButton . "`nmgRomPath = " . mgRomPath . "`nmgRomExt = " . mgRomExt . "`nmgRomName = "  . mgRomName
	; Unmount the CD from DaemonTools
	If ( romExtension = ".cue" && dtEnabled = "true" )
		DaemonTools("unmount")
	Sleep, 500	; Required to prevent  DT from bugging
	; Mount the CD using DaemonTools
	If ( romExtension = ".cue" && dtEnabled = "true" )
		DaemonTools("mount",selectedRom)
Return

RestoreEmu:
	SetWinDelay, 50
	If fullscreen = true
	{	SetKeyDelay(50)
		Send, {Alt Down}{Enter Down}{Enter Up}{Alt Up}
	}
Return

CloseProcess:
	FadeOutStart()
	WinClose("pSX ahk_class pSX")
Return
