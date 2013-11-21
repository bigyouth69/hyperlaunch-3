MEmu = ePSXe
MEmuV =  v1.8.0
MURL = http://www.epsxe.com/
MAuthor = djvj & Shateredsoul & brolly
MVersion = 2.0.5
MCRC = 657DFC8B
iCRC = AFD664B0
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
MLanguage := IniReadCheck(settingsFile, "Settings", "MLanguage","English",,1)		; If English, dialog boxes look for the word "Open" and if Spanish/Portuguese, looks for "Abrir"
perGameMemCards := IniReadCheck(settingsFile, "Settings", "PerGameMemoryCards","true",,1)
disableMemoryCard1 := IniReadCheck(settingsFile, romName, "DisableMemoryCard1","false",,1)	; If true, disables memory card 1 for this game. Some games may not boot if both memory cards are inserted.
disableMemoryCard2 := IniReadCheck(settingsFile, romName, "DisableMemoryCard2","false",,1)	; If true, disables memory card 2 for this game. Some games may not boot if both memory cards are inserted.

mLang := Object("English","Open","Spanish/Portuguese","Abrir")
winLang := mLang[MLanguage]	; search object for the MLanguage associated to the user's language
If !winLang
	ScriptError("Your chosen language is: """ . MLanguage . """. It is not one of the known supported languages for this module: " . moduleName)

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

7z(romPath, romName, romExtension, 7zExtractPath)

epsxeExtension := InStr(".ccd|.cue|.img|.iso|.mdf",romExtension)	; the psx extensions supported by the emu

SetKeyDelay, 50
; turboButton := xHotKeyVarEdit(turboButton,"turboButton","~","Add")
xHotKeywrapper(turboButton,"TurboProcess")
turboEnabled = 0				; Initialize turbo state

slowBoot := If slowBoot = "true" ? " -slowboot" : ""
noGUI := If romTable.MaxIndex() ? "" : " -nogui" ; multidisc games will not use nogui because we need to select an option in epsxe's gui to swap discs

If (noGUI = "" && hideEpsxeGUIs = "true")	; for multi disc games only
	SetTimer, HideGUIWindow, 10	; start watching for gui window so it can be completely hidden

; Mount the CD using DaemonTools
If (epsxeExtension && dtEnabled = "true" ) {
	Log("Module - Daemon Tools is enabled and " . romExtension . " is a supported DT extension.")
	DaemonTools("mount",romPath . "\" . romName . romExtension)
	errorLvl := Run(executable . noGUI . slowBoot, emuPath)
	usedDT := 1
} Else {
	Log("Module - Sending rom to emu directly as Daemon Tools is not enabled or " . romExtension . " is not a supported DT extension.")
	errorLvl := Run(executable . noGUI . slowBoot . " -loadiso """ . romPath . "\" . romName . romExtension . """", emuPath)
}

If errorLvl != 0
	ScriptError("Error launching " . executable . "`, closing module.")

epsxeLaunchType := If usedDT ? "CDROM" : "ISO"	; determines which command gets sent to epsxe

If (noGUI = "") {	; for multi disc games only
	Log("Module - " . romName . " is a multi-disc game, so launching " . MEmu . " with GUI enabled so swapping can occur.")
	WinWait("ePSXe ahk_class EPSXGUI")
	WinMenuSelectItem,  ahk_class EPSXGUI,, File, Run %epsxeLaunchType%	; run CDROM or ISO
} Else
	Log("Module - " . romName . " is not a multi-disc game, so launching " . MEmu . " with GUI disabled.")

epsxeOpenWindow := winLang . " PSX ISO ahk_class #32770"
If (!usedDT && noGUI = "") {		; for some reason, epsxe still shows an open psx iso box even though it was provided on the run command when we don't also send -nogui. This handles loading the rom.
	Log("Module - " . MEmu . " GUI and DT support are both disabled. Loading rom via the Open PSX ISO window.")
	WinWait(epsxeOpenWindow)
	Loop {
		ControlGetText, edit1Text, Edit1, %epsxeOpenWindow%
		If (edit1Text = romPath . "\" . romName . romExtension)
			Break
		Sleep, 100
		ControlSetText, Edit1, %romPath%\%romName%%romExtension%, %epsxeOpenWindow%
	}
	ControlSend, Button1, {Enter}, %epsxeOpenWindow% ; Select Open
}	

WinWait("ePSXe ahk_class EPSX")
WinWaitActive("ePSXe ahk_class EPSX")

If (noGUI = "" && hideEpsxeGUIs = "true")	; for multi disc games only
	SetTimer, HideGUIWindow, Off

BezelDraw()
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
	{	Send, !{Enter}
		Sleep, 200
	}
Return
MultiGame:
	; msgbox % "selectedRom = " . selectedRom . "`nselected game = " . currentButton . "`nmgRomPath = " . mgRomPath . "`nmgRomExt = " . mgRomExt . "`nmgRomName = "  . mgRomName
	SetKeyDelay, 50
	If usedDT
	{	DaemonTools("unmount")	; Unmount the CD from DaemonTools
		Sleep, 500	; Required to prevent  DT from bugging
		DaemonTools("mount",selectedRom)	; Mount the CD using DaemonTools
	}
	ControlSend,, {ESC down}{ESC Up}, ahk_class EPSX
	If hideEpsxeGUIs = true
		SetTimer, HideGUIWindow, 10
	WinMenuSelectItem,  ahk_class EPSXGUI,, File, Change Disc, %epsxeLaunchType%	; change CDROM or ISO
	If usedDT
	{	WinWait("Change Disc Option ahk_class #32770")
		ControlSend,Button1,{Enter},Change Disc Option ahk_class #32770
	} Else {
		WinWait(epsxeOpenWindow)
		Loop {
			ControlGetText, edit1Text, Edit1, %epsxeOpenWindow% 
			If (edit1Text = selectedRom)
				Break
			Sleep, 100
			ControlSetText, Edit1, %selectedRom%, %epsxeOpenWindow%
		}
		ControlSend, Button1, {Enter}, %epsxeOpenWindow% ; Select Open
	}	
	If hideEpsxeGUIs = true
		SetTimer, HideGUIWindow, off
Return
RestoreEmu:
	WinActivate, ahk_id  %emulatorID%
	If Fullscreen = true
		Send, !{Enter}
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
	ControlSend,, {Esc down}{Esc up}, ePSXe ahk_class EPSX ; DO NOT CHANGE
	If (noGUI = "") {	; for multi disc games only
		WinWait("ePSXe ahk_class EPSXGUI")
		WinClose("ePSXe ahk_class EPSXGUI")
	}
Return
