MEmu = WinUAE
MEmuV =  v2.6.0
MURL = http://www.winuae.net/
MAuthor = brolly
MVersion = 2.1
MCRC = CEE67085
iCRC = 587D7C70
mId = 635138307631183750
MSystem = "Commodore Amiga","Commodore Amiga CD32","Commodore CDTV","Commodore Amiga CD"
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
FadeInStart()

settingsFile := modulePath . "\" . systemName . ".ini"

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
PathToWHDFolder := IniReadCheck(settingsFile, "Settings", "PathToWHDFolder", EmuPath . "\HDD\WHD",,1)
PathToWorkBenchBase := IniReadCheck(settingsFile, "Settings", "PathToWorkBenchBase", EmuPath . "\HDD\Workbench31_Lite.vhd",,1)

If NOT PathToWHDFolder contains EmuPath
{
	PathToWHDFolder := EmuPath . "\" . PathToWHDFolder
}
If NOT PathToWorkBenchBase contains EmuPath
{
	PathToWorkBenchBase := EmuPath . "\" . PathToWorkBenchBase
}

; This object controls how the module reacts to different systems. MESS can play a lot of systems, but needs to know what system you want to run, so this module has to adapt.
mType := Object("Commodore Amiga","a500","Commodore Amiga CD32","cd32","Commodore CDTV","cdtv","Commodore Amiga CD","amigacd")
ident := mType[systemName]	; search object for the systemName identifier MESS uses
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this WinUAE module: " . moduleName)

windowClass = PCsuxRox ;Class name is different depending on if the game is being run windowed or fullscreen
If ( Fullscreen = "true" )
	windowClass = AmigaPowah

specialcfg = %emuPath%Configurations\%romName%.uae

If romExtension in .hdf,.vhd
	DefaultRequireWB := "true"
Else
	DefaultRequireWB := "false"

