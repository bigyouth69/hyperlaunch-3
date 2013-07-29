MCRC = 31E81191
MVersion=1.0.1

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
	XHotKeywrapper(exitEmulatorKey,"CloseProcess","OFF")	; turning off exitEmulatorKey so user cannot press it while the GUI is loading
	mgW := originalWidth	; MG will use the original width and height of your desktop from when HL started
	mgH := originalHeight
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

	; Create a simple ahk Black Gui which helps avoid flashing to desktop on some PCs when mgKey is pressed. This must remain after the rom table creation otherwise it can unnecessarily disrupt the emu window for no reason.
	Gui, 19: Color, 000000
	Gui, 19: -Caption +ToolWindow
	Gui, 19: Show, x0 y0 W%A_ScreenWidth% H%A_ScreenHeight%, mgBlackScreen
	WinActivate, mgBlackScreen

	; If romExtensionOrig contains %7zFormats%	; Check If our original rom was compressed.
		; If 7zEnabled = true	; Only need to continue If 7z support is turned on, this check is in case emu supports loading of compressed roms. No need to decompress our rom If it does
			; romNeeds7z:=1	; Flag that we need to use 7z to extract the game the user selects from the GUI

	If (keymapperEnabled = "true") and (keymapperHyperLaunchProfileEnabled = "true") and (keymapper != "ahk")
		RunKeyMapper%zz%("menu",keymapper)	; If user desires, load HyperLaunch profile for controllers

	;-----------------------------------------------------------------------------------------------------------------------------------------
	; GDI GUI START
	;-----------------------------------------------------------------------------------------------------------------------------------------
	If !pToken := Gdip_Startup()	; Start gdi+
	{	ScriptError("Gdiplus failed to start. Please ensure you have gdiplus on your system")
		ExitApp
	}

	Log("StartMulti - Halting emu If module contains a HaltEmu label.",4)
	Gosub, HaltEmu
	Log("StartMulti - Finished Processing HaltEmu label.",4)

	Gui, MG_GUI1: New, +HwndMG1_ID +E0x80000 +ToolWindow -Caption +AlwaysOnTop +OwnDialogs, MG Layer 1	; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
	Gui, MG_GUI2: New, +OwnerMG_GUI1 +HwndMG2_ID +E0x80000 +ToolWindow -Caption +AlwaysOnTop +OwnDialogs, MG Layer 2		; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
	Loop, 2 { ; create 2 GUI layers (1 = background, text, image1, 2 = image2 and what is animated)
		Gui, MG_GUI%A_Index%: Show
		hbm%A_Index% := CreateDIBSection(mgW, mgH), hdc%A_Index% := CreateCompatibleDC(), obm%A_Index% := SelectObject(hdc%A_Index%, hbm%A_Index%)
		G%A_Index% := Gdip_GraphicsFromhdc(hdc%A_Index%)
	}
	Gdip_SetInterpolationMode(G1, 7) ; we only want to use interpolation mode for our background as it slows down rotation on the images

	If !hFamily := Gdip_FontFamilyCreate(mgFont)
		ScriptError("The Font " . mgFont . " you have specified does not exist on the system")
	Gdip_DeleteFontFamily(hFamily)	; Delete mgFont family as we now know the mgFont does exist

	;-----------------------------------------------------------------------------------------------------------------------------------------
	; If a background image exists, use it instead of a solid color
	Supported_Images = png,gif,tif,bmp,jpg
	MGBackground := []
    DescriptionNameWithoutDisc := romTable[1,4]
	Log("MultiGame - Scanning for background art in: " . HLMediaPath . "\Backgrounds\",4)
	If FileExist(HLMediaPath . "\Backgrounds\" . systemName . "\"  . dbName . "\*.*")
        Loop, parse, Supported_Images,`,,
		{	Log("MultiGame - Scanning for background art: " . HLMediaPath . "\Backgrounds\" . systemName . "\" . dbName . "\*." . A_LoopField,4)
            Loop, %HLMediaPath%\Backgrounds\%systemName%\%dbName%\*.%A_LoopField%
			{ 	Log("MultiGame - Scanning for background art: " . HLMediaPath . "\Backgrounds\" . systemName . "\" . dbName . "\*." . A_LoopField,4)
                MGBackground.Insert(A_LoopFileFullPath)
			}
		}
    If !MGBackground[1]
        If FileExist(HLMediaPath . "\Backgrounds\" . systemName . "\"  . DescriptionNameWithoutDisc . "\*.*")
            Loop, parse, Supported_Images,`,,
			{	Log("MultiGame - Scanning for background art: " . HLMediaPath . "\Backgrounds\" . systemName . "\" . DescriptionNameWithoutDisc . "\*." . A_LoopField,4)
                Loop, %HLMediaPath%\Backgrounds\%systemName%\%DescriptionNameWithoutDisc%\*.%A_LoopField%
				{ 	Log("MultiGame - Found background art: " . A_LoopFileFullPath,4)
					MGBackground.Insert(A_LoopFileFullPath)
				}
			}
	If !MGBackground[1]
        If FileExist(HLMediaPath . "\Backgrounds\" . systemName . "\_Default\*.*")
            Loop, parse, Supported_Images,`,,
			{ 	Log("MultiGame - Scanning for background art: " . HLMediaPath . "\Backgrounds\" . systemName . "\_Default\*." . A_LoopField,4)
                Loop, %HLMediaPath%\Backgrounds\%systemName%\_Default\*.%A_LoopField%
				{ 	Log("MultiGame - Found background art: " . A_LoopFileFullPath,4)
                    MGBackground.Insert(A_LoopFileFullPath)
				}
			}
    If !MGBackground[1]
        If FileExist(HLMediaPath . "\Backgrounds\_Default\*.*")
            Loop, parse, Supported_Images,`,,
			{ 	Log("MultiGame - Scanning for background art: " . HLMediaPath . "\Backgrounds\_Default\*." . A_LoopField,4)
                Loop, %HLMediaPath%\Backgrounds\_Default\*.%A_LoopField%, 0
				{ 	Log("MultiGame - Found background art: " . A_LoopFileFullPath,4)
                    MGBackground.Insert(A_LoopFileFullPath)
				}
			}
	If MGBackground[1] {
	 	Log("MultiGame - Randomizing found background images.",4)
        Random, RndmBackground, 1, % MGBackground.MaxIndex()
        multiBG := MGBackground[RndmBackground]
		Log("MultiGame - Using background art: " . multiBG,4)
    }
	Loop, 2 {	; Load our 2 files into variables for easy calling later
        If FileExist(HLMediaPath . "\MultiGame\" . systemName . "\" . dbName . "\" . romTable[A_Index,6] . "_image_" . A_Index . ".png") 
            Image_%A_Index% := HLMediaPath . "\MultiGame\" . systemName . "\" . dbName . "\" . romTable[A_Index,6] . "_image_" . A_Index . ".png"
        Else If FileExist(HLMediaPath . "\MultiGame\" . systemName . "\" . DescriptionNameWithoutDisc . "\" . romTable[A_Index,6] . "_image_" . A_Index . ".png") 
            Image_%A_Index% := HLMediaPath . "\MultiGame\" . systemName . "\" . DescriptionNameWithoutDisc . "\" . romTable[A_Index,6] . "_image_" . A_Index . ".png"
        Else If FileExist(HLMediaPath . "\MultiGame\" . systemName . "\" . _Default . "\" . romTable[A_Index,6] . "_image_" . A_Index . ".png") 
            Image_%A_Index% := HLMediaPath . "\MultiGame\" . systemName . "\" . _Default . "\" . romTable[A_Index,6] . "_image_" . A_Index . ".png"
        Else If FileExist(HLMediaPath . "\MultiGame\_Default\" . romTable[A_Index,6] . "_image_" . A_Index . ".png") 
            Image_%A_Index% := HLMediaPath . "\MultiGame\_Default\" . romTable[A_Index,6] . "_image_" . A_Index . ".png"   
		Else {
			ToolTip, Downloading Image %A_Index%,0,0
			IfNotExist, %  HLMediaPath . "\MultiGame\_Default\"
				FileCreateDir, %  HLMediaPath . "\MultiGame\_Default\" ; Need to create the folder first otherwise urldownload will fail
			UrlDownloadToFile, % "http://www.hyperspin-fe.com/HL2/" . romTable[A_Index,6] . "_image_" . A_Index . ".png", %  HLMediaPath . "\MultiGame\_Default\" . romTable[A_Index,6] . "_image_" . A_Index . ".png"
			If ErrorLevel
				ScriptError("Error connecting to www.hyperspin-fe.com to download images. Please try again later or report the problem If it persists.")
			Else
				Image_%A_Index% := HLMediaPath . "\MultiGame\_Default\" . romTable[A_Index,6] . "_image_" . A_Index . ".png"  
		}
    }    
    for index, element in romTable	; for each rom found in the table
	{
		If FileExist(frontendPath . "\Media\" . systemName . "\Images\" . mgArtworkDir . "\" . romTable[A_Index, 3] . ".png") && (mgUseGameArt = "true" ) {
			Log("MultiGame - Using game art: " . frontendPath . "\Media\" . systemName . "\Images\" . mgArtworkDir . "\" . romTable[A_Index, 3] . ".png",4)
			romTable[A_Index, 17] := Gdip_CreateBitmapFromFile(frontendPath . "\Media\" . systemName . "\Images\" . mgArtworkDir . "\" . romTable[A_Index, 3] . ".png")	; store pointer to artwork in column 13
			If !romTable[A_Index, 17] {
				ScriptError("Error Loading MultiGame Artwork " . A_Index . "`, Could not find " .  romTable[A_Index,3] . ".png. Please try again later or report the problem If it persists.")
				Goto, MGExit
			}
			romTable[A_Index, 16] := "Yes"	; Column 16 contains Yes If artwork was found for current Disc
		} Else {
			romTable[A_Index, 17] := Gdip_CreateBitmapFromFile(Image_1)	; If user doesn't have mediatype art for this game or has mgUseGameArt turned off, load the default instead and store pointer to Image_1 in column 17
			romTable[A_Index, 18] := Gdip_CreateBitmapFromFile(Image_2)	; Also have to load the highlighted image_2 and store its pointer in column 18
		}
		Gdip_GetImageDimensions(romTable[A_Index, 17], mgArtW, mgArtH)	; get the width and height of the image
		romTable[A_Index,12] := mgArtW, romTable[A_Index,13] := mgArtH	; recording each images original width in column 12 and original height in column 13
		romTable[A_Index,14] := romTable[A_Index,12]*mgImageAdjust, romTable[A_Index, 15] := romTable[A_Index,13]*mgImageAdjust	; recording each images adjusted width in column 14 and adjusted height in column 15
		If mgSelectedEffect = rotate
		{	Gdip_GetRotatedDimensions(romTable[A_Index, 14], romTable[A_Index, 15], 90, mgRW%A_Index%, mgRH%A_Index%)	; getting rotated dimensions of the images and storing them in the mgRW vars
			mgRW%A_Index% := (mgRW%A_Index% > romTable[A_Index, 14]) ? mgRW%A_Index%* : romTable[A_Index, 14], mgRH%A_Index% := (mgRH%A_Index% > romTable[A_Index, 15]) ? mgRH%A_Index% : romTable[A_Index, 15]
		}
	}

	totalUnusedWidth := mgW - ( romTable[1,14] * romTable.MaxIndex() )	; calculate the width of the screen not being used by the adjusted width of the images
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
		Gdip_DrawImage(G1, mBGBitmap, 0, 0, mgW+1, mgH+1, 0, 0, mBGw, mBGh)	; draw background image onto screen on layer 1
	} Else {
		mPBrush := Gdip_BrushCreateSolid("0x" . mgBackgroundColor)						; Painting the background color
		Gdip_FillRectangle(G1, mPBrush, -1, -1, mgW+1, mgH+1)										; draw the background first on layer 1, layer order matters!!
	}

	Gdip_TextToGraphics(G1, mgText1Text, mgText1Options, mgFont, mgW, mgH)					; set screen text in middle on layer 1

	; This loops places each image_1 evenly across the screen and the text to go along with each image. It also creates a button control so each image is selectable.
	for index, element in romTable {
		romTable[A_Index,10] := (If romTable[A_Index, 16] ? (imageXcurrent) : (imageXcurrent+(romTable[1,14]//2-romTable[A_Index,14]//2)))	; storing the X position of the image in column 6. If no art is found, the default art's X is adjusted to fit in the middle of  the width of the missing art's width (aka centering the default image)
		romTable[A_Index,11] := mgH - mgYOffset	; storing the Y position of the image in column 7
		Gdip_DrawImage(G1, romTable[A_Index, 17], romTable[A_Index,10], mgH - mgYOffset, romTable[1,14], romTable[A_Index, 15], 0, 0, romTable[1,14]//mgImageAdjust, romTable[A_Index, 15]//mgImageAdjust) ; draw each mgArt or default mgArt1 onto screen on layer 1
		Gdip_TextToGraphics(G1, romTable[A_Index,5], "x" . imageXcurrent . " y" . mgH-mgYOffset-mgText2Offset . " " . mgText2Options, mgFont, romTable[1,14], romTable[A_Index, 15]) ; place the text from the table in column 3 above each mgArt to describe it on layer 1
		mgArt%A_Index%X := imageXcurrent
		If ( A_index <= paddingSpotsNeeded ) ; only need to adjust imageXcurrent on loops that we are adding another image next loop through
			imageXcurrent:=imageXcurrent+ romTable[1,14]+imageSpacing
	}

	UpdateLayeredWindow(MG1_ID, hdc1, 0, 0, mgW, mgH)
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
		Gdip_GraphicsClear(G2)
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
		Gdip_GraphicsClear(G2)
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
	Gdip_GraphicsClear(G2)
	If (mgSelectedEffect = "rotate" && romTable[currentButton,16]) {	; If current button has artwork
		angle := (angle > 360) ? 2 : angle+2
		Gdip_ResetWorldTransform(G2)
		Gdip_TranslateWorldTransform(G2, mgRW%currentButton%//2, mgRH%currentButton%//2)
		Gdip_RotateWorldTransform(G2, angle)
		Gdip_TranslateWorldTransform(G2, -mgRW%currentButton%//2, -mgRH%currentButton%//2)
		Gdip_DrawImage(G2, romTable[currentButton,17], (mgRW%currentButton%-romTable[currentButton,14]), (mgRH%currentButton%-romTable[currentButton,15]), romTable[currentButton,14], romTable[currentButton,15])
		UpdateLayeredWindow(MG2_ID, hdc2, romTable[currentButton,10]-1, romTable[currentButton,11]-1, mgRW%currentButton%, mgRH%currentButton%)	; small adjustment to keep images exactly on layer 1 images
		Return
	} Else If (mgSelectedEffect = "rotate" && !romTable[currentButton,16]) {	; If current button has no artwork
		Gdip_ResetWorldTransform(G2)
		Gdip_DrawImage(G2, romTable[currentButton,18], romTable[currentButton,10],  romTable[currentButton,11], romTable[currentButton,14], romTable[currentButton,15], 0, 0, romTable[currentButton,14]//mgImageAdjust, romTable[currentButton,15]//mgImageAdjust) ; draw Image_2 on top of Image_1
	} Else If (mgSelectedEffect = "grow") {
		Sleep, 5	; required otherwise this loop moves too fast and grow animations don't occur
		If !mgGrowing
			SetTimer, MGGrow, -1	; launch MGGrow once
		Return
	}
	UpdateLayeredWindow(MG2_ID, hdc2, 0, 0, mgW, mgH)
Return

MGGrow:
	Log("MGGrow - Started",4)
	mgGrowing:=1
	While b <= 30 {	; grow image by 30 pixels
		Gdip_DrawImage(G2, (If romTable[currentButton,16] ? (romTable[currentButton,17]):(romTable[currentButton,18])), romTable[currentButton,10]-(b//2),  romTable[currentButton,11]-(b//2), romTable[currentButton,14]+b, romTable[currentButton,15]+b, 0, 0, romTable[currentButton,14]//mgImageAdjust, romTable[currentButton,15]//mgImageAdjust) ; grow Image slightly and highlight If default image used
		UpdateLayeredWindow(MG2_ID, hdc2, 0, 0, mgW, mgH)
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
	Log("SelectGame - Started",4)
	SetTimer,Update, Off ; turning off timer, otherwise it resets the mgExitEffect during its loop
	mgLastGame := If !selectedRom ? dbName : selectedRom	; fill this var so we can track what game we were running before
	If mgExitEffect {
		v := 1
		b+=2
		If mgSelectedEffect = rotate
		{
			Gdip_GraphicsClear(G2)
			Gdip_ResetWorldTransform(G2)
			UpdateLayeredWindow(MG2_ID, hdc2, 0, 0, mgW, mgH)
		}
		Loop, 25 {
			If mgExitEffect = pixelate
			{
				mgArtOut := Gdip_CreateBitmap(romTable[currentButton,14]//mgImageAdjust, romTable[currentButton,15]//mgImageAdjust)
				If romTable[currentButton,16] {	; If current button has artwork and not default image
					Gdip_PixelateBitmap(romTable[currentButton,17], mgArtOut,++v)
					Gdip_DrawImage(G2, mgArtOut, romTable[currentButton,10]-(b//2), romTable[currentButton,11]-(b//2), romTable[currentButton,14]+b, romTable[currentButton,15]+b) ;, 0, 0, romTable[currentButton,14]//mgImageAdjust, romTable[currentButton,15]//mgImageAdjust)
				} Else {
					Gdip_PixelateBitmap(romTable[currentButton,18], mgArtOut,++v)
					Gdip_DrawImage(G2, mgArtOut, romTable[currentButton,10], romTable[currentButton,11], romTable[currentButton,14], romTable[currentButton,15], 0, 0, romTable[currentButton,14]//mgImageAdjust, romTable[currentButton,15]//mgImageAdjust)
				}
			} Else If mgExitEffect = grow
			{
				Gdip_DrawImage(G2, (If romTable[currentButton,16] ? (romTable[currentButton,17]):(romTable[currentButton,18])), romTable[currentButton,10]-(b//2)-(v//2), romTable[currentButton,11]-(b//2)-(v//2), romTable[currentButton,14]+b+v, romTable[currentButton,15]+b+v, 0, 0, romTable[currentButton,14]//mgImageAdjust, romTable[currentButton,15]//mgImageAdjust)
			}
			UpdateLayeredWindow(MG2_ID, hdc2)
			v+=2
		}
	}
	selectedRom:=romTable[currentButton,1] ; need to convert this for the next line to work
	Log("SelectGame - User selected to load: " . selectedRom,4)
	SplitPath, selectedRom,,mgRomPath,mgRomExt,mgDbName
	mgRomExt := "." . mgRomExt	; need to add the period back in otherwise ByRef on the 7z call doesn't work
	If 7zEnabled = true	; Only need to continue If 7z support is turned on, this check is in case emu supports loading of compressed roms. No need to decompress our rom If it does
		If mgRomExt in %7zFormats%	; Check If our selected rom is compressed.
		{	Log("SelectGame - This game needs 7z to load. Sending it off for extraction.",4)
			7z%currentButton% := 7z(mgRomPath, mgDbName, mgRomExt, 7zExtractPath)	; Send chosen game to 7z for processing. We get back the same vars but updated to the new location.
			selectedRom := mgRomPath . "\" . mgDbName . mgRomExt
			Log("SelectGame - Returned from 7z extraction, path to new rom is: " . selectedRom,4)
			romTable[currentButton,19] := mgRomPath	; storing path to extracted rom in column 19 so 7zCleanUp knows to del it later
			Log("SelectGame - Stored """ . mgRomPath . """ for deletion in 7zCleanup.",4)
		} Else
			Log("SelectGame - This game does not need 7z. Sending it directly to the emu or to Daemon Tools If required.",4)
		
	mgSelectedGame = 1	; filling var so we know user selected a game
	Log("SelectGame - Ended",4)
	Goto, MGExit

MGExit:
	Log("MGExit - Started",4)
	SetTimer,Update, Off
	ToolTip
	Gdip_DeleteBrush(mPBrush)
	for index, element in romTable	; for each rom found in the table
		Gdip_DisposeImage(romTable[currentButton,17]), Gdip_DisposeImage(romTable[currentButton,14])
	If mgExitEffect = pixelate
		Gdip_DisposeImage(mgArtOut)
	Loop, 2 {
		Gdip_GraphicsClear(G%A_Index%)
		UpdateLayeredWindow(MG%A_Index%_ID, hdc%A_Index%, 0, 0, mgW, mgH)
		SelectObject(hdc%A_Index%, obm%A_Index%), DeleteObject(hbm%A_Index%), DeleteDC(hdc%A_Index%)
		Gui, MG_GUI%A_Index%: Destroy
	}
	Gdip_Shutdown(pToken)	; gdi+ may now be shutdown on exiting the program
	Log("MGExit - Waiting 1 second to allow MG to shut down and prevent user from breaking the GUI.",4)
	Sleep, 1000	; attempt  to prevent user from breaking the GUI by spamming the mgKey and exiting

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
	XHotKeywrapper(exitEmulatorKey,"CloseProcess","ON")
	XHotKeywrapper(mgKey,"StartMulti","ON")	; turning back on mgKey

	If hpEnabled = true
		XHotKeywrapper(hpKey,"TogglePauseMenuStatus","ON"), On	; turning back on hpKey
	If (keymapperEnabled = "true") and (keymapperHyperLaunchProfileEnabled = "true") and (keymapper != "ahk") {
		Log("MGExit - Running keymapper to load the proper profile.",4)
		RunKeyMapper%zz%("load",keymapper)	; load correct keymapper profile on exit
	}
	Log("MGExit - Restoring emu If module contains a RestoreEmu label.",4)
	Gosub, RestoreEmu
	Log("MGExit - Finished Processing RestoreEmu label.",4)
	Gui, 19: Destroy
	IfWinNotActive, ahk_class %mgEmuClass%,,ahk_pid %focusAppOnExit% 	; focusAppOnExit is from HL, the PID is from the FE the user is using. We use this here as to be sure we never give it focus.
		Loop{ 
			WinActivate, ahk_class %mgEmuClass%,,ahk_pid %focusAppOnExit% 
			IfWinActive, ahk_class %mgEmuClass%,,ahk_pid %focusAppOnExit% 
				Break 
			Sleep, 100
		}
	MultiGame_EndTime := A_TickCount
	TotalElapsedTimeinPause :=  If TotalElapsedTimeinPause ? TotalElapsedTimeinPause + (MultiGame_EndTime-MultiGame_BeginTime)//1000 : (MultiGame_EndTime-MultiGame_BeginTime)//1000
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
	Log("MGExit - Ended",4)
Return
