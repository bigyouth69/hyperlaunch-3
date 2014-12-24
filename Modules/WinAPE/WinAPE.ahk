MEmu = WinAPE
MEmuV = v2.0.a18
MURL = http://www.winape.net/
MAuthor = djvj, brolly & wahoobrian
MVersion = 2.0.2
MCRC = AEE6BF5E
iCRC = 9CF274AA
MID = 635038268934069007
MSystem = "Amstrad GX4000","Amstrad CPC"
;----------------------------------------------------------------------------
; Notes:
; You cannot pass a game name to the emu through CLI, but the emu will autolaunch the game set in its ini file.
; Run the exe manually and goto Settings->General, check "Disable Automatic Update"
; On the Display tab, check "Hide Control Panel", "Hide Menus" and "No Right-Click Menu". "Linear Palette" will slightly darken image if you enable it.
; On the Sound tab, check "44 kHz" and "16 bit".
; On the Input tab, set your controls and hit OK.
; Press F10 to turn on fullscreen then ALT+F4 to exit and save your settings.
; Make sure your rom extension is either zip or cpr, not both.
; Make sure you have Arnold V Diagnostic Cartridge.cpr rom on WinApe\ROM folder if you want to run No Exit.
; You can use any other CPCPlus cart if you prefer, in that case make sure you edit the variable below to the correct name.
;
; Default WinAPE disk swap/flip keys:
; Shift+F1 will flip Disk on Drive A:
; Shift+F2 will flip Disk on Drive B:
; Shift+Ctrl+F3 will swap Disks on Drive A: and B:
;
; Tape support (.cdt files):
; WinApe has limited tape support, some games might not load and the ones that do load will load at real time! So it can take several minutes for 
; a tape game to load. It's highly suggested to use CPCE instead to play tape games.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

IfExist, % modulePath . "\" . systemName . ".ini"	; use a custom systemName ini If it exists
	settingsFile := modulePath . "\" . systemName . ".ini"
Else
	settingsFile := modulePath . "\" . moduleName . ".ini"

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
DiagCart := IniReadCheck(settingsFile, "Settings", "DiagCart","Arnold V Diagnostic Cartridge.cpr",,1)
driveErrorFix := IniReadCheck(settingsFile, "Settings", "DriveErrorFix","false",,1)

Command := IniReadCheck(settingsFile, romName, "Command","",,1)
SendCommandDelay := IniReadCheck(settingsFile, romName, "SendCommandDelay", "1000",,1)
MachineType := IniReadCheck(settingsFile, romName, "MachineType", "CPC",,1)

DiagCart := GetFullName(DiagCart)

