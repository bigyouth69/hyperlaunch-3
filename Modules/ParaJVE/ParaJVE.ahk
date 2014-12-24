MEmu = ParaJVE
MEmuV = v0.7.0
MURL = http://www.vectrex.fr/ParaJVE/
MAuthor = djvj
MVersion = 2.0.2
MCRC = 3793FAE9
iCRC = DC6FE5FD
MID = 635038268912130749
MSystem = "GCE Vectrex"
;----------------------------------------------------------------------------
; Notes:
; To use the built-in roms for this emu, set SkipChecks to "Rom Only" in HLHQ.
; ParaJVE requires Java Runtime Environment 1.5.0+ - Get it here: http://java.com/en/download/index.jsp
; Roms are not needed for this system, they come with the emu
; You must use the official database from HyperList for this module to work
; In order to use the built-in overlays, the romName is being converted to the emu's built in game id found in the configuration.xml. This avoids having to edit the xml manually to change it to HS naming standards. We also don't have to setup overlay files this way too!
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
CreateParaModuleIni()	; create default ini if one doesn't exist
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
Menu := IniReadCheck(settingsFile, "Settings", "Menu","false",,1)
Sound := IniReadCheck(settingsFile, "Settings", "Sound","true",,1)
gameID := IniReadCheck(settingsFile, romName, "gameID",A_Space,,1)

