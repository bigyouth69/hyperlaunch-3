MEmu = WinAPE
MEmuV = v2.0.a18
MURL = http://www.winape.net/
MAuthor = djvj & brolly
MVersion = 2.0
MCRC = BA48CA3E
iCRC = FC556A8E
MID = 635038268934069007
MSystem = "Amstrad GX4000","Amstrad CPC","Amstrad CPC Plus"
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
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
DiagCart := IniReadCheck(settingsFile, "Settings", "DiagCart","Arnold V Diagnostic Cartridge.cpr",,1)

DiagCart := GetFullName(DiagCart)
7z(romPath, romName, romExtension, 7zExtractPath)

;Clean any previous disk in drives
IniWrite, %A_Space%, %emuPath%\WinAPE.ini, Drives, Drive(0) ; Drive A Side A
IniWrite, %A_Space%, %emuPath%\WinAPE.ini, Drives, Drive(4) ; Drive A Side B
IniWrite, %A_Space%, %emuPath%\WinAPE.ini, Drives, Drive(1) ; Drive B Side A
IniWrite, %A_Space%, %emuPath%\WinAPE.ini, Drives, Drive(5) ; Drive B Side B

;Clean any previous cart
IniWrite, %A_Space%, %emuPath%\WinAPE.ini, ROMS, Cartridge

;If autobootrom=true it means rom will start through CLI otherwise another cart must be loaded before hand as a workaround
autobootrom=true
If romName contains No Exit
{	;No Exit won't boot if the cart is already plugged it requires another cart (not all work) to be plugged and then we need to swap them
	;we use the diagnostic cart as the booting cart since it always works
	autobootrom=false
}

;Change settings based on system name (CPC Plus games will only work if system is CPC Plus or GX4000)
If systemName = Amstrad CPC
{	IniWrite, false, %emuPath%\WinAPE.ini, Configuration, Enable Plus
	IniWrite, 0, %emuPath%\WinAPE.ini, Configuration, CRTC Type
	IniWrite, false, %emuPath%\WinAPE.ini, ROMS, Cartridge Enabled
	IniWrite, OS6128, %emuPath%\WinAPE.ini, ROMS, Lower
	IniWrite, BASIC1-1, %emuPath%\WinAPE.ini, ROMS, Upper(0)
} Else {
	IniWrite, true, %emuPath%\WinAPE.ini, Configuration, Enable Plus
	IniWrite, 3, %emuPath%\WinAPE.ini, Configuration, CRTC Type
	IniWrite, true, %emuPath%\WinAPE.ini, ROMS, Cartridge Enabled
	IniWrite, %A_Space%, %emuPath%\WinAPE.ini, ROMS, Lower
	IniWrite, %A_Space%, %emuPath%\WinAPE.ini, ROMS, Upper(0)
}

;Plug the cartridge/disk through ini file
If (systemName = "Amstrad CPC Plus" AND romExtension = "dsk")
	IniWrite, cpc_plus.cpr, %emuPath%\WinAPE.ini, ROMS, Cartridge
Else
	If autobootrom = true
		If romExtension = .zip
			IniWrite, %romPath%\%romName%%romExtension%\:%romName%.cpr, %emuPath%\WinAPE.ini, ROMS, Cartridge
		Else If romExtension = .cpr
			IniWrite, %romPath%\%romName%%romExtension%, %emuPath%\WinAPE.ini, ROMS, Cartridge
	Else
		IniWrite, %DiagCart%, %emuPath%\WinAPE.ini, ROMS, Cartridge

;Set Fullscreen
If (Fullscreen = "true" && autobootrom = "true")
	IniWrite, true, %emuPath%\WinAPE.ini, Configuration, Full Screen
Else
	IniWrite, false, %emuPath%\WinAPE.ini, Configuration, Full Screen

;Set Numlock since you should have your joystick configurations made for this
SetNumlockState, off

;MultiDisk loading, this will load the first 2 disks into drives A and B since some games can read from both drives and therefore 
;the user won't need to change disks through the MG menu.
If (romName contains "(Disk 1" OR romName contains "(Side A")
{	;If the user boots any disk rather than the first one, multi disk support must be done through HyperLaunch MG menu
	multipartTable := CreateRomTable(multipartTable)

	If multipartTable.MaxIndex() 
	{	;Make the searches case insensitive
		original_case_sense := A_StringCaseSense
		StringCaseSense, Off

		;Has multi part
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
		;Restore original StringCaseSense
		StringCaseSense, %original_case_sense%
	}
}

Run(executable . " """ . romPath . "\" . romName . romExtension . """ /A", emuPath)

WinWait("ahk_class TfrmCover") ; waiting for logo to show
WinHide, ahk_class TfrmCover ; making logo dissappear!

WinWait("Windows Amstrad Plus Emulator ahk_class TfrmEmu")
WinWaitActive("Windows Amstrad Plus Emulator ahk_class TfrmEmu")

If autobootrom != true
{	;Lets swap carts to load No Exit
	Sleep 500 ;Wait just an instant for the diagnostic cart to load
	Send ^{F3}
	WinWait("Open ahk_class #32770")
	WinWaitActive("Open ahk_class #32770")
	Sleep, 100
	ControlSetText, Edit1, %romPath%\%romName%%romExtension%, Open ahk_class #32770
	Send {Enter}
	Sleep, 100
	If Fullscreen = true
		Send {F10} ;Go Fullscreen
}

FadeInExit()
Process("WaitClose",executable)
7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("ahk_class TfrmEmu")
Return
