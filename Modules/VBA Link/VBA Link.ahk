MEmu = VBA Link
MEmuV =  1.80b0
MURL = http://www.vbalink.info/
MAuthor = ghutch92 & bleasby
MVersion = 2.0.2
MCRC = 9C75BB65
iCRC = 389D415A
mId = 635148768577074672
MSystem = "Nintendo Game Boy","Nintendo Game Boy Color","Nintendo Game Boy Advance"
;----------------------------------------------------------------------------
; Notes:
; If you get flashing of the emu screen, try setting Options -> Video -> Render Method -> Direct3D. OpenGL gave me problems.
; 
; Link feature:
; To use the link feature, in the emu choose Options>Link>Settings>Single Computer. 
; Configure the inputs for all 4 players. 
; After all your settings have been made, open the emulator manually four times to create the four ini files.
; Open your games and navigate through the game's menu until you are able to connect the different emulators.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()

settingsFile := modulePath . "\" . moduleName . ".ini"
VBALink := IniReadCheck(settingsFile, romName, "VBALink", "false",,1)
VBALink_SplitScreen2PlayersMode := IniReadCheck(settingsFile, "Settings", "VBALink_SplitScreen_2_Players","Vertical",,1) ;horizontal or vertical
VBALink_SplitScreen3PlayersMode := IniReadCheck(settingsFile, "Settings", "VBALink_SplitScreen_3_Players","P1top",,1) ; For Player1 screen to be on left: P1left. For Player1 screen to be on top: P1top. For Player1 screen to be on bottom: P1bottom. For Player1 screen to be on right: P1right.

If (VBALink = "true")
	StartPlayersSelectionMenu(4)

FadeInStart()

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
VideoMode := IniReadCheck(settingsFile, "Settings", "VideoMode","3",,1) ;0-3 are window sizes. 4=320x240, 5=640x480, 6=600x800, 7 = fullscreen 
fsWidth := IniReadCheck(settingsFile, "Settings", "fsWidth",A_ScreenWidth,,1) ;fullscreen width
fsHeight := IniReadCheck(settingsFile, "Settings", "fsHeight",A_ScreenHeight,,1) ;fullscreen height


If (SelectedNumberofPlayers>1) {
	BezelStart(SelectedNumberofPlayers)	
} Else
	BezelStart()

7z(romPath, romName, romExtension, 7zExtractPath)

; vba1.ini is automatically created when the emulator is opened
vbaINI_1 := CheckFile(emuPath . "\vba1.ini")
IniRead, currentVideoMode, %vbaINI_1%, preferences, video

If (currentVideoMode > 3) AND (Fullscreen = "false")
	VideoMode = 3
Else If (currentVideoMode < 4) AND (Fullscreen = "true")
	VideoMode = 7

IniWrite, %VideoMode%, %vbaINI_1%, preferences, video
IniWrite, %fsWidth%, %vbaINI_1%, preferences, fsWidth
IniWrite, %fsHeight%, %vbaINI_1%, preferences, fsHeight


; This changes the mode the emulator runs in
If systemName = Nintendo Game Boy
	emuType = 3
Else If systemName = Nintendo Game Boy Color
	emuType = 1
Else If systemName = Nintendo Game Boy Advance
	emuType = 4
IniWrite, %emuType%, %vbaINI_1%, preferences, emulatorType

