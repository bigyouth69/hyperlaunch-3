MEmu = PSXfin
MEmuV =  v1.13
MURL = http://psxemulator.gazaxian.com/
MAuthor = brolly & djvj
MVersion = 2.0
MCRC = 334F49FF
MID = 635038268919606980
MSystem = "Sony PlayStation"
;----------------------------------------------------------------------------
; Notes:
; You need to change the drive letter on the script your daemon tools virtual drive letter
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

If dtEnabled = true
	DaemonTools("get")	; populates the dtDriveLetter variable with the drive letter to your scsi or dt virtual drive

7z(romPath, romName, romExtension, 7zExtractPath)

; Mount the CD using DaemonTools
If ( romExtension = ".cue" && dtEnabled = "true" ) 
{
	DaemonTools("mount",romPath . "\" . romName . romExtension)
	Run(executable . " -f " . dtDriveLetter . ":", emuPath)
} Else {
	Log("Module RunWait - " . emuPath "\" . executable . " -f """ . romPath . "\" . romName . romExtension . """")
	RunWait, %executable% -f "%romPath%\%romName%%romExtension%", %emuPath%
}

WinWait("ahk_class pSX")
WinWaitActive("ahk_class pSX")

FadeInExit()
Process("WaitClose", executable)

If ( romExtension = ".cue" && dtEnabled = "true" )
	DaemonTools("unmount")

7zCleanUp()
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
	Send {Alt Down}{Enter Down}{Enter Up}{Alt Up}
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class pSX")
Return
