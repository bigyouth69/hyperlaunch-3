MEmu = PCSXR
MEmuV =  r87054
MURL = http://pcsxr.codeplex.com/
MAuthor = djvj
MVersion = 2.0.4
MCRC = B3C7605B
iCRC = 30C9905C
MID = 635038268913822158
MSystem = "Sony PlayStation"
;----------------------------------------------------------------------------
; Notes:
; To use CUE files: (NOTE: no other file types are tested with this module)
; In the emu, set your Cdrom plugin to P.E.OpS CDR Driver 1.4 and press configure
; I set Interface to "W2K/XP - IOCTL scsi commands"
; Set Drive to match your Daemon Tools scsi drive letter and mount a PSX disc in it, then click "Try auto-detection" and Read Mode should be filled for you.
; I set Caching to Async, but haven't done much testing. If something else is better please let me know.
; Module supports sending cue files directly to the emu simply by turning off Daemon Tools in HLHQ
; On first time use, 2 default memory card files will be created called _default_001.mcr and _default_002.mcr in emuPath\memcards
;
; Sound
; I had to change the Sound mode to High Compatibility to get rid of scratchy sounds
;
; Graphics
; If you have no video with OpenGL Driver, try using Pete's OpenGL2 plugin
; Fullscreen is controlled by the setting in HLHQ to give quick access to testing and bezel support
; Resolution can changed in the emu's GPU Plugin config.
;
; MultiGame
; Module only supports swapping discs when using Daemon Tools
;
; Emu settings are stored in the registry @ HKEY_CURRENT_USER\Software\Pcsxr
; GPU settings are stored in the registry @ HKEY_CURRENT_USER\Software\Vision Thing\PSEmu Pro\GPU\
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
NoEmuGUI := IniReadCheck(settingsFile, "Settings", "NoEmuGUI","true",,1)			; Remove all GUI elements from the emu
sysParams := IniReadCheck(settingsFile, "Settings", "Params", A_Space,,1)
perGameMemCards := IniReadCheck(settingsFile, "Settings", "PerGameMemoryCards","true",,1)
romParams := IniReadCheck(settingsFile, romName, "Params", A_Space,,1)

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
origMemCard1 := memCardPath . "\Mcd001.mcr"	; defining original memory card for slot 1
origMemCard2 := memCardPath . "\Mcd002.mcr"	; defining original memory card for slot 2
defaultMemCard1 := memCardPath . "\_default_001.mcr"	; defining default blank memory card for slot 1
defaultMemCard2 := memCardPath . "\_default_002.mcr"	; defining default blank memory card for slot 2
romMemCard1 := memCardPath . "\" . romName . "_001.mcr"		; defining name for rom's memory card for slot 1
romMemCard2 := memCardPath . "\" . romName . "_002.mcr"		; defining name for rom's memory card for slot 2
memcardType := If perGameMemCards = "true" ? "rom" : "default"	; define the type of memory card we will create in the below loop
IfNotExist, %memCardPath%
	FileCreateDir, %memCardPath%	; create memcard folder if it doesn't exist
Loop 2
{	IfExist, % origMemCard%A_Index%
		FileMove, % origMemCard%A_Index%, % defaultMemCard%A_Index%, 1		; rename the original memory cards to the new defaults if they exist
	If perGameMemCards = true
	{	IfNotExist, % romMemCard%A_Index%
		{	FileCopy, % defaultMemCard%A_Index%, % romMemCard%A_Index%		; copy the default to a new rom named memory card if one does not exist
			Log("Module - Created a new blank memory card in Slot " . A_Index . ":" . romMemCard%A_Index%)
		}
		WriteReg("SZ", "Pcsxr", "Mcd" . A_Index, romMemCard%A_Index%)
	} Else
		WriteReg("SZ", "Pcsxr", "Mcd" . A_Index, defaultMemCard%A_Index%)

	; Now disable a memory card if required for the game to boot properly
	; memcard%A_Index%Enable := ReadReg("Pcsxr\config", "Memcard" . A_Index . "Enable")
	; If (disableMemoryCard%A_Index% = "true")
		; WriteReg("SZ", "Pcsxr", "Memcard" . A_Index . "Enable", 0)
	; Else
		; WriteReg("SZ", "Pcsxr", "Memcard" . A_Index . "Enable", 1)
}

If (dtEnabled != "true" && (mgEnabled = "true" || ChangeDisc_Menu_Enabled = "true")) {
	Log("Module - Turning off MultiGame and HyperPause Change Disc Menu support as the module only supports swapping discs with Daemon Tools and it is disabled",2)
	mgEnabled = false	; turn off MultiGame
	ChangeDisc_Menu_Enabled = false	; turn off change disc menu in HyperPause
}

7z(romPath, romName, romExtension, 7zExtractPath)

noEmuGUI := If NoEmuGUI = "true" ? "-nogui" : ""
cdType := If dtEnabled = "true" ? "-runcd" : "-cdfile"
cdPath := If dtEnabled = "true" ? "" : """" . romPath . "\" . romName . romExtension . """"
sysParams := If sysParams != ""  ? sysParams : ""
romParams := If romParams != ""  ? romParams : ""

; Mount the CD using DaemonTools
If dtEnabled = true
	DaemonTools("mount", romPath . "\" . romName . romExtension)

Run(executable . A_Space .  noEmuGUI . A_Space . sysParams . A_Space . romParams . A_Space . cdType . A_Space .  cdPath, emuPath)

WinWait("ahk_class PCSXR Main")
WinWaitActive("ahk_class PCSXR Main")

BezelDraw()
FadeInExit()
Process("WaitClose", executable)

If dtEnabled = true
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

MultiGame:
	; msgbox % "selectedRom = " . selectedRom . "`nselected game = " . currentButton . "`nmgRomPath = " . mgRomPath . "`nmgRomExt = " . mgRomExt . "`nmgRomName = "  . mgRomName
	; Unmount the CD from DaemonTools
	DaemonTools("unmount")
	Sleep, 500	; Required to prevent  DT from bugging
	; Mount the CD using DaemonTools
	DaemonTools("mount",selectedRom)
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class PCSXR Main")
Return
