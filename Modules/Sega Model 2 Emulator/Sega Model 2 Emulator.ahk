MEmu = Sega Model 2 Emulator
MEmuV = v1.0
MURL = http://nebula.emulatronia.com/
MAuthor = djvj & ghutch92
MVersion = 2.0.4
MCRC = A49D7940
iCRC = AD80243A
mId = 635175648125374429
MSystem = "Sega Model 2"
;----------------------------------------------------------------------------
; Notes:
; Oustide of Hyperspin, open the Sega Model 2 Emulator. 
; Under Video enable "auto switch to fullscreen".
; model2.zip must exist in your rom path which contains the needed bios files for the system.
; Module settings overwrite what you have set in the emulator itself.
;
; For Multiplayer Support:
; To enable the linked games support, set Link_Enabled to true in the module settings in HLHQ
; The module has an internal list of games that it will only enable it for. Not all of the games work in this emu. See below for more info.
;
; 1.) Multiplayer does not work when the emulator is launched using the same executable in the same path.
; 2.) Multiplayer only works if player 1 is set to be in master mode and players 2-4 are set to be in slave mode. (this info is stored in the emupath\NVDATA folder, press F2 to set in game)
; 3.) Singleplayer only works if player 1 is set to be in single mode. (this info is stored in the emupath\NVDATA folder, press F2 to set in game)
; 4.) Only the active window accepts keyboard input.
;
; Fixed Issue 1 by having folders in the emupath named Player 2, Player 3, and Player 4  and within each of these folsers there are separate installs of sega model 2 emulator.
; Fixed Issue 2 and 3 for Player 1 by having a folder named "Multi" in the NVDATA folder for multiplayer dat files and a folder name "Single" in the NVDATA folder for single player dat files.
; Fixed Issue 4 by activating the first player window so first player always has the keyboard and players 2-4 have to use a joystick(gamepad).
;
;Games that have a working link: 
; daytona,daytonagtx,daytonam,daytonas,daytonat,indy500,indy500d,manxtt,motoraid,skisuprg,srallyc,srallycb,srallyp,stcc,stcce,von,vonj,waverunr
;
;overrev and sgt24h both look like they can support link but I couldn't get it working, because I think m2emulator uses a linking hack to get these games to work in stand alone mode.
;Still need to see if waverunr, stcc, stcce, von, and vonj can link, I couldn't get these working, I think my processor is the issue here. Saw video of stcc & waverunr link working though.
;von and vonj can only do a 2 player link
;----------------------------------------------------------------------------
StartModule()
BezelGUI()

settingsFile := modulePath . "\" . moduleName . ".ini"
linkEnabled := IniReadCheck(settingsFile, "Settings|" . romName, "Link_Enabled", "false",,1)
SplitScreen2PlayersMode := IniReadCheck(settingsFile, "Settings", "SplitScreen_2_Players","Vertical",,1) ;horizontal or vertical
SplitScreen3PlayersMode := IniReadCheck(settingsFile, "Settings", "SplitScreen_3_Players","P1top",,1) ; For Player1 screen to be on left: P1left. For Player1 screen to be on top: P1top. For Player1 screen to be on bottom: P1bottom. For Player1 screen to be on right: P1right.

linkGames := "daytona","daytonagtx","daytonam","daytonas","daytonat","indy500","indy500d","manxtt","motoraid","skisuprg","srallyc","srallycb","srallyp","stcc","stcce","von","vonj","waverunr"
If (linkEnabled = "true" && InStr(linkGames, romName))
	linkEnabledGame := 1

If linkEnabledGame
	If (romName = "von") or (romName = "vonj")
		StartPlayersSelectionMenu(2)
	Else
		StartPlayersSelectionMenu(4)

FadeInStart()

fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
fullScreenWidth := IniReadCheck(settingsFile, "Settings", "FullScreenWidth",A_ScreenWidth,,1)
fullScreenHeight := IniReadCheck(settingsFile, "Settings", "FullScreenHeight",A_ScreenHeight,,1)
emupath2 := IniReadCheck(settingsFile, "Settings", "Player2_EmulatorPath",emupath . "\Player 2",,1) ;must be a unique path to same version of the emulator
emupath3 := IniReadCheck(settingsFile, "Settings", "Player3_EmulatorPath",emupath . "\Player 3",,1) ;must be a unique path to same version of the emulator
emupath4 := IniReadCheck(settingsFile, "Settings", "Player4_EmulatorPath",emupath . "\Player 4",,1) ;must be a unique path to same version of the emulator

