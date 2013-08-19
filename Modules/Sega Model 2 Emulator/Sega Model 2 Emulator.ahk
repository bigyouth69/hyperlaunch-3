MEmu = Sega Model 2 Emulator
MEmuV = v1.0
MURL = http://nebula.emulatronia.com/
MAuthor = djvj
MVersion = 2.0.1
MCRC = 155BC798
iCRC = 
MID = 635038268923290039
MSystem = "Sega Model 2"
;----------------------------------------------------------------------------
; Notes:
; Oustide of Hyperspin, open the Sega Model 2 Emulator. 
; Under Video enable "auto switch to fullscreen".
; Open the EMULATOR.INI and set your Dir1 to your roms dir (no backslash needed)
; model2.zip must exist in your rom path which contains the needed bios files for the system.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

CheckFile(romPath . "\model2.zip","Could not locate ""model2.zip"" which contains the bios files for this emulator. Please make sure it exists in the same folder as your roms.")

Run(executable . A_Space . romName,emuPath,"Hide")

WinWait("AHK_class MYWIN",,,"Model 2 Emulator")
WinWaitActive("AHK_class MYWIN",,,"Model 2 Emulator")
Sleep, 1000 ; Increase if Hyperspin is getting a quick flash in before the game loads

FadeInExit()
Process("WaitClose", executable)
FadeOutExit()
ExitModule()


RestoreEmu:
	SetKeyDelay,,100
	Send !{Enter}
	Send !{Enter}
Return

CloseProcess:
	FadeOutStart()
	WinClose("AHK_class MYWIN")
Return
