MEmu = Atari800WinPlus
MEmuV =  4.1
MURL = https://github.com/Jaskier/Atari800Win-PLus/downloads
MAuthor = wahoobrian
MVersion = 1.0
MCRC = A3F59E69
iCRC = 3F1E06FD
mId = 635532589929508800
MSystem = "Atari XEGS","Atari 8-Bit","Atari 5200"

;----------------------------------------------------------------------------
; Notes:
;
; Settings are stored in the registry @ HKEY_CURRENT_USER\Software\Atari800WinPLus
; CLI is the same is nonGUI emulator, Atari800.  However, some of the CLI does not seem to do anything,
; so registry updates are used in some cases.
;
; Enter rom images for OS-A, OS-B, XL/XE, 5200 and BASIC via Atari | Rom images
;
; Some Atari 8-Bit computer games require BASIC Revision A version.  Not a bad idea to use that as a default,
; since it seems to work for all games that require a version of BASIC.
;
; Mouse can be used to emulate paddles, lightgun and lightpen.
; 
; This emulator has proven to be very buggy with lots of random crashes. Also fullscreen doesn't work properly.
; To setup fullscreen mode, go to View->Graphics Options and then select:
; - 640x480, partially clipped - This is the only real fullscreen mode, but the image will be clipped so it's 
;   no good.
; - 800x600 or 1024x768, full display - These will work without clipping, but the colors will be wrong and you 
;   will also have the menu and toolbar always visible.
; So it's basically useless. Besides fullscreen will make the emulator crash many times. It's highly suggested 
; than you use Atari800 instead of this emulator since it's a much better version.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

mType := Object("Atari XEGS","xegs","Atari 8-Bit","xl","Atari 5200","5200")
ident := mType[systemName]	; search object for the systemName identifier Atari800 uses
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this Atari800 module: " . moduleName)

;clear out registry values - any leftovers from previous executions can cause the emu to crash
RegWrite, REG_SZ, HKCU, Software\Atari800WinPLus, fileAutoboot, 
RegWrite, REG_SZ, HKCU, Software\Atari800WinPLus, fileTape, 
RegWrite, REG_SZ, HKCU, Software\Atari800WinPLus, pathDiskDrive1, 
RegWrite, REG_SZ, HKCU, Software\Atari800WinPLus, fileRomCartridge,
RegWrite, REG_SZ, HKCU, Software\Atari800WinPLus, fileRomCurrent,

IfExist, % modulePath . "\" . systemName . ".ini"	; use a custom systemName ini if it exists
	settingsFile := modulePath . "\" . systemName . ".ini"
Else
	settingsFile := modulePath . "\" . moduleName . ".ini"

7z(romPath, romName, romExtension, 7zExtractPath)

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
fullscreenCLI := If (Fullscreen="true") ? "-fullscreen" : "-windowed"
MouseMode := IniReadCheck(settingsFile, romName, "MouseMode",A_Space,,1)

cliOptions = %fullscreenCLI%

;set mouse mode
if (MouseMode in Paddle,Lightgun,Lightpen)
	RegWrite, REG_DWORD, HKCU, Software\Atari800WinPLus, inputState,66
	if (MouseMode = "Paddle")
		cliOptions := cliOptions . " -mouse pad"
	else if (MouseMode = "Lightgun")
		cliOptions := cliOptions . " -mouse gun"
	else if (MouseMode = "Lightpen")
		cliOptions := cliOptions . " -mouse pen"
else {
	RegWrite, REG_DWORD, HKCU, Software\Atari800WinPLus, inputState,2
	cliOptions := cliOptions . " -mouse off"
}	