CheckFile(romPath . "\model2.zip","Could not locate ""model2.zip"" which contains the bios files for this emulator. Please make sure it exists in the same folder as your roms.")

m2Ini := CheckFile(emuPath . "\EMULATOR.INI")
romDir1 := IniReadCheck(m2Ini, "RomDirs", "Dir1",,,1)
If (romDir1 != romPath)
	IniWrite, %romPath%, %m2Ini%, RomDirs, Dir1	; write the correct romPath to the emu's ini so the user does not need to define this

If SelectedNumberofPlayers > 1
	BezelStart(SelectedNumberofPlayers)	
Else
	BezelStart()

7z(romPath, romName, romExtension, 7zExtractPath)

; Write settings to m2's ini file - this needs to change also
IniWrite, % (If fullscreen = "true" ? 1 : 0), %m2Ini%, Renderer, AutoFull
IniWrite, %fullScreenWidth%, %m2Ini%, Renderer, FullScreenWidth
IniWrite, %fullScreenHeight%, %m2Ini%, Renderer, FullScreenHeight

If (SelectedNumberofPlayers = 1 || !linkEnabledGame) {
	; Changing Cabinent Settings for player 1 this is because we will need to switch between master controller mode and single mode
	; this info is stored in the NVDATA folder
	; store single player settings in the NVDATA\Single folder and the Multiplayer Settings in the NVDATA\Multi folder
	If (FileExist(emupath . "\NVDATA\Single\" . romName . ".DAT") && linkEnabledGame) {
		Log("Overwriting " . emupath . "\NVDATA\" . romName . ".DAT with " . emupath . "\NVDATA\Single\" . romName . ".DAT")
		FileCopy,%emupath%\NVDATA\Single\%romName%.DAT,%emupath%\NVDATA,1
	}
	
	Run(executable . A_Space . romName, emuPath, "Hide")	; Hides the emulator on launch. When bezel is enabled, this helps not show the emu before the rom is loaded
	WinWait("ahk_class MYWIN",,,"Model 2 Emulator")
	;WinWaitActive("ahk_class MYWIN",,,"Model 2 Emulator") ;this line only works if fade in is enabled
	Sleep, 1000 ; Increase if Hyperspin is getting a quick flash in before the game loads
} Else {
	;screen positions
	If (SelectedNumberofPlayers = 2)
		If SplitScreen2PlayersMode = Vertical
			X1 := 0 , Y1 := 0 ,	W1 := A_ScreenWidth//2 , H1 := A_ScreenHeight , X2 := A_ScreenWidth//2 , Y2 := 0 ,	W2 := A_ScreenWidth//2 , H2 := A_ScreenHeight
		Else
			X1 := 0 , Y1 := 0 ,	W1 := A_ScreenWidth , H1 := A_ScreenHeight//2 , X2 := 0 , Y2 := A_ScreenHeight//2 ,	W2 := A_ScreenWidth , H2 := A_ScreenHeight//2
	Else If (SelectedNumberofPlayers = 3)
		If SplitScreen3PlayersMode = P1left
			X1 := 0 , Y1 := 0 ,	W1 := A_ScreenWidth//2 , H1 := A_ScreenHeight , X2 := A_ScreenWidth//2 , Y2 := 0 ,	W2 := A_ScreenWidth//2 , H2 := A_ScreenHeight//2 , X3 := A_ScreenWidth//2 , Y3 := A_ScreenHeight//2 ,	W3 := A_ScreenWidth//2 , H3 := A_ScreenHeight//2
		Else If SplitScreen3PlayersMode = P1bottom
			X1 := 0 , Y1 := A_ScreenHeight//2 ,	W1 := A_ScreenWidth , H1 := A_ScreenHeight//2 , X2 := 0 , Y2 := 0 ,	W2 := A_ScreenWidth//2 , H2 := A_ScreenHeight//2 , X3 := A_ScreenWidth//2 , Y3 := 0 ,	W3 := A_ScreenWidth//2 , H3 := A_ScreenHeight//2
		Else If SplitScreen3PlayersMode = P1right
			X1 := A_ScreenWidth//2 , Y1 := 0 ,	W1 := A_ScreenWidth//2 , H1 := A_ScreenHeight ,	X2 := 0 , Y2 := 0 ,	W2 := A_ScreenWidth//2 , H2 := A_ScreenHeight//2 , X3 := 0 , Y3 := A_ScreenHeight//2 ,	W3 := A_ScreenWidth//2 , H3 := A_ScreenHeight//2
		Else	; top
			X1 := 0 , Y1 := 0 ,	W1 := A_ScreenWidth , H1 := A_ScreenHeight//2, X2 := 0 , Y2 := A_ScreenHeight//2 ,	W2 := A_ScreenWidth//2 , H2 := A_ScreenHeight//2, X3 := A_ScreenWidth//2 , Y3 := A_ScreenHeight//2 , W3 := A_ScreenWidth//2 , H3 := A_ScreenHeight//2
	Else
		X1 := 0 , Y1 := 0 ,	W1 := A_ScreenWidth//2 , H1 := A_ScreenHeight//2 , X2 := A_ScreenWidth//2 , Y2 := 0 ,	W2 := A_ScreenWidth//2 , H2 := A_ScreenHeight//2 , X3 := 0 , Y3 := A_ScreenHeight//2 ,	W3 := A_ScreenWidth//2 , H3 := A_ScreenHeight//2 , X4 := A_ScreenWidth//2 , Y4 := A_ScreenHeight//2 ,	W4 := A_ScreenWidth//2 , H4 := A_ScreenHeight//2
	
	;this loop is for error checking since this emulator needs multiple instances of the emulator starting from different locations to run
	Loop, %SelectedNumberofPlayers%
	{
		LinkedEmuPath := (A_Index = 1) ? (emupath) : (emupath%A_Index%)
		CheckFile(LinkedEmuPath . "\" . executable)
		CheckFile(LinkedEmuPath . "\EMULATOR.INI")
	}
	; Changing Cabinent Settings for player 1 this is because we will need to switch between master controller mode and single mode
	; this info is stored in the NVDATA folder
	; store single player settings in the NVDATA\Single folder and the Multiplayer Settings in the NVDATA\Multi folder
	If FileExist(emupath . "\NVDATA\Multi\" . romName . ".DAT") {
		Log("Overwriting " . emupath . "\NVDATA\" . romName . ".DAT with " . emupath . "\NVDATA\Multi\" . romName . ".DAT")
		FileCopy,%emupath%\NVDATA\Multi\%romName%.DAT,%emupath%\NVDATA,1
		}
		
	Loop, %SelectedNumberofPlayers%
	{
		LinkedEmuPath := (A_Index = 1) ? (emupath) : (emupath%A_Index%)
		m2ini := LinkedEmuPath . "\EMULATOR.INI"		;no need to checkfile it here since it's already been done
		romDir1 := IniReadCheck(m2Ini, "RomDirs", "Dir1",,,1)
		If (romDir1 != romPath)
			IniWrite, %romPath%, %m2Ini%, RomDirs, Dir1	; write the correct romPath to the emu's ini so the user does not need to define this
		; Removing Fullscreen
		IniWrite, 0, %m2Ini%, Renderer, AutoFull
		; Creating the link
		IniWrite,127.0.0.1,%LinkedEmuPath%\m2network.ini,network,NextIp		;127.0.0.1 is local address
		IniWrite,% (1978 + A_Index - 1),%LinkedEmuPath%\m2network.ini,network,RxPort		;Recieving port 
		;the last player sends information to the first player completing the circle
		IniWrite,% (If (A_Index = SelectedNumberofPlayers) ? 1978 : (1978 + A_Index)),%LinkedEmuPath%\m2network.ini,network,NextPort	;Sending Port 
		Run(executable . A_Space . romName, LinkedEmuPath, "Hide",Screen%A_Index%PID)
		WinWait("ahk_pid " . Screen%A_Index%PID)
		WinGet, Screen%A_Index%ID, ID, % "ahk_pid " . Screen%A_Index%PID
		If Fullscreen = true
		{	WinSet, Style, -0xC00000, % "ahk_id " . Screen%A_Index%ID
			ToggleMenu(Screen%A_Index%ID)
			WinSet, Style, -0xC40000, % "ahk_id " . Screen%A_Index%ID
			currentScreen := A_Index
			Log("Moving window " . currentScreen . " to " .  X%currentScreen% . "`," . Y%currentScreen% . " with W" . W%currentScreen% . " H" . H%currentScreen%)
			WinMove,  % "ahk_id " . Screen%currentScreen%ID, , % X%currentScreen%, % Y%currentScreen%, % W%currentScreen%, % H%currentScreen%
			;check If window moved
			timeout := A_TickCount
			Loop
			{	WinGetPos, X, Y, W, H, % "ahk_id " . Screen%currentScreen%ID
				If (X=X%currentScreen%) and (Y=Y%currentScreen%) and (W=W%currentScreen%) and (H=H%currentScreen%)
					break
				If (timeout<A_TickCount-2000)
					Break
				Sleep, 50
				WinMove, % "ahk_id " . Screen%currentScreen%ID, , % X%currentScreen%, % Y%currentScreen%, % W%currentScreen%, % H%currentScreen%
			}
		}
		Sleep, 50
	}
}

BezelDraw()

If (SelectedNumberofPlayers = 1 || !linkEnabledGame) {
	WinShow, ahk_class MYWIN	; Show the emulator
} Else {
	Loop %SelectedNumberofPlayers%
		WinShow, % "ahk_id " . Screen%a_index%ID	; Show the emulator
	WinActivate, ahk_id %Screen1ID%		; activate first player window so that first player can use keyboard instead of last player
}

;I find that the fade in exit looks better after the winshow lines
FadeInExit()

Process("WaitClose", executable)
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	If (SelectedNumberofPlayers>1) {
		Loop, %SelectedNumberofPlayers%
		{	WinClose("ahk_id " . Screen%A_Index%ID)
			WinWaitClose("ahk_id " . Screen%A_Index%ID)
		}
	} Else
		WinClose("AHK_class MYWIN")
Return



;_______________Players Selection Menu Code__________________________

StartPlayersSelectionMenu(maxPlayers=4){
	Global
	NumberofPlayersonMenu := maxPlayers
	If !pToken
		pToken := Gdip_Startup()
	Loop, 2 {
		Gui, playersMenu_GUI%A_Index%: +Disabled -Caption +E0x80000 +OwnDialogs +LastFound +ToolWindow +AlwaysOnTop 
		Gui, playersMenu_GUI%A_Index%: Margin,0,0
		Gui, playersMenu_GUI%A_Index%: Show,, playersMenuLayer%A_Index%
		playersMenu_hwnd%A_Index% := WinExist()
		playersMenu_hbm%A_Index% := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
		playersMenu_hdc%A_Index% := CreateCompatibleDC()
		playersMenu_obm%A_Index% := SelectObject(playersMenu_hdc%A_Index%, playersMenu_hbm%A_Index%)
		playersMenu_G%A_Index% := Gdip_GraphicsFromhdc(playersMenu_hdc%A_Index%)
		Gdip_SetSmoothingMode(playersMenu_G%A_Index%, 4)
	}
	;menu scalling factor
	playersMenuScallingFactor := A_ScreenWidth/1920
	VplayersMenuScallingFactor := A_ScreenHeight/1080
	If (playersMenuScallingFactor>VplayersMenuScallingFactor)
		playersMenuScallingFactor := VplayersMenuScallingFactor
	;Initializing parameters
	playersMenuTextFont := "Bebas Neue" 
	playersMenuSelectedTextSize := round(50*playersMenuScallingFactor)
	playersMenuSelectedTextColor := "FFFFFFFF"
	playersMenuDisabledTextColor := "FFAAAAAA"
	playersMenuDisabledTextSize := round(30*playersMenuScallingFactor)
	playersMenuMargin := round(50*playersMenuScallingFactor)
	playersMenuSpaceBtwText := round(30*playersMenuScallingFactor)
	playersMenuW := MeasureText(0,"X Players",playersMenuTextFont,playersMenuSelectedTextSize,"bold") + 2*playersMenuMargin
	playersMenuH := NumberofPlayersonMenu*playersMenuSelectedTextSize + (NumberofPlayersonMenu-1)*playersMenuSpaceBtwText + 2*playersMenuMargin
	playersMenuX := (a_screenWidth-playersMenuW)//2
	playersMenuY := (a_screenHeight-playersMenuH)//2
	playersMenuBackgroundBrush := Gdip_BrushCreateSolid("0xDD000000")
	;Drawing Background
	Gdip_FillRoundedRectangle(playersMenu_G1, playersMenuBackgroundBrush, 0, 0, playersMenuW, playersMenuH,5*playersMenuScallingFactor)
	UpdateLayeredWindow(playersMenu_hwnd1, playersMenu_hdc1, playersMenuX, playersMenuY, playersMenuW, playersMenuH)
    ;Drawing choice list   
	SelectedNumberofPlayers := 1
	DrawPlayersSelectionMenu(NumberofPlayersonMenu)
	;Enabling Keys
	If (keymapperEnabled = "true") and (keymapperHyperLaunchProfileEnabled = "true")
        RunKeymapper%zz%("menu",keymapper)
	If keymapperAHKMethod = "External"
		RunAHKKeymapper%zz%("menu")
	Gosub, EnablePlayersMenuKeys
	;Waiting for menu to exit
	Loop
	{	If PlayersMenuExit
			Break
		Sleep, 100
	}
	Return
}
	
DrawPlayersSelectionMenu(NumberofPlayersonMenu){
	Global
	currentY := 0
	Gdip_GraphicsClear(playersMenu_G2)
	Loop, % NumberofPlayersonMenu
	{
		If (a_index=SelectedNumberofPlayers) {
			currentTextSize := playersMenuSelectedTextSize
			currentTextColor := playersMenuSelectedTextColor
			currentTextStyle := "bold"
		} Else {
			currentTextSize := playersMenuDisabledTextSize
			currentTextColor := playersMenuDisabledTextColor
			currentTextStyle := "normal"
		}
		If (a_index=1)
			currentText := "1 Player"
		Else
			currentText := a_index . " Players"
		currentY := playersMenuMargin + (a_index-1)*(playersMenuSelectedTextSize+playersMenuSpaceBtwText)+(playersMenuSelectedTextSize-currentTextSize)//2
		Gdip_TextToGraphics(playersMenu_G2, currentText, "x0 y" . currentY . " Center c" . currentTextColor . " r4 s" . currentTextSize . " " . currentTextStyle, playersMenuTextFont, playersMenuW, playersMenuSelectedTextSize)
	}
	UpdateLayeredWindow(playersMenu_hwnd2, playersMenu_hdc2, playersMenuX, playersMenuY, playersMenuW, playersMenuH)
	Return	
}

EnablePlayersMenuKeys:
	XHotKeywrapper(navSelectKey,"PlayersMenuSelect","ON") 
	XHotKeywrapper(navUpKey,"PlayersMenuUP","ON")
	XHotKeywrapper(navDownKey,"PlayersMenuDown","ON")
	XHotKeywrapper(navP2SelectKey,"PlayersMenuSelect","ON") 
	XHotKeywrapper(navP2UpKey,"PlayersMenuUP","ON")
	XHotKeywrapper(navP2DownKey,"PlayersMenuDown","ON")
	XHotKeywrapper(exitEmulatorKey,"CloseProcess","OFF")
	XHotKeywrapper(exitEmulatorKey,"ClosePlayersMenu","ON")
Return

DisablePlayersMenuKeys:
	XHotKeywrapper(navSelectKey,"PlayersMenuSelect","OFF") 
	XHotKeywrapper(navUpKey,"PlayersMenuUP","OFF")
	XHotKeywrapper(navDownKey,"PlayersMenuDown","OFF")
	XHotKeywrapper(navP2SelectKey,"PlayersMenuSelect","OFF") 
	XHotKeywrapper(navP2UpKey,"PlayersMenuUP","OFF")
	XHotKeywrapper(navP2DownKey,"PlayersMenuDown","OFF")
	XHotKeywrapper(exitEmulatorKey,"ClosePlayersMenu","OFF")
	XHotKeywrapper(exitEmulatorKey,"CloseProcess","ON")
Return

PlayersMenuUP:
	SelectedNumberofPlayers--
	If (SelectedNumberofPlayers<1)
		SelectedNumberofPlayers:=NumberofPlayersonMenu
	DrawPlayersSelectionMenu(NumberofPlayersonMenu)
Return

PlayersMenuDown:
	SelectedNumberofPlayers++
	If (SelectedNumberofPlayers>NumberofPlayersonMenu)
		SelectedNumberofPlayers:=1
	DrawPlayersSelectionMenu(NumberofPlayersonMenu)
Return

PlayersMenuSelect:
	If ClosedPlayerMenu = true
		Log("User cancelled the launch at the Player Select Menu")
	Else
		Log("Number of Players Selected: " . SelectedNumberofPlayers)
	Gosub, DisablePlayersMenuKeys
	Gdip_DeleteBrush(playersMenuBackgroundBrush)
	Loop, 2 {
		SelectObject(playersMenu_hdc%A_Index%, playersMenu_obm%A_Index%)
		DeleteObject(playersMenu_hbm%A_Index%)
		DeleteDC(playersMenu_hdc%A_Index%)
		Gdip_DeleteGraphics(playersMenu_G%A_Index%)
		Gui, playersMenu_GUI%A_Index%: Destroy
	}
	If (keymapperEnabled = "true") and (keymapperHyperLaunchProfileEnabled = "true")
		RunKeymapper%zz%("load", keymapper)
	If keymapperAHKMethod = External
		RunAHKKeymapper%zz%("load")
	PlayersMenuExit := true
Return

ClosePlayersMenu:
	ClosedPlayerMenu := true
	Gosub, PlayersMenuSelect
	ExitModule()
Return
