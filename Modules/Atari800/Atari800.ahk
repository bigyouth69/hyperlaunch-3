MEmu = Atari800
MEmuV =  v2.2.1 svn r2186
MURL = http://atari800.sourceforge.net/
MAuthor = djvj & brolly
MVersion = 2.0
MCRC = 2386B893
iCRC = 4555ACBC
MID = 635038268874969816
MSystem = "Atari XEGS","Atari 8-Bit","Atari 5200"
;----------------------------------------------------------------------------
; Notes:
; Enter the UI by pressing F1. ESC is used to return to the previous screen.
; On this menu go to Emulator Settings and make sure you set Save Settings on Exit to Yes otherwise your settings won't save
;
; Settings are stored in the registry @ HKEY_CURRENT_USER\Software\Atari800WinPLus
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
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

mType := Object("Atari XEGS","xegs","Atari 8-Bit","xl","Atari 5200","5200")
ident := mType[systemName]	; search object for the systemName identifier Atari800 uses
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this Atari800 module: " . moduleName)

settingsFile := modulePath . "\" . moduleName . ".ini"
SystemINI := CheckCreateFile(modulePath . "\" . systemName . ".ini")

7z(romPath, romName, romExtension, 7zExtractPath)

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
Mouse := IniReadCheck(SystemINI, romName, "Mouse","off",,1)
CartType := IniReadCheck(SystemINI, romName, "CartType",0,,1) ;0-59 Info found in DOC\cart.txt

fullscreen := If (Fullscreen="true") ? "-fullscreen" : "-windowed"

If (SystemName = "Atari 5200" and !CartType)
{	;Mapping of a5200 cart sizes to types
	;Note that 16KB carts can be of 2 types One Chip (default and id=16) and Two Chip (id=6), if a game uses a One Chip cart then it should be defined on Atari 5200.ini
	a5200cartMaps := Object(4,20,8,19,16,16,32,4,40,7)

	FileGetSize, fsize, %romPath%\%romName%%romExtension%, K
	CartType := a5200cartMaps[fsize]	; search object for the systemName identifier Atari800 uses

	If (!CartType)
		ScriptError("Unknown cart type, make sure you define a CartType for this game on Atari 5200.ini")
}
If (SystemName = "Atari 8-Bit")
{	Basic := IniReadCheck(SystemINI, romName, "Basic","false",,1)
	OSType := IniReadCheck(SystemINI, romName, "OSType",A_Space,,1)
	VideoMode := IniReadCheck(SystemINI, romName, "VideoMode","PAL",,1)
	MachineType := IniReadCheck(SystemINI, romName, "MachineType",ident,,1)

	If MachineType = atari
	{	ident := MachineType
		If (OSType)
			ostype := If (OSType="OSa" and VideoMode="PAL") ? "-800-rev a-pal" : (If (OSType="OSa" and VideoMode="NTSC") ? "-800-rev a-ntsc" : "-800-rev b-ntsc")
	}
	basic := If (Basic="true") ? "-basic" : "-nobasic"
	videomode := If (VideoMode="PAL") ? "-pal" : "-ntsc"
}

carttype := If (CartType) ? "-cart-type " . CartType : ""

If romExtension in .a52,.car,.cart,.rom	; Carts
	options = %videomode% -cart
Else if romExtension in .cas	; Tapes
	options = %videomode% -boottape
Else if romExtension in .atr,.xfd,.atx	; Disks
	options = %ostype% %videomode% -disk1
Else if romExtension in .xex,.com,.bas	; Programs
	options = %ostype% %videomode% -run
Else
	ScriptError("Your rom has an extension of " . romExtension . ", only these extensions are supported:`a52,car,cart,rom,cas,atr,xfd,atx,xex,com,bas")

Run(executable . " " . fullscreen . " -" . ident . " " . carttype . " " . basic . " " . options . " """ . romPath . "\" . romName . romExtension . """ -mouse " . Mouse, emuPath)

WinWait("Atari 800 Emulator ahk_class SDL_app")
WinWaitActive("Atari 800 Emulator ahk_class SDL_app")

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
	WinClose("Atari 800 Emulator ahk_class SDL_app")
Return
