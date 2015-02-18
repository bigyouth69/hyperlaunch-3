MCRC=48FFD00B
mVersion=1.0.8

;Author: bleasby
;Thanks to djvj and brolly for helping in the development of HyperPause (without them this would be impossible to achieve)
;Thanks to THK for the great work with moves list icons
;Thanks to BBB for making HyperSpin and thanks to all the hyperspin community 
;Thanks to all beta testers, ghutch92 (thks for the owner gui code), dustind900, emb, mameshane, DrMoney,...
;Thanks to autohotkey community for library files and example scripts
;Thanks to all people involde at the command.dat project, emumovies, tempest for creating system ini files, HitoText creators,... 
;---------------------------------------
;A necessary Warning for anyone that wants to modify my code! I am not a programmer. I did this as a hobby and a way to learn languages and autohotkey. Right now I would do a lot of things diferently, but time is a scarce commodity.
;Probably my way to code is not the smallest, more structured or more efficient way to do things.
;I am really, really, open to any suggestion about the code If you have more experience in codding.

;File Descripton
;This file contains all functions and labels related with the HyperPause Addon for HyperLaunch

;HyperPause Layers
; 	- HP_GUI21 - Loading Screen and Black Screen to Hide FrontEnd
; 	- HP_GUI21b - Loading Screen Dynamic Text
; 	- HP_GUI22 - Background Image (covers entire screen)
; 	- HP_GUI23 - Background (covers entire screen)
; 	- HP_GUI24 - Moving description
; 	- HP_GUI25 - Main Menu bar
; 	- HP_GUI26 - Config Options (Above Bar Label)
; 	- HP_GUI27 - Submenus
; 	- HP_GUI28 - Clock
; 	- HP_GUI29 - Full Screen drawing while changing screens in HP (covers entire screen)
; 	- HP_GUI30 - Disc Rotation, animations, submenu animations
; 	- HP_GUI31 - ActiveX Video
; 	- HP_GUI32 - Mouse Overlay
; 	- HP_GUI33 - Help text while in submenu


;HPMediaObj

;HPMediaObj[SubMenuLabel].maxLabelSize
;HPMediaObj[SubMenuLabel].txtLines 
;HPMediaObj[SubMenuLabel].txtFSLines 

;HPMediaObj[SubMenuLabel].1 := Label   ; gives the label corresponding to each index (index = 1, 2, ...)
;HPMediaObj[SubMenuLabel].Label.Label	
;HPMediaObj[SubMenuLabel].Label.Path1, HPMediaObj[SubMenuLabel].Label.Ext2,...
;HPMediaObj[SubMenuLabel].Label.Ext1, HPMediaObj[SubMenuLabel].Label.Ext2,...
;HPMediaObj[SubMenuLabel].Label.TotalItems   

;for txt only
;HPMediaObj[SubMenuLabel].Label.txtWidth
;HPMediaObj[SubMenuLabel].Label.Page1, HPMediaObj[SubMenuLabel].Label.Page2, ....
;HPMediaObj[SubMenuLabel].Label.FSPage1, HPMediaObj[SubMenuLabel].Label.Page2, ....
;HPMediaObj[SubMenuLabel].Label.TotalV2SubMenuItems
;HPMediaObj[SubMenuLabel].Label.TotalFSV2SubMenuItems

;-----------------CODE-------------

HyperPause_Main:
    HyperPause_Running:=true ; HyperPause menu is running
    XHotKeywrapper(exitEmulatorKey,"CloseProcess","OFF") ;cancel exit emulator key for future reasigning 
    XHotKeywrapper(hpKey,"TogglePauseMenuStatus","OFF") ;cancel HyperPause key for future reasigning 
    If mgEnabled = true
        XHotKeywrapper(mgKey,"StartMulti","OFF") ;cancel MultiGame key while HyperPause is running
    If (bezelEnabled = true) and (bezelPath = true)
	{	Gosub, DisableBezelKeys%zz%	; many more bezel keys if they are used need to be disabled
        if %ICRandomSlideShowTimer%
			SetTimer, randomICChange%zz%, off
        if ICRightMenuDraw 
            Gosub, DisableICRightMenuKeys%zz%
        if ICLeftMenuDraw
            Gosub, DisableICLeftMenuKeys%zz%
        if (bezelBackgroundsList.MaxIndex() > 1)
            if bezelBackgroundChangeDur
                settimer, BezelBackgroundTimer%zz%, OFF
	}
    Log("Disabled exit emulator, bezel, and multigame keys",5)
	If (emuIdleShutdown and emuIdleShutdown != "ERROR")	; turn off emuIdleShutdown while in HP
		SetTimer, EmuIdleCheck%zz%, Off
    If (HyperPause_Loaded <> 1){ ; Initiate Gdip+ If first HyperPause run
        If !pToken := Gdip_Startup()
            Log("gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system",3)
        Log("Started Gdip " pToken " (If number -> loaded)",5)
    }
    ; Loading HyperPause ini keys 
    HyperPause_GlobalFile := A_ScriptDir . "\Settings\Global HyperPause.ini" 
    HyperPause_SystemFile := A_ScriptDir . "\Settings\" . systemName . "\HyperPause.ini" 
    If (RIni_Read(3,HyperPause_GlobalFile) = -11) {
        Log("Global HyperPause.ini file not found, creating a new one.",5)
        RIni_Create(3)
    }
    If (RIni_Read(4,HyperPause_SystemFile) = -11) {
        IfNotExist, % A_ScriptDir . "\Settings\" . systemName
            FileCreateDir, % A_ScriptDir . "\Settings\" . systemName
        Log( A_ScriptDir . "\Settings\" . systemName . "\HyperPause.ini file not found, creating a new one.",5)
        RIni_Create(4)
	}
    If (HyperPause_Loaded <> 1){ ;determining emulator information to use in system specific commands in the module files
        WinGet emulatorProcessName, ProcessName, A
        WinGetClass, EmulatorClass, A
        WinGet emulatorID, ID, A
        WinGet emulatorProcessID, PID, A
    }
    Log("Loaded Emulator information: EmulatorProcessName: " emulatorProcessName ", EmulatorClass: " EmulatorClass ", EmulatorID: " EmulatorID,5)
    ;Mute when loading HyperPause to avoiding sound stuttering
    HyperPause_MuteWhenLoading := RIniHyperPauseLoadVar(3,4, "General Options", "Mute_when_Loading_Hyperpause", "true") 
    HyperPause_MuteSound := RIniHyperPauseLoadVar(3,4, "General Options", "Mute_Sound", "false") 
    If((HyperPause_MuteWhenLoading="true") or (HyperPause_MuteSound="true")){ 
        if !emulatorVolumeObject
            emulatorVolumeObject := GetVolumeObject(emulatorProcessID)
        getMute(HyperPauseInitialMuteState,emulatorVolumeObject)
        If !(HyperPauseInitialMuteState){
            setMute(1,emulatorVolumeObject)
            Log("Muting emulator sound while HP is loaded. Master Mute status: " getMute(,emulatorVolumeObject) " (1 is mutted)",5)
        }
    }
    If(HyperPause_MainMenu_UseScreenshotAsBackground="true"){
        HyperPause_Screenshot_Extension := RIniHyperPauseLoadVar(3,4, "General Options", "Screenshot_Extension", "jpg") ;Supported extensions are: .BMP,.DIB,.RLE,.JPG,.JPEG,.JPE,.JFIF,.GIF,.TIF,.TIFF,.PNG
        HyperPause_Screenshot_JPG_Quality := RIniHyperPauseLoadVar(3,4, "General Options", "Screenshot_JPG_Quality", "100") ;If saving as jpg (.JPG,.JPEG,.JPE,.JFIF) then quality can be 1-100 with default at maximum quality
        HyperPause_SaveScreenshotPath := HLMediaPath . "\Artwork\" . systemname . "\" . dbName . "\Screenshots\"
        IfNotExist, %HyperPause_SaveScreenshotPath%
            FileCreateDir, %HyperPause_SaveScreenshotPath%
        GameScreenshot := HyperPause_SaveScreenshotPath . "GameScreenshot." . HyperPause_Screenshot_Extension
        CaptureScreen(GameScreenshot, "0|0|" . A_ScreenWidth . "|" . A_ScreenHeight , HyperPause_Screenshot_JPG_Quality)
    }
    if (HyperPause_Loaded <> 1)
        HyperPause_MainMenu_Labels := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Main_Menu_Items", "Controller|Change Disc|Save State|Load State|HighScore|Artwork|Guides|Manuals|Videos|Sound|Statistics|Moves List|History|Settings|Shutdown")
    ; Reading HyperPause menu disable option for canceling HyperPause drawn
    HyperPause_Disable_Menu := RIniHyperPauseLoadVar(3,4, "General Options", "Disable_HyperPause_Menu", "true") 
    If !disableLoadScreen 
        gosub, HideFrontEnd ; Creating HP_GUI21 non activated Black Screen to Hide FrontEnd 
    Log("HyperPause Started: current rom: " dbName ", current system Name: " systemName,1)
    Log("Created Black Screen to hide FrontEnd",5)
    Gosub, HaltEmu ;getting system specific commands from modules and pausing the emulator 
    Log("Loaded emulator specific module start commands",5)
    If !disableLoadScreen ;activating HP_GUI21 Black Screen for hidding FrontEnd If not disabled in the module 
        If !(disableActivateBlackScreen and HyperPause_Disable_Menu="true")
            WinActivate, HyperPauseBlackScreen
    ;Acquiring screen info for dealing with rotated menu drawings
    Gdip_Alt_GetRotatedDimensions(A_ScreenWidth, A_ScreenHeight, screenRotationAngle, baseScreenWidth, baseScreenHeight)
    Gdip_GetRotatedTranslation(baseScreenWidth, baseScreenHeight, screenRotationAngle, xTranslation, yTranslation)
    xTranslation:=round(xTranslation), yTranslation:=round(yTranslation)
    ;Setting Scale Res Factors
    hyperpauseWidthBaseRes := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "HyperPause_Base_Resolution_Width", "1920") 
    hyperpauseHeightBaseRes := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "HyperPause_Base_Resolution_Height", "1080") 
    if (((A_screenWidth < A_screenHeight) and ((screenRotationAngle=0) or (screenRotationAngle=180))) or ((A_screenWidth > A_screenHeight) and ((screenRotationAngle=90) or (screenRotationAngle=270)))){
        temp := hyperpauseWidthBaseRes , hyperpauseWidthBaseRes := hyperpauseHeightBaseRes , hyperpauseHeightBaseRes := temp
    }
    HyperPause_XScale := baseScreenWidth/hyperpauseWidthBaseRes
    HyperPause_YScale := baseScreenHeight/hyperpauseHeightBaseRes
    Log("HyperPause screen scale factor: X=" . HyperPause_XScale . ", Y= " . HyperPause_YScale,5)
    If !disableSuspendEmu { ;Suspending emulator process while in HyperPause (pauses the emulator If halemu does not contain pause controls)
		If (hlMode != "hp")	; On hp mode, emulatorProcessName = HyperLaunch.exe and obviously can't be suspended
			ProcSus(emulatorProcessName)
	}
    HyperPause_BeginTime := A_TickCount ;start to count the time expent in the pause menu for statistics purposes
    Log("Setting HP starting time for subtracting from statistics played time: " HyperPause_BeginTime,5)
    If !disableLoadScreen ;updating HP_GUI21 for loading screen message If not disabled in the module 
        If !(disableActivateBlackScreen and HyperPause_Disable_Menu="true")
            gosub, LoadingHyperPauseScreen
    Log("Loading screen created",5)
    If (disableActivateBlackScreen and HyperPause_Disable_Menu="true") { ;Stop HyperPause Drawn If menu shouldnt be drawn (HyperPause key just pauses the emu)
        HyperPause_Active:=true ;HyperPause menu active (fully loaded)
        XHotKeywrapper(exitEmulatorKey,"TogglePauseMenuStatus","ON")
        XHotKeywrapper(hpKey,"TogglePauseMenuStatus","ON")
        Return
    }
    HyperPause_ChangeRes := RIniHyperPauseLoadVar(3,4, "General Options", "Force_Resolution_Change", "") 
    if HyperPause_ChangeRes
        {
        HyperPause_ScreenResToBeRestored := CheckForNearestSupportedRes( CurrentDisplaySettings(0) )
		StringSplit, HyperPause_ScreenResToBeRestoredArray, HyperPause_ScreenResToBeRestored , |,     ; ResArray1 - width, ResArray2 - height, ResArray3 - color, ResArray4 - frequency,
		HyperPause_ForcedRes := CheckForNearestSupportedRes( HyperPause_ChangeRes )
		StringSplit, HyperPause_ForcedResArray, HyperPause_ForcedRes , |,     ; ResArray1 - width, ResArray2 - height, ResArray3 - color, ResArray4 - frequency,
		ChangeDisplaySettings(HyperPause_ForcedResArray1,HyperPause_ForcedResArray2,HyperPause_ForcedResArray3,HyperPause_ForcedResArray4)
    }
    If (HyperPause_Loaded <> 1){
        gosub, LoadExternalVariables ;Loading external variables and paths for the first time
        Log("Loaded HP options",5)
        HyperPauseOptionsScale() ;Setting scalling parameters and scalling variables        
        Log("Scaled HP variables",5)
        gosub, FirstTimeHyperPauseRun ;Loading variables on first run        
        Log("Initilized HP variables for the first time",5)
    }
    SavedKeyDelay := A_KeyDelay ;Saving previous key delay and setting the new one for save and load state commands
    GoSub, InitializePauseMainMenu ;Initializing the main menu and creating HyperPause Guis
    Log("Initilized HP brushes and guis",5)
    Gosub DrawMainMenu ;Drawing the main menu background and game information
    Alt_UpdateLayeredWindow(HP_hwnd22, HP_hdc22,0,0, baseScreenWidth, baseScreenHeight)
    Alt_UpdateLayeredWindow(HP_hwnd23, HP_hdc23,0,0, baseScreenWidth, baseScreenHeight)
    Log("Loaded Main Menu Background and infos",5)
    Gosub DrawMainMenuBar ;Drawing the main menu bar
    Alt_UpdateLayeredWindow(HP_hwnd25, HP_hdc25,0,round((baseScreenHeight-HyperPause_MainMenu_BarHeight)/2)+HyperPause_MainMenu_BarVerticalOffset, baseScreenWidth, HyperPause_MainMenu_BarHeight)
    Log("Loaded Main Menu Bar. Current Main Menu Label: " HyperPause_MainMenuSelectedLabel,5)
    If(HyperPause_MainMenu_ShowClock="true"){ ;Drawing the clock
        SetTimer, Clock, 1000
        Log("Loaded Clock",5)
    }
    If not(HyperPause_MuteSound="true"){ 
        If(HyperPause_MuteWhenLoading="true"){ ;Unmuting If initial state was unmuted
            If !(HyperPauseInitialMuteState){
                getMute(CurrentMuteState,emulatorVolumeObject)
                If(CurrentMuteState=1){
                    setMute(0,emulatorVolumeObject)
                    Log("Unmuting computer sound while HP is loaded. Master Mute status: " getMute(,emulatorVolumeObject) " (0 is unmutted)",5)
                }
            }  
        }
    }   
	If(HyperPause_MusicPlayerEnabled = "true"){ ;Loading music player 
		gosub, HyperPause_MusicPlayer
        Log("Loaded Music Player",5)
    }
    XHotKeywrapper(navLeftKey,"MoveLeft","ON")
    XHotKeywrapper(navRightKey,"MoveRight","ON")
    XHotKeywrapper(navUpKey,"MoveUp","ON")
    XHotKeywrapper(navDownKey,"MoveDown","ON")
    XHotKeywrapper(navSelectKey,"ToggleItemSelectStatus","ON") ;Activating Pause Menu Hotkeys
    XHotKeywrapper(navP2LeftKey,"MoveLeft","ON")
    XHotKeywrapper(navP2RightKey,"MoveRight","ON")
    XHotKeywrapper(navP2UpKey,"MoveUp","ON")
    XHotKeywrapper(navP2DownKey,"MoveDown","ON")
    XHotKeywrapper(navP2SelectKey,"ToggleItemSelectStatus","ON")
    XHotKeywrapper(hpBackToMenuBarKey,"BacktoMenuBar","ON")
    XHotKeywrapper(hpZoomInKey,"ZoomIn","ON")
    XHotKeywrapper(hpZoomOutKey,"ZoomOut","ON")
    XHotKeywrapper(exitEmulatorKey,"TogglePauseMenuStatus","ON")
    XHotKeywrapper(hpKey,"TogglePauseMenuStatus","ON")
    If (keymapperEnabled = "true") and (keymapperHyperLaunchProfileEnabled = "true")
        {
        RunKeymapper%zz%("menu",keymapper)
        Loop, 10 { ;Activating HyperPause Screen
            CurrentGUI := A_Index+21
            WinActivate, hpLayer%CurrentGUI%
        }
    }
	If keymapperAHKMethod = External
		RunAHKKeymapper%zz%("menu")
    SetTimer, UpdateDescription, 15  ;Setting timer for game description scroling text
    SetTimer, SubMenuUpdate, 100  ;Setting timer for submenu apearance
    ; Clearing Loading HyperPause Screen
    Gdip_GraphicsClear(HP_G21)
    Alt_UpdateLayeredWindow(HP_hwnd21, HP_hdc21, 0, 0, baseScreenWidth, baseScreenHeight)
    Gdip_GraphicsClear(HP_G21b)
    Alt_UpdateLayeredWindow(HP_hwnd21b, HP_hdc21b, 0, 0, baseScreenWidth, baseScreenHeight)
    ;Initilaizing Mouse Overlay Controls
    If(HyperPause_EnableMouseControl = "true") {
        Gdip_Alt_DrawImage(HP_G32, MouseOverlayBitmap, 0, 0, MouseOverlayW, MouseOverlayH)
        Alt_UpdateLayeredWindow(HP_hwnd32, HP_hdc32,0,baseScreenHeight-MouseOverlayH, MouseOverlayW, MouseOverlayH,HyperPause_MouseControlTransparency)
        hotkey, LButton, hpMouseClick
    }
    HyperPause_Active:=true ;HyperPause menu active (fully loaded)
    HyperPause_Loaded = 1 ;HyperPause menu fully loaded at least one time
    Log("Finished Loading HyperPause",1)
Return

HideFrontEnd: ;Hide FrontEnd with a black Gui
    HyperPause_Load_Background_Color = ff000000
    HyperPause_Load_Background_Brush := Gdip_BrushCreateSolid("0x" . HyperPause_Load_Background_Color)
    Gui, HP_GUI21: New, +HwndHP_hwnd21 +E0x80000 +ToolWindow -Caption +AlwaysOnTop +OwnDialogs, HyperPauseBlackScreen
    HP_hbm21 := CreateDIBSection(originalWidth, originalHeight)
    HP_hdc21 := CreateCompatibleDC()
    HP_obm21 := SelectObject(HP_hdc21, HP_hbm21)
    HP_G21 := Gdip_GraphicsFromhdc(HP_hdc21)
    Gdip_FillRectangle(HP_G21, HyperPause_Load_Background_Brush, -1, -1, originalWidth+1, originalHeight+1)   
    Gui, HP_GUI21: Show, na
    UpdateLayeredWindow(HP_hwnd21, HP_hdc21, 0, 0, originalWidth, originalHeight)
Return

LoadingHyperPauseScreen: ;Drawning Loading HyperPause Message
    Gdip_GraphicsClear(HP_G21)
    Gdip_TranslateWorldTransform(HP_G21, xTranslation, yTranslation)
    Gdip_RotateWorldTransform(HP_G21, screenRotationAngle)
    pGraphUpd(HP_G21,baseScreenWidth,baseScreenHeight)
    Gdip_Alt_FillRectangle(HP_G21, HyperPause_Load_Background_Brush, 0, 0, baseScreenWidth, baseScreenHeight)   
    HyperPause_AuxiliarScreen_StartText := RIniHyperPauseLoadVar(3,4, "Start and Exit Screen", "Loading_Text", "Loading HyperPause")
    HyperPause_AuxiliarScreen_ExitText := RIniHyperPauseLoadVar(3,4, "Start and Exit Screen", "Exiting_Text", "Exiting HyperPause")
    HyperPause_AuxiliarScreen_Font := RIniHyperPauseLoadVar(3,4, "Start and Exit Screen", "Font", "Bebas Neue")
    HyperPause_AuxiliarScreen_FontSize := RIniHyperPauseLoadVar(3,4, "Start and Exit Screen", "Font_Size", "45")
    HyperPause_AuxiliarScreen_FontColor := RIniHyperPauseLoadVar(3,4, "Start and Exit Screen", "Font_Color", "ff222222")
    HyperPause_AuxiliarScreen_ExitTextMargin := RIniHyperPauseLoadVar(3,4, "Start and Exit Screen", "Text_Margin", "65")
    CheckFont(HyperPause_AuxiliarScreen_Font)
    OptionScale(HyperPause_AuxiliarScreen_FontSize, HyperPause_YScale)
    OptionScale(HyperPause_AuxiliarScreen_ExitTextMargin, HyperPause_XScale)
    AuxiliarScreenTextX := HyperPause_AuxiliarScreen_ExitTextMargin
    AuxiliarScreenTextY := baseScreenHeight - HyperPause_AuxiliarScreen_ExitTextMargin - HyperPause_AuxiliarScreen_FontSize
    OptionsLoadHP = x%AuxiliarScreenTextX% y%AuxiliarScreenTextY% Left c%HyperPause_AuxiliarScreen_FontColor% r4 s%HyperPause_AuxiliarScreen_FontSize% bold
    Gdip_Alt_TextToGraphics(HP_G21, HyperPause_AuxiliarScreen_StartText, OptionsLoadHP, HyperPause_AuxiliarScreen_Font, 0, 0)
    Alt_UpdateLayeredWindow(HP_hwnd21, HP_hdc21, 0, 0, baseScreenWidth, baseScreenHeight)
    ;creating dynamic loading text gui
    Gui, HP_GUI21b: New, +HwndHP_hwnd21b +E0x80000 +ToolWindow -Caption +AlwaysOnTop +OwnDialogs, hpLayer21b
    HP_hbm21b := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
    HP_hdc21b := CreateCompatibleDC()
    HP_obm21b := SelectObject(HP_hdc21b, HP_hbm21b)
    HP_G21b := Gdip_GraphicsFromhdc(HP_hdc21b)
    Gdip_TranslateWorldTransform(HP_G21b, xTranslation, yTranslation)
    Gdip_RotateWorldTransform(HP_G21b, screenRotationAngle)
    pGraphUpd(HP_G21b,baseScreenWidth,baseScreenHeight)
    Gui, HP_GUI21b: Show, na
Return


FirstTimeHyperPauseRun: ;Loading pause menu variables (first time run only)
    LoadingText("Initializing...")
    SelectedMenuOption=    ;Loading auxiliar parameters
    HyperPause_MainMenuItem = 1
    FullScreenView = 0
    VSubMenuItem = 0
    V2SubMenuItem = 1
    HSubMenuItem = 1
    ZoomLevel := 100
    HorizontalPanFullScreen := 0
    VerticalPanFullScreen := 0
    TotalSubMenuGuidesPages = 0 
    TotalSubMenuManualsPages = 0 
    TotalSubMenuHistoryPages = 0 
    TotalSubMenuControllerPages = 0 
    TotalSubMenuArtworkPages = 0 
    filesToBeDeleted := ""
    FileRemoveDir, %HyperPause_GuidesTempPath%, 1   ;removing temp folders for pdf and compressed files
    FileRemoveDir, %HyperPause_ManualsTempPath%, 1
    FileRemoveDir, %HyperPause_ArtworkTempPath%, 1
    FileRemoveDir, %HyperPause_ControllerTempPath%, 1 
    Lettersandnumbers = a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,0,1,2,3,4,5,6,7,8,9,/,\ ;List of letters and numbers for using in line validation on moves list
    ;Description name without (Disc X)
    If (!romTable && mgCandidate)
        romTable:=CreateRomTable(dbName)
    Totaldiscsofcurrentgame:=romTable.MaxIndex()
    If (Totaldiscsofcurrentgame>1){ 
        DescriptionNameWithoutDisc := romTable[1,4]
    } else {
        DescriptionNameWithoutDisc := dbName
    }
    ;Defining supported files in txt, pdf and images menu
    Supported_Images = png
    If (HyperPause_SupportAdditionalImageFiles="true")
        Supported_Images = png,gif,tif,bmp,jpg 
    Supported_Extensions = %Supported_Images%,pdf,txt,%7zFormatsNoP%,cbr,cbz
    StringReplace, CommaSeparated_MusicFilesExtension, HyperPause_MusicFilesExtension, |,`,, All
    ;checking for bad written labels and non included labels (and adding them to the end of HyperPause_MainMenu_Labels)
    CheckedHyperPause_MainMenu_Labels := ""
    Loop, parse, HyperPause_MainMenu_Labels,|
        {
        If A_LoopField in Controller,Change Disc,Save State,Load State,HighScore,Artwork,Guides,Manuals,Videos,Sound,Statistics,Moves List,History,Settings,Shutdown
            CheckedHyperPause_MainMenu_Labels := CheckedHyperPause_MainMenu_Labels . A_LoopField . "|"
    }
    If !(CheckedHyperPause_MainMenu_Labels = HyperPause_MainMenu_Labels . "|")
        Log("You have a Main Menu item not found or bad written in the HyperPause_MainMenu_Labels items list:`r`n`t`t`t`t`t Original Ini Main Menu list: " HyperPause_MainMenu_Labels "`r`n`t`t`t`t`t Corrected Main Menu list:    " CheckedHyperPause_MainMenu_Labels,2)
    HyperPause_MainMenu_Labels := CheckedHyperPause_MainMenu_Labels
    ; removing menu items not needed on HyperPause only call 
    If (hlMode = "hp"){
        if InStr(HyperPause_MainMenu_Labels,"Save State")
            StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Save State|,
        if InStr(HyperPause_MainMenu_Labels,"Load State")
            StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Load State|,
        if InStr(HyperPause_MainMenu_Labels,"Change Disc")
            StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Change Disc|, ;
    }
    ;loading general image paths
    LoadingText("Loading Logos and Backgrounds...")
    LogoImageList := []
    If FileExist(HLMediaPath . "\Logos\" . systemname . "\" . dbname . "\*.*")
        Loop, parse, Supported_Images,`,,
            Loop, %HLMediaPath%\Logos\%systemname%\%dbname%\*.%A_LoopField%
                LogoImageList.Insert(A_LoopFileFullPath)
    If !LogoImageList[1]
        If FileExist(HLMediaPath . "\Logos\" . systemname . "\"  . DescriptionNameWithoutDisc . "\*.*")
            Loop, parse, Supported_Images,`,,
                Loop, %HLMediaPath%\Logos\%systemname%\%DescriptionNameWithoutDisc%\*.%A_LoopField%
                    LogoImageList.Insert(A_LoopFileFullPath)
    If !LogoImageList[1]
    {
        for index, element in feMedia["Logos"]
        {   if element.Label
            {   if (element.AssetType="game")
                {   loop, % element.TotalItems    
                    {    LogoImageList.Insert(element["Path" . a_index])
                    }
                }
            }
        }
    }
    PauseImage = %HyperPause_IconsImagePath%Pause.png  
    SoundImage = %HyperPause_IconsImagePath%Sound.png  
    MuteImage = %HyperPause_IconsImagePath%Mute.png  
    ToggleONImage = %HyperPause_IconsImagePath%Toggle_ON.png 
    ToggleOFFImage = %HyperPause_IconsImagePath%Toggle_OFF.png 
    Log("Starting Creating HyperPause Contents Object.",5)
    ;loading background image paths
    HPBackground := []
    if (((A_screenWidth < A_screenHeight) and ((screenRotationAngle=0) or (screenRotationAngle=180))) or ((A_screenWidth > A_screenHeight) and ((screenRotationAngle=90) or (screenRotationAngle=270))))
		screenVerticalOrientation:="true"
	
    If FileExist(HyperPause_BackgroundsPath . systemName . "\"  . dbName . "\*.*")
        Loop, parse, Supported_Images,`,,
            Loop, %HyperPause_BackgroundsPath%%systemName%\%dbName%\*.%A_LoopField%
                HPBackground.Insert(A_LoopFileFullPath)
    If !HPBackground[1]
        If dbCloneOf
            If FileExist(HyperPause_BackgroundsPath . systemName . "\"  . dbCloneOf . "\*.*")
                Loop, parse, Supported_Images,`,,
                    Loop, %HyperPause_BackgroundsPath%%systemName%\%dbCloneOf%\*.%A_LoopField%
                        HPBackground.Insert(A_LoopFileFullPath)
    If !HPBackground[1]
        If FileExist(HyperPause_BackgroundsPath . systemName . "\"  . DescriptionNameWithoutDisc . "\*.*")
            Loop, parse, Supported_Images,`,,
                Loop, %HyperPause_BackgroundsPath%%systemName%\%DescriptionNameWithoutDisc%\*.%A_LoopField%
                    HPBackground.Insert(A_LoopFileFullPath)
    If !HPBackground[1]
    {
        for index, element in feMedia["Backgrounds"]
        {   if element.Label
            {   if (element.AssetType="game")
                {   loop, % element.TotalItems    
                    {    HPBackground.Insert(element["Path" . a_index])
                    }
                }
            }
        }
    }
    If !HPBackground[1]
    {   if (screenVerticalOrientation)
        {   If FileExist(HyperPause_BackgroundsPath . systemName . "\_Default\Vertical\*.*")
                Loop, parse, Supported_Images,`,,
                    Loop, %HyperPause_BackgroundsPath%%systemName%\_Default\Vertical\*.%A_LoopField%
                        HPBackground.Insert(A_LoopFileFullPath)
        } else {
           If FileExist(HyperPause_BackgroundsPath . systemName . "\_Default\Horizontal\*.*")
                Loop, parse, Supported_Images,`,,
                    Loop, %HyperPause_BackgroundsPath%%systemName%\_Default\Horizontal\*.%A_LoopField%
                        HPBackground.Insert(A_LoopFileFullPath)
        }
    }
    If !HPBackground[1]
        If FileExist(HyperPause_BackgroundsPath . systemName . "\_Default\*.*")
            Loop, parse, Supported_Images,`,,
                Loop, %HyperPause_BackgroundsPath%%systemName%\_Default\*.%A_LoopField%
                    HPBackground.Insert(A_LoopFileFullPath)
    If !HPBackground[1]
    {
        for index, element in feMedia["Backgrounds"]
        {   if element.Label
            {   if (element.AssetType="system")
                {   loop, % element.TotalItems    
                    {    HPBackground.Insert(element["Path" . a_index])
                    }
                }
            }
        }
    }
    If !HPBackground[1]
    {   if (screenVerticalOrientation)
        {   If FileExist(HyperPause_BackgroundsPath . "_Default\Vertical\*.*")
                Loop, parse, Supported_Images,`,,
                    Loop, %HyperPause_BackgroundsPath%_Default\Vertical\*.%A_LoopField%
                        HPBackground.Insert(A_LoopFileFullPath)
        } else {
           If FileExist(HyperPause_BackgroundsPath . "_Default\Horizontal\*.*")
                Loop, parse, Supported_Images,`,,
                    Loop, %HyperPause_BackgroundsPath%_Default\Horizontal\*.%A_LoopField%
                        HPBackground.Insert(A_LoopFileFullPath)
        }
    }
    If !HPBackground[1]
        If FileExist(HyperPause_BackgroundsPath . "_Default\*.*")
            Loop, parse, Supported_Images,`,,
                Loop, %HyperPause_BackgroundsPath%_Default\*.%A_LoopField%, 0
                    HPBackground.Insert(A_LoopFileFullPath)
    
    Loop, parse, HyperPause_MainMenu_Labels,|, ;Loading Submenu information and excluding empty sub menus
        {
        StringReplace, temp_mainmenulabel, A_LoopField, %A_SPACE%,, All
        If(temp_mainmenulabel="Artwork"){
            Log("Loading Artwork Contents",5)
            LoadingText("Loading Artwork...")
            If(HyperPause_ArtworkMenuEnabled="true"){
                if !HPMediaObj
                    HPMediaObj := []
                HPMediaObj.Artwork := CreateSubMenuMediaObject("Artwork")
                ;MultiContentSubMenuList("Artwork") ;Creating Artwork list
            } Else {
                StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Artwork|, ;Removing Artwork menu If user defined to not show it
            }
        }
        If(temp_mainmenulabel="Controller"){
            Log("Loading Controller Contents",5)
            If(HyperPause_ControllerMenuEnabled="true"){
                LoadingText("Loading Controller...")
                if !HPMediaObj
                    HPMediaObj := []
                HPMediaObj.Controller := CreateSubMenuMediaObject("Controller")
                ;config menu parameters
                If (keymapperEnabled = "true") {
                    WidthofConfigMenuLabel := MeasureText("Control Config"," Center r4 s" . HyperPause_SubMenu_FontSize . " bold",HyperPause_SubMenu_LabelFont)+HyperPause_SubMenu_AdditionalTextMarginContour
                    ConfigMenuX := (baseScreenWidth-(WidthofConfigMenuLabel+HyperPause_SubMenu_AdditionalTextMarginContour))//2
                    ConfigMenuY := (baseScreenHeight-HyperPause_MainMenu_BarHeight)//2-(HyperPause_SubMenu_FontSize+HyperPause_SubMenu_AdditionalTextMarginContour)+2
                    ConfigMenuWidth := WidthofConfigMenuLabel+HyperPause_SubMenu_AdditionalTextMarginContour
                    ConfigMenuHeight := HyperPause_SubMenu_FontSize+HyperPause_SubMenu_AdditionalTextMarginContour
                }
            } Else {
                StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Controller|, ;Removing Controller menu If user defined to not show it
            }
        }
        If((temp_mainmenulabel="SaveState")or(temp_mainmenulabel="LoadState")){
            Log("Loading " temp_mainmenulabel " Contents",5)
            If(HyperPause_SaveandLoadMenuEnabled="true"){
                LoadingText("Loading " temp_mainmenulabel "...")
                count:=0
                loop, 10
                    {
                    currentLabel := temp_mainmenulabel . "Slot" . a_index
                    if IsLabel(currentLabel) 
                        count++
                }
                if (HPMediaObj[temp_mainmenulabel].TotalLabels<1){
                    Loop, parse, hp%temp_mainmenulabel%KeyCodes,|, ;counting total save and load state slots
                        count++
                } 
                currentObj := {}
                currentObj["TotalLabels"] := count
                HPMediaObj.Insert(temp_mainmenulabel, currentObj)
                If(HPMediaObj[temp_mainmenulabel].TotalLabels<1){ ;Removing Save and Load State menus If no contents found 
                    If(temp_mainmenulabel="SaveState")
                        StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Save State|,
                    Else
                        StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Load State|,
                }
            } Else { ;Removing Save and Load State menus If user defined to not show it
                If(temp_mainmenulabel="SaveState")
                    StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Save State|,
                Else
                    StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Load State|,
            }
        }
        If(temp_mainmenulabel="ChangeDisc"){
            Log("Loading Change Disc Contents",5)
            If(HyperPause_ChangeDiscMenuEnabled="true"){
                LoadingText("Loading Change Disc...")
                currentObj := {}
                currentObj["TotalLabels"] := Totaldiscsofcurrentgame
                HPMediaObj.Insert(temp_mainmenulabel, currentObj) ;Checking If the game is a multi Disc game, loading images and counting total disc sub menu items
                If (Totaldiscsofcurrentgame>1){
                    If romExtensionOrig contains %7zFormats%
                        If % 7zEnabled = "true"
                            romNeeds7z:=1
                } Else {
                    StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Change Disc|, ;Removing change disc submenu If the game is not a multi disc game  
                }
            } Else {
                StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Change Disc|, ;Removing change disc submenu If user defined to not show it
            }
        }
        If(temp_mainmenulabel="HighScore"){
            Log("Loading HighScore Contents",5)
            If(HyperPause_HighScoreMenuEnabled="true"){
                If FileExist(hpHiToTextPath) and FileExist(hpHitoTextDir . "\hitotext.xml") {
                    LoadingText("Loading HighScore...")
                    HighScoreText := StdoutToVar_CreateProcess(hpHiToTextPath . " -ra " . """" . emuPath . "\hi\" . dbName . ".hi" . """","",hpHitoTextDir) ;Loading HighScore information
                    StringReplace, HighScoreText, HighScoreText, %a_space%,,all
                    stringreplace, HighScoreText, HighScoreText, `r`n,¡,all
                    stringreplace, HighScoreText, HighScoreText, ¡¡,,all
                    count:=0
                    Loop, parse, HighScoreText,¡, ,all
                        {
                        count++
                        HPMediaObj[temp_mainmenulabel].TotalLabels := A_Index-1
                    }
                    currentObj := {}
                    currentObj["TotalLabels"] := count-1
                    HPMediaObj.Insert(temp_mainmenulabel, currentObj) 
                    IfNotInString, HighScoreText, RANK ;Removing high score submenu If no high score information is found
                        {
                        StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, HighScore|,
                    }
                } Else { ;Removing high score submenu If hitotext files not found
                    StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, HighScore|,
                }                    
            } Else { ;Removing high score submenu If user defined to not show it
                StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, HighScore|,
            }
        }
        If(temp_mainmenulabel="MovesList"){
            Log("Loading MovesList Contents",5)
            If(HyperPause_MovesListMenuEnabled="true"){
                IfExist, %HyperPause_MovesListDataPath%%systemName%.dat ;Loading Moves List
                    {
                    LoadingText("Loading MovesList...")
                    FileRead, CommandDatFileContents, %HyperPause_MovesListDataPath%%systemName%.dat
                    CommandDatFileContents := RegExReplace(CommandDatFileContents, "i)info=\s*" . dbName . "\b\s*", "BeginofMovesListRomData",1) 
                    FoundPos := RegExMatch(CommandDatFileContents, "BeginofMovesListRomData")
                    If !FoundPos {
                        If (gameInfo["Cloneof"].Label)
                            CommandDatFileContents := RegExReplace(CommandDatFileContents, "i)info=\s*" . gameInfo["Cloneof"].Value . "\b\s*", "BeginofMovesListRomData",1) 
                    }
                    RomCommandDatText := StrX(CommandDatFileContents,"$BeginofMovesListRomData",1,0,"$info",1,0)
                    If RomCommandDatText
                        {
                        ReadMovesListInformation()
                    } Else {
                        StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Moves List|, ;Removing the moves list submenu If the game is not founded in the system.dat 
                    }
                } Else {
                    StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Moves List|, ;Removing the moves list submenu If the system.dat is not found
                }
            } Else {
                StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Moves List|, ;Removing the moves list submenu If user defined to not show it
            }
        }
        If(temp_mainmenulabel="Guides"){
            Log("Loading Guides Contents",5)
            If(HyperPause_GuidesMenuEnabled="true"){
                LoadingText("Loading Guides...")
                if !HPMediaObj
                    HPMediaObj := []
                HPMediaObj.Guides := CreateSubMenuMediaObject("Guides")
            } Else {
                StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Guides|, ;Removing the guides submenu If user defined to not show it
            }
        }
        If(temp_mainmenulabel="Manuals"){
            Log("Loading Manuals Contents",5)
            If(HyperPause_ManualsMenuEnabled="true"){
                LoadingText("Loading Manuals...")
                if !HPMediaObj
                    HPMediaObj := []
                HPMediaObj.Manuals := CreateSubMenuMediaObject("Manuals")
            } Else {
                StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Manuals|, ;Removing the manuals submenu If user defined to not show it
            }
        }
        If(temp_mainmenulabel="Videos"){
            Log("Loading Videos Contents",5)
            If(HyperPause_VideosMenuEnabled="true"){
                LoadingText("Loading Videos...")
                StringReplace, ListofSupportedVideos, HyperPause_SupportedVideos, |, `,, All
                if !HPMediaObj
                    HPMediaObj := []
                HPMediaObj.Videos := CreateSubMenuMediaObject("Videos")
                ;VideoButtonImages
                HyperPauseVideoImage1 = %HyperPause_IconsImagePath%VideoPlayerPlay.png   
                HyperPauseVideoImage2 = %HyperPause_IconsImagePath%VideoPlayerFullScreen.png   
                HyperPauseVideoImage3 = %HyperPause_IconsImagePath%VideoPlayerRewind.png   
                HyperPauseVideoImage4 = %HyperPause_IconsImagePath%VideoPlayerFastForward.png 
                HyperPauseVideoImage5 = %HyperPause_IconsImagePath%VideoPlayerStop.png 
                HyperPauseVideoImage6 = %HyperPause_IconsImagePath%VideoPlayerPause.png 
            } Else {
                StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Videos|, ;Removing the videos submenu If user defined to not show it
            }
        }        
        If(temp_mainmenulabel="Sound"){
            If (HyperPause_SoundMenuEnabled="true")
                Log("Loading Sound Contents",5)
            Else
                StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Sound|, ;Removing the sound submenu If user defined to not show it
        }     
        If(temp_mainmenulabel="Settings"){
            If (HyperPause_SettingsMenuEnabled="true")
                Log("Loading Settings Menu Contents",5)
            Else
                StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Settings|, ;Removing the sound submenu If user defined to not show it
        }     
        If(temp_mainmenulabel="Statistics"){
            If  statisticsEnabled = true
                {
                If (HyperPause_StatisticsMenuEnabled="true"){
                    Log("Loading Statistics Contents",5)
                    LoadingText("Loading Statistics...")
                    if !statisticsLoaded 
                        gosub, LoadStatistics ;Load Game Statistics Information
                    CreatingStatisticsVariablestoSubmenu()
                } Else {
                    StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Statistics|, ;Removing the Statistics submenu If user defined to not show it
                }
            } Else { 
               StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Statistics|, 
           }
        }    
        If(temp_mainmenulabel="History"){
            Log("Loading History.dat Contents",5)
            If(HyperPause_HistoryMenuEnabled="true"){
                LoadingText("Loading History.dat...")
                if !HPMediaObj
                    HPMediaObj := []
                HPMediaObj.History := loadHistoryDataInfo() ;creating History Dat submenu list
            } Else {
                StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, History|, ;Removing the History Dat submenu If user defined to not show it
            }
        }
        If(temp_mainmenulabel="Shutdown"){
            If(HyperPause_ShutdownLabelEnabled="true"){
                Log("Adding Shutdown Label",5)
            } Else {
                StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Shutdown|, ;Removing Artwork menu If user defined to not show it
            }
        }        
    }    
    LoadingText("Processing HyperPause Menu Contents...")
    PostProcessingMediaObject(feMedia,HPMediaObj)
    if InStr(HyperPause_MainMenu_Labels,"Videos")
        loop, % HPMediaObj["Videos"].TotalLabels
            VideoPosition%a_index% := 0
    StringTrimRight, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, 1 ;Counting total Main Menu items
    Loop, parse, HyperPause_MainMenu_Labels,|, 
        {
        TotalMainMenuItems := A_Index
    }
    Log("HyperPause Menu items: " HyperPause_MainMenu_Labels,1)
    IfExist, %HyperPause_GameInfoPath%%systemName%.ini ;Reading game info ini for game information 
        {
        FileRead, GameInfoFileContents, %HyperPause_GameInfoPath%%systemName%.ini
        If InStr(GameInfoFileContents, "[" . dbName . "]")
            {
            GameIniKey := dbName
        } Else If InStr(GameInfoFileContents, "[" . DescriptionNameWithoutDisc . "]")
            {
            GameIniKey := DescriptionNameWithoutDisc
        } Else If InStr(GameInfoFileContents, "[" . ClearDescriptionName . "]")
            {
            GameIniKey := ClearDescriptionName
        } Else { ;searching for variations of game name on ini files (&amp;=&, &apos;=', &=and)
            StringReplace, TempDbName, dbName, &amp;, &, All
			StringReplace, TempDbName, dbName, &apos;, ', All 
            StringReplace, TempDescriptionNameWithoutDisc, DescriptionNameWithoutDisc, &amp;, &, All
			StringReplace, TempDescriptionNameWithoutDisc, DescriptionNameWithoutDisc, &apos;, ', All         
            StringReplace, TempClearDescriptionName, ClearDescriptionName, &amp;, &, All
			StringReplace, TempClearDescriptionName, ClearDescriptionName, &apos;, ', All        
            StringReplace, Temp2DbName, TempDbName, &, and, All
            StringReplace, Temp2DescriptionNameWithoutDisc, TempDescriptionNameWithoutDisc, &, and, All
            StringReplace, Temp2ClearDescriptionName, TempClearDescriptionName, &, and, All
            If InStr(GameInfoFileContents, "[" . TempDbName . "]")
                GameIniKey := TempDbName
            Else If InStr(GameInfoFileContents, "[" . TempDescriptionNameWithoutDisc . "]")
                GameIniKey := TempDescriptionNameWithoutDisc
            Else If InStr(GameInfoFileContents, "[" . TempClearDescriptionName . "]")
                GameIniKey := TempClearDescriptionName
            Else If InStr(GameInfoFileContents, "[" . Temp2DbName . "]")
                GameIniKey := Temp2DbName
            Else If InStr(GameInfoFileContents, "[" . Temp2DescriptionNameWithoutDisc . "]")
                GameIniKey := Temp2DescriptionNameWithoutDisc
            Else If InStr(GameInfoFileContents, "[" . Temp2ClearDescriptionName . "]")
                GameIniKey := Temp2ClearDescriptionName
        }
        Loop, parse, HyperPause_MainMenu_Info_Labels,|, 
            {
            IniRead, %A_LoopField%, %HyperPause_GameInfoPath%%systemName%.ini, %GameIniKey%, %A_LoopField%,%A_Space%
            If(%A_LoopField%)
                gameinfoexist = 1
        }
        If !gameinfoexist { ;Look for parent info if game info not found
            Loop, parse, HyperPause_MainMenu_Info_Labels,|, 
                {        
                IniRead, %A_LoopField%, %HyperPause_GameInfoPath%%systemName%.ini, % gameInfo["Cloneof"].Value, %A_LoopField%,%A_Space%
                If(%A_LoopField%)  
                    gameinfoexist = 1
            }
        }
    }
    If !gameinfoexist { ;Look for database xml files info 
        Loop, parse, HyperPause_MainMenu_Info_Labels,|, 
            %A_loopfield% := gameInfo[A_loopfield].Value
    }
    Loop, parse, HyperPause_MainMenu_Info_Labels,|,   ; game info complete text
        If (%A_loopfield%)
            If !(A_LoopField="Description")
                TopLeftGameInfoText := % TopLeftGameInfoText . "`r`n" . A_loopfield . "=" . %A_loopfield%
    StringTrimLeft, TopLeftGameInfoText, TopLeftGameInfoText, 2
    posDescriptionY := round((baseScreenHeight+HyperPause_MainMenu_BarHeight+HyperPause_MainMenu_Info_Description_FontSize)/2)
    StringReplace,Description,Description,<br>,%A_Space%,All
    StringLen, DescriptionLength, Description
    Loop, parse, HyperPause_MainMenu_Labels,|, ;initializing auxiliar page tracking
        {
        StringReplace, temp_mainmenulabel, A_LoopField, %A_SPACE%,, All
        Loop, % HPMediaObj[temp_mainmenulabel].TotalLabels {    
            HSubmenuitem%temp_mainmenulabel%VSubmenuitem%a_index% = 1
            HSubmenuitem%temp_mainmenulabel%VSubmenuitem%a_index% += 0 
            HSubmenuitem%temp_mainmenulabel%V2Submenuitem%a_index% = 1
            HSubmenuitem%temp_mainmenulabel%V2Submenuitem%a_index% += 0       
        }
    }
    If(HyperPause_EnableMouseControl = "true") {
        If(HyperPause_MouseClickSound = "true") {
            MouseSoundsAr:=[]
            Loop, %HyperPause_MouseSoundPath%\*.mp3
                MouseSoundsAr.Insert(A_LoopFileName)
        }
        MouseMaskBitmap := Gdip_CreateBitmapFromFile( HyperPause_MouseOverlayPath . "MouseMask.png")
        MouseOverlayBitmap := Gdip_CreateBitmapFromFile( HyperPause_MouseOverlayPath . "MouseOverlay.png")
        MouseFullScreenMaskBitmap := Gdip_CreateBitmapFromFile( HyperPause_MouseOverlayPath . "MouseFullScreenMask.png")
        MouseFullScreenOverlayBitmap := Gdip_CreateBitmapFromFile( HyperPause_MouseOverlayPath . "MouseFullScreenOverlay.png")
        MouseClickImageBitmap := Gdip_CreateBitmapFromFile( HyperPause_MouseOverlayPath . "MouseClickImage.png")
        Gdip_GetImageDimensions(MouseOverlayBitmap, MouseOverlayW, MouseOverlayH)
        Gdip_GetImageDimensions(MouseClickImageBitmap, MouseClickImageW, MouseClickImageH)
    }
    ;calculating maximun main bar label size
    Loop, parse, HyperPause_MainMenu_Labels,|, 
        {
        Widthoftext := MeasureText(A_LoopField, "Centre r4 s" . HyperPause_MainMenu_LabelFontsize . " bold",HyperPause_MainMenu_LabelFont)
        if (Widthoftext>hpMainMenuLabelMaxWidth)
            hpMainMenuLabelMaxWidth := Widthoftext
    }
    LoadingText("Loading Complete!")
Return

            
InitializePauseMainMenu: ;Drawing the main menu for the first time (constructing Gui and setting initial parameters)
    ;Loading auxiliar parameters
    MenuChanged = 1
    ItemSelected = 0
    changeDiscMenuLoaded = 0
    ;Loading settings variables
    If (HyperPause_SettingsMenuEnabled="true"){
        if lockLaunchGame
            initialLockLaunch := lockLaunchGame
        else 
            initialLockLaunch := lockLaunch    
        currentLockLaunch := initialLockLaunch
        current7zDelTemp := 7zDelTemp
    }
    ;Logo random image
    If LogoImageList[1]
        {
        Random, RndmLogoImage, 1, % LogoImageList.MaxIndex()
        LogoImage := LogoImageList[RndmLogoImage]
    }
    Loop, 3
        HSubmenuitemSoundVSubmenuitem%a_index% = 1
    BlackGradientBrush := Gdip_CreateLineBrushFromRect(-1, round(baseScreenHeight/2-50),baseScreenWidth+2, HyperPause_MainMenu_BarHeight, "0x" . HyperPause_MainMenu_BarGradientBrush1, "0x" . HyperPause_MainMenu_BarGradientBrush2, 1, 1) ;Loading Brushs
    HyperPause_SubMenu_BackgroundBrushV := Gdip_BrushCreateSolid("0x" . HyperPause_SubMenu_BackgroundBrush)
    HyperPause_SubMenu_SelectedBrushV := Gdip_BrushCreateSolid("0x" . HyperPause_SubMenu_SelectedBrush)
    HyperPause_SubMenu_DisabledBrushV := Gdip_BrushCreateSolid("0x" . HyperPause_SubMenu_DisabledBrush)
    HyperPause_MainMenu_BackgroundBrushV := Gdip_BrushCreateSolid("0x" . HyperPause_MainMenu_BackgroundBrush)
    HyperPause_SubMenu_GuidesSelectedBrushV := Gdip_BrushCreateSolid("0x" . HyperPause_SubMenu_GuidesSelectedBrush)
    HyperPause_SubMenu_ManualsSelectedBrushV := Gdip_BrushCreateSolid("0x" . HyperPause_SubMenu_ManualsSelectedBrush)
    HyperPause_SubMenu_HistorySelectedBrushV := Gdip_BrushCreateSolid("0x" . HyperPause_SubMenu_HistorySelectedBrush)
    HyperPause_SubMenu_ControllerSelectedBrushV := Gdip_BrushCreateSolid("0x" . HyperPause_SubMenu_ControllerSelectedBrush)
    HyperPause_SubMenu_ArtworkSelectedBrushV := Gdip_BrushCreateSolid("0x" . HyperPause_SubMenu_ArtworkSelectedBrush)
    HyperPause_SubMenu_FullScreenTextBrushV := Gdip_BrushCreateSolid("0x" . HyperPause_SubMenu_FullScreenTextBrush)
    HyperPause_SubMenu_FullScreenBrushV := Gdip_BrushCreateSolid("0x" . HyperPause_SubMenu_FullScreenBrush)
    HyperPause_SubMenu_ControllerSelectedPen := Gdip_CreatePen("0x" . HyperPause_SubMenu_ControllerSelectedBrush, HyperPause_SubMenu_Pen_Width)
    If (HPMediaObj["MovesList"].TotalLabels<>0){ ;Creating Bitmaps
        Loop, %TotalCommandDatImageFiles%
            {
            CommandDatBitmap%A_index% := Gdip_CreateBitmapFromFile(CommandDatfile%A_index%)
        }
    }
    Loop, 12 { ;Creating Pause Menu Guis
        CurrentGUI := A_Index+21
        If not (CurrentGUI = 31) {
            If (A_Index=1) {
                Gui, HP_GUI%CurrentGUI%: -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop  
            } Else If (A_Index = 11) {
                OwnerGUI := CurrentGUI - 2
                Gui, HP_GUI%CurrentGUI%: +OwnerHP_GUI%OwnerGUI% +OwnDialogs -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop
            } Else If (A_Index = 12) {
                OwnerGUI := CurrentGUI - 1
                Gui, HP_GUI%CurrentGUI%: +OwnerHP_GUI%OwnerGUI% +OwnDialogs -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop
            } Else {
                OwnerGUI := CurrentGUI - 1
                Gui, HP_GUI%CurrentGUI%: +OwnerHP_GUI%OwnerGUI% -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop
            }
            Gui, HP_GUI%CurrentGUI%: Margin,0,0
            Gui, HP_GUI%CurrentGUI%: Show,, hpLayer%CurrentGUI%
            HP_hwnd%CurrentGUI% := WinExist()
            HP_hbm%CurrentGUI% := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
            HP_hdc%CurrentGUI% := CreateCompatibleDC()
            HP_obm%CurrentGUI% := SelectObject(HP_hdc%CurrentGUI%, HP_hbm%CurrentGUI%)
            HP_G%CurrentGUI% := Gdip_GraphicsFromhdc(HP_hdc%CurrentGUI%)
            Gdip_SetSmoothingMode(HP_G%CurrentGUI%, 4)
            Gdip_TranslateWorldTransform(HP_G%CurrentGUI%, xTranslation, yTranslation)
            Gdip_RotateWorldTransform(HP_G%CurrentGUI%, screenRotationAngle)
        }
    }
    ; Definition of update layers areas needed for screen rotation support of non full screen update area
    ;pGraphUpd(HP_G21,baseScreenWidth,baseScreenHeight) ;defined before
    pGraphUpd(HP_G22,baseScreenWidth,baseScreenHeight)
    pGraphUpd(HP_G23,baseScreenWidth,baseScreenHeight)
    pGraphUpd(HP_G24,baseScreenWidth,2*HyperPause_MainMenu_Info_Description_FontSize) ;multiple values handled on code
    pGraphUpd(HP_G25,baseScreenWidth,HyperPause_MainMenu_BarHeight) ; multiple values handled on code
    pGraphUpd(HP_G26,ConfigMenuWidth,ConfigMenuHeight) 
    ;pGraphUpd(HP_G27,HyperPause_SubMenu_Width, HyperPause_SubMenu_Height) ;multiple values handled on code
    ;pGraphUpd(HP_G28,CurrentTimeTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_MainMenu_ClockFontSize) ; undefined, handled on code
    ;pGraphUpd(HP_G29, HyperPause_ControllerFullScreenWidth, baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin) ;multiple values handled on code
    ;pGraphUpd(HP_G30,HyperPause_SubMenu_Width, HyperPause_SubMenu_Height) ;multiple values handled on code
    ;HP_GUI31 is handled on the code as it is not composed by GDIP elements  
    pGraphUpd(HP_G32,MouseOverlayW, MouseOverlayH)
    If (HPMediaObj["Videos"].TotalLabels>0){ ;creating ActiveX video gui
        Gui, HP_GUI31: +OwnerHP_GUI30 -Caption +LastFound +ToolWindow +AlwaysOnTop
        try Gui, HP_GUI31: Add, ActiveX, vwmpVideo, WMPLayer.OCX
        catch e
            Log("A Windows Media Player Video exception was thrown: " . e , 5)
        try ComObjConnect(wmpVideo, "wmpVideo_")
        catch e
            Log("A Windows Media Player Video exception was thrown: " . e , 5)
        try wmpVideo.settings.volume := HyperPause_VideoPlayerVolumeLevel
        try wmpVideo.settings.autoStart := false
        If(HyperPause_EnableVideoLoop="true")
            try wmpVideo.Settings.setMode("Loop",true)
        try wmpVideo.settings.enableErrorDialogs := false
        try wmpVideo.uimode := "none"
        try wmpVideo.stretchToFit := true
        If (HyperPause_Loaded <> 1){
            try wmpVersion := wmpVideo.versionInfo
            Log("Windows Media Player Version: " . wmpVersion,5)
        }
    }   
    getVolume(HyperPause_VolumeMaster)
    If (SelectedMenuOption="Video"){
        AnteriorFilePath:=
        V2Submenuitem := 1
        try CurrentVideoPlayStatus := wmpVideo.playState
        If(CurrentVideoPlayStatus=3) {
            try VideoPosition%videoplayingindex% := wmpVideo.controls.currentPosition
            Log("VideoPosition at main menu change:" "VideoPosition"videoplayingindex " " VideoPosition%videoplayingindex%,5)
            try wmpVideo.controls.stop
        }
        Gui,HP_GUI31: Show, Hide
        Gui, HP_GUI32: Show
    }
Return

;-----------------MENU DRAWING-------------
DrawMainMenu: ;Draw Main Menu Background
    If(HyperPause_MainMenu_UseScreenshotAsBackground="true"){
        MainMenuBackground := GameScreenshot
        filesToBeDeleted .= GameScreenshot . "|"
        HyperPause_MainMenu_BackgroundAlign := "Stretch and Lose Aspect" 
    } Else If HPBackground[1] {
        Random, RndmBackground, 1, % HPBackground.MaxIndex()
        MainMenuBackground := HPBackground[RndmBackground]
    }
    If MainMenuBackground {
        ; Creating bacground base color 
        HyperPause_Background_Brush := Gdip_BrushCreateSolid("0x" . HyperPause_MainMenu_Background_Color)
        Gdip_Alt_FillRectangle(HP_G22, HyperPause_Background_Brush, -1, -1, originalWidth+1, originalHeight+1) 
        ; Loading Bacground image
        MainMenuBackgroundBitmap := Gdip_CreateBitmapFromFile(MainMenuBackground)
        Gdip_GetImageDimensions(MainMenuBackgroundBitmap, MainMenuBackgroundBitmapW, MainMenuBackgroundBitmapH)
        GetBGPicPosition(HyperPauseBGPicXNew,HyperPauseBGYNew,HyperPauseBGWNew,HyperPauseBGHNew,MainMenuBackgroundBitmapW,MainMenuBackgroundBitmapH,HyperPause_MainMenu_BackgroundAlign)	; get the background pic's new position and size
        If (HyperPause_MainMenu_BackgroundAlign = "Stretch and Lose Aspect") {	 
            MainMenuBackgroundX := 0
            MainMenuBackgroundY := 0
            MainMenuBackgroundW := baseScreenWidth+1
            MainMenuBackgroundH := baseScreenHeight+1
        } Else If (HyperPause_MainMenu_BackgroundAlign = "Stretch and Keep Aspect" Or HyperPause_MainMenu_BackgroundAlign = "Center Width" Or HyperPause_MainMenu_BackgroundAlign = "Center Height" Or HyperPause_MainMenu_BackgroundAlign = "Align to Bottom Left" Or HyperPause_MainMenu_BackgroundAlign = "Align to Bottom Right") {
            MainMenuBackgroundX := HyperPauseBGPicXNew
            MainMenuBackgroundY := HyperPauseBGYNew
            MainMenuBackgroundW := HyperPauseBGWNew+1
            MainMenuBackgroundH := HyperPauseBGHNew+1
        } Else If (HyperPause_MainMenu_BackgroundAlign = "Center") {	; original image size and aspect
            MainMenuBackgroundX := HyperPauseBGPicXNew
            MainMenuBackgroundY := HyperPauseBGYNew
            MainMenuBackgroundW := MainMenuBackgroundBitmapW+1
            MainMenuBackgroundH := MainMenuBackgroundBitmapH+1
        } Else If (HyperPause_MainMenu_BackgroundAlign = "Align to Top Right") {	; place the pic so the top right corner matches the screen's top right corner
            MainMenuBackgroundX := HyperPauseBGPicXNew
            MainMenuBackgroundY := 0
            MainMenuBackgroundW := HyperPauseBGWNew+1
            MainMenuBackgroundH := HyperPauseBGHNew
        } Else {	; place the pic so the top left corner matches the screen's top left corner, also the default
            MainMenuBackgroundX := 0
            MainMenuBackgroundY := 0
            MainMenuBackgroundW := HyperPauseBGWNew+1
            MainMenuBackgroundH := HyperPauseBGHNew+1
        }
        Gdip_Alt_DrawImage(HP_G22, MainMenuBackgroundBitmap, MainMenuBackgroundX, MainMenuBackgroundY, MainMenuBackgroundW, MainMenuBackgroundH, 0, 0, MainMenuBackgroundBitmapW, MainMenuBackgroundBitmapH)
    }
    Gdip_Alt_FillRectangle(HP_G23, HyperPause_MainMenu_BackgroundBrushV, -1, -1, baseScreenWidth+2, baseScreenHeight+2)  
    PauseImageBitmap := Gdip_CreateBitmapFromFile(PauseImage) ;Drawing Main menu bitmaps
    PauseBitmapW := Gdip_GetImageWidth(PauseImageBitmap), PauseBitmapH := Gdip_GetImageHeight(PauseImageBitmap)
    OptionScale(PauseBitmapW, HyperPause_XScale)
    OptionScale(PauseBitmapH, HyperPause_XScale)
    Gdip_Alt_DrawImage(HP_G23, PauseImageBitmap, HyperPause_Logo_Image_Margin, round((BitmapLogoH-PauseBitmapH)/2),PauseBitmapW,PauseBitmapH)        
    If FileExist(LogoImage) {
        LogoImageBitmap := Gdip_CreateBitmapFromFile(LogoImage)
        BitmapLogoW := Gdip_GetImageWidth(LogoImageBitmap), BitmapLogoH := Gdip_GetImageHeight(LogoImageBitmap)
        If(baseScreenWidth<=1000){
            OptionScale(BitmapLogoW, HyperPause_XScale)
            OptionScale(BitmapLogoH, HyperPause_XScale)
            }            
        if (((A_screenWidth < A_screenHeight) and ((screenRotationAngle=0) or (screenRotationAngle=180))) or ((A_screenWidth > A_screenHeight) and ((screenRotationAngle=90) or (screenRotationAngle=270))))
            LogoImageX := HyperPause_Logo_Image_Margin, LogoImageY := PauseBitmapH + HyperPause_Logo_Image_Margin
        else
            LogoImageX := PauseBitmapW + 2*HyperPause_Logo_Image_Margin, LogoImageY := HyperPause_Logo_Image_Margin
        Gdip_Alt_DrawImage(HP_G23, LogoImageBitmap, LogoImageX, LogoImageY,BitmapLogoW,BitmapLogoH)
    }
    color := HyperPause_MainMenu_Info_FontColor
    posInfoX := baseScreenWidth-HyperPause_MainMenu_Info_Margin
    posInfoY := HyperPause_MainMenu_Info_Margin
    If(HyperPause_MainMenu_ShowClock="true")
        posInfoY := HyperPause_MainMenu_ClockFontSize
    If LogoImageBitmap
        TopLeftGameInfoWidth := baseScreenWidth - (LogoImageX + BitmapLogoW + HyperPause_MainMenu_Info_Margin)
    else
        TopLeftGameInfoWidth := baseScreenWidth - (PauseBitmapW + HyperPause_Logo_Image_Margin + HyperPause_MainMenu_Info_Margin) 
    Options_MainMenu_Info := % "x" . posInfoX-TopLeftGameInfoWidth . " y" . posInfoY . " Right c" . color . " r4 s" . HyperPause_MainMenu_Info_FontSize . " Regular W" . TopLeftGameInfoWidth . " H" . round((baseScreenHeight-HyperPause_MainMenu_BarHeight)/2)+HyperPause_MainMenu_BarVerticalOffset-posInfoY-HyperPause_MainMenu_Info_FontSize
    Gdip_Alt_TextToGraphics(HP_G23, TopLeftGameInfoText, Options_MainMenu_Info, HyperPause_MainMenu_Info_Font)
Return



DrawMainMenuBar: ;Drawing Main Menu Bar
    Gdip_Alt_FillRectangle(HP_G25, BlackGradientBrush, -1, 0, baseScreenWidth+2, HyperPause_MainMenu_BarHeight) ;Draw Main Menu Bar
    color := HyperPause_MainMenu_LabelDisabledColor ;Draw Main Menu Labels
    posX1 := round(baseScreenWidth/2 - (HyperPause_MainMenuItem-1)*(HyperPause_MainMenu_HdistBetwLabels+hpMainMenuLabelMaxWidth))
    posX2 := round(baseScreenWidth/2 - (HyperPause_MainMenuItem-1)*(HyperPause_MainMenu_HdistBetwLabels+hpMainMenuLabelMaxWidth) - TotalMainMenuItems*(HyperPause_MainMenu_HdistBetwLabels+hpMainMenuLabelMaxWidth))
    posX3 := round(baseScreenWidth/2 - (HyperPause_MainMenuItem-1)*(HyperPause_MainMenu_HdistBetwLabels+hpMainMenuLabelMaxWidth) +  TotalMainMenuItems*(HyperPause_MainMenu_HdistBetwLabels+hpMainMenuLabelMaxWidth))
    posY := round(HyperPause_MainMenu_BarHeight/2 - HyperPause_MainMenu_LabelFontsize/2)
    Loop, parse, HyperPause_MainMenu_Labels,|, 
    {
        If( (HyperPause_MainMenuItem = A_index)and(VSubMenuItem=0) ){
            color := HyperPause_MainMenu_LabelSelectedColor
            HyperPause_MainMenuSelectedLabel := A_LoopField
        }
        Options1 = x%posX1% y%posY% Centre c%color% r4 s%HyperPause_MainMenu_LabelFontsize% bold
        Options2 = x%posX2% y%posY% Centre c%HyperPause_MainMenu_LabelDisabledColor% r4 s%HyperPause_MainMenu_LabelFontsize% bold
        Options3 = x%posX3% y%posY% Centre c%HyperPause_MainMenu_LabelDisabledColor% r4 s%HyperPause_MainMenu_LabelFontsize% bold
        If (A_LoopField="Change Disc") { 
            Gdip_Alt_TextToGraphics(HP_G25, "Change " . romTable[1,6], Options1, HyperPause_MainMenu_LabelFont, 0, 0)
            Gdip_Alt_TextToGraphics(HP_G25, "Change " . romTable[1,6], Options2, HyperPause_MainMenu_LabelFont, 0, 0)
            Gdip_Alt_TextToGraphics(HP_G25, "Change " . romTable[1,6], Options3, HyperPause_MainMenu_LabelFont, 0, 0)
        } Else {
            Gdip_Alt_TextToGraphics(HP_G25, A_LoopField, Options1, HyperPause_MainMenu_LabelFont, 0, 0)
            Gdip_Alt_TextToGraphics(HP_G25, A_LoopField, Options2, HyperPause_MainMenu_LabelFont, 0, 0)
            Gdip_Alt_TextToGraphics(HP_G25, A_LoopField, Options3, HyperPause_MainMenu_LabelFont, 0, 0)            
        }
        posX1 := posX1+(HyperPause_MainMenu_HdistBetwLabels+hpMainMenuLabelMaxWidth)
        posX2 := posX2+(HyperPause_MainMenu_HdistBetwLabels+hpMainMenuLabelMaxWidth)
        posx3 := posX3+(HyperPause_MainMenu_HdistBetwLabels+hpMainMenuLabelMaxWidth)
        color := HyperPause_MainMenu_LabelDisabledColor
    }
Return


UpdateDescription: ;Updating moving description text position
    Options = y0 c%HyperPause_MainMenu_Info_Description_FontColor% r4 s%HyperPause_MainMenu_Info_Description_FontSize% Regular
    descX := (-descX >= E3) ? baseScreenWidth+HyperPause_MainMenu_Info_Description_FontSize : descX-HyperPause_MainMenu_DescriptionScrollingVelocity
    Gdip_GraphicsClear(HP_G24)
    E := Gdip_Alt_TextToGraphics(HP_G24, Description, "x" descX " " Options, "Arial", (descX < 0) ? baseScreenWidth+HyperPause_MainMenu_Info_Description_FontSize-descX : baseScreenWidth+HyperPause_MainMenu_Info_Description_FontSize, HyperPause_MainMenu_Info_Description_FontSize)
    StringSplit, E, E, |
    Alt_UpdateLayeredWindow(HP_hwnd24, HP_hdc24,0,posDescriptionY, baseScreenWidth, 2*HyperPause_MainMenu_Info_Description_FontSize)
Return


SubMenuBottomApearanceAnimation: ;Showing SubMenu contents animation 
    if !Point1x
        CalcSubMenuCoordinates() 
    ApearanceAnimationbegintime := A_TickCount
    Loop {
        submenuanimationdrawncount++
        Gdip_GraphicsClear(HP_G27)
        pGraphUpd(HP_G27,HyperPause_SubMenu_Width, A_TickCount-ApearanceAnimationbegintime)
        RPoint1x := Point1x, RPoint1y := Point1y, RPoint2x := Point2x, RPoint2y := Point2y, RPoint3x := Point3x, RPoint3y := Point3y
        GraphicsCoordUpdate(HP_G27,RPoint1x,RPoint1y)
        GraphicsCoordUpdate(HP_G27,RPoint2x,RPoint2y)
        GraphicsCoordUpdate(HP_G27,RPoint3x,RPoint3y)
        Gdip_Alt_FillRectangle(HP_G27, HyperPause_SubMenu_BackgroundBrushV, Point1x, Point1y, HyperPause_SubMenu_Width-HyperPause_SubMenu_TopRightChamfer, HyperPause_SubMenu_Height)
        Gdip_Alt_FillRectangle(HP_G27, HyperPause_SubMenu_BackgroundBrushV, Point2x, Point2y, HyperPause_SubMenu_TopRightChamfer, HyperPause_SubMenu_Height-HyperPause_SubMenu_TopRightChamfer)
        Gdip_FillPolygon(HP_G27, HyperPause_SubMenu_BackgroundBrushV,  RPoint1x . "," . RPoint1y . "|" . RPoint2x . "," . RPoint2y . "|" . RPoint3x . "," . RPoint3y, FillMode=0)
        posy := baseScreenHeight-(A_TickCount-ApearanceAnimationbegintime)
        If((posy<=baseScreenHeight-HyperPause_SubMenu_Height)or(SubMenuDrawn=1)){
            pGraphUpd(HP_G27,HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
            RPoint1x := Point1x, RPoint1y := Point1y, RPoint2x := Point2x, RPoint2y := Point2y, RPoint3x := Point3x, RPoint3y := Point3y
            GraphicsCoordUpdate(HP_G27,RPoint1x,RPoint1y)
            GraphicsCoordUpdate(HP_G27,RPoint2x,RPoint2y)
            GraphicsCoordUpdate(HP_G27,RPoint3x,RPoint3y)
            Alt_UpdateLayeredWindow(HP_hwnd27, HP_hdc27,baseScreenWidth-HyperPause_SubMenu_Width,baseScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
           break
        }
        Alt_UpdateLayeredWindow(HP_hwnd27, HP_hdc27,baseScreenWidth-HyperPause_SubMenu_Width,posy, HyperPause_SubMenu_Width, A_TickCount-ApearanceAnimationbegintime)
    }
Return

CalcSubMenuCoordinates(){
    Global
    Point1x := HyperPause_SubMenu_TopRightChamfer
    Point1y := HyperPause_SubMenu_Height-HyperPause_SubMenu_Height
    Point2x := 0
    Point2y := HyperPause_SubMenu_Height+HyperPause_SubMenu_TopRightChamfer-HyperPause_SubMenu_Height
    Point3x := HyperPause_SubMenu_TopRightChamfer
    Point3y := HyperPause_SubMenu_Height+HyperPause_SubMenu_TopRightChamfer-HyperPause_SubMenu_Height
    RPoint1x := Point1x, RPoint1y := Point1y, RPoint2x := Point2x, RPoint2y := Point2y, RPoint3x := Point3x, RPoint3y := Point3y
    pGraphUpd(HP_G27,HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
    GraphicsCoordUpdate(HP_G27,RPoint1x,RPoint1y)
    GraphicsCoordUpdate(HP_G27,RPoint2x,RPoint2y)
    GraphicsCoordUpdate(HP_G27,RPoint3x,RPoint3y)
Return
}

DrawSubMenu: ;Drawing SubMenu Background
    Gdip_GraphicsClear(HP_G26)
    Gdip_GraphicsClear(HP_G27)
    pGraphUpd(HP_G27,HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
    If not ((SelectedMenuOption = "Controller") and (!(HPMediaObj["Controller"].TotalLabels))) or (SelectedMenuOption = "Shutdown") {
        if !Point1x
            CalcSubMenuCoordinates() 
        Gdip_Alt_FillRectangle(HP_G27, HyperPause_SubMenu_BackgroundBrushV, Point1x, Point1y, HyperPause_SubMenu_Width-HyperPause_SubMenu_TopRightChamfer, HyperPause_SubMenu_Height)
        Gdip_Alt_FillRectangle(HP_G27, HyperPause_SubMenu_BackgroundBrushV, Point2x, Point2y, HyperPause_SubMenu_TopRightChamfer, HyperPause_SubMenu_Height-HyperPause_SubMenu_TopRightChamfer)
        Gdip_FillPolygon(HP_G27, HyperPause_SubMenu_BackgroundBrushV,  RPoint1x . "," . RPoint1y . "|" . RPoint2x . "," . RPoint2y . "|" . RPoint3x . "," . RPoint3y, FillMode=0)
    }
    If !submenuMouseClickChange
        SoundPlay %HyperPause_MenuSoundPath%hpsubmenu.wav
    Else
        submenuMouseClickChange =
    If not (SelectedMenuOption = "Shutdown") {
        Loop, parse, HyperPause_MainMenu_Labels,|
        {
            If (HyperPause_MainMenuItem = a_Index) { 
                StringReplace, SelectedMenuOption, A_LoopField, %A_SPACE%,, All
                Gosub %SelectedMenuOption%
            }
        }
    }
    Alt_UpdateLayeredWindow(HP_hwnd26, HP_hdc26,ConfigMenuX,ConfigMenuY, ConfigMenuWidth, ConfigMenuHeight)
    Alt_UpdateLayeredWindow(HP_hwnd27, HP_hdc27,baseScreenWidth-HyperPause_SubMenu_Width,baseScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
    Log("Loaded " SelectedMenuOption " SubMenu",1)
    SubMenuDrawn=1
Return   


SubMenuUpdate: ;Drawing SubMenu Contents
		If ((A_TimeIdle >= HyperPause_SubMenu_DelayinMilliseconds) and (MenuChanged = 1)) {
            If(HyperPause_Active=true)
                gosub, DisableKeys
            If SelectedMenuOption
                If(SubMenuDrawn<>1) 
                    If (SelectedMenuOption <> "Shutdown") and not ((SelectedMenuOption = "Controller") and (!(HPMediaObj["Controller"].TotalLabels)))
                        gosub, SubMenuBottomApearanceAnimation
            Loop, parse, HyperPause_MainMenu_Labels,|
                {
                If (HyperPause_MainMenuItem = a_Index) { 
                StringReplace, SelectedMenuOption, A_LoopField, %A_SPACE%,, All
                }
            }
            If not (SelectedMenuOption = "Shutdown")
                Gosub DrawSubMenu
            MenuChanged = 0
            If(HyperPause_Active=true)
                gosub, EnableKeys
        }
Return

;-----------------SUB MENU DRAWING-------------

;-------Controller Sub Menu------- 
Controller:
    ;drawing config controls option
    If (keymapperEnabled = "true") {
        If FileExist(HyperPause_KeymapperMediaPath . "Controller Images\controller disconnected.png") {
            controllerDisconnectedBitmap := Gdip_CreateBitmapFromFile(HyperPause_KeymapperMediaPath . "Controller Images\controller disconnected.png")
            Gdip_GetImageDimensions(controllerDisconnectedBitmap, BitmapW, BitmapH)
            controllerDisconnectedBitmapW := round(HyperPause_ControllerBannerHeight/BitmapH*BitmapW) 
        }
        If(VSubMenuItem = -1){
            color := HyperPause_MainMenu_LabelSelectedColor
            Optionbrush := HyperPause_SubMenu_SelectedBrushV            
        } Else {
            color := HyperPause_MainMenu_LabelDisabledColor
            Optionbrush := HyperPause_SubMenu_DisabledBrushV           
        }
        Gdip_Alt_FillRoundedRectangle(HP_G26, Optionbrush, 0, 0, ConfigMenuWidth, ConfigMenuHeight,HyperPause_SubMenu_RadiusofRoundedCorners)
        Gdip_Alt_TextToGraphics(HP_G26, "Control Config", "x" . ConfigMenuWidth//2 . " y" . HyperPause_SubMenu_AdditionalTextMarginContour//2 . " Center c" . color . " r4 s" . HyperPause_SubMenu_FontSize . " bold",         HyperPause_SubMenu_LabelFont, 0, 0)
        If(VSubMenuItem = -1) and (FullScreenView = 1){
            gosub, CheckConnectedJoys
            Loop, 16
                {
                If joyConnectedInfo[A_Index,1]
                    {
                    If FileExist(HyperPause_KeymapperMediaPath . "Controller Images\" . joyConnectedInfo[A_Index,2] . ".png")
                        joyConnectedInfo[A_Index,8] := HyperPause_KeymapperMediaPath . "Controller Images\" . joyConnectedInfo[A_Index,2] . ".png"
                    Else If FileExist(HyperPause_KeymapperMediaPath . "Controller Images\" . joyConnectedInfo[A_Index,6] . ".png")
                        joyConnectedInfo[A_Index,8] := HyperPause_KeymapperMediaPath . "Controller Images\" . joyConnectedInfo[A_Index,2] . ".png"
                    Else
                        joyConnectedInfo[A_Index,8] := HyperPause_KeymapperMediaPath . "Controller Images\default.png"
                }   
            }
            Loop, 16
                {
                If 	joyConnectedInfo[A_Index,1]
                    { 
                    TextSize := MeasureText(joyConnectedInfo[A_Index,7], "Centre r4 s" . HyperPause_SubMenu_FontSize . " bold",HyperPause_SubMenu_LabelFont)+HyperPause_SubMenu_AdditionalTextMarginContour    
                    ControllerNameTextSize := If ControllerNameTextSize > TextSize ? ControllerNameTextSize : TextSize
                    joyConnectedInfo[A_Index,9] := Gdip_CreateBitmapFromFile(joyConnectedInfo[A_Index,8])
                    Gdip_GetImageDimensions(joyConnectedInfo[A_Index,9], BitmapW, BitmapH)
                    joyConnectedInfo[A_Index,10] := round(HyperPause_ControllerBannerHeight/BitmapH*BitmapW) 
                    maxImageWidthSize := If maxImageWidthSize > joyConnectedInfo[A_Index,10] ? maxImageWidthSize : joyConnectedInfo[A_Index,10]
                    maxImageWidthSize := If maxImageWidthSize > controllerDisconnectedBitmapW ? maxImageWidthSize : controllerDisconnectedBitmapW                
                }
            }
            maxControllerTextsize := If ControllerNameTextSize > maxControllerTableTitleSize ? ControllerNameTextSize : maxControllerTableTitleSize
            NumberingTextSize := MeasureText("4", "Center r4 s" . HyperPause_SubMenu_FontSize . " bold",HyperPause_SubMenu_LabelFont)+HyperPause_SubMenu_AdditionalTextMarginContour 
            BannerTitleY := HyperPause_SubMenu_FullScreenMargin+2*HyperPause_vDistanceBetweenButtons
            PlayerX := HyperPause_SubMenu_AdditionalTextMarginContour+NumberingTextSize//2
            BitmapX := PlayerX + NumberingTextSize//2 + HyperPause_hDistanceBetweenControllerBannerElements
            ControllerNameX := BitmapX + maxImageWidthSize + HyperPause_hDistanceBetweenControllerBannerElements
            BannerWidth := ControllerNameX+maxControllerTextsize+HyperPause_SubMenu_AdditionalTextMarginContour
            HyperPause_ControllerFullScreenWidth := BannerWidth+8*HyperPause_SubMenu_FullScreenMargin
            Gdip_GraphicsClear(HP_G29)
            pGraphUpd(HP_G29,HyperPause_ControllerFullScreenWidth, baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin)
            Gdip_Alt_FillRoundedRectangle(HP_G29, HyperPause_SubMenu_FullScreenTextBrushV, 0, 0, HyperPause_ControllerFullScreenWidth, baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin, HyperPause_SubMenu_FullScreenRadiusofRoundedCorners)
            ;drawing the exit full screen button
            ControllerTextButtonSize := MeasureText("Restore Preferred Order", "Center r4 s" . HyperPause_SubMenu_FontSize . " bold",HyperPause_SubMenu_LabelFont)+HyperPause_SubMenu_AdditionalTextMarginContour 
            TextSize := MeasureText("Exit Control Config", "Center r4 s" . HyperPause_SubMenu_FontSize . " bold",HyperPause_SubMenu_LabelFont)+HyperPause_SubMenu_AdditionalTextMarginContour 
            ControllerTextButtonSize := If ControllerTextButtonSize > TextSize ? ControllerTextButtonSize : TextSize
            If (V2SubMenuItem = 1){
                color := HyperPause_MainMenu_LabelSelectedColor
                Optionbrush := HyperPause_SubMenu_SelectedBrushV 
            } Else {
                color := HyperPause_MainMenu_LabelDisabledColor
                Optionbrush := HyperPause_SubMenu_DisabledBrushV         
            }
            posX := HyperPause_ControllerFullScreenWidth-2*HyperPause_SubMenu_FullScreenMargin-ControllerTextButtonSize-2*HyperPause_SubMenu_AdditionalTextMarginContour
            Width := ControllerTextButtonSize+2*HyperPause_SubMenu_AdditionalTextMarginContour
            Height := HyperPause_SubMenu_FontSize+2*HyperPause_SubMenu_AdditionalTextMarginContour
            Gdip_Alt_FillRoundedRectangle(HP_G29, Optionbrush, posX, HyperPause_SubMenu_FullScreenMargin, Width, Height,HyperPause_SubMenu_RadiusofRoundedCorners)
            Gdip_Alt_TextToGraphics(HP_G29, "Exit Control Config", "x" . posX+Width//2 . " y" . HyperPause_SubMenu_FullScreenMargin+HyperPause_VTextDisplacementAdjust+HyperPause_SubMenu_AdditionalTextMarginContour . " Center c" . color . " r4 s" . HyperPause_SubMenu_FontSize . " bold", HyperPause_SubMenu_LabelFont, 0, 0)            
            If (V2SubMenuItem = 1)
                Gdip_Alt_DrawRoundedRectangle(HP_G29, HyperPause_SubMenu_ControllerSelectedPen, posX, HyperPause_SubMenu_FullScreenMargin, Width, Height,HyperPause_SubMenu_RadiusofRoundedCorners)
            ;drawing Restore Preferred Order button
            If (V2SubMenuItem = 2) {
                color := HyperPause_MainMenu_LabelSelectedColor
                Optionbrush := HyperPause_SubMenu_SelectedBrushV 
            } Else {
                color := HyperPause_MainMenu_LabelDisabledColor
                Optionbrush := HyperPause_SubMenu_DisabledBrushV           
            }             
            posY := HyperPause_SubMenu_FullScreenMargin+HyperPause_vDistanceBetweenButtons
            Gdip_Alt_FillRoundedRectangle(HP_G29, Optionbrush, posX, posY, Width, Height,HyperPause_SubMenu_RadiusofRoundedCorners)
            Gdip_Alt_TextToGraphics(HP_G29, "Restore Preferred Order", "x" . posX+Width//2 . " y" . posY+HyperPause_SubMenu_AdditionalTextMarginContour+HyperPause_VTextDisplacementAdjust . " Center c" . color . " r4 s" . HyperPause_SubMenu_FontSize . " bold", HyperPause_SubMenu_LabelFont, 0, 0)
            If (V2SubMenuItem = 2)
                Gdip_Alt_DrawRoundedRectangle(HP_G29, HyperPause_SubMenu_ControllerSelectedPen, posX, posY, Width, Height,HyperPause_SubMenu_RadiusofRoundedCorners)
            ;drawing Control Banners
            BannerMargin := (HyperPause_ControllerFullScreenWidth-BannerWidth)//2
            PlayerX := PlayerX+BannerMargin
            BitmapX := BitmapX+BannerMargin
            ControllerNameX := ControllerNameX+BannerMargin
            If (V2SubMenuItem > 2){
                color := HyperPause_MainMenu_LabelSelectedColor
                Optionbrush := HyperPause_SubMenu_SelectedBrushV 
            } Else {
                color := HyperPause_MainMenu_LabelDisabledColor
                Optionbrush := HyperPause_SubMenu_DisabledBrushV         
            }
            Gdip_Alt_TextToGraphics(HP_G29, "Player", "x" . PlayerX . " y" . BannerTitleY . " Center c" . color . " r4 s" . HyperPause_SubMenu_FontSize . " bold", HyperPause_SubMenu_LabelFont, 0, 0)
            Gdip_Alt_TextToGraphics(HP_G29, "Controller", "x" . ControllerNameX+maxControllerTextsize//2 . " y" . BannerTitleY . " Center c" . color . " r4 s" . HyperPause_SubMenu_FontSize . " bold", HyperPause_SubMenu_LabelFont, 0, 0)
            numberOfBannersperScreen := (baseScreenHeight-HyperPause_SubMenu_FullScreenMargin-BannerTitleY-HyperPause_vDistanceBetweenBanners)//(HyperPause_ControllerBannerHeight+HyperPause_vDistanceBetweenBanners)
            firstbanner := If (V2SubMenuItem-1 - numberOfBannersperScreen) > 0 ? (V2SubMenuItem-1 - numberOfBannersperScreen) : 1
            Loop, %numberOfBannersperScreen%
                {
                BannerPosY := BannerTitleY+HyperPause_vDistanceBetweenBanners+(a_index-1)*(HyperPause_ControllerBannerHeight+HyperPause_vDistanceBetweenBanners)
                If (V2SubMenuItem = a_index+2+firstbanner-1){
                    color := HyperPause_MainMenu_LabelSelectedColor
                    Optionbrush := HyperPause_SubMenu_SelectedBrushV 
                } Else {
                    color := HyperPause_MainMenu_LabelDisabledColor
                    Optionbrush := HyperPause_SubMenu_DisabledBrushV         
                }
                Gdip_Alt_FillRoundedRectangle(HP_G29, Optionbrush, BannerMargin, BannerPosY, BannerWidth, HyperPause_ControllerBannerHeight,HyperPause_SubMenu_RadiusofRoundedCorners)
                If (V2SubMenuItem = a_index+2+firstbanner-1)
                    Gdip_Alt_DrawRoundedRectangle(HP_G29, HyperPause_SubMenu_ControllerSelectedPen, BannerMargin, BannerPosY, BannerWidth, HyperPause_ControllerBannerHeight,HyperPause_SubMenu_RadiusofRoundedCorners)
                If (a_index+firstbanner-1 <= 4)
                    Gdip_Alt_TextToGraphics(HP_G29, a_index+firstbanner-1, "x" . PlayerX . " y" . BannerPosY+HyperPause_VTextDisplacementAdjust+(HyperPause_ControllerBannerHeight-HyperPause_SubMenu_FontSize)//2 . " Center c" . color . " r4 s" . HyperPause_SubMenu_FontSize . " bold", HyperPause_SubMenu_LabelFont, 0, 0)
                Else
                    Gdip_Alt_TextToGraphics(HP_G29, ".", "x" . PlayerX . " y" . BannerPosY+HyperPause_VTextDisplacementAdjust+(HyperPause_ControllerBannerHeight-HyperPause_SubMenu_FontSize)//2 . " Center c" . color . " r4 s" . HyperPause_SubMenu_FontSize . " bold", HyperPause_SubMenu_LabelFont, 0, 0)
                If joyConnectedInfo[a_index+firstbanner-1,1]
                    Gdip_Alt_DrawImage(HP_G29, joyConnectedInfo[a_index+firstbanner-1,9], BitmapX+(maxImageWidthSize-joyConnectedInfo[a_index+firstbanner-1,10])//2, BannerPosY, joyConnectedInfo[a_index+firstbanner-1,10], HyperPause_ControllerBannerHeight)
                Else
                    Gdip_Alt_DrawImage(HP_G29, controllerDisconnectedBitmap, BitmapX+(maxImageWidthSize-controllerDisconnectedBitmapW)//2, BannerPosY, controllerDisconnectedBitmapW, HyperPause_ControllerBannerHeight)
                Gdip_Alt_TextToGraphics(HP_G29, joyConnectedInfo[a_index+firstbanner-1,7], "x" . ControllerNameX+maxControllerTextsize//2 . " y" . BannerPosY+HyperPause_VTextDisplacementAdjust+(HyperPause_ControllerBannerHeight-HyperPause_SubMenu_FontSize)//2 . " Center c" . color . " r4 s" . HyperPause_SubMenu_FontSize . " bold", HyperPause_SubMenu_LabelFont, 0, 0)
            }
            ; drawing submenu with profile options
            If  (HSubMenuItem = 2) {
                If (V2SubMenuItem > 2){
                    possibleProfilesList := Keymapper_HyperPauseProfileList%zz%(joyConnectedInfo[V2SubMenuItem-2,2],V2SubMenuItem-2,keymapper)
                    If  V3SubMenuItem < 1 
                        V3SubMenuItem := % possibleProfilesList.MaxIndex() 
                    If  V3SubMenuItem > % possibleProfilesList.MaxIndex() 
                        V3SubMenuItem = 1
                    secondColumnWidth := MeasureText("emulator", "Left r4 s" . HyperPause_SubMenu_SmallFontSize . " bold",HyperPause_SubMenu_Font)
                    thirdColumnWidth := 0
                    Loop, % possibleProfilesList.MaxIndex() 
                        {
                        tempWidth := MeasureText(possibleProfilesList[a_index,1], "Left r4 s" . HyperPause_SubMenu_SmallFontSize . " bold",HyperPause_SubMenu_Font)
                        if (tempWidth > thirdColumnWidth)
                            thirdColumnWidth := tempWidth
                    }
                    titleWidth := MeasureText("Choose the Profile That you want to load", "Left r4 s" . HyperPause_SubMenu_FontSize . " bold",HyperPause_SubMenu_LabelFont) + 2*HyperPause_Controller_Profiles_Margin 
                    profilesListWidth := if ((HyperPause_Controller_Profiles_First_Column_Width+secondColumnWidth+thirdColumnWidth+4*HyperPause_Controller_Profiles_Margin) > titleWidth) ? (HyperPause_Controller_Profiles_First_Column_Width+secondColumnWidth+thirdColumnWidth+4*HyperPause_Controller_Profiles_Margin) : titleWidth
                    Gdip_Alt_FillRoundedRectangle(HP_G29, HyperPause_SubMenu_SelectedBrushV, BannerMargin+HyperPause_selectedControllerBannerDisplacement, BannerTitleY+HyperPause_vDistanceBetweenBanners-HyperPause_VTextDisplacementAdjust, profilesListWidth, (possibleProfilesList.MaxIndex())*(HyperPause_SubMenu_SmallFontSize + HyperPause_Controller_Profiles_Margin) + 2*(HyperPause_SubMenu_FontSize + HyperPause_Controller_Profiles_Margin) + HyperPause_Controller_Profiles_Margin,HyperPause_SubMenu_RadiusofRoundedCorners)
                    Gdip_Alt_TextToGraphics(HP_G29, "Choose the Profile That you want to load:", "x" . BannerMargin+HyperPause_selectedControllerBannerDisplacement+HyperPause_Controller_Profiles_Margin . " y" . BannerTitleY+HyperPause_vDistanceBetweenBanners+HyperPause_Controller_Profiles_Margin . " Left c" . HyperPause_MainMenu_LabelSelectedColor . " r4 s" . HyperPause_SubMenu_FontSize . " bold", HyperPause_SubMenu_LabelFont)
                    Gdip_Alt_TextToGraphics(HP_G29, "Type", "x" . BannerMargin+HyperPause_selectedControllerBannerDisplacement+HyperPause_Controller_Profiles_First_Column_Width+2*HyperPause_Controller_Profiles_Margin . " y" . BannerTitleY+HyperPause_vDistanceBetweenBanners+2*HyperPause_Controller_Profiles_Margin+HyperPause_SubMenu_FontSize . " Left c" . HyperPause_MainMenu_LabelSelectedColor . " r4 s" . HyperPause_SubMenu_FontSize . " bold", HyperPause_SubMenu_LabelFont)
                    Gdip_Alt_TextToGraphics(HP_G29, "File Name", "x" . BannerMargin+HyperPause_selectedControllerBannerDisplacement+HyperPause_Controller_Profiles_First_Column_Width+secondColumnWidth+3*HyperPause_Controller_Profiles_Margin . " y" . BannerTitleY+HyperPause_vDistanceBetweenBanners+2*HyperPause_Controller_Profiles_Margin+HyperPause_SubMenu_FontSize . " Left c" . HyperPause_MainMenu_LabelSelectedColor . " r4 s" . HyperPause_SubMenu_FontSize . " bold", HyperPause_SubMenu_LabelFont)
                    if !profileRecommendedBitmap
                        If FileExist(HLMediaPath . "\Menu Images\HyperPause\Icons\Recommended.png") 
                            profileRecommendedBitmap := Gdip_CreateBitmapFromFile(HLMediaPath . "\Menu Images\HyperPause\Icons\Recommended.png")
                    if !profileQuestionMarkBitmap
                        If FileExist(HLMediaPath . "\Menu Images\HyperPause\Icons\QuestionMark.png") 
                            profileQuestionMarkBitmap := Gdip_CreateBitmapFromFile(HLMediaPath . "\Menu Images\HyperPause\Icons\QuestionMark.png")    
                    if !selectedProfile[V2SubMenuItem-2,1] {
                        currentSelectedProfile := 1 
						If (keymapper = "xpadder") {
							selectedProfile[V2SubMenuItem-2,1] := 1
							selectedProfile[V2SubMenuItem-2,2] := possibleProfilesList[1,4] ;store for later use with xpadder and joytokey run functions
						} else if (keymapper="joy2key") OR (keymapper = "joytokey") {
							Loop, 16
							{
								selectedProfile[A_Index,1] := 1
								selectedProfile[A_Index,2] := possibleProfilesList[1,4] ;store for later use with xpadder and joytokey run functions
							}
						}
					} else
                        currentSelectedProfile := selectedProfile[V2SubMenuItem-2,1]
                    Loop, % possibleProfilesList.MaxIndex()
                        {
                        If (a_index = V3SubMenuItem)
                            color := HyperPause_MainMenu_LabelSelectedColor
                        Else If (a_index = currentSelectedProfile)
                            color := "ffffff00"
                        Else
                            color := HyperPause_MainMenu_LabelDisabledColor
                        If possibleProfilesList[a_index,3]
                            Gdip_Alt_DrawImage(HP_G29, profileRecommendedBitmap, BannerMargin+HyperPause_selectedControllerBannerDisplacement+HyperPause_Controller_Profiles_Margin, BannerTitleY+HyperPause_vDistanceBetweenBanners+3*HyperPause_Controller_Profiles_Margin+2*HyperPause_SubMenu_FontSize + (a_index-1)*(HyperPause_Controller_Profiles_Margin+HyperPause_SubMenu_SmallFontSize)-(HyperPause_Controller_Profiles_First_Column_Width-HyperPause_SubMenu_SmallFontSize)//2, HyperPause_Controller_Profiles_First_Column_Width, HyperPause_Controller_Profiles_First_Column_Width)
                         else
                            Gdip_Alt_DrawImage(HP_G29, profileQuestionMarkBitmap, BannerMargin+HyperPause_selectedControllerBannerDisplacement+HyperPause_Controller_Profiles_Margin, BannerTitleY+HyperPause_vDistanceBetweenBanners+3*HyperPause_Controller_Profiles_Margin+2*HyperPause_SubMenu_FontSize + (a_index-1)*(HyperPause_Controller_Profiles_Margin+HyperPause_SubMenu_SmallFontSize)-(HyperPause_Controller_Profiles_First_Column_Width-HyperPause_SubMenu_SmallFontSize)//2, HyperPause_Controller_Profiles_First_Column_Width, HyperPause_Controller_Profiles_First_Column_Width) 
                        Gdip_Alt_TextToGraphics(HP_G29, possibleProfilesList[a_index,2], "x" . BannerMargin+HyperPause_selectedControllerBannerDisplacement+HyperPause_Controller_Profiles_First_Column_Width+2*HyperPause_Controller_Profiles_Margin . " y" . BannerTitleY+HyperPause_vDistanceBetweenBanners+3*HyperPause_Controller_Profiles_Margin+2*HyperPause_SubMenu_FontSize + (a_index-1)*(HyperPause_Controller_Profiles_Margin+HyperPause_SubMenu_SmallFontSize) . " Left c" . color . " r4 s" . HyperPause_SubMenu_SmallFontSize . " bold", HyperPause_SubMenu_Font)
                        Gdip_Alt_TextToGraphics(HP_G29, possibleProfilesList[a_index,1], "x" . BannerMargin+HyperPause_selectedControllerBannerDisplacement+HyperPause_Controller_Profiles_First_Column_Width+secondColumnWidth+3*HyperPause_Controller_Profiles_Margin . " y" . BannerTitleY+HyperPause_vDistanceBetweenBanners+3*HyperPause_Controller_Profiles_Margin+2*HyperPause_SubMenu_FontSize + (a_index-1)*(HyperPause_Controller_Profiles_Margin+HyperPause_SubMenu_SmallFontSize) . " Left c" . color . " r4 s" . HyperPause_SubMenu_SmallFontSize . " bold", HyperPause_SubMenu_Font)
                    }
                }
            } else {
                V3SubMenuItem := 1
            }
            ;drawing moving selected controller banner
            If (V2SubMenuItem <= 2) or (HSubMenuItem = 2)
                SelectedController :=
            If SelectedController {
                BannerPosY := BannerTitleY+HyperPause_vDistanceBetweenBanners+(V2SubMenuItem-2-firstbanner+1-1)*(HyperPause_ControllerBannerHeight+HyperPause_vDistanceBetweenBanners)
                color := HyperPause_MainMenu_LabelSelectedColor
                Optionbrush := HyperPause_SubMenu_SelectedBrushV 
                Gdip_Alt_FillRoundedRectangle(HP_G29, Optionbrush, BannerMargin+HyperPause_selectedControllerBannerDisplacement, BannerPosY+HyperPause_selectedControllerBannerDisplacement, BannerWidth, HyperPause_ControllerBannerHeight,HyperPause_SubMenu_RadiusofRoundedCorners)
                Gdip_Alt_DrawRoundedRectangle(HP_G29, HyperPause_SubMenu_ControllerSelectedPen, BannerMargin+HyperPause_selectedControllerBannerDisplacement, BannerPosY+HyperPause_selectedControllerBannerDisplacement, BannerWidth, HyperPause_ControllerBannerHeight,HyperPause_SubMenu_RadiusofRoundedCorners)
                Gdip_Alt_TextToGraphics(HP_G29, ".", "x" . PlayerX+HyperPause_selectedControllerBannerDisplacement . " y" . BannerPosY+(HyperPause_ControllerBannerHeight-HyperPause_SubMenu_FontSize)//2+HyperPause_selectedControllerBannerDisplacement . " Center c" . color . " r4 s" . HyperPause_SubMenu_FontSize . " bold", HyperPause_SubMenu_LabelFont, 0, 0)
                Gdip_Alt_DrawImage(HP_G29, joyConnectedInfo[SelectedController,9], BitmapX+HyperPause_selectedControllerBannerDisplacement, BannerPosY+HyperPause_selectedControllerBannerDisplacement, joyConnectedInfo[SelectedController,10], HyperPause_ControllerBannerHeight)
                Gdip_Alt_TextToGraphics(HP_G29, joyConnectedInfo[SelectedController,7], "x" . ControllerNameX+maxControllerTextsize//2+HyperPause_selectedControllerBannerDisplacement . " y" . BannerPosY+(HyperPause_ControllerBannerHeight-HyperPause_SubMenu_FontSize)//2+HyperPause_selectedControllerBannerDisplacement . " Center c" . color . " r4 s" . HyperPause_SubMenu_FontSize . " bold", HyperPause_SubMenu_LabelFont, 0, 0)
            }          
            Alt_UpdateLayeredWindow(HP_hwnd29, HP_hdc29,(baseScreenWidth-HyperPause_ControllerFullScreenWidth)//2, HyperPause_SubMenu_FullScreenMargin, HyperPause_ControllerFullScreenWidth, baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin)
        } Else {
            V2SubMenuItem := 1   
        }
    }
    If (HPMediaObj["Controller"].TotalLabels)
        TextImagesAndPDFMenu("Controller")
Return

CheckConnectedJoys:
    If !joyConnectedInfo
        joyConnectedInfo:=[]  ; joyConnectedInfo[port,1] = number_of_buttons    joyConnectedInfo[port,2] = OemName   joyConnectedInfo[A_Index,3] Mid   joyConnectedInfo[A_Index,4] Pid    joyConnectedInfo[A_Index,5] Guid    joyConnectedInfo[port,6] = CustomJoyName     joyConnectedInfo[A_Index,7] Name to be used on menu joyConnectedInfo[A_Index,8] Path to image    joyConnectedInfo[A_Index,9] bitmap pointer    yConnectedInfo[A_Index,10] bitmap width   
	joystickArray := GetJoystickArray%zz%()
    Loop 16  ; Query each joystick number to find out which ones exist.
        {
        currentController := A_Index
        Loop, 7
            joyConnectedInfo[currentController,A_Index] := ""
        controllerName := joystickArray[currentController,1]
		Mid := joystickArray[currentController,2]
		Pid := joystickArray[currentController,3]
		GUID := joystickArray[currentController,4]
		If controllerName
            {
            GetKeyState, buttonsNumber, %currentController%JoyButtons
			joyConnectedInfo[currentController,1] := buttonsNumber
            joyConnectedInfo[currentController,2] := controllerName
			joyConnectedInfo[currentController,3] := Mid
			joyConnectedInfo[currentController,4] := Pid
			joyConnectedInfo[currentController,5] := GUID
            joyConnectedInfo[currentController,6] := CustomJoyNameArray[controllerName]
            joyConnectedInfo[currentController,7] := If joyConnectedInfo[currentController,6] ? joyConnectedInfo[currentController,6] : joyConnectedInfo[currentController,2]
        }
    }
Return


CheckJoyPresses:
    If SelectedController
        Return
    Loop, 16
        {
        If 	joyConnectedInfo[A_Index,1]
            {
            joy_buttons := joyConnectedInfo[A_Index,1]
            JoystickNumber := A_Index
            Loop, %joy_buttons%
                {
                GetKeyState, joy%a_index%, %JoystickNumber%joy%a_index%
                If joy%a_index% = D
                    {
                    If (JoystickNumber>=firstbanner) and (JoystickNumber<firstbanner+numberOfBannersperScreen) {
                        ControllerGrowSize := 0
                        TotalGrowSize := HyperPause_Controller_Joy_Selected_Grow_Size*2
                        BannerPosY := BannerTitleY+HyperPause_vDistanceBetweenBanners+(JoystickNumber-firstbanner)*(HyperPause_ControllerBannerHeight+HyperPause_vDistanceBetweenBanners)
                        Loop, %TotalGrowSize% {    
                            If a_index <= % TotalGrowSize//2
                                ControllerGrowSize++
                            Else
                                ControllerGrowSize--   
                            Gdip_GraphicsClear(HP_G30)
                            pGraphUpd(HP_G30,joyConnectedInfo[JoystickNumber,10]+TotalGrowSize, HyperPause_ControllerBannerHeight+TotalGrowSize)
                            Gdip_Alt_DrawImage(HP_G30, joyConnectedInfo[JoystickNumber,9], 0, 0, joyConnectedInfo[JoystickNumber,10]+ControllerGrowSize*2, HyperPause_ControllerBannerHeight+ControllerGrowSize*2)
                            Alt_UpdateLayeredWindow(HP_hwnd30, HP_hdc30, (baseScreenWidth-HyperPause_ControllerFullScreenWidth)//2+BitmapX+(maxImageWidthSize-joyConnectedInfo[JoystickNumber,10])//2-ControllerGrowSize,HyperPause_SubMenu_FullScreenMargin+BannerPosY-ControllerGrowSize, joyConnectedInfo[JoystickNumber,10]+TotalGrowSize, HyperPause_ControllerBannerHeight+TotalGrowSize)
                        }
                        Gdip_GraphicsClear(HP_G30) 
                        Alt_UpdateLayeredWindow(HP_hwnd30, HP_hdc30, (baseScreenWidth-HyperPause_ControllerFullScreenWidth)//2+BitmapX+(maxImageWidthSize-joyConnectedInfo[JoystickNumber,10])//2-TotalGrowSize//2,HyperPause_SubMenu_FullScreenMargin+BannerPosY-TotalGrowSize//2, joyConnectedInfo[JoystickNumber,10]+TotalGrowSize, HyperPause_ControllerBannerHeight+TotalGrowSize)
                    }
                }
            }
        }
    }
Return


;-------Save and Load State Sub Menu-------
SaveState:
    If(VSubMenuItem<>0){
        SubMenuHelpText("Press Select Key to Save the Game")
        if (HyperPause_SaveStateScreenshot = "true")
            SaveStateBackgroundFile := RIni_GetKeyValue(1,dbName,"SaveState" . VSubMenuItem . "Screenshot", false)
        If SaveStateBackgroundFile
            {
            SaveStateBackgroundBitmap := Gdip_CreateBitmapFromFile(HyperPause_SaveScreenshotPath . SaveStateBackgroundFile)
            Gdip_GraphicsClear(HP_G22) 
            Gdip_Alt_DrawImage(HP_G22, SaveStateBackgroundBitmap, 0, 0, baseScreenWidth, baseScreenHeight)
            Alt_UpdateLayeredWindow(HP_hwnd22, HP_hdc22, 0, 0, baseScreenWidth, baseScreenHeight)
        } Else {
            Gdip_GraphicsClear(HP_G22) 
            Gdip_Alt_DrawImage(HP_G22, MainMenuBackgroundBitmap, MainMenuBackgroundX, MainMenuBackgroundY, MainMenuBackgroundW, MainMenuBackgroundH, 0, 0, MainMenuBackgroundBitmapW, MainMenuBackgroundBitmapH)
            Alt_UpdateLayeredWindow(HP_hwnd22, HP_hdc22, 0, 0, baseScreenWidth, baseScreenHeight)
        }
    } Else {
        Gdip_GraphicsClear(HP_G22) 
        Gdip_Alt_DrawImage(HP_G22, MainMenuBackgroundBitmap, MainMenuBackgroundX, MainMenuBackgroundY, MainMenuBackgroundW, MainMenuBackgroundH, 0, 0, MainMenuBackgroundBitmapW, MainMenuBackgroundBitmapH)
        Alt_UpdateLayeredWindow(HP_hwnd22, HP_hdc22, 0, 0, baseScreenWidth, baseScreenHeight)
    }
    gosub, StateMenuList
Return

LoadState:
    If(VSubMenuItem<>0){
        SubMenuHelpText("Press Select Key to Load the Game")
        SaveStateBackgroundFile := RIni_GetKeyValue(1,dbName,"SaveState" . VSubMenuItem . "Screenshot", false)
        If SaveStateBackgroundFile
            {
            SaveStateBackgroundBitmap := Gdip_CreateBitmapFromFile(HyperPause_SaveScreenshotPath . SaveStateBackgroundFile)
            Gdip_GraphicsClear(HP_G22) 
            Gdip_Alt_DrawImage(HP_G22, SaveStateBackgroundBitmap, 0, 0, baseScreenWidth, baseScreenHeight)
            Alt_UpdateLayeredWindow(HP_hwnd22, HP_hdc22, 0, 0, baseScreenWidth, baseScreenHeight)
        } Else {
            Gdip_GraphicsClear(HP_G22) 
            Gdip_Alt_DrawImage(HP_G22, MainMenuBackgroundBitmap, MainMenuBackgroundX, MainMenuBackgroundY, MainMenuBackgroundW, MainMenuBackgroundH, 0, 0, MainMenuBackgroundBitmapW, MainMenuBackgroundBitmapH)
            Alt_UpdateLayeredWindow(HP_hwnd22, HP_hdc22, 0, 0, baseScreenWidth, baseScreenHeight)
        }
    } Else {
        Gdip_GraphicsClear(HP_G22) 
        Gdip_Alt_DrawImage(HP_G22, MainMenuBackgroundBitmap, MainMenuBackgroundX, MainMenuBackgroundY, MainMenuBackgroundW, MainMenuBackgroundH, 0, 0, MainMenuBackgroundBitmapW, MainMenuBackgroundBitmapH)
        Alt_UpdateLayeredWindow(HP_hwnd22, HP_hdc22, 0, 0, baseScreenWidth, baseScreenHeight)
    }
    gosub, StateMenuList
Return

StateMenuList:
    SlotEmpty := true
    color := HyperPause_MainMenu_LabelDisabledColor
    Optionbrush := HyperPause_SubMenu_DisabledBrushV
    HyperPause_State_DistBetweenLabelandHour := 50
    WidthofStateText := MeasureText("Save State XX", "Left r4 s" . HyperPause_SubMenu_LabelFontSize . " bold",HyperPause_SubMenu_LabelFont)+HyperPause_SubMenu_AdditionalTextMarginContour
    posStateX := round(HyperPause_State_HMargin+WidthofStateText/2)
    posStateX2 := HyperPause_State_HMargin+WidthofStateText+HyperPause_State_DistBetweenLabelandHour
    posStateY := HyperPause_State_VMargin
    posStateY2 := HyperPause_State_VMargin+HyperPause_SubMenu_FontSize-HyperPause_SubMenu_SmallFontSize
    Loop, % HPMediaObj[SelectedMenuOption].TotalLabels
    {    
    If(VSubMenuItem = A_index ){
        color := HyperPause_MainMenu_LabelSelectedColor
        Optionbrush := HyperPause_SubMenu_SelectedBrushV
        }
    If( A_index >= VSubMenuItem){   
        OptionsState = x%posStateX% y%posStateY% Center c%color% r4 s%HyperPause_SubMenu_LabelFontSize% bold
        OptionsState2 = x%posStateX2% y%posStateY2% Left c%color% r4 s%HyperPause_SubMenu_SmallFontSize% italic
        Gdip_Alt_FillRoundedRectangle(HP_G27, Optionbrush, HyperPause_State_HMargin, posStateY-HyperPause_SubMenu_AdditionalTextMarginContour+HyperPause_VTextDisplacementAdjust, WidthofStateText, HyperPause_SubMenu_FontSize+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_RadiusofRoundedCorners)
        If(SelectedMenuOption="SaveState"){
            StateLabel := "Save State "A_Index
        } Else {
            StateLabel := "Load State "A_Index
        }    
        Gdip_Alt_TextToGraphics(HP_G27, StateLabel, OptionsState, HyperPause_SubMenu_LabelFont, 0, 0)
        ReadSaveTime := RIni_GetKeyValue(1,dbName,"SaveState" . A_index . "SaveTime", "Empty Slot")
        Gdip_Alt_TextToGraphics(HP_G27, ReadSaveTime, OptionsState2, HyperPause_SubMenu_Font, 0, 0)
        posStateY := posStateY+HyperPause_State_VdistBetwLabels
        posStateY2 := posStateY2+HyperPause_State_VdistBetwLabels
        color := HyperPause_MainMenu_LabelDisabledColor
        Optionbrush := HyperPause_SubMenu_DisabledBrushV
        }
    }
    If(SelectedMenuOption="LoadState"){
        ReadSaveTime := RIni_GetKeyValue(1,dbName,"SaveState" . VSubMenuItem . "SaveTime", "Empty Slot")
        If(ReadSaveTime<>"Empty Slot")
            SlotEmpty := false
    }
Return


;-------Change Disc Sub Menu-------
ChangeDisc:
    SetTimer, DiscChangeUpdate, 30  ;setting timer for disc change animations
    If(VSubMenuItem<>0){
        SubMenuHelpText("Press Select Key to Load Disc")
    }
    EnableDiscChangeUpdate = 0
    discAngle:=0    
    If (HyperPause_ChangeDisc_SelectedEffect = "grow") {
        Gdip_GraphicsClear(HP_G30)
        HyperPause_Growing:=
        b := 1
    }
    if !(changeDiscMenuLoaded = true)
        {
        HPDiscChangetotalUsedWidth := 0
        Loop, 2 {
            If FileExist(multiGameImgPath . systemName . "\" . dbName . "\" . romTable[A_Index,6] . "_image_" . A_Index . ".png") 
                Image_%A_Index% := multiGameImgPath . systemName . "\" . dbName . "\" . romTable[A_Index,6] . "_image_" . A_Index . ".png"
            Else If FileExist(multiGameImgPath . systemName . "\" . DescriptionNameWithoutDisc . "\" . romTable[A_Index,6] . "_image_" . A_Index . ".png") 
                Image_%A_Index% := multiGameImgPath . systemName . "\" . DescriptionNameWithoutDisc . "\" . romTable[A_Index,6] . "_image_" . A_Index . ".png"
            Else If FileExist(multiGameImgPath . systemName . "\" . _Default . "\" . romTable[A_Index,6] . "_image_" . A_Index . ".png") 
                Image_%A_Index% := multiGameImgPath . systemName . "\" . _Default . "\" . romTable[A_Index,6] . "_image_" . A_Index . ".png"
            Else If FileExist(multiGameImgPath . "_Default" . "\" . romTable[A_Index,6] . "_image_" . A_Index . ".png") 
                Image_%A_Index% := multiGameImgPath . "_Default" . "\" . romTable[A_Index,6] . "_image_" . A_Index . ".png"     
        }
        HyperPause_ChangeDisc_ImageAdjustV := []
        HyperPause_ChangeDisc_ImageAdjustH := []
        HyperPause_ChangeDisc_ImageAdjust := []
        if (path := feMedia["ArtWork"][feDiscArtworkLabel].Path1)
            SplitPath, path, , feDiscChangeDir
        for index, element in romTable
            {
            Gdip_DisposeImage(romTable[A_Index, 17])
            If (FileExist(HLMediaPath . "\MultiGame\" . systemName . "\" . romTable[A_Index, 3] . "\*.png") && (HyperPause_ChangeDisc_UseGameArt = "true" )) {
                gameArtArray := []
                Loop, % HLMediaPath . "\MultiGame\" . systemName . "\" . romTable[A_Index, 3] . "\*.png"
                    gameArtArray.Insert(A_LoopFileFullPath)
                Random, RndmgameArt, 1, % gameArtArray.MaxIndex()
                gameArtFile := gameArtArray[RndmgameArt]
                romTable[A_Index, 17] := Gdip_CreateBitmapFromFile(gameArtFile)
                romTable[A_Index,16] := "Yes"
            } Else If (FileExist(feDiscChangeDir . "\" . romTable[A_Index, 3] . ".png") && (HyperPause_ChangeDisc_UseGameArt = "true" )) {
                romTable[A_Index, 17] := Gdip_CreateBitmapFromFile(feDiscChangeDir . "\" . romTable[A_Index, 3] . ".png")
                romTable[A_Index,16] := "Yes"
            } Else {
                Gdip_DisposeImage(romTable[A_Index, 18])
                romTable[A_Index, 17] := Gdip_CreateBitmapFromFile(Image_1)
                romTable[A_Index, 18] := Gdip_CreateBitmapFromFile(Image_2)
            }
            Gdip_GetImageDimensions(romTable[A_Index, 17], HyperPause_DiscChange_ArtW, HyperPause_DiscChange_ArtH)
            romTable[A_Index,12] := HyperPause_DiscChange_ArtW, romTable[A_Index,13] := HyperPause_DiscChange_ArtH
            HyperPause_ChangeDisc_ImageAdjustH[A_Index] := ((HyperPause_SubMenu_Width - (romTable.MaxIndex()+1)*HyperPause_ChangingDisc_GrowSize)/romTable.MaxIndex())/romTable[A_Index,12]
            HyperPause_ChangeDisc_ImageAdjustV[A_Index] := (HyperPause_SubMenu_Height-2*HyperPause_ChangeDisc_VMargin-HyperPause_ChangeDisc_TextDisttoImage-HyperPause_SubMenu_FontSize)/romTable[A_Index,13]
            HyperPause_ChangeDisc_ImageAdjust[A_Index] := if (HyperPause_ChangeDisc_ImageAdjustV[A_Index] < HyperPause_ChangeDisc_ImageAdjustH[A_Index]) ? HyperPause_ChangeDisc_ImageAdjustV[A_Index] : HyperPause_ChangeDisc_ImageAdjustH[A_Index]
            romTable[A_Index,14] := round(romTable[A_Index,12]*HyperPause_ChangeDisc_ImageAdjust[A_Index]), romTable[A_Index,15] := round(romTable[A_Index,13]*HyperPause_ChangeDisc_ImageAdjust[A_Index])
            If HyperPause_ChangeDisc_SelectedEffect = rotate
                {
                Gdip_GetRotatedDimensions(romTable[A_Index, 14], romTable[A_Index, 15], 90, HyperPause_DiscChange_RW%A_Index%, HyperPause_DiscChange_RH%A_Index%)
                HyperPause_DiscChange_RW%A_Index% := if (HyperPause_DiscChange_RW%A_Index% > romTable[A_Index, 14]) ? HyperPause_DiscChange_RW%A_Index%* : romTable[A_Index, 14], HyperPause_DiscChange_RH%A_Index% := if (HyperPause_DiscChange_RH%A_Index% > romTable[A_Index, 15]) ? HyperPause_DiscChange_RH%A_Index% : romTable[A_Index, 15]
            }
            HPDiscChangetotalUsedWidth += romTable[A_Index,14]
        }
        HPDiscChangetotalUnusedWidth := HyperPause_SubMenu_Width - HPDiscChangetotalUsedWidth
        HPDiscChangeremainingUnusedWidth := HPDiscChangetotalUnusedWidth * ( 1 - ( HyperPause_ChangeDisc_SidePadding * 2 ))
        HPDiscChangepaddingSpotsNeeded := romTable.MaxIndex() - 1
        HPDiscChangeimageSpacing := round(HPDiscChangeremainingUnusedWidth/HPDiscChangepaddingSpotsNeeded)
        changeDiscMenuLoaded := true
    }
    HPDiscChangeimageXcurrent:=HyperPause_ChangeDisc_SidePadding * HPDiscChangetotalUnusedWidth ;in respect to the top left of the sub menu window
    for index, element in romTable {
        color := HyperPause_MainMenu_LabelDisabledColor
        romTable[A_Index,10] := HPDiscChangeimageXcurrent
        romTable[A_Index,11] :=  (HyperPause_SubMenu_Height - romTable[A_Index,15] - HyperPause_SubMenu_FontSize - HyperPause_ChangeDisc_TextDisttoImage)//2 + HyperPause_SubMenu_FontSize+HyperPause_ChangeDisc_TextDisttoImage
        If(VSubMenuItem=0){
            SetTimer, DiscChangeUpdate, off
            Gdip_ResetWorldTransform(HP_G30)
            Gdip_TranslateWorldTransform(HP_G30, xTranslation, yTranslation)
            Gdip_RotateWorldTransform(HP_G30, screenRotationAngle)
            Gdip_GraphicsClear(HP_G30)
            pGraphUpd(HP_G30,HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
            Alt_UpdateLayeredWindow(HP_hwnd30, HP_hdc30, baseScreenWidth-HyperPause_SubMenu_Width, baseScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
            Gdip_Alt_DrawImage(HP_G27, romTable[A_Index, 17], romTable[A_Index,10], romTable[A_Index,11], romTable[A_Index,14], romTable[A_Index,15])
        } Else If(HSubMenuItem = A_index){    
            color := HyperPause_MainMenu_LabelSelectedColor
            Gdip_GraphicsClear(HP_G30)
            Gdip_ResetWorldTransform(HP_G30)
            Gdip_TranslateWorldTransform(HP_G30, xTranslation, yTranslation)
            Gdip_RotateWorldTransform(HP_G30, screenRotationAngle)
            pGraphUpd(HP_G30,HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
            Gdip_Alt_DrawImage(HP_G30, romTable[A_Index, 17], romTable[A_Index,10], romTable[A_Index,11], romTable[A_Index,14], romTable[A_Index,15])
            Alt_UpdateLayeredWindow(HP_hwnd30, HP_hdc30, baseScreenWidth-HyperPause_SubMenu_Width, baseScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
        } Else {
            Gdip_Alt_DrawImage(HP_G27, romTable[A_Index, 17], romTable[A_Index,10], romTable[A_Index,11], romTable[A_Index,14], romTable[A_Index,15])
        }
        posDiscChangeTextX := HPDiscChangeimageXcurrent
        posDiscChangeTextY := (HyperPause_SubMenu_Height - romTable[A_Index,15] - HyperPause_SubMenu_FontSize - HyperPause_ChangeDisc_TextDisttoImage)//2
        OptionsDiscChange = x%posDiscChangeTextX% y%posDiscChangeTextY% Center c%color% r4 s%HyperPause_SubMenu_FontSize% bold
        Gdip_Alt_TextToGraphics(HP_G27, romTable[A_Index,5], OptionsDiscChange, HyperPause_SubMenu_Font, romTable[A_Index,14], romTable[A_Index,15])
        ;HyperPause_DiscChange_Art%A_Index%X := HPimageXcurrent
        If ( A_index <= HPDiscChangepaddingSpotsNeeded )
            HPDiscChangeimageXcurrent:= HPDiscChangeimageXcurrent+ romTable[A_Index,14]+HPDiscChangeimageSpacing
    }
    If(VSubMenuItem=1){
        EnableDiscChangeUpdate = 1
    }
Return    
 

DiscChangeUpdate:
    If !(SelectedMenuOption="ChangeDisc"){
        pGraphUpd(HP_G30,HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
        Gdip_GraphicsClear(HP_G30)
        Alt_UpdateLayeredWindow(HP_hwnd30, HP_hdc30, baseScreenWidth-HyperPause_SubMenu_Width, baseScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
        SetTimer, DiscChangeUpdate, Off 
        Return
    }
    If(EnableDiscChangeUpdate = 1){
        If((VSubMenuItem=1)and(SelectedMenuOption="ChangeDisc")){
            If (HyperPause_ChangeDisc_SelectedEffect = "grow") {
                Sleep, 5
                If !HyperPause_Growing
                    SetTimer, DiscChangeGrowAnimation, -1
            } Else If (HyperPause_ChangeDisc_SelectedEffect = "rotate" && romTable[HSubMenuItem, 16]) {
                Gdip_GraphicsClear(HP_G30)
                pGraphUpd(HP_G30,HyperPause_DiscChange_RW%HSubMenuItem%, HyperPause_DiscChange_RH%HSubMenuItem%)
                discAngle := (discAngle > 360) ? 2 : discAngle+2
                Gdip_ResetWorldTransform(HP_G30)
                Gdip_TranslateWorldTransform(HP_G30, HyperPause_DiscChange_RW%HSubMenuItem%//2, HyperPause_DiscChange_RH%HSubMenuItem%//2)
                Gdip_RotateWorldTransform(HP_G30, discAngle)
                Gdip_TranslateWorldTransform(HP_G30, -HyperPause_DiscChange_RW%HSubMenuItem%//2, -HyperPause_DiscChange_RH%HSubMenuItem%//2)
                Gdip_TranslateWorldTransform(HP_G30, xTranslation, yTranslation)
                Gdip_RotateWorldTransform(HP_G30, screenRotationAngle)
                Gdip_Alt_DrawImage(HP_G30, romTable[HSubMenuItem, 17], (HyperPause_DiscChange_RW%HSubMenuItem%-romTable[HSubMenuItem, 14]), (HyperPause_DiscChange_RH%HSubMenuItem%-romTable[HSubMenuItem, 15]), romTable[HSubMenuItem, 14], romTable[HSubMenuItem, 15])
                Alt_UpdateLayeredWindow(HP_hwnd30, HP_hdc30, baseScreenWidth-HyperPause_SubMenu_Width+romTable[HSubMenuItem, 10]-1, baseScreenHeight-HyperPause_SubMenu_Height+romTable[HSubMenuItem, 11]-1, HyperPause_DiscChange_RW%HSubMenuItem%, HyperPause_DiscChange_RH%HSubMenuItem%)
            } Else If (HyperPause_ChangeDisc_SelectedEffect = "rotate" && !romTable[HSubMenuItem, 16]) {
                Gdip_GraphicsClear(HP_G30)
                pGraphUpd(HP_G30,HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
                Gdip_ResetWorldTransform(HP_G30)
                Gdip_TranslateWorldTransform(HP_G30, xTranslation, yTranslation)
                Gdip_RotateWorldTransform(HP_G30, screenRotationAngle)
                Gdip_Alt_DrawImage(HP_G30, romTable[HSubMenuItem, 18], romTable[HSubMenuItem, 10],  romTable[HSubMenuItem, 11], romTable[HSubMenuItem,14], romTable[HSubMenuItem,15], 0, 0, round(romTable[HSubMenuItem,14]/HyperPause_ChangeDisc_ImageAdjust[HSubMenuItem]), round(romTable[HSubMenuItem,15]/HyperPause_ChangeDisc_ImageAdjust[HSubMenuItem]))
                Alt_UpdateLayeredWindow(HP_hwnd30, HP_hdc30, baseScreenWidth-HyperPause_SubMenu_Width, baseScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
            } 
        }
    }
Return

DiscChangeGrowAnimation:
    If(EnableDiscChangeUpdate = 1){
        HyperPause_Growing:=1
        While b <= HyperPause_ChangingDisc_GrowSize {
            Gdip_GraphicsClear(HP_G30)
            pGraphUpd(HP_G30,HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
            Gdip_Alt_DrawImage(HP_G30, (If romTable[HSubMenuItem, 16] ? (romTable[HSubMenuItem, 17]):(romTable[HSubMenuItem, 18])), romTable[HSubMenuItem,10]-(b//2), romTable[ HSubMenuItem,11]-(b//2), romTable[HSubMenuItem,14]+b, romTable[HSubMenuItem,15]+b, 0, 0, romTable[HSubMenuItem,14]//HyperPause_ChangeDisc_ImageAdjust[HSubMenuItem], romTable[HSubMenuItem,15]//HyperPause_ChangeDisc_ImageAdjust[HSubMenuItem])
            Alt_UpdateLayeredWindow(HP_hwnd30, HP_hdc30, baseScreenWidth-HyperPause_SubMenu_Width, baseScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
            b+=2
        }
        b := 0
    }
Return

;-------Settings Sub Menu-------
Settings:
    locklaunchValues := "false|true|password|directonly"
    StringSplit, locklaunchValue, locklaunchValues, |
    ButtonToggleONBitmap := Gdip_CreateBitmapFromFile(ToggleONImage)
    ButtonToggleONBitmapW := Gdip_GetImageWidth(ButtonToggleONBitmap), OptionScale(ButtonToggleONBitmapW, HyperPause_XScale)
    ButtonToggleONBitmapH := Gdip_GetImageHeight(ButtonToggleONBitmap), OptionScale(ButtonToggleONBitmapH, HyperPause_XScale)
    ButtonToggleOFFBitmap := Gdip_CreateBitmapFromFile(ToggleOFFImage)
    color7zCleanupTitle := HyperPause_SubMenu_SoundDisabledColor
    colorLockLaunchTitle := HyperPause_SubMenu_SoundDisabledColor 
    ; LockLaunch toggle
    Loop, 4
        {
        if (currentLockLaunch=locklaunchValue%a_index%){
            currentLockLaunchLabel := locklaunchValue%a_index%
            currentLockLaunchIndex := A_Index
        }
    }
    If(VSubMenuItem=1){
        colorLockLaunchTitle := HyperPause_SubMenu_SoundSelectedColor
        HelpText1 := "False = game lanches normaly."
        HelpText2 := "True = Locked from all forms of launching. Use this for games that do not work correctly."
        HelpText3 := "Password = You need to provide the Launch Password to be able to play."
        HelpText4 := "directonly = Cannot launch to play, but can launch into HyperPause direct mode to view media."
        SubMenuHelpText("Select if you want to lock this game from launch. " . HelpText%currentLockLaunchIndex%)
    }
    posLockLaunchTitleX := HyperPause_Settings_HMargin
    posLockLaunchTitleY := HyperPause_Settings_VMargin
    textOptionsLockLaunch = x%posLockLaunchTitleX% y%posLockLaunchTitleY% Left c%colorLockLaunchTitle% r4 s%HyperPause_Settings_OptionFontSize% bold
    Gdip_Alt_TextToGraphics(HP_G27, "Lock Launch:", textOptionsLockLaunch, HyperPause_SubMenu_Font, 0, 0)
    WidthofLockLaunchText := MeasureText("Lock Launch:", "Left r4 s" . HyperPause_Settings_OptionFontSize . " bold",HyperPause_SubMenu_Font)+HyperPause_SubMenu_AdditionalTextMarginContour
    posLockLaunchTitleX := posLockLaunchTitleX+WidthofLockLaunchText+HyperPause_Settings_Margin
    textLabelOptions = x%posLockLaunchTitleX% y%posLockLaunchTitleY% Left c%colorLockLaunchTitle% r4 s%HyperPause_Settings_OptionFontSize% bold
    Gdip_Alt_TextToGraphics(HP_G27, currentLockLaunchLabel, textLabelOptions, HyperPause_SubMenu_Font, 0, 0)
    ; 7zCleanup toggle
    if ((found7z="true") and (7zEnabled = "true"))  {
        if (current7zDelTemp="true")
        {
            current7zDelTempLabel = ON
            CurrentButton7zCleanupBitmap := ButtonToggleONBitmap
        } else {
            current7zDelTempLabel = OFF
            CurrentButton7zCleanupBitmap := ButtonToggleOFFBitmap
        }
        If(VSubMenuItem=2){
            color7zCleanupTitle := HyperPause_SubMenu_SoundSelectedColor
            SubMenuHelpText("Select if you want to disable the deletion of the 7z extracted file for this game if you are going to play it consecutively.")
        }
        pos7zCleanupTitleX := HyperPause_Settings_HMargin
        pos7zCleanupTitleY := HyperPause_Settings_VMargin + HyperPause_Settings_VdistBetwLabels
        textOptions7zCleanup = x%pos7zCleanupTitleX% y%pos7zCleanupTitleY% Left c%color7zCleanupTitle% r4 s%HyperPause_Settings_OptionFontSize% bold
        Gdip_Alt_TextToGraphics(HP_G27, "7z Cleanup:", textOptions7zCleanup, HyperPause_SubMenu_Font, 0, 0)
        Widthof7zCleanupText := MeasureText("7z Cleanup:", "Left r4 s" . HyperPause_Settings_OptionFontSize . " bold",HyperPause_SubMenu_Font)+HyperPause_SubMenu_AdditionalTextMarginContour
        Gdip_Alt_DrawImage(HP_G27, CurrentButton7zCleanupBitmap, pos7zCleanupTitleX+Widthof7zCleanupText+HyperPause_Settings_Margin, pos7zCleanupTitleY, ButtonToggleONBitmapW, ButtonToggleONBitmapH)  
        pos7zCleanupTitleX := round(pos7zCleanupTitleX+Widthof7zCleanupText+HyperPause_Settings_Margin+ButtonToggleONBitmapW+HyperPause_Settings_Margin)
        textLabelOptions = x%pos7zCleanupTitleX% y%pos7zCleanupTitleY% Left c%color7zCleanupTitle% r4 s%HyperPause_Settings_OptionFontSize% bold
        Gdip_Alt_TextToGraphics(HP_G27, current7zDelTempLabel, textLabelOptions, HyperPause_SubMenu_Font, 0, 0)
    }
return

;-------Sound Control Sub Menu-------
Sound:
    SoundBarHeight := round(HyperPause_SoundBar_SingleBarHeight + (100/HyperPause_SoundBar_vol_Step)*HyperPause_SoundBar_HeightDifferenceBetweenBars)
    SoundBarWidth := round((100/HyperPause_SoundBar_vol_Step)*HyperPause_SoundBar_SingleBarWidth+((100/HyperPause_SoundBar_vol_Step)-1)*HyperPause_SoundBar_SingleBarSpacing) 
    SoundBitmap := Gdip_CreateBitmapFromFile(SoundImage)
    SoundBitmapW := Gdip_GetImageWidth(SoundBitmap), SoundBitmapH := Gdip_GetImageHeight(SoundBitmap)
    OptionScale(SoundBitmapW,HyperPause_XScale)
    OptionScale(SoundBitmapH,HyperPause_XScale)
    MuteBitmap := Gdip_CreateBitmapFromFile(MuteImage)
    ButtonToggleONBitmap := Gdip_CreateBitmapFromFile(ToggleONImage)
    ButtonToggleONBitmapW := Gdip_GetImageWidth(ButtonToggleONBitmap), ButtonToggleONBitmapH := Gdip_GetImageHeight(ButtonToggleONBitmap)
    OptionScale(ButtonToggleONBitmapW,HyperPause_XScale)
    OptionScale(ButtonToggleONBitmapH,HyperPause_XScale)
    ButtonToggleOFFBitmap := Gdip_CreateBitmapFromFile(ToggleOFFImage)
    colorMuteTitle := HyperPause_SubMenu_SoundDisabledColor 
    colorInGameMusicTitle := HyperPause_SubMenu_SoundDisabledColor
    colorShuffleTitle := HyperPause_SubMenu_SoundDisabledColor
    colorSoundBarTitle := HyperPause_SubMenu_SoundDisabledColor 
    If(VSubMenuItem=1){
        colorSoundBarTitle := HyperPause_SubMenu_SoundSelectedColor
        If (HyperPause_VolumeMaster > 0)
            SoundPlay %HyperPause_MenuSoundPath%hpsubmenu.wav
    }
    If(VSubMenuItem=2)
        SoundPlay %HyperPause_MenuSoundPath%hpsubmenu.wav
    If(VSubMenuItem=3){
        SoundPlay %HyperPause_MenuSoundPath%hpsubmenu.wav
        CurrentMusicButton := HSubmenuitemSoundVSubmenuitem3 - currentPlayindex + 3 
        If  CurrentMusicButton < 1 
            currentPlayindex := currentPlayindex-4
        If  CurrentMusicButton > 4
            currentPlayindex := currentPlayindex+4
        CurrentMusicButton := HSubmenuitemSoundVSubmenuitem3 - currentPlayindex + 3
        CurrentMusicButton := Round(CurrentMusicButton)
    }    
    getMute(CurrentMuteState)
    If(CurrentMuteState=1){
        SoundMuteLabel = ON
        CurrentButtonMuteBitmap := ButtonToggleONBitmap
        CurrentSoundBitmap := MuteBitmap
    } Else {
        SoundMuteLabel = OFF        
        CurrentButtonMuteBitmap := ButtonToggleOFFBitmap
        CurrentSoundBitmap := SoundBitmap
    } 
    If HyperPause_VolumeMaster=0
        CurrentSoundBitmap := MuteBitmap
    posSoundBarTextX := round((HyperPause_SubMenu_Width-SoundBarWidth)/2-SoundBitmapW-HyperPause_SubMenu_SoundSpaceBetweenSoundBarandSoundBitmap)
    posSoundBarTextY := round((HyperPause_SubMenu_Height-SoundBarHeight-HyperPause_SubMenu_SoundMuteButtonVDist-HyperPause_SubMenu_SoundMuteButtonFontSize)/2-HyperPause_SubMenu_SoundMuteButtonFontSize)
	If(HyperPause_CurrentPlaylist<>""){
        posSoundBarTextY := round((HyperPause_SubMenu_Height-SoundBarHeight-HyperPause_SubMenu_SoundMuteButtonVDist-HyperPause_SubMenu_SoundMuteButtonFontSize-HyperPause_SubMenu_MusicPlayerVDist-HyperPause_SubMenu_SizeofMusicPlayerButtons)/2-HyperPause_SubMenu_SoundMuteButtonFontSize)
        posMusicButtonsY := posSoundBarTextY+SoundBarHeight+HyperPause_SubMenu_SoundMuteButtonVDist+HyperPause_SubMenu_SoundMuteButtonFontSize+HyperPause_SubMenu_MusicPlayerVDist 
        Loop, 4
            {
            posMusicButton%a_index%X := round((HyperPause_SubMenu_Width-(4*HyperPause_SubMenu_SizeofMusicPlayerButtons+3*HyperPause_SubMenu_SpaceBetweenMusicPlayerButtons))/2+(a_index-1)*(HyperPause_SubMenu_SizeofMusicPlayerButtons + HyperPause_SubMenu_SpaceBetweenMusicPlayerButtons))
            try CurrentMusicPlayStatus := wmpMusic.playState
            If (a_index = 3) and (CurrentMusicPlayStatus = 3)
                HyperPauseMusicBitmap%a_index% := Gdip_CreateBitmapFromFile(HyperPauseMusicImage5)
            Else
                HyperPauseMusicBitmap%a_index% := Gdip_CreateBitmapFromFile(HyperPauseMusicImage%a_index%)
            Gdip_Alt_DrawImage(HP_G27,HyperPauseMusicBitmap%a_index%,posMusicButton%a_index%X,posMusicButtonsY,HyperPause_SubMenu_SizeofMusicPlayerButtons,HyperPause_SubMenu_SizeofMusicPlayerButtons)
            If((VsubMenuItem = 3) and (CurrentMusicButton = a_index)){
                pGraphUpd(HP_G30,HyperPause_SubMenu_SizeofMusicPlayerButtons+HyperPause_Sound_MarginBetweenButtons, HyperPause_SubMenu_SizeofMusicPlayerButtons+HyperPause_Sound_MarginBetweenButtons)
                If (PreviousCurrentMusicButton<>CurrentMusicButton){ 
                    GrowSize := 1
                    While GrowSize <= HyperPause_Sound_Buttons_Grow_Size {
                        Gdip_GraphicsClear(HP_G30)
                        Gdip_Alt_DrawImage(HP_G30,HyperPauseMusicBitmap%CurrentMusicButton%,HyperPause_Sound_Buttons_Grow_Size-GrowSize,HyperPause_Sound_Buttons_Grow_Size-GrowSize,HyperPause_SubMenu_SizeofMusicPlayerButtons+2*GrowSize,HyperPause_SubMenu_SizeofMusicPlayerButtons+2*GrowSize)
                        Alt_UpdateLayeredWindow(HP_hwnd30, HP_hdc30, round(baseScreenWidth-HyperPause_SubMenu_Width+posMusicButton%CurrentMusicButton%X-HyperPause_Sound_Buttons_Grow_Size), round(baseScreenHeight-HyperPause_SubMenu_Height+posMusicButtonsY-HyperPause_Sound_Buttons_Grow_Size), HyperPause_SubMenu_SizeofMusicPlayerButtons+2*HyperPause_Sound_Buttons_Grow_Size, HyperPause_SubMenu_SizeofMusicPlayerButtons+2*HyperPause_Sound_Buttons_Grow_Size)
                        GrowSize+= HyperPause_SoundButtonGrowingEffectVelocity
                    }
                    Gdip_GraphicsClear(HP_G30)
                    If(GrowSize<>15){
                        Gdip_Alt_DrawImage(HP_G30,HyperPauseMusicBitmap%CurrentMusicButton%,0,0,HyperPause_SubMenu_SizeofMusicPlayerButtons+2*HyperPause_Sound_Buttons_Grow_Size,HyperPause_SubMenu_SizeofMusicPlayerButtons+2*HyperPause_Sound_Buttons_Grow_Size)
                        Alt_UpdateLayeredWindow(HP_hwnd30, HP_hdc30, round(baseScreenWidth-HyperPause_SubMenu_Width+posMusicButton%CurrentMusicButton%X-HyperPause_Sound_Buttons_Grow_Size), round(baseScreenHeight-HyperPause_SubMenu_Height+posMusicButtonsY-HyperPause_Sound_Buttons_Grow_Size), HyperPause_SubMenu_SizeofMusicPlayerButtons+2*HyperPause_Sound_Buttons_Grow_Size, HyperPause_SubMenu_SizeofMusicPlayerButtons+2*HyperPause_Sound_Buttons_Grow_Size)
                    }
                } Else {
                    Gdip_Alt_DrawImage(HP_G30,HyperPauseMusicBitmap%CurrentMusicButton%,0,0,HyperPause_SubMenu_SizeofMusicPlayerButtons+2*HyperPause_Sound_Buttons_Grow_Size,HyperPause_SubMenu_SizeofMusicPlayerButtons+2*HyperPause_Sound_Buttons_Grow_Size)
                    Alt_UpdateLayeredWindow(HP_hwnd30, HP_hdc30, round(baseScreenWidth-HyperPause_SubMenu_Width+posMusicButton%CurrentMusicButton%X-HyperPause_Sound_Buttons_Grow_Size), round(baseScreenHeight-HyperPause_SubMenu_Height+posMusicButtonsY-HyperPause_Sound_Buttons_Grow_Size), HyperPause_SubMenu_SizeofMusicPlayerButtons+2*HyperPause_Sound_Buttons_Grow_Size, HyperPause_SubMenu_SizeofMusicPlayerButtons+2*HyperPause_Sound_Buttons_Grow_Size)
                }
                PreviousCurrentMusicButton := CurrentMusicButton   
            }
        }
    }
    Gdip_Alt_DrawImage(HP_G27, CurrentSoundBitmap, posSoundBarTextX, round(posSoundBarTextY+HyperPause_SubMenu_SoundMuteButtonFontSize+SoundBarHeight-(SoundBitmapH+HyperPause_SoundBar_SingleBarHeight)/2), SoundBitmapW, SoundBitmapH)
    OptionsSoundBar = x%posSoundBarTextX% y%posSoundBarTextY% Left c%colorSoundBarTitle% r4 s%HyperPause_SubMenu_SoundMuteButtonFontSize% bold
    Gdip_Alt_TextToGraphics(HP_G27, "Master Sound Control:", OptionsSoundBar, HyperPause_SubMenu_Font, 0, 0)
    ; Mute toggle
    If(VSubMenuItem=2) and (HSubmenuitemSoundVSubmenuitem2=1)
        colorMuteTitle := HyperPause_SubMenu_SoundSelectedColor
    posMuteX := posSoundBarTextX + HyperPause_Sound_MarginBetweenButtons
    If(HyperPause_CurrentPlaylist<>"")
        posMuteX := posSoundBarTextX - HyperPause_Sound_MarginBetweenButtons
    posMuteY := posSoundBarTextY+HyperPause_SubMenu_SoundMuteButtonFontSize + SoundBarHeight+HyperPause_SubMenu_SoundMuteButtonVDist
    OptionsSoundMute = x%posMuteX% y%posMuteY% Left c%colorMuteTitle% r4 s%HyperPause_SubMenu_SoundMuteButtonFontSize% bold
    Gdip_Alt_TextToGraphics(HP_G27, "Mute Status:", OptionsSoundMute, HyperPause_SubMenu_Font, 0, 0)
    WidthofMuteText := MeasureText("Mute Status:", "Left r4 s" . HyperPause_SubMenu_SoundMuteButtonFontSize . " bold",HyperPause_SubMenu_Font)+HyperPause_SubMenu_AdditionalTextMarginContour
    Gdip_Alt_DrawImage(HP_G27, CurrentButtonMuteBitmap, posMuteX+WidthofMuteText, posMuteY, ButtonToggleONBitmapW, ButtonToggleONBitmapH)  
    posMuteX := round(posMuteX+WidthofMuteText+ButtonToggleONBitmapW+HyperPause_Sound_Margin)
    OptionsSoundButton = x%posMuteX% y%posMuteY% Left c%colorMuteTitle% r4 s%HyperPause_SubMenu_SoundMuteButtonFontSize% bold
    Gdip_Alt_TextToGraphics(HP_G27, SoundMuteLabel, OptionsSoundButton, HyperPause_SubMenu_Font, 0, 0)
    ; In Game Music Toggle
    If(HyperPause_CurrentPlaylist<>""){
        If(VSubMenuItem=2) and (HSubmenuitemSoundVSubmenuitem2=2)
            colorInGameMusicTitle := HyperPause_SubMenu_SoundSelectedColor
        If(HyperPause_KeepPlayingAfterExitingHyperPause="true"){
            InGameMusic = ON
            CurrentButtonInGameMusic := ButtonToggleONBitmap
        } Else {
            InGameMusic = OFF  
            CurrentButtonInGameMusic := ButtonToggleOFFBitmap
        }
        posInGameMusicX := posMuteX + HyperPause_Sound_InGameMusic_Margin
        OptionsInGameMusic = x%posInGameMusicX% y%posMuteY% Left c%colorInGameMusicTitle% r4 s%HyperPause_SubMenu_SoundMuteButtonFontSize% bold
        Gdip_Alt_TextToGraphics(HP_G27, "In Game Music:", OptionsInGameMusic, HyperPause_SubMenu_Font, 0, 0)
        WidthofInGameMusicText := MeasureText("In Game Music:", "Left r4 s" . HyperPause_SubMenu_SoundMuteButtonFontSize . " bold",HyperPause_SubMenu_Font)+       HyperPause_SubMenu_AdditionalTextMarginContour
        Gdip_Alt_DrawImage(HP_G27, CurrentButtonInGameMusic, posInGameMusicX+WidthofInGameMusicText, posMuteY, ButtonToggleONBitmapW, ButtonToggleONBitmapH)       
        posInGameMusicX := round(posInGameMusicX+WidthofInGameMusicText+ButtonToggleONBitmapW+HyperPause_Sound_Margin)
        OptionsInGameMusicButton = x%posInGameMusicX% y%posMuteY% Left c%colorInGameMusicTitle% r4 s%HyperPause_SubMenu_SoundMuteButtonFontSize% bold
        Gdip_Alt_TextToGraphics(HP_G27, InGameMusic, OptionsInGameMusicButton, HyperPause_SubMenu_Font, 0, 0)    

        ; Shuffle Toggle
        If(VSubMenuItem=2) and (HSubmenuitemSoundVSubmenuitem2=3)
            colorShuffleTitle := HyperPause_SubMenu_SoundSelectedColor
        If(HyperPause_EnableShuffle="true"){
            ShuffleText = ON
            CurrentButtonShuffle := ButtonToggleONBitmap
        } Else {
            ShuffleText = OFF  
            CurrentButtonShuffle := ButtonToggleOFFBitmap
        }
        posShuffleX := posInGameMusicX + HyperPause_Sound_InGameMusic_Margin
        OptionsShuffle = x%posShuffleX% y%posMuteY% Left c%colorShuffleTitle% r4 s%HyperPause_SubMenu_SoundMuteButtonFontSize% bold
        Gdip_Alt_TextToGraphics(HP_G27, "Shuffle:", OptionsShuffle, HyperPause_SubMenu_Font, 0, 0)
        WidthofShuffleText := MeasureText("Shuffle:", "Left r4 s" . HyperPause_SubMenu_SoundMuteButtonFontSize . " bold",HyperPause_SubMenu_Font)+       HyperPause_SubMenu_AdditionalTextMarginContour
        Gdip_Alt_DrawImage(HP_G27, CurrentButtonShuffle, posShuffleX+WidthofShuffleText, posMuteY, ButtonToggleONBitmapW, ButtonToggleONBitmapH)       
        posShuffleX := round(posShuffleX+WidthofShuffleText+ButtonToggleONBitmapW+HyperPause_Sound_Margin)
        OptionsShuffleButton = x%posShuffleX% y%posMuteY% Left c%colorShuffleTitle% r4 s%HyperPause_SubMenu_SoundMuteButtonFontSize% bold
        Gdip_Alt_TextToGraphics(HP_G27, ShuffleText, OptionsShuffleButton, HyperPause_SubMenu_Font, 0, 0)        
    }
    Loop, % (100/HyperPause_SoundBar_vol_Step) { ;empty Sound Bar Progress
        DrawSoundEmptyProgress(HP_G27, round((HyperPause_SubMenu_Width-SoundBarWidth)/2+(A_Index - 1) * (HyperPause_SoundBar_SingleBarWidth+HyperPause_SoundBar_SingleBarSpacing)), posSoundBarTextY+HyperPause_SubMenu_SoundMuteButtonFontSize+SoundBarHeight, HyperPause_SoundBar_SingleBarWidth, HyperPause_SoundBar_SingleBarHeight+HyperPause_SoundBar_HeightDifferenceBetweenBars*A_Index)
    }
    Loop, % (HyperPause_VolumeMaster // HyperPause_SoundBar_vol_Step){ ;full Sound Bar Progress
        SetFormat Integer, Hex
        SoundBarAlpha:= round((A_Index/HyperPause_VolumeMaster)*(255-150)+150)
        SetFormat Integer, D
        SoundBarBodyColor = 14CB14 ;CB1414 - RED  
        SoundBarBottomEffectColor = 003E00 ; 3E0000 -RED
        PrimaryColorSoundBar := SoundBarAlpha SoundBarBodyColor
        SecondaryColorSoundBar := SoundBarAlpha SoundBarBottomEffectColor 
        DrawSoundFullProgress(HP_G27, round((HyperPause_SubMenu_Width-SoundBarWidth)/2+(A_Index - 1) * (HyperPause_SoundBar_SingleBarWidth+HyperPause_SoundBar_SingleBarSpacing)), posSoundBarTextY+HyperPause_SubMenu_SoundMuteButtonFontSize+SoundBarHeight, HyperPause_SoundBar_SingleBarWidth, HyperPause_SoundBar_SingleBarHeight+HyperPause_SoundBar_HeightDifferenceBetweenBars*A_Index,PrimaryColorSoundBar,SecondaryColorSoundBar)
    }
    posVolX := round((HyperPause_SubMenu_Width-SoundBarWidth)/2+SoundBarWidth+HyperPause_SubMenu_SoundDisttoSoundLevel) 
    posVolY := posSoundBarTextY+HyperPause_SubMenu_SoundMuteButtonFontSize
    OptionsSound = x%posVolX% y%posVolY% Center c%colorSoundBarTitle% r4 s%HyperPause_SubMenu_SmallFontSize% bold
    soundtext := round(HyperPause_VolumeMaster) "%"
    If(HyperPause_VolumeMaster=0){
    soundtext = Mute    
    }
    Gdip_Alt_TextToGraphics(HP_G27, soundtext, OptionsSound, "Arial")
    If (HyperPause_CurrentPlaylist<>"")
        settimer, UpdateMusicPlayingInfo, 100, Period
    Else 
        gosub, UpdateMusicPlayingInfo
Return


;-------Videos Sub Menu-------
Videos:
    try CurrentMusicPlayStatus := wmpMusic.playState
    If (CurrentMusicPlayStatus = 3) {
        try wmpMusic.controls.pause  
        MusicPausedonVideosMenu := true
    }        
    TextImagesAndPDFMenu("Videos")
Return


;-------High Score Sub Menu-------
HighScore:
    posHighScoreX = 0
    line=0
    StringSplit, FirstLineContents, HighScoreText, ¡
    StringReplace, FirstLineContents1,FirstLineContents1,|,|,UseErrorLevel
    numberofcolumns := ErrorLevel+1
    Loop, %numberofcolumns%
        {
        If(FullScreenView <> 1){
            If (a_index=1)
                PosX := round((HyperPause_SubMenu_Width)/(numberofcolumns*2))
            Else
                PosX := PosX + 2*round((HyperPause_SubMenu_Width)/(numberofcolumns*2))
            posHighScoreX%a_index% := PosX
        } Else {
            If (a_index=1)
                PosX := round((HyperPause_SubMenu_HighScoreFullScreenWidth)/(numberofcolumns*2))
            Else
                PosX := PosX + 2*round((HyperPause_SubMenu_HighScoreFullScreenWidth)/(numberofcolumns*2))
            posHighScoreX%a_index% := PosX
        }
    }
    If(FullScreenView <> 1){
        posHighScoreY1 := HyperPause_SubMenu_HighScore_SuperiorMargin
        posHighScoreY2 := HyperPause_SubMenu_HighScore_SuperiorMargin+2*HyperPause_SubMenu_HighScoreTitleFontSize
    } Else {
        posHighScoreY1 := 2*HyperPause_SubMenu_FullScreenMargin
        posHighScoreY2 := 2*HyperPause_SubMenu_FullScreenMargin+2*HyperPause_SubMenu_HighScoreTitleFontSize
        Gdip_Alt_FillRoundedRectangle(HP_G29, HyperPause_SubMenu_FullScreenTextBrushV, 0, 0, HyperPause_SubMenu_HighScoreFullScreenWidth, baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin, HyperPause_SubMenu_FullScreenRadiusofRoundedCorners)
    }
    Loop, parse, HighScoreText,¡,
        {
        line++
        If(line=1){
            color := HyperPause_SubMenu_HighScoreTitleFontColor
            Loop, parse, a_loopfield,|,
                {
                column++
                posHighScoreX = % posHighScoreX%column%
                OptionsHighScore1 = x%posHighScoreX% y%posHighScoreY1% Center c%color% r4 s%HyperPause_SubMenu_HighScoreTitleFontSize% bold
                If FullScreenView<>1
                    Gdip_Alt_TextToGraphics(HP_G27, a_loopfield, OptionsHighScore1, HyperPause_SubMenu_Font)
                Else
                    Gdip_Alt_TextToGraphics(HP_G29, a_loopfield, OptionsHighScore1, HyperPause_SubMenu_Font)
            }
        } Else If (line >= VSubMenuItem+1){
            If(line=VSubMenuItem+1){
                color :=HyperPause_SubMenu_HighScoreSelectedFontColor    
            } Else {
                color := HyperPause_SubMenu_HighScoreFontColor       
            }
            IfInString, a_loopfield, %HyperPause_SubMenu_HighlightPlayerName%
                {
                color := HyperPause_SubMenu_HighlightPlayerFontColor                 
            }
            Loop, parse, a_loopfield,|,
                {
                column++
                HighScoreitem := A_LoopField
                If(column=1){
                    If(A_LoopField=1)
                        HighScoreitem := HighScoreitem "st"
                    If(A_LoopField=2)
                        HighScoreitem := HighScoreitem "nd"
                    If(A_LoopField=3)
                        HighScoreitem := HighScoreitem "rd"
                    If(A_LoopField>3)
                        HighScoreitem := HighScoreitem "th"                        
                }
                posHighScoreX = % posHighScoreX%column%
                OptionsHighScore2 = x%posHighScoreX% y%posHighScoreY2% Center c%color% r4 s%HyperPause_SubMenu_HighScoreFontSize% bold
                If FullScreenView<>1
                    Gdip_Alt_TextToGraphics(HP_G27, HighScoreitem, OptionsHighScore2, HyperPause_SubMenu_Font)
                Else
                    Gdip_Alt_TextToGraphics(HP_G29, HighScoreitem, OptionsHighScore2, HyperPause_SubMenu_Font)
                }
        posHighScoreY2 := round(posHighScoreY2+1.5*HyperPause_SubMenu_HighScoreFontSize)
        }
    column = 0
    }
    If(FullScreenView=1){      
        HyperPause_SubMenu_FullScreenHelpBoxHeight := 4*HyperPause_SubMenu_FullScreenFontSize
        HyperPause_SubMenu_FullScreenHelpBoxWidth := MeasureText("Press Up or Down to move between High Scores", "Left r4 s" . HyperPause_SubMenu_FullScreenFontSize . " bold",HyperPause_SubMenu_Font)+HyperPause_SubMenu_AdditionalTextMarginContour
        Gdip_Alt_FillRoundedRectangle(HP_G29, HyperPause_SubMenu_FullScreenBrushV, round((HyperPause_SubMenu_HighScoreFullScreenWidth-HyperPause_SubMenu_FullScreenHelpBoxWidth)/2), baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin-5*HyperPause_SubMenu_FullScreenFontSize, HyperPause_SubMenu_FullScreenHelpBoxWidth,HyperPause_SubMenu_FullScreenHelpBoxHeight,HyperPause_SubMenu_FullScreenRadiusofRoundedCorners)
        posFullScreenTextX := round(HyperPause_SubMenu_HighScoreFullScreenWidth/2)
        posFullScreenTextY := round(baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin-4*HyperPause_SubMenu_FullScreenFontSize-HyperPause_SubMenu_FullScreenFontSize/2)
        OptionsFullScreenText = x%posFullScreenTextX% y%posFullScreenTextY% Center c%HyperPause_SubMenu_FullScreenFontColor% r4 s%HyperPause_SubMenu_FullScreenFontSize% bold
        TotaltxtPages := % TotalFullScreenV2SubMenuItems%SubMenuName%%CurrentLabelNumber%
        CurrentHelpText = Press Select Key to Exit Full Screen`nPress Up or Down to move between High Scores
        Gdip_Alt_TextToGraphics(HP_G29, CurrentHelpText, OptionsFullScreenText, HyperPause_SubMenu_Font, 0, 0)
        Alt_UpdateLayeredWindow(HP_hwnd29, HP_hdc29,round((baseScreenWidth-HyperPause_SubMenu_HighScoreFullScreenWidth)/2), HyperPause_SubMenu_FullScreenMargin, HyperPause_SubMenu_HighScoreFullScreenWidth, baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin)
    } Else If ((VSubMenuItem<>0) and (HSubMenuItem=1)){
            CurrentHelpText = Press Select Key to go FullScreen
            SubMenuHelpText(CurrentHelpText)
    }
Return



;-------Artwork Sub Menu-------
Artwork:
    TextImagesAndPDFMenu("Artwork")
Return


;-------Moves List Sub Menu-------
MovesList:
    current_item := VSubMenuItem
    If(VSubMenuItem = 0){
        current_item := 1
        V2SubMenuItem = 1
    }
    color := HyperPause_MainMenu_LabelDisabledColor
    Optionbrush := HyperPause_SubMenu_DisabledBrushV
    posMovesListLabelY := HyperPause_MovesList_VMargin
    MaxMovesListLabelWidth = %HyperPause_SubMenu_MinimumTextBoxWidth%
    Loop, % HPMediaObj["MovesList"].TotalLabels
        {
        MovesListLabelWidth := MeasureText(MovesListLabel%A_index%, "Left r4 s" . HyperPause_SubMenu_LabelFontSize . " bold",HyperPause_SubMenu_LabelFont)+HyperPause_SubMenu_AdditionalTextMarginContour
        If(MovesListLabelWidth>MaxMovesListLabelWidth){
        MaxMovesListLabelWidth := MovesListLabelWidth
        }    
    }   
    posMovesListLabelX := round(HyperPause_MovesList_HMargin+MaxMovesListLabelWidth/2)
    Loop, % HPMediaObj["MovesList"].TotalLabels
        {
        If( A_index >= VSubMenuItem){   
            If((HSubMenuItem=1)and(A_index=VSubMenuItem)){
                V2SubMenuItem = 1
                color := HyperPause_MainMenu_LabelSelectedColor
                Optionbrush := HyperPause_SubMenu_SelectedBrushV
            }
            OptionsMovesListLabel = x%posMovesListLabelX% y%posMovesListLabelY% Center c%color% r4 s%HyperPause_SubMenu_LabelFontSize% bold
            Gdip_Alt_FillRoundedRectangle(HP_G27, Optionbrush, round(posMovesListLabelX-MaxMovesListLabelWidth/2), posMovesListLabelY-HyperPause_SubMenu_AdditionalTextMarginContour+HyperPause_VTextDisplacementAdjust, MaxMovesListLabelWidth, HyperPause_SubMenu_FontSize+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_RadiusofRoundedCorners)
            Gdip_Alt_TextToGraphics(HP_G27, MovesListLabel%A_index%, OptionsMovesListLabel, HyperPause_SubMenu_LabelFont, 0, 0)
            posMovesListLabelY := posMovesListLabelY+HyperPause_MovesList_VdistBetwLabels
            color := HyperPause_MainMenu_LabelDisabledColor
            Optionbrush := HyperPause_SubMenu_DisabledBrushV
        }
    }
    If(FullScreenView=1)
        TotalMovesListPages := % %SelectedMenuOption%TotalNumberofFullScreenPages%current_item%
    Else
        TotalMovesListPages := % %SelectedMenuOption%TotalNumberofPages%current_item%
    If (V2SubMenuItem > TotalMovesListPages)
            V2SubMenuItem := TotalMovesListPages
    If(FullScreenView=1){
        FirstLine := (V2SubMenuItem-1) * LinesperFullScreenPage%SelectedMenuOption% + 1
        LastLine := FirstLine + LinesperFullScreenPage%SelectedMenuOption% - 1
        Gdip_GraphicsClear(HP_G29)
        pGraphUpd(HP_G29,HyperPause_SubMenu_MovesListFullScreenWidth, baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin)
        Gdip_Alt_FillRoundedRectangle(HP_G29, HyperPause_SubMenu_FullScreenTextBrushV, 0, 0, HyperPause_SubMenu_MovesListFullScreenWidth, baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin, HyperPause_SubMenu_FullScreenRadiusofRoundedCorners)
    } Else {
        FirstLine := (V2SubMenuItem-1)*LinesperPage%SelectedMenuOption% + 1
        LastLine := FirstLine + LinesperPage%SelectedMenuOption% - 1
    } 
    MovesListLineCount=0
    validLineCount=0
    posMovesListY := HyperPause_MovesList_VMargin
    stringreplace, AuxMovesListItem%current_item%, MovesListItem%current_item%, `r`n,¿,all
    Loop, parse, AuxMovesListItem%current_item%, ¿
        {
        If A_LoopField contains %Lettersandnumbers%  
            {
            validLineCount++  
            If((validLineCount >= FirstLine) and (validLineCount <= LastLine)){
                MovesListLineCount++
                If FullScreenView<>1
                    posMovesListX := round(posMovesListLabelX+MaxMovesListLabelWidth/2+HyperPause_MovesList_HdistBetwLabelsandMovesList)
                Else
                    posMovesListX := HyperPause_MovesList_HFullScreenMovesMargin
                color2 := HyperPause_MainMenu_LabelDisabledColor
                If(HSubMenuItem=2){
                    color2 := HyperPause_MainMenu_LabelSelectedColor
                }
                MovesListCurrentLine  := A_LoopField
                StringCaseSense, On
                replace := {"_a":"#a","_b":"#b","_c":"#c","_d":"#d","_e":"#e","_f":"#f","_g":"#g","_h":"#h","_i":"#i","_j":"#j","_k":"#k","_l":"#l","_m":"#m","_n":"#n","_o":"#o","_p":"#p","_q":"#q","_r":"#r","_s":"#s","_t":"#t","_u":"#u","_v":"#v","_w":"#w","_x":"#x","_y":"#y","_z":"#z","^s":"@S","_?":"_;","^*":"^X"} ; Dealing with altered filenames due to the impossibility of using a lower and upper case file names on the same directory (_letter lower cases are transformed in #letter)  
                For what, with in replace
                    StringReplace, MovesListCurrentLine, MovesListCurrentLine, %what%, %with%, All
                
                Loop, parse, CommandDatImageFileList, `,
                    {
                    Stringreplace, MovesListCurrentLine, MovesListCurrentLine, %A_loopfield%, ¡%A_loopfield%¡ ,all
                }
                MovesListCurrentLine := "¡" . MovesListCurrentLine . "¡" 
                Stringreplace, MovesListCurrentLine, MovesListCurrentLine, ¡¡, ¡ ,all
                StringTrimLeft, MovesListCurrentLine, MovesListCurrentLine, 1
                StringTrimRight, MovesListCurrentLine, MovesListCurrentLine, 1
                Loop, parse, MovesListCurrentLine, ¡
                    {
                    OptionsMovesList = x%posMovesListX% y%posMovesListY% Left c%color2% r4 s%HyperPause_MovesList_SecondaryFontSize% bold
                    If(A_LoopField<>""){
                        If A_LoopField contains %CommandDatImageFileList%
                            {
                            currentbitmap := A_LoopField
                            Loop, parse, CommandDatImageFileList, `,
                                {
                                currentbitmapindex := A_index
                                If(A_LoopField=currentbitmap){
                                    CurrentBitmapW := Gdip_GetImageWidth(CommandDatBitmap%currentbitmapindex%), CurrentBitmapH := Gdip_GetImageHeight(CommandDatBitmap%currentbitmapindex%)
                                    ResizedBitmapH := HyperPause_MovesList_VImageSize
                                    ResizedBitmapW := round((HyperPause_MovesList_VImageSize/CurrentBitmapH)*CurrentBitmapW)
                                    If FullScreenView<>1
                                        Gdip_Alt_DrawImage(HP_G27,CommandDatBitmap%currentbitmapindex%,posMovesListX,round(posMovesListY-ResizedBitmapH/2+HyperPause_MovesList_SecondaryFontSize/2),ResizedBitmapW,ResizedBitmapH)
                                    Else
                                        Gdip_Alt_DrawImage(HP_G29,CommandDatBitmap%currentbitmapindex%,posMovesListX,round(posMovesListY-ResizedBitmapH/2+HyperPause_MovesList_SecondaryFontSize/2),ResizedBitmapW,ResizedBitmapH)
                                    AddposMovesListX := ResizedBitmapW
                                    break                                            
                                }
                            }
                        } Else {
                            If (InStr(A_LoopField, ":")=1) ;Undrelining title that starts and ends with ":" 
                                If (InStr(A_LoopField, ":",false,0)>StrLen(A_LoopField)-2)
                                    OptionsMovesList = x%posMovesListX% y%posMovesListY% Left c%color2% r4 s%HyperPause_MovesList_SecondaryFontSize% Underline
                            If FullScreenView<>1
                                Gdip_Alt_TextToGraphics(HP_G27, A_LoopField, OptionsMovesList, HyperPause_SubMenu_Font, 0, 0)
                            Else
                                Gdip_Alt_TextToGraphics(HP_G29, a_loopfield, OptionsMovesList, HyperPause_SubMenu_Font)                            
                            AddposMovesListX := MeasureText(A_LoopField, "Left r4 s" . HyperPause_MovesList_SecondaryFontSize . " bold",HyperPause_SubMenu_Font)
                        }
                        posMovesListX := posMovesListX+AddposMovesListX
                    }            
                }
                posMovesListY := posMovesListY+HyperPause_MovesList_VdistBetwMovesListLabels
            }
        }
    }
    StringCaseSense, Off
    If(FullScreenView <> 1){
        If((VSubMenuItem<>0) and (HSubMenuItem=2)){
            CurrentHelpText = Press Select Key to go FullScreen - Page %V2SubMenuItem% of %TotalMovesListPages%
            SubMenuHelpText(CurrentHelpText)
        } Else If ((VSubMenuItem<>0) and (HSubMenuItem=1)){
            CurrentHelpText = Press Left of Right to Select the Moves List - Page %V2SubMenuItem% of %TotalMovesListPages%
            SubMenuHelpText(CurrentHelpText)
        } Else {            
        Gdip_GraphicsClear(HP_G33)
        Alt_UpdateLayeredWindow(HP_hwnd33, HP_hdc33,baseScreenWidth - HelpTextLenghtWidth - 2*HyperPause_SubMenu_AdditionalTextMarginContour,baseScreenHeight- HyperPause_SubMenu_SmallFontSize,HelpTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_HelpFontSize)
        }
    } Else {
        HyperPause_SubMenu_FullScreenHelpBoxHeight := 5*HyperPause_SubMenu_FullScreenFontSize
        HyperPause_SubMenu_FullScreenHelpBoxWidth := MeasureText("Press Up for Page Up or Press Down for Page Down", "Left r4 s" . HyperPause_SubMenu_FullScreenFontSize . " bold",HyperPause_SubMenu_Font)+HyperPause_SubMenu_AdditionalTextMarginContour
        Gdip_Alt_FillRoundedRectangle(HP_G29, HyperPause_SubMenu_FullScreenBrushV, round((HyperPause_SubMenu_MovesListFullScreenWidth-HyperPause_SubMenu_FullScreenHelpBoxWidth)/2), baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin-6*HyperPause_SubMenu_FullScreenFontSize, HyperPause_SubMenu_FullScreenHelpBoxWidth,HyperPause_SubMenu_FullScreenHelpBoxHeight,HyperPause_SubMenu_FullScreenRadiusofRoundedCorners)
        posFullScreenTextX := round(HyperPause_SubMenu_MovesListFullScreenWidth/2)
        posFullScreenTextY := round(baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin-5*HyperPause_SubMenu_FullScreenFontSize-HyperPause_SubMenu_FullScreenFontSize/2)
        OptionsFullScreenText = x%posFullScreenTextX% y%posFullScreenTextY% Center c%HyperPause_SubMenu_FullScreenFontColor% r4 s%HyperPause_SubMenu_FullScreenFontSize% bold
        CurrentHelpText = Press Select Key to Exit Full Screen`nPress Up for Page Up or Press Down for Page Down`nPage %V2SubMenuItem% of %TotalMovesListPages%
        Gdip_Alt_TextToGraphics(HP_G29, CurrentHelpText, OptionsFullScreenText, HyperPause_SubMenu_Font, 0, 0)
        Alt_UpdateLayeredWindow(HP_hwnd29, HP_hdc29,round((baseScreenWidth-HyperPause_SubMenu_MovesListFullScreenWidth)/2), HyperPause_SubMenu_FullScreenMargin, HyperPause_SubMenu_MovesListFullScreenWidth, baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin)
    }
Return

       

;-------Statistics Sub Menu-------
Statistics:
    SetTimer, UpdateStatsScrollingText, off
    Gdip_GraphicsClear(HP_G30)
    Alt_UpdateLayeredWindow(HP_hwnd30, HP_hdc30, 0, 0, baseScreenWidth, baseScreenHeight)
    Statistics_TitleLabel_1 = General Statistics:
    Statistics_TitleLabel_3 = System Top Ten:
    Statistics_TitleLabel_6 = Global Top Ten:
    Statistics_Label_List = General_Statistics|Global_Last_Played_Games|System_Top_Ten_(Most_Played)|System_Top_Ten_(Times_Played)|System_Top_Ten_(Average_Time)|Global_Top_Ten_(System_Most_Played)|Global_Top_Ten_(Most_Played)|Global_Top_Ten_(Times_Played)|Global_Top_Ten_(Average_Time)
    Statistics_Label_Name_List = Game Statistics|Last Played Games|Most Played Games|Number of Times Played|Average Time Played|Systems Most Played|Most Played Games|Number of Times Played|Average Time Played
    Statistics_var_List_1 = Game Name|System Name|Number_of_Times_Played|Last_Time_Played|Average_Time_Played|Total_Time_Played|System_Total_Played_Time|Total_Global_Played_Time
    Statistics_var_List_2 = 1|2|3|4|5|6|7|8|9|10  
    Loop, 7
        {
        current := A_index + 2
        Statistics_var_List_%current% = 1st|2nd|3rd|4th|5th|6th|7th|8th|9th|10th
        ;Statistics_var_List_%current% = 1st_Place|2nd_Place|3rd_Place|4th_Place|5th_Place|6th_Place|7th_Place|8th_Place|9th_Place|10th_Place 
    }
    color := HyperPause_MainMenu_LabelDisabledColor
    color2 := HyperPause_MainMenu_LabelDisabledColor
    color3 := HyperPause_Statistics_TitleFontColor
    Optionbrush := HyperPause_SubMenu_DisabledBrushV
    posStatisticsLabelY := HyperPause_Statistics_VMargin
    StatisticsLabelCount=0
    NumberofDrawns=0
    MaxStatisticsLabelWidth = %HyperPause_SubMenu_MinimumTextBoxWidth%
    Loop, parse, Statistics_Label_Name_List, |
    {
        StatisticsLabelCount++
        Statistics_Label_Name_%a_index% := A_LoopField  
        StatisticsLabelWidth := MeasureText(A_LoopField, "Left r4 s" . HyperPause_SubMenu_LabelFontSize . " bold",HyperPause_SubMenu_LabelFont)+HyperPause_SubMenu_AdditionalTextMarginContour
        If(StatisticsLabelWidth>MaxStatisticsLabelWidth){
        MaxStatisticsLabelWidth := StatisticsLabelWidth
        }    
    }      
    posStatisticsLabelX := round(HyperPause_Statistics_HMargin+MaxStatisticsLabelWidth/2)
    StatisticsTablecount=0
    Loop, parse, Statistics_Label_List, |
        {
        If(Statistics_TitleLabel_%a_index%<>""){
            posStatisticsTitleLabelX := round(HyperPause_Statistics_HMargin/2)
            OptionsStatisticsTitleLabel = x%posStatisticsTitleLabelX% y%posStatisticsLabelY% Left c%HyperPause_MainMenu_LabelDisabledColor% r4 s%HyperPause_SubMenu_LabelFontSize% bold
            Gdip_Alt_TextToGraphics(HP_G27, Statistics_TitleLabel_%A_index%, OptionsStatisticsTitleLabel, HyperPause_SubMenu_LabelFont, 0, 0)
            posStatisticsLabelY := posStatisticsLabelY+HyperPause_Statistics_VdistBetwLabels
        }
        If(A_index >= VSubMenuItem){
            If((HSubMenuItem=1)and(A_index=VSubMenuItem)){
                V2SubMenuItem = 1
                color := HyperPause_MainMenu_LabelSelectedColor
                Optionbrush := HyperPause_SubMenu_SelectedBrushV
                Current_Label := A_LoopField
                current_item := A_index
            }
            OptionsStatisticsLabel = x%posStatisticsLabelX% y%posStatisticsLabelY% Center c%color% r4 s%HyperPause_SubMenu_LabelFontSize% bold
            Gdip_Alt_FillRoundedRectangle(HP_G27, Optionbrush, round(posStatisticsLabelX-MaxStatisticsLabelWidth/2), posStatisticsLabelY-HyperPause_SubMenu_AdditionalTextMarginContour+HyperPause_VTextDisplacementAdjust, MaxStatisticsLabelWidth, HyperPause_SubMenu_FontSize+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_RadiusofRoundedCorners)
            Gdip_Alt_TextToGraphics(HP_G27, Statistics_Label_Name_%a_index%, OptionsStatisticsLabel, HyperPause_SubMenu_LabelFont, 0, 0)
            posStatisticsLabelY := posStatisticsLabelY+HyperPause_Statistics_VdistBetwLabels
            color := HyperPause_MainMenu_LabelDisabledColor
            Optionbrush := HyperPause_SubMenu_DisabledBrushV
        }
    }  
    If(FullScreenView=1){
        Gdip_GraphicsClear(HP_G29)
        pGraphUpd(HP_G29, HyperPause_SubMenu_StatisticsFullScreenWidth, baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin)
        Gdip_Alt_FillRoundedRectangle(HP_G29, HyperPause_SubMenu_FullScreenTextBrushV, 0, 0, HyperPause_SubMenu_StatisticsFullScreenWidth, baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin, HyperPause_SubMenu_FullScreenRadiusofRoundedCorners)
        posStatisticsTableTitleY := 4*HyperPause_SubMenu_FullScreenMargin
        posStatisticsTableY := 4*HyperPause_SubMenu_FullScreenMargin+2*HyperPause_Statistics_TitleFontSize
        posStatisticsTableX := 4*HyperPause_SubMenu_FullScreenMargin
        posStatisticsTableX3 := HyperPause_SubMenu_StatisticsFullScreenWidth-4*HyperPause_SubMenu_FullScreenMargin
    } Else {
        posStatisticsTableTitleY := HyperPause_Statistics_VMargin
        posStatisticsTableY := HyperPause_Statistics_VMargin+2*HyperPause_Statistics_TitleFontSize
        posStatisticsTableX := round(posStatisticsLabelX+MaxStatisticsLabelWidth/2+HyperPause_Statistics_DistBetweenLabelsandTable)
        posStatisticsTableX3 := HyperPause_SubMenu_Width-HyperPause_Statistics_DistBetweenLabelsandTable
    }
    posStatisticsTableX2 := round((posStatisticsTableX + posStatisticsTableX3)/2+HyperPause_Statistics_Middle_Column_Offset)
    OptionsStatisticsTableTitle = x%posStatisticsTableX% y%posStatisticsTableTitleY% Left c%HyperPause_Statistics_TitleFontColor% r4 s%HyperPause_Statistics_TableFontSize% bold
    OptionsStatisticsTableTitle2 = x%posStatisticsTableX2% y%posStatisticsTableTitleY% Center c%HyperPause_Statistics_TitleFontColor% r4 s%HyperPause_Statistics_TableFontSize% bold
    OptionsStatisticsTableTitle3 = x%posStatisticsTableX3% y%posStatisticsTableTitleY% Right c%HyperPause_Statistics_TitleFontColor% r4 s%HyperPause_Statistics_TableFontSize% bold
    If(VSubMenuItem=0){
        Current_Label := "General_Statistics"
        current_item := 1
    }
    stringreplace, Current_Label_Without_Parenthesis, Current_Label, (,,all
    stringreplace, Current_Label_Without_Parenthesis, Current_Label_Without_Parenthesis, ),,all
    If(Current_Label="General_Statistics"){
        current_column1_Title = Game Statistics
    } Else If (Current_Label="Global_Last_Played_Games"){
        current_column1_Title = Last Played Games        
        current_column2_Title =
        current_column3_Title := "System Name"
        current_column3_TitleExtra := "Last Time Played"
    }Else{
        current_column1_Title = Rank
        If(Current_Label="Global_Top_Ten_(System_Most_Played)")
            current_column2_Title := "System"
        Else
            current_column2_Title := "Game"
        If((Current_Label="System_Top_Ten_(Most_Played)")or(Current_Label="Global_Top_Ten_(Most_Played)")){
            current_column3_Title := "Total Time"
        } If Else ((Current_Label="System_Top_Ten_(Times_Played)")or(Current_Label="Global_Top_Ten_(Times_Played)")){
            current_column3_Title := "Number of Times"
        } If Else ((Current_Label="System_Top_Ten_(Average_Time)")or(Current_Label="Global_Top_Ten_(Average_Time)")) {
            current_column3_Title := "Average Time"
        }
    }
    ; Drawing Title
    If !(Current_Label="General_Statistics"){
        If (FullScreenView=1){
            Gdip_Alt_TextToGraphics(HP_G29, current_column2_Title, OptionsStatisticsTableTitle2, HyperPause_SubMenu_Font, 0, 0)
            Gdip_Alt_TextToGraphics(HP_G29, current_column3_Title, OptionsStatisticsTableTitle3, HyperPause_SubMenu_Font, 0, 0)
        } Else {
            Gdip_Alt_TextToGraphics(HP_G27, current_column2_Title, OptionsStatisticsTableTitle2, HyperPause_SubMenu_Font, 0, 0)
            Gdip_Alt_TextToGraphics(HP_G27, current_column3_Title, OptionsStatisticsTableTitle3, HyperPause_SubMenu_Font, 0, 0)
        }
    }   
    If (Current_Label="Global_Last_Played_Games") {
        If (FullScreenView=1)
            Gdip_Alt_TextToGraphics(HP_G29, current_column3_TitleExtra, "x" . posStatisticsTableX3 . " y" . posStatisticsTableTitleY+HyperPause_Statistics_VdistBetwTableLines . " Right c" . HyperPause_Statistics_TitleFontColor . " r4 s" . HyperPause_Statistics_TableFontSize . " bold", HyperPause_SubMenu_Font, 0, 0)
        else
            Gdip_Alt_TextToGraphics(HP_G27, current_column3_TitleExtra, "x" . posStatisticsTableX3 . " y" . posStatisticsTableTitleY+HyperPause_Statistics_VdistBetwTableLines . " Right c" . HyperPause_Statistics_TitleFontColor . " r4 s" . HyperPause_Statistics_TableFontSize . " bold", HyperPause_SubMenu_Font, 0, 0)
        posStatisticsTableY := posStatisticsTableY+HyperPause_Statistics_VdistBetwTableLines 
    }
    If(FullScreenView=1)    
        Gdip_Alt_TextToGraphics(HP_G29, current_column1_Title, OptionsStatisticsTableTitle, HyperPause_SubMenu_Font, 0, 0)  
    Else
        Gdip_Alt_TextToGraphics(HP_G27, current_column1_Title, OptionsStatisticsTableTitle, HyperPause_SubMenu_Font, 0, 0)              
    ;Drawing Table contents
    Loop, parse, Statistics_var_List_%current_item%,| 
        {
        StatisticsTablecount++
        stringreplace, current_column1, a_loopfield, _, %a_space%,all
        If(((V2SubMenuItem = A_index ) and (HSubMenuItem=2)) or (FullScreenView=1))
            color2 := HyperPause_MainMenu_LabelSelectedColor
        If(A_index >= V2SubMenuItem){  
            ; Column 2 and 3 values
            If(Current_Label="General_Statistics"){
                If(A_index=1)
                    current_column3 := gameInfo["Name"].Value
                Else If(A_index=2)
                    current_column3 := SystemName
                Else {
                    current_column3_Label := % "Value_" . Current_Label_Without_Parenthesis . "_Statistic_" . A_index-2
                    current_column3 := % %current_column3_Label%
                }
            } Else If (Current_Label="Global_Last_Played_Games"){
                current_column1_Label := % "Value_" . Current_Label_Without_Parenthesis . "_Name_" . A_index
                current_column3_Label := % "Value_" . Current_Label_Without_Parenthesis . "_System_" . A_index
                current_column1 := % %current_column1_Label%
                current_column3 := % %current_column3_Label%
            } Else {
                current_column2_Label := % "Value_" . Current_Label_Without_Parenthesis . "_Name_" . A_index
                current_column3_Label := % "Value_" . Current_Label_Without_Parenthesis . "_Number_" . A_index
                current_column2 := % %current_column2_Label%
                current_column3 := % %current_column3_Label%                
            }  
            ; Max Size for columns
            If(Current_Label="General_Statistics"){
                statsTextSpace := posStatisticsTableX3 - posStatisticsTableX - HyperPause_Statistics_MarginBetweenTableColumns - MeasureText(current_column1, "c" . color2 . " r4 s" . HyperPause_Statistics_TableFontSize . " bold",HyperPause_SubMenu_Font)
                currentTextSize := MeasureText(current_column3, "c" . color2 . " r4 s" . HyperPause_Statistics_TableFontSize . " bold",HyperPause_SubMenu_Font)
            } Else if (Current_Label="Global_Last_Played_Games"){
                statsTextSpace := posStatisticsTableX3 - posStatisticsTableX - HyperPause_Statistics_MarginBetweenTableColumns - MeasureText(current_column1, "c" . color2 . " r4 s" . HyperPause_Statistics_TableFontSize . " bold",HyperPause_SubMenu_Font)
                currentTextSize := MeasureText(current_column3, "c" . color2 . " r4 s" . HyperPause_Statistics_TableFontSize . " bold",HyperPause_SubMenu_Font)
            } else {
                statsTextSpace1 := posStatisticsTableX2 - posStatisticsTableX - HyperPause_Statistics_MarginBetweenTableColumns - MeasureText(current_column1, "c" . color2 . " r4 s" . HyperPause_Statistics_TableFontSize . " bold",HyperPause_SubMenu_Font)
                statsTextSpace2 := posStatisticsTableX3 - posStatisticsTableX2 - HyperPause_Statistics_MarginBetweenTableColumns - MeasureText(current_column3, "c" . color2 . " r4 s" . HyperPause_Statistics_TableFontSize . " bold",HyperPause_SubMenu_Font)
                statsTextSpace := 2* ((statsTextSpace1<statsTextSpace2) ? statsTextSpace1 : statsTextSpace2)
                currentTextSize := MeasureText(current_column2, "c" . color2 . " r4 s" . HyperPause_Statistics_TableFontSize . " bold",HyperPause_SubMenu_Font)
            }
            ; Text Options
            OptionsStatisticsTable = x%posStatisticsTableX% y%posStatisticsTableY% Left c%color2% r4 s%HyperPause_Statistics_TableFontSize% bold
            If ((Current_Label="General_Statistics") or (Current_Label="Global_Last_Played_Games")) {
                OptionsStatisticsTable3 := "x" . posStatisticsTableX3-HyperPause_Statistics_MarginBetweenTableColumns-statsTextSpace . " y" . posStatisticsTableY . " w" . statsTextSpace . " h" . HyperPause_Statistics_TableFontSize . " Right c" . color2 . " r4 s" . HyperPause_Statistics_TableFontSize . " bold"
            } else {
                OptionsStatisticsTable2 := "x" . posStatisticsTableX2-statsTextSpace//2 . " y" . posStatisticsTableY . " w" . statsTextSpace . " h" . HyperPause_Statistics_TableFontSize . " Center c" . color2 . " r4 s" . HyperPause_Statistics_TableFontSize . " bold"
                OptionsStatisticsTable3 := "x" . posStatisticsTableX3 . " y" . posStatisticsTableY . " Right c" . color2 . " r4 s" . HyperPause_Statistics_TableFontSize . " bold"
            }
            ; Draw Column 1
            If(Current_Label="Global_Last_Played_Games"){
                If (FullScreenView=1)
                    Gdip_Alt_TextToGraphics(HP_G29, current_column1, OptionsStatisticsTable, HyperPause_SubMenu_Font, 0, 0)   
                else
                    Gdip_Alt_TextToGraphics(HP_G27, current_column1, OptionsStatisticsTable, HyperPause_SubMenu_Font, 0, 0)   
            } Else {
                If (FullScreenView=1)
                    Gdip_Alt_TextToGraphics(HP_G29, current_column1, OptionsStatisticsTable, HyperPause_SubMenu_Font, 0, 0)  
                Else 
                    Gdip_Alt_TextToGraphics(HP_G27, current_column1, OptionsStatisticsTable, HyperPause_SubMenu_Font, 0, 0)
            }
            ; Draw Column 2 and 3
            If((V2SubMenuItem = A_index ) and (HSubMenuItem=2)){ ; test if current text fits. If not, do a scrolling text effect
                if ( currentTextSize <= statsTextSpace) { ; draw normaly the text on screen
                    If((Current_Label="General_Statistics") or (Current_Label="Global_Last_Played_Games")){
                        if  (FullScreenView=1)
                            Gdip_Alt_TextToGraphics(HP_G29, current_column3, OptionsStatisticsTable3, HyperPause_SubMenu_Font, 0, 0)  
                        else
                            Gdip_Alt_TextToGraphics(HP_G27, current_column3, OptionsStatisticsTable3, HyperPause_SubMenu_Font, 0, 0)        
                    } else {
                        If(FullScreenView=1)   
                            Gdip_Alt_TextToGraphics(HP_G29, current_column2, OptionsStatisticsTable2, HyperPause_SubMenu_Font, 0, 0) 
                        Else
                            Gdip_Alt_TextToGraphics(HP_G27, current_column2, OptionsStatisticsTable2, HyperPause_SubMenu_Font, 0, 0)   
                    }
                } else { ; start scrolling text effect	
                    initStatsPixels := 0
                    xIncrementStatsScroll := 0
                    yStatsScroll := posStatisticsTableY
                    colorStatsScroll := color2
                    sizeStatsScroll := HyperPause_Statistics_TableFontSize
                    If((Current_Label="General_Statistics") or (Current_Label="Global_Last_Played_Games")){
                        textStatsScroll := current_column3
                        xStatsScroll := posStatisticsTableX3-statsTextSpace
                    } else {
                        textStatsScroll := current_column2
                        xStatsScroll := posStatisticsTableX2-statsTextSpace//2
                    }
                    SetTimer, UpdateStatsScrollingText, 20
                }
            } else {
                If((Current_Label="General_Statistics") or (Current_Label="Global_Last_Played_Games")){
                    if  (FullScreenView=1)
                        Gdip_Alt_TextToGraphics(HP_G29, current_column3, OptionsStatisticsTable3, HyperPause_SubMenu_Font, 0, 0)  
                    else
                        Gdip_Alt_TextToGraphics(HP_G27, current_column3, OptionsStatisticsTable3, HyperPause_SubMenu_Font, 0, 0)        
                } else {
                    If(FullScreenView=1)   
                        Gdip_Alt_TextToGraphics(HP_G29, current_column2, OptionsStatisticsTable2, HyperPause_SubMenu_Font, 0, 0) 
                    Else
                        Gdip_Alt_TextToGraphics(HP_G27, current_column2, OptionsStatisticsTable2, HyperPause_SubMenu_Font, 0, 0)   
                }
            }
            If(VSubMenuItem > 2){
                If(FullScreenView=1)    
                    Gdip_Alt_TextToGraphics(HP_G29, current_column3, OptionsStatisticsTable3, HyperPause_SubMenu_Font, 0, 0)     
                else
                    Gdip_Alt_TextToGraphics(HP_G27, current_column3, OptionsStatisticsTable3, HyperPause_SubMenu_Font, 0, 0) 
            }
            posStatisticsTableY := posStatisticsTableY+HyperPause_Statistics_VdistBetwTableLines            
            ; Extra Info
            If(VSubMenuItem > 6){
                current_column2_Label := % "Value_" . Current_Label_Without_Parenthesis . "_System_" . A_index
                current_column2 := % %current_column2_Label%
                OptionsStatisticsTable2 = x%posStatisticsTableX2% y%posStatisticsTableY% Center c%color2% r4 s%HyperPause_Statistics_TableFontSize% bold
                If(FullScreenView<>1)    
                    Gdip_Alt_TextToGraphics(HP_G27, current_column2, OptionsStatisticsTable2, HyperPause_SubMenu_Font, 0, 0)   
                Else
                    Gdip_Alt_TextToGraphics(HP_G29, current_column2, OptionsStatisticsTable2, HyperPause_SubMenu_Font, 0, 0)   
                posStatisticsTableY := posStatisticsTableY+HyperPause_Statistics_VdistBetwTableLines
            }            
            If(VSubMenuItem = 2){
                current_column3_Label := % "Value_" . Current_Label_Without_Parenthesis . "_Date_" . A_index
                current_column3 := % %current_column3_Label%
                OptionsStatisticsTable3 = x%posStatisticsTableX3% y%posStatisticsTableY% Right c%color2% r4 s%HyperPause_Statistics_TableFontSize% bold
                If(FullScreenView<>1)    
                    Gdip_Alt_TextToGraphics(HP_G27, current_column3, OptionsStatisticsTable3, HyperPause_SubMenu_Font, 0, 0)                     
                Else
                    Gdip_Alt_TextToGraphics(HP_G29, current_column3, OptionsStatisticsTable3, HyperPause_SubMenu_Font, 0, 0)                     
                posStatisticsTableY := posStatisticsTableY+HyperPause_Statistics_VdistBetwTableLines
            }
            color2 := HyperPause_MainMenu_LabelDisabledColor
        }
    }
    If(FullScreenView <> 1){
        If((VSubMenuItem<>0) and (HSubMenuItem=2)){
            SubMenuHelpText("Press Select Key to go FullScreen")
        } Else If ((VSubMenuItem<>0) and (HSubMenuItem=1)){
            CurrentHelpText = Press Left or Right to Select the Statistics
            SubMenuHelpText(CurrentHelpText)
        } Else {            
        Gdip_GraphicsClear(HP_G33)
        Alt_UpdateLayeredWindow(HP_hwnd33, HP_hdc33,baseScreenWidth - HelpTextLenghtWidth - 2*HyperPause_SubMenu_AdditionalTextMarginContour,baseScreenHeight- HyperPause_SubMenu_SmallFontSize,HelpTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_HelpFontSize)
        }
    } Else {
        HyperPause_SubMenu_FullScreenHelpBoxHeight := 4*HyperPause_SubMenu_FullScreenFontSize
        HyperPause_SubMenu_FullScreenHelpBoxWidth := MeasureText("Press Up or Down to move between Statistics", "Left r4 s" . HyperPause_SubMenu_FullScreenFontSize . " bold",HyperPause_SubMenu_Font)+HyperPause_SubMenu_AdditionalTextMarginContour
        Gdip_Alt_FillRoundedRectangle(HP_G29, HyperPause_SubMenu_FullScreenBrushV, round((HyperPause_SubMenu_MovesListFullScreenWidth-HyperPause_SubMenu_FullScreenHelpBoxWidth)/2), baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin-5*HyperPause_SubMenu_FullScreenFontSize, HyperPause_SubMenu_FullScreenHelpBoxWidth,HyperPause_SubMenu_FullScreenHelpBoxHeight,HyperPause_SubMenu_FullScreenRadiusofRoundedCorners)
        posFullScreenTextX := round(HyperPause_SubMenu_MovesListFullScreenWidth/2)
        posFullScreenTextY := round(baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin-4*HyperPause_SubMenu_FullScreenFontSize-HyperPause_SubMenu_FullScreenFontSize/2)
        OptionsFullScreenText = x%posFullScreenTextX% y%posFullScreenTextY% Center c%HyperPause_SubMenu_FullScreenFontColor% r4 s%HyperPause_SubMenu_FullScreenFontSize% bold
        CurrentHelpText = Press Select Key to Exit Full Screen`nPress Up or Down to move between Statistics
        Gdip_Alt_TextToGraphics(HP_G29, CurrentHelpText, OptionsFullScreenText, HyperPause_SubMenu_Font, 0, 0)
        Alt_UpdateLayeredWindow(HP_hwnd29, HP_hdc29,round((baseScreenWidth-HyperPause_SubMenu_StatisticsFullScreenWidth)/2), HyperPause_SubMenu_FullScreenMargin, HyperPause_SubMenu_StatisticsFullScreenWidth, baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin)
    }
Return 
            
UpdateStatsScrollingText:
    scrollingVelocity := 2
	xIncrementStatsScroll := (-xIncrementStatsScroll >= WidthStatsScrollingText3) ? initStatsPixels : xIncrementStatsScroll-scrollingVelocity
	initStatsPixels := statsTextSpace
    Gdip_GraphicsClear(HP_G30)
    pGraphUpd(HP_G30,statsTextSpace,sizeStatsScroll)
    WidthStatsScrollingText := Gdip_Alt_TextToGraphics(HP_G30, textStatsScroll, "x" . xIncrementStatsScroll . " y0 Left c" . colorStatsScroll . " r4 s" . sizeStatsScroll . " Bold", HyperPause_SubMenu_Font, (xIncrementStatsScroll < 0) ? initStatsPixels-xIncrementStatsScroll : initStatsPixels, sizeStatsScroll)
    StringSplit, WidthStatsScrollingText, WidthStatsScrollingText, |
    if (FullScreenView=1)
        Alt_UpdateLayeredWindow(HP_hwnd30, HP_hdc30, (baseScreenWidth-HyperPause_SubMenu_StatisticsFullScreenWidth)//2+xStatsScroll, HyperPause_SubMenu_FullScreenMargin+yStatsScroll, statsTextSpace, sizeStatsScroll)
    else
        Alt_UpdateLayeredWindow(HP_hwnd30, HP_hdc30, baseScreenWidth-HyperPause_SubMenu_Width+xStatsScroll, baseScreenHeight-HyperPause_SubMenu_Height+yStatsScroll, statsTextSpace, sizeStatsScroll)
Return      



;-------Guides Sub Menu-------
Guides:
    TextImagesAndPDFMenu("Guides")
Return

;-------Manuals Sub Menu-------
Manuals:
    TextImagesAndPDFMenu("Manuals")
Return

;-------History dat Sub Menu-------
History:
    TextImagesAndPDFMenu("History")
Return

;-----------------COMMANDS-------------
MoveRight:
    If DirectionCommandRunning
        Return   
    DirectionCommandRunning := true
    If(VSubMenuItem=0){
        If (SelectedMenuOption:="Video"){
            AnteriorFilePath:=
            V2Submenuitem := 1
            try CurrentVideoPlayStatus := wmpVideo.playState
            If(CurrentVideoPlayStatus=3) {
                try VideoPosition%videoplayingindex% := wmpVideo.controls.currentPosition
                Log("VideoPosition at main menu change:" "VideoPosition"videoplayingindex " " VideoPosition%videoplayingindex%,5)
                try wmpVideo.controls.stop
            }
            if MusicPausedonVideosMenu
                {
                try wmpMusic.controls.play
                MusicPausedonVideosMenu := false                    
            }
            Gui,HP_GUI31: Show, Hide
            Gui, HP_GUI32: Show
        }
        HyperPause_MainMenuItem := HyperPause_MainMenuItem+1
        HSubMenuItem=1
        Gdip_GraphicsClear(HP_G29)
        Alt_UpdateLayeredWindow(HP_hwnd29, HP_hdc29, baseScreenWidth - HyperPause_SubMenu_Width,baseScreenHeight-HyperPause_SubMenu_Height,HyperPause_SubMenu_Width,HyperPause_SubMenu_Height)
        Gdip_GraphicsClear(HP_G33)
        Alt_UpdateLayeredWindow(HP_hwnd33, HP_hdc33, 0,0,baseScreenWidth,baseScreenHeight)
        Gosub MainMenuSwap
        Gdip_GraphicsClear(HP_G25)
        Gosub DrawMainMenuBar
        Alt_UpdateLayeredWindow(HP_hwnd25, HP_hdc25,0,round((baseScreenHeight-HyperPause_MainMenu_BarHeight)/2)+HyperPause_MainMenu_BarVerticalOffset, baseScreenWidth, HyperPause_MainMenu_BarHeight)
        Log("Loaded Main Menu Bar. Current Main Menu Label: " HyperPause_MainMenuSelectedLabel,1)
        If(SubMenuDrawn=1){
            Gdip_GraphicsClear(HP_G26)
            Alt_UpdateLayeredWindow(HP_hwnd26, HP_hdc26,ConfigMenuX,ConfigMenuY, ConfigMenuWidth, ConfigMenuHeight)
            Gdip_GraphicsClear(HP_G27)
            Alt_UpdateLayeredWindow(HP_hwnd27, HP_hdc27,baseScreenWidth-HyperPause_SubMenu_Width,baseScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
            SubMenuDrawn=0
        }
    } Else If (SelectedMenuOption="Sound") and (VSubMenuItem=1){
        HyperPause_VolumeMaster := round(HyperPause_VolumeMaster + HyperPause_SoundBar_vol_Step)+0
        HyperPause_VolumeMaster := round(HyperPause_VolumeMaster//HyperPause_SoundBar_vol_Step*HyperPause_SoundBar_vol_Step)+0 ;Avoiding volume increase in non multiple steps
        If  HyperPause_VolumeMaster < 0 
            HyperPause_VolumeMaster = 0
        If  HyperPause_VolumeMaster > 100
            HyperPause_VolumeMaster = 100
        setVolume(HyperPause_VolumeMaster)
        gosub, DrawSubMenu
    } Else {
        If((FullScreenView = 1) and (ZoomLevel <> 100)){
            HorizontalPanFullScreen := HorizontalPanFullScreen-HyperPause_SubMenu_FullScreenPanSteps
            gosub, DrawSubMenu            
        } Else If ((FullScreenView = 1) and (SelectedMenuOption="MovesList")){
            V2SubMenuItem := V2SubMenuItem+1
            Gosub SubMenuSwap 
            gosub, DrawSubMenu   
        } Else If ((FullScreenView = 1) and ((SelectedMenuOption="Guides") or (SelectedMenuOption="Manuals") or (SelectedMenuOption="History") or (SelectedMenuOption="Controller") or (SelectedMenuOption="Artwork")) and (CurrentFileExtension = "txt")){
            V2SubMenuItem := V2SubMenuItem+1
            If  V2SubMenuItem < 1 
            V2SubMenuItem = % TotaltxtPages
            If  V2SubMenuItem > % TotaltxtPages
            V2SubMenuItem = 1
            Gosub SubMenuSwap 
            HSubmenuitem%SelectedMenuOption%V2Submenuitem%VSubmenuitem% = % V2SubMenuItem
            gosub, DrawSubMenu
        } Else If ((FullScreenView = 1) and (SelectedMenuOption="HighScore")){
            VSubMenuItem := VSubMenuItem+1
            Gosub SubMenuSwap   
            gosub, DrawSubMenu
        } Else If ((SelectedMenuOption="Controller") and (VSubMenuItem = -1) and (FullScreenView=1)){   
            If (V2SubMenuItem > 2)
                HSubMenuItem := HSubMenuItem+1
            Else 
                HSubMenuItem := 1
            Gosub SubMenuSwap
            gosub, DrawSubMenu
        } Else {
            HSubMenuItem := HSubMenuItem+1
            Gosub SubMenuSwap 
            if (VSubMenuItem >= 0)
                HSubmenuitem%SelectedMenuOption%VSubmenuitem%VSubmenuitem% = % HSubMenuItem            
            gosub, DrawSubMenu
        }
    }
    If (SelectedMenuOption<>"Sound")
        settimer, UpdateMusicPlayingInfo, off
    If (SelectedMenuOption<>"Videos")
        settimer, UpdateVideoPlayingInfo, off
    DirectionCommandRunning := false   
Return


MoveLeft:
    If DirectionCommandRunning
        Return   
    DirectionCommandRunning := true
    If(VSubMenuItem=0){
        If (SelectedMenuOption:="Video"){
            AnteriorFilePath:=
            V2Submenuitem := 1
            try CurrentVideoPlayStatus := wmpVideo.playState
            If(CurrentVideoPlayStatus=3) {
                try VideoPosition%videoplayingindex% := wmpVideo.controls.currentPosition
                Log("VideoPosition at main menu change:" "VideoPosition"videoplayingindex " " VideoPosition%videoplayingindex%,5)
                try wmpVideo.controls.stop
            }
            if MusicPausedonVideosMenu
                {
                try wmpMusic.controls.play
                MusicPausedonVideosMenu := false                    
            }
            Gui,HP_GUI31: Show, Hide
            Gui, HP_GUI32: Show
        }
        HyperPause_MainMenuItem := HyperPause_MainMenuItem-1
        HSubMenuItem=1
        Gdip_GraphicsClear(HP_G29)
        Alt_UpdateLayeredWindow(HP_hwnd29, HP_hdc29, baseScreenWidth - HyperPause_SubMenu_Width,baseScreenHeight-HyperPause_SubMenu_Height,HyperPause_SubMenu_Width,HyperPause_SubMenu_Height) 
        Gdip_GraphicsClear(HP_G33)
        Alt_UpdateLayeredWindow(HP_hwnd33, HP_hdc33, 0,0,baseScreenWidth,baseScreenHeight)
        Gosub MainMenuSwap
        Gdip_GraphicsClear(HP_G25)
        Gosub DrawMainMenuBar
        Alt_UpdateLayeredWindow(HP_hwnd25, HP_hdc25,0,round((baseScreenHeight-HyperPause_MainMenu_BarHeight)/2)+HyperPause_MainMenu_BarVerticalOffset, baseScreenWidth, HyperPause_MainMenu_BarHeight)
        Log("Loaded Main Menu Bar. Current Main Menu Label: " HyperPause_MainMenuSelectedLabel,1)
        If(SubMenuDrawn=1){
            Gdip_GraphicsClear(HP_G26)
            Alt_UpdateLayeredWindow(HP_hwnd26, HP_hdc26,ConfigMenuX,ConfigMenuY, ConfigMenuWidth, ConfigMenuHeight)
            Gdip_GraphicsClear(HP_G27)
            Alt_UpdateLayeredWindow(HP_hwnd27, HP_hdc27,baseScreenWidth-HyperPause_SubMenu_Width,baseScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
            SubMenuDrawn=0
        }
    } Else If (SelectedMenuOption="Sound") and (VSubMenuItem=1){
        HyperPause_VolumeMaster := round(HyperPause_VolumeMaster - HyperPause_SoundBar_vol_Step)+0
        HyperPause_VolumeMaster := round(HyperPause_VolumeMaster//HyperPause_SoundBar_vol_Step*HyperPause_SoundBar_vol_Step)+0 ;Avoiding volume decreae in non multiple steps
        If  HyperPause_VolumeMaster < 0 
            HyperPause_VolumeMaster = 0
        If  HyperPause_VolumeMaster > 100
            HyperPause_VolumeMaster = 100
        setVolume(HyperPause_VolumeMaster)
        gosub, DrawSubMenu
    } Else {
        If((FullScreenView = 1) and (ZoomLevel <> 100)){
            HorizontalPanFullScreen := HorizontalPanFullScreen+HyperPause_SubMenu_FullScreenPanSteps
            gosub, DrawSubMenu            
        } Else If ((FullScreenView = 1) and (SelectedMenuOption="MovesList")){
            V2SubMenuItem := V2SubMenuItem-1
            Gosub SubMenuSwap 
            gosub, DrawSubMenu   
        } Else If ((FullScreenView = 1) and ((SelectedMenuOption="Guides") or (SelectedMenuOption="Manuals") or (SelectedMenuOption="History") or (SelectedMenuOption="Controller") or (SelectedMenuOption="Artwork")) and (CurrentFileExtension = "txt")){
            V2SubMenuItem := V2SubMenuItem-1
            If  V2SubMenuItem < 1 
            V2SubMenuItem = % TotaltxtPages
            If  V2SubMenuItem > % TotaltxtPages
            V2SubMenuItem = 1
            Gosub SubMenuSwap 
            HSubmenuitem%SelectedMenuOption%V2Submenuitem%VSubmenuitem% = % V2SubMenuItem
            gosub, DrawSubMenu
        } Else If ((FullScreenView = 1) and (SelectedMenuOption="HighScore")){
            VSubMenuItem := VSubMenuItem-1
            Gosub SubMenuSwap   
            gosub, DrawSubMenu
        } Else If ((SelectedMenuOption="Controller") and (VSubMenuItem = -1) and (FullScreenView=1)){   
            If (V2SubMenuItem > 2)
                HSubMenuItem := HSubMenuItem-1
            Else 
                HSubMenuItem := 1
            Gosub SubMenuSwap
            gosub, DrawSubMenu
        } Else {
            HSubMenuItem := HSubMenuItem-1
            Gosub SubMenuSwap
            if (VSubMenuItem >= 0)
                HSubmenuitem%SelectedMenuOption%VSubmenuitem%VSubmenuitem% = % HSubMenuItem
            gosub, DrawSubMenu
        }
    }
    If (SelectedMenuOption<>"Sound")
        settimer, UpdateMusicPlayingInfo, off
    If (SelectedMenuOption<>"Videos")
        settimer, UpdateVideoPlayingInfo, off
    DirectionCommandRunning := false   
Return

MoveUp:
    If DirectionCommandRunning
        Return   
    DirectionCommandRunning := true
    If (SelectedMenuOption="Shutdown"){
        DirectionCommandRunning := false   
        Return
    }
    If((FullScreenView = 1) and (ZoomLevel <> 100)){
        VerticalPanFullScreen := VerticalPanFullScreen+HyperPause_SubMenu_FullScreenPanSteps       
        gosub, DrawSubMenu
        DirectionCommandRunning := false   
        Return
    }
    Previous_VSubMenuItem := VSubMenuItem
    If((SelectedMenuOption="Controller") and (VSubMenuItem = -1) and (FullScreenView=1)){
        VSubMenuItem := VSubMenuItem+1
        if (HSubMenuItem=2) {
            V3SubMenuItem := V3SubMenuItem-1
        } else {
            V2SubMenuItem := V2SubMenuItem-1
			If  V2SubMenuItem < 1 
				V2SubMenuItem = 18
			If  V2SubMenuItem > 18
				V2SubMenuItem = 1
        }
    }
    VSubMenuItem := VSubMenuItem-1
    If((SelectedMenuOption="Statistics")and(HSubMenuItem>1)){
        VSubMenuItem := VSubMenuItem+1
        V2SubMenuItem := V2SubMenuItem-1
    }
    If((SelectedMenuOption="MovesList")and(HSubMenuItem>1)){
        VSubMenuItem := VSubMenuItem+1
        V2SubMenuItem := V2SubMenuItem-1
        If  V2SubMenuItem < 1 
            V2SubMenuItem = % TotalMovesListPages
        If  V2SubMenuItem > % TotalMovesListPages
            V2SubMenuItem = 1
    }
    If(((SelectedMenuOption="Guides") or (SelectedMenuOption="Manuals") or (SelectedMenuOption="History") or (SelectedMenuOption="Controller") or (SelectedMenuOption="Artwork"))and(HSubMenuItem>1)and (VSubMenuItem>=0)){
        If((!(CurrentFileExtension ="pdf")) and (!(HPMediaObj[SelectedMenuOption][CurrentLabelName].Type="ImageGroup")) and (!(CurrentCompressedFileExtension="true"))){
            VSubMenuItem := VSubMenuItem+1
        }
        If(CurrentFileExtension ="txt")
        {   if (TotaltxtPages>1)
            {   V2SubMenuItem := V2SubMenuItem-1
                If  V2SubMenuItem < 1 
                    V2SubMenuItem = % TotaltxtPages
                If  V2SubMenuItem > % TotaltxtPages
                    V2SubMenuItem = 1
            } else
                VSubMenuItem := VSubMenuItem-1
        }
        If (VSubMenuItem>=0)
            HSubmenuitem%SelectedMenuOption%V2Submenuitem%VSubmenuitem% = % V2SubMenuItem
    }
    If((SelectedMenuOption="Videos") and (HSubMenuItem>1)){
        VSubMenuItem := VSubMenuItem+1
        V2SubMenuItem := V2SubMenuItem-1
        If  V2SubMenuItem < 1 
            V2SubMenuItem = 5
        If  V2SubMenuItem > 5
            V2SubMenuItem = 1
            HSubmenuitem%SelectedMenuOption%V2Submenuitem%VSubmenuitem% = % V2SubMenuItem
    }
    Gosub SubMenuSwap
    If((Previous_VSubMenuItem = 0) or (VSubMenuItem = 0)){
        HSubMenuItem=1
        Gdip_GraphicsClear(HP_G25)
        Gosub DrawMainMenuBar
        Alt_UpdateLayeredWindow(HP_hwnd25, HP_hdc25,0,round((baseScreenHeight-HyperPause_MainMenu_BarHeight)/2)+HyperPause_MainMenu_BarVerticalOffset, baseScreenWidth, HyperPause_MainMenu_BarHeight)
        Log("Loaded Main Menu Bar. Current Main Menu Label: " HyperPause_MainMenuSelectedLabel,1)
    }
    If (SelectedMenuOption="Sound"){
        If (VSubMenuItem = 3){
            currentPlayindex := HSubmenuitemSoundVSubmenuitem3           
        } Else {
            PreviousCurrentMusicButton = 
            Gdip_GraphicsClear(HP_G30)
            Alt_UpdateLayeredWindow(HP_hwnd30, HP_hdc30, baseScreenWidth-HyperPause_SubMenu_Width, baseScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
        }
    }
    If (SelectedMenuOption="Videos"){
        If (HSubMenuItem <> 2){
            Gdip_GraphicsClear(HP_G30)
            Alt_UpdateLayeredWindow(HP_hwnd30, HP_hdc30, baseScreenWidth-HyperPause_SubMenu_Width, baseScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
        }
    }
    gosub, DrawSubMenu  
    DirectionCommandRunning := false  
Return

MoveDown:
    If DirectionCommandRunning
        Return   
    DirectionCommandRunning := true
    If (SelectedMenuOption="Shutdown"){
        DirectionCommandRunning := false   
        Return
    }
    If((FullScreenView = 1) and (ZoomLevel <> 100)){
        VerticalPanFullScreen := VerticalPanFullScreen-HyperPause_SubMenu_FullScreenPanSteps     
        gosub, DrawSubMenu
        DirectionCommandRunning := false   
        Return
    }
    Previous_VSubMenuItem := VSubMenuItem
    If((SelectedMenuOption="Controller") and (VSubMenuItem = -1) and (FullScreenView=1)){
        VSubMenuItem := VSubMenuItem-1
        if (HSubMenuItem=2) {
            V3SubMenuItem := V3SubMenuItem+1
        } else {
            V2SubMenuItem := V2SubMenuItem+1
			If  V2SubMenuItem < 1 
				V2SubMenuItem = 18
			If  V2SubMenuItem > 18
				V2SubMenuItem = 1
        }
    }
    VSubMenuItem := VSubMenuItem+1
    If((SelectedMenuOption="Statistics")and(HSubMenuItem>1)){
        VSubMenuItem := VSubMenuItem-1
        V2SubMenuItem := V2SubMenuItem+1
    }
    If((SelectedMenuOption="MovesList")and(HSubMenuItem>1)){
        VSubMenuItem := VSubMenuItem-1
        V2SubMenuItem := V2SubMenuItem+1
        If  V2SubMenuItem < 1 
            V2SubMenuItem = % TotalMovesListPages
        If  V2SubMenuItem > % TotalMovesListPages
            V2SubMenuItem = 1
    }
    If(((SelectedMenuOption="Guides") or (SelectedMenuOption="Manuals") or (SelectedMenuOption="History") or (SelectedMenuOption="Controller") or (SelectedMenuOption="Artwork"))and (HSubMenuItem>1) and (VSubMenuItem>=0)){
        If((CurrentFileExtension <> "pdf") and (!(HPMediaObj[SelectedMenuOption][CurrentLabelName].Type="ImageGroup")) and (CurrentCompressedFileExtension<> "true")){
            VSubMenuItem := VSubMenuItem-1
        }
        If(CurrentFileExtension ="txt")
        {   if (TotaltxtPages>1)
            {   V2SubMenuItem := V2SubMenuItem+1
                If  V2SubMenuItem < 1 
                    V2SubMenuItem = % TotaltxtPages
                If  V2SubMenuItem > % TotaltxtPages
                    V2SubMenuItem = 1
            } else
                VSubMenuItem := VSubMenuItem+1
        }
        If (VSubMenuItem>=0)
            HSubmenuitem%SelectedMenuOption%V2Submenuitem%VSubmenuitem% = % V2SubMenuItem
    }
    If((SelectedMenuOption="Videos") and (HSubMenuItem>1)){
        VSubMenuItem := VSubMenuItem-1
        V2SubMenuItem := V2SubMenuItem+1
        If  V2SubMenuItem < 1 
            V2SubMenuItem = 5
        If  V2SubMenuItem > 5
            V2SubMenuItem = 1
            HSubmenuitem%SelectedMenuOption%V2Submenuitem%VSubmenuitem% = % V2SubMenuItem
    }
    
    Gosub SubMenuSwap
    If((Previous_VSubMenuItem = 0) or (VSubMenuItem = 0)){
        HSubMenuItem=1
         Gdip_GraphicsClear(HP_G25)
        Gosub DrawMainMenuBar
        Alt_UpdateLayeredWindow(HP_hwnd25, HP_hdc25,0,round((baseScreenHeight-HyperPause_MainMenu_BarHeight)/2)+HyperPause_MainMenu_BarVerticalOffset, baseScreenWidth, HyperPause_MainMenu_BarHeight)
        Log("Loaded Main Menu Bar. Current Main Menu Label: " HyperPause_MainMenuSelectedLabel,1)
    }
    If (SelectedMenuOption="Sound"){
        If (VSubMenuItem = 3){
            currentPlayindex := HSubmenuitemSoundVSubmenuitem3            
        } Else {
            PreviousCurrentMusicButton = 
            Gdip_GraphicsClear(HP_G30)
            Alt_UpdateLayeredWindow(HP_hwnd30, HP_hdc30, baseScreenWidth-HyperPause_SubMenu_Width, baseScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
        }
    }
    If (SelectedMenuOption="Videos"){
        If (HSubMenuItem <> 2){
            Gdip_GraphicsClear(HP_G30)
            Alt_UpdateLayeredWindow(HP_hwnd30, HP_hdc30, baseScreenWidth-HyperPause_SubMenu_Width, baseScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
        }
    }
    gosub, DrawSubMenu  
    DirectionCommandRunning := false   
Return


BacktoMenuBar:
    If (SelectedMenuOption = "Shutdown")
        Return
    If ((SelectedMenuOption="Controller") and (VSubMenuItem = -1))
        settimer, CheckJoyPresses, off
    VSubMenuItem := 0
    HSubMenuItem=1
    Gdip_GraphicsClear(HP_G30)
    Alt_UpdateLayeredWindow(HP_hwnd30, HP_hdc30, baseScreenWidth-HyperPause_SubMenu_Width, baseScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
    If(FullScreenView = 1){
        Gdip_GraphicsClear(HP_G29)
        Alt_UpdateLayeredWindow(HP_hwnd29, HP_hdc29,0,0,baseScreenWidth,baseScreenHeight) 
        Gdip_GraphicsClear(HP_G33)
        Alt_UpdateLayeredWindow(HP_hwnd33, HP_hdc33,0,0,baseScreenWidth,baseScreenHeight) 
        FullScreenView = 0   
    }
    If (SelectedMenuOption:="Video"){
        AnteriorFilePath:=
        V2Submenuitem := 1
        HSubMenuItem := 1
        try CurrentVideoPlayStatus := wmpVideo.playState
        If(CurrentVideoPlayStatus=3) {
            try VideoPosition%videoplayingindex% := wmpVideo.controls.currentPosition
            Log("VideoPosition at back to main menu:" "VideoPosition"videoplayingindex " " VideoPosition%videoplayingindex%,5)
            try wmpVideo.controls.stop
        }
        Gui,HP_GUI31: Show, Hide
        Gui, HP_GUI32: Show
    }
    gosub, DrawSubMenu 
    Gdip_GraphicsClear(HP_G25)
    Gosub DrawMainMenuBar
    Alt_UpdateLayeredWindow(HP_hwnd25, HP_hdc25,0,round((baseScreenHeight-HyperPause_MainMenu_BarHeight)/2)+HyperPause_MainMenu_BarVerticalOffset, baseScreenWidth, HyperPause_MainMenu_BarHeight)
    Log("Loaded Main Menu Bar. Current Main Menu Label: " HyperPause_MainMenuSelectedLabel,1)
Return


MainMenuSwap:
    MenuChanged = 1
    VSubMenuItem = 0
    HSubMenuItem = 1
    FullScreenView = 0
    If !submenuMouseClickChange
        SoundPlay %HyperPause_MenuSoundPath%hpmenu.wav
    Else
        submenuMouseClickChange =
    If  HyperPause_MainMenuItem = 0 
        HyperPause_MainMenuItem = %TotalMainMenuItems%
    If  HyperPause_MainMenuItem = % TotalMainMenuItems+1
        HyperPause_MainMenuItem = 1
    Loop, parse, HyperPause_MainMenu_Labels,|
    {
        If (HyperPause_MainMenuItem = a_Index) { 
            StringReplace, SelectedMenuOption, A_LoopField, %A_SPACE%,, All
        }
    }
Return


SubMenuSwap:
    If((SelectedMenuOption="SaveState")or(SelectedMenuOption="LoadState")or(SelectedMenuOption="HighScore")){
        If  VSubMenuItem < 0 
            VSubMenuItem = % HPMediaObj[SelectedMenuOption].TotalLabels
        If  VSubMenuItem > % HPMediaObj[SelectedMenuOption].TotalLabels
            VSubMenuItem = 0
    }
    If(SelectedMenuOption="ChangeDisc"){
        If  HSubMenuItem < 1 
            HSubMenuItem = % HPMediaObj[SelectedMenuOption].TotalLabels
        If  HSubMenuItem > % HPMediaObj[SelectedMenuOption].TotalLabels
            HSubMenuItem = 1  
        If  VSubMenuItem < 0 
            VSubMenuItem = 1
        If  VSubMenuItem > 1
            VSubMenuItem = 0
    }
    If(SelectedMenuOption="Sound"){
        currentObj := {}
        currentObj["TotalLabels"] := 2
        TotalVSubMenuItem2SoundItems := 1
        If(HyperPause_CurrentPlaylist<>""){
            currentObj["TotalLabels"] := 3
            TotalVSubMenuItem2SoundItems := 3
        }
        HPMediaObj.Insert("Sound", currentObj) 
        If  VSubMenuItem < 0 
            VSubMenuItem = % HPMediaObj[SelectedMenuOption].TotalLabels
        If  VSubMenuItem > % HPMediaObj[SelectedMenuOption].TotalLabels
            VSubMenuItem = 0
        If(VSubMenuItem=2){
            If  HSubMenuItem < 1 
                HSubMenuItem = % TotalVSubMenuItem2SoundItems
            If  HSubMenuItem > % TotalVSubMenuItem2SoundItems
                HSubMenuItem = 1
        }
    }
    If(SelectedMenuOption="Settings"){
        if ((found7z="true") and (7zEnabled = "true"))
            maxItems := 2
        else
            maxItems := 1
        If  VSubMenuItem < 0 
            VSubMenuItem = % maxItems
        If  VSubMenuItem > % maxItems
            VSubMenuItem = 0
    }
    If(SelectedMenuOption="MovesList"){
        If  HSubMenuItem < 1 
            HSubMenuItem = 2
        If  HSubMenuItem > 2
            HSubMenuItem = 1  
        If  VSubMenuItem < 0 
            VSubMenuItem = % HPMediaObj[SelectedMenuOption].TotalLabels
        If  VSubMenuItem > % HPMediaObj[SelectedMenuOption].TotalLabels
            VSubMenuItem = 0
        If  V2SubMenuItem < 1 
            V2SubMenuItem = % TotalMovesListPages
        If  V2SubMenuItem > % TotalMovesListPages
            V2SubMenuItem = 1
    }
    If(SelectedMenuOption="Statistics"){
        If  HSubMenuItem < 1 
            HSubMenuItem = 2
        If  HSubMenuItem > 2
            HSubMenuItem = 1  
        If  VSubMenuItem < 0 
            VSubMenuItem = % StatisticsLabelCount
        If  VSubMenuItem > % StatisticsLabelCount
            VSubMenuItem = 0
        If  V2SubMenuItem < 1 
            V2SubMenuItem = % StatisticsTablecount
        If  V2SubMenuItem > % StatisticsTablecount
            V2SubMenuItem = 1
    }    
    If((SelectedMenuOption="Guides")or(SelectedMenuOption="Artwork")or(SelectedMenuOption="History")or(SelectedMenuOption="Manuals")){
        If  HSubMenuItem < 0
            HSubMenuItem = 1
        If  HSubMenuItem > % TotalCurrentPages
            HSubMenuItem = 1 
        If  VSubMenuItem < 0
            VSubMenuItem = % HPMediaObj[SelectedMenuOption].TotalLabels
        If  VSubMenuItem > % HPMediaObj[SelectedMenuOption].TotalLabels
            VSubMenuItem = 0
    }
    If(SelectedMenuOption="Controller"){
        If((SelectedMenuOption="Controller") and (VSubMenuItem = -1) and (FullScreenView=1)){
            If  HSubMenuItem < 0
                HSubMenuItem = 2
            If  HSubMenuItem > 2
                HSubMenuItem = 1 
        } else {
            If  HSubMenuItem < 0
                HSubMenuItem = 1
            If  HSubMenuItem > % TotalCurrentPages
                HSubMenuItem = 1 
        }
        If (keymapperEnabled = "true") {
            If  VSubMenuItem < -1
                VSubMenuItem = % HPMediaObj[SelectedMenuOption].TotalLabels
            If  VSubMenuItem > % HPMediaObj[SelectedMenuOption].TotalLabels
                VSubMenuItem = -1
        } Else {
            If  VSubMenuItem < 0
                VSubMenuItem = % HPMediaObj[SelectedMenuOption].TotalLabels
            If  VSubMenuItem > % HPMediaObj[SelectedMenuOption].TotalLabels
                VSubMenuItem = 0            
        }
    }    
    If(SelectedMenuOption="Videos"){
        If  VSubMenuItem < 0
            VSubMenuItem = % HPMediaObj[SelectedMenuOption].TotalLabels
        If  VSubMenuItem > % HPMediaObj[SelectedMenuOption].TotalLabels
            VSubMenuItem = 0
        
        If  HSubMenuItem < 1
            HSubMenuItem = 2
        If  HSubMenuItem > 2
            HSubMenuItem = 1         
        
    }
    If(VSubMenuItem=0){
        If not(SelectedMenuOption="Sound"){
            Gdip_GraphicsClear(HP_G29)
            Alt_UpdateLayeredWindow(HP_hwnd29, HP_hdc29,0,0,baseScreenWidth,baseScreenHeight) 
            Gdip_GraphicsClear(HP_G33)
            Alt_UpdateLayeredWindow(HP_hwnd33, HP_hdc33,0,0,baseScreenWidth,baseScreenHeight) 
        }
        FullScreenView = 0  
    }
Return


ToggleItemSelectStatus:
    If (SelectedMenuOption = "Shutdown") {
        If !(hlMode = "hp")
            close_emulator := true
        gosub, ExitHyperPause
    }
    If(SelectedMenuOption="LoadState"){ 
        If SlotEmpty
            Return
        ItemSelected=1
        gosub, ExitHyperPause
    }
    If(SelectedMenuOption="SaveState"){ 
        ItemSelected=1
        gosub, ExitHyperPause
    }
    If(SelectedMenuOption="ChangeDisc"){
        gosub, DisableKeys
        SetTimer, UpdateDescription, off
        SetTimer, DiscChangeUpdate, off
        ItemSelected=1
        selectedRom:=romTable[HSubMenuItem,1]	; need to convert this for the next line to work
        selectedRomNum:=romTable[HSubMenuItem,5]	; Store selected rom's Media and number
        Log("SelectGame - User selected to load: " . selectedRom,4)
        SplitPath, selectedRom,,HyperPause_RomPath,HyperPause_RomExt,HyperPause_DbName
        HyperPause_RomExt := "." . HyperPause_RomExt	; need to add the period back in otherwise ByRef on the 7z call doesn't work
        ;creating Disc Changing Screen
        Loop, 9 {
            If not (A_Index=8) {
                CurrentGUI := A_Index+23
                Gdip_GraphicsClear(HP_G%CurrentGUI%)
                Alt_UpdateLayeredWindow(HP_hwnd%CurrentGUI%, HP_hdc%CurrentGUI%, 0, 0, baseScreenWidth, baseScreenHeight)
            }
        }
        pGraphUpd(HP_G24,baseScreenWidth,baseScreenHeight)
        DiscChangeTextWidth := MeasureText("Changing Disc", "Left r4 s" . HyperPause_MainMenu_LabelFontsize . " bold",HyperPause_MainMenu_LabelFont)        
        Gdip_Alt_FillRoundedRectangle(HP_G24, BlackGradientBrush, (baseScreenWidth-DiscChangeTextWidth)//2-HyperPause_ChangingDisc_Margin//2, (baseScreenHeight-HyperPause_MainMenu_LabelFontsize)//2-HyperPause_ChangingDisc_Margin//2, DiscChangeTextWidth+HyperPause_ChangingDisc_Margin, HyperPause_MainMenu_LabelFontsize+HyperPause_ChangingDisc_Margin,HyperPause_ChangingDisc_Rounded_Corner)
        Gdip_Alt_TextToGraphics(HP_G24, "Changing Disc", "x" . (baseScreenWidth-DiscChangeTextWidth)//2 . "y" . (baseScreenHeight-HyperPause_MainMenu_LabelFontsize)//2 . "Centre c" . HyperPause_MainMenu_LabelSelectedColor . "r4 s" . HyperPause_MainMenu_LabelFontsize . " bold", HyperPause_MainMenu_LabelFont)	
        Alt_UpdateLayeredWindow(HP_hwnd24, HP_hdc24, 0, 0, baseScreenWidth, baseScreenHeight)
        If 7zEnabled = true	; Only need to continue If 7z support is turned on, this check is in case emu supports loading of compressed roms. No need to decompress our rom If it does
            {	
            If HyperPause_RomExt in %7zFormats%	; Check If our selected rom is compressed.
                {	
                Log("SelectGame - This game needs 7z to load. Sending it off for extraction: " . HyperPause_RomPath . "\" . HyperPause_DbName . HyperPause_RomExt,4)
                7z%HSubMenuItem% := 7z(HyperPause_RomPath, HyperPause_DbName, HyperPause_RomExt, 7zExtractPath, "hp")	; Send chosen game to 7z for processing. We get back the same vars but updated to the new location.
                selectedRom := HyperPause_RomPath . "\" . HyperPause_DbName . HyperPause_RomExt
                Log("SelectGame - Returned from 7z extraction, path to new rom is: " . selectedRom,4)
                romTable[HSubMenuItem,19] := HyperPause_RomPath	; storing path to extracted rom in column 19 so 7zCleanUp knows to delete it later
                Log("SelectGame - Stored """ . HyperPause_RomPath . """ for deletion in 7zCleanup.",4)
            } Else {
                Log("SelectGame - This game does not need 7z. Sending it directly to the emu or to Daemon Tools If required.",4)
            }
            Log("SelectGame - Ended")
        }
        Gosub, ExitHyperPause
    }
    If(( (SelectedMenuOption="Guides") or (SelectedMenuOption="Manuals") or (SelectedMenuOption="History") or (SelectedMenuOption="Controller") or (SelectedMenuOption="Artwork") or (SelectedMenuOption="Statistics") or (SelectedMenuOption="MovesList") or (SelectedMenuOption="HighScore")) and (VSubMenuItem > 0)){
        If(FullScreenView = 1){
            If(SelectedMenuOption="MovesList"){
                AdjustedPage := % (((V2SubMenuItem-1)*(HPMediaObj[SelectedMenuOption].txtFSLines))/HPMediaObj[SelectedMenuOption].txtLines)+1
                V2SubMenuItem := Floor(AdjustedPage)
            }
            If(((SelectedMenuOption="Manuals") and (CurrentFileExtension = "txt")) or ((SelectedMenuOption="Guides") and (CurrentFileExtension = "txt")) or ((SelectedMenuOption="History") and (CurrentFileExtension = "txt"))){
                AdjustedPage := % (((V2SubMenuItem-1)*(HPMediaObj[SelectedMenuOption].txtFSLines))/HPMediaObj[SelectedMenuOption].txtLines)+1
                V2SubMenuItem := Floor(AdjustedPage)
                HSubmenuitem%SelectedMenuOption%V2Submenuitem%VSubmenuitem% = % V2SubMenuItem
            }
            SetTimer, ClearFullScreenHelpText1, off
            SetTimer, ClearFullScreenHelpText2, off
            Gdip_GraphicsClear(HP_G29)
            Alt_UpdateLayeredWindow(HP_hwnd29, HP_hdc29,0,0,baseScreenWidth,baseScreenHeight)    
            FullScreenView = 0
            gosub, DrawSubMenu
        } Else {
            If ((CurrentFileExtension = "txt") and (HSubMenuItem=1)) 
                HSubmenuitem%SelectedMenuOption%VSubmenuitem%VSubmenuitem% := 2
            If(SelectedMenuOption="MovesList"){
                if (HSubMenuItem=1)
                    HSubMenuItem=2
                AdjustedPage := % (((V2SubMenuItem-1)*(HPMediaObj[SelectedMenuOption].txtLines))/HPMediaObj[SelectedMenuOption].txtFSLines)+1
                V2SubMenuItem := Floor(AdjustedPage)
            }
            If(((SelectedMenuOption="Manuals") and (CurrentFileExtension = "txt")) or ((SelectedMenuOption="Guides") and (CurrentFileExtension = "txt")) or ((SelectedMenuOption="History") and (CurrentFileExtension = "txt"))){
                AdjustedPage := % (((V2SubMenuItem-1)*(HPMediaObj[SelectedMenuOption].txtLines))/HPMediaObj[SelectedMenuOption].txtFSLines)+1
                V2SubMenuItem := Floor(AdjustedPage)
                HSubmenuitem%SelectedMenuOption%V2Submenuitem%VSubmenuitem% = % V2SubMenuItem
            }                
            FullScreenView = 1
            ZoomLevel := 100
            gosub, DrawSubMenu
        }
    } 
    If ((SelectedMenuOption="Controller") and (VSubMenuItem = -1)){
        If(FullScreenView = 1) {
            If (V2SubMenuItem = 1){
                Gdip_GraphicsClear(HP_G29)
                Alt_UpdateLayeredWindow(HP_hwnd29, HP_hdc29,0,0,baseScreenWidth,baseScreenHeight)   
                FullScreenView=0
                settimer, CheckJoyPresses, off
            } Else If(V2SubMenuItem = 2){
                LoadPreferredControllers%zz%(JoyIDsPreferredControllers)
                RunKeymapper%zz%("menu",keymapper)
                Loop, 10 { ;Activating HyperPause Screen
                    CurrentGUI := A_Index+21
                    WinActivate, hpLayer%CurrentGUI%
                }
                gosub, DrawSubMenu 
            } Else If(V2SubMenuItem > 2){
                If (HSubMenuItem = 2) {
                    currentSelectedJoy := V2SubMenuItem-2
                    currentSelectedProfileNumber := V3SubMenuItem
					KeymapperProfileChangeInHyperPause = 1
                    if !selectedProfile
                        selectedProfile := []
					If (keymapper = "xpadder") {
						selectedProfile[V2SubMenuItem-2,1] := V3SubMenuItem
						selectedProfile[V2SubMenuItem-2,2] := possibleProfilesList[V3SubMenuItem,4] ;store for later use with xpadder and joytokey run functions
					} else if (keymapper="joy2key") OR (keymapper = "joytokey") {
						Loop, 16
						{
							selectedProfile[A_Index,1] := V3SubMenuItem
							selectedProfile[A_Index,2] := possibleProfilesList[V3SubMenuItem,4] ;store for later use with xpadder and joytokey run functions
						}
					}
                    currentSelectedProfileFileName := possibleProfilesList[V3SubMenuItem,1] ;FileName
                    currentSelectedProfileFolderType := possibleProfilesList[V3SubMenuItem,2] ;FolderType
                    currentSelectedProfileControllerSpecificBoolean := possibleProfilesList[V3SubMenuItem,3] ;Controller_specific_Boolean
                    currentSelectedProfileFilePath := possibleProfilesList[V3SubMenuItem,4] ;FilePath
                    HSubMenuItem = 1
                    gosub, DrawSubMenu 
                } else {
                    If (JoyIDsEnabled = "true") {
                        If SelectedController 
                            {
                            Mid1 := joyConnectedInfo[SelectedController,3]
                            Pid1 := joyConnectedInfo[SelectedController,4]
                            Guid1 := joyConnectedInfo[SelectedController,5]
                            ChangeJoystickID%zz%(Mid1,Pid1,GUID1,V2SubMenuItem-2)
                            Mid2 := joyConnectedInfo[V2SubMenuItem-2,3]
                            Pid2 := joyConnectedInfo[V2SubMenuItem-2,4]
                            Guid2 := joyConnectedInfo[V2SubMenuItem-2,5]
                            ChangeJoystickID%zz%(Mid2,Pid2,GUID2,SelectedController)
                            RunKeymapper%zz%("menu",keymapper)
                            SelectedController := ""
                            Loop, 10 { ;Activating HyperPause Screen
                                CurrentGUI := A_Index+21
                                WinActivate, hpLayer%CurrentGUI%
                            }
                            gosub, DrawSubMenu 
                        } Else {
                            SelectedController := V2SubMenuItem-2
                            gosub, DrawSubMenu 
                        }
                    } Else {
                        tooltip, Enable JoyIDs to be able to change the controller order 
                        settimer,EndofToolTipDelay, -2000   
                    }
                }
            }
        } Else {
            gosub, CheckConnectedJoys
            Loop, 16
                {
                If (joyConnectedInfo[A_Index,1]) {
                   joyConnectedExist := true
                   break
                }
            }
            If joyConnectedExist
                {
                FullScreenView=1
                gosub, DrawSubMenu 
                settimer, CheckJoyPresses, 50
            } Else {
                CoordMode, ToolTip, Screen
                tooltip, You need at least one connected controller to use this menu!, baseScreenWidth//2, baseScreenHeight//2
                setTimer, EndofToolTipDelay, -1000
            }
            joyConnectedExist := ""
        }
    }
    If(SelectedMenuOption="Sound"){
        If(VSubMenuItem=2){
            If(HSubmenuitemSoundVSubmenuitem2=1){
                getMute(CurrentMuteStatus)
                If(CurrentMuteStatus=1)
                    setMute(0)
                Else
                    setMute(1)
            } Else If(HSubmenuitemSoundVSubmenuitem2=2){
                If(HyperPause_KeepPlayingAfterExitingHyperPause="false")
                    HyperPause_KeepPlayingAfterExitingHyperPause:="true"
                Else
                    HyperPause_KeepPlayingAfterExitingHyperPause:="false"
            } Else {
                If(HyperPause_EnableShuffle="false") {
                    HyperPause_EnableShuffle:="true"
                    try wmpMusic.Settings.setMode("shuffle",true)
                } Else {
                    HyperPause_EnableShuffle:="false"
                    try wmpMusic.Settings.setMode("shuffle",false)
                }
            }
            gosub, DrawSubMenu
        }
        If(VSubMenuItem=3){
            If(CurrentMusicButton=1)
                try wmpMusic.controls.stop   
            If(CurrentMusicButton=2)               
                try wmpMusic.controls.previous
            If(CurrentMusicButton=3) {
                try CurrentMusicPlayStatus := wmpMusic.playState
                If (CurrentMusicPlayStatus = 3)
                    try wmpMusic.controls.pause   
                Else
                    try wmpMusic.controls.play 
                gosub, DrawSubMenu
            }
            If(CurrentMusicButton=4)            
                try wmpMusic.controls.next            
        }
    }
    If(SelectedMenuOption="Settings"){
        If(VSubMenuItem=1){
            if (currentLockLaunchIndex<4) {
                updatedIndex := currentLockLaunchIndex + 1
                currentLockLaunch := locklaunchValue%updatedIndex%
            } else 
                currentLockLaunch := locklaunchValue1
            gosub, DrawSubMenu
        }If(VSubMenuItem=2){
            If (current7zDelTemp = "true")
                current7zDelTemp := "false"
            Else
                current7zDelTemp := "true"
            gosub, DrawSubMenu
        }
    }
    If((SelectedMenuOption="Videos")and (VSubMenuItem > 0)){
        If((VSubMenuItem > 0)){
            If(FullScreenView = 1){
                If(HyperPause_Active=true)
                    gosub, EnableKeys
                Gdip_GraphicsClear(HP_G30)
                Alt_UpdateLayeredWindow(HP_hwnd30, HP_hdc30, baseScreenWidth-HyperPause_SubMenu_Width, baseScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
                try wmpvideo.fullScreen := false
                FullScreenView = 0
            } Else if (HSubMenuItem=1) {
                    If(HyperPause_Active=true)
                        gosub, DisableKeys 
                    XHotKeywrapper(navSelectKey,"ToggleItemSelectStatus","ON")
                    XHotKeywrapper(navP2SelectKey,"ToggleItemSelectStatus","ON") 
                    try wmpvideo.fullScreen := true
                    FullScreenView = 1 
            } Else {
                try CurrentVideoPlayStatus := wmpVideo.playState
                If(V2SubMenuItem=1)
                    If(CurrentVideoPlayStatus=3)                
                        try wmpVideo.controls.pause 
                    Else
                        try wmpVideo.controls.play 
                If(V2SubMenuItem=2) {               
                    If(HyperPause_Active=true)
                        gosub, DisableKeys 
                    XHotKeywrapper(navSelectKey,"ToggleItemSelectStatus","ON")
                    XHotKeywrapper(navP2SelectKey,"ToggleItemSelectStatus","ON") 
                    try wmpvideo.fullScreen := true
                    FullScreenView = 1 
                }
                If(V2SubMenuItem=3) {  
                    SaveActualStateHSubmenuitem := HSubmenuitem
                    SaveActualStateVSubmenuitem := VSubmenuitem
                    SaveActualStateV2Submenuitem := V2Submenuitem
                    FFRWtimeractualstate := (FFRWtimeractualstate=true)?false:true  
                    If FFRWtimeractualstate {
                        settimer, RewindTimer, 100, Period
                    } Else {
                        AcumulatedRewindFastForwardJumpSeconds = 0
                        settimer, RewindTimer, off
                    }
                }                    
                If(V2SubMenuItem=4) { 
                    SaveActualStateHSubmenuitem := HSubmenuitem
                    SaveActualStateVSubmenuitem := VSubmenuitem
                    SaveActualStateV2Submenuitem := V2Submenuitem
                    FFRWtimeractualstate := (FFRWtimeractualstate=true)?false:true  
                    If FFRWtimeractualstate {
                        settimer, FastForwardTimer, 100, Period
                    } Else {
                        AcumulatedRewindFastForwardJumpSeconds = 0
                        settimer, FastForwardTimer, off
                    }
                } 
                If(V2SubMenuItem=5) {               
                    try wmpVideo.controls.stop
                    VideoPosition%videoplayingindex% := 0
                }
            }
            gosub, DrawSubMenu
        }
    } 
    If(HyperPause_EnableMouseControl = "true") {
        If (FullScreenView = 1) {
            Gdip_GraphicsClear(HP_G32)
            Gdip_Alt_DrawImage(HP_G32, MouseFullScreenOverlayBitmap, 0, 0, MouseOverlayW, MouseOverlayH)
            Alt_UpdateLayeredWindow(HP_hwnd32, HP_hdc32,0,baseScreenHeight-MouseOverlayH, MouseOverlayW, MouseOverlayH,HyperPause_MouseControlTransparency)        
        } Else {
            Gdip_GraphicsClear(HP_G32)
            Gdip_Alt_DrawImage(HP_G32, MouseOverlayBitmap, 0, 0, MouseOverlayW, MouseOverlayH)
            Alt_UpdateLayeredWindow(HP_hwnd32, HP_hdc32,0,baseScreenHeight-MouseOverlayH, MouseOverlayW, MouseOverlayH,HyperPause_MouseControlTransparency)        
        }
    }
Return

RewindTimer:
FastForwardTimer:
    If ((SaveActualStateHSubmenuitem = HSubmenuitem) and (SaveActualStateVSubmenuitem = VSubmenuitem) and (SaveActualStateV2Submenuitem = V2Submenuitem)) {
        AcumulatedRewindFastForwardJumpSeconds += HyperPause_SubMenu_VideoRewindFastForwardJumpSeconds
        If (AcumulatedRewindFastForwardJumpSeconds<60) {
            Secondstojump = 1
        } Else If (AcumulatedRewindFastForwardJumpSeconds<180) {
            Secondstojump = 2
        } Else If (AcumulatedRewindFastForwardJumpSeconds<360) {
            Secondstojump = 3
        } Else If (AcumulatedRewindFastForwardJumpSeconds<600) {
            Secondstojump = 4
        } Else {
            Secondstojump := HyperPause_SubMenu_VideoRewindFastForwardJumpSeconds
        }
        Secondstojump += 0
        try wmpVideo.Controls.CurrentPosition += (A_ThisLabel="RewindTimer"? -Secondstojump:Secondstojump)
        FFRWtimeractualstate := true
    } Else {
        FFRWtimeractualstate := false
        AcumulatedRewindFastForwardJumpSeconds = 0
        settimer, FastForwardTimer, off
        settimer, RewindTimer, off
    }
Return

TogglePauseMenuStatus:
    If !(HyperPause_Running){
        gosub, HyperPause_Main
    } Else {
        If(HyperPause_Active){
            If ((disableActivateBlackScreen) and (HyperPause_Disable_Menu="true")) or (ErrorExit) {
                gosub, SimplifiedExitHyperPause
            } Else {
                gosub, ExitHyperPause
            }
        }
    }
Return

ZoomIn:
    If((FullScreenView = 1) and !(CurrentFileExtension = "txt")){
        ZoomLevel := ZoomLevel+HyperPause_SubMenu_FullScreenZoomSteps
        gosub, DrawSubMenu
    }
Return

ZoomOut:
    If((FullScreenView = 1) and !(CurrentFileExtension = "txt")){
        If(ZoomLevel>100+HyperPause_SubMenu_FullScreenZoomSteps){
            ZoomLevel := ZoomLevel-HyperPause_SubMenu_FullScreenZoomSteps
        } Else {
            HorizontalPanFullScreen := 0
            VerticalPanFullScreen := 0
            ZoomLevel := 100
        }
        gosub, DrawSubMenu
    }
Return


;-----------------EXIT HYPERPAUSE------------
ExitHyperPause:
    If(FunctionRunning=true){
        Return   
    }
    if initialLockLaunch
     if !(initialLockLaunch=currentLockLaunch)
        IniWrite, %currentLockLaunch%, % A_ScriptDir . "\Settings\" . systemName . "\Game Options.ini", %dbName%, Lock_Launch
    if !(7zDelTemp=current7zDelTemp)
        IniWrite, %current7zDelTemp%, % A_ScriptDir . "\Settings\" . systemName . "\Game Options.ini", %dbName%, 7z_Delete_Temp
    Log("Closing HyperPause",1)
    gosub, DisableKeys
    Log("Disabled Keys while exiting",5)    
    HyperPause_Active:=false
    If not(HyperPause_MuteSound="true"){ 
        If(HyperPause_MuteWhenLoading="true"){ ;Mute when exiting HyperPause to avoiding sound stuttering
            getMute(HyperPauseInitialMuteState,emulatorVolumeObject)
            If !(HyperPauseInitialMuteState){
                setMute(1,emulatorVolumeObject)
                Log("Muting computer sound while HP is loaded. Master Mute status: " getMute(,emulatorVolumeObject) " (1 is mutted)",5)            
            }
        }
    }    
    settimer, UpdateMusicPlayingInfo, off
    settimer, UpdateVideoPlayingInfo, off
    try CurrentMusicPlayStatus := wmpMusic.playState
    If(HyperPause_KeepPlayingAfterExitingHyperPause="false"){
        If(CurrentMusicPlayStatus=3){
            try wmpMusic.controls.pause
            Log("Pausing music",5)
        }
    }
    If (SelectedMenuOption="Videos") {
        try VideoPosition%videoplayingindex% := wmpVideo.controls.currentPosition
        Log("VideoPosition at hyperpause exit:" "VideoPosition"videoplayingindex " " VideoPosition%videoplayingindex%,5) 
        try wmpVideo.controls.stop
        try wmpVideo.close
    }
    If !disableLoadScreen {
        Gdip_GraphicsClear(HP_G21)
        If(HyperPause_MainMenu_GlobalBackground ="true"){
            Gdip_Alt_FillRectangle(HP_G21, HyperPause_Load_Background_Brush, -1, -1, baseScreenWidth+1, baseScreenHeight+1)
            Gdip_Alt_TextToGraphics(HP_G21, HyperPause_AuxiliarScreen_ExitText, OptionsLoadHP, HyperPause_AuxiliarScreen_Font, 0, 0)
        }
        Alt_UpdateLayeredWindow(HP_hwnd21, HP_hdc21, 0, 0, baseScreenWidth, baseScreenHeight)
    }
    Log("Disabling timers",5)
    SetTimer, UpdateDescription, off
    SetTimer, SubMenuUpdate, off
    SetTimer, DiscChangeUpdate, off
    SetTimer, Clock, off
    If romTable.MaxIndex() { ; Resetting romtable changes made by HP If the game is a multiple dics game
        for index, element in romTable
            {
            current := A_Index
            Loop, 19 
                {
                If (A_Index > 6 && A_Index != 19)	; do not wipe column 19 which has 7zCleanup data

                    romTable[current, A_Index] := ""
            }
        }
    }
    if HyperPause_ChangeRes
        ChangeDisplaySettings(HyperPause_ScreenResToBeRestoredArray1,HyperPause_ScreenResToBeRestoredArray2,HyperPause_ScreenResToBeRestoredArray3,HyperPause_ScreenResToBeRestoredArray4)
    If !disableLoadScreen
        If !disableActivateBlackScreen
            WinActivate, HyperPauseBlackScreen
    Loop, 12
        {
		If not (A_Index=10) {
            CurrentGUI := A_Index+21
            SelectObject(HP_hdc%CurrentGUI%, HP_obm%CurrentGUI%)
            DeleteObject(HP_hbm%CurrentGUI%)
            DeleteDC(HP_hdc%CurrentGUI%)
            Gdip_DeleteGraphics(HP_G%CurrentGUI%)
            Gui, HP_GUI%CurrentGUI%: Destroy
        }
    }
    If(HPMediaObj["Videos"].TotalLabels >0)
        Gui, HP_GUI31: Destroy
    Log("Guis destroyed",5)
    Gdip_DeleteBrush(BlackGradientBrush), Gdip_DeleteBrush(PBRUSH), Gdip_DeleteBrush(HyperPause_SubMenu_BackgroundBrushV), Gdip_DeleteBrush(HyperPause_SubMenu_SelectedBrushV), Gdip_DeleteBrush(HyperPause_SubMenu_DisabledBrushV), Gdip_DeleteBrush(HyperPause_BackgroundBrushV), Gdip_DeleteBrush(HyperPause_SubMenu_GuidesSelectedBrushV), Gdip_DeleteBrush(HyperPause_SubMenu_ManualsSelectedBrushV), Gdip_DeleteBrush(HyperPause_SubMenu_HistorySelectedBrushV), Gdip_DeleteBrush(HyperPause_SubMenu_ControllerSelectedBrushV), Gdip_DeleteBrush(HyperPause_SubMenu_ArtworkSelectedBrushV),Gdip_DeleteBrush(HyperPause_SubMenu_FullScreenTextBrushV), Gdip_DeleteBrush(HyperPause_SubMenu_FullScreenBrushV), Gdip_DeleteBrush(HyperPause_7zProgress_BackgroundBrush), Gdip_DeleteBrush(HyperPause_7zProgress_BarBackBrush), Gdip_DeleteBrush(HyperPause_7zProgress_BarBrush) 
	Log("Brushes deleted",5)
    Gdip_DisposeImage(MainMenuBackgroundBitmap), Gdip_DisposeImage(LogoImageBitmap), Gdip_DisposeImage(PauseImageBitmap), Gdip_DisposeImage(SoundBitmap), Gdip_DisposeImage(MuteBitmap), Gdip_DisposeImage(ButtonToggleONBitmap), Gdip_DisposeImage(ButtonToggleOFFBitmap), Gdip_DisposeImage(CurrentBitmap), Gdip_DisposeImage(SelectedBitmap), Gdip_DisposeImage(pGameScreenshot), Gdip_DisposeImage(SaveStateBackgroundBitmap) 
    Loop, 5
        Gdip_DisposeImage(HyperPauseMusicBitmap%A_Index%)
    Loop, 6 
        Gdip_DisposeImage(HyperPauseVideoBitmap%A_Index%)
    Loop, %TotalCommandDatImageFiles% {
        Gdip_DisposeImage(CommandDatBitmap%A_index%)
    }
    If(HyperPause_EnableMouseControl = "true") {
        Gdip_DisposeImage(MouseFullScreenMaskBitmap), Gdip_DisposeImage(MouseFullScreenOverlayBitmap), Gdip_DisposeImage(MouseClickImageBitmap)
    }
    for index, element in romTable
        {
        Gdip_DisposeImage(romTable[A_Index, 17]), Gdip_DisposeImage(romTable[A_Index, 18])
    }      
    Log("Disposed images",5)
    If !(hlMode = "hp") 
        {
        If (keymapperEnabled = "true") {
            If (KeymapperProfileChangeInHyperPause = 1) {
                SplitPath, keymapperFullPath, keymapperExe, keymapperPath, keymapperExt
                If (keymapper = "xpadder") {
                    Loop, 16
                    {
                        ControllerName := joystickArray[A_Index,1]
                        If ControllerName {
                            If !ProfilesInIdOrder
                                ProfilesInIdOrder := selectedProfile[A_Index,2]
                            Else
                                ProfilesInIdOrder .= "|" . selectedProfile[A_Index,2]
                        }
                    }
                    RunXpadder%zz%(keymapperPath,keymapperExe,ProfilesInIdOrder,joystickArray)
                    ProfilesInIdOrder := "" 		;clear so this variable doesn't grow by duplication on 2nd or more closings of HyperPause
                } Else If (keymapper="joy2key") OR (keymapper = "joytokey") {
                    RunJoyToKey%zz%(keymapperPath,keymapperExe,selectedProfile[1,2])
                    }
            } Else If (keymapperHyperLaunchProfileEnabled = "true") {
                RunKeymapper%zz%("load",keymapper)
            }
            If !disableLoadScreen
                If !disableActivateBlackScreen
                    WinActivate, HyperPauseBlackScreen
        }
        If keymapperAHKMethod = External
            RunAHKKeymapper%zz%("load")
    }
	If !disableSuspendEmu  ;Unsuspending Emulator Process 
        {
        ProcRes(emulatorProcessName)
        Log("Emulator process started",5)
    }
    If !disableRestoreEmu  ;Restoring emulator
        {
        timeout := A_TickCount
        sleep, 200
        WinRestore, ahk_ID %emulatorID%
        IfWinNotActive, ahk_class %EmulatorClass%,,%frontendWinTitle% ahk_class %frontendWinClass%
            {
            Loop{
                sleep, 200
                WinRestore, ahk_ID %emulatorID%
                sleep, 200
                WinActivate, ahk_class %EmulatorClass%,,%frontendWinTitle% ahk_class %frontendWinClass%
                IfWinActive, ahk_class %EmulatorClass%,,%frontendWinTitle% ahk_class %frontendWinClass%
                    {
                    break
                    }
            If(timeout<A_TickCount-3000)
                    break
            sleep, 200
            }
            Log("Emulator screen reactivated",5)
        }
    }
    gosub, RestoreEmu
    Log("Loaded emulator specific module restore commands",5)
    HyperPause_EndTime := A_TickCount
    Log("Setting HP starting end for subtracting from statistics played time: " HyperPause_EndTime,5)
    TotalElapsedTimeinPause :=  If TotalElapsedTimeinPause ? TotalElapsedTimeinPause + (HyperPause_EndTime-HyperPause_BeginTime)//1000 : (HyperPause_EndTime-HyperPause_BeginTime)//1000
    If !disableLoadScreen {
        If ( !((ItemSelected=1) and (SelectedMenuOption="ChangeDisc")) or ((ItemSelected=1) and (SelectedMenuOption="ChangeDisc") and !(forceMGGuiDestroy)) ) {
            SelectObject(HP_hdc21, HP_obm21)
            DeleteObject(HP_hbm21)
            DeleteDC(HP_hdc21)
            Gdip_DeleteGraphics(HP_G21)
            Gui, HP_GUI21: Destroy  
        }
    }
    Log("Black Screen Gui destroyed",5)
    If !(hlMode = "hp") { 
        XHotKeywrapper(exitEmulatorKey,"CloseProcess","ON")
        XHotKeywrapper(hpKey,"TogglePauseMenuStatus","ON")
        If mgEnabled = true
            XHotKeywrapper(mgKey,"StartMulti","ON")
        If (bezelEnabled = true) and (bezelPath = true)
        {	Gosub, EnableBezelKeys%zz%	; turning on the bezel keys
            if %ICRandomSlideShowTimer%
                SetTimer, randomICChange%zz%, %ICRandomSlideShowTimer%
            if ICRightMenuDraw 
                Gosub, EnableICRightMenuKeys%zz%
            if ICLeftMenuDraw
                Gosub, EnableICLeftMenuKeys%zz%
            if (bezelBackgroundsList.MaxIndex() > 1)
                if bezelBackgroundChangeDur
                    settimer, BezelBackgroundTimer%zz%, %bezelBackgroundChangeDur%
            ;reloading the top most bezel layers
            Loop, 7 { 
                index := a_index + 1
                Gui, Bezel_GUI%index%: Show
            }
            WinActivate, ahk_class %EmulatorClass%,,%frontendWinTitle% ahk_class %frontendWinClass%
        }
        Log("Enabled exit emulator, bezel, and multigame keys",5)
        Gosub, SendCommandstoEmulator
        if filesToBeDeleted
            {
            remainingFilesToBeDeleted := ""
            StringTrimRight, filesToBeDeleted, filesToBeDeleted, 1 
            Loop, parse, filesToBeDeleted,|, 
                {
                if FileExist(A_LoopField)
                    {
                    FileDelete, % A_LoopField
                    if ErrorLevel
                        remainingFilesToBeDeleted .= A_LoopField . "|"
                }
            }
            filesToBeDeleted := remainingFilesToBeDeleted
        }
    }
    If !disableLoadScreen {
        If ((ItemSelected=1) and (SelectedMenuOption="ChangeDisc") and (forceMGGuiDestroy)) {
            SelectObject(HP_hdc21, HP_obm21)
            DeleteObject(HP_hbm21)
            DeleteDC(HP_hdc21)
            Gdip_DeleteGraphics(HP_G21)
            Gui, HP_GUI21: Destroy  
        }
    }
    If close_emulator {
        Log("Exiting Emulator From HyperPause",1)
        gosub, CloseProcess
        WinWaitClose, ahk_id  %emulatorID%
    }
    If((HyperPause_MuteWhenLoading="true") or (HyperPause_MuteSound="true")){
        If !(HyperPauseInitialMuteState){
            getMute(CurrentMuteState,emulatorVolumeObject)
            If(CurrentMuteState=1){
                setMute(0,emulatorVolumeObject)
                Log("Unmuting computer sound while HP is loaded. Master Mute status: " getMute(,emulatorVolumeObject) " (0 is unmutted)",5)
            }
        }
    }
    If (emuIdleShutdown and emuIdleShutdown != "ERROR")	; turn on emuIdleShutdown while in HP
		SetTimer, EmuIdleCheck%zz%, On
    setVolume(HyperPause_VolumeMaster) ; making sure that changes on sound menu are updated   
    Log("HyperPause Closed",1)
    HyperPause_Running:=false
Return


SimplifiedExitHyperPause:
    If !disableSuspendEmu    
        {
        ProcRes(emulatorProcessName)
        Log("Emulator process started",5)
        timeout := A_TickCount
        sleep, 200
        WinRestore, ahk_ID %emulatorID%
        IfWinNotActive, ahk_class %EmulatorClass%,,%frontendWinTitle% ahk_class %frontendWinClass%
            {
            Loop{
                sleep, 200
                WinRestore, ahk_ID %emulatorID%
                sleep, 200
                WinActivate, ahk_class %EmulatorClass%,,%frontendWinTitle% ahk_class %frontendWinClass%
                IfWinActive, ahk_class %EmulatorClass%,,%frontendWinTitle% ahk_class %frontendWinClass%
                    {
                    break
                    }
            If(timeout<A_TickCount-3000)
                    break
            sleep, 200
            }
            Log("Emulator screen reactivated",5)
        }
    }
    gosub, RestoreEmu
    If((HyperPause_MuteWhenLoading="true") or (HyperPause_MuteSound="true")){ ;Unmute If initial state is unmuted
        If !(HyperPauseInitialMuteState){
            getMute(CurrentMuteState,emulatorVolumeObject)
            If(CurrentMuteState=1){
                setMute(0,emulatorVolumeObject)
                Log("Unmuting computer sound while HP is loaded. Master Mute status: " getMute(,emulatorVolumeObject) " (0 is unmutted)",5)
            }
        }  
    }    
    If !disableLoadScreen {
        SelectObject(HP_hdc21, HP_obm21)
        DeleteObject(HP_hbm21)
        DeleteDC(HP_hdc21)
        Gdip_DeleteGraphics(HP_G21)
        Gui, HP_GUI21: Destroy  
    }
    XHotKeywrapper(exitEmulatorKey,"CloseProcess","ON")
    XHotKeywrapper(hpKey,"TogglePauseMenuStatus","ON")
    If mgEnabled = true
        XHotKeywrapper(mgKey,"StartMulti","ON")
	If bezelEnabled = true
	{	Gosub, EnableBezelKeys%zz%	; turning on the bezel keys
        if %ICRandomSlideShowTimer%
			SetTimer, randomICChange%zz%, %ICRandomSlideShowTimer%
        if ICRightMenuDraw 
            Gosub, EnableICRightMenuKeys%zz%
        if ICLeftMenuDraw
            Gosub, EnableICLeftMenuKeys%zz%
        if (bezelBackgroundsList.MaxIndex() > 1)
            if bezelBackgroundChangeDur
                settimer, BezelBackgroundTimer%zz%, %bezelBackgroundChangeDur%
	}
	Log("Enabled exit emulator, bezel, and multigame keys",5)
    HyperPause_Active:=false
    HyperPause_Running:=false
Return

SendCommandstoEmulator:
    If (ItemSelected = 1){
        If((SelectedMenuOption="SaveState")or(SelectedMenuOption="LoadState")){ 
            If(A_KeyDelay<HyperPause_SetKeyDelay) 
                SetKeyDelay(HyperPause_SetKeyDelay)
            currentLabel := SelectedMenuOption . "Slot" . VSubMenuItem
            if IsLabel(currentLabel) 
                {
                Gosub %currentLabel%
                If(SelectedMenuOption="SaveState") {
                    SaveTime := "This game was saved in " A_DDDD ", " A_MMMM " " A_DD ", " A_YYYY ", at " A_Hour ":" A_Min ":" A_Sec  
                    RIni_SetKeyValue(1,dbName, SelectedMenuOption . VSubMenuItem . "SaveTime",SaveTime) ; makes sure that save state info is saved on statistics update   
                    IniWrite, %SaveTime%, %HyperPause_GameStatistics%%systemName%.ini, %dbName%, %SelectedMenuOption%%VSubMenuItem%SaveTime ; saves save state info between HyperPause menu calls
                } 
            } else {
                Loop, parse, hp%SelectedMenuOption%KeyCodes,|, 
                {
                    If(VSubMenuItem=A_Index){
                        If(SelectedMenuOption="SaveState") {
                            SaveTime := "This game was saved in " A_DDDD ", " A_MMMM " " A_DD ", " A_YYYY ", at " A_Hour ":" A_Min ":" A_Sec  
                            RIni_SetKeyValue(1,dbName, SelectedMenuOption . VSubMenuItem . "SaveTime",SaveTime) ; makes sure that save state info is saved on statistics update   
                            IniWrite, %SaveTime%, %HyperPause_GameStatistics%%systemName%.ini, %dbName%, %SelectedMenuOption%%VSubMenuItem%SaveTime ; saves save state info between HYperPause menu calls
                        }         
                        KeySelected:=A_LoopField
                        break
                    }
                }
                sleep, %HyperPause_DelaytoSendKeys%
                Loop, parse, KeySelected,;, 
                {
                    If InStr(A_LoopField,"Sleep"){
                        StringReplace, SleepPeriod, A_LoopField, Sleep, , all
                        Sleep, %SleepPeriod%
                    } Else {
                        Send, , %A_LoopField%
                    }
                }
                Log(SelectedMenuOption " KeySelected " KeySelected " sent to the emulator",1)
            }
            If(SelectedMenuOption="SaveState") and (HyperPause_SaveStateScreenshot = "true") {
                gosub, SaveScreenshot  
                filesToBeDeleted .=  HyperPause_SaveScreenshotPath . SaveStateBackgroundFile . "|"
                RIni_SetKeyValue(1,dbName, "SaveState" . VSubMenuItem . "Screenshot",CurrentScreenshotFileName) ; makes sure that save state info is saved on statistics update   
                IniWrite, %CurrentScreenshotFileName%, %HyperPause_GameStatistics%%systemName%.ini, %dbName%, SaveState%VSubMenuItem%Screenshot ; saves save state info between HYperPause menu calls
            }
            SetKeyDelay(SavedKeyDelay)
        }
        If(SelectedMenuOption="ChangeDisc"){
            If statisticsEnabled = true
                gosub, UpdateStatistics
            gameSectionStartTime := A_TickCount
            gameSectionStartHour := A_Now
            Log("HyperPauseExit - Processing MultiGame label in module.",4)
            gosub, MultiGame%zz%
            Log("HyperPauseExit - Finished Processing MultiGame label.",4)
        }
    }
Return


;--- Change Disc Labels

HyperPause_UpdateFor7z:
	Gosub, HyperPause_ProgressBarAnimation	; Calling HyperPause progress bar animation
Return

HyperPause_ProgressBarAnimation:
	; start the progress bar animation Loop
	Log("HyperPause_ProgressBarAnimation - Started")
    HyperPause_7zProgress_BarX := (baseScreenWidth - HyperPause_7zProgress_BarW)//2 - HyperPause_7zProgress_BarBackgroundMargin 
    HyperPause_7zProgress_BarY := 3*(baseScreenHeight)//4 - (HyperPause_7zProgress_BarH+HyperPause_7zProgress_BarBackgroundMargin)//2
    Text1Option := HyperPause_7zProgress_BarText1Options . " s" . HyperPause_7zProgress_BarText1FontSize
    Text2Option := HyperPause_7zProgress_BarText2Options . " s" . HyperPause_7zProgress_BarText2FontSize
    currentFloat := A_FormatFloat 
	SetFormat, Float, 3.2	; required otherwise calculations below falsely trigger
	HyperPause_7zProgress_FinishedBar := 0
    pGraphUpd(HP_G25,HyperPause_7zProgress_BarW+2*HyperPause_7zProgress_BarBackgroundMargin, HyperPause_7zProgress_BarH+2*HyperPause_7zProgress_BarBackgroundMargin)
    Loop {
		Gdip_GraphicsClear(HP_G25)
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
		
		; Drawing Bar Background
		HyperPause_7zProgress_BackgroundBrush := Gdip_BrushCreateSolid("0x" . HyperPause_7zProgress_BarBackgroundColor)
		HyperPause_7zProgress_BarBackBrush := Gdip_BrushCreateSolid("0x" . HyperPause_7zProgress_BarBackColor)
		HyperPause_7zProgress_BarBrush := Gdip_BrushCreateHatch(0x00000000, "0x" . HyperPause_7zProgress_BarColor, HyperPause_7zProgress_BarHatchStyle) 
		Gdip_Alt_FillRoundedRectangle(HP_G25, HyperPause_7zProgress_BackgroundBrush, 0, 0, HyperPause_7zProgress_BarW+2*HyperPause_7zProgress_BarBackgroundMargin, HyperPause_7zProgress_BarH+2*HyperPause_7zProgress_BarBackgroundMargin,HyperPause_7zProgress_BarBackgroundRadius)
		Gdip_Alt_FillRoundedRectangle(HP_G25, HyperPause_7zProgress_BarBackBrush, HyperPause_7zProgress_BarBackgroundMargin, HyperPause_7zProgress_BarBackgroundMargin, HyperPause_7zProgress_BarW, HyperPause_7zProgress_BarH, HyperPause_7zProgress_BarR)
		; Drawing Progress Bar
		If percentage > 100
			percentage := 100
		If(HyperPause_7zProgress_BarW*percentage/100<3*HyperPause_7zProgress_BarR)	; avoiding glitch in rounded rectangle drawing when they are too small
			currentRBar := HyperPause_7zProgress_BarR * ((HyperPause_7zProgress_BarW*percentage/100)/(3*HyperPause_7zProgress_BarR))
		Else
			currentRBar := HyperPause_7zProgress_BarR
		Gdip_Alt_TextToGraphics(HP_G25, round(percentage) . "%", "x" round(HyperPause_7zProgress_BarBackgroundMargin+HyperPause_7zProgress_BarW*percentage/100) " y" (HyperPause_7zProgress_BarBackgroundMargin-HyperPause_7zProgress_Text_Offset)//2 . " " . Text1Option, HyperPause_7zProgress_Font, 0, 0)
		If percentage < 100
			If (fadeBarInfoText = "true")
				Gdip_Alt_TextToGraphics(HP_G25, HyperPause_7zProgress_BarText1, "x" HyperPause_7zProgress_BarBackgroundMargin+HyperPause_7zProgress_BarW " y" HyperPause_7zProgress_BarBackgroundMargin+HyperPause_7zProgress_BarH+(HyperPause_7zProgress_BarBackgroundMargin-HyperPause_7zProgress_Text_Offset)//2 . " " . Text1Option, HyperPause_7zProgress_Font, 0, 0)
		Else {	; bar is at 100%
			HyperPause_7zProgress_FinishedBar:= 1
			Log("HyperPause_ProgressBarAnimation - Bar reached 100%",4)
			If (fadeBarInfoText = "true")
				Gdip_Alt_TextToGraphics(HP_G25, HyperPause_7zProgress_BarText2, "x" HyperPause_7zProgress_BarBackgroundMargin+HyperPause_7zProgress_BarW " y" HyperPause_7zProgress_BarBackgroundMargin+HyperPause_7zProgress_BarH+(HyperPause_7zProgress_BarBackgroundMargin-HyperPause_7zProgress_Text_Offset)//2 . " " . Text2Option, HyperPause_7zProgress_Font, 0, 0)
		}
		Gdip_Alt_FillRoundedRectangle(HP_G25, HyperPause_7zProgress_BarBrush, HyperPause_7zProgress_BarBackgroundMargin, HyperPause_7zProgress_BarBackgroundMargin, HyperPause_7zProgress_BarW*percentage/100, HyperPause_7zProgress_BarH,currentRBar)
		Alt_UpdateLayeredWindow(HP_hwnd25, HP_hdc25,HyperPause_7zProgress_BarX,HyperPause_7zProgress_BarY, HyperPause_7zProgress_BarW+2*HyperPause_7zProgress_BarBackgroundMargin, HyperPause_7zProgress_BarH+2*HyperPause_7zProgress_BarBackgroundMargin)
		Process, Exist, 7z.exe	; This breaks out of 7z.exe If it's no longer running. Sometimes an extraction was very quick or there was an error and we don't want to be stuck in an infinite Loop
		If !ErrorLevel ; bar is at 100% or 7z is already closed or user interrupted fade, so break out
		{	Log("HyperPause_ProgressBarAnimation - 7z.exe is no longer running, breaking out of progress loop.",4)
			Break
		}
		If HyperPause_7zProgress_FinishedBar
			Break
	}
	SetFormat, Float, %currentFloat%	; restore previous float
	Log("HyperPause_ProgressBarAnimation - Ended")
Return

;-----------------SUB MENU LIST AND DRAWING FUNCTIONS------------

LoadMediaAssetsFiles(path, fileExtensions, assetType, SubMenuName, ByRef MediaList){
    Global 7zFormatsNoP, Supported_Images, HLMediaPath, 7zPath, HyperPause_LoadPDFandCompressedFilesatStart, systemName
    if FileExist(path) {
        Loop, % path . "\*", 1 
        {
            if InStr(A_LoopFileAttrib, "D") { ; it is a folder
                folderName := A_LoopFileName
                Loop % A_LoopFileLongPath . "\*.*"
                {   
                    If A_LoopFileExt in %Supported_Images%
                    {
                        currentobj := {}
                        currentobj["Label"] := folderName
                        if MediaList[folderName].Label
                        {   currentobj := MediaList[folderName]
                            currentobj.TotalItems := currentobj.TotalItems+1
                        } else {
                            currentobj.TotalItems := 1
                        }
                        currentobj["Path" . currentobj.TotalItems] := A_LoopFileLongPath
                        currentobj["Ext" . currentobj.TotalItems] := A_LoopFileExt
                        currentobj["AssetType"] := assetType
                        if (currentobj.TotalItems>1)
                            currentobj["Type"] := "ImageGroup"
                        MediaList.Insert(currentobj["Label"], currentobj)
                    }
                }
            } else if InStr(A_LoopFileAttrib, "A") { ; it is a file
                If A_LoopFileExt in %7zFormatsNoP%,cbr,cbz
                {
                    IfExist, % 7zPath
                    {
                        CurrentExtension := A_LoopFileExt
                        CurrentFile :=  A_LoopFileFullPath
                        CurrentFileName := A_LoopFileName
                        TempCompressedListofFiles := StdoutToVar_CreateProcess(7zPath . " l """ . CurrentFile . """")
                        Loop, parse, Supported_Images,`,,
                        {
                            If TempCompressedListofFiles contains %A_LoopField%
                            {
                                SplitPath, CurrentFile, ,,,FileNameWithoutExtension
                                currentobj := {}
                                currentobj["Label"] := FileNameWithoutExtension
                                if MediaList[FileNameWithoutExtension].Label
                                {   currentobj := MediaList[FileNameWithoutExtension]
                                    currentobj.TotalItems := currentobj.TotalItems+1
                                } else {
                                    currentobj.TotalItems := 1
                                }
                                currentobj["Path" . currentobj.TotalItems] := CurrentFile
                                currentobj["Ext" . currentobj.TotalItems] := CurrentExtension
                                currentobj["AssetType"] := assetType
                                MediaList.Insert(currentobj["Label"], currentobj)  
                                If(HyperPause_LoadPDFandCompressedFilesatStart = "true"){
                                    HyperPause_7zExtractDir := HLMediaPath . "\" . SubMenuName . "\Temp\" . systemName . "\" . FileNameWithoutExtension
                                    RunWait, %7zPath% e "%CurrentFile%" -aoa -o"%HyperPause_7zExtractDir%",,Hide ; perform the extraction and overwrite all
                                    currentobj := MediaList[FileNameWithoutExtension]
                                    Loop, % HLMediaPath . "\" . SubMenuName . "\Temp\" . systemName . "\" . FileNameWithoutExtension . "\*.*"
                                        {
                                        currentobj["Path" . a_index] := A_LoopFileLongPath
                                        currentobj["Ext" . a_index] := A_LoopFileExt
                                        currentobj["AssetType"] := assetType
                                        currentobj["TotalItems"] := a_index
                                    }
                                    if (currentobj.TotalItems>1)
                                        currentobj["Type"] := "ImageGroup"
                                    MediaList.Insert(currentobj["Label"], currentobj)                                      
                                }
                            }
                        }
                    }
                } Else if A_LoopFileExt in %fileExtensions% 
                    {
                    SplitPath, A_LoopFileFullPath, ,,,FileNameWithoutExtension
                    currentobj := {}
                    currentobj["Label"] := FileNameWithoutExtension
                    if MediaList[FileNameWithoutExtension].Label
                    {   currentobj := MediaList[FileNameWithoutExtension]
                        currentobj.TotalItems := currentobj.TotalItems+1
                    } else {
                        currentobj.TotalItems := 1
                    }
                    currentobj["Path" . currentobj.TotalItems] := A_LoopFileLongPath
                    currentobj["Ext" . currentobj.TotalItems] := A_LoopFileExt
                    currentobj["AssetType"] := assetType
                    if  (A_LoopFileExt = "txt"){
                        FileRead, txtContents, % A_LoopFileFullPath
                        currentobj["txtContents"] := txtContents
                    }
                    MediaList.Insert(currentobj["Label"], currentobj)  
                }
            }
        }            
    }
Return 
}

CreateSubMenuMediaObject(SubMenuName){
    Global systemName, dbName, HLMediaPath, Supported_Images, Supported_Extensions, DescriptionNameWithoutDisc, Totaldiscsofcurrentgame, ListofSupportedVideos, gameInfo, HyperPause_UseParentGameMediaAssets
    HLMediaList := {}
    if (SubMenuName="Videos")
        currentExtensions := ListofSupportedVideos
    else
        currentExtensions := Supported_Extensions
    ; Loop HyperLaunch\Media\Sony Playstation\Final Fantasy VII (USA) (Disc x)\ 
    LoadMediaAssetsFiles(HLMediaPath . "\" . SubMenuName . "\" . systemName . "\" . dbName, currentExtensions, "game", SubMenuName, HLMediaList)
    ; Loop HyperLaunch\Media\Sony Playstation\Final Fantasy VII (USA)\ 
    If (Totaldiscsofcurrentgame>1)
        LoadMediaAssetsFiles(HLMediaPath . "\" . SubMenuName . "\"  . systemName . "\" . DescriptionNameWithoutDisc, currentExtensions, "game", SubMenuName, HLMediaList)
    ; Parent game Assets 
    if (HyperPause_UseParentGameMediaAssets="true")
        if (gameInfo["CloneOf"].Label)
            LoadMediaAssetsFiles(HLMediaPath . "\" . SubMenuName . "\"  . systemName . "\" . gameInfo["CloneOf"].Value, currentExtensions, "game", SubMenuName, HLMediaList)
    ; Loop HyperLaunch\Media\Sony Playstation\_Default\ 
    LoadMediaAssetsFiles(HLMediaPath . "\" . SubMenuName . "\"  . systemName . "\_Default", currentExtensions, "system", SubMenuName, HLMediaList)
    ; Loop HyperLaunch\Media\_Default\ 
    LoadMediaAssetsFiles(HLMediaPath . "\" . SubMenuName . "\"  . "_Default", currentExtensions, "system", SubMenuName, HLMediaList)
    Return HLMediaList    
}

PostProcessingMediaObject(feMedia, ByRef HPMediaObj){
    Global HyperPause_MainMenu_Labels, keymapperEnabled, systemName
    Global HyperPause_Artwork_VMargin, HyperPause_Controller_VMargin, HyperPause_Guides_VMargin, HyperPause_Manuals_VMargin, HyperPause_Videos_VMargin, logLevel
    Global HyperPause_SubMenu_Height, HyperPause_SubMenu_SmallFontSize, baseScreenHeight, HyperPause_SubMenu_FullScreenMargin, HyperPause_SubMenu_LabelFontSize, HyperPause_SubMenu_LabelFont, HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_MinimumTextBoxWidth, HyperPause_SubMenu_Font
    Global HLObject, HyperPause_SubMenu_PdfDpiResolution, HyperPause_LoadPDFandCompressedFilesatStart, HLMediaPath, pdfMaxHeight, HyperPause_PDF_Page_Layout
    ; Load FrontEnd Assets
    for SubMenuLabel, element2 in feMedia
    {   for index, element in element2
        {   if element.Label
            {   currentobj := feMedia[SubMenuLabel][element.Label]
				if (HPMediaObj[SubMenuLabel][element.Label].Label)
                {   currentobj.Insert(currentobj["Label"], HPMediaObj[SubMenuLabel][element.Label]) 
                    currentobj.TotalItems := currentobj.TotalItems+1
                }
                HPMediaObj[SubMenuLabel].Insert(currentobj["Label"], currentobj) 
            }
        }
    }    
    ; PostProcesing variables
    objAux := [] ;auxiliar array
    for SubMenuLabel, element2 in HPMediaObj
        {        
        VMargin := % HyperPause_%SubMenuLabel%_VMargin
        HPMediaObj[SubMenuLabel].maxLabelSize := HyperPause_SubMenu_MinimumTextBoxWidth
        HPMediaObj[SubMenuLabel].txtLines := round((HyperPause_SubMenu_Height-2*VMargin-2*HyperPause_SubMenu_SmallFontSize)/(HyperPause_SubMenu_SmallFontSize)) ;Number of Lines per page
        HPMediaObj[SubMenuLabel].txtFSLines := round((baseScreenHeight - 4*HyperPause_SubMenu_FullScreenMargin-2*HyperPause_SubMenu_SmallFontSize)/(HyperPause_SubMenu_SmallFontSize)) ;Number of lines in Full Screen 
        mediaAssetsLog := ""
        count := 0
        for index, element in element2
        {   ; total labels in sub menu
            if element.Label
            {   ;total elements
                if SubMenuLabel in Artwork,Controller,Guides,Manuals,Videos,History
                    {
                    count++
                    HPMediaObj[SubMenuLabel].TotalLabels := count
                    objAux[SubMenuLabel,count] := HPMediaObj[SubMenuLabel][element.Label].Label
                }
                ;maxlabelsize
                FontListWidth := MeasureText(element.Label, "Left r4 s" . HyperPause_SubMenu_LabelFontSize . " bold",HyperPause_SubMenu_LabelFont)+HyperPause_SubMenu_AdditionalTextMarginContour
                If(FontListWidth>HPMediaObj[SubMenuLabel].maxLabelSize)
                    HPMediaObj[SubMenuLabel].maxLabelSize := FontListWidth
                ; txt files post processing
                if (element.Ext1 = "txt") {
                    currentobj := HPMediaObj[SubMenuLabel][element.Label]
                    ;Counting total number of pages in txt files
                    currentobj["txtWidth"] := MeasureText(currentobj.txtContents, "Left r4 s" . HyperPause_SubMenu_SmallFontSize . " Regular",HyperPause_SubMenu_Font)
                    count1:=1
                    count2:=1
                    txtContents := currentobj.txtContents
                    Loop, parse, txtContents, `n, `r  
                        {
                        FirstLine := (count1-1)* HPMediaObj[SubMenuLabel].txtLines
                        LastLine := FirstLine + HPMediaObj[SubMenuLabel].txtLines
                        FullScreenFirstLine := % (count2-1) * HPMediaObj[SubMenuLabel].txtFSLines
                        FullScreenLastLine := % FullScreenFirstLine + HPMediaObj[SubMenuLabel].txtFSLines
                        currentobj["Page" . count1] := currentobj["Page" . count1] . A_LoopField . "`r`n" 
                        If(A_index >= FirstLine){
                            If(A_index > LastLine){
                                count1++
                            }
                        }
                        currentobj["FSPage" . count2] := currentobj["FSPage" . count2] . A_LoopField . "`r`n" 
                        If(A_index >= FullScreenFirstLine){
                            If(A_index > FullScreenLastLine){
                                count2++
                            }
                        }
                    }          
                    currentobj["TotalV2SubMenuItems"] := count1
                    currentobj["TotalFSV2SubMenuItems"] := count2 
                    HPMediaObj[SubMenuLabel].Insert(currentobj["Label"], currentobj) 
                } else if (element.Ext1 = "pdf"){
                    currentobj := HPMediaObj[SubMenuLabel][element.Label]
                    If(HyperPause_LoadPDFandCompressedFilesatStart = "true"){ ; loading pdfs at startup
                        IfNotExist, % HLMediaPath . "\" . SubMenuLabel . "\Temp\" . systemName . "\" . element.Label
                            FileCreateDir, % HLMediaPath . "\" . SubMenuLabel . "\Temp\" . systemName . "\" . element.Label
                        COM_Invoke(HLObject, "generatePngFromPdf", element.Path1, HLMediaPath . "\" . SubMenuLabel . "\Temp\" . systemName . "\" . element.Label, HyperPause_SubMenu_PdfDpiResolution,pdfMaxHeight,1,0,HyperPause_PDF_Page_Layout)
                        currentobj := HPMediaObj[SubMenuLabel][element.Label]
                        Loop, % HLMediaPath . "\" . SubMenuLabel . "\Temp\" . systemName . "\" . element.Label . "\*.*"
                            {
                            currentobj["Path" . a_index] := A_LoopFileLongPath
                            currentobj["Ext" . a_index] := A_LoopFileExt
                            currentobj["TotalItems"] := a_index
                        }
                        if (currentobj.TotalItems>1)
                            currentobj["Type"] := "ImageGroup"
                    } else 
                        currentobj["TotalItems"] := COM_Invoke(HLObject, "getPdfPageCount", element.Path1,HyperPause_PDF_Page_Layout)
                    HPMediaObj[SubMenuLabel].Insert(currentobj["Label"], currentobj) 
                }
                if (logLevel>=5){
                    loop, % HPMediaObj[SubMenuLabel][element.Label].TotalItems
                        mediaAssetsLog := % mediaAssetsLog . "`r`n`t`t`t`t`tAsset Label: " . element.Label . " | Asset Path" . a_index . ":  " . element["Path" . a_index] . " | Asset Extension" . a_index . ":  " . element["Ext" . a_index]
                }
            }
        }
        ; Removing empty menus
        if !(HPMediaObj[SubMenuLabel].TotalLabels)
            if !((SubMenuLabel="Controller") and (keymapperEnabled = "true"))
                StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, %SubMenuLabel%|,
        if mediaAssetsLog
            Log("Media assets found on submenu: " . SubMenuLabel . mediaAssetsLog,5)
    }
    ; Correspondence between label index and label name 
    if SubMenuLabel in Artwork,Controller,Guides,Manuals,Videos,History
    {   for SubMenuLabel, element2 in objAux
            for index, element in element2
                HPMediaObj[SubMenuLabel][index] := objAux[SubMenuLabel][index]
    }
    ; Moving Screenshot Label to the end of the artwork assets list
    count := 0
    if HPMediaObj["Artwork"].Screenshots.Label
    {
        loop, % HPMediaObj["Artwork"].TotalLabels
        {
            if (HPMediaObj["Artwork"][a_index]="Screenshots")
                keyScreenshotsFound := true
            if keyScreenshotsFound
                HPMediaObj["Artwork"][a_index] := HPMediaObj["Artwork"][a_index+1]
        }
        HPMediaObj["Artwork"][HPMediaObj["Artwork"].TotalLabels] := "Screenshots"
    }
Return
}

loadHistoryDataInfo(){
	Global HyperPause_HistoryDatPath, systemName, dbName, gameInfo 
    HLMediaList := {}   
    IniRead, historyDatSystemName, %HyperPause_HistoryDatPath%System Names.ini, Settings, %systemName%, %A_Space%
    IniRead, romNameToSearch, %HyperPause_HistoryDatPath%%systemName%.ini, %dbName%, Alternate_Rom_Name, %A_Space%
    if !romNameToSearch
        romNameToSearch := dbName
    FileRead, historyContents, %HyperPause_HistoryDatPath%History.dat
    FoundPos := RegExMatch(historyContents, "i)" . "\$\s*" . historyDatSystemName . "\s*=\s*.*\b" . romNameToSearch . "\b\s*,")
    If !FoundPos {
        If (gameInfo["CloneOf"].Label)
            FoundPos := RegExMatch(historyContents, "i)" . "\$\s*" . historyDatSystemName . "\s*=\s*.*\b" . gameInfo["CloneOf"].Value . "\b\s*,")
    }
    If FoundPos
        {
        FoundPos2 := RegExMatch(historyContents, "i)\$end",EndString,FoundPos)
        StringMid, HistoryDataText, historyContents, % FoundPos, % FoundPos2-FoundPos
        historySectionNumber := 1
        Loop, parse, HistoryDataText, `n, `r  
            {
            if historyDatSectionName%historySectionNumber% := historyDatSection(A_LoopField)
                {
                currentHistorySectionNumber := historySectionNumber
                historySectionNumber++
            } else if (historySectionNumber>1) {
                HistoryFileTxtContents%currentHistorySectionNumber% := % HistoryFileTxtContents%currentHistorySectionNumber% . "`n`r" . A_LoopField
            }
        }
        count := 0
        loop, % currentHistorySectionNumber
            {
            if ((!(InStr(historyDatSectionName%A_Index%, "SOURCES"))) and (historyDatSectionName%A_Index%)) {
                count++
                currentobj := {}
                currentobj["Label"] := historyDatSectionName%A_Index%
                currentobj["txtContents"] := RegExReplace(HistoryFileTxtContents%count%,"^\s+|\s+$")
                currentobj["Ext1"] := "txt"
                HLMediaList.Insert(currentobj["Label"], currentobj)  
            }
        }
    }
    Return HLMediaList
}

historyDatSection(line){
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
     

      
TextImagesAndPDFMenu(SubMenuName)
{   Global
    FunctionRunning := true ;error check function running (necessary to avoid exiting hyperpause in the middle of function running)
    CurrentLabelNumber := VSubMenuItem ;initializing variables
    If(VSubMenuItem < 1){
        CurrentLabelNumber := 1
    }
    CurrentLabelName := HPMediaObj[SubMenuName][CurrentLabelNumber]
    CurrentFilePath := HPMediaObj[SubMenuName][CurrentLabelName].Path1
    ;CurrentFilePath := % %SubMenuName%File%CurrentLabelNumber%
    CurrentFileExtension := HPMediaObj[SubMenuName][CurrentLabelName].Ext1
    ;CurrentFileExtension := % %SubMenuName%FileExtension%CurrentLabelNumber%
    If not((SelectedMenuOption="Videos") or (VSubMenuItem=-1)){
        HSubMenuItem := % HSubmenuitem%SubMenuName%VSubmenuitem%VSubmenuitem%
        V2Submenuitem := % HSubmenuitem%SubMenuName%V2Submenuitem%VSubmenuitem%
    }
    ;CurrentList := % %SubMenuName%List
    HMargin := % HyperPause_%SubMenuName%_HMargin
    HdistBetwLabelsandPages := % HyperPause_%SubMenuName%_HdistBetwLabelsandPages
    VMargin := % HyperPause_%SubMenuName%_VMargin
    VdistBetwLabels := HyperPause_%SubMenuName%_VdistBetwLabels
    TempPath := % HyperPause_%SubMenuName%TempPath
    PageNumberFontColor := % HyperPause_%SubMenuName%_PageNumberFontColor
    HdistBetwPages := % HyperPause_%SubMenuName%_HdistBetwPages
    color := HyperPause_MainMenu_LabelDisabledColor ;drawing Label List
    Optionbrush := HyperPause_SubMenu_DisabledBrushV
    posSubMenuY1 := % HyperPause_%SubMenuName%_VMargin
    MaxFontListWidth := HPMediaObj[SubMenuName].maxLabelSize
    ;MaxFontListWidth := % %SubMenuName%MaxFontListWidth
    posPageX := HMargin+MaxFontListWidth+HdistBetwLabelsandPages
    posPageY := VMargin
    showItemLabel := % HyperPause_%SubMenuName%_Item_Labels
    Loop, % HPMediaObj[SubMenuName].TotalLabels
    {
        posSubMenuX1 := round(HMargin+MaxFontListWidth/2)
        If(VSubMenuItem = A_index ){
            If(SelectedMenuOption="Videos") and  (HSubmenuitem=2) {
                color := HyperPause_MainMenu_LabelDisabledColor
                Optionbrush := HyperPause_SubMenu_DisabledBrushV
            } Else {
                color := HyperPause_MainMenu_LabelSelectedColor
                Optionbrush := HyperPause_SubMenu_SelectedBrushV                
            }
        }    
        If( A_index >= VSubMenuItem){  
            Options1 := "x" . posSubMenuX1 . " y" . posSubMenuY1 . " Center c" . color . " r4 s" . HyperPause_SubMenu_LabelFontSize . " bold"
            Gdip_Alt_FillRoundedRectangle(HP_G27, Optionbrush, round(posSubMenuX1-MaxFontListWidth/2), posSubMenuY1+HyperPause_VTextDisplacementAdjust-HyperPause_SubMenu_AdditionalTextMarginContour, MaxFontListWidth, HyperPause_SubMenu_FontSize+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_RadiusofRoundedCorners)
            Gdip_Alt_TextToGraphics(HP_G27, HPMediaObj[SubMenuName][a_index], Options1, HyperPause_SubMenu_LabelFont, 0, 0)
            posSubMenuY1 := posSubMenuY1+VdistBetwLabels
            color := HyperPause_MainMenu_LabelDisabledColor
            Optionbrush := HyperPause_SubMenu_DisabledBrushV
        }
    }
    ;If video file:  
    If CurrentFileExtension in %ListofSupportedVideos%    
        {
        If !(FullScreenView){
            If !(AnteriorFilePath = CurrentFilePath) {
                try CurrentVideoPlayStatus := wmpVideo.playState
                If(CurrentVideoPlayStatus=3) {
                    try VideoPosition%videoplayingindex% := wmpVideo.controls.currentPosition
                    Log("VideoPosition at video change in videos menu:" "VideoPosition"videoplayingindex " " VideoPosition%videoplayingindex%,5) 
                    try wmpVideo.controls.stop
                    timeout:= A_TickCount
                    Loop
                        {
                        try CurrentVideoPlayStatus := wmpVideo.playState
                        If(CurrentVideoPlayStatus=1)
                            break
                        If(timeout<A_TickCount-2000)
                            break
                    }
                }
                Gui,HP_GUI31: Show, Hide
                Gui, HP_GUI32: Show
                try wmpVideo.Url := CurrentFilePath
                try wmpVideo.controls.play ;Workaround because I am still not able to figure out how to set the wmpVideo.currentMedia := 
                try wmpVideo.controls.pause
                Log("Playing Video File: " CurrentFilePath,5)
                VideoH := HyperPause_SubMenu_Height-2*HyperPause_Videos_VMargin ;Calculating the Video Position and size If I am not able to acquire the real video size 
                VideoW := round(16*VideoH/9)
                If(VideoW > HyperPause_SubMenu_Width-3*HyperPause_Videos_HMargin+HPMediaObj[SubMenuName].maxLabelSize+2*HyperPause_SubMenu_AdditionalTextMarginContour + HyperPause_SubMenu_SpaceBetweenLabelsandVideoButtons+HyperPause_SubMenu_SizeofVideoButtons){
                    VideoW := HyperPause_SubMenu_Width-3*HyperPause_Videos_HMargin+HPMediaObj[SubMenuName].maxLabelSize+2*HyperPause_SubMenu_AdditionalTextMarginContour + HyperPause_SubMenu_SpaceBetweenLabelsandVideoButtons+HyperPause_SubMenu_SizeofVideoButtons
                    VideoH := round(9*VideoW/16)
                }
                VideoX := baseScreenWidth-HyperPause_SubMenu_Width+HyperPause_Videos_HMargin+ HPMediaObj[SubMenuName].maxLabelSize +2*HyperPause_SubMenu_AdditionalTextMarginContour +HyperPause_SubMenu_SpaceBetweenLabelsandVideoButtons+HyperPause_SubMenu_SizeofVideoButtons+((HyperPause_SubMenu_Width-(HyperPause_Videos_HMargin+HPMediaObj[SubMenuName].maxLabelSize+2*HyperPause_SubMenu_AdditionalTextMarginContour +HyperPause_SubMenu_SpaceBetweenLabelsandVideoButtons+HyperPause_SubMenu_SizeofVideoButtons))-VideoW)//2
                VideoY := baseScreenHeight-HyperPause_SubMenu_Height+VMargin + round((HyperPause_SubMenu_Height-2*HyperPause_Videos_VMargin-VideoH)/2)
                timeout := A_TickCount ;Calculating the real Video Position and size (two seconds timeout If not able to acquire video size)
                VideoRealH := 0
                VideoRealW := 0
                Loop
                    {
                    try VideoRealH := wmpVideo.currentMedia.imageSourceHeight
                    try VideoRealW := wmpVideo.currentMedia.imageSourceWidth
                    If((VideoRealH<>0) and (VideoRealW<>0))
                        break
                    If(timeout<A_TickCount-2000)
                        break
                }
                If((VideoRealH<>0) and (VideoRealW<>0)){
                    VideoH := HyperPause_SubMenu_Height-2*HyperPause_Videos_VMargin
                    VideoW := round(VideoRealW/(VideoRealH/VideoH))
                    If(VideoW > HyperPause_SubMenu_Width-3*HyperPause_Videos_HMargin-HPMediaObj[SubMenuName].maxLabelSize-2*HyperPause_SubMenu_AdditionalTextMarginContour){
                        VideoW := HyperPause_SubMenu_Width-3*HyperPause_Videos_HMargin-HPMediaObj[SubMenuName].maxLabelSize-2*HyperPause_SubMenu_AdditionalTextMarginContour
                        VideoH := round(VideoRealH/(VideoRealW/VideoW)) 
                    }
                    VideoX := baseScreenWidth-HyperPause_SubMenu_Width+HyperPause_Videos_HMargin+HPMediaObj[SubMenuName].maxLabelSize+2*HyperPause_SubMenu_AdditionalTextMarginContour +HyperPause_SubMenu_SpaceBetweenLabelsandVideoButtons+HyperPause_SubMenu_SizeofVideoButtons+((HyperPause_SubMenu_Width-(HyperPause_Videos_HMargin+HPMediaObj[SubMenuName].maxLabelSize+2*HyperPause_SubMenu_AdditionalTextMarginContour +HyperPause_SubMenu_SpaceBetweenLabelsandVideoButtons+HyperPause_SubMenu_SizeofVideoButtons))-VideoW)//2
                    VideoY :=  baseScreenHeight-HyperPause_SubMenu_Height+VMargin + round((HyperPause_SubMenu_Height-2*HyperPause_Videos_VMargin-VideoH)/2)
                }
                WindowCoordUpdate(VideoX,VideoY,VideoW,VideoH)
                GuiControl, HP_GUI31: Move, wmpVideo, x0 y0 w%VideoW% h%VideoH% ;Resizing and showing window and playing video
                try wmpVideo.controls.play
                If (VSubMenuItem=0)
                    currentvideoposition := VideoPosition1
                Else 
                    currentvideoposition := VideoPosition%VSubMenuItem%                    
                currentvideoposition += 0
                try wmpVideo.Controls.CurrentPosition += currentvideoposition
                Log("Jumping to VideoPosition:" "VideoPosition"VSubMenuItem " " VideoPosition%VSubMenuItem%,5)
                Gui, HP_GUI31: Show, x%VideoX% y%VideoY% w%VideoW% h%VideoH%
                Gui, HP_GUI32: Show
                If (VSubmenuitem=0)
                    videoplayingindex := 1
                Else
                    videoplayingindex := VSubMenuItem
            }
            AnteriorFilePath := CurrentFilePath
            If (VSubmenuitem) {
                posVideoButtonsX := HyperPause_Videos_HMargin+HPMediaObj[SubMenuName].maxLabelSize+2*HyperPause_SubMenu_AdditionalTextMarginContour + HyperPause_SubMenu_SpaceBetweenLabelsandVideoButtons
                Loop, 5
                    {
                    posVideoButton%a_index%Y := HyperPause_Videos_VMargin + (a_index-1)*(HyperPause_SubMenu_SizeofVideoButtons + HyperPause_SubMenu_SpaceBetweenVideoButtons)
                    try CurrentVideoPlayStatus := wmpVideo.playState
                    If (a_index=1) and (CurrentVideoPlayStatus=3)
                        HyperPauseVideoBitmap%a_index% := Gdip_CreateBitmapFromFile(HyperPauseVideoImage6)
                    Else
                        HyperPauseVideoBitmap%a_index% := Gdip_CreateBitmapFromFile(HyperPauseVideoImage%a_index%)
                    Gdip_Alt_DrawImage(HP_G27,HyperPauseVideoBitmap%a_index%,posVideoButtonsX,posVideoButton%a_index%Y,HyperPause_SubMenu_SizeofVideoButtons,HyperPause_SubMenu_SizeofVideoButtons)
                    If(HsubMenuItem = 2){
                        If (V2Submenuitem = a_index){
                            pGraphUpd(HP_G30,round(HyperPause_SubMenu_SizeofVideoButtons+2*HyperPause_Video_Buttons_Grow_Size), round(HyperPause_SubMenu_SizeofVideoButtons+2*HyperPause_Video_Buttons_Grow_Size))
                            If (PreviousVideoButton<>V2Submenuitem){ 
                                GrowSize := 1
                                While GrowSize <= HyperPause_Video_Buttons_Grow_Size {
                                    Gdip_GraphicsClear(HP_G30)
                                    Gdip_Alt_DrawImage(HP_G30,HyperPauseVideoBitmap%V2Submenuitem%,HyperPause_Video_Buttons_Grow_Size-GrowSize,HyperPause_Video_Buttons_Grow_Size-GrowSize,HyperPause_SubMenu_SizeofVideoButtons+2*HyperPause_Video_Buttons_Grow_Size,HyperPause_SubMenu_SizeofVideoButtons+2*HyperPause_Video_Buttons_Grow_Size)
                                    Alt_UpdateLayeredWindow(HP_hwnd30, HP_hdc30, round(baseScreenWidth-HyperPause_SubMenu_Width+posVideoButtonsX-HyperPause_Video_Buttons_Grow_Size), round(baseScreenHeight-HyperPause_SubMenu_Height+posVideoButton%V2Submenuitem%Y-HyperPause_Video_Buttons_Grow_Size), HyperPause_SubMenu_SizeofVideoButtons+2*HyperPause_Video_Buttons_Grow_Size, HyperPause_SubMenu_SizeofVideoButtons+2*HyperPause_Video_Buttons_Grow_Size)
                                    GrowSize+= HyperPause_VideoButtonGrowingEffectVelocity
                                }
                                Gdip_GraphicsClear(HP_G30)
                                If(GrowSize<>15){
                                    Gdip_Alt_DrawImage(HP_G30,HyperPauseVideoBitmap%V2Submenuitem%,0,0,HyperPause_SubMenu_SizeofVideoButtons+2*HyperPause_Video_Buttons_Grow_Size,HyperPause_SubMenu_SizeofVideoButtons+2*HyperPause_Video_Buttons_Grow_Size)
                                    Alt_UpdateLayeredWindow(HP_hwnd30, HP_hdc30, round(baseScreenWidth-HyperPause_SubMenu_Width+posVideoButtonsX-HyperPause_Video_Buttons_Grow_Size), round(baseScreenHeight-HyperPause_SubMenu_Height+posVideoButton%V2Submenuitem%Y-HyperPause_Video_Buttons_Grow_Size), HyperPause_SubMenu_SizeofVideoButtons+2*HyperPause_Video_Buttons_Grow_Size, HyperPause_SubMenu_SizeofVideoButtons+2*HyperPause_Video_Buttons_Grow_Size)
                                }
                            } Else {
                                Gdip_Alt_DrawImage(HP_G30,HyperPauseVideoBitmap%V2Submenuitem%,0,0,HyperPause_SubMenu_SizeofVideoButtons+2*HyperPause_Video_Buttons_Grow_Size,HyperPause_SubMenu_SizeofVideoButtons+2*HyperPause_Video_Buttons_Grow_Size)
                                Alt_UpdateLayeredWindow(HP_hwnd30, HP_hdc30, round(baseScreenWidth-HyperPause_SubMenu_Width+posVideoButtonsX-HyperPause_Video_Buttons_Grow_Size), round(baseScreenHeight-HyperPause_SubMenu_Height+posVideoButton%V2Submenuitem%Y-HyperPause_Video_Buttons_Grow_Size), HyperPause_SubMenu_SizeofVideoButtons+2*HyperPause_Video_Buttons_Grow_Size, HyperPause_SubMenu_SizeofVideoButtons+2*HyperPause_Video_Buttons_Grow_Size)
                            }
                        }
                    } Else {
                        Gdip_GraphicsClear(HP_G30)
                        Alt_UpdateLayeredWindow(HP_hwnd30, HP_hdc30, round(baseScreenWidth-HyperPause_SubMenu_Width+posVideoButtonsX-HyperPause_Video_Buttons_Grow_Size), round(baseScreenHeight-HyperPause_SubMenu_Height+posVideoButton%V2Submenuitem%Y-HyperPause_Video_Buttons_Grow_Size), HyperPause_SubMenu_SizeofVideoButtons+2*HyperPause_Video_Buttons_Grow_Size, HyperPause_SubMenu_SizeofVideoButtons+2*HyperPause_Video_Buttons_Grow_Size)
                    }
                    PreviousVideoButton := V2Submenuitem
                }
            }
        settimer, UpdateVideoPlayingInfo, 100, Period
        }
    }    
    ;If txt file:
    If(CurrentFileExtension = "txt"){
        If(FullScreenView <> 1){
            ;TotaltxtPages := % TotalV2SubMenuItems%SubMenuName%%CurrentLabelNumber%
            TotaltxtPages := HPMediaObj[SubMenuName][CurrentLabelName].TotalV2SubMenuItems
        } Else {
            ;TotaltxtPages := % TotalFullScreenV2SubMenuItems%SubMenuName%%CurrentLabelNumber%
            TotaltxtPages := HPMediaObj[SubMenuName][CurrentLabelName].TotalFSV2SubMenuItems
        }
        If (HSubmenuitem%SubMenuName%V2Submenuitem%VSubmenuitem% > TotaltxtPages) {
            HSubmenuitem%SubMenuName%V2Submenuitem%VSubmenuitem% = % TotaltxtPages
            V2Submenuitem := % HSubmenuitem%SubMenuName%V2Submenuitem%VSubmenuitem%
        }
        TotalCurrentPages=2
        ;TextWidth := % FileTxtWidth%CurrentLabelNumber%
        TextWidth := HPMediaObj[SubMenuName][CurrentLabelName].txtWidth
        posPageText2X := 2*HMargin+MaxFontListWidth
        posPageText2Y := VMargin
        colorText := HyperPause_MainMenu_LabelDisabledColor
        If(FullScreenView <> 1){
            Width := HyperPause_SubMenu_Width-3*HMargin-MaxFontListWidth
            Height := HyperPause_SubMenu_Height-2*VMargin
            If(TextWidth<Width){
                posPageText2X := round(2*HMargin+MaxFontListWidth+(Width-TextWidth)/2)
            }  
            If(HSubMenuItem=2){
                colorText := HyperPause_MainMenu_LabelSelectedColor
            }   
            OptionsText2 = x%posPageText2X% y%posPageText2Y% Left c%colorText% r4 s%HyperPause_SubMenu_SmallFontSize% Regular
            ;Gdip_Alt_TextToGraphics(HP_G27, %SubMenuName%FileTxtContents%CurrentLabelNumber%Page%V2SubMenuItem%, OptionsText2, HyperPause_SubMenu_Font, Width, Height)
            Gdip_Alt_TextToGraphics(HP_G27, HPMediaObj[SubMenuName][CurrentLabelName]["Page" .  V2SubMenuItem], OptionsText2, HyperPause_SubMenu_Font, Width, Height)
            Gdip_GraphicsClear(HP_G29)
            Alt_UpdateLayeredWindow(HP_hwnd29, HP_hdc29,baseScreenWidth - HelpTextLenghtWidth - 2*HyperPause_SubMenu_AdditionalTextMarginContour,baseScreenHeight- HyperPause_SubMenu_SmallFontSize,HelpTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_HelpFontSize)
        }
    }
    ;If pdf file:
    If(CurrentFileExtension = "pdf"){
        If(HSubMenuItem=0){
            HSubmenuitem%SubMenuName%VSubmenuitem%VSubmenuitem% := 1
            HSubMenuItem := % HSubmenuitem%SubMenuName%VSubmenuitem%VSubmenuitem%
        }
        TotalCurrentPages := HPMediaObj[SubMenuName][CurrentLabelName].TotalItems 
        ;TotalCurrentPages := % TotalSubMenu%SubMenuName%Pages%CurrentLabelNumber% 
        IfNotExist, % HLMediaPath . "\" . SubMenuName . "\Temp\" . systemName . "\" . CurrentLabelName
            FileCreateDir, % HLMediaPath . "\" . SubMenuName . "\Temp\" . systemName . "\" . CurrentLabelName        
        if !((HyperPause_LoadPDFOnLabel="true") and (VSubMenuItem < 1))
        {   
            Loop, %TotalCurrentPages%
            {   
                If(A_index >= HSubMenuItem){
                    If(A_index > TotalCurrentPages){
                        AllPagesLoaded%CurrentLabelNumber% := true
                    }
                    If(posPageX > HyperPause_SubMenu_Width){
                        break   
                    }
                    If !(AllPagesLoaded%CurrentLabelNumber% = true){
                        IfNotExist, % HLMediaPath . "\" . SubMenuName . "\Temp\" . systemName . "\" . CurrentLabelName . "\" . "page" . A_Index . ".png"
                            {
                            if (FullScreenView = 1){
                                loadingPageTextWidth := MeasureText("Loading New Page", "Center r4 s" . HyperPause_SubMenu_FullScreenFontSize . " bold",HyperPause_SubMenu_Font)
                                Gdip_Alt_FillRoundedRectangle(HP_G29, HyperPause_SubMenu_FullScreenBrushV, round((baseScreenWidth-HyperPause_SubMenu_FullScreenMargin)/2 - loadingPageTextWidth/2 - HyperPause_SubMenu_AdditionalTextMarginContour), round((baseScreenHeight-HyperPause_SubMenu_FullScreenMargin)/2 - HyperPause_SubMenu_FullScreenFontSize), loadingPageTextWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour, 2*HyperPause_SubMenu_FullScreenFontSize,HyperPause_SubMenu_FullScreenRadiusofRoundedCorners)
                                loadingPageTextOptions := "x" . round((baseScreenWidth-HyperPause_SubMenu_FullScreenMargin)/2) . " y" . round((baseScreenHeight-HyperPause_SubMenu_FullScreenMargin)/2 - HyperPause_SubMenu_FullScreenFontSize/2) . " Center c" . HyperPause_SubMenu_FullScreenFontColor . " r4 s" . HyperPause_SubMenu_FullScreenFontSize . "bold"
                                Gdip_Alt_TextToGraphics(HP_G29, "Loading New Page", loadingPageTextOptions, HyperPause_SubMenu_Font, 0, 0)
                                Alt_UpdateLayeredWindow(HP_hwnd29, HP_hdc29,HyperPause_SubMenu_FullScreenMargin,HyperPause_SubMenu_FullScreenMargin,baseScreenWidth-2*HyperPause_SubMenu_FullScreenMargin,baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin)
                            } 
                            SubMenuHelpText("Please wait while pdf pages are loaded")
                            Alt_UpdateLayeredWindow(HP_hwnd27, HP_hdc27,baseScreenWidth-HyperPause_SubMenu_Width,baseScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
                            Log("Loaded PDF page " A_Index " and update " SelectedMenuOption " SubMenu.",5)
                            COM_Invoke(HLObject, "generatePngFromPdf", CurrentFilePath, HLMediaPath . "\" . SubMenuName . "\Temp\" . systemName . "\" . CurrentLabelName, HyperPause_SubMenu_PdfDpiResolution,pdfMaxHeight,a_index,a_index,HyperPause_PDF_Page_Layout)
                        }  
                    }
                    CurrentImage%a_index% := HLMediaPath . "\" . SubMenuName . "\Temp\" . systemName . "\" . CurrentLabelName . "\" . "page" . A_Index . ".png"
                    Gdip_DisposeImage(CurrentBitmap)
                    CurrentBitmap := Gdip_CreateBitmapFromFile(CurrentImage%a_index%)
                    If(HSubMenuItem = a_index){
                        SelectedImage := % CurrentImage%a_index%
                    }
                    BitmapW := Gdip_GetImageWidth(CurrentBitmap), BitmapH := Gdip_GetImageHeight(CurrentBitmap) 
                    resizedBitmapH := HyperPause_SubMenu_Height-2*VMargin-2*HyperPause_SubMenu_AdditionalTextMarginContour
                    resizedBitmapW := round(BitmapW/(BitmapH/resizedBitmapH))
                    If(resizedBitmapW > (HyperPause_SubMenu_Width-2*HMargin-HdistBetwLabelsandPages-MaxFontListWidth-2*HyperPause_SubMenu_AdditionalTextMarginContour)){
                        resizedBitmapW := HyperPause_SubMenu_Width-2*HMargin-HdistBetwLabelsandPages-MaxFontListWidth
                        resizedBitmapH := round(BitmapH/(BitmapW/resizedBitmapW)) 
                    }        
                    If((VSubMenuItem <> 0) and (HSubMenuItem = a_index)){
                        Gdip_Alt_FillRoundedRectangle(HP_G27, HyperPause_SubMenu_%SubMenuName%SelectedBrushV, posPageX, round((HyperPause_SubMenu_Height-resizedBitmapH)/2-HyperPause_SubMenu_AdditionalTextMarginContour), resizedBitmapW+2*HyperPause_SubMenu_AdditionalTextMarginContour, resizedBitmapH+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_RadiusofRoundedCorners)
                    }
                    Gdip_Alt_DrawImage(HP_G27, CurrentBitmap, posPageX+HyperPause_SubMenu_AdditionalTextMarginContour, round((HyperPause_SubMenu_Height-resizedBitmapH)/2), resizedBitmapW, resizedBitmapH)
                    if (showItemLabel = "true")
                    {   posPageTextX := posPageX+round((resizedBitmapW+2*HyperPause_SubMenu_AdditionalTextMarginContour)/2)
                        posPageTextY := HyperPause_SubMenu_Height-VMargin-HyperPause_SubMenu_AdditionalTextMarginContour-2*HyperPause_SubMenu_SmallFontSize
                        OptionsPage1 = x%posPageTextX% y%posPageTextY% Center c%PageNumberFontColor% r4 s%HyperPause_SubMenu_SmallFontSize% bold
                        Gdip_Alt_TextToGraphics(HP_G27, "Page " . a_index, OptionsPage1, HyperPause_SubMenu_Font, 0, 0)
                    }
                    If(VSubMenuItem = 0){
                        Gdip_Alt_FillRoundedRectangle(HP_G27, HyperPause_SubMenu_DisabledBrushV, posPageX, round((HyperPause_SubMenu_Height-resizedBitmapH)/2-HyperPause_SubMenu_AdditionalTextMarginContour), resizedBitmapW+2*HyperPause_SubMenu_AdditionalTextMarginContour, resizedBitmapH+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_RadiusofRoundedCorners)
                    }
                    If((VSubMenuItem <> 0) and (HSubMenuItem <> a_index)){
                        Gdip_Alt_FillRoundedRectangle(HP_G27, HyperPause_SubMenu_DisabledBrushV, posPageX, round((HyperPause_SubMenu_Height-resizedBitmapH)/2-HyperPause_SubMenu_AdditionalTextMarginContour), resizedBitmapW+2*HyperPause_SubMenu_AdditionalTextMarginContour, resizedBitmapH+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_RadiusofRoundedCorners)
                    }
                    posPageX := posPageX+resizedBitmapW+2*HyperPause_SubMenu_AdditionalTextMarginContour+HdistBetwPages                
                }
            }  
        }
    }
    ;If Compressed file
    If CurrentFileExtension in %7zFormatsNoP%,cbr,cbz
    {
        CurrentCompressedFileExtension = true
        HyperPause_7zExtractDir := HLMediaPath . "\" . SubMenuName . "\Temp\" . systemName . "\" . CurrentLabelName
        SubMenuHelpText("Please wait while compressed images are loaded")
        RunWait, %7zPath% e "%CurrentFilePath%" -aoa -o"%HyperPause_7zExtractDir%",,Hide ; perform the extraction and overwrite all
        currentobj := {}
        currentobj := HPMediaObj[SubMenuName][CurrentLabelName]
        Loop, % HLMediaPath . "\" . SubMenuName . "\Temp\" . systemName . "\" . CurrentLabelName . "\*.*"
            {
            currentobj["Path" . a_index] := A_LoopFileLongPath
            currentobj["Ext" . a_index] := A_LoopFileExt
            currentobj["TotalItems"] := a_index
            sleep, 500
        }
        if (currentobj.TotalItems>1)
            currentobj["Type"]:="ImageGroup"
        HPMediaObj[SubMenuLabel].Insert(currentobj["Label"], currentobj)             
    } Else {
        CurrentCompressedFileExtension = false
    }
    
    ;If image folder or compressed images:
    If((HPMediaObj[SubMenuName][CurrentLabelName].Type="ImageGroup") or (CurrentCompressedFileExtension="true")){
    ;If((HPMediaObj[SubMenuLabel][CurrentLabelName].Path2) or (CurrentCompressedFileExtension="true")){
        If(HSubMenuItem=0){
            HSubmenuitem%SubMenuName%VSubmenuitem%VSubmenuitem% := 1
            HSubMenuItem := % HSubmenuitem%SubMenuName%VSubmenuitem%VSubmenuitem%
        }
        TotalCurrentPages := HPMediaObj[SubMenuName][CurrentLabelName].TotalItems   
        ;TotalCurrentPages := % TotalSubMenu%SubMenuName%Pages%CurrentLabelNumber%  
        Loop, %TotalCurrentPages%
        {
            If(A_index >= HSubMenuItem){
                If(posPageX > HyperPause_SubMenu_Width){
                    break   
                }
                CurrentImage%a_index% := HPMediaObj[SubMenuName][CurrentLabelName]["Path" . a_index]
                ;CurrentImage%a_index% := % %SubMenuName%File%CurrentLabelNumber%File%a_index%
                Gdip_DisposeImage(CurrentBitmap)
                CurrentBitmap := Gdip_CreateBitmapFromFile(CurrentImage%a_index%)
                If(HSubMenuItem = a_index){
                    SelectedImage := % CurrentImage%a_index%
                }
                BitmapW := Gdip_GetImageWidth(CurrentBitmap), BitmapH := Gdip_GetImageHeight(CurrentBitmap)        
                resizedBitmapH := HyperPause_SubMenu_Height-2*VMargin-2*HyperPause_SubMenu_AdditionalTextMarginContour
                resizedBitmapW := round(BitmapW/(BitmapH/resizedBitmapH))
                If(resizedBitmapW > (HyperPause_SubMenu_Width-2*HMargin-HdistBetwLabelsandPages-MaxFontListWidth-2*HyperPause_SubMenu_AdditionalTextMarginContour)){
                    resizedBitmapW := HyperPause_SubMenu_Width-2*HMargin-HdistBetwLabelsandPages-MaxFontListWidth
                    resizedBitmapH := round(BitmapH/(BitmapW/resizedBitmapW)) 
                }        
                If((VSubMenuItem > 0) and (HSubMenuItem = a_index)){
                    Gdip_Alt_FillRoundedRectangle(HP_G27, HyperPause_SubMenu_%SubMenuName%SelectedBrushV, posPageX, round((HyperPause_SubMenu_Height-resizedBitmapH)/2-HyperPause_SubMenu_AdditionalTextMarginContour), resizedBitmapW+2*HyperPause_SubMenu_AdditionalTextMarginContour, resizedBitmapH+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_RadiusofRoundedCorners)
                }
                Gdip_Alt_DrawImage(HP_G27, CurrentBitmap, posPageX+HyperPause_SubMenu_AdditionalTextMarginContour, round((HyperPause_SubMenu_Height-resizedBitmapH)/2), resizedBitmapW, resizedBitmapH)
                if (showItemLabel = "true")
                {   SplitPath, CurrentImage%a_index%, , , , FileNameText
                    posPageTextX := posPageX+HyperPause_SubMenu_AdditionalTextMarginContour
                    posPageTextY := HyperPause_SubMenu_Height-VMargin-HyperPause_SubMenu_AdditionalTextMarginContour-1.3*HyperPause_SubMenu_SmallFontSize-HyperPause_SubMenu_SmallFontSize*(ceil(MeasureText(FileNameText, "Left r4 s" . HyperPause_SubMenu_SmallFontSize . " bold",HyperPause_SubMenu_Font)/resizedBitmapW))
                    OptionsPage1 = x%posPageTextX% y%posPageTextY% w%resizedBitmapW% Center c%PageNumberFontColor% r4 s%HyperPause_SubMenu_SmallFontSize% bold
                    Gdip_Alt_TextToGraphics(HP_G27, FileNameText, OptionsPage1, HyperPause_SubMenu_Font, 0, 0)
                }
                If(VSubMenuItem <= 0){
                    Gdip_Alt_FillRoundedRectangle(HP_G27, HyperPause_SubMenu_DisabledBrushV, posPageX, round((HyperPause_SubMenu_Height-resizedBitmapH)/2-HyperPause_SubMenu_AdditionalTextMarginContour), resizedBitmapW+2*HyperPause_SubMenu_AdditionalTextMarginContour, resizedBitmapH+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_RadiusofRoundedCorners)
                }
                If((VSubMenuItem <> 0) and (HSubMenuItem <> a_index)){
                    Gdip_Alt_FillRoundedRectangle(HP_G27, HyperPause_SubMenu_DisabledBrushV, posPageX, round((HyperPause_SubMenu_Height-resizedBitmapH)/2-HyperPause_SubMenu_AdditionalTextMarginContour), resizedBitmapW+2*HyperPause_SubMenu_AdditionalTextMarginContour, resizedBitmapH+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_RadiusofRoundedCorners)
                }
                posPageX := posPageX+resizedBitmapW+2*HyperPause_SubMenu_AdditionalTextMarginContour+HdistBetwPages                
            }
        }  
    } else If CurrentFileExtension in %Supported_Images% ;If image file:
        { 
        TotalCurrentPages=1
        SelectedImage := CurrentFilePath
        Gdip_DisposeImage(SelectedBitmap)
        SelectedBitmap := Gdip_CreateBitmapFromFile(SelectedImage)
        BitmapW := Gdip_GetImageWidth(SelectedBitmap), BitmapH := Gdip_GetImageHeight(SelectedBitmap) 
        resizedBitmapH := HyperPause_SubMenu_Height-2*VMargin-2*HyperPause_SubMenu_AdditionalTextMarginContour
        resizedBitmapW := round(BitmapW/(BitmapH/resizedBitmapH))
        If(resizedBitmapW > (HyperPause_SubMenu_Width-2*HMargin-HMargin-MaxFontListWidth-2*HyperPause_SubMenu_AdditionalTextMarginContour)){
            resizedBitmapW := HyperPause_SubMenu_Width-2*HMargin-HMargin-MaxFontListWidth
            resizedBitmapH := round(BitmapH/(BitmapW/resizedBitmapW)) 
        }         
        If(FullScreenView <> 1){
            Gdip_Alt_FillRoundedRectangle(HP_G27, HyperPause_SubMenu_DisabledBrushV, round((HyperPause_SubMenu_Width-resizedBitmapW+MaxFontListWidth+HMargin)/2-HyperPause_SubMenu_AdditionalTextMarginContour), round((HyperPause_SubMenu_Height-resizedBitmapH)/2-HyperPause_SubMenu_AdditionalTextMarginContour), resizedBitmapW+2*HyperPause_SubMenu_AdditionalTextMarginContour, resizedBitmapH+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_RadiusofRoundedCorners)
            Gdip_Alt_DrawImage(HP_G27, SelectedBitmap, round((HyperPause_SubMenu_Width+MaxFontListWidth+HMargin-resizedBitmapW)/2), round((HyperPause_SubMenu_Height-resizedBitmapH)/2), resizedBitmapW, resizedBitmapH)
        }
    }
    ;full screen view
    If(VSubMenuItem>=0){
    If(FullScreenView = 1){
        Gdip_GraphicsClear(HP_G29)
        pGraphUpd(HP_G29,baseScreenWidth-2*HyperPause_SubMenu_FullScreenMargin,baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin) 
        If CurrentFileExtension in %ListofSupportedVideos%    
            {       
        } Else If(CurrentFileExtension = "txt"){
            If(HSubMenuItem=2){
            Width := baseScreenWidth - 4*HyperPause_SubMenu_FullScreenMargin
            Height := baseScreenHeight - 4*HyperPause_SubMenu_FullScreenMargin
            posTextFullScreenX := 2*HyperPause_SubMenu_FullScreenMargin 
            posTextFullScreenY := 2*HyperPause_SubMenu_FullScreenMargin
            If(TextWidth<Width){
                posTextFullScreenX := round(2*HyperPause_SubMenu_FullScreenMargin + (Width-TextWidth)/2)
            }           
            colorText := HyperPause_MainMenu_LabelSelectedColor
            Gdip_Alt_FillRoundedRectangle(HP_G29, HyperPause_SubMenu_FullScreenTextBrushV, posTextFullScreenX-HyperPause_SubMenu_FullScreenMargin, HyperPause_SubMenu_FullScreenMargin, TextWidth+2*HyperPause_SubMenu_FullScreenMargin, Height+2*HyperPause_SubMenu_FullScreenMargin, HyperPause_SubMenu_FullScreenRadiusofRoundedCorners)
            OptionsTextFullScreen = x%posTextFullScreenX% y%posTextFullScreenY% Left c%colorText% r4 s%HyperPause_SubMenu_SmallFontSize% Regular
            textFullScreen := HPMediaObj[SubMenuName][CurrentLabelName]["FSPage" .  V2SubMenuItem]
            ;textFullScreen := %SubMenuName%FileTxtContents%CurrentLabelNumber%FullScreenPage%V2SubMenuItem%
            Gdip_Alt_TextToGraphics(HP_G29, HPMediaObj[SubMenuName][CurrentLabelName]["FSPage" .  V2SubMenuItem], OptionsTextFullScreen, HyperPause_SubMenu_Font, Width, Height)
            If HyperPause_SubMenu_FullSCreenHelpTextTimer
                { 
                HyperPause_SubMenu_FullScreenHelpBoxHeight := 5*HyperPause_SubMenu_FullScreenFontSize
                HyperPause_SubMenu_FullScreenHelpBoxWidth := MeasureText("Press Up for Page Up or Press Down for Page Down", "Left r4 s" . HyperPause_SubMenu_FullScreenFontSize . " bold",HyperPause_SubMenu_Font)+HyperPause_SubMenu_AdditionalTextMarginContour
                Gdip_Alt_FillRoundedRectangle(HP_G29, HyperPause_SubMenu_FullScreenBrushV, round((baseScreenWidth-HyperPause_SubMenu_FullScreenHelpBoxWidth)/2-HyperPause_SubMenu_FullScreenMargin), baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin-6*HyperPause_SubMenu_FullScreenFontSize, HyperPause_SubMenu_FullScreenHelpBoxWidth,HyperPause_SubMenu_FullScreenHelpBoxHeight,HyperPause_SubMenu_FullScreenRadiusofRoundedCorners)
                posFullScreenTextX := round(baseScreenWidth/2-HyperPause_SubMenu_FullScreenMargin)
                posFullScreenTextY := round(baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin-5*HyperPause_SubMenu_FullScreenFontSize-HyperPause_SubMenu_FullScreenFontSize/2)
                OptionsFullScreenText = x%posFullScreenTextX% y%posFullScreenTextY% Center c%HyperPause_SubMenu_FullScreenFontColor% r4 s%HyperPause_SubMenu_FullScreenFontSize% bold
                CurrentHelpText = Press Select Key to Exit Full Screen`nPress Up for Page Up or Press Down for Page Down`nPage %V2SubMenuItem% of %TotaltxtPages%
                Gdip_Alt_TextToGraphics(HP_G29, CurrentHelpText, OptionsFullScreenText, HyperPause_SubMenu_Font, 0, 0)
                if !(HyperPause_SubMenu_FullSCreenHelpTextTimer="always"){
                    savedHSubMenuItem := HSubMenuItem
                    savedVSubMenuItem := VSubMenuItem
                    savedV2SubMenuItem := V2SubMenuItem
                    SetTimer, ClearFullScreenHelpText1, -%HyperPause_SubMenu_FullSCreenHelpTextTimer% 
                }
            }
            Alt_UpdateLayeredWindow(HP_hwnd29, HP_hdc29,HyperPause_SubMenu_FullScreenMargin,HyperPause_SubMenu_FullScreenMargin,baseScreenWidth-2*HyperPause_SubMenu_FullScreenMargin,baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin) 
            } Else {
                Gdip_GraphicsClear(HP_G29)
                Alt_UpdateLayeredWindow(HP_hwnd29, HP_hdc29,HyperPause_SubMenu_FullScreenMargin,HyperPause_SubMenu_FullScreenMargin,baseScreenWidth-2*HyperPause_SubMenu_FullScreenMargin,baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin) 
                FullScreenView = 0
            }
        } Else {
            Gdip_DisposeImage(SelectedBitmap)
            SelectedBitmap := Gdip_CreateBitmapFromFile(SelectedImage)
            BitmapW := Gdip_GetImageWidth(SelectedBitmap), BitmapH := Gdip_GetImageHeight(SelectedBitmap) 
            resizedBitmapH := baseScreenHeight - 2*HyperPause_SubMenu_FullScreenMargin
            resizedBitmapW := round(BitmapW/(BitmapH/resizedBitmapH))
            If(resizedBitmapW > baseScreenWidth - 2*HyperPause_SubMenu_FullScreenMargin){
                resizedBitmapW := baseScreenWidth - 2*HyperPause_SubMenu_FullScreenMargin
                resizedBitmapH := round(BitmapH/(BitmapW/resizedBitmapW))
            }
            Gdip_Alt_DrawImage(HP_G29, SelectedBitmap, round((baseScreenWidth-resizedBitmapW)/2-HyperPause_SubMenu_FullScreenMargin+HorizontalPanFullScreen+(resizedBitmapW-resizedBitmapW*ZoomLevel/100)/2), round((baseScreenHeight-resizedBitmapH)/2-HyperPause_SubMenu_FullScreenMargin+VerticalPanFullScreen+(resizedBitmapH-resizedBitmapH*ZoomLevel/100)/2), round(resizedBitmapW*ZoomLevel/100), round(resizedBitmapH*ZoomLevel/100))
            If HyperPause_SubMenu_FullSCreenHelpTextTimer
                {
                HyperPause_SubMenu_FullScreenHelpBoxHeight := 7*HyperPause_SubMenu_FullScreenFontSize
                HyperPause_SubMenu_FullScreenHelpBoxWidth := MeasureText("(Press Zoom In or Zoom Out Keys to Change Zoom Level)", "Left r4 s" . HyperPause_SubMenu_FullScreenFontSize . " bold",HyperPause_SubMenu_Font)+HyperPause_SubMenu_AdditionalTextMarginContour
                Gdip_Alt_FillRoundedRectangle(HP_G29, HyperPause_SubMenu_FullScreenBrushV, round((baseScreenWidth-HyperPause_SubMenu_FullScreenHelpBoxWidth)/2-HyperPause_SubMenu_FullScreenMargin), baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin-8*HyperPause_SubMenu_FullScreenFontSize, HyperPause_SubMenu_FullScreenHelpBoxWidth,HyperPause_SubMenu_FullScreenHelpBoxHeight,HyperPause_SubMenu_FullScreenRadiusofRoundedCorners)
                posFullScreenTextX := round(baseScreenWidth/2-HyperPause_SubMenu_FullScreenMargin)
                posFullScreenTextY := round(baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin-7*HyperPause_SubMenu_FullScreenFontSize-HyperPause_SubMenu_FullScreenFontSize/2)
                OptionsFullScreenText = x%posFullScreenTextX% y%posFullScreenTextY% Center c%HyperPause_SubMenu_FullScreenFontColor% r4 s%HyperPause_SubMenu_FullScreenFontSize% bold
                Gdip_Alt_TextToGraphics(HP_G29, "Press Select Key to Exit Full Screen`nPress Left or Right to Change Pages while 100% Zoom`nZoom Level: " . ZoomLevel . "%`n(Press Zoom In or Zoom Out Keys to Change Zoom Level)`n(Press Up, Down Left or Right to Pan in Zoom Mode)", OptionsFullScreenText, HyperPause_SubMenu_Font, 0, 0)
                if (showItemLabel = "true")
                {   SplitPath, SelectedImage, , , , FileNameText
                    posPageTextX := (baseScreenWidth-2*HyperPause_SubMenu_FullScreenMargin) //2
                    posPageTextY := HyperPause_SubMenu_FullScreenMargin > round((baseScreenHeight-resizedBitmapH)/2-HyperPause_SubMenu_FullScreenMargin+VerticalPanFullScreen+(resizedBitmapH-resizedBitmapH*ZoomLevel/100)/2)+HyperPause_SubMenu_SmallFontSize//2 ? HyperPause_SubMenu_FullScreenMargin : round((baseScreenHeight-resizedBitmapH)/2-HyperPause_SubMenu_FullScreenMargin+VerticalPanFullScreen+(resizedBitmapH-resizedBitmapH*ZoomLevel/100)/2)+HyperPause_SubMenu_SmallFontSize//2
                    OptionsPage1 = x%posPageTextX% y%posPageTextY% Center c%HyperPause_SubMenu_FullScreenFontColor% r4 s%HyperPause_SubMenu_SmallFontSize% bold
                    Gdip_Alt_FillRectangle(HP_G29, HyperPause_SubMenu_FullScreenBrushV, posPageTextX-(round( MeasureText(FileNameText, "Left r4 s" . HyperPause_SubMenu_SmallFontSize . " bold",HyperPause_SubMenu_Font)+HyperPause_SubMenu_AdditionalTextMarginContour))//2, posPageTextY-HyperPause_SubMenu_SmallFontSize//2, round( MeasureText(FileNameText, "Left r4 s" . HyperPause_SubMenu_SmallFontSize . " bold",HyperPause_SubMenu_Font)+HyperPause_SubMenu_AdditionalTextMarginContour), HyperPause_SubMenu_SmallFontSize+HyperPause_SubMenu_AdditionalTextMarginContour)
                    Gdip_Alt_TextToGraphics(HP_G29, FileNameText, OptionsPage1, HyperPause_SubMenu_Font, 0, 0)
                }
                if !(HyperPause_SubMenu_FullSCreenHelpTextTimer="always"){
                    savedHSubMenuItem := HSubMenuItem
                    savedVSubMenuItem := VSubMenuItem
                    savedV2SubMenuItem := V2SubMenuItem
                    SetTimer, ClearFullScreenHelpText2, -%HyperPause_SubMenu_FullSCreenHelpTextTimer% 
                }
            }
            Alt_UpdateLayeredWindow(HP_hwnd29, HP_hdc29,HyperPause_SubMenu_FullScreenMargin,HyperPause_SubMenu_FullScreenMargin,baseScreenWidth-2*HyperPause_SubMenu_FullScreenMargin,baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin)
        }
        SubMenuHelpText("Press Select Key to exit FullScreen")
    } Else If(VSubMenuItem <> 0){
        If(CurrentFileExtension = "txt"){
            If(HSubMenuItem=1){
                CurrentHelpText = Press Left or Right to Select the Text Information - Page %V2SubMenuItem% of %TotaltxtPages%
                SubMenuHelpText(CurrentHelpText)
            } Else {
                CurrentHelpText = Press Select Key to go FullScreen - Page %V2SubMenuItem% of %TotaltxtPages%
                SubMenuHelpText(CurrentHelpText)
            }
        } Else {
            SubMenuHelpText("Press Select Key to go FullScreen")
        }
    } Else {
        Gdip_GraphicsClear(HP_G29)
        Alt_UpdateLayeredWindow(HP_hwnd29, HP_hdc29,HyperPause_SubMenu_FullScreenMargin,HyperPause_SubMenu_FullScreenMargin,baseScreenWidth-2*HyperPause_SubMenu_FullScreenMargin,baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin)
        Gdip_GraphicsClear(HP_G33)
        Alt_UpdateLayeredWindow(HP_hwnd33, HP_hdc33,0,0,baseScreenWidth,baseScreenHeight)
        FullScreenView = 0
    }
    }
   FunctionRunning := false
Return    
}

ClearFullScreenHelpText1:
    if (savedHSubMenuItem=HSubMenuItem) and (savedVSubMenuItem=VSubMenuItem) and (savedV2SubMenuItem=V2SubMenuItem) {
        Gdip_GraphicsClear(HP_G29)
        pGraphUpd(HP_G29,baseScreenWidth-2*HyperPause_SubMenu_FullScreenMargin,baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin) 
        Gdip_Alt_FillRoundedRectangle(HP_G29, HyperPause_SubMenu_FullScreenTextBrushV, posTextFullScreenX-HyperPause_SubMenu_FullScreenMargin, HyperPause_SubMenu_FullScreenMargin, TextWidth+2*HyperPause_SubMenu_FullScreenMargin, Height+2*HyperPause_SubMenu_FullScreenMargin, HyperPause_SubMenu_FullScreenRadiusofRoundedCorners)
        Gdip_Alt_TextToGraphics(HP_G29, textFullScreen, OptionsTextFullScreen, HyperPause_SubMenu_Font, Width, Height)
        Alt_UpdateLayeredWindow(HP_hwnd29, HP_hdc29,HyperPause_SubMenu_FullScreenMargin,HyperPause_SubMenu_FullScreenMargin,baseScreenWidth-2*HyperPause_SubMenu_FullScreenMargin,baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin) 
    }
Return


ClearFullScreenHelpText2:
    if (savedHSubMenuItem=HSubMenuItem) and (savedVSubMenuItem=VSubMenuItem) and (savedV2SubMenuItem=V2SubMenuItem) {
        Gdip_GraphicsClear(HP_G29)
        pGraphUpd(HP_G29,baseScreenWidth-2*HyperPause_SubMenu_FullScreenMargin,baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin)
        Gdip_Alt_DrawImage(HP_G29, SelectedBitmap, round((baseScreenWidth-resizedBitmapW)/2-HyperPause_SubMenu_FullScreenMargin+HorizontalPanFullScreen+(resizedBitmapW-resizedBitmapW*ZoomLevel/100)/2), round((baseScreenHeight-resizedBitmapH)/2-HyperPause_SubMenu_FullScreenMargin+VerticalPanFullScreen+(resizedBitmapH-resizedBitmapH*ZoomLevel/100)/2), round(resizedBitmapW*ZoomLevel/100), round(resizedBitmapH*ZoomLevel/100))
        Alt_UpdateLayeredWindow(HP_hwnd29, HP_hdc29,HyperPause_SubMenu_FullScreenMargin,HyperPause_SubMenu_FullScreenMargin,baseScreenWidth-2*HyperPause_SubMenu_FullScreenMargin,baseScreenHeight-2*HyperPause_SubMenu_FullScreenMargin)
    }
Return


ReadMovesListInformation() ;Reading Moves List info
{
    Global
    count:=0
    Loop {
        MovesListItem%A_index%  := StrX( RomCommandDatText ,  "$cmd" ,N,4, "$end",1,4,  N )
        If (!(MovesListItem%A_index%))
            break
        count++
        MovesListLabel%A_index%:=StrX(MovesListItem%A_index%,"[",1,1,"]",1,1)	
        StringReplace, MovesListItem%A_index%, MovesListItem%A_index%, % MovesListLabel%A_index%,, All
        StringReplace, MovesListItem%A_index%, MovesListItem%A_index%, [],, All
        MovesListItem%A_index%:=RegExReplace(MovesListItem%A_index%,"^\s*","") ; remove leading
        MovesListItem%A_index%:=RegExReplace(MovesListItem%A_index%,"\s*$","") ; remove trailing
        StringReplace, MovesListLabel%A_index%, MovesListLabel%A_index%,-,, All
        StringReplace, MovesListLabel%A_index%, MovesListLabel%A_index%, —,, All
    }
    currentObj := {}
    currentObj["TotalLabels"] := count
    HPMediaObj.Insert("MovesList", currentObj)
    If (HPMediaObj["MovesList"].TotalLabels<>0){    ;Loading button images
        If FileExist(HyperPause_MovesListImagePath . systemName . "\"  . dbName . "\*.png")
            HyperPause_MovesListCurrentPath := HyperPause_MovesListImagePath . systemName . "\"  . dbName . "\"
        Else If FileExist(HyperPause_MovesListImagePath . systemName . "\"  . DescriptionNameWithoutDisc . "\*.png")
            HyperPause_MovesListCurrentPath := HyperPause_MovesListImagePath . systemName . "\"  . DescriptionNameWithoutDisc . "\"
        Else If FileExist(HyperPause_MovesListImagePath . systemName . "\_Default\*.png")
            HyperPause_MovesListCurrentPath := HyperPause_MovesListImagePath . systemName . "\_Default\"
        Else FileExist(HyperPause_MovesListImagePath . "_Default\*.png")
            HyperPause_MovesListCurrentPath := HyperPause_MovesListImagePath . "_Default\"
        Log("Moves List icons path: " . HyperPause_MovesListCurrentPath,5)
        Loop, %HyperPause_MovesListCurrentPath%\*.png, 0
            { 
            StringTrimRight, FileNameWithoutExtension, A_LoopFileName, 4 
            CommandDatImageFileList .= FileNameWithoutExtension . "`,"
            CommandDatfile%A_index% = %A_LoopFileFullPath%
            CommandDatBitmap%A_index% := Gdip_CreateBitmapFromFile(CommandDatfile%A_index%)
            TotalCommandDatImageFiles++
            }
        VMargin := % HyperPause_%temp_mainmenulabel%_VMargin ;Number of Lines per page
        LinesperPage%temp_mainmenulabel% := floor((HyperPause_SubMenu_Height-VMargin)/HyperPause_MovesList_VdistBetwMovesListLabels)
        LinesperFullScreenPage%temp_mainmenulabel% := floor((baseScreenHeight - 4*HyperPause_SubMenu_FullScreenMargin  - 5*HyperPause_SubMenu_FullScreenFontSize)/HyperPause_MovesList_VdistBetwMovesListLabels)  ;Number of lines in Full Screen
        Loop, % HPMediaObj["MovesList"].TotalLabels ;Total number of pages
            {
            currentLabelNumber := A_index
            stringreplace, TempAuxMovesListItem%currentLabelNumber%, MovesListItem%currentLabelNumber%, `r`n,¿,all
            Loop, parse, TempAuxMovesListItem%currentLabelNumber%, ¿
                {
                If A_LoopField contains %Lettersandnumbers%  
                    {
                    %temp_mainmenulabel%TotalNumberofLines%currentLabelNumber%++
                }
            }
            %temp_mainmenulabel%TotalNumberofPages%currentLabelNumber% = % %temp_mainmenulabel%TotalNumberofLines%currentLabelNumber% / LinesperPage%temp_mainmenulabel% 
            %temp_mainmenulabel%TotalNumberofFullScreenPages%currentLabelNumber% = % %temp_mainmenulabel%TotalNumberofLines%currentLabelNumber% / LinesperFullScreenPage%temp_mainmenulabel% 
            %temp_mainmenulabel%TotalNumberofPages%currentLabelNumber% := ceil(%temp_mainmenulabel%TotalNumberofPages%currentLabelNumber%)
            %temp_mainmenulabel%TotalNumberofFullScreenPages%currentLabelNumber% := ceil(%temp_mainmenulabel%TotalNumberofFullScreenPages%currentLabelNumber%)
        }
    }
Return
}


CreatingStatisticsVariablestoSubmenu()
    {
    Global
    If(Initial_General_Statistics_Statistic_1=0){
        Value_General_Statistics_Statistic_1 := "Never"
    } Else If (Initial_General_Statistics_Statistic_1=1) {
        Value_General_Statistics_Statistic_1 := Initial_General_Statistics_Statistic_1 . " time"
    } Else {
        Value_General_Statistics_Statistic_1 := Initial_General_Statistics_Statistic_1 . " times"
    }  
    If(Initial_General_Statistics_Statistic_2=0){
        Value_General_Statistics_Statistic_2 := "Never"
    } Else {
        FormatTime, Value_General_Statistics_Statistic_2, %gameSectionStartHour%, dddd MMMM d, yyyy hh:mm:ss tt
    }
    If (Initial_General_Statistics_Statistic_3>0)
        Value_General_Statistics_Statistic_3 := GetTimeString(Initial_General_Statistics_Statistic_3) . " per session"
    Value_General_Statistics_Statistic_4 := GetTimeString(Initial_General_Statistics_Statistic_4)
    Value_General_Statistics_Statistic_5 := GetTimeString(Initial_General_Statistics_Statistic_5)
    Value_General_Statistics_Statistic_6 := GetTimeString(Initial_General_Statistics_Statistic_6) 
    Loop, 10 {
        Value_System_Top_Ten_Most_Played_Name_%a_index% := Initial_System_Top_Ten_Most_Played_Name_%a_index%
        Value_System_Top_Ten_Most_Played_Number_%a_index% := GetTimeString(Initial_System_Top_Ten_Most_Played_Number_%a_index%)
        Value_System_Top_Ten_Times_Played_Name_%a_index% := Initial_System_Top_Ten_Times_Played_Name_%a_index%
        If(Initial_System_Top_Ten_Times_Played_Number_%a_index% = 1){
            Value_System_Top_Ten_Times_Played_Number_%a_index% := Initial_System_Top_Ten_Times_Played_Number_%a_index% . " time"
        }
        If (Initial_System_Top_Ten_Times_Played_Number_%a_index% > 1){
            Value_System_Top_Ten_Times_Played_Number_%a_index% := Initial_System_Top_Ten_Times_Played_Number_%a_index% . " times"
        }
        Value_System_Top_Ten_Average_Time_Name_%a_index% := Initial_System_Top_Ten_Average_Time_Name_%a_index%
        If (Initial_System_Top_Ten_Average_Time_Number_%a_index%>0)
            Value_System_Top_Ten_Average_Time_Number_%a_index% := GetTimeString(Initial_System_Top_Ten_Average_Time_Number_%a_index%) . " per session"

        Value_Global_Last_Played_Games_System_%a_index% := Initial_Global_Last_Played_Games_System_%a_index%
        Value_Global_Last_Played_Games_Name_%a_index% := Initial_Global_Last_Played_Games_Name_%a_index% 
        Value_Global_Last_Played_Games_Date_%a_index% := Initial_Global_Last_Played_Games_Date_%a_index%
        Value_Global_Top_Ten_System_Most_Played_Name_%a_index% := Initial_Global_Top_Ten_System_Most_Played_Name_%a_index%
        Value_Global_Top_Ten_System_Most_Played_Number_%a_index% := GetTimeString(Initial_Global_Top_Ten_System_Most_Played_Number_%a_index%)
        Value_Global_Top_Ten_Most_Played_System_%a_index% := Initial_Global_Top_Ten_Most_Played_System_%a_index%
        Value_Global_Top_Ten_Most_Played_Name_%a_index% := Initial_Global_Top_Ten_Most_Played_Name_%a_index%
        Value_Global_Top_Ten_Most_Played_Number_%a_index% := GetTimeString(Initial_Global_Top_Ten_Most_Played_Number_%a_index%)
        Value_Global_Top_Ten_Times_Played_System_%a_index% := Initial_Global_Top_Ten_Times_Played_System_%a_index%
        Value_Global_Top_Ten_Times_Played_Name_%a_index% := Initial_Global_Top_Ten_Times_Played_Name_%a_index%
        If(Initial_Global_Top_Ten_Times_Played_Number_%a_index% = 1){
            Value_Global_Top_Ten_Times_Played_Number_%a_index% := Initial_Global_Top_Ten_Times_Played_Number_%a_index% . " time"
        }
        If (Initial_Global_Top_Ten_Times_Played_Number_%a_index% > 1){
            Value_Global_Top_Ten_Times_Played_Number_%a_index% := Initial_Global_Top_Ten_Times_Played_Number_%a_index% . " times"
        }
        Value_Global_Top_Ten_Average_Time_System_%a_index% := Initial_Global_Top_Ten_Average_Time_System_%a_index%
        Value_Global_Top_Ten_Average_Time_Name_%a_index% := Initial_Global_Top_Ten_Average_Time_Name_%a_index%
        If (Initial_Global_Top_Ten_Average_Time_Number_%a_index%>0)
            Value_Global_Top_Ten_Average_Time_Number_%a_index% := GetTimeString(Initial_Global_Top_Ten_Average_Time_Number_%a_index%) . " per session"
    }
Return
}

;--------------------

SubMenuHelpText(HelpText) ;SubMenu Help Text drawn function
    {
    Global
    Gdip_GraphicsClear(HP_G33)
    HelpTextLenghtWidth := MeasureText(HelpText, "Left r4 s" . HyperPause_SubMenu_HelpFontSize . " Regular",HyperPause_SubMenu_HelpFont)
    pGraphUpd(HP_G33,HelpTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_HelpFontSize)
    posHelpX := round(HelpTextLenghtWidth/2 + HyperPause_SubMenu_AdditionalTextMarginContour)
    OptionsHelp = x%posHelpX% y0 Center c%HyperPause_MainMenu_LabelDisabledColor% r4 s%HyperPause_SubMenu_HelpFontSize% Regular
    Gdip_Alt_FillRectangle(HP_G33, HyperPause_SubMenu_DisabledBrushV, 0, 0, HelpTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_HelpFontSize)
    Gdip_Alt_TextToGraphics(HP_G33, HelpText, OptionsHelp, HyperPause_SubMenu_HelpFont, 0, 0)
    Alt_UpdateLayeredWindow(HP_hwnd33, HP_hdc33,baseScreenWidth - HelpTextLenghtWidth - 2*HyperPause_SubMenu_AdditionalTextMarginContour,baseScreenHeight- HyperPause_SubMenu_SmallFontSize,HelpTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_HelpFontSize)
    Return    
}

DisableKeys:
    Log("Disable HyperPause Keys",4)
    XHotKeywrapper(navLeftKey,"MoveLeft","OFF")
    XHotKeywrapper(navRightKey,"MoveRight","OFF")
    XHotKeywrapper(navUpKey,"MoveUp","OFF")
    XHotKeywrapper(navDownKey,"MoveDown","OFF")
    XHotKeywrapper(navSelectKey,"ToggleItemSelectStatus","OFF")
    XHotKeywrapper(navP2LeftKey,"MoveLeft","OFF")
    XHotKeywrapper(navP2RightKey,"MoveRight","OFF")
    XHotKeywrapper(navP2UpKey,"MoveUp","OFF")
    XHotKeywrapper(navP2DownKey,"MoveDown","OFF")
    XHotKeywrapper(navP2SelectKey,"ToggleItemSelectStatus","OFF")
    XHotKeywrapper(hpBackToMenuBarKey,"BacktoMenuBar","OFF")
    XHotKeywrapper(hpZoomInKey,"ZoomIn","OFF")
    XHotKeywrapper(hpZoomOutKey,"ZoomOut","OFF")
    XHotKeywrapper(exitEmulatorKey,"TogglePauseMenuStatus","OFF")
    XHotKeywrapper(hpKey,"TogglePauseMenuStatus","OFF")
    If(HyperPause_EnableMouseControl = "true")
        hotkey, LButton, hpMouseClick, Off
    Log("HyperPause Keys Disabled",5)
Return

EnableKeys:
    Log("Enable HyperPause Keys",4)
    XHotKeywrapper(navSelectKey,"ToggleItemSelectStatus","ON")
    XHotKeywrapper(navLeftKey,"MoveLeft","ON")
    XHotKeywrapper(navRightKey,"MoveRight","ON")
    XHotKeywrapper(navUpKey,"MoveUp","ON")
    XHotKeywrapper(navDownKey,"MoveDown","ON")
    XHotKeywrapper(hpBackToMenuBarKey,"BacktoMenuBar","ON")
    XHotKeywrapper(hpZoomInKey,"ZoomIn","ON")
    XHotKeywrapper(hpZoomOutKey,"ZoomOut","ON")
    XHotKeywrapper(exitEmulatorKey,"TogglePauseMenuStatus","ON")
    XHotKeywrapper(hpKey,"TogglePauseMenuStatus","ON")
    XHotKeywrapper(navP2LeftKey,"MoveLeft","ON")
    XHotKeywrapper(navP2RightKey,"MoveRight","ON")
    XHotKeywrapper(navP2UpKey,"MoveUp","ON")
    XHotKeywrapper(navP2DownKey,"MoveDown","ON")
    XHotKeywrapper(navP2SelectKey,"ToggleItemSelectStatus","ON") 
    If(HyperPause_EnableMouseControl = "true")
        hotkey, LButton, hpMouseClick, On
    Log("HyperPause Keys Enabled",5)
Return


LoadExternalVariables:
;-----------------------------------------------------------------------------------------------------------------------------------------
 ; Paths
;-----------------------------------------------------------------------------------------------------------------------------------------
    SplitPath, hpHiToTextPath, , hpHitoTextDir
    ;HyperPause General Media Paths
    HyperPause_MenuSoundPath := HLMediaPath . "\Sounds\Menu\"
    HyperPause_MouseSoundPath := HLMediaPath . "\Sounds\Mouse\" 
    HyperPause_IconsImagePath := HLMediaPath . "\Menu Images\HyperPause\Icons\" 
    HyperPause_MouseOverlayPath := HLMediaPath . "\Menu Images\HyperPause\Mouse Overlay\" 
    ;HyperPause Menu Media Paths
    HyperPause_ControllerPath := HLMediaPath . "\Controller\"
    IfNotExist, %HyperPause_ControllerPath%
		FileCreateDir, %HyperPause_ControllerPath%
    HyperPause_ControllerTempPath := HLMediaPath . "\Controller\Temp\" . systemName . "\"
    HyperPause_ArtworkPath := HLMediaPath . "\Artwork\"
    IfNotExist, %HyperPause_ArtworkPath%
		FileCreateDir, %HyperPause_ArtworkPath%
    HyperPause_ArtworkTempPath := HLMediaPath . "\Artwork\Temp\" . systemName . "\"
    HyperPause_GuidesPath := HLMediaPath . "\Guides\"
    IfNotExist, %HyperPause_GuidesPath%
		FileCreateDir, %HyperPause_GuidesPath%
    HyperPause_GuidesTempPath := HLMediaPath . "\Guides\Temp\" . systemName . "\"
    HyperPause_ManualsPath := HLMediaPath . "\Manuals\"
    IfNotExist, %HyperPause_ManualsPath%
		FileCreateDir, %HyperPause_ManualsPath%
    HyperPause_ManualsTempPath := HLMediaPath . "\Manuals\Temp\" . systemName . "\"
    HyperPause_VideosPath := HLMediaPath . "\Videos\"
    IfNotExist, %HyperPause_VideosPath%
		FileCreateDir, %HyperPause_VideosPath%
    multiGameImgPath := HLMediaPath . "\MultiGame\"
    IfNotExist, %multiGameImgPath%
        FileCreateDir, %multiGameImgPath%
    HyperPause_BackgroundsPath := HLMediaPath . "\Backgrounds\"
    IfNotExist, %HyperPause_BackgroundsPath%
        FileCreateDir, %HyperPause_BackgroundsPath%
    HyperPause_MusicPath := HLMediaPath . "\Music\"
    IfNotExist, %HyperPause_MusicPath%
        FileCreateDir, %HyperPause_MusicPath%
    HyperPause_MovesListImagePath := HLMediaPath . "\Moves List\" 
    IfNotExist, %HyperPause_MovesListImagePath%
		FileCreateDir, %HyperPause_MovesListImagePath%
    HyperPause_HistoryDatPath := HLDataPath . "\History\"
    IfNotExist, %HyperPause_HistoryDatPath%
		FileCreateDir, %HyperPause_HistoryDatPath%
    HyperPause_KeymapperMediaPath := HLMediaPath . "\Keymapper\" 
    ;HyperPause Data paths    
    HyperPause_GameInfoPath := HLDataPath . "\Game Info\"
    IfNotExist, %HyperPause_GameInfoPath%
		FileCreateDir, %HyperPause_GameInfoPath%
    HyperPause_MovesListDataPath := HLDataPath . "\Moves List\" 
    IfNotExist, %HyperPause_MovesListDataPath%
		FileCreateDir, %HyperPause_MovesListDataPath%
    HyperPause_GameStatistics := HLDataPath . "\Statistics\"
    IfNotExist, %HyperPause_GameStatistics%
		FileCreateDir, %HyperPause_GameStatistics%
    HyperPause_SaveScreenshotPath := HLMediaPath . "\Artwork\" . systemname . "\" . dbName . "\Screenshots\"
    ;HyperPause files:
    HyperPause_StatisticsFile := HyperPause_GameStatistics . systemName . ".ini" 
    HyperPause_GlobalStatisticsFile := HyperPause_GameStatistics . "Global Statistics.ini"
    ;Cheking HyperPause files existence
    IfNotExist, % 7zPath 
        Log("7z.exe not found", 3)
    IfNotExist, %HyperPause_MenuSoundPath%\hpmenu.wav 
        Log("HyperPause source sound files not found", 3)
    IfNotExist, %HyperPause_IconsImagePath%\Pause.png 
        Log("HyperPause source image files not found", 3)    
    IfNotExist, %HyperPause_MovesListDataPath%\*.dat 
        Log("No Moves List files available", 3)    
    Log("HyperLaunch HitoText Path:          " hpHiToTextPath)
    Log("HyperLaunch 7z Path:                " 7zPath)
    ;Settings hardcoded
    ;Mouse Click Sound
    HyperPause_MouseClickSound := "false" ; not reliable
    ;SubMenu
    HyperPause_SubMenu_Pen_Width := 7
    HyperPause_Logo_Image_Margin := 25
    HyperPause_MainMenu_Info_Margin := 15
	HyperPause_Controller_Profiles_Margin := 15
	HyperPause_Controller_Profiles_First_Column_Width := 40
	HyperPause_Controller_Joy_Selected_Grow_Size := 7
	HyperPause_Settings_Margin := 15
	HyperPause_Sound_MarginBetweenButtons := 40
	HyperPause_Sound_Buttons_Grow_Size := 20
	HyperPause_Sound_Margin := 15
	HyperPause_Sound_InGameMusic_Margin := 125
	HyperPause_Statistics_Middle_Column_Offset := -40
    HyperPause_Statistics_MarginBetweenTableColumns := 10
    HyperPause_ChangingDisc_GrowSize := 30
    HyperPause_ChangingDisc_Rounded_Corner := 7
	HyperPause_ChangingDisc_Margin := 15
	HyperPause_Video_Buttons_Grow_Size := 20
    HyperPause_VTextDisplacementAdjust := 5
	; 7z Progress Bar Options:
    HyperPause_7zProgress_BarW := 800
    HyperPause_7zProgress_BarH := 45
    HyperPause_7zProgress_BarBackgroundMargin := 55
    HyperPause_7zProgress_BarBackgroundRadius := 15
    HyperPause_7zProgress_BarR := 15
    HyperPause_7zProgress_BarBackgroundColor := "BB000000"
    HyperPause_7zProgress_BarBackColor := "BB555555"
    HyperPause_7zProgress_BarColor := "DD00BFFF"
    HyperPause_7zProgress_BarHatchStyle := 3
    HyperPause_7zProgress_BarText1FontSize := 30
    HyperPause_7zProgress_BarText2FontSize := 30
    HyperPause_7zProgress_BarText1Options := "cFFFFFFFF r4 Right Bold"
    HyperPause_7zProgress_BarText1 := "Loading Game"
    Text2Option := "cFFFFFFFF r4 Right Bold"
    HyperPause_7zProgress_BarText2 := "Extraction Complete"
    HyperPause_7zProgress_Font := "BEBAS NEUE"
    HyperPause_7zProgress_Text_Offset := 30
	;Loading ini settings
    HyperPause_ControllerMenuEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "Controller_Menu_Enabled", "true")  
    HyperPause_ChangeDiscMenuEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "ChangeDisc_Menu_Enabled", "true")  
    HyperPause_SaveandLoadMenuEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "SaveandLoad_Menu_Enabled", "true")  
    HyperPause_HighScoreMenuEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "HighScore_Menu_Enabled", "true")  
    HyperPause_ArtworkMenuEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "Artwork_Menu_Enabled", "true")  
    HyperPause_GuidesMenuEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "Guides_Menu_Enabled", "true")  
    HyperPause_ManualsMenuEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "Manuals_Menu_Enabled", "true")  
    HyperPause_HistoryMenuEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "History_Menu_Enabled", "true")  
    HyperPause_SoundMenuEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "Sound_Menu_Enabled", "true")  
    HyperPause_SettingsMenuEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "Settings_Menu_Enabled", "true")  
    HyperPause_VideosMenuEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "Videos_Menu_Enabled", "true")
    HyperPause_StatisticsMenuEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "Statistics_Menu_Enabled", "true")  
    HyperPause_MovesListMenuEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "MovesList_Menu_Enabled", "true")  
    HyperPause_ShutdownLabelEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "Shutdown_Label_Enabled", "true")  
    HyperPause_LoadPDFandCompressedFilesatStart := RIniHyperPauseLoadVar(3,4, "General Options", "Load_PDF_and_Compressed_Files_at_HyperPause_First_Start", "false")
    HyperPause_PDF_Page_Layout := RIniHyperPauseLoadVar(3,4, "General Options", "PDF_Page_Layout", "frompdf") 
    HyperPause_SubMenu_PdfDpiResolution := RIniHyperPauseLoadVar(3,4, "General Options", "Pdf_Dpi_Resolution", "72")
    pdfMaxHeight := RIniHyperPauseLoadVar(3,4, "General Options", "PDF_Max_Height", "1080")
    HyperPause_MuteWhenLoading := RIniHyperPauseLoadVar(3,4, "General Options", "Mute_when_Loading_Hyperpause", "true") 
    HyperPause_MuteSound := RIniHyperPauseLoadVar(3,4, "General Options", "Mute_Sound", "false") 
    HyperPause_Disable_Menu := RIniHyperPauseLoadVar(3,4, "General Options", "Disable_HyperPause_Menu", "true") 
    HyperPause_EnableMouseControl := RIniHyperPauseLoadVar(3,4, "General Options", "Enable_Mouse_Control", "false")  
    HyperPause_SupportAdditionalImageFiles := RIniHyperPauseLoadVar(3,4, "General Options", "Support_Additional_Image_Files", "true") 
    HyperPause_Screenshot_Extension := RIniHyperPauseLoadVar(3,4, "General Options", "Screenshot_Extension", "jpg") ;Supported extensions are: .BMP,.DIB,.RLE,.JPG,.JPEG,.JPE,.JFIF,.GIF,.TIF,.TIFF,.PNG
    HyperPause_Screenshot_JPG_Quality := RIniHyperPauseLoadVar(3,4, "General Options", "Screenshot_JPG_Quality", "100") ;If saving as jpg (.JPG,.JPEG,.JPE,.JFIF) then quality can be 1-100 with default at maximum quality
    HyperPause_UseParentGameMediaAssets := RIniHyperPauseLoadVar(3,4, "General Options", "HyperPause_Use_Parent_Game_Media_Assets", "true")  
    HyperPause_LoadPDFOnLabel := RIniHyperPauseLoadVar(3,4, "General Options", "HyperPause_Load_PDF_On_Label", "false")
    ;Main Menu Options
    HyperPause_MainMenu_GlobalBackground := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Enable_Global_Background", "true")  
    HyperPause_MainMenu_BackgroundAlign := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Background_Align_Image", "Align to Top Left")  
    HyperPause_MainMenu_ShowClock := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Enable_Clock", "true")
    HyperPause_MainMenu_ClockFont := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Clock_Font", "Bebas Neue")
    HyperPause_MainMenu_ClockFontSize := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Clock_Font_Size", "25")
    HyperPause_MainMenu_LabelFont := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Main_Bar_Text_Font", "Bebas Neue")
    HyperPause_MainMenu_LabelFontsize := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Main_Bar_Text_Font_Size", "75")
    HyperPause_MainMenu_LabelSelectedColor := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Main_Bar_Text_Selected_Color", "ffffffff")
    HyperPause_MainMenu_LabelDisabledColor := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Main_Bar_Text_Disabled_Color", "44ffffff")
    HyperPause_MainMenu_HdistBetwLabels := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Main_Bar_Horizontal_Distance_Between_Labels", "160")
    HyperPause_MainMenu_BarHeight := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Main_Bar_Height", "90")
    HyperPause_MainMenu_BarGradientBrush1 := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Main_Bar_GradientBrush1", "6f000000")
    HyperPause_MainMenu_BarGradientBrush2 := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Main_Bar_GradientBrush2", "ff000000")
    HyperPause_MainMenu_Background_Color := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Background_Color", "ff000000")
    HyperPause_MainMenu_BackgroundBrush := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Background_Brush", "aa000000") 
    HyperPause_MainMenu_Info_Labels := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Game_Info_Items", "Publisher|Developer|Company|Released|Year|Systems|Genre|Perspective|GameType|Language|Score|Controls|Players|NumPlayers|Series|Rating|Description")
    HyperPause_MainMenu_Info_Font := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Game_Info_Font", "Arial")
    HyperPause_MainMenu_Info_FontSize := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Game_Info_Font_Size", "22")
    HyperPause_MainMenu_Info_FontColor := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Game_Info_Font_Color", "ffffffff")
    HyperPause_MainMenu_Info_Description_Font := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Game_Info_Description_Font", "Arial")
    HyperPause_MainMenu_Info_Description_FontSize := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Game_Info_Description_Font_Size", "22")
    HyperPause_MainMenu_Info_Description_FontColor := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Game_Info_Description_Font_Color", "ffffffff")
    HyperPause_MainMenu_DescriptionScrollingVelocity := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Game_Info_Description_Scrolling_Velocity", "2")
    HyperPause_MainMenu_UseScreenshotAsBackground := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Use_Screenshot_As_Background", "false") 
    HyperPause_MouseControlTransparency := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Mouse_Control_Overlay_Transparency", "50")
    HyperPause_MainMenu_BarVerticalOffset := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Bar_Vertical_Offset", "0")
    ;SubMenu General Options
    HyperPause_SubMenu_AdditionalTextMarginContour := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Additional_Text_Margin_Contour", "15")
    HyperPause_SubMenu_MinimumTextBoxWidth := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Minimum_Text_Box_Width", "270")
    HyperPause_SubMenu_DelayinMilliseconds := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Appearance_Delay_in_Milliseconds", "500")
    HyperPause_SubMenu_TopRightChamfer := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Top_Right_Chamfer_Size", "40")
    HyperPause_SubMenu_Width := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Width", "1350|1020")
    HyperPause_SubMenu_Height := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Height", "450|700")
    HyperPause_SubMenu_BackgroundBrush := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Background_Brush", "44000000")
    HyperPause_SubMenu_LabelFont := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Label_Font", "Bebas Neue")
    HyperPause_SubMenu_LabelFontSize := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Label_Font_Size", "37")
    HyperPause_SubMenu_Font := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Content_Font", "Lucida Console")
    HyperPause_SubMenu_FontSize := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Content_Font_Size", "30")
    HyperPause_SubMenu_SmallFontSize := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Content_Small_Font_Size", "22")
    HyperPause_SubMenu_HelpFont := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Help_Font", "Bebas Neue")
    HyperPause_SubMenu_HelpFontSize := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Help_Font_Size", "22")
    HyperPause_SubMenu_SelectedBrush := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Selected_Brush", "cc000000")
    HyperPause_SubMenu_DisabledBrush := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Disabled_Brush", "44000000")
    HyperPause_SubMenu_RadiusofRoundedCorners := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Radius_of_Rounded_Corners", "15") 
    ;SubMenu FullScreen Options
    HyperPause_SubMenu_FullScreenMargin := RIniHyperPauseLoadVar(3,4, "SubMenu FullScreen Appearance Options", "Margin", "25") 
    HyperPause_SubMenu_FullScreenRadiusofRoundedCorners := RIniHyperPauseLoadVar(3,4, "SubMenu FullScreen Appearance Options", "Radius_of_Rounded_Corners", "15") 
    HyperPause_SubMenu_FullScreenBrush := RIniHyperPauseLoadVar(3,4, "SubMenu FullScreen Appearance Options", "Background_Brush", "88000000") 
    HyperPause_SubMenu_FullScreenTextBrush := RIniHyperPauseLoadVar(3,4, "SubMenu FullScreen Appearance Options", "Legend_Text_Brush", "DD000015") 
    HyperPause_SubMenu_FullScreenFontColor := RIniHyperPauseLoadVar(3,4, "SubMenu FullScreen Appearance Options", "Legend_Text_Font_Color", "ffffffff") 
    HyperPause_SubMenu_FullScreenFontSize := RIniHyperPauseLoadVar(3,4, "SubMenu FullScreen Appearance Options", "Legend_Text_Font_Size", "22") 
    HyperPause_SubMenu_FullScreenZoomSteps := RIniHyperPauseLoadVar(3,4, "SubMenu FullScreen Appearance Options", "Zoom_Steps", "25") 
    HyperPause_SubMenu_FullScreenPanSteps := RIniHyperPauseLoadVar(3,4, "SubMenu FullScreen Appearance Options", "Pan_Steps", "120") 
    HyperPause_SubMenu_FullSCreenHelpTextTimer := RIniHyperPauseLoadVar(3,4, "SubMenu FullScreen Appearance Options", "Full_Screen_Help_Text_Timer", "2000") 
    ;Save and Load State Options 
    HyperPause_State_VdistBetwLabels := RIniHyperPauseLoadVar(3,4, "SubMenu Save and Load State Appearance Options", "Vertical_Distance_Between_Labels", "75")
    HyperPause_State_HMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Save and Load State Appearance Options", "Horizontal_Margin", "200")
    HyperPause_State_VMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Save and Load State Appearance Options", "Vertical_Margin", "90")
    HyperPause_DelaytoSendKeys := RIniHyperPauseLoadVar(3,4, "SubMenu Save and Load State Appearance Options", "Delay_to_Send_Keys", "500")
    HyperPause_SetKeyDelay := RIniHyperPauseLoadVar(3,4, "SubMenu Save and Load State Appearance Options", "Set_Key_Delay", "200")
    HyperPause_SaveStateScreenshot := RIniHyperPauseLoadVar(3,4, "SubMenu Save and Load State Appearance Options", "Enable_Save_State_Screenshot", "true") 
    ;Settings Menu Options
    HyperPause_Settings_VdistBetwLabels := RIniHyperPauseLoadVar(3,4, "SubMenu Settings Appearance Options", "Vertical_Distance_Between_Labels", "75")
    HyperPause_Settings_HMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Settings Appearance Options", "Horizontal_Margin", "200")
    HyperPause_Settings_VMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Settings Appearance Options", "Vertical_Margin", "90")
    HyperPause_Settings_OptionFontSize := RIniHyperPauseLoadVar(3,4, "SubMenu Settings Appearance Options", "Option_Font_Size", "22")
    ;Sound Menu Options
    HyperPause_SoundBar_SingleBarWidth := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Single_Bar_Width", "25")
    HyperPause_SoundBar_SingleBarSpacing := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Single_Bar_Spacing", "7")
    HyperPause_SoundBar_SingleBarHeight := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Single_Bar_Height", "45")
    HyperPause_SoundBar_HeightDifferenceBetweenBars := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Height_Difference_Between_Bars", "3")
    HyperPause_SoundBar_vol_Step := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Volume_Steps", "5")
    HyperPause_SubMenu_SoundSelectedColor := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Selected_Color", "ffffffff")
    HyperPause_SubMenu_SoundDisabledColor := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Disabled_Color", "44ffffff")
    HyperPause_SubMenu_SoundMuteButtonFontSize := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Mute_Button_Font_Size", "20")
    HyperPause_SubMenu_SoundMuteButtonVDist := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Sound_Mute_Button_Vertical_Distance", "75|100")
    HyperPause_SubMenu_SoundSpaceBetweenSoundBarandSoundBitmap := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Space_Between_Sound_Bar_and_Sound_Bitmap", "55")
    HyperPause_SubMenu_SoundDisttoSoundLevel := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Sound_Distance_to_Sound_Level", "15")
    HyperPause_MusicPlayerEnabled := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Enable_Music_Player", "true")
    HyperPause_PlaylistExtension := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Playlist_Extension", "m3u")
    HyperPause_MusicFilesExtension := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Music_Files_Extension", "mp3|m4a|wav|mid|wma")
    HyperPause_EnableMusicOnStartup := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Enable_Music_on_HyperPause_Startup", "true")
    HyperPause_KeepPlayingAfterExitingHyperPause := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Keep_Playing_after_Exiting_HyperPause", "false")
    HyperPause_EnableShuffle := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Enable_Shuffle", "true")
    HyperPause_EnableLoop := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Enable_Loop", "true")
    HyperPause_ExternalPlaylistPath := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "External_Playlist_Path", "")
    HyperPause_SubMenu_SpaceBetweenMusicPlayerButtons := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Space_Between_Music_Player_Buttons", "65")
    HyperPause_SubMenu_SizeofMusicPlayerButtons := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Size_of_Music_Player_Buttons", "65")
    HyperPause_SubMenu_MusicPlayerVDist := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Music_Player_Vertical_Distance", "75|100")
    HyperPause_SoundButtonGrowingEffectVelocity := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Sound_Button_Growing_Velocity", "1") 
    HyperPause_MusicPlayerVolumeLevel := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Music_Player_Volume_Level", "100")
    ;Change Disc Options
    HyperPause_ChangeDisc_VMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Change Disc Appearance Options", "Vertical_Margin", "45")
    HyperPause_ChangeDisc_TextDisttoImage := RIniHyperPauseLoadVar(3,4, "SubMenu Change Disc Appearance Options", "Text_Distance_to_Image", "30") 
    HyperPause_ChangeDisc_UseGameArt := RIniHyperPauseLoadVar(3,4, "SubMenu Change Disc Appearance Options", "Use_Game_Art_for_Disc_Image", "true") 
    HyperPause_ChangeDisc_SelectedEffect := RIniHyperPauseLoadVar(3,4, "SubMenu Change Disc Appearance Options", "Selected_Disc_Effect", "rotate") 
    HyperPause_ChangeDisc_SidePadding := RIniHyperPauseLoadVar(3,4, "SubMenu Change Disc Appearance Options", "Side_Padding", "0.2") 
    ;High Score Options
    HyperPause_SubMenu_HighlightPlayerName := RIniHyperPauseLoadVar(3,4, "SubMenu HighScore Appearance Options", "Highlighted_Player_Name", "GEN") 
    HyperPause_SubMenu_HighlightPlayerFontColor := RIniHyperPauseLoadVar(3,4, "SubMenu HighScore Appearance Options", "Highlighted_Player_Font_Color", "ff00ffff") 
    HyperPause_SubMenu_HighScoreFontColor := RIniHyperPauseLoadVar(3,4, "SubMenu HighScore Appearance Options", "Font_Color", "ffffffff") 
    HyperPause_SubMenu_HighScoreFontSize := RIniHyperPauseLoadVar(3,4, "SubMenu HighScore Appearance Options", "Font_Size", "22") 
    HyperPause_SubMenu_HighScoreTitleFontSize := RIniHyperPauseLoadVar(3,4, "SubMenu HighScore Appearance Options", "Title_Font_Size", "30") 
    HyperPause_SubMenu_HighScoreTitleFontColor := RIniHyperPauseLoadVar(3,4, "SubMenu HighScore Appearance Options", "Title_Font_Color", "ffffff00") 
    HyperPause_SubMenu_HighScoreSelectedFontColor := RIniHyperPauseLoadVar(3,4, "SubMenu HighScore Appearance Options", "Selected_Font_Color", "ffff00ff") 
    HyperPause_SubMenu_HighScore_SuperiorMargin := RIniHyperPauseLoadVar(3,4, "SubMenu HighScore Appearance Options", "Superior_Margin", "45")
    HyperPause_SubMenu_HighScoreFullScreenWidth := RIniHyperPauseLoadVar(3,4, "SubMenu HighScore Appearance Options", "Full_Screen_Width", "1000") 
    ;Moves List Options
    HyperPause_MovesList_VMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Moves List Appearance Options", "Vertical_Margin", "45") 
    HyperPause_MovesList_HMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Moves List Appearance Options", "Horizontal_Margin", "40") 
    HyperPause_MovesList_VdistBetwLabels := RIniHyperPauseLoadVar(3,4, "SubMenu Moves List Appearance Options", "Vertical_Distance_Between_Labels", "75") 
    HyperPause_MovesList_HdistBetwLabelsandMovesList := RIniHyperPauseLoadVar(3,4, "SubMenu Moves List Appearance Options", "Horizontal_Distance_Between_Labels_and_MovesList", "125") 
    HyperPause_MovesList_VdistBetwMovesListLabels := RIniHyperPauseLoadVar(3,4, "SubMenu Moves List Appearance Options", "Vertical_Distance_Between_Moves_Lines", "60") 
    HyperPause_MovesList_SecondaryFontSize := RIniHyperPauseLoadVar(3,4, "SubMenu Moves List Appearance Options", "Secondary_Font_Size", "22")
    HyperPause_MovesList_VImageSize := RIniHyperPauseLoadVar(3,4, "SubMenu Moves List Appearance Options", "Vertical_Move_Image_Size", "55") 
    HyperPause_SubMenu_MovesListFullScreenWidth := RIniHyperPauseLoadVar(3,4, "SubMenu Moves List Appearance Options", "Full_Screen_Width", "1000")
    HyperPause_MovesList_HFullScreenMovesMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Moves List Appearance Options", "Horizontal_Full_Screen_Moves_Margin", "270")
    ;Statistics Menu Options
    HyperPause_Statistics_VMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Statistics Appearance Options", "Vertical_Margin", "45")  
    HyperPause_Statistics_HMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Statistics Appearance Options", "Horizontal_Margin", "40") 
    HyperPause_Statistics_TableFontSize := RIniHyperPauseLoadVar(3,4, "SubMenu Statistics Appearance Options", "Table_Font_Size", "22") 
    HyperPause_Statistics_DistBetweenLabelsandTable := RIniHyperPauseLoadVar(3,4, "SubMenu Statistics Appearance Options", "Distance_Between_Labels_and_Table", "55") 
    HyperPause_Statistics_VdistBetwTableLines := RIniHyperPauseLoadVar(3,4, "SubMenu Statistics Appearance Options", "Vertical_Distance_Between_Table_Lines", "45") 
    HyperPause_Statistics_VdistBetwLabels := RIniHyperPauseLoadVar(3,4, "SubMenu Statistics Appearance Options", "Vertical_Distance_Between_Labels", "75") 
    HyperPause_Statistics_TitleFontSize := RIniHyperPauseLoadVar(3,4, "SubMenu Statistics Appearance Options", "Title_Font_Size", "30") 
    HyperPause_Statistics_TitleFontColor := RIniHyperPauseLoadVar(3,4, "SubMenu Statistics Appearance Options", "Title_Font_Color", "ffffff00") 
    HyperPause_SubMenu_StatisticsFullScreenWidth := RIniHyperPauseLoadVar(3,4, "SubMenu Statistics Appearance Options", "Full_Screen_Width", "1000") 
    ;Guides Menu Options
    HyperPause_Guides_VMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Guides Appearance Options", "Vertical_Margin", "45") 
    HyperPause_Guides_HMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Guides Appearance Options", "Horizontal_Margin", "40") 
    HyperPause_Guides_HdistBetwPages := RIniHyperPauseLoadVar(3,4, "SubMenu Guides Appearance Options", "Horizontal_Distance_Between_Pages", "65") 
    HyperPause_SubMenu_GuidesSelectedBrush := RIniHyperPauseLoadVar(3,4, "SubMenu Guides Appearance Options", "Selected_Brush", "33ffff00") 
    HyperPause_Guides_VdistBetwLabels := RIniHyperPauseLoadVar(3,4, "SubMenu Guides Appearance Options", "Vertical_Distance_Between_Labels", "75") 
    HyperPause_Guides_HdistBetwLabelsandPages := RIniHyperPauseLoadVar(3,4, "SubMenu Guides Appearance Options", "Horizontal_Distance_Between_Labels_and_Pages", "65") 
    HyperPause_Guides_PageNumberFontColor := RIniHyperPauseLoadVar(3,4, "SubMenu Guides Appearance Options", "Page_Number_Font_Color", "00000000") 
    HyperPause_Guides_Item_Labels := RIniHyperPauseLoadVar(3,4, "SubMenu Guides Appearance Options", "Show_Item_Labels", "true") 
    ;Manuals Menu Options
    HyperPause_Manuals_VMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Manuals Appearance Options", "Vertical_Margin", "45") 
    HyperPause_Manuals_HMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Manuals Appearance Options", "Horizontal_Margin", "40") 
    HyperPause_Manuals_HdistBetwPages := RIniHyperPauseLoadVar(3,4, "SubMenu Manuals Appearance Options", "Horizontal_Distance_Between_Pages", "65") 
    HyperPause_SubMenu_ManualsSelectedBrush := RIniHyperPauseLoadVar(3,4, "SubMenu Manuals Appearance Options", "Selected_Brush", "33ffff00") 
    HyperPause_Manuals_VdistBetwLabels := RIniHyperPauseLoadVar(3,4, "SubMenu Manuals Appearance Options", "Vertical_Distance_Between_Labels", "75") 
    HyperPause_Manuals_HdistBetwLabelsandPages := RIniHyperPauseLoadVar(3,4, "SubMenu Manuals Appearance Options", "Horizontal_Distance_Between_Labels_and_Pages", "65") 
    HyperPause_Manuals_PageNumberFontColor := RIniHyperPauseLoadVar(3,4, "SubMenu Manuals Appearance Options", "Page_Number_Font_Color", "00000000") 
    HyperPause_Manuals_Item_Labels := RIniHyperPauseLoadVar(3,4, "SubMenu Manuals Appearance Options", "Show_Item_Labels", "true") 
    ;History Menu Options
    HyperPause_History_VMargin := RIniHyperPauseLoadVar(3,4, "SubMenu History Appearance Options", "Vertical_Margin", "45") 
    HyperPause_History_HMargin := RIniHyperPauseLoadVar(3,4, "SubMenu History Appearance Options", "Horizontal_Margin", "40") 
    HyperPause_History_HdistBetwPages := RIniHyperPauseLoadVar(3,4, "SubMenu History Appearance Options", "Horizontal_Distance_Between_Pages", "65") 
    HyperPause_SubMenu_HistorySelectedBrush := RIniHyperPauseLoadVar(3,4, "SubMenu History Appearance Options", "Selected_Brush", "33ffff00") 
    HyperPause_History_VdistBetwLabels := RIniHyperPauseLoadVar(3,4, "SubMenu History Appearance Options", "Vertical_Distance_Between_Labels", "75") 
    HyperPause_History_HdistBetwLabelsandPages := RIniHyperPauseLoadVar(3,4, "SubMenu History Appearance Options", "Horizontal_Distance_Between_Labels_and_Pages", "65") 
    HyperPause_History_PageNumberFontColor := RIniHyperPauseLoadVar(3,4, "SubMenu History Appearance Options", "Page_Number_Font_Color", "00000000") 
    ;Controller Menu Options
    HyperPause_Controller_VMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Controller Appearance Options", "Vertical_Margin", "45") 
    HyperPause_Controller_HMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Controller Appearance Options", "Horizontal_Margin", "40") 
    HyperPause_Controller_HdistBetwPages := RIniHyperPauseLoadVar(3,4, "SubMenu Controller Appearance Options", "Horizontal_Distance_Between_Pages", "65") 
    HyperPause_SubMenu_ControllerSelectedBrush := RIniHyperPauseLoadVar(3,4, "SubMenu Controller Appearance Options", "Selected_Brush", "33ffff00") 
    HyperPause_Controller_VdistBetwLabels := RIniHyperPauseLoadVar(3,4, "SubMenu Controller Appearance Options", "Vertical_Distance_Between_Labels", "75") 
    HyperPause_Controller_HdistBetwLabelsandPages := RIniHyperPauseLoadVar(3,4, "SubMenu Controller Appearance Options", "Horizontal_Distance_Between_Labels_and_Pages", "65") 
    HyperPause_Controller_PageNumberFontColor := RIniHyperPauseLoadVar(3,4, "SubMenu Controller Appearance Options", "Page_Number_Font_Color", "00000000") 
    HyperPause_Controller_Item_Labels := RIniHyperPauseLoadVar(3,4, "SubMenu Controller Appearance Options", "Show_Item_Labels", "true") 
    HyperPause_ControllerBannerHeight := RIniHyperPauseLoadVar(3,4, "SubMenu Controller Appearance Options", "Controller_Banner_Height", "60") 
    HyperPause_vDistanceBetweenButtons := RIniHyperPauseLoadVar(3,4, "SubMenu Controller Appearance Options", "Vertical_Distance_Between_Buttons", "120") 
    HyperPause_vDistanceBetweenBanners := RIniHyperPauseLoadVar(3,4, "SubMenu Controller Appearance Options", "Vertical_Distance_Between_Banners", "45") 
    HyperPause_hDistanceBetweenControllerBannerElements := RIniHyperPauseLoadVar(3,4, "SubMenu Controller Appearance Options", "Horizontal_Distance_Between_Controller_Banner_Elements", "55") 
    HyperPause_selectedControllerBannerDisplacement := RIniHyperPauseLoadVar(3,4, "SubMenu Controller Appearance Options", "Selected_Controller_Banner_Displacement", "25") 
    ;Artwork Menu Options
    HyperPause_Artwork_VMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Artwork Appearance Options", "Vertical_Margin", "45") 
    HyperPause_Artwork_HMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Artwork Appearance Options", "Horizontal_Margin", "40") 
    HyperPause_Artwork_HdistBetwPages := RIniHyperPauseLoadVar(3,4, "SubMenu Artwork Appearance Options", "Horizontal_Distance_Between_Pages", "65") 
    HyperPause_SubMenu_ArtworkSelectedBrush := RIniHyperPauseLoadVar(3,4, "SubMenu Artwork Appearance Options", "Selected_Brush", "33ffff00") 
    HyperPause_Artwork_VdistBetwLabels := RIniHyperPauseLoadVar(3,4, "SubMenu Artwork Appearance Options", "Vertical_Distance_Between_Labels", "75") 
    HyperPause_Artwork_HdistBetwLabelsandPages := RIniHyperPauseLoadVar(3,4, "SubMenu Artwork Appearance Options", "Horizontal_Distance_Between_Labels_and_Pages", "65") 
    HyperPause_Artwork_PageNumberFontColor := RIniHyperPauseLoadVar(3,4, "SubMenu Artwork Appearance Options", "Page_Number_Font_Color", "00000000") 
    HyperPause_Artwork_Item_Labels := RIniHyperPauseLoadVar(3,4, "SubMenu Artwork Appearance Options", "Show_Item_Labels", "true") 
    ;Videos Menu Options
    HyperPause_SupportedVideos := RIniHyperPauseLoadVar(3,4, "SubMenu Videos Appearance Options", "Supported_Videos", "avi|wmv|mp4")
    HyperPause_Videos_VMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Videos Appearance Options", "Vertical_Margin", "45") 
    HyperPause_Videos_HMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Videos Appearance Options", "Horizontal_Margin", "40") 
    HyperPause_Videos_VdistBetwLabels := RIniHyperPauseLoadVar(3,4, "SubMenu Videos Appearance Options", "Vertical_Distance_Between_Labels", "75") 
    HyperPause_EnableVideoLoop := RIniHyperPauseLoadVar(3,4, "SubMenu Videos Appearance Options", "Enable_Loop", "true") 
    HyperPause_SubMenu_VideoRewindFastForwardJumpSeconds := RIniHyperPauseLoadVar(3,4, "SubMenu Videos Appearance Options", "Video_Seconds_to_Jump_in_Rewind_and_Fast_Forward_Buttons", "5") 
    HyperPause_VideoButtonGrowingEffectVelocity := RIniHyperPauseLoadVar(3,4, "SubMenu Videos Appearance Options", "Video_Button_Growing_Velocity", "1") 
    HyperPause_SubMenu_SizeofVideoButtons := RIniHyperPauseLoadVar(3,4, "SubMenu Videos Appearance Options", "Size_of_Video_Player_Buttons", "60") 
    HyperPause_SubMenu_SpaceBetweenVideoButtons := RIniHyperPauseLoadVar(3,4, "SubMenu Videos Appearance Options", "Space_Between_Video_Player_Buttons", "20") 
    HyperPause_SubMenu_SpaceBetweenLabelsandVideoButtons := RIniHyperPauseLoadVar(3,4, "SubMenu Videos Appearance Options", "Space_Between_Label_and_Video_Player_Buttons", "45") 
    HyperPause_VideoPlayerVolumeLevel := RIniHyperPauseLoadVar(3,4, "SubMenu Videos Appearance Options", "Video_Player_Volume_Level", "100") 
    ;Start and exit screen
    HyperPause_AuxiliarScreen_StartText := RIniHyperPauseLoadVar(3,4, "Start and Exit Screen", "Loading_Text", "Loading HyperPause") 
    HyperPause_AuxiliarScreen_ExitText := RIniHyperPauseLoadVar(3,4, "Start and Exit Screen", "Exiting_Text", "Exiting HyperPause") 
    HyperPause_AuxiliarScreen_Font := RIniHyperPauseLoadVar(3,4, "Start and Exit Screen", "Font", "Bebas Neue") 
    HyperPause_AuxiliarScreen_FontSize := RIniHyperPauseLoadVar(3,4, "Start and Exit Screen", "Font_Size", "45") 
    HyperPause_AuxiliarScreen_FontColor := RIniHyperPauseLoadVar(3,4, "Start and Exit Screen", "Font_Color", "ff222222") 
    HyperPause_AuxiliarScreen_ExitTextMargin := RIniHyperPauseLoadVar(3,4, "Start and Exit Screen", "Text_Margin", "65") 
    ;Check font
    CheckFont(HyperPause_7zProgress_Font)
    CheckFont(HyperPause_MainMenu_ClockFont)
    CheckFont(HyperPause_MainMenu_LabelFont)
    CheckFont(HyperPause_MainMenu_Info_Font)
    CheckFont(HyperPause_MainMenu_Info_Description_Font)
    CheckFont(HyperPause_SubMenu_LabelFont)
    CheckFont(HyperPause_SubMenu_Font)
    CheckFont(HyperPause_SubMenu_HelpFont)
    CheckFont(HyperPause_AuxiliarScreen_Font)
    ; Saving values to ini file
    RIni_Write(3,HyperPause_GlobalFile,"`r`n",1,1,1)
    RIni_Write(4,HyperPause_SystemFile,"`r`n",1,1,1)
    ;checking HitoText files existence 
    If (HyperPause_HighScoreMenuEnabled="true")
        If !FileExist(hpHiToTextPath) or !FileExist(hpHitoTextDir . "\hitotext.xml") 
            Log("Please copy HitoText.exe and HitoText.xml to your module extensions folder in order to view High Score contents", 3)
    ;logging all HyperPause Vars
    Log("HyperPause variables values: " . HPVarLog,5)
Return

RIniHyperPauseLoadVar(gRIniVar,sRIniVar,gsec,gkey,gdefaultvalue="",ssec=0,skey=0,sdefaultvalue="use_global") {
    Global
    If not ssec
        ssec := gsec
    If not skey
        skey := gkey
	X1 := (If RIni_GetKeyValue(gRIniVar,gsec,gkey,gdefaultvalue) = -3 ? "" : RIni_GetKeyValue(gRIniVar,gsec,gkey,gdefaultvalue))
	X2 := (If RIni_GetKeyValue(sRIniVar,ssec,skey,sdefaultvalue) = -3 ? "" : RIni_GetKeyValue(sRIniVar,ssec,skey,sdefaultvalue))
    X3 := (If X2 = "use_global" ? (X1) : (X2))
    RIni_SetKeyValue(gRIniVar,gsec,gkey,X1)
    RIni_SetKeyValue(sRIniVar,ssec,skey,X2)
    HPVarLog .= "`r`n`t`t`t`t`t" . "[" . gsec . "] " . gkey . " = " . X3
	Return X3
}  

HyperPauseOptionsScale(){
	global
    ; HardCoded Parameters
    OptionScale(HyperPause_SubMenu_Pen_Width, HyperPause_XScale)
    OptionScale(HyperPause_Logo_Image_Margin, HyperPause_XScale)
    OptionScale(HyperPause_MainMenu_Info_Margin, HyperPause_XScale)
    OptionScale(HyperPause_Controller_Profiles_Margin, HyperPause_XScale)
    OptionScale(HyperPause_Controller_Profiles_First_Column_Width, HyperPause_XScale)
    OptionScale(HyperPause_Controller_Joy_Selected_Grow_Size, HyperPause_XScale)
    OptionScale(HyperPause_Settings_Margin, HyperPause_XScale)
    OptionScale(HyperPause_Sound_MarginBetweenButtons, HyperPause_XScale)
    OptionScale(HyperPause_Sound_Buttons_Grow_Size, HyperPause_XScale)
    OptionScale(HyperPause_Sound_Mute_Margin, HyperPause_XScale)
    OptionScale(HyperPause_Sound_InGameMusic_Margin, HyperPause_XScale)
    OptionScale(HyperPause_Statistics_Middle_Column_Offset, HyperPause_XScale)
    OptionScale(HyperPause_Statistics_MarginBetweenTableColumns, HyperPause_XScale)
    OptionScale(HyperPause_ChangingDisc_GrowSize, HyperPause_XScale)
    OptionScale(HyperPause_ChangingDisc_Rounded_Corner, HyperPause_XScale)
	OptionScale(HyperPause_ChangingDisc_Margin, HyperPause_XScale)
	OptionScale(HyperPause_Video_Buttons_Grow_Size, HyperPause_XScale)
    OptionScale(HyperPause_VTextDisplacementAdjust, HyperPause_YScale)
    OptionScale(HyperPause_7zProgress_BarW, HyperPause_XScale)
    OptionScale(HyperPause_7zProgress_BarH, HyperPause_YScale)
    OptionScale(HyperPause_7zProgress_BarBackgroundMargin, HyperPause_XScale)
    OptionScale(HyperPause_7zProgress_BarBackgroundRadius, HyperPause_XScale)
    OptionScale(HyperPause_7zProgress_BarR, HyperPause_XScale)
    OptionScale(HyperPause_7zProgress_BarText1FontSize, HyperPause_YScale)
    OptionScale(HyperPause_7zProgress_BarText2FontSize, HyperPause_YScale)
    OptionScale(HyperPause_7zProgress_Text_Offset, HyperPause_YScale)
    ; Ini Loaded Parameters
    OptionScale(HyperPause_MainMenu_ClockFontSize, HyperPause_YScale)
    OptionScale(HyperPause_MainMenu_LabelFontsize, HyperPause_YScale)
    OptionScale(HyperPause_MainMenu_HdistBetwLabels, HyperPause_XScale)
    OptionScale(HyperPause_MainMenu_BarHeight, HyperPause_YScale)
    OptionScale(HyperPause_MainMenu_Info_FontSize, HyperPause_YScale)
    OptionScale(HyperPause_MainMenu_Info_Description_FontSize, HyperPause_YScale)
    OptionScale(HyperPause_MainMenu_DescriptionScrollingVelocity, HyperPause_XScale)
    OptionScale(HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_XScale)
    OptionScale(HyperPause_SubMenu_MinimumTextBoxWidth, HyperPause_XScale)
    OptionScale(HyperPause_SubMenu_TopRightChamfer, HyperPause_XScale)
    OptionScale(HyperPause_SubMenu_Width, HyperPause_XScale)
    OptionScale(HyperPause_SubMenu_Height, HyperPause_YScale)
    OptionScale(HyperPause_SubMenu_LabelFontSize, HyperPause_YScale)
    OptionScale(HyperPause_SubMenu_FontSize, HyperPause_YScale)
    OptionScale(HyperPause_SubMenu_SmallFontSize, HyperPause_YScale)
    OptionScale(HyperPause_SubMenu_HelpFontSize, HyperPause_YScale)
    OptionScale(HyperPause_SubMenu_RadiusofRoundedCorners, HyperPause_XScale)
    OptionScale(HyperPause_SubMenu_FullScreenMargin, HyperPause_XScale)
    OptionScale(HyperPause_SubMenu_FullScreenRadiusofRoundedCorners, HyperPause_XScale)
    OptionScale(HyperPause_SubMenu_FullScreenFontSize, HyperPause_YScale)
    OptionScale(HyperPause_State_VdistBetwLabels, HyperPause_YScale)
    OptionScale(HyperPause_State_HMargin, HyperPause_XScale)
    OptionScale(HyperPause_State_VMargin, HyperPause_YScale)
    OptionScale(HyperPause_Settings_VdistBetwLabels, HyperPause_YScale)
    OptionScale(HyperPause_Settings_HMargin, HyperPause_XScale)
    OptionScale(HyperPause_Settings_VMargin, HyperPause_YScale)
    OptionScale(HyperPause_Settings_OptionFontSize, HyperPause_YScale)
    OptionScale(HyperPause_SoundBar_SingleBarWidth, HyperPause_XScale)
    OptionScale(HyperPause_SoundBar_SingleBarSpacing, HyperPause_XScale)
    OptionScale(HyperPause_SoundBar_SingleBarHeight, HyperPause_YScale)
    OptionScale(HyperPause_SoundBar_HeightDifferenceBetweenBars, HyperPause_YScale)
    OptionScale(HyperPause_SubMenu_SoundMuteButtonFontSize, HyperPause_YScale)
    OptionScale(HyperPause_SubMenu_SoundMuteButtonVDist, HyperPause_YScale)
    OptionScale(HyperPause_SubMenu_SoundSpaceBetweenSoundBarandSoundBitmap, HyperPause_XScale)
    OptionScale(HyperPause_SubMenu_SoundDisttoSoundLevel, HyperPause_XScale)
    OptionScale(HyperPause_SubMenu_SpaceBetweenMusicPlayerButtons, HyperPause_XScale)
    OptionScale(HyperPause_SubMenu_SizeofMusicPlayerButtons, HyperPause_XScale)
    OptionScale(HyperPause_SubMenu_MusicPlayerVDist, HyperPause_YScale)
    OptionScale(HyperPause_ChangeDisc_VMargin, HyperPause_YScale)
    OptionScale(HyperPause_ChangeDisc_TextDisttoImage, HyperPause_YScale)
    OptionScale(HyperPause_SubMenu_HighScoreFontSize, HyperPause_YScale)
    OptionScale(HyperPause_SubMenu_HighScoreTitleFontSize, HyperPause_YScale)
    OptionScale(HyperPause_SubMenu_HighScore_SuperiorMargin, HyperPause_YScale)
    OptionScale(HyperPause_SubMenu_HighScoreFullScreenWidth, HyperPause_XScale)
    OptionScale(HyperPause_MovesList_VMargin, HyperPause_YScale)
    OptionScale(HyperPause_MovesList_HMargin, HyperPause_XScale)
    OptionScale(HyperPause_MovesList_VdistBetwLabels, HyperPause_YScale)
    OptionScale(HyperPause_MovesList_HdistBetwLabelsandMovesList, HyperPause_XScale)
    OptionScale(HyperPause_MovesList_VdistBetwMovesListLabels, HyperPause_YScale)
    OptionScale(HyperPause_MovesList_SecondaryFontSize, HyperPause_YScale)
    OptionScale(HyperPause_MovesList_VImageSize, HyperPause_YScale)
    OptionScale(HyperPause_SubMenu_MovesListFullScreenWidth, HyperPause_XScale)
    OptionScale(HyperPause_MovesList_HFullScreenMovesMargin, HyperPause_XScale)
    OptionScale(HyperPause_Statistics_VMargin, HyperPause_YScale)
    OptionScale(HyperPause_Statistics_HMargin, HyperPause_XScale)
    OptionScale(HyperPause_Statistics_TableFontSize, HyperPause_YScale)
    OptionScale(HyperPause_Statistics_DistBetweenLabelsandTable, HyperPause_XScale)
    OptionScale(HyperPause_Statistics_VdistBetwTableLines, HyperPause_YScale)
    OptionScale(HyperPause_Statistics_VdistBetwLabels, HyperPause_YScale)
    OptionScale(HyperPause_Statistics_TitleFontSize, HyperPause_YScale)
    OptionScale(HyperPause_SubMenu_StatisticsFullScreenWidth, HyperPause_XScale)
    OptionScale(HyperPause_Guides_VMargin, HyperPause_YScale)
    OptionScale(HyperPause_Guides_HMargin, HyperPause_XScale)
    OptionScale(HyperPause_Guides_HdistBetwPages, HyperPause_XScale)
    OptionScale(HyperPause_Guides_VdistBetwLabels, HyperPause_YScale)
    OptionScale(HyperPause_Guides_HdistBetwLabelsandPages, HyperPause_XScale)
    OptionScale(HyperPause_Manuals_VMargin, HyperPause_YScale)
    OptionScale(HyperPause_Manuals_HMargin, HyperPause_XScale)
    OptionScale(HyperPause_Manuals_HdistBetwPages, HyperPause_XScale)
    OptionScale(HyperPause_Manuals_VdistBetwLabels, HyperPause_YScale)
    OptionScale(HyperPause_Manuals_HdistBetwLabelsandPages, HyperPause_XScale)
    OptionScale(HyperPause_History_VMargin, HyperPause_YScale)
    OptionScale(HyperPause_History_HMargin, HyperPause_XScale)
    OptionScale(HyperPause_History_HdistBetwPages, HyperPause_XScale)
    OptionScale(HyperPause_History_VdistBetwLabels, HyperPause_YScale)
    OptionScale(HyperPause_History_HdistBetwLabelsandPages, HyperPause_XScale)
    OptionScale(HyperPause_Controller_VMargin, HyperPause_YScale)
    OptionScale(HyperPause_Controller_HMargin, HyperPause_XScale)
    OptionScale(HyperPause_Controller_HdistBetwPages, HyperPause_XScale)
    OptionScale(HyperPause_Controller_VdistBetwLabels, HyperPause_YScale)
    OptionScale(HyperPause_Controller_HdistBetwLabelsandPages, HyperPause_XScale)
    OptionScale(HyperPause_ControllerBannerHeight, HyperPause_YScale)
    OptionScale(HyperPause_vDistanceBetweenButtons, HyperPause_YScale)
    OptionScale(HyperPause_vDistanceBetweenBanners, HyperPause_YScale)
    OptionScale(HyperPause_hDistanceBetweenControllerBannerElements, HyperPause_XScale)
    OptionScale(HyperPause_selectedControllerBannerDisplacement, HyperPause_XScale)
    OptionScale(HyperPause_Artwork_VMargin, HyperPause_YScale)
    OptionScale(HyperPause_Artwork_HMargin, HyperPause_XScale)
    OptionScale(HyperPause_Artwork_HdistBetwPages, HyperPause_XScale)
    OptionScale(HyperPause_Artwork_VdistBetwLabels, HyperPause_YScale)
    OptionScale(HyperPause_Artwork_HdistBetwLabelsandPages, HyperPause_XScale)
    OptionScale(HyperPause_Videos_VMargin, HyperPause_YScale)
    OptionScale(HyperPause_Videos_HMargin, HyperPause_XScale)
    OptionScale(HyperPause_Videos_VdistBetwLabels, HyperPause_YScale)
    OptionScale(HyperPause_SubMenu_SizeofVideoButtons, HyperPause_XScale)
    OptionScale(HyperPause_SubMenu_SpaceBetweenVideoButtons, HyperPause_YScale)
    OptionScale(HyperPause_SubMenu_SpaceBetweenLabelsandVideoButtons, HyperPause_XScale)
    OptionScale(HyperPause_AuxiliarScreen_FontSize, HyperPause_YScale)
    OptionScale(HyperPause_AuxiliarScreen_ExitTextMargin, HyperPause_XScale)
Return	
}  

;-----------------SOUND CONTROL FUNCTIONS------------
;Draw the colored progress bars.
DrawSoundFullProgress(G, X, Y, W, H, color1, color2) {
   PBRUSH := Gdip_CreateLineBrushFromRect(X-W, Y-H, W-5, H, color1, color2)
   Gdip_Alt_FillRoundedRectangle(G, PBRUSH, X-W, Y-H, W, H, 3)
   PBRUSH := Gdip_CreateLineBrushFromRect(X-W, Y-H, W//2, H, 0xAAFFFFFF, 0x11FFFFFF)
   Gdip_Alt_FillRoundedRectangle(G, PBRUSH, X-W, Y-H, W//2, H, 3)
   PPEN := Gdip_CreatePen(0x22000000, 1)
   Gdip_Alt_DrawRoundedRectangle(G, PPEN, X-W, Y-H, W, H, 3)
}

;Draw the blank progress bars.
DrawSoundEmptyProgress(G, X, Y, W, H) {
    PBRUSH := Gdip_CreateLineBrushFromRect(X-W, Y-H, W-5, H, 0xFF8E8F8E, 0xFF565756)
    Gdip_Alt_FillRoundedRectangle(G, PBRUSH, X-W, Y-H, W, H, 3)
    PBRUSH := Gdip_CreateLineBrushFromRect(X-W, Y-H, W//2, H, 0xAAFFFFFF, 0x11FFFFFF)
    Gdip_Alt_FillRoundedRectangle(G, PBRUSH, X-W, Y-H, W//2, H, 3)
    PPEN := Gdip_CreatePen(0x22000000, 1)
    Gdip_Alt_DrawRoundedRectangle(G, PPEN, X-W, Y-H, W, H, 3)
}

;Main Menu Clock
Clock:
    Gdip_GraphicsClear(HP_G28)
    FormatTime, CurrentTime, %A_Now%, dddd MMMM d, yyyy hh:mm:ss tt
    CurrentTimeTextLenghtWidth := MeasureText(CurrentTime, "Left r4 s" . HyperPause_MainMenu_ClockFontSize . " Regular",HyperPause_MainMenu_ClockFont)
    pGraphUpd(HP_G28,CurrentTimeTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_MainMenu_ClockFontSize)
    posCurrentTimeX := CurrentTimeTextLenghtWidth + HyperPause_SubMenu_AdditionalTextMarginContour
    OptionsCurrentTime = x%posCurrentTimeX% y0 Right c%HyperPause_MainMenu_LabelDisabledColor% r4 s%HyperPause_MainMenu_ClockFontSize% Regular
    Gdip_Alt_FillRectangle(HP_G28, HyperPause_SubMenu_DisabledBrushV, 0, 0, CurrentTimeTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_MainMenu_ClockFontSize)
    Gdip_Alt_TextToGraphics(HP_G28, CurrentTime, OptionsCurrentTime, HyperPause_MainMenu_ClockFont, 0, 0)
    Alt_UpdateLayeredWindow(HP_hwnd28, HP_hdc28,baseScreenWidth - CurrentTimeTextLenghtWidth - 2*HyperPause_SubMenu_AdditionalTextMarginContour,0,CurrentTimeTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_MainMenu_ClockFontSize)
Return 

;-----------------MUSIC PLAYER------------
HyperPause_MusicPlayer:
    If (HyperPause_Loaded <> 1){
        try wmpMusic := ComObjCreate("WMPlayer.OCX")
        catch e
            Log("A Windows Media Player Music exception was thrown: " . e , 5)
        try ComObjConnect(wmpMusic, "wmpMusic_")
        catch e
            Log("A Windows Media Player Music exception was thrown: " . e , 5)
        try wmpMusic.settings.enableErrorDialogs := false
        ;loading music player paths
        If (FileExist(HyperPause_ExternalPlaylistPath))
            HyperPause_CurrentPlaylist := HyperPause_ExternalPlaylistPath            
        If !HyperPause_CurrentPlaylist
            Loop, %HyperPause_MusicPath%%systemName%\%dbName%\*.%HyperPause_PlaylistExtension%, 0
                HyperPause_CurrentPlaylist := A_LoopFileFullPath
        If !HyperPause_CurrentPlaylist {
            Loop, %HyperPause_MusicPath%%systemName%\%dbName%\*.*, 0
                If A_LoopFileExt in %CommaSeparated_MusicFilesExtension%
                    {
                    StringReplace, CurrentMusicfile, A_LoopFileFullPath, %HyperPause_MusicPath%%systemName%\%dbName%\                        
                    FileAppend, %CurrentMusicfile%`r`n, %HyperPause_MusicPath%%systemName%\%dbName%\%dbName%.m3u
                }
            If (FileExist(HyperPause_MusicPath . systemName . "\"  . dbName . "\" . dbName . ".m3u")) {
                HyperPause_PlaylistExtension := "m3u"
                HyperPause_CurrentPlaylist := HyperPause_MusicPath . systemName . "\"  . dbName . "\" . dbName . ".m3u"
            }
        }
        If !HyperPause_CurrentPlaylist
            Loop, %HyperPause_MusicPath%%systemName%\%DescriptionNameWithoutDisc%\*.%HyperPause_PlaylistExtension%, 0
                HyperPause_CurrentPlaylist := A_LoopFileFullPath
        If !HyperPause_CurrentPlaylist {
            Loop, %HyperPause_MusicPath%%systemName%\%DescriptionNameWithoutDisc%\*.*, 0
                If A_LoopFileExt in %CommaSeparated_MusicFilesExtension%
                    {
                    StringReplace, CurrentMusicfile, A_LoopFileFullPath, %HyperPause_MusicPath%%systemName%\%DescriptionNameWithoutDisc%\                        
                    FileAppend, %CurrentMusicfile%`r`n, %HyperPause_MusicPath%%systemName%\%DescriptionNameWithoutDisc%\%dbName%.m3u
                }
            If (FileExist(HyperPause_MusicPath . systemName . "\"  . DescriptionNameWithoutDisc . "\" . dbName . ".m3u")) {
                HyperPause_PlaylistExtension := "m3u"
                HyperPause_CurrentPlaylist := HyperPause_MusicPath . systemName . "\"  . DescriptionNameWithoutDisc . "\" . dbName . ".m3u"
            }
        }
        If !HyperPause_CurrentPlaylist
            Loop, %HyperPause_MusicPath%%systemName%\_Default\*.%HyperPause_PlaylistExtension%, 0
                HyperPause_CurrentPlaylist := A_LoopFileFullPath
        If !HyperPause_CurrentPlaylist {
            Loop, %HyperPause_MusicPath%%systemName%\_Default\*.*, 0
                If A_LoopFileExt in %CommaSeparated_MusicFilesExtension%
                    {
                    StringReplace, CurrentMusicfile, A_LoopFileFullPath, %HyperPause_MusicPath%%systemName%\_Default\                        
                    FileAppend, %CurrentMusicfile%`r`n, %HyperPause_MusicPath%%systemName%\_Default\default.m3u
                }
            If (FileExist(HyperPause_MusicPath . systemName . "\_Default\default.m3u")) {
                HyperPause_PlaylistExtension := "m3u"
                HyperPause_CurrentPlaylist := HyperPause_MusicPath . systemName . "\_Default\default.m3u"
            }
        }
        If !HyperPause_CurrentPlaylist
            Loop, %HyperPause_MusicPath%_Default\*.%HyperPause_PlaylistExtension%, 0
                HyperPause_CurrentPlaylist := A_LoopFileFullPath
        If !HyperPause_CurrentPlaylist {
            Loop, %HyperPause_MusicPath%_Default\*.*, 0
                If A_LoopFileExt in %CommaSeparated_MusicFilesExtension%
                    {
                    StringReplace, CurrentMusicfile, A_LoopFileFullPath, %HyperPause_MusicPath%_Default\                        
                    FileAppend, %CurrentMusicfile%`r`n, %HyperPause_MusicPath%_Default\default.m3u
                }
            If (FileExist(HyperPause_MusicPath . "_Default\default.m3u")) {
                HyperPause_PlaylistExtension := "m3u"
                HyperPause_CurrentPlaylist := HyperPause_MusicPath . "_Default\default.m3u"
            }
        }
        ;loading music player songs
        try wmpMusic.settings.volume := HyperPause_MusicPlayerVolumeLevel
        try wmpMusic.settings.autoStart := false
        try wmpMusic.Settings.setMode("shuffle",false)
        If((HyperPause_EnableMusicOnStartup = "true") and (HyperPauseInitialMuteState<>1))
            try wmpMusic.settings.autoStart := true
        try wmpMusic.uimode := "invisible"
        If(HyperPause_EnableLoop="true")
            try wmpMusic.Settings.setMode("Loop",true)
        If(HyperPause_EnableShuffle="true")
            try wmpMusic.Settings.setMode("shuffle",true)
        try wmpMusic.Url := HyperPause_CurrentPlaylist
        If(HyperPause_CurrentPlaylist<>""){
            ;musicPlayerImages
            HyperPauseMusicImage1 = %HyperPause_IconsImagePath%MusicPlayerStop.png
            HyperPauseMusicImage2 = %HyperPause_IconsImagePath%MusicPlayerPrevious.png      
            HyperPauseMusicImage3 = %HyperPause_IconsImagePath%MusicPlayerPlay.png   
            HyperPauseMusicImage4 = %HyperPause_IconsImagePath%MusicPlayerNext.png             
            HyperPauseMusicImage5 = %HyperPause_IconsImagePath%MusicPlayerPause.png   
        }
        If not wmpVersion {
            try wmpVersion := wmpMusic.versionInfo
            Log("Windows Media Player Version: " . wmpVersion,5)
        }
    } Else {
        try CurrentMusicPlayStatus := wmpMusic.playState
        If(HyperPause_EnableMusicOnStartup = "true")
            If(CurrentMusicPlayStatus=2)
                try wmpMusic.controls.play
    }
Return


UpdateMusicPlayingInfo:
    If (SelectedMenuOption="Sound"){
        Gdip_GraphicsClear(HP_G33)
        pGraphUpd(HP_G33,HyperPause_SubMenu_Width,HyperPause_SubMenu_Height)
        MusicPlayerTextX := round((HyperPause_SubMenu_Width)/2) 
        MusicPlayerTextY := posSoundBarTextY+SoundBarHeight+HyperPause_SubMenu_SoundMuteButtonVDist+HyperPause_SubMenu_SoundMuteButtonFontSize+HyperPause_SubMenu_MusicPlayerVDist + HyperPause_SubMenu_SizeofMusicPlayerButtons + HyperPause_SubMenu_SmallFontSize
        OptionsMusicPlayerText = x%MusicPlayerTextX% y%MusicPlayerTextY% Center c%HyperPause_MainMenu_LabelDisabledColor% r4 s%HyperPause_SubMenu_SmallFontSize% bold
        try CurrentMusicPlayStatus := wmpMusic.playState
        try CurrentMusicPositionString := wmpMusic.controls.currentPositionString
        try CurrentMusicStatusDescription := wmpMusic.status
        try CurrentMusicDurationString := wmpMusic.currentMedia.durationString
        If ((CurrentMusicPositionString<>"") and ((CurrentMusicPlayStatus=2) or (CurrentMusicPlayStatus=3))) {
            Gdip_Alt_TextToGraphics(HP_G33, CurrentMusicStatusDescription . " - " . CurrentMusicPositionString . " (" . CurrentMusicDurationString . ")", OptionsMusicPlayerText, HyperPause_SubMenu_Font, 0, 0)
        }
        posHelpY := HyperPause_SubMenu_Height - HyperPause_SubMenu_SmallFontSize
        If(VSubMenuItem = 1){
            HelpTextLenghtWidth := MeasureText("Press Left or Right to Change the Volume Level", "Left r4 s" . HyperPause_SubMenu_HelpFontSize . " Regular",HyperPause_SubMenu_HelpFont)
            posHelpX := round(HyperPause_SubMenu_Width - HelpTextLenghtWidth/2 - HyperPause_SubMenu_AdditionalTextMarginContour)
            OptionsHelp = x%posHelpX% y%posHelpY% Center c%HyperPause_MainMenu_LabelDisabledColor% r4 s%HyperPause_SubMenu_HelpFontSize% Regular
            Gdip_Alt_FillRectangle(HP_G33, HyperPause_SubMenu_DisabledBrushV, HyperPause_SubMenu_Width - HelpTextLenghtWidth - 2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_Height- HyperPause_SubMenu_SmallFontSize, HelpTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_HelpFontSize)
            Gdip_Alt_TextToGraphics(HP_G33, "Press Left or Right to Change the Volume Level", OptionsHelp, HyperPause_SubMenu_HelpFont, 0, 0)
        }
        If(VSubMenuItem = 2) and (HSubmenuitemSoundVSubmenuitem2=1){
            HelpTextLenghtWidth := MeasureText("Press Select to Change Mute Status", "Left r4 s" . HyperPause_SubMenu_HelpFontSize . " Regular",HyperPause_SubMenu_HelpFont)
            posHelpX := round(HyperPause_SubMenu_Width - HelpTextLenghtWidth/2 - HyperPause_SubMenu_AdditionalTextMarginContour)
            OptionsHelp = x%posHelpX% y%posHelpY% Center c%HyperPause_MainMenu_LabelDisabledColor% r4 s%HyperPause_SubMenu_HelpFontSize% Regular
            Gdip_Alt_FillRectangle(HP_G33, HyperPause_SubMenu_DisabledBrushV, HyperPause_SubMenu_Width - HelpTextLenghtWidth - 2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_Height- HyperPause_SubMenu_SmallFontSize, HelpTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_HelpFontSize)
            Gdip_Alt_TextToGraphics(HP_G33, "Press Select to Change Mute Status", OptionsHelp, HyperPause_SubMenu_HelpFont, 0, 0)
        }
        If(VSubMenuItem = 2) and (HSubmenuitemSoundVSubmenuitem2=2){
            HelpTextLenghtWidth := MeasureText("Press Select to Enable Music While Playing the Game", "Left r4 s" . HyperPause_SubMenu_HelpFontSize . " Regular",HyperPause_SubMenu_HelpFont)
            posHelpX := round(HyperPause_SubMenu_Width - HelpTextLenghtWidth/2 - HyperPause_SubMenu_AdditionalTextMarginContour)
            OptionsHelp = x%posHelpX% y%posHelpY% Center c%HyperPause_MainMenu_LabelDisabledColor% r4 s%HyperPause_SubMenu_HelpFontSize% Regular
            Gdip_Alt_FillRectangle(HP_G33, HyperPause_SubMenu_DisabledBrushV, HyperPause_SubMenu_Width - HelpTextLenghtWidth - 2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_Height- HyperPause_SubMenu_SmallFontSize, HelpTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_HelpFontSize)
            Gdip_Alt_TextToGraphics(HP_G33, "Press Select to Enable Music While Playing the Game", OptionsHelp, HyperPause_SubMenu_HelpFont, 0, 0)
        }
        If(VSubMenuItem = 3){
            HelpTextLenghtWidth := MeasureText("Press Select to Choose Music Control Option", "Left r4 s" . HyperPause_SubMenu_HelpFontSize . " Regular",HyperPause_SubMenu_HelpFont)
            posHelpX := round(HyperPause_SubMenu_Width - HelpTextLenghtWidth/2 - HyperPause_SubMenu_AdditionalTextMarginContour)
            OptionsHelp = x%posHelpX% y%posHelpY% Center c%HyperPause_MainMenu_LabelDisabledColor% r4 s%HyperPause_SubMenu_HelpFontSize% Regular
            Gdip_Alt_FillRectangle(HP_G33, HyperPause_SubMenu_DisabledBrushV, HyperPause_SubMenu_Width - HelpTextLenghtWidth - 2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_Height- HyperPause_SubMenu_SmallFontSize, HelpTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_HelpFontSize)
            Gdip_Alt_TextToGraphics(HP_G33, "Press Select to Choose Music Control Option", OptionsHelp, HyperPause_SubMenu_HelpFont, 0, 0)
        }
        Alt_UpdateLayeredWindow(HP_hwnd33, HP_hdc33, baseScreenWidth - HyperPause_SubMenu_Width,baseScreenHeight-HyperPause_SubMenu_Height,HyperPause_SubMenu_Width,HyperPause_SubMenu_Height)
    } Else {
        Gdip_GraphicsClear(HP_G33)     
        Alt_UpdateLayeredWindow(HP_hwnd33, HP_hdc33, baseScreenWidth - HyperPause_SubMenu_Width,baseScreenHeight-HyperPause_SubMenu_Height,HyperPause_SubMenu_Width,HyperPause_SubMenu_Height)            
    }
Return


UpdateVideoPlayingInfo:
    If (SelectedMenuOption="Videos") and (VSubMenuItem <> 0){
        Gdip_GraphicsClear(HP_G33)
        pGraphUpd(HP_G33,HyperPause_SubMenu_Width,HyperPause_SubMenu_Height)
        VideoPlayerTextX := (2*HyperPause_Videos_HMargin + HPMediaObj["Videos"].maxLabelSize + 2*HyperPause_SubMenu_AdditionalTextMarginContour) + (HyperPause_SubMenu_Width - (2*HyperPause_Videos_HMargin+HPMediaObj["Videos"].maxLabelSize+2*HyperPause_SubMenu_AdditionalTextMarginContour)) // 2 
        VideoPlayerTextY := HyperPause_SubMenu_SmallFontSize // 2
        OptionsVideoPlayerText = x%VideoPlayerTextX% y%VideoPlayerTextY% Center c%HyperPause_MainMenu_LabelDisabledColor% r4 s%HyperPause_SubMenu_SmallFontSize% bold
        try CurrentVideoPlayStatus := wmpVideo.playState
        try CurrentVideoPositionString := wmpVideo.controls.currentPositionString
        try CurrentVideoStatusDescription := wmpVideo.status
        try CurrentVideoDurationString := wmpVideo.currentMedia.durationString
        If ((CurrentVideoPositionString<>"") and ((CurrentVideoPlayStatus=2) or (CurrentVideoPlayStatus=3)))
            Gdip_Alt_TextToGraphics(HP_G33, CurrentVideoStatusDescription . " - " . CurrentVideoPositionString . " (" . CurrentVideoDurationString . ")", OptionsVideoPlayerText, HyperPause_SubMenu_Font, 0, 0)
        posHelpY := HyperPause_SubMenu_Height - HyperPause_SubMenu_SmallFontSize
        If(HSubMenuItem = 1){
            HelpTextLenghtWidth := MeasureText("Press Up or Down to Select the Video and Left or Right to Control the Video Playing", "Left r4 s" . HyperPause_SubMenu_HelpFontSize . " Regular",HyperPause_SubMenu_HelpFont)
            posHelpX := round(HyperPause_SubMenu_Width - HelpTextLenghtWidth/2 - HyperPause_SubMenu_AdditionalTextMarginContour)
            OptionsHelp = x%posHelpX% y%posHelpY% Center c%HyperPause_MainMenu_LabelDisabledColor% r4 s%HyperPause_SubMenu_HelpFontSize% Regular
            Gdip_Alt_FillRectangle(HP_G33, HyperPause_SubMenu_DisabledBrushV, HyperPause_SubMenu_Width - HelpTextLenghtWidth - 2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_Height- HyperPause_SubMenu_SmallFontSize, HelpTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_HelpFontSize)
            Gdip_Alt_TextToGraphics(HP_G33, "Press Up or Down to Select the Video and Left or Right to Control the Video Playing", OptionsHelp, HyperPause_SubMenu_HelpFont, 0, 0)
        } Else If(HSubMenuItem = 2) {
            If (V2SubMenuItem=1){
                If(CurrentVideoPlayStatus=3)                
                    VideoHelpText := "Press Select to Pause Video Playing"
                Else
                    VideoHelpText := "Press Select to Resume Playing Video"
            } Else If (V2SubMenuItem=2) {
                VideoHelpText := "Press Select to go to Full Screen"
            } Else If (V2SubMenuItem=3) {
                VideoHelpText := "Press Select to Rewind the Video " . HyperPause_SubMenu_VideoRewindFastForwardJumpSeconds " seconds"
            } Else If (V2SubMenuItem=4) {
                VideoHelpText := "Press Select to Fast Forward " . HyperPause_SubMenu_VideoRewindFastForwardJumpSeconds " seconds"
            }
            HelpTextLenghtWidth := MeasureText(VideoHelpText, "Left r4 s" . HyperPause_SubMenu_HelpFontSize . " Regular",HyperPause_SubMenu_HelpFont)
            posHelpX := round(HyperPause_SubMenu_Width - HelpTextLenghtWidth/2 - HyperPause_SubMenu_AdditionalTextMarginContour)
            OptionsHelp = x%posHelpX% y%posHelpY% Center c%HyperPause_MainMenu_LabelDisabledColor% r4 s%HyperPause_SubMenu_HelpFontSize% Regular
            Gdip_Alt_FillRectangle(HP_G33, HyperPause_SubMenu_DisabledBrushV, HyperPause_SubMenu_Width - HelpTextLenghtWidth - 2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_Height- HyperPause_SubMenu_SmallFontSize, HelpTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_HelpFontSize)
            Gdip_Alt_TextToGraphics(HP_G33, VideoHelpText, OptionsHelp, HyperPause_SubMenu_HelpFont, 0, 0)
        }
        Alt_UpdateLayeredWindow(HP_hwnd33, HP_hdc33, baseScreenWidth - HyperPause_SubMenu_Width,baseScreenHeight-HyperPause_SubMenu_Height,HyperPause_SubMenu_Width,HyperPause_SubMenu_Height)
    } Else {
        Gdip_GraphicsClear(HP_G33)   
        Alt_UpdateLayeredWindow(HP_hwnd33, HP_hdc33, baseScreenWidth - HyperPause_SubMenu_Width,baseScreenHeight-HyperPause_SubMenu_Height,HyperPause_SubMenu_Width,HyperPause_SubMenu_Height)            
    }
Return

  
SaveScreenshot:
    CoordMode, ToolTip
    ToolTip
    HyperPause_SaveScreenshotPath := HLMediaPath . "\Artwork\" . systemname . "\" . dbName . "\Screenshots\"
        IfNotExist, %HyperPause_SaveScreenshotPath%
            FileCreateDir, %HyperPause_SaveScreenshotPath%
    if !HyperPause_Screenshot_Extension
        {
        ; Loading HyperPause ini keys 
        HyperPause_GlobalFile := A_ScriptDir . "\Settings\Global HyperPause.ini" 
        HyperPause_SystemFile := A_ScriptDir . "\Settings\" . systemName . "\HyperPause.ini" 
        If (RIni_Read(3,HyperPause_GlobalFile) = -11) {
            Log("Global HyperPause.ini file not found, creating a new one.",5)
            RIni_Create(3)
        }
        If (RIni_Read(4,HyperPause_SystemFile) = -11) {
            IfNotExist, % A_ScriptDir . "\Settings\" . systemName
                FileCreateDir, % A_ScriptDir . "\Settings\" . systemName
            Log( A_ScriptDir . "\Settings\" . systemName . "\HyperPause.ini file not found, creating a new one.",5)
            RIni_Create(4)
        }
        HyperPause_Screenshot_Extension := RIniHyperPauseLoadVar(3,4, "General Options", "Screenshot_Extension", "jpg") ;Supported extensions are: .BMP,.DIB,.RLE,.JPG,.JPEG,.JPE,.JFIF,.GIF,.TIF,.TIFF,.PNG
        HyperPause_Screenshot_JPG_Quality := RIniHyperPauseLoadVar(3,4, "General Options", "Screenshot_JPG_Quality", "100") ;If saving as jpg (.JPG,.JPEG,.JPE,.JFIF) then quality can be 1-100 with default at maximum quality
    }
    CurrentScreenshotFileName := A_Now . "." . HyperPause_Screenshot_Extension
    pToken := Gdip_Startup()
    CaptureScreen(HyperPause_SaveScreenshotPath . CurrentScreenshotFileName,  "0|0|" . A_ScreenWidth . "|" . A_ScreenHeight , HyperPause_Screenshot_JPG_Quality)
    ToolTip, Screenshot saved (%HyperPause_SaveScreenshotPath%%CurrentScreenshotFileName%), 0,baseScreenHeight
    settimer,EndofToolTipDelay, -2000   
    If HyperPause_Loaded
        {
        If(HyperPause_ArtworkMenuEnabled="true"){
            ;reseting menu variables
            ArtworkList =
            Loop, % HPMediaObj["Artwork"].TotalLabels 
                {
                FileCount := a_index
                ArtworkFileExtension%FileCount% =
                ArtworkFile%FileCount% =
                ArtworkCompressedFile%FileCount%Loaded =
                TotalSubMenuArtworkPages%FileCount% =
                Loop, % TotalSubMenuArtworkPages%FileCount%
                    {
                    %SubMenuName%File%FileCount%File%a_index% =
                }
                TotalSubMenuArtworkPages%FileCount% =
            }
            ;creating an Artwork object to show the new screenshot
            if !HPMediaObj
                HPMediaObj := []
            if HPMediaObj["Artwork"].Screenshots.Label
                {
                currentobj := HPMediaObj["Artwork"].Screenshots
                currentobj["TotalItems"] := currentobj.TotalItems+1
                currentobj["Type"] := "ImageGroup"
            } else {
                if HPMediaObj["Artwork"].TotalLabels
                {
                    currentobj := {}
                    currentobj["Label"] := "Screenshots"
                    currentobj["TotalItems"] := 1
                    HPMediaObj["Artwork"].TotalLabels := HPMediaObj["Artwork"].TotalLabels+1
                    HPMediaObj["Artwork"][HPMediaObj["Artwork"].TotalLabels] := currentobj["Label"]
                }
            }
            currentobj["Path" . currentobj.TotalItems] := HyperPause_SaveScreenshotPath . CurrentScreenshotFileName
            currentobj["Ext" . currentobj.TotalItems] := HyperPause_Screenshot_Extension
            HPMediaObj["Artwork"].Insert(currentobj["Label"], currentobj)
            ;updating artwork menu If active
            If HyperPause_Running
                If(SelectedMenuOption="Artwork")
                    gosub, DrawSubMenu
            If HyperPause_MainMenu_Labels not contains Artwork
                {
                HyperPause_MainMenu_Labels .= "|Artwork" 
                TotalMainMenuItems++
                Gdip_GraphicsClear(HP_G25)
                Gosub DrawMainMenuBar
                Alt_UpdateLayeredWindow(HP_hwnd25, HP_hdc25,0,round((baseScreenHeight-HyperPause_MainMenu_BarHeight)/2)+HyperPause_MainMenu_BarVerticalOffset, baseScreenWidth, HyperPause_MainMenu_BarHeight)
            }
        }
    }
Return

CaptureScreen(File,screen,quality=100)
{
    Global
    raster := 0x40000000 + 0x00CC0020
    screenBitmapPointer := Gdip_BitmapFromScreen(screen,raster)
    Gdip_SaveBitmapToFile(screenBitmapPointer, File, quality)
    Gdip_DisposeImage(screenBitmapPointer)
    return
}

EndofToolTipDelay:
	ToolTip
Return


;Mouse Control
hpMouseClick:
    submenuMouseClickChange := 1
    Gdip_GraphicsClear(HP_G32)
    If (FullScreenView = 1)
        Gdip_Alt_DrawImage(HP_G32, MouseFullScreenOverlayBitmap, 0, 0, MouseOverlayW, MouseOverlayH)
    Else
        Gdip_Alt_DrawImage(HP_G32, MouseOverlayBitmap, 0, 0, MouseOverlayW, MouseOverlayH)	
    If(HyperPause_MouseClickSound = "true") {
        Random, MouseRndmSound, 1, % MouseSoundsAr.MaxIndex()
        MouseRndmSoundPath := % HyperPause_MouseSoundPath . MouseSoundsAr[MouseRndmSound]
        log("Selected Mouse Click Sound: " . MouseRndmSoundPath,5)
    }
    CoordMode, Mouse, Screen 
    MouseGetPos, ClickX, ClickY
    if (screenRotationAngle=0) {
        ClickY := ClickY - (A_ScreenHeight-MouseOverlayH)
    } else if (screenRotationAngle=90) {
        Gdip_Alt_GetRotatedDimensions(ClickX, ClickY, screenRotationAngle, ClickX, ClickY)
        ClickY := MouseOverlayH - ClickY
    } else if (screenRotationAngle=180){
        ClickX := ClickX - (A_ScreenWidth - MouseOverlayW)
        ClickX := MouseOverlayW - ClickX
        ClickY := MouseOverlayH - ClickY
    } else if (screenRotationAngle=270) {
        ClickX := ClickX - (A_ScreenWidth - MouseOverlayH)
        ClickY := ClickY - (A_ScreenHeight-MouseOverlayW)
        X := ClickY
        ClickY := ClickX
        ClickX := MouseOverlayW - X
    } 
    if (ClickX>MouseOverlayW) or (ClickY>MouseOverlayH)
        Return        
    If (FullScreenView = 1)
        MouseMaskColor := Gdip_GetPixel( MouseFullScreenMaskBitmap, ClickX, ClickY)
    Else
        MouseMaskColor := Gdip_GetPixel( MouseMaskBitmap, ClickX, ClickY)	
    SetFormat Integer, Hex
    MouseMaskColor += 0
    SetFormat Integer, D
    If (MouseMaskColor=0xFFFF0000) {
        Gdip_Alt_DrawImage(HP_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseRndmSound
            SoundPlay, %MouseRndmSoundPath%, Wait
        gosub, MoveUp
    } Else If (MouseMaskColor=0xFF00FFFF) {
        Gdip_Alt_DrawImage(HP_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay, %MouseRndmSoundPath%
        gosub, MoveRight
    } Else If (MouseMaskColor=0xFF0000FF) {
        Gdip_Alt_DrawImage(HP_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay, %MouseRndmSoundPath%
        gosub, MoveDown
    } Else If (MouseMaskColor=0xFF00FF00) {
        Gdip_Alt_DrawImage(HP_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay, %MouseRndmSoundPath%
        gosub, MoveLeft
    } Else If (MouseMaskColor=0xFFFF00FF) {
        Gdip_Alt_DrawImage(HP_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay, %MouseRndmSoundPath%
        gosub, ToggleItemSelectStatus
    } Else If (MouseMaskColor=0xFFFFFF00) {
        Gdip_Alt_DrawImage(HP_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay, %MouseRndmSoundPath%
        gosub, TogglePauseMenuStatus
    } Else If (MouseMaskColor=0xFFFF6400) {
        Gdip_Alt_DrawImage(HP_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay, %MouseRndmSoundPath%
        gosub, BacktoMenuBar
    } Else If (MouseMaskColor=0xFF00FF64) {
        Gdip_Alt_DrawImage(HP_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay, %MouseRndmSoundPath%
        gosub, SaveScreenshot
    } Else If (MouseMaskColor=0xFF6400FF) {
        Gdip_Alt_DrawImage(HP_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay, %MouseRndmSoundPath%
        gosub, ZoomIn
    } Else If (MouseMaskColor=0xFF0064FF) {
        Gdip_Alt_DrawImage(HP_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay, %MouseRndmSoundPath%
        gosub, ZoomOut
    }
    Alt_UpdateLayeredWindow(HP_hwnd32, HP_hdc32,0,baseScreenHeight-MouseOverlayH, MouseOverlayW, MouseOverlayH,HyperPause_MouseControlTransparency)
    settimer, ClearMouseClickImages, -500
Return


ClearMouseClickImages:
    Gdip_GraphicsClear(HP_G32)
    If (FullScreenView = 1)
        Gdip_Alt_DrawImage(HP_G32, MouseFullScreenOverlayBitmap, 0, 0, MouseOverlayW, MouseOverlayH)
    Else
        Gdip_Alt_DrawImage(HP_G32, MouseOverlayBitmap, 0, 0, MouseOverlayW, MouseOverlayH)	
    Alt_UpdateLayeredWindow(HP_hwnd32, HP_hdc32,0,baseScreenHeight-MouseOverlayH, MouseOverlayW, MouseOverlayH,HyperPause_MouseControlTransparency)        
Return


; Windows Media Player Error handling (NOT WORKING)
wmpVideo_Error(wmpVideo) {
    try max := wmpVideo.error.errorCount
    try ErrorDescription := wmpVideo.error.item(max-1).errorDescription
    Log("A Windows Media Player Video exception was thrown: " . ErrorDescription , 5)
Return
} 

wmpMusic_Error(wmpMusic) {
    try max := wmpMusic.error.errorCount
    try ErrorDescription := wmpMusic.error.item(max-1).errorDescription
    Log("A Windows Media Player Music exception was thrown: " . ErrorDescription , 5)
Return
} 





loadingText(message) ;dynamic loading text
    {
    Global
    HyperPause_LoadingMessage_Font := "Bebas Neue"
    HyperPause_LoadingMessage_FontSize := "20"
    HyperPause_LoadingMessage_FontColor := "ff222222"
    OptionScale(HyperPause_LoadingMessage_FontSize, HyperPause_YScale)
    Gdip_GraphicsClear(HP_G21b)
    messageLenghtWidth := MeasureText(message, "Left r4 s" . HyperPause_LoadingMessage_FontSize . " Regular",HyperPause_LoadingMessage_Font)
    pGraphUpd(HP_G21b,messageLenghtWidth, HyperPause_LoadingMessage_FontSize)
    messageTextOptions = x0 y0 Left c%HyperPause_LoadingMessage_FontColor% r4 s%HyperPause_LoadingMessage_FontSize% Regular
    Gdip_Alt_TextToGraphics(HP_G21b, message, messageTextOptions, HyperPause_LoadingMessage_Font)
    Alt_UpdateLayeredWindow(HP_hwnd21b, HP_hdc21b, HyperPause_AuxiliarScreen_ExitTextMargin, baseScreenHeight - HyperPause_AuxiliarScreen_ExitTextMargin//2 - HyperPause_LoadingMessage_FontSize//2,messageLenghtWidth,HyperPause_LoadingMessage_FontSize)
    Return    
}
