MEmu = WinUAE
MEmuV =  v2.6.0
MURL = http://www.winuae.net/
MAuthor = brolly
MVersion = 2.1.2
MCRC = 36AB306
iCRC = EEA3289D
mId = 635138307631183750
MSystem = "Commodore Amiga","Commodore Amiga CD32","Commodore CDTV","Commodore Amiga CD","Commodore Amiga Demos"
;----------------------------------------------------------------------------
; Notes:
; You can have specific configuration files inside a Configurations folder on WinUAE main dir.
; Just name them the same as the game name on the XML file.
; Make sure you create a host config files with these names:
; CD32 : cd32host.uae and cd32mousehost.uae;
; CDTV : cdtvhost.uae and cdtvmousehost.uae;
; Amiga : amigahost.uae;
; Amiga CD : amigacdhost.uae;
; cd32mouse and cdtvmouse are for mouse controlled games on these systems, you should configure 
; Windows Mouse on Port1 and a CD32 pad on Port2. For Amiga and Amiga CD make sure you set both 
; a joystick and a mouse on Port1 and only a joystick on Port2.
; Set all your other preferences like video display settings. And make sure you are saving a HOST 
; configuration file and not a general configuration file.
;
; If you want to configure an exit key through WinUAE:
; Host-Input-Configuration #1-RAW Keyboard and then remap the desired key to Quit Emulator.
; If you want to configure a key to toggle fullscreen/windowed mode:
; Host-Input-Configuration #1-RAW Keyboard and then remap the desired key to Toggle windowed/fullscreen.
;
; CD32 and CDTV:
; A settings file called System_Name.ini should be placed on your module dir. on that file you can define if a 
; game uses mouse or if it needs the special delay hack loading method amongst other things. Example of such a file:
;
; [Lemmings (Europe)]
; UseMouse=true
;
; [Project-X & F17 Challenge (Europe)]
; DelayHack=true
;
; Amiga:
; For MultiGame support make sure you don't change the default WinUAE diskswapper keys which are:
; END+1-0 (not numeric keypad) = insert image from swapper slot 1-10
; END+SHIFT+1-0 = insert image from swapper slot 11-20
; END+CTRL+1-4 = select drive
;
; To do that follow the same procedure as above for the exit 
; key, but on F11 set it to Toggle windowed/fullscreen. Make sure you save your configuration afterwards.
; Note : If you want to use Send commands to WinUAE for any keys that you configured through Input-Configuration panel make sure you 
; set those keys for Null Keyboard! This is a virtual keyboard that collects all input events that don't come from physical 
; keyboards. This applies to the exit or windowed/fullscreen keys mentioned above.
;
; If you are using WHDLoad games, but want to keep your default user-startup file after exiting then make a copy of it in the 
; WHDFolder\S (Set in PathToWHDFolder) and name it default-user-startup. This file will then be copied over S\user-startup on exit.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . systemName . ".ini"

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
PathToWHDFolder := IniReadCheck(settingsFile, "Settings", "PathToWHDFolder", EmuPath . "\HDD\WHD",,1)
PathToWorkBenchBase := IniReadCheck(settingsFile, "Settings", "PathToWorkBenchBase", EmuPath . "\HDD\Workbench31_Lite.vhd",,1)

PathToWHDFolder := AbsoluteFromRelative(EmuPath, PathToWHDFolder)
PathToWorkBenchBase := AbsoluteFromRelative(EmuPath, PathToWorkBenchBase)

;Bezel settings
bezelTopOffset := IniReadCheck(settingsFile, "Settings", "Bezel_Top_Offset","0",,1)
bezelBottomOffset := IniReadCheck(settingsFile, "Settings", "Bezel_Bottom_Offset","0",,1)
bezelRightOffset := IniReadCheck(settingsFile, "Settings", "Bezel_Right_Offset", "0",,1)
bezelLeftOffset := IniReadCheck(settingsFile, "Settings", "Bezel_Left_Offset", "0",,1)

