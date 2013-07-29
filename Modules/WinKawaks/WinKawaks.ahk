MEmu = WinKawaks
MEmuV = v1.62
MURL = http://www.kawaks.net/
MAuthor = djvj
MVersion = 2.0
MCRC = 1E128178
iCRC = 84C72842
MID = 635038268935109871
MSystem = "SNK Neo Geo","SNK Neo Geo AES","SNK Neo Geo MVS"
;----------------------------------------------------------------------------
; SNK Neo Geo, CPS1, CPS2

; Notes:
; If you want to use fading, turn off hide_desktop in your Hyperspin\Settings\Settings.ini
; Set your roms dir in the emu by going to File->Configure paths. If all your roms are in one dir, you only need to set one of them. If they are in seperate dirs, makes sure they are all defined here.
; All your roms should be zipped. Bios zips should be placed in the same dir as the games they are for. (ex.  neogeo.zip should be with the neogeo roms)
; Load a game and set your controls at Game->Redefine keys->Player1 and 2. Then click Game->save key settings as default. Now they will be mapped for every game.
; Set your Region to USA by going to Game->NeoGeo settings->USA. If you don't want to use coins, select Game->NeoGeo settings->Console
; Set Sound->Sound frequency->44 KHz (or 48 KHz)

; The larger games take a long time to load, be patient.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
Freeplay := IniReadCheck(settingsFile, "Settings", "Freeplay","0",,1)						; 0=off, 1=on
Country := IniReadCheck(settingsFile, "Settings", "Country","1",,1)						; 0 = Japan,  1 = USA,  2 = Europe
Hardware := IniReadCheck(settingsFile, "Settings", "Hardware","1",,1)						; 0 = Console, 1 = Arcade
Hotkeys := IniReadCheck(settingsFile, "Settings", "Hotkeys","1",,1)						; Set to 0 to disable menu shortcuts (handy for Hotrod players)

7z(romPath, romName, romExtension, 7zExtractPath)

wkINI := CheckFile(emuPath . "\WinKawaks.ini")

; Now let's update all our keys if they differ in the ini
iniLookup =
( ltrim c
   NeoGeo, NeoGeoFreeplay, %Freeplay%
   NeoGeo, NeoGeoCountry, %Country%
   NeoGeo, NeoGeoSystem, %Hardware%
   Misc, EnableHotKeys, %Hotkeys%
)
Loop, Parse, iniLookup, `n
{	StringSplit, split, A_LoopField, `,, %A_Space%%A_Tab%
	IniRead, tempVar, %wkINI%, %split1%, %split2%
	If ( tempVar != split3 )
		IniWrite, % split3, %wkINI%, %split1%, %split2%
}

Fullscreen := If Fullscreen = "true" ? ("-fullscreen") : ("")

Run(executable . " " . romName . " " . Fullscreen, emuPath)

WinWait("Kawaks")
WinWaitActive("Kawaks")

Loop { ; looping until WinKawaks is done loading game
	Sleep, 200
	WinGetTitle, winTitle, Kawaks 1.62 ahk_class Afx:400000:0 ; excluding the title of the GUI window so we can read the title of the game window instead
	StringSplit, T, winTitle, %A_Space%
	If ( T4 != "Initializing" && T4 != "Lost" && T4 != "" ) {
		Sleep, 500 ; need a bit longer so we don't see the winkawaks window
		Break
	}
}

; Sometimes the border and titlebar appear and flash rapidly, this gets rid of them
If Fullscreen {
	WinSet, Style, -0xC00000, Kawaks 1.62 ahk_class Afx:400000:0 ; Removes the TitleBar
	WinSet, Style, -0x40000, Kawaks 1.62 ahk_class Afx:400000:0 ; Removes the border of the game window
}

FadeInExit()
Process("WaitClose",executable)
7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	Send, {ENTER} ; pause emu
	Sleep, 1000 ; increase this if winkawaks is not closing and only going into windowed mode
	WinClose("Kawaks 1.62 ahk_class Afx:400000:0")
	Sleep, 500
	IfWinExist, Kawaks 1.62 ahk_class Afx:400000:0
	{	WinActivate ; use the window found above
		Send, {Alt}FX
	}	
	; alternate closing method
	; errorLvl := Process("Exist", executable)
	; If errorLvl
		; Process("Close", executable)	; sometimes the process doesn't close when using the GUI, this makes sure it closes (eeprom still saves with previous line)
Return
