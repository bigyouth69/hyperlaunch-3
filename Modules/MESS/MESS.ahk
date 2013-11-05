MEmu = MESS
MEmuV =  v0.150
MURL = http://www.mess.org/
MAuthor = djvj
MVersion = 2.1.5
MCRC = DDB18118
iCRC = AA949FDC
MID = 635038268905515239
MSystem = "Amstrad GX4000","APF Imagination Machine","Apple IIGS","Atari 2600","Atari 5200","Atari 7800","Atari Jaguar","Atari Lynx","Bally Astrocade","Bandai WonderSwan","Bandai WonderSwan Color","Casio PV-1000","Casio PV-2000","Coleco ADAM","ColecoVision","Creatronic Mega Duck","Emerson Arcadia 2001","Entex AdventureVision","Epoch Game Pocket Computer","Epoch Super Cassette Vision","Fairchild Channel F","Funtech Super Acan","GCE Vectrex","Interton VC4000","Magnavox Odyssey 2","Mattel Aquarius","Mattel Intellivision","NEC PC Engine","NEC PC Engine-CD","NEC SuperGrafx","NEC TurboGrafx-16","NEC TurboGrafx-CD","Nintendo 64","Nintendo Entertainment System","Nintendo Game Boy","Nintendo Game Boy Advance","Nintendo Game Boy Color","Nintendo Virtual Boy","Philips CD-i","RCA Studio II","Sega 32X","Sega CD","Sega Game Gear","Sega Genesis","Sega Master System","Sega Mega Drive","SNK Neo Geo AES","SNK Neo Geo CD","SNK Neo Geo Pocket","SNK Neo Geo Pocket Color","Sony PlayStation","Super Nintendo Entertainment System","Texas Instruments TI 99-4A","Tiger Game.com","VTech CreatiVision","Watara Supervision"
;----------------------------------------------------------------------------
; Notes:
; Exit fade will only work correctly if you don't have Esc, the default MESS exit key,  as your exit key. If you use Esc, turn off the ExitScreen
; This module assumes you have bios zip in your MESS "roms" directory, which might be different than your actual roms directory, for each system you need this module for. All tested systems listed below
; If MESS has a problem reading the bios zips, try archving them with "no compression"
; This site can help a ton with details for the various systems supported: http://www.progettoemma.net/mess/index.html
; You may get a black screen or MESS may close w/o notice if you do not have a bios rom for your system when one is needed.
; If you use bezel, it is recommended to set the module bezel mode to normal, and go to your mess.ini file, on your emulator folder, and choose these options: artwork_crop 1, use_backdrops 1, use_overlays 1, use_bezels 0 
;
; Following systems require a BIOS zip with their roms inside, placed in the "Mess\Roms\" directory:
; Amstrad GX4000 - N/A
; APF Imagination Machine - apfimag (tape games), apfm1000 (cart games)
; Apple IIGS - apple2gs
; Atari 5200 - a5200
; Atari 7800 - a7800
; Atari Jaguar - jaguar
; Atari Lynx - lynx
; Bally Astrocade - astrocde
; Bandai WonderSwan - N/A
; Bandai WonderSwan Color - N/A
; Casio PV-2000 - pv2000
; Coleco ADAM - adam, adam_ddp, adam_fdc, adam_kb, adam_prn, adam_spi
; ColecoVision - coleco
; Creatronic Mega Duck - N/A
; Emerson Arcadia 2001 - N/A
; Entex Adventure Vision - advision
; Epoch Game Pocket Computer - gamepock
; Epoch Super Cassette Vision - scv
; Fairchild Channel F - channelf
; Funtech Super ACan - supracan
; GCE Vectrex - vextrex
; Interton VC4000 - vc4000
; Magnavox Odyssey 2 - odyssey2
; Mattel Aquarius - aquarius
; Mattel Intellivision - intv ("exec.bin" [8,192 bytes] & "grom.bin" [2,048 bytes])
; NEC PC Engine - N/A
; NEC PC Engine-CD - N/A
; NEC SuperGrafx - N/A
; NEC TurboGrafx-16 - N/A
; NEC TurboGrafx-CD - "Super CD-ROM2 System V3.01 (U).pce" [262,144 bytes] (placed in the roms subfolder in the emuPath)
; Nintendo 64 - n64
; Nintendo Entertainment System - N/A

