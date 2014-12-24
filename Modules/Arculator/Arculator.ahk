MEmu = Arculator
MEmuV = v0.99
MURL = http://b-em.bbcmicro.com/arculator/
MAuthor = brolly
MVersion = 1.0
MCRC = 39F4E0F9
iCRC = 953693BD
mId = 635403945755833655
MSystem = "Acorn Archimedes"
;----------------------------------------------------------------------------
; Notes:
; You will need to have the RiscOS roms in the Roms folder inside each respective sub-folder depending on the RiscOS version you are going to use
; For faster loading If you want to boot into the command prompt instead of RiscOS do this:
; After RiscOS has booted, press F12 to go to the prompt and type: conf. language 0
; Press Enter to get rid of the prompt and reset Arculator, you should now boot into command prompt
; This info is stored in the cmos, so make sure you backup your CMOS folder before attempting it so you can revert back If needed
; Some games might require RiscOS to start, so beware of it
; WaitTime in the module settings file should be adjusted to your machine as RiscOS load might be slower or faster
; You can download a blank pre-formatted hdf file to use as HDD disk 4 and/or disk 5 here:
; http://b-em.bbcmicro.com/arculator/download.html
;
; hdf games are supported, but they will always be mounted in drive 5 so make sure you go to RiscOS desktop-Apps-!Configure-Discs and set the number of IDE hard discs to 2.
; You can have multiple games inside the same hdf file, to be able to launch the games make sure you set the HdfFileName in the module ini file
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"

;General Settings
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
FullBorders := IniReadCheck(settingsFile, "Settings", "FullBorders","true",,1)
NoBorders := IniReadCheck(settingsFile, "Settings", "NoBorders","false",,1)
WaitTime := IniReadCheck(settingsFile, "Settings", "WaitTime","15000",,1)

