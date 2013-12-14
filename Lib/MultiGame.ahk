MCRC = 99D52E2F
MVersion=1.0.3

StartMulti:
	Log("StartMulti - Started",4)
	MultiGame_BeginTime := A_TickCount 
	;-----------------------------------------------------------------------------------------------------------------------------------------
	 ; Check If launched rom is part of a set so we know to cancel GUI or not. Then check If 7z support is needed.
	;-----------------------------------------------------------------------------------------------------------------------------------------
	multiTypes = (Disc,(Disk,(Cart,(Tape,(Cassette,(Part,(Side
	If dbName not contains %multiTypes%
		Return
	XHotKeywrapper(mgKey,"StartMulti","OFF")	; turning off mgKey so user cannot press it while the GUI is loading
	If hpEnabled = true
		XHotKeywrapper(hpKey,"TogglePauseMenuStatus","OFF")	; turning off the HyperPause key so nobody can bring up HP while MG is active, it will crash or cause advers affects
	If bezelEnabled = true
	{	Gosub, DisableBezelKeys	; many more bezel keys if they are used need to be disabled
        if ICRightMenuDraw 
            Gosub, DisableICRightMenuKeys
        if ICLeftMenuDraw
            Gosub, DisableICLeftMenuKeys
        if (bezelBackgroundsList.MaxIndex() > 1)
            if bezelBackgroundChangeDur
                settimer, BezelBackgroundTimer, OFF
	}
    XHotKeywrapper(exitEmulatorKey,"CloseProcess","OFF")	; turning off exitEmulatorKey so user cannot press it while the GUI is loading
	currentButton:=1 ; Start at one
	mgCancel:=	; resetting mgCancel
	mgSelectedGame:=	; resetting mgSelectedGame
	angle:=0	; resetting Angle
	b:=1	; resetting Grow
	mgGrowing:=	; resetting Grow
	
	;-----------------------------------------------------------------------------------------------------------------------------------------
	; Main script to get the information to populate the GUI
	;-----------------------------------------------------------------------------------------------------------------------------------------
	If !romTable ; romTable was already created, no need to create it again
		romTable:=CreateRomTable(dbName)	; This creates a table or the roms that match the media type this rom uses. We need to know what roms are part of this rom's set and only look for those. It stores a path (column 1), filename (column 2), and the image text (column 3) in a table.

	If !romTable.MaxIndex() {
		ToolTip, This game does not need Multi-Game support, 0, 0
		Log("StartMulti - This game does not need Multi-Game support or your rom names are not named correctly so that HyperLaunch can link them together.",2)
		Sleep, 1000
		ToolTip
		XHotKeywrapper(mgKey,"StartMulti","ON")	; turning back on mgKey
		If hpEnabled = true
			XHotKeywrapper(hpKey,"TogglePauseMenuStatus","ON"), On	; turning back on hpKey
		XHotKeywrapper(exitEmulatorKey,"CloseProcess","ON")
		Log("StartMulti - Ended",4)
		Return	; required for HL, this will return back to the emu If rom does not qualify for MG
	}

	; Grab the current emulator's info so we can restore on exit
	WinGet mgEmuProcessName, ProcessName, A
	WinGetClass, mgEmuClass, A
	WinGet mgEmuID, ID, A
	WinGetPos,,, emuW, emuH, ahk_id %mgEmuID%
	Log("StartMulti - Your current screen's resolution is " . A_ScreenWidth . "x" . A_ScreenHeight,4)
	Log("StartMulti - Your emulator """ . mgEmuProcessName . """ is running at " . emuW . "x" . emuH,4)

	;-----------------------------------------------------------------------------------------------------------------------------------------
	; GDI GUI START
	;-----------------------------------------------------------------------------------------------------------------------------------------
	If !pToken := Gdip_Startup()	; Start gdi+
	{	ScriptError("Gdiplus failed to start. Please ensure you have gdiplus on your system")
		ExitApp
	}
	
	; Create a simple ahk Black Gui which helps avoid flashing to desktop on some PCs when mgKey is pressed. 
	If !disableLoadScreen
	{	mgBlackScreenBackgroundBrush := Gdip_BrushCreateSolid("0xff000000")
		Gui, 19: New, +HwndmgBlackScreen19 +E0x80000 +ToolWindow -Caption +AlwaysOnTop +OwnDialogs, mgBlackScreen
		mgBlackScreen_hbm := CreateDIBSection(originalWidth, originalHeight)
		mgBlackScreen_hdc := CreateCompatibleDC()
		mgBlackScreen_obm := SelectObject(mgBlackScreen_hdc, mgBlackScreen_hbm)
		mgBlackScreen_G := Gdip_GraphicsFromhdc(mgBlackScreen_hdc)
		Gdip_FillRectangle(mgBlackScreen_G, mgBlackScreenBackgroundBrush, -1, -1, originalWidth+1, originalHeight+1)   
		Gui,19: Show, na
		UpdateLayeredWindow(mgBlackScreen19, mgBlackScreen_hdc, 0, 0, originalWidth, originalHeight)
	}
	Log("StartMulti - Halting emu If module contains a HaltEmu label.",4)
	Gosub, HaltEmu
	Log("StartMulti - Finished Processing HaltEmu label.",4)
	;activating mg Black Screen for hidding Hyperspin If not disabled in the module 
	If !disableLoadScreen 
        If !(disableActivateBlackScreen and HyperPause_Disable_Menu="true")
            WinActivate, mgBlackScreen
	;Suspending emulator process while in multigame (pauses the emulator If halemu does not contain pause controls)
	If !disableSuspendEmu { 
        ProcSus(mgEmuProcessName)
        Log("Emulator process suspended",4)
    }
	
	If (keymapperEnabled = "true") and (keymapperHyperLaunchProfileEnabled = "true") and (keymapper != "ahk")
		RunKeyMapper%zz%("menu",keymapper)	; If user desires, load HyperLaunch profile for controllers
	If ((keymapperEnabled = "true") and (keymapperAHKMethod = External))
		RunAHKKeymapper%zz%("menu")

	Loop, 2 { ; create 2 GUI layers (1 = background, text, image1, 2 = image2 and what is animated)
		if (A_Index=1)
			Gui,  MG_GUI%A_Index%: -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop +OwnDialogs ; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
		else if (A_Index > 1)
			Gui,  MG_GUI%A_Index%: +OwnerMG_GUI1 -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop +OwnDialogs 
		Gui, MG_GUI%A_Index%: Margin,0,0
		Gui, MG_GUI%A_Index%: Show,, MG Layer %A_Index%
		MG%A_Index%_ID := WinExist()	
		MGhbm%A_Index% := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
		MGhdc%A_Index% := CreateCompatibleDC()
		MGobm%A_Index% := SelectObject(MGhdc%A_Index%, MGhbm%A_Index%)
		mgG%A_Index% := Gdip_GraphicsFromhdc(MGhdc%A_Index%)
	}
	Gdip_SetInterpolationMode(mgG1, 7) ; we only want to use interpolation mode for our background as it slows down rotation on the images

	If !hFamily := Gdip_FontFamilyCreate(mgFont)
		ScriptError("The Font " . mgFont . " you have specified does not exist on the system")
	Gdip_DeleteFontFamily(hFamily)	; Delete mgFont family as we now know the mgFont does exist

	;-----------------------------------------------------------------------------------------------------------------------------------------
	; If a background image exists, use it instead of a solid color
	Supported_Images = png,gif,tif,bmp,jpg
	MGBackground := []
    DescriptionNameWithoutDisc := romTable[1,4]
	
	; Search for Background Artwork
	mgBackgroundPath1 := HLMediaPath . "\Backgrounds\" . systemName . "\"  . dbName
	mgBackgroundPath2 := HLMediaPath . "\Backgrounds\" . systemName . "\"  . DescriptionNameWithoutDisc
	mgBackgroundPath3 := HLMediaPath . "\Backgrounds\" . systemName . "\_Default"
	mgBackgroundPath4 := HLMediaPath . "\Backgrounds\_Default"
	Loop, 4 {
		mgBackgroundIndex := A_Index	; so it can be used in the next loop
		Log("MultiGame - Looking for Backgrounds in: " . mgBackgroundPath%A_Index%,4)
		If FileExist(mgBackgroundPath%A_Index% . "\*.*")
			Loop, parse, Supported_Images,`,
			{	Log("MultiGame - Scanning for Background art: " . mgBackgroundPath%mgBackgroundIndex% . "\*." . A_LoopField,4)
				Loop, % mgBackgroundPath%mgBackgroundIndex% . "\*." . A_LoopField
				{ 	Log("MultiGame - Found Background art: " . A_LoopFileFullPath,4)
					MGBackground.Insert(A_LoopFileFullPath)
				}
			}
		If MGBackground[1]
			Break
	}
	If MGBackground[1] {
	 	Log("MultiGame - Randomizing found background images.",4)
        Random, RndmBackground, 1, % MGBackground.MaxIndex()
        multiBG := MGBackground[RndmBackground]
		Log("MultiGame - Using background art: " . multiBG)
    }

	; Search for Default Artwork used for media types
	Loop, 2 {	; Load the 2 files into variables for easy calling later
		mgDefaultArtPath1 := HLMediaPath . "\MultiGame\" . systemName . "\_Default\" . romTable[A_Index,6] . "_image_" . A_Index . ".png"
		mgDefaultArtPath2 := HLMediaPath . "\MultiGame\_Default\" . romTable[A_Index,6] . "_image_" . A_Index . ".png"
		mgDefaultArtIndex := A_Index	; so it can be used in the next loop
		Loop, 2 {
			Log("MultiGame - Looking for Default " . romTable[A_Index,6] . " Art in: " . mgDefaultArtPath%A_Index%,4)
			If FileExist(mgDefaultArtPath%A_Index%) {
				Image_%mgDefaultArtIndex% := mgDefaultArtPath%A_Index%
				Log("MultiGame - Found Default " . romTable[A_Index,6] . " Art: " . mgDefaultArtPath%A_Index%)
				foundDefaultMGArt = 1
				Break
			}
		}
		If !foundDefaultMGArt {
			Log("MultiGame - Could not locate any Default " . romTable[A_Index,6] . " Art, downloading default " . romTable[A_Index,6] . " artwork to: " . mgDefaultArtPath,4)
			ToolTip, Downloading Image %A_Index%,0,0
			IfNotExist, %  HLMediaPath . "\MultiGame\_Default\"
				FileCreateDir, %  HLMediaPath . "\MultiGame\_Default\" ; Need to create the folder first otherwise urldownload will fail
			UrlDownloadToFile, % "http://www.hyperspin-fe.com/HL2/" . romTable[A_Index,6] . "_image_" . A_Index . ".png", % mgDefaultArtPath2
			If ErrorLevel
				ScriptError("Error connecting to www.hyperspin-fe.com to download images. Please try again later or report the problem If it persists.")
			Else
				Image_%A_Index% := mgDefaultArtPath4
		}
		foundDefaultMGArt:=	; empty for next loop
	}

	;Defining a scalling factor based on screen resolution if mgImageAdjust is set to zero
	if (mgImageAdjust="0"){
		mgScallingFactor := 1
		mgImageAdjust := A_ScreenWidth/1920
		VmgImageAdjust := A_ScreenHeight/1080
		If(mgImageAdjust>VmgImageAdjust)
			mgImageAdjust := VmgImageAdjust 
		mgSidePadding := round(mgSidePadding*mgImageAdjust)
		mgYOffset := round(mgYOffset*mgImageAdjust)
		mgText2Offset := round(mgText2Offset*mgImageAdjust)
		FoundPos := RegExMatch(mgText1Options, "i)S(\d+)(p*)", OriginalSize) ; Acquiring rom info font size
		StringTrimLeft, Size , OriginalSize,1
		FinalSize := "s" . round(Size*mgImageAdjust)
		StringReplace, mgText1Options, mgText1Options, %OriginalSize%, %FinalSize%
		FoundPos := RegExMatch(mgText2Options, "i)S(\d+)(p*)", OriginalSize) ; Acquiring rom info font size
		StringTrimLeft, Size , OriginalSize,1
		FinalSize := "s" . round(Size*mgImageAdjust)
		StringReplace, mgText2Options, mgText2Options, %OriginalSize%, %FinalSize%
		Log("Multigame screen components scale factor: " mgImageAdjust,5)
    }

	; Search for Game Artwork used for media types, then get dimensions and add to romTable
    for index, element in romTable	; for each rom found in the table
	{
		If mgUseGameArt = true
		{	mgGameArtPath1 := HLMediaPath . "\MultiGame\" . systemName . "\" . dbName . "\" . romTable[A_Index,6] . "_image_" . A_Index . ".png"
			mgGameArtPath2 := HLMediaPath . "\MultiGame\" . systemName . "\" . DescriptionNameWithoutDisc . "\" . romTable[A_Index,6] . "_image_" . A_Index . ".png"
			mgGameArtPath3 := frontendPath . "\Media\" . systemName . "\Images\" . mgArtworkDir . "\" . romTable[A_Index, 3] . ".png"
			mgGameArtIndex := A_Index	; so it can be used in the next loop
			Loop, 3 {
				Log("MultiGame - Checking for Game " . romTable[mgGameArtIndex,6] . " Art: " . mgGameArtPath%A_Index%,4)
				If FileExist(mgGameArtPath%A_Index%) {
					Log("MultiGame - Using Game Art for " . romTable[mgGameArtIndex,6] . " " . mgGameArtIndex . ": " . mgGameArtPath%A_Index%)
					romTable[mgGameArtIndex, 16] := "Yes"	; Column 16 contains Yes If artwork was found for current Disc
					romTable[mgGameArtIndex, 17] := Gdip_CreateBitmapFromFile(mgGameArtPath%A_Index%)	; store pointer to artwork in column 17
					If !romTable[mgGameArtIndex, 17] {
						ScriptError("Error Loading MultiGame Artwork " . A_Index . "`, Could not find " .  romTable[mgGameArtIndex,3] . ".png. Please try again later or report the problem If it persists.")
						Goto, MGExit
					}
					foundGameArt = 1
					Break
				}
			}
		}
		If !foundGameArt {
			Log("MultiGame - " . (mgUseGameArt = "true" ? "No Game Art found" : "Game Art disabled") . ". for " . romTable[A_Index,6] . " " . A_Index . ", using default: """ . Image_1 . """ and """ . Image_2 . """")
			romTable[A_Index, 17] := Gdip_CreateBitmapFromFile(Image_1)	; If user doesn't have mediatype art for this game or has mgUseGameArt turned off, load the default instead and store pointer to Image_1 in column 17
			romTable[A_Index, 18] := Gdip_CreateBitmapFromFile(Image_2)	; Also have to load the highlighted image_2 and store its pointer in column 18
		}

		Gdip_GetImageDimensions(romTable[A_Index, 17], mgArtW, mgArtH)	; get the width and height of the image
		romTable[A_Index,12] := mgArtW, romTable[A_Index,13] := mgArtH	; recording each images original width in column 12 and original height in column 13
		romTable[A_Index,14] := round(romTable[A_Index,12]*mgImageAdjust), romTable[A_Index, 15] := round(romTable[A_Index,13]*mgImageAdjust)	; recording each images adjusted width in column 14 and adjusted height in column 15
		If mgSelectedEffect = rotate
		{	Gdip_GetRotatedDimensions(romTable[A_Index, 14], romTable[A_Index, 15], 90, mgRW%A_Index%, mgRH%A_Index%)	; getting rotated dimensions of the images and storing them in the mgRW vars
			mgRW%A_Index% := (mgRW%A_Index% > romTable[A_Index, 14]) ? mgRW%A_Index%* : romTable[A_Index, 14], mgRH%A_Index% := (mgRH%A_Index% > romTable[A_Index, 15]) ? mgRH%A_Index% : romTable[A_Index, 15]
		}
		foundGameArt:=	; empty for next loop
	}

	totalUnusedWidth := A_ScreenWidth - ( romTable[1,14] * romTable.MaxIndex() )	; calculate the width of the screen not being used by the adjusted width of the images
	remainingUnusedWidth := totalUnusedWidth * ( 1 - ( mgSidePadding * 2 )) ; multiply mgSidePadding by 2 for left/right sides, then subtract it from 1 (or 100%) to get our remaining multiplier for totalUnusedWidth
	paddingSpotsNeeded := romTable.MaxIndex() - 1 ; the amount of spaces we need to divy up our remainingUnusedWidth
	imageSpacing := remainingUnusedWidth//paddingSpotsNeeded ; now take our remainingUnusedWidth and divide it up by the amount of spaces we need between our images
	imageX:=mgSidePadding * totalUnusedWidth ; this is the initial spot for the first image
	imageXcurrent:=imageX
	; imageChosen:=1 ; set the first image control number (the first button), for mouse input only
	;-----------------------------------------------------------------------------------------------------------------------------------------

	If MultiBG {
		mBGBitmap := Gdip_CreateBitmapFromFile(multiBG)
		Gdip_GetImageDimensions(mBGBitmap, mBGw, mBGh)	; get the width and height of the background image
		Gdip_DrawImage(mgG1, mBGBitmap, 0, 0, A_ScreenWidth+1, A_ScreenHeight+1, 0, 0, mBGw, mBGh)	; draw background image onto screen on layer 1
	} Else {
		mPBrush := Gdip_BrushCreateSolid("0x" . mgBackgroundColor)						; Painting the background color
		Gdip_FillRectangle(mgG1, mPBrush, -1, -1, A_ScreenWidth+1, A_ScreenHeight+1)										; draw the background first on layer 1, layer order matters!!
	}

	Gdip_TextToGraphics(mgG1, mgText1Text, mgText1Options, mgFont, A_ScreenWidth, A_ScreenHeight)					; set screen text in middle on layer 1

	; This loops places each image_1 evenly across the screen and the text to go along with each image. It also creates a button control so each image is selectable.
	for index, element in romTable {
		romTable[A_Index,10] := (If romTable[A_Index, 16] ? (imageXcurrent) : (imageXcurrent+(romTable[1,14]//2-romTable[A_Index,14]//2)))	; storing the X position of the image in column 6. If no art is found, the default art's X is adjusted to fit in the middle of  the width of the missing art's width (aka centering the default image)
		romTable[A_Index,11] := A_ScreenHeight - mgYOffset	; storing the Y position of the image in column 7
		Gdip_DrawImage(mgG1, romTable[A_Index, 17], romTable[A_Index,10], A_ScreenHeight - mgYOffset, romTable[1,14], romTable[A_Index, 15], 0, 0, romTable[1,14]//mgImageAdjust, romTable[A_Index, 15]//mgImageAdjust) ; draw each mgArt or default mgArt1 onto screen on layer 1
		Gdip_TextToGraphics(mgG1, romTable[A_Index,5], "x" . imageXcurrent . " y" . A_ScreenHeight-mgYOffset-mgText2Offset . " " . mgText2Options, mgFont, romTable[1,14], romTable[A_Index, 15]) ; place the text from the table in column 3 above each mgArt to describe it on layer 1
		mgArt%A_Index%X := imageXcurrent
		If ( A_index <= paddingSpotsNeeded ) ; only need to adjust imageXcurrent on loops that we are adding another image next loop through
			imageXcurrent:=imageXcurrent+ romTable[1,14]+imageSpacing
	}

	UpdateLayeredWindow(MG1_ID, mgHDC1, 0, 0, A_ScreenWidth, A_ScreenHeight)
	SetTimer,Update,30 ; start updating GUI for user input

	; By placing this OnMessage here. The function WM_LBUTTONDOWN will be called every time the user left clicks on the gui
	OnMessage(0x201, "WM_LBUTTONDOWN") ; commented out so bitmap is not clickable/draggable
	XHotKeywrapper(navUpKey,"Forward","On")
	XHotKeywrapper(navDownKey,"Backward","On")
	XHotKeywrapper(navLeftKey,"Forward","On")
	XHotKeywrapper(navRightKey,"Backward","On")
	XHotKeywrapper(navSelectKey,"SelectGame","On")
	XHotKeywrapper(navP2UpKey,"Forward","On")
	XHotKeywrapper(navP2DownKey,"Backward","On")
	XHotKeywrapper(navP2P2LeftKey,"Forward","On")
	XHotKeywrapper(navP2RightKey,"Backward","On")
	XHotKeywrapper(navP2SelectKey,"SelectGame","On")
	XHotKeywrapper(mgKey,"MGExit","On")
	XHotKeywrapper(exitEmulatorKey,"MGExit","On")
	Log("StartMulti - Ended",4)
Return

Forward:
	If (mgUseSound="true")
		SoundBeep,%mgSoundfreq%,10
	If (mgSelectedEffect = "grow") {
		Gdip_GraphicsClear(mgG2)
		mgGrowing:=
		b := 1
	}
		angle:=0
	old_currentButton:=currentButton ; this sets the button I am leaving to the original color
	If (currentButton>1) ; this is what controls when the cursor moves to the next or previous button when moving left or right
		currentButton:=currentButton-1
	Else
		currentButton:=romTable.MaxIndex()
Return
Backward:
	If (mgUseSound="true")
		SoundBeep,%mgSoundfreq%,10
	If (mgSelectedEffect = "grow") {
		Gdip_GraphicsClear(mgG2)
		mgGrowing:=
		b := 1
	}
	angle:=0
	old_currentButton:=currentButton
	If (currentButton<romTable.MaxIndex())
		currentButton:=currentButton+1
	Else
		currentButton:=1
Return

Update:
	;ToolTip % "Button: " . currentButton . "`nFull Path Name (Col1): " . romTable[currentButton, 1] . "`nFilename w/ext (Col2): " . romTable[currentButton, 2] . "`nFilename w/o ext(Col3): " . romTable[currentButton, 3] . "`nFilename w/o media (Col4): " . romTable[currentButton, 4] . "`nFull media type and # (Col5): " . romTable[currentButton, 5] . "`nMedia type only (Col6): " . romTable[currentButton, 6] . "`nX (Col10): " . romTable[currentButton,10] . "`nY (Col11): " . romTable[currentButton,11] . "`nCurrent Button Original Width (Col12): " . romTable[currentButton, 12] . "`nCurrent Button Original Height (Col13): " . romTable[currentButton, 13] . "`nCurrent Button Adjusted Width (Col14): " . romTable[currentButton,14] . "`nCurrent Button Adjusted Height (Col15): " . romTable[currentButton,15] . "`nDisc Art Found (Col16): " . romTable[currentButton,16] . "`nImage 1 Pointer (Col17)?: " . romTable[currentButton,17] . "`nImage 2 Pointer (Col18)?: " . romTable[currentButton,18] . "`n7z Extracted (Col19): " . romTable[currentButton, 19],0,0
	IfWinNotActive,MG Layer 2 ahk_class AutoHotkeyGUI
	WinActivate,MG Layer 2 ahk_class AutoHotkeyGUI
	Gdip_GraphicsClear(mgG2)
	If (mgSelectedEffect = "rotate" && romTable[currentButton,16]) {	; If current button has artwork
		angle := (angle > 360) ? 2 : angle+2
		Gdip_ResetWorldTransform(mgG2)
		Gdip_TranslateWorldTransform(mgG2, mgRW%currentButton%//2, mgRH%currentButton%//2)
		Gdip_RotateWorldTransform(mgG2, angle)
		Gdip_TranslateWorldTransform(mgG2, -mgRW%currentButton%//2, -mgRH%currentButton%//2)
		Gdip_DrawImage(mgG2, romTable[currentButton,17], (mgRW%currentButton%-romTable[currentButton,14]), (mgRH%currentButton%-romTable[currentButton,15]), romTable[currentButton,14], romTable[currentButton,15])
		UpdateLayeredWindow(MG2_ID, mgHDC2, romTable[currentButton,10]-1, romTable[currentButton,11]-1, mgRW%currentButton%, mgRH%currentButton%)	; small adjustment to keep images exactly on layer 1 images
		Return
	} Else If (mgSelectedEffect = "rotate" && !romTable[currentButton,16]) {	; If current button has no artwork
		Gdip_ResetWorldTransform(mgG2)
		Gdip_DrawImage(mgG2, romTable[currentButton,18], romTable[currentButton,10],  romTable[currentButton,11], romTable[currentButton,14], romTable[currentButton,15], 0, 0, romTable[currentButton,14]//mgImageAdjust, romTable[currentButton,15]//mgImageAdjust) ; draw Image_2 on top of Image_1
	} Else If (mgSelectedEffect = "grow") {
		Sleep, 5	; required otherwise this loop moves too fast and grow animations don't occur
		If !mgGrowing
			SetTimer, MGGrow, -1	; launch MGGrow once
		Return
	}
	UpdateLayeredWindow(MG2_ID, mgHDC2, 0, 0, A_ScreenWidth, A_ScreenHeight)
Return

MGGrow:
	Log("MGGrow - Started",4)
	mgGrowing:=1
	While b <= 30 {	; grow image by 30 pixels
		Gdip_DrawImage(mgG2, (If romTable[currentButton,16] ? (romTable[currentButton,17]):(romTable[currentButton,18])), romTable[currentButton,10]-(b//2),  romTable[currentButton,11]-(b//2), romTable[currentButton,14]+b, romTable[currentButton,15]+b, 0, 0, romTable[currentButton,14]//mgImageAdjust, romTable[currentButton,15]//mgImageAdjust) ; grow Image slightly and highlight If default image used
		UpdateLayeredWindow(MG2_ID, mgHDC2, 0, 0, A_ScreenWidth, A_ScreenHeight)
		b+=2
	}
	Log("MGGrow - Ended",4)
Return

;-----------------------------------------------------------------------------------------------------------------------------------------
; This requires standard ahk gui buttons and is used as the g-label. You cannot assign g-labels to gdi objects
; ImageMouseControl: ; this gets assigned to each button and gets ran when user clicks on it with the mouse, not called when the user uses the arrow keys to select buttons
	; imageChosen=%A_GuiControl% ; imageChosen is the control for the button clicked
	; StringReplace,imageChosen,imageChosen,GDI_image,,, ; this removes the GDI_image from the variable so only the button # is in the variable
	; old_currentButton:=currentButton ; when user clicks the new button, this sets the current button as the old one
	; currentButton:=imageChosen ; when user clicks the new button, this is what changes the image of the new button
	; msgbox, %currentButton%
; Return

SelectGame:
	Log("SelectGame - Started")
	SetTimer,Update, Off ; turning off timer, otherwise it resets the mgExitEffect during its loop
	mgLastGame := If !selectedRom ? dbName : selectedRom	; fill this var so we can track what game we were running before
	If mgExitEffect {
		v := 1
		b+=2
		If mgSelectedEffect = rotate
		{
			Gdip_GraphicsClear(mgG2)
			Gdip_ResetWorldTransform(mgG2)
			UpdateLayeredWindow(MG2_ID, mgHDC2, 0, 0, A_ScreenWidth, A_ScreenHeight)
		}
		Loop, 25 {
			If mgExitEffect = pixelate
			{
				mgArtOut := Gdip_CreateBitmap(romTable[currentButton,14]//mgImageAdjust, romTable[currentButton,15]//mgImageAdjust)
				If romTable[currentButton,16] {	; If current button has artwork and not default image
					Gdip_PixelateBitmap(romTable[currentButton,17], mgArtOut,++v)
					Gdip_DrawImage(mgG2, mgArtOut, romTable[currentButton,10]-(b//2), romTable[currentButton,11]-(b//2), romTable[currentButton,14]+b, romTable[currentButton,15]+b) ;, 0, 0, romTable[currentButton,14]//mgImageAdjust, romTable[currentButton,15]//mgImageAdjust)
				} Else {
					Gdip_PixelateBitmap(romTable[currentButton,18], mgArtOut,++v)
					Gdip_DrawImage(mgG2, mgArtOut, romTable[currentButton,10], romTable[currentButton,11], romTable[currentButton,14], romTable[currentButton,15], 0, 0, romTable[currentButton,14]//mgImageAdjust, romTable[currentButton,15]//mgImageAdjust)
				}
			} Else If mgExitEffect = grow
			{
				Gdip_DrawImage(mgG2, (If romTable[currentButton,16] ? (romTable[currentButton,17]):(romTable[currentButton,18])), romTable[currentButton,10]-(b//2)-(v//2), romTable[currentButton,11]-(b//2)-(v//2), romTable[currentButton,14]+b+v, romTable[currentButton,15]+b+v, 0, 0, romTable[currentButton,14]//mgImageAdjust, romTable[currentButton,15]//mgImageAdjust)
			}
			UpdateLayeredWindow(MG2_ID, mgHDC2)
			v+=2
		}
	}
	selectedRom:=romTable[currentButton,1]	; need to convert this for the next line to work
	selectedRomNum:=romTable[currentButton,5]	; Store selected rom's Media and number
	Log("SelectGame - User selected to load: " . selectedRom,4)
	SplitPath, selectedRom,,mgRomPath,mgRomExt,mgDbName
	mgRomExt := "." . mgRomExt	; need to add the period back in otherwise ByRef on the 7z call doesn't work
	;creating Disc Changing Screen
	Gdip_GraphicsClear(mgG1)
	If MultiBG 
		Gdip_DrawImage(mgG1, mBGBitmap, 0, 0, A_ScreenWidth+1, A_ScreenHeight+1, 0, 0, mBGw, mBGh)	; draw background image onto screen on layer 1
	Else
		Gdip_FillRectangle(mgG1, mPBrush, -1, -1, A_ScreenWidth+1, A_ScreenHeight+1)										; draw the background first on layer 1, layer order matters!!
	Gdip_TextToGraphics(mgG1, "Changing Disc", mgText1Options, mgFont, A_ScreenWidth, A_ScreenHeight)	
	UpdateLayeredWindow(MG1_ID, mgHDC1, 0, 0, A_ScreenWidth, A_ScreenHeight)
	If 7zEnabled = true	; Only need to continue If 7z support is turned on, this check is in case emu supports loading of compressed roms. No need to decompress our rom If it does
	{	If mgRomExt in %7zFormats%	; Check If our selected rom is compressed.
		{	Log("SelectGame - This game needs 7z to load. Sending it off for extraction: " . mgRomPath . "\" . mgDbName . mgRomExt,4)
			7z%currentButton% := 7z(mgRomPath, mgDbName, mgRomExt, 7zExtractPath, "mg")	; Send chosen game to 7z for processing. We get back the same vars but updated to the new location.
			selectedRom := mgRomPath . "\" . mgDbName . mgRomExt
			Log("SelectGame - Returned from 7z extraction, path to new rom is: " . selectedRom,4)
			romTable[currentButton,19] := mgRomPath	; storing path to extracted rom in column 19 so 7zCleanUp knows to delete it later
			Log("SelectGame - Stored """ . mgRomPath . """ for deletion in 7zCleanup.",4)
		} Else
			Log("SelectGame - This game does not need 7z. Sending it directly to the emu or to Daemon Tools If required.",4)
	}
	mgSelectedGame = 1	; filling var so we know user selected a game
	Log("SelectGame - Ended")
	Goto, MGExit
Return

UpdateMGFor7z:
	Gosub, MGProgressBarAnimation	; Calling MG Progress Bar Animation
Return

MGProgressBarAnimation:
	; start the progress bar animation Loop
	Log("MGProgressBarAnimation - Started")
	currentFloat := A_FormatFloat 
	mgFinishedBar :=
	SetFormat, Float, 3.2	; required otherwise calculations below falsely trigger
	Loop {
		Gdip_GraphicsClear(mgG2)
		; Updating 7z extraction info
		romExPercentageAndFile := COM_Invoke(HLObject, "getExtractionSize", 7zRomPath, 0)	; Get the current file being extracted and size of the 7z Extract Path - (Extraction Progress (Accurate Method))
		Loop, Parse, romExPercentageAndFile, |	; StringSplit oddly doesn't work for some unknown reason, must resort to a parsing Loop instead
			If A_Index = 1
			{
				romExCurSize := A_LoopField									; Store bytes extracted
				percentage := (A_LoopField / romExSize) * 100	; Calculate percentage extracted
			} Else If A_Index = 2
				romExFile := A_LoopField
		; Drawing progress Bar
		; Appearance Options:
		mgBarW := round(600*mgImageAdjust)
		mgBarH := round(30*mgImageAdjust)
		mgBarBackgroundMargin := round(40*mgImageAdjust)
		mgBarBackgroundRadius := round(10*mgImageAdjust) 
		mgBarX := (A_ScreenWidth - mgBarW)//2 - mgBarBackgroundMargin 
		mgBarY := (A_ScreenHeight)//2 + round(300*mgImageAdjust)
		mgBarR := round(10*mgImageAdjust)
		mgBarBackgroundColor := "BB000000"
		mgBarBackColor := "BB555555"
		mgBarColor := "DD00BFFF"
		mgBarHatchStyle := 3
		mgBarText1Options := "cFFFFFFFF r4 s" . round(20*mgImageAdjust) . " Right Bold"
		mgBarText1 := "Loading Game"
		mgBarText2Options := "cFFFFFFFF r4 s" . round(20*mgImageAdjust) . " Right Bold"
		mgBarText2 := "Extraction Complete"
		; Drawing Bar Background
		mgBackgroundBrush := Gdip_BrushCreateSolid("0x" . mgBarBackgroundColor)
		mgBarBackBrush := Gdip_BrushCreateSolid("0x" . mgBarBackColor)
		mgBarBrush := Gdip_BrushCreateHatch(0x00000000, "0x" . mgBarColor, mgBarHatchStyle) 
		Gdip_FillRoundedRectangle(mgG2, mgBackgroundBrush, 0, 0, mgBarW+2*mgBarBackgroundMargin, mgBarH+2*mgBarBackgroundMargin,mgBarBackgroundRadius)
		Gdip_FillRoundedRectangle(mgG2, mgBarBackBrush, mgBarBackgroundMargin, mgBarBackgroundMargin, mgBarW, mgBarH, mgBarR)
		; Drawing Progress Bar
		If percentage > 100
			percentage := 100
		If(mgBarW*percentage/100<3*mgBarR)	; avoiding glitch in rounded rectangle drawing when they are too small
			currentRBar := mgBarR * ((mgBarW*percentage/100)/(3*mgBarR))
		Else
			currentRBar := mgBarR
		Gdip_TextToGraphics(mgG2, round(percentage) . "%", "x" round(mgBarBackgroundMargin+mgBarW*percentage/100) " y" (mgBarBackgroundMargin-20*mgImageAdjust)//2 . " " . mgBarText1Options, mgFont, 0, 0)
		If percentage < 100
			If (fadeBarInfoText = "true")
				Gdip_TextToGraphics(mgG2, mgBarText1, "x" mgBarBackgroundMargin+mgBarW " y" mgBarBackgroundMargin+mgBarH+(mgBarBackgroundMargin-20*mgImageAdjust)//2 . " " . mgBarText1Options, mgFont, 0, 0)
		Else {	; bar is at 100%
			mgFinishedBar:= 1
			Log("MGProgressBarAnimation - Bar reached 100%",4)
			If (fadeBarInfoText = "true")
				Gdip_TextToGraphics(mgG2, mgBarText2, "x" mgBarBackgroundMargin+mgBarW " y" mgBarBackgroundMargin+mgBarH+(mgBarBackgroundMargin-20*mgImageAdjust)//2 . " " . mgBarText2Options, mgFont, 0, 0)
		}
		Gdip_FillRoundedRectangle(mgG2, mgBarBrush, mgBarBackgroundMargin, mgBarBackgroundMargin, mgBarW*percentage/100, mgBarH,currentRBar)
		UpdateLayeredWindow(MG2_ID, mgHDC2,mgBarX,mgBarY, mgBarW+2*mgBarBackgroundMargin, mgBarH+2*mgBarBackgroundMargin)
		Process, Exist, 7z.exe	; This breaks out of 7z.exe If it's no longer running. Sometimes an extraction was very quick or there was an error and we don't want to be stuck in an infinite Loop
		If !ErrorLevel ; bar is at 100% or 7z is already closed or user interrupted fade, so break out
		{	Log("MGProgressBarAnimation - 7z.exe is no longer running, breaking out of progress loop.",4)
			Break
		}
		If mgFinishedBar
			Break
	}
	SetFormat, Float, %currentFloat%	; restore previous float
	Log("MGProgressBarAnimation - Ended")
Return

MGExit:
	Log("MGExit - Started",4)
	SetTimer,Update, Off
	ToolTip
	XHotKeywrapper(navUpKey,"Forward","Off")
	XHotKeywrapper(navDownKey,"Backward","Off")
	XHotKeywrapper(navLeftKey,"Forward","Off")
	XHotKeywrapper(navRightKey,"Backward","Off")
	XHotKeywrapper(navSelectKey,"SelectGame","Off")
	XHotKeywrapper(navP2UpKey,"Forward","Off")
	XHotKeywrapper(navP2DownKey,"Backward","Off")
	XHotKeywrapper(navP2LeftKey,"Forward","Off")
	XHotKeywrapper(navP2RightKey,"Backward","Off")
	XHotKeywrapper(navP2SelectKey,"SelectGame","Off")
	XHotKeywrapper(mgKey,"MGExit","Off")
	XHotKeywrapper(exitEmulatorKey,"MGExit","Off")
	for index, element in romTable	; for each rom found in the table
		Gdip_DisposeImage(romTable[currentButton,17]), Gdip_DisposeImage(romTable[currentButton,14])
	If mgExitEffect = pixelate
		Gdip_DisposeImage(mgArtOut)
	If forceMGGuiDestroy
		{
		If !disableLoadScreen
			If !disableActivateBlackScreen
				WinActivate, mgBlackScreen
		Loop, 2 {
		Gdip_GraphicsClear(mgG%A_Index%)
		UpdateLayeredWindow(MG%A_Index%_ID, mgHDC%A_Index%, 0, 0, A_ScreenWidth, mgH)
		SelectObject(mgHDC%A_Index%, mgOBM%A_Index%), DeleteObject(mgHBM%A_Index%), DeleteDC(mgHDC%A_Index%)
		Gui, MG_GUI%A_Index%: Destroy
		}
		Gdip_DeleteBrush(mgBackgroundBrush), Gdip_DeleteBrush(mgBarBackBrush), Gdip_DeleteBrush(mgBarBrush)
	}
	Gdip_DeleteBrush(mPBrush)
	Gdip_DeleteBrush(mgBlackScreenBackgroundBrush)
	If !disableSuspendEmu	; Unsuspending Emulator Process 
	{	ProcRes(mgEmuProcessName)
		Log("Emulator process started",4)
	}
	If !disableRestoreEmu		; Restoring emulator
	{	timeout := A_TickCount
		Sleep, 200
		WinRestore, ahk_ID %mgEmuID%
		IfWinNotActive, ahk_class %mgEmuClass%,,Hyperspin
		{	Loop
			{	Sleep, 200
				WinRestore, ahk_ID %mgEmuID%
				Sleep, 200
				WinActivate, ahk_class %mgEmuClass%,,Hyperspin
				IfWinActive, ahk_class %mgEmuClass%,,Hyperspin
					Break
				If (timeout<A_TickCount-3000)
					Break
				Sleep, 200
			}
			Log("Emulator screen reactivated",4)
		}
	}
	Log("MGExit - Restoring emu If module contains a RestoreEmu label.",4)
	Gosub, RestoreEmu
	Log("MGExit - Finished Processing RestoreEmu label.",4)
	MultiGame_EndTime := A_TickCount
	TotalElapsedTimeinPause :=  If TotalElapsedTimeinPause ? TotalElapsedTimeinPause + (MultiGame_EndTime-MultiGame_BeginTime)//1000 : (MultiGame_EndTime-MultiGame_BeginTime)//1000
	If !disableLoadScreen {
		SelectObject(mgBlackScreen_hdc, mgBlackScreen_obm)
		DeleteObject(mgBlackScreen_hbm)
		DeleteDC(mgBlackScreen_hdc)
		Gdip_DeleteGraphics(mgBlackScreen_G)
		Gui, 19: Destroy
	}
	Log("Black Screen Gui destroyed",4)
	XHotKeywrapper(exitEmulatorKey,"CloseProcess","ON")
	XHotKeywrapper(mgKey,"StartMulti","ON")	; turning back on mgKey
	If hpEnabled = true
		XHotKeywrapper(hpKey,"TogglePauseMenuStatus","ON"), On	; turning back on hpKey
	If bezelEnabled = true
	{	Gosub, EnableBezelKeys	; turning on the bezel keys
        if ICRightMenuDraw 
            Gosub, EnableICRightMenuKeys
        if ICLeftMenuDraw
            Gosub, EnableICLeftMenuKeys
        if (bezelBackgroundsList.MaxIndex() > 1)
            if bezelBackgroundChangeDur
                settimer, BezelBackgroundTimer, %bezelBackgroundChangeDur%
	}
   	Log("Enabled exit emulator, bezel, hyperpause and multigame keys",4)
	If (keymapperEnabled = "true") and (keymapperHyperLaunchProfileEnabled = "true") and (keymapper != "ahk") {
		Log("MGExit - Running keymapper to load the proper profile.",4)
		RunKeyMapper%zz%("load",keymapper)	; load correct keymapper profile on exit
	}
	If ((keymapperEnabled = "true") and (keymapperAHKMethod = External))
		RunAHKKeymapper%zz%("load")

	If disableActivateBlackScreen != true	; set this to true in HaltEmu label to disable this GUI
		Gui, 19: Destroy
	IfWinNotActive, ahk_class %mgEmuClass%,,ahk_pid %focusAppOnExit% 	; focusAppOnExit is from HL, the PID is from the FE the user is using. We use this here as to be sure we never give it focus.
		Loop{ 
			WinActivate, ahk_class %mgEmuClass%,,ahk_pid %focusAppOnExit% 
			IfWinActive, ahk_class %mgEmuClass%,,ahk_pid %focusAppOnExit% 
				Break 
			Sleep, 100
		}
	If mgSelectedGame {
		If statisticsEnabled = true
		{	Log("MGExit - Updating Statistics.",4)
			Gosub, UpdateStatistics
		}
        gameSectionStartTime := A_TickCount
		gameSectionStartHour := A_Now
		Log("MGExit - Processing MultiGame label in module.",4)
		Gosub, MultiGame
		Log("MGExit - Finished Processing MultiGame label.",4)
	}
	If !forceMGGuiDestroy
		{
		Loop, 2 {
		Gdip_GraphicsClear(mgG%A_Index%)
		UpdateLayeredWindow(MG%A_Index%_ID, mgHDC%A_Index%, 0, 0, A_ScreenWidth, mgH)
		SelectObject(mgHDC%A_Index%, mgOBM%A_Index%), DeleteObject(mgHBM%A_Index%), DeleteDC(mgHDC%A_Index%)
		Gui, MG_GUI%A_Index%: Destroy
		}
		Gdip_DeleteBrush(mgBackgroundBrush), Gdip_DeleteBrush(mgBarBackBrush), Gdip_DeleteBrush(mgBarBrush)
	}
	Log("MGExit - Ended",4)
Return
