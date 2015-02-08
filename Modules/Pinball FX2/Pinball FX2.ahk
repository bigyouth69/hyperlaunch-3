MEmu = Pinball FX2
MEmuV = N/A
MURL = http://www.pinballfx.com/
MAuthor = djvj & bleasby
MVersion = 2.0.4
MCRC = 48091017
iCRC = B2656270
mId = 635244873683327779
MSystem = "Pinball FX2","Pinball"
;----------------------------------------------------------------------------
; Notes:
; If launching as a Steam game:
; When setting this up in HLHQ under the global emulators tab, make sure to select it as a Virtual Emulator. Also no rom extensions, executable, or rom paths need to be defined. 
; Set Skip Checks to "Rom and Emu" when using this module as roms do not exist.
;
; If not launching through Steam:
; Add this as any other standard emulator and define the PInball FX2.exe as your executable, but still select Virtual Emulator as you do not need rom extensions or rom paths
; Set Skip Checks to "Rom and Emu" when using this module as roms do not exist.
;
;This module requires BlockInput.exe to exist in your Module Extensions folder. It is used to prevent users from messing up the table selection routine.
;
;Windowed mode:
; - To hide the game selection behind fade the game needs to be run in Windowed mode. The original game does not support windowed mode, therefore it is necessary to use the dxwnd for forcing this mode. Use this option at your own risk, as this could be eventually considered as an injected code and may end up in a banned licence (I did not had any problem in this subject until now). 
; - Windowed mode requires to set the dxwnd to run as admin. Go to the folder HyperLaunch\Module Extensions\dxwnd\dxwnd.exe and righht click the executable to set it to run as admin.
; - If dxwnd is not closing, that is because dxwnd cannot be closed by a script not also running as admin. So make sure HyperLaunch.exe is set to run as admin also by right clicking it and going to Properties -> Compatibility -> Run as Administrator should be checked.
; - It is also required to set on the modules options the WindowedResolution to match your Pinball FX2 game resolution. If you don't do it, the game will crash as dxwnd will not be able to set the windowed mode.
;
; Optional Fade recomended settings:
; - On Windowed mode you can use these settings: Progress Bar - Enable = true, Progress Bar - Non 7z Progress Bar Time = 21500 (adjust this to the average time that it takes for getting to the table on your computer, mine was 21,5 secds), Fade In - Exit Delay = 3500 (time that the Pinball FX2 takes for loading the selected table. HL will know when Pinball FX2 reaches this screen but if you want to hide it also, you will need to set this option). This will give the user a approximate measure of how much time it takes for the table be ready to be played and the fade screen will only disapears after the Pinball FX2 table is ready to be played.
;
; Bezel:
; Bezel uses the fixResMode and requires the use of windowed mode, therefore you need to set the resolution on the module options to the same resolution that you set in Pinball FX2.
; By default, the module will use the resolution of your desktop. Your bezel is most likely smaller, so make sure to set the correct windowed resolution in HLHQ for this module.
;
; DMD (Dot Matrix Display)
; The module will support and hide the window components of detached DMD
; To see it, you must have a 2nd monitor connected as an extension of your desktop, and placement will be on that monitor
; To Detach:
; Run Pinball FX2 manually, and goto Help & Options -> Settings -> Video
; Set Dot Matrix Size to Off, and close Pinball FX2
; The module will automatically create the dotmatrix.cfg file in the same folder of the "Pinball FX2.exe" (your installation folder) for you
; Edit the module's settings in RLUI to customize the DMD size and placement of this window
;----------------------------------------------------------------------------
StartModule()
BezelGUI()

settingsFile := modulePath . "\" . moduleName . ".ini"
multiplayerMenu := IniReadCheck(settingsFile, "Settings", "Multiplayer_Menu","true",,1)
If (multiplayerMenu = "true")
	SelectedNumberofPlayers := NumberOfPlayersSelectionMenu(4)

FadeInStart()

