MEmu = Pinball Arcade
MEmuV = v1.31.8
MURL = http://www.pinballarcade.com/
MAuthor = djvj
MVersion = 2.0.1
MCRC = DE46ABEC
iCRC = 7893F2F8
mId = 635589857631115764
MSystem = "Pinball Arcade","Pinball"
;----------------------------------------------------------------------------
; Notes:
; Initial setup:
; Manually run Pinball Arcade. If you own all the games and they can all be found in the My Tables folder, Simply Enter the My Tables folder and browse to the first table (alphabetically) and exit Pinball Arcade.
; The module comes default with all the available tables (as of 1/14/2014) alphabetically sorted in the module setting My_Tables.
; It will parse this setting and assume you own all the games. If you do not own all the games, recreate this setting in HLHQ with all the games you own, and separate each one with a |
; The My_Tables names match the names from your FE's database.
;
; If launching as a Steam game:
; When setting this up in HLHQ under the global emulators tab, make sure to select it as a Virtual Emulator. Also no rom extensions, executable, or rom paths need to be defined.
; Set Skip Checks to "Rom and Emu" when using this module as roms do not exist.
;
; If not launching through Steam:
; Add this as any other standard emulator and define the PinballArcade.exe as your executable, but still select Virtual Emulator as you do not need rom extensions or rom paths
; Set Skip Checks to "Rom and Emu" when using this module as roms do not exist.
;
; This module requires BlockInput.exe to exist in your Module Extensions folder. It is used to prevent users from messing up the table selection routine.
; If BlockInput is not actually blocking input, it's due to not having admin credentials, which you will need to set this exe to run as admin.
; However, this also means HyperLaunch needs to be set to run as admin as well, keep this in mind.
;
; If you want bezel support set to the game be played in windowed mode
;
; How to run vertical games on a standard monitor:
; There are 3 methods supported by this module to rotate your desktop. Windows shortcuts, display.exe and irotate.exe. If one method does not work on your computer, try another.
;
; If the key sends are not working, make sure your hyperlaunch is set to run as administrator.
;
; Pinball Arcade stores some settings in your registry @ HKEY_CURRENT_USER\Software\PinballArcade\PinballArcade
;----------------------------------------------------------------------------
StartModule()

settingsFile := modulePath . "\" . moduleName . ".ini"
rotateMethod := IniReadCheck(settingsFile, "settings", "Rotate_Method",,,1) ; Shortcut, Display, iRotate 
rotateDisplay := IniReadCheck(settingsFile, "settings", "Rotate_Display", 0,,1) ; 0, 90, 180, 270
moduleDebugging := IniReadCheck(settingsFile, "settings", "Module_Debugging", "false",,1)

If windowsRotate {
	Res := (A_ScreenWidth>A_ScreenWidth) ? A_ScreenWidth : A_ScreenWidth
	Gui 1: Color, 000000
	Gui 1: -Caption +ToolWindow
	Gui 1: Show, x0 y0 W%Res% H%Res%, BlackScreen	; experimental to hide entire desktop and windows
	If rotateMethod
		Rotate(rotateMethod, rotateDisplay)
}

BezelGUI()
FadeInStart()

