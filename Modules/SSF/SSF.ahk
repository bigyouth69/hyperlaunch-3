MEmu = SSF
MEmuV =  v0.12 beta R4
MURL = http://www7a.biglobe.ne.jp/~phantasy/ssf/
MAuthor = djvj
MVersion = 2.0.5
MCRC = 20071FE1
iCRC = DAC1D75D
MID = 635038268924991452
MSystem = "Sega Saturn","Sega ST-V"
;------------------------------------------------------------------------
; Notes:
; Sega Saturn:
; This only works with DTLite, not DTPro
; Make sure your Daemontools Path in HLHQ is correct
; romExtension should be ccd|mds|cue|iso|cdi|nrg
; You MUST set the path to the 3 different region BIOS files in HLHQ module's settings.
; If you prefer a region-free bios, extract this bios and set all 3 bios paths to this one file: http://theisozone.com/downloads/other-consoles/sega-saturn/sega-saturn-region-free-bios/
; Make sure you have your CDDrive set to whatever number you use for your games. 0 may be your hardware drive, while 1 may be your virtual drive (depending on how many you have). If you get a black screen, try different numbers starting from 0.
; If you keep getting the CD Player BIOS screen, you have the CDDrive variable set wrong below
; If you keep getting the CD Player screen with the message "Game disc unsuitable for this system", you have the incorrect bios set for the region game you are playing and or region is set wrong in the emu options. Or you can just turn off the BIOS below :)
; If your game's region is (USA), you must use a USA bios and set SSF Area Code to "America, Canada Brazil". For (Japan) games, bios must be a Japan one and SSF Area Code set to Japan. Use the same logic for European games. You will only see a black screen if wrong.
; SSF forces 1024x768 in fullscreen mode if your GPU supports pixel shader 3.0, otherwise it forces 640x480 if it does not. This cannot be changed as far as I can tell.
; If you are getting clipping, set the vSync variable to true below
; For faster MultiGame switching, keep the BIOS off, otherwise you have to "play" the disc each time you switch discs
; Module will attempt to auto-detect the region for your game by using the region tags in parenthesis on your rom file and set SSF to use the appropriate region settings that match.
;
; Shining Force III - Scenario 2 & 3 (Japan) (Translated En) games crash at chapter 4 and when you use Marki Proserpina spell or using the Abyss Wand. Fix may be to use a different bios if this occurs, but this is untested. Read more about it here: http://forums.shiningforcecentral.com/viewtopic.php?f=34&t=14858&start=80
;
; Sega ST-V:
; romExtension should be zip
; Extract the stv110.bin bios into the BIOS folder. Run SSF.exe and goto Option->Option and point ST-V BIOS to this file.
; Set fullscreen mode via the variable below
; If you are getting clipping, set the vSync variable to true below
;
; If it seems like it's taking a long time to load, it probably is. You are going to stare at the black screen while SSF is decoding the roms.
;------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
ShowBIOS := IniReadCheck(settingsFile, "Settings", "ShowBIOS","false",,1)
BilinearFiltering := IniReadCheck(settingsFile, "Settings", "BilinearFiltering","true",,1)
WideScreen := IniReadCheck(settingsFile, "Settings", "WideScreen","false",,1)
Stretch := IniReadCheck(settingsFile, "Settings", "Stretch","false",,1)
AutoFieldSkip := IniReadCheck(settingsFile, "Settings", "AutoFieldSkip","true",,1)
EnforceAspectRatioWindow := IniReadCheck(settingsFile, "Settings", "EnforceAspectRatioWindow","true",,1)
EnforceAspectRatioFullscreen := IniReadCheck(settingsFile, "Settings", "EnforceAspectRatioFullscreen","true",,1)
FixedWindowResolution := IniReadCheck(settingsFile, "Settings", "FixedWindowResolution","false",,1)
FixedFullscreenResolution := IniReadCheck(settingsFile, "Settings", "FixedFullscreenResolution","false",,1)
VSynchWaitWindow := IniReadCheck(settingsFile, "Settings", "VSynchWaitWindow","true",,1)
VSynchWaitFullscreen := IniReadCheck(settingsFile, "Settings", "VSynchWaitFullscreen","true",,1)
CDDrive := IniReadCheck(settingsFile, "Settings", "CDDrive","1",,1)
defaultRegion := IniReadCheck(settingsFile, "Settings", "DefaultRegion","America, Canada, Brazil",,1)
usBios := IniReadCheck(settingsFile, "Settings", "USBios","",,1)
euBios := IniReadCheck(settingsFile, "Settings", "EUBios","",,1)
jpBios := IniReadCheck(settingsFile, "Settings", "JPBios","",,1)
usBios := GetFullName(usBios)	; convert relative to absolute path
euBios := GetFullName(euBios)
jpBios := GetFullName(jpBios)

BezelStart()
7z(romPath, romName, romExtension, 7zExtractPath)

