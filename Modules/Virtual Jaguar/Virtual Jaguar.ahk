MEmu = Virtual Jaguar
MEmuV =  v2.1.2
MURL = http://icculus.org/virtualjaguar/
MAuthor = djvj & brolly
MVersion = 2.1.0
MCRC = C1F665E4
iCRC = 31619F7D
MID = 635038268931827139
MSystem = "Atari Jaguar"
;----------------------------------------------------------------------------
; Notes:
; The Atari Jaguar bios "jagboot.rom" must exist in the eeproms emulator folder
; The emu stores its config in the registry @ HKEY_CURRENT_USER\Software\Underground Software\Virtual Jaguar
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
WindowZoom := IniReadCheck(settingsFile, "Settings", "WindowZoom","3",,1)
Filter := IniReadCheck(settingsFile, "Settings", "Filter","0",,1)

VideoMode := IniReadCheck(settingsFile, "Settings" . "|" . romName, "VideoMode","0",,1)
GPUEnabled := IniReadCheck(settingsFile, "Settings" . "|" . romName, "GPUEnabled","true",,1)
DSPEnabled := IniReadCheck(settingsFile, "Settings" . "|" . romName, "DSPEnabled","true",,1)
EnableJaguarBIOS := IniReadCheck(settingsFile, "Settings" . "|" . romName, "EnableJaguarBIOS","true",,1)
UseFastBlitter := IniReadCheck(settingsFile, romName, "useFastBlitter","false",,1)

If bezelEnabled
{
	If (Fullscreen = "true") {
		disableForceFullscreen := true
		disableWinMove := true
		disableHideTitleBar := true
		disableHideToggleMenu := true
		disableHideBorder := true
		BezelStart()
	} Else {
		disableHideToggleMenu := true
		disableHideBorder := true
		bezelTopOffset := IniReadCheck(settingsFile, "Settings", "Bezel_Top_Offset","62",,1)
		bezelBottomOffset := IniReadCheck(settingsFile, "Settings", "Bezel_Bottom_Offset","52",,1)
		bezelRightOffset := IniReadCheck(settingsFile, "Settings", "Bezel_Right_Offset", "8",,1)
		bezelLeftOffset := IniReadCheck(settingsFile, "Settings", "Bezel_Left_Offset", "8",,1)
		BezelStart("fixResMode")
	}
}

; Setting Fullscreen setting in registry if it doesn't match what user wants above
currentFullScreen := ReadReg("fullscreen")
If ( Fullscreen = "true" And currentFullScreen = "false" )
	WriteReg("fullscreen", "true")
Else If ( Fullscreen != "true" And currentFullScreen = "true" )
	WriteReg("fullscreen", "false")

;Same for window zoom
currentWindowZoom := ReadReg("zoom")
If ( WindowZoom != currentWindowZoom )
	WriteReg("zoom", WindowZoom, "REG_DWORD")

;Same for GPU Enabled
currentGPUEnabled := ReadReg("GPUEnabled")
If ( GPUEnabled = "true" And currentGPUEnabled = "false" )
	WriteReg("GPUEnabled", "true")
Else If ( GPUEnabled != "true" And currentGPUEnabled = "true" )
	WriteReg("GPUEnabled", "false")

;Same for DSP Enabled
currentDSPEnabled := ReadReg("DSPEnabled")
If ( DSPEnabled = "true" And currentDSPEnabled = "false" )
	WriteReg("DSPEnabled", "true")
Else If ( DSPEnabled != "true" And currentDSPEnabled = "true" )
	WriteReg("DSPEnabled", "false")

;And for use BIOS
currentEnableJaguarBIOS := ReadReg("useJaguarBIOS")
If ( EnableJaguarBIOS = "true" And currentEnableJaguarBIOS = "false" )
	WriteReg("useJaguarBIOS", "true")
Else If ( EnableJaguarBIOS != "true" And currentEnableJaguarBIOS = "true" )
	WriteReg("useJaguarBIOS", "false")

;And for bilenear filter
currentFilter := ReadReg("glFilterType")
If ( Filter != currentFilter )
	WriteReg("glFilterType", Filter, "REG_DWORD")

;And Video Mode
currentHardwareTypeNTSC := ReadReg("hardwareTypeNTSC")
If ( VideoMode = "PAL" And currentHardwareTypeNTSC = "true" )
	WriteReg("hardwareTypeNTSC", "false")
Else If ( VideoMode = "NTSC" And currentHardwareTypeNTSC = "false" )
	WriteReg("hardwareTypeNTSC", "true")

;And Fast Blitter
currentUseFastBlitter := ReadReg("useFastBlitter")
If ( UseFastBlitter = "true" And currentUseFastBlitter = "false" )
	WriteReg("useFastBlitter", "true")
Else If ( UseFastBlitter != "true" And currentUseFastBlitter = "true" )
	WriteReg("useFastBlitter", "false")

jagBIOS := emuPath . "\eeproms\jagboot.rom"
CheckFile(jagBIOS, "Could not find ""jagboot.rom"" bios rom, it is required for " . MEmu . ": " . jagBIOS)

hideEmuObj := Object("Virtual Jaguar ahk_class QWidget",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("Virtual Jaguar ahk_class QWidget")
WinWaitActive("Virtual Jaguar ahk_class QWidget")

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose",executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()

ReadReg(var1) {
	regValue := RegRead("HKEY_CURRENT_USER", "Software\Underground Software\Virtual Jaguar", var1) 
	Return %regValue%
}

WriteReg(var1, var2, ValueType="REG_SZ") {
	RegWrite(ValueType, "HKEY_CURRENT_USER", "Software\Underground Software\Virtual Jaguar", var1, var2)
}

CloseProcess:
	FadeOutStart()
	WinClose("Virtual Jaguar ahk_class QWidget")
Return