pinballTitleClass := "Pinball FX2 ahk_class PxWindowClass"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
WindowedResolution := IniReadCheck(settingsFile, "Settings", "Windowed_Resolution",A_ScreenWidth . "x" . A_ScreenHeight,,1)
initialTableX := IniReadCheck(settingsFile, "Settings", "Initial_Table_X",1,,1)
initialTableY := IniReadCheck(settingsFile, "Settings", "Initial_Table_Y",1,,1)
sleepLogo := IniReadCheck(settingsFile, "Settings", "Sleep_Until_Logo",12000,,1)
sleepMenu := IniReadCheck(settingsFile, "Settings", "Sleep_Until_Main_Menu",1500,,1)
sleepBaseTime := IniReadCheck(settingsFile, "Settings", "Sleep_Base_Time",1,,1)
externalDMD := IniReadCheck(settingsFile, "Settings", "External_DMD","false",,1)
dmdX := IniReadCheck(settingsFile, "Settings", "DMD_X",A_ScreenWidth,,1)
dmdY := IniReadCheck(settingsFile, "Settings", "DMD_Y",0,,1)
dmdW := IniReadCheck(settingsFile, "Settings", "DMD_Width",0,,1)
dmdH := IniReadCheck(settingsFile, "Settings", "DMD_Height",0,,1)
tableNavX := IniReadCheck(settingsFile, romName, "x",,,1)
tableNavY := IniReadCheck(settingsFile, romName, "y",,,1)
tableNavX2 := IniReadCheck(settingsFile, romName, "x2",,,1)
tableNavY2 := IniReadCheck(settingsFile, romName, "y2",,,1)

BezelStart("fixResMode")

CheckFile(moduleExtensionsPath . "\BlockInput.exe")

If (tableNavX = "" || tableNavY = "")
	ScriptError("This game is not configured in the module ini. Please set the grid coordinates in HyperLaunchHQ so HyperLaunch can launch the game for you")