If romExtension not in .ccd,.mds,.cue,.iso,.cdi,.nrg
	ScriptError("SSF only supports extensions ""mds|cue|iso|cdi|nrg"" and you are trying to use """ . romExtension . """")

SSFINI := CheckFile(emuPath . "\SSF.ini")
mySW := A_ScreenWidth
mySH := A_ScreenHeight

; Now let's update all our keys if they differ in the ini
Fullscreen := If Fullscreen = "true" ? "1" : "0"
ShowBIOS := If ShowBIOS = "true" ? "0" : "1"
BilinearFiltering := If BilinearFiltering = "true" ? "1" : "0"
WideScreen := If WideScreen = "true" ? "1" : "0"
Stretch := If Stretch = "true" ? "1" : "0"
AutoFieldSkip := If AutoFieldSkip = "true" ? "1" : "0"
EnforceAspectRatioWindow := If EnforceAspectRatioWindow = "true" ? "1" : "0"
EnforceAspectRatioFullscreen := If EnforceAspectRatioFullscreen = "true" ? "1" : "0"
FixedWindowResolution := If FixedWindowResolution = "true" ? "1" : "0"
FixedFullscreenResolution := If FixedFullscreenResolution = "true" ? "1" : "0"
VSynchWaitWindow := If VSynchWaitWindow = "true" ? "1" : "0"
VSynchWaitFullscreen := If VSynchWaitFullscreen = "true" ? "1" : "0"
defaultRegion := If defaultRegion = "America, Canada, Brazil" ? "1" : If defaultRegion = "Japan, Taiwan, Korea, Philippines" ? "2" : "3"	; translating for easier use later

If systemName = Sega Saturn
{	If RegExMatch(romName, "\(U\)|\(USA\)|\(Braz")
	{	Log("Module - This is an American rom. Setting SSF's settings to this region.")
		Areacode := "4"	; 1 = Japan, 2 = Taiwan/Korea/Philippines. 4 = America/Canada/Brazil, c = Europe/Australia/South Africa
		SaturnBIOS := usBios
	} Else If RegExMatch(romName, "JP|\(J\)|\(Jap")
	{	Log("Module - This is a Japanese rom. Setting SSF's settings to this region.")
		Areacode := "1"
		SaturnBIOS := jpBios
	} Else If RegExMatch(romName, "\(Eu\)|\(Eur|\(German")
	{	Log("Module - This is a European rom. Setting SSF's settings to this region.")
		Areacode := "c"
		SaturnBIOS := euBios
	} Else If RegExMatch(romName, "\(Kore")
	{	Log("Module - This is a Korean rom. Setting SSF's settings to this region.")
		Areacode := "2"
		SaturnBIOS := jpBios	; don't see a bios for this region, assuming it uses japanese one
	} Else
	{	Log("Module - This rom has an UNKNOWN region. Reverting to use your default region. If you get a black screen, please rename your rom to add a proper (Region) tag.",2)
		Areacode := If defaultRegion = "1" ? "4" : If defaultRegion = "2" ? "1" : "c"
		SaturnBIOS := If defaultRegion = "1" ? usBios : If defaultRegion = "2" ? jpBios : euBios
	}

	If RegExMatch(romName, "i)ultraman.*hikari") {		; only for the game Ultraman - Hikari no Kyojin Densetsu (Japan). Game's file name must contain "ultraman" and "hikari" to trigger this condition
		CartridgeID := "21"
		DataCartridgeEnable := "1"
		DataCartridge := romPath . "\" . romName . ".rom"
	} Else {	; all other games
		CartridgeID := "5c"
		DataCartridgeEnable := "0"
		DataCartridge := 
	}
}

; Compare existing settings and if different then desired, write them to the SSF.ini
iniLookup =
( ltrim c
	Screen, FullSize, "%Fullscreen%"
	Screen, BilinearFiltering, "%BilinearFiltering%"
	Screen, WideScreen, "%WideScreen%"
	Screen, StretchScreen, "%Stretch%"
	Screen, AutoFieldSkip, "%AutoFieldSkip%"
	Screen, EnforceAspectRatioWindow, "%EnforceAspectRatioWindow%"
	Screen, EnforceAspectRatioFullscreen, "%EnforceAspectRatioFullscreen%"
	Screen, FixedWindowResolution, "%FixedWindowResolution%"
	Screen, FixedFullscreenResolution, "%FixedFullscreenResolution%"
	Screen, VSynchWaitWindow, "%VSynchWaitWindow%"
	Screen, VSynchWaitFullscreen, "%VSynchWaitFullscreen%"
	Peripheral, SaturnBIOS, "%SaturnBIOS%"
	Peripheral, CDDrive, "%CDDrive%"
	Peripheral, Areacode, "%Areacode%"
	Peripheral, CartridgeID, "%CartridgeID%"
	Peripheral, DataCartridgeEnable, "%DataCartridgeEnable%"
	Peripheral, DataCartridge, "%DataCartridge%"
	Program4, NoBIOS, "%ShowBIOS%"
	Other, ScreenMode, "%Fullscreen%"
)
Loop, Parse, iniLookup, `n
{
	StringSplit, split, A_LoopField, `,, %A_Space%%A_Tab%
	IniRead, tempVar, %SSFINI%, %split1%, %split2%
	If ( tempVar != split3 ) {
		Log("Module - SSF INI Update - Changing [" . split1 . "] " . split2 . " to " . split3)
		IniWrite, % split3, %SSFINI%, %split1%, %split2%
	}
}

If systemName = Sega Saturn
	DaemonTools("mount",romPath . "\" . romName . romExtension)

; Run(executable,emuPath,(If Fullscreen = 1 ? ("Hide" ): ("")), ssfPID)	; Worked in R3, not in R4
Run(executable,emuPath,, ssfPID)

If systemName = Sega ST-V
{	Send, {SHIFTDOWN} ; this tells SSF we want to boot in ST-V mode
	WinWait("Select ROM file ahk_class #32770",,8) ; times out after 8 Seconds
	If ErrorLevel
	{	Send, {SHIFTUP}
		WinClose, SSF
		ScriptError("Module timed out waiting for Select ROM file window. This probably means you did not set your ST-V bios or have an invalid ST-V bios file.")
	}
	IfWinNotActive, Select ROM file ahk_class #32770, , WinActivate, Select ROM file
	WinWaitActive("Select ROM file ahk_class #32770")
	Send, {SHIFTUP}
	Loop {
		ControlGetText, edit1Text, Edit1, Select ROM file ahk_class #32770
		If ( edit1Text = romPath . "\" . romName . romExtension )
			Break
		Sleep, 100
		ControlSetText, Edit1, %romPath%\%romName%%romExtension%, Select ROM file ahk_class #32770
	}
	Send, {ENTER}
	WinWait("Decoding ahk_class #32770")
}

WinWait("SSF")
WinWaitActive("SSF")
BezelDraw()
Sleep, 1000 ; SSF flashes in real fast before going fullscreen if this is not here

FadeInExit()

; WinMove,SSF,,0,0 ; uncomment me if you turned off fullscreen mode and cannot see the emu, but hear it in the background

Process("WaitClose", executable)

If systemName = Sega Saturn
	DaemonTools("unmount")

7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


HaltEmu:
	disableActivateBlackScreen = true
	If Fullscreen = 1 ; only have to take the emu out of fullscreen we are using it
	{		; SSF cannot swap discs in fullscreen mode, so we have to go windowed first, swap, and restore fullscreen
		WinGet, ssfPID, ID, A
		WinGetPos,,,ssfW,ssfH,ahk_id %ssfPID%
		SetKeyDelay,,10
		Send, !{Enter}
		WinSet, Transparent, 0, ahk_id %ssfPID%
		If (mySW != ssfW || mySH != ssfH) { ; if our screen not the same size as SSF uses for it's fullscreen, we can detect when it changes
			While % ssfH = ssfHn
			{	WinGetPos,,,,ssfHn,ahk_id %ssfPID%
				Sleep, 100
			}
		} Else ; if our screen is the same size as SSF uses for it's fullscreen, use a sleep instead
			Sleep, 3000 ; increase me if MG GUI is showing tiny instead of the full screen size
		tempgui()
	}
Return

MultiGame:
	WinMenuSelectItem,ahk_id %ssfID%,,Hardware,CD Open
	DaemonTools("unmount")
	Sleep, 200	; just in case script moves too fast for DT
	DaemonTools("mount",selectedRom)
	WinMenuSelectItem,ahk_id %ssfID%,,Hardware,CD Close
	If Fullscreen = 1
	{
		Loop { ; looping until SSF is done loading the new disc
			Sleep, 200
			WinGetTitle, winTitle, ahk_id %ssfID%
			StringSplit, T, winTitle, %A_Space%:
			; ToolTip, %A_Index%`nT10=%T10%,0,0
			If !oldT10	; get the current T10 as soon as it exists and store it
				oldT10:=T10
			If (T10 > oldT10)	; If T10 starts incrementing, we know SSF has a game loaded and can continue the script
				Break
		}
		WinActivate, ahk_id %ssfID%
		SetKeyDelay,,10
		Send, !{Enter}
		Sleep, 500
		Gui, 69: Destroy
		WinSet, Transparent, 255, ahk_id %ssfID%
		WinSet, Transparent, Off, ahk_id %ssfID%
	}
Return

RestoreEmu:
	WinActivate, ahk_id %ssfID%
	Sleep, 500
	SetKeyDelay,,100
	Send, !{Enter}
Return

CloseProcess:
	FadeOutStart()
	WinClose("SSF")
Return

tempgui(){
	Gui, 69:Color, 000000 
	Gui, 69:-Caption +ToolWindow 
	Gui, 69:Show, x0 y0 W%A_ScreenWidth% H%A_ScreenHeight%, BlackScreen
}