dialogOpen := i18n("dialog.open")	; Looking up local translation
hideEmuObj := Object(dialogOpen . " ahk_class #32770",0,"ahk_class TfrmCover",0,"Windows Amstrad Plus Emulator ahk_class TfrmEmu",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later

7z(romPath, romName, romExtension, 7zExtractPath)

BezelStart()

; Clean any previous disk in drives
IniWrite, %A_Space%, %emuPath%\WinAPE.ini, Drives, Drive(0) ; Drive A Side A
IniWrite, %A_Space%, %emuPath%\WinAPE.ini, Drives, Drive(4) ; Drive A Side B
IniWrite, %A_Space%, %emuPath%\WinAPE.ini, Drives, Drive(1) ; Drive B Side A
IniWrite, %A_Space%, %emuPath%\WinAPE.ini, Drives, Drive(5) ; Drive B Side B

; Clean any previous cart
IniWrite, %A_Space%, %emuPath%\WinAPE.ini, ROMS, Cartridge

; Clean any previous tape
IniWrite, %A_Space%, %emuPath%\WinAPE.ini, Tape, File Name

; autobootrom=true means rom will start through CLI otherwise another cart must be loaded before it as a workaround
autobootrom=true

; Set Fullscreen
If (Fullscreen = "true" && autobootrom = "true")
	IniWrite, true, %emuPath%\WinAPE.ini, Configuration, Full Screen
Else
	IniWrite, false, %emuPath%\WinAPE.ini, Configuration, Full Screen

; Set Numlock since you should have your joystick configurations made for this
SetNumlockState, off

If (systemName = "Amstrad GX4000") {
	Gosub, CPCPlus
} Else {
	; Change settings based on system name (CPC Plus games will only work if system is CPC Plus or GX4000)
	IfInString, romName, (CPC+) 
	{	
		Gosub, CPCPlus
	}
	Else If (MachineType = "CPC+") {
		Gosub, CPCPlus
	}
	Else {
		IniWrite, false, %emuPath%\WinAPE.ini, Configuration, Enable Plus
		IniWrite, 0, %emuPath%\WinAPE.ini, Configuration, CRTC Type
		IniWrite, false, %emuPath%\WinAPE.ini, ROMS, Cartridge Enabled
		IniWrite, OS6128, %emuPath%\WinAPE.ini, ROMS, Lower
		IniWrite, BASIC1-1, %emuPath%\WinAPE.ini, ROMS, Upper(0)

		If autobootrom = true
			If romExtension = .cpr
			{
				IniWrite, %romPath%\%romName%%romExtension%, %emuPath%\WinAPE.ini, ROMS, Cartridge
			}
			Else If romExtension = .cdt
			{
				IniWrite, %romPath%\%romName%%romExtension%, %emuPath%\WinAPE.ini, Tape, File Name
			}
	}
	
	; MultiDisk loading, this will load the first 2 disks into drives A and B since some games can read from both drives and therefore 
	; the user won't need to change disks through the MG menu.
	; If (romName contains "(Disk 1" OR romName contains "(Side A")
	If (InStr(romName, "(Disk 1") || InStr(romName, "(Side A"))
	{	; If the user boots any disk rather than the first one, multi disk support must be done through HyperLaunch 	MG menu
		multipartTable := CreateRomTable(multipartTable)

		If multipartTable.MaxIndex() 
		{	; Make the searches case insensitive
			original_case_sense := A_StringCaseSense
			StringCaseSense, Off

			; Has multi part
			for index, element in multipartTable 
			{	current_rom := multipartTable[A_Index,1]

				driveA_sideA = (Side A,(Disk 1),(Disk 1 Side A
				driveA_sideB = (Side B,(Disk 1 Side B
				driveB_sideA = (Disk 2),(Disk 2 Side A
				driveB_sideB = (Disk 2 Side B

				If current_rom contains %driveA_sideA%
					IniWrite, %current_rom%, %emuPath%\WinAPE.ini, Drives, Drive(0)
				Else If current_rom contains %driveA_sideB%
					IniWrite, %current_rom%, %emuPath%\WinAPE.ini, Drives, Drive(4)
				Else If current_rom contains %driveB_sideA%
					IniWrite, %current_rom%, %emuPath%\WinAPE.ini, Drives, Drive(1)
				Else If current_rom contains %driveB_sideB%
					IniWrite, %current_rom%, %emuPath%\WinAPE.ini, Drives, Drive(5)
			}
			; Restore original StringCaseSense
			StringCaseSense, %original_case_sense%
		}
	}
}

HideEmuStart()
Run(executable . " """ . romPath . "\" . romName . romExtension . """ /A", emuPath)

If driveErrorFix = true
{
	WinWait("WinApe.exe - Drive Not Ready ahk_class #32770")
	WinActivate, WinApe.exe - Drive Not Ready ahk_class #32770
	ControlClick, Button1, WinApe.exe - Drive Not Ready ahk_class #32770
}

WinWait("ahk_class TfrmCover") ; waiting for logo to show
WinHide, ahk_class TfrmCover ; making logo dissappear!

; Close Information window, if it exists
Loop, 10 {
	If WinExist("ahk_class TMessageForm") {
		WinActivate
		Send, {Enter}
		break
	}
	Else
		Sleep, 50
}

WinWait("Windows Amstrad Plus Emulator ahk_class TfrmEmu")
WinWaitActive("Windows Amstrad Plus Emulator ahk_class TfrmEmu")
BezelDraw()

If (autobootrom != "true")
{	; Lets swap carts to load No Exit
	Sleep 500	; Wait just an instant for the diagnostic cart to load
	ControlSend,, ^{F3},Windows Amstrad Plus Emulator ahk_class TfrmEmu	; Open CPC Plus Cartridge File
	OpenROM(dialogOpen . " ahk_class #32770", romPath . "\" . romName . romExtension)
	Sleep, 100
	If Fullscreen = true
		ControlSend,, {F10},Windows Amstrad Plus Emulator ahk_class TfrmEmu	; Fullscreen
}

; US keyboards need to send @ to type " while most EUR keyboards type "
; Both are located in the 2 key so we send Shift+2 instead so it will work on all cases
StringReplace, Command, Command, ", {Shift Down}2{Shift Up}, All

SendCommand(Command, SendCommandDelay)

If romExtension = .cdt
{	; Tape Loading
	SendCommand("{Shift Down}{vkBBsc01A}{Shift Up}tape{Enter}{Wait:200}run{Shift Down}2{Shift Up}{Enter}")
	PostMessage, 0x111, 23,,,Windows Amstrad Plus Emulator ahk_class TfrmEmu ;Play Tape
	SendCommand("{Enter}")
}

HideEmuEnd()
FadeInExit()
Process("WaitClose",executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CPCPlus:
	IniWrite, true, %emuPath%\WinAPE.ini, Configuration, Enable Plus
	IniWrite, 3, %emuPath%\WinAPE.ini, Configuration, CRTC Type
	IniWrite, true, %emuPath%\WinAPE.ini, ROMS, Cartridge Enabled
	IniWrite, %A_Space%, %emuPath%\WinAPE.ini, ROMS, Lower
	IniWrite, %A_Space%, %emuPath%\WinAPE.ini, ROMS, Upper(0)

	If romExtension = .dsk
		IniWrite, cpc_plus.cpr, %emuPath%\WinAPE.ini, ROMS, Cartridge
	Else If romExtension = .cpr
		IniWrite, %romPath%\%romName%%romExtension%, %emuPath%\WinAPE.ini, ROMS, Cartridge

	; If autobootrom=true it means rom will start through CLI otherwise another cart must be loaded before hand as a workaround
	If romName contains No Exit 
	{
		; No Exit won't boot if the cart is already plugged it requires another cart (not all work) to be plugged and then we need to swap them
		; We use the diagnostic cart as the booting cart since it always works
		autobootrom=false
		IniWrite, %DiagCart%, %emuPath%\WinAPE.ini, ROMS, Cartridge
	}	
Return

HaltEmu:
	disableSuspendEmu := true
	SetTimer, HideDebugWindow, 2
	SendMessage, 0x0000bd00, 0x00000076, 410001,,Windows Amstrad Plus Emulator ahk_class TfrmEmu	; Pause
	Log("Module - Sent a message to pause " . MEmu . (If ErrorLevel = 1 ? " and returned successful!" : ", but it failed with an error code of " . ErrorLevel))
Return
RestoreEmu:
	SendMessage, 0x0000bd00, 0x00000078, 430001,,Windows Amstrad Plus Emulator ahk_class TfrmEmu	; Run
	Log("Module - Sent a message to resume " . MEmu . (If ErrorLevel = 1 ? " and returned successful!" : ", but it failed with an error code of " . ErrorLevel))
	SetTimer, HideDebugWindow, Off
Return

HideDebugWindow:
	IfWinNotExist, WinAPE Debugger ahk_class TfrmDebug
		Return
	Else
		WinSet, Transparent, 0, WinAPE Debugger ahk_class TfrmDebug
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class TfrmEmu")
Return