;Different keyboard layouts will use different keys
AsteriskKey := IniReadCheck(settingsFile, "Keys", "AsteriskKey","*",,1)
DoubleQuoteKey := IniReadCheck(settingsFile, "Keys", "DoubleQuoteKey","""",,1)
UnderscoreKey := IniReadCheck(settingsFile, "Keys", "UnderscoreKey","_",,1)
MinusKey := IniReadCheck(settingsFile, "Keys", "MinusKey","-",,1)

;Rom Settings
CpuType := IniReadCheck(settingsFile, romName, "CpuType","3",,1)
MemorySize := IniReadCheck(settingsFile, romName, "MemorySize","8192",,1)
OperatingSystem := IniReadCheck(settingsFile, romName, "OperatingSystem","3",,1)
FullBorders := IniReadCheck(settingsFile, romName, "FullBorders",FullBorders,,1)
NoBorders := IniReadCheck(settingsFile, romName, "NoBorders",NoBorders,,1)
WaitTime := IniReadCheck(settingsFile, romName, "WaitTime",WaitTime,,1)
ExecuteCmd := IniReadCheck(settingsFile, romName, "ExecuteCmd",A_Space,,1)
WorkingDir := IniReadCheck(settingsFile, romName, "WorkingDir",A_Space,,1)
HdfFileName := IniReadCheck(settingsFile, romName, "HdfFileName",A_Space,,1)

If (!HdfFileName AND romExtension = ".hdf")
{
	HdfFileName := romName . romExtension
}

If (HdfFileName) ;Check If HDF File exists
	HdfFile := CheckFile(romPath . "\" . HdfFileName)
	
;Enable FDC If OS is RiscOS 3 with new FDC
FdcType := If OperatingSystem = "3" ? "1" : "0"

cfgFile := CheckFile(emuPath . "\arc.cfg")
cfgArray := LoadProperties(cfgFile)

BezelStart("fixResMode")

hideEmuObj := Object("Arculator ahk_class WindowsApp",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

; Read current settings from arc.cfg
CurrentFirstFullscreen := ReadProperty(cfgArray,"first_fullscreen")
CurrentFullBorders := ReadProperty(cfgArray,"full_borders")
CurrentNoBorders := ReadProperty(cfgArray,"no_borders")
CurrentCpuType := ReadProperty(cfgArray,"cpu_type")
CurrentMemorySize := ReadProperty(cfgArray,"mem_size")
CurrentOperatingSystem := ReadProperty(cfgArray,"rom_set")
CurrentFdcType := ReadProperty(cfgArray,"fdc_type")

If (FullBorders = "true" && CurrentFullBorders != "1")
	WriteProperty(cfgArray,"full_borders","1",1)
Else If (FullBorders != "true" && CurrentFullBorders != "0")
	WriteProperty(cfgArray,"full_borders","0",1)

If (NoBorders = "true" && CurrentNoBorders != "1")
	WriteProperty(cfgArray,"no_borders","1",1)
Else If (NoBorders != "true" && CurrentNoBorders != "0")
	WriteProperty(cfgArray,"no_borders","0",1)

If (CpuType != CurrentCpuType)
	WriteProperty(cfgArray,"cpu_type",CpuType,1)
If (MemorySize != CurrentMemorySize)
	WriteProperty(cfgArray,"mem_size",MemorySize,1)
If (OperatingSystem != CurrentOperatingSystem)
	WriteProperty(cfgArray,"rom_set",OperatingSystem,1)
If (FdcType != CurrentFdcType)
	WriteProperty(cfgArray,"fdc_type",FdcType,1)
If (CurrentFirstFullscreen != "0") ;If first_fullscreen=1 a dialog will appear telling you to press Ctrl+End to get back to windowed mode and we don't want that
	WriteProperty(cfgArray,"first_fullscreen","0",1)

;Clean any previous disk in drives
WriteProperty(cfgArray,"disc_name_0",A_Space,1)
WriteProperty(cfgArray,"disc_name_1",A_Space,1)
WriteProperty(cfgArray,"disc_name_2",A_Space,1)
WriteProperty(cfgArray,"disc_name_3",A_Space,1)

;Replace special keys due to different keyboard layouts
If ExecuteCmd contains *
	StringReplace, ExecuteCmd, ExecuteCmd, *, %AsteriskKey%, All
If ExecuteCmd contains "
	StringReplace, ExecuteCmd, ExecuteCmd, ", %DoubleQuoteKey%, All
If ExecuteCmd contains _
	StringReplace, ExecuteCmd, ExecuteCmd, _, %UnderscoreKey%, All
If ExecuteCmd contains -
	StringReplace, ExecuteCmd, ExecuteCmd, -, %MinusKey%, All

If romExtension contains .adf,.apd
{	;Disk loading
	WriteProperty(cfgArray,"disc_name_0", romPath . "\" . romName . romExtension,1)

	;MultiDisk loading, this will load the first 2 disks into drives A and B since some games can read from both drives and therefore 
	;the user won't need to change disks through the MG menu.
	If romName contains (Disk 1)
	{	;If the user boots any disk rather than the first one, multi disk support must be done through HyperLaunch MG menu
		RomTableCheck()	; make sure romTable is created already so the next line can calculate correctly
		If romTable.MaxIndex() > 1
			WriteProperty(cfgArray,"disc_name_1", romTable[2,1],1)
	}
} Else {
	;hdf game, game might need a disk in the drive due to copy protection so lets search for it
	diskFile := romPath . "\" . romName . ".apd"
	IfExist, %diskFile%
		WriteProperty(cfgArray,"disc_name_0", diskFile,1)
	Else {
		diskFile := romPath . "\" . romName . ".adf"
		IfExist, %diskFile%
			WriteProperty(cfgArray,"disc_name_0", diskFile,1)
	}
}

SaveProperties(cfgFile,cfgArray)

If (HdfFile) ;Copy game to drive 5
	FileCopy, %HdfFile%, %emuPath%\hd5.hdf, 1

HideEmuStart()
Run(executable, emuPath)

WinWait("Arculator ahk_class WindowsApp")
WinWaitActive("Arculator ahk_class WindowsApp")

If (ExecuteCmd OR WorkingDir)
{
	Sleep %WaitTime% ;Wait until RiscOS has finished booting
	SetKeyDelay(50, 50)

	Send {F12}
	If romExtension Contains .adf,.apd
		Send drive{Space}0
	Else If HdfFile
		Send drive{Space}5
	Send {Enter}

	If (WorkingDir)
	{
		Send dir{Space}%WorkingDir%
		Send {Enter}
	}
	If (ExecuteCmd)
	{
		Send %ExecuteCmd%
		Send {Enter}
	}
}

; Set fullscreen If needed
If (Fullscreen = "true")
	WinMenuSelectItem, Arculator ahk_class WindowsApp,, Video, Fullscreen

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose",executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


HaltEmu:
Return

MultiGame:
	WinMenuSelectItem, Arculator ahk_class WindowsApp,, Disc, Change Disc, Drive 0...
	OpenROM("Open ahk_class #32770",selectedRom)
	If (Fullscreen = "true")
		WinMenuSelectItem, Arculator ahk_class WindowsApp,, Video, Fullscreen
	WinActivate, Arculator ahk_class WindowsApp
Return

CloseProcess:
	FadeOutStart()
	WinClose("Arculator ahk_class WindowsApp")
Return
