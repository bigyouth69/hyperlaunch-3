MEmu = Altirra
MEmuV =  v2.60 Test 12
MURL = http://www.virtualdub.org/altirra.html
MAuthor = wahoobrian & brolly
MVersion = 1.0
MCRC = 42A17FA6
iCRC = 497AEC65
mId = 635532590282232367
MSystem = "Atari 8-Bit","Atari XEGS","Atari 5200"
;-----------------------------------------------------------------------------------------------------------
; Notes:
;
; From command prompt, "altirra /?" will display help for command-line switches.
; Select your Bios files via System | Firmware | Rom Images...
;
; Lightgun/pen emulation via mouse is tricky, doesn't seem to work very well.  Not supported by module.
;
; The module will force Altirra to run in portable mode so all settings will be saved to a file named Altirra.ini 
; instead of the registry.
;
; Some compatibility tips from the Altirra authors:
;  Disable BASIC (unless you're actually running a BASIC program).
;  For older games, use 800 hardware and 48K RAM, and the OS-B kernel.
;  For newer games, use XL hardware and 128K RAM (XE), and use the XL kernel.
;  For demos and games written in Europe, use XL hardware/kernel, 320K RAM, and PAL.
;  If you don't have kernel ROM images, use the HLE kernel instead.
;  Use Input > Joystick to toggle the joystick, which uses the arrow keys and the left control key.
;-----------------------------------------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

mType := Object("Atari XEGS","xegs","Atari 8-Bit","800xl","Atari 5200","5200")
ident := mType[systemName]	; search object for the systemName identifier Atari800 uses
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this Atari800 module: " . moduleName)

IfExist, % modulePath . "\" . systemName . ".ini"	; use a custom systemName ini if it exists
	settingsFile := modulePath . "\" . systemName . ".ini"
Else
	settingsFile := modulePath . "\" . moduleName . ".ini"

7z(romPath, romName, romExtension, 7zExtractPath)

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
Mouse := IniReadCheck(settingsFile, romName, "Mouse","off",,1)
CartType := IniReadCheck(settingsFile, romName, "CartType",0,,1)	; 1-59 Info found in DOC\cart.txt

cliOptions := If (Fullscreen="true") ? "/f" : ""
cliOptions := cliOptions . " /portable"

If (SystemName = "Atari 5200") {
	cliOptions := cliOptions . " /hardware:5200 /kernel:5200 "

	CartType := IniReadCheck(settingsFile, romName, "CartType",0,,1)
	if (!CartType) {
		a5200cartMaps := Object(4,58,8,19,16,6,32,4,40,7)
		FileGetSize, fsize, %romPath%\%romName%%romExtension%, K
		CartType := a5200cartMaps[fsize]
	}
	If (!CartType)
		ScriptError("Unknown cart type, make sure you define a CartType for this game on Atari 5200.ini")

	cliOptions := cliOptions . " /cartmapper " . CartType . " /cart "
}
Else If (SystemName = "Atari XEGS") {
	cliOptions := cliOptions . " /hardware:xegs /kernel:xegs /memsize:64k /cart "
}
Else {
	Basic := IniReadCheck(settingsFile, romName, "Basic",If (romExtension=".bas") ? "true" : "false",,1)
	OSType := IniReadCheck(settingsFile, romName, "OSType","default",,1)
	VideoMode := IniReadCheck(settingsFile, romName, "VideoMode","PAL",,1)
	MachineType := IniReadCheck(settingsFile, romName, "MachineType",ident,,1)
	CartType := IniReadCheck(settingsFile, romName, "CartType",0,,1)	
	CassetteLoadingMethod := IniReadCheck(settingsFile, romName, "CassetteLoadingMethod",Auto,,1)
	Command := IniReadCheck(settingsFile, romName, "Command", "",,1)
	SendCommandDelay := IniReadCheck(settingsFile, romName, "SendCommandDelay", "2000",,1)
	MouseMode := IniReadCheck(settingsFile, romName, "MouseMode",A_Space,,1)
	DisableSIOPatch := IniReadCheck(settingsFile, romName, "DisableSIOPatch","false",,1)
	LoadBasicAsCart := IniReadCheck(settingsFile, romName, "LoadBasicAsCart","",,1)

	DefaultMemSize := "128K"
	if (MachineType = "800")
		DefaultMemSize := "48K"

	MemorySize := IniReadCheck(settingsFile, romName, "MemorySize",DefaultMemSize,,1)

	;set sio patch (fast i/o access)
	if (DisableSIOPatch = "true")
		cliOptions := cliOptions . " /nosiopatch "
	else
		cliOptions := cliOptions . " /siopatch "

	basic := If (Basic="true") ? " /basic" : " /nobasic"
	videomode := If (VideoMode="PAL") ? " /pal" : " /ntsc"
	machine := " /hardware:" . MachineType
	os := " /kernel:" . OSType
	memsize := " /memsize:" . MemorySize

	cliOptions := cliOptions . emuFullscreen . videomode . machine . basic . os . memsize
	
	If (LoadBasicAsCart)
	{
		PathToBasicCart := AbsoluteFromRelative(EmuPath, LoadBasicAsCart)
		CheckFile(PathToBasicCart)
		cliOptions := cliOptions . " /cart """ . PathToBasicCart . """ /cartmapper 1"
	}

	If romExtension in .a52,.car,.cart,.rom	 ;Carts
	{
		If (CartType > 0) 
			cliOptions := cliOptions . " /cartmapper" . CartType
		cliOptions := cliOptions . " /cart"
	}
	Else if romExtension in .cas ;Tapes
	{
		If (CassetteLoadingMethod = "Auto")
			cliOptions := cliOptions . " /casautoboot /tape"
		Else 
			cliOptions := cliOptions . " /nocasautoboot /tape"
	}
	Else if romExtension in .atr,.xfd,.atx,.bas 	;Disks
	{
		cliOptions := cliOptions . " /bootrw"
	}
	Else if romExtension in .xex,.com ;Binary Programs
	{
		cliOptions := cliOptions . " /run"
	}
	Else
		ScriptError("Your rom has an extension of " . romExtension . ", only these extensions are supported:`a52,car,cart,rom,cas,atr,xfd,atx,xex,com,bas")
}

BezelStart()	
Run(executable . " " . cliOptions . " """ . romPath . "\" . romName . romExtension, emuPath)					
WinWait("Altirra ahk_class AltirraMainWindow")
WinWaitActive("Altirra ahk_class AltirraMainWindow")
BezelDraw()

If (CassetteLoadingMethod="CLOAD+RUN") {
	Sleep,5000 ;allow time for tape to mount, emulator to boot
	SendCommand("CLOAD{Enter}", 100)
	SendCommand("{Enter}", 100)
	Sleep, 3000
	SendCommand("RUN{Enter}", 100)
}

If (Command) {
	Sleep,5000	;allow time for emulator to boot
	SendCommand(Command, 1000)
}
	
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


MultiGame:
	Log("MultiGame Label was run!")
	If romExtension in .atr, .cas
	{	Send !o 
		wvTitle:="Load disk, cassette, cartridge, or program image ahk_class #32770"
	} Else
		ScriptError(romExtension . " is an invalid multi-game extension")
	
	WinWait(wvTitle)
	WinWaitActive(wvTitle)
	OpenROM(wvTitle, selectedRom)
	WinWaitActive("Altirra ahk_class AltirraMainWindow",,5)
	WinActivate, "Altirra ahk_class AltirraMainWindow"
Return

CheckCreateFile(file){
	IfNotExist, %file%
		FileAppend,, %file%
	Return file
}

CloseProcess:
	FadeOutStart()
	BezelExit()
	WinClose("Altirra ahk_class AltirraMainWindow")
Return
