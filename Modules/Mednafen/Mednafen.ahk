MEmu = Mednafen
MEmuV =  v0.9.31 WIP
MURL = http://mednafen.sourceforge.net/
MAuthor = djvj
MVersion = 2.0.5
MCRC = 7ECA1014
iCRC = 5D855D01
MID = 635038268903923913
MSystem = "Atari Lynx","Bandai Wonderswan","Bandai Wonderswan Color","NEC PC Engine","NEC PC Engine-CD","NEC PC-FX","NEC SuperGrafx","NEC TurboGrafx-16","NEC TurboGrafx-CD","Nintendo Entertainment System","Nintendo Famicom","Nintendo Famicom Disk System","Nintendo Game Boy","Nintendo Game Boy Advance","Nintendo Game Boy Color","Nintendo Super Famicom","Nintendo Virtual Boy","Sega Game Gear","Sega Genesis","Sega Master System","Sega Mega Drive","SNK Neo Geo Pocket","SNK Neo Geo Pocket Color","Sony PlayStation","Super Nintendo Entertainment System"
;----------------------------------------------------------------------------
; Notes:
; Below are some basic params you can change, there are many other params
; located in the mednafen documentation that you can add If needed.
;
; Some people experience screen flickering and mednafen will not stay in 
; fullscreen, you can changed vDriver below to -vdriver sdl and it will
; possibly fix the issue.
;
; There is no error checking If mednafen fails, so If you try to launch
; your game and nothing happens, then check the stdout.txt in your mednafen
; installation directory to see what went wrong.
;
; To remap your keys, start a game then press alt + shift + 1 to enter
; the key configuration.  Also see mednafen.cfg to change other keys such
; as the exit key.
;
; Atari Lynx:
; Create a folder called "firmware" in your mednafen folder and place lynxboot.img in there
;
; Nintendo Virtual Boy:
; For Virtual Boy you might not be able to get in game and get stuck
; on the intro screen, so open your cfg file and change these settings
; to allow you to play. There are some extra options here to.
; vb.anaglyph.lcolor 0xFF0000
; vb.anaglyph.preset disabled
; vb.anaglyph.rcolor 0x000000
; vb.default_color 0xFFFFFF
; vb.disable_parallax 0
; vb.input.builtin.gamepad.a keyboard 109
; vb.input.builtin.gamepad.b keyboard 110
; vb.input.builtin.gamepad.down-l keyboard 100
; vb.input.builtin.gamepad.down-r keyboard 107
; vb.input.builtin.gamepad.left-l keyboard 115
; vb.input.builtin.gamepad.left-r keyboard 106
; vb.input.builtin.gamepad.lt keyboard 103
; vb.input.builtin.gamepad.rapid_a keyboard 46
; vb.input.builtin.gamepad.rapid_b keyboard 44
; vb.input.builtin.gamepad.right-l keyboard 102
; vb.input.builtin.gamepad.right-r keyboard 108
; vb.input.builtin.gamepad.rt keyboard 104
; vb.input.builtin.gamepad.select keyboard 118
; vb.input.builtin.gamepad.start keyboard 13
; vb.input.builtin.gamepad.up-l keyboard 101
; vb.input.builtin.gamepad.up-r keyboard 105

; Sony PlayStation Info:
; Create a folder called "firmware" in your mednafen folder and place all your bios files (ex. scph5501.bin) in there. Set the options below so mednafen can find them
; This module only supports Daemon Tools when mounting with a cue extension for psx.
; Set your rom extension to cue
; Multi-Disc games REQUIRES Daemon Tools, do not attempt to swap discs any other way as it is not supported by this module.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

