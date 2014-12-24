MEmu = BlueMSX
MEmuV = v2.8.2
MURL = http://www.bluemsx.com/
MAuthor = djvj & brolly
MVersion = 2.1.0
MCRC = 3162CE42
iCRC = 646E01AA
MID = 635038268875990669
MSystem = "ColecoVision","Microsoft MSX","Microsoft MSX2","Microsoft MSX2+","Microsoft MSX Turbo-R","Sega SG-1000","Spectravideo"
;----------------------------------------------------------------------------
; Notes:
; Set your fullscreen res manually in the emu by clicking Options->Performance->Fullscreen Resolution
;
; Make sure you enable the following settings:
; File->Cassette->Rewind after insert
; File->Cassette->Use Cassette Image Read Only
; File->Cartridge Slot 1->Reset After Insert/Remove
; Options->Settings->Eject all media when blueMSX exits
;
; And make sure you disable the following settings:
; File->Disk Drive A->Reset After Insert
;
; Configure the keymapping for the joysticks in Tools->Input Editor
;
; Valid Spectravideo Machines are only the SVI-318 and SVI-328 ones all the others are MSX based machines
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

mType := Object("ColecoVision","COL - ColecoVision","Microsoft MSX","MSX","Microsoft MSX2","MSX2","Microsoft MSX2+","MSX2+","Microsoft MSX Turbo-R","MSXturboR","Sega SG-1000","SEGA - SG-1000","Spectravideo","SVI - Spectravideo SVI-328 80 Column")

ident := mType[systemName]	; search machine type for the systemName identifier BlueMSX uses
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this BlueMSX module: " . moduleName)

IfExist, % modulePath . "\" . systemName . ".ini"	; use a custom systemName ini If it exists
	settingsFile := modulePath . "\" . systemName . ".ini"
Else
	settingsFile := modulePath . "\" . moduleName . ".ini"

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
Stretch := IniReadCheck(settingsFile, "Settings", "Stretch","false",,1)

GlobalJoystick1 := IniReadCheck(settingsFile, "Settings", "Joystick1","joystick",,1)
GlobalJoystick2 := IniReadCheck(settingsFile, "Settings", "Joystick2","joystick",,1)
Joystick1 := IniReadCheck(settingsFile, romName, "Joystick1",GlobalJoystick1,,1)
Joystick2 := IniReadCheck(settingsFile, romName, "Joystick2",GlobalJoystick2,,1)

BezelStart("fixResMode")

If ident contains MSX
{
	TapeLoadTime := IniReadCheck(settingsFile, "Settings", "TapeLoadTime","8000",,1)

	Machine := IniReadCheck(settingsFile, romName, "Machine",ident,,1)
	TapeLoadingMethod := IniReadCheck(settingsFile, romName, "TapeLoadingMethod","RUN""CAS:""",,1)
	CLoadWaitTime := IniReadCheck(settingsFile, romName, "CLoadWaitTime","50",,1)
	PositionTape := IniReadCheck(settingsFile, romName, "PositionTape","false",,1)
	CartSlot1 := IniReadCheck(settingsFile, romName, "CartSlot1","",,1)
	CartSlot2 := IniReadCheck(settingsFile, romName, "CartSlot2","",,1)
	HoldKeyOnBoot := IniReadCheck(settingsFile, romName, "HoldKeyOnBoot","",,1)
	DualDiskLoad := IniReadCheck(settingsFile, romName, "DualDiskLoad","false",,1)
	DiskSwapDrive := IniReadCheck(settingsFile, romName, "DiskSwapDrive","A",,1)
}
Else If ident contains SVI
{
	TapeLoadTime := IniReadCheck(settingsFile, "Settings", "TapeLoadTime","8000",,1)

	Machine := IniReadCheck(settingsFile, romName, "Machine",ident,,1)
	TapeLoadingMethod := IniReadCheck(settingsFile, romName, "TapeLoadingMethod","CLOAD+RUN",,1)
	CLoadWaitTime := IniReadCheck(settingsFile, romName, "CLoadWaitTime","50",,1)
	PositionTape := IniReadCheck(settingsFile, romName, "PositionTape","false",,1)
}

