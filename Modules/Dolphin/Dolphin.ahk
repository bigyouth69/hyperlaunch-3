MEmu = Dolphin
MEmuV =  v4.0
MURL = http://www.dolphin-emulator.com/
MAuthor = djvj
MVersion = 2.0.4
MCRC = 68C4777D
iCRC = 33A87511
MID = 635038268884477733
MSystem = "Nintendo Gamecube","Nintendo Wii"
;----------------------------------------------------------------------------
; Notes:
; Be sure you are running at least Dolphin v3.0-589 or greater.
; To set fullscreen, set the variabe below
; If you get an error that you are missing a vcomp100.dll, install Visual C++ 2010: http://www.microsoft.com/download/en/details.aspx?id=14632
; Also make sure you are running latest directx: http://www.microsoft.com/downloads/details.aspx?FamilyID=2da43d38-db71-4c1b-bc6a-9b6652cd92a3
; Dolphin will sometimes crash when connnecting a Wiimote, then going back to the game. After all Wiimotes are connected that you want to use, it shouldn't have anymore issues.
; Convert all your games to ciso using Wii Backup Manager to save alot of space by stripping everything but the game partition. http://www.wiibackupmanager.tk/
; Render to Main Window needs to be unchecked, otherwise hotkeys to pair wiimotes will not work in fullscreen. This is done for you if you forget.
; If you want to keep your Dolphin.ini in the emu folder, create a "portable.txt" file in MyDocuments\Dolphin Emulator\
;
; Bezels:
; If the game does not fit the window, you can try setting stretch to window manually in dolphin.
;
; Setting up custom Wiimote or GCPad profiles:
; First set UseCustomWiimoteProfiles or UseCustomGCpadProfiles to true in HLHQ for this module
; Launch Dolphin manually and goto Options->(Wiimote or Gamecube Pad) Settings and configure all your controls how you want your default setup to look like. This will be used for all games that you don't set a custom profile for. No need to save any profiles.
; All your controls are stored in WiimoteNew.ini or GCPadNew.ini and get copied to a _Default_(WiimoteNew or GCPadNew).ini on first launch. This ini contains all the controls for all 4 controllers.
; Do not confuse this with Dolphin's built-in profiles as those only contain info for only one controller. The (WiimoteNew or GCPadNew).ini and all the profiles HL uses contain info for all controllers in one file.
; This new profile now called _Default_(WiimoteNew or GCPadNew).ini will be found in Dolphins settings folder: \Config\Profiles\(Wiimote or GCPad) (HL)\Default.ini
; For each game or custom control sets you want to use, edit the controls for all the controllers to work for that game and exit Dolphin. Now copy the (WiimoteNew or GCPadNew).ini to the "(Wiimote or GCPad) (HL)" folder and name it whatever you like.
; In HLHQ's module settings for Dolphin, Click the Rom Settings tab and add each game from your xml you want to use a this custom profile for.
; Now for all those games you added, make sure the Profile setting it set to the custom profile you want to load when that game is launched.
; Any game not added will use the "_Default_(WiimoteNew or GCPadNew).ini" profile HL makes on first launch.
;
; To Pair a Wiimote:
; Press 1 + 2 on the wiimote
; Immediately press your PairKey to start pairing and wait for the countdown to finish
; When the countdown reaches 0, your wiimote should have linked to show what player it is
; If it did not link, press your RefreshKey before the wiimote stops flashing
;----------------------------------------------------------------------------
StartModule()
BezelGui()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
UseCustomWiimoteProfiles := IniReadCheck(settingsFile, "Settings", "UseCustomWiimoteProfiles","false",,1)	; set to true if you want to setup custom Wiimote profiles for games
UseCustomGCPadProfiles := IniReadCheck(settingsFile, "Settings", "UseCustomGCPadProfiles","false",,1)	; set to true if you want to setup custom GCPad profiles for games
HideMouse := IniReadCheck(settingsFile, "Settings", "HideMouse","true",,1)					; hides mouse cursor in the emu options
PairKey := IniReadCheck(settingsFile, "Settings", "PairKey","",,1)							; hotkey to "Pair Up" Wiimotes, delete the key to disable it
RefreshKey := IniReadCheck(settingsFile, "Settings", "RefreshKey","",,1)						; hotkey to "Refresh" Wiimotes, delete the key to disable it
Timeout := IniReadCheck(settingsFile, "Settings", "Timeout","5",,1)							; amount in seconds we should wait for the above hotkeys to timeout

