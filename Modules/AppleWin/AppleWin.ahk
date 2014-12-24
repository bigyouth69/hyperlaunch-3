MEmu = AppleWin
MEmuV =  v1.24.0.0
MURL = http://applewin.berlios.de/
MAuthor = faahrev, wahoobrian, brolly
MVersion = 1.5
MCRC = C14B537F
iCRC = 9039D01D
mId = 635403945717531776
MSystem = "Apple II"
;----------------------------------------------------------------------------
; Notes:
; v1.24.0.0 or greater is required as it adds a CLI switch to prevent the printscreen key error from appearing
; No bezel support (yet)
;
; Settings in HQ:
; - Fullscreen
; per ROM:
; - Option to choose the type of AppleII
; - Option to load the second disc in floppy station 1 at boot (first disc in station 0 is default)
; - Option to configure in which floppy station discs should be changed (0 or 1)
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

eamonProDOSBoot   := "Eamon ProDOS Boot Disk (USA).dsk"
eamonAdv001ProDOS := "Eamon 001 - Main Hall & Beginners Cave (USA) (Unl) (ProDOS).dsk"
eamonAdv001DOS33  := "Eamon 001 - Main Hall & Beginners Cave (USA) (Unl) (DOS3.3).dsk"

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
bezelRightOffset := IniReadCheck(settingsFile, "Settings", "bezelRightOffset","50",,1)
DiskSwapKey := IniReadCheck(settingsFile, "Settings", "DiskSwapKey","F5",,1)
RotateMethod := IniReadCheck(settingsFile, "Settings", "RotateMethod",rotateMethod,,1)
DualDiskLoad := IniReadCheck(settingsFile, romName, "DualDiskLoad","true",,1)
MultipleDiskSlot := IniReadCheck(settingsFile, romName, "MultipleDiskSlot","0",,1)
SystemType := IniReadCheck(settingsFile, romName, "SystemType","17",,1)
VideoMode := IniReadCheck(settingsFile, romName, "VideoMode","1",,1)
Command := IniReadCheck(settingsFile, romName, "Command", "",,1)
SendCommandDelay := IniReadCheck(settingsFile, romName, "SendCommandDelay", "2000",,1)
RotateDisplay := IniReadCheck(settingsFile, romName, "RotateDisplay", "0",,1)
ReadOnlyDisk := IniReadCheck(settingsFile, romName, "ReadOnlyDisk", "false",,1)
Drive2Disk := IniReadCheck(settingsFile, romName, "Drive2Disk", "",,1)

