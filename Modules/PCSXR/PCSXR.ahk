MEmu = PCSXR
MEmuV =  r80440
MURL = http://pcsxr.codeplex.com/
MAuthor = djvj
MVersion = 2.0.2
MCRC = C4827D3A
iCRC = 60E37EB3
MID = 635038268913822158
MSystem = "Sony PlayStation"
;----------------------------------------------------------------------------
; Notes:
; To use CUE files: (NOTE no other file types are supported by this module)
; In the emu, set your Cdrom plugin to SaPu's CD-ROM Plugin.
;
; If you have no video with OpenGL plugin, use Pete's OpenGL2 plugin
; Fullscreen is controlled by the setting in HLHQ to give quick access to testing
; Resolution can changed in the emu's GPU Plugin config.
;
; Emu settings are stored in the registry @ HKEY_CURRENT_USER\Software\Pcsxr
; Pete's OpenGL2 settings are stored in the registry @ HKEY_CURRENT_USER\Software\Vision Thing\PSEmu Pro\GPU\PeteOpenGL2
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)		; For OpenGL2 only
NoEmuGUI := IniReadCheck(settingsFile, "Settings", "NoEmuGUI","true",,1)			; Remove all GUI elements from the emu
sysParams := IniReadCheck(settingsFile, "Settings", "Params", A_Space,,1)
romParams := IniReadCheck(settingsFile, romName, "Params", A_Space,,1)

; Setting Fullscreen setting in registry if it doesn't match what user wants above
currentFullScreen := ReadReg("WindowMode")
If ( Fullscreen != "true" And currentFullScreen = 0 )
	WriteReg("WindowMode", 1)
Else If ( Fullscreen = "true" And currentFullScreen = 1 )
	WriteReg("WindowMode", 0)

7z(romPath, romName, romExtension, 7zExtractPath)

noEmuGUI := (If NoEmuGUI = "true" ? ("-nogui") : (""))
cdType := (If romExtension = ".cue" ? ("-runcd") : ("-cdfile"))
cdPath := (If romExtension = ".cue" ? ("") : ("""" . romPath . "\" . romName . romExtension . """"))
sysParams := If sysParams != ""  ? sysParams : ""
romParams := If romParams != ""  ? romParams : ""

; Mount the CD using DaemonTools
If ( romExtension = ".cue" && dtEnabled = "true" )
	DaemonTools("mount",romPath . "\" . romName . romExtension)

Run(executable . A_Space .  noEmuGUI . A_Space . sysParams . A_Space . romParams . A_Space . cdType . A_Space .  cdPath, emuPath)

WinWait("AHK_class PCSXR Main")
WinWaitActive("AHK_class PCSXR Main")

FadeInExit()
Process("WaitClose", executable)

If ( romExtension = ".cue" && dtEnabled = "true" )
	DaemonTools("unmount")

7zCleanUp()
FadeOutExit()
ExitModule()


ReadReg(var1) {
	RegRead, regValue, HKEY_CURRENT_USER, Software\Vision Thing\PSEmu Pro\GPU\PeteOpenGL2, %var1%
	Return %regValue%
}

WriteReg(var1, var2) {
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Vision Thing\PSEmu Pro\GPU\PeteOpenGL2, %var1%, %var2%
}

MultiGame:
	; msgbox % "selectedRom = " . selectedRom . "`nselected game = " . currentButton . "`nmgRomPath = " . mgRomPath . "`nmgRomExt = " . mgRomExt . "`nmgRomName = "  . mgRomName
	; Unmount the CD from DaemonTools
	If romExtension = .cue
		DaemonTools("unmount")
	Sleep, 500	; Required to prevent  DT from bugging
	; Mount the CD using DaemonTools
	If romExtension = .cue
		DaemonTools("mount",selectedRom)
Return

CloseProcess:
	FadeOutStart()
	WinClose("AHK_class PCSXR Main")
Return