BezelStart()

; Determine where Dolphin is storing its ini, this will act as the base folder for settings and profiles related to this emu
dolphinININewPath := A_MyDocuments . "\Dolphin Emulator\Config\Dolphin.ini"	; location of Dolphin.ini for v4.0+
dolphinINIOldPath := emuPath . "\User\Config\Dolphin.ini"	; location of Dolphin.ini prior to v4.0
IfExist % dolphinININewPath
{	dolphinBasePath := A_MyDocuments . "\Dolphin Emulator"
	Log("Module - Dolphin's base settings folder is not portable and found in: " . dolphinBasePath)
} Else IfExist % dolphinINIOldPath
{	dolphinBasePath := emuPath . "\User"
	Log("Module - Dolphin's base settings folder is portable and found in: " . dolphinBasePath)
} Else
	ScriptError("Could not find your Dolphin.ini in either of these folders. Please run Dolphin manually first to create it.`n" . dolphinINIOldPath . "`n" . dolphinININewPath)
dolphinINI := dolphinBasePath . "Config\Dolphin.ini"

7z(romPath, romName, romExtension, 7zExtractPath)

If romExtension in .zip,.7z,.rar
	ScriptError(MEmu . " does not support compressed roms. Please enable 7z support in HLHQ to use this module/emu.")

If PairKey {
	PairKey := xHotKeyVarEdit(PairKey,"PairKey","~","Add")
	xHotKeywrapper(PairKey,"PairWiimote")
}
If RefreshKey {
	RefreshKey := xHotKeyVarEdit(RefreshKey,"RefreshKey","~","Add")
	xHotKeywrapper(RefreshKey,"RefreshWiimote")
}

Fullscreen := (If ( Fullscreen = "true" ) ? ("True") : ("False"))
HideMouse := (If ( HideMouse = "true" ) ? ("True") : ("False"))

iniLookup =
( ltrim c
	Display, Fullscreen, %Fullscreen%
	Display, RenderToMain, False
	Interface, HideCursor, %HideMouse%
)
Loop, Parse, iniLookup, `n
{
	StringSplit, split, A_LoopField, `,, %A_Space%%A_Tab%
	IniRead, tempVar, %dolphinINI%, %split1%, %split2%
	If ( tempVar != split3 )
		IniWrite, % split3, %dolphinINI%, %split1%, %split2%
}

 ; Load default or user specified Wiimote or GCPad profiles for launching
