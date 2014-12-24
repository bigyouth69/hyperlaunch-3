MCRC=6342D186
MVersion=1.0.3

CreateRomMappingLaunchMenu(table){
	Global
	Log("CreateRomMappingLaunchMenu - Started")
	;Creating Menu Full List and Filtered List
	menuGameList := [] ; list of games to be shown on rom mapping launch menu
	menuFilteredGameList := [] ; list of filtered games to be shown on rom mapping launch menu
	currentGameInfo := [] 
	;cheking for dbname rom existence
	Log("CreateRomMappingLaunchMenu - Checking if dbName rom exists",5)
	IniRead, showInfo, % table[1,1],General,showInfo, Cloneof|Crc|Manufacturer|Year|Genre|Rating|HistoryDatDescription|HistoryDatTechnical|HistoryDatTrivia|HistoryDatSeries|HistoryDatSources|HighScores
	showInfo := "|" . showInfo . "|"
	Loop, Parse,  romPathFromIni, |
	{	If romFound	; break out of the first Loop, If rom was found in the 2nd
			Break
		tempRomPath := A_LoopField	; assigning this to a var so it can be accessed in the next Loop
		Loop, Parse, romExtensions, |
		{	Log("CreateRomMappingLaunchMenu - Looking for rom: " . tempRomPath . "\" . dbName . "." . A_LoopField,5)
			IfExist %tempRomPath%\%dbName%.%A_LoopField%
			{	menuGameList[1,2] := tempRomPath . "\" . dbName . "." . A_LoopField
				currentGameInfo := createFrontEndTable(dbName,gameInfo)
				menuGameList[1,1] := currentGameInfo[1,2,1] ; Game Title
				menuGameList[1,5] := gameinfotext()
				Log("CreateRomMappingLaunchMenu - Adding database game to the rom mapping menu list located on: " .  menuGameList[1,2] . " with the file name: " menuGameList[1,1] ,2)
				countAltGame := 1
				romFound := 1
				Break
			}Else{
				Log("CreateRomMappingLaunchMenu - Looking for rom: " . tempRomPath . "\" . dbName . "\" . dbName . "." . A_LoopField,5)
				IfExist %tempRomPath%\%dbName%\%dbName%.%A_LoopField%
				{	menuGameList[1,2] = tempRomPath . "\" . dbName . "\" . dbName "." . A_LoopField
					currentGameInfo := createFrontEndTable(dbName,gameInfo)
					menuGameList[1,1] := currentGameInfo[1,2,1] ; Game Title
					menuGameList[1,5] := gameinfotext()
					Log("CreateRomMappingLaunchMenu - Adding database game to the rom mapping menu list located on: " .  menuGameList[1,2] . " with the file name: " menuGameList[1,1] ,2)
					countAltGame := 1
					romFound := 1
					Break	   
				}Else{
					romFound :=
				}
			}
		}
	}
	; adding ini defined rom mappings  
	Log("CreateRomMappingLaunchMenu - Adding any ini-defined rom mappings",5)
	;creating the regExExpresion to remove the extension from the rom name if represent
	regexEndExtension := % "|" . romExtensions . "|"
	StringReplace, regexEndExtension, regexEndExtension, |, % "$|\.", All
	regexEndExtension := "i)" SubStr(regexEndExtension, 1, -3)
	;adding rom mapped roms to the rom map menu table
	for index, element in table
		{
		currentItem := A_Index
		currentIniPath := table[currentItem,1]
		currentFilePath := table[currentItem,2]
		SplitPath, currentFilePath, , , , currentFile
		IniRead,namingConvention, %currentIniPath%,General,Name_Schema, %A_Space%
		IniRead, showInfo, %currentIniPath%,General,showInfo, Cloneof|Crc|Manufacturer|Year|Genre|Rating|HistoryDatDescription|HistoryDatTechnical|HistoryDatTrivia|HistoryDatSeries|HistoryDatSources|HighScores
		showInfo := "|" . showInfo . "|"
		If namingConvention
			LoadMappingIniExtraInfo() 
		Loop
			{			
			countAltGame++
			menuGameList[countAltGame,2] := table[currentItem,2] ;7z game path
			If !table[currentItem,A_Index+2]
				menuGameList[countAltGame,3] := table[currentItem,2] ;game
			Else
				menuGameList[countAltGame,3] := table[currentItem,A_Index+2] ;game
			menuGameList[countAltGame,3]:=RegExReplace(menuGameList[countAltGame,3],"^\s+|\s+$")  ; remove leading and trailing
			currentAltFilePath := menuGameList[countAltGame,3]
			if InStr(currentAltFilePath, "\")
				SplitPath, currentAltFilePath, , , , currentAltFile
			else
				currentAltFile := RegExReplace(currentAltFilePath, regexEndExtension)
			If (namingConvention="Tosec") {
				;create normal game list
				currentGameInfo := createTosecTable(currentAltFile)
				menuGameList[countAltGame,1] := currentGameInfo[1,2,1] ; Game Title
				menuGameList[countAltGame,4] := "Tosec"
				;create filtered game list
				If FilterPass("tosec")	
					{
					countFilteredGame++
					menuFilteredGameList[countFilteredGame,1] := menuGameList[countAltGame,1]
					menuFilteredGameList[countFilteredGame,2] := menuGameList[countAltGame,2]					
					menuFilteredGameList[countFilteredGame,3] := menuGameList[countAltGame,3]
					menuFilteredGameList[countFilteredGame,4] := menuGameList[countAltGame,4]
				}
			} Else If (namingConvention="NoIntro") {
				;create normal game list
				currentGameInfo := createNoIntroTable(currentAltFile)
				menuGameList[countAltGame,1] := currentGameInfo[1,2,1] ; Game Title
				menuGameList[countAltGame,4] := "NoIntro"
				;create filtered game list
				If FilterPass("NoIntro")	
					{
					countFilteredGame++	
					menuFilteredGameList[countFilteredGame,1] := menuGameList[countAltGame,1]		
					menuFilteredGameList[countFilteredGame,2] := menuGameList[countAltGame,2]					
					menuFilteredGameList[countFilteredGame,3] := menuGameList[countAltGame,3]
					menuFilteredGameList[countFilteredGame,4] := menuGameList[countAltGame,4]
				}
			} Else if (namingConvention="FrontendDatabase") {
				currentGameInfo := createFrontEndTable(currentAltFile)
				menuGameList[countAltGame,1] := currentGameInfo[1,2,1] ; Game Title
				menuGameList[countAltGame,4] := "FrontendDatabase"
			} Else {
				;create normal game list
				menuGameList[countAltGame,1] := currentAltFile ; Game Title
				menuGameList[countAltGame,4] := "NoFilter"
				menuGameList[countAltGame,5] := "Name = " . currentAltFile
			}
			Log("CreateRomMappingLaunchMenu - Adding database game to the rom mapping menu list located on: " .  menuGameList[countAltGame,2] . " with the file name: " menuGameList[countAltGame,3] ,2)
			If !table[currentItem,A_Index+3]
				break
		}
	}
	; Returning if only one rom is found
	If (menuGameList.MaxIndex()=1) {
		Log("CreateRomMappingLaunchMenu - Skipping Rom Map Menu because there was only one selection on the menu.")
		Return
	}
	If (romMappingSingleFilteredRomAutomaticLaunch="true")
		If (menuFilteredGameList.MaxIndex()=1)
			gosub, SelectRom
	;initializing gdi plus
	If !pToken
		pToken := Gdip_Startup()
	; Creating Menu GUIs
	Gdip_Alt_GetRotatedDimensions(A_ScreenWidth, A_ScreenHeight, screenRotationAngle, baseScreenWidth, baseScreenHeight)
	Gdip_GetRotatedTranslation(baseScreenWidth, baseScreenHeight, screenRotationAngle, xTranslation, yTranslation)
	xTranslation:=round(xTranslation), yTranslation:=round(yTranslation)
	Loop, 4 { 
        CurrentGUI := A_Index
        If (A_Index=1)
			Gui, RomSelect_GUI%CurrentGUI%: -Caption +E0x80000 +OwnDialogs +LastFound +ToolWindow +AlwaysOnTop 
		Else {
			OwnerGUI := CurrentGUI - 1
			Gui, RomSelect_GUI%CurrentGUI%: +OwnerRomSelect_GUI%OwnerGUI% -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop
		}
		Gui, RomSelect_GUI%CurrentGUI%: Margin,0,0
		Gui, RomSelect_GUI%CurrentGUI%: Show,, RomSelect_Layer%CurrentGUI%
		RomSelect_hwnd%CurrentGUI% := WinExist()
		RomSelect_hbm%CurrentGUI% := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
		RomSelect_hdc%CurrentGUI% := CreateCompatibleDC()
		RomSelect_obm%CurrentGUI% := SelectObject(RomSelect_hdc%CurrentGUI%, RomSelect_hbm%CurrentGUI%)
		RomSelect_G%CurrentGUI% := Gdip_GraphicsFromhdc(RomSelect_hdc%CurrentGUI%)
		Gdip_SetSmoothingMode(RomSelect_G%CurrentGUI%, 4)
		Gdip_TranslateWorldTransform(RomSelect_G%CurrentGUI%, xTranslation, yTranslation)
		Gdip_RotateWorldTransform(RomSelect_G%CurrentGUI%, screenRotationAngle)
	}
	pGraphUpd(RomSelect_G1,baseScreenWidth,baseScreenHeight)
	pGraphUpd(RomSelect_G2,baseScreenWidth,baseScreenHeight)
	;Setting Scale Res Factors
	XBaseRes := 1920, YBaseRes := 1080
    if (((A_screenWidth < A_screenHeight) and ((screenRotationAngle=0) or (screenRotationAngle=180))) or ((A_screenWidth > A_screenHeight) and ((screenRotationAngle=90) or (screenRotationAngle=270))))
        XBaseRes := 1080, YBaseRes := 1920
    if !romMappingXScale 
		romMappingXScale := baseScreenWidth/XBaseRes
    if !romMappingYScale
		romMappingYScale := baseScreenHeight/YBaseRes
	;Resizing Menu items
	TextOptionScale(romMappingTextOptions, romMappingXScale,romMappingYScale)
	OptionScale(romMappingMenuWidth, romMappingXScale)
	OptionScale(romMappingMenuMargin, romMappingXScale)
	OptionScale(romMappingTextSizeDifference, romMappingXScale)
	OptionScale(romMappingTextMargin, romMappingXScale)
	OptionScale(romMappingMenuFlagWidth, romMappingXScale)
	OptionScale(romMappingMenuFlagSeparation, romMappingXScale)
	;Parsing text color and size
	RegExMatch(romMappingTextOptions,"i)c[a-zA-Z0-9]+",romMappingSelectTextColor)
	StringTrimLeft, romMappingSelectTextColor, romMappingSelectTextColor, 1
	RegExMatch(romMappingTextOptions,"i)s[0-9]+",romMappingTextSize)
	StringTrimLeft, romMappingTextSize, romMappingTextSize, 1
	RegExMatch(romMappingTitleTextOptions,"i)s[0-9]+",romMappingTitleTextSize)
	StringTrimLeft, romMappingTitleTextSize, romMappingTitleTextSize, 1
	RegExMatch(romMappingGameInfoTextOptions,"i)s[0-9]+",romMappingGameInfoTextSize)
	StringTrimLeft, romMappingGameInfoTextSize, romMappingGameInfoTextSize, 1
	RegExMatch(romMappingTitle2TextOptions,"i)s[0-9]+",romMappingTitle2TextSize)
	StringTrimLeft, romMappingTitle2TextSize, romMappingTitle2TextSize, 1
	;hardcoded options
	romMappingButtonCornerRadius := 15
	romMappingButtonCornerRadius2 := 15
	romMappingButtonBrushW := 800
	romMappingButtonBrushH := 225
	OptionScale(romMappingButtonCornerRadius, romMappingXScale)
	OptionScale(romMappingButtonCornerRadius2, romMappingXScale)
	OptionScale(romMappingButtonBrushW, romMappingXScale)
	OptionScale(romMappingButtonBrushH, romMappingYScale)
	pGraphUpd(RomSelect_G3,romMappingMenuWidth,baseScreenHeight)
	pGraphUpd(RomSelect_G4,romMappingMenuWidth-2*romMappingTextMargin,romMappingTextSize)
	;Drawing Menu
	currentSelectedRom := 1
	VDistBtwRomNames := baseScreenHeight//(romMappingNumberOfGamesByScreen+1)
	romMappingBackgroundBrush := Gdip_BrushCreateSolid("0x" . romMappingBackgroundBrush)	
	romMappingButtonBrush1 := Gdip_CreateLineBrushFromRect(0, 0, romMappingButtonBrushW, romMappingButtonBrushH, "0x" . romMappingButtonBrush1, "0x" . romMappingButtonBrush1)
	romMappingButtonBrush2 := Gdip_CreatePen("0x" . romMappingButtonBrush2, romMappingButtonCornerRadius2)
	romMappingColumnBrush1 := Gdip_BrushCreateSolid("0x" . romMappingColumnBrush)
	StringTrimLeft, romMappingColumnBrushTransp, romMappingColumnBrush, 2
	romMappingColumnBrush2 := Gdip_CreateLineBrushFromRect(0, 0, romMappingMenuWidth, (baseScreenHeight-(VDistBtwRomNames*romMappingNumberOfGamesByScreen))//2, "0x00" . romMappingColumnBrushTransp, "0x" . romMappingColumnBrush)
	romMappingColumnBrush3 := Gdip_CreateLineBrushFromRect(0, 0, romMappingMenuWidth, (baseScreenHeight-(VDistBtwRomNames*romMappingNumberOfGamesByScreen))//2, "0x00" . romMappingColumnBrushTransp, "0x" . romMappingColumnBrush)
	;loading background image paths
    Supported_Images = png,gif,tif,bmp,jpg
	romMappingBackground := []
	If !IsObject(romTable)
	{	Log("CreateRomMappingLaunchMenu - romTable does not exist, creating one for """ . dbName . """",5)
		romTable := CreateRomTable(dbName)
	}
    DescriptionNameWithoutDisc := romTable[1,4]
	; Search for Background Artwork
    If FileExist(HLMediaPath . "\Backgrounds\" . systemName . "\"  . dbName . "\*.*")
        Loop, parse, Supported_Images,`,,
            Loop, % HLMediaPath . "\Backgrounds\" . systemName . "\"  . dbName . "\*." . A_LoopField
                romMappingBackground.Insert(A_LoopFileFullPath)
    If !romMappingBackground[1]
        If FileExist(HLMediaPath . "\Backgrounds\" . systemName . "\"  . DescriptionNameWithoutDisc . "\*.*")
            Loop, parse, Supported_Images,`,,
                Loop, % HLMediaPath . "\Backgrounds\" . systemName . "\"  . DescriptionNameWithoutDisc . "\*." . A_LoopField
                    romMappingBackground.Insert(A_LoopFileFullPath)
    If !romMappingBackground[1]
    {
        for index, element in feMedia["Backgrounds"]
        {   if element.Label
            {   if (element.AssetType="game")
                {   loop, % element.TotalItems    
                    {    romMappingBackground.Insert(element["Path" . a_index])
                    }
                }
            }
        }
    }
    If !romMappingBackground[1]
        If FileExist(HLMediaPath . "\Backgrounds\" . systemName . "\_Default\*.*")
            Loop, parse, Supported_Images,`,,
                Loop, % HLMediaPath . "\Backgrounds\" . systemName . "\_Default\*." . A_LoopField
                    romMappingBackground.Insert(A_LoopFileFullPath)
    If !romMappingBackground[1]
    {
        for index, element in feMedia["Backgrounds"]
        {   if element.Label
            {   if (element.AssetType="system")
                {   loop, % element.TotalItems    
                    {    romMappingBackground.Insert(element["Path" . a_index])
                    }
                }
            }
        }
    }
    If !romMappingBackground[1]
        If FileExist(HLMediaPath . "\Backgrounds\" . "_Default\*.*")
            Loop, parse, Supported_Images,`,,
                Loop, % HLMediaPath . "\Backgrounds\" . "_Default\*." . A_LoopField, 0
                    romMappingBackground.Insert(A_LoopFileFullPath)
	;Drawing Background Image
	If romMappingBackground[1] {
        Random, RndmBackground, 1, % romMappingBackground.MaxIndex()
        romMappingBG := romMappingBackground[RndmBackground]
		romMappingBGBitmap := Gdip_CreateBitmapFromFile(romMappingBG)
        Gdip_GetImageDimensions(romMappingBGBitmap, BitmapW, BitmapH)
        GetBGPicPosition(romMappingBGPicXNew,romMappingBGYNew,romMappingBGWNew,romMappingBGHNew,BitmapW,BitmapH,romMappingBackgroundAlign)	; get the background pic's new position and size
        If (romMappingBackgroundAlign = "Stretch and Lose Aspect") {	 
            Gdip_Alt_DrawImage(RomSelect_G1, romMappingBGBitmap, 0, 0, baseScreenWidth+1, baseScreenHeight+1, 0, 0, BitmapW, BitmapH)
        } Else If (romMappingBackgroundAlign = "Stretch and Keep Aspect" Or romMappingBackgroundAlign = "Center Width" Or romMappingBackgroundAlign = "Center Height" Or romMappingBackgroundAlign = "Align to Bottom Left" Or romMappingBackgroundAlign = "Align to Bottom Right") {
            Gdip_Alt_DrawImage(RomSelect_G1, romMappingBGBitmap, romMappingBGPicXNew, romMappingBGYNew, romMappingBGWNew+1, romMappingBGHNew+1, 0, 0, BitmapW, BitmapH)
        } Else If (romMappingBackgroundAlign = "Center") {	; original image size and aspect
            Gdip_Alt_DrawImage(RomSelect_G1, romMappingBGBitmap, romMappingBGPicXNew, romMappingBGYNew, BitmapW+1, BitmapH+1, 0, 0, BitmapW, BitmapH)
        } Else If (romMappingBackgroundAlign = "Align to Top Right") {	; place the pic so the top right corner matches the screen's top right corner
            Gdip_Alt_DrawImage(RomSelect_G1, romMappingBGBitmap, romMappingBGPicXNew, 0,romMappingBGWNew+1,romMappingBGHNew, 0, 0, BitmapW, BitmapH)
        } Else {	; place the pic so the top left corner matches the screen's top left corner, also the default
            Gdip_Alt_DrawImage(RomSelect_G1, romMappingBGBitmap, 0, 0,romMappingBGWNew+10,romMappingBGHNew+1, 0, 0, BitmapW, BitmapH)
        }
    }	
	;Drawing Background Brush
	Gdip_Alt_FillRectangle(RomSelect_G1, romMappingBackgroundBrush, 0, 0, baseScreenWidth, baseScreenHeight)
	;Drawing Title Text
	TitleTextOption := "x" . romMappingMenuMargin . " y" . baseScreenHeight-romMappingMenuMargin-romMappingTitleTextSize-2*romMappingTitle2TextSize . " Left " . romMappingTitleTextOptions
	Gdip_Alt_TextToGraphics(RomSelect_G1, "CHOOSE YOUR GAME!!!", TitleTextOption, romMappingTitleTextFont, 0, 0)
	mapStartTime := A_TickCount
	Loop{	; fading in the launch menu
		tMap := ((mapTimeElapsed := A_TickCount-mapStartTime) < fadeInDuration) ? 255*(mapTimeElapsed/fadeInDuration) : 255
		Alt_UpdateLayeredWindow(RomSelect_hwnd1, RomSelect_hdc1, 0, 0, baseScreenWidth, baseScreenHeight, tMap)	; to fade in, set transparency to 0 at first
		If tMap >= 255
			Break
	}
	;Setting current showed list
	currentRomMappingMenuList := []
	currentRomMappingMenuList := menuGameList
	If menuFilteredGameList.MaxIndex()
		If (romMappingDefaultMenuList = "FilteredList")
			If (menuFilteredGameList.MaxIndex()<>menuGameList.MaxIndex())
				currentRomMappingMenuList := menuFilteredGameList
	drawnRomSelectColumn()
	;Enabling Hotkeys
	XHotKeywrapper(navSelectKey,"SelectRom","ON")
	XHotKeywrapper(navUpKey,"SelectRomMenuMoveUp","ON")
	XHotKeywrapper(navDownKey,"SelectRomMenuMoveDown","ON")
	XHotKeywrapper(navLeftKey,"toggleList","ON")
	XHotKeywrapper(navRightKey,"toggleList","ON")
    XHotKeywrapper(navP2SelectKey,"SelectRom","ON") 
    XHotKeywrapper(navP2UpKey,"SelectRomMenuMoveUp","ON")
    XHotKeywrapper(navP2DownKey,"SelectRomMenuMoveDown","ON")
	XHotKeywrapper(navP2LeftKey,"toggleList","ON")
    XHotKeywrapper(navP2RightKey,"toggleList","ON")
	XHotKeywrapper(exitEmulatorKey,"CloseRomLaunchMenu")
	If (keymapperEnabled = "true") and (keymapperHyperLaunchProfileEnabled = "true") {
		Log("CreateRomMappingLaunchMenu - Running keymapper to load the ""menu"" profile.",5)
        RunKeymapper%zz%("menu",keymapper)
	}
	;filling game info
	for index, element in menuGameList
		{
		if !(menuGameList[a_index,5]){			
			currentAltFilePath := menuGameList[a_index,3]
			if InStr(currentAltFilePath, "\")
				SplitPath, currentAltFilePath, , , , currentAltFile
			else
				currentAltFile := RegExReplace(currentAltFilePath, regexEndExtension)
			If (menuGameList[a_index,4]="Tosec") {
				currentGameInfo := createTosecTable(currentAltFile)
				menuGameList[a_index,5] := gameinfotext()	
				menuGameList[a_index,6] := currentGameInfo[8,2,3]
				menuGameList[a_index,7] := currentGameInfo[24,2,1] ; good dump	
			} Else If (menuGameList[a_index,4]="NoIntro"){
				currentGameInfo := createNoIntroTable(currentAltFile)
				menuGameList[a_index,5] := gameinfotext()
				menuGameList[a_index,6] := currentGameInfo[2,2,3]	
				If !currentGameInfo[8,2,1]
					menuGameList[a_index,7] := true ; good dump						
			} Else If (menuGameList[a_index,4]="FrontendDatabase"){
				currentGameInfo := createFrontEndTable(currentAltFile)
				menuGameList[a_index,5] := gameinfotext()
			} Else {
					menuGameList[a_index,5] := "Name = " . currentAltFile
			}	
		}
	}
	for index, element in menuFilteredGameList
		{
		if !(menuFilteredGameList[a_index,5]){		
			currentAltFilePath := menuFilteredGameList[a_index,3]
			if InStr(currentAltFilePath, "\")
				SplitPath, currentAltFilePath, , , , currentAltFile
			else
				currentAltFile := RegExReplace(currentAltFilePath, regexEndExtension)
			If (menuFilteredGameList[a_index,4]="Tosec") {
				currentGameInfo := createTosecTable(currentAltFile)
				menuFilteredGameList[a_index,5] := gameinfotext()	
				menuFilteredGameList[a_index,6] := currentGameInfo[8,2,1] ; game Language Flag		
				menuFilteredGameList[a_index,7] := currentGameInfo[24,2,1] ; good dump			
			} Else If (menuFilteredGameList[a_index,4]="NoIntro"){
				currentGameInfo := createNoIntroTable(currentAltFile)
				menuFilteredGameList[a_index,5] := gameinfotext()	
				menuFilteredGameList[a_index,6] := currentGameInfo[2,2,1] ; game Language Flag
				If !currentGameInfo[8,2,1]
				menuFilteredGameList[a_index,7] := true ; good dump	
			} Else If (menuGameList[a_index,4]="FrontendDatabase"){
				currentGameInfo := createFrontEndTable(currentAltFile)
				menuFilteredGameList[a_index,5] := gameinfotext()
			} Else {
					menuFilteredGameList[a_index,5] := "Name = " . currentAltFile
			}	 
		}
	}
	If (currentRomMappingMenuList = menuGameList) {
		currentRomMappingMenuList[currentSelectedRom,5] := menuGameList[currentSelectedRom,5]
		currentRomMappingMenuList[currentSelectedRom,6] := menuGameList[currentSelectedRom,6]
		currentRomMappingMenuList[currentSelectedRom,7] := menuGameList[currentSelectedRom,7]
	} Else {
		currentRomMappingMenuList[currentSelectedRom,5] := menuFilteredGameList[currentSelectedRom,5]
		currentRomMappingMenuList[currentSelectedRom,6] := menuFilteredGameList[currentSelectedRom,6]
		currentRomMappingMenuList[currentSelectedRom,7] := menuFilteredGameList[currentSelectedRom,7]
	}
	;Loading Language Flags Bitmaps
	Loop, %HLMediaPath%\Menu Images\Rom Mapping Launch Menu\Language Flags\*.png
		{
		SplitPath, A_LoopFileFullPath, , , , currentFileName
		Bitmap%currentFileName% := Gdip_CreateBitmapFromFile(A_LoopFileFullPath)
	}
	;Loading Warning bitmap
	bitmapNoGoodDump := Gdip_CreateBitmapFromFile( HLMediaPath . "\Menu Images\Rom Mapping Launch Menu\Icons\no Good Dump.png")
	; loging Menu Game list items
	Loop, % menuGameList.MaxIndex()
		menuGameListLog := % menuGameListLog . "`r`n`t`t`t`t`t" . "List: Game " . a_index . "`r`n`t`t`t`t`t`tGame Title: `t`t" . menuGameList[a_index,1] . "`r`n`t`t`t`t`t`t7z Game Path: `t`t" . menuGameList[a_index,2] . "`r`n`t`t`t`t`t`tRom Name: `t`t`t" . menuGameList[a_index,3]  . "`r`n`t`t`t`t`t`tNaming Convention: `t" . menuGameList[a_index,4]  . "`r`n`t`t`t`t`t`tInfo Text: `t`t`t" . RegExReplace(menuGameList[a_index,5],"`r`n","|") 
	Log("CreateRomMappingLaunchMenu - Menu Game list Log:" menuGameListLog ,5)
	romMapLaunchMenuCreated := 1	; let other features now the menu was created
	;Drawing Select Menu
	drawnRomSelectColumn()
	Log("CreateRomMappingLaunchMenu - Ended")
	Loop, 
		If romMappingMenuExit
			Break
Return
}


DestroyRomMappingLaunchMenu(){
	Global
	Log("DestroyRomMappingLaunchMenu - Started",5)
	; Destroying Menu GUIs
	mapStartTime := A_TickCount
	Loop{	; fading out the launch menu
		tMap := ((mapTimeElapsed := A_TickCount-mapStartTime) < fadeOutDuration) ? 255*(1-(mapTimeElapsed/fadeOutDuration)) : 0
		UpdateLayeredWindow(RomSelect_hwnd1, RomSelect_hdc1,,,,, tMap)
		UpdateLayeredWindow(RomSelect_hwnd4, RomSelect_hdc4,,,,, tMap)
		UpdateLayeredWindow(RomSelect_hwnd2, RomSelect_hdc2,,,,, tMap)
		UpdateLayeredWindow(RomSelect_hwnd3, RomSelect_hdc3,,,,, tMap)
		If tMap <= 0
			Break
	}

	Loop, 4 { 
        CurrentGUI := A_Index
        SelectObject(RomSelect_hdc%CurrentGUI%, RomSelect_obm%CurrentGUI%)
		DeleteObject(RomSelect_hbm%CurrentGUI%)
		DeleteDC(RomSelect_hdc%CurrentGUI%)
		Gdip_DeleteGraphics(RomSelect_G%CurrentGUI%)
		Gui, RomSelect_GUI%CurrentGUI%: Destroy
	}
	Gdip_DeleteBrush(romMappingBackgroundBrush), Gdip_DeleteBrush(romMappingButtonBrush1), Gdip_DeleteBrush(romMappingButtonBrush2), Gdip_DeleteBrush(romMappingColumnBrush1), Gdip_DeleteBrush(romMappingColumnBrush2), Gdip_DeleteBrush(romMappingColumnBrush3)
	Gdip_DisposeImage(romMappingBG)
	romMapLaunchMenuCreated :=
	Log("DestroyRomMappingLaunchMenu - Ended",5)
Return	
}

drawnRomSelectColumn(){
	Global
	Log("drawnRomSelectColumn - Started",5)
	Gdip_GraphicsClear(RomSelect_G2)
	Gdip_GraphicsClear(RomSelect_G3)
	;Drawing Title text 2 help
	If (menuFilteredGameList.MaxIndex()) 
		{
		If (menuFilteredGameList.MaxIndex()<>menuGameList.MaxIndex()) 
			{
			Title2TextOption := "x" . romMappingMenuMargin . " y" . baseScreenHeight-romMappingMenuMargin-romMappingTitle2TextSize . " Left " . romMappingTitle2TextOptions
			If (currentRomMappingMenuList = menuGameList)
				Gdip_Alt_TextToGraphics(RomSelect_G2, "Game " . currentSelectedRom . " of " . currentRomMappingMenuList.MaxIndex() . " - Press Left or Right to go to Filtered Games List", Title2TextOption, romMappingTitle2TextFont, 0, 0)
			Else
				Gdip_Alt_TextToGraphics(RomSelect_G2, "Game " . currentSelectedRom . " of " . currentRomMappingMenuList.MaxIndex() . " - Press Left or Right to go to Full Games List", Title2TextOption, romMappingTitle2TextFont, 0, 0)
		} Else {
			Gdip_Alt_TextToGraphics(RomSelect_G2,  "Game " . currentSelectedRom . " of " . currentRomMappingMenuList.MaxIndex(), Title2TextOption, romMappingTitle2TextFont, 0, 0)
		}
	}
	;Drawing Games List column
	Gdip_Alt_FillRectangle(RomSelect_G3, romMappingColumnBrush1, 0, (baseScreenHeight-(VDistBtwRomNames*romMappingNumberOfGamesByScreen))//2, romMappingMenuWidth, VDistBtwRomNames*romMappingNumberOfGamesByScreen)
	Gdip_Alt_FillRectangle(RomSelect_G3, romMappingColumnBrush2, 0, 0,romMappingMenuWidth, (baseScreenHeight-(VDistBtwRomNames*romMappingNumberOfGamesByScreen))//2)
	Gdip_Alt_FillRectangle(RomSelect_G3, romMappingColumnBrush3, 0, (baseScreenHeight-(VDistBtwRomNames*romMappingNumberOfGamesByScreen))//2+VDistBtwRomNames*romMappingNumberOfGamesByScreen, romMappingMenuWidth, (baseScreenHeight-(VDistBtwRomNames*romMappingNumberOfGamesByScreen))//2)
	bottomtext := currentSelectedRom
	topText := currentSelectedRom
	Loop, % romMappingNumberOfGamesByScreen//2+1
		{
		currentIndex := a_index
		If (a_index=1)
			{
			Gdip_Alt_FillRoundedRectangle(RomSelect_G3, romMappingButtonBrush1, 0, (baseScreenHeight-romMappingTextSize)//2-romMappingTextMargin, romMappingMenuWidth,romMappingTextSize+2*romMappingTextMargin, romMappingButtonCornerRadius)
			Gdip_Alt_DrawRoundedRectangle(RomSelect_G3, romMappingButtonBrush2, 0, (baseScreenHeight-romMappingTextSize)//2-romMappingTextMargin, romMappingMenuWidth, romMappingTextSize+2*romMappingTextMargin, romMappingButtonCornerRadius)
			currentSelectedRomText := currentRomMappingMenuList[currentSelectedRom,1]
			MeasureCurrentSelectedRomText := MeasureText(currentSelectedRomText, "Left r4 s" . romMappingTextSize . " Bold",romMappingTextFont)
			If (MeasureCurrentSelectedRomText<=romMappingMenuWidth-2*romMappingTextMargin) or (romMappingMenuDrawn != true) {
				SetTimer, UpdateCurrentRomScrollingText, off
				Gdip_GraphicsClear(RomSelect_G4)
				TextOptions := "x0 y0 Center c" . romMappingSelectTextColor . " r4 s" . romMappingTextSize . " bold"
				Gdip_Alt_TextToGraphics(RomSelect_G4, currentSelectedRomText, TextOptions, romMappingTextFont, romMappingMenuWidth-2*romMappingTextMargin, romMappingTextSize)
				Alt_UpdateLayeredWindow(RomSelect_hwnd4, RomSelect_hdc4, baseScreenWidth-romMappingMenuMargin-romMappingMenuWidth+romMappingTextMargin, (baseScreenHeight-romMappingTextSize)//2, romMappingMenuWidth-2*romMappingTextMargin, romMappingTextSize)
			} Else {	
				initPixels := 0
				x := 0
				SetTimer, UpdateCurrentRomScrollingText, 20
			}
			GameInfoTextOptions := "x" . romMappingMenuMargin//2 . " y" . romMappingMenuMargin//2 . " Left " . romMappingGameInfoTextOptions
			Gdip_Alt_TextToGraphics(RomSelect_G2, currentRomMappingMenuList[currentSelectedRom,5], GameInfoTextOptions, romMappingGameInfoTextFont, baseScreenWidth-romMappingMenuMargin-romMappingMenuMargin-romMappingMenuWidth-2*romMappingTextMargin, baseScreenHeight)
			LanguageFlag := currentRomMappingMenuList[currentSelectedRom,6]
			If LanguageFlag
				{
				Loop, parse, LanguageFlag, `,
					{
					Gdip_GetImageDimensions(Bitmap%A_LoopField%, BitmapW, BitmapH)
					Gdip_Alt_DrawImage(RomSelect_G3, Bitmap%A_LoopField%, romMappingMenuWidth-romMappingMenuFlagWidth - (a_index-1)*(romMappingMenuFlagWidth+romMappingMenuFlagSeparation), (baseScreenHeight-romMappingTextSize)//2-romMappingTextMargin-round(romMappingMenuFlagWidth*BitmapH/BitmapW)//2,romMappingMenuFlagWidth,round(romMappingMenuFlagWidth*BitmapH/BitmapW))
				}
			}
			If !currentRomMappingMenuList[currentSelectedRom,7] and ((currentRomMappingMenuList[currentSelectedRom,4] = "Tosec") or (currentRomMappingMenuList[currentSelectedRom,4] = "NoIntro")) 
				{
				Gdip_GetImageDimensions(bitmapNoGoodDump, BitmapW, BitmapH)
				Gdip_Alt_DrawImage(RomSelect_G3, bitmapNoGoodDump, romMappingMenuWidth-romMappingMenuFlagWidth//2, (baseScreenHeight-romMappingTextSize)//2-romMappingTextMargin-round(romMappingMenuFlagWidth*BitmapH/BitmapW)//2,romMappingMenuFlagWidth//2,round(romMappingMenuFlagWidth*BitmapH/BitmapW)//2)
			}
		} Else {
			currentromTextSize := If (romMappingTextSize-a_index*romMappingTextSizeDifference>1) ? (romMappingTextSize-a_index*romMappingTextSizeDifference) : 1
			bottomtext++
			bottomtext := If (bottomtext > currentRomMappingMenuList.MaxIndex()) ? 1 : bottomtext
			Gdip_Alt_FillRoundedRectangle(RomSelect_G3, romMappingButtonBrush1, romMappingMenuWidth-romMappingMenuWidth+(romMappingMenuWidth-romMappingMenuWidth*(currentromTextSize/romMappingTextSize))//2, round((baseScreenHeight-romMappingTextSize)//2+(a_index-1)*(VDistBtwRomNames)-romMappingTextMargin*(currentromTextSize/romMappingTextSize)), round(romMappingMenuWidth*(currentromTextSize/romMappingTextSize)),round((romMappingTextSize+2*romMappingTextMargin)*(currentromTextSize/romMappingTextSize)), round(romMappingButtonCornerRadius*(currentromTextSize/romMappingTextSize)))
			TextOptions := "x" . (romMappingMenuWidth-romMappingMenuWidth*(currentromTextSize/romMappingTextSize))//2+(romMappingTextMargin*(currentromTextSize/romMappingTextSize))//2 . " y" . (baseScreenHeight-romMappingTextSize)//2+(a_index-1)*(VDistBtwRomNames) . " Center c" . romMappingDisabledTextColor . " r4 s" . currentromTextSize . " normal"
			Gdip_Alt_TextToGraphics(RomSelect_G3, currentRomMappingMenuList[bottomtext,1], TextOptions, romMappingTextFont, round((romMappingMenuWidth-2*romMappingTextMargin)*(currentromTextSize/romMappingTextSize)), currentromTextSize)
			LanguageFlag := currentRomMappingMenuList[bottomtext,6]
			If LanguageFlag
				{
				Loop, parse, LanguageFlag, `,
					{
					Gdip_GetImageDimensions(Bitmap%A_LoopField%, BitmapW, BitmapH)
					Gdip_Alt_DrawImage(RomSelect_G3, Bitmap%A_LoopField%, round(romMappingMenuWidth/2+(romMappingMenuWidth*(currentromTextSize/romMappingTextSize))/2-romMappingMenuFlagWidth*(currentromTextSize/romMappingTextSize) - (a_index-1)*(romMappingMenuFlagWidth*(currentromTextSize/romMappingTextSize)+romMappingMenuFlagSeparation*(currentromTextSize/romMappingTextSize))), round((baseScreenHeight-romMappingTextSize)/2+(currentIndex-1)*(VDistBtwRomNames)-romMappingTextMargin*(currentromTextSize/romMappingTextSize)-(romMappingMenuFlagWidth*BitmapH/BitmapW*(currentromTextSize/romMappingTextSize))/2),round(romMappingMenuFlagWidth*(currentromTextSize/romMappingTextSize)),round(romMappingMenuFlagWidth*BitmapH/BitmapW*(currentromTextSize/romMappingTextSize)))               
				}
			}
			If !currentRomMappingMenuList[bottomtext,7] and ((currentRomMappingMenuList[bottomtext,4] = "Tosec") or (currentRomMappingMenuList[bottomtext,4] = "NoIntro"))
				{
				Gdip_GetImageDimensions(bitmapNoGoodDump, BitmapW, BitmapH)
				Gdip_Alt_DrawImage(RomSelect_G3, bitmapNoGoodDump, round(romMappingMenuWidth-romMappingMenuWidth+(romMappingMenuWidth-romMappingMenuWidth*(currentromTextSize/romMappingTextSize))/2+romMappingMenuWidth*(currentromTextSize/romMappingTextSize)-romMappingMenuFlagWidth*(currentromTextSize/romMappingTextSize)/2), round((baseScreenHeight-romMappingTextSize)/2+(currentIndex-1)*(VDistBtwRomNames)-romMappingTextMargin*(currentromTextSize/romMappingTextSize)-(romMappingMenuFlagWidth*BitmapH/BitmapW*(currentromTextSize/romMappingTextSize))/2),(romMappingMenuFlagWidth*(currentromTextSize/romMappingTextSize))//2,round(romMappingMenuFlagWidth*BitmapH/BitmapW*(currentromTextSize/romMappingTextSize))//2)
			}
			topText--
			topText := If (topText < 1) ? currentRomMappingMenuList.MaxIndex() : topText
			Gdip_Alt_FillRoundedRectangle(RomSelect_G3, romMappingButtonBrush1, (romMappingMenuWidth-romMappingMenuWidth*(currentromTextSize/romMappingTextSize))//2, round((baseScreenHeight-romMappingTextSize)//2-(a_index-1)*(VDistBtwRomNames)-romMappingTextMargin*(currentromTextSize/romMappingTextSize)), round(romMappingMenuWidth*(currentromTextSize/romMappingTextSize)),round((romMappingTextSize+2*romMappingTextMargin)*(currentromTextSize/romMappingTextSize)), round(romMappingButtonCornerRadius*(currentromTextSize/romMappingTextSize)))
			TextOptions := "x" . (romMappingMenuWidth-romMappingMenuWidth*(currentromTextSize/romMappingTextSize))//2+(romMappingTextMargin*(currentromTextSize/romMappingTextSize))//2 . " y" . (baseScreenHeight-romMappingTextSize)//2-(a_index-1)*(VDistBtwRomNames) . " Center c" . romMappingDisabledTextColor . " r4 s" . currentromTextSize . " normal"
			Gdip_Alt_TextToGraphics(RomSelect_G3, currentRomMappingMenuList[topText,1], TextOptions, romMappingTextFont, round((romMappingMenuWidth-2*romMappingTextMargin)*(currentromTextSize/romMappingTextSize)), currentromTextSize)
			LanguageFlag := currentRomMappingMenuList[topText,6]
			If LanguageFlag
				{
				Loop, parse, LanguageFlag, `,
					{
					Gdip_GetImageDimensions(Bitmap%A_LoopField%, BitmapW, BitmapH)
					Gdip_Alt_DrawImage(RomSelect_G3, Bitmap%A_LoopField%, round(romMappingMenuWidth/2+(romMappingMenuWidth*(currentromTextSize/romMappingTextSize))/2-romMappingMenuFlagWidth*(currentromTextSize/romMappingTextSize) - (a_index-1)*(romMappingMenuFlagWidth*(currentromTextSize/romMappingTextSize)+romMappingMenuFlagSeparation*(currentromTextSize/romMappingTextSize))), round((baseScreenHeight-romMappingTextSize)/2-(currentIndex-1)*(VDistBtwRomNames)-romMappingTextMargin*(currentromTextSize/romMappingTextSize)-(romMappingMenuFlagWidth*BitmapH/BitmapW*(currentromTextSize/romMappingTextSize))/2),round(romMappingMenuFlagWidth*(currentromTextSize/romMappingTextSize)),round(romMappingMenuFlagWidth*BitmapH/BitmapW*(currentromTextSize/romMappingTextSize)))               
				}
			}
			If !currentRomMappingMenuList[topText,7] and ((topText[currentSelectedRom,4] = "Tosec") or (currentRomMappingMenuList[topText,4] = "NoIntro"))
				{
				Gdip_GetImageDimensions(bitmapNoGoodDump, BitmapW, BitmapH)
				Gdip_Alt_DrawImage(RomSelect_G3, bitmapNoGoodDump, round(romMappingMenuWidth-romMappingMenuWidth+(romMappingMenuWidth-romMappingMenuWidth*(currentromTextSize/romMappingTextSize))/2+romMappingMenuWidth*(currentromTextSize/romMappingTextSize)-romMappingMenuFlagWidth*(currentromTextSize/romMappingTextSize)/2), round((baseScreenHeight-romMappingTextSize)/2-(currentIndex-1)*(VDistBtwRomNames)-romMappingTextMargin*(currentromTextSize/romMappingTextSize)-(romMappingMenuFlagWidth*BitmapH/BitmapW*(currentromTextSize/romMappingTextSize))/2),(romMappingMenuFlagWidth*(currentromTextSize/romMappingTextSize))//2,round(romMappingMenuFlagWidth*BitmapH/BitmapW*(currentromTextSize/romMappingTextSize))//2)
			}
		}	
	}
	Alt_UpdateLayeredWindow(RomSelect_hwnd2, RomSelect_hdc2, 0, 0, baseScreenWidth, baseScreenHeight)
	Alt_UpdateLayeredWindow(RomSelect_hwnd3, RomSelect_hdc3, baseScreenWidth-romMappingMenuMargin-romMappingMenuWidth, 0, romMappingMenuWidth, baseScreenHeight)
	romMappingMenuDrawn := true
	Log("drawnRomSelectColumn - Ended",5)
Return	
}

UpdateCurrentRomScrollingText: ;Updating scrolling rom name
    Options = y0 c%romMappingSelectTextColor% r4 s%romMappingTextSize% bold
	scrollingVelocity := 2
	x := (-x >= E3) ? initPixels : x-scrollingVelocity
	initPixels := romMappingMenuWidth-2*romMappingTextMargin
    Gdip_GraphicsClear(RomSelect_G4)
    E := Gdip_Alt_TextToGraphics((RomSelect_G4), currentSelectedRomText, "x" x " " Options, romMappingTextFont, (x < 0) ? baseScreenWidth+romMappingTextSize-x : baseScreenWidth+romMappingTextSize, romMappingTextSize)
    StringSplit, E, E, |
	Alt_UpdateLayeredWindow(RomSelect_hwnd4, RomSelect_hdc4, baseScreenWidth-romMappingMenuMargin-romMappingMenuWidth+romMappingTextMargin, (baseScreenHeight-romMappingTextSize)//2, romMappingMenuWidth-2*romMappingTextMargin, romMappingTextSize)
Return


SelectRom:
	Log("SelectRom - Started",5)
	XHotKeywrapper(navSelectKey,"SelectRom","OFF")
	XHotKeywrapper(navUpKey,"SelectRomMenuMoveUp","OFF")
	XHotKeywrapper(navDownKey,"SelectRomMenuMoveDown","OFF")
	XHotKeywrapper(navLeftKey,"toggleList","OFF")
	XHotKeywrapper(navRightKey,"toggleList","OFF")
    XHotKeywrapper(navP2SelectKey,"SelectRom","OFF") 
    XHotKeywrapper(navP2UpKey,"SelectRomMenuMoveUp","OFF")
    XHotKeywrapper(navP2DownKey,"SelectRomMenuMoveDown","OFF")
	XHotKeywrapper(navP2LeftKey,"toggleList","OFF")
    XHotKeywrapper(navP2RightKey,"toggleList","OFF")
	XHotKeywrapper(exitEmulatorKey,"CloseRomLaunchMenu","OFF")
	If (keymapperEnabled = "true") and (keymapperHyperLaunchProfileEnabled = "true") {
		Log("SelectRom - Running keymapper to load the ""load"" profile.",5)
        RunKeymapper%zz%("load",keymapper)
	}
	romMappingMenuExit := true
	romMenuSelectedRom := currentRomMappingMenuList[currentSelectedRom,2]
	romMenuRomName := currentRomMappingMenuList[currentSelectedRom,3]
	Log("SelectRom - User selected this game from the Launch Menu: " . romMenuRomName,5)
	Log("SelectRom - romMenuSelectedRom is being split apart into the new romPath, romName, and romExtension: " . romMenuSelectedRom,5)
	SplitPath, romMenuSelectedRom,,romPath,romExtension, romName
	romExtension := "." . romExtension
;	clipboard :=  % "result if selected on the menu:`nromMenuSelectedRom=" . romMenuSelectedRom . "`nromMenuRomName=" . romMenuRomName . "`nromPath=" . romPath . "`nromExtension=" . romExtension  . "`nromName=" . romName  
	Log("SelectRom - Ended",5)
Return


CloseRomLaunchMenu:
	Log("CloseRomLaunchMenu - Started",5)
	Log("CloseRomLaunchMenu - User canceled out of the launch menu.",5)
	DestroyRomMappingLaunchMenu()
	ExitModule()
	Log("CloseRomLaunchMenu - Ended",5)
Return

SelectRomMenuMoveUp:
	currentSelectedRom--
	Log("SelectRomMenuMoveUp - Current selection changed to: " . currentRomMappingMenuList[currentSelectedRom,3],5)
	If  currentSelectedRom < 1
		currentSelectedRom := currentRomMappingMenuList.MaxIndex()
	drawnRomSelectColumn() 
Return

SelectRomMenuMoveDown:
	currentSelectedRom++
	Log("SelectRomMenuMoveDown - Current selection changed to: " . currentRomMappingMenuList[currentSelectedRom,3],5)
	If  currentSelectedRom > % currentRomMappingMenuList.MaxIndex()
		currentSelectedRom = 1 
	drawnRomSelectColumn() 
Return

toggleList:
	If menuFilteredGameList.MaxIndex()
		{
		If (menuFilteredGameList.MaxIndex()<>menuGameList.MaxIndex())
			{
			currentSelectedRom := 1
			If (currentRomMappingMenuList = menuGameList)
				currentRomMappingMenuList := menuFilteredGameList
			Else
				currentRomMappingMenuList := menuGameList
			drawnRomSelectColumn() 	
		}
	}
Return

LoadMappingIniExtraInfo(){
	Global
	;Log("LoadMappingIniExtraInfo - Started",5)
	FilterArr := []
	If (namingConvention="Tosec") {
		filtersList := "Demo|Year|Publisher|System|Resolution|Origin_Country|Language|Copyright|Development_Status|Media_Type|Media_Label|Cracked_Dump|Fix_Dump|Hacked_Dump|Modified_Dump|Pirate_Dump|Translated|Trained_Dump|Over_Dump|Under_Dump|Virus_Dump|Bad_Dump|Verified_Dump"
		Loop, parse, filtersList, |
			{
			FilterArr[a_index+1] :=
			IniRead,%a_loopfield%, %currentIniPath%,Filter,%a_loopfield%, %a_space%
			FilterArr[a_index+1] := %a_loopfield%
		}
	} Else If (namingConvention="NoIntro") {
		filtersList := "Language|Region|Development_Status|Version|Bios|Unlicensed_Game|Bad_or_Hacked_Dump"
		Loop, parse, filtersList, |
			{
			FilterArr[a_index+1] :=
			IniRead,%a_loopfield%, %currentIniPath%,Filter,%a_loopfield%, %a_space%
			FilterArr[a_index+1] := %a_loopfield%
		}
	}
	;Log("LoadMappingIniExtraInfo - Ended",5)
Return
}

gameinfotext(){
	Global currentGameInfo, romMappingGameInfoTextSize, romMappingGameInfoTextFont, romMappingMenuMargin, romMappingMenuWidth 
	loop, % currentGameInfo.MaxIndex()
		{
		currentItem := a_index
		If RegExReplace(currentGameInfo[currentItem,2,1],"^\s+|\s+$")
			{
			GameInfocontent :=
			Loop,
				{
				If !currentGameInfo[currentItem,a_index+1,1]
				{
					break
				} Else { 
					If currentGameInfo[currentItem,a_index+1,2]
						GameInfocontent := % GameInfocontent . currentGameInfo[currentItem,a_index+1,2] . ", "
					Else
						GameInfocontent := % GameInfocontent . currentGameInfo[currentItem,a_index+1,1] . ", " 
				}
			}
			StringTrimRight,GameInfocontent,GameInfocontent,2
			GameInfoLine := % currentGameInfo[currentItem,1,1] . " = " . GameInfocontent
			GameInfoFinalcontent := % GameInfoFinalcontent . GameInfoLine . "`r`n"
		}
	}
	Return GameInfoFinalcontent
}



FilterPass(NameConv){
	Global currentGameInfo, FilterArr
	;Log("FilterPass - Started",5)
	filter := true
	If (NameConv="Tosec") {
		Loop, 25
			{
			currentItem := a_index+1
			currentIniFilterChoice := % FilterArr[currentItem] ; ini file filter list
			If !(currentItem=18){
				If currentIniFilterChoice
					{
					currentGameInfoList := currentGameInfo[currentItem,2,1]
					If currentGameInfoList
						{
						If (currentItem=7) or (currentItem=8) {
							Loop, parse, currentGameInfoList, -
								{
								If a_loopfield not in %currentIniFilterChoice%
									filter := false
							}
						} Else If (currentItem>=13) and (currentItem<=24) {
							If (currentIniFilterChoice="false")
								filter := false
						} Else {
							If currentGameInfoList not in %currentIniFilterChoice%
								filter := false
						}
					}
				}
			}
		}
	} 	Else If (NameConv="NoIntro") {
		Loop, 8
			{
			currentItem := a_index+1
			currentIniFilterChoice := % FilterArr[currentItem] ; ini file filter list
			If currentIniFilterChoice
				{
				currentGameInfoList := currentGameInfo[currentItem,2,1]
				If currentGameInfoList
					{
					If (currentItem=2) or (currentItem=3) {
						Loop, parse, currentGameInfoList, `,
							{
							If a_loopfield not in %currentIniFilterChoice%
								filter := false
						}
					} Else If (currentItem>=6) and (currentItem<=8) {
							If (currentIniFilterChoice="false")
								filter := false
					} Else {
						If currentGameInfoList not in %currentIniFilterChoice%
							filter := false
					}
				}
			}
		}	
	}
	;Log("FilterPass - Ended",5)
Return	filter
}

createFrontEndTable(GameName,romMapGameInfo=false){
	Global systemName, showInfo, frontendDatabaseFields, frontendDatabaseLabels
	romMapGameInfoTable := []
	romMapGameInfoTable[1,1,1] := "NAME"
	if !(romMapGameInfo)
		{
		romMapGameInfo := Object()
		if (IsFunc("BuildDatabaseTable")) and (frontendDatabaseFields) and (frontendDatabaseLabels) {
			romMapGameInfo := BuildDatabaseTable%zz%(GameName,systemName,frontendDatabaseFields,frontendDatabaseLabels)
		} else {
			log("CreateRomMappingLaunchMenu - the BuildDatabaseTable function or required labels (frontendDatabaseFields and frontendDatabaseLabels) were not found on the plugin file. If you want to take advantage of the game frontend info and more descriptive names on the rom mapping menu you should create a propper BuildDatabaseTable function and the variables frontendDatabaseFields and frontendDatabaseLabels.",2)
			romMapGameInfoTable[1,2,1] := GameName
			Return romMapGameInfoTable
		}
	}
	if (romMapGameInfo["Name"].Label)
		romMapGameInfoTable[1,2,1] := romMapGameInfo["Name"].Value
	else
		romMapGameInfoTable[1,2,1] := GameName
	for index, element in romMapGameInfo
	{
		if !( element.Label = "Name") {
			if InStr(showInfo, "|" . element.Label . "|") {
				romMapGameInfoTable[a_index+1,1,1] := element.Label
				romMapGameInfoTable[a_index+1,2,1] := element.Value
			}
		}
	}
	romMapGameInfoTable := addHistoryDatInfo(GameName,romMapGameInfoTable)
	romMapGameInfoTable := addHighScoreInfo(GameName,romMapGameInfoTable)
	Return romMapGameInfoTable
}

	
addHistoryDatInfo(GameName,Array){	
	Global systemName, HLDataPath, showInfo
	currentIndex := % array.MaxIndex()
	; Loading history.dat info	
	IniRead, historyDatSystemName, % HLDataPath . "\History\System Names.ini", Settings, %systemName%, %A_Space%
    IniRead, romNameToSearch, % HLDataPath . "\History\" . systemName . ".ini", %GameName%, Alternate_Rom_Name, %A_Space%
	if !romNameToSearch
        romNameToSearch := GameName
    FileRead, historyContents, % HLDataPath . "\History\History.dat"
	FoundPos := RegExMatch(historyContents, "i)" . "\$\s*" . historyDatSystemName . "\s*=\s*.*\b" . romNameToSearch . "\b\s*,")
	If FoundPos
        {
        FoundPos2 := RegExMatch(historyContents, "i)\$end",EndString,FoundPos)
	    StringMid, HistoryDataText, historyContents, % FoundPos, % FoundPos2-FoundPos
        historySectionNumber := currentIndex
        Loop, parse, HistoryDataText, `n`r,`n`r  
            {
			line:=RegExReplace(A_LoopField,"^\s+|\s+$")  ; remove leading and trailing
			if historyDatSectionName%historySectionNumber% := RomMappinghistoryDatSection(line)
				{
				currentHistorySectionNumber := historySectionNumber		
				historySectionNumber++
			} else if (historySectionNumber>currentIndex) {
				HistoryFileTxtContents%currentHistorySectionNumber% := % HistoryFileTxtContents%currentHistorySectionNumber% . line
			}
		}
		loop, % historySectionNumber
			{
			if historyDatSectionName%a_index%
				if InStr(showInfo, "|" . "HistoryDat" . historyDatSectionName%a_index% . "|")
					if !(historyDatSectionName%a_index%=0)
						if HistoryFileTxtContents%a_index%
							{
							Array[a_index,1,1] := historyDatSectionName%a_index%
							Array[a_index,2,1] := HistoryFileTxtContents%a_index%
						}
		}
	}
	return Array
}

RomMappinghistoryDatSection(line){
	line:=RegExReplace(line,"^\s+|\s+$")  ; remove leading and trailing
	if InStr(line, "$bio")
		Return "DESCRIPTION"
	if !( InStr(line, "-") = 1 )
		Return 0
	if !( InStr(line, "-",false,0) = StrLen(line) )
		Return 0
	StringTrimLeft, line, line, 1
	StringTrimRight, line, line, 1
	line:=RegExReplace(line,"^\s+|\s+$")  ; remove leading and trailing
	sectionName := line
	StringReplace, line, line, %A_SPACE%, , All
	If line is upper
		Return %sectionName%
	else
		Return 0
Return
}

addHighScoreInfo(GameName,Array){
	Global showInfo, hpHiToTextPath, emuPath
	currentIndex := % array.MaxIndex()
	; Adding High Score info
	if InStr(showInfo, "|HighScores|") {
		SplitPath, hpHiToTextPath, , hpHitoTextDir
		If FileExist(hpHiToTextPath) and FileExist(hpHitoTextDir . "\hitotext.xml") {  ; making sure that hitotext files exist
			HighScoreText := StdoutToVar_CreateProcess("""" . hpHiToTextPath . """" . " -ra " . """" . emuPath . "\hi\" . GameName . ".hi" . """","",hpHitoTextDir) ;Loading HighScore information		
			If InStr(HighScoreText, "RANK"){ ; if High score info is found compare with the exit game high score values
				Array[currentIndex+1,1,1] := "High Scores"
				Array[currentIndex+1,2,1] := "`n`r" . HighScoreText
			}
		}
	}
	Return Array
}



createTosecTable(GameName){
	;Log("createTosecTable - Started",5)
	If !tosecTable
		tosecTable := []
		tosecTable[1,1,1] := "Name"
		tosecTable[2,1,1] := "Demo Info"
		tosecTable[3,1,1] := "Year"
		tosecTable[4,1,1] := "Publisher"
		tosecTable[5,1,1] := "System Info"	
		tosecTable[6,1,1] := "Video Info"	
		tosecTable[7,1,1] := "Country Info"	
		tosecTable[8,1,1] := "Language Info"
		tosecTable[9,1,1] := "Copyright Status"
		tosecTable[10,1,1] := "Development Status"
		tosecTable[11,1,1] := "Media Type"
		tosecTable[12,1,1] := "Media Label"
		tosecTable[13,1,1] := "Cracked Dump" 
		tosecTable[14,1,1] := "Fix Dump" 
		tosecTable[15,1,1] := "Hacked Dump" 
		tosecTable[16,1,1] := "Modified Dump" 
		tosecTable[17,1,1] := "Pirate Dump" 
		tosecTable[18,1,1] := "Translated Dump"
		tosecTable[19,1,1] := "Trained Dump" 
		tosecTable[20,1,1] := "Over Dump"
		tosecTable[21,1,1] := "Under Dump"
		tosecTable[22,1,1] := "Virus Dump" 
		tosecTable[23,1,1] := "Bad Dump" 
		tosecTable[24,1,1] := "Verified Dump" 
		tosecTable[25,1,1] := "More Info"
		tosecTable[26,1,1] := "Non Identified Info"
	reducedText := GameName
	;game name
		RegExMatch(reducedText, "[^(]*",name)
		RegExMatch(name, "[^[]*",name)
		StringReplace,reducedText,reducedText,%name%
		gameName:=RegExReplace(name,"^\s*","") ; remove leading
		gameName:=RegExReplace(name,"\s*$","") ; remove trailing
		tosecTable[1,2,1] := name
	;searching demo info
		demoList := "demo|demo-kiosk|demo-playable|demo-slideshow"
		tosecTable[2,2,1] := extractinfo(reducedText, demoList)
	;searching year 
		tosecTable[3,2,1] := extractinfo(reducedText, "[0-9][0-9][0-9][0-9][^)]*","","","",true)
		RegExMatch(tosecTable[3,2,1], "[0-9][0-9][0-9][0-9]",year) 
		If tosecTable[3,2,1]
			tosecTable[3,2,2] := year
	;searching Publisher 
		tosecTable[4,2,1] := extractinfo(reducedText, "[^)]*","","","",true)
	;Searching for System info
		systemList := "+2|+2a|+3|130XE|A1000|A1200|A1200-A4000|A2000|A2000-A3000|A2024|A2500-A3000UX|A3000|A4000|A4000T|A500|A500+|A500-A1000-A2000|A500-A1000-A2000-CDTV|A500-A1200|A500-A1200-A2000-A4000|A500-A2000|A500-A600-A2000|A570|A600|A600HD|AGA|AGA-CD32|Aladdin Deck Enhancer|CD32|CDTV|Computrainer|Doctor PC Jr.|ECS|ECS-AGA|Executive|Mega ST|Mega-STE|OCS|OCS-AGA|ORCH80|Osbourne 1|PIANO90|PlayChoice-10|Plus4|Primo-A|Primo-A64|Primo-B|Primo-B64|Pro-Primo|ST|STE|STE-Falcon|TT|TURBO-R GT|TURBO-R ST|VS DualSystem|VS UniSystem"
		systemDescriptionList := "Sinclair ZX Spectrum|Sinclair ZX Spectrum|Sinclair ZX Spectrum|Atari 8-bit|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Commodore Amiga|Nintendo NES|Commodore Amiga|Commodore Amiga|Nintendo NES|Nintendo NES|Commodore Amiga|Commodore Amiga|Osborne OSBORNE 1 & Executive|Atari ST|Atari ST|Commodore Amiga|Commodore Amiga|???|Osborne OSBORNE 1 & Executive|???|Nintendo NES|???|Microkey Primo|Microkey Primo|Microkey Primo|Microkey Primo|Microkey Primo|Atari ST|Atari ST|???|Atari ST|MSX|MSX|Nintendo NES|Nintendo NES"
		tosecTable[5,2,1] := extractinfo(reducedText,systemList, systemDescriptionList, systemdescription, true)
		If tosecTable[5,2,1]
			tosecTable[5,2,2] := systemdescription
	;searching video info 
		videoList := "MCGA|CGA|EGA|HGC|MDA|NTSC-PAL|NTSC|PAL-60|PAL-NTSC|PAL|SVGA|VGA|XGA"
		tosecTable[6,2,1] := extractinfo(reducedText, videoList)
	;Searching for country info 
		countryList := "AD|AE|AF|AG|AI|AL|AM|AO|AQ|AR|AS|AT|AU|AW|AX|AZ|BA|BB|BD|BE|BF|BG|BH|BI|BJ|BL|BM|BN|BO|BQ|BR|BS|BT|BV|BW|BY|BZ|CA|CC|CD|CF|CG|CH|CI|CK|CL|CM|CN|CO|CR|CU|CV|CW|CX|CY|CZ|DE|DJ|DK|DM|DO|DZ|EC|EE|EG|EH|ER|ES|ET|FI|FJ|FK|FM|FO|FR|GA|GB|GD|GE|GF|GG|GH|GI|GL|GM|GN|GP|GQ|GR|GS|GT|GU|GW|GY|HK|HM|HN|HR|HT|HU|ID|IE|IL|IM|IN|IO|IQ|IR|IS|IT|JE|JM|JO|JP|KE|KG|KH|KI|KM|KN|KP|KR|KW|KY|KZ|LA|LB|LC|LI|LK|LR|LS|LT|LU|LV|LY|MA|MC|MD|ME|MF|MG|MH|MK|ML|MM|MN|MO|MP|MQ|MR|MS|MT|MU|MV|MW|MX|MY|MZ|NA|NC|NE|NF|NG|NI|NL|NO|NP|NR|NU|NZ|OM|PA|PE|PF|PG|PH|PK|PL|PM|PN|PR|PS|PT|PW|PY|QA|RE|RO|RS|RU|RW|SA|SB|SC|SD|SE|SG|SH|SI|SJ|SK|SL|SM|SN|SO|SR|SS|ST|SV|SX|SY|SZ|TC|TD|TF|TG|TH|TJ|TK|TL|TM|TN|TO|TR|TT|TV|TW|TZ|UA|UG|UM|US|UY|UZ|VA|VC|VE|VG|VI|VN|VU|WF|WS|YE|YT|ZA|ZM|ZW"
		countryDescriptionList := "Andorra|United Arab Emirates|Afghanistan|Antigua and Barbuda|Anguilla|Albania|Armenia|Angola|Antarctica|Argentina|American Samoa|Austria|Australia|Aruba|�and Islands|Azerbaijan|Bosnia and Herzegovina|Barbados|Bangladesh|Belgium|Burkina Faso|Bulgaria|Bahrain|Burundi|Benin|Saint Barth�my|Bermuda|Brunei Darussalam|Bolivia, Plurinational State of|Bonaire, Sint Eustatius and Saba|Brazil|Bahamas|Bhutan|Bouvet Island|Botswana|Belarus|Belize|Canada|Cocos (Keeling) Islands|Congo, the Democratic Republic of the|Central African Republic|Congo|Switzerland|C�d'Ivoire|Cook Islands|Chile|Cameroon|China|Colombia|Costa Rica|Cuba|Cape Verde|Cura�|Christmas Island|Cyprus|Czech Republic|Germany|Djibouti|Denmark|Dominica|Dominican Republic|Algeria|Ecuador|Estonia|Egypt|Western Sahara|Eritrea|Spain|Ethiopia|Finland|Fiji|Falkland Islands (Malvinas)|Micronesia, Federated States of|Faroe Islands|France|Gabon|United Kingdom|Grenada|Georgia|French Guiana|Guernsey|Ghana|Gibraltar|Greenland|Gambia|Guinea|Guadeloupe|Equatorial Guinea|Greece|South Georgia and the South Sandwich Islands|Guatemala|Guam|Guinea-Bissau|Guyana|Hong Kong|Heard Island and McDonald Islands|Honduras|Croatia|Haiti|Hungary|Indonesia|Ireland|Israel|Isle of Man|India|British Indian Ocean Territory|Iraq|Iran, Islamic Republic of|Iceland|Italy|Jersey|Jamaica|Jordan|Japan|Kenya|Kyrgyzstan|Cambodia|Kiribati|Comoros|Saint Kitts and Nevis|Korea, Democratic People's Republic of|Korea, Republic of|Kuwait|Cayman Islands|Kazakhstan|Lao People's Democratic Republic|Lebanon|Saint Lucia|Liechtenstein|Sri Lanka|Liberia|Lesotho|Lithuania|Luxembourg|Latvia|Libya|Morocco|Monaco|Moldova, Republic of|Montenegro|Saint Martin (French part)|Madagascar|Marshall Islands|Macedonia, the former Yugoslav Republic of|Mali|Myanmar|Mongolia|Macao|Northern Mariana Islands|Martinique|Mauritania|Montserrat|Malta|Mauritius|Maldives|Malawi|Mexico|Malaysia|Mozambique|Namibia|New Caledonia|Niger|Norfolk Island|Nigeria|Nicaragua|Netherlands|Norway|Nepal|Nauru|Niue|New Zealand|Oman|Panama|Peru|French Polynesia|Papua New Guinea|Philippines|Pakistan|Poland|Saint Pierre and Miquelon|Pitcairn|Puerto Rico|Palestine, State of|Portugal|Palau|Paraguay|Qatar|R�ion|Romania|Serbia|Russian Federation|Rwanda|Saudi Arabia|Solomon Islands|Seychelles|Sudan|Sweden|Singapore|Saint Helena, Ascension and Tristan da Cunha|Slovenia|Svalbard and Jan Mayen|Slovakia|Sierra Leone|San Marino|Senegal|Somalia|Suriname|South Sudan|Sao Tome and Principe|El Salvador|Sint Maarten (Dutch part)|Syrian Arab Republic|Swaziland|Turks and Caicos Islands|Chad|French Southern Territories|Togo|Thailand|Tajikistan|Tokelau|Timor-Leste|Turkmenistan|Tunisia|Tonga|Turkey|Trinidad and Tobago|Tuvalu|Taiwan, Province of China|Tanzania, United Republic of|Ukraine|Uganda|United States Minor Outlying Islands|United States|Uruguay|Uzbekistan|Holy See (Vatican City State)|Saint Vincent and the Grenadines|Venezuela, Bolivarian Republic of|Virgin Islands, British|Virgin Islands, U.S.|Viet Nam|Vanuatu|Wallis and Futuna|Samoa|Yemen|Mayotte|South Africa|Zambia|Zimbabwe"
		countryListDescArr := []
		Loop, parse, countryDescriptionList, |
			countryListDescArr[a_index] := a_loopfield
		Loop, parse, countryList, |
			%A_LoopField% := countryListDescArr[a_index]
		tosecTable[7,2,1] := extractinfo(reducedText,countryList, countryDescriptionList, countrydescription, "", true)
		If tosecTable[7,2,1]
			tosecTable[7,2,2] := countrydescription
		If !tosecTable[7,2,1]
			{
			tosecTable[7,2,1] := "US"
			tosecTable[7,2,2] := "United States"			
		} 
		If InStr(tosecTable[7,2,1],"-") 
			{
			countrylisttoparse := tosecTable[7,2,1]
			Loop, parse, countrylisttoparse, -
				{
				currentField := A_LoopField
				currentField:=RegExReplace(currentField,"^\s*","") ; remove leading
				currentField:=RegExReplace(currentField,"\s*$","") ; remove trailing
				tosecTable[7,a_index+1,1] := currentField
				tosecTable[7,a_index+1,2] := %currentField%
			}
		}
	;Searching for language info
		languageList := "ab|aa|af|ak|sq|am|ar|an|hy|as|av|ae|ay|az|bm|ba|eu|be|bn|bh|bi|bs|br|bg|my|ca|ch|ce|ny|zh|cv|kw|co|cr|hr|cs|da|dv|nl|dz|en|eo|et|ee|fo|fj|fi|fr|ff|gl|ka|de|el|gn|gu|ht|ha|he|hz|hi|ho|hu|ia|id|ie|ga|ig|ik|io|is|it|iu|ja|jv|kl|kn|kr|ks|kk|km|ki|rw|ky|kv|kg|ko|ku|kj|la|lb|lg|li|ln|lo|lt|lu|lv|gv|mk|mg|ms|ml|mt|mi|mr|mh|mn|na|nv|nb|nd|ne|ng|nn|no|ii|nr|oc|oj|cu|om|or|os|pa|pi|fa|pl|ps|pt|qu|rm|rn|ro|ru|sa|sc|sd|se|sm|sg|sr|gd|sn|si|sk|sl|so|st|es|su|sw|ss|sv|ta|te|tg|th|ti|bo|tk|tl|tn|to|tr|ts|tt|tw|ty|ug|uk|ur|uz|ve|vi|vo|wa|cy|wo|fy|xh|yi|yo|za|zu"
		languageDescriptionList := "Abkhaz|Afar|Afrikaans|Akan|Albanian|Amharic|Arabic|Aragonese|Armenian|Assamese|Avaric|Avestan|Aymara|Azerbaijani|Bambara|Bashkir|Basque|Belarusian|Bengali; Bangla|Bihari|Bislama|Bosnian|Breton|Bulgarian|Burmese|Catalan;�Valencian|Chamorro|Chechen|Chichewa; Chewa; Nyanja|Chinese|Chuvash|Cornish|Corsican|Cree|Croatian|Czech|Danish|Divehi; Dhivehi; Maldivian;|Dutch|Dzongkha|English|Esperanto|Estonian|Ewe|Faroese|Fijian|Finnish|French|Fula; Fulah; Pulaar; Pular|Galician|Georgian|German|Greek, Modern|Guaran�ujarati|Haitian; Haitian Creole|Hausa|Hebrew�(modern)|Herero|Hindi|Hiri Motu|Hungarian|Interlingua|Indonesian|Interlingue|Irish|Igbo|Inupiaq|Ido|Icelandic|Italian|Inuktitut|Japanese|Javanese|Kalaallisut, Greenlandic|Kannada|Kanuri|Kashmiri|Kazakh|Khmer|Kikuyu, Gikuyu|Kinyarwanda|Kyrgyz|Komi|Kongo|Korean|Kurdish|Kwanyama, Kuanyama|Latin|Luxembourgish, Letzeburgesch|Ganda|Limburgish, Limburgan, Limburger|Lingala|Lao|Lithuanian|Luba-Katanga|Latvian|Manx|Macedonian|Malagasy|Malay|Malayalam|Maltese|Maori|Marathi (Mara?hi)|Marshallese|Mongolian|Nauru|Navajo, Navaho|Norwegian Bokm�North Ndebele|Nepali|Ndonga|Norwegian Nynorsk|Norwegian|Nuosu|South Ndebele|Occitan|Ojibwe, Ojibwa|Old Church Slavonic, Church Slavic, Church Slavonic, Old Bulgarian, Old Slavonic|Oromo|Oriya|Ossetian, Ossetic|Panjabi, Punjabi|Pali|Persian|Polish|Pashto, Pushto|Portuguese|Quechua|Romansh|Kirundi|Romanian,�Moldavian(Romanian from�Republic of Moldova)|Russian|Sanskrit (Sa?sk?ta)|Sardinian|Sindhi|Northern Sami|Samoan|Sango|Serbian|Scottish Gaelic; Gaelic|Shona|Sinhala, Sinhalese|Slovak|Slovene|Somali|Southern Sotho|Spanish; Castilian|Sundanese|Swahili|Swati|Swedish|Tamil|Telugu|Tajik|Thai|Tigrinya|Tibetan Standard, Tibetan, Central|Turkmen|Tagalog|Tswana|Tonga�(Tonga Islands)|Turkish|Tsonga|Tatar|Twi|Tahitian|Uighur, Uyghur|Ukrainian|Urdu|Uzbek|Venda|Vietnamese|Volap�k|Walloon|Welsh|Wolof|Western Frisian|Xhosa|Yiddish|Yoruba|Zhuang, Chuang|Zulu"
		countryLanguageList := "AE\ar|AL\sq|AM\hy|AR\es|AT\de|AU\en|AZ\Lt|BE\nl-fr|BG\bg|BH\ar|BN\ms|BO\es|BR\pt|BY\be|BZ\en|CA\en-fr|CB\en|CH\fr-de-it|CHS\zh|CHT\zh|CL\es|CN\zh|CO\es|CR\es|CZ\cs|DE\de|DK\da|DO\es|DZ\ar|EC\es|EE\et|EG\ar|ES\es|FI\fi-sv|FO\fo|FR\fr|GB\en|GE\ka|GR\el|GT\es|HK\zh|HN\es|HR\hr|HU\hu|ID\id|IE\en|IL\he|IN\en|IQ\ar|IR\fa|IS\is|IT\it|JM\en|JO\ar|JP\ja|KE\sw|KR\ko|KW\ar|KZ\kk|KZ\ky|LB\ar|LI\de|LT\lt|LU\fr-de|LV\lv|LY\ar|MA\ar|MC\fr|MK\mk|MN\mn|MO\zh|MV\div|MX\es|MY\ms|NI\es|NL\nl|NO\nb-nn|NZ\en|OM\ar|PA\es|PE\es|PH\en|PK\ur|PL\pl|PR\es|PT\pt|PY\es|QA\ar|RO\ro|RU\ru|SA\ar|SE\sv|SG\zh|SI\sl|SK\sk|SP\Lt|SV\es|SY\syr|TH\th|TN\ar|TR\tr|TT\en|TW\zh|UA\uk|US\en|UY\es|UZ\Lt|VE\es|VN\vi|YE\ar|ZA\en|ZW\en"
		langListDescArr := []
		Loop, parse, languageDescriptionList, |
			langListDescArr[a_index] := a_loopfield
		Loop, parse, languageList, |
			%A_LoopField% := langListDescArr[a_index]
		tosecTable[8,2,1] := extractinfo(reducedText,languageList, languageDescriptionList, languagedescription, "", true)
		If tosecTable[8,2,1]
			tosecTable[8,2,2] := languagedescription
		If !tosecTable[8,2,1]
			{
			Loop, parse, countryLanguageList, |
				{
				StringSplit, currentCountry, a_loopfield, \
				Loop  
					{
					If tosecTable[7,a_index+1,1]
						{
						If (tosecTable[7,a_index+1,1] = currentCountry1) {
							currentField := currentCountry2
							tosecTable[8,a_index+1,1] := currentField
							tosecTable[8,a_index+1,2] := %currentField%	
						}
					} Else {
						break
					}
				}
			}
		} 
		tosecTable[8,2,3] := tosecTable[8,2,1]
		If InStr(tosecTable[8,2,1],"-") 
			{
			languagelisttoparse := tosecTable[8,2,1]
			stringReplace, fullLanguageList, languagelisttoparse, -,`,,all 
			tosecTable[8,2,3] := fullLanguageList
			Loop, parse, languagelisttoparse, -
				{
				currentField := A_LoopField
				currentField:=RegExReplace(currentField,"^\s*","") ; remove leading
				currentField:=RegExReplace(currentField,"\s*$","") ; remove trailing
				tosecTable[8,a_index+1,1] := currentField
				tosecTable[8,a_index+1,2] := %currentField%
			}
		}
		If !(tosecTable[8,2,1])	{
			If (tosecTable[7,2,1] = "US") {
				tosecTable[8,2,1] := "en"
				tosecTable[8,2,2] := "English"
				tosecTable[8,2,3] := "en"
			}
		} 
		;checking for multiple languages tag
		MultiLanguages := extractinfo(reducedText, "M[0-9][^)]*","", "","",true,"",true)	
		If MultiLanguages
			{
			RegExMatch(MultiLanguages, "[0-9]+",MultiLanguages) 
			tosecTable[8,2,1] := "The game is in " . MultiLanguages . " different languages"
		}
	; Copyright Status 
		CopyrightList := "CW|CW-R|FW|GW|GW-R|LW|PD"
		CopyrightDescriptionList := "Cardware|Cardware-Registered|Freeware|Giftware|Giftware-Registered|Licenceware|Public Domain"
		tosecTable[9,2,1] := extractinfo(reducedText,CopyrightList, CopyrightDescriptionList, Copyrightdescription, false)
		If tosecTable[9,2,1]
			tosecTable[9,2,2] := Copyrightdescription
	; Devstatus Status 
		DevstatusList := "alpha|beta|preview|pre-release|proto"
		DevstatusDescriptionList := "Early test build|Later, feature complete test build|Near complete build|Near complete build|Unreleased, prototype software"
		tosecTable[10,2,1] := extractinfo(reducedText,DevstatusList, DevstatusDescriptionList, Devstatusdescription, false)
		If tosecTable[10,2,1]
			tosecTable[10,2,2] := Devstatusdescription
	; MediaType
		MediaTypeList := "Disc|Disk|File|Part|Side|Tape"
		MediaTypeDescriptionList := "Optical disc based media|Magnetic disk based media|Individual files|Individual parts|Side of media|Magnetic tape based media"
		tosecTable[11,2,1] := extractinfo(reducedText,MediaTypeList, MediaTypeDescriptionList, MediaTypedescription, false, true)
		If tosecTable[11,2,1]
			tosecTable[11,2,2] := MediaTypedescription
	; Media Label
		tosecTable[12,1,1] := extractinfo(reducedText, "[^)]*")
	;Dump Info Flags
		dumpInfoList := "cr|f|h|m|p|tr|t|o|u|v|b|a|!"
		dumpInfoDescription := "Cracked|Fix|Hacked|Modified|Pirate|Translated|Trained|Over Dump (too much data dumped)|Under Dump (not enough data dumped)|Virus (infected)|Bad dump (incorrect data dumped)|Verified good dump"
		dumpInfoDescriptionArr := []
		Loop, parse, dumpInfoDescription, |
			dumpInfoDescriptionArr[a_index] := a_loopfield
		Loop, parse, dumpInfoList, |
			{
			currentDumpInfo := A_Index+12
			tempdumpinfo := extractinfo(reducedText, A_LoopField . "[^]]*",A_LoopField, "","","",true)	
			If tempdumpinfo
				{
				tosecTable[currentDumpInfo,2,1] := true
				tosecTable[currentDumpInfo,2,2] := dumpInfoDescriptionArr[a_index]
				If (currentDumpInfo=18){
					translatedInfo := tempdumpinfo
					StringReplace,tempdumpinfo,tempdumpinfo,%A_LoopField%
					tempdumpinfo:=RegExReplace(tempdumpinfo,"^\s*","") ; remove leading
					tempdumpinfo:=RegExReplace(tempdumpinfo,"\s*$","") ; remove trailing
					tosecTable[currentDumpInfo,2,1] := tempdumpinfo
					tosecTable[currentDumpInfo,2,3] := tosecTable[currentDumpInfo,2,1]
					TranslatedDumpInfo := tosecTable[currentDumpInfo,2,2] . " from " . tosecTable[8,2,2] . " to "
					tosecTable[8,2,3] := tempdumpinfo
					If InStr(tempdumpinfo,"-") 
						{
						languagelisttoparse := tempdumpinfo
						stringReplace, fullLanguageList, languagelisttoparse, -,`,,all 
						tosecTable[8,2,3] := fullLanguageList
						Loop, parse, languagelisttoparse, -
							{
							currentField := A_LoopField
							currentField:=RegExReplace(currentField,"^\s*","") ; remove leading
							currentField:=RegExReplace(currentField,"\s*$","") ; remove trailing
							tosecTable[8,a_index+1,1] := currentField
							tosecTable[8,a_index+1,2] := %currentField%
							TranslatedDumpInfo := TranslatedDumpInfo . tosecTable[8,a_index+1,2] . "`, "
						}
						stringtrimRight, TranslatedDumpInfo, TranslatedDumpInfo, 1
						tosecTable[currentDumpInfo,2,2] := TranslatedDumpInfo
					} Else {
						tosecTable[8,2,1] := tempdumpinfo
						tosecTable[8,2,2] := %tempdumpinfo%
						tosecTable[currentDumpInfo,2,2] := TranslatedDumpInfo . tosecTable[8,2,2]	
					}
				}
			If !(currentDumpInfo=18)
				If tosecTable[currentDumpInfo,2,1]
					ExitDumpInfo := true
			}
		}
		If !ExitDumpInfo
			{
			tosecTable[24,2,1] := "!"
			tosecTable[24,2,2] := "Verified good dump"
		}
	;More info
		tosecTable[25,2,1] := extractinfo(reducedText, "[^]]*",A_LoopField, "","","",true)	
	;Non Identified
	reducedText:=RegExReplace(reducedText,"^\s*","") ; remove leading
	reducedText:=RegExReplace(reducedText,"\s*$","") ; remove trailing
	If reducedText
		tosecTable[26,2,1] := reducedText
	tosecTable := addHistoryDatInfo(GameName,tosecTable)
	tosecTable := addHighScoreInfo(GameName,tosecTable)
	;Log("createTosecTable - Ended",5)
	Return tosecTable	
}
	
createNoIntroTable(GameName){
	;Log("createNoIntroTable - Started",5)
	If !NoIntroTable
		NoIntroTable := []
	NoIntroTable[1,1,1] := "Name"
	NoIntroTable[2,1,1] := "Language Info"
	NoIntroTable[3,1,1] := "Region Info"
	NoIntroTable[4,1,1] := "Development Status"
	NoIntroTable[5,1,1] := "Version"
	NoIntroTable[6,1,1] := "Bios"	
	NoIntroTable[7,1,1] := "Game Info"
	NoIntroTable[8,1,1] := "Dump Info"
	NoIntroTable[9,1,1] := "Additional Info"
	reducedText := GameName
	;Bad or Hacked dump
	badDump := extractinfo(reducedText, "b","", "","","",true)	
	If badDump
		{
		NoIntroTable[8,2,1] := true
		NoIntroTable[8,2,2] := "Bad or Hacked Dump Game"
	}
	; unlicensed game
	unlGame := extractinfo(reducedText, "unl","", "","","","",true)	
	If unlGame
		{
		NoIntroTable[7,2,1] := true
		NoIntroTable[7,2,2] := "Unlicensed Game"
	}
	;BIOS
	biosDump := extractinfo(reducedText, "BIOS","", "","","",true,true)	
	If biosDump
		{
		NoIntroTable[6,2,1] := true
		NoIntroTable[6,2,2] := "Bios Dumped"
	}
	;Version
	NoIntroTable[5,2,1] := extractinfo(reducedText, "v[0-9][^)]*","", "","",true,"",true)	 
	NoIntroTable[5,2,1] := extractinfo(reducedText, "Rev[^)]*","", "","",true,"",true)	 
	; Development and/or Commercial Status
	DevstatusList := "Beta|Proto|Sample"
	DevstatusDescriptionList := "Feature complete test build|Unreleased, prototype software|Sample" 
	NoIntroTable[4,2,1] := extractinfo(reducedText,DevstatusList, DevstatusDescriptionList, Devstatusdescription, "",true,"",true)
	If NoIntroTable[4,2,1]
		NoIntroTable[4,2,2] := Devstatusdescription
	;Searching for Region info 
		regionList := "World|Europe|Asia|USA|United Arab Emirates|Albania|Asia|Austria|Australia|Bosnia and Herzegovina|Belgium|Bulgaria|Brazil|Canada|Switzerland|Chile|China|Serbia and Montenegro|Cyprus|Czech Republic|Germany|Denmark|Estonia|Egypt|Spain|Europe|Finland|France|United Kingdom|Greece|Hong Kong|Croatia|Hungary|Indonesia|Ireland|Israel|India|Iran|Iceland|Italy|Jordan|Japan|South Korea|Lithuania|Luxembourg|Latvia|Mongolia|Mexico|Malaysia|Netherlands|Norway|Nepal|New Zealand|Oman|Peru|Philippines|Poland|Portugal|Qatar|Romania|Russia|Sweden|Singapore|Slovenia|Slovakia|Thailand|Turkey|Taiwan|United States|Vietnam|Yugoslavia|South Africa"
		NoIntroTable[3,2,1] := extractinfo(reducedText,regionList, "", "", "", true,"",true)
		If InStr(NoIntroTable[3,2,1],"`,") 
			{
			regionlisttoparse := NoIntroTable[3,2,1]
			Loop, parse, regionlisttoparse, `,
				{
				currentField := A_LoopField
				currentField:=RegExReplace(currentField,"^\s*","") ; remove leading
				currentField:=RegExReplace(currentField,"\s*$","") ; remove trailing
				NoIntroTable[3,a_index+1,1] := currentField
			}
		}
	;Searching for language info
		languageList := "ab|aa|af|ak|sq|am|ar|an|hy|as|av|ae|ay|az|bm|ba|eu|be|bn|bh|bi|bs|br|bg|my|ca|ch|ce|ny|zh|cv|kw|co|cr|hr|cs|da|dv|nl|dz|en|eo|et|ee|fo|fj|fi|fr|ff|gl|ka|de|el|gn|gu|ht|ha|he|hz|hi|ho|hu|ia|id|ie|ga|ig|ik|io|is|it|iu|ja|jv|kl|kn|kr|ks|kk|km|ki|rw|ky|kv|kg|ko|ku|kj|la|lb|lg|li|ln|lo|lt|lu|lv|gv|mk|mg|ms|ml|mt|mi|mr|mh|mn|na|nv|nb|nd|ne|ng|nn|no|ii|nr|oc|oj|cu|om|or|os|pa|pi|fa|pl|ps|pt|qu|rm|rn|ro|ru|sa|sc|sd|se|sm|sg|sr|gd|sn|si|sk|sl|so|st|es|su|sw|ss|sv|ta|te|tg|th|ti|bo|tk|tl|tn|to|tr|ts|tt|tw|ty|ug|uk|ur|uz|ve|vi|vo|wa|cy|wo|fy|xh|yi|yo|za|zu"
		languageDescriptionList := "Abkhaz|Afar|Afrikaans|Akan|Albanian|Amharic|Arabic|Aragonese|Armenian|Assamese|Avaric|Avestan|Aymara|Azerbaijani|Bambara|Bashkir|Basque|Belarusian|Bengali; Bangla|Bihari|Bislama|Bosnian|Breton|Bulgarian|Burmese|Catalan;�Valencian|Chamorro|Chechen|Chichewa; Chewa; Nyanja|Chinese|Chuvash|Cornish|Corsican|Cree|Croatian|Czech|Danish|Divehi; Dhivehi; Maldivian;|Dutch|Dzongkha|English|Esperanto|Estonian|Ewe|Faroese|Fijian|Finnish|French|Fula; Fulah; Pulaar; Pular|Galician|Georgian|German|Greek, Modern|Guaran�ujarati|Haitian; Haitian Creole|Hausa|Hebrew�(modern)|Herero|Hindi|Hiri Motu|Hungarian|Interlingua|Indonesian|Interlingue|Irish|Igbo|Inupiaq|Ido|Icelandic|Italian|Inuktitut|Japanese|Javanese|Kalaallisut, Greenlandic|Kannada|Kanuri|Kashmiri|Kazakh|Khmer|Kikuyu, Gikuyu|Kinyarwanda|Kyrgyz|Komi|Kongo|Korean|Kurdish|Kwanyama, Kuanyama|Latin|Luxembourgish, Letzeburgesch|Ganda|Limburgish, Limburgan, Limburger|Lingala|Lao|Lithuanian|Luba-Katanga|Latvian|Manx|Macedonian|Malagasy|Malay|Malayalam|Maltese|Maori|Marathi (Mara?hi)|Marshallese|Mongolian|Nauru|Navajo, Navaho|Norwegian Bokm�North Ndebele|Nepali|Ndonga|Norwegian Nynorsk|Norwegian|Nuosu|South Ndebele|Occitan|Ojibwe, Ojibwa|Old Church Slavonic, Church Slavic, Church Slavonic, Old Bulgarian, Old Slavonic|Oromo|Oriya|Ossetian, Ossetic|Panjabi, Punjabi|Pali|Persian|Polish|Pashto, Pushto|Portuguese|Quechua|Romansh|Kirundi|Romanian,�Moldavian(Romanian from�Republic of Moldova)|Russian|Sanskrit (Sa?sk?ta)|Sardinian|Sindhi|Northern Sami|Samoan|Sango|Serbian|Scottish Gaelic; Gaelic|Shona|Sinhala, Sinhalese|Slovak|Slovene|Somali|Southern Sotho|Spanish; Castilian|Sundanese|Swahili|Swati|Swedish|Tamil|Telugu|Tajik|Thai|Tigrinya|Tibetan Standard, Tibetan, Central|Turkmen|Tagalog|Tswana|Tonga�(Tonga Islands)|Turkish|Tsonga|Tatar|Twi|Tahitian|Uighur, Uyghur|Ukrainian|Urdu|Uzbek|Venda|Vietnamese|Volap�k|Walloon|Welsh|Wolof|Western Frisian|Xhosa|Yiddish|Yoruba|Zhuang, Chuang|Zulu"
		langListDescArr := []
		Loop, parse, languageDescriptionList, |
			langListDescArr[a_index] := a_loopfield
		Loop, parse, languageList, |
			%A_LoopField% := langListDescArr[a_index]
		NoIntroTable[2,2,1] := extractinfo(reducedText,languageList, languageDescriptionList, languagedescription, "", true)
		If NoIntroTable[2,2,1]
			NoIntroTable[2,2,2] := languagedescription
		NoIntroTable[2,2,3] := NoIntroTable[2,2,1]
		If InStr(NoIntroTable[2,2,1],"`,") 
			{
			languagelisttoparse := NoIntroTable[2,2,1]
			Loop, parse, languagelisttoparse, `,
				{
				currentField := A_LoopField
				currentField:=RegExReplace(currentField,"^\s*","") ; remove leading
				currentField:=RegExReplace(currentField,"\s*$","") ; remove trailing
				NoIntroTable[2,a_index+1,1] := currentField
				NoIntroTable[2,a_index+1,2] := %currentField%
			}
		}
	; game name
	RegExMatch(reducedText, "[^(]*",name)
	RegExMatch(name, "[^[]*",name)
	StringReplace,reducedText,reducedText,%name%
	gameName:=RegExReplace(name,"^\s*","") ; remove leading
	gameName:=RegExReplace(name,"\s*$","") ; remove trailing
	NoIntroTable[1,2,1] := name
	;additional Info
	reducedText:=RegExReplace(reducedText,"^\s*","") ; remove leading
	reducedText:=RegExReplace(reducedText,"\s*$","") ; remove trailing
	If reducedText
		NoIntroTable[9,2,1] := reducedText
	NoIntroTable := addHistoryDatInfo(GameName,NoIntroTable)
	NoIntroTable := addHighScoreInfo(GameName,NoIntroTable)
	;Log("createNoIntroTable - Ended",5)
	Return NoIntroTable
}	

extractinfo(ByRef searchtext, List, DescriptionList = "", ByRef description="", RegExCharCorrect=false, matchOnlyInBeggining=false, dumpInfo=false, caseinsentitive=false){
	;Log("extractinfo - Started",5)
	;extra conditions to speed up search
	If !searchtext
		{
		;Log("extractinfo - Ended`, no searchtext provided",5)		
		Return
	}
	;removing invalid regex characters from list
	;Log("extractinfo - Searching for """ . searchtext . """",5)
	If RegExCharCorrect
		{
		StringReplace, List, List, \, \\, All
		replace :=   {"&":"&amp;","'":"&apos;",".":"\.","*":"\*","?":"\?","+":"\+","[":"\[","{":"\{","|":"\|","(":"\(",")":"\)","^":"\^","$":"\$"}
		For what, with in replace
		StringReplace, List, List, %what%, %with%, All
	}
	;preparing list 2 If available
	If DescriptionList
		{
		List2 := []
		Loop, parse, DescriptionList, |
			List2[a_index] := A_LoopField
	}
	;acquiring text info
	Loop, parse, List, |
		{
		If RegExCharCorrect	
			StringTrimRight,currentField,A_LoopField, 1
		Else
			currentField := A_LoopField
		If dumpInfo
			searchREgEX := % "\[\s*" . currentField . "[^]]*" 
		Else If matchOnlyInBeggining
			searchREgEX := % "\(\s*" . currentField . "[^)]*" 
		Else
			searchREgEX := % "\(\s*" . currentField . "\s*\)"
		If caseinsentitive
			searchREgEX := % "i)" . searchREgEX
		Pos := RegExMatch(searchtext, searchREgEX , FullText)
		If Pos
			{
			If matchOnlyInBeggining
				FullText := FullText . ")"
			If dumpInfo
				FullText := FullText . "]"
			StringTrimLeft, Text, FullText, 1
			StringTrimRight, Text, Text, 1
			Text:=RegExReplace(Text,"^\s*","") ; remove leading
			Text:=RegExReplace(Text,"\s*$","") ; remove trailing
			foundText := Text
			StringReplace,searchtext,searchtext,%FullText%
			If DescriptionList
				description := List2[a_index]
			break
		}
	}
	;Log("extractinfo - Ended",5)
	Return foundText
}