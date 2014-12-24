MCRC=6842990E
MVersion=1.0.7

BezelGUI(){
	Global
	if (bezelEnabled = "true"){
		Log("BezelGUI - Started")
		; creating GUi elements and pointers
		; Bezel_GUI1 - Background
		; Bezel_GUI2 - Overlay
		; Bezel_GUI3 - Bezel Image
		; Bezel_GUI4 - Instruction Card
		; Bezel_GUI5 - Instruction Card Left Menu Background
		; Bezel_GUI6 - Instruction Card Left Menu List
		; Bezel_GUI7 - Instruction Card Right Menu Background
		; Bezel_GUI8 - Instruction Card Right Menu List
		;initializing gdi plus
		If !pToken
			pToken := Gdip_Startup()
		Loop, 8 { 
			If (a_index = 1) {
				Gui, Bezel_GUI%A_Index%: +Disabled -Caption +E0x80000 +OwnDialogs +LastFound +ToolWindow 
			} Else {
				OwnerGUI := A_Index - 1
				Gui, Bezel_GUI%A_Index%: +OwnerBezel_GUI%OwnerGUI% +Disabled -Caption +E0x80000 +OwnDialogs +LastFound +ToolWindow +AlwaysOnTop 
			}
			Gui, Bezel_GUI%A_Index%: Margin,0,0
			Gui, Bezel_GUI%A_Index%: Show,, BezelLayer%A_Index%
			Bezel_hwnd%A_Index% := WinExist()
			Bezel_hbm%A_Index% := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
			Bezel_hdc%A_Index% := CreateCompatibleDC()
			Bezel_obm%A_Index% := SelectObject(Bezel_hdc%A_Index%, Bezel_hbm%A_Index%)
			Bezel_G%A_Index% := Gdip_GraphicsFromhdc(Bezel_hdc%A_Index%)
			Gdip_SetSmoothingMode(Bezel_G%A_Index%, 4)
		}
		Log("BezelGUI - Ended")	
	}
}