If (ReadOnlyDisk = "true") {
	;check file attribute of rom to make sure it is read only, error out If it isn't
	FileGetAttrib, attributes, %romPath%\%romName%%romExtension%
	IfNotInString, attributes, R
		ScriptError("The file " . romPath . "\" . romName .  romExtension " must be read-only.  Please change windows attributes to make file read-only.")
}

If (SystemType not in 0,1,16,17)
	ScriptError("The system type " . SystemType . " is not one of the known supported systems for this module: " . moduleName . ". Please use the option to configure the type of system needed (Default is Enhanced AppleII/e) through Hyperlaunch HQ.")
Else
	RegWrite, REG_SZ, HKCU, Software\AppleWin\CurrentVersion\Configuration, Apple2 Type, %SystemType%

If (VideoMode not in 1,4,5,6)
	ScriptError("The video mode " . VideoMode . " is not a valid for this module: " . moduleName . ". Please use the option to configure the type of system needed (Default is Enhanced AppleII/e) through Hyperlaunch HQ.")
Else
	RegWrite, REG_SZ, HKCU, Software\AppleWin\CurrentVersion\Configuration, Video Emulation, %VideoMode%
	
; Ejecting discs
RegWrite, REG_SZ, HKCU, Software\AppleWin\CurrentVersion\Preferences, Last Disk Image 1,
RegWrite, REG_SZ, HKCU, Software\AppleWin\CurrentVersion\Preferences, Last Disk Image 2,

DiskSwapKey := xHotKeyVarEdit(DiskSwapKey,"DiskSwapKey","~","Add")
xHotKeywrapper(DiskSwapKey,"DiskSwap")

hideEmuObj := Object("ahk_class APPLE2FRAME",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

If (RotateDisplay > 0)
	Rotate(rotateMethod, RotateDisplay)

BezelStart("FixResMode")
fullscreen := If fullscreen = "true" ? " -f" : " "
params := " -noreg -no-printscreen-dlg"

HideEmuStart()

If InStr(romName, "Eamon") {
	;-----------------------------------------------------------------------------------------------------------------
	;Special handling required for booting Eamon Adventure games.
	;Most Eamon Adventures use the DOS3.3 formatted disks, but some use ProDOS.  The booting of the machine in preparation
	;for loading each differs.  ProDOS versions require the emulator to boot standalone, then load and start the appropriate	
	;Eamon disks.  The DOS3.3 formatted adventure disks can be booted using the Eamon Master Diskette (Eamon #001).
	;-----------------------------------------------------------------------------------------------------------------
	EamonAdventureDOS := IniReadCheck(settingsFile, romName, "EamonAdventureDOS","1",,1)
	
	If InStr(romName, "SoftDisk") {
		;-----------------------------------------------------------------------------------------------------------------
		;Eamon SoftDisk Booting.
		;	1.  Boot using generic ProDOS diskette in Drive 1.
		;	2.  Put initial adventure disk in Drive 2.
		;   3.  Once machine booted, swaps disks and run startup command
		;-----------------------------------------------------------------------------------------------------------------
		disc1 := " -d1 """ . romPath . "\" . eamonProDOSBoot . """"
		disc2 := " -d2 """ . romPath . "\" . romName . romExtension . """"
		Run(executable . A_space . fullscreen . params . disc1 . disc2, emupath, "UseErrorLevel")
		Sleep, 2000 ;allow time for emulator to boot ProDOS
		WinWait("ahk_class APPLE2FRAME")
		WinWaitActive("ahk_class APPLE2FRAME")
		SendCommand(Command, SendCommandDelay)
	} Else If (EamonAdventureDOS = "ProDOS") {
		;-----------------------------------------------------------------------------------------------------------------
		;Eamon ProDOS Booting.
		;	1.  Boot using generic ProDOS diskette in Drive 1.
		;	2.  Put initial adventure disk in Drive 2.
		;   3.  Once machine booted, replace ProDOS diskette in Drive one with the ProDOS Eamon Master Disk (Eamon #001).
		;   4.  Issue "RUN STARTUP" command to start Adventure.
		;   5.  When prompted to load adventure of choice, using the swap disk key will place the adventure disk in Drive 1.
		;-----------------------------------------------------------------------------------------------------------------

		disc1 := " -d1 """ . romPath . "\" . eamonProDOSBoot . """"
		disc2 := " -d2 """ . romPath . "\" . romName . romExtension . """"
		Run(executable . A_space . fullscreen . params . disc1 . disc2, emupath, "UseErrorLevel")

		Sleep,2000 ;allow time for emulator to boot ProDOS
		WinWait("ahk_class APPLE2FRAME")
		WinWaitActive("ahk_class APPLE2FRAME")
		Send, {F3} ;Open Disk Select Dialog
	
		OpenROM("Select Disk Image For Drive 1 ahk_class #32770", romPath . "\" . eamonAdv001ProDOS)
		WinWait("ahk_class APPLE2FRAME")
		WinWaitActive("ahk_class APPLE2FRAME")

		SendCommand(Command, SendCommandDelay)
	} Else {
		;-----------------------------------------------------------------------------------------------------------------
		;Eamon DOS3.3 Booting.
		;	1.  Boot using DOS3.3 Eamon Master Disk (Eamon #001) in Drive 1.
		;	2.  Put initial adventure disk in Drive 2.
		;   3.  When prompted to load adventure of choice, using the swap disk key will place the adventure disk in Drive 1.
		;-----------------------------------------------------------------------------------------------------------------
		disc1 := " -d1 """ . romPath . "\" . eamonAdv001DOS33 . """"
		StringTrimRight, Eamon001Rom, eamonAdv001DOS33, 4 ;remove extension from literal value
		If (romName != Eamon001Rom)
			disc2 := " -d2 """ . romPath . "\" . romName . romExtension . """"
		Else
			disc2 := ""
		Run(executable . fullscreen . params . disc1 . disc2, emupath, "UseErrorLevel")
		WinWait("ahk_class APPLE2FRAME")
		WinWaitActive("ahk_class APPLE2FRAME")
	}	
} Else {
	;-----------------------------------------------------------------------------------------------------------------
	;All other games
	;-----------------------------------------------------------------------------------------------------------------
	disc1 := " -d1 """ . romPath . "\" . romName . romExtension . """"

	; Opening second disc If game exists of two discs only and DualDiskLoad is true
	Sleep 50	;	Needs to stay in for romTable.MaxIndex() to work.
	If (Drive2Disk <> "")
		disc2 := " -d2 """ . romTable[Drive2Disk,1] . """"
	Else If (DualDiskLoad = "true" And romTable.MaxIndex() = "2")
		disc2 := " -d2 """ . romTable[2,1] . """"
	
	Run(executable . fullscreen . params . disc1 . disc2, emupath, "UseErrorLevel")
	WinActivate, ahk_class APPLE2FRAME
	WinWaitActive("ahk_class APPLE2FRAME")

	SendCommand(Command, SendCommandDelay)
}

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)

; Switching orientation back to normal
If (RotateDisplay > 0)
	Rotate(rotateMethod, 0)

7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


DiskSwap:
	Send {F5}
Return

HaltEmu:
Return

MultiGame:
	ControlKey := If MultipleDiskSlot = "1" ? "F4" : "F3"
	Send {%ControlKey%}
	OpenROM("ahk_class #32770", selectedRom)
	WinActivate, ahk_class APPLE2FRAME
	Send {Enter}	
Return

RestoreEmu:
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class APPLE2FRAME")
Return
