MEmu = Dolphin
MEmuV =  v3.0 r766
MURL = http://www.dolphin-emulator.com/
MAuthor = djvj
MVersion = 2.0.2
MCRC = 11D8FD1E
iCRC = 8197DF4
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
;
; Bezels:
; If the game does not fit the window, you can try setting stretch to window manually in dolphin.
;
; Setting up custom Wiimote profiles:
; First set UseCustomProfiles to true below
; Download the example Settings.ini from my user dir on the ftp @ /Upload Here/djvj/Nintendo Wii/ and put it in the folder with this module
; Launch dolphin and goto Options->Wiimote Settings and configure all your Wiimotes how you want your default setup to look like, this will be used for all games that you don't set a custom profile for. Save that profile, calling it Default.
; Now create custom profiles for all the games you need non-default button layouts for, and name the profiles whatever you want.
; Open the example Settings.ini and add each game from your xml like you see from my examples and set its profile to match the one you want that game to load.
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
UseCustomProfiles := IniReadCheck(settingsFile, "Settings", "UseCustomProfiles","false",,1)	; set to true if you want to setup custom Wiimote profiles for games
HideMouse := IniReadCheck(settingsFile, "Settings", "HideMouse","true",,1)					; hides mouse cursor in the emu options
PairKey := IniReadCheck(settingsFile, "Settings", "PairKey","",,1)							; hotkey to "Pair Up" Wiimotes, delete the key to disable it
RefreshKey := IniReadCheck(settingsFile, "Settings", "RefreshKey","",,1)						; hotkey to "Refresh" Wiimotes, delete the key to disable it
Timeout := IniReadCheck(settingsFile, "Settings", "Timeout","5",,1)							; amount in seconds we should wait for the above hotkeys to timeout

BezelStart()

dolphinINI := CheckFile(emuPath . "\User\Config\Dolphin.ini")

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

 ; Load default or user specified wiimote profile for launching
If UseCustomProfiles = true
{	profile := IniReadCheck(settingsFile, romName, "profile","default",,1)
	currentProfile = %emupath%\User\Config\WiimoteNew.ini
	newProfile =  %emupath%\User\Config\Profiles\Wiimote\%profile%.ini
	defaultProfile = %emupath%\User\Config\Profiles\Wiimote\Default.ini
	IfNotExist, %newProfile%
		ScriptError(romName . " is set to load a custom Wiimote profile`, but it could not be found.`nPlease fix the profile's name or create a profile called " . profile)
	FileRead, cProfile, %currentProfile%
	FileRead, nProfile, %newProfile%
	If ( cProfile != nProfile ) {
		If profile != default	; loading custom profile
			FileCopy, %newProfile%, %currentProfile%, 1
		Else	; loading default profile
			FileCopy, %defaultProfile%, %currentProfile%, 1
	}
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