BezelStart(Mode="",parent="",angle="",rom=""){
	Global
	if (bezelEnabled = "true"){
		Log("BezelStart - Started")
			;Defining Bezel Mode
		if !Mode
			bezelMode = Normal
		else if (Mode = "fixResMode")
			bezelMode = fixResMode
		else if (Mode = "layout")
			bezelLayoutFile = %rom%
		else if RegExMatch(Mode, "^\d+$")
			bezelMode = MultiScreens	
		else
			Log("Invalid Bezel mode defined on the module.",3)
		;Choosing to use layout files or normal bezel
		if bezelLayoutFile	
			{
			If !FileExist( emuPath . "\artwork\" . bezelLayoutFile . ".zip") and !FileExist( emuPath . "\artwork\" . parent . ".zip")
				{
				Log("Bezel - Layout mode selected but no MAME or MESS layout file found. Using HyperLaunch Bezel normal mode instead.",1)
				bezelMode = Normal
				bezelLayoutFile =
			} else {
				Log("Bezel - MAME or MESS layout file (" . emuPath . "\artwork\" . bezelLayoutFile . ".zip" . " or " . emuPath . "\artwork\" . parent . ".zip" . ") already exists. Bezel addon will exit without doing any change to the emulator launch.",1)
				useBezels := " -use_bezels"
				Return
			}
		}
		Log("Bezel - Bezel mode " . bezelMode . " selected.",4)
		;Check for old modules error 
		IfWinNotExist, BezelLayer1
			ScriptError("You have an old incompatible module version.`n`r`n`rUpdate your modules before running HyperLaunch again!!!")
		; -------------- Read ini options and define default values
		Bezel_GlobalFile := A_ScriptDir . "\Settings\Global Bezel.ini" 
		Bezel_SystemFile := A_ScriptDir . "\Settings\" . systemName . "\Bezel.ini" 
		Bezel_RomFile := A_ScriptDir . "\Settings\" . systemName . "\" . dbname . "\Bezel.ini" 
		if (RIni_Read("bezelGlobalRini",Bezel_GlobalFile) = -11)
			RIni_Create("bezelGlobalRini")
		if (RIni_Read("bezelSystemRini",Bezel_SystemFile) = -11)
			RIni_Create("bezelSystemRini")
		if (RIni_Read("BezelRomRini",Bezel_RomFile) = -11)
			RIni_Create("BezelRomRini")
		;[Settings]
		bezelFileExtensions := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Settings", "Bezel_Supported_Image_Files","png|gif|tif|bmp|jpg")
		;[Bezel Change]
		bezelChangeDur := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Bezel Change", "Bezel_Transition_Duration","500")
		bezelSaveSelected := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini","Bezel Change","Bezel_Save_Selected","false")
		extraFullScreenBezel := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini","Bezel Change","Extra_FullScreen_Bezel","false") 
		;[Background]
		bezelBackgroundChangeDur := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Background", "Background_Change_Timer","0") ; 0 if disabled, number if you want the bezel background to change automatically at each x miliseconds
		bezelBackgroundTransition := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Background", "Background_Transition_Animation","fade") ; none or fade
		bezelBackgroundTransitionDur := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Background", "Background_Transition_Duration","500") ; determines the duration of fade bezel background transition
		bezelUseBackgrounds := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Background", "Use_Backgrounds","false") ; determines the duration of fade bezel background transition
		;[Bezel Change Keys]
		nextBezelKey := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Bezel Change Keys", "Next_Bezel_Key", "") 
		previousBezelKey := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Bezel Change Keys", "Previous_Bezel_Key","")
		If (bezelICEnabled = "true") {
			;[Instruction Cards General Settings]
			positionIC := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards General Settings", "IC_Positions","topLeft|topRight|bottomLeft|bottomRight|topCenter|leftCenter|rightCenter|bottomCenter") ; (1-8 positions) can be topLeft|topRight|bottomLeft|bottomRight|topCenter|leftCenter|rightCenter|bottomCenter
			animationIC := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards General Settings", "IC_Transition_Animation","fade") ; can be none, fade, slideIn, slideOutandIn
			ICChangeDur := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards General Settings", "IC_Transition_Duration","500")
			enableICChangeSound := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards General Settings", "IC_Enable_Transition_Sound","true") ; It searches for sound files named ICslideIn.mp3, ICslideOut.mp3, ICFadeOut.mp3, ICFadeIn.mp3 or ICChange.mp3 on the default global, default system and rom bezel folders to be played while changing the ICs
			ICScaleFactor := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards General Settings", "IC_Scale_Factor","ScreenHeight") ;you can choose between a number (1 to keep the original image size), or the words: ScreenHeight, ScreenWidth, HalfScreenHeight, HalfScreenWidth, OneThirdScreenHeight and OneThirdScreenWidth in order to resize the image in relation to the screen size. The default value is ScreenHeight that will work better in any resolution with a two ICs option (also the default one). 
			ICSaveSelected := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini","Instruction Cards General Settings","IC_Save_Selected","false")
			;[Instruction Cards Menu]
			leftMenuPositionsIC := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Menu", "IC_Left_Menu_Positions","topLeft|leftCenter|bottomLeft|bottomCenter") ; (1-8 positions) can be topLeft|topRight|bottomLeft|bottomRight|topCenter|leftCenter|rightCenter|bottomCenter
			ICleftMenuListItems := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Menu", "IC_Left_Menu_Number_of_List_Items","7")
			rightMenuPositionsIC := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Menu", "IC_Right_Menu_Positions","topRight|rightCenter|bottomRight|topCenter") ; (1-8 positions) can be topLeft|topRight|bottomLeft|bottomRight|topCenter|leftCenter|rightCenter|bottomCenter 
			ICrightMenuListItems := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Menu", "IC_Right_Menu_Number_of_List_Items","7")
			;[Instruction Cards Visibility]
			displayICOnStartup := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Visibility", "IC_Display_Card_on_Startup","false")  
			ICRandomSlideShowTimer := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Visibility", "IC_Random_Slide_Show_Timer","0")  
			toogleICVisibilityKey := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Visibility", "IC_Toggle_Visibility_Key","") 
			;[Instruction Cards Keys Change Mode 1]
			leftICMenuKey := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 1", "IC_Left_Menu_Key","")
			rightICMenuKey := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 1", "IC_Right_Menu_Key","")
			;[Instruction Cards Keys Change Mode 2]
			changeActiveICKey := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 2", "IC_Change_Active_Instruction_Card_Key","")
			previousICKey := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 2", "IC_Previous_Instruction_Card_Key","")
			nextICKey := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 2", "IC_Next_Instruction_Card_Key","")
			;[Instruction Cards Keys Change Mode 3]
			previousIC1Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_1_Previous_Key","")
			previousIC2Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_2_Previous_Key","")
			previousIC3Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_3_Previous_Key","")
			previousIC4Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_4_Previous_Key","")
			previousIC5Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_5_Previous_Key","")
			previousIC6Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_6_Previous_Key","")
			previousIC7Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_7_Previous_Key","")
			previousIC8Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_8_Previous_Key","")
			nextIC1Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_1_Next_Key","")
			nextIC2Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_2_Next_Key","")
			nextIC3Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_3_Next_Key","")
			nextIC4Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_4_Next_Key","")
			nextIC5Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_5_Next_Key","")
			nextIC6Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_6_Next_Key","")
			nextIC7Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_7_Next_Key","")
			nextIC8Key := RIniBezelLoadVar("bezelGlobalRini","bezelSystemRini", "BezelRomRini", "Instruction Cards Keys Change Mode 3", "IC_8_Next_Key","")
		}
		; Saving values to ini file
		RIni_Write("bezelGlobalRini",Bezel_GlobalFile,"`r`n",1,1,1)
		IfNotExist, % A_ScriptDir . "\Settings\" . systemName 
			FileCreateDir, % A_ScriptDir . "\Settings\" . systemName 
		RIni_Write("bezelSystemRini",Bezel_SystemFile,"`r`n",1,1,1)
		;logging all Bezel Options
		Log("Bezel variable values: " . BezelVarLog,5)
		; -------------- End of Read ini options and define default values
		;Loading Bezel parameters and images
		;Checking if game is vertical oriented
		if ((angle=90) or (angle=270) or (angle)) {
			vertical := "true"
			Log("Bezel - Assuming that game has vertical orientation. Bezel will search on the extra folder Vertical in order to find assets.",4)
		} else
			Log("Bezel - Assuming that game has horizontal orientation.",4)
		;Read Bezel Image
		if (bezelMode = "MultiScreens"){
			bezelNumberOfScreens := mode
			bezelPath := BezelFilesPath("Bezel [" . bezelNumberOfScreens . "S]",bezelFileExtensions)
		} else {
			bezelPath := BezelFilesPath("Bezel",bezelFileExtensions,true)
		}
		;-----Loading Image Files into ARRAYs for bezel/background/overlay/instruction card
		If bezelPath 
			{
			bezelCheckPosTimeout = 5000
			;Setting bezel aleatory choosed file
			bezelImagesList := []
			if (bezelMode = "MultiScreens")
				{
				Loop, Parse, bezelFileExtensions,|
					Loop, % bezelPath . "\Bezel [" . bezelNumberOfScreens . "S]*." . A_LoopField
						bezelImagesList.Insert(A_LoopFileFullPath)
			} else {
				Loop, Parse, bezelFileExtensions,|
					Loop, % bezelPath . "\Bezel*." . A_LoopField
						if !RegExMatch(A_LoopFileName, "i)\[[0-9]+S\]")
							bezelImagesList.Insert(A_LoopFileFullPath)
			}
			if (bezelSaveSelected="true"){
				Random, initialRndmBezel, 1, % bezelImagesList.MaxIndex()
				bezelSelectedIndex := RIni_GetKeyValue("BezelRomRini","Bezel Change","Initial_Bezel_Index")
				RndmBezel := if (bezelSelectedIndex = -2) or (bezelSelectedIndex = -3) ? initialRndmBezel :  bezelSelectedIndex
			} else
				Random, RndmBezel, 1, % bezelImagesList.MaxIndex()
			bezelImageFile := bezelImagesList[RndmBezel]
			Log("Bezel - Loading Bezel image: " . bezelImageFile,1)		
			;Setting background aleatory choosed file
			bezelBackgroundsList := []
			SplitPath, bezelImageFile, bezelImageFileName 
			If FileExist(bezelPath . "\Background" . SubStr(bezelImageFileName,6)) {
				bezelBackgroundsList.Insert(bezelPath . "\Background" . SubStr(bezelImageFileName,6))
				bezelBackgroundfile := % bezelPath . "\Background" . SubStr(bezelImageFileName,6)
				Log("Bezel - Loading Background image with the same name of the bezel image: " . bezelBackgroundFile,1)
			} Else {
				bezelBackgroundfile := RndBezelFilePath("Background",false,if (bezelUseBackgrounds="true") ? true : false)
				If FileExist(bezelBackgroundFile)
					Log("Bezel - Loading Background image: " . bezelBackgroundFile,1)
			}
			;Setting overlay aleatory choosed file (only searches overlays at the bezel.png folder)
			bezelOverlaysList := []
			If FileExist(bezelPath . "\Overlay" . SubStr(bezelImageFileName,6)) {
				bezelOverlaysList.Insert(bezelPath . "\Overlay" . SubStr(bezelImageFileName,6))
				bezelOverlayFile := % bezelPath . "\Overlay" . SubStr(bezelImageFileName,6)
				Log("Bezel - Loading Overlay image with the same name of the bezel image: " . bezelOverlayFile,1)
			} Else {
				if (bezelMode = "MultiScreens")
					{
					Loop, Parse, bezelFileExtensions,|
						Loop, % bezelPath . "\Overlay [" . bezelNumberOfScreens . "S]*." . A_LoopField
							bezelOverlaysList.Insert(A_LoopFileFullPath)
				} else {
					Loop, Parse, bezelFileExtensions,|
						Loop, % bezelPath . "\Overlay*." . A_LoopField
							if !RegExMatch(A_LoopFileName, "i)\[[0-9]+S\]")
								 bezelOverlaysList.Insert(A_LoopFileFullPath)
				}
				Random, RndmBezelOverlay, 1, % bezelOverlaysList.MaxIndex()
				bezelOverlayFile := bezelOverlaysList[RndmBezelOverlay]
				If FileExist(bezelOverlayFile)
					Log("Bezel - Loading Overlay image: " . bezelOverlayFile,1)
			}
		}
		if (extraFullScreenBezel = "true"){
			Log("Adding extra fullscreen fake bezel image",1)
			if !bezelPath
				{
				bezelImagesList := []
				bezelPath := "fakeFullScreenBezel"
				RndmBezel := 1
				bezelImageFile := "fakeFullScreenBezel"
			}
			bezelImagesList.Insert("fakeFullScreenBezel")
		}
		If (bezelICEnabled = "true") {
			;Loading bezel instruction card files
			bezelICPath := BezelFilesPath("Instruction Card",bezelFileExtensions)		
			if bezelICPath
				{
				;Acquiring screen info for dealing with rotated menu drawings
				Gdip_Alt_GetRotatedDimensions(A_ScreenWidth, A_ScreenHeight, screenRotationAngle, baseScreenWidth, baseScreenHeight)
				Gdip_GetRotatedTranslation(baseScreenWidth, baseScreenHeight, screenRotationAngle, xTranslation, yTranslation)
				xTranslation:=round(xTranslation), yTranslation:=round(yTranslation)
				Loop, 5 { 
					CurrentGUI := a_index + 3
					Gdip_TranslateWorldTransform(Bezel_G%CurrentGUI%, xTranslation, yTranslation)
					Gdip_RotateWorldTransform(Bezel_G%CurrentGUI%, screenRotationAngle)
				}
				;List of available IC images
				bezelICImageList := []
				Loop, Parse, bezelFileExtensions,|
					Loop, %bezelICPath%\Instruction Card*.%A_LoopField%
						bezelICImageList.Insert(A_LoopFileFullPath)
				Loop, % bezelICImageList.MaxIndex()
					ICLogFilesList := ICLogFilesList . "`r`n`t`t`t`t`t" . bezelICImageList[a_index]
				Log("Bezel - Instruction Card images found: " . ICLogFilesList,4)
				;IC Position Array
				listofPosibleICPositions = topLeft,topRight,bottomLeft,bottomRight,topCenter,leftCenter,rightCenter,bottomCenter
				listofPossibleICScale = HalfScreenHeight|HalfScreenWidth|OneThirdScreenHeight|OneThirdScreenWidth|ScreenHeight|ScreenWidth
				StringSplit, positionICArray, positionIC, |, 
				;IC Array	
				defaultICScaleFactor := ICScaleFactor
				bezelICArray := [] ;bezelICArray[screenICPositionIndex, ICimageIndex, Attribute]
				activeIC := 1
				selectedICimage := []
				prevselectedICimage := []
				selectedRightMenuItem := []
				selectedLeftMenuItem := []
				maxICimage := []
				currentImage := 0
				loop, 8
					{
					currentImage := 0
					currentICPositionIndex := a_index
					Loop, % bezelICImageList.MaxIndex()
						{
						currentBezelICFileName := bezelICImageList[a_index]
						SplitPath, currentBezelICFileName, , , , currentPureFileName
						postionNotDefined := false
						if currentPureFileName not contains %listofPosibleICPositions%
							postionNotDefined := true
						if ( ( (positionICArray%currentICPositionIndex%) and (InStr(currentPureFileName,positionICArray%currentICPositionIndex%)) ) or (postionNotDefined = true) ) 
							{
							currentImage++
							bezelICArray[currentICPositionIndex,currentImage,1] := currentBezelICFileName ; path to instruction card image
							bezelICArray[currentICPositionIndex,currentImage,2] := Gdip_CreateBitmapFromFile(currentBezelICFileName) ;bitmap pointer
							;image size
							ICScaleFactor := defaultICScaleFactor
							Loop, parse, listofPossibleICScale,|,
							{
								if InStr(currentPureFileName,A_LoopField)
								{
								ICScaleFactor := A_LoopField
								Log("ICScaleFactor set by instruction card file name: " . ICScaleFactor,5)
								break
								}
							}
							if (ICScaleFactor="ScreenHeight")
								ICScaleFactor := baseScreenHeight/Gdip_GetImageHeight(bezelICArray[currentICPositionIndex,currentImage,2])
							else if (ICScaleFactor="ScreenWidth")
								ICScaleFactor := baseScreenWidth/Gdip_GetImageWidth(bezelICArray[currentICPositionIndex,currentImage,2])	
							else if (ICScaleFactor="HalfScreenHeight")
								ICScaleFactor := baseScreenHeight/2/Gdip_GetImageHeight(bezelICArray[currentICPositionIndex,currentImage,2])	
							else if (ICScaleFactor="HalfScreenWidth")
								ICScaleFactor := baseScreenWidth/2/Gdip_GetImageWidth(bezelICArray[currentICPositionIndex,currentImage,2])	
							else if (ICScaleFactor="OneThirdScreenHeight")
								ICScaleFactor := baseScreenHeight/3/Gdip_GetImageHeight(bezelICArray[currentICPositionIndex,currentImage,2])	
							else if (ICScaleFactor="OneThirdScreenWidth")
								ICScaleFactor := baseScreenWidth/3/Gdip_GetImageWidth(bezelICArray[currentICPositionIndex,currentImage,2])	
							else 
								ICScaleFactor := ICScaleFactor	
							bezelICArray[currentICPositionIndex,currentImage,3] := round(Gdip_GetImageWidth(bezelICArray[currentICPositionIndex,currentImage,2])*ICScaleFactor) ; width of instruction card image
							bezelICArray[currentICPositionIndex,currentImage,4] := round(Gdip_GetImageHeight(bezelICArray[currentICPositionIndex,currentImage,2])*ICScaleFactor) ; height of instruction card image
							;clean name
							StringTrimLeft, currentLabel, currentPureFileName,16
							replace := {"topLeft":"","topRight":"","bottomLeft":"","bottomRight":"","topCenter":"","leftCenter":"","rightCenter":"","bottomCenter":""} ; Removing place strings from name
							For what, with in replace
								if InStr(currentLabel,what)
									StringReplace, currentLabel, currentLabel, %what%, %with%, All
							replace := {"HalfScreenHeight":"","HalfScreenWidth":"","OneThirdScreenHeight":"","OneThirdScreenWidth":"","ScreenHeight":"","ScreenWidth":""} ; Removing scale factor from name
							For what, with in replace
								if InStr(currentLabel,what)
									StringReplace, currentLabel, currentLabel, %what%, %with%, All
							currentLabel:=RegExReplace(currentLabel,"\(.*\)","") ; remove anything inside parentesis
							currentLabel:=RegExReplace(currentLabel,"^\s*","") ; remove leading
							currentLabel:=RegExReplace(currentLabel,"\s*$","") ; remove trailing
							bezelICArray[currentICPositionIndex,currentImage,5] := currentLabel ;clean Name
						}
					}
					bezelICArray[currentICPositionIndex,0,5] := "None"
					selectedICimage[currentICPositionIndex] := 0
					prevselectedICimage[currentICPositionIndex] := 0
					selectedRightMenuItem[currentICPositionIndex] := 0
					selectedLeftMenuItem[currentICPositionIndex] := 0
					maxICimage[currentICPositionIndex] := currentImage
					currentImage := 0
					ICVisibilityOn := true
				}
				if enableICChangeSound
					{
					currentPath := BezelFilesPath("ICslideIn","mp3")
					if currentPath
						slideInICSound := currentPath . "\ICslideIn.mp3"
					currentPath := BezelFilesPath("ICslideOut","mp3")
					if currentPath
						slideOutICSound := currentPath . "\ICslideOut.mp3"
					currentPath := BezelFilesPath("ICFadeOut","mp3")
					if currentPath
						fadeOutICSound := currentPath . "\ICFadeOut.mp3"
					currentPath := BezelFilesPath("ICFadeIn","mp3")
					if currentPath
						fadeOutICSound := currentPath . "\ICFadeIn.mp3"
					currentPath := BezelFilesPath("ICChange","mp3")
					if currentPath
						changeICSound := currentPath . "\ICChange.mp3"
				}
				;initializing IC menus
				StringReplace, leftMenuPositionsIC, leftMenuPositionsIC,|,`,, all
				StringReplace, rightMenuPositionsIC, rightMenuPositionsIC,|,`,, all
				loop, 8
					{
					if positionICArray%a_index% in %leftMenuPositionsIC%
						{
						if bezelICArray[a_index,1,1]
							{
							leftMenuActiveIC := a_index
							break
						}
					}
				}
				loop, 8
					{
					if positionICArray%a_index% in %rightMenuPositionsIC%
						{
						if bezelICArray[a_index,1,1]
							{
							rightMenuActiveIC := a_index
							break
						}
					}
				}
				;loading menu parameters
				menuSelectedItem := []	
				loop, 2
					{
					if (a_index=1)
						currentICMenu := "Left" 
					else 
						currentICMenu := "Right" 
					bezelIC%currentICMenu%MenuList := []
					bezelICMenuPath := BezelFilesPath("IC Menu " . currentICMenu, bezelFileExtensions)
					Loop, Parse, bezelFileExtensions,|
						Loop, % bezelICMenuPath . "\IC Menu " . currentICMenu . "*." . A_LoopField
							bezelIC%currentICMenu%MenuList.Insert(A_LoopFileFullPath)
					Random, RndmbezelICMenu, 1, % bezelIC%currentICMenu%MenuList.MaxIndex()
					;File and bitmap pointers
					bezelIC%currentICMenu%MenuFile := bezelIC%currentICMenu%MenuList[RndmbezelICMenu]
					bezelIC%currentICMenu%MenuBitmap := Gdip_CreateBitmapFromFile(bezelIC%currentICMenu%MenuFile)
					Gdip_GetImageDimensions(bezelIC%currentICMenu%MenuBitmap, bezelIC%currentICMenu%MenuBitmapW, bezelIC%currentICMenu%MenuBitmapH)
					;Ini appearance options
					currentICMenuFile := bezelIC%currentICMenu%MenuList[RndmbezelICMenu]
					SplitPath, currentICMenuFile,,,,ICMenuFileNameNoExt
					BezelICMenuIniFile := bezelICMenuPath . "\" . ICMenuFileNameNoExt . ".ini"
					if (RIni_Read("bezelICRini" . currentICMenu,BezelICMenuIniFile) = -11)
						RIni_Create("bezelICRini" . currentICMenu)
					IC%currentICMenu%MenuListTextFont := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Font","Bebas Neue")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Font",IC%currentICMenu%MenuListTextFont) ; set value if ini not found
					IC%currentICMenu%MenuListTextAlignment := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Alignment","Center")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Alignment",IC%currentICMenu%MenuListTextAlignment) ; set value if ini not found
					IC%currentICMenu%MenuListTextSize := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Text_Size","50")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Text_Size",IC%currentICMenu%MenuListTextSize) ; set value if ini not found
					IC%currentICMenu%MenuListDisabledTextSize := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Disabled_Text_Size","30")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Disabled_Text_Size",IC%currentICMenu%MenuListDisabledTextSize) ; set value if ini not found
					IC%currentICMenu%MenuListTextColor := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Selected_Text_Color","FF000000")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Selected_Text_Color",IC%currentICMenu%MenuListTextColor) ; set value if ini not found
					IC%currentICMenu%MenuListDisabledTextColor := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Disabled_Text_Color","FFCCCCCC")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Disabled_Text_Color",IC%currentICMenu%MenuListDisabledTextColor) ; set value if ini not found
					IC%currentICMenu%MenuListCurrentTextColor := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Current_Text_Color","FFFF00FF")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Current_Text_Color",IC%currentICMenu%MenuListCurrentTextColor) ; set value if ini not found
					IC%currentICMenu%MenuListX := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Top_X_position","20")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Top_X_position",IC%currentICMenu%MenuListX) ; set value if ini not found
					IC%currentICMenu%MenuListY := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Top_Y_position","20")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Top_Y_position",IC%currentICMenu%MenuListY) ; set value if ini not found
					IC%currentICMenu%MenuListWidth := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Width","260")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Width",IC%currentICMenu%MenuListWidth) ; set value if ini not found
					IC%currentICMenu%MenuListHeight := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Height","360")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card List Settings","Height",IC%currentICMenu%MenuListHeight) ; set value if ini not found
					IC%currentICMenu%MenuPositionTextFont := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Font","Bebas Neue")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Font",IC%currentICMenu%MenuPositionTextFont) ; set value if ini not found
					IC%currentICMenu%MenuPositionTextAlignment := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Alignment","Right")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Alignment",IC%currentICMenu%MenuPositionTextAlignment) ; set value if ini not found
					IC%currentICMenu%MenuPositionTextSize := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Text_Size","20")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Text_Size",IC%currentICMenu%MenuPositionTextSize) ; set value if ini not found				
					IC%currentICMenu%MenuPositionTextColor := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Text_Color","FFFFFFFF")
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Text_Color",IC%currentICMenu%MenuPositionTextColor) ; set value if ini not found	
					IC%currentICMenu%MenuPositionTextX := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Top_X_position",0)
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Top_X_position",IC%currentICMenu%MenuPositionTextX) ; set value if ini not found
					IC%currentICMenu%MenuPositionTextY := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Top_Y_position",bezelIC%currentICMenu%MenuBitmapH-IC%currentICMenu%MenuPositionTextSize)
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Top_Y_position",IC%currentICMenu%MenuPositionTextY) ; set value if ini not found
					IC%currentICMenu%MenuPositionTextWidth := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Width",bezelIC%currentICMenu%MenuBitmapW)
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Width",IC%currentICMenu%MenuPositionTextWidth) ; set value if ini not found
					IC%currentICMenu%MenuPositionTextHeight := RIni_GetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Height",IC%currentICMenu%MenuPositionTextSize)
					RIni_SetKeyValue("bezelICRini" . currentICMenu,"Instruction Card Screen Position Text Settings","Height",IC%currentICMenu%MenuPositionTextHeight) ; set value if ini not found
					; Saving values to ini file
					RIni_Write("bezelICRini" . currentICMenu,BezelICMenuIniFile,"`r`n",1,1,1)
					;Resizing Menu items
					XBaseRes := 1920, YBaseRes := 1080
					if (((A_screenWidth < A_screenHeight) and ((screenRotationAngle=0) or (screenRotationAngle=180))) or ((A_screenWidth > A_screenHeight) and ((screenRotationAngle=90) or (screenRotationAngle=270))))
						XBaseRes := 1080, YBaseRes := 1920
					ICMenuScreenScallingFactor := baseScreenHeight/YBaseRes
					OptionScale(IC%currentICMenu%MenuListX, ICMenuScreenScallingFactor)
					OptionScale(IC%currentICMenu%MenuListY, ICMenuScreenScallingFactor)
					OptionScale(IC%currentICMenu%MenuListWidth, ICMenuScreenScallingFactor)
					OptionScale(IC%currentICMenu%MenuListHeight, ICMenuScreenScallingFactor)
					OptionScale(IC%currentICMenu%MenuListTextSize, ICMenuScreenScallingFactor)
					OptionScale(IC%currentICMenu%MenuListDisabledTextSize, ICMenuScreenScallingFactor)
					OptionScale(IC%currentICMenu%MenuPositionTextX, ICMenuScreenScallingFactor)
					OptionScale(IC%currentICMenu%MenuPositionTextY, ICMenuScreenScallingFactor)
					OptionScale(IC%currentICMenu%MenuPositionTextWidth, ICMenuScreenScallingFactor)
					OptionScale(IC%currentICMenu%MenuPositionTextHeight, ICMenuScreenScallingFactor)
					OptionScale(bezelIC%currentICMenu%MenuBitmapW, ICMenuScreenScallingFactor)
					OptionScale(bezelIC%currentICMenu%MenuBitmapH, ICMenuScreenScallingFactor)
				}
				pGraphUpd(Bezel_G4,baseScreenWidth,baseScreenHeight)
				pGraphUpd(Bezel_G5,bezelICLeftMenuBitmapW,bezelICLeftMenuBitmapH)
				pGraphUpd(Bezel_G6,ICLeftMenuListWidth,ICLeftMenuListTextSize)
				pGraphUpd(Bezel_G7,bezelICRightMenuBitmapW,bezelICRightMenuBitmapH)
				pGraphUpd(Bezel_G8,ICRightMenuListWidth,ICRightMenuListTextSize)
			}
		}
		If bezelPath 
			{	
			;Setting ini file with bezel coordinates and reading its values
			if (bezelImageFile = "fakeFullScreenBezel"){
				bezelScreenX := 0
				bezelScreenY := 0
				bezelScreenWidth := A_ScreenWidth
				bezelScreenHeight := A_ScreenHeight
				origbezelImageW := A_ScreenWidth
				origbezelImageH := A_ScreenHeight
				bezelOrigIniScreenX1 := 0
				bezelOrigIniScreenY1 := 0
				bezelOrigIniScreenX2 := A_ScreenWidth
				bezelOrigIniScreenY2 := A_ScreenHeight
			} else {		
				ReadBezelIniFile()
				bezelScreenX1 := bezelOrigIniScreenX1
				bezelScreenY1 := bezelOrigIniScreenY1
				bezelScreenX2 := bezelOrigIniScreenX2
				bezelScreenY2 := bezelOrigIniScreenY2	
				; creating bitmap pointers
				bezelBitmap := Gdip_CreateBitmapFromFile(bezelImageFile)
				Gdip_GetImageDimensions(bezelBitmap, origbezelImageW, origbezelImageH)
				bezelImageW := origbezelImageW
				bezelImageH := origbezelImageH 
				; calculating BezelCoordinates
				if (bezelMode = "Normal")
					BezelCoordinates("Normal")
				else if (bezelMode = "MultiScreens")
					BezelCoordinates("MultiScreens")
			}
			if bezelBackgroundFile
				bezelBackgroundBitmap := Gdip_CreateBitmapFromFile(bezelBackgroundFile)
			if bezelOverlayFile
				bezelOverlayBitmap := Gdip_CreateBitmapFromFile(bezelOverlayFile)
			; Updating GUI 1 - Background - with image
			If bezelBackgroundFile
				{
				Gdip_DrawImage(Bezel_G1, bezelBackgroundBitmap, 0, 0,A_ScreenWidth+1,A_ScreenHeight+1)        
				UpdateLayeredWindow(Bezel_hwnd1, Bezel_hdc1,0,0, A_ScreenWidth, A_ScreenHeight)
				Gui, Bezel_GUI1: Show, na
				Log("Bezel - Background Screen Position: BezelImage left=" . 0 . " top=" . 0 . " right=" . A_ScreenWidth . " bottom=" . A_ScreenHeight ,5)
			}
		}
		If (bezelPath) or (bezelICPath) 
			{
			;force windowed mode
				if !disableForceFullscreen
					Fullscreen := false
		}
		Log("BezelStart - Ended")
	}