DXWndGame :=
If (!Fullscreen || Fullscreen = "false"){
	StringSplit, WindowedResolution, WindowedResolution, x
	DxwndIniRW("target", "sizx", WindowedResolution1,, "Pinball FX2")
	DxwndIniRW("target", "sizy", WindowedResolution2,, "Pinball FX2")
	If executable
		DxwndIniRW("target", "path", emuPath . "\" . executable,, "Pinball FX2")
	If !executable {
		If !steamPath
			GetSteamPath()
		DxwndIniRW("target", "path", steamPath . "\SteamApps\common\Pinball FX2\Pinball FX2.exe",, "Pinball FX2")
	}
	DxwndRun()
	DXWndGame := 1
}

If (externalDMD = "true") {
	Log("Module - Updating external DMD window placement values",4)
	If !executable
		If !steamPath
			GetSteamPath()
	dotmatrixCFGFile := If executable ? emuPath . "\dotmatrix.cfg" : steamPath . "\SteamApps\common\Pinball FX2\dotmatrix.cfg"
	IfNotExist, %dotmatrixCFGFile%
		FileAppend, %dotmatrixCFGFile%	; create a new blank file if one does not exist
	Log("Module - Using this dotmatrix.cfg: " . dotmatrixCFGFile,4)
	dotmatrixCFG := LoadProperties(dotmatrixCFGFile)
	WriteProperty(dotmatrixCFG, "x", dmdX, 1)
	WriteProperty(dotmatrixCFG, "y", dmdY, 1)
	WriteProperty(dotmatrixCFG, "width", dmdW, 1)
	WriteProperty(dotmatrixCFG, "height", dmdH, 1)
	SaveProperties(dotmatrixCFGFile, dotmatrixCFG)	
}

If executable {
	Log("Module - Running Pinball FX2 as a stand alone game and not through Steam as an executable was defined.")
	Run(executable, emuPath)
} Else {
	Log("Module - Running Pinball FX2 through Steam.")
	Steam(226980)
}

WinWait(pinballTitleClass)
WinWaitActive(pinballTitleClass)

; Attempt to hide window components of the detached DMD
If (externalDMD = "true") {
	Gui +LastFound
	hWnd := WinExist()
	DllCall("RegisterShellHookWindow", UInt,hWnd)
	MsgNum := DllCall("RegisterWindowMessage", Str,"SHELLHOOK")
	OnMessage(MsgNum, "ShellMessage")
}

Run("BlockInput.exe 30", moduleExtensionsPath)	; start the tool that blocks all input so user cannot interrupt the launch process for 30 seconds
SetKeyDelay(50*sleepBaseTime)	; required otherwise pinball fx2 does not respond to the keys
Sleep, %sleepLogo%	; sleep till Pinball FX2 logo appears
ControlSend,, {Esc Down}{Esc Up}, %pinballTitleClass%	
Sleep, % 200*sleepBaseTime
ControlSend,, {Enter Down}{Enter Up}, %pinballTitleClass%	; cancel pinball fx2 logo
Sleep, %sleepMenu%	; sleep till table select window appears

tableNavX := tableNavX - initialTableX
tableNavY := tableNavY - initialTableY
If (tableNavX<0){
	Loop % -tableNavX
	{	ControlSend,, {Left Down}{Left Up}, %pinballTitleClass%
		Sleep, % 50*sleepBaseTime
	}
} Else {
	Loop % tableNavX
	{	ControlSend,, {Right Down}{Right Up}, %pinballTitleClass%
		Sleep, % 50*sleepBaseTime
	}
}
If (tableNavY<0){
	Loop % -tableNavY
	{	ControlSend,, {Up Down}{Up Up}, %pinballTitleClass%
		Sleep, % 50*sleepBaseTime
	}
} Else {
	Loop % tableNavY
	{	ControlSend,, {Down Down}{Down Up}, %pinballTitleClass%
		Sleep, % 50*sleepBaseTime
	}
}
	
If (tableNavX2) and (tableNavY2)
{	IniRead,currentFootballTable, %settingsFile%, Settings, Current_Football_Table
	If !(currentFootballTable=romName){
		ControlSend,, {Enter Down}{Enter Up}, %pinballTitleClass%	; select game
		Sleep, % 500*sleepBaseTime
		ControlSend,, {Up Down}{Up Up}, %pinballTitleClass%	; Move up
		Sleep, % 50*sleepBaseTime
		ControlSend,, {Enter Down}{Enter Up}, %pinballTitleClass%	; select team
		iniRead,initialX,%settingsFile%,%currentFootballTable%,X2, 1
		iniRead,initialY,%settingsFile%,%currentFootballTable%,Y2, 1
		NavX2 := tableNavX2 - initialX
		NavY2 := tableNavY2 - initialY
		Sleep, % 500*sleepBaseTime
		If (NavX2<0){
			Loop % -NavX2
			{	ControlSend,, {Left Down}{Left Up}, %pinballTitleClass%
				Sleep, % 50*sleepBaseTime
			}
		} Else {
			Loop % NavX2
			{	ControlSend,, {Right Down}{Right Up}, %pinballTitleClass%
				Sleep, % 50*sleepBaseTime
			}
		}
		If (NavY2<0){
			Loop % -NavY2
			{	ControlSend,, {Up Down}{Up Up}, %pinballTitleClass%
				Sleep, % 50*sleepBaseTime
			}
		} Else {
			Loop % NavY2
			{	ControlSend,, {Down Down}{Down Up}, %pinballTitleClass%
				Sleep, % 50*sleepBaseTime
			}
		}
		IniWrite, %romName%, %settingsFile%, Settings, Current_Football_Table
	}
}

ControlSend,, {Enter Down}{Enter Up}, %pinballTitleClass%	; select team or game
Sleep, % 750*sleepBaseTime

If (tableNavX2 && tableNavY2)
	If !(currentFootballTable = romName)
		ControlSend,, {Down Down}{Down Up}, %pinballTitleClass%	; down to play single game

If (SelectedNumberofPlayers > 1)  ; select number of players
{	Sleep, % 50*sleepBaseTime
	ControlSend,, {Down Down}{Down Up}, %pinballTitleClass%		; down to hot seat
	ControlSend,, {Enter Down}{Enter Up}, %pinballTitleClass%	; select hot seat
	Sleep, % 500*sleepBaseTime
	Loop % SelectedNumberofPlayers-2
	{	ControlSend,, {Down Down}{Down Up}, %pinballTitleClass%   ;select number of players
		Sleep, % 50*sleepBaseTime
	}
}

ControlSend,, {Enter Down}{Enter Up}, %pinballTitleClass%	; start game

Process("Close", "BlockInput.exe")	; end script that blocks all input

BezelDraw()
FadeInExit()

Process("WaitClose", "Pinball FX2.exe")
BezelExit()
FadeOutExit()
ExitModule()
    

ShellMessage(wParam, lParam) {
	Log("Module - DMD external window - " . wParam,4)
	If (wParam = 1)
		IfWinExist Pinball FX2 DotMatrix ahk_class PxWindowClass
		{
			WinSet, Style, -0xC00000 ; hide title bar
			WinSet, Style, -0x800000 ; hide thin-line border
			WinSet, Style, -0x400000 ; hide dialog frame
			WinSet, Style, -0x40000 ; hide thickframe/sizebox
			;WinMove, , , 0, 0, 1920, 1080
		} 
}

CloseProcess:
	FadeOutStart()
	WinClose(pinballTitleClass)
	If DXWndGame
		DxwndClose()
Return
