MEmu = ePSXe
MEmuV =  v1.9.0
MURL = http://www.epsxe.com/
MAuthor = djvj & Shateredsoul & brolly
MVersion = 2.0.8
MCRC = 748F1FE3
iCRC = 727A7789
MID = 635038268888210842
MSystem = "Sony PlayStation"
;----------------------------------------------------------------------------
; Notes:
; epsxe can't deal with bin/cue dumps with more than one audio track if you load the cue file directly.
; For these to work you must mount the cue on daemon tools and let epsxe boot the game from there.
; You need to make sure you have a SCSI virtual drive on Daemon Tools, NOT a DT one.
; On first time use, 2 default memory card files will be created called _default_001.mcr and _default_002.mcr in emuPath\memcards
;
; Extract all your BIOS files to the bios subfolder. Then goto Config->Bios and select the bios you wish to use.
;
; Go to Config->Video then choose a plugin. Pete's OpenGL line is preffered
; Click Configure (under video plugin) and choose fullscreen and set your desired resolution. Video options/results will vary based on the plugin you choose.
;
; If you are using images with multiple tracks, set your extension to cue (make sure all your cues are correctly pointing to their tracks).
; Go to Config->Cdrom->Configure button and select the drive letter associated with your daemon tools virtual drive.
;
; ePSXe will ONLY close via Escape, it will bug out with all other forms of closing a normal program. Do not edit CloseProcess!
;
; TurboButton will only work with DX7 video plugin. Turbo key by Hypnoziz
;
; Requires at least Libs\Shared.ahk v1.1.3
;
; epsxe stores its settings in the registry @ HKEY_CURRENT_USER\Software\epsxe\config
; plugins store their settings in the registry @ HKEY_CURRENT_USER\Software\Vision Thing\PSEmu Pro
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
turboButton := IniReadCheck(settingsFile, "Settings", "turboButton","F12",,1)		; Key mapping for turbo button assignment
slowBoot := IniReadCheck(settingsFile, "Settings", "slowBoot","false",,1)			; If true, force emulator to show bios screen at boot
enableAnalog := IniReadCheck(settingsFile, "Settings", "enableAnalog","true",,1)	; If true, enables analog controls at start of game for you, so you don't have to press F5
hideEpsxeGUIs := IniReadCheck(settingsFile, "Settings", "HideePSXeGUIs","true",,1)
perGameMemCards := IniReadCheck(settingsFile, "Settings", "PerGameMemoryCards","true",,1)
disableMemoryCard1 := IniReadCheck(settingsFile, romName, "DisableMemoryCard1","false",,1)	; If true, disables memory card 1 for this game. Some games may not boot if both memory cards are inserted.
disableMemoryCard2 := IniReadCheck(settingsFile, romName, "DisableMemoryCard2","false",,1)	; If true, disables memory card 2 for this game. Some games may not boot if both memory cards are inserted.

dialogOpen := i18n("dialog.open")	; Looking up local translation

BezelStart()

If (Fullscreen = "true") {
	WriteReg("DWORD", "Vision Thing\PSEmu Pro\GPU\PeteOpenGL2", "WindowMode", 0)	; changes fullscreen setting for all 3 gpu plugins
	WriteReg("DWORD", "Vision Thing\PSEmu Pro\GPU\PeteTNT", "WindowMode", 0)
	WriteReg("DWORD", "Vision Thing\PSEmu Pro\GPU\DFXVideo", "WindowMode", 0)
} Else {
	WriteReg("DWORD", "Vision Thing\PSEmu Pro\GPU\PeteOpenGL2", "WindowMode", 1)
	WriteReg("DWORD", "Vision Thing\PSEmu Pro\GPU\PeteTNT", "WindowMode", 1)
	WriteReg("DWORD", "Vision Thing\PSEmu Pro\GPU\DFXVideo", "WindowMode", 1)
	If (bezelEnabled = "true") {
		winSize := bezelScreenHeight * 65536 + bezelScreenWidth	; convert desired windowed resolution to Decimal
		WriteReg("DWORD", "Vision Thing\PSEmu Pro\GPU\PeteOpenGL2", "WinSize", winSize)
		WriteReg("DWORD", "Vision Thing\PSEmu Pro\GPU\PeteTNT", "WinSize", winSize)
		WriteReg("DWORD", "Vision Thing\PSEmu Pro\GPU\DFXVideo", "WinSize", winSize)
	}
}

; Memory Cards
memCardPath := emuPath . "\memcards"
defaultMemCard1 := memCardPath . "\_default_001.mcr"	; defining default blank memory card for slot 1
defaultMemCard2 := memCardPath . "\_default_002.mcr"	; defining default blank memory card for slot 2
romMemCard1 := memCardPath . "\" . romName . "_001.mcr"		; defining name for rom's memory card for slot 1
romMemCard2 := memCardPath . "\" . romName . "_002.mcr"		; defining name for rom's memory card for slot 2
memcardType := If perGameMemCards = "true" ? "rom" : "default"	; define the type of memory card we will create in the below loop
IfNotExist, %memCardPath%
	FileCreateDir, %memCardPath%	; create memcard folder if it doesn't exist