Return 
}

BezelDraw(){
	Global
	if (bezelEnabled = "true"){
		Log("BezelDraw - Started")
		;------------ bezelMode bezelLayoutFile
		if bezelLayoutFile	
			return
		If bezelPath 
			{
			;------------ bezelMode MultiScreens
			if (bezelMode = "MultiScreens") {
				; Disable windows components
				; Going to the label on the module to enable or disable emulator window manipulation codes to hide windows components, ...  
				var := "BezelLabel"
				If IsLabel(var)
					gosub, %var%
				loop, %bezelNumberOfScreens%
					{
					currentScreen := a_index
					If !disableHideTitleBarScreen%currentScreen%
						WinSet, Style, -0xC00000, % "ahk_id " . Screen%currentScreen%ID
					If !disableHideToggleMenuScreen%currentScreen%
						ToggleMenu(Screen%a_index%ID)
					If !disableHideBorderScreen%currentScreen%
						WinSet, Style, -0xC40000, % "ahk_id " . Screen%currentScreen%ID
					;Moving emulator Window to predefined bezel position
					screenPositionLogList := screenPositionLogList . "`r`n`t`t`t`t`tScreen " . currentScreen . ": left=" . bezelScreen%currentScreen%X1 . " top=" . bezelScreen%currentScreen%Y1 . " right=" . (bezelScreen%currentScreen%X1+bezelScreen%currentScreen%W) . " bottom=" . (bezelScreen%currentScreen%Y1+bezelScreen%currentScreen%H)
					If !disableWinMove
						WinMove, % "ahk_id " . Screen%currentScreen%ID, , % bezelScreen%currentScreen%X1, % bezelScreen%currentScreen%Y1, % bezelScreen%currentScreen%W, % bezelScreen%currentScreen%H
				}
				If !disableWinMove
					{
					;check if windows moved
					sleep, 200
					loop, %bezelNumberOfScreens%
						{			
						currentScreen := a_index
						X:="" , Y:="" , W:="" , H:=""
						timeout := A_TickCount
						loop
							{
							sleep, 50
							WinGetPos, X, Y, W, H, % "ahk_id " . Screen%currentScreen%ID
							if (X=bezelScreen%currentScreen%X1) and (Y=bezelScreen%currentScreen%Y1) and (W=bezelScreen%currentScreen%W) and (H=bezelScreen%currentScreen%H)
								break
							if(timeout < A_TickCount - bezelCheckPosTimeout) {
								Log("Screen " . currentScreen . " did not moved to correct bezel position. Timeout enabled.",5)
								break
							}
							sleep, 50
							WinMove, % "ahk_id " . Screen%currentScreen%ID, , % bezelScreen%currentScreen%X1, % bezelScreen%currentScreen%Y1, % bezelScreen%currentScreen%W, % bezelScreen%currentScreen%H
						}
					}
				}				
			;------------ bezelMode Normal
			} else if (bezelMode = "Normal") {
				WinGet emulatorID, ID, A
				;BezelCoordinates("Normal")
				Log("Bezel - Bezel Screen Offset: left=" . bezelLeftOffset . " top=" . bezelTopOffset . " right=" . bezelRightOffset . " bottom=" . bezelBottomOffset ,1)
				; Going to the label on the module to enable or disable emulator window manipulation codes to hide windows components, ...  
				var := "BezelLabel"
				If IsLabel(var)
					gosub, %var%
				; list of windows manipulation options that can be enabled/disabled on the BezelLabel (they are enable as default)
				If !disableHideTitleBar
					WinSet, Style, -0xC00000, A
				If !disableHideToggleMenu
					ToggleMenu(emulatorID)
				If !disableHideBorder
					WinSet, Style, -0xC40000, A
				;Moving emulator Window to predefined bezel window 
				If !disableWinMove
					{
					bezelScreenX := round(bezelScreenX) , bezelScreenY := round(bezelScreenY), bezelScreenWidth := round(bezelScreenWidth) , bezelScreenHeight := round(bezelScreenHeight)
					WinMove, ahk_id %emulatorID%, , %bezelScreenX%, %bezelScreenY%, %bezelScreenWidth%, %bezelScreenHeight%
					; check if window moved
					X:="" , Y:="" , W:="" , H:=""
					timeout := A_TickCount
					sleep, 200
					loop
						{
						sleep, 50
						WinGetPos, X, Y, W, H, ahk_id %emulatorID%
						if (X=bezelScreenX) and (Y=bezelScreenY) and (W=bezelScreenWidth) and (H=bezelScreenHeight)
							break
						if(timeout < A_TickCount - bezelCheckPosTimeout)
							break
						sleep, 50
						WinMove, ahk_id %emulatorID%, , %bezelScreenX%, %bezelScreenY%, %bezelScreenWidth%, %bezelScreenHeight%
					}
				}
			;------------ bezelMode fixResMode
			} else if (bezelMode = "fixResMode") {  ; Define coordinates for emulators that does not support custom made resolutions. 
				WinGet emulatorID, ID, A
				Log("Bezel - Emulator does not support custom made resolution. Game screen will be centered at the emulator resolution and the bezel png will be drawn around it. The bezel image will be croped if its resolution is bigger them the screen resolution.",1)
				X:="" , Y:="" , W:="" , H:=""
				timeout := A_TickCount
				loop 
					{
					sleep, 50
					WinGetPos, bezelScreenX, bezelScreenY, bezelScreenWidth, bezelScreenHeight, A
					if bezelScreenX and bezelScreenY and bezelScreenWidth and bezelScreenHeight
						break
					if(timeout < A_TickCount - bezelCheckPosTimeout)
						break
				}
				Log("Bezel - Emulator Screen Position: left=" . bezelScreenX . " top=" . bezelScreenY . " width=" . bezelScreenWidth . " height=" . bezelScreenHeight ,5)
				BezelCoordinates("fixResMode")
				Log("Bezel - Screen Offset: left=" . bezelLeftOffset . " top=" . bezelTopOffset . " right=" . bezelRightOffset . " bottom=" . bezelBottomOffset ,1)
				; Going to the label on the module to enable or disable emulator window manipulation codes to hide windows components, ...  
				var := "BezelLabel"
				If IsLabel(var)
					gosub, %var%
				; list of windows manipulation options that can be enabled/disabled on the BezelLabel (they are enable as default)
				If !disableHideTitleBar
					WinSet, Style, -0xC00000, A
				If !disableHideToggleMenu
					ToggleMenu(emulatorID)
				If !disableHideBorder
					WinSet, Style, -0xC40000, A
				;Moving emulator Window to predefined bezel window 
				If !disableWinMove
					{
					bezelScreenX := round(bezelScreenX) , bezelScreenY := round(bezelScreenY)
					WinMove, ahk_id %emulatorID%, , %bezelScreenX%, %bezelScreenY%
					; check if window moved
					X:="" , Y:="" 
					timeout := A_TickCount
					sleep, 200
					loop
						{
						sleep, 50
						WinGetPos, X, Y, , , ahk_id %emulatorID%
						if (X=bezelScreenX) and (Y=bezelScreenY) 
							break
						if(timeout < A_TickCount - bezelCheckPosTimeout)
							break
						sleep, 50
						WinMove, ahk_id %emulatorID%, , %bezelScreenX%, %bezelScreenY%
					}
				}
			}
			;Drawing Bezel GUI
			if !(bezelImageFile = "fakeFullScreenBezel"){
				Gdip_DrawImage(Bezel_G3, bezelBitmap, bezelImageX, bezelImageY,bezelImageW,bezelImageH)        
				if !bezelLoaded
					UpdateLayeredWindow(Bezel_hwnd3, Bezel_hdc3,0,0, A_ScreenWidth, A_ScreenHeight)
				Log("Bezel - Bezel Image Screen Position: BezelImage left=" . bezelImageX . " top=" . bezelImageY . " right=" . (bezelImageX+bezelImageW) . " bottom=" . (bezelImageY+bezelImageH)  ,5)	
				if (bezelMode = "MultiScreens")
					Log("Bezel - Game Screen Position:" . screenPositionLogList, 4)
				else
					Log("Bezel - Game Screen Position: BezelImage left=" . bezelScreenX . " top=" . bezelScreenY . " right=" . (bezelScreenX+bezelScreenWidth) . " bottom=" . (bezelScreenY+bezelScreenHeight) ,5)	
			}
			;Drawing Overlay Image above screen
			If bezelOverlayFile
				{
				if (bezelMode = "MultiScreens") {
					loop, %bezelNumberOfScreens%
						Gdip_DrawImage(Bezel_G2, bezelOverlayBitmap, bezelScreen%A_Index%X1, bezelScreen%A_Index%Y1,bezelScreen%A_Index%W,bezelScreen%A_Index%H)     		
					if !bezelLoaded
						UpdateLayeredWindow(Bezel_hwnd2, Bezel_hdc2,0,0, A_ScreenWidth, A_ScreenHeight)
				} else {
					Gdip_DrawImage(Bezel_G2, bezelOverlayBitmap, 0, 0,bezelScreenWidth,bezelScreenHeight)        
					if !bezelLoaded
						UpdateLayeredWindow(Bezel_hwnd2, Bezel_hdc2,bezelScreenX,bezelScreenY, bezelScreenWidth, bezelScreenHeight)
					Log("Bezel - Overlay Screen Position: BezelImage left=" . bezelScreenX . " top=" . bezelScreenY . " right=" . (bezelScreenX+bezelScreenWidth) . " bottom=" . (bezelScreenY+bezelScreenHeight) ,5)	
				}
			}
			if !bezelLoaded
				{
				;Initializing Instruction Cards Keys
				gosub, EnableBezelKeys
				;Initializing bezel change
				if (bezelImagesList.MaxIndex() > 1) {
					if nextBezelKey
						{
						nextBezelKey := xHotKeyVarEdit(nextBezelKey,"nextBezelKey","~","Add")
						XHotKeywrapper(nextBezelKey,"nextBezel")
					}
					if previousBezelKey
						{
						previousBezelKey := xHotKeyVarEdit(previousBezelKey,"previousBezelKey","~","Add")
						XHotKeywrapper(previousBezelKey,"previousBezel")
					}
				}
				;Creating bezel background timer
				if (bezelBackgroundsList.MaxIndex() > 1)
					if bezelBackgroundChangeDur
						settimer, BezelBackgroundTimer, %bezelBackgroundChangeDur%
			}
		}
		if bezelICPath
			{
			Loop, 8
				if maxICimage[a_index]
					selectedICimage[a_index] := 1
			if ((ICSaveSelected="true") and (FileExist(Bezel_RomFile))) {
				loop, 8
					if maxICimage[a_index]
						{
						selectedIndex := RIni_GetKeyValue("BezelRomRini","Instruction Cards","Initial_Card_" . a_index . "_Index")
						selectedICimage[a_index] := if (selectedIndex = -2) or (selectedIndex = -3) ? 1 :  selectedIndex
					}
			}
			if (displayICOnStartup = "true") {
				loop, 8
					{
					if maxICimage[a_index]
						{

						DrawIC()
					}
				}
			} else if (displayICOnStartup = "Random") {
				gosub, randomICChange
			}
			if %ICRandomSlideShowTimer%
				SetTimer, randomICChange, %ICRandomSlideShowTimer%
		}
		bezelLoaded := true
		Log("BezelDraw - Ended")
	}
Return
}