If (SystemName = "Atari 5200")
{	
	cliOptions := cliOptions . " -5200 "

	CartType := IniReadCheck(settingsFile, romName, "CartType",0,,1)
	if (!CartType) {
		a5200cartMaps := Object(4,20,8,19,16,6,32,4,40,7)
		FileGetSize, fsize, %romPath%\%romName%%romExtension%, K
		CartType := a5200cartMaps[fsize]	; search object for the systemName identifier Atari800 uses
	}	

	If (!CartType)
		ScriptError("Unknown cart type, make sure you define a CartType for this game on Atari 5200.ini")
	Else
		RegWrite, REG_DWORD, HKCU, Software\Atari800WinPLus, sysCartType,%CartType%
	
	cliOptions := cliOptions . " -cart "
}
Else If (SystemName = "Atari XEGS") 
{
	MouseMode := IniReadCheck(settingsFile, romName, "MouseMode", "off",,1)
	cliOptions := cliOptions . " -xegs -mouse " . MouseMode . " -cart "
}
Else
{
	Basic := IniReadCheck(settingsFile, romName, "Basic","false",,1)
	OSType := IniReadCheck(settingsFile, romName, "OSType",2,,1)
	VideoMode := IniReadCheck(settingsFile, romName, "VideoMode","PAL",,1)
	MachineType := IniReadCheck(settingsFile, romName, "MachineType","xl",,1)
	CassetteLoadingMethod := IniReadCheck(settingsFile, romName, "CassetteLoadingMethod","Auto",,1)
	CartType := IniReadCheck(settingsFile, romName, "CartType",0,,1)	
	Command := IniReadCheck(settingsFile, romName, "Command", "",,1)
	SendCommandDelay := IniReadCheck(settingsFile, romName, "SendCommandDelay", "2000",,1)
	MouseMode := IniReadCheck(settingsFile, romName, "MouseMode", "off",,1)
	DisableSIOPatch := IniReadCheck(settingsFile, romName, "DisableSIOPatch","false",,1)
	LoadBasicAsCart := IniReadCheck(settingsFile, romName, "LoadBasicAsCart","",,1)
	
	;set machine type (OS-A, OS-B, XL)
	RegWrite, REG_DWORD, HKCU, Software\Atari800WinPLus, sysMachineType,%OSType%
		
	;set sio patch (fast i/o access)
	if (DisableSIOPatch = "true")
		RegWrite, REG_DWORD, HKCU, Software\Atari800WinPLus, sysEnableSIOPatch,0
	else
		RegWrite, REG_DWORD, HKCU, Software\Atari800WinPLus, sysEnableSIOPatch,1
	
	basic := If (Basic="true") ? " -basic" : " -nobasic"
	videomode := If (VideoMode="PAL") ? " -pal" : " -ntsc"
	
	cliOptions := cliOptions . basic . videomode . " -"MachineType . " -mouse " . MouseMode

	if (LoadBasicAsCart)
	{
		PathToBasicCart := AbsoluteFromRelative(EmuPath, LoadBasicAsCart)
		CheckFile(PathToBasicCart)
		cliOptions := cliOptions . " -cart " . PathToBasicCart
	}
	
	If romExtension in .a52,.car,.cart,.rom 	;Carts
	{	cliOptions := cliOptions . " -cart"
		RegWrite, REG_DWORD, HKCU, Software\Atari800WinPLus, sysCartType,%CartType%
	}
	Else if romExtension in .atr,.xfd,.atx 		;Disks
		cliOptions := cliOptions . " -disk1"
	Else if romExtension in .xex,.com,.bas 		;Programs
		cliOptions := cliOptions . " -run"
	Else if romExtension in .cas 				;Tapes
	{
		fullRomPath := romPath . "\" . romName . romExtension
		if (CassetteLoadingMethod = "Auto")
			cliOptions := cliOptions . " -boottape"
		else 
			RegWrite, REG_SZ, HKCU, Software\Atari800WinPLus, fileTape, %fullRomPath%
	}
	Else  
		ScriptError("Your rom has an extension of " . romExtension . ", only these extensions are supported:`a52,car,cart,rom,cas,atr,xfd,atx,xex,com,bas") 
}

BezelStart("fixResMode")	
Run(executable . " " . cliOptions . " """ . romPath . "\" . romName . romExtension, emuPath)			

WinWait("Atari800Win PLus")
Sleep, 500

; script to look for previous crash window...
; If previous run of emu crashed, auto-select No to avoid resetting ALL settings
IfWinExist, Atari800Win PLus ahk_class #32770 
{	
	WinActivate, Atari800Win PLus ahk_class #32770
	IfWinActive, Atari800Win PLus ahk_class #32770
	{	
		SetControlDelay -1
		;ControlClick, Button2, Atari800Win PLus ahk_class #32770 ; Click No
		PostMessage, 0x111, 7,,,Atari800Win PLus ahk_class #32770 ;Same as clicking No, but more reliable
	}
}

WinWaitActive("Atari800Win PLus 4.1")

If (Fullscreen="true") ;CLI for fullscreen is broken so enable it through a PostMessage instead
{
	PostMessage, 0x111, 32851,,,Atari800Win PLus 4.1
	Sleep, 100
}
BezelDraw()

if (CassetteLoadingMethod="CLOAD+RUN") {
	Sleep,1000
	SendCommand("CLOAD{Enter}", 100)
	SendCommand("{Enter}", 100)
	Sleep, 3000
	SendCommand("RUN{Enter}", 100)
}

SendCommand(Command, 1000)

;check if emu crashed, if it did, just get out - can we log/display a message so user knows what happened?
Sleep, 5000
IfWinExist, Atari800Win PLus Monitor 
	WinClose, Atari800Win PLus Monitor

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


MultiGame:
	Log("MultiGame Label was run!")

	If romExtension in .atr
	{	Send !1 ; swaps a Disk
		wvTitle:="Select disk to insert into drive 1 ahk_class #32770"
	} Else If romExtension in .cas
	{	Send !t ; swaps a Tape
		wvTitle:="Select tape image to attach ahk_class #32770"
	} Else
		ScriptError(romExtension . " is an invalid multi-game extension")

	WinWait(wvTitle)
	WinWaitActive(wvTitle)
	OpenROM(wvTitle, selectedRom)
	Log("Module - WinWaitActive`, ahk_class Atari800Win PLus 4.1`, `, 5")
	WinWaitActive("Atari800Win PLus 4.1",,5)
	WinActivate, Atari800Win PLus 4.1
Return

CheckCreateFile(file){
	IfNotExist, %file%
		FileAppend,, %file%
	Return file
}

CloseProcess:
	FadeOutStart()
	BezelExit()
	If (Fullscreen="true") ;If the process is closed on fullscreen then the emulator will always start to a black screen
	{
		PostMessage, 0x111, 32851,,,Atari800Win PLus 4.1
		Sleep, 100
	}
	WinClose("Atari800Win PLus 4.1")
Return