pinballTitleClass := "Pinball Arcade ahk_class Pinball Arcade"
fullscreen := IniReadCheck(settingsFile, "settings", "Fullscreen", "true",,1) ; 0, Shortcut, Display, iRotate 
sleepLogo := IniReadCheck(settingsFile, "Settings", "Sleep_Until_Logo",7000,,1)
sleepBaseTime := IniReadCheck(settingsFile, "Settings", "Sleep_Base_Time",1,,1)
lastMyTable := "Attack from Mars (Bally)"	; Mytables always starts on Attack from Mars
; myTables := IniReadCheck(settingsFile, "Settings", "My_Tables","Attack From Mars|Big Shot|Black Hole|Black Knight|Bride of Pin-Bot|Cactus Canyon|Centaur|Central Park|Champion Pub|Cirqus Voltaire|Class of 1812|Creature from the Black Lagoon|Cue Ball Wizard|Dr. Dude|El Dorado - City of Gold|Elvira|Firepower|Fish Tales|Flight 2000|Funhouse|Genie|Goin' Nuts|Gorgar|Harley-Davidson|Haunted House|Medieval Madness|Monster Bash|No Good Gofers|Pin-Bot|Ripley's Believe It or Not|Scared Stiff|Space Shuttle|Star Trek|Tales of the Arabian Nights|Taxi|Tee'd Off|Terminator 2|Theatre of Magic|Twilight Zone|Victory|Whirlwind|White Water",,1) ; | separated list of the tables I own
myTables := IniReadCheck(settingsFile, "Settings", "My_Tables","Attack from Mars (Bally)|Big Shot (Gottlieb)|Black Hole (Gottlieb)|Black Knight 2000 (Williams)|Black Knight (Williams)|Black Rose (Bally)|Bram Stoker's Dracula (Williams)|Machine - Bride of Pin Bot, The (Williams)|Cactus Canyon (Bally)|Centaur (Bally)|Central Park (Gottlieb)|Champion Pub, The (Bally)|Cirqus Voltaire (Bally)|Class of 1812 (Gottlieb)|Creature from the Black Lagoon (Bally)|Cue Ball Wizard (Gottlieb)|Diner (Williams)|Dr. Dude & His Excellent Ray (Bally)|El Dorado - City Of Gold (Gottlieb)|Elvira and the Party Monsters (Bally)|Firepower (Williams)|Fish Tales (Williams)|Flight 2000 (Stern)|FunHouse (Williams)|Genie (Gottlieb)|Goin' Nuts (Gottlieb)|Gorgar (Williams)|Harley-Davidson, 3rd Edition (Stern)|Haunted House (Gottlieb)|High Roller Casino (Stern)|High Speed (Williams)|Junk Yard (Williams)|Lights... Camera... Action! (Gottlieb)|Medieval Madness (Williams)|Monster Bash (Williams)|No Good Gofers (Williams)|Phantom of the Opera, The (Stern)|Pin Bot (Williams)|Ripley's Believe It or Not! (Stern)|Scared Stiff (Bally)|Space Shuttle (Williams)|Star Trek - The Next Generation (Williams)|Tales of the Arabian Nights (Williams)|Taxi (Williams)|Tee'd Off (Gottlieb)|Terminator 2 - Judgment Day (Williams)|Theatre of Magic (Bally)|Twilight Zone (Bally)|Victory (Gottlieb)|Whirlwind (Williams)|White Water (Williams)|WHO Dunnit (Bally)",,1)	; | separated list of the tables user owns

BezelStart()

; get user's save path
paUserPath := RegRead("HKCU", "Software\PinballArcade\PinballArcade", "SavePath", "Auto")
pinballArcadeDat := CheckFile(paUserPath . "settings.dat")

; Update fullscreen setting
res := BinRead(pinballArcadeDat,pinballArcadeDatData,1,8)	; read current fullscreen setting
Bin2Hex(hexData,pinballArcadeDatData,res)
If (fullscreen = "true" && hexData != "02") {
	Hex2Bin(binData,"02")
	res := BinWrite(pinballArcadeDat,binData,1,8)
} Else If (fullscreen != "true" && hexData != "00") {
	Hex2Bin(binData,"00")
	res := BinWrite(pinballArcadeDat,binData,1,8)
}