BezelExit(){
	Global
	if (bezelEnabled = "true"){
		Log("BezelExit - Started")
		If bezelPath 
			{
			log("Bezel - Removing bezel image components to exit HyperLaunch.",1)
			;Deleting pointers and destroying GUis
			loop, 8 {
				SelectObject(Bezel_hdc%A_Index%, Bezel_obm%A_Index%)
				DeleteObject(Bezel_hbm%A_Index%)
				DeleteDC(Bezel_hdc%A_Index%)
				Gdip_DeleteGraphics(Bezel_G%A_Index%)
				Gui, Bezel_GUI%A_Index%: Destroy
			}
			if bezelBitmap
				Gdip_DisposeImage(bezelBitmap)
			if bezelBackgroundFile
				Gdip_DisposeImage(bezelBackgroundBitmap)
			if bezelOverlayFile
				Gdip_DisposeImage(bezelOverlayBitmap) 
			if BezelBackgroundChangeLoaded
				Gdip_DisposeImage(preRndmBezelBackground) 
			if bezelICPath
				{
				loop, 8
					{
					currentICPositionIndex := a_index
					loop, %numberofICImages%
						{
						if bezelICArray[currentICPositionIndex,a_index,2]
							Gdip_DisposeImage(bezelICArray[currentICPositionIndex,a_index,2])
					}
				}
			}
			if (bezelSaveSelected="true") {
				RIni_SetKeyValue("BezelRomRini","Bezel Change","Initial_Bezel_Index",RndmBezel)	
				updateBezel_RomFile := true
			}
		}
		if bezelICPath
			{
			if (ICSaveSelected="true"){
				Loop, 8
					RIni_SetKeyValue("BezelRomRini","Instruction Cards","Initial_Card_" . a_index . "_Index",selectedICimage[a_index])
				updateBezel_RomFile := true
			}
		}
		if updateBezel_RomFile
			{
			SplitPath, Bezel_RomFile, , Bezel_RomFilePath
			FileCreateDir, % Bezel_RomFilePath
			RIni_Write("BezelRomRini",Bezel_RomFile,"`r`n",1,1,1)
		}
		Log("BezelExit - Ended")
	}
Return
}


ReadBezelIniFile(){
	Global
	StringTrimRight, bezelIniFile, bezelImageFile, 4
	bezelIniFile := bezelIniFile . ".ini"
	If !FileExist(bezelIniFile)
		Log("Bezel - Bezel Ini file not found. Creating the file " . bezelIniFile . " with full screen coordinates. You should edit the ini file to enter the coordinates in pixels of the screen emulator location on the bezel image.",2)
	bezelOrigIniScreenX1 := IniReadCheck(bezelIniFile, "General", "Bezel Screen Top Left X Coordinate", 0)
	bezelOrigIniScreenY1 := IniReadCheck(bezelIniFile, "General", "Bezel Screen Top Left Y Coordinate", 0)
	bezelOrigIniScreenX2 := IniReadCheck(bezelIniFile, "General", "Bezel Screen Bottom Right X Coordinate", A_ScreenWidth)
	bezelOrigIniScreenY2 := IniReadCheck(bezelIniFile, "General", "Bezel Screen Bottom Right Y Coordinate", A_ScreenHeight)
	Log("Bezel - Bezel ini file found. Defined screen positions: X1=" . bezelOrigIniScreenX1 . " Y1=" . bezelOrigIniScreenY1 . " X2=" . bezelOrigIniScreenX2 . " Y2=" . bezelOrigIniScreenY2 ,5)	
	;reading additional screens info
	if (bezelMode = "MultiScreens") {
		loop, % bezelNumberOfScreens-1
			{
			currentScreen := a_index+1
			bezelScreen%currentScreen%X1 := IniReadCheck(bezelIniFile, "General", "Bezel Screen " . currentScreen . " Top Left X Coordinate", 0)
			bezelScreen%currentScreen%Y1 := IniReadCheck(bezelIniFile, "General", "Bezel Screen " . currentScreen . " Top Left Y Coordinate", 0)
			bezelScreen%currentScreen%X2 := IniReadCheck(bezelIniFile, "General", "Bezel Screen " . currentScreen . " Bottom Right X Coordinate", 0)
			bezelScreen%currentScreen%Y2 := IniReadCheck(bezelIniFile, "General", "Bezel Screen " . currentScreen . " Bottom Right Y Coordinate", 0)
		}
	}
return
}

