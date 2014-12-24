MEmu = Atari800
MEmuV =  v2.2.1 svn r2186
MURL = http://atari800.sourceforge.net/
MAuthor = djvj, brolly & wahoobrian
MVersion = 2.0.3
MCRC = 495BFE6A
iCRC = EBFDAB6C
MID = 635038268874969816
MSystem = "Atari XEGS","Atari 8-Bit","Atari 5200"
;----------------------------------------------------------------------------
; Notes:
; Enter the UI by pressing F1. ESC is used to return to the previous screen.
; On this menu go to Emulator Settings and make sure you set Save Settings on Exit to Yes otherwise your settings won't save!
;
; Atari 5200:
; In the UI, enter the Emulator Settings and set a 5200 bios to 5200.rom (you should place this in a Rom subfolder in your Emu_Path)
;
; Atari XL:
; Make sure XL/XE bios paths point to ATARIXL.rom and BASIC points to ATARIBAS.ROM
;
; Supported emulation modes via CLI:
; -atari                Emulate Atari 800
; -1200                 Emulate Atari 1200XL
; -xl                   Emulate Atari 800XL
; -xe                   Emulate Atari 130XE
; -320xe                Emulate Atari 320XE (Compy Shop)
; -rambo                Emulate Atari 320XE (Rambo)
; -xegs                 Emulate Atari XEGS
; -5200                 Emulate Atari 5200
;
; More CLI commands can be found in DOC\USAGE
;
; The Bezel offset values are needed If you are not running in Hardware Acceleration mode in the emulator.  With Harware Acceleration 
; disabled, the title bar and borders of the emulator window is not hidden.
;
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

mType := Object("Atari XEGS","xegs","Atari 8-Bit","xl","Atari 5200","5200")
ident := mType[systemName]	; search object for the systemName identifier Atari800 uses
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this Atari800 module: " . moduleName)

IfExist, % modulePath . "\" . systemName . ".ini"	; use a custom systemName ini If it exists
	settingsFile := modulePath . "\" . systemName . ".ini"
Else
	settingsFile := modulePath . "\" . moduleName . ".ini"

7z(romPath, romName, romExtension, 7zExtractPath)

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
VideoMode := IniReadCheck(settingsFile, romName, "VideoMode","PAL",,1)
MouseMode := IniReadCheck(settingsFile, romName, "MouseMode",A_Space,,1)

;Bezel settings
bezelTopOffset := IniReadCheck(settingsFile, "Settings", "Bezel_Top_Offset","0",,1)
bezelBottomOffset := IniReadCheck(settingsFile, "Settings", "Bezel_Bottom_Offset","0",,1)
bezelRightOffset := IniReadCheck(settingsFile, "Settings", "Bezel_Right_Offset", "0",,1)
bezelLeftOffset := IniReadCheck(settingsFile, "Settings", "Bezel_Left_Offset", "0",,1)

BezelStart()

cliOptions := If (Fullscreen="true") ? "-fullscreen " : "-windowed "

; set video mode
; If (VideoMode = "PAL")
	; cliOptions := cliOptions . " -pal "
; Else 
	; cliOptions := cliOptions . " -ntsc "

;set mouse mode
If (MouseMode in Paddle,Lightgun,Lightpen)
	If (MouseMode = "Paddle")
		cliOptions := cliOptions . " -mouse pad"
	Else If (MouseMode = "Lightgun")
		cliOptions := cliOptions . " -mouse gun"
	Else If (MouseMode = "Lightpen")
		cliOptions := cliOptions . " -mouse pen"
Else {
	cliOptions := cliOptions . " -mouse off"
}	

If (SystemName = "Atari 5200") {
	cliOptions := cliOptions . " -5200 "
	CartType := IniReadCheck(settingsFile, romName, "CartType",0,,1)
	If (!CartType) {
		a5200cartMaps := Object(4,20,8,19,16,6,32,4,40,7)
		FileGetSize, fsize, %romPath%\%romName%%romExtension%, K
		CartType := a5200cartMaps[fsize]	; search object for the systemName identifier Atari800 uses
	}	

	If (!CartType)
		ScriptError("Unknown cart type, make sure you define a CartType for this game on Atari 5200.ini")
	
	cliOptions := cliOptions . " -cart-type " . CartType
	cliOptions := cliOptions . " -cart "
}