hideEmuObj := Object("ahk_class Static",0,"ParaJVE ahk_class SunAwtFrame",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later

IfExist % romPath . "\" . romName . romExtension
If (!gameID && !userRom)
	ScriptError("Built-in rom not found in " . moduleName . ".ini or in " . romPath . "\" . romName . romExtension . "`nPlease use the official database from HyperList" )

BezelStart()
fullscreen := If Fullscreen = "true" ? "-Fullscreen=TRUE" : "-Fullscreen=FALSE"
menu := If Menu = "true" ? "-Menu=ON" : "-Menu=OFF"
sound := If Sound = "true" ? "-Sound=ON" : "-Sound=OFF"
disableHideToggleMenu := true

If bezelPath {		; check for a bezel image and disable ParaJVE's chassis setting if found
	paraJVEFile := CheckFIle(emuPath . "\data\configuration.xml")
	FileRead, paraJVECFG, %paraJVEFile%
	If InStr(paraJVECFG, "chassis enabled=""true""") {
		paraJVEOrig := paraJVECFG
		paraJVECFG := RegExReplace(paraJVECFG,"chassis enabled=""true""","chassis enabled=""false""")
		Log("Module - Disabling chassis setting in ParaJVE's configuration.xml so bezels work properly")
		SaveFile(paraJVECFG, paraJVEFile)
	}
}

HideEmuStart()

Run(executable . " -game=" . (If userRom ? """" . romPath . "\" . romName . romExtension . """" : gameID) . " " . Fullscreen . " " . Menu . " " . Sound, emuPath) ;, "Min")

WinWait("ParaJVE ahk_class SunAwtFrame")
WinWaitActive("ParaJVE ahk_class SunAwtFrame")

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", "javaw.exe")
FadeOutExit()

If paraJVEOrig {	;If bezel was used, save original config file
	Log("Module - Restoring ParaJVE's original configuration.xml")
	SaveFile(paraJVEOrig, paraJVEFile)
}

ExitModule()


CreateParaModuleIni() {
	Global settingsFile
	If !FileExist(settingsFile)
	{	txt := "# Standard games`r`n[Armor..Attack (World)]`r`ngameID = ARMORATTACK`r`n[Bedlam (USA, Europe)]`r`ngameID = BEDLAM`r`n[Berzerk (World)]`r`ngameID = BERZERK`r`n[Blitz! - Action Football (USA, Europe)]`r`ngameID = BLITZ`r`n[Clean Sweep (World)]`r`ngameID = CLEANSWEEP`r`n[Cosmic Chasm (World)]`r`ngameID = COSMICCHASM`r`n[Fortress of Narzod (USA, Europe)]`r`ngameID = NARZOD`r`n[Heads-Up - Action Soccer (USA)]`r`ngameID = HEADSUP`r`n[HyperChase - Auto Race (World)]`r`ngameID = HYPERCHASE`r`n[Mine Storm (World)]`r`ngameID = MINESTORM`r`n[Mine Storm II (USA)]`r`ngameID = MINESTORM2`r`n[Polar Rescue (USA)]`r`ngameID = POLARRESCUE`r`n[Pole Position (USA)]`r`ngameID = POLEPOSITION`r`n[Rip Off (World)]`r`ngameID = RIPOFF`r`n[Scramble (USA, Europe)]`r`ngameID = SCRAMBLE`r`n[Solar Quest (World)]`r`ngameID = SOLARQUEST`r`n[Space Wars (World)]`r`ngameID = SPACEWARS`r`n[Spike (USA, Europe)]`r`ngameID = SPIKE`r`n[Spinball (USA)]`r`ngameID = SPINBALL`r`n[Star Castle (USA)]`r`ngameID = STARCASTLE`r`n[Star Trek - The Motion Picture (USA)]`r`ngameID = STARTREK`r`n[Star Hawk (World)]`r`ngameID = STARHAWK`r`n[Web Wars (USA)]`r`ngameID = WEBWARS`r`n# 3D Imager games`r`n[3D Crazy Coaster (USA)]`r`ngameID = 3DCRAZYCOASTER`r`n[3D Mine Storm (USA)]`r`ngameID = 3DMINESTORM`r`n[3D Narrow Escape (USA)]`r`ngameID = 3DNARROWESCAPE`r`n# Homebrew games`r`n[3D Lord Of The Robots (World) (Unl)]`r`ngameID = 3DLOTR`r`n[All Good Things (World) (Unl)]`r`ngameID = ALLGOODTHINGS`r`n[City Bomber (World) (Unl)]`r`ngameID = CITYBOMBER`r`n[Continuum (World) (Unl)]`r`ngameID = CONTINUUM`r`n[Gravitrex (World) (Unl)]`r`ngameID = GRAVITREX`r`n[Moon Lander (World) (Unl)]`r`ngameID = MOONLANDER`r`n[Nebula Commander (World) (Unl)]`r`ngameID = NEBULA`r`n[Omega Chase (World) (Unl)]`r`ngameID = OMEGACHASE`r`n[Patriots (World) (Unl)]`r`ngameID = PATRIOTS`r`n[Patriots Remix (World) (Unl)]`r`ngameID = PATRIOTSREMIX`r`n[Patriots III (World) (Unl)]`r`ngameID = PATRIOTS3`r`n[Protector (World) (Unl)]`r`ngameID = PROTECTOR`r`n[Repulse (World) (Unl)]`r`ngameID = REPULSE`r`n[Revector (World) (Unl)]`r`ngameID = REVECTOR`r`n[Rockaroids Remix (World) (Unl)]`r`ngameID = ROCKAR`r`n[Rockaroids Remix - 3rd Rock (World) (Unl)]`r`ngameID = ROCKAR3RD`r`n[Space Frenzy (World) (Unl)]`r`ngameID = SPACEFRENZY`r`n[Spike Hoppin' (World) (Unl)]`r`ngameID = SPIKEHOPPIN`r`n[Spike's Water Balloons (World) (Unl)]`r`ngameID = SPIKEBALLONS`r`n[Star Fire Spirits (World) (Unl)]`r`ngameID = STARFIRESPIR`r`n[Star Sling - Freeware Edition (World) (Unl)]`r`ngameID = STARSLING`r`n[Star Sling - Turbo Edition (World) (Unl)]`r`ngameID = STARSLING_1`r`n[Thrust (World) (Unl)]`r`ngameID = THRUST`r`n[Tsunami (World) (Unl)]`r`ngameID = TSUNAMI`r`n[Vectrex Frogger (World) (Unl)]`r`ngameID = VFROGGER`r`n[Vaboom! (World) (Unl)]`r`ngameID = VABOOM`r`n[Vec Fu (World) (Unl)]`r`ngameID = VECFU`r`n[Vecmania (World) (Unl)]`r`ngameID = VECMANIA64`r`n[Vectopia (World) (Unl)]`r`ngameID = VECTOPIA64`r`n[Vector 21 (World) (Unl)]`r`ngameID = VECTOR21`r`n[Vector Sports Boxing (World) (Unl)]`r`ngameID = VECTORSPORTSBOX`r`n[Vector Vaders (World) (Unl)]`r`ngameID = VECTORVADERS`r`n[Vector Vaders Remix (World) (Unl)]`r`ngameID = VECTORVADERSREMIX`r`n[Vectrace (World) (Unl)]`r`ngameID = VECTRACE`r`n[Vectrex Maze (World) (Unl)]`r`ngameID = VECTREXMAZE`r`n[Vectrex Pong (World) (Unl)]`r`ngameID = VECTREXPONG`r`n[Vectrexians (World) (Unl)]`r`ngameID = VECTREXIANS`r`n[Vexperience - B.E.T.H. and Vecsports Boxing (World) (Unl)]`r`ngameID = VEXPERIENCE`r`n[Vimpula (World) (Unl)]`r`ngameID = VIMPULA`r`n[VIX (World) (Unl)]`r`ngameID = VIX`r`n[War of the Robots (World) (Unl)]`r`ngameID = WOTR`r`n[War of the Robots - Bow to the Queen (World) (Unl)]`r`ngameID = BTTQ`r`n[Wormhole (World) (Unl)]`r`ngameID = WORMHOLE`r`n# VecVoice enabled games`r`n[Verzerk (World) (Unl)]`r`ngameID = VERZERK`r`n[Yasi (World) (Unl)]`r`ngameID = YASI`r`n# Lightpen games`r`n[AnimAction - Advanced Animation (USA)]`r`ngameID = ANIMACTION`r`n[Art Master (USA)]`r`ngameID = ARTMASTER`r`n[Engine Analyzer (USA) (Proto)]`r`ngameID = ANALYZER`r`n[Melody Master - Music Composition and Entertainment (USA)]`r`ngameID = MELODYMASTER`r`n# Prototypes`r`n[Pitcher's Duel (USA) (Proto)]`r`ngameID = PITCHERSDUEL"
		FileAppend, %txt%, %settingsFile%
	}
}

SaveFile(text,file) {
	FileDelete, %file%
	FileAppend, %text%, %file%
}

CloseProcess:
	FadeOutStart()
	BezelExit()
	WinClose("ParaJVE ahk_class SunAwtFrame")
Return