; Nintendo Game Boy - gameboy
; Nintendo Game Boy Advance - gba
; Nintendo Game Boy Color - gbcolor

; Nintendo Virtual Boy - N/A
; Philips CD-i - the cdimono1
; RCA Studio II - studio2
; Sega 32X - 32x
; Sega CD - segacd, megacd, megacd2j (megacd2j seems to be more compatible over megacdj)
; Sega Game Gear - gamegear
; Sega Genesis - N/A
; Sega Master System - sms
; SNK Neo Geo AES - aes
; SNK Neo Geo CD - neocd
; SNK Neo Geo Pocket - ngp
; SNK Neo Geo Pocket Color - ngpc
; Sony PlayStation - psa, pse, psj, psu
; Super Nintendo Entertainment System - snes
; Texas Instruments TI 99-4A - ti99_4a
; Tiger Game.com - gamecom
; VTech CreatiVision - crvision
; Watara Supervision - N/A
;
; Custom Configuration Files:
; If you want to use custom configuration files (.cfg files) for some games you will need to store them inside your MESS cfg folder using the following structure:
; cfg\mess_system_name\HS_XML_rom_name\mess_system_name.cfg
; An example of a game that requires specific settings is ICBM Attack for the Bally Astrocade, in this case special cfg file should be:
; cfg\astrocde\I.C.B.M. Attack (USA) (Unl)\astrocde.cfg
;
; Bally Astrocade:
; ICBM requires a soft reset (even on the real hardware) to launch. You can read about it here: http://www.ballyalley.com/ballyalley/articles/Playing_ICBM_Attack_Using_MESS.pdf
; A custom build of MESS is needed to play this game if you don't want to press F3 manually each time you play ICBM. The custom build enables DirectInput so it is possible to script a soft reset in.
; I compiled a mess with this turned on and it can be found in my user dir @ /Upload Here/djvj/Bally Astrocade/
; Also ICBM uses different controls then the rest of the games. Make sure you follow the procedure explained above under "Custom Configuration Files" to create such file.
; Rom extensions should be zip,bin,txt
; Create a txt file in your rom dir called "Gunfight+Checkmate+Calculator+Scribbling (USA).txt" This game is built into the system and no rom is required to play it.
;
; GCE Vectrex:
; Requires a vectrex.lay and a png overlay for each game. These all need to be placed in the mess\artwork\vectrex folder.
; You can download all these pngs and the lay file in my ftp folder. You need to use the HyperList XML to match the pngs.
;
; Magnavox Odyssey 2:
; Euro games should use the videopac bios instead of the odyssey2 one or you'll get some timing issues.
; Use the systemName ini file in the folder with this module for this, example:
; [Moto-Crash (France)]
; Bios=videopac
;
; Texas Instruments TI 99/4A:
; This system requires full keyboard emulation to work properly
; Split cart dumps are not supported since MESS .145 so you'll have to convert them to RPK format or use an earlier version of MESS (and a different module)
; You can check how to convert split cart dumps to RPK here:
; http://www.ninerpedia.org/index.php/MESS_multicart_system
; For floppy games make sure you have a RPK dump of an extended basic rom on your roms folder. It should be named "extended_basic.rpk"
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