Else If (SystemName = "Atari XEGS") {
	cliOptions := cliOptions . " -xegs -cart "
}

Else If (SystemName = "Atari 8-Bit")
{	
	Basic := IniReadCheck(settingsFile, romName, "Basic","false",,1)
	OSType := IniReadCheck(settingsFile, romName, "OSType",2,,1)
	MachineType := IniReadCheck(settingsFile, romName, "MachineType","xl",,1)
	CassetteLoadingMethod := IniReadCheck(settingsFile, romName, "CassetteLoadingMethod","Auto",,1)
	CartType := IniReadCheck(settingsFile, romName, "CartType",0,,1)	
	Command := IniReadCheck(settingsFile, romName, "Command", "",,1)
	SendCommandDelay := IniReadCheck(settingsFile, romName, "SendCommandDelay", "2000",,1)
	DisableSIOPatch := IniReadCheck(settingsFile, romName, "DisableSIOPatch","false",,1)
	LoadBasicAsCart := IniReadCheck(settingsFile, romName, "LoadBasicAsCart","",,1)
	
	;set OSType (OS-A, OS-B), Machine Type	
	If (OSType = "0")
		cliOptions := cliOptions . " -800-rev a-pal -atari "
	Else If (OSType = "1")
		cliOptions := cliOptions . " -800-rev b-ntsc -atari "
	Else
		cliOptions := cliOptions . " -" . MachineType
	
	;set sio patch (fast i/o access)
	If (DisableSIOPatch = "true")
		cliOptions := cliOptions . " -nopatch "

	If (Basic = "true")
		cliOptions := cliOptions . " -basic "
	Else
		cliOptions := cliOptions . " -nobasic "

	If (LoadBasicAsCart)
	{
		PathToBasicCart := AbsoluteFromRelative(EmuPath, LoadBasicAsCart)
		CheckFile(PathToBasicCart)
		cliOptions := cliOptions . " -cart """ . PathToBasicCart . """ -cart-type 1"
	}

	fullRomPath := romPath . "\" . romName . romExtension
	
	If romExtension in .a52,.car,.cart,.rom 	;Carts
	{	
		cliOptions := cliOptions . " -cart-type " . CartType
		cliOptions := cliOptions . " -cart "
	}
	Else If romExtension in .atr,.xfd,.atx 		;Disks
		cliOptions := cliOptions . " -disk1 "
	Else If romExtension in .xex,.com,.bas 		;Programs
		cliOptions := cliOptions . " -run "
	Else If romExtension in .cas 				;Tapes
	{
		If (CassetteLoadingMethod = "Auto") 
			cliOptions := cliOptions . " -boottape "
		Else 
			cliOptions := cliOptions . " -tape "
	}
	Else  
		ScriptError("Your rom has an extension of " . romExtension . ", only these extensions are supported:`a52,car,cart,rom,cas,atr,xfd,atx,xex,com,bas") 
}

Run(executable . " " . cliOptions . " """ . romPath . "\" . romName . romExtension, emuPath)						

WinWait("Atari 800 Emulator ahk_class SDL_app")
WinSet, Transparent, On, ahk_class ConsoleWindowClass	; makes the console window transparent so you don't see it on exit
WinWaitActive("Atari 800 Emulator ahk_class SDL_app")
BezelDraw()

If (CassetteLoadingMethod="CLOAD+RUN") {
	Sleep,1000
	SendCommand("CLOAD{Enter}", 100)
	SendCommand("{Enter}", 100)
	Sleep, 3000
	SendCommand("RUN{Enter}", 100)
}

SendCommand(Command, 2000)

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()

CheckCreateFile(file){
	IfNotExist, %file%
		FileAppend,, %file%
	Return file
}

CloseProcess:
	FadeOutStart()
	BezelExit()
	WinClose("Atari 800 Emulator ahk_class SDL_app")
Return