; The next 2 objects control how the module reacts to different systems. Mednafen can play a lot of systems, but changes itself slightly so this module has to adapt 
mType1 := Object("Atari Lynx","lynx","Bandai Wonderswan","wswan","Bandai Wonderswan Color","wswan","NEC PC Engine","pce","NEC PC-FX","pcfx","NEC SuperGrafx","pce","NEC TurboGrafx-16","pce","Nintendo Entertainment System","nes","Nintendo Famicom","nes","Nintendo Famicom Disk System","nes","Nintendo Game Boy","gb","Nintendo Game Boy Advance","gba","Nintendo Game Boy Color","gb","Nintendo Super Famicom","snes","Nintendo Virtual Boy","vb","Samsung Gam Boy","sms","Sega Game Gear","gg","Sega Genesis","md","Sega Mega Drive","md","Sega Master System","sms","SNK Neo Geo Pocket","ngp","SNK Neo Geo Pocket Color","ngp","Super Nintendo Entertainment System","snes")
mType2 := Object("NEC PC Engine-CD","pce","NEC TurboGrafx-CD","pce","Sony PlayStation","psx")	; these systems change Mednafen's window name, so it needs to be separate from the rest

ident1 := mType1[systemName]	; search 1st array for the systemName identifier mednafen uses
ident2 := mType2[systemName]	; search 2nd array for the systemName identifier mednafen uses
ident := If (!ident1 && !ident2) ? ("") : (ident1 . ident2)
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this Mednafen module: " . moduleName)

settingsFile := modulePath . "\" . systemName . ".ini"
IfNotExist, %settingsFile%
	settingsFile := modulePath . "\" . moduleName . ".ini"

; Settings used for all systems
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
Stretch := IniReadCheck(settingsFile, "Settings", "Stretch","aspect",,1)			; 0, aspect, or full
vDriver := IniReadCheck(settingsFile, "Settings", "vDriver","opengl",,1)				; opengl or sdl
xRes := IniReadCheck(settingsFile, "Settings", "xRes",0,,1)
yRes := IniReadCheck(settingsFile, "Settings", "yRes",0,,1)

stretch := If Stretch ? ("-" . ident . ".stretch " . Stretch) : ""
vDriver := If vDriver ? ("-vdriver " . vDriver) : ""
xRes := If xRes ? ("-" . ident . ".xres " . xRes) : ""
yRes := If yRes ? ("-" . ident . ".yres " yRes) : ""

If ident = lynx	; this needs to be before BezelStart so we can tell it if we need to rotate the screen or not
{	rotateScreen := IniReadCheck(settingsFile, romName, "RotateScreen","false",,1)	; also remove all systemName section support, using systemName ini files instead, like MESS module
	rotateScreen := If rotateScreen = "true" ? "-lynx.rotateinput 1" : ""
	CheckFile(emuPath . "\firmware\lynxboot.img","Cannot find the Atari Lynx bios file required to use this system:`n" . emuPath . "\firmware\lynxboot.img")
}

BezelStart(,,(If rotateScreen ? 1:""))

emuFullscreen := If Fullscreen = "true" ? "-fs 1" : "-fs 0"	; This needs to stay after BezelStart

If ident1 = pce
	sgfxMode := If (systemName = "NEC SuperGrafx" && romExtension != sgx) ? "-pce.forcesgx 1"  : ""