BezelCoordinates(CoordinatesMode){
	Global
	if (CoordinatesMode = "Normal"){
		; Resizing bezel transparent area to the screen resolution (image is stretched to Center screen, keeping aspect)
		widthMaxPerc := ( A_ScreenWidth / bezelImageW )	; get the percentage needed to maximise the image so the higher dimension reaches the screen's edge
		heightMaxPerc := ( A_ScreenHeight / bezelImageH )
		scaleFactor := If (widthMaxPerc < heightMaxPerc) ? widthMaxPerc : heightMaxPerc
		bezelImageW := Round(bezelImageW * scaleFactor)
		bezelImageH := Round(bezelImageH * scaleFactor)
		bezelImageX := Round( ( A_ScreenWidth - bezelImageW ) // 2 )
		bezelImageY := Round( ( A_ScreenHeight - bezelImageH ) // 2 )
		; Defining emulator position 
		bezelScreenX := Round ( bezelImageX + (bezelScreenX1 * scaleFactor) )
		bezelScreenY := Round ( bezelImageY + (bezelScreenY1 * scaleFactor) )
		bezelScreenWidth := Round( (bezelScreenX2-bezelScreenX1)* scaleFactor )
		bezelScreenHeight := Round( (bezelScreenY2-bezelScreenY1)* scaleFactor )
		; Applying offsets to correctly place the emulator if the emulator has extra window components
		bezelScreenX := if bezelLeftOffset ? bezelScreenX - bezelLeftOffset : bezelScreenX
		bezelScreenY := if bezelTopOffset ? bezelScreenY - bezelTopOffset : bezelScreenY
		bezelScreenWidth := if bezelRightOffset ? ( if bezelLeftOffset ? bezelScreenWidth + bezelRightOffset + bezelLeftOffset : bezelScreenWidth + bezelRightOffset ) : ( if bezelLeftOffset ? bezelScreenWidth + bezelLeftOffset : bezelScreenWidth )
		bezelScreenHeight := if bezelTopOffset ? ( if bezelBottomOffset ? bezelScreenHeight + bezelTopOffset + bezelBottomOffset : bezelScreenHeight + bezelTopOffset ) : ( if bezelBottomOffset ? bezelScreenHeight + bezelBottomOffset : bezelScreenHeight )
		bezelScreenX := round(bezelScreenX) , bezelScreenY := round(bezelScreenY), bezelScreenWidth := round(bezelScreenWidth) , bezelScreenHeight := round(bezelScreenHeight)
	} else if (CoordinatesMode = "MultiScreens") {
		; Resizing bezel transparent area to the screen resolution (image is stretched to Center screen, keeping aspect)
		widthMaxPerc := ( A_ScreenWidth / bezelImageW )	; get the percentage needed to maximise the image so the higher dimension reaches the screen's edge
		heightMaxPerc := ( A_ScreenHeight / bezelImageH )
		scaleFactor := If (widthMaxPerc < heightMaxPerc) ? widthMaxPerc : heightMaxPerc
		bezelImageW := Round(bezelImageW * scaleFactor)
		bezelImageH := Round(bezelImageH * scaleFactor)
		bezelImageX := Round( ( A_ScreenWidth - bezelImageW ) // 2 )
		bezelImageY := Round( ( A_ScreenHeight - bezelImageH ) // 2 )
		; Defining emulator position 
		bezelScreen1X1 := bezelScreenX1
		bezelScreen1Y1 := bezelScreenY1
		bezelScreen1X2 := bezelScreenX2
		bezelScreen1Y2 := bezelScreenY2	
		loop, %bezelNumberOfScreens%
			{
			bezelScreen%a_index%W := Round((bezelScreen%a_index%X2-bezelScreen%a_index%X1)*scaleFactor) 
			bezelScreen%a_index%H := Round((bezelScreen%a_index%Y2-bezelScreen%a_index%Y1)*scaleFactor) 
			bezelScreen%a_index%X1 := Round(bezelImageX+bezelScreen%a_index%X1*scaleFactor)	 
			bezelScreen%a_index%Y1 := Round(bezelImageY+bezelScreen%a_index%Y1*scaleFactor)	 
			; Applying offsets to correctly place the emulator if the emulator has extra window components
			bezelScreen%a_index%X1 := if bezelLeftOffsetScreen%a_index% ? bezelScreen%a_index%X1 - bezelLeftOffsetScreen%a_index% : bezelScreen%a_index%X1
			bezelScreen%a_index%Y1 := if bezelTopOffsetScreen%a_index% ? bezelScreen%a_index%Y1 - bezelTopOffsetScreen%a_index% : bezelScreen%a_index%Y1
			bezelScreen%a_index%W := if bezelRightOffsetScreen%a_index% ? ( if bezelLeftOffsetScreen%a_index% ? bezelScreen%a_index%W + bezelRightOffsetScreen%a_index% + bezelLeftOffsetScreen%a_index% : bezelScreen%a_index%W + bezelRightOffsetScreen%a_index% ) : ( if bezelLeftOffsetScreen%a_index% ? bezelScreen%a_index%W + bezelLeftOffsetScreen%a_index% : bezelScreen%a_index%W )
			bezelScreen%a_index%H := if bezelTopOffsetScreen%a_index% ? ( if bezelBottomOffsetScreen%a_index% ? bezelScreen%a_index%H + bezelTopOffsetScreen%a_index% + bezelBottomOffsetScreen%a_index% : bezelScreen%a_index%H + bezelTopOffsetScreen%a_index% ) : ( if bezelBottomOffsetScreen%a_index% ? bezelScreen%a_index%H + bezelBottomOffsetScreen%a_index% : bezelScreen%a_index%H )
			bezelScreen%a_index%X1 := round(bezelScreen%a_index%X1) , bezelScreen%a_index%Y1 := round(bezelScreen%a_index%Y1), bezelScreen%a_index%W := round(bezelScreen%a_index%W) , bezelScreen%a_index%H := round(bezelScreen%a_index%H)			
			log("Emulator Screen " . a_index . " position on bezel: X=" . bezelScreen%a_index%X1 . " Y=" . bezelScreen%a_index%Y1 . " W=" . bezelScreen%a_index%W . " H=" . bezelScreen%a_index%H ,5)
		}
	} else if (CoordinatesMode = "fixResMode") {
		bezelScreenWidth := if bezelRightOffset ? ( if bezelLeftOffset ? bezelScreenWidth - bezelRightOffset - bezelLeftOffset : bezelScreenWidth - bezelRightOffset ) : ( if bezelLeftOffset ? bezelScreenWidth - bezelLeftOffset : bezelScreenWidth )
		bezelScreenHeight := if bezelTopOffset ? ( if bezelBottomOffset ? bezelScreenHeight - bezelTopOffset - bezelBottomOffset : bezelScreenHeight - bezelTopOffset ) : ( if bezelBottomOffset ? bezelScreenHeight - bezelBottomOffset : bezelScreenHeight )
		bezelScreenX:= Round((A_ScreenWidth-bezelScreenWidth)/2)
		bezelScreenY:= Round((A_ScreenHeight-bezelScreenHeight)/2) 
		bezelScreenX := if bezelLeftOffset ? bezelScreenX - bezelLeftOffset : bezelScreenX
		bezelScreenY := if bezelTopOffset ? bezelScreenY - bezelTopOffset : bezelScreenY
		xScaleFactor := (bezelScreenWidth)/(bezelScreenX2-bezelScreenX1)
		yScaleFactor := (bezelScreenHeight)/(bezelScreenY2-bezelScreenY1)
		bezelImageW := Round(bezelImageW * xScaleFactor)
		bezelImageH := Round(bezelImageH * yScaleFactor) 
		bezelImageX := Round( (A_ScreenWidth-(bezelScreenX2-bezelScreenX1)*xScaleFactor)//2-bezelScreenX1*xScaleFactor )
		bezelImageY := Round( (A_ScreenHeight-(bezelScreenY2-bezelScreenY1)*yScaleFactor)//2-bezelScreenY1*yScaleFactor )		
	}
Return
}


RndBezelFilePath(filename,excludeScreens=false,useBkgdPath=false){
	Global HLMediaPath, systemName, dbName, vertical, dbCloneOf, feMedia
	bezelFileList := []
	bezelFileList := GetRndBezelFile(HLMediaPath . "\Bezels\" . systemName . "\" . dbName . "\" . filename,excludeScreens)
	If !bezelFileList[1]
		bezelFileList := GetRndBezelFile(HLMediaPath . "\Bezels\" . systemName . "\" . dbCloneOf . "\" . filename,excludeScreens)
	If !bezelFileList[1]
	{ If (vertical = "true")
		bezelFileList := GetRndBezelFile(HLMediaPath . "\Bezels\" . systemName . "\_Default\Vertical\" . filename,excludeScreens)
		else
		bezelFileList := GetRndBezelFile(HLMediaPath . "\Bezels\" . systemName . "\_Default\Horizontal\" . filename,excludeScreens)	
	}
	If ((useBkgdPath) and (!(bezelFileList[1])))
		bezelFileList := GetRndBezelFile(HLMediaPath . "\Backgrounds\" . systemName . "\" . dbName . "\",false)
	If ((useBkgdPath) and (!(bezelFileList[1])))
	{	for index, element in feMedia["Backgrounds"]
		{   if element.Label
			{   if (element.AssetType="game")
				{   loop, % element.TotalItems    
					{    bezelFileList.Insert(element["Path" . a_index])
					}
				}
			}
		}
	}
	If !bezelFileList[1]
		bezelFileList := GetRndBezelFile(HLMediaPath . "\Bezels\" . systemName . "\_Default\" . filename,excludeScreens)
	If ((useBkgdPath) and (!(bezelFileList[1])))
		bezelFileList := GetRndBezelFile(HLMediaPath . "\Backgrounds\" . systemName . "\_Default\",false)
	If ((useBkgdPath) and (!(bezelFileList[1])))
	{	for index, element in feMedia["Backgrounds"]
		{   if element.Label
			{   if (element.AssetType="system")
				{   loop, % element.TotalItems    
					{    bezelFileList.Insert(element["Path" . a_index])
					}
				}
			}
		}
	}
	If !bezelFileList[1]
		bezelFileList := GetRndBezelFile(HLMediaPath . "\Bezels\_Default\" . filename,excludeScreens)
	If ((useBkgdPath) and (!(bezelFileList[1])))
		bezelFileList := GetRndBezelFile(HLMediaPath . "\Backgrounds\_Default\",false)
	
	If bezelFileList[1]
	{	Random, RndmBezelBackground, 1, % bezelFileList.MaxIndex()
		file := bezelFileList[RndmBezelBackground]
		Log("Bezel - Random " . filename . " art choosen in path: " . file,4)
		Return file
	} Else {
		Log("Bezel - Bezels are enabled, however none of the below valid " . filename . " files, with extensions " . fileextension . " exist: " . "`n`t`t`t`t`t" . HLMediaPath . "\Bezels\" . systemName . "\" . dbName . "\" . filename  . "*.ext`n`t`t`t`t`t" . HLMediaPath . "\Bezels\" . systemName . "\_Default\Vertical\" . filename  . "*.ext`n`t`t`t`t`t" . HLMediaPath . "\Bezels\" . systemName . "\_Default\Horizontal\" . filename  . "*.ext`n`t`t`t`t`t" . HLMediaPath . "\Bezels\" . systemName . "\_Default\" . filename  . "*.ext`n`t`t`t`t`t" . HLMediaPath . "\Bezels\_Default\" . filename  . "*.ext",2)
	}
				
}


GetRndBezelFile(path,excludeScreens){
	Global bezelFileExtensions
	bezelPicList := []
	If (FileExist(path . "*.*")) {
		Loop, Parse, bezelFileExtensions,|
		{	Log("Bezel - Looking for Bezel pic: " . path . "*." . A_LoopField,4)
			Loop, % path . "*." . A_LoopField
			{	If excludeScreens
					{
					If !RegExMatch(A_LoopFileName, "i)\[[0-9]+S\]")
						{
						Log("Bezel - Found Bezel pic: " . A_LoopFileFullPath,4)
						bezelPicList.Insert(A_LoopFileFullPath)
					}
				} Else {
					Log("Bezel - Found Bezel pic: " . A_LoopFileFullPath,4)
					bezelPicList.Insert(A_LoopFileFullPath)
				}
			}
		}
	}
	Return bezelPicList
}



			
BezelFilesPath(filename,fileextension,excludeScreens=false)
{
	Global HLMediaPath, systemName, dbName, vertical
	Global dbCloneOf
	bezelpath1 := HLMediaPath . "\Bezels\" . systemName . "\" . dbName
	If dbCloneOf
		bezelpath2 := HLMediaPath . "\Bezels\" . systemName . "\" . dbCloneOf
	If (vertical = "true")
		bezelpath3 := HLMediaPath . "\Bezels\" . systemName . "\_Default\Vertical"
	Else
		bezelpath3 := HLMediaPath . "\Bezels\" . systemName . "\_Default\Horizontal"
	bezelpath4 := HLMediaPath . "\Bezels\" . systemName . "\_Default"
	bezelpath5 := HLMediaPath . "\Bezels\_Default"
	bezelpath6 := HLMediaPath . "\Bezels\" . systemName . "\" . dbName
	Loop, 6 {
		If bezelpath%a_index%
			{
			Log("Bezel - Looking for " . filename . " in: " . bezelpath%A_Index%,4)
			currentbezelpathNumber := a_index
			Loop, Parse, fileextension,|
			{
				Loop % bezelpath%currentbezelpathNumber% . "\" . filename . "*." . A_LoopField
					{
					If excludeScreens
						{
						If !RegExMatch(A_LoopFileName, "i)\[[0-9]+S\]")
							{
							Log("Bezel - Found " . filename . " art in folder: " . bezelpath%currentbezelpathNumber%,4)
							bezelPathFound := bezelpath%currentbezelpathNumber%
							break
						}
					} Else {
						Log("Bezel - Found " . filename . " art in folder: " . bezelpath%currentbezelpathNumber%,4)
						bezelPathFound := bezelpath%currentbezelpathNumber%
						break
					}
				}
			}
			If bezelPathFound
				break
		}
	}
	If !bezelPathFound
		log("Bezel - Bezels are enabled, however none of the below valid " . filename . " files, with extensions " . fileextension . " exist: " . "`n`t`t`t`t`t" . HLMediaPath . "\Bezels\" . systemName . "\" . dbName . "\" . filename  . "*.ext`n`t`t`t`t`t" . HLMediaPath . "\Bezels\" . systemName . "\_Default\Vertical\" . filename  . "*.ext`n`t`t`t`t`t" . HLMediaPath . "\Bezels\" . systemName . "\_Default\Horizontal\" . filename  . "*.ext`n`t`t`t`t`t" . HLMediaPath . "\Bezels\" . systemName . "\_Default\" . filename  . "*.ext`n`t`t`t`t`t" . HLMediaPath . "\Bezels\_Default\" . filename  . "*.ext",2)
	Return bezelPathFound
}		


;Function to load ini values
RIniBezelLoadVar(gRIniVar,sRIniVar,rRIniVar,gsec,gkey,gdefaultvalue="",ssec=0,skey=0,sdefaultvalue="use_global",rdefaultvalue="use_global") {
    Global
    if not ssec
        ssec := gsec
    if not skey
        skey := gkey
	X1 := RIni_GetKeyValue(gRIniVar,gsec,gkey)
	X1 := If (X1 = -2) or (X1 = -3) ? gdefaultvalue :  X1
	X2 := RIni_GetKeyValue(sRIniVar,ssec,skey)
	X2 := If (X2 = -2) or (X2 = -3) ? sdefaultvalue :  X2
	X3 := RIni_GetKeyValue(rRIniVar,ssec,skey)
	X3 := If (X3 = -2) or (X3 = -3) ? rdefaultvalue :  X3
	X4 := (If (X3 = "use_global")  ? (If (X2 = "use_global") ? (X1) : (X2)) : (X3))	
	RIni_SetKeyValue(gRIniVar,gsec,gkey,X1)
    RIni_SetKeyValue(sRIniVar,ssec,skey,X2)
	RIni_SetKeyValue(rRIniVar,ssec,skey,X3)
    BezelVarLog .= "`r`n`t`t`t`t`t" . "[" . gsec . "] " . gkey . " = " . X4
	Return X4
}


; Bezel Change Code 
BezelBackgroundTimer:
	BezelBackgroundChangeLoaded := true
	preRndmBezelBackground := RndmBezelBackground
	RndmBezelBackground := RndmBezelBackground + 1
	if (RndmBezelBackground > bezelBackgroundsList.MaxIndex())
		RndmBezelBackground := 1
	prebezelBackgroundfile := bezelBackgroundsList[preRndmBezelBackground] 
	bezelBackgroundfile := bezelBackgroundsList[RndmBezelBackground]
	prebezelBackgroundBitmap := Gdip_CreateBitmapFromFile(prebezelBackgroundfile)
	bezelBackgroundBitmap := Gdip_CreateBitmapFromFile(bezelBackgroundFile)
	if (bezelBackgroundTransition="fade"){
		;fade in
		startTime := A_TickCount
		Loop {
			Gdip_GraphicsClear(Bezel_G1)
			t := if ((TimeElapsed := A_TickCount-startTime) < bezelBackgroundTransitionDur) ? ((timeElapsed/bezelBackgroundTransitionDur)) : 1
			Gdip_DrawImage(Bezel_G1, prebezelBackgroundBitmap, 0, 0,A_ScreenWidth,A_ScreenHeight)    
			Gdip_DrawImage(Bezel_G1, bezelBackgroundBitmap, 0, 0,A_ScreenWidth,A_ScreenHeight,"","","","",t) 
			UpdateLayeredWindow(Bezel_hwnd1, Bezel_hdc1,0,0, A_ScreenWidth, A_ScreenHeight)
			If (t >= 1)
				Break
		}				
	} else {
		Gdip_GraphicsClear(Bezel_G1)
		Gdip_DrawImage(Bezel_G1, bezelBackgroundBitmap, 0, 0,A_ScreenWidth,A_ScreenHeight)    
		UpdateLayeredWindow(Bezel_hwnd1, Bezel_hdc1,0,0, A_ScreenWidth, A_ScreenHeight)		
	}
return


NextBezel:
PreviousBezel:
if bezelPath
	{
	if bezelLayoutFile
		return
	if (A_ThisLabel="NextBezel") {
		RndmBezel := RndmBezel + 1
		if (RndmBezel > bezelImagesList.MaxIndex()){
			RndmBezel := 1
		}
	} else if (A_ThisLabel="PreviousBezel") {
		RndmBezel := RndmBezel - 1
		if (RndmBezel < 1){
			RndmBezel := bezelImagesList.MaxIndex()
		}
	}
	;fade out
	startTime := A_TickCount
	Loop {
		t := if ((TimeElapsed := A_TickCount-startTime) < bezelChangeDur) ? (255*(1-(timeElapsed/bezelChangeDur))) : 0
		If bezelOverlayFile
			{
			if (bezelMode = "MultiScreens") {
				Gdip_GraphicsClear(Bezel_G2)
				loop, %bezelNumberOfScreens%
					Gdip_DrawImage(Bezel_G2, bezelOverlayBitmap, bezelScreen%A_Index%X1, bezelScreen%A_Index%Y1,bezelScreen%A_Index%W,bezelScreen%A_Index%H)     		
				UpdateLayeredWindow(Bezel_hwnd2, Bezel_hdc2,0,0, A_ScreenWidth, A_ScreenHeight,t)
			} else {
				Gdip_GraphicsClear(Bezel_G2)
				Gdip_DrawImage(Bezel_G2, bezelOverlayBitmap, 0, 0,bezelScreenWidth,bezelScreenHeight)
				UpdateLayeredWindow(Bezel_hwnd2, Bezel_hdc2,bezelScreenX,bezelScreenY, bezelScreenWidth, bezelScreenHeight,t)	
			}
		}
		Gdip_GraphicsClear(Bezel_G3)
		if (bezelImageFile = "fakeFullScreenBezel"){
			Gdip_DrawImage(Bezel_G3, bezelBitmap, bezelImageX, bezelImageY,bezelImageW,bezelImageH)
			UpdateLayeredWindow(Bezel_hwnd3, Bezel_hdc3,0,0, A_ScreenWidth, A_ScreenHeight,t)
		}
		WinSet, Transparent, %t%, ahk_id %emulatorID%
		If (t <= 0)
			Break
	}
	prevbezelImageW := origbezelImageW
	prevbezelImageH := origbezelImageH
	prevbezelOrigIniScreenX1 := bezelOrigIniScreenX1
	prevbezelOrigIniScreenY1 := bezelOrigIniScreenY1
	prevbezelOrigIniScreenX2 := bezelOrigIniScreenX2
	prevbezelOrigIniScreenY2 := bezelOrigIniScreenY2		
	bezelImageFile := bezelImagesList[RndmBezel]	
	bezelBitmap := Gdip_CreateBitmapFromFile(bezelImageFile)
	Gdip_GetImageDimensions(bezelBitmap, origbezelImageW, origbezelImageH)
	ReadBezelIniFile()
	WinActivate, ahk_id %emulatorID%
	Gdip_GraphicsClear(Bezel_G2)
	Gdip_GraphicsClear(Bezel_G3)
	if ((prevbezelImageW=origbezelImageW) and (prevbezelImageH = origbezelImageH) and (prevbezelOrigIniScreenX1 = bezelOrigIniScreenX1) and (prevbezelOrigIniScreenY1 = bezelOrigIniScreenY1) and (prevbezelOrigIniScreenX2 = bezelOrigIniScreenX2) and (prevbezelOrigIniScreenY2 = bezelOrigIniScreenY2) )	{ ;just replace bezel image
		if !(bezelImageFile = "fakeFullScreenBezel")
			Gdip_DrawImage(Bezel_G3, bezelBitmap, bezelImageX, bezelImageY,bezelImageW,bezelImageH)        
		;Drawing Overlay Image above screen
		If bezelOverlayFile
			if (bezelMode = "MultiScreens")
				Gdip_DrawImage(Bezel_G2, bezelOverlayBitmap, bezelScreen%A_Index%X1, bezelScreen%A_Index%Y1,bezelScreen%A_Index%W,bezelScreen%A_Index%H)     		
			else
				Gdip_DrawImage(Bezel_G2, bezelOverlayBitmap, 0, 0,bezelScreenWidth,bezelScreenHeight)
	} else { ; recalculate everything bezel related
		bezelImageW := origbezelImageW 
		bezelImageH := origbezelImageH 
		bezelScreenX1 := bezelOrigIniScreenX1
		bezelScreenY1 := bezelOrigIniScreenY1
		bezelScreenX2 := bezelOrigIniScreenX2
		bezelScreenY2 := bezelOrigIniScreenY2	
		ToggleMenu(emulatorID)
		if (bezelMode = "Normal")
			BezelCoordinates("Normal")			
		BezelDraw()
	}
	;fade in
	startTime := A_TickCount
	Loop {
		t := if ((TimeElapsed := A_TickCount-startTime) < bezelChangeDur) ? (255*(timeElapsed/bezelChangeDur)) : 255
		If bezelOverlayFile
			{
			if (bezelMode = "MultiScreens") {
				Gdip_GraphicsClear(Bezel_G2)
				loop, %bezelNumberOfScreens%
					Gdip_DrawImage(Bezel_G2, bezelOverlayBitmap, bezelScreen%A_Index%X1, bezelScreen%A_Index%Y1,bezelScreen%A_Index%W,bezelScreen%A_Index%H)     		
					UpdateLayeredWindow(Bezel_hwnd2, Bezel_hdc2,0,0, A_ScreenWidth, A_ScreenHeight,t)
			} else {
				Gdip_GraphicsClear(Bezel_G2)
				Gdip_DrawImage(Bezel_G2, bezelOverlayBitmap, 0, 0,bezelScreenWidth,bezelScreenHeight)
				UpdateLayeredWindow(Bezel_hwnd2, Bezel_hdc2,bezelScreenX,bezelScreenY, bezelScreenWidth, bezelScreenHeight,t)	
			}
		}
		Gdip_GraphicsClear(Bezel_G3)
		if !(bezelImageFile = "fakeFullScreenBezel")
			Gdip_DrawImage(Bezel_G3, bezelBitmap, bezelImageX, bezelImageY,bezelImageW,bezelImageH)  
		UpdateLayeredWindow(Bezel_hwnd3, Bezel_hdc3,0,0, A_ScreenWidth, A_ScreenHeight,t)
		WinSet, Transparent, %t%, ahk_id %emulatorID%
		If (t >= 255)
			Break
	}		
}	
return


;Instruction Cards Code
toogleICVisibility:
	if ICVisibilityOn
		{
		gosub, DisableBezelKeys
		if ICRightMenuDraw 
			gosub, DisableICRightMenuKeys
		if ICLeftMenuDraw
			gosub, DisableICLeftMenuKeys
		XHotKeywrapper(toogleICVisibilityKey,"toogleICVisibility", "ON")
		startTime := A_TickCount
		Loop {
			t := if ((TimeElapsed := A_TickCount-startTime) < ICChangeDur) ? ((1-(timeElapsed/ICChangeDur))) : 0
			Alt_UpdateLayeredWindow(Bezel_hwnd4, Bezel_hdc4,0,0, baseScreenWidth, baseScreenHeight, round(255*t))
			If (t <= 0){
				Alt_UpdateLayeredWindow(Bezel_hwnd4, Bezel_hdc4,0,0, baseScreenWidth, baseScreenHeight,  0)
				Break
			}
		}
		ICVisibilityOn := false
		} else {
		gosub, EnableBezelKeys
		if ICRightMenuDraw 
			gosub, EnableICRightMenuKeys
		if ICLeftMenuDraw
			gosub, EnableICLeftMenuKeys
		startTime := A_TickCount
		Loop {
			t := if ((TimeElapsed := A_TickCount-startTime) < ICChangeDur) ? ((timeElapsed/ICChangeDur)) : 1
			Alt_UpdateLayeredWindow(Bezel_hwnd4, Bezel_hdc4,0,0, baseScreenWidth, baseScreenHeight, round(255*t))
			If (t >= 1){
				Alt_UpdateLayeredWindow(Bezel_hwnd4, Bezel_hdc4,0,0, baseScreenWidth, baseScreenHeight)
				Break
			}
		}
		ICVisibilityOn := true
	}
return


nextIC1:
nextIC2:
nextIC3:
nextIC4:
nextIC5:
nextIC6:
nextIC7:
nextIC8:
previousIC1:
previousIC2:
previousIC3:
previousIC4:
previousIC5:
previousIC6:
previousIC7:
previousIC8:
	if %ICRandomSlideShowTimer%
		{
		SetTimer, randomICChange, off
		ICRandomSlideShowTimer := 0
		Return
	}
	StringTrimRight, currentICChange, A_ThisLabel, 1
	StringRight, currentICChangeKeyPressed, A_ThisLabel, 1
	activeIC := 0
	ICindex := 0
	loop, 8
		{
		if bezelICArray[a_index,1,1]
			ICindex++
		if (ICindex = currentICChangeKeyPressed)
			{
			activeIC := a_index
			break
		}
	}
	if (currentICChange="nextIC"){
		gosub, nextIC		
	} else {
		gosub, previousIC		
	}
return
		
nextIC:
previousIC:
	if %ICRandomSlideShowTimer%
		{
		SetTimer, randomICChange, off
		ICRandomSlideShowTimer := 0
		Return
	}
	prevSelectedICimage[activeIC] := selectedICimage[activeIC]
	if (A_ThisLabel="nextIC") {
		selectedICimage[activeIC] := selectedICimage[activeIC] + 1
		if (selectedICimage[activeIC] > maxICimage[activeIC]){
			selectedICimage[activeIC] := 0
		}
	} else {
		selectedICimage[activeIC] := selectedICimage[activeIC] - 1
		if (selectedICimage[activeIC] < 0){
			selectedICimage[activeIC] := maxICimage[activeIC]
		}
	}
	DrawIC()
return


changeActiveIC:
	if %ICRandomSlideShowTimer%
		{
		SetTimer, randomICChange, off
		ICRandomSlideShowTimer := 0
		Return
	}
	loop, 8 
		{
		activeIC++
		if (activeIC > 8)
		activeIC := 1
		if bezelICArray[activeIC,1,1] 
			break
	}
	if selectedICimage[activeIC]
		{
		;grow effect
		GrowSize := 1
		While GrowSize <= 10 {
			Gdip_GraphicsClear(Bezel_G4)
			loop, 8
				{
				if (a_index = activeIC) {
					ICposition(a_index,selectedICimage[a_index])
					Gdip_Alt_DrawImage(Bezel_G4, bezelICArray[a_index,selectedICimage[a_index],2], ICPositionArray[1]-GrowSize, ICPositionArray[2]-GrowSize, bezelICArray[a_index,selectedICimage[a_index],3]+2*GrowSize, bezelICArray[a_index,selectedICimage[a_index],4]+2*GrowSize)
				} else {
					if bezelICArray[a_index,selectedICimage[a_index],1] 
						{
						ICposition(a_index,selectedICimage[a_index])
						Gdip_Alt_DrawImage(Bezel_G4, bezelICArray[a_index,selectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,selectedICimage[a_index],3], bezelICArray[a_index,selectedICimage[a_index],4])    
					}
				}
			}
			Alt_UpdateLayeredWindow(Bezel_hwnd4, Bezel_hdc4,0,0, baseScreenWidth, baseScreenHeight)
			GrowSize++
		}
		;reset
		Gdip_GraphicsClear(Bezel_G4)
		loop, 8
			{
			if bezelICArray[a_index,selectedICimage[a_index],1] 
				{
				ICposition(a_index,selectedICimage[a_index])
				Gdip_Alt_DrawImage(Bezel_G4, bezelICArray[a_index,selectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,selectedICimage[a_index],3], bezelICArray[a_index,selectedICimage[a_index],4])
			}
		}
		Alt_UpdateLayeredWindow(Bezel_hwnd4, Bezel_hdc4,0,0, baseScreenWidth, baseScreenHeight)
	}
return


DrawIC(){
	Global 
	if (animationIC="none"){
		Gdip_GraphicsClear(Bezel_G4)
		if changeICSound
			SoundPlay, %changeICSound%
		loop, 8
			{
			if bezelICArray[a_index,selectedICimage[a_index],1]
				{
				ICposition(a_index,selectedICimage[a_index])
				Gdip_Alt_DrawImage(Bezel_G4, bezelICArray[a_index,selectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,selectedICimage[a_index],3], bezelICArray[a_index,selectedICimage[a_index],4])
			}
		}
		Alt_UpdateLayeredWindow(Bezel_hwnd4, Bezel_hdc4,0,0, baseScreenWidth, baseScreenHeight)
	} else if (animationIC="fade"){ 
		;fade out
		if prevSelectedICimage[activeIC]
			{
			if fadeOutICSound
				SoundPlay, %fadeOutICSound%
			startTime := A_TickCount
			Loop {
				Gdip_GraphicsClear(Bezel_G4)
				t := if ((TimeElapsed := A_TickCount-startTime) < ICChangeDur) ? ((1-(timeElapsed/ICChangeDur))) : 0
				loop, 8
					{
					if (activeIC = a_index) {
						ICposition(a_index,prevselectedICimage[a_index])
						Gdip_Alt_DrawImage(Bezel_G4, bezelICArray[a_index,prevselectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,prevselectedICimage[a_index],3], bezelICArray[a_index,prevselectedICimage[a_index],4],"","","","",t)   
					} else {
						if bezelICArray[a_index,selectedICimage[a_index],1]
							{
							ICposition(a_index,selectedICimage[a_index])
							Gdip_Alt_DrawImage(Bezel_G4, bezelICArray[a_index,selectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,selectedICimage[a_index],3], bezelICArray[a_index,selectedICimage[a_index],4])
						}
					}
				}
				Alt_UpdateLayeredWindow(Bezel_hwnd4, Bezel_hdc4,0,0, baseScreenWidth, baseScreenHeight)
				If (t <= 0)
					Break
			}
		}	
		;fade in
		if fadeInICSound
				SoundPlay, %fadeInICSound%
		startTime := A_TickCount
		Loop {
			Gdip_GraphicsClear(Bezel_G4)
			t := if ((TimeElapsed := A_TickCount-startTime) < ICChangeDur) ? ((timeElapsed/ICChangeDur)) : 1
			loop, 8
				{
				if (activeIC = a_index) {
					ICposition(a_index,selectedICimage[a_index])
					Gdip_Alt_DrawImage(Bezel_G4, bezelICArray[a_index,selectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,selectedICimage[a_index],3], bezelICArray[a_index,selectedICimage[a_index],4],"","","","",t) 
				} else {
					if bezelICArray[a_index,selectedICimage[a_index],1]
						{
						ICposition(a_index,selectedICimage[a_index])
						Gdip_Alt_DrawImage(Bezel_G4, bezelICArray[a_index,selectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,selectedICimage[a_index],3], bezelICArray[a_index,selectedICimage[a_index],4])
					}
				}
			}
			Alt_UpdateLayeredWindow(Bezel_hwnd4, Bezel_hdc4,0,0, baseScreenWidth, baseScreenHeight)
			If (t >= 1)
				Break
		}			
	} else if (animationIC="slideOutandIn"){
		; slide out
		if prevSelectedICimage[activeIC]
			{
			if slideOutICSound
				SoundPlay, %slideOutICSound%
			startTime := A_TickCount
			Loop {
				Gdip_GraphicsClear(Bezel_G4)
				t := if ((TimeElapsed := A_TickCount-startTime) < ICChangeDur) ? ((timeElapsed/ICChangeDur)) : 1
				loop, 8
					{
					if (activeIC = a_index) {
						ICposition(a_index,prevselectedICimage[a_index],t)
						Gdip_Alt_DrawImage(Bezel_G4, bezelICArray[a_index,prevselectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,prevselectedICimage[a_index],3], bezelICArray[a_index,prevselectedICimage[a_index],4])
					} else {
						if bezelICArray[a_index,selectedICimage[a_index],1]
							{
							ICposition(a_index,selectedICimage[a_index])
							Gdip_Alt_DrawImage(Bezel_G4, bezelICArray[a_index,selectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,selectedICimage[a_index],3], bezelICArray[a_index,selectedICimage[a_index],4])
						}						
					}
				}
				Alt_UpdateLayeredWindow(Bezel_hwnd4, Bezel_hdc4,0,0, baseScreenWidth, baseScreenHeight)
				If (t >= 1)
					Break
			}
		}
		; slide in
		if slideInICSound
			SoundPlay, %slideInICSound%
		startTime := A_TickCount
		Loop {
			Gdip_GraphicsClear(Bezel_G4)
			t := if ((TimeElapsed := A_TickCount-startTime) < ICChangeDur) ? ((1-(timeElapsed/ICChangeDur))) : 0
			loop, 8
				{
				if (a_index = activeIC) {
					ICposition(a_index,selectedICimage[a_index],t)
					Gdip_Alt_DrawImage(Bezel_G4, bezelICArray[a_index,selectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,selectedICimage[a_index],3], bezelICArray[a_index,selectedICimage[a_index],4])
				} else {
					if bezelICArray[a_index,selectedICimage[a_index],1]
						{
						ICposition(a_index,selectedICimage[a_index])
						Gdip_Alt_DrawImage(Bezel_G4, bezelICArray[a_index,selectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,selectedICimage[a_index],3], bezelICArray[a_index,selectedICimage[a_index],4])
					}						
				}
			}
			Alt_UpdateLayeredWindow(Bezel_hwnd4, Bezel_hdc4,0,0, baseScreenWidth, baseScreenHeight)
			If (t <= 0)
				Break
		}
	} else if (animationIC="slideIn"){
		; slide in
		if slideInICSound
			SoundPlay, %slideInICSound%
		startTime := A_TickCount
		Loop {
			Gdip_GraphicsClear(Bezel_G4)
			t := if ((TimeElapsed := A_TickCount-startTime) < ICChangeDur) ? ((1-(timeElapsed/ICChangeDur))) : 0
			loop, 8
				{
				if (a_index = activeIC) {
					ICposition(a_index,selectedICimage[a_index],t)
					Gdip_Alt_DrawImage(Bezel_G4, bezelICArray[a_index,selectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,selectedICimage[a_index],3], bezelICArray[a_index,selectedICimage[a_index],4])
				} else {
					if bezelICArray[a_index,selectedICimage[a_index],1]
						{
						ICposition(a_index,selectedICimage[a_index])
						Gdip_Alt_DrawImage(Bezel_G4, bezelICArray[a_index,selectedICimage[a_index],2], ICPositionArray[1], ICPositionArray[2], bezelICArray[a_index,selectedICimage[a_index],3], bezelICArray[a_index,selectedICimage[a_index],4])
					}						
				}
			}
			Alt_UpdateLayeredWindow(Bezel_hwnd4, Bezel_hdc4,0,0, baseScreenWidth, baseScreenHeight)
			If (t <= 0)
				Break
		}	
	}
return
}

ICposition(ICSelectedIndex,ICImageSelectedIndex, step = "0"){
	Global
	if not ICPositionArray
		ICPositionArray := []
	if (positionICArray%ICSelectedIndex% = "topLeft") {
		ICPositionArray[1] := round( 0 - step*bezelICArray[ICSelectedIndex,ICImageSelectedIndex,3] )
		ICPositionArray[2] := 0	
	} else if (positionICArray%ICSelectedIndex% = "topRight") {
		ICPositionArray[1] := round( baseScreenWidth - bezelICArray[ICSelectedIndex,ICImageSelectedIndex,3] + step*bezelICArray[ICSelectedIndex,ICImageSelectedIndex,3] )
		ICPositionArray[2] := 0		
	} else if (positionICArray%ICSelectedIndex% = "bottomLeft") {
		ICPositionArray[1] := round( 0 - step*bezelICArray[ICSelectedIndex,ICImageSelectedIndex,3] )
		ICPositionArray[2] := round( baseScreenHeight - bezelICArray[ICSelectedIndex,ICImageSelectedIndex,4] ) 			
	} else if (positionICArray%ICSelectedIndex% = "bottomRight") {
		ICPositionArray[1] := round( baseScreenWidth - bezelICArray[ICSelectedIndex,ICImageSelectedIndex,3] + step*bezelICArray[ICSelectedIndex,ICImageSelectedIndex,3] )
		ICPositionArray[2] := round( baseScreenHeight - bezelICArray[ICSelectedIndex,ICImageSelectedIndex,4] )			
	} else if (positionICArray%ICSelectedIndex% = "topCenter") {
		ICPositionArray[1] := round( baseScreenWidth//2 - bezelICArray[ICSelectedIndex,ICImageSelectedIndex,3]//2 )
		ICPositionArray[2] := round( 0 - step*bezelICArray[ICSelectedIndex,ICImageSelectedIndex,4] )
	} else if (positionICArray%ICSelectedIndex% = "leftCenter") {
		ICPositionArray[1] := round( 0 - step*bezelICArray[ICSelectedIndex,ICImageSelectedIndex,3] )
		ICPositionArray[2] := round( ( baseScreenHeight - bezelICArray[ICSelectedIndex,ICImageSelectedIndex,4] ) // 2 )								
	} else if (positionICArray%ICSelectedIndex% = "rightCenter") {
		ICPositionArray[1] := round( ( baseScreenWidth - bezelICArray[ICSelectedIndex,ICImageSelectedIndex,3] ) + step*bezelICArray[ICSelectedIndex,ICImageSelectedIndex,3] )
		ICPositionArray[2] := round( ( baseScreenHeight - bezelICArray[ICSelectedIndex,ICImageSelectedIndex,4] ) // 2 )											
	} else { ; bottomCenter
		ICPositionArray[1] := round( ( baseScreenWidth - bezelICArray[ICSelectedIndex,ICImageSelectedIndex,3] ) // 2 )
		ICPositionArray[2] := round( baseScreenHeight - bezelICArray[ICSelectedIndex,ICImageSelectedIndex,4] + step*bezelICArray[ICSelectedIndex,ICImageSelectedIndex,4] )			
	}
return  ICPositionArray
}


;IC Menu code

rightICMenu:
leftICMenu:
	if %ICRandomSlideShowTimer%
		{
		SetTimer, randomICChange, off
		ICRandomSlideShowTimer := 0
	}
	if (A_ThisLabel="rightICMenu") {
		if ICRightMenuDraw
			{
			gosub, DisableICRightMenuKeys
			SetTimer, UpdatecurrentRightICScrollingText, off
			Gdip_GraphicsClear(Bezel_G7)
			Gdip_GraphicsClear(Bezel_G8)
			Alt_UpdateLayeredWindow(Bezel_hwnd7, Bezel_hdc7, baseScreenWidth-bezelICRightMenuBitmapW, (baseScreenHeight-bezelICRightMenuBitmapH)//2, bezelICRightMenuBitmapW, bezelICRightMenuBitmapH)
			Alt_UpdateLayeredWindow(Bezel_hwnd8, Bezel_hdc8, baseScreenWidth-ICMenuListX-ICMenuListWidth, (baseScreenHeight-bezelICLeftMenuBitmapH)//2+ICMenuListY+ICMenuListHeight//2-ICMenuListTextSize//2, ICMenuListWidth, ICMenuListTextSize)				
			ICRightMenuDraw := false
		} else {
			DrawICMenu("right")
			gosub, EnableICRightMenuKeys
			ICRightMenuDraw := true
		}
    } else {
		if ICLeftMenuDraw
			{
			gosub, DisableICLeftMenuKeys
			SetTimer, UpdatecurrentLeftICScrollingText, off
			Gdip_GraphicsClear(Bezel_G5)
			Gdip_GraphicsClear(Bezel_G6)
			Alt_UpdateLayeredWindow(Bezel_hwnd5, Bezel_hdc5, 0, (baseScreenHeight-bezelICLeftMenuBitmapH)//2, bezelICLeftMenuBitmapW, bezelICLeftMenuBitmapH)
			Alt_UpdateLayeredWindow(Bezel_hwnd6, Bezel_hdc6, ICMenuListX, (baseScreenHeight-bezelICLeftMenuBitmapH)//2+ICMenuListY+ICMenuListHeight//2-ICMenuListTextSize//2, ICMenuListWidth, ICMenuListTextSize)
			ICLeftMenuDraw := false
		} else {
			DrawICMenu("left")
			gosub, EnableICLeftMenuKeys
			ICLeftMenuDraw := true
		}
	}
return

rightICMenuUp:
rightICMenuDown:
rightICMenuLeft:
rightICMenuRight:
leftICMenuUp:
leftICMenuDown:
leftICMenuLeft:
leftICMenuRight:
	if InStr(A_ThisLabel,"MenuUp"){
		if InStr(A_ThisLabel,"rightIC"){
				selectedRightMenuItem[rightMenuActiveIC] := selectedRightMenuItem[rightMenuActiveIC] + 1
			if (selectedRightMenuItem[rightMenuActiveIC] > maxICimage[rightMenuActiveIC])
				selectedRightMenuItem[rightMenuActiveIC] := 0	
		} else { ;left
				selectedLeftMenuItem[leftMenuActiveIC] := selectedLeftMenuItem[leftMenuActiveIC] + 1
			if (selectedLeftMenuItem[leftMenuActiveIC] > maxICimage[leftMenuActiveIC])
				selectedLeftMenuItem[leftMenuActiveIC] := 0			
		}
	} else if InStr(A_ThisLabel,"MenuDown"){
		if InStr(A_ThisLabel,"rightIC"){
			selectedRightMenuItem[rightMenuActiveIC] := selectedRightMenuItem[rightMenuActiveIC] - 1
			if (selectedRightMenuItem[rightMenuActiveIC] < 0)
				selectedRightMenuItem[rightMenuActiveIC] := maxICimage[rightMenuActiveIC]	
		} else { ;left
			selectedLeftMenuItem[leftMenuActiveIC] := selectedLeftMenuItem[leftMenuActiveIC] - 1
			if (selectedLeftMenuItem[leftMenuActiveIC] < 0)
				selectedLeftMenuItem[leftMenuActiveIC] := maxICimage[leftMenuActiveIC]			
		}		
	} else if InStr(A_ThisLabel,"MenuLeft"){ ;left key
		if InStr(A_ThisLabel,"rightIC"){ ;right menu
			loop, 8
				{
				rightMenuActiveIC--
				if (rightMenuActiveIC < 1)
					rightMenuActiveIC := 8
				if bezelICArray[rightMenuActiveIC,1,1] 
					if positionICArray%rightMenuActiveIC% in %rightMenuPositionsIC% 
						break
			}
		} else { ;left menu key
			loop, 8
				{
				leftMenuActiveIC--
				if (leftMenuActiveIC < 1)
					leftMenuActiveIC := 8
				if bezelICArray[leftMenuActiveIC,1,1] 
					if positionICArray%leftMenuActiveIC% in %leftMenuPositionsIC% 
						break
			}		
		}
	} else { ;Right key
		if InStr(A_ThisLabel,"rightIC"){ ;right menu
			loop, 8 
				{
				rightMenuActiveIC++
				if (rightMenuActiveIC > 8)
					rightMenuActiveIC := 1
				if bezelICArray[rightMenuActiveIC,1,1] 
					if positionICArray%rightMenuActiveIC% in %rightMenuPositionsIC% 
						break
			}
		} else { ;left menu key
			loop, 8
				{
				leftMenuActiveIC++
				if (leftMenuActiveIC > 8)
					leftMenuActiveIC := 1
				if bezelICArray[leftMenuActiveIC,1,1] 
					if positionICArray%leftMenuActiveIC% in %leftMenuPositionsIC% 
						break
			}		
		}
	}
	if InStr(A_ThisLabel,"rightIC")
		DrawICMenu("right")
	else ; left
		DrawICMenu("left")
Return


rightICMenuSelect:
leftICMenuSelect:
	if InStr(A_ThisLabel,"rightIC"){
		activeIC := rightMenuActiveIC
		selectedICimage[activeIC] := selectedRightMenuItem[rightMenuActiveIC]
		DrawIC()
		DrawICMenu("right")
	} else { ; left
		activeIC := leftMenuActiveIC
		selectedICimage[activeIC] := selectedLeftMenuItem[leftMenuActiveIC]
		DrawIC()
		DrawICMenu("left")
	}
Return


DrawICMenu(side){
	Global 
	;Initializing parameters
	ICMenuListTextFont := IC%side%MenuListTextFont 
	ICMenuListTextAlignment := IC%side%MenuListTextAlignment
	ICMenuListTextSize := IC%side%MenuListTextSize 
	ICMenuListTextColor := IC%side%MenuListTextColor
	ICMenuListDisabledTextColor := IC%side%MenuListDisabledTextColor
	ICMenuListCurrentTextColor := IC%side%MenuListCurrentTextColor 
	ICMenuListDisabledTextSize   := IC%side%MenuListDisabledTextSize 
	ICMenuListItems := IC%side%MenuListItems
	ICMenuListX := IC%side%MenuListX
	ICMenuListY := IC%side%MenuListY
	ICMenuListWidth := IC%side%MenuListWidth 
	ICMenuListHeight := IC%side%MenuListHeight
	ICMenuPositionTextFont := IC%side%MenuPositionTextFont
	ICMenuPositionTextSize := IC%side%MenuPositionTextSize 
	ICMenuPositionTextColor := IC%side%MenuPositionTextColor
	ICMenuPositionTextX := IC%side%MenuPositionTextX
	ICMenuPositionTextY := IC%side%MenuPositionTextY
	ICMenuPositionTextWidth := IC%side%MenuPositionTextWidth
	ICMenuPositionTextHeight := IC%side%MenuPositionTextHeight
	ICMenuPositionTextAlignment := IC%side%MenuPositionTextAlignment
	VDistBtwICNames := ICMenuListHeight//(ICMenuListItems+1)
	menuActiveIC := %side%MenuActiveIC
	menuSelectedItem[menuActiveIC] := if selected%side%MenuItem[menuActiveIC] ? selected%side%MenuItem[menuActiveIC] : 0 
	;Drawing Menu Image
	if (side="left"){
		Gdip_GraphicsClear(Bezel_G5)
		Gdip_GraphicsClear(Bezel_G6)
		Gdip_Alt_DrawImage(Bezel_G5, bezelICLeftMenuBitmap, 0, 0, bezelICLeftMenuBitmapW, bezelICLeftMenuBitmapH)
		Gdip_Alt_TextToGraphics(Bezel_G5, positionICArray%leftMenuActiveIC%, "x" . ICMenuPositionTextX . " y" . ICMenuPositionTextY . " " . ICMenuPositionTextAlignment . " c" . ICMenuPositionTextColor . " r4 s" . ICMenuPositionTextSize . " normal", ICMenuPositionTextFont, ICMenuPositionTextWidth, ICMenuPositionTextHeight)
	} else {
		Gdip_GraphicsClear(Bezel_G7)
		Gdip_GraphicsClear(Bezel_G8)
		Gdip_Alt_DrawImage(Bezel_G7, bezelICRightMenuBitmap, 0, 0, bezelICRightMenuBitmapW, bezelICRightMenuBitmapH)
		Gdip_Alt_TextToGraphics(Bezel_G7, positionICArray%rightMenuActiveIC%, "x" . ICMenuPositionTextX . " y" . ICMenuPositionTextY . " " . ICMenuPositionTextAlignment . " c" . ICMenuPositionTextColor . " r4 s" . ICMenuPositionTextSize . " normal", ICMenuPositionTextFont, ICMenuPositionTextWidth, ICMenuPositionTextHeight)
	}
	;Drawing IC List
	bottomtext := menuSelectedItem[menuActiveIC]
	topText := menuSelectedItem[menuActiveIC]
	Loop, % ICMenuListItems//2+1
		{
		If (a_index=1)
			{
			currentSelectedColor%side% := if (menuSelectedItem[menuActiveIC] = selectedICimage[menuActiveIC]) ? ICMenuListCurrentTextColor : ICMenuListTextColor
			currentSelectedLabel%side% := bezelICArray[menuActiveIC,menuSelectedItem[menuActiveIC],5]
			MeasureCurrentSelectedIC := MeasureText(currentSelectedLabel%side%, "Left r4 s" . ICMenuListTextSize . " bold",ICMenuListTextFont)
			if (MeasureCurrentSelectedIC <= ICMenuListWidth) {
				TextOptions := "x0 y0 " . ICMenuListTextAlignment . " c" . currentSelectedColor%side% . " r4 s" . ICMenuListTextSize . " bold"
				if (side="left") {
					SetTimer, UpdatecurrentLeftICScrollingText, off
					Gdip_GraphicsClear(Bezel_G6)
					Gdip_Alt_TextToGraphics(Bezel_G6, currentSelectedLabel%side%, TextOptions, ICMenuListTextFont, ICMenuListWidth, ICMenuListTextSize)
				} else {
					SetTimer, UpdatecurrentRightICScrollingText, off
					Gdip_GraphicsClear(Bezel_G8)
					Gdip_Alt_TextToGraphics(Bezel_G8, currentSelectedLabel%side%, TextOptions, ICMenuListTextFont, ICMenuListWidth, ICMenuListTextSize)
				}
			} else {	
				if (side="left"){
					initLeftPixels := 0
					xLeft := 0
					SetTimer, UpdatecurrentLeftICScrollingText, 20
				} else {
					initRightPixels := 0
					xRight := 0
					SetTimer, UpdatecurrentRightICScrollingText, 20
				}
			}
		} Else {		
			bottomtext++
			bottomtext := If (bottomtext > maxICimage[menuActiveIC]) ? 0 : bottomtext
			currentColor := if (bottomtext = selectedICimage[menuActiveIC]) ? ICMenuListCurrentTextColor : ICMenuListDisabledTextColor
			currentLabel := bezelICArray[menuActiveIC,bottomtext,5]
			TextOptions := "x" . ICMenuListX . " y" . ICMenuListY+ICMenuListHeight//2-(a_index-1)*(VDistBtwICNames)-ICMenuListDisabledTextSize//2 . " " . ICMenuListTextAlignment . " c" . currentColor . " r4 s" . ICMenuListDisabledTextSize . " normal"
			if (side="left"){
				Gdip_Alt_TextToGraphics(Bezel_G5, currentLabel, TextOptions, ICMenuListTextFont, ICMenuListWidth, ICMenuListDisabledTextSize)
			} else {
				Gdip_Alt_TextToGraphics(Bezel_G7, currentLabel, TextOptions, ICMenuListTextFont, ICMenuListWidth, ICMenuListDisabledTextSize)
			}
			topText--
			topText := If (topText < 0) ? maxICimage[menuActiveIC] : topText
			currentColor := if (topText = selectedICimage[menuActiveIC]) ? ICMenuListCurrentTextColor : ICMenuListDisabledTextColor
			currentLabel := bezelICArray[menuActiveIC,topText,5]
			TextOptions := "x" . ICMenuListX . " y" . ICMenuListY+ICMenuListHeight//2+(a_index-1)*(VDistBtwICNames)-ICMenuListDisabledTextSize//2 . " " . ICMenuListTextAlignment . " c" . currentColor . " r4 s" . ICMenuListDisabledTextSize . " normal"
			if (side="left"){
				Gdip_Alt_TextToGraphics(Bezel_G5, currentLabel, TextOptions, ICMenuListTextFont, ICMenuListWidth, ICMenuListDisabledTextSize)
			} else {
				Gdip_Alt_TextToGraphics(Bezel_G7, currentLabel, TextOptions, ICMenuListTextFont, ICMenuListWidth, ICMenuListDisabledTextSize)
			}
		}
	}
	if (side="left"){
		Alt_UpdateLayeredWindow(Bezel_hwnd5, Bezel_hdc5, 0, (baseScreenHeight-bezelICLeftMenuBitmapH)//2, bezelICLeftMenuBitmapW, bezelICLeftMenuBitmapH)
		Alt_UpdateLayeredWindow(Bezel_hwnd6, Bezel_hdc6, ICMenuListX, (baseScreenHeight-bezelICLeftMenuBitmapH)//2+ICMenuListY+ICMenuListHeight//2-(ICMenuListTextSize)//2, ICMenuListWidth, ICMenuListTextSize)
	} else {
		Alt_UpdateLayeredWindow(Bezel_hwnd7, Bezel_hdc7, baseScreenWidth-bezelICRightMenuBitmapW, (baseScreenHeight-bezelICRightMenuBitmapH)//2, bezelICRightMenuBitmapW, bezelICRightMenuBitmapH)
		Alt_UpdateLayeredWindow(Bezel_hwnd8, Bezel_hdc8, baseScreenWidth-bezelICRightMenuBitmapW+ICMenuListX, (baseScreenHeight-bezelICLeftMenuBitmapH)//2+ICMenuListY+ICMenuListHeight//2-(ICMenuListTextSize)//2, ICMenuListWidth, ICMenuListTextSize)				
	}		
Return	
}

UpdatecurrentLeftICScrollingText: ;Updating scrolling IC name
    Options = y0 c%currentSelectedColorLeft% r4 s%ICMenuListTextSize% bold
	scrollingVelocity := 2
	xLeft := (-xLeft >= E3) ? initLeftPixels : xLeft-scrollingVelocity
	initLeftPixels := ICLeftMenuListWidth
    Gdip_GraphicsClear(Bezel_G6)
    E := Gdip_Alt_TextToGraphics(Bezel_G6, currentSelectedLabelLeft, "x" xLeft " " Options, ICMenuListTextFont, (xLeft < 0) ? ICLeftMenuListWidth-xLeft : ICLeftMenuListWidth, ICMenuListTextSize)
    StringSplit, E, E, |
	Alt_UpdateLayeredWindow(Bezel_hwnd6, Bezel_hdc6, ICMenuListX, (baseScreenHeight-bezelICLeftMenuBitmapH)//2+ICMenuListY+ICMenuListHeight//2-(ICMenuListTextSize)//2, ICMenuListWidth, ICMenuListTextSize)
return

UpdatecurrentRightICScrollingText: ;Updating scrolling IC name
    Options = y0 c%currentSelectedColorRight% r4 s%ICMenuListTextSize% bold
	scrollingVelocity := 2
	xRight := (-xRight >= E3) ? initRightPixels : xRight-scrollingVelocity
	initRightPixels := ICRightMenuListWidth
    Gdip_GraphicsClear(Bezel_G8)
    E := Gdip_Alt_TextToGraphics(Bezel_G8, currentSelectedLabelRight, "x" xRight " " Options, ICMenuListTextFont, (xRight < 0) ? ICRightMenuListWidth-xRight : ICRightMenuListWidth, ICMenuListTextSize)
    StringSplit, E, E, |
	Alt_UpdateLayeredWindow(Bezel_hwnd8, Bezel_hdc8, baseScreenWidth-bezelICRightMenuBitmapW+ICMenuListX, (baseScreenHeight-bezelICLeftMenuBitmapH)//2+ICMenuListY+ICMenuListHeight//2-(ICMenuListTextSize)//2, ICMenuListWidth, ICMenuListTextSize)
Return



randomICChange:
	loop, 8
		{
		if 	maxICimage[a_index]
			{
			activeIC := a_index
			Random, ICImage, 1, % maxICimage[activeIC]
			selectedICimage[activeIC] := ICImage
			DrawIC()
		}
	}
Return


EnableBezelKeys:
	if bezelICPath
		{
		if toogleICVisibilityKey
			XHotKeywrapper(toogleICVisibilityKey,"toogleICVisibility", "ON")
		if nextICKey
			XHotKeywrapper(nextICKey,"nextIC", "ON")
		if previousICKey
			XHotKeywrapper(previousICKey,"previousIC", "ON")
		if changeActiveICKey
			XHotKeywrapper(changeActiveICKey,"changeActiveIC", "ON")
		loop, 8
			{
			if nextIC%a_index%Key
				XHotKeywrapper(nextIC%a_index%Key,"nextIC" . A_Index, "ON")
			if previousIC%a_index%Key
				XHotKeywrapper(previousIC%a_index%Key,"previousIC" . A_Index, "ON")
		}
		if leftICMenuKey
			XHotKeywrapper(leftICMenuKey,"leftICMenu", "ON")
		if rightICMenuKey
			XHotKeywrapper(rightICMenuKey,"rightICMenu", "ON")
	}		
	if (bezelImagesList.MaxIndex() > 1) {
		if nextBezelKey
			XHotKeywrapper(nextBezelKey,"nextBezel", "ON")
		if previousBezelKey
			XHotKeywrapper(previousBezelKey,"previousBezel", "ON")
	} 
    Log("Bezel Keys Enabled",5)
Return


DisableBezelKeys:
	if bezelICPath
		{
		if toogleICVisibilityKey
			XHotKeywrapper(toogleICVisibilityKey,"toogleICVisibility", "OFF")
		if nextICKey
			XHotKeywrapper(nextICKey,"nextIC", "OFF")
		if previousICKey
			XHotKeywrapper(previousICKey,"previousIC", "OFF")
		if changeActiveICKey
			XHotKeywrapper(changeActiveICKey,"changeActiveIC", "OFF")
		loop, 8
			{
			if nextIC%a_index%Key
				XHotKeywrapper(nextIC%a_index%Key,"nextIC" . A_Index, "OFF")
			if previousIC%a_index%Key
				XHotKeywrapper(previousIC%a_index%Key,"previousIC" . A_Index, "OFF")
		}
		if leftICMenuKey
			XHotKeywrapper(leftICMenuKey,"leftICMenu", "OFF")
		if rightICMenuKey
			XHotKeywrapper(rightICMenuKey,"rightICMenu", "OFF")
	}		
	if (bezelImagesList.MaxIndex() > 1) {
		if nextBezelKey
			XHotKeywrapper(nextBezelKey,"nextBezel", "OFF")
		if previousBezelKey
			XHotKeywrapper(previousBezelKey,"previousBezel", "OFF")
	} 
    Log("Bezel Keys Disabled",5)
Return

EnableICRightMenuKeys:
	XHotKeywrapper(navP2SelectKey,"rightICMenuSelect","ON") 
	XHotKeywrapper(navP2LeftKey,"rightICMenuLeft","ON")
	XHotKeywrapper(navP2RightKey,"rightICMenuRight","ON")
	XHotKeywrapper(navP2UpKey,"rightICMenuUp","ON")
	XHotKeywrapper(navP2DownKey,"rightICMenuDown","ON")
return

DisableICRightMenuKeys:
	XHotKeywrapper(navP2SelectKey,"rightICMenuSelect","OFF") 
	XHotKeywrapper(navP2LeftKey,"rightICMenuLeft","OFF")
	XHotKeywrapper(navP2RightKey,"rightICMenuRight","OFF")
	XHotKeywrapper(navP2UpKey,"rightICMenuUp","OFF")
	XHotKeywrapper(navP2DownKey,"rightICMenuDown","OFF")
return

EnableICLeftMenuKeys:
	XHotKeywrapper(navSelectKey,"leftICMenuSelect","ON") 
	XHotKeywrapper(navLeftKey,"leftICMenuLeft","ON")
	XHotKeywrapper(navRightKey,"leftICMenuRight","ON")
	XHotKeywrapper(navUpKey,"leftICMenuUp","ON")
	XHotKeywrapper(navDownKey,"leftICMenuDown","ON")
return

DisableICLeftMenuKeys:
	XHotKeywrapper(navSelectKey,"leftICMenuSelect","OFF") 
	XHotKeywrapper(navLeftKey,"leftICMenuLeft","OFF")
	XHotKeywrapper(navRightKey,"leftICMenuRight","OFF")
	XHotKeywrapper(navUpKey,"leftICMenuUp","OFF")
	XHotKeywrapper(navDownKey,"leftICMenuDown","OFF")
return