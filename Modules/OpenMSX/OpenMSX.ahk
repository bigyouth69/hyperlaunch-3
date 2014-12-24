MEmu = OpenMSX
MEmuV =  v0.11.0
MURL = http://openmsx.sourceforge.net/
MAuthor = brolly
MVersion = 2.0.2
MCRC = BDC1E167
iCRC = 693BAD2A
mId = 635403946322405220
MSystem = "Microsoft MSX","Microsoft MSX2","Microsoft MSX2+","Microsoft MSX Turbo-R","Pioneer Palcom LaserDisc"
;----------------------------------------------------------------------------
; Notes:
; Make sure you have the bios for the system/model you are trying to emulate inside share/machines.
; You can find roms for several systems here: http://www.msxarchive.nl/pub/msx/emulator/
;
; For emulating the Pioneer Palcom LaserDisc system you must have the PX-7 bios inside share/machines/Pioneer_PX-7/roms
;
; A file named boot_script.txt will be created in your emulator path every time you start a game. If you have any file with the 
; same name there make sure you rename it to something Else or it will get overwritten.
;
; About C-BIOS Machines:
; C-BIOS is a minimal implementation of the MSX BIOS, allowing some games to be played without an original MSX BIOS ROM image.
; It only supports cart games. It's highly suggested that you use a real machine instead of one of the C-BIOS implementations.
;
; Key remapping:
; If you want to remap any keys you can do it directly on OpenMSX just create a folder named remaps in the emulator folder. Inside 
; that folder create SYSTEMNAME.txt files depending on the system and you can also create a GLOBAL.txt file with remaps that you want 
; to use for any system of this module. Read the emulator docs for details on how to create remaps, for example:
; bind PAGEUP "set pause on"
; bind ESCAPE "quit"
;
; MSX Turbo-R Machines : Panasonic_FS-A1GT & Panasonic_FS-A1ST
; MSX2+ Machines : Sony_HB-F1XDJ, Sanyo_PHC-70FD, Sanyo_PHC-70FD2, Sanyo_PHC-35J, Panasonic_FS-A1FX, Panasonic_FS-A1WSX, Panasonic_FS-A1WX
; MSX Machines with Disk Drives : National_CF-3300 & Gradiente_Expert_DDPlus
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

sysTypes := Object("Pioneer Palcom LaserDisc","palcom","Microsoft MSX","msx","Microsoft MSX2","msx2","Microsoft MSX2+","msx2+","Microsoft MSX Turbo-R","turbor")
sysIdent := sysTypes[systemName]
If !sysIdent
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this OpenMSX module: " . moduleName)

defaultMachines := Object("palcom","Pioneer_PX-7","msx","Sony_HB-501P","msx2","Sony_HB-F900","msx2+","Panasonic_FS-A1WSX","turbor","Panasonic_FS-A1GT")
defaultmach := defaultMachines[sysIdent]

If (sysIdent = "msx") ;For Disk games in MSX1 we will need a specific model with disk drives
	If romExtension in .dsk,.dmk
		defaultmach = Gradiente_Expert_DDPlus

settingsFile := modulePath . "\" . (If FileExist(modulePath . "\" . systemName . ".ini") ? systemName : moduleName) . ".ini"		; use a custom systemName ini If it exists
Log("SettingsFile is " . settingsFile)

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
HideConsole := IniReadCheck(settingsFile, "Settings", "HideConsole","true",,1)
FullSpeedWhenLoading := IniReadCheck(settingsFile, "Settings", "FullSpeedWhenLoading","true",,1)
DefaultMachine := IniReadCheck(settingsFile, "Settings", "DefaultMachine",defaultmach,,1)
ScalerAlgorithm := IniReadCheck(settingsFile, "Settings", "ScalerAlgorithm","simple",,1)
ScaleFactor := IniReadCheck(settingsFile, "Settings", "ScaleFactor","2",,1)
ApplyScalerOnFullscreen := IniReadCheck(settingsFile, "Settings", "ApplyScalerOnFullscreen","false",,1)
SoundDriver := IniReadCheck(settingsFile, "Settings", "SoundDriver","",,1)

If (sysIdent = "msx") ;For Disk games in MSX1 we will need a specific model with disk drives
{
	DefaultMachine := IniReadCheck(settingsFile, romName, "Machine",DefaultMachine,,1)
	RomType := IniReadCheck(settingsFile, romName, "RomType","",,1)
	ExtensionCart := IniReadCheck(settingsFile, romName, "ExtensionCart","",,1)
	DualDiskLoad := IniReadCheck(settingsFile, romName, "DualDiskLoad","false",,1)
	DiskSwapDrive := IniReadCheck(settingsFile, romName, "DiskSwapDrive","A",,1)
}

GlobalJoystick1 := IniReadCheck(settingsFile, "Settings", "Joystick1","keyjoystick1",,1)
GlobalJoystick2 := IniReadCheck(settingsFile, "Settings", "Joystick2","keyjoystick2",,1)
Joystick1 := IniReadCheck(settingsFile, romName, "Joystick1",GlobalJoystick1,,1)
Joystick2 := IniReadCheck(settingsFile, romName, "Joystick2",GlobalJoystick2,,1)

;Generate a boot_script file
scriptName = boot_script.txt

;Create the user-startup file to launch the game
BootScriptFile := emuPath . "\" . scriptName
FileDelete, %BootScriptFile%

BezelStart("fixResMode")

