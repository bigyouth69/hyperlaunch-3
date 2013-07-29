MEmu = PSXMAME
MEmuV = v20090903
MURL = http://emulationrealm.net/modules/wfdownloads/singlefile.php?cid=822&lid=1493
MAuthor = djvj
MVersion = 2.0
MCRC = 5497E9E6
MID = 635038268920127414
MSystem = "PSXMAME","ZiNc"
;----------------------------------------------------------------------------
; Notes:
; IMPORTANT *** psxmame.exe is only a frontend for mame.exe. You still need to copy your mame.exe to the psxmame folder or point psxmame to your mame folder for it to work. ***
; Performance is better using zinc.exe for older systems
; If you are using this for a Zinc wheel, make sure your roms and database use standard mame naming, not the numbered ones Zinc requires.
; Uses mame style rom names
; Open the mame.ini and set rompath to your rom dir
; Executable should be pointing to mame.exe, not psxmame.exe (it is not an emulator)
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

Run(executable . " " . romName, emuPath, "Hide UseErrorLevel")

If ErrorLevel != 0
{	If (ErrorLevel = 1)
		Error = Failed Validity
	Else If(ErrorLevel = 2)
		Error = Missing Files
	Else If(ErrorLevel = 3)
		Error = Fatal Error
	Else If(ErrorLevel = 4)
		Error = Device Error
	Else If(ErrorLevel = 5)
		Error = Game Does Not Exist
	Else If(ErrorLevel = 6)
		Error = Invalid Config
	Else If ErrorLevel in 7,8,9
		Error = Identification Error
	Else
		Error = MAME Error
	ScriptError("MAME Error - " . Error)
}

WinWait("MAME ahk_class MAME")
WinWaitActive("MAME ahk_class MAME")

FadeInExit()
Process("WaitClose", executable)
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("MAME ahk_class MAME")
Return
