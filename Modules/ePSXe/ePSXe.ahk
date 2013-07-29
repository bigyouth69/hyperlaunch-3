MEmu = ePSXe
MEmuV =  v1.8.0
MURL = http://www.epsxe.com/
MAuthor = djvj & Shateredsoul & brolly
MVersion = 2.0.3
MCRC = 8E174373
iCRC = D6E3720
MID = 635038268888210842
MSystem = "Sony PlayStation"
;----------------------------------------------------------------------------
; Notes:
; epsxe can't deal with bin/cue dumps with more than one audio track if you load the cue file directly.
; For these to work you must mount the cue on daemon tools and let epsxe boot the game from there.
; You need to make sure you have a SCSI virtual drive on Daemon Tools, NOT a DT one.
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
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
turboButton := IniReadCheck(settingsFile, "Settings", "turboButton","F12",,1)		; Key mapping for turbo button assignment
slowBoot := IniReadCheck(settingsFile, "Settings", "slowBoot","false",,1)			; If true, force emulator to show bios screen at boot
enableAnalog := IniReadCheck(settingsFile, "Settings", "enableAnalog","true",,1)	; If true, enables analog controls at start of game for you, so you don't have to press F5

7z(romPath, romName, romExtension, 7zExtractPath)

epsxeExtension := InStr(".cue|.img|.iso|.mdf",romExtension)	; the psx extensions supported by the emu

SetKeyDelay, 50
; turboButton := xHotKeyVarEdit(turboButton,"turboButton","~","Add")
xHotKeywrapper(turboButton,"TurboProcess")
turboEnabled = 0				; Initialize turbo state

slowBoot := If (slowBoot = "true") ? "-slowboot" : ""

; Mount the CD using DaemonTools
If (epsxeExtension && dtEnabled = "true" ) {
	Log("Module - Daemon Tools is enabled and " . romExtension . " is a supported DT extension.")
	DaemonTools("mount",romPath . "\" . romName . romExtension)
	errorLvl := Run(executable . " -nogui " . slowBoot, emuPath)
} Else {
	Log("Module - Sending rom to emu directly as Daemon Tools is not enabled or " . romExtension . " is not a supported DT extension.")
	errorLvl := Run(executable . " -nogui " . slowBoot . " -loadiso """ . romPath . "\" . romName . romExtension . """", emuPath)
}

If errorLvl != 0
	ScriptError("Error launching " . executable . "`, closing module.")

WinWait("ePSXe ahk_class EPSX")
WinWaitActive("ePSXe ahk_class EPSX")

FadeInExit()

If enableAnalog = true
{	Sleep, 1500	; necessary otherwise epsxe doesn't register the key
	Send, {F5 down}{F5 up}
}

Process("WaitClose", executable)

If (epsxeExtension && dtEnabled = "true" )
	DaemonTools("unmount")

7zCleanUp()
FadeOutExit()
ExitModule()


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
	Send, !{Enter}
	Sleep, 200
Return
MultiGame:
	; msgbox % "selectedRom = " . selectedRom . "`nselected game = " . currentButton . "`nmgRomPath = " . mgRomPath . "`nmgRomExt = " . mgRomExt . "`nmgRomName = "  . mgRomName
	; Unmount the CD from DaemonTools
	If ( romExtension = ".cue" && dtEnabled = "true" )
		DaemonTools("unmount")
	Sleep, 500	; Required to prevent  DT from bugging
	; Mount the CD using DaemonTools
	If ( romExtension = ".cue" && dtEnabled = "true" )
		DaemonTools("mount",selectedRom)
Return
RestoreEmu:
	WinActivate, ahk_id  %emulatorID%
	Send, !{Enter}
Return

CloseProcess:
	FadeOutStart()
	SetWinDelay, 50
	Log("Module - Sending Escape to close emulator")
	; WinClose("ePSXe ahk_class EPSX")	; epsxe remains running as a process when this is used
	Send, {Esc down}{Esc up} ; DO NOT CHANGE
Return