; This object controls how the module reacts to different systems. MESS can play a lot of systems, but needs to know what system you want to run, so this module has to adapt.
mType := Object("Amstrad GX4000","gx4000","APF Imagination Machine","apfimag","Apple IIGS","apple2gs","Atari 2600","a2600","Atari 5200","a5200","Atari 7800","a7800","Atari Jaguar","jaguar","Atari Lynx","lynx","Bally Astrocade","astrocde","Bandai WonderSwan","wswan","Bandai WonderSwan Color","wscolor","Casio PV-1000","pv1000","Casio PV-2000","pv2000","Coleco ADAM","adam","ColecoVision","coleco","Creatronic Mega Duck","megaduck","Emerson Arcadia 2001","arcadia","Entex AdventureVision","advision","Epoch Game Pocket Computer","gamepock","Epoch Super Cassette Vision","scv","Fairchild Channel F","channelf","Funtech Super Acan","supracan","GCE Vectrex","vectrex","Interton VC 4000","vc4000","Magnavox Odyssey 2","odyssey2","Mattel Aquarius","aquarius","Mattel Intellivision","intv","NEC PC Engine","pce","NEC PC Engine-CD","pce","NEC SuperGrafx","sgx","NEC TurboGrafx-16","tg16","NEC TurboGrafx-CD","tg16","Nintendo 64","n64","Nintendo Entertainment System","nes","Nintendo Game Boy","gameboy","Nintendo Game Boy Advance","gba","Nintendo Game Boy Color","gbcolor","Nintendo Virtual Boy","vboy","Philips CD-i","cdimono1","RCA Studio II","studio2","Sega 32X","32x","Sega CD","segacd","Sega Game Gear","gamegear","Sega Genesis","genesis","Sega Master System","sms","Sega Mega Drive","genesis","SNK Neo Geo AES","aes","SNK Neo Geo CD","neocdz","SNK Neo Geo Pocket","ngp","SNK Neo Geo Pocket Color","ngpc","Sony PlayStation","psx","Super Nintendo Entertainment System","snes","Texas Instruments TI 99-4A","ti99_4a","Tiger Game.com","gamecom","VTech CreatiVision","crvision","Watara Supervision","svision")
ident := mType[systemName]	; search object for the systemName identifier MESS uses
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this MESS module: " . moduleName)

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)		; Set fullscreen mode
Videomode := IniReadCheck(settingsFile, "Settings", "Videomode","d3d",,1)	; Choices are gdi,ddraw,d3d. If left blank, mess uses d3d by default
hlsl := IniReadCheck(settingsFile, "Settings|" . systemName, "HLSL","false",,1)
bezelMode := IniReadCheck(settingsFile, "Settings", "BezelMode","layout",,1)	; "layout" or "normal"
UseSoftwareList := IniReadCheck(settingsFile, SystemName, "UseSoftwareList","false",,1)
userparams := IniReadCheck(settingsFile, SystemName, "Parameters",A_Space,,1)
Artwork_Crop := IniReadCheck(settingsFile, systemName . "|" . romName, "Artwork_Crop", "true",,1)
Use_Bezels := IniReadCheck(settingsFile, systemName . "|" . romName, "Use_Bezels", "true",,1)
Use_Overlays := IniReadCheck(settingsFile, systemName . "|" . romName, "Use_Overlays", "true",,1)
Use_Backdrops := IniReadCheck(settingsFile, systemName . "|" . romName, "Use_Backdrops", "true",,1)

7z(romPath, romName, romExtension, 7zExtractPath)

If (bezelEnabled = "true") {
	artworkCrop := If (Artwork_Crop = "true") ? "-artwork_crop" : "-noartwork_crop"
	useBezels := If (Use_Bezels = "true") ? "-use_bezels" : "-nouse_bezels"
	useOverlays := If (Use_Overlays = "true") ? "-use_overlays" : "-nouse_overlays"
	useBackdrops := If (Use_Backdrops = "true") ? "-use_backdrops" : "-nouse_backdrops"
	ListXMLtable := []
	ListXMLtable := ListXMLInfo(ident)
	If bezelMode = layout
		BezelStart(ident,ListXMLtable[1],ListXMLtable[2],ListXMLtable[3],ListXMLtable[4])
	Else if !(Use_Bezels = "true")
		BezelStart(,,ListXMLtable[2])
} Else {
	artworkCrop := "-artwork_crop"
	useBezels := "-nouse_bezels"
	useOverlays := "-nouse_overlays"
	useBackdrops := "-nouse_backdrops"
}