; This object controls how the module reacts to different systems. MESS can play a lot of systems, but needs to know what system you want to run, so this module has to adapt.
mType := Object("Commodore Amiga","a500","Commodore Amiga CD32","cd32","Commodore CDTV","cdtv","Commodore Amiga CD","amigacd","Commodore Amiga Demos","a500")
ident := mType[systemName]	; search object for the systemName identifier MESS uses
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this WinUAE module: " . moduleName)

specialcfg = %emuPath%\Configurations\%romName%.uae

If romExtension in .hdf,.vhd
	DefaultRequireWB := "true"
Else
	DefaultRequireWB := "false"

If romExtension in .zip,.lha,.rar,.7z
{
	SlaveFile := COM_Invoke(HLObject, "findByExtension", romPath . "\" . romName . romExtension, "slave")
	If (SlaveFile) {
		If romName contains (AGA)
		{
			defaultCycleExact := "false"
			defaultCpuSpeed := "max"
		} Else {
			defaultCycleExact := "true"
			defaultCpuSpeed := "real"
		}
		defaultImmediateBlittler = "false"
		defaultCpuCompatible := "false"
		defaultCacheSize := "0" ;8192
	}
}

usemouse := IniReadCheck(settingsFile, romName, "UseMouse","false",,1)
delayhack := IniReadCheck(settingsFile, romName, "DelayHack","false",,1)

floppyspeed := IniReadCheck(settingsFile, romName, "FloppySpeed","turbo",,1)
quickstartmode := IniReadCheck(settingsFile, romName, "QuickStartMode",A_Space,,1)
options := IniReadCheck(settingsFile, romName, "Options","",,1)
requireswb := IniReadCheck(settingsFile, romName, "RequiresWB",DefaultRequireWB,,1)
customwb := IniReadCheck(settingsFile, romName, "CustomWB",A_Space,,1)

;Chipset settings
videomode := IniReadCheck(settingsFile, romName, "VideoMode","PAL",,1)
immediateblitter := IniReadCheck(settingsFile, romName, "ImmediateBlitter",defaultImmediateBlittler,,1)
collisionlevel := IniReadCheck(settingsFile, romName, "CollisionLevel","",,1)

;CPU settings
cycleexact := IniReadCheck(settingsFile, romName, "CycleExact",defaultCycleExact,,1)
cpucycleexact := IniReadCheck(settingsFile, romName, "CpuCycleExact","",,1)
blittercycleexact := IniReadCheck(settingsFile, romName, "BlitterCycleExact","",,1)
cpucompatible := IniReadCheck(settingsFile, romName, "CpuCompatible",defaultCpuCompatible,,1)
cpuspeed := IniReadCheck(settingsFile, romName, "CpuSpeed",defaultCpuSpeed,,1)
cachesize := IniReadCheck(settingsFile, romName, "CacheSize",defaultCacheSize,,1)

;RAM settings
chipmemory := IniReadCheck(settingsFile, romName, "ChipMemory","",,1)
fastmemory := IniReadCheck(settingsFile, romName, "FastMemory","",,1)
autoconfigfastmemory := IniReadCheck(settingsFile, romName, "AutoConfigFastMemory","",,1)
slowmemory := IniReadCheck(settingsFile, romName, "SlowMemory","",,1)
z3fastmemory := IniReadCheck(settingsFile, romName, "Z3FastMemory","",,1)
megachipmemory := IniReadCheck(settingsFile, romName, "MegaChipMemory","",,1)

;WHDLoad settings
whdloadoptions := IniReadCheck(settingsFile, romName, "WHDLoadOptions","PRELOAD",,1)
neverextract := IniReadCheck(settingsFile, romName, "NeverExtract","false",,1)

BezelStart()

windowClass = PCsuxRox ;Class name is different depending on if the game is being run windowed or fullscreen
If ( Fullscreen = "true" )
	windowClass = AmigaPowah

If (cpucycleexact and blittercycleexact)
	cycleexact := "" ;No need to set cycle exact if both cpu and blitter are set as it could lead to inconsistent states

;Fill both z3 slots when amount of RAM requires it
If (z3fastmemory = "384") {
	z3fastmemory = "256"
	z3fastmemoryb = "128"
} Else If (z3fastmemory = "768") {
	z3fastmemory = "512"
	z3fastmemoryb = "256"
} Else If (z3fastmemory = "1536") {
	z3fastmemory = "1024"
	z3fastmemoryb = "512"
}	

fs := If (Fullscreen = "true") ? "true" : "false"
videomode := (If videomode = "NTSC" ? ("-s ntsc=true") : (""))
floppyspeed := (If floppyspeed ? ("-s floppy_speed=" . floppyspeed) : (""))

If (requireswb = "true") {
	ident := "a1200"

	If (customwb)
		PathToWorkBenchBase := %EmuPath% . "\" . customwb
	CheckFile(PathToWorkBenchBase)
	wbDrive := "-s hardfile=rw,32,1,2,512," . """" . PathToWorkBenchBase . """"
}

If romExtension in .hdf,.vhd
{
	ident := "a1200"
	gameDrive := "-s hardfile=rw,32,1,2,512," . """" . romPath . "\" . romName . romExtension . """"
}

options := options . " " . videomode

If (ident = "a500" or ident = "a1200") {
	If romName contains (AGA),(LW)
		ident := "a1200"

	If (SlaveFile) {
		CheckFolder(PathToWHDFolder)

		ident := "a1200"

		;Create the user-startup file to launch the game
		WHDUserStartupFile := PathToWHDFolder . "\S\user-startup"
		SplitPath, SlaveFile, SlaveName, SlaveFolder

		FileDelete, %WHDUserStartupFile%
		FileAppend, echo "";`n, %WHDUserStartupFile%
		FileAppend, echo "Running: %SlaveName%";`n, %WHDUserStartupFile%
		FileAppend, echo "";`n, %WHDUserStartupFile%
		FileAppend, cd dh1:%SlaveFolder%;`n, %WHDUserStartupFile%
		FileAppend, whdload %SlaveName% %whdloadoptions%;`n, %WHDUserStartupFile%
	}
}

hideEmuObj := Object("ahk_class " . windowClass,1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

;--- Detecting what Configuration File to use (Or Quick Start Mode) ---

If FileExist(specialcfg) {
	;Game specific configuration file exists
	configFile = %romName%.uae
} Else {
	;Game specific configuration file doesn't exist
	If (ident = "cd32" or ident = "cdtv") {
		configFile := If (usemouse = "true") ? ("host\" . ident . "mousehost.uae") : ("host\" . ident . "host.uae")
		quickcfg := If (ident = "cd32") ? ("-s quickstart=" . ident . "`,0 -s chipmem_size=8") : ("-s quickstart=" . ident . "`,0")
	} Else {
		;Amiga or Amiga CD game

		configFile := If systemName = "Commodore Amiga CD" ? "host\amigacdhost.uae" : "host\amigahost.uae"
		If quickstartmode
			quickcfg := "-s quickstart=" . quickstartmode
		Else
			quickcfg := If (ident = "a500") ? "-s quickstart=a500`,1" : "-s quickstart=a1200`,1"
	}
}

;--- Setting up command line arguments to use ---

If (ident = "cd32" or ident = "cdtv") {
	If (delayhack = "true")
		options := options . " -s cdimage0=" . """" . romPath . "\" . romName . romExtension . """" . "`,delay"
	Else
		options := options . " -cdimage=" . """" . romPath . "\" . romName . romExtension . """"
} Else {
	If immediateblitter
		options := options . " -s immediate_blits=" . immediateblitter
	If cycleexact
		options := options . " -s cycle_exact=" . cycleexact
	If cpucycleexact
		options := options . " -s cpu_cycle_exact=" . cpucycleexact
	If blittercycleexact
		options := options . " -s blitter_cycle_exact=" . blittercycleexact
	If cpucompatible
		options := options . " -s cpu_compatible=" . cpucompatible
	If cpuspeed
		options := options . " -s cpu_speed=" . cpuspeed
	If cachesize
		options := options . " -s cachesize=" . cachesize
	If collisionlevel
		options := options . " -s collision_level=" . collisionlevel
	If chipmemory
		options := options . " -s chipmem_size=" . chipmemory
	If fastmemory
		options := options . " -s fastmem_size=" . fastmemory
	If autoconfigfastmemory
		options := options . " -s fastmem_autoconfig=" . autoconfigfastmemory
	If slowmemory
		options := options . " -s bogomem_size=" . slowmemory
	If z3fastmemory
		options := options . " -s z3mem_size=" . z3fastmemory
	If z3fastmemoryb
		options := options . " -s z3mem2_size=" . z3fastmemoryb
	If megachipmemory
		options := options . " -s megachipmem_size=" . megachipmemory

	If (SlaveFile) {
		;WHDLoad Game
		options := options . " -s filesystem=rw,WHD:" . """" . PathToWHDFolder . """" . " -s filesystem=ro,Games:" . """" . romPath . "\" . romName . romExtension . """"
	}
	Else If (gameDrive) {
		;HDD Game
		options := options . " " . wbDrive . " " . gameDrive
	} Else If romExtension in .cue,.iso
	{
		;Amiga CD game
		options := options . " " . wbDrive . " -cdimage=" . """" . romPath . "\" . romName . romExtension . """" . " -s win32.map_cd_drives=true -s scsi=true"
	} Else {
		;Floppy Game

		;MultiDisk loading, this will load the first 2 disks into drives 0 and 1 since some games can read from both drives and therefore 
		;the user won't need to change disks through the MG menu. We can have up to 4 drives, but most of the games will only support 2 drives 
		;so disks are only loaded into the first 2 for better compatibility. Remaining drives will be loaded into quick disk slots.
		
		romCount = % romTable.MaxIndex()
		If romName contains (Disk 1)
		{
			;If the user boots any disk rather than the first one, multi disk support must be done through HyperLaunch MG menu
			If romCount > 1
			{
				options := options . " -s nr_floppies=2"
				mgoptions := " -s floppy1=" . """" . romTable[2,1] . """"
			}
		}
		options := options . " " . floppyspeed . " -s floppy0=" . """" . romPath . "\" . romName . romExtension . """" . mgoptions
		
		If romCount > 1
		{
			;DiskSwapper
			;diskswapper := " -diskswapper "
			Loop % romTable.MaxIndex() ; loop each item in our array
			{
				;diskswapper := diskswapper . """" . romTable[A_Index,1] . ""","
				diskswapper := diskswapper . " -s diskimage" . (A_Index-1) . "=" . """" . romTable[A_Index,1] . """"
			}
			options := options . diskswapper
		}
	}
}

param1 := "-f " . """" . EmuPath . "\Configurations\" . configFile . """" . " " . quickcfg
param2 := "-s use_gui=no -s gfx_fullscreen_amiga=" . fs
param3 := options

;MsgBox, %param1% %param2% %param3%
;ExitApp

;disableActivateBlackScreen = true

HideEmuStart()
Run(Executable . A_Space . param1 . A_Space . param2 . A_Space . param3 . A_Space . " -portable", emuPath)

WinWait("ahk_class " . windowClass)
WinWaitActive("ahk_class " . windowClass)

If bezelPath
	Control, Hide, , ahk_class msctls_statusbar32, ahk_class %windowClass% ;Hide status bar (Doesn't seem to work...)

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose",executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


MultiGame:
	If currentButton = 10
		diskslot = 0
	Else If currentButton > 10
		diskslot := currentButton - 10
	Else
		diskslot := currentButton

	If currentButton > 10
		Send, {End Down}{Shift Down}%diskslot%{Shift Up}{End Up}
	Else
		Send, {End Down}%diskslot%{End Up}
Return

CloseProcess:
	If (ident = "a500" or ident = "a1200") {
		If (SlaveFile) {
			CheckFolder(PathToWHDFolder)
			;Copy default-user-startup to user-startup if file exists
			IfExist, %PathToWHDFolder%\S\default-user-startup
				FileCopy,%PathToWHDFolder%\S\default-user-startup, %PathToWHDFolder%\S\user-startup, 1
		}
	}
	FadeOutStart()
	WinClose, ahk_class %windowClass%
Return