If (Fullscreen = "true")
	FileAppend, set fullscreen on`n, %BootScriptFile%
Else
	FileAppend, set fullscreen off`n, %BootScriptFile%

If (FullSpeedWhenLoading = "true")
	FileAppend, set fullspeedwhenloading on`n, %BootScriptFile%
Else
	FileAppend, set fullspeedwhenloading off`n, %BootScriptFile%

If (Fullscreen = "false" OR ApplyScalerOnFullscreen = "true")
{
	FileAppend, set scale_algorithm %ScalerAlgorithm%`n, %BootScriptFile%
	FileAppend, set scale_factor %ScaleFactor%`n, %BootScriptFile%
}

If (SoundDriver)
	FileAppend, set sound_driver %SoundDriver%`n, %BootScriptFile%

;hideEmuObj := Object("ahk_class ConsoleWindowClass",0,"openmsx ahk_class ConsoleWindowClass",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
hideEmuObj := Object("ahk_class ConsoleWindowClass",0,"ahk_class SDL_app",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

If romExtension in .cas,.wav
{
	FileAppend, set autoruncassettes on`n, %BootScriptFile%
	;StringReplace, newRompath, rompath, \, /, All ;\ characters are not accepted in the script and must be replaced by /
	;FileAppend, cassetteplayer insert "%newRompath%/%romname%%romextension%"`n, %BootScriptFile%
}

If (Joystick1 != none)
	FileAppend, plug joyporta %Joystick1%`n, %BootScriptFile%
If (Joystick2 != none)
	FileAppend, plug joyportb %Joystick2%`n, %BootScriptFile%

If (Joystick1 = "mouse" || Joystick2 = "mouse" || Joystick1 = "trackball" || Joystick2 = "trackball" || Joystick1 = "touchpad" || Joystick2 = "touchpad") {
	FileAppend, set grabinput on`n, %BootScriptFile%
	FileAppend, escape_grab`n, %BootScriptFile%
}

If ExtensionCart ;We should append it to the boot script because using the -ext CLI it will always try to add it to cart slot a unless the config XML specifically says slot 2
	If romExtension in .rom,.bin
		If (ExtensionCart != "64KBexRAM")
			FileAppend, ext %ExtensionCart%`n, %BootScriptFile%

;Read remaps from remaps text files
If FileExist(emuPath . "\remaps\GLOBAL.txt")
	Loop, read, %emuPath%\remaps\GLOBAL.txt
		FileAppend, %A_LoopReadLine%`n, %BootScriptFile%
If FileExist(emuPath . "\remaps\" . SystemName . ".txt")
	Loop, read, %emuPath%\remaps\%SystemName%.txt
		FileAppend, %A_LoopReadLine%`n, %BootScriptFile%

If (sysIdent = "palcom") {
	machinetype = Pioneer_PX-7
	mediatype1 = laserdisc
}

If (!DefaultMachine)
	ScriptError("Machine Type not defined for " . sysIdent)

params := " -machine " . DefaultMachine . " -script " . scriptName
If romExtension in .rom,.bin
	params := params . " -carta """ . romPath . "\" . romName . romExtension . """"
Else If romExtension in .dsk,.dmk
{
	params := params . " -diska """ . romPath . "\" . romName . romExtension . """"
	If (DualDiskLoad = "true")
	{
		If romName contains (Disk 1
		{
			RomTableCheck()	; make sure romTable is created already so the next line can calculate correctly
			If (romtable.MaxIndex() > 1)
			{
				romName2 := romtable[2,1] ;This should be disk 2
				params := params . " -diskb """ . romName2 . """"
			}
		}
	}
	If ExtensionCart
		params := params . " -ext " . ExtensionCart
} Else If romExtension in .cas,.wav
{
	params := params . " -cassetteplayer """ . romPath . "\" . romName . romExtension . """"
	If ExtensionCart
		params := params . " -ext " . ExtensionCart
}
Else If romExtension = .ogv
	params := params . " -laserdisc """ . romPath . "\" . romName . romExtension . """"

If RomType
	params := params . " -romtype " . RomType

HideEmuStart()
Run(executable . params, emuPath)

;WinWait("openmsx ahk_class ConsoleWindowClass")
;WinWaitActive("openmsx ahk_class ConsoleWindowClass")
WinWait("ahk_class SDL_app")
WinWaitActive("ahk_class SDL_app")

If HideConsole = true
	WinSet, Transparent, On, ahk_class ConsoleWindowClass	; makes the console window transparent so you don't see it on exit

Sleep, 2000 ;Needs this otherwise BezelDraw won't be able to get the correct window dimension

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


MultiGame:
	If romExtension in .cas,.wav
	{
		StringReplace, newRompath, selectedRom, \, /, All ;\ characters are not accepted in the script and must be replaced by /
		Send, {F10} ;Open the console
		Send, cassetteplayer insert "%newRompath%" ;Change tape
		Send, {Enter}
		Send, {F10} ;Close the console
	}
	Else If romExtension in .dsk,.dmk
	{
		DriveToUse := If DiskSwapDrive = "A" ? "diska" : "diskb"
		StringReplace, newRompath, selectedRom, \, /, All ;\ characters are not accepted in the script and must be replaced by /
		Send, {F10} ;Open the console
		Send, %DriveToUse% "%newRompath%" ;Change disk
		Send, {Enter}
		Send, {F10} ;Close the console
	}
Return

CloseProcess:
	FadeOutStart()
	;WinClose("openmsx ahk_class ConsoleWindowClass")
	WinClose("ahk_class SDL_app")
Return