If (SelectedNumberofPlayers = 1) or (VBALink = "false") {
	Run(executable . " """ . romPath . "\" . romName . romExtension,emuPath)
	WinWait("VisualBoyAdvance")
	WinWaitActive("VisualBoyAdvance")
} Else {
	;screen positions
	If (SelectedNumberofPlayers = 2)
		If VBALink_SplitScreen2PlayersMode = Vertical
			X1 := 0 , Y1 := 0 ,	W1 := A_ScreenWidth//2 , H1 := A_ScreenHeight , X2 := A_ScreenWidth//2 , Y2 := 0 ,	W2 := A_ScreenWidth//2 , H2 := A_ScreenHeight
		Else
			X1 := 0 , Y1 := 0 ,	W1 := A_ScreenWidth , H1 := A_ScreenHeight//2 , X2 := 0 , Y2 := A_ScreenHeight//2 ,	W2 := A_ScreenWidth , H2 := A_ScreenHeight//2
	Else If (SelectedNumberofPlayers = 3)
		If VBALink_SplitScreen3PlayersMode = P1left
			X1 := 0 , Y1 := 0 ,	W1 := A_ScreenWidth//2 , H1 := A_ScreenHeight , X2 := A_ScreenWidth//2 , Y2 := 0 ,	W2 := A_ScreenWidth//2 , H2 := A_ScreenHeight//2 , X3 := A_ScreenWidth//2 , Y3 := A_ScreenHeight//2 ,	W3 := A_ScreenWidth//2 , H3 := A_ScreenHeight//2
		Else If VBALink_SplitScreen3PlayersMode = P1bottom
			X1 := 0 , Y1 := A_ScreenHeight//2 ,	W1 := A_ScreenWidth , H1 := A_ScreenHeight//2 , X2 := 0 , Y2 := 0 ,	W2 := A_ScreenWidth//2 , H2 := A_ScreenHeight//2 , X3 := A_ScreenWidth//2 , Y3 := 0 ,	W3 := A_ScreenWidth//2 , H3 := A_ScreenHeight//2
		Else If VBALink_SplitScreen3PlayersMode = P1right
			X1 := A_ScreenWidth//2 , Y1 := 0 ,	W1 := A_ScreenWidth//2 , H1 := A_ScreenHeight ,	X2 := 0 , Y2 := 0 ,	W2 := A_ScreenWidth//2 , H2 := A_ScreenHeight//2 , X3 := 0 , Y3 := A_ScreenHeight//2 ,	W3 := A_ScreenWidth//2 , H3 := A_ScreenHeight//2
		Else	; top
			X1 := 0 , Y1 := 0 ,	W1 := A_ScreenWidth , H1 := A_ScreenHeight//2, X2 := 0 , Y2 := A_ScreenHeight//2 ,	W2 := A_ScreenWidth//2 , H2 := A_ScreenHeight//2, X3 := A_ScreenWidth//2 , Y3 := A_ScreenHeight//2 , W3 := A_ScreenWidth//2 , H3 := A_ScreenHeight//2
	Else
		X1 := 0 , Y1 := 0 ,	W1 := A_ScreenWidth//2 , H1 := A_ScreenHeight//2 , X2 := A_ScreenWidth//2 , Y2 := 0 ,	W2 := A_ScreenWidth//2 , H2 := A_ScreenHeight//2 , X3 := 0 , Y3 := A_ScreenHeight//2 ,	W3 := A_ScreenWidth//2 , H3 := A_ScreenHeight//2 , X4 := A_ScreenWidth//2 , Y4 := A_ScreenHeight//2 ,	W4 := A_ScreenWidth//2 , H4 := A_ScreenHeight//2

	Loop, %SelectedNumberofPlayers%
	{	; vba%a_index%.ini is automatically created when the emulator is opened
		vbaINI := CheckFile(emuPath . "\vba" . a_index . ".ini", "Could not locate " . emuPath . "\vba" . a_index . ".ini. Make sure you opened " . executable . " manually 4 times to create all 4 ini files before attempting to use the Link feature.")
		IniRead, cVideo, %vbaINI%, preferences, video
		IniRead, cPauseWInactive, %vbaINI%, preferences, pauseWhenInactive
		IniRead, cAutoHideMenu, %vbaINI%, preferences, autoHideMenu
		IniRead, cStretch, %vbaINI%, preferences, stretch
		; Removing Fullscreen
		If (cVideo != 1)
			IniWrite, 1, %vbaINI%, preferences, video
		If (cPauseWInactive != 0)
			IniWrite, 0, %vbaINI%, preferences, pauseWhenInactive
		If (cAutoHideMenu != 1)
			IniWrite, 1, %vbaINI%, preferences, autoHideMenu
		If (cStretch != 0)
			IniWrite, 0, %vbaINI%, preferences, stretch
		IniWrite, % a_index-1, %vbaINI%, preferences, joypadDefault
		Run(executable . " """ . romPath . "\" . romName . romExtension,emuPath,, Screen%A_Index%PID)
		WinWait("ahk_pid " . Screen%A_Index%PID)
		WinGet, Screen%A_Index%ID, ID, % "ahk_pid " . Screen%A_Index%PID
		If Fullscreen = true
		{	WinSet, Style, -0xC00000, % "ahk_id " . Screen%A_Index%ID
			ToggleMenu(Screen%A_Index%ID)
			WinSet, Style, -0xC40000, % "ahk_id " . Screen%A_Index%ID
			currentScreen := a_index
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

FadeInExit()
Process("WaitClose",executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	If (SelectedNumberofPlayers>1) {
		Loop, %SelectedNumberofPlayers%
		{	WinClose("ahk_id " . Screen%a_index%ID)
			WinWaitClose("ahk_id " . Screen%a_index%ID)
		}
	} Else
		WinClose("VisualBoyAdvance")
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
	If keymapperAHKMethod = External
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
	Log("Number of Players Selected: " . SelectedNumberofPlayers)
	gosub, DisablePlayersMenuKeys
	Gdip_DeleteBrush(playersMenuBackgroundBrush)
	Loop, 2 {
		SelectObject(playersMenu_hdc%A_Index%, playersMenu_obm%A_Index%)
		DeleteObject(playersMenu_hbm%A_Index%)
		DeleteDC(playersMenu_hdc%A_Index%)
		Gdip_DeleteGraphics(playersMenu_G%A_Index%)
		Gui, playersMenu_GUI%A_Index%: Destroy
	}
	If (keymapperEnabled = "true") and (keymapperHyperLaunchProfileEnabled = "true")
		RunKeymapper%zz%("load",keymapper)
	If keymapperAHKMethod = External
		RunAHKKeymapper%zz%("load")
	PlayersMenuExit := true
Return

ClosePlayersMenu:
	Gosub, PlayersMenuSelect
	ExitModule()
Return