Loop 2
{	IfNotExist, % %memcardType%MemCard%A_Index%
	{	FileAppend,, % %memcardType%MemCard%A_Index%		; create a new blank memory card if one does not exist
		Log("Module - Created a new blank memory card in Slot " . A_Index . ":" . %memcardType%MemCard%A_Index%)
	}
	WriteReg("SZ", "epsxe\config", "Memcard" . A_Index, %memcardType%MemCard%A_Index%)

	; Now disable a memory card if required for the game to boot properly
	memcard%A_Index%Enable := ReadReg("epsxe\config", "Memcard" . A_Index . "Enable")
	If (disableMemoryCard%A_Index% = "true")
		WriteReg("SZ", "epsxe\config", "Memcard" . A_Index . "Enable", 0)
	Else
		WriteReg("SZ", "epsxe\config", "Memcard" . A_Index . "Enable", 1)
}

hideEmuObj := Object(dialogOpen . " PSX ISO ahk_class #32770",0,"ahk_class EPSXGUI",0,"ePSXe ahk_class EPSX",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

epsxeExtension := InStr(".ccd|.cue|.img|.iso|.mdf",romExtension)	; the psx extensions supported by the emu

SetKeyDelay(50)
; turboButton := xHotKeyVarEdit(turboButton,"turboButton","~","Add")
xHotKeywrapper(turboButton,"TurboProcess")
turboEnabled = 0				; Initialize turbo state

RomTableCheck()	; make sure romTable is created already so the next line can calculate correctly
noGUI := If romTable.MaxIndex() ? "" : " -nogui" ; multidisc games will not use nogui because we need to select an option in epsxe's gui to swap discs
slowBoot := If slowBoot = "true" ? " -slowboot" : ""

If (noGUI = "" && hideEpsxeGUIs = "true") {	; for multi disc games only
	Log("Module - Starting the HideGUIWindow timer to prevent them from showing")
	SetTimer, HideGUIWindow, 10	; start watching for gui window so it can be completely hidden
}

; Mount the CD using DaemonTools
If (epsxeExtension && dtEnabled = "true" ) {
	Log("Module - Daemon Tools is enabled and " . romExtension . " is a supported DT extension")

	DaemonTools("get")	; populates the dtDriveLetter variable with the drive letter to your scsi or dt virtual drive
	currentCDRomAscii := ReadReg("epsxe\config", "CdromLetter")	; read the current setting for ePSXe's cdrom it is using
	currentCDRomLetter := Chr(currentCDRomAscii)	; converts the ascii code to a letter

	If (currentCDRomLetter = "")
		Log("Module - " . MEmu . " is not configured with a CDRom Drive")
	Else If (currentCDRomAscii = 48)
		Log("Module - " . MEmu . " is configured to read from the FirstCdrom Drive and will be updated to a proper letter instead")
	Else
		Log("Module - " . MEmu . " is configured to read from Drive " . currentCDRomLetter . ":")
	
	If (currentCDRomLetter != dtDriveLetter) {
		newCDRomAscii := Asc(dtDriveLetter)	; converts the letter to an ascii code
		WriteReg("SZ", "epsxe\config", "CdromLetter", newCDRomAscii)
		Log("Module - Updated " . MEmu . " to use Drive " . dtDriveLetter . ": for all future launches.",2)
	} Else
		Log("Module - " . MEmu . " is configured to use the correct drive already")

	DaemonTools("mount",romPath . "\" . romName . romExtension)
	HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait
	errorLvl := Run(executable . noGUI . slowBoot, emuPath)
	usedDT := 1
} Else {
	Log("Module - Sending rom to emu directly as Daemon Tools is not enabled or " . romExtension . " is not a supported DT extension.")
	HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait
	errorLvl := Run(executable . noGUI . slowBoot . " -loadiso """ . romPath . "\" . romName . romExtension . """", emuPath)
}
If errorLvl
	ScriptError("Error launching " . executable . "`, closing module.")

epsxeLaunchType := If usedDT ? "CDROM" : "ISO"	; determines which command gets sent to epsxe

If (noGUI = "") {	; for multi disc games only
	Log("Module - " . romName . " is a multi-disc game, so launching " . MEmu . " with GUI enabled so swapping can occur.")
	WinWait("ePSXe ahk_class EPSXGUI")
	If (epsxeLaunchType = "CDROM") {
		Log("Module - Telling ePSXe to run a CDROM")
		PostMessage, 0x111, 40001,,,ahk_class EPSXGUI	; Run CDROM
	} Else {
		Log("Module - Telling ePSXe to run an ISO")
		PostMessage, 0x111, 40003,,,ahk_class EPSXGUI	; Run ISO
	}
} Else
	Log("Module - " . romName . " is not a multi-disc game, so launching " . MEmu . " with GUI disabled.")

If (!usedDT && noGUI = "") {		; for some reason, epsxe still shows an open psx iso box even though it was provided on the run command when we don't also send -nogui. This handles loading the rom.
	Log("Module - " . MEmu . " GUI and DT support are both disabled. Loading rom via the Open PSX ISO window.")
	OpenROM(dialogOpen . " PSX ISO ahk_class #32770", romPath . "\" . romName . romExtension)
}	

WinWait("ePSXe ahk_class EPSX")
WinWaitActive("ePSXe ahk_class EPSX")

If (noGUI = "" && hideEpsxeGUIs = "true") {	; for multi disc games only
	Log("Module - Stopping the HideGUIWindow timer")
	SetTimer, HideGUIWindow, Off
}

BezelDraw()
HideEmuEnd()
FadeInExit()

If enableAnalog = true
{	Sleep, 1500	; necessary otherwise epsxe doesn't register the key
	Send, {F5 down}{F5 up}
}

Process("WaitClose", executable)

If usedDT
	DaemonTools("unmount")

7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


ReadReg(var1, var2) {
	RegRead, regValue, HKEY_CURRENT_USER, Software\%var1%, %var2%
	Return %regValue%
}

WriteReg(type, var1, var2, var3) {
	RegWrite, REG_%type%, HKEY_CURRENT_USER, Software\%var1%, %var2%, %var3%
}

TurboProcess:
    If (turboEnabled = 0) {
		Send, {Delete}{End}{End}{Delete}
		turboEnabled = 1
    } Else {
		Send, {Delete}{End}{Delete}
		turboEnabled = 0
    }
Return

HaltEmu:
	If Fullscreen = true
	{	PostMessage, 0x111, 40001,,,ahk_class EPSXGUI	; Go fullscreen, same as alt+enter
		Sleep, 200
	}
Return
MultiGame:
	; msgbox % "selectedRom = " . selectedRom . "`nselected game = " . currentButton . "`nmgRomPath = " . mgRomPath . "`nmgRomExt = " . mgRomExt . "`nmgRomName = "  . mgRomName
	SetKeyDelay(50)
	If usedDT
	{	DaemonTools("unmount")	; Unmount the CD from DaemonTools
		Sleep, 500	; Required to prevent  DT from bugging
		DaemonTools("mount",selectedRom)	; Mount the CD using DaemonTools
	}
	ControlSend,, {ESC down}{ESC Up}, ahk_class EPSX	; this exits the game window and brings back ePSXe's gui menu window
	If hideEpsxeGUIs = true
	{	Log("Module - Starting the HideGUIWindow timer to prevent them from showing")
		SetTimer, HideGUIWindow, 10
	}

	If (epsxeLaunchType = "CDROM") {
		Log("Module - Telling ePSXe to swap to another CDROM")
		PostMessage, 0x111, 40005,,,ahk_class EPSXGUI	; Change Disc CDROM
	} Else {
		Log("Module - Telling ePSXe to swap to another ISO")
		PostMessage, 0x111, 40006,,,ahk_class EPSXGUI	; Change Disc ISO
	}

	If usedDT
	{	WinWait("Change Disc Option ahk_class #32770")
		ControlSend,Button1,{Enter},Change Disc Option ahk_class #32770
	} Else {
		OpenROM(dialogOpen . " PSX ISO ahk_class #32770", romPath . "\" . romName . romExtension)
	}	
	If hideEpsxeGUIs = true
	{	Log("Module - Stopping the HideGUIWindow timer")
		SetTimer, HideGUIWindow, off
	}
	; If BezelEnabled
		; BezelDraw()
Return
RestoreEmu:
	WinActivate, ahk_id  %emulatorID%
	If Fullscreen = true
		PostMessage, 0x111, 40001,,,ahk_class EPSXGUI	; Go fullscreen, same as alt+enter
Return

HideGUIWindow:
	WinSet, Transparent, On, ePSXe ahk_class EPSXGUI
	WinSet, Transparent, On, Open PSX ISO ahk_class #32770	; when not using DT
	WinSet, Transparent, On, Change Disc Option ahk_class #32770	; when using DT
Return

CloseProcess:
	FadeOutStart()
	SetWinDelay, 50
	Log("Module - Sending Escape to close emulator")
	; ControlSend,, {Esc down}{Esc up}, ePSXe ahk_class EPSX ; DO NOT CHANGE
	PostMessage, 0x111, 40007,,,ahk_class EPSX	; Exit ePSXe
	If (noGUI = "") {	; for multi disc games only
		WinWait("ePSXe ahk_class EPSXGUI")
		WinClose("ePSXe ahk_class EPSXGUI")
	}
Return