; Convert myTables into a real array
myTablesArray := []
Loop, Parse, myTables, |
{
	myTablesArray[A_Index] := A_Loopfield
	If (romName = A_Loopfield) {
		thisTablePos := A_Index ; store the position (in the array) this table was found
		thisTableArray := "myTablesArray"       ; save the array this table was found in
		lastTable := lastMyTable        ; store the last table loaded for the same array as this table
		Log("Module -  Found """ . romName . """ at position " . thisTablePos . " in MyTables")
	}
}

CheckFile(moduleExtensionsPath . "\BlockInput.exe")

If !thisTableArray
	ScriptError("This table """ . romName . """ was not found in My Tables folder. Please check its name that it matches what the module recognizes.")
Log("Module - Table """ . romName . """ was found in array """ . thisTableArray . """ at position " . thisTablePos)
Log("Module - Last Table of array """ . thisTableArray . """ left off at """ . lastTable . """ which was found at position " . lastTablePos)

; Calculate the shortest distance to this table from the lastTable
max := %thisTableArray%.MaxIndex()
a := 1
b := thisTablePos
If (a > b) {
	moveDown := a - b
	moveUp := (max - a) + b
} Else If (b > a) {
	moveDown := b - a
	moveUp := (max - b) + a
} Else {	; a=b
	moveDown := 0
	moveUp := 0
}
moveDirection := If moveUp < moveDown ? "moveUp" : "moveDown"
Log("Module - The array """ . thisTableArray . """ has " . max . " tables in it and shortest distance to this table is " . %moveDirection% . " in direction " . moveDirection)

If executable {
	Log("Module - Running Pinball Arcade as a stand alone game and not through Steam as an executable was defined.")
	Run(executable, emuPath)
} Else {
	If !steamPath
		GetSteamPath()
	Log("Module - Running Pinball Arcade through Steam.")
	Steam(238260)
}

WinWait(pinballTitleClass)
WinWaitActive(pinballTitleClass)

BezelDraw()
Run("BlockInput.exe 30", moduleExtensionsPath)        ; start the tool that blocks all input so user cannot interrupt the launch process for 30 seconds
If moduleDebugging = true
	Tooltip, waiting %sleepLogo% seconds for logo
SetKeyDelay(80*sleepBaseTime)
Sleep % sleepLogo      ; sleep till Pinball FX2 logo appears

If moduleDebugging = true
	Tooltip, sending enter to get to the main menu
Send, {Enter Down}{Enter Up}100{Enter Down}{Enter Up}100{Enter Down}{Enter Up}        ; get to the Main menu

If moduleDebugging = true
	Tooltip, entering MyTable folder
Sleep % 2000*sleepBaseTime     ; wait for folder to load

If moduleDebugging = true
	Tooltip, navigating to %romName%
SetKeyDelay(80*sleepBaseTime)
If (moveDirection = "moveUp") {
	Loop % %moveDirection%
	{	If moduleDebugging = true
			Tooltip % "Index: " . A_Index . " | Game: " . %thisTableArray%[A_Index]
		Send, {Up Down}{Up Up}
		Sleep % 100*sleepBaseTime
	}
} Else {        ; moveDown
	Loop % %moveDirection%
	{	If moduleDebugging = true
			Tooltip % "Index: " . A_Index . " | Game: " . %thisTableArray%[A_Index]
		Send, {Down Down}{Down Up}
		Sleep % 100*sleepBaseTime
	}
}
Send, {Enter Down}{Enter Up}    ; select game
Sleep % 500*sleepBaseTime

If moduleDebugging = true
	Tooltip, waiting for game to load
Send, {Enter Down}{Enter Up}80{Enter Down}{Enter Up}      ; select game
Sleep % 4800*sleepBaseTime     ; waiting for table to load
Send, {Enter Down}{Enter Up}80{Enter Down}{Enter Up}      ; start game
If moduleDebugging = true
	Tooltip, Finished

Process("Close", "BlockInput.exe")    ; end script that blocks all input

FadeInExit()
Process("WaitClose", "PinballArcade.exe")
BezelExit()
FadeOutExit()

If windowsRotate {
	Gui 1: Show
	If rotateMethod
		Rotate(rotateMethod, 0)
	Sleep % 200*sleepBaseTime
	Gui 1: Destroy
}

ExitModule()


HaltEmu:
	disableSuspendEmu := true
	Send, {ESC down}{ESC up}
Return
RestoreEmu:
	Send, {ESC down}{ESC up}
Return

CloseProcess:
	FadeOutStart()
	WinClose(pinballTitleClass)
Return