If ident2 = pce
{	PCE_CD_Bios := IniReadCheck(settingsFile, "Bios", "PCE_CD_Bios","syscard3.pce",,1)		; Bios, placed in the bios subfolder of the emu, required for these systems: NEC PC Engine-CD & NEC TurboGrafx-CD
	CheckFile(emuPath . "\firmware\" . PCE_CD_Bios ,"Cannot find the PCE_CD_Bios  file you have defined in the module:`n" . emuPath . "\firmware\" . PCE_CD_Bios)
	pceCDBios := If PCE_CD_Bios ? ("-pce.cdbios ""firmware\"  . PCE_CD_Bios  . """") : ""
}
If ident = pcfx
{	PCFX_Bios := IniReadCheck(settingsFile, "Bios", "PCFX_Bios","pcfxbios.bin",,1)			; Bios, placed in the bios subfolder of the emu, required for NEC PC-FX
	CheckFile(emuPath . "\firmware\" . PCFX_Bios ,"Cannot find the PCFX_Bios  file you have defined in the module:`n" . emuPath . "\firmware\" . PCFX_Bios)
	pcfxBios := If PCFX_Bios ? ("-pcfx.bios ""firmware\"  . PCFX_Bios  . """") : ""
}

If ident = psx	; only need these for Sony PlayStation, must check If these files exist, otherwise mednafan doesn't launch and HL gets stuck
{	NA_Bios := IniReadCheck(settingsFile, "Bios", "NA_Bios","PSX - SCPH1001.bin",,1)		; Sony PlayStation only - this is the bios you want to use for North American games - place this in a "bios" subfolder where Mednafen is
	EU_Bios := IniReadCheck(settingsFile, "Bios", "EU_Bios","PSX - SCPH5502.bin",,1)		; Sony PlayStation only - this is the bios you want to use for European games - place this in a "bios" subfolder where Mednafen is
	JP_Bios := IniReadCheck(settingsFile, "Bios", "JP_Bios","PSX - SCPH5500.bin",,1)		; Sony PlayStation only - this is the bios you want to use for Japanese games - place this in a "bios" subfolder where Mednafen is
	CheckFile(emuPath . "\firmware\" . NA_Bios,"Cannot find the NA_Bios file you have defined in the module:`n" . emuPath . "\firmware\" . NA_Bios)
	CheckFile(emuPath . "\firmware\" . EU_Bios,"Cannot find the EU_Bios file you have defined in the module:`n" . emuPath . "\firmware\" . EU_Bios)
	CheckFile(emuPath . "\firmware\" . JP_Bios,"Cannot find the JP_Bios file you have defined in the module:`n" . emuPath . "\firmware\" . JP_Bios)
	naBios := If NA_Bios ? ("-psx.bios_na ""firmware\" . NA_Bios . """") : ""
	euBios := If EU_Bios ? ("-psx.bios_eu ""firmware\" .  EU_Bios . """") : ""
	jpBios := If JP_Bios ? ("-psx.bios_jp ""firmware\"  . JP_Bios . """") : ""
}

If bezelPath ; defining xscale and yscale relative to the bezel windowed mode
{	If ident = lynx
	{	If !rotateScreen
		{	bezelXres := IniReadCheck(settingsFile, "Settings", "Bezel_X_Res",160,,1)	; Controls width of the emu's window, relative to the bezel's window
			bezelYres := IniReadCheck(settingsFile, "Settings", "Bezel_Y_Res",102,,1)	; Controls height of the emu's window, relative to the bezel's window
		} Else {
			bezelXres := IniReadCheck(settingsFile, "Settings", "Bezel_X_Vertical_Res",198,,1)	; Only for Atari Lynx vertical games - Controls height of the emu's window, relative to the bezel's vertical window
			bezelYres := IniReadCheck(settingsFile, "Settings", "Bezel_Y_Vertical_Res",164,,1)	; Only for Atari Lynx vertical games - Controls width of the emu's window, relative to the bezel's vertical window
		}
	} Else If ident = wswan
	{	bezelXres := IniReadCheck(settingsFile, "Settings", "Bezel_X_Res",224,,1)
		bezelYres := IniReadCheck(settingsFile, "Settings", "Bezel_Y_Res",144,,1)
	} Else If ident = pce
	{	bezelXres := IniReadCheck(settingsFile, "Settings", "Bezel_X_Res",288,,1)
		bezelYres := IniReadCheck(settingsFile, "Settings", "Bezel_Y_Res",231,,1)
	} Else If ident = pcfx
	{	bezelXres := IniReadCheck(settingsFile, "Settings", "Bezel_X_Res",341,,1)
		bezelYres := IniReadCheck(settingsFile, "Settings", "Bezel_Y_Res",480,,1)
	} Else If ident = nes
	{	bezelXres := IniReadCheck(settingsFile, "Settings", "Bezel_X_Res",298,,1)
		bezelYres := IniReadCheck(settingsFile, "Settings", "Bezel_Y_Res",240,,1)
	} Else If ident = gb
	{	bezelXres := IniReadCheck(settingsFile, "Settings", "Bezel_X_Res",160,,1)
		bezelYres := IniReadCheck(settingsFile, "Settings", "Bezel_Y_Res",144,,1)
	} Else If ident = gba
	{	bezelXres := IniReadCheck(settingsFile, "Settings", "Bezel_X_Res",240,,1)
		bezelYres := IniReadCheck(settingsFile, "Settings", "Bezel_Y_Res",160,,1)
	} Else If ident = snes
	{	bezelXres := IniReadCheck(settingsFile, "Settings", "Bezel_X_Res",512,,1)
		bezelYres := IniReadCheck(settingsFile, "Settings", "Bezel_Y_Res",478,,1)
	} Else If ident = vb
	{	bezelXres := IniReadCheck(settingsFile, "Settings", "Bezel_X_Res",384,,1)
		bezelYres := IniReadCheck(settingsFile, "Settings", "Bezel_Y_Res",224,,1)
	} Else If ident = gg
	{	bezelXres := IniReadCheck(settingsFile, "Settings", "Bezel_X_Res",160,,1)
		bezelYres := IniReadCheck(settingsFile, "Settings", "Bezel_Y_Res",144,,1)
	} Else If ident = md
	{	bezelXres := IniReadCheck(settingsFile, "Settings", "Bezel_X_Res",320,,1)
		bezelYres := IniReadCheck(settingsFile, "Settings", "Bezel_Y_Res",480,,1)
	} Else If ident = sms
	{	bezelXres := IniReadCheck(settingsFile, "Settings", "Bezel_X_Res",256,,1)
		bezelYres := IniReadCheck(settingsFile, "Settings", "Bezel_Y_Res",240,,1)
	} Else If ident = ngp
	{	bezelXres := IniReadCheck(settingsFile, "Settings", "Bezel_X_Res",160,,1)
		bezelYres := IniReadCheck(settingsFile, "Settings", "Bezel_Y_Res",152,,1)
	} Else If ident = psx
	{	bezelXres := IniReadCheck(settingsFile, "Settings", "Bezel_X_Res",640,,1)
		bezelYres := IniReadCheck(settingsFile, "Settings", "Bezel_Y_Res",480,,1)
	}
	xscale := round( bezelScreenWidth / bezelXres , 2)
	yscale := round( bezelScreenHeight / bezelYres , 2)
	xscale := "-" . ident . ".xscale " . xscale
	yscale := "-" . ident . ".yscale " . yscale
}

;----------------------------------------------------------------------------

7z(romPath, romName, romExtension, 7zExtractPath)

; Mount the CD using DaemonTools
If (romExtension = ".cue" && dtEnabled = "true" && ident = "psx") {	; only Sony PlayStation tested
	Log("Module - Mounting rom in Daemon Tools")
	DaemonTools("get")
	DaemonTools("mount",romPath . "\" . romName . romExtension)
	useDT = 1
}

Run(executable . " " . emuFullscreen . " " . stretch . " " . vDriver . " " . (If Fullscreen = "true" ? xRes . " " . yRes : xscale . " " . yscale) . " " . sgfxMode . " " . naBios . " " . euBios . " " . jpBios . " " . pceCDBios . " " . pcfxBios . " " . rotateScreen . " " . (If useDT ? "-physcd " . dtDriveLetter . ":" : """" . romPath . "\" . romName . romExtension . """"), emuPath)

; WinWait, % (If ident2 ? ("Mednafen") : (romName)) . " ahk_class SDL_app"
; WinWaitActive, % (If ident2 ? ("Mednafen") : (romName)) . " ahk_class SDL_app"
WinWait("ahk_class SDL_app")
WinWaitActive("ahk_class SDL_app")
BezelDraw()
FadeInExit()

errorLvl := Process("Exist", executable)
If errorLvl != 0
	Process("WaitClose", executable)

7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


MultiGame:
	If (romExtension = ".cue" && dtEnabled = "true" && ident = "psx") {
		Send, {F8 down}{F8 up}	; eject disc in mednafen - MIGHT WANT TO TRY DOING A CONTROLSEND
		DaemonTools("unmount")
		Sleep, 500	; Required to prevent  DT from bugging
		DaemonTools("mount",selectedRom,"dt")	; forcing dt drive, scsi does not work in mednafen
		WinActivate, ahk_class SDL_app
		Send, {F8 down}{F8 up}	; eject disc in mednafen
	}
Return
RestoreEmu:
	If fullscreen = true
		WinMaximize, Mednafen ahk_class SDL_app	; mednafen will not restore unless this command is used
	WinActivate, Mednafen ahk_class SDL_app
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class SDL_app")
	; WinClose, % (If ident2 ? ("Mednafen") : (romName)) . " ahk_class SDL_app"
Return