winstate := If (Fullscreen = "true") ? "Hide UseErrorLevel" : "UseErrorLevel"
fullscreen := If (Fullscreen = "true") ? "-nowindow" : "-window"
videomode := If (Videomode != "" )? "-video " . videomode : ""
hlsl := If hlsl = "true" ? "-hlsl_enable" : "-nohlsl_enable"
param1 := "-cart " . """" . romPath . "\" . romName . romExtension . """"	; default param1 used for launching most systems.

If romExtension = .txt	; This can be applied to all systems
	param1:=

If ident = apfimag	; APF Imagination Machine
	If romExtension != .tap
		ident = apfm1000	; cart games for APF Imagination Machine require a different bios to be loaded

If UseSoftwareList != true
{	; Now that we know the system we are loading, determine if we use an ini assocated with that system for custom game configs a user might need. Then load the configs associated to that game.
	If ident in apple2gs,odyssey2,ti99_4a	; these systems will use an ini to store game specific settings
	{	messSysINI := CheckFileMESS(modulePath . "\" . systemName . ".ini")	; create the ini if it does not exist
		If ident = ti99_4a	; Texas Instruments TI 99-4A
		{	mainCart := IniReadCheck(messSysINI, romName, "Main_Cart",A_Space,,1)
			basicCart := IniReadCheck(messSysINI, romName, "Basic_Cart","extended_basic.rpk",,1)	; user can specify a rom specific cart instead of the default basic one
			expansionLocation := IniReadCheck(messSysINI, romName, "Expansion_Location","extended_basic.rpk",,1)
			; Now set the parameters to send to mess
			If romExtension = .dsk	; Expansion Disk
				; If using the mainCart , send expansionLocation to MESS. This will require DirectInput to be enabled on the MESS build! Else we are loading a Disk game
				param1:="-gromport multi -cart1", param2:="""" . romPath . "\" . (If mainCart ? (mainCart):(basicCart)) . """", param3:="-peb:slot2 32kmem -peb:slot3 speech -peb:slot6 tirs232 -peb:slot8 hfdc", param4:="-flop1", param5:="""" . romPath . "\" . romName . romExtension . """"
			Else If romExtension = .rpk	; Cart Game (RPK Format)
				param1:="-gromport multi -cart1", param2:="""" . romPath . "\" . romName . romExtension . """", param3:="-peb:slot3 speech"
			param6 := "-ui_active" ;Enable partial keyboard mode at startup
		}Else if ident = apple2gs	; Apple IIGS
		{	externalOS := IniReadCheck(messSysINI, romName, "External_OS","false",,1)
			2gsSystemFile:="System6.2mg"	;For games without OS included, always force this name and error out if not found
			multipartTable:=CreateRomTable(multipartTable)

			If externalOS = true
			{	CheckFile(romPath . "\" . 2gsSystemFile)
				param1:="-flop3", param2:="""" . romPath . "\" . 2gsSystemFile . """", param3:="-flop4", param4:="""" . romPath . "\" . romName . romExtension . """"
			}Else{
				param1:="-flop3", param2:="""" . romPath . "\" . romName . romExtension . """"
				If (multipartTable.MaxIndex() > 1)
					param3:="-flop4", param4:="""" . multipartTable[2,1] . """"
			}
			param5 := "-ui_active" ;Enable partial keyboard mode at startup
		}Else if ident = odyssey2	; Magnavox Odyssey 2
			param2 := "-ui_active" ;Enable partial keyboard mode at startup

		;Use a different bios if needed (This must be done after the above if conditions since the ident will change)
		iniBios := IniReadCheck(messSysINI, romName, "Bios",ident,,1) ; for all games, we use the default bios. Some games might require different bios like Odyssey2's Jopac games use the videopac bios instead, which should be defined in the ini
		If (iniBios != "")
			ident := iniBios	; need to change the bios name for some games
	}

	; These systems don't use an ini, but do require parameters to be changed from the default method of launching Mess
	If ident = aes	; SNK Neo Geo AES
	{	param1 := "-bios asia-aes" ;can also be jap-aes (default), but the asian one has english menus for most games
		param2 := "-rompath " . """" . "roms;" . romPath . """"
		param3 := "-cart " . romName
	}Else If (ident = "neocdz" || ident = "cdimono1" || ident = "segacd" || ident = "psx" || (ident = "tg16" && systemName = "NEC TurboGrafx-CD") || (ident = "pce" && systemName = "NEC PC Engine-CD"))	; SNK Neo Geo CD, Philips CD-i, Sega CD, Sony PlayStation, NEC PC Engine-CD or NEC TurboGrafx-CD
	{	If romExtension not in .chd,.cue
			ScriptError("MESS only supports " . systemName . " games in chd and cue format. It does not support:`n" . romExtension)
		If (systemName = "NEC TurboGrafx-CD") {		; NEC TurboGrafx-CD needs an additional bios mounted as a cart to run
			; tgcdBios := CheckFile(emuPath . "\roms\CD-ROM System V2.01 (U).pce")	; older bios that doesn't seem to work with many games
			tgcdBios := CheckFile(emuPath . "\roms\Super CD-ROM2 System V3.01 (U).pce")
			param2 := "-cart " . """" . tgcdBios . """"
		} Else If (ident = "psx") {		; Sony PlayStation
			ident = psu	; changing ident sent to Mess to use the USA bios
			; SelectMemCard()	; future function to swap around memcards
			; Usage: mc1 "J:\MESS\software\psu\card1.mc" 
		} If (systemName = "Sega CD") {	; 
			If InStr(romName,"(Jap")	; Mega CD Japanese v2
				ident = megacd2j
			Else If InStr(romName,"(Euro")	; Mega CD European (PAL)
				ident = megacd
		}
		param1 := "-cdrm " . """" . romPath . "\" . romName . romExtension . """"
	}Else If ident = gamecom	; Tiger Game.com
	{	If romExtension != .txt
			param1 := "-cart1 " . """" . romPath . "\" . romName . romExtension . """"
	}Else If ident = vectrex	; GCE Vectrex
	{	If romName = Mine Storm (World)	; Mess dumps an error if you try to launch Mine Storm using a rom instead of just booting vectrex w/o a game in it (Mine Storm is built into vectrex)
			param1:=
	}Else If ident = adam		; Coleco ADAM
	{	If romExtension = .ddp	;  Decide if disk or ddp game
			param1 := (If romExtension = ".ddp" ? "-cass1" : "-net4 fdc,bios=160ta -floppydisk") . " """ . romPath . "\" . romName . romExtension . """"
	}
}Else{	; Use Software List
	hashname := ident
	param1 := "-rompath " . """" . "roms;" . romPath . """" . A_Space . romName	; param1 used for launching from software lists

	If ident = aes	; SNK Neo Geo AES
	{	hashname := "neogeo"
		param2 := "-bios asia-aes" ;can also be jap-aes (default), but the asian one has english menus for most games
	}
	CheckFile(emuPath . "\hash\" . hashname . ".xml","Could not find a software list for the system " . ident) ;Check if software list for selected system exists
}

If ident = vectrex	; GCE Vectrex
	param2 := "-view "  . (If (FileExist(emuPath . "\artwork\Vectrex\" . romName . ".png"))?("""" . romName . """"):"standard")	; need overlays extracted in the artwork\vectres folder. PNGs must match romName

; use a custom cfg file if it exists and append it to param1
IfExist, % emuPath . "\cfg\" . ident . "\" . dbName
	param1 := "-cfg_directory " . """" . emuPath . "\cfg\" . ident . "\" . dbName . """" . A_Space . param1

Run(executable . A_Space . ident . A_Space . param1 . A_Space . param2 . A_Space . param3 . A_Space . param4 . A_Space . param5 . A_Space . param6 . A_Space . userparams . A_Space . fullscreen . A_Space . hlsl . A_Space . videomode . A_Space . artworkCrop . A_Space . useBezels . A_Space . useOverlays . A_Space . useBackdrops . " -skip_gameinfo", emuPath, winstate)

If(ErrorLevel != 0){
	If (ErrorLevel = 1)
		Error = Failed Validity
	Else If(ErrorLevel = 2)
		Error = Missing Files
	Else If(ErrorLevel = 3)
		Error = Fatal Error
	Else If(ErrorLevel = 4)
		Error = Device Error
	Else If(ErrorLevel = 5)
		Error = Game Does Not Exist
	Else If(ErrorLevel = 6)
		Error = Invalid Config
	Else If ErrorLevel in 7,8,9
		Error = Identification Error
	Else
		Error = MESS Error
	ScriptError("MESS Error - " . Error)
}

WinWait("ahk_class MAME")
WinWaitActive("ahk_class MAME")

BezelDraw()

If romName = ICBMromName	; for Bally Astrocade only
{	Sleep, 2000 ; increase if you don't see the title screen
	SetKeyDelay, 50
	Send, {F3 down}{F3 up}	; sends a reset to MESS, needed for ICBM to boot
}

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


; This will simply create a new blank ini if one does not exist
CheckFileMESS(file){
	IfNotExist, %file%
		FileAppend,, %file%
	Return file
}

ListXMLInfo(rom){ ; returns MAME/MESS info about parent rom, orientation angle, resolution
	Global emuFullPath, emuPath
	ListXMLtable := []
	Log("Module - RunWait`, " .  comspec . " /c " . """" . emuFullPath . """" . " -listxml " . rom . " > tempBezel.txt`, " . emuPath . "`, Hide")
	RunWait, % comspec . " /c " . """" . emuFullPath . """" . " -listxml " . rom . " > tempBezel.txt", %emuPath%, Hide
	Fileread, ListxmlContents, %emuPath%\tempBezel.txt
	RegExMatch(ListxmlContents, "s)<game.*name=" . """" . rom . """" . ".*" . "cloneof=" . """" . "[^""""]*", parent)
	RegExMatch(parent,"cloneof=" . """" . ".*", parent)
	RegExMatch(parent,"""" . ".*", parent)
	StringTrimLeft, parent, parent, 1
	RegExMatch(ListxmlContents, "s)<display.*rotate=" . """" . "[0-9]+" . """", angle)
	RegExMatch(angle,"[0-9]+", angle, "-6")
	RegExMatch(ListxmlContents, "s)<display.*width=" . """" . "[0-9]+" . """", width)
	RegExMatch(width,"[0-9]+", width, "-6")
	RegExMatch(ListxmlContents, "s)<display.*height=" . """" . "[0-9]+" . """", Height)
	RegExMatch(Height,"[0-9]+", Height, "-6")
	ListXMLtable[1] := parent
	ListXMLtable[2] := angle
	If (ListXMLtable[2]<>0)
		ListXMLtable[3] := height
	Else
		ListXMLtable[3] := width
	If (ListXMLtable[2]<>0)
		ListXMLtable[4] := width
	Else
		ListXMLtable[4] := height
	FileDelete, %emuPath%\tempBezel.txt
	Return ListXMLtable	
}

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class MAME")
Return

BezelLabel:
	WinSet, Transparent, 0, ahk_class ConsoleWindowClass
Return