If romExtension in .zip,.lha,.rar,.7z
{
	SlaveFile := COM_Invoke(HLObject, "findByExtension", romPath . "\" . romName . romExtension, "slave")
	If (SlaveFile)
	{
		If romName contains (AGA)
			DefaultOptions := "-s cycle_exact=false " . "-s immediate_blits=false " . "-s cpu_compatible=false " . "-s cpu_speed=max " . "-s cachesize=8192" ;AGA
		Else
			DefaultOptions := "-s cycle_exact=true " . "-s immediate_blits=false " . "-s cpu_compatible=false " . "-s cpu_speed=real " . "-s cachesize=8192 " ;Non-AGA
	}
}

usemouse := IniReadCheck(settingsFile, romName, "UseMouse","false",,1)
delayhack := IniReadCheck(settingsFile, romName, "DelayHack","false",,1)
options := IniReadCheck(settingsFile, romName, "Options",DefaultOptions,,1)
videomode := IniReadCheck(settingsFile, romName, "VideoMode","PAL",,1)

floppyspeed := IniReadCheck(settingsFile, romName, "FloppySpeed","turbo",,1)
quickstartmode := IniReadCheck(settingsFile, romName, "QuickStartMode",A_Space,,1)
immediateblitter := IniReadCheck(settingsFile, romName, "ImmediateBlitter","false",,1)
requireswb := IniReadCheck(settingsFile, romName, "RequiresWB",DefaultRequireWB,,1)
customwb := IniReadCheck(settingsFile, romName, "CustomWB",A_Space,,1)
whdloadoptions := IniReadCheck(settingsFile, romName, "WHDLoadOptions","PRELOAD",,1)
neverextract := IniReadCheck(settingsFile, romName, "NeverExtract","false",,1)

fs := If (Fullscreen = "true") ? "true" : "false"
videomode := (If videomode = "NTSC" ? ("-s ntsc=true") : (""))
floppyspeed := (If floppyspeed ? ("-s floppy_speed=" . floppyspeed) : (""))

If (requireswb = "true")
{
	ident := "a1200"

	If (customwb)
	{
		PathToWorkBenchBase := %EmuPath% . "\" . customwb
	}
	CheckFile(PathToWorkBenchBase)
	wbDrive := "-s hardfile=rw,32,1,2,512," . """" . PathToWorkBenchBase . """"
}
If romExtension in .hdf,.vhd
{
	ident := "a1200"
	gameDrive := "-s hardfile=rw,32,1,2,512," . """" . romPath . "\" . romName . romExtension . """"
}
If (immediateblitter = "true")
{
	options := options . " " . "-s immediate_blits=true"
}

options := options . " " . videomode

If (ident = "a500" or ident = "a1200")
{
	If romName contains (AGA),(LW)
		ident := "a1200"

	If (SlaveFile)
	{
		CheckFile(PathToWHDFolder)

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

7z(romPath, romName, romExtension, 7zExtractPath)

If FileExist(specialcfg)
{
	;Game specific configuration file exists
	configFile = %romName%.uae
}
Else
{
	;Game specific configuration file doesn't exist
	If (ident = "cd32" or ident = "cdtv")
	{
		configFile := If (usemouse = "true") ? ("host\" . ident . "mousehost.uae") : ("host\" . ident . "host.uae")
		quickcfg := If (ident = "cd32") ? ("-s quickstart=" . ident . "`,0 -s chipmem_size=8") : ("-s quickstart=" . ident . "`,0")
		If (delayhack = "true")
			options := options . " -s cdimage0=" . """" . romPath . "\" . romName . romExtension . """" . "`,delay"
		Else
			options := options . " -cdimage=" . """" . romPath . "\" . romName . romExtension . """"
	}
	Else
	{
		;Amiga or Amiga CD game

		configFile := If systemName = "Commodore Amiga CD" ? "host\amigacdhost.uae" : "host\amigahost.uae"
		If quickstartmode
			quickcfg := "-s quickstart=" . quickstartmode
		Else
			quickcfg := If (ident = "a500") ? "-s quickstart=a500`,1" : "-s quickstart=a1200`,1"

		If (SlaveFile)
		{
			;WHDLoad Game
			options := options . " -s filesystem=rw,WHD:" . """" . PathToWHDFolder . """" . " -s filesystem=ro,Games:" . """" . romPath . "\" . romName . romExtension . """"
		}
		Else If (gameDrive)
		{
			;HDD Game
			options := options . " " . wbDrive . " " . gameDrive
		}
		Else If romExtension in .cue,.iso
		{
			;Amiga CD game
			options := options . " " . wbDrive . " -cdimage=" . """" . romPath . "\" . romName . romExtension . """" . " -s win32.map_cd_drives=true -s scsi=true"
		}
		Else
		{
			;Floppy Game

			;MultiDisk loading, this will load the first 2 disks into drives 0 and 1 since some games can read from both drives and therefore 
			;the user won't need to change disks through the MG menu. We can have up to 4 drives, but most of the games will only support 2 drives 
			;so disks are only loaded into the first 2 for better compatibility. Remaining drives will be loaded into quick disk slots.
			
			romCount = % romTable.MaxIndex()
			If romName contains (Disk 1)
			{
				;If the user boots any disk rather than the first one, multi disk support must be done through HyperLaunch MG menu
				if romCount > 1
				{
					options := options . " -s nr_floppies=2"
					mgoptions := " -s floppy1=" . """" . romTable[2,1] . """"
				}
			}
			options := options . " " . floppyspeed . " -s floppy0=" . """" . romPath . "\" . romName . romExtension . """" . mgoptions
			
			if romCount > 1
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
}

param1 := "-f " . """" . EmuPath . "\Configurations\" . configFile . """" . " " . quickcfg
param2 := "-s use_gui=no -s gfx_fullscreen_amiga=" . fs
param3 := options

;MsgBox, %param1% %param2% %param3% %param4% %param5% %param6%
;ExitApp

;disableActivateBlackScreen = true

Run(Executable . A_Space . param1 . A_Space . param2 . A_Space . param3 . A_Space . param4 . A_Space . param5 . A_Space . param6 . A_Space . " -portable", emuPath)

WinWait("ahk_class " . windowClass)
WinWaitActive("ahk_class " . windowClass)

FadeInExit()
Process("WaitClose",executable)
7zCleanUp()
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
return

CloseProcess:
	If (ident = "a500" or ident = "a1200")
	{
		If (SlaveFile)
		{
			CheckFile(PathToWHDFolder)
			;Copy default-user-startup to user-startup if file exists
			IfExist, %PathToWHDFolder%\S\default-user-startup
				FileCopy,%PathToWHDFolder%\S\default-user-startup, %PathToWHDFolder%\S\user-startup, 1
		}
	}
	FadeOutStart()
	WinClose, ahk_class %windowClass%
return