If ((InStr(systemName, "wii") && UseCustomWiimoteProfiles = "true") || (InStr(systemName, "cube") && UseCustomGCPadProfiles = "true"))
{	profileType := If InStr(systemName, "wii") ? "WiimoteNew" : "GCPadNew"
	profileTypeFolder := If InStr(systemName, "wii") ? "Wiimote" : "GCPad"
	profile := IniReadCheck(settingsFile, romName, "profile", "Default",,1)
	HLProfilePath := dolphinBasePath . "\Config\Profiles\" . profileTypeFolder . " (HL)"
	currentProfile := dolphinBasePath . "\Config\" . profileType . ".ini"
	defaultProfile := HLProfilePath . "\_Default_" . profileType . ".ini"
	customProfile := HLProfilePath . "\" . profile . ".ini"
	If !FileExist(currentProfile)
		ScriptError("You have custom " . profileTypeFolder . " profiles enabled, but could not locate " . currentProfile . ". This file stores all your current controls in Dolphin. Please setup your controls in Dolphin first.")
	If !FileExist(defaultProfile) {
		Log("Module - Creating initial Default " . profileTypeFolder . " profile by copying " . profileType . ".ini to " . defaultProfile, 2)
		FileCreateDir % HLProfilePath
		FileCopy, %currentProfile%, %defaultProfile%	; create the initial default profile on first launch
	}
	If (profile != "Default" && !FileExist(customProfile))
		ScriptError(romName . " is set to load a custom " . profileTypeFolder . " profile`, but it could not be found: " . customProfile)
	FileRead, cProfile, %currentProfile%	; read current profile into memory
	FileRead, nProfile, %customProfile%	; read custom profile into memory
	If ( cProfile != nProfile ) {	; if both profiles do not match exactly
		Log("Module - Current " . profileTypeFolder . " profile does not match the one this game should use.")
		If (profile != "Default") {	; if user set to use a custom profile
			Log("Module - Copying this defined " . profileTypeFolder . " profile to replace the current one: " . customProfile)
			FileCopy, %customProfile%, %currentProfile%, 1
		} Else {	; load default profile
			Log("Module - Copying the default " . profileTypeFolder . " profile to replace the current one: " . defaultProfile)
			FileCopy, %defaultProfile%, %currentProfile%, 1
		}
	} Else
		Log("Module - Current " . profileTypeFolder . " profile is already the correct one for this game, not touching it.")
}

Run(executable . " /b /e """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("Dolphin ahk_class wxWindowNR")
WinWaitActive("Dolphin ahk_class wxWindowNR")
BezelDraw()

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


ConnectWiimote(key) {
	Global Timeout
	Timeout := (10*Timeout) ; adjusting timeout to match loop sleep timer
	IfWinNotExist, Dolphin Wiimote Configuration ahk_class #32770
	{
		DetectHiddenWindows, OFF ; this needs to be off otherwise WinMenuSelectItem doesn't work for some odd reason
		WinActivate, Dolphin ahk_class wxWindowNR,,,FPS
		WinMenuSelectItem, ahk_class wxWindowNR,, Options, Wiimote Settings,,,,,,FPS
		WinWait("Dolphin Wiimote Configuration ahk_class #32770")
		WinWaitActive("Dolphin Wiimote Configuration ahk_class #32770")
	}
	;WinActivate, Dolphin Wiimote Configuration ahk_class #32770 ; test if window needs to be active
	ControlClick, %key%, Dolphin Wiimote Configuration ahk_class #32770
	SetFormat, float, 0
	Loop {
		timeLeft := (50-A_Index)/10
		ToolTip, Waiting for at least one Wiimote to be connected...`nTiming out in %timeLeft%, 20, 20
		ControlGetText, connMotes, Static5, Dolphin Wiimote Configuration ahk_class #32770
		StringLeft, numOfMotes, connMotes, 1
		If ( numOfMotes > 0 ) or ( A_Index >= Timeout )
			Break ; exit loop if a wiimote is detected or set Timeout elapsed
		IfWinNotExist, Dolphin Wiimote Configuration ahk_class #32770
			Break ; exit loop if user closed the window manually
		Sleep, 100
	}
	ToolTip
	If ( key = "Pair Up" )
		ControlClick, Refresh, Dolphin Wiimote Configuration ahk_class #32770 ; clicking refresh once after pairing so the wiimotes get link
	ControlClick, OK, Dolphin Wiimote Configuration ahk_class #32770
	; WinActivate, FPS ahk_class wxWindowClassNR ; for older dolphins
	WinActivate, FPS ahk_class wxWindowNR
}

PairWiimote:
	ConnectWiimote("Pair Up")
Return

RefreshWiimote:
	ConnectWiimote("Refresh")
Return

CloseProcess:
	FadeOutStart()
	WinClose("FPS ahk_class wxWindowNR") ; this needs to close the window the game is running in otherwise dolphin crashes on exit
Return