;Different keyboard layouts will use different keys
ColonKey := IniReadCheck(settingsFile, "Settings", "ColonKey",":",,1)
DoubleQuoteKey := IniReadCheck(settingsFile, "Settings", "DoubleQuoteKey","""",,1)

bluemsxINI := CheckFile(emuPath . "\bluemsx.ini")

params := " /machine """ . Machine . """"

IniRead, currentFullscreen, %bluemsxINI%, config, video.windowSize
IniRead, currentStretch, %bluemsxINI%, config, video.horizontalStretch

IniRead, currentJoystick1, %bluemsxINI%, config, joy1.type
IniRead, currentJoystick2, %bluemsxINI%, config, joy2.type

; Setting Fullscreen setting in ini If it doesn't match what user wants above
; Do not use the /fullscreen CLI because If it's not specified it will use the setting from the ini file
If ( Fullscreen != "true" And currentFullScreen = "fullscreen" )
	IniWrite, normal, %bluemsxINI%, config, video.windowSize
Else If ( Fullscreen = "true" And currentFullScreen = "normal" )
	IniWrite, fullscreen, %bluemsxINI%, config, video.windowSize

; Setting Stretch setting in ini If it doesn't match what user wants above
If ( Stretch != "true" And currentStretch = "yes" )
	IniWrite, no, %bluemsxINI%, config, video.horizontalStretch
Else If ( Stretch = "true" And currentStretch = "no" )
	IniWrite, yes, %bluemsxINI%, config, video.horizontalStretch

; Setting Joystick settings If they don't match
If ( Joystick1 != currentJoystick1 )
	IniWrite, %Joystick1%, %bluemsxINI%, config, joy1.type
If ( Joystick2 != currentJoystick2 )
	IniWrite, %Joystick2%, %bluemsxINI%, config, joy2.type

params := params . " /theme """ . (If bezelPath ? "Classic" : "DIGIblue_SuiteX2") .  """"

hideEmuObj := Object("blueMSX ahk_class blueMSX",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

If romExtension in .rom,.bin,.sg
	params := params . " /rom1 """ . romPath . "\" . romName . romExtension . """"
Else If romExtension = .dsk
{
	params := params . " /diskA """ . romPath . "\" . romName . romExtension . """"
	If (DualDiskLoad = "true")
	{
		If romName contains (Disk 1
		{
			RomTableCheck()	; make sure romTable is created already so the next line can calculate correctly
			If (romtable.MaxIndex() > 1)
			{
				romName2 := romtable[2,1] ;This should be disk 2
				params := params . " /diskB """ . romName2 . """"
			}
		}
	}
}
Else If romExtension = .cas
	params := params . " /cas """ . romPath . "\" . romName . romExtension . """"

If CartSlot1
	If (CartSlot1 != "64KBexRAM")
		params := params . " /romtype1 """ . CartSlot1
If CartSlot2
	If (CartSlot2 != "64KBexRAM")
		params := params . " /romtype2 """ . CartSlot2

HideEmuStart()
Run(executable . params, emuPath)

WinWait("blueMSX ahk_class blueMSX")
WinWaitActive("blueMSX ahk_class blueMSX")

If bezelPath
	Control, Hide, , ahk_class blueMSXmenuWindow1, ahk_class blueMSX

If CartSlot1
	If (CartSlot1 = "64KBexRAM")
		PostMessage, 0x111, 41113,,,blueMSX ahk_class blueMSX
If CartSlot2
	If (CartSlot2 = "64KBexRAM")
		PostMessage, 0x111, 41263,,,blueMSX ahk_class blueMSX

If HoldKeyOnBoot
{
	Sleep, 2000 ;To make sure the boot process has started otherwise the key will be pressed too early

	If (HoldKeyOnBoot = "Ctrl")
		Send {LCtrl Down}
	Else If (HoldKeyOnBoot = "Shift")
		Send {SHIFTDOWN}

	If romExtension != .cas
	{
		Sleep, 3000 ;Wait for boot
		If (HoldKeyOnBoot = "Ctrl")
			Send {LCtrl Up}
		Else If (HoldKeyOnBoot = "Shift")
			Send {SHIFTUP}
	}
}

Sleep, 2000 ; need this otherwise Hyperspin flashes back in during fade

If romExtension = .cas
{
	;Tape loading procedures
	Sleep, %TapeLoadTime%

	delay := 50
	pressDuration := 50
	If ident contains SVI
	{
		;Spectravideo needs longer durations otherwise keys won't be captured properly
		delay := 100
		pressDuration := 100
	}

	If ident contains MSX
	{
		SetKeyDelay(delay, pressDuration)
		Send {Enter}{Enter} ;For the date screen
		Sleep, 1000 ;Wait for the BASIC prompt to appear
	}

	;Release the boot keys If needed
	If (HoldKeyOnBoot = "Ctrl")
		Send {LCtrl Up}
	Else If (HoldKeyOnBoot = "Shift")
		Send {SHIFTUP}

	If (TapeLoadingMethod)
	{
		If (PositionTape = "true")
		{
			;Wait until user selects the game
			Send ^!{F11}
			WinWait("blueMSX - Tape Position ahk_class #32770")
			WinWaitActive("blueMSX ahk_class #32770")
			WinWaitClose("blueMSX ahk_class #32770")
			BezelDraw()
			HideEmuEnd()
			FadeInExit()
		}

		If (TapeLoadingMethod = "CLOAD+RUN")
		{
			SendCommand("cload{Enter}{Wait:" . CLoadWaitTime . "}run{Enter}", 0, 500, 0, delay, pressDuration)
		} Else {
			StringReplace, TapeLoadingMethod, TapeLoadingMethod, ", %DoubleQuoteKey%, All
			StringReplace, TapeLoadingMethod, TapeLoadingMethod, :, %ColonKey%, All
			SendCommand(TapeLoadingMethod . "{Enter}", 0, 500, 0, delay, pressDuration)
		}

		If (PositionTape != "true")
		{
			BezelDraw()
			HideEmuEnd()
			FadeInExit()
		}
	}
} Else {
	BezelDraw()
	HideEmuEnd()
	FadeInExit()
}

Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


MultiGame:
	If romExtension = .cas
	{
		PostMessage, 0x111, 41500,,,blueMSX ahk_class blueMSX ;Insert Cassette
		OpenROM("Insert cassette tape ahk_class #32770",selectedRom)
	}
	Else If romExtension = .dsk
	{
		MessageToSend := If DiskSwapDrive = "A" ? "41300" : "41400"
		DialogTitle := If DiskSwapDrive = "A" ? "Insert disk image into drive A ahk_class #32770" : "Insert disk image into drive B ahk_class #32770"

		PostMessage, 0x111, %MessageToSend%,,,blueMSX ahk_class blueMSX ;Insert Disk A
		OpenROM(DialogTitle,selectedRom)
	}
Return

HaltEmu:
	disableSuspendEmu := true
	PostMessage, 0x111, 40025,,,blueMSX ahk_class blueMSX   ; Pause
Return

RestoreEmu:
	PostMessage, 0x111, 40025,,,blueMSX ahk_class blueMSX   ; Pause
Return

CloseProcess:
	FadeOutStart()
	WinClose("blueMSX ahk_class blueMSX")
Return
