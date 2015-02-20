MEmu = RPCEmu
MEmuV = v0.8.12
MURL = http://www.marutan.net/rpcemu/
MAuthor = brolly
MVersion = 1.0
MCRC = E4B7C32A
iCRC = 5DBBF626
mId = 635599773137091110
MSystem = "Acorn Archimedes"
;----------------------------------------------------------------------------
; Notes:
; You will need to have the RiscOS roms in the Roms folder
; WaitTime in the module settings file should be adjusted to your machine as RiscOS load might be slower or faster
; You can download a blank pre-formatted hdf file to use as HDD disk 4 and/or disk 5 here:
; http://b-em.bbcmicro.com/arculator/download.html
;
; hdf games are supported, but they will always be mounted in drive 5 so make sure you go to RiscOS desktop-Apps-!Configure-Discs and set the number of IDE hard discs to 2.
; You can have multiple games inside the same hdf file, to be able to launch the games make sure you set the HdfFileName in the module ini file
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"

;General Settings
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
WaitTime := IniReadCheck(settingsFile, "Settings", "WaitTime","5000",,1)

;Different keyboard layouts will use different keys
AsteriskKey := IniReadCheck(settingsFile, "Keys", "AsteriskKey","*",,1)
DoubleQuoteKey := IniReadCheck(settingsFile, "Keys", "DoubleQuoteKey","""",,1)
UnderscoreKey := IniReadCheck(settingsFile, "Keys", "UnderscoreKey","_",,1)
MinusKey := IniReadCheck(settingsFile, "Keys", "MinusKey","-",,1)

;Rom Settings
CpuType := IniReadCheck(settingsFile, romName, "CpuType","ARM710",,1)
RAMSize := IniReadCheck(settingsFile, romName, "RAMSize","32",,1)
VRAMSize := IniReadCheck(settingsFile, romName, "VRAMSize","2",,1)

WaitTime := IniReadCheck(settingsFile, romName, "WaitTime",WaitTime,,1)
ExecuteCmd := IniReadCheck(settingsFile, romName, "ExecuteCmd",A_Space,,1)
WorkingDir := IniReadCheck(settingsFile, romName, "WorkingDir",A_Space,,1)
HdfFileName := IniReadCheck(settingsFile, romName, "HdfFileName",A_Space,,1)

;Msgbox, % romPath romName . romExtension

If (!HdfFileName AND romExtension = ".hdf") {
	;MsgBox, EMPTY!!!!!!
	HdfFileName := romName . romExtension
}

If (HdfFileName) ;Check If HDF File exists
	HdfFile := CheckFile(romPath . "\" . HdfFileName)
	
cfgFile := CheckFile(emuPath . "\rpc.cfg")
cfgArray := LoadProperties(cfgFile)

7z(romPath, romName, romExtension, 7zExtractPath)

; Read current settings from rpc.cfg
CurrentCpuType := ReadProperty(cfgArray,"cpu_type")
CurrentRAMSize := ReadProperty(cfgArray,"mem_size")
CurrentVRAMSize := ReadProperty(cfgArray,"vram_size")

;MsgBox %Fullscreen%,%FullBorders%,%NoBorders%,%WaitTime%,%CpuType%,%MemorySize%,%OperatingSystem%,%FdcType%,%ExecuteCmd%,%NoBorders%
;MsgBox %CurrentFullscreen%,%CurrentFullBorders%,%CurrentNoBorders%,%CurrentCpuType%,%CurrentMemorySize%,%CurrentOperatingSystem%,%CurrentFdcType%

If (CpuType != CurrentCpuType)
	WriteProperty(cfgArray,"cpu_type",CpuType,1)
If (RAMSize != CurrentRAMSize)
	WriteProperty(cfgArray,"mem_size",RAMSize,1)
If (VRAMSize != CurrentVRAMSize)
	WriteProperty(cfgArray,"vram_size",VRAMSize,1)

;Replace special keys due to different keyboard layouts
If ExecuteCmd contains *
	StringReplace, ExecuteCmd, ExecuteCmd, *, %AsteriskKey%, All
If ExecuteCmd contains "
	StringReplace, ExecuteCmd, ExecuteCmd, ", %DoubleQuoteKey%, All
If ExecuteCmd contains _
	StringReplace, ExecuteCmd, ExecuteCmd, _, %UnderscoreKey%, All
If ExecuteCmd contains -
	StringReplace, ExecuteCmd, ExecuteCmd, -, %MinusKey%, All

SaveProperties(cfgFile,cfgArray)

If (HdfFile) ;Copy game to drive 5
	FileCopy, %HdfFile%, %emuPath%\hd5.hdf, 1

Run(executable, emuPath)

WinWait("RPCEmu ahk_class WindowsApp")
WinWaitActive("RPCEmu ahk_class WindowsApp")

SetKeyDelay, 50, 50

If romExtension Contains .adf,.apd
{
	Log(romPath . "\" . romName . romExtension)
	;Disk loading
	WinMenuSelectItem, RPCEmu ahk_class WindowsApp,, Disc, Load Disc :0
	fullRomPath := romPath . "\" . romName . romExtension
	OpenROM("Open ahk_class #32770", fullRomPath)
	WinWaitActive("RPCEmu ahk_class WindowsApp")
}

If (ExecuteCmd OR WorkingDir)
{
	Sleep %WaitTime% ;Wait until RiscOS has finished booting
	SetKeyDelay, 50, 50
	
	Send {F12}
	If romExtension Contains .adf,.apd
		Send drive{Space}0
	Else If HdfFile
		Send drive{Space}5
	Send {Enter}

	If (WorkingDir) {
		Send dir{Space}%WorkingDir%
		Send {Enter}
	}
	If (ExecuteCmd) {
		Send %ExecuteCmd%
		Send {Enter}
	}
}

; Set fullscreen If needed
If (Fullscreen = "true")
	WinMenuSelectItem, RPCEmu ahk_class WindowsApp,, Settings, Fullscreen mode

FadeInExit()
Process("WaitClose",executable)
7zCleanUp()
FadeOutExit()
ExitModule()


HaltEmu:
Return

MultiGame:
	WinMenuSelectItem, RPCEmu ahk_class WindowsApp,, Disc, Load Disc :0
	OpenROM("Open ahk_class #32770",selectedRom)
	If (Fullscreen = "true")
		WinMenuSelectItem, RPCEmu ahk_class WindowsApp,, Settings, Fullscreen mode
	WinActivate, RPCEmu ahk_class WindowsApp
Return

CloseProcess:
	FadeOutStart()
	WinClose("RPCEmu ahk_class WindowsApp")
Return
