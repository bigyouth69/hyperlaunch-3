MEmu = ActiveGS
MEmuV = v3.7.1019
MURL = http://activegs.freetoolsassociation.com/
MAuthor = wahoobrian, brolly
MVersion = 2.1
MCRC = ECDD566B
iCRC = ED17ED6
mId = 635412285478387119
MSystem = "Apple II","Apple IIGS"
;------------------------------------------------------------------------------------------------------------------
; Notes:
; CLI is very limited for this Emulator.  
; To get around this, the module deletes and recreates the startup configuration xml file - default.activegsxml
;
; You will need to supply a default hard drive image that contains the ProDOS operating system.
; This is a good one ---> http://www.whatisthe2gs.apple2.org.za/files/harddrive_image.zip 
;
; If you want to keep your default default.activegsxml file after exiting then make a copy of it in the 
; emulator folder and name it original.activegsxml. This file will then be copied over on exit.
;------------------------------------------------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . (If FileExist(modulePath . "\" . systemName . ".ini") ? systemName : moduleName) . ".ini"		; use a custom systemName ini If it exists
configFile := A_MyDocuments . "\ActiveGSLocalData\activegs.conf"

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
KeepAspectRatio := IniReadCheck(settingsFile, "Settings", "KeepAspectRatio","true",,1)
externalOS := IniReadCheck(settingsFile, romName, "External_OS","false",,1)
SingleDrive := IniReadCheck(settingsFile, romName, "SingleDrive","false",,1)
DiskSwapDrive := IniReadCheck(settingsFile, romName, "DiskSwapDrive","1",,1)
HardDiskImage := IniReadCheck(settingsFile, romName, "HardDiskImage","false",,1)
Command := IniReadCheck(settingsFile, romName, "Command", "",,1)
SendCommandDelay := IniReadCheck(settingsFile, "Settings" . "|" . romName, "SendCommandDelay", "2000",,1)
WaitBetweenSends := IniReadCheck(settingsFile, "Settings" . "|" . romName, "WaitBetweenSends", "false",,1)
DefaultVideoType := IniReadCheck(settingsFile, "Settings", "VideoType", "lcd",,1)
VideoType := IniReadCheck(settingsFile, romName, "VideoType", DefaultVideoType,,1)
ColorMode := IniReadCheck(settingsFile, romName, "ColorMode", "auto",,1)
BootableHardDiskImage := IniReadCheck(settingsFile, "Settings", "BootableHardDiskImage","System 6 and Free Games.hdv",,1)

If FileExist(configFile) {
	configIni := LoadProperties(configFile)	; load the config into memory
	;Set the properties in the preferences.cfg file
	WriteProperty(configIni,"videoFX",VideoType,,,":")
	WriteProperty(configIni,"colorMode",ColorMode,,,":")
	SaveProperties(configFile,configIni)	; save changes to Preferences.cfg
} Else
	Log("activegs.conf was not found at " . configFile . ". Emulator was probably never run before")

If (SystemName = "Apple II") {
	if (romExtension = ".dsk") {
		bootslot := "6"
		SlotNumber := "6"
	} Else {
		bootslot := "5" 
		SlotNumber := "5"
	}	
} Else {
	bootslot := "5" 
	SlotNumber := "5"
}	

disk1 := " "
disk2 := " "
slot7disk1 := " "

If (%HardDiskImage%) {
	slot7disk1 := romPath . romName . romExtension
	bootslot := 7
} Else {
	Sleep, 100 ;Without this romtable comes empty (thread related?)
	RomTableCheck()	; make sure romTable is created already so the next line can calculate correctly
	If (romTable.MaxIndex() > 1) {
		If (%SingleDrive%) { ;some games require all disks to be mounted in only one drive
			disk1 := romTable[1,1]
		} Else {
			disk1 := romTable[1,1]
			disk2 := romTable[2,1]
		}
	} Else
		disk1 := romPath . "\" . romName . romExtension
}	

If (%externalOS%) {
	checkImageExists := CheckFile(emuPath . "\" . BootableHardDiskImage)	;For games without OS included, make sure it exists and error If not found
	slot7disk1 := emuPath . "\" . BootableHardDiskImage
	bootslot := 7
}

;Limited CLI, so setup XML with proper disks and correct boot sequence
ActiveGSXML := emuPath . "\default.activegsxml"
FileDelete %ActiveGSXML%  ; Build a new file on every execution

FileAppend,
(
<?xml version="1.0" encoding="iso-8859-1"?>
<config version="2">
	<format>2GS</format>
	<image slot="%SlotNumber%" disk="1" icon="">%disk1%</image>
	<image slot="%SlotNumber%" disk="2" icon="">%disk2%</image>
	<image slot="7" disk="1" icon="">%slot7disk1%</image>
	<speed>2</speed>
	<bootslot>%bootslot%</bootslot>
</config>	
), %ActiveGSXML%

BezelStart()

hideEmuObj := Object("ActiveGS ahk_class AfxFrameOrView90s",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

HideEmuStart()
Run(executable, emuPath)

WinWait("ActiveGS ahk_class AfxFrameOrView90s")
WinWaitActive("ActiveGS ahk_class AfxFrameOrView90s")

Send, {F8} ;Enable Mouse Lock

If (Fullscreen = "true") {
	;No true fullscreen is available for ActiveGS, so we fake it by maximizing the window
	;WinGetPos, WinX, WinY, WinWidth, WinHeight, A
	WinSet, Style, -0xC00000, ActiveGS ahk_class AfxFrameOrView90s ; Removes the TitleBar
	DllCall("SetMenu", uint, WinActive( "A" ), uint, 0) ; Removes the MenuBar	
	WinSet, Style, -0x40000, ActiveGS ahk_class AfxFrameOrView90s ; Removes the border of the game window
	;Sleep, 600 ; Need this otherwise the game window snaps back to size, increase If this occurs

	If (KeepAspectRatio = "true")
		MaximizeWindow("ActiveGS ahk_class AfxFrameOrView90s")
	Else
		WinMove, A, , 0, 0, A_ScreenWidth, A_ScreenHeight
} Else {
	;Resize window per user settings and center
	WindowWidth := IniReadCheck(settingsFile, "Settings", "WindowWidth","800",,1)
	WindowHeight := IniReadCheck(settingsFile, "Settings", "WindowHeight","600",,1)
	WinMove, A, , (A_ScreenWidth-WindowWidth)/2, (A_ScreenHeight-WindowHeight)/2, WindowWidth, WindowHeight
}

WaitBetweenSends := (If WaitBetweenSends = "true" ? "1" : "0")

WinWaitActive("ActiveGS ahk_class AfxFrameOrView90s")
SendCommand(Command, SendCommandDelay, "500", WaitBetweenSends)

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


MaximizeWindow(class) {
	WinGetPos, appX, appY, appWidth, appHeight, %class%
	widthMaxPercenty := ( A_ScreenWidth / appWidth )
	heightMaxPercenty := ( A_ScreenHeight / appHeight )

	If  ( widthMaxPercenty < heightMaxPercenty )
		percentToEnlarge := widthMaxPercenty
	Else
		percentToEnlarge := heightMaxPercenty

	appWidthNew := appWidth * percentToEnlarge
	appHeightNew := appHeight * percentToEnlarge
	Transform, appX, Round, %appX%
	Transform, appY, Round, %appY%
	Transform, appWidthNew, Round, %appWidthNew%, 2
	Transform, appHeightNew, Round, %appHeightNew%, 2
	appXPos := ( A_ScreenWidth / 2 ) - ( appWidthNew / 2 )
	appYPos := ( A_ScreenHeight / 2 ) - ( appHeightNew / 2 )
	WinMove, %class%,, appXPos, appYPos, appWidthNew, appHeightNew
}

HaltEmu:
	disableSuspendEmu := true
	PostMessage, 0x111, 40025,,,ActiveGS ahk_class AfxFrameOrView90s   ; Pause
Return

RestoreEmu:
	PostMessage, 0x111, 40025,,,ActiveGS ahk_class AfxFrameOrView90s   ; Pause
Return

MultiGame:
	If (SystemName = "Apple II")
		DriveToChoose := If DiskSwapDrive = "1" ? "S6D1" : "S6D2"
	Else
		DriveToChoose := If DiskSwapDrive = "1" ? "S5D1" : "S5D2"

	ControlClick,x100 y100,ActiveGS ahk_class AfxFrameOrView90s,,RIGHT,,NAPos ;Click on the window (this way it will work even If it's not on focus)

	WinWait("ActiveGS ahk_class #32770")
	WinWaitActive("ActiveGS ahk_class #32770")
	
	Control, ChooseString, %DriveToChoose%, ComboBox1, ActiveGS ahk_class #32770 ;Select the correct drive in the ComboBox
	ControlClick,Button7,ActiveGS ahk_class #32770,,,,NA
	OpenROM("Open ahk_class #32770", selectedRom)

	WinClose("ActiveGS ahk_class #32770")
Return

CloseProcess:
	FadeOutStart()
	IfExist, %emuPath%\original.activegsxml
	{
		FileCopy,%emuPath%\original.activegsxml, %emuPath%\default.activegsxml, 1
	}
	WinClose("ActiveGS ahk_class AfxFrameOrView90s")
Return
