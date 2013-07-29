MCRC=B387AFF1
mVersion=1.0.2

;Author: bleasby
;Thanks to djvj and brolly for helping in the development of HyperPause (without them this would be impossible to achieve)
;Thanks to THK for the great work with moves list icons
;Thanks to BBB for making HyperSpin and thanks to all the hyperspin community 
;Thanks to Rain for developing the system scrapper info
;Thanks to all beta testers, ghutch92 (thks for the owner gui code), dustind900, emb, mameshane, DrMoney,...
;Thanks to autohotkey community for library and example scripts
;Thanks to all people involde at command.dat, emumovies and tempest for the system ini files, HitoText,cpwizard... 
;---------------------------------------
;If you want to modify my code, feel free to do it.
;I am also open for any new feature suggestion. Use the HyperSpin forum to let me know of any new ideas.
;A necessary Warning for anyone that wants to modify my code! I am not a programmer. I did this as a hobby and a way to learn languages and autohotkey. Right now I would do a lot of things diferently, but time is a scarce commodity.
;Probably my way to code is not the smallest, more structured or more efficient way to do things.
;I am really, really, open to any suggestion about the code If you have more experience in codding.

;File Descripton
;This file contains all functions and labels related with the HyperPause Addon

;HyperPause Layers
; 	- HP_GUI21 - Loading Screen and Black Screen to Hide Hyperspin
; 	- HP_GUI22 - Background Image (covers entire screen)
; 	- HP_GUI23 - Background (covers entire screen)
; 	- HP_GUI24 - Moving description
; 	- HP_GUI25 - Main Menu bar
; 	- HP_GUI26 - Config Options (Above Bar Label)
; 	- HP_GUI27 - Submenus
; 	- HP_GUI28 - Clock
; 	- HP_GUI29 - Full Screen drawing while changing screens in HP (covers entire screen) (Help text while in submenu)
; 	- HP_GUI30 - Disc Rotation, animations, submenu animations
; 	- HP_GUI31 - ActiveX Video
; 	- HP_GUI32 - Mouse Overlay

;-----------------CODE-------------

HyperPause_Main:
    HyperPause_Running:=true ; HyperPause menu is running
    XHotKeywrapper(exitEmulatorKey,"CloseProcess","OFF") ;cancel exit emulator key for future reasigning 
    XHotKeywrapper(hpKey,"TogglePauseMenuStatus","OFF") ;cancel HyperPause key for future reasigning 
    If mgEnabled = true
        XHotKeywrapper(mgKey,"StartMulti","OFF") ;cancel MultiGame key while HyperPause is running
    Log("Disabled exit emulator and multigame keys",5)
	If (emuIdleShutdown and emuIdleShutdown != "ERROR")	; turn off emuIdleShutdown while in HP
		SetTimer, EmuIdleCheck, Off
    If (HyperPause_Loaded <> 1){ ; Initiate Gdip+ If first HyperPause run
        pToken := Gdip_Startup()
        Log("Started Gdip " pToken " (If number -> loaded)",5)
    }
    If(HyperPause_MainMenu_UseScreenshotAsBackground="true"){
        HyperPause_SaveScreenshotPath := HLMediaPath . "\Artwork\" . systemname . "\" . dbName . "\Screenshots\"
        IfNotExist, %HyperPause_SaveScreenshotPath%
            FileCreateDir, %HyperPause_SaveScreenshotPath%
        GameScreenshot := HyperPause_SaveScreenshotPath . "GameScreenshot.png"
        CaptureScreen(GameScreenshot)
    }
    ; Loading HyperPause ini keys 
    HyperPause_GlobalFile := A_ScriptDir . "\Settings\Global HyperPause.ini" 
    HyperPause_SystemFile := A_ScriptDir . "\Settings\" . systemName . "\HyperPause.ini" 
    If (RIni_Read(3,HyperPause_GlobalFile) = -11) {
        Log("Global HyperPause.ini file not found, creating a new one.",5)
        RIni_Create(3)
    }
    If (RIni_Read(4,HyperPause_SystemFile) = -11) {
        Log("System\HyperPause.ini file not found, creating a new one.",5)
        RIni_Create(4)
	}
    xp := IsWinXPOrBelow() ;identify the OS for sound control
    ;Mute when loading HyperPause to avoiding sound stuttering
    HyperPause_MuteWhenLoading := RIniHyperPauseLoadVar(3,4, "General Options", "Mute_when_Loading_Hyperpause", "true") 
    HyperPause_MuteSound := RIniHyperPauseLoadVar(3,4, "General Options", "Mute_Sound", "false") 
    If((HyperPause_MuteWhenLoading="true") or (HyperPause_MuteSound="true")){ 
        InitialMuteState := GetMasterMute()
        If(InitialMuteState<>1){
            SetMasterMute(true)
            Log("Muting computer sound while HP is loaded. Master Mute status: " GetMasterMute() " (1 is mutted)",5)
        }
    }
    ; Reading HyperPause menu disable option for canceling HyperPause drawn
    HyperPause_Disable_Menu := RIniHyperPauseLoadVar(3,4, "General Options", "Disable_HyperPause_Menu", "true") 
    If !disableLoadScreen 
        gosub, HideHyperSpin ; Creating HP_GUI21 non activated Black Screen to Hide HyperSpin 
    Log("HyperPause Started: current rom: " dbName ", current system Name: " systemName,1)
    Log("Created Black Screen to hide HyperSpin",5)
    If (HyperPause_Loaded <> 1){ ;determining emulator information to use in system specific commands in the module files
        WinGet emulatorProcessName, ProcessName, A
        WinGetClass, EmulatorClass, A
        WinGet emulatorID, ID, A
    }
    Log("Loaded Emulator information: EmulatorProcessName: " emulatorProcessName ", EmulatorClass: " EmulatorClass ", EmulatorID: " EmulatorID,5)
    Gosub, HaltEmu ;getting system specific commands from modules and pausing the emulator 
    If !disableLoadScreen ;activating HP_GUI21 Black Screen for hidding Hyperspin If not disabled in the module 
        If !(disableActivateBlackScreen and HyperPause_Disable_Menu="true")
            WinActivate, HyperPauseBlackScreen
    Log("Loaded emulator specific module start commands",5)
    If (HyperPause_Loaded <> 1){ ;Loading Scalling options
        HyperPause_AutoScallingToScreenResolution := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Enable_Auto_Fit_Screen_Resolution", "true") 
        Log("Loaded ini options for scalable HP and Loading Background screen",5)
    }
    If !disableSuspendEmu { ;Suspending emulator process while in HyperPause (pauses the emulator If halemu does not contain pause controls)
        ProcSus(emulatorProcessName)
        Log("Emulator process suspended",5)
    }
    HyperPause_BeginTime := A_TickCount ;start to count the time expent in the pause menu for statistics purposes
    Log("Setting HP starting time for subtracting from statistics played time: " HyperPause_BeginTime,5)
    If (HyperPause_Loaded <> 1){ ;set working resolution of the emulator and scalling parameters
        ScallingFactor := 1
        If(HyperPause_AutoScallingToScreenResolution="true")
            {
            ScallingFactor := A_ScreenWidth/1280
            VScallingFactor := A_ScreenHeight/800
            If(ScallingFactor>VScallingFactor)
                ScallingFactor := VScallingFactor 
        }
        Log("Scalable HP factor: " ScallingFactor,5)
    }
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
    IfNotExist, %A_WinDir%\Fonts\BebasNeue.ttf
        {
        gosub, HPWarningMessage    
        Log("Please install the HyperPause default fonts located at " . HLMediaPath . "\Fonts folder.",3)
        XHotKeywrapper(exitEmulatorKey,"TogglePauseMenuStatus","ON")
        XHotKeywrapper(hpKey,"TogglePauseMenuStatus","ON")
        Return
    }
    If (HyperPause_Loaded <> 1){
        gosub, LoadExternalVariables ;Loading external variables and paths for the first time
        Log("Loaded HP options",5)
        If(HyperPause_AutoScallingToScreenResolution="true"){ ;Setting scalling parameters and scalling variables        
             gosub, AutoAdjustMenutoScreenResolution
             Log("Scaled HP variables",5)
         }
        gosub, FirstTimeHyperPauseRun ;Loading variables on first run        
        Log("Initilized HP variables for the first time",5)
    }
    SavedKeyDelay := A_KeyDelay ;Saving previous key delay and setting the new one for save and load state commands
    If(A_KeyDelay<HyperPause_SetKeyDelay) 
        SetKeyDelay, %HyperPause_SetKeyDelay%
	GoSub, InitializePauseMainMenu ;Initializing the main menu and creating HyperPause Guis
    Log("Initilized HP brushes and guis",5)
    Gosub DrawMainMenu ;Drawing the main menu background and game information
    UpdateLayeredWindow(HP_hwnd22, HP_hdc22,0,0, A_ScreenWidth, A_ScreenHeight)
    UpdateLayeredWindow(HP_hwnd23, HP_hdc23,0,0, A_ScreenWidth, A_ScreenHeight)
    Log("Loaded Main Menu Background and infos",5)
    Gosub DrawMainMenuBar ;Drawing the main menu bar
    UpdateLayeredWindow(HP_hwnd25, HP_hdc25,0,round((A_ScreenHeight-HyperPause_MainMenu_BarHeight)/2)+HyperPause_MainMenu_BarVerticalOffset, A_ScreenWidth, HyperPause_MainMenu_BarHeight)
    Log("Loaded Main Menu Bar. Current Main Menu Label: " HyperPause_MainMenuSelectedLabel,5)
    If(HyperPause_MainMenu_ShowClock="true"){ ;Drawing the clock
        SetTimer, Clock, 1000
        Log("Loaded Clock",5)
    }
    If not(HyperPause_MuteSound="true"){ 
        If(HyperPause_MuteWhenLoading="true"){ ;Unmuting If initial state was unmuted
            If(InitialMuteState<>1){
                CurrentMuteState := GetMasterMute()
                If(CurrentMuteState=1){
                    SetMasterMute(false)
                    Log("Unmuting computer sound while HP is loaded. Master Mute status: " GetMasterMute() " (0 is unmutted)",5)
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
    SetTimer, UpdateDescription, 15  ;Setting timer for game description scroling text
    SetTimer, SubMenuUpdate, 100  ;Setting timer for submenu apearance
    ; Clearing Loading HyperPause Screen
    Gdip_GraphicsClear(HP_G21)
    UpdateLayeredWindow(HP_hwnd21, HP_hdc21, 0, 0, A_ScreenWidth, A_ScreenHeight)
    ;Initilaizing Mouse Overlay Controls
    If(HyperPause_EnableMouseControl = "true") {
        Gdip_DrawImage(HP_G32, MouseOverlayBitmap, 0, 0, MouseOverlayW, MouseOverlayH)
        UpdateLayeredWindow(HP_hwnd32, HP_hdc32,0,A_ScreenHeight-MouseOverlayH, MouseOverlayW, MouseOverlayH,HyperPause_MouseControlTransparency)
        hotkey, LButton, hpMouseClick
    }
    HyperPause_Active:=true ;HyperPause menu active (fully loaded)
    HyperPause_Loaded = 1 ;HyperPause menu fully loaded at least one time
    Log("Finished Loading HyperPause",1)
Return

HideHyperSpin: ;Hide HyperSpin with a black Gui
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
    HyperPause_AuxiliarScreen_StartText := RIniHyperPauseLoadVar(3,4, "Start and Exit Screen", "Loading_Text", "Loading HyperPause")
    HyperPause_AuxiliarScreen_ExitText := RIniHyperPauseLoadVar(3,4, "Start and Exit Screen", "Exiting_Text", "Exiting HyperPause")
    HyperPause_AuxiliarScreen_Font := RIniHyperPauseLoadVar(3,4, "Start and Exit Screen", "Font", "Bebas Neue")
    HyperPause_AuxiliarScreen_FontSize := RIniHyperPauseLoadVar(3,4, "Start and Exit Screen", "Font_Size", "30")
    HyperPause_AuxiliarScreen_FontColor := RIniHyperPauseLoadVar(3,4, "Start and Exit Screen", "Font_Color", "ff222222")
    HyperPause_AuxiliarScreen_ExitTextMargin := RIniHyperPauseLoadVar(3,4, "Start and Exit Screen", "Text_Margin", "50")
    HyperPause_AuxiliarScreen_FontSize := round(HyperPause_AuxiliarScreen_FontSize * ScallingFactor)
    HyperPause_AuxiliarScreen_ExitTextMargin := round(HyperPause_AuxiliarScreen_ExitTextMargin * ScallingFactor)
    AuxiliarScreenTextX := HyperPause_AuxiliarScreen_ExitTextMargin
    AuxiliarScreenTextY := A_ScreenHeight - HyperPause_AuxiliarScreen_ExitTextMargin - HyperPause_AuxiliarScreen_FontSize
    OptionsLoadHP = x%AuxiliarScreenTextX% y%AuxiliarScreenTextY% Left c%HyperPause_AuxiliarScreen_FontColor% r4 s%HyperPause_AuxiliarScreen_FontSize% bold
    Gdip_TextToGraphics(HP_G21, HyperPause_AuxiliarScreen_StartText, OptionsLoadHP, HyperPause_AuxiliarScreen_Font, 0, 0)
    UpdateLayeredWindow(HP_hwnd21, HP_hdc21, 0, 0, A_ScreenWidth, A_ScreenHeight)
Return
 
HPWarningMessage: ;Drawning Warning Message If HyperPause default font not found
    ErrorExit := true
    HyperPause_Active:=true
    If(HyperPause_MuteWhenLoading="true"){ ;Unmuting If initial state was unmuted
        If(InitialMuteState<>1){
            CurrentMuteState := GetMasterMute()
            If(CurrentMuteState=1){
                SetMasterMute(false)
                Log("Unmuting computer sound while HP is loaded. Master Mute status: " GetMasterMute() " (0 is unmutted)",5)
            }
        }  
    }  
    brushWarningBackgroung := Gdip_CreateLineBrushFromRect(0, 0, round(600*ScallingFactor), round(150*ScallingFactor), 0xff555555, 0xff050505)
    penWarningBackgroung := Gdip_CreatePen(0xffffffff, round(5*ScallingFactor))
    Gdip_FillRoundedRectangle(HP_G21, brushWarningBackgroung, (A_ScreenWidth - 600*ScallingFactor)//2, (A_ScreenHeight - 150*ScallingFactor)//2, round(600*ScallingFactor), round(150*ScallingFactor), round(25*ScallingFactor))
    Gdip_DrawRoundedRectangle(HP_G21, penWarningBackgroung, (A_ScreenWidth - 600*ScallingFactor)//2, (A_ScreenHeight - 150*ScallingFactor)//2, round(600*ScallingFactor), round(150*ScallingFactor), round(25*ScallingFactor))
    WarningBitmap := Gdip_CreateBitmapFromFile(HyperPause_IconsImagePath . "Warning.png")
    Gdip_DrawImage(HP_G21,WarningBitmap, round((A_ScreenWidth - 600*ScallingFactor)//2 + 25*ScallingFactor),round((A_ScreenHeight - 150*ScallingFactor)//2 + 25*ScallingFactor),round(100*ScallingFactor),round(100*ScallingFactor))
    Gdip_TextToGraphics(HP_G21, "Please install the HyperPause default fonts located at " . HLMediaPath . "\Fonts folder.`n`nPress HyperPause Key to go back to the game.", "x" round((A_ScreenWidth-600*ScallingFactor)//2+125*ScallingFactor) " y" round((A_ScreenHeight-150*ScallingFactor)//2+25*ScallingFactor) " Center vCenter cffffffff r4 s" round(15*ScallingFactor) " Bold", , round((600 - 50 - 100)*ScallingFactor) , round((150 - 50)*ScallingFactor))
    UpdateLayeredWindow(HP_hwnd21, HP_hdc21, 0, 0, A_ScreenWidth, A_ScreenHeight)
Return
 
 
FirstTimeHyperPauseRun: ;Loading pause menu variables (first time run only)
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
    TotalSubMenuControllerPages = 0 
    TotalSubMenuArtworkPages = 0 
    FileRemoveDir, %HyperPause_GuidesTempPath%, 1   ;removing temp folders for pdf and compressed files
    FileRemoveDir, %HyperPause_ManualsTempPath%, 1
    FileRemoveDir, %HyperPause_ArtworkTempPath%, 1
    FileRemoveDir, %HyperPause_ControllerTempPath%, 1 
    Lettersandnumbers = a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,0,1,2,3,4,5,6,7,8,9,/,\ ;List of letters and numbers for using in line validation on moves list
    ;Defining supported files in txt, pdf and images menu
    Supported_Images = png
    If (HyperPause_SupportAdditionalImageFiles="true")
        Supported_Images = png,gif,tif,bmp,jpg 
    Supported_Extensions = %Supported_Images%,pdf,txt,%7zFormatsNoP%
    StringReplace, CommaSeparated_MusicFilesExtension, HyperPause_MusicFilesExtension, |,`,, All
    ;checking for bad written labels and non included labels (and adding them to the end of HyperPause_MainMenu_Labels)
    FullMainMenuLabelsList = Controller|Change Disc|Save State|Load State|HighScore|Artwork|Guides|Manuals|Videos|Sound|Statistics|Moves List|Shutdown
    StringReplace, CommaSeparated_FullMainMenuLabelsList, FullMainMenuLabelsList, |,`,, All
    Loop, parse, HyperPause_MainMenu_Labels,|,
        {
        If A_LoopField in %CommaSeparated_FullMainMenuLabelsList%
            CheckedHyperPause_MainMenu_Labels .= A_LoopField . "|"
    }
    StringReplace, CommaSeparatedCheckedList, CheckedHyperPause_MainMenu_Labels, |,`,, All
    Loop, parse, FullMainMenuLabelsList,|, 
        {
        If A_LoopField not in %CommaSeparatedCheckedList%
            CheckedHyperPause_MainMenu_Labels .= A_LoopField . "|"
    }        
    If (CheckedHyperPause_MainMenu_Labels <> HyperPause_MainMenu_Labels . "|")
        Log("You have a Main Menu item not found or bad written in the HyperPause_MainMenu_Labels items list:`r`n`t`t`t`t`t Original Ini Main Menu list: " HyperPause_MainMenu_Labels "`r`n`t`t`t`t`t Corrected Main Menu list:    " CheckedHyperPause_MainMenu_Labels,2)
    HyperPause_MainMenu_Labels := CheckedHyperPause_MainMenu_Labels
    ;loading general image paths
    If FileExist(HLMediaPath . "\Wheels\" . systemname . "\" . dbname . "\*.png") {
        WheelImageList := []
        Loop, %HLMediaPath%\Wheels\%systemname%\%dbname%\*.png
            WheelImageList.Insert(A_LoopFileFullPath)
    }
    PauseImage = %HyperPause_IconsImagePath%Pause.png  
    SoundImage = %HyperPause_IconsImagePath%Sound.png  
    MuteImage = %HyperPause_IconsImagePath%Mute.png  
    ToggleONImage = %HyperPause_IconsImagePath%Toggle_ON.png 
    ToggleOFFImage = %HyperPause_IconsImagePath%Toggle_OFF.png 
    ;loading background image paths
    HPBackground := []
    If FileExist(HyperPause_BackgroundsPath . systemName . "\"  . dbName . "\*.*")
        Loop, parse, Supported_Images,`,,
            Loop, %HyperPause_BackgroundsPath%%systemName%\%dbName%\*.%A_LoopField%
                HPBackground.Insert(A_LoopFileFullPath)
    If !HPBackground[1]
        If FileExist(HyperPause_BackgroundsPath . systemName . "\"  . DescriptionNameWithoutDisc . "\*.*")
            Loop, parse, Supported_Images,`,,
                Loop, %HyperPause_BackgroundsPath%%systemName%\%DescriptionNameWithoutDisc%\*.%A_LoopField%
                    HPBackground.Insert(A_LoopFileFullPath)
    If !HPBackground[1]
        If FileExist(HyperPause_BackgroundsPath . systemName . "\_Default\*.*")
            Loop, parse, Supported_Images,`,,
                Loop, %HyperPause_BackgroundsPath%%systemName%\_Default\*.%A_LoopField%
                    HPBackground.Insert(A_LoopFileFullPath)
    If !HPBackground[1]
        If FileExist(HyperPause_BackgroundsPath . "_Default\*.*")
            Loop, parse, Supported_Images,`,,
                Loop, %HyperPause_BackgroundsPath%_Default\*.%A_LoopField%, 0
                    HPBackground.Insert(A_LoopFileFullPath)
    ;VarizeDbName := Varize(dbName) ; Necessary to avoid invalid characters in RIni functions.
    Log("Starting Creating Contents List",5)
    Loop, parse, HyperPause_MainMenu_Labels,|, ;Loading Submenu information and excluding empty sub menus
        {
        StringReplace, temp_mainmenulabel, A_LoopField, %A_SPACE%,, All
        If(temp_mainmenulabel="Artwork"){
            Log("Loading Artwork Contents",5)
            If(HyperPause_ArtworkMenuEnabled="true"){
                MultiContentSubMenuList("Artwork") ;Creating Artwork list
            } Else {
                StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Artwork|, ;Removing Artwork menu If user defined to not show it
            }
        }
        If(temp_mainmenulabel="Controller"){
            Log("Loading Controller Contents",5)
            If(HyperPause_ControllerMenuEnabled="true"){
                MultiContentSubMenuList("Controller") ;Creating Controller list
            } Else {
                StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Controller|, ;Removing Controller menu If user defined to not show it
            }
        }
        If((temp_mainmenulabel="SaveState")or(temp_mainmenulabel="LoadState")){
            Log("Loading " temp_mainmenulabel " Contents",5)
            If(HyperPause_SaveandLoadMenuEnabled="true"){
                Loop, parse, hp%temp_mainmenulabel%KeyCodes,|, ;counting total save and load state slots
                    {
                    TotalSubMenuItems%temp_mainmenulabel%++
                } 
                If(TotalSubMenuItems%temp_mainmenulabel%<1){ ;Removing Save and Load State menus If no contents found 
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
                TotalSubMenuItems%temp_mainmenulabel%:=romTable.MaxIndex() ;Checking If the game is a multi Disc game, loading images and counting total disc sub menu items
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
                    HighScoreText := StdoutToVar_CreateProcess(hpHiToTextPath . " -ra " . """" . emuPath . "\hi\" . dbName . ".hi" . """","",hpHitoTextDir) ;Loading HighScore information
                    StringReplace, HighScoreText, HighScoreText, %a_space%,,all
                    stringreplace, HighScoreText, HighScoreText, `r`n,°,all
                    stringreplace, HighScoreText, HighScoreText, °°,,all
                    Loop, parse, HighScoreText,°, ,all
                        {
                        TotalSubMenuItems%temp_mainmenulabel% := A_Index-1
                    }
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
                    FileRead, CommandDatFileContents, %HyperPause_MovesListDataPath%%systemName%.dat
                    CommandDatFileContents := RegExReplace(CommandDatFileContents, "i)info=\s*" . dbName . "\b\s*", "BeginofMovesListRomData",1) 
                    FoundPos := RegExMatch(CommandDatFileContents, "BeginofMovesListRomData")
                    If !FoundPos {
                        If !GameXMLInfo
                            gosub ReadHyperSpinXML
                        If XMLcloneof
                            {
                            CommandDatFileContents := RegExReplace(CommandDatFileContents, "i)info=\s*" . XMLcloneof . "\b\s*", "BeginofMovesListRomData",1) 
                        }
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
                MultiContentSubMenuList("Guides") ;creating Guides list
            } Else {
                StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Guides|, ;Removing the guides submenu If user defined to not show it
            }
        }
        If(temp_mainmenulabel="Manuals"){
            Log("Loading Manuals Contents",5)
            If(HyperPause_ManualsMenuEnabled="true"){
                MultiContentSubMenuList("Manuals") ;creating Manuals list
            } Else {
                StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Manuals|, ;Removing the manuals submenu If user defined to not show it
            }
        }
        If(temp_mainmenulabel="Videos"){
            Log("Loading Videos Contents",5)
            If(HyperPause_VideosMenuEnabled="true"){
                StringReplace, ListofSupportedVideos, HyperPause_SupportedVideos, |, `,, All
                VideosSubMenuList("Videos") ;creating Videos list
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
        If(temp_mainmenulabel="Statistics"){
            If  statisticsEnabled = true
                {
                If (HyperPause_StatisticsMenuEnabled="true"){
                    Log("Loading Statistics Contents",5)
                    gosub, LoadStatistics ;Load Game Statistics Information
                    CreatingStatisticsVariablestoSubmenu()
                } Else {
                    StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Statistics|, ;Removing the Statistics submenu If user defined to not show it
                }
            } Else { 
               StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, Statistics|, 
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
            If(%A_LoopField%<>""){  
                gameinfoexist = 1
            }
        }
    }
    If(gameinfoexist<>1){ ;If the game information is not found, search for parent info and If still do not exists use the info in the hyperspin database xml files 
        If !GameXMLInfo
            gosub ReadHyperSpinXML
        Loop, parse, HyperPause_MainMenu_Info_Labels,|, 
            {        
            IniRead, %A_LoopField%, %HyperPause_GameInfoPath%%systemName%.ini, %XMLcloneof%, %A_LoopField%,%A_Space%
            If(%A_LoopField%<>""){  
                gameinfoexist = 1
            }
        }
        If(gameinfoexist<>1){
            Loop, parse, HyperPause_MainMenu_Info_Labels,|, 
                {
                %A_loopfield% := XML%A_loopfield%
            }
        }
    }
    posDescriptionY := round((A_ScreenHeight+HyperPause_MainMenu_BarHeight+HyperPause_MainMenu_Info_Description_FontSize)/2)
    Description := "                                         " Description
    StringReplace,Description,Description,<br>,%A_Space%,All
    StringLen, DescriptionLength, Description
    Loop, parse, HyperPause_MainMenu_Labels,|, ;initializing auxiliar page tracking
        {
        StringReplace, temp_mainmenulabel, A_LoopField, %A_SPACE%,, All
        Loop, % TotalSubMenuItems%temp_mainmenulabel% {    
            HSubmenuitem%temp_mainmenulabel%VSubmenuitem%a_index% = 1
            HSubmenuitem%temp_mainmenulabel%VSubmenuitem%a_index% += 0 
            HSubmenuitem%temp_mainmenulabel%V2Submenuitem%a_index% = 1
            HSubmenuitem%temp_mainmenulabel%V2Submenuitem%a_index% += 0       
        }
    }
    If(HyperPause_EnableMouseControl = "true") {
        MouseSoundsAr:=[]
        Loop, %HyperPause_MouseSoundPath%\*.mp3
        MouseSoundsAr.Insert(A_LoopFileName)
        MouseMaskBitmap := Gdip_CreateBitmapFromFile( HyperPause_MouseOverlayPath . "MouseMask.png")
        MouseOverlayBitmap := Gdip_CreateBitmapFromFile( HyperPause_MouseOverlayPath . "MouseOverlay.png")
        MouseFullScreenMaskBitmap := Gdip_CreateBitmapFromFile( HyperPause_MouseOverlayPath . "MouseFullScreenMask.png")
        MouseFullScreenOverlayBitmap := Gdip_CreateBitmapFromFile( HyperPause_MouseOverlayPath . "MouseFullScreenOverlay.png")
        MouseClickImageBitmap := Gdip_CreateBitmapFromFile( HyperPause_MouseOverlayPath . "MouseClickImage.png")
        Gdip_GetImageDimensions(MouseOverlayBitmap, MouseOverlayW, MouseOverlayH)
        Gdip_GetImageDimensions(MouseClickImageBitmap, MouseClickImageW, MouseClickImageH)
    }
Return

            
InitializePauseMainMenu: ;Drawing the main menu for the first time (constructing Gui and setting initial parameters)
    ;Loading auxiliar parameters
    MenuChanged = 1
    ItemSelected = 0
    ChandeDiscSelected = false
    ;Wheel random image
    If WheelImageList[1]
        {
        Random, RndmWheelImage, 1, % WheelImageList.MaxIndex()
        WheelImage := WheelImageList[RndmWheelImage]
    } Else {
        WheelImage := WheelImagePath . dbName . ".png"
    }
    Loop, 3
        HSubmenuitemSoundVSubmenuitem%a_index% = 1
    BlackGradientBrush := Gdip_CreateLineBrushFromRect(-1, round(A_ScreenHeight/2-50),A_ScreenWidth+2, HyperPause_MainMenu_BarHeight, "0x" . HyperPause_MainMenu_BarGradientBrush1, "0x" . HyperPause_MainMenu_BarGradientBrush2, 1, 1) ;Loading Brushs
    HyperPause_SubMenu_BackgroundBrushV := Gdip_BrushCreateSolid("0x" . HyperPause_SubMenu_BackgroundBrush)
    HyperPause_SubMenu_SelectedBrushV := Gdip_BrushCreateSolid("0x" . HyperPause_SubMenu_SelectedBrush)
    HyperPause_SubMenu_DisabledBrushV := Gdip_BrushCreateSolid("0x" . HyperPause_SubMenu_DisabledBrush)
    HyperPause_MainMenu_BackgroundBrushV := Gdip_BrushCreateSolid("0x" . HyperPause_MainMenu_BackgroundBrush)
    HyperPause_SubMenu_GuidesSelectedBrushV := Gdip_BrushCreateSolid("0x" . HyperPause_SubMenu_GuidesSelectedBrush)
    HyperPause_SubMenu_ManualsSelectedBrushV := Gdip_BrushCreateSolid("0x" . HyperPause_SubMenu_ManualsSelectedBrush)
    HyperPause_SubMenu_ControllerSelectedBrushV := Gdip_BrushCreateSolid("0x" . HyperPause_SubMenu_ControllerSelectedBrush)
    HyperPause_SubMenu_ArtworkSelectedBrushV := Gdip_BrushCreateSolid("0x" . HyperPause_SubMenu_ArtworkSelectedBrush)
    HyperPause_SubMenu_FullScreenTextBrushV := Gdip_BrushCreateSolid("0x" . HyperPause_SubMenu_FullScreenTextBrush)
    HyperPause_SubMenu_FullScreenBrushV := Gdip_BrushCreateSolid("0x" . HyperPause_SubMenu_FullScreenBrush)
    HyperPause_SubMenu_ControllerSelectedPen := Gdip_CreatePen("0x" . HyperPause_SubMenu_ControllerSelectedBrush, round(5*ScallingFactor))
    If (TotalSubMenuItemsMovesList<>0){ ;Creating Bitmaps
        Loop, %TotalCommandDatImageFiles%
            {
            CommandDatBitmap%A_index% := Gdip_CreateBitmapFromFile(CommandDatfile%A_index%)
        }
    }
    Loop, 11 { ;Creating Pause Menu Guis
        CurrentGUI := A_Index+21
        If not (CurrentGUI = 31) {
            If (A_Index=1) {
                Gui, HP_GUI%CurrentGUI%: -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop 
            } Else If (A_Index < 10) {
                OwnerGUI := CurrentGUI - 1
                Gui, HP_GUI%CurrentGUI%: +OwnerHP_GUI%OwnerGUI% -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop
            } Else {
                Gui, HP_GUI32: +OwnerHP_GUI30 +OwnDialogs -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop
            }
            Gui, HP_GUI%CurrentGUI%: Margin,0,0
            Gui, HP_GUI%CurrentGUI%: Show,, hpLayer%CurrentGUI%
            HP_hwnd%CurrentGUI% := WinExist()
            HP_hbm%CurrentGUI% := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
            HP_hdc%CurrentGUI% := CreateCompatibleDC()
            HP_obm%CurrentGUI% := SelectObject(HP_hdc%CurrentGUI%, HP_hbm%CurrentGUI%)
            HP_G%CurrentGUI% := Gdip_GraphicsFromhdc(HP_hdc%CurrentGUI%)
            Gdip_SetSmoothingMode(HP_G%CurrentGUI%, 4)
        }
    }
    If (TotalSubMenuItemsVideos>0){ ;creating ActiveX video gui
        Gui, HP_GUI31: +OwnerHP_GUI30 -Caption +LastFound +ToolWindow +AlwaysOnTop
        try Gui, HP_GUI31: Add, ActiveX, vwmpVideo, WMPLayer.OCX
        catch e
            Log("A Windows Media Player Video exception was thrown: " . e , 5)
        try ComObjConnect(wmpVideo, "wmpVideo_")
        catch e
            Log("A Windows Media Player Video exception was thrown: " . e , 5)
        try wmpVideo.settings.volume := 100
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
    HyperPause_VolumeMaster := round(getMasterVolume())
    If (SelectedMenuOption:="Video"){
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
        HyperPause_MainMenu_BackgroundAlign := "Stretch and Lose Aspect" 
    } Else If HPBackground[1] {
        Random, RndmBackground, 1, % HPBackground.MaxIndex()
        MainMenuBackground := HPBackground[RndmBackground]
    }
    If MainMenuBackground {
        MainMenuBackgroundBitmap := Gdip_CreateBitmapFromFile(MainMenuBackground)
        Gdip_GetImageDimensions(MainMenuBackgroundBitmap, MainMenuBackgroundBitmapW, MainMenuBackgroundBitmapH)
        GetBGPicPosition(HyperPauseBGPicXNew,HyperPauseBGYNew,HyperPauseBGWNew,HyperPauseBGHNew,MainMenuBackgroundBitmapW,MainMenuBackgroundBitmapH,HyperPause_MainMenu_BackgroundAlign)	; get the background pic's new position and size
        If (HyperPause_MainMenu_BackgroundAlign = "Stretch and Lose Aspect") {	 
            MainMenuBackgroundX := 0
            MainMenuBackgroundY := 0
            MainMenuBackgroundW := A_ScreenWidth+1
            MainMenuBackgroundH := A_ScreenHeight+1
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
        Gdip_DrawImage(HP_G22, MainMenuBackgroundBitmap, MainMenuBackgroundX, MainMenuBackgroundY, MainMenuBackgroundW, MainMenuBackgroundH, 0, 0, MainMenuBackgroundBitmapW, MainMenuBackgroundBitmapH)
    }
    IfExist, %GameScreenshot%
        FileDelete, %GameScreenshot%
    Gdip_FillRectangle(HP_G23, HyperPause_MainMenu_BackgroundBrushV, -1, -1, A_ScreenWidth+2, A_ScreenHeight+2)  
    PauseImageBitmap := Gdip_CreateBitmapFromFile(PauseImage) ;Drawing Main menu bitmaps
    PauseBitmapW := Gdip_GetImageWidth(PauseImageBitmap), PauseBitmapH := Gdip_GetImageHeight(PauseImageBitmap)
    PauseBitmapW := round(PauseBitmapW*ScallingFactor)
    PauseBitmapH := round(PauseBitmapH*ScallingFactor)
    If FileExist(WheelImage) {
        WheelImageBitmap := Gdip_CreateBitmapFromFile(WheelImage)
        BitmapWheelW := Gdip_GetImageWidth(WheelImageBitmap), BitmapWheelH := Gdip_GetImageHeight(WheelImageBitmap)
        If(A_ScreenWidth<=1000){
            BitmapWheelW := round(BitmapWheelW*ScallingFactor)
            BitmapWheelH := round(BitmapWheelH*ScallingFactor)
            }            
        Gdip_DrawImage(HP_G23, WheelImageBitmap, round(PauseBitmapW+40*ScallingFactor), round(20*ScallingFactor),BitmapWheelW,BitmapWheelH)
    }
    Gdip_DrawImage(HP_G23, PauseImageBitmap, round(20*ScallingFactor), round((BitmapWheelH-PauseBitmapH)/2),PauseBitmapW,PauseBitmapH)        
    color := HyperPause_MainMenu_Info_FontColor
    posInfoX := round(A_ScreenWidth-10*ScallingFactor)
    posInfoY := round(10*ScallingFactor)
    If(HyperPause_MainMenu_ShowClock="true")
        posInfoY := posInfoY + HyperPause_MainMenu_ClockFontSize
    Loop, parse, HyperPause_MainMenu_Info_Labels,|, ;Drawing Main Menu Additional Information
        {
            If((%A_LoopField%<>"") and (A_LoopField<>"Description")){
                ExtraLinesCount:=0
                Widthoftextchanged:=0
                Loop, Parse, %A_Loopfield% , |
                    {
                    TempTopLeftDescriptionText := TopLeftDescriptionText . A_LoopField
                    Widthoftext := MeasureText(0,TempTopLeftDescriptionText,HyperPause_MainMenu_Info_Font,HyperPause_MainMenu_Info_FontSize,"Regular")
                    If((Widthoftext > HyperPause_MainMenu_TopLeftInfoMaxSize)and(a_index<>1)){
                        ExtraLinesCount++
                        If (InStr(TopLeftDescriptionText, "|",false,0)=StrLen(TopLeftDescriptionText))
                            StringTrimRight,TopLeftDescriptionText,TopLeftDescriptionText,1 
                        TopLeftDescriptionText :=  TopLeftDescriptionText . "`n" . A_LoopField
                    } Else {
                    TopLeftDescriptionText := TopLeftDescriptionText . A_LoopField . "|"
                    }
                }
                StringTrimRight,TopLeftDescriptionText,TopLeftDescriptionText,1
                TopLeftDescriptionText := A_LoopField . "`: " . TopLeftDescriptionText
                Options_MainMenu_Info = x%posInfoX% y%posInfoY% Right c%color% r4 s%HyperPause_MainMenu_Info_FontSize% Regular
                Gdip_TextToGraphics(HP_G23, TopLeftDescriptionText, Options_MainMenu_Info, HyperPause_MainMenu_Info_Font, 0, 0)
                posInfoY := round(posInfoY+HyperPause_MainMenu_Info_FontSize*1.5 + ExtraLinesCount*HyperPause_MainMenu_Info_FontSize)
                TopLeftDescriptionTextFisrtCut :=
                TopLeftDescriptionText := 
            }
        }  
Return



DrawMainMenuBar: ;Drawing Main Menu Bar
    Gdip_FillRectangle(HP_G25, BlackGradientBrush, -1, 0, A_ScreenWidth+2, HyperPause_MainMenu_BarHeight) ;Draw Main Menu Bar
    color := HyperPause_MainMenu_LabelDisabledColor ;Draw Main Menu Labels
    posX1 := round(A_ScreenWidth/2 - (HyperPause_MainMenuItem-1)*HyperPause_MainMenu_HdistBetwLabels)
    posX2 := round(A_ScreenWidth/2 - (HyperPause_MainMenuItem-1)*HyperPause_MainMenu_HdistBetwLabels - TotalMainMenuItems*HyperPause_MainMenu_HdistBetwLabels)
    posX3 := round(A_ScreenWidth/2 - (HyperPause_MainMenuItem-1)*HyperPause_MainMenu_HdistBetwLabels +  TotalMainMenuItems*HyperPause_MainMenu_HdistBetwLabels)
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
            Gdip_TextToGraphics(HP_G25, "Change " . romTable[1,6], Options1, HyperPause_MainMenu_LabelFont, 0, 0)
            Gdip_TextToGraphics(HP_G25, "Change " . romTable[1,6], Options2, HyperPause_MainMenu_LabelFont, 0, 0)
            Gdip_TextToGraphics(HP_G25, "Change " . romTable[1,6], Options3, HyperPause_MainMenu_LabelFont, 0, 0)
        } Else {
            Gdip_TextToGraphics(HP_G25, A_LoopField, Options1, HyperPause_MainMenu_LabelFont, 0, 0)
            Gdip_TextToGraphics(HP_G25, A_LoopField, Options2, HyperPause_MainMenu_LabelFont, 0, 0)
            Gdip_TextToGraphics(HP_G25, A_LoopField, Options3, HyperPause_MainMenu_LabelFont, 0, 0)            
        }
        posX1 := posX1+HyperPause_MainMenu_HdistBetwLabels
        posX2 := posX2+HyperPause_MainMenu_HdistBetwLabels
        posx3 := posX3+HyperPause_MainMenu_HdistBetwLabels
        color := HyperPause_MainMenu_LabelDisabledColor
    }
Return


UpdateDescription: ;Updating moving description text position
    Options = y0 c%HyperPause_MainMenu_Info_Description_FontColor% r4 s%HyperPause_MainMenu_Info_Description_FontSize% Regular
    x := (-x >= E3) ? A_ScreenWidth+HyperPause_MainMenu_Info_Description_FontSize : x-HyperPause_MainMenu_DescriptionScrollingVelocity
    Gdip_GraphicsClear(HP_G24)
    E := Gdip_TextToGraphics(HP_G24, Description, "x" x " " Options, "Arial", (x < 0) ? A_ScreenWidth+HyperPause_MainMenu_Info_Description_FontSize-x : A_ScreenWidth+HyperPause_MainMenu_Info_Description_FontSize, HyperPause_MainMenu_Info_Description_FontSize)
    StringSplit, E, E, |
    UpdateLayeredWindow(HP_hwnd24, HP_hdc24,0,posDescriptionY, A_ScreenWidth, 2*HyperPause_MainMenu_Info_Description_FontSize)
Return


SubMenuBottomApearanceAnimation: ;Showing SubMenu contents animation 
    Point1x := HyperPause_SubMenu_TopRightChamfer
    Point1y := HyperPause_SubMenu_Height-HyperPause_SubMenu_Height
    Point2x := 0
    Point2y := HyperPause_SubMenu_Height+HyperPause_SubMenu_TopRightChamfer-HyperPause_SubMenu_Height
    Point3x := HyperPause_SubMenu_TopRightChamfer
    Point3y := HyperPause_SubMenu_Height+HyperPause_SubMenu_TopRightChamfer-HyperPause_SubMenu_Height
    triangle = %Point1x%,%Point1y%|%Point2x%,%Point2y%|%Point3x%,%Point3y%
    ApearanceAnimationbegintime := A_TickCount
    Loop {
        submenuanimationdrawncount++
        Gdip_GraphicsClear(HP_G27)
        Gdip_FillRectangle(HP_G27, HyperPause_SubMenu_BackgroundBrushV, Point1x, Point1y, HyperPause_SubMenu_Width-HyperPause_SubMenu_TopRightChamfer, HyperPause_SubMenu_Height)
        Gdip_FillRectangle(HP_G27, HyperPause_SubMenu_BackgroundBrushV, Point2x, Point2y, HyperPause_SubMenu_TopRightChamfer, HyperPause_SubMenu_Height-HyperPause_SubMenu_TopRightChamfer)
        Gdip_FillPolygon(HP_G27, HyperPause_SubMenu_BackgroundBrushV,  triangle, FillMode=0)
        posy := A_ScreenHeight-(A_TickCount-ApearanceAnimationbegintime)
        If((posy<=A_ScreenHeight-HyperPause_SubMenu_Height)or(SubMenuDrawn=1)){
            UpdateLayeredWindow(HP_hwnd27, HP_hdc27,A_ScreenWidth-HyperPause_SubMenu_Width,A_ScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
           break
            }
        UpdateLayeredWindow(HP_hwnd27, HP_hdc27,A_ScreenWidth-HyperPause_SubMenu_Width,posy, HyperPause_SubMenu_Width, A_TickCount-ApearanceAnimationbegintime)
    }
Return


DrawSubMenu: ;Drawing SubMenu Background
    Gdip_GraphicsClear(HP_G26)
    Gdip_GraphicsClear(HP_G27)
    If not ((SelectedMenuOption = "Controller") and (TotalSubMenuItemsController=0)) {
        Point1x := HyperPause_SubMenu_TopRightChamfer
        Point1y := HyperPause_SubMenu_Height-HyperPause_SubMenu_Height
        Point2x := 0
        Point2y := HyperPause_SubMenu_Height+HyperPause_SubMenu_TopRightChamfer-HyperPause_SubMenu_Height
        Point3x := HyperPause_SubMenu_TopRightChamfer
        Point3y := HyperPause_SubMenu_Height+HyperPause_SubMenu_TopRightChamfer-HyperPause_SubMenu_Height
        triangle = %Point1x%,%Point1y%|%Point2x%,%Point2y%|%Point3x%,%Point3y%
        Gdip_FillRectangle(HP_G27, HyperPause_SubMenu_BackgroundBrushV, Point1x, Point1y, HyperPause_SubMenu_Width-HyperPause_SubMenu_TopRightChamfer, HyperPause_SubMenu_Height)
        Gdip_FillRectangle(HP_G27, HyperPause_SubMenu_BackgroundBrushV, Point2x, Point2y, HyperPause_SubMenu_TopRightChamfer, HyperPause_SubMenu_Height-HyperPause_SubMenu_TopRightChamfer)
        Gdip_FillPolygon(HP_G27, HyperPause_SubMenu_BackgroundBrushV,  triangle, FillMode=0)
    }
    If !submenuMouseClickChange
        SoundPlay %HyperPause_MenuSoundPath%hpsubmenu.wav
    Else
        submenuMouseClickChange =
    Loop, parse, HyperPause_MainMenu_Labels,|
    {
        If (HyperPause_MainMenuItem = a_Index) { 
            StringReplace, SelectedMenuOption, A_LoopField, %A_SPACE%,, All
            Gosub %SelectedMenuOption%
        }
    }
    UpdateLayeredWindow(HP_hwnd26, HP_hdc26,ConfigMenuX,ConfigMenuY, ConfigMenuWidth, ConfigMenuHeight)
    UpdateLayeredWindow(HP_hwnd27, HP_hdc27,A_ScreenWidth-HyperPause_SubMenu_Width,A_ScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
    Log("Loaded " SelectedMenuOption " SubMenu",1)
    SubMenuDrawn=1
Return   


SubMenuUpdate: ;Drawing SubMenu Contents
		If ((A_TimeIdlePhysical >= HyperPause_SubMenu_DelayinMilliseconds) and (MenuChanged = 1)) {
            If(HyperPause_Active=true)
                gosub, DisableKeys
            If SelectedMenuOption
                If(SubMenuDrawn<>1) 
                    If (SelectedMenuOption <> "Shutdown") and not ((SelectedMenuOption = "Controller") and (TotalSubMenuItemsController=0))
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
    If (keymapperEnabled = "true") and (JoyIDsEnabled = "true"){
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
        WidthofText := MeasureText(0,"Control Config",HyperPause_SubMenu_LabelFont,HyperPause_SubMenu_FontSize,"bold")+HyperPause_SubMenu_AdditionalTextMarginContour
        ConfigMenuX := (A_ScreenWidth-(WidthofText+HyperPause_SubMenu_AdditionalTextMarginContour))//2
        ConfigMenuY := (A_ScreenHeight-HyperPause_MainMenu_BarHeight)//2-(HyperPause_SubMenu_FontSize+HyperPause_SubMenu_AdditionalTextMarginContour)+2
        ConfigMenuWidth := WidthofText+HyperPause_SubMenu_AdditionalTextMarginContour
        ConfigMenuHeight := HyperPause_SubMenu_FontSize+HyperPause_SubMenu_AdditionalTextMarginContour
        Gdip_FillRoundedRectangle(HP_G26, Optionbrush, 0, 0, ConfigMenuWidth, ConfigMenuHeight,HyperPause_SubMenu_RadiusofRoundedCorners)
        Gdip_TextToGraphics(HP_G26, "Control Config", "x" . ConfigMenuWidth//2 . " y" . HyperPause_SubMenu_AdditionalTextMarginContour//2 . " Center c" . color . " r4 s" . HyperPause_SubMenu_FontSize . " bold",         HyperPause_SubMenu_LabelFont, 0, 0)
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
                    TextSize := MeasureText(0,joyConnectedInfo[A_Index,7],HyperPause_SubMenu_LabelFont,HyperPause_SubMenu_FontSize,"bold")+HyperPause_SubMenu_AdditionalTextMarginContour    
                    ControllerNameTextSize := If ControllerNameTextSize > TextSize ? ControllerNameTextSize : TextSize
                    joyConnectedInfo[A_Index,9] := Gdip_CreateBitmapFromFile(joyConnectedInfo[A_Index,8])
                    Gdip_GetImageDimensions(joyConnectedInfo[A_Index,9], BitmapW, BitmapH)
                    joyConnectedInfo[A_Index,10] := round(HyperPause_ControllerBannerHeight/BitmapH*BitmapW) 
                    maxImageWidthSize := If maxImageWidthSize > joyConnectedInfo[A_Index,10] ? maxImageWidthSize : joyConnectedInfo[A_Index,10]
                    maxImageWidthSize := If maxImageWidthSize > controllerDisconnectedBitmapW ? maxImageWidthSize : controllerDisconnectedBitmapW                
                }
            }
            maxControllerTextsize := If ControllerNameTextSize > maxControllerTableTitleSize ? ControllerNameTextSize : maxControllerTableTitleSize
            NumberingTextSize := MeasureText(0,"4",HyperPause_SubMenu_LabelFont,HyperPause_SubMenu_FontSize,"bold")+HyperPause_SubMenu_AdditionalTextMarginContour 
            BannerTitleY := HyperPause_SubMenu_FullScreenMargin+2*HyperPause_vDistanceBetweenButtons
            PlayerX := HyperPause_SubMenu_AdditionalTextMarginContour+NumberingTextSize//2
            BitmapX := PlayerX + NumberingTextSize//2 + HyperPause_hDistanceBetweenControllerBannerElements
            ControllerNameX := BitmapX + maxImageWidthSize + HyperPause_hDistanceBetweenControllerBannerElements
            BannerWidth := ControllerNameX+maxControllerTextsize+HyperPause_SubMenu_AdditionalTextMarginContour
            HyperPause_ControllerFullScreenWidth := BannerWidth+8*HyperPause_SubMenu_FullScreenMargin
            Gdip_GraphicsClear(HP_G29)
            Gdip_FillRoundedRectangle(HP_G29, HyperPause_SubMenu_FullScreenTextBrushV, 0, 0, HyperPause_ControllerFullScreenWidth, A_ScreenHeight-2*HyperPause_SubMenu_FullScreenMargin, HyperPause_SubMenu_FullScreenRadiusofRoundedCorners)
            ;drawing the exit full screen button
            ControllerTextButtonSize := MeasureText(0,"Restore Preferred Order",HyperPause_SubMenu_LabelFont,HyperPause_SubMenu_FontSize,"bold")+HyperPause_SubMenu_AdditionalTextMarginContour 
            
            TextSize := MeasureText(0,"Exit Control Config",HyperPause_SubMenu_LabelFont,HyperPause_SubMenu_FontSize,"bold")+HyperPause_SubMenu_AdditionalTextMarginContour 
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
            Gdip_FillRoundedRectangle(HP_G29, Optionbrush, posX, HyperPause_SubMenu_FullScreenMargin, Width, Height,HyperPause_SubMenu_RadiusofRoundedCorners)
            Gdip_TextToGraphics(HP_G29, "Exit Control Config", "x" . posX+Width//2 . " y" . HyperPause_SubMenu_FullScreenMargin+HyperPause_SubMenu_AdditionalTextMarginContour . " Center c" . color . " r4 s" . HyperPause_SubMenu_FontSize . " bold", HyperPause_SubMenu_LabelFont, 0, 0)
            If (V2SubMenuItem = 1)
                Gdip_DrawRoundedRectangle(HP_G29, HyperPause_SubMenu_ControllerSelectedPen, posX, HyperPause_SubMenu_FullScreenMargin, Width, Height,HyperPause_SubMenu_RadiusofRoundedCorners)
            ;drawing Restore Preferred Order button
            If (V2SubMenuItem = 2) {
                color := HyperPause_MainMenu_LabelSelectedColor
                Optionbrush := HyperPause_SubMenu_SelectedBrushV 
            } Else {
                color := HyperPause_MainMenu_LabelDisabledColor
                Optionbrush := HyperPause_SubMenu_DisabledBrushV           
            }             
            posY := HyperPause_SubMenu_FullScreenMargin+HyperPause_vDistanceBetweenButtons
            Gdip_FillRoundedRectangle(HP_G29, Optionbrush, posX, posY, Width, Height,HyperPause_SubMenu_RadiusofRoundedCorners)
            Gdip_TextToGraphics(HP_G29, "Restore Preferred Order", "x" . posX+Width//2 . " y" . posY+HyperPause_SubMenu_AdditionalTextMarginContour . " Center c" . color . " r4 s" . HyperPause_SubMenu_FontSize . " bold", HyperPause_SubMenu_LabelFont, 0, 0)
            If (V2SubMenuItem = 2)
                Gdip_DrawRoundedRectangle(HP_G29, HyperPause_SubMenu_ControllerSelectedPen, posX, posY, Width, Height,HyperPause_SubMenu_RadiusofRoundedCorners)
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
            Gdip_TextToGraphics(HP_G29, "Player", "x" . PlayerX . " y" . BannerTitleY . " Center c" . color . " r4 s" . HyperPause_SubMenu_FontSize . " bold", HyperPause_SubMenu_LabelFont, 0, 0)
            Gdip_TextToGraphics(HP_G29, "Controller", "x" . ControllerNameX+maxControllerTextsize//2 . " y" . BannerTitleY . " Center c" . color . " r4 s" . HyperPause_SubMenu_FontSize . " bold", HyperPause_SubMenu_LabelFont, 0, 0)
            numberOfBannersperScreen := (A_ScreenHeight-HyperPause_SubMenu_FullScreenMargin-BannerTitleY-HyperPause_vDistanceBetweenBanners)//(HyperPause_ControllerBannerHeight+HyperPause_vDistanceBetweenBanners)
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
                Gdip_FillRoundedRectangle(HP_G29, Optionbrush, BannerMargin, BannerPosY, BannerWidth, HyperPause_ControllerBannerHeight,HyperPause_SubMenu_RadiusofRoundedCorners)
                If (V2SubMenuItem = a_index+2+firstbanner-1)
                    Gdip_DrawRoundedRectangle(HP_G29, HyperPause_SubMenu_ControllerSelectedPen, BannerMargin, BannerPosY, BannerWidth, HyperPause_ControllerBannerHeight,HyperPause_SubMenu_RadiusofRoundedCorners)
                If (a_index+firstbanner-1 <= 4)
                    Gdip_TextToGraphics(HP_G29, a_index+firstbanner-1, "x" . PlayerX . " y" . BannerPosY+(HyperPause_ControllerBannerHeight-HyperPause_SubMenu_FontSize)//2 . " Center c" . color . " r4 s" . HyperPause_SubMenu_FontSize . " bold", HyperPause_SubMenu_LabelFont, 0, 0)
                Else
                    Gdip_TextToGraphics(HP_G29, ".", "x" . PlayerX . " y" . BannerPosY+(HyperPause_ControllerBannerHeight-HyperPause_SubMenu_FontSize)//2 . " Center c" . color . " r4 s" . HyperPause_SubMenu_FontSize . " bold", HyperPause_SubMenu_LabelFont, 0, 0)
                If joyConnectedInfo[a_index+firstbanner-1,1]
                    Gdip_DrawImage(HP_G29, joyConnectedInfo[a_index+firstbanner-1,9], BitmapX+(maxImageWidthSize-joyConnectedInfo[a_index+firstbanner-1,10])//2, BannerPosY, joyConnectedInfo[a_index+firstbanner-1,10], HyperPause_ControllerBannerHeight)
                Else
                    Gdip_DrawImage(HP_G29, controllerDisconnectedBitmap, BitmapX+(maxImageWidthSize-controllerDisconnectedBitmapW)//2, BannerPosY, controllerDisconnectedBitmapW, HyperPause_ControllerBannerHeight)
                Gdip_TextToGraphics(HP_G29, joyConnectedInfo[a_index+firstbanner-1,7], "x" . ControllerNameX+maxControllerTextsize//2 . " y" . BannerPosY+(HyperPause_ControllerBannerHeight-HyperPause_SubMenu_FontSize)//2 . " Center c" . color . " r4 s" . HyperPause_SubMenu_FontSize . " bold", HyperPause_SubMenu_LabelFont, 0, 0)
            }
            ;drawing moving selected controller banner
            If (V2SubMenuItem <= 2)
                SelectedController :=
            If SelectedController {
                BannerPosY := BannerTitleY+HyperPause_vDistanceBetweenBanners+(V2SubMenuItem-2-firstbanner+1-1)*(HyperPause_ControllerBannerHeight+HyperPause_vDistanceBetweenBanners)
                color := HyperPause_MainMenu_LabelSelectedColor
                Optionbrush := HyperPause_SubMenu_SelectedBrushV 
                Gdip_FillRoundedRectangle(HP_G29, Optionbrush, BannerMargin+HyperPause_selectedControllerBannerDisplacement, BannerPosY+HyperPause_selectedControllerBannerDisplacement, BannerWidth, HyperPause_ControllerBannerHeight,HyperPause_SubMenu_RadiusofRoundedCorners)
                Gdip_DrawRoundedRectangle(HP_G29, HyperPause_SubMenu_ControllerSelectedPen, BannerMargin+HyperPause_selectedControllerBannerDisplacement, BannerPosY+HyperPause_selectedControllerBannerDisplacement, BannerWidth, HyperPause_ControllerBannerHeight,HyperPause_SubMenu_RadiusofRoundedCorners)
                Gdip_TextToGraphics(HP_G29, ".", "x" . PlayerX+HyperPause_selectedControllerBannerDisplacement . " y" . BannerPosY+(HyperPause_ControllerBannerHeight-HyperPause_SubMenu_FontSize)//2+HyperPause_selectedControllerBannerDisplacement . " Center c" . color . " r4 s" . HyperPause_SubMenu_FontSize . " bold", HyperPause_SubMenu_LabelFont, 0, 0)
                Gdip_DrawImage(HP_G29, joyConnectedInfo[SelectedController,9], BitmapX+HyperPause_selectedControllerBannerDisplacement, BannerPosY+HyperPause_selectedControllerBannerDisplacement, joyConnectedInfo[SelectedController,10], HyperPause_ControllerBannerHeight)
                Gdip_TextToGraphics(HP_G29, joyConnectedInfo[SelectedController,7], "x" . ControllerNameX+maxControllerTextsize//2+HyperPause_selectedControllerBannerDisplacement . " y" . BannerPosY+(HyperPause_ControllerBannerHeight-HyperPause_SubMenu_FontSize)//2+HyperPause_selectedControllerBannerDisplacement . " Center c" . color . " r4 s" . HyperPause_SubMenu_FontSize . " bold", HyperPause_SubMenu_LabelFont, 0, 0)
            }          
            UpdateLayeredWindow(HP_hwnd29, HP_hdc29,(A_ScreenWidth-HyperPause_ControllerFullScreenWidth)//2, HyperPause_SubMenu_FullScreenMargin, HyperPause_ControllerFullScreenWidth, A_ScreenHeight-2*HyperPause_SubMenu_FullScreenMargin)
        } Else {
            V2SubMenuItem := 1   
        }
    }
    If (TotalSubMenuItemsController > 0)
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
                        TotalGrowSize := round(5*ScallingFactor)*2
                        BannerPosY := BannerTitleY+HyperPause_vDistanceBetweenBanners+(JoystickNumber-firstbanner)*(HyperPause_ControllerBannerHeight+HyperPause_vDistanceBetweenBanners)
                        Loop, %TotalGrowSize% {    
                            If a_index <= % TotalGrowSize//2
                                ControllerGrowSize++
                            Else
                                ControllerGrowSize--   
                            Gdip_GraphicsClear(HP_G30)
                            Gdip_DrawImage(HP_G30, joyConnectedInfo[JoystickNumber,9], 0, 0, joyConnectedInfo[JoystickNumber,10]+ControllerGrowSize*2, HyperPause_ControllerBannerHeight+ControllerGrowSize*2)
                            UpdateLayeredWindow(HP_hwnd30, HP_hdc30, (A_ScreenWidth-HyperPause_ControllerFullScreenWidth)//2+BitmapX+(maxImageWidthSize-joyConnectedInfo[JoystickNumber,10])//2-ControllerGrowSize,HyperPause_SubMenu_FullScreenMargin+BannerPosY-ControllerGrowSize, joyConnectedInfo[JoystickNumber,10]+TotalGrowSize, HyperPause_ControllerBannerHeight+TotalGrowSize)
                        }
                        Gdip_GraphicsClear(HP_G30) 
                        UpdateLayeredWindow(HP_hwnd30, HP_hdc30, (A_ScreenWidth-HyperPause_ControllerFullScreenWidth)//2+BitmapX+(maxImageWidthSize-joyConnectedInfo[JoystickNumber,10])//2-TotalGrowSize//2,HyperPause_SubMenu_FullScreenMargin+BannerPosY-TotalGrowSize//2, joyConnectedInfo[JoystickNumber,10]+TotalGrowSize, HyperPause_ControllerBannerHeight+TotalGrowSize)
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
        SaveStateBackgroundFile := RIni_GetKeyValue(1,dbName,"SaveState" . VSubMenuItem . "Screenshot", false)
        If SaveStateBackgroundFile
            {
            SaveStateBackgroundBitmap := Gdip_CreateBitmapFromFile(SaveStateBackgroundFile)
            Gdip_GraphicsClear(HP_G22) 
            Gdip_DrawImage(HP_G22, SaveStateBackgroundBitmap, 0, 0, A_ScreenWidth, A_ScreenHeight)
            UpdateLayeredWindow(HP_hwnd22, HP_hdc22, 0, 0, A_ScreenWidth, A_ScreenHeight)
        } Else {
            Gdip_GraphicsClear(HP_G22) 
            Gdip_DrawImage(HP_G22, MainMenuBackgroundBitmap, MainMenuBackgroundX, MainMenuBackgroundY, MainMenuBackgroundW, MainMenuBackgroundH, 0, 0, MainMenuBackgroundBitmapW, MainMenuBackgroundBitmapH)
            UpdateLayeredWindow(HP_hwnd22, HP_hdc22, 0, 0, A_ScreenWidth, A_ScreenHeight)
        }
    } Else {
        Gdip_GraphicsClear(HP_G22) 
        Gdip_DrawImage(HP_G22, MainMenuBackgroundBitmap, MainMenuBackgroundX, MainMenuBackgroundY, MainMenuBackgroundW, MainMenuBackgroundH, 0, 0, MainMenuBackgroundBitmapW, MainMenuBackgroundBitmapH)
        UpdateLayeredWindow(HP_hwnd22, HP_hdc22, 0, 0, A_ScreenWidth, A_ScreenHeight)
    }
    gosub, StateMenuList
Return

LoadState:
    If(VSubMenuItem<>0){
        SubMenuHelpText("Press Select Key to Load the Game")
        SaveStateBackgroundFile := RIni_GetKeyValue(1,dbName,"SaveState" . VSubMenuItem . "Screenshot", false)
        If SaveStateBackgroundFile
            {
            SaveStateBackgroundBitmap := Gdip_CreateBitmapFromFile(SaveStateBackgroundFile)
            Gdip_GraphicsClear(HP_G22) 
            Gdip_DrawImage(HP_G22, SaveStateBackgroundBitmap, 0, 0, A_ScreenWidth, A_ScreenHeight)
            UpdateLayeredWindow(HP_hwnd22, HP_hdc22, 0, 0, A_ScreenWidth, A_ScreenHeight)
        } Else {
            Gdip_GraphicsClear(HP_G22) 
            Gdip_DrawImage(HP_G22, MainMenuBackgroundBitmap, MainMenuBackgroundX, MainMenuBackgroundY, MainMenuBackgroundW, MainMenuBackgroundH, 0, 0, MainMenuBackgroundBitmapW, MainMenuBackgroundBitmapH)
            UpdateLayeredWindow(HP_hwnd22, HP_hdc22, 0, 0, A_ScreenWidth, A_ScreenHeight)
        }
    } Else {
        Gdip_GraphicsClear(HP_G22) 
        Gdip_DrawImage(HP_G22, MainMenuBackgroundBitmap, MainMenuBackgroundX, MainMenuBackgroundY, MainMenuBackgroundW, MainMenuBackgroundH, 0, 0, MainMenuBackgroundBitmapW, MainMenuBackgroundBitmapH)
        UpdateLayeredWindow(HP_hwnd22, HP_hdc22, 0, 0, A_ScreenWidth, A_ScreenHeight)
    }
    gosub, StateMenuList
Return

StateMenuList:
    SlotEmpty := true
    color := HyperPause_MainMenu_LabelDisabledColor
    Optionbrush := HyperPause_SubMenu_DisabledBrushV
    HyperPause_State_DistBetweenLabelandHour := 50
    WidthofStateText := MeasureText(0,"Save State XX",HyperPause_SubMenu_LabelFont,HyperPause_SubMenu_LabelFontSize,"bold")+HyperPause_SubMenu_AdditionalTextMarginContour
    posStateX := round(HyperPause_State_HMargin+WidthofStateText/2)
    posStateX2 := HyperPause_State_HMargin+WidthofStateText+HyperPause_State_DistBetweenLabelandHour
    posStateY := HyperPause_State_VMargin
    posStateY2 := HyperPause_State_VMargin+HyperPause_SubMenu_FontSize-HyperPause_SubMenu_SmallFontSize
    Loop, parse, hp%SelectedMenuOption%KeyCodes,|, 
    {    
    If(VSubMenuItem = A_index ){
        color := HyperPause_MainMenu_LabelSelectedColor
        Optionbrush := HyperPause_SubMenu_SelectedBrushV
        }
    If( A_index >= VSubMenuItem){   
        OptionsState = x%posStateX% y%posStateY% Center c%color% r4 s%HyperPause_SubMenu_LabelFontSize% bold
        OptionsState2 = x%posStateX2% y%posStateY2% Left c%color% r4 s%HyperPause_SubMenu_SmallFontSize% italic
        Gdip_FillRoundedRectangle(HP_G27, Optionbrush, HyperPause_State_HMargin, posStateY-HyperPause_SubMenu_AdditionalTextMarginContour, WidthofStateText, HyperPause_SubMenu_FontSize+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_RadiusofRoundedCorners)
        If(SelectedMenuOption="SaveState"){
            StateLabel := "Save State "A_Index
        } Else {
            StateLabel := "Load State "A_Index
        }    
        Gdip_TextToGraphics(HP_G27, StateLabel, OptionsState, HyperPause_SubMenu_LabelFont, 0, 0)
        ReadSaveTime := RIni_GetKeyValue(1,dbName,"SaveState" . A_index . "SaveTime", "Empty Slot")
        Gdip_TextToGraphics(HP_G27, ReadSaveTime, OptionsState2, HyperPause_SubMenu_Font, 0, 0)
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
    If (HyperPause_ChangeDisc_UseGameArt = "true" ) {
        If FileExist(HLMediaPath . "\MultiGame\" . systemname . "\" . dbname . "\" . dbname . ".png") 
            GameArtPath := HLMediaPath . "\MultiGame\" . systemname . "\" . dbname . "\"
        Else 
            GameArtPath := MediaImagePath . HyperPause_ChangeDisc_ArtworkDir . "\"
    }
    for index, element in romTable
        {
        If FileExist(GameArtPath . dbname . ".png") && (HyperPause_ChangeDisc_UseGameArt = "true" ) {
            Gdip_DisposeImage(romTable[A_Index, 17])
            romTable[A_Index, 17] := Gdip_CreateBitmapFromFile(MediaImagePath . HyperPause_ChangeDisc_ArtworkDir . "\" . romTable[A_Index, 3] . ".png")
            romTable[A_Index,16] := "Yes"
        } Else {
            Gdip_DisposeImage(romTable[A_Index, 17])
            Gdip_DisposeImage(romTable[A_Index, 18])
            romTable[A_Index, 17] := Gdip_CreateBitmapFromFile(Image_1)
            romTable[A_Index, 18] := Gdip_CreateBitmapFromFile(Image_2)
        }
        Gdip_GetImageDimensions(romTable[A_Index, 17], HyperPause_DiscChange_ArtW, HyperPause_DiscChange_ArtH)
        romTable[A_Index,12] := HyperPause_DiscChange_ArtW, romTable[A_Index,13] := HyperPause_DiscChange_ArtH
        HyperPause_ChangeDisc_ImageAdjust := 1/(HyperPause_DiscChange_ArtH/(HyperPause_SubMenu_Height-2*HyperPause_ChangeDisc_VMargin-HyperPause_ChangeDisc_TextDisttoImage-HyperPause_SubMenu_FontSize))
        Loop { 
            HPtotalUnusedWidth := round (HyperPause_SubMenu_Width - ( romTable[1,12]*HyperPause_ChangeDisc_ImageAdjust * romTable.MaxIndex() ))
            If(HPtotalUnusedWidth>200){
                break
                }
            HyperPause_ChangeDisc_ImageAdjust := HyperPause_ChangeDisc_ImageAdjust*0.9
        }
        romTable[A_Index,14] := round(romTable[A_Index,12]*HyperPause_ChangeDisc_ImageAdjust), romTable[A_Index,15] := round(romTable[A_Index,13]*HyperPause_ChangeDisc_ImageAdjust)
        If HyperPause_ChangeDisc_SelectedEffect = rotate
            {
            Gdip_GetRotatedDimensions(romTable[A_Index, 14], romTable[A_Index, 15], 90, HyperPause_DiscChange_HyperPause_DiscChange_RW%A_Index%, HyperPause_DiscChange_RH%A_Index%)
            HyperPause_DiscChange_RW%A_Index% := (HyperPause_DiscChange_RW%A_Index% > romTable[A_Index, 14]) ? HyperPause_DiscChange_RW%A_Index%* : romTable[A_Index, 14], HyperPause_DiscChange_RH%A_Index% := (HyperPause_DiscChange_RH%A_Index% > romTable[A_Index, 15]) ? HyperPause_DiscChange_RH%A_Index% : romTable[A_Index, 15]
        }
    }
    HPtotalUnusedWidth := HyperPause_SubMenu_Width - ( romTable[1,14] * romTable.MaxIndex() )
    HPremainingUnusedWidth := HPtotalUnusedWidth * ( 1 - ( HyperPause_ChangeDisc_SidePadding * 2 ))
    HPpaddingSpotsNeeded := romTable.MaxIndex() - 1
    HPimageSpacing := round(HPremainingUnusedWidth/HPpaddingSpotsNeeded)
    HPimageXcurrent:=HyperPause_ChangeDisc_SidePadding * HPtotalUnusedWidth ;in respect to the top left of the sub menu window
    for index, element in romTable {
        color := HyperPause_MainMenu_LabelDisabledColor
        romTable[A_Index,10] := (If romTable[A_Index,16] ? (HPimageXcurrent) : (round(HPimageXcurrent+(romTable[1,14]/2-romTable[A_Index,14]/2))))
        romTable[A_Index,11] := HyperPause_ChangeDisc_VMargin+HyperPause_SubMenu_FontSize+HyperPause_ChangeDisc_TextDisttoImage
        If(VSubMenuItem=0){
            SetTimer, DiscChangeUpdate, off
            Gdip_ResetWorldTransform(HP_G30)
            Gdip_GraphicsClear(HP_G30)
            UpdateLayeredWindow(HP_hwnd30, HP_hdc30, A_ScreenWidth-HyperPause_SubMenu_Width, A_ScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
            Gdip_DrawImage(HP_G27, romTable[A_Index, 17], romTable[A_Index,10], romTable[A_Index,11], romTable[1,14], romTable[A_Index,15], 0, 0, round(romTable[1,14]/HyperPause_ChangeDisc_ImageAdjust), round(romTable[A_Index,15]/HyperPause_ChangeDisc_ImageAdjust))
        } Else If(HSubMenuItem = A_index){    
                color := HyperPause_MainMenu_LabelSelectedColor
        } Else {
        Gdip_DrawImage(HP_G27, romTable[A_Index, 17], romTable[A_Index,10], romTable[A_Index,11], romTable[1,14], romTable[A_Index,15], 0, 0, round(romTable[1,14]/HyperPause_ChangeDisc_ImageAdjust), round(romTable[A_Index,15]/HyperPause_ChangeDisc_ImageAdjust))
        }
        posDiscChangeTextX := HPimageXcurrent
        posDiscChangeTextY := HyperPause_ChangeDisc_VMargin
        OptionsDiscChange = x%posDiscChangeTextX% y%posDiscChangeTextY% Center c%color% r4 s%HyperPause_SubMenu_FontSize% bold
        Gdip_TextToGraphics(HP_G27, romTable[A_Index,5], OptionsDiscChange, HyperPause_SubMenu_Font, romTable[1,14], romTable[A_Index,15])
        HyperPause_DiscChange_Art%A_Index%X := HPimageXcurrent
        If ( A_index <= HPpaddingSpotsNeeded )
            HPimageXcurrent:=HPimageXcurrent+ romTable[1,14]+HPimageSpacing
    }
    If(VSubMenuItem=1){
        EnableDiscChangeUpdate = 1
    }
Return    
 

DiscChangeUpdate:
    If (SelectedMenuOption<>"ChangeDisc"){
        SetTimer, DiscChangeUpdate, Off  
        Return
    }
    If(EnableDiscChangeUpdate = 1){
        If((VSubMenuItem=1)and(SelectedMenuOption="ChangeDisc")){
            Gdip_GraphicsClear(HP_G30)
            If (HyperPause_ChangeDisc_SelectedEffect = "rotate" && romTable[HSubMenuItem, 16]) {
                discAngle := (discAngle > 360) ? 2 : discAngle+2
                Gdip_ResetWorldTransform(HP_G30)
                Gdip_TranslateWorldTransform(HP_G30, HyperPause_DiscChange_RW%HSubMenuItem%//2, HyperPause_DiscChange_RH%HSubMenuItem%//2)
                Gdip_RotateWorldTransform(HP_G30, discAngle)
                Gdip_TranslateWorldTransform(HP_G30, -HyperPause_DiscChange_RW%HSubMenuItem%//2, -HyperPause_DiscChange_RH%HSubMenuItem%//2)
                Gdip_DrawImage(HP_G30, romTable[HSubMenuItem, 17], (HyperPause_DiscChange_RW%HSubMenuItem%-romTable[HSubMenuItem, 14]), (HyperPause_DiscChange_RH%HSubMenuItem%-romTable[HSubMenuItem, 15]), romTable[HSubMenuItem, 14], romTable[HSubMenuItem, 15])
                UpdateLayeredWindow(HP_hwnd30, HP_hdc30, A_ScreenWidth-HyperPause_SubMenu_Width+romTable[HSubMenuItem, 10]-1, A_ScreenHeight-HyperPause_SubMenu_Height+romTable[HSubMenuItem, 11]-1, HyperPause_DiscChange_RW%HSubMenuItem%, HyperPause_DiscChange_RH%HSubMenuItem%)
            Return
            } Else If (HyperPause_ChangeDisc_SelectedEffect = "rotate" && !romTable[HSubMenuItem, 16]) {
                Gdip_ResetWorldTransform(HP_G30)
                Gdip_DrawImage(HP_G30, romTable[HSubMenuItem, 18], romTable[HSubMenuItem, 10],  romTable[HSubMenuItem, 11], romTable[HSubMenuItem,14], romTable[HSubMenuItem,15], 0, 0, round(romTable[HSubMenuItem,14]/HyperPause_ChangeDisc_ImageAdjust), round(romTable[HSubMenuItem,15]/HyperPause_ChangeDisc_ImageAdjust))
            } Else If (HyperPause_ChangeDisc_SelectedEffect = "grow") {
                Sleep, 5
                If !HyperPause_Growing
                    SetTimer, DiscChangeGrowAnimation, -1
                Return
            }
            UpdateLayeredWindow(HP_hwnd30, HP_hdc30, A_ScreenWidth-HyperPause_SubMenu_Width, A_ScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
        }
    }
Return

DiscChangeGrowAnimation:
    If(HyperPause_Active=true)
        gosub, DisableKeys 
If(EnableDiscChangeUpdate = 1){
    HyperPause_Growing:=1
    While b <= 30 {
        Gdip_DrawImage(HP_G30, (If romTable[HSubMenuItem, 16] ? (romTable[HSubMenuItem, 17]):(romTable[HSubMenuItem, 18])), romTable[HSubMenuItem,10]-(b//2), romTable[ HSubMenuItem,11]-(b//2), romTable[HSubMenuItem,14]+b, romTable[HSubMenuItem,15]+b, 0, 0, romTable[HSubMenuItem,14]//HyperPause_ChangeDisc_ImageAdjust, romTable[HSubMenuItem,15]//HyperPause_ChangeDisc_ImageAdjust)
        UpdateLayeredWindow(HP_hwnd30, HP_hdc30, A_ScreenWidth-HyperPause_SubMenu_Width, A_ScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
        b+=2
    }
}
    If(HyperPause_Active=true)
        gosub, EnableKeys 
Return


;-------Sound Control Sub Menu-------
Sound:
    SoundBarHeight := round(HyperPause_SoundBar_SingleBarHeight + (100/HyperPause_SoundBar_vol_Step)*HyperPause_SoundBar_HeightDifferenceBetweenBars)
    SoundBarWidth := round((100/HyperPause_SoundBar_vol_Step)*HyperPause_SoundBar_SingleBarWidth+((100/HyperPause_SoundBar_vol_Step)-1)*HyperPause_SoundBar_SingleBarSpacing) 
    SoundBitmap := Gdip_CreateBitmapFromFile(SoundImage)
    SoundBitmapW := Gdip_GetImageWidth(SoundBitmap), SoundBitmapH := Gdip_GetImageHeight(SoundBitmap)
    SoundBitmapW := round(SoundBitmapW*ScallingFactor)
    SoundBitmapH := round(SoundBitmapH*ScallingFactor)
    MuteBitmap := Gdip_CreateBitmapFromFile(MuteImage)
    ButtonToggleONBitmap := Gdip_CreateBitmapFromFile(ToggleONImage)
    ButtonToggleONBitmapW := Gdip_GetImageWidth(ButtonToggleONBitmap), ButtonToggleONBitmapH := Gdip_GetImageHeight(ButtonToggleONBitmap)
    ButtonToggleONBitmapW := round(ButtonToggleONBitmapW*ScallingFactor)
    ButtonToggleONBitmapH := round(ButtonToggleONBitmapH*ScallingFactor)
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
    CurrentMuteState := GetMasterMute()
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
            Gdip_DrawImage(HP_G27,HyperPauseMusicBitmap%a_index%,posMusicButton%a_index%X,posMusicButtonsY,HyperPause_SubMenu_SizeofMusicPlayerButtons,HyperPause_SubMenu_SizeofMusicPlayerButtons)
            If((VsubMenuItem = 3) and (CurrentMusicButton = a_index)){
                If (PreviousCurrentMusicButton<>CurrentMusicButton){ 
                    GrowSize := 1
                    While GrowSize <= round(15*ScallingFactor) {
                        Gdip_GraphicsClear(HP_G30)
                        Gdip_DrawImage(HP_G30,HyperPauseMusicBitmap%CurrentMusicButton%,round(15*ScallingFactor-GrowSize*ScallingFactor),round(15*ScallingFactor-GrowSize*ScallingFactor),round(HyperPause_SubMenu_SizeofMusicPlayerButtons+2*GrowSize*ScallingFactor),round(HyperPause_SubMenu_SizeofMusicPlayerButtons+2*GrowSize*ScallingFactor))
                        UpdateLayeredWindow(HP_hwnd30, HP_hdc30, round(A_ScreenWidth-HyperPause_SubMenu_Width+posMusicButton%CurrentMusicButton%X-15*ScallingFactor), round(A_ScreenHeight-HyperPause_SubMenu_Height+posMusicButtonsY-15*ScallingFactor), round(HyperPause_SubMenu_SizeofMusicPlayerButtons+30*ScallingFactor), round(HyperPause_SubMenu_SizeofMusicPlayerButtons+30*ScallingFactor))
                        GrowSize+= round(HyperPause_SoundButtonGrowingEffectVelocity*ScallingFactor)
                    }
                    Gdip_GraphicsClear(HP_G30)
                    If(GrowSize<>15){
                        Gdip_DrawImage(HP_G30,HyperPauseMusicBitmap%CurrentMusicButton%,0,0,round(HyperPause_SubMenu_SizeofMusicPlayerButtons+30*ScallingFactor),round(HyperPause_SubMenu_SizeofMusicPlayerButtons+30*ScallingFactor))
                        UpdateLayeredWindow(HP_hwnd30, HP_hdc30, round(A_ScreenWidth-HyperPause_SubMenu_Width+posMusicButton%CurrentMusicButton%X-15*ScallingFactor), round(A_ScreenHeight-HyperPause_SubMenu_Height+posMusicButtonsY-15*ScallingFactor), round(HyperPause_SubMenu_SizeofMusicPlayerButtons+30*ScallingFactor), round(HyperPause_SubMenu_SizeofMusicPlayerButtons+30*ScallingFactor))
                    }
                } Else {
                    Gdip_DrawImage(HP_G30,HyperPauseMusicBitmap%CurrentMusicButton%,0,0,round(HyperPause_SubMenu_SizeofMusicPlayerButtons+30*ScallingFactor),round(HyperPause_SubMenu_SizeofMusicPlayerButtons+30*ScallingFactor))
                    UpdateLayeredWindow(HP_hwnd30, HP_hdc30, round(A_ScreenWidth-HyperPause_SubMenu_Width+posMusicButton%CurrentMusicButton%X-15*ScallingFactor), round(A_ScreenHeight-HyperPause_SubMenu_Height+posMusicButtonsY-15*ScallingFactor), round(HyperPause_SubMenu_SizeofMusicPlayerButtons+30*ScallingFactor), round(HyperPause_SubMenu_SizeofMusicPlayerButtons+30*ScallingFactor))
                }
                PreviousCurrentMusicButton := CurrentMusicButton   
            }
        }
    }
    Gdip_DrawImage(HP_G27, CurrentSoundBitmap, posSoundBarTextX, round(posSoundBarTextY+HyperPause_SubMenu_SoundMuteButtonFontSize+SoundBarHeight-(SoundBitmapH+HyperPause_SoundBar_SingleBarHeight)/2), SoundBitmapW, SoundBitmapH)
    OptionsSoundBar = x%posSoundBarTextX% y%posSoundBarTextY% Left c%colorSoundBarTitle% r4 s%HyperPause_SubMenu_SoundMuteButtonFontSize% bold
    Gdip_TextToGraphics(HP_G27, "Master Sound Control:", OptionsSoundBar, HyperPause_SubMenu_Font, 0, 0)
    ; Mute toggle
    If(VSubMenuItem=2) and (HSubmenuitemSoundVSubmenuitem2=1)
        colorMuteTitle := HyperPause_SubMenu_SoundSelectedColor
    posMuteX := round(posSoundBarTextX + 30*ScallingFactor)
    If(HyperPause_CurrentPlaylist<>"")
        posMuteX := round(posSoundBarTextX - 30*ScallingFactor)
    posMuteY := posSoundBarTextY+HyperPause_SubMenu_SoundMuteButtonFontSize + SoundBarHeight+HyperPause_SubMenu_SoundMuteButtonVDist
    OptionsSoundMute = x%posMuteX% y%posMuteY% Left c%colorMuteTitle% r4 s%HyperPause_SubMenu_SoundMuteButtonFontSize% bold
    Gdip_TextToGraphics(HP_G27, "Mute Status:", OptionsSoundMute, HyperPause_SubMenu_Font, 0, 0)
    WidthofMuteText := MeasureText(0,"Mute Status:",HyperPause_SubMenu_Font,HyperPause_SubMenu_SoundMuteButtonFontSize,"bold")+HyperPause_SubMenu_AdditionalTextMarginContour
    Gdip_DrawImage(HP_G27, CurrentButtonMuteBitmap, posMuteX+WidthofMuteText, posMuteY, ButtonToggleONBitmapW, ButtonToggleONBitmapH)  
    posMuteX := round(posMuteX+WidthofMuteText+ButtonToggleONBitmapW+10*ScallingFactor)
    OptionsSoundButton = x%posMuteX% y%posMuteY% Left c%colorMuteTitle% r4 s%HyperPause_SubMenu_SoundMuteButtonFontSize% bold
    Gdip_TextToGraphics(HP_G27, SoundMuteLabel, OptionsSoundButton, HyperPause_SubMenu_Font, 0, 0)
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
        posInGameMusicX := round(posMuteX + 100*ScallingFactor)
        OptionsInGameMusic = x%posInGameMusicX% y%posMuteY% Left c%colorInGameMusicTitle% r4 s%HyperPause_SubMenu_SoundMuteButtonFontSize% bold
        Gdip_TextToGraphics(HP_G27, "In Game Music:", OptionsInGameMusic, HyperPause_SubMenu_Font, 0, 0)
        WidthofInGameMusicText := MeasureText(0,"In Game Music:",HyperPause_SubMenu_Font,HyperPause_SubMenu_SoundMuteButtonFontSize,"bold")+       HyperPause_SubMenu_AdditionalTextMarginContour
        Gdip_DrawImage(HP_G27, CurrentButtonInGameMusic, posInGameMusicX+WidthofInGameMusicText, posMuteY, ButtonToggleONBitmapW, ButtonToggleONBitmapH)       
        posInGameMusicX := round(posInGameMusicX+WidthofInGameMusicText+ButtonToggleONBitmapW+10*ScallingFactor)
        OptionsInGameMusicButton = x%posInGameMusicX% y%posMuteY% Left c%colorInGameMusicTitle% r4 s%HyperPause_SubMenu_SoundMuteButtonFontSize% bold
        Gdip_TextToGraphics(HP_G27, InGameMusic, OptionsInGameMusicButton, HyperPause_SubMenu_Font, 0, 0)    

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
        posShuffleX := round(posInGameMusicX + 100*ScallingFactor)
        OptionsShuffle = x%posShuffleX% y%posMuteY% Left c%colorShuffleTitle% r4 s%HyperPause_SubMenu_SoundMuteButtonFontSize% bold
        Gdip_TextToGraphics(HP_G27, "Shuffle:", OptionsShuffle, HyperPause_SubMenu_Font, 0, 0)
        WidthofShuffleText := MeasureText(0,"Shuffle:",HyperPause_SubMenu_Font,HyperPause_SubMenu_SoundMuteButtonFontSize,"bold")+       HyperPause_SubMenu_AdditionalTextMarginContour
        Gdip_DrawImage(HP_G27, CurrentButtonShuffle, posShuffleX+WidthofShuffleText, posMuteY, ButtonToggleONBitmapW, ButtonToggleONBitmapH)       
        posShuffleX := round(posShuffleX+WidthofShuffleText+ButtonToggleONBitmapW+10*ScallingFactor)
        OptionsShuffleButton = x%posShuffleX% y%posMuteY% Left c%colorShuffleTitle% r4 s%HyperPause_SubMenu_SoundMuteButtonFontSize% bold
        Gdip_TextToGraphics(HP_G27, ShuffleText, OptionsShuffleButton, HyperPause_SubMenu_Font, 0, 0)        
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
    Gdip_TextToGraphics(HP_G27, soundtext, OptionsSound, "Arial")
    If (HyperPause_CurrentPlaylist<>"")
        settimer, UpdateMusicPlayingInfo, 100, Period
    Else 
        gosub, UpdateMusicPlayingInfo
Return


;-------Videos Sub Menu-------
Videos:
    TextImagesAndPDFMenu("Videos")
Return


;-------High Score Sub Menu-------
HighScore:
    posHighScoreX = 0
    line=0
    StringSplit, FirstLineContents, HighScoreText, °
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
        Gdip_FillRoundedRectangle(HP_G29, HyperPause_SubMenu_FullScreenTextBrushV, 0, 0, HyperPause_SubMenu_HighScoreFullScreenWidth, A_ScreenHeight-2*HyperPause_SubMenu_FullScreenMargin, HyperPause_SubMenu_FullScreenRadiusofRoundedCorners)
    }
    Loop, parse, HighScoreText,°,
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
                    Gdip_TextToGraphics(HP_G27, a_loopfield, OptionsHighScore1, HyperPause_SubMenu_Font)
                Else
                    Gdip_TextToGraphics(HP_G29, a_loopfield, OptionsHighScore1, HyperPause_SubMenu_Font)
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
                    Gdip_TextToGraphics(HP_G27, HighScoreitem, OptionsHighScore2, HyperPause_SubMenu_Font)
                Else
                    Gdip_TextToGraphics(HP_G29, HighScoreitem, OptionsHighScore2, HyperPause_SubMenu_Font)
                }
        posHighScoreY2 := round(posHighScoreY2+1.5*HyperPause_SubMenu_HighScoreFontSize)
        }
    column = 0
    }
    If(FullScreenView=1){                
        HyperPause_SubMenu_FullScreenHelpBoxHeight := 4*HyperPause_SubMenu_FullScreenFontSize
        HyperPause_SubMenu_FullScreenHelpBoxWidth := MeasureText(0,"Press Up or Down to move between High Scores",HyperPause_SubMenu_Font,HyperPause_SubMenu_FullScreenFontSize,"bold")+HyperPause_SubMenu_AdditionalTextMarginContour
        Gdip_FillRoundedRectangle(HP_G29, HyperPause_SubMenu_FullScreenBrushV, round((HyperPause_SubMenu_HighScoreFullScreenWidth-HyperPause_SubMenu_FullScreenHelpBoxWidth)/2), A_ScreenHeight-2*HyperPause_SubMenu_FullScreenMargin-5*HyperPause_SubMenu_FullScreenFontSize, HyperPause_SubMenu_FullScreenHelpBoxWidth,HyperPause_SubMenu_FullScreenHelpBoxHeight,HyperPause_SubMenu_FullScreenRadiusofRoundedCorners)
        posFullScreenTextX := round(HyperPause_SubMenu_HighScoreFullScreenWidth/2)
        posFullScreenTextY := round(A_ScreenHeight-2*HyperPause_SubMenu_FullScreenMargin-4*HyperPause_SubMenu_FullScreenFontSize-HyperPause_SubMenu_FullScreenFontSize/2)
        OptionsFullScreenText = x%posFullScreenTextX% y%posFullScreenTextY% Center c%HyperPause_SubMenu_FullScreenFontColor% r4 s%HyperPause_SubMenu_FullScreenFontSize% bold
        TotaltxtPages := % TotalFullScreenV2SubMenuItems%SubMenuName%%CurrentLabelNumber%
        CurrentHelpText = Press Select Key to Exit Full Screen`nPress Up or Down to move between High Scores
        Gdip_TextToGraphics(HP_G29, CurrentHelpText, OptionsFullScreenText, HyperPause_SubMenu_Font, 0, 0)
        UpdateLayeredWindow(HP_hwnd29, HP_hdc29,round((A_ScreenWidth-HyperPause_SubMenu_HighScoreFullScreenWidth)/2), HyperPause_SubMenu_FullScreenMargin, HyperPause_SubMenu_HighScoreFullScreenWidth, A_ScreenHeight-2*HyperPause_SubMenu_FullScreenMargin)
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
    Loop, %TotalSubMenuItemsMovesList%
        {
        MovesListLabelWidth := MeasureText(0,MovesListLabel%A_index%,HyperPause_SubMenu_LabelFont,HyperPause_SubMenu_LabelFontSize,"bold")+HyperPause_SubMenu_AdditionalTextMarginContour
        If(MovesListLabelWidth>MaxMovesListLabelWidth){
        MaxMovesListLabelWidth := MovesListLabelWidth
        }    
    }   
    posMovesListLabelX := round(HyperPause_MovesList_HMargin+MaxMovesListLabelWidth/2)
    Loop, %TotalSubMenuItemsMovesList%
        {
        If( A_index >= VSubMenuItem){   
            If((HSubMenuItem=1)and(A_index=VSubMenuItem)){
                V2SubMenuItem = 1
                color := HyperPause_MainMenu_LabelSelectedColor
                Optionbrush := HyperPause_SubMenu_SelectedBrushV
            }
            OptionsMovesListLabel = x%posMovesListLabelX% y%posMovesListLabelY% Center c%color% r4 s%HyperPause_SubMenu_LabelFontSize% bold
            Gdip_FillRoundedRectangle(HP_G27, Optionbrush, round(posMovesListLabelX-MaxMovesListLabelWidth/2), posMovesListLabelY-HyperPause_SubMenu_AdditionalTextMarginContour, MaxMovesListLabelWidth, HyperPause_SubMenu_FontSize+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_RadiusofRoundedCorners)
            Gdip_TextToGraphics(HP_G27, MovesListLabel%A_index%, OptionsMovesListLabel, HyperPause_SubMenu_LabelFont, 0, 0)
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
        Gdip_FillRoundedRectangle(HP_G29, HyperPause_SubMenu_FullScreenTextBrushV, 0, 0, HyperPause_SubMenu_MovesListFullScreenWidth, A_ScreenHeight-2*HyperPause_SubMenu_FullScreenMargin, HyperPause_SubMenu_FullScreenRadiusofRoundedCorners)
    } Else {
        FirstLine := (V2SubMenuItem-1)*LinesperPage%SelectedMenuOption% + 1
        LastLine := FirstLine + LinesperPage%SelectedMenuOption% - 1
    } 
    MovesListLineCount=0
    validLineCount=0
    posMovesListY := HyperPause_MovesList_VMargin
    stringreplace, AuxMovesListItem%current_item%, MovesListItem%current_item%, `r`n,ø,all
    Loop, parse, AuxMovesListItem%current_item%, ø
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
                replace := {"_a":"#a","_b":"#b","_c":"#c","_d":"#d","_e":"#e","_f":"#f","_g":"#g","_h":"#h","_i":"#i","_j":"#j","_k":"#k","_l":"#l","_m":"#m","_n":"#n","_o":"#o","_p":"#p","_q":"#q","_r":"#r","_s":"#s","_t":"#t","_u":"#u","_v":"#v","_w":"#w","_x":"#x","_y":"#y","_z":"#z","^s":"Òs","^?":"ÒQ","^*":"^X"} ; Dealing with altered filenames due to the impossibility of using a lower and upper case file names on the same directory (_letter lower cases are transformed in #letter)  
                For what, with in replace
                    StringReplace, MovesListCurrentLine, MovesListCurrentLine, %what%, %with%, All
                
                Loop, parse, CommandDatImageFileList, `,
                    {
                    Stringreplace, MovesListCurrentLine, MovesListCurrentLine, %A_loopfield%, °%A_loopfield%° ,all
                }
                MovesListCurrentLine := "°" . MovesListCurrentLine . "°" 
                Stringreplace, MovesListCurrentLine, MovesListCurrentLine, °°, ° ,all
                StringTrimLeft, MovesListCurrentLine, MovesListCurrentLine, 1
                StringTrimRight, MovesListCurrentLine, MovesListCurrentLine, 1
                Loop, parse, MovesListCurrentLine, °
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
                                        Gdip_DrawImage(HP_G27,CommandDatBitmap%currentbitmapindex%,posMovesListX,round(posMovesListY-ResizedBitmapH/2+HyperPause_MovesList_SecondaryFontSize/2),ResizedBitmapW,ResizedBitmapH)
                                    Else
                                        Gdip_DrawImage(HP_G29,CommandDatBitmap%currentbitmapindex%,posMovesListX,round(posMovesListY-ResizedBitmapH/2+HyperPause_MovesList_SecondaryFontSize/2),ResizedBitmapW,ResizedBitmapH)
                                    AddposMovesListX := ResizedBitmapW
                                    break                                            
                                }
                            }
                        } Else {
                            If (InStr(A_LoopField, ":")=1) ;Undrelining title that starts and ends with ":" 
                                If (InStr(A_LoopField, ":",false,0)>StrLen(A_LoopField)-2)
                                    OptionsMovesList = x%posMovesListX% y%posMovesListY% Left c%color2% r4 s%HyperPause_MovesList_SecondaryFontSize% Underline
                            If FullScreenView<>1
                                Gdip_TextToGraphics(HP_G27, A_LoopField, OptionsMovesList, HyperPause_SubMenu_Font, 0, 0)
                            Else
                                Gdip_TextToGraphics(HP_G29, a_loopfield, OptionsMovesList, HyperPause_SubMenu_Font)
                            AddposMovesListX := MeasureText(0,A_LoopField,HyperPause_SubMenu_Font,HyperPause_MovesList_SecondaryFontSize,"bold")
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
        Gdip_GraphicsClear(HP_G29)
        UpdateLayeredWindow(HP_hwnd29, HP_hdc29,A_ScreenWidth - HelpTextLenghtWidth - 2*HyperPause_SubMenu_AdditionalTextMarginContour,A_ScreenHeight- HyperPause_SubMenu_SmallFontSize,HelpTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_HelpFontSize)
        }
    } Else {
        HyperPause_SubMenu_FullScreenHelpBoxHeight := 5*HyperPause_SubMenu_FullScreenFontSize
        HyperPause_SubMenu_FullScreenHelpBoxWidth := MeasureText(0,"Press Up for Page Up or Press Down for Page Down",HyperPause_SubMenu_Font,HyperPause_SubMenu_FullScreenFontSize,"bold")+HyperPause_SubMenu_AdditionalTextMarginContour
        Gdip_FillRoundedRectangle(HP_G29, HyperPause_SubMenu_FullScreenBrushV, round((HyperPause_SubMenu_MovesListFullScreenWidth-HyperPause_SubMenu_FullScreenHelpBoxWidth)/2), A_ScreenHeight-2*HyperPause_SubMenu_FullScreenMargin-6*HyperPause_SubMenu_FullScreenFontSize, HyperPause_SubMenu_FullScreenHelpBoxWidth,HyperPause_SubMenu_FullScreenHelpBoxHeight,HyperPause_SubMenu_FullScreenRadiusofRoundedCorners)
        posFullScreenTextX := round(HyperPause_SubMenu_MovesListFullScreenWidth/2)
        posFullScreenTextY := round(A_ScreenHeight-2*HyperPause_SubMenu_FullScreenMargin-5*HyperPause_SubMenu_FullScreenFontSize-HyperPause_SubMenu_FullScreenFontSize/2)
        OptionsFullScreenText = x%posFullScreenTextX% y%posFullScreenTextY% Center c%HyperPause_SubMenu_FullScreenFontColor% r4 s%HyperPause_SubMenu_FullScreenFontSize% bold
        CurrentHelpText = Press Select Key to Exit Full Screen`nPress Up for Page Up or Press Down for Page Down`nPage %V2SubMenuItem% of %TotalMovesListPages%
        Gdip_TextToGraphics(HP_G29, CurrentHelpText, OptionsFullScreenText, HyperPause_SubMenu_Font, 0, 0)
        UpdateLayeredWindow(HP_hwnd29, HP_hdc29,round((A_ScreenWidth-HyperPause_SubMenu_MovesListFullScreenWidth)/2), HyperPause_SubMenu_FullScreenMargin, HyperPause_SubMenu_MovesListFullScreenWidth, A_ScreenHeight-2*HyperPause_SubMenu_FullScreenMargin)
    }
Return

       

;-------Statistics Sub Menu-------
Statistics:
    Statistics_TitleLabel_1 = General Statistics:
    Statistics_TitleLabel_3 = System Top Ten:
    Statistics_TitleLabel_6 = Global Top Ten:
    Statistics_Label_List = General_Statistics|Global_Last_Played_Games|System_Top_Ten_(Most_Played)|System_Top_Ten_(Times_Played)|System_Top_Ten_(Average_Time)|Global_Top_Ten_(System_Most_Played)|Global_Top_Ten_(Most_Played)|Global_Top_Ten_(Times_Played)|Global_Top_Ten_(Average_Time)
    Statistics_Label_Name_List = Game Statistics|Last Played Games|Most Played Games|Number of Times Played|Average Time Played|Systems Most Played|Most Played Games|Number of Times Played|Average Time Played
    Statistics_var_List_1 = Game Name|System Name|Number_of_Times_Played|Last_Time_Played|Average_Time_Played|Total_Time_Played|System_Total_Played_Time|Total_Global_Played_Time
    Statistics_var_List_2 = 1|2|3|4|5|6|7|8|9|10
    Statistics_var_List_3 = 1st_Place|2nd_Place|3rd_Place|4th_Place|5th_Place|6th_Place|7th_Place|8th_Place|9th_Place|10th_Place
    Statistics_var_List_4 = 1st_Place|2nd_Place|3rd_Place|4th_Place|5th_Place|6th_Place|7th_Place|8th_Place|9th_Place|10th_Place
    Statistics_var_List_5 = 1st_Place|2nd_Place|3rd_Place|4th_Place|5th_Place|6th_Place|7th_Place|8th_Place|9th_Place|10th_Place
    Statistics_var_List_6 = 1st_Place|2nd_Place|3rd_Place|4th_Place|5th_Place|6th_Place|7th_Place|8th_Place|9th_Place|10th_Place
    Statistics_var_List_7 = 1st_Place|2nd_Place|3rd_Place|4th_Place|5th_Place|6th_Place|7th_Place|8th_Place|9th_Place|10th_Place
    Statistics_var_List_8 = 1st_Place|2nd_Place|3rd_Place|4th_Place|5th_Place|6th_Place|7th_Place|8th_Place|9th_Place|10th_Place
    Statistics_var_List_9 = 1st_Place|2nd_Place|3rd_Place|4th_Place|5th_Place|6th_Place|7th_Place|8th_Place|9th_Place|10th_Place    
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
        StatisticsLabelWidth := MeasureText(0,A_LoopField,HyperPause_SubMenu_LabelFont,HyperPause_SubMenu_LabelFontSize,"bold")+HyperPause_SubMenu_AdditionalTextMarginContour
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
            Gdip_TextToGraphics(HP_G27, Statistics_TitleLabel_%A_index%, OptionsStatisticsTitleLabel, HyperPause_SubMenu_LabelFont, 0, 0)
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
            Gdip_FillRoundedRectangle(HP_G27, Optionbrush, round(posStatisticsLabelX-MaxStatisticsLabelWidth/2), posStatisticsLabelY-HyperPause_SubMenu_AdditionalTextMarginContour, MaxStatisticsLabelWidth, HyperPause_SubMenu_FontSize+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_RadiusofRoundedCorners)
            Gdip_TextToGraphics(HP_G27, Statistics_Label_Name_%a_index%, OptionsStatisticsLabel, HyperPause_SubMenu_LabelFont, 0, 0)
            posStatisticsLabelY := posStatisticsLabelY+HyperPause_Statistics_VdistBetwLabels
            color := HyperPause_MainMenu_LabelDisabledColor
            Optionbrush := HyperPause_SubMenu_DisabledBrushV
        }
    }  
    If(FullScreenView=1){
        Gdip_GraphicsClear(HP_G29)
        Gdip_FillRoundedRectangle(HP_G29, HyperPause_SubMenu_FullScreenTextBrushV, 0, 0, HyperPause_SubMenu_StatisticsFullScreenWidth, A_ScreenHeight-2*HyperPause_SubMenu_FullScreenMargin, HyperPause_SubMenu_FullScreenRadiusofRoundedCorners)
        posStatisticsTableTitleY := 4*HyperPause_SubMenu_FullScreenMargin
        posStatisticsTableY := 4*HyperPause_SubMenu_FullScreenMargin+2*HyperPause_Statistics_TitleFontSize
        posStatisticsTableX := 4*HyperPause_SubMenu_FullScreenMargin
        posStatisticsTableX3 := HyperPause_SubMenu_StatisticsFullScreenWidth-4*HyperPause_SubMenu_FullScreenMargin
        posStatisticsTableX2 := round((posStatisticsTableX + posStatisticsTableX3)/2-40*ScallingFactor)
    } Else {
        posStatisticsTableTitleY := HyperPause_Statistics_VMargin
        posStatisticsTableY := HyperPause_Statistics_VMargin+2*HyperPause_Statistics_TitleFontSize
        posStatisticsTableX := round(posStatisticsLabelX+MaxStatisticsLabelWidth/2+HyperPause_Statistics_DistBetweenLabelsandTable)
        posStatisticsTableX3 := HyperPause_SubMenu_Width-HyperPause_Statistics_DistBetweenLabelsandTable
        posStatisticsTableX2 := round((posStatisticsTableX + posStatisticsTableX3)/2-40*ScallingFactor)
    }
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
        current_column3_Title := "System Name|Last Time Played"
    }Else{
        current_column1_Title = Rank
        If(Current_Label="Global_Top_Ten_(System_Most_Played)")
            current_column2_Title := "System"
        Else
            current_column2_Title := "Game"
        If((Current_Label="System_Top_Ten_(Most_Played)")or(Current_Label="Global_Top_Ten_(Most_Played)")){
            current_column3_Title := "Total Time Played"
        } If Else ((Current_Label="System_Top_Ten_(Times_Played)")or(Current_Label="Global_Top_Ten_(Times_Played)")){
            current_column3_Title := "Number of Times Played"
        } If Else ((Current_Label="System_Top_Ten_(Average_Time)")or(Current_Label="Global_Top_Ten_(Average_Time)")) {
            current_column3_Title := "Average Time Played"
        }
    }
    If(Current_Label<>"General_Statistics"){
        If(FullScreenView<>1){
            Gdip_TextToGraphics(HP_G27, current_column2_Title, OptionsStatisticsTableTitle2, HyperPause_SubMenu_Font, 0, 0)
            Gdip_TextToGraphics(HP_G27, current_column3_Title, OptionsStatisticsTableTitle3, HyperPause_SubMenu_Font, 0, 0)
        } Else {
            Gdip_TextToGraphics(HP_G29, current_column2_Title, OptionsStatisticsTableTitle2, HyperPause_SubMenu_Font, 0, 0)
            Gdip_TextToGraphics(HP_G29, current_column3_Title, OptionsStatisticsTableTitle3, HyperPause_SubMenu_Font, 0, 0)
        }
    }   
    If(FullScreenView<>1)    
        Gdip_TextToGraphics(HP_G27, current_column1_Title, OptionsStatisticsTableTitle, HyperPause_SubMenu_Font, 0, 0)              
    Else
        Gdip_TextToGraphics(HP_G29, current_column1_Title, OptionsStatisticsTableTitle, HyperPause_SubMenu_Font, 0, 0)              
    Loop, parse, Statistics_var_List_%current_item%,| 
        {
        StatisticsTablecount++
        stringreplace, current_column1, a_loopfield, _, %a_space%,all
        If(((V2SubMenuItem = A_index ) and (HSubMenuItem=2)) or (FullScreenView=1)){
            color2 := HyperPause_MainMenu_LabelSelectedColor
        }
        If(A_index >= V2SubMenuItem){  
            If(Current_Label="General_Statistics"){
                IndexMinusTwo := A_index-2
                If(A_index=1)
                    current_column3 = XMLDescription
                Else If(A_index=2)
                    current_column3 = SystemName
                Else
                    current_column3 = % "Value_" . Current_Label_Without_Parenthesis . "_Statistic_" . IndexMinusTwo
            } Else If (Current_Label="Global_Last_Played_Games"){
                current_column1 := % "Value_" . Current_Label_Without_Parenthesis . "_Name_" . A_index
                current_column3 := % "Value_" . Current_Label_Without_Parenthesis . "_System_" . A_index
            } Else {
                current_column2 := % "Value_" . Current_Label_Without_Parenthesis . "_Name_" . A_index
                current_column3 := % "Value_" . Current_Label_Without_Parenthesis . "_Number_" . A_index
                OptionsStatisticsTable2 = x%posStatisticsTableX2% y%posStatisticsTableY% Center c%color2% r4 s%HyperPause_Statistics_TableFontSize% bold
                If(FullScreenView<>1)   
                    Gdip_TextToGraphics(HP_G27, %current_column2%, OptionsStatisticsTable2, HyperPause_SubMenu_Font, 0, 0)   
                Else
                    Gdip_TextToGraphics(HP_G29, %current_column2%, OptionsStatisticsTable2, HyperPause_SubMenu_Font, 0, 0)   
            }    
            OptionsStatisticsTable = x%posStatisticsTableX% y%posStatisticsTableY% Left c%color2% r4 s%HyperPause_Statistics_TableFontSize% bold
            OptionsStatisticsTable3 = x%posStatisticsTableX3% y%posStatisticsTableY% Right c%color2% r4 s%HyperPause_Statistics_TableFontSize% bold
            If(FullScreenView<>1){
                If(Current_Label="Global_Last_Played_Games"){
                    Gdip_TextToGraphics(HP_G27, %current_column1%, OptionsStatisticsTable, HyperPause_SubMenu_Font, 0, 0)  
                } Else {
                    Gdip_TextToGraphics(HP_G27, current_column1, OptionsStatisticsTable, HyperPause_SubMenu_Font, 0, 0)  
                }
                Gdip_TextToGraphics(HP_G27, %current_column3%, OptionsStatisticsTable3, HyperPause_SubMenu_Font, 0, 0)                     
            } Else {
                If(Current_Label="Global_Last_Played_Games"){
                    Gdip_TextToGraphics(HP_G29, %current_column1%, OptionsStatisticsTable, HyperPause_SubMenu_Font, 0, 0)  
                } Else {
                    Gdip_TextToGraphics(HP_G29, current_column1, OptionsStatisticsTable, HyperPause_SubMenu_Font, 0, 0)  
                }
                Gdip_TextToGraphics(HP_G29, %current_column3%, OptionsStatisticsTable3, HyperPause_SubMenu_Font, 0, 0)                     
            }
            posStatisticsTableY := posStatisticsTableY+HyperPause_Statistics_VdistBetwTableLines
            If(VSubMenuItem > 6){
                current_column2 := % "Value_" . Current_Label_Without_Parenthesis . "_System_" . A_index
                OptionsStatisticsTable2 = x%posStatisticsTableX2% y%posStatisticsTableY% Center c%color2% r4 s%HyperPause_Statistics_TableFontSize% bold
                If(FullScreenView<>1)    
                    Gdip_TextToGraphics(HP_G27, %current_column2%, OptionsStatisticsTable2, HyperPause_SubMenu_Font, 0, 0)   
                Else
                    Gdip_TextToGraphics(HP_G29, %current_column2%, OptionsStatisticsTable2, HyperPause_SubMenu_Font, 0, 0)   
                posStatisticsTableY := posStatisticsTableY+HyperPause_Statistics_VdistBetwTableLines
            }
            If(VSubMenuItem = 2){
                current_column3 := % "Value_" . Current_Label_Without_Parenthesis . "_Date_" . A_index
                OptionsStatisticsTable3 = x%posStatisticsTableX3% y%posStatisticsTableY% Right c%color2% r4 s%HyperPause_Statistics_TableFontSize% bold
                If(FullScreenView<>1)    
                    Gdip_TextToGraphics(HP_G27, %current_column3%, OptionsStatisticsTable3, HyperPause_SubMenu_Font, 0, 0)                     
                Else
                    Gdip_TextToGraphics(HP_G29, %current_column3%, OptionsStatisticsTable3, HyperPause_SubMenu_Font, 0, 0)                     
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
        Gdip_GraphicsClear(HP_G29)
        UpdateLayeredWindow(HP_hwnd29, HP_hdc29,A_ScreenWidth - HelpTextLenghtWidth - 2*HyperPause_SubMenu_AdditionalTextMarginContour,A_ScreenHeight- HyperPause_SubMenu_SmallFontSize,HelpTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_HelpFontSize)
        }
    } Else {
        HyperPause_SubMenu_FullScreenHelpBoxHeight := 4*HyperPause_SubMenu_FullScreenFontSize
        HyperPause_SubMenu_FullScreenHelpBoxWidth := MeasureText(0,"Press Up or Down to move between Statistics",HyperPause_SubMenu_Font,HyperPause_SubMenu_FullScreenFontSize,"bold")+HyperPause_SubMenu_AdditionalTextMarginContour
        Gdip_FillRoundedRectangle(HP_G29, HyperPause_SubMenu_FullScreenBrushV, round((HyperPause_SubMenu_MovesListFullScreenWidth-HyperPause_SubMenu_FullScreenHelpBoxWidth)/2), A_ScreenHeight-2*HyperPause_SubMenu_FullScreenMargin-5*HyperPause_SubMenu_FullScreenFontSize, HyperPause_SubMenu_FullScreenHelpBoxWidth,HyperPause_SubMenu_FullScreenHelpBoxHeight,HyperPause_SubMenu_FullScreenRadiusofRoundedCorners)
        posFullScreenTextX := round(HyperPause_SubMenu_MovesListFullScreenWidth/2)
        posFullScreenTextY := round(A_ScreenHeight-2*HyperPause_SubMenu_FullScreenMargin-4*HyperPause_SubMenu_FullScreenFontSize-HyperPause_SubMenu_FullScreenFontSize/2)
        OptionsFullScreenText = x%posFullScreenTextX% y%posFullScreenTextY% Center c%HyperPause_SubMenu_FullScreenFontColor% r4 s%HyperPause_SubMenu_FullScreenFontSize% bold
        CurrentHelpText = Press Select Key to Exit Full Screen`nPress Up or Down to move between Statistics
        Gdip_TextToGraphics(HP_G29, CurrentHelpText, OptionsFullScreenText, HyperPause_SubMenu_Font, 0, 0)
        UpdateLayeredWindow(HP_hwnd29, HP_hdc29,round((A_ScreenWidth-HyperPause_SubMenu_StatisticsFullScreenWidth)/2), HyperPause_SubMenu_FullScreenMargin, HyperPause_SubMenu_StatisticsFullScreenWidth, A_ScreenHeight-2*HyperPause_SubMenu_FullScreenMargin)
    }
Return    

;-------Guides Sub Menu-------
Guides:
    TextImagesAndPDFMenu("Guides")
Return

;-------Manuals Sub Menu-------
Manuals:
    TextImagesAndPDFMenu("Manuals")
Return

;-----------------COMMANDS-------------
MoveRight:
    If FunctionRunning
        Return   
    If(VSubMenuItem = -1)
        Return
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
            Gui,HP_GUI31: Show, Hide
            Gui, HP_GUI32: Show
        }
        HyperPause_MainMenuItem := HyperPause_MainMenuItem+1
        HSubMenuItem=1
        Gdip_GraphicsClear(HP_G29)
        UpdateLayeredWindow(HP_hwnd29, HP_hdc29, A_ScreenWidth - HyperPause_SubMenu_Width,A_ScreenHeight-HyperPause_SubMenu_Height,HyperPause_SubMenu_Width,HyperPause_SubMenu_Height)
        Gosub MainMenuSwap
        Gdip_GraphicsClear(HP_G25)
        Gosub DrawMainMenuBar
        UpdateLayeredWindow(HP_hwnd25, HP_hdc25,0,round((A_ScreenHeight-HyperPause_MainMenu_BarHeight)/2)+HyperPause_MainMenu_BarVerticalOffset, A_ScreenWidth, HyperPause_MainMenu_BarHeight)
        Log("Loaded Main Menu Bar. Current Main Menu Label: " HyperPause_MainMenuSelectedLabel,1)
        If(SubMenuDrawn=1){
            Gdip_GraphicsClear(HP_G26)
            UpdateLayeredWindow(HP_hwnd26, HP_hdc26,ConfigMenuX,ConfigMenuY, ConfigMenuWidth, ConfigMenuHeight)
            Gdip_GraphicsClear(HP_G27)
            UpdateLayeredWindow(HP_hwnd27, HP_hdc27,A_ScreenWidth-HyperPause_SubMenu_Width,A_ScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
            SubMenuDrawn=0
        }
    } Else If (SelectedMenuOption="Sound") and (VSubMenuItem=1){
        HyperPause_VolumeMaster := round(HyperPause_VolumeMaster + HyperPause_SoundBar_vol_Step)+0
        HyperPause_VolumeMaster := round(HyperPause_VolumeMaster//HyperPause_SoundBar_vol_Step*HyperPause_SoundBar_vol_Step)+0 ;Avoiding volume increase in non multiple steps
        If  HyperPause_VolumeMaster < 0 
            HyperPause_VolumeMaster = 0
        If  HyperPause_VolumeMaster > 100
            HyperPause_VolumeMaster = 100
        setMasterVolume(HyperPause_VolumeMaster)
        gosub, DrawSubMenu
    } Else {
        If((FullScreenView = 1) and (ZoomLevel <> 100)){
            HorizontalPanFullScreen := HorizontalPanFullScreen-HyperPause_SubMenu_FullScreenPanSteps
            gosub, DrawSubMenu            
            Return
        } Else If ((FullScreenView = 1) and (SelectedMenuOption="MovesList")){
            V2SubMenuItem := V2SubMenuItem+1
            Gosub SubMenuSwap 
            gosub, DrawSubMenu   
            Return
        } Else If ((FullScreenView = 1) and ((SelectedMenuOption="Guides") or (SelectedMenuOption="Manuals") or (SelectedMenuOption="Controller") or (SelectedMenuOption="Artwork")) and (CurrentFileExtension = "txt")){
            V2SubMenuItem := V2SubMenuItem+1
            If  V2SubMenuItem < 1 
            V2SubMenuItem = % TotaltxtPages
            If  V2SubMenuItem > % TotaltxtPages
            V2SubMenuItem = 1
            Gosub SubMenuSwap 
            HSubmenuitem%SelectedMenuOption%V2Submenuitem%VSubmenuitem% = % V2SubMenuItem
            gosub, DrawSubMenu
            Return   
        } Else If ((FullScreenView = 1) and (SelectedMenuOption="HighScore")){
            VSubMenuItem := VSubMenuItem+1
            Gosub SubMenuSwap   
            gosub, DrawSubMenu
            Return   
        } Else {
            HSubMenuItem := HSubMenuItem+1
            Gosub SubMenuSwap 
            If not ((SelectedMenuOption="Controller") and (VSubMenuItem = -1) and (FullScreenView=1))
                HSubmenuitem%SelectedMenuOption%VSubmenuitem%VSubmenuitem% = % HSubMenuItem            
            gosub, DrawSubMenu
        }
    }
    If (SelectedMenuOption<>"Sound")
        settimer, UpdateMusicPlayingInfo, off
    If (SelectedMenuOption<>"Videos")
        settimer, UpdateVideoPlayingInfo, off
Return


MoveLeft:
    If FunctionRunning
        Return 
    If(VSubMenuItem = -1)
        Return
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
            Gui,HP_GUI31: Show, Hide
            Gui, HP_GUI32: Show
        }
        HyperPause_MainMenuItem := HyperPause_MainMenuItem-1
        HSubMenuItem=1
        Gdip_GraphicsClear(HP_G29)
        UpdateLayeredWindow(HP_hwnd29, HP_hdc29, A_ScreenWidth - HyperPause_SubMenu_Width,A_ScreenHeight-HyperPause_SubMenu_Height,HyperPause_SubMenu_Width,HyperPause_SubMenu_Height) 
        Gosub MainMenuSwap
        Gdip_GraphicsClear(HP_G25)
        Gosub DrawMainMenuBar
        UpdateLayeredWindow(HP_hwnd25, HP_hdc25,0,round((A_ScreenHeight-HyperPause_MainMenu_BarHeight)/2)+HyperPause_MainMenu_BarVerticalOffset, A_ScreenWidth, HyperPause_MainMenu_BarHeight)
        Log("Loaded Main Menu Bar. Current Main Menu Label: " HyperPause_MainMenuSelectedLabel,1)
        If(SubMenuDrawn=1){
            Gdip_GraphicsClear(HP_G26)
            UpdateLayeredWindow(HP_hwnd26, HP_hdc26,ConfigMenuX,ConfigMenuY, ConfigMenuWidth, ConfigMenuHeight)
            Gdip_GraphicsClear(HP_G27)
            UpdateLayeredWindow(HP_hwnd27, HP_hdc27,A_ScreenWidth-HyperPause_SubMenu_Width,A_ScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
            SubMenuDrawn=0
        }
    } Else If (SelectedMenuOption="Sound") and (VSubMenuItem=1){
        HyperPause_VolumeMaster := round(HyperPause_VolumeMaster - HyperPause_SoundBar_vol_Step)+0
        HyperPause_VolumeMaster := round(HyperPause_VolumeMaster//HyperPause_SoundBar_vol_Step*HyperPause_SoundBar_vol_Step)+0 ;Avoiding volume decreae in non multiple steps
        If  HyperPause_VolumeMaster < 0 
            HyperPause_VolumeMaster = 0
        If  HyperPause_VolumeMaster > 100
            HyperPause_VolumeMaster = 100
        setMasterVolume(HyperPause_VolumeMaster)
        gosub, DrawSubMenu
    } Else {
        If((FullScreenView = 1) and (ZoomLevel <> 100)){
            HorizontalPanFullScreen := HorizontalPanFullScreen+HyperPause_SubMenu_FullScreenPanSteps
            gosub, DrawSubMenu            
            Return
        } Else If ((FullScreenView = 1) and (SelectedMenuOption="MovesList")){
            V2SubMenuItem := V2SubMenuItem-1
            Gosub SubMenuSwap 
            gosub, DrawSubMenu   
            Return
        } Else If ((FullScreenView = 1) and ((SelectedMenuOption="Guides") or (SelectedMenuOption="Manuals") or (SelectedMenuOption="Controller") or (SelectedMenuOption="Artwork")) and (CurrentFileExtension = "txt")){
            V2SubMenuItem := V2SubMenuItem-1
            If  V2SubMenuItem < 1 
            V2SubMenuItem = % TotaltxtPages
            If  V2SubMenuItem > % TotaltxtPages
            V2SubMenuItem = 1
            Gosub SubMenuSwap 
            HSubmenuitem%SelectedMenuOption%V2Submenuitem%VSubmenuitem% = % V2SubMenuItem
            gosub, DrawSubMenu
            Return   
        } Else If ((FullScreenView = 1) and (SelectedMenuOption="HighScore")){
            VSubMenuItem := VSubMenuItem-1
            Gosub SubMenuSwap   
            gosub, DrawSubMenu
            Return   
        } Else {
            HSubMenuItem := HSubMenuItem-1
            Gosub SubMenuSwap
            If not ((SelectedMenuOption="Controller") and (VSubMenuItem = -1) and (FullScreenView=1))
                HSubmenuitem%SelectedMenuOption%VSubmenuitem%VSubmenuitem% = % HSubMenuItem
            gosub, DrawSubMenu
        }
    }
    If (SelectedMenuOption<>"Sound")
        settimer, UpdateMusicPlayingInfo, off
    If (SelectedMenuOption<>"Videos")
        settimer, UpdateVideoPlayingInfo, off
Return

MoveUp:
    If FunctionRunning
        Return 
    If (SelectedMenuOption="Shutdown")
        Return
    If((FullScreenView = 1) and (ZoomLevel <> 100)){
        VerticalPanFullScreen := VerticalPanFullScreen+HyperPause_SubMenu_FullScreenPanSteps       
        gosub, DrawSubMenu
        Return
    }
    Previous_VSubMenuItem := VSubMenuItem
    If((SelectedMenuOption="Controller") and (VSubMenuItem = -1) and (FullScreenView=1)){
        VSubMenuItem := VSubMenuItem+1
        V2SubMenuItem := V2SubMenuItem-1
        If  V2SubMenuItem < 1 
            V2SubMenuItem = 18
        If  V2SubMenuItem > 18
            V2SubMenuItem = 1
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
    If(((SelectedMenuOption="Guides") or (SelectedMenuOption="Manuals") or (SelectedMenuOption="Controller") or (SelectedMenuOption="Artwork") or (SelectedMenuOption="Guides"))and(HSubMenuItem>1)and (VSubMenuItem>=0)){
        If((CurrentFileExtension <> "pdf") and (CurrentFileExtension <> "folder") and (CurrentCompressedFileExtension<> "true")){
            VSubMenuItem := VSubMenuItem+1
        }
        V2SubMenuItem := V2SubMenuItem-1
        If  V2SubMenuItem < 1 
            V2SubMenuItem = % TotaltxtPages
        If  V2SubMenuItem > % TotaltxtPages
            V2SubMenuItem = 1
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
        UpdateLayeredWindow(HP_hwnd25, HP_hdc25,0,round((A_ScreenHeight-HyperPause_MainMenu_BarHeight)/2)+HyperPause_MainMenu_BarVerticalOffset, A_ScreenWidth, HyperPause_MainMenu_BarHeight)
        Log("Loaded Main Menu Bar. Current Main Menu Label: " HyperPause_MainMenuSelectedLabel,1)
    }
    If (SelectedMenuOption="Sound"){
        If (VSubMenuItem = 3){
            currentPlayindex := HSubmenuitemSoundVSubmenuitem3           
        } Else {
            PreviousCurrentMusicButton = 
            Gdip_GraphicsClear(HP_G30)
            UpdateLayeredWindow(HP_hwnd30, HP_hdc30, A_ScreenWidth-HyperPause_SubMenu_Width, A_ScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
        }
    }
    If (SelectedMenuOption="Videos"){
        If (HSubMenuItem <> 2){
            Gdip_GraphicsClear(HP_G30)
            UpdateLayeredWindow(HP_hwnd30, HP_hdc30, A_ScreenWidth-HyperPause_SubMenu_Width, A_ScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
        }
    }
    gosub, DrawSubMenu  
Return

MoveDown:
    If FunctionRunning
        Return 
    If (SelectedMenuOption="Shutdown")
        Return
    If((FullScreenView = 1) and (ZoomLevel <> 100)){
        VerticalPanFullScreen := VerticalPanFullScreen-HyperPause_SubMenu_FullScreenPanSteps     
        gosub, DrawSubMenu
        Return
    }
    Previous_VSubMenuItem := VSubMenuItem
    If((SelectedMenuOption="Controller") and (VSubMenuItem = -1) and (FullScreenView=1)){
        VSubMenuItem := VSubMenuItem-1
        V2SubMenuItem := V2SubMenuItem+1
        If  V2SubMenuItem < 1 
            V2SubMenuItem = 18
        If  V2SubMenuItem > 18
            V2SubMenuItem = 1
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
    If(((SelectedMenuOption="Guides") or (SelectedMenuOption="Manuals") or (SelectedMenuOption="Controller") or (SelectedMenuOption="Artwork") or (SelectedMenuOption="Guides"))and (HSubMenuItem>1) and (VSubMenuItem>=0)){
        If((CurrentFileExtension <> "pdf") and (CurrentFileExtension <> "folder") and (CurrentCompressedFileExtension<> "true")){
            VSubMenuItem := VSubMenuItem-1
        }
        V2SubMenuItem := V2SubMenuItem+1
        If  V2SubMenuItem < 1 
            V2SubMenuItem = % TotaltxtPages
        If  V2SubMenuItem > % TotaltxtPages
            V2SubMenuItem = 1
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
        UpdateLayeredWindow(HP_hwnd25, HP_hdc25,0,round((A_ScreenHeight-HyperPause_MainMenu_BarHeight)/2)+HyperPause_MainMenu_BarVerticalOffset, A_ScreenWidth, HyperPause_MainMenu_BarHeight)
        Log("Loaded Main Menu Bar. Current Main Menu Label: " HyperPause_MainMenuSelectedLabel,1)
    }
    If (SelectedMenuOption="Sound"){
        If (VSubMenuItem = 3){
            currentPlayindex := HSubmenuitemSoundVSubmenuitem3            
        } Else {
            PreviousCurrentMusicButton = 
            Gdip_GraphicsClear(HP_G30)
            UpdateLayeredWindow(HP_hwnd30, HP_hdc30, A_ScreenWidth-HyperPause_SubMenu_Width, A_ScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
        }
    }
    If (SelectedMenuOption="Videos"){
        If (HSubMenuItem <> 2){
            Gdip_GraphicsClear(HP_G30)
            UpdateLayeredWindow(HP_hwnd30, HP_hdc30, A_ScreenWidth-HyperPause_SubMenu_Width, A_ScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
        }
    }
    gosub, DrawSubMenu  
Return


BacktoMenuBar:
    If (SelectedMenuOption = "Shutdown")
        Return
    If ((SelectedMenuOption="Controller") and (VSubMenuItem = -1))
        settimer, CheckJoyPresses, off
    VSubMenuItem := 0
    HSubMenuItem=1
    Gdip_GraphicsClear(HP_G30)
    UpdateLayeredWindow(HP_hwnd30, HP_hdc30, A_ScreenWidth-HyperPause_SubMenu_Width, A_ScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
    If(FullScreenView = 1){
        Gdip_GraphicsClear(HP_G29)
        UpdateLayeredWindow(HP_hwnd29, HP_hdc29,0,0,A_ScreenWidth,A_ScreenHeight) 
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
    UpdateLayeredWindow(HP_hwnd25, HP_hdc25,0,round((A_ScreenHeight-HyperPause_MainMenu_BarHeight)/2)+HyperPause_MainMenu_BarVerticalOffset, A_ScreenWidth, HyperPause_MainMenu_BarHeight)
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
            VSubMenuItem = % TotalSubMenuItems%SelectedMenuOption%
        If  VSubMenuItem > % TotalSubMenuItems%SelectedMenuOption%
            VSubMenuItem = 0
    }
    If(SelectedMenuOption="ChangeDisc"){
        If  HSubMenuItem < 1 
            HSubMenuItem = % TotalSubMenuItems%SelectedMenuOption%
        If  HSubMenuItem > % TotalSubMenuItems%SelectedMenuOption%
            HSubMenuItem = 1  
        If  VSubMenuItem < 0 
            VSubMenuItem = 1
        If  VSubMenuItem > 1
            VSubMenuItem = 0
    }
    If(SelectedMenuOption="Sound"){
        TotalSubMenuItemsSound := 2
        TotalVSubMenuItem2SoundItems := 1
        If(HyperPause_CurrentPlaylist<>""){
            TotalSubMenuItemsSound := 3
            TotalVSubMenuItem2SoundItems := 3
        }
        If  VSubMenuItem < 0 
            VSubMenuItem = % TotalSubMenuItems%SelectedMenuOption%
        If  VSubMenuItem > % TotalSubMenuItems%SelectedMenuOption%
            VSubMenuItem = 0
        If(VSubMenuItem=2){
            If  HSubMenuItem < 1 
                HSubMenuItem = % TotalVSubMenuItem2SoundItems
            If  HSubMenuItem > % TotalVSubMenuItem2SoundItems
                HSubMenuItem = 1
        }
    }
    If(SelectedMenuOption="MovesList"){
        If  HSubMenuItem < 1 
            HSubMenuItem = 2
        If  HSubMenuItem > 2
            HSubMenuItem = 1  
        If  VSubMenuItem < 0 
            VSubMenuItem = % TotalSubMenuItems%SelectedMenuOption%
        If  VSubMenuItem > % TotalSubMenuItems%SelectedMenuOption%
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
    If((SelectedMenuOption="Guides")or(SelectedMenuOption="Artwork")or(SelectedMenuOption="Manuals")){
        If  HSubMenuItem < 0
            HSubMenuItem = 1
        If  HSubMenuItem > % TotalCurrentPages
            HSubMenuItem = 1 
        If  VSubMenuItem < 0
            VSubMenuItem = % TotalSubMenuItems%SelectedMenuOption%
        If  VSubMenuItem > % TotalSubMenuItems%SelectedMenuOption%
            VSubMenuItem = 0
    }
    If(SelectedMenuOption="Controller"){
        If  HSubMenuItem < 0
            HSubMenuItem = 1
        If  HSubMenuItem > % TotalCurrentPages
            HSubMenuItem = 1 
        If (keymapperEnabled = "true") and (JoyIDsEnabled = "true"){
            If  VSubMenuItem < -1
                VSubMenuItem = % TotalSubMenuItems%SelectedMenuOption%
            If  VSubMenuItem > % TotalSubMenuItems%SelectedMenuOption%
                VSubMenuItem = -1
        } Else {
            If  VSubMenuItem < 0
                VSubMenuItem = % TotalSubMenuItems%SelectedMenuOption%
            If  VSubMenuItem > % TotalSubMenuItems%SelectedMenuOption%
                VSubMenuItem = 0            
        }
    }    
    If(SelectedMenuOption="Videos"){
        If  VSubMenuItem < 0
            VSubMenuItem = % TotalSubMenuItems%SelectedMenuOption%
        If  VSubMenuItem > % TotalSubMenuItems%SelectedMenuOption%
            VSubMenuItem = 0
        
        If  HSubMenuItem < 1
            HSubMenuItem = 2
        If  HSubMenuItem > 2
            HSubMenuItem = 1         
        
    }
    If(VSubMenuItem=0){
        If not(SelectedMenuOption="Sound"){
            Gdip_GraphicsClear(HP_G29)
            UpdateLayeredWindow(HP_hwnd29, HP_hdc29,0,0,A_ScreenWidth,A_ScreenHeight) 
        }
        FullScreenView = 0  
    }
Return


ToggleItemSelectStatus:
    If (SelectedMenuOption = "Shutdown") {
        close_emulator := true
        gosub, ExitHyperPause
    }
    If(SelectedMenuOption="LoadState"){ 
        If SlotEmpty
            Return
        ItemSelected=1
        gosub, ExitHyperPause
    }
    If((SelectedMenuOption="SaveState")or(SelectedMenuOption="ChangeDisc")){ 
        ItemSelected=1
        gosub, ExitHyperPause
    }
    If(((SelectedMenuOption="Statistics") or (SelectedMenuOption="Guides") or (SelectedMenuOption="Manuals") or (SelectedMenuOption="Controller") or (SelectedMenuOption="Artwork") or ((SelectedMenuOption="MovesList") and (HSubMenuItem=2)) or (SelectedMenuOption="HighScore")) and (VSubMenuItem > 0)){
        If !((CurrentFileExtension = "txt") and (HSubMenuItem=1)){
            If(FullScreenView = 1){
                If(SelectedMenuOption="MovesList"){
                    AdjustedPage := % (((V2SubMenuItem-1)*(LinesperFullScreenPage%SelectedMenuOption%))/LinesperPage%SelectedMenuOption%)+1
                    V2SubMenuItem := Floor(AdjustedPage)
                }
                If(((SelectedMenuOption="Manuals") and (CurrentFileExtension = "txt")) or ((SelectedMenuOption="Guides") and (CurrentFileExtension = "txt"))){
                    AdjustedPage := % (((V2SubMenuItem-1)*(LinesperFullScreenPage%SelectedMenuOption%))/LinesperPage%SelectedMenuOption%)+1
                    V2SubMenuItem := Floor(AdjustedPage)
                    HSubmenuitem%SelectedMenuOption%V2Submenuitem%VSubmenuitem% = % V2SubMenuItem
                }
                Gdip_GraphicsClear(HP_G29)
                UpdateLayeredWindow(HP_hwnd29, HP_hdc29,0,0,A_ScreenWidth,A_ScreenHeight)    
                FullScreenView = 0
                gosub, DrawSubMenu
            } Else {
                If(SelectedMenuOption="MovesList"){
                    AdjustedPage := % (((V2SubMenuItem-1)*(LinesperPage%SelectedMenuOption%))/LinesperFullScreenPage%SelectedMenuOption%)+1
                    V2SubMenuItem := Floor(AdjustedPage)
                }
                If(((SelectedMenuOption="Manuals") and (CurrentFileExtension = "txt")) or ((SelectedMenuOption="Guides") and (CurrentFileExtension = "txt"))){
                     AdjustedPage := % (((V2SubMenuItem-1)*(LinesperPage%SelectedMenuOption%))/LinesperFullScreenPage%SelectedMenuOption%)+1
                    V2SubMenuItem := Floor(AdjustedPage)
                    HSubmenuitem%SelectedMenuOption%V2Submenuitem%VSubmenuitem% = % V2SubMenuItem
                }                
                FullScreenView = 1
                ZoomLevel := 100
                gosub, DrawSubMenu
            }
        }
    } 
    If ((SelectedMenuOption="Controller") and (VSubMenuItem = -1)){
        If(FullScreenView = 1) {
            If (V2SubMenuItem = 1){
                Gdip_GraphicsClear(HP_G29)
                UpdateLayeredWindow(HP_hwnd29, HP_hdc29,0,0,A_ScreenWidth,A_ScreenHeight)   
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
                tooltip, You need at least one connected controller to use this menu!, A_ScreenWidth//2, A_ScreenHeight//2
                setTimer, EndofToolTipDelay, -1000
            }
            joyConnectedExist := ""
        }
    }
    If(SelectedMenuOption="Sound"){
        If(VSubMenuItem=2){
            If(HSubmenuitemSoundVSubmenuitem2=1){
                CurrentMuteStatus := GetMasterMute()
                If(CurrentMuteStatus=1)
                    SetMasterMute(false)
                Else
                    SetMasterMute(true)
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
    If((SelectedMenuOption="Videos")and (VSubMenuItem > 0)){
        If((HSubMenuItem=2) and (VSubMenuItem > 0)){
            If(FullScreenView = 1){
                If(HyperPause_Active=true)
                    gosub, EnableKeys
                Gdip_GraphicsClear(HP_G30)
                UpdateLayeredWindow(HP_hwnd30, HP_hdc30, A_ScreenWidth-HyperPause_SubMenu_Width, A_ScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
                try wmpvideo.fullScreen := false
                FullScreenView = 0
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
            Gdip_DrawImage(HP_G32, MouseFullScreenOverlayBitmap, 0, 0, MouseOverlayW, MouseOverlayH)
            UpdateLayeredWindow(HP_hwnd32, HP_hdc32,0,A_ScreenHeight-MouseOverlayH, MouseOverlayW, MouseOverlayH,HyperPause_MouseControlTransparency)        
        } Else {
            Gdip_GraphicsClear(HP_G32)
            Gdip_DrawImage(HP_G32, MouseOverlayBitmap, 0, 0, MouseOverlayW, MouseOverlayH)
            UpdateLayeredWindow(HP_hwnd32, HP_hdc32,0,A_ScreenHeight-MouseOverlayH, MouseOverlayW, MouseOverlayH,HyperPause_MouseControlTransparency)        
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
    If (HyperPause_Running<>true){
        gosub, HyperPause_Main
    } Else {
        If(HyperPause_Active=true){
            If (disableActivateBlackScreen and HyperPause_Disable_Menu="true") or ErrorExit {
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
    Log("Closing HyperPause",1)
    gosub, DisableKeys
    Log("Disabled Keys while exiting",5)    
    HyperPause_Active:=false
    If not(HyperPause_MuteSound="true"){ 
        If(HyperPause_MuteWhenLoading="true"){ ;Mute when exiting HyperPause to avoiding sound stuttering
            InitialMuteState := GetMasterMute()
            If(InitialMuteState<>1){
                SetMasterMute(true)
                Log("Muting computer sound while HP is loaded. Master Mute status: " GetMasterMute() " (1 is mutted)",5)            
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
            Gdip_FillRectangle(HP_G21, HyperPause_Load_Background_Brush, -1, -1, A_ScreenWidth+1, A_ScreenHeight+1)
            Gdip_TextToGraphics(HP_G21, HyperPause_AuxiliarScreen_ExitText, OptionsLoadHP, HyperPause_AuxiliarScreen_Font, 0, 0)
        }
        UpdateLayeredWindow(HP_hwnd21, HP_hdc21, 0, 0, A_ScreenWidth, A_ScreenHeight)
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
                If (A_Index > 6)
                    romTable[current, A_Index] := ""
            }
        }
    }
    If !disableLoadScreen
        If !disableActivateBlackScreen
            WinActivate, HyperPauseBlackScreen
    Loop, 10 {
        If not (A_Index=9) {
            CurrentGUI := A_Index+21
            SelectObject(HP_hdc%CurrentGUI%, HP_obm%CurrentGUI%)
            DeleteObject(HP_hbm%CurrentGUI%)
            DeleteDC(HP_hdc%CurrentGUI%)
            Gdip_DeleteGraphics(HP_G%CurrentGUI%)
            Gui, HP_GUI%CurrentGUI%: Destroy
        }
    }
    If(TotalSubMenuItemsVideos>0)
        Gui, HP_GUI31: Destroy
    Log("Guis destroyed",5)
    Gdip_DeleteBrush(BlackGradientBrush), Gdip_DeleteBrush(PBRUSH), Gdip_DeleteBrush(HyperPause_SubMenu_BackgroundBrushV), Gdip_DeleteBrush(HyperPause_SubMenu_SelectedBrushV), Gdip_DeleteBrush(HyperPause_SubMenu_DisabledBrushV), Gdip_DeleteBrush(HyperPause_BackgroundBrushV), Gdip_DeleteBrush(HyperPause_SubMenu_GuidesSelectedBrushV), Gdip_DeleteBrush(HyperPause_SubMenu_ManualsSelectedBrushV), Gdip_DeleteBrush(HyperPause_SubMenu_ControllerSelectedBrushV), Gdip_DeleteBrush(HyperPause_SubMenu_ArtworkSelectedBrushV),Gdip_DeleteBrush(HyperPause_SubMenu_FullScreenTextBrushV), Gdip_DeleteBrush(HyperPause_SubMenu_FullScreenBrushV)
    Log("Brushes deleted",5)
    Gdip_DisposeImage(MainMenuBackgroundBitmap), Gdip_DisposeImage(WheelImageBitmap), Gdip_DisposeImage(PauseImageBitmap), Gdip_DisposeImage(SoundBitmap), Gdip_DisposeImage(MuteBitmap), Gdip_DisposeImage(ButtonToggleONBitmap), Gdip_DisposeImage(ButtonToggleOFFBitmap), Gdip_DisposeImage(CurrentBitmap), Gdip_DisposeImage(SelectedBitmap), Gdip_DisposeImage(pGameScreenshot)
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
    If (keymapperEnabled = "true") and (keymapperHyperLaunchProfileEnabled = "true") {
        RunKeymapper%zz%("load",keymapper)
        If !disableLoadScreen
            If !disableActivateBlackScreen
                WinActivate, HyperPauseBlackScreen
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
        IfWinNotActive, ahk_class %EmulatorClass%,,Hyperspin
            {
            Loop{
                sleep, 200
                WinRestore, ahk_ID %emulatorID%
                sleep, 200
                WinActivate, ahk_class %EmulatorClass%,,Hyperspin
                IfWinActive, ahk_class %EmulatorClass%,,Hyperspin
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
        SelectObject(HP_hdc21, HP_obm21)
        DeleteObject(HP_hbm21)
        DeleteDC(HP_hdc21)
        Gdip_DeleteGraphics(HP_G21)
        Gui, HP_GUI21: Destroy  
    }
    Log("Black Screen Gui destroyed",5)
    XHotKeywrapper(exitEmulatorKey,"CloseProcess","ON")
    XHotKeywrapper(hpKey,"TogglePauseMenuStatus","ON")
    If mgEnabled = true
        XHotKeywrapper(mgKey,"StartMulti","ON")
    Log("Enabling HyperLaunch Keys",5)
    Gosub, SendCommandstoEmulator
    If((ItemSelected=1)and(SelectedMenuOption="ChangeDisc")){ 
        If statisticsEnabled = true
            gosub, UpdateStatistics
        gameSectionStartTime := A_TickCount
        gameSectionStartHour := A_Now
        gosub, MultiGame
    }
    SetKeyDelay, %SavedKeyDelay%
    Log("HyperPause Closed",1)
    HyperPause_Running:=false
    Log("Exiting Emulator From HyperPause",1)
    If close_emulator {
        gosub, CloseProcess
        WinWaitClose, ahk_id  %emulatorID%
    }
    If((HyperPause_MuteWhenLoading="true") or (HyperPause_MuteSound="true")){
        If(InitialMuteState<>1){
            CurrentMuteState := GetMasterMute()
            If(CurrentMuteState=1){
                SetMasterMute(false)
                Log("Unmuting computer sound while HP is loaded. Master Mute status: " GetMasterMute() " (0 is unmutted)",5)
            }
        }
    }
	If (emuIdleShutdown and emuIdleShutdown != "ERROR")	; turn on emuIdleShutdown while in HP
		SetTimer, EmuIdleCheck, On
    setMasterVolume(HyperPause_VolumeMaster) ; making sure that changes on sound menu are updated   
Return


SimplifiedExitHyperPause:
    If !disableSuspendEmu    
        {
        ProcRes(emulatorProcessName)
        Log("Emulator process started",5)
        timeout := A_TickCount
        sleep, 200
        WinRestore, ahk_ID %emulatorID%
        IfWinNotActive, ahk_class %EmulatorClass%,,Hyperspin
            {
            Loop{
                sleep, 200
                WinRestore, ahk_ID %emulatorID%
                sleep, 200
                WinActivate, ahk_class %EmulatorClass%,,Hyperspin
                IfWinActive, ahk_class %EmulatorClass%,,Hyperspin
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
        If(InitialMuteState<>1){
            CurrentMuteState := GetMasterMute()
            If(CurrentMuteState=1){
                SetMasterMute(false)
                Log("Unmuting computer sound while HP is loaded. Master Mute status: " GetMasterMute() " (0 is unmutted)",5)
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
    HyperPause_Active:=false
    HyperPause_Running:=false
Return

SendCommandstoEmulator:
    If (ItemSelected = 1){
        If((SelectedMenuOption="SaveState")or(SelectedMenuOption="LoadState")){ 
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
            
            If(SelectedMenuOption="SaveState") {
                gosub, SaveScreenshot   
                RIni_SetKeyValue(1,dbName, "SaveState" . VSubMenuItem . "Screenshot",CurrentScreenshotFileName) ; makes sure that save state info is saved on statistics update   
                IniWrite, %CurrentScreenshotFileName%, %HyperPause_GameStatistics%%systemName%.ini, %dbName%, SaveState%VSubMenuItem%Screenshot ; saves save state info between HYperPause menu calls
            }
        }
        If(SelectedMenuOption="ChangeDisc"){
            ChandeDiscSelected = true
            ;selectedRom:=HPromTable[HSubMenuItem,1]
            selectedRom:=romTable[HSubMenuItem,1]
            SplitPath, selectedRom,,mgRomPath,mgRomExt,mgDbName
            If romNeeds7z {
                mgRomExt:="." . mgRomExt
                7z%currentButton% := 7z(mgRomPath, mgDbName, mgRomExt, 7zExtractDir)
                ;HPromTable[HSubMenuItem,19]:=mgRomPath . mgDbName
                romTable[HSubMenuItem,19]:=mgRomPath . mgDbName
            }
            Log("Change Disc command sent to module",1)
        }
    }
Return


;-----------------SUB MENU LIST AND DRAWING FUNCTIONS------------
VideosSubMenuList(SubMenuName)
{
    global
    FileCount := 0
    CurrentPath := % HyperPause_%SubMenuName%Path
    Loop, parse, HyperPause_SupportedVideos,|,
        {
        If (Totaldiscsofcurrentgame>1){
            Loop, %CurrentPath%%systemName%\%DescriptionNameWithoutDisc%\*.%A_LoopField%, 0
                {
                Log("Loading " SubMenuName " : " A_LoopFileLongPath,5)
                SplitPath, A_LoopFileLongPath , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
                FileCount++
                %SubMenuName%List := % %SubMenuName%List OutNameNoExt . "|"
                %SubMenuName%File%FileCount% := A_LoopFileLongPath
                %SubMenuName%FileExtension%FileCount% = %OutExtension%
            }
        }
        Loop, %CurrentPath%%systemName%\%dbName%\*.%A_LoopField%, 0
            {
            Log("Loading " SubMenuName " : " A_LoopFileLongPath,5)
            SplitPath, A_LoopFileLongPath , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
            FileCount++
            %SubMenuName%List := % %SubMenuName%List OutNameNoExt . "|"
            %SubMenuName%File%FileCount% := A_LoopFileLongPath
            %SubMenuName%FileExtension%FileCount% = %OutExtension%
        }
    }
    If(HyperPause_EnableHyperspinVideos="true"){
        If HyperPause_SupportedVideos contains flv,mp4
            {
            IfExist, % VideoSystemPath . dbName . ".flv"
                {
                Log("Loading HyperSpin rom " SubMenuName ": "  VideoSystemPath . dbName ".flv",5)
                FileCount++
                %SubMenuName%List := % %SubMenuName%List dbName . "|"
                %SubMenuName%File%FileCount% := VideoSystemPath . dbName . ".flv"
                %SubMenuName%FileExtension%FileCount% = flv  
            }
            IfExist, % VideoSystemPath . dbName . ".mp4"
                {
                Log("Loading HyperSpin rom " SubMenuName ": "  VideoSystemPath . dbName ".mp4",5)
                FileCount++
                %SubMenuName%List := % %SubMenuName%List dbName . "|"
                %SubMenuName%File%FileCount% := VideoSystemPath . dbName . ".mp4"
                %SubMenuName%FileExtension%FileCount% = mp4  
            }
        }
    }
    Loop, parse, HyperPause_SupportedVideos,|,
        {
        Loop, %CurrentPath%%systemName%\_Default\*.%A_LoopField%, 0
            {
            Log("Loading " SubMenuName " : " A_LoopFileLongPath,5)
            SplitPath, A_LoopFileLongPath , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
            FileCount++
            %SubMenuName%List := % %SubMenuName%List OutNameNoExt . "|"
            %SubMenuName%File%FileCount% := A_LoopFileLongPath
            %SubMenuName%FileExtension%FileCount% = %OutExtension%
        }
    }
    If(HyperPause_EnableHyperspinVideos="true"){
        If HyperPause_SupportedVideos contains flv,mp4
            {
            IfExist, % VideoMainMenuPath . systemName . ".flv"
                {
                Log("Loading HyperSpin System " SubMenuName ": "  VideoSystemPath . dbName ".flv",5)
                FileCount++
                %SubMenuName%List := % %SubMenuName%List systemName . "|"
                %SubMenuName%File%FileCount% := VideoMainMenuPath . systemName . ".flv"
                %SubMenuName%FileExtension%FileCount% = flv         
            }   
            IfExist, % VideoMainMenuPath . systemName . ".mp4"
                {
                Log("Loading HyperSpin System " SubMenuName ": "  VideoSystemPath . dbName ".mp4",5)
                FileCount++
                %SubMenuName%List := % %SubMenuName%List systemName . "|"
                %SubMenuName%File%FileCount% := VideoMainMenuPath . systemName . ".mp4"
                %SubMenuName%FileExtension%FileCount% = mp4         
            }  
        }    
    }
    StringTrimRight, %SubMenuName%List, %SubMenuName%List, 1   
    TotalSubMenuItems%SubMenuName% := FileCount  ;counting total sub menu items  
    %SubMenuName%MaxFontListWidth = %HyperPause_SubMenu_MinimumTextBoxWidth% ;determining max text size of submenulabels and initializing video positions
    Loop, parse, %SubMenuName%List,|, 
        {
        FontListWidth := MeasureText(0,A_LoopField,HyperPause_SubMenu_LabelFont,HyperPause_SubMenu_LabelFontSize,"bold")+HyperPause_SubMenu_AdditionalTextMarginContour
        If(FontListWidth>%SubMenuName%MaxFontListWidth){
            %SubMenuName%MaxFontListWidth := FontListWidth
        }
        VideoPosition%a_index% := 0
        Log("Initializing VideoPosition:" "VideoPosition"a_index " " VideoPosition%a_index%,5)        
    }
    If (TotalSubMenuItems%SubMenuName%<1){ ;excluding submenu If no files are found 
        StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, %SubMenuName%|,
    }
}    
Return


MultiContentSubMenuList(SubMenuName)
{
    global
    %SubMenuName%MenuFirsttimeLoaded := 0
    FileCount := 0
    %SubMenuName%List := "|"
    CurrentPath := % HyperPause_%SubMenuName%Path
    ; Loop HyperLaunch\Media\Sony Playstation\Final Fantasy VII (USA)\ folders
    If (Totaldiscsofcurrentgame>1){
        Loop, %CurrentPath%%systemName%\%DescriptionNameWithoutDisc%\*.*, 2
            {
            folderName := A_LoopFileName
            Loop % A_LoopFileLongPath . "\*.*"
                {
                If A_LoopFileExt in  %Supported_Images%
                    {
                    Log("Loading " SubMenuName " image folder: " folderName,5)
                    If ! Instr(%SubMenuName%List, "|" . folderName . "|") {
                        FileCount++
                        %SubMenuName%List .= folderName . "|"
                    }
                    %SubMenuName%FileExtension%FileCount% = folder
                    Log("Loading " SubMenuName " image inside folder: " A_LoopFileLongPath,5)
                    %SubMenuName%File%FileCount%File%a_index% = %A_LoopFileLongPath% 
                    TotalSubMenu%SubMenuName%Pages%FileCount%++
                    TotalSubMenu%SubMenuName%Pages%FileCount% += 0 
                }
            }
        }
    }
    ; Loop HyperLaunch\Media\Sony Playstation\Final Fantasy VII (USA) (Disc x)\ folders
    Loop, %CurrentPath%%systemName%\%dbName%\*.*, 2
        {
        folderName := A_LoopFileName
        Loop % A_LoopFileLongPath . "\*.*"
            {
            If A_LoopFileExt in  %Supported_Images%
                {
                Log("Loading " SubMenuName " image folder: " folderName,5)
                If ! Instr(%SubMenuName%List, "|" . folderName . "|") {
                    FileCount++
                    %SubMenuName%List .= folderName . "|"
                }
                %SubMenuName%FileExtension%FileCount% = folder
                Log("Loading " SubMenuName " image inside folder: " A_LoopFileLongPath,5)
                %SubMenuName%File%FileCount%File%a_index% = %A_LoopFileLongPath% 
                TotalSubMenu%SubMenuName%Pages%FileCount%++
                TotalSubMenu%SubMenuName%Pages%FileCount% += 0 
            }
        }
    }
    ; Loop HyperLaunch\Media\Sony Playstation\Final Fantasy VII (USA)\*.png files
    If (Totaldiscsofcurrentgame>1){
        Loop, %CurrentPath%%systemName%\%DescriptionNameWithoutDisc%\*.*, 0
            {
            If A_LoopFileExt in %Supported_Extensions%
                {
                If A_LoopFileExt in %7zFormatsNoP%
                    {
                    IfExist, % 7zPath
                        {
                        Log("Loading " SubMenuName " 7z file: " A_LoopFileFullPath,5)
                        CurrentExtension := A_LoopFileExt
                        CurrentFile :=  A_LoopFileFullPath
                        CurrentFileName := A_LoopFileName
                        TempCompressedListofFiles := StdoutToVar_CreateProcess(7zPath . " l """ . CurrentFile . """")
                        Loop, parse, Supported_Images,`,,
                            {
                            If TempCompressedListofFiles contains %A_LoopField%
                                {  
                            Log("Loading " SubMenuName " image inside 7z file: " CurrentFileName,5)
                            FileCount++
                            SplitPath, CurrentFile, ,,,FileNameWithoutExtension
                            %SubMenuName%List .= FileNameWithoutExtension . "|"
                            %SubMenuName%File%FileCount% = %CurrentFile%
                            %SubMenuName%FileExtension%FileCount% = %CurrentExtension% 
                            %SubMenuName%CompressedFile%FileCount%Loaded = false                                   
                            break
                            }
                        }
                    }                     
                } Else If (A_LoopFileExt="pdf"){
                        Log("Loading " SubMenuName " pdf file: " A_LoopFileFullPath,5)
                        FileCount++ 
                        SplitPath, A_LoopFileFullPath, ,,,FileNameWithoutExtension
                        %SubMenuName%List .= FileNameWithoutExtension . "|"
                        %SubMenuName%File%FileCount% = %A_LoopFileFullPath%
                        %SubMenuName%FileExtension%FileCount% = %A_LoopFileExt%    
                } Else {
                    Log("Loading " SubMenuName " file: " A_LoopFileFullPath,5)
                    FileCount++ 
                    SplitPath, A_LoopFileFullPath, ,,,FileNameWithoutExtension
                    %SubMenuName%List .= FileNameWithoutExtension . "|"
                    %SubMenuName%File%FileCount% = %A_LoopFileFullPath%
                    %SubMenuName%FileExtension%FileCount% = %A_LoopFileExt%
                }
            }
        }
    }
    ; Loop HyperLaunch\Media\Sony Playstation\Final Fantasy VII (USA) (Disc x)\*.png files
    Loop, %CurrentPath%%systemName%\%dbName%\*.*, 0
        {
        If A_LoopFileExt in %Supported_Extensions%
            {
            If A_LoopFileExt in %7zFormatsNoP%
                {
                IfExist, % 7zPath
                    {
                    Log("Loading " SubMenuName " 7z file: " A_LoopFileFullPath,5)
                    CurrentExtension := A_LoopFileExt
                    CurrentFile :=  A_LoopFileFullPath
                    CurrentFileName := A_LoopFileName
                    TempCompressedListofFiles := StdoutToVar_CreateProcess(7zPath . " l """ . CurrentFile . """")
                    Loop, parse, Supported_Images,`,,
                        {
                        If TempCompressedListofFiles contains %A_LoopField%
                            {  
                            Log("Loading " SubMenuName " image inside 7z file: " CurrentFileName,5)
                            FileCount++
                            SplitPath, CurrentFile, ,,,FileNameWithoutExtension
                            %SubMenuName%List .= FileNameWithoutExtension . "|"
                            %SubMenuName%File%FileCount% = %CurrentFile%
                            %SubMenuName%FileExtension%FileCount% = %CurrentExtension% 
                            %SubMenuName%CompressedFile%FileCount%Loaded = false                          
                            break
                        }
                    }
                }  
            } Else If (A_LoopFileExt="pdf"){
                Log("Loading " SubMenuName " pdf file: " A_LoopFileFullPath,5)
                FileCount++ 
                SplitPath, A_LoopFileFullPath, ,,,FileNameWithoutExtension
                %SubMenuName%List .= FileNameWithoutExtension . "|"
                %SubMenuName%File%FileCount% = %A_LoopFileFullPath%
                %SubMenuName%FileExtension%FileCount% = %A_LoopFileExt%               
            } Else {
                Log("Loading " SubMenuName " file: " A_LoopFileFullPath,5)
                FileCount++ 
                SplitPath, A_LoopFileFullPath, ,,,FileNameWithoutExtension
                %SubMenuName%List .= FileNameWithoutExtension . "|"
                %SubMenuName%File%FileCount% = %A_LoopFileFullPath%
                %SubMenuName%FileExtension%FileCount% = %A_LoopFileExt%
            }
        }
    }
    ; Loop HyperLaunch\Media\Sony Playstation\_Default\ folders
    Loop, %CurrentPath%%systemName%\_Default\*.*, 2
        {
        folderName := A_LoopFileName
        Loop % A_LoopFileLongPath . "\*.*"
            {
            If A_LoopFileExt in  %Supported_Images%
                {
                Log("Loading " SubMenuName " image folder: " folderName,5)
                If ! Instr(%SubMenuName%List, "|" . folderName . "|") {
                    FileCount++
                    %SubMenuName%List .= folderName . "|"
                }
                %SubMenuName%FileExtension%FileCount% = folder
                Log("Loading " SubMenuName " image inside folder: " A_LoopFileLongPath,5)
                %SubMenuName%File%FileCount%File%a_index% = %A_LoopFileLongPath% 
                TotalSubMenu%SubMenuName%Pages%FileCount%++
                TotalSubMenu%SubMenuName%Pages%FileCount% += 0 
            }
        }
    }
    ; Loop HyperLaunch\Media\Sony Playstation\_Default\*.png files
    Loop, %CurrentPath%%systemName%\_Default\*.*, 0
        {
        If A_LoopFileExt in %Supported_Extensions%
            {
            If A_LoopFileExt in %7zFormatsNoP%
                {
                IfExist, % 7zPath
                    {
                    Log("Loading " SubMenuName " 7z file: " A_LoopFileFullPath,5)    
                    CurrentExtension := A_LoopFileExt
                    CurrentFile :=  A_LoopFileFullPath
                    CurrentFileName := A_LoopFileName
                    TempCompressedListofFiles := StdoutToVar_CreateProcess(7zPath . " l """ . CurrentFile . """")
                    Loop, parse, Supported_Images,`,,
                        {
                        If TempCompressedListofFiles contains %A_LoopField%
                            {  
                            Log("Loading " SubMenuName " image inside 7z file: " CurrentFileName,5)
                            FileCount++
                            SplitPath, CurrentFile, ,,,FileNameWithoutExtension
                            %SubMenuName%List .= FileNameWithoutExtension . "|"
                            %SubMenuName%File%FileCount% = %CurrentFile%
                            %SubMenuName%FileExtension%FileCount% = %CurrentExtension% 
                            %SubMenuName%CompressedFile%FileCount%Loaded = false                          
                            break
                        }
                    }
                } 
            } Else If (A_LoopFileExt="pdf"){
                Log("Loading " SubMenuName " pdf file: " A_LoopFileFullPath,5)
                FileCount++ 
                SplitPath, A_LoopFileFullPath, ,,,FileNameWithoutExtension
                %SubMenuName%List .= FileNameWithoutExtension . "|"
                %SubMenuName%File%FileCount% = %A_LoopFileFullPath%
                %SubMenuName%FileExtension%FileCount% = %A_LoopFileExt%                 
            } Else {
                Log("Loading " SubMenuName " file: " A_LoopFileFullPath,5)
                FileCount++ 
                SplitPath, A_LoopFileFullPath, ,,,FileNameWithoutExtension
                %SubMenuName%List .= FileNameWithoutExtension . "|"
                %SubMenuName%File%FileCount% = %A_LoopFileFullPath%
                %SubMenuName%FileExtension%FileCount% = %A_LoopFileExt%
            }
        }
    }
    ;loading hyperspin\media\system\artwork files If Artwork menu
    If(SubMenuName="Artwork"){ 
        Loop, 4
            {
            currentDirNumber := a_index
            Loop, parse, Supported_Images,`,,
                {
                IfExist, % MediaImagePath . "artwork" . currentDirNumber  . "\" . dbName . "." . A_LoopField
                    {
                    Log("Loading HyperSpin " SubMenuName ": " MediaImagePath . "artwork" . currentDirNumber  . "\" . dbName . "." . A_LoopField,5)
                    FileCount++    
                    %SubMenuName%List := % %SubMenuName%List HyperPause_Artwork_%currentDirNumber%_Label . "|"
                    %SubMenuName%File%FileCount% := MediaImagePath . "artwork" . currentDirNumber  . "\" . dbName . "." . A_LoopField
                    %SubMenuName%FileExtension%FileCount% = %A_LoopField% 
                }   
            }
        }
    }
    StringTrimRight, %SubMenuName%List, %SubMenuName%List, 1 
    StringTrimLeft, %SubMenuName%List, %SubMenuName%List, 1
    TotalSubMenuItems%SubMenuName% := FileCount ;counting total sub menu items
    Loop, % TotalSubMenuItems%SubMenuName%
        {
        count2 := A_index
        If(%SubMenuName%FileExtension%a_index%="pdf"){
            CurrentFile := % %SubMenuName%File%A_Index%
            Log("Processing " SubMenuName " number of pages: " CurrentFile,5)
            TotalSubMenu%SubMenuName%Pages%count2% := COM_Invoke(HLObject, "getPdfPageCount", CurrentFile)
            TotalSubMenu%SubMenuName%Pages%count2% += 0     
        }
    }
    If(HyperPause_LoadPDFandCompressedFilesatStart = "true"){ ;loading pdf and 7z files at startup
        Log("Processing " SubMenuName " pdf and 7z files at startup",5)
        Loop, % TotalSubMenuItems%SubMenuName%
            {
            CurrentLabelNumber := A_index
            TempPath := % HyperPause_%SubMenuName%TempPath
            CurrentFile := % %SubMenuName%File%CurrentLabelNumber%
            If(%SubMenuName%FileExtension%CurrentLabelNumber%="pdf"){
                Log("Processing " SubMenuName " pdf png creation: " CurrentFile,5)
                outputFolder := % TempPath . SubMenuName . "File" . CurrentLabelNumber
                IfNotExist, % TempPath . SubMenuName . "File" . CurrentLabelNumber . "\" 
                    FileCreateDir, % TempPath . SubMenuName . "File" . CurrentLabelNumber . "\" 
                COM_Invoke(HLObject, "generatePngFromPdf", CurrentFile, outputFolder, HyperPause_SubMenu_PdfDpiResolution)
            }
            If %SubMenuName%FileExtension%CurrentLabelNumber% in %7zFormatsNoP%
                {
                Log("Processing " SubMenuName " 7z file: " CurrentFile,5)
                HyperPause_7zExtractDir := TempPath . SubMenuName . "File" . CurrentLabelNumber . "\" 
                RunWait, %7zPath% e "%CurrentFile%" -aoa -o"%HyperPause_7zExtractDir%",,Hide ; perform the extraction and overwrite all
                Loop, %HyperPause_7zExtractDir%\*.*, 0
                    If A_LoopFileExt in  %Supported_Images%
                    {
                    Log("Processing " SubMenuName " image inside 7z file: " A_LoopFileLongPath,5)
                    %SubMenuName%File%CurrentLabelNumber%File%a_index% = %A_LoopFileLongPath% 
                    %SubMenuName%CompressedFile%CurrentLabelNumber%Loaded = true                      
                    TotalSubMenu%SubMenuName%Pages%CurrentLabelNumber%++  
                    TotalSubMenu%SubMenuName%Pages%CurrentLabelNumber% += 0
                }
            }  
        }
    }
    VMargin := % HyperPause_%SubMenuName%_VMargin ;Counting total number of pages in txt files
    LinesperPage%SubMenuName% := round((HyperPause_SubMenu_Height-VMargin)/(1.5*HyperPause_SubMenu_SmallFontSize)) ;Number of Lines per page
    LinesperFullScreenPage%SubMenuName% := round((A_ScreenHeight - HyperPause_SubMenu_FullScreenMargin - 5*HyperPause_SubMenu_FullScreenFontSize)/(1.5*HyperPause_SubMenu_SmallFontSize)) ;Number of lines in Full Screen    
    Loop, % TotalSubMenuItems%SubMenuName%
        {
        count2 := A_index
        If(%SubMenuName%FileExtension%a_index%="txt"){
            Log("Loading " SubMenuName " : Parsing txt files",5)
            count3:=1
            count4:=1
            FileRead, %SubMenuName%FileTxtContents%a_index%, % %SubMenuName%File%a_index% 
            FileTxtWidth%count2% := MeasureText(0,%SubMenuName%FileTxtContents%a_index%,HyperPause_SubMenu_Font,HyperPause_SubMenu_SmallFontSize,"Regular")
            stringreplace, CurrentTextContents, %SubMenuName%FileTxtContents%a_index%, `r`n,ø,all
            Loop, parse, CurrentTextContents, ø
                {
                FirstLine := (count3-1)*LinesperPage%SubMenuName%
                LastLine := FirstLine + LinesperPage%SubMenuName%
                FullScreenFirstLine := % (count4-1) * LinesperFullScreenPage%SubMenuName%
                FullScreenLastLine := % FullScreenFirstLine + LinesperFullScreenPage%SubMenuName% 
                %SubMenuName%FileTxtContents%count2%Page%count3% := % %SubMenuName%FileTxtContents%count2%Page%count3% A_LoopField "`r`n"
                If(A_index >= FirstLine){
                    If(A_index > LastLine){
                    count3++
                    }
                }
                %SubMenuName%FileTxtContents%count2%FullScreenPage%count4% := % %SubMenuName%FileTxtContents%count2%FullScreenPage%count4% A_LoopField "`r`n"
                If(A_index >= FullScreenFirstLine){
                    If(A_index > FullScreenLastLine){
                        count4++
                    }
                }
            }
            TotalV2SubMenuItems%SubMenuName%%count2% := % count3
            TotalFullScreenV2SubMenuItems%SubMenuName%%count2% := % count4
            }
    }
    %SubMenuName%MaxFontListWidth = %HyperPause_SubMenu_MinimumTextBoxWidth% ;determining max text size of submenulabels
    Loop, parse, %SubMenuName%List,|, 
        {
        FontListWidth := MeasureText(0,A_LoopField,HyperPause_SubMenu_LabelFont,HyperPause_SubMenu_LabelFontSize,"bold")+HyperPause_SubMenu_AdditionalTextMarginContour
        If(FontListWidth>%SubMenuName%MaxFontListWidth){
            %SubMenuName%MaxFontListWidth := FontListWidth
        }    
    }        
    If (SubMenuName="Controller") {
        If (FileCount=0) 
            If !((keymapperEnabled = "true") and (JoyIDsEnabled = "true"))
                StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, %SubMenuName%|,
    } Else If (FileCount=0){ ;excluding submenu If no files are found 
        StringReplace, HyperPause_MainMenu_Labels, HyperPause_MainMenu_Labels, %SubMenuName%|,
    }
 Return   
}

      
      
TextImagesAndPDFMenu(SubMenuName)
{
    Global
    FunctionRunning := true ;error check function running (necessary to avoid exiting hyperpause in the middle of function running)
    CurrentLabelNumber := VSubMenuItem ;initializing variables
    If(VSubMenuItem < 1){
        CurrentLabelNumber := 1
    }
    CurrentFilePath := % %SubMenuName%File%CurrentLabelNumber%
    CurrentFileExtension := % %SubMenuName%FileExtension%CurrentLabelNumber%
    If not((SelectedMenuOption="Videos") or (VSubMenuItem=-1)){
        HSubMenuItem := % HSubmenuitem%SubMenuName%VSubmenuitem%VSubmenuitem%
        V2Submenuitem := % HSubmenuitem%SubMenuName%V2Submenuitem%VSubmenuitem%
    }
    CurrentList := % %SubMenuName%List
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
    MaxFontListWidth := % %SubMenuName%MaxFontListWidth
    posPageX := HMargin+MaxFontListWidth+HdistBetwLabelsandPages
    posPageY := VMargin
    Loop, parse, CurrentList,|, 
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
            Options1 = x%posSubMenuX1% y%posSubMenuY1% Center c%color% r4 s%HyperPause_SubMenu_LabelFontSize% bold
            Gdip_FillRoundedRectangle(HP_G27, Optionbrush, round(posSubMenuX1-MaxFontListWidth/2), posSubMenuY1-HyperPause_SubMenu_AdditionalTextMarginContour, MaxFontListWidth, HyperPause_SubMenu_FontSize+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_RadiusofRoundedCorners)
            Gdip_TextToGraphics(HP_G27, A_LoopField, Options1, HyperPause_SubMenu_LabelFont, 0, 0)
            posSubMenuY1 := posSubMenuY1+VdistBetwLabels
            color := HyperPause_MainMenu_LabelDisabledColor
            Optionbrush := HyperPause_SubMenu_DisabledBrushV
        }
    }
    ;If video file:  
    If CurrentFileExtension in %ListofSupportedVideos%    
        {
        If(FullScreenView <> 1){
            If (AnteriorFilePath <> CurrentFilePath) {
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
                If(VideoW>HyperPause_SubMenu_Width-3*HyperPause_Videos_HMargin+VideosMaxFontListWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour + HyperPause_SubMenu_SpaceBetweenLabelsandVideoButtons+HyperPause_SubMenu_SizeofVideoButtons){
                    VideoW := HyperPause_SubMenu_Width-3*HyperPause_Videos_HMargin+VideosMaxFontListWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour + HyperPause_SubMenu_SpaceBetweenLabelsandVideoButtons+HyperPause_SubMenu_SizeofVideoButtons
                    VideoH := round(9*VideoW/16)
                }
                VideoX := A_ScreenWidth-HyperPause_SubMenu_Width+HyperPause_Videos_HMargin+%SubMenuName%MaxFontListWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour +HyperPause_SubMenu_SpaceBetweenLabelsandVideoButtons+HyperPause_SubMenu_SizeofVideoButtons+((HyperPause_SubMenu_Width-(HyperPause_Videos_HMargin+%SubMenuName%MaxFontListWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour +HyperPause_SubMenu_SpaceBetweenLabelsandVideoButtons+HyperPause_SubMenu_SizeofVideoButtons))-VideoW)//2
                VideoY := A_ScreenHeight-HyperPause_SubMenu_Height+VMargin + round((HyperPause_SubMenu_Height-2*HyperPause_Videos_VMargin-VideoH)/2)
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
                    If(VideoW > HyperPause_SubMenu_Width-3*HyperPause_Videos_HMargin-VideosMaxFontListWidth-2*HyperPause_SubMenu_AdditionalTextMarginContour){
                        VideoW := HyperPause_SubMenu_Width-3*HyperPause_Videos_HMargin-VideosMaxFontListWidth-2*HyperPause_SubMenu_AdditionalTextMarginContour
                        VideoH := round(VideoRealH/(VideoRealW/VideoW)) 
                    }
                    VideoX := A_ScreenWidth-HyperPause_SubMenu_Width+HyperPause_Videos_HMargin+%SubMenuName%MaxFontListWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour +HyperPause_SubMenu_SpaceBetweenLabelsandVideoButtons+HyperPause_SubMenu_SizeofVideoButtons+((HyperPause_SubMenu_Width-(HyperPause_Videos_HMargin+%SubMenuName%MaxFontListWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour +HyperPause_SubMenu_SpaceBetweenLabelsandVideoButtons+HyperPause_SubMenu_SizeofVideoButtons))-VideoW)//2
                    VideoY :=  A_ScreenHeight-HyperPause_SubMenu_Height+VMargin + round((HyperPause_SubMenu_Height-2*HyperPause_Videos_VMargin-VideoH)/2)
                }
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
            If(VSubmenuitem<>0) {
                posVideoButtonsX := HyperPause_Videos_HMargin+VideosMaxFontListWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour + HyperPause_SubMenu_SpaceBetweenLabelsandVideoButtons
                Loop, 5
                    {
                    posVideoButton%a_index%Y := HyperPause_Videos_VMargin + (a_index-1)*(HyperPause_SubMenu_SizeofVideoButtons + HyperPause_SubMenu_SpaceBetweenVideoButtons)
                    try CurrentVideoPlayStatus := wmpVideo.playState
                    If (a_index=1) and (CurrentVideoPlayStatus=3)
                        HyperPauseVideoBitmap%a_index% := Gdip_CreateBitmapFromFile(HyperPauseVideoImage6)
                    Else
                        HyperPauseVideoBitmap%a_index% := Gdip_CreateBitmapFromFile(HyperPauseVideoImage%a_index%)
                    Gdip_DrawImage(HP_G27,HyperPauseVideoBitmap%a_index%,posVideoButtonsX,posVideoButton%a_index%Y,HyperPause_SubMenu_SizeofVideoButtons,HyperPause_SubMenu_SizeofVideoButtons)
                    If(HsubMenuItem = 2){
                        If (V2Submenuitem = a_index){
                            If (PreviousVideoButton<>V2Submenuitem){ 
                                GrowSize := 1
                                While GrowSize <= round(15*ScallingFactor) {
                                    Gdip_GraphicsClear(HP_G30)
                                    Gdip_DrawImage(HP_G30,HyperPauseVideoBitmap%V2Submenuitem%,round(15*ScallingFactor-GrowSize*ScallingFactor),round(15*ScallingFactor-GrowSize*ScallingFactor),round(HyperPause_SubMenu_SizeofVideoButtons+2*GrowSize*ScallingFactor),round(HyperPause_SubMenu_SizeofVideoButtons+2*GrowSize*ScallingFactor))
                                    UpdateLayeredWindow(HP_hwnd30, HP_hdc30, round(A_ScreenWidth-HyperPause_SubMenu_Width+posVideoButtonsX-15*ScallingFactor), round(A_ScreenHeight-HyperPause_SubMenu_Height+posVideoButton%V2Submenuitem%Y-15*ScallingFactor), round(HyperPause_SubMenu_SizeofVideoButtons+30*ScallingFactor), round(HyperPause_SubMenu_SizeofVideoButtons+30*ScallingFactor))
                                    GrowSize+= round(HyperPause_VideoButtonGrowingEffectVelocity*ScallingFactor)
                                }
                                Gdip_GraphicsClear(HP_G30)
                                If(GrowSize<>15){
                                    Gdip_DrawImage(HP_G30,HyperPauseVideoBitmap%V2Submenuitem%,0,0,round(HyperPause_SubMenu_SizeofVideoButtons+30*ScallingFactor),round(HyperPause_SubMenu_SizeofVideoButtons+30*ScallingFactor))
                                    UpdateLayeredWindow(HP_hwnd30, HP_hdc30, round(A_ScreenWidth-HyperPause_SubMenu_Width+posVideoButtonsX-15*ScallingFactor), round(A_ScreenHeight-HyperPause_SubMenu_Height+posVideoButton%V2Submenuitem%Y-15*ScallingFactor), round(HyperPause_SubMenu_SizeofVideoButtons+30*ScallingFactor), round(HyperPause_SubMenu_SizeofVideoButtons+30*ScallingFactor))
                                }
                            } Else {
                                Gdip_DrawImage(HP_G30,HyperPauseVideoBitmap%V2Submenuitem%,0,0,round(HyperPause_SubMenu_SizeofVideoButtons+30*ScallingFactor),round(HyperPause_SubMenu_SizeofVideoButtons+30*ScallingFactor))
                                UpdateLayeredWindow(HP_hwnd30, HP_hdc30, round(A_ScreenWidth-HyperPause_SubMenu_Width+posVideoButtonsX-15*ScallingFactor), round(A_ScreenHeight-HyperPause_SubMenu_Height+posVideoButton%V2Submenuitem%Y-15*ScallingFactor), round(HyperPause_SubMenu_SizeofVideoButtons+30*ScallingFactor), round(HyperPause_SubMenu_SizeofVideoButtons+30*ScallingFactor))
                            }
                        }
                    } Else {
                        Gdip_GraphicsClear(HP_G30)
                        UpdateLayeredWindow(HP_hwnd30, HP_hdc30, round(A_ScreenWidth-HyperPause_SubMenu_Width+posVideoButtonsX-15*ScallingFactor), round(A_ScreenHeight-HyperPause_SubMenu_Height+posVideoButton%V2Submenuitem%Y-15*ScallingFactor), round(HyperPause_SubMenu_SizeofVideoButtons+30*ScallingFactor), round(HyperPause_SubMenu_SizeofVideoButtons+30*ScallingFactor))
                    }
                    PreviousVideoButton := V2Submenuitem
                }
            }
        settimer, UpdateVideoPlayingInfo, 100, Period
        }
    }    
    ;If image file:
    If CurrentFileExtension in %Supported_Images%
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
            Gdip_FillRoundedRectangle(HP_G27, HyperPause_SubMenu_DisabledBrushV, round((HyperPause_SubMenu_Width-resizedBitmapW+MaxFontListWidth+HMargin)/2-HyperPause_SubMenu_AdditionalTextMarginContour), round((HyperPause_SubMenu_Height-resizedBitmapH)/2-HyperPause_SubMenu_AdditionalTextMarginContour), resizedBitmapW+2*HyperPause_SubMenu_AdditionalTextMarginContour, resizedBitmapH+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_RadiusofRoundedCorners)
            Gdip_DrawImage(HP_G27, SelectedBitmap, round((HyperPause_SubMenu_Width+MaxFontListWidth+HMargin-resizedBitmapW)/2), round((HyperPause_SubMenu_Height-resizedBitmapH)/2), resizedBitmapW, resizedBitmapH)
        }
    }
    ;If txt file:
    If(CurrentFileExtension = "txt"){
        If(FullScreenView <> 1){
            TotaltxtPages := % TotalV2SubMenuItems%SubMenuName%%CurrentLabelNumber%
        } Else {
            TotaltxtPages := % TotalFullScreenV2SubMenuItems%SubMenuName%%CurrentLabelNumber%
        }
        If (HSubmenuitem%SubMenuName%V2Submenuitem%VSubmenuitem% > TotaltxtPages) {
            HSubmenuitem%SubMenuName%V2Submenuitem%VSubmenuitem% = % TotaltxtPages
            V2Submenuitem := % HSubmenuitem%SubMenuName%V2Submenuitem%VSubmenuitem%
        }
        TotalCurrentPages=2
        TextWidth := % FileTxtWidth%CurrentLabelNumber%
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
            Gdip_TextToGraphics(HP_G27, %SubMenuName%FileTxtContents%CurrentLabelNumber%Page%V2SubMenuItem%, OptionsText2, HyperPause_SubMenu_Font, Width, Height)
            Gdip_GraphicsClear(HP_G29)
            UpdateLayeredWindow(HP_hwnd29, HP_hdc29,A_ScreenWidth - HelpTextLenghtWidth - 2*HyperPause_SubMenu_AdditionalTextMarginContour,A_ScreenHeight- HyperPause_SubMenu_SmallFontSize,HelpTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_HelpFontSize)
        }
    }
    ;If pdf file:
    If(CurrentFileExtension = "pdf"){
        If(HSubMenuItem=0){
            HSubmenuitem%SubMenuName%VSubmenuitem%VSubmenuitem% := 1
            HSubMenuItem := % HSubmenuitem%SubMenuName%VSubmenuitem%VSubmenuitem%
        }
        TotalCurrentPages := % TotalSubMenu%SubMenuName%Pages%CurrentLabelNumber%  
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
                    IfNotExist, % TempPath . SubMenuName . "File" . CurrentLabelNumber . "\" 
                        FileCreateDir, % TempPath . SubMenuName . "File" . CurrentLabelNumber . "\" 
                    IfNotExist, % TempPath . SubMenuName . "File" . CurrentLabelNumber . "\" . "page" . A_Index . ".png"
                        {
                        SubMenuHelpText("Please wait while pdf pages are loaded")
                        UpdateLayeredWindow(HP_hwnd27, HP_hdc27,A_ScreenWidth-HyperPause_SubMenu_Width,A_ScreenHeight-HyperPause_SubMenu_Height, HyperPause_SubMenu_Width, HyperPause_SubMenu_Height)
                        Log("Loaded PDF page " A_Index " and update " SelectedMenuOption " SubMenu.",5)
                        COM_Invoke(HLObject, "generatePngFromPdf", CurrentFilePath, TempPath . SubMenuName . "File" . CurrentLabelNumber, HyperPause_SubMenu_PdfDpiResolution,a_index,a_index)
                    }  
                }
                CurrentImage%a_index% := TempPath . SubMenuName . "File" . CurrentLabelNumber . "\" . "page" . A_Index . ".png"
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
                    Gdip_FillRoundedRectangle(HP_G27, HyperPause_SubMenu_%SubMenuName%SelectedBrushV, posPageX, round((HyperPause_SubMenu_Height-resizedBitmapH)/2-HyperPause_SubMenu_AdditionalTextMarginContour), resizedBitmapW+2*HyperPause_SubMenu_AdditionalTextMarginContour, resizedBitmapH+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_RadiusofRoundedCorners)
                }
                Gdip_DrawImage(HP_G27, CurrentBitmap, posPageX+HyperPause_SubMenu_AdditionalTextMarginContour, round((HyperPause_SubMenu_Height-resizedBitmapH)/2), resizedBitmapW, resizedBitmapH)
                posPageTextX := posPageX+round((resizedBitmapW+2*HyperPause_SubMenu_AdditionalTextMarginContour)/2)
                posPageTextY := HyperPause_SubMenu_Height-VMargin-HyperPause_SubMenu_AdditionalTextMarginContour-2*HyperPause_SubMenu_SmallFontSize
                OptionsPage1 = x%posPageTextX% y%posPageTextY% Center c%PageNumberFontColor% r4 s%HyperPause_SubMenu_SmallFontSize% bold
                Gdip_TextToGraphics(HP_G27, "Page " . a_index, OptionsPage1, HyperPause_SubMenu_Font, 0, 0)
                If(VSubMenuItem = 0){
                    Gdip_FillRoundedRectangle(HP_G27, HyperPause_SubMenu_DisabledBrushV, posPageX, round((HyperPause_SubMenu_Height-resizedBitmapH)/2-HyperPause_SubMenu_AdditionalTextMarginContour), resizedBitmapW+2*HyperPause_SubMenu_AdditionalTextMarginContour, resizedBitmapH+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_RadiusofRoundedCorners)
                }
                If((VSubMenuItem <> 0) and (HSubMenuItem <> a_index)){
                    Gdip_FillRoundedRectangle(HP_G27, HyperPause_SubMenu_DisabledBrushV, posPageX, round((HyperPause_SubMenu_Height-resizedBitmapH)/2-HyperPause_SubMenu_AdditionalTextMarginContour), resizedBitmapW+2*HyperPause_SubMenu_AdditionalTextMarginContour, resizedBitmapH+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_RadiusofRoundedCorners)
                }
                posPageX := posPageX+resizedBitmapW+2*HyperPause_SubMenu_AdditionalTextMarginContour+HdistBetwPages                
            }
        }  
    }
    ;If Compressed file
    If CurrentFileExtension in %7zFormatsNoP%
    {
        CurrentCompressedFileExtension = true
        CurrentPath := % TempPath . SubMenuName . "File" . CurrentLabelNumber . "\" 
        CurrentFile := % %SubMenuName%File%CurrentLabelNumber%
        If(%SubMenuName%CompressedFile%CurrentLabelNumber%Loaded <> "true"){
            %SubMenuName%CompressedFile%CurrentLabelNumber%Loaded = true
            SubMenuHelpText("Please wait while compressed images are loaded")
            If %SubMenuName%FileExtension%CurrentLabelNumber% in %7zFormatsNoP%
                {
                RunWait, %7zPath% e "%CurrentFile%" -aoa -o"%CurrentPath%",,Hide ; perform the extraction and overwrite all
                Loop, %CurrentPath%\*.*, 0
                    If A_LoopFileExt in  %Supported_Images%
                    {
                    %SubMenuName%File%CurrentLabelNumber%File%a_index% = %A_LoopFileLongPath%                
                    TotalSubMenu%SubMenuName%Pages%CurrentLabelNumber%++  
                    TotalSubMenu%SubMenuName%Pages%CurrentLabelNumber% += 0
                }
            }
        }
    } Else {
        CurrentCompressedFileExtension = false
    }
    ;If image folder or compressed images:
    If((CurrentFileExtension = "folder") or (CurrentCompressedFileExtension="true")){
        If(HSubMenuItem=0){
            HSubmenuitem%SubMenuName%VSubmenuitem%VSubmenuitem% := 1
            HSubMenuItem := % HSubmenuitem%SubMenuName%VSubmenuitem%VSubmenuitem%
        }
        TotalCurrentPages := % TotalSubMenu%SubMenuName%Pages%CurrentLabelNumber%  
        Loop, %TotalCurrentPages%
        {
            If(A_index >= HSubMenuItem){
                If(posPageX > HyperPause_SubMenu_Width){
                    break   
                }
                CurrentImage%a_index% := % %SubMenuName%File%CurrentLabelNumber%File%a_index%
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
                    Gdip_FillRoundedRectangle(HP_G27, HyperPause_SubMenu_%SubMenuName%SelectedBrushV, posPageX, round((HyperPause_SubMenu_Height-resizedBitmapH)/2-HyperPause_SubMenu_AdditionalTextMarginContour), resizedBitmapW+2*HyperPause_SubMenu_AdditionalTextMarginContour, resizedBitmapH+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_RadiusofRoundedCorners)
                }
                Gdip_DrawImage(HP_G27, CurrentBitmap, posPageX+HyperPause_SubMenu_AdditionalTextMarginContour, round((HyperPause_SubMenu_Height-resizedBitmapH)/2), resizedBitmapW, resizedBitmapH)
                SplitPath, CurrentImage%a_index%, , , , FileNameText
                posPageTextX := posPageX+HyperPause_SubMenu_AdditionalTextMarginContour
                posPageTextY := HyperPause_SubMenu_Height-VMargin-HyperPause_SubMenu_AdditionalTextMarginContour-1.3*HyperPause_SubMenu_SmallFontSize-HyperPause_SubMenu_SmallFontSize*(ceil(MeasureText(0,FileNameText,HyperPause_SubMenu_Font,HyperPause_SubMenu_SmallFontSize,"bold")/resizedBitmapW))
                OptionsPage1 = x%posPageTextX% y%posPageTextY% w%resizedBitmapW% Center c%PageNumberFontColor% r4 s%HyperPause_SubMenu_SmallFontSize% bold
                Gdip_TextToGraphics(HP_G27, FileNameText, OptionsPage1, HyperPause_SubMenu_Font, 0, 0)
                If(VSubMenuItem = 0){
                    Gdip_FillRoundedRectangle(HP_G27, HyperPause_SubMenu_DisabledBrushV, posPageX, round((HyperPause_SubMenu_Height-resizedBitmapH)/2-HyperPause_SubMenu_AdditionalTextMarginContour), resizedBitmapW+2*HyperPause_SubMenu_AdditionalTextMarginContour, resizedBitmapH+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_RadiusofRoundedCorners)
                }
                If((VSubMenuItem <> 0) and (HSubMenuItem <> a_index)){
                    Gdip_FillRoundedRectangle(HP_G27, HyperPause_SubMenu_DisabledBrushV, posPageX, round((HyperPause_SubMenu_Height-resizedBitmapH)/2-HyperPause_SubMenu_AdditionalTextMarginContour), resizedBitmapW+2*HyperPause_SubMenu_AdditionalTextMarginContour, resizedBitmapH+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_RadiusofRoundedCorners)
                }
                posPageX := posPageX+resizedBitmapW+2*HyperPause_SubMenu_AdditionalTextMarginContour+HdistBetwPages                
            }
        }  
    } 
    ;full screen view
    If(VSubMenuItem>=0){
    If(FullScreenView = 1){
        Gdip_GraphicsClear(HP_G29)
        If CurrentFileExtension in %ListofSupportedVideos%    
            {       
        } Else If(CurrentFileExtension = "txt"){
            If(HSubMenuItem=2){
            Width := A_ScreenWidth - 4*HyperPause_SubMenu_FullScreenMargin
            Height := A_ScreenHeight - 4*HyperPause_SubMenu_FullScreenMargin
            posTextFullScreenX := 2*HyperPause_SubMenu_FullScreenMargin 
            posTextFullScreenY := 2*HyperPause_SubMenu_FullScreenMargin
            If(TextWidth<Width){
                posTextFullScreenX := round(2*HyperPause_SubMenu_FullScreenMargin + (Width-TextWidth)/2)
            }           
            colorText := HyperPause_MainMenu_LabelSelectedColor
            Gdip_FillRoundedRectangle(HP_G29, HyperPause_SubMenu_FullScreenTextBrushV, posTextFullScreenX-HyperPause_SubMenu_FullScreenMargin, HyperPause_SubMenu_FullScreenMargin, TextWidth+2*HyperPause_SubMenu_FullScreenMargin, Height+2*HyperPause_SubMenu_FullScreenMargin, HyperPause_SubMenu_FullScreenRadiusofRoundedCorners)
            OptionsTextFullScreen = x%posTextFullScreenX% y%posTextFullScreenY% Left c%colorText% r4 s%HyperPause_SubMenu_SmallFontSize% Regular
            textFullScreen := %SubMenuName%FileTxtContents%CurrentLabelNumber%FullScreenPage%V2SubMenuItem%
            Gdip_TextToGraphics(HP_G29, %SubMenuName%FileTxtContents%CurrentLabelNumber%FullScreenPage%V2SubMenuItem%, OptionsTextFullScreen, HyperPause_SubMenu_Font, Width, Height)
            If HyperPause_SubMenu_FullSCreenHelpTextTimer
                { 
                HyperPause_SubMenu_FullScreenHelpBoxHeight := 5*HyperPause_SubMenu_FullScreenFontSize
                HyperPause_SubMenu_FullScreenHelpBoxWidth := MeasureText(0,"Press Up for Page Up or Press Down for Page Down",HyperPause_SubMenu_Font,HyperPause_SubMenu_FullScreenFontSize,"bold")+HyperPause_SubMenu_AdditionalTextMarginContour
                Gdip_FillRoundedRectangle(HP_G29, HyperPause_SubMenu_FullScreenBrushV, round((A_ScreenWidth-HyperPause_SubMenu_FullScreenHelpBoxWidth)/2-HyperPause_SubMenu_FullScreenMargin), A_ScreenHeight-2*HyperPause_SubMenu_FullScreenMargin-6*HyperPause_SubMenu_FullScreenFontSize, HyperPause_SubMenu_FullScreenHelpBoxWidth,HyperPause_SubMenu_FullScreenHelpBoxHeight,HyperPause_SubMenu_FullScreenRadiusofRoundedCorners)
                posFullScreenTextX := round(A_ScreenWidth/2-HyperPause_SubMenu_FullScreenMargin)
                posFullScreenTextY := round(A_ScreenHeight-2*HyperPause_SubMenu_FullScreenMargin-5*HyperPause_SubMenu_FullScreenFontSize-HyperPause_SubMenu_FullScreenFontSize/2)
                OptionsFullScreenText = x%posFullScreenTextX% y%posFullScreenTextY% Center c%HyperPause_SubMenu_FullScreenFontColor% r4 s%HyperPause_SubMenu_FullScreenFontSize% bold
                CurrentHelpText = Press Select Key to Exit Full Screen`nPress Up for Page Up or Press Down for Page Down`nPage %V2SubMenuItem% of %TotaltxtPages%
                Gdip_TextToGraphics(HP_G29, CurrentHelpText, OptionsFullScreenText, HyperPause_SubMenu_Font, 0, 0)
                if !(HyperPause_SubMenu_FullSCreenHelpTextTimer="always"){
                    savedHSubMenuItem := HSubMenuItem
                    savedVSubMenuItem := VSubMenuItem
                    savedV2SubMenuItem := V2SubMenuItem
                    SetTimer, ClearFullScreenHelpText1, -%HyperPause_SubMenu_FullSCreenHelpTextTimer% 
                }
            }
            UpdateLayeredWindow(HP_hwnd29, HP_hdc29,HyperPause_SubMenu_FullScreenMargin,HyperPause_SubMenu_FullScreenMargin,A_ScreenWidth-2*HyperPause_SubMenu_FullScreenMargin,A_ScreenHeight-2*HyperPause_SubMenu_FullScreenMargin) 
            } Else {
                    FullScreenView = 0
            }
        } Else {
            Gdip_DisposeImage(SelectedBitmap)
            SelectedBitmap := Gdip_CreateBitmapFromFile(SelectedImage)
            BitmapW := Gdip_GetImageWidth(SelectedBitmap), BitmapH := Gdip_GetImageHeight(SelectedBitmap) 
            resizedBitmapH := A_ScreenHeight - 2*HyperPause_SubMenu_FullScreenMargin
            resizedBitmapW := round(BitmapW/(BitmapH/resizedBitmapH))
            If(resizedBitmapW > A_ScreenWidth - 2*HyperPause_SubMenu_FullScreenMargin){
                resizedBitmapW := A_ScreenWidth - 2*HyperPause_SubMenu_FullScreenMargin
                resizedBitmapH := round(BitmapH/(BitmapW/resizedBitmapW))
            }
            Gdip_DrawImage(HP_G29, SelectedBitmap, round((A_ScreenWidth-resizedBitmapW)/2-HyperPause_SubMenu_FullScreenMargin+HorizontalPanFullScreen+(resizedBitmapW-resizedBitmapW*ZoomLevel/100)/2), round((A_ScreenHeight-resizedBitmapH)/2-HyperPause_SubMenu_FullScreenMargin+VerticalPanFullScreen+(resizedBitmapH-resizedBitmapH*ZoomLevel/100)/2), round(resizedBitmapW*ZoomLevel/100), round(resizedBitmapH*ZoomLevel/100))
            If HyperPause_SubMenu_FullSCreenHelpTextTimer
                {
                HyperPause_SubMenu_FullScreenHelpBoxHeight := 7*HyperPause_SubMenu_FullScreenFontSize
                HyperPause_SubMenu_FullScreenHelpBoxWidth := MeasureText(0,"(Press Zoom In or Zoom Out Keys to Change Zoom Level)",HyperPause_SubMenu_Font,HyperPause_SubMenu_FullScreenFontSize,"bold")+HyperPause_SubMenu_AdditionalTextMarginContour
                Gdip_FillRoundedRectangle(HP_G29, HyperPause_SubMenu_FullScreenBrushV, round((A_ScreenWidth-HyperPause_SubMenu_FullScreenHelpBoxWidth)/2-HyperPause_SubMenu_FullScreenMargin), A_ScreenHeight-2*HyperPause_SubMenu_FullScreenMargin-8*HyperPause_SubMenu_FullScreenFontSize, HyperPause_SubMenu_FullScreenHelpBoxWidth,HyperPause_SubMenu_FullScreenHelpBoxHeight,HyperPause_SubMenu_FullScreenRadiusofRoundedCorners)
                posFullScreenTextX := round(A_ScreenWidth/2-HyperPause_SubMenu_FullScreenMargin)
                posFullScreenTextY := round(A_ScreenHeight-2*HyperPause_SubMenu_FullScreenMargin-7*HyperPause_SubMenu_FullScreenFontSize-HyperPause_SubMenu_FullScreenFontSize/2)
                OptionsFullScreenText = x%posFullScreenTextX% y%posFullScreenTextY% Center c%HyperPause_SubMenu_FullScreenFontColor% r4 s%HyperPause_SubMenu_FullScreenFontSize% bold
                Gdip_TextToGraphics(HP_G29, "Press Select Key to Exit Full Screen`nPress Left or Right to Change Pages while 100% Zoom`nZoom Level: " . ZoomLevel . "%`n(Press Zoom In or Zoom Out Keys to Change Zoom Level)`n(Press Up, Down Left or Right to Pan in Zoom Mode)", OptionsFullScreenText, HyperPause_SubMenu_Font, 0, 0)
                SplitPath, SelectedImage, , , , FileNameText
                posPageTextX := (A_ScreenWidth-2*HyperPause_SubMenu_FullScreenMargin) //2
                posPageTextY := HyperPause_SubMenu_FullScreenMargin > round((A_ScreenHeight-resizedBitmapH)/2-HyperPause_SubMenu_FullScreenMargin+VerticalPanFullScreen+(resizedBitmapH-resizedBitmapH*ZoomLevel/100)/2)+HyperPause_SubMenu_SmallFontSize//2 ? HyperPause_SubMenu_FullScreenMargin : round((A_ScreenHeight-resizedBitmapH)/2-HyperPause_SubMenu_FullScreenMargin+VerticalPanFullScreen+(resizedBitmapH-resizedBitmapH*ZoomLevel/100)/2)+HyperPause_SubMenu_SmallFontSize//2
                OptionsPage1 = x%posPageTextX% y%posPageTextY% Center c%HyperPause_SubMenu_FullScreenFontColor% r4 s%HyperPause_SubMenu_SmallFontSize% bold
                Gdip_FillRectangle(HP_G29, HyperPause_SubMenu_FullScreenBrushV, posPageTextX-(round( MeasureText(0,FileNameText,HyperPause_SubMenu_Font,HyperPause_SubMenu_SmallFontSize,"bold")+HyperPause_SubMenu_AdditionalTextMarginContour))//2, posPageTextY-HyperPause_SubMenu_SmallFontSize//2, round( MeasureText(0,FileNameText,HyperPause_SubMenu_Font,HyperPause_SubMenu_SmallFontSize,"bold")+HyperPause_SubMenu_AdditionalTextMarginContour), HyperPause_SubMenu_SmallFontSize+HyperPause_SubMenu_AdditionalTextMarginContour)
                Gdip_TextToGraphics(HP_G29, FileNameText, OptionsPage1, HyperPause_SubMenu_Font, 0, 0)
                if !(HyperPause_SubMenu_FullSCreenHelpTextTimer="always"){
                    savedHSubMenuItem := HSubMenuItem
                    savedVSubMenuItem := VSubMenuItem
                    savedV2SubMenuItem := V2SubMenuItem
                    SetTimer, ClearFullScreenHelpText2, -%HyperPause_SubMenu_FullSCreenHelpTextTimer% 
                }
            }
            UpdateLayeredWindow(HP_hwnd29, HP_hdc29,HyperPause_SubMenu_FullScreenMargin,HyperPause_SubMenu_FullScreenMargin,A_ScreenWidth-2*HyperPause_SubMenu_FullScreenMargin,A_ScreenHeight-2*HyperPause_SubMenu_FullScreenMargin)
        }
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
        UpdateLayeredWindow(HP_hwnd29, HP_hdc29,HyperPause_SubMenu_FullScreenMargin,HyperPause_SubMenu_FullScreenMargin,A_ScreenWidth-2*HyperPause_SubMenu_FullScreenMargin,A_ScreenHeight-2*HyperPause_SubMenu_FullScreenMargin)
        FullScreenView = 0
    }
    }
   FunctionRunning := false
Return    
}

ClearFullScreenHelpText1:
    if (savedHSubMenuItem=HSubMenuItem) and (savedVSubMenuItem=VSubMenuItem) and (savedV2SubMenuItem=V2SubMenuItem) {
        Gdip_GraphicsClear(HP_G29)
        Gdip_FillRoundedRectangle(HP_G29, HyperPause_SubMenu_FullScreenTextBrushV, posTextFullScreenX-HyperPause_SubMenu_FullScreenMargin, HyperPause_SubMenu_FullScreenMargin, TextWidth+2*HyperPause_SubMenu_FullScreenMargin, Height+2*HyperPause_SubMenu_FullScreenMargin, HyperPause_SubMenu_FullScreenRadiusofRoundedCorners)
        Gdip_TextToGraphics(HP_G29, textFullScreen, OptionsTextFullScreen, HyperPause_SubMenu_Font, Width, Height)
        UpdateLayeredWindow(HP_hwnd29, HP_hdc29,HyperPause_SubMenu_FullScreenMargin,HyperPause_SubMenu_FullScreenMargin,A_ScreenWidth-2*HyperPause_SubMenu_FullScreenMargin,A_ScreenHeight-2*HyperPause_SubMenu_FullScreenMargin) 
    }
Return


ClearFullScreenHelpText2:
    if (savedHSubMenuItem=HSubMenuItem) and (savedVSubMenuItem=VSubMenuItem) and (savedV2SubMenuItem=V2SubMenuItem) {
        Gdip_GraphicsClear(HP_G29)
        Gdip_DrawImage(HP_G29, SelectedBitmap, round((A_ScreenWidth-resizedBitmapW)/2-HyperPause_SubMenu_FullScreenMargin+HorizontalPanFullScreen+(resizedBitmapW-resizedBitmapW*ZoomLevel/100)/2), round((A_ScreenHeight-resizedBitmapH)/2-HyperPause_SubMenu_FullScreenMargin+VerticalPanFullScreen+(resizedBitmapH-resizedBitmapH*ZoomLevel/100)/2), round(resizedBitmapW*ZoomLevel/100), round(resizedBitmapH*ZoomLevel/100))
        UpdateLayeredWindow(HP_hwnd29, HP_hdc29,HyperPause_SubMenu_FullScreenMargin,HyperPause_SubMenu_FullScreenMargin,A_ScreenWidth-2*HyperPause_SubMenu_FullScreenMargin,A_ScreenHeight-2*HyperPause_SubMenu_FullScreenMargin)
    }
Return


ReadMovesListInformation() ;Reading Moves List info
{
    Global
    Loop {
        MovesListItem%A_index%  := StrX( RomCommandDatText ,  "$cmd" ,N,4, "$end",1,4,  N )
        If(MovesListItem%A_index%="")
            break
        MovesListLabel%A_index%:=StrX(MovesListItem%A_index%,"[",1,1,"]",1,1)	
        StringReplace, MovesListItem%A_index%, MovesListItem%A_index%, % MovesListLabel%A_index%,, All
        StringReplace, MovesListItem%A_index%, MovesListItem%A_index%, [],, All
        MovesListItem%A_index%:=RegExReplace(MovesListItem%A_index%,"^\s*","") ; remove leading
        MovesListItem%A_index%:=RegExReplace(MovesListItem%A_index%,"\s*$","") ; remove trailing
        StringReplace, MovesListLabel%A_index%, MovesListLabel%A_index%,-,, All
        StringReplace, MovesListLabel%A_index%, MovesListLabel%A_index%, ó,, All
        TotalSubMenuItemsMovesList++
    }
    If (TotalSubMenuItemsMovesList<>0){    ;Loading button images
        Loop, %HyperPause_MovesListImagePath%\Icons\*.png, 0
            { 
            StringTrimRight, FileNameWithoutExtension, A_LoopFileName, 4 
            CommandDatImageFileList .= FileNameWithoutExtension . "`,"
            CommandDatfile%A_index% = %A_LoopFileFullPath%
            CommandDatBitmap%A_index% := Gdip_CreateBitmapFromFile(CommandDatfile%A_index%)
            TotalCommandDatImageFiles++
            }
        VMargin := % HyperPause_%temp_mainmenulabel%_VMargin ;Number of Lines per page
        LinesperPage%temp_mainmenulabel% := floor((HyperPause_SubMenu_Height-VMargin)/HyperPause_MovesList_VdistBetwMovesListLabels)
        LinesperFullScreenPage%temp_mainmenulabel% := floor((A_ScreenHeight - 4*HyperPause_SubMenu_FullScreenMargin  - 5*HyperPause_SubMenu_FullScreenFontSize)/HyperPause_MovesList_VdistBetwMovesListLabels)  ;Number of lines in Full Screen
        Loop, %TotalSubMenuItemsMovesList% ;Total number of pages
            {
            currentLabelNumber := A_index
            stringreplace, TempAuxMovesListItem%currentLabelNumber%, MovesListItem%currentLabelNumber%, `r`n,ø,all
            Loop, parse, TempAuxMovesListItem%currentLabelNumber%, ø
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
        FormatTime, Value_General_Statistics_Statistic_2, gameSectionStartTime, dddd MMMM d, yyyy hh:mm:ss tt
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
    Gdip_GraphicsClear(HP_G29)
    HelpTextLenghtWidth := MeasureText(0,HelpText,HyperPause_SubMenu_HelpFont,HyperPause_SubMenu_HelpFontSize,"Regular")
    posHelpX := round(HelpTextLenghtWidth/2 + HyperPause_SubMenu_AdditionalTextMarginContour)
    OptionsHelp = x%posHelpX% y0 Center c%HyperPause_MainMenu_LabelDisabledColor% r4 s%HyperPause_SubMenu_HelpFontSize% Regular
    Gdip_FillRectangle(HP_G29, HyperPause_SubMenu_DisabledBrushV, 0, 0, HelpTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_HelpFontSize)
    Gdip_TextToGraphics(HP_G29, HelpText, OptionsHelp, HyperPause_SubMenu_HelpFont, 0, 0)
    UpdateLayeredWindow(HP_hwnd29, HP_hdc29,A_ScreenWidth - HelpTextLenghtWidth - 2*HyperPause_SubMenu_AdditionalTextMarginContour,A_ScreenHeight- HyperPause_SubMenu_SmallFontSize,HelpTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_SubMenu_HelpFontSize)
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
    HyperPause_ControllerTempPath := HLMediaPath . "\Controller\Temp\"
    HyperPause_ArtworkPath := HLMediaPath . "\Artwork\"
    IfNotExist, %HyperPause_ArtworkPath%
		FileCreateDir, %HyperPause_ArtworkPath%
    HyperPause_ArtworkTempPath := HLMediaPath . "\Artwork\Temp\"
    HyperPause_GuidesPath := HLMediaPath . "\Guides\"
    IfNotExist, %HyperPause_GuidesPath%
		FileCreateDir, %HyperPause_GuidesPath%
    HyperPause_GuidesTempPath := HLMediaPath . "\Guides\Temp\" 
    HyperPause_ManualsPath := HLMediaPath . "\Manuals\"
    IfNotExist, %HyperPause_ManualsPath%
		FileCreateDir, %HyperPause_ManualsPath%
    HyperPause_ManualsTempPath := HLMediaPath . "\Manuals\Temp\"
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
    ; Front End related Paths
    WheelImagePath := frontendPath . "\Media\" . systemName . "\Images\Wheel\"
    MediaImagePath := frontendPath . "\Media\" . systemName . "\Images\"
    iniread, VideoMainMenuPath, %frontendPath%\Settings\Main Menu.ini, video defaults, path, %frontendPath%\Media\Main Menu\Video\
    If (VideoMainMenuPath="")
        VideoMainMenuPath := frontendPath . "\Media\Main Menu\Video\"
    VideoMainMenuPath:=GetFullName(VideoMainMenuPath)	
    iniread, VideoSystemPath, %frontendPath%\Settings\%systemName%.ini, video defaults, path, %frontendPath%\Media\%systemName%\Video\    
    If (VideoSystemPath="")
        VideoSystemPath := frontendPath . "\Media\" . systemName . "\Video\"  
    VideoSystemPath:=GetFullName(VideoSystemPath)
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
    ;Loading ini settings
    HyperPause_ControllerMenuEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "Controller_Menu_Enabled", "true")  
    HyperPause_ChangeDiscMenuEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "ChangeDisc_Menu_Enabled", "true")  
    HyperPause_SaveandLoadMenuEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "SaveandLoad_Menu_Enabled", "true")  
    HyperPause_HighScoreMenuEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "HighScore_Menu_Enabled", "true")  
    HyperPause_ArtworkMenuEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "Artwork_Menu_Enabled", "true")  
    HyperPause_GuidesMenuEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "Guides_Menu_Enabled", "true")  
    HyperPause_ManualsMenuEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "Manuals_Menu_Enabled", "true")  
    HyperPause_SoundMenuEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "Sound_Menu_Enabled", "true")  
    HyperPause_VideosMenuEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "Videos_Menu_Enabled", "true")
    HyperPause_StatisticsMenuEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "Statistics_Menu_Enabled", "true")  
    HyperPause_MovesListMenuEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "MovesList_Menu_Enabled", "true")  
    HyperPause_ShutdownLabelEnabled := RIniHyperPauseLoadVar(3,4, "General Options", "Shutdown_Label_Enabled", "true")  
    HyperPause_LoadPDFandCompressedFilesatStart := RIniHyperPauseLoadVar(3,4, "General Options", "Load_PDF_and_Compressed_Files_at_HyperPause_First_Start", "false")
    HyperPause_SubMenu_PdfDpiResolution := RIniHyperPauseLoadVar(3,4, "General Options", "Pdf_Dpi_Resolution", "72")
    HyperPause_MuteWhenLoading := RIniHyperPauseLoadVar(3,4, "General Options", "Mute_when_Loading_Hyperpause", "true") 
    HyperPause_MuteSound := RIniHyperPauseLoadVar(3,4, "General Options", "Mute_Sound", "false") 
    HyperPause_Disable_Menu := RIniHyperPauseLoadVar(3,4, "General Options", "Disable_HyperPause_Menu", "true") 
    HyperPause_EnableMouseControl := RIniHyperPauseLoadVar(3,4, "General Options", "Enable_Mouse_Control", "false")  
    HyperPause_SupportAdditionalImageFiles := RIniHyperPauseLoadVar(3,4, "General Options", "Support_Additional_Image_Files", "true") 
    ;Main Menu Options
    HyperPause_MainMenu_GlobalBackground := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Enable_Global_Background", "true")  
    HyperPause_MainMenu_BackgroundAlign := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Background_Align_Image", "Align to Top Left")  
    HyperPause_MainMenu_Labels := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Main_Menu_Items", "Controller|Change Disc|Save State|Load State|HighScore|Artwork|Guides|Manuals|Videos|Sound|Statistics|Moves List|Shutdown")
    HyperPause_MainMenu_ShowClock := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Enable_Clock", "true")
    HyperPause_MainMenu_ClockFont := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Clock_Font", "Bebas Neue")
    HyperPause_MainMenu_ClockFontSize := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Clock_Font_Size", "15")
    HyperPause_MainMenu_LabelFont := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Main_Bar_Text_Font", "Bebas Neue")
    HyperPause_MainMenu_LabelFontsize := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Main_Bar_Text_Font_Size", "50")
    HyperPause_MainMenu_LabelSelectedColor := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Main_Bar_Text_Selected_Color", "ffffffff")
    HyperPause_MainMenu_LabelDisabledColor := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Main_Bar_Text_Disabled_Color", "44ffffff")
    HyperPause_MainMenu_HdistBetwLabels := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Main_Bar_Horizontal_Distance_Between_Labels", "300")
    HyperPause_MainMenu_BarHeight := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Main_Bar_Height", "60")
    HyperPause_MainMenu_BarGradientBrush1 := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Main_Bar_GradientBrush1", "6f000000")
    HyperPause_MainMenu_BarGradientBrush2 := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Main_Bar_GradientBrush2", "ff000000")
    HyperPause_MainMenu_BackgroundBrush := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Background_Brush", "aa000000") 
    HyperPause_MainMenu_Info_Labels := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Game_Info_Items", "Publisher|Developer|Company|Released|Year|Systems|Genre|Perspective|GameType|Language|Score|Controls|Players|NumPlayers|Series|Rating|Description")
    HyperPause_MainMenu_Info_Font := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Game_Info_Font", "Arial")
    HyperPause_MainMenu_Info_FontSize := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Game_Info_Font_Size", "15")
    HyperPause_MainMenu_Info_FontColor := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Game_Info_Font_Color", "ffffffff")
    HyperPause_MainMenu_TopLeftInfoMaxSize := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Game_Info_Break_Line_Max_Text_Size", "600")
    HyperPause_MainMenu_Info_Description_Font := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Game_Info_Description_Font", "Arial")
    HyperPause_MainMenu_Info_Description_FontSize := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Game_Info_Description_Font_Size", "15")
    HyperPause_MainMenu_Info_Description_FontColor := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Game_Info_Description_Font_Color", "ffffffff")
    HyperPause_MainMenu_DescriptionScrollingVelocity := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Game_Info_Description_Scrolling_Velocity", "1")
    HyperPause_MainMenu_UseScreenshotAsBackground := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Use_Screenshot_As_Background", "false") 
    HyperPause_AutoScallingToScreenResolution := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Enable_Auto_Fit_Screen_Resolution", "true") 
    HyperPause_MouseControlTransparency := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Mouse_Control_Overlay_Transparency", "50")
    HyperPause_MainMenu_BarVerticalOffset := RIniHyperPauseLoadVar(3,4, "Main Menu Appearance Options", "Bar_Vertical_Offset", "0")
    ;SubMenu General Options
    HyperPause_SubMenu_AdditionalTextMarginContour := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Additional_Text_Margin_Contour", "10")
    HyperPause_SubMenu_MinimumTextBoxWidth := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Minimum_Text_Box_Width", "200")
    HyperPause_SubMenu_DelayinMilliseconds := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Appearance_Delay_in_Milliseconds", "500")
    HyperPause_SubMenu_TopRightChamfer := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Top_Right_Chamfer_Size", "30")
    HyperPause_SubMenu_Width := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Width", "1000")
    HyperPause_SubMenu_Height := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Height", "320")
    HyperPause_SubMenu_BackgroundBrush := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Background_Brush", "44000000")
    HyperPause_SubMenu_LabelFont := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Label_Font", "Bebas Neue")
    HyperPause_SubMenu_LabelFontSize := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Label_Font_Size", "25")
    HyperPause_SubMenu_Font := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Content_Font", "Arial")
    HyperPause_SubMenu_FontSize := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Content_Font_Size", "20")
    HyperPause_SubMenu_SmallFontSize := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Content_Small_Font_Size", "15")
    HyperPause_SubMenu_HelpFont := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Help_Font", "Bebas Neue")
    HyperPause_SubMenu_HelpFontSize := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Help_Font_Size", "15")
    HyperPause_SubMenu_SelectedBrush := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Selected_Brush", "cc000000")
    HyperPause_SubMenu_DisabledBrush := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Disabled_Brush", "44000000")
    HyperPause_SubMenu_RadiusofRoundedCorners := RIniHyperPauseLoadVar(3,4, "SubMenu Appearance Options", "Radius_of_Rounded_Corners", "10") 
    ;SubMenu FullScreen Options
    HyperPause_SubMenu_FullScreenMargin := RIniHyperPauseLoadVar(3,4, "SubMenu FullScreen Appearance Options", "Margin", "20") 
    HyperPause_SubMenu_FullScreenRadiusofRoundedCorners := RIniHyperPauseLoadVar(3,4, "SubMenu FullScreen Appearance Options", "Radius_of_Rounded_Corners", "10") 
    HyperPause_SubMenu_FullScreenBrush := RIniHyperPauseLoadVar(3,4, "SubMenu FullScreen Appearance Options", "Background_Brush", "88000000") 
    HyperPause_SubMenu_FullScreenTextBrush := RIniHyperPauseLoadVar(3,4, "SubMenu FullScreen Appearance Options", "Legend_Text_Brush", "DD000015") 
    HyperPause_SubMenu_FullScreenFontColor := RIniHyperPauseLoadVar(3,4, "SubMenu FullScreen Appearance Options", "Legend_Text_Font_Color", "ffffffff") 
    HyperPause_SubMenu_FullScreenFontSize := RIniHyperPauseLoadVar(3,4, "SubMenu FullScreen Appearance Options", "Legend_Text_Font_Size", "15") 
    HyperPause_SubMenu_FullScreenZoomSteps := RIniHyperPauseLoadVar(3,4, "SubMenu FullScreen Appearance Options", "Zoom_Steps", "25") 
    HyperPause_SubMenu_FullScreenPanSteps := RIniHyperPauseLoadVar(3,4, "SubMenu FullScreen Appearance Options", "Pan_Steps", "120") 
    HyperPause_SubMenu_FullSCreenHelpTextTimer := RIniHyperPauseLoadVar(3,4, "SubMenu FullScreen Appearance Options", "Full_Screen_Help_Text_Timer", "2000") 
    ;Save and Load State Options 
    HyperPause_State_VdistBetwLabels := RIniHyperPauseLoadVar(3,4, "SubMenu Save and Load State Appearance Options", "Vertical_Distance_Between_Labels", "50")
    HyperPause_State_HMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Save and Load State Appearance Options", "Horizontal_Margin", "150")
    HyperPause_State_VMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Save and Load State Appearance Options", "Vertical_Margin", "60")
    HyperPause_DelaytoSendKeys := RIniHyperPauseLoadVar(3,4, "SubMenu Save and Load State Appearance Options", "Delay_to_Send_Keys", "500")
    HyperPause_SetKeyDelay := RIniHyperPauseLoadVar(3,4, "SubMenu Save and Load State Appearance Options", "Set_Key_Delay", "200")
    ;Sound Menu Options
    HyperPause_SoundBar_SingleBarWidth := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Single_Bar_Width", "20")
    HyperPause_SoundBar_SingleBarSpacing := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Single_Bar_Spacing", "5")
    HyperPause_SoundBar_SingleBarHeight := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Single_Bar_Height", "30")
    HyperPause_SoundBar_HeightDifferenceBetweenBars := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Height_Difference_Between_Bars", "2")
    HyperPause_SoundBar_vol_Step := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Volume_Steps", "5")
    HyperPause_SubMenu_SoundSelectedColor := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Selected_Color", "ffffffff")
    HyperPause_SubMenu_SoundDisabledColor := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Disabled_Color", "44ffffff")
    HyperPause_SubMenu_SoundMuteButtonFontSize := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Mute_Button_Font_Size", "15")
    HyperPause_SubMenu_SoundMuteButtonVDist := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Sound_Mute_Button_Vertical_Distance", "50")
    HyperPause_SubMenu_SoundSpaceBetweenSoundBarandSoundBitmap := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Space_Between_Sound_Bar_and_Sound_Bitmap", "40")
    HyperPause_SubMenu_SoundDisttoSoundLevel := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Sound_Distance_to_Sound_Level", "10")
    HyperPause_MusicPlayerEnabled := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Enable_Music_Player", "true")
    HyperPause_PlaylistExtension := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Playlist_Extension", "m3u")
    HyperPause_MusicFilesExtension := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Music_Files_Extension", "mp3|m4a|wav|mid|wma")
    HyperPause_EnableMusicOnStartup := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Enable_Music_on_HyperPause_Startup", "true")
    HyperPause_KeepPlayingAfterExitingHyperPause := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Keep_Playing_after_Exiting_HyperPause", "false")
    HyperPause_EnableShuffle := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Enable_Shuffle", "true")
    HyperPause_EnableLoop := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Enable_Loop", "true")
    HyperPause_ExternalPlaylistPath := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "External_Playlist_Path", "")
    HyperPause_SubMenu_SpaceBetweenMusicPlayerButtons := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Space_Between_Music_Player_Buttons", "50")
    HyperPause_SubMenu_SizeofMusicPlayerButtons := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Size_of_Music_Player_Buttons", "50")
    HyperPause_SubMenu_MusicPlayerVDist := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Music_Player_Vertical_Distance", "50")
    HyperPause_SoundButtonGrowingEffectVelocity := RIniHyperPauseLoadVar(3,4, "SubMenu Sound Control Appearance Options", "Sound_Button_Growing_Velocity", "1") 
    ;Change Disc Options
    HyperPause_ChangeDisc_VMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Change Disc Appearance Options", "Vertical_Margin", "30")
    HyperPause_ChangeDisc_TextDisttoImage := RIniHyperPauseLoadVar(3,4, "SubMenu Change Disc Appearance Options", "Text_Distance_to_Image", "20") 
    HyperPause_ChangeDisc_UseGameArt := RIniHyperPauseLoadVar(3,4, "SubMenu Change Disc Appearance Options", "Use_Game_Art_for_Disc_Image", "true") 
    HyperPause_ChangeDisc_SelectedEffect := RIniHyperPauseLoadVar(3,4, "SubMenu Change Disc Appearance Options", "Selected_Disc_Effect", "rotate") 
    HyperPause_ChangeDisc_SidePadding := RIniHyperPauseLoadVar(3,4, "SubMenu Change Disc Appearance Options", "Side_Padding", "0.2") 
    HyperPause_ChangeDisc_ArtworkDir := RIniHyperPauseLoadVar(3,4, "SubMenu Change Disc Appearance Options", "Game_Art_Disc_Artwork_Dir", "Artwork1") 
    ;High Score Options
    HyperPause_SubMenu_HighlightPlayerName := RIniHyperPauseLoadVar(3,4, "SubMenu HighScore Appearance Options", "Highlighted_Player_Name", "GEN") 
    HyperPause_SubMenu_HighlightPlayerFontColor := RIniHyperPauseLoadVar(3,4, "SubMenu HighScore Appearance Options", "Highlighted_Player_Font_Color", "ff00ffff") 
    HyperPause_SubMenu_HighScoreFontColor := RIniHyperPauseLoadVar(3,4, "SubMenu HighScore Appearance Options", "Font_Color", "ffffffff") 
    HyperPause_SubMenu_HighScoreFontSize := RIniHyperPauseLoadVar(3,4, "SubMenu HighScore Appearance Options", "Font_Size", "15") 
    HyperPause_SubMenu_HighScoreTitleFontSize := RIniHyperPauseLoadVar(3,4, "SubMenu HighScore Appearance Options", "Title_Font_Size", "20") 
    HyperPause_SubMenu_HighScoreTitleFontColor := RIniHyperPauseLoadVar(3,4, "SubMenu HighScore Appearance Options", "Title_Font_Color", "ffffff00") 
    HyperPause_SubMenu_HighScoreSelectedFontColor := RIniHyperPauseLoadVar(3,4, "SubMenu HighScore Appearance Options", "Selected_Font_Color", "ffff00ff") 
    HyperPause_SubMenu_HighScore_SuperiorMargin := RIniHyperPauseLoadVar(3,4, "SubMenu HighScore Appearance Options", "Superior_Margin", "30")
    HyperPause_SubMenu_HighScoreFullScreenWidth := RIniHyperPauseLoadVar(3,4, "SubMenu HighScore Appearance Options", "Full_Screen_Width", "800") 
    ;Moves List Options
    HyperPause_MovesList_VMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Moves List Appearance Options", "Vertical_Margin", "30") 
    HyperPause_MovesList_HMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Moves List Appearance Options", "Horizontal_Margin", "30") 
    HyperPause_MovesList_VdistBetwLabels := RIniHyperPauseLoadVar(3,4, "SubMenu Moves List Appearance Options", "Vertical_Distance_Between_Labels", "50") 
    HyperPause_MovesList_HdistBetwLabelsandMovesList := RIniHyperPauseLoadVar(3,4, "SubMenu Moves List Appearance Options", "Horizontal_Distance_Between_Labels_and_MovesList", "100") 
    HyperPause_MovesList_VdistBetwMovesListLabels := RIniHyperPauseLoadVar(3,4, "SubMenu Moves List Appearance Options", "Vertical_Distance_Between_Moves_Lines", "40") 
    HyperPause_MovesList_SecondaryFontSize := RIniHyperPauseLoadVar(3,4, "SubMenu Moves List Appearance Options", "Secondary_Font_Size", "15")
    HyperPause_MovesList_VImageSize := RIniHyperPauseLoadVar(3,4, "SubMenu Moves List Appearance Options", "Vertical_Move_Image_Size", "40") 
    HyperPause_SubMenu_MovesListFullScreenWidth := RIniHyperPauseLoadVar(3,4, "SubMenu Moves List Appearance Options", "Full_Screen_Width", "800")
    HyperPause_MovesList_HFullScreenMovesMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Moves List Appearance Options", "Horizontal_Full_Screen_Moves_Margin", "200")
    ;Statistics Menu Options
    HyperPause_Statistics_VMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Statistics Appearance Options", "Vertical_Margin", "30")  
    HyperPause_Statistics_HMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Statistics Appearance Options", "Horizontal_Margin", "60") 
    HyperPause_Statistics_TableFontSize := RIniHyperPauseLoadVar(3,4, "SubMenu Statistics Appearance Options", "Table_Font_Size", "15") 
    HyperPause_Statistics_DistBetweenLabelsandTable := RIniHyperPauseLoadVar(3,4, "SubMenu Statistics Appearance Options", "Distance_Between_Labels_and_Table", "40") 
    HyperPause_Statistics_VdistBetwTableLines := RIniHyperPauseLoadVar(3,4, "SubMenu Statistics Appearance Options", "Vertical_Distance_Between_Table_Lines", "30") 
    HyperPause_Statistics_VdistBetwLabels := RIniHyperPauseLoadVar(3,4, "SubMenu Statistics Appearance Options", "Vertical_Distance_Between_Labels", "50") 
    HyperPause_Statistics_TitleFontSize := RIniHyperPauseLoadVar(3,4, "SubMenu Statistics Appearance Options", "Title_Font_Size", "20") 
    HyperPause_Statistics_TitleFontColor := RIniHyperPauseLoadVar(3,4, "SubMenu Statistics Appearance Options", "Title_Font_Color", "ffffff00") 
    HyperPause_SubMenu_StatisticsFullScreenWidth := RIniHyperPauseLoadVar(3,4, "SubMenu Statistics Appearance Options", "Full_Screen_Width", "800") 
    ;Guides Menu Options
    HyperPause_Guides_VMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Guides Appearance Options", "Vertical_Margin", "30") 
    HyperPause_Guides_HMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Guides Appearance Options", "Horizontal_Margin", "30") 
    HyperPause_Guides_HdistBetwPages := RIniHyperPauseLoadVar(3,4, "SubMenu Guides Appearance Options", "Horizontal_Distance_Between_Pages", "50") 
    HyperPause_SubMenu_GuidesSelectedBrush := RIniHyperPauseLoadVar(3,4, "SubMenu Guides Appearance Options", "Selected_Brush", "33ffff00") 
    HyperPause_Guides_VdistBetwLabels := RIniHyperPauseLoadVar(3,4, "SubMenu Guides Appearance Options", "Vertical_Distance_Between_Labels", "50") 
    HyperPause_Guides_HdistBetwLabelsandPages := RIniHyperPauseLoadVar(3,4, "SubMenu Guides Appearance Options", "Horizontal_Distance_Between_Labels_and_Pages", "50") 
    HyperPause_Guides_PageNumberFontColor := RIniHyperPauseLoadVar(3,4, "SubMenu Guides Appearance Options", "Page_Number_Font_Color", "00000000") 
    ;Manuals Menu Options
    HyperPause_Manuals_VMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Manuals Appearance Options", "Vertical_Margin", "30") 
    HyperPause_Manuals_HMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Manuals Appearance Options", "Horizontal_Margin", "30") 
    HyperPause_Manuals_HdistBetwPages := RIniHyperPauseLoadVar(3,4, "SubMenu Manuals Appearance Options", "Horizontal_Distance_Between_Pages", "50") 
    HyperPause_SubMenu_ManualsSelectedBrush := RIniHyperPauseLoadVar(3,4, "SubMenu Manuals Appearance Options", "Selected_Brush", "33ffff00") 
    HyperPause_Manuals_VdistBetwLabels := RIniHyperPauseLoadVar(3,4, "SubMenu Manuals Appearance Options", "Vertical_Distance_Between_Labels", "50") 
    HyperPause_Manuals_HdistBetwLabelsandPages := RIniHyperPauseLoadVar(3,4, "SubMenu Manuals Appearance Options", "Horizontal_Distance_Between_Labels_and_Pages", "50") 
    HyperPause_Manuals_PageNumberFontColor := RIniHyperPauseLoadVar(3,4, "SubMenu Manuals Appearance Options", "Page_Number_Font_Color", "00000000") 
    ;Controller Menu Options
    HyperPause_Controller_VMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Controller Appearance Options", "Vertical_Margin", "30") 
    HyperPause_Controller_HMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Controller Appearance Options", "Horizontal_Margin", "30") 
    HyperPause_Controller_HdistBetwPages := RIniHyperPauseLoadVar(3,4, "SubMenu Controller Appearance Options", "Horizontal_Distance_Between_Pages", "50") 
    HyperPause_SubMenu_ControllerSelectedBrush := RIniHyperPauseLoadVar(3,4, "SubMenu Controller Appearance Options", "Selected_Brush", "33ffff00") 
    HyperPause_Controller_VdistBetwLabels := RIniHyperPauseLoadVar(3,4, "SubMenu Controller Appearance Options", "Vertical_Distance_Between_Labels", "50") 
    HyperPause_Controller_HdistBetwLabelsandPages := RIniHyperPauseLoadVar(3,4, "SubMenu Controller Appearance Options", "Horizontal_Distance_Between_Labels_and_Pages", "50") 
    HyperPause_Controller_PageNumberFontColor := RIniHyperPauseLoadVar(3,4, "SubMenu Controller Appearance Options", "Page_Number_Font_Color", "00000000") 
    HyperPause_ControllerBannerHeight := RIniHyperPauseLoadVar(3,4, "SubMenu Controller Appearance Options", "Controller_Banner_Height", "40") 
    HyperPause_vDistanceBetweenButtons := RIniHyperPauseLoadVar(3,4, "SubMenu Controller Appearance Options", "Vertical_Distance_Between_Buttons", "80") 
    HyperPause_vDistanceBetweenBanners := RIniHyperPauseLoadVar(3,4, "SubMenu Controller Appearance Options", "Vertical_Distance_Between_Banners", "30") 
    HyperPause_hDistanceBetweenControllerBannerElements := RIniHyperPauseLoadVar(3,4, "SubMenu Controller Appearance Options", "Horizontal_Distance_Between_Controller_Banner_Elements", "40") 
    HyperPause_selectedControllerBannerDisplacement := RIniHyperPauseLoadVar(3,4, "SubMenu Controller Appearance Options", "Selected_Controller_Banner_Displacement", "20") 
    ;Artwork Menu Options
    HyperPause_Artwork_VMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Artwork Appearance Options", "Vertical_Margin", "30") 
    HyperPause_Artwork_HMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Artwork Appearance Options", "Horizontal_Margin", "30") 
    HyperPause_Artwork_HdistBetwPages := RIniHyperPauseLoadVar(3,4, "SubMenu Artwork Appearance Options", "Horizontal_Distance_Between_Pages", "50") 
    HyperPause_SubMenu_ArtworkSelectedBrush := RIniHyperPauseLoadVar(3,4, "SubMenu Artwork Appearance Options", "Selected_Brush", "33ffff00") 
    HyperPause_Artwork_VdistBetwLabels := RIniHyperPauseLoadVar(3,4, "SubMenu Artwork Appearance Options", "Vertical_Distance_Between_Labels", "50") 
    HyperPause_Artwork_HdistBetwLabelsandPages := RIniHyperPauseLoadVar(3,4, "SubMenu Artwork Appearance Options", "Horizontal_Distance_Between_Labels_and_Pages", "50") 
    HyperPause_Artwork_PageNumberFontColor := RIniHyperPauseLoadVar(3,4, "SubMenu Artwork Appearance Options", "Page_Number_Font_Color", "00000000") 
    HyperPause_Artwork_1_Label := RIniHyperPauseLoadVar(3,4, "SubMenu Artwork Appearance Options", "Artwork_1_Label", "Artwork 1")
    HyperPause_Artwork_2_Label := RIniHyperPauseLoadVar(3,4, "SubMenu Artwork Appearance Options", "Artwork_2_Label", "Game Box Art")
    HyperPause_Artwork_3_Label := RIniHyperPauseLoadVar(3,4, "SubMenu Artwork Appearance Options", "Artwork_3_Label", "Cartridge")
    HyperPause_Artwork_4_Label := RIniHyperPauseLoadVar(3,4, "SubMenu Artwork Appearance Options", "Artwork_4_Label", "Flyers")
    ;Videos Menu Options
    HyperPause_SupportedVideos := RIniHyperPauseLoadVar(3,4, "SubMenu Videos Appearance Options", "Supported_Videos", "avi|wmv|mp4")
    HyperPause_EnableHyperspinVideos := RIniHyperPauseLoadVar(3,4, "SubMenu Videos Appearance Options", "Enable_Hyperspin_Videos", "true")
    HyperPause_Videos_VMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Videos Appearance Options", "Vertical_Margin", "30") 
    HyperPause_Videos_HMargin := RIniHyperPauseLoadVar(3,4, "SubMenu Videos Appearance Options", "Horizontal_Margin", "30") 
    HyperPause_Videos_VdistBetwLabels := RIniHyperPauseLoadVar(3,4, "SubMenu Videos Appearance Options", "Vertical_Distance_Between_Labels", "50") 
    HyperPause_EnableVideoLoop := RIniHyperPauseLoadVar(3,4, "SubMenu Videos Appearance Options", "Enable_Loop", "true") 
    HyperPause_SubMenu_VideoRewindFastForwardJumpSeconds := RIniHyperPauseLoadVar(3,4, "SubMenu Videos Appearance Options", "Video_Seconds_to_Jump_in_Rewind_and_Fast_Forward_Buttons", "5") 
    HyperPause_VideoButtonGrowingEffectVelocity := RIniHyperPauseLoadVar(3,4, "SubMenu Videos Appearance Options", "Video_Button_Growing_Velocity", "1") 
    HyperPause_SubMenu_SizeofVideoButtons := RIniHyperPauseLoadVar(3,4, "SubMenu Videos Appearance Options", "Size_of_Video_Player_Buttons", "45") 
    HyperPause_SubMenu_SpaceBetweenVideoButtons := RIniHyperPauseLoadVar(3,4, "SubMenu Videos Appearance Options", "Space_Between_Video_Player_Buttons", "15") 
    HyperPause_SubMenu_SpaceBetweenLabelsandVideoButtons := RIniHyperPauseLoadVar(3,4, "SubMenu Videos Appearance Options", "Space_Between_Label_and_Video_Player_Buttons", "30") 
    ;Start and exit screen
    HyperPause_AuxiliarScreen_StartText := RIniHyperPauseLoadVar(3,4, "Start and Exit Screen", "Loading_Text", "Loading HyperPause") 
    HyperPause_AuxiliarScreen_ExitText := RIniHyperPauseLoadVar(3,4, "Start and Exit Screen", "Exiting_Text", "Exiting HyperPause") 
    HyperPause_AuxiliarScreen_Font := RIniHyperPauseLoadVar(3,4, "Start and Exit Screen", "Font", "Bebas Neue") 
    HyperPause_AuxiliarScreen_FontSize := RIniHyperPauseLoadVar(3,4, "Start and Exit Screen", "Font_Size", "30") 
    HyperPause_AuxiliarScreen_FontColor := RIniHyperPauseLoadVar(3,4, "Start and Exit Screen", "Font_Color", "ff222222") 
    HyperPause_AuxiliarScreen_ExitTextMargin := RIniHyperPauseLoadVar(3,4, "Start and Exit Screen", "Text_Margin", "50") 
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

;scalling the font size, windows, bars,... If necessary
AutoAdjustMenutoScreenResolution:
    HyperPause_MainMenu_ClockFontSize := round(HyperPause_MainMenu_ClockFontSize * ScallingFactor)
    HyperPause_MainMenu_LabelFontsize := round(HyperPause_MainMenu_LabelFontsize * ScallingFactor)
    HyperPause_MainMenu_HdistBetwLabels := round(HyperPause_MainMenu_HdistBetwLabels * ScallingFactor)
    HyperPause_MainMenu_BarHeight := round(HyperPause_MainMenu_BarHeight * ScallingFactor)
    HyperPause_MainMenu_Info_FontSize := round(HyperPause_MainMenu_Info_FontSize * ScallingFactor)
    HyperPause_MainMenu_TopLeftInfoMaxSize := round(HyperPause_MainMenu_TopLeftInfoMaxSize * ScallingFactor)
    HyperPause_MainMenu_Info_Description_FontSize := round(HyperPause_MainMenu_Info_Description_FontSize * ScallingFactor)
    HyperPause_MainMenu_DescriptionScrollingVelocity := round(HyperPause_MainMenu_DescriptionScrollingVelocity * ScallingFactor)
    HyperPause_SubMenu_AdditionalTextMarginContour := round(HyperPause_SubMenu_AdditionalTextMarginContour * ScallingFactor)
    HyperPause_SubMenu_MinimumTextBoxWidth := round(HyperPause_SubMenu_MinimumTextBoxWidth * ScallingFactor)
    HyperPause_SubMenu_TopRightChamfer := round(HyperPause_SubMenu_TopRightChamfer * ScallingFactor)
    HyperPause_SubMenu_Width := round(HyperPause_SubMenu_Width * ScallingFactor)
    HyperPause_SubMenu_Height := round(HyperPause_SubMenu_Height * ScallingFactor)
    HyperPause_SubMenu_LabelFontSize := round(HyperPause_SubMenu_LabelFontSize * ScallingFactor)
    HyperPause_SubMenu_FontSize := round(HyperPause_SubMenu_FontSize * ScallingFactor)
    HyperPause_SubMenu_SmallFontSize := round(HyperPause_SubMenu_SmallFontSize * ScallingFactor)
    HyperPause_SubMenu_HelpFontSize := round(HyperPause_SubMenu_HelpFontSize * ScallingFactor)
    HyperPause_SubMenu_RadiusofRoundedCorners := round(HyperPause_SubMenu_RadiusofRoundedCorners * ScallingFactor)
    HyperPause_SubMenu_FullScreenMargin := round(HyperPause_SubMenu_FullScreenMargin * ScallingFactor)
    HyperPause_SubMenu_FullScreenRadiusofRoundedCorners := round(HyperPause_SubMenu_FullScreenRadiusofRoundedCorners * ScallingFactor)
    HyperPause_SubMenu_FullScreenFontSize := round(HyperPause_SubMenu_FullScreenFontSize * ScallingFactor)
    HyperPause_State_VdistBetwLabels := round(HyperPause_State_VdistBetwLabels * ScallingFactor)
    HyperPause_State_HMargin := round(HyperPause_State_HMargin * ScallingFactor)
    HyperPause_State_VMargin := round(HyperPause_State_VMargin * ScallingFactor)
    HyperPause_SoundBar_SingleBarWidth := round(HyperPause_SoundBar_SingleBarWidth * ScallingFactor)
    HyperPause_SoundBar_SingleBarSpacing := round(HyperPause_SoundBar_SingleBarSpacing * ScallingFactor)
    HyperPause_SoundBar_SingleBarHeight := round(HyperPause_SoundBar_SingleBarHeight * ScallingFactor)
    HyperPause_SoundBar_HeightDifferenceBetweenBars := round(HyperPause_SoundBar_HeightDifferenceBetweenBars * ScallingFactor)
    HyperPause_SubMenu_SoundMuteButtonFontSize := round(HyperPause_SubMenu_SoundMuteButtonFontSize * ScallingFactor)
    HyperPause_SubMenu_SoundMuteButtonVDist := round(HyperPause_SubMenu_SoundMuteButtonVDist * ScallingFactor)
    HyperPause_SubMenu_SoundSpaceBetweenSoundBarandSoundBitmap := round(HyperPause_SubMenu_SoundSpaceBetweenSoundBarandSoundBitmap * ScallingFactor)
    HyperPause_SubMenu_SoundDisttoSoundLevel := round(HyperPause_SubMenu_SoundDisttoSoundLevel * ScallingFactor)
    HyperPause_SubMenu_SpaceBetweenMusicPlayerButtons := round(HyperPause_SubMenu_SpaceBetweenMusicPlayerButtons * ScallingFactor)
    HyperPause_SubMenu_SizeofMusicPlayerButtons := round(HyperPause_SubMenu_SizeofMusicPlayerButtons * ScallingFactor)
    HyperPause_SubMenu_MusicPlayerVDist := round(HyperPause_SubMenu_MusicPlayerVDist * ScallingFactor)
    HyperPause_ChangeDisc_VMargin := round(HyperPause_ChangeDisc_VMargin * ScallingFactor)
    HyperPause_ChangeDisc_TextDisttoImage := round(HyperPause_ChangeDisc_TextDisttoImage * ScallingFactor)
    HyperPause_SubMenu_HighScoreFontSize := round(HyperPause_SubMenu_HighScoreFontSize * ScallingFactor)
    HyperPause_SubMenu_HighScoreTitleFontSize := round(HyperPause_SubMenu_HighScoreTitleFontSize * ScallingFactor)
    HyperPause_SubMenu_HighScore_SuperiorMargin := round(HyperPause_SubMenu_HighScore_SuperiorMargin * ScallingFactor)
    HyperPause_SubMenu_HighScoreFullScreenWidth := round(HyperPause_SubMenu_HighScoreFullScreenWidth * ScallingFactor)
    HyperPause_MovesList_VMargin := round(HyperPause_MovesList_VMargin * ScallingFactor)
    HyperPause_MovesList_HMargin := round(HyperPause_MovesList_HMargin * ScallingFactor)
    HyperPause_MovesList_VdistBetwLabels := round(HyperPause_MovesList_VdistBetwLabels * ScallingFactor)
    HyperPause_MovesList_HdistBetwLabelsandMovesList := round(HyperPause_MovesList_HdistBetwLabelsandMovesList * ScallingFactor)
    HyperPause_MovesList_VdistBetwMovesListLabels := round(HyperPause_MovesList_VdistBetwMovesListLabels * ScallingFactor)
    HyperPause_MovesList_SecondaryFontSize := round(HyperPause_MovesList_SecondaryFontSize * ScallingFactor)
    HyperPause_MovesList_VImageSize := round(HyperPause_MovesList_VImageSize * ScallingFactor)
    HyperPause_SubMenu_MovesListFullScreenWidth := round(HyperPause_SubMenu_MovesListFullScreenWidth * ScallingFactor)
    HyperPause_MovesList_HFullScreenMovesMargin := round(HyperPause_MovesList_HFullScreenMovesMargin * ScallingFactor)
    HyperPause_Statistics_VMargin := round(HyperPause_Statistics_VMargin * ScallingFactor)
    HyperPause_Statistics_HMargin := round(HyperPause_Statistics_HMargin * ScallingFactor)
    HyperPause_Statistics_TableFontSize := round(HyperPause_Statistics_TableFontSize * ScallingFactor)
    HyperPause_Statistics_DistBetweenLabelsandTable := round(HyperPause_Statistics_DistBetweenLabelsandTable * ScallingFactor)
    HyperPause_Statistics_VdistBetwTableLines := round(HyperPause_Statistics_VdistBetwTableLines * ScallingFactor)
    HyperPause_Statistics_VdistBetwLabels := round(HyperPause_Statistics_VdistBetwLabels * ScallingFactor)
    HyperPause_Statistics_TitleFontSize := round(HyperPause_Statistics_TitleFontSize * ScallingFactor)
    HyperPause_SubMenu_StatisticsFullScreenWidth := round(HyperPause_SubMenu_StatisticsFullScreenWidth * ScallingFactor)
    HyperPause_Guides_VMargin := round(HyperPause_Guides_VMargin * ScallingFactor)
    HyperPause_Guides_HMargin := round(HyperPause_Guides_HMargin * ScallingFactor)
    HyperPause_Guides_HdistBetwPages := round(HyperPause_Guides_HdistBetwPages * ScallingFactor)
    HyperPause_Guides_VdistBetwLabels := round(HyperPause_Guides_VdistBetwLabels * ScallingFactor)
    HyperPause_Guides_HdistBetwLabelsandPages := round(HyperPause_Guides_HdistBetwLabelsandPages * ScallingFactor)
    HyperPause_Manuals_VMargin := round(HyperPause_Manuals_VMargin * ScallingFactor)
    HyperPause_Manuals_HMargin := round(HyperPause_Manuals_HMargin * ScallingFactor)
    HyperPause_Manuals_HdistBetwPages := round(HyperPause_Manuals_HdistBetwPages * ScallingFactor)
    HyperPause_Manuals_VdistBetwLabels := round(HyperPause_Manuals_VdistBetwLabels * ScallingFactor)
    HyperPause_Manuals_HdistBetwLabelsandPages := round(HyperPause_Manuals_HdistBetwLabelsandPages * ScallingFactor)
    HyperPause_Controller_VMargin := round(HyperPause_Controller_VMargin * ScallingFactor)
    HyperPause_Controller_HMargin := round(HyperPause_Controller_HMargin * ScallingFactor)
    HyperPause_Controller_HdistBetwPages := round(HyperPause_Controller_HdistBetwPages * ScallingFactor)
    HyperPause_Controller_VdistBetwLabels := round(HyperPause_Controller_VdistBetwLabels * ScallingFactor)
    HyperPause_Controller_HdistBetwLabelsandPages := round(HyperPause_Controller_HdistBetwLabelsandPages * ScallingFactor)
    HyperPause_ControllerBannerHeight := round(HyperPause_ControllerBannerHeight * ScallingFactor)
    HyperPause_vDistanceBetweenButtons := round(HyperPause_vDistanceBetweenButtons * ScallingFactor)
    HyperPause_vDistanceBetweenBanners := round(HyperPause_vDistanceBetweenBanners * ScallingFactor)
    HyperPause_hDistanceBetweenControllerBannerElements := round(HyperPause_hDistanceBetweenControllerBannerElements * ScallingFactor)
    HyperPause_selectedControllerBannerDisplacement := round(HyperPause_selectedControllerBannerDisplacement * ScallingFactor)
    HyperPause_Artwork_VMargin := round(HyperPause_Artwork_VMargin * ScallingFactor)
    HyperPause_Artwork_HMargin := round(HyperPause_Artwork_HMargin * ScallingFactor)
    HyperPause_Artwork_HdistBetwPages := round(HyperPause_Artwork_HdistBetwPages * ScallingFactor)
    HyperPause_Artwork_VdistBetwLabels := round(HyperPause_Artwork_VdistBetwLabels * ScallingFactor)
    HyperPause_Artwork_HdistBetwLabelsandPages := round(HyperPause_Artwork_HdistBetwLabelsandPages * ScallingFactor)
    HyperPause_Videos_VMargin := round(HyperPause_Videos_VMargin * ScallingFactor)
    HyperPause_Videos_HMargin := round(HyperPause_Videos_HMargin * ScallingFactor)
    HyperPause_Videos_VdistBetwLabels := round(HyperPause_Videos_VdistBetwLabels * ScallingFactor)
    HyperPause_SubMenu_SizeofVideoButtons := round(HyperPause_SubMenu_SizeofVideoButtons * ScallingFactor)
    HyperPause_SubMenu_SpaceBetweenVideoButtons := round(HyperPause_SubMenu_SpaceBetweenVideoButtons * ScallingFactor)
    HyperPause_SubMenu_SpaceBetweenLabelsandVideoButtons := round(HyperPause_SubMenu_SpaceBetweenLabelsandVideoButtons * ScallingFactor)
    HyperPause_AuxiliarScreen_FontSize := round(HyperPause_AuxiliarScreen_FontSize * ScallingFactor)
    HyperPause_AuxiliarScreen_ExitTextMargin := round(HyperPause_AuxiliarScreen_ExitTextMargin * ScallingFactor)
Return


;-----------------OPEN AND CLOSE PROCESS FUNCTIONS------------
ProcSus(PID_or_Name)
{
   If InStr(PID_or_Name, ".") {
      Process, Exist, %PID_or_Name%
      PID_or_Name := ErrorLevel
   }
   If !(h := DllCall("OpenProcess", "uInt", 0x1F0FFF, "Int", 0, "Int", PID_or_Name))
      Return -1
   DllCall("ntdll.dll\NtSuspendProcess", "Int", h), DllCall("CloseHandle", "Int", h)
}

ProcRes(PID_or_Name)
{
   If InStr(PID_or_Name, ".") {
      Process, Exist, %PID_or_Name%
      PID_or_Name := ErrorLevel
   }
   If !(h := DllCall("OpenProcess", "uInt", 0x1F0FFF, "Int", 0, "Int", PID_or_Name))
      Return -1
   DllCall("ntdll.dll\NtResumeProcess", "Int", h), DllCall("CloseHandle", "Int", h)
}


;-----------------SOUND CONTROL FUNCTIONS------------
;Draw the colored progress bars.
DrawSoundFullProgress(G, X, Y, W, H, color1, color2) {
   PBRUSH := Gdip_CreateLineBrushFromRect(X-W, Y-H, W-5, H, color1, color2)
   Gdip_FillRoundedRectangle(G, PBRUSH, X-W, Y-H, W, H, 3)
   PBRUSH := Gdip_CreateLineBrushFromRect(X-W, Y-H, W//2, H, 0xAAFFFFFF, 0x11FFFFFF)
   Gdip_FillRoundedRectangle(G, PBRUSH, X-W, Y-H, W//2, H, 3)
   PPEN := Gdip_CreatePen(0x22000000, 1)
   Gdip_DrawRoundedRectangle(G, PPEN, X-W, Y-H, W, H, 3)
}

;Draw the blank progress bars.
DrawSoundEmptyProgress(G, X, Y, W, H) {
    PBRUSH := Gdip_CreateLineBrushFromRect(X-W, Y-H, W-5, H, 0xFF8E8F8E, 0xFF565756)
    Gdip_FillRoundedRectangle(G, PBRUSH, X-W, Y-H, W, H, 3)
    PBRUSH := Gdip_CreateLineBrushFromRect(X-W, Y-H, W//2, H, 0xAAFFFFFF, 0x11FFFFFF)
    Gdip_FillRoundedRectangle(G, PBRUSH, X-W, Y-H, W//2, H, 3)
    PPEN := Gdip_CreatePen(0x22000000, 1)
    Gdip_DrawRoundedRectangle(G, PPEN, X-W, Y-H, W, H, 3)
}

; Returns the master volume
getMasterVolume() {
	Global xp
	If (xp)
		SoundGet, volume
	Else
		volume := VA_GetMasterVolume()
	Return volume
}

;Sets the master volume
setMasterVolume(value) {
	Global xp
	If (xp)
		SoundSet %value%
	Else {
		VA_SetMasterVolume(value)
    }
}

; Returns True If the master volume is muted
getMasterMute() {
	Global xp
	If (xp)
	{
		SoundGet, mute, Master, Mute
		If mute=On
			mute := 1
		Else
			mute := 0
	}
	Else {
		mute := VA_GetMasterMute()
	}
	Return mute
}

;Set wheter the master volume is muted or not
setMasterMute(state) {
	Global xp
	If (xp)
	{
		If (!getMasterMute() && state)
			SoundSet, -1,, mute
		Else If (getMasterMute() && !state)
			SoundSet, -1,, mute
	}
	Else {
		VA_SetMute(state)
	}
}


; If the OS is Windows XP or below it will Return True
IsWinXPOrBelow() {
	If A_OSVersion in WIN_2003,WIN_XP,WIN_2000,WIN_NT4,WIN_95,WIN_98,WIN_ME
		Return 1
	Return 0
}


;Main Menu Clock
Clock:
    Gdip_GraphicsClear(HP_G28)
    FormatTime, CurrentTime, A_Now, dddd MMMM d, yyyy hh:mm:ss tt
    CurrentTimeTextLenghtWidth := MeasureText(0,CurrentTime,HyperPause_MainMenu_ClockFont,HyperPause_MainMenu_ClockFontSize,"Regular")
    posCurrentTimeX := CurrentTimeTextLenghtWidth + HyperPause_SubMenu_AdditionalTextMarginContour
    OptionsCurrentTime = x%posCurrentTimeX% y0 Right c%HyperPause_MainMenu_LabelDisabledColor% r4 s%HyperPause_MainMenu_ClockFontSize% Regular
    Gdip_FillRectangle(HP_G28, HyperPause_SubMenu_DisabledBrushV, 0, 0, CurrentTimeTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_MainMenu_ClockFontSize)
    Gdip_TextToGraphics(HP_G28, CurrentTime, OptionsCurrentTime, HyperPause_MainMenu_ClockFont, 0, 0)
    UpdateLayeredWindow(HP_hwnd28, HP_hdc28,A_ScreenWidth - CurrentTimeTextLenghtWidth - 2*HyperPause_SubMenu_AdditionalTextMarginContour,0,CurrentTimeTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour,HyperPause_MainMenu_ClockFontSize)
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
        try wmpMusic.settings.volume := 100
        try wmpMusic.settings.autoStart := false
        try wmpMusic.Settings.setMode("shuffle",false)
        If((HyperPause_EnableMusicOnStartup = "true") and (InitialMuteState<>1))
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
        Gdip_GraphicsClear(HP_G29)  
        MusicPlayerTextX := round((HyperPause_SubMenu_Width)/2) 
        MusicPlayerTextY := posSoundBarTextY+SoundBarHeight+HyperPause_SubMenu_SoundMuteButtonVDist+HyperPause_SubMenu_SoundMuteButtonFontSize+HyperPause_SubMenu_MusicPlayerVDist + HyperPause_SubMenu_SizeofMusicPlayerButtons + HyperPause_SubMenu_SmallFontSize
        OptionsMusicPlayerText = x%MusicPlayerTextX% y%MusicPlayerTextY% Center c%HyperPause_MainMenu_LabelDisabledColor% r4 s%HyperPause_SubMenu_SmallFontSize% bold
        try CurrentMusicPlayStatus := wmpMusic.playState
        try CurrentMusicPositionString := wmpMusic.controls.currentPositionString
        try CurrentMusicStatusDescription := wmpMusic.status
        try CurrentMusicDurationString := wmpMusic.currentMedia.durationString
        If ((CurrentMusicPositionString<>"") and ((CurrentMusicPlayStatus=2) or (CurrentMusicPlayStatus=3))) {
            Gdip_TextToGraphics(HP_G29, CurrentMusicStatusDescription . " - " . CurrentMusicPositionString . " (" . CurrentMusicDurationString . ")", OptionsMusicPlayerText, HyperPause_SubMenu_Font, 0, 0)
        }
        posHelpY := HyperPause_SubMenu_Height - HyperPause_SubMenu_SmallFontSize
        If(VSubMenuItem = 1){
            HelpTextLenghtWidth := MeasureText(0,"Press Left or Right to Change the Volume Level",HyperPause_SubMenu_HelpFont,HyperPause_SubMenu_HelpFontSize,"Regular")
            posHelpX := round(HyperPause_SubMenu_Width - HelpTextLenghtWidth/2 - HyperPause_SubMenu_AdditionalTextMarginContour)
            OptionsHelp = x%posHelpX% y%posHelpY% Center c%HyperPause_MainMenu_LabelDisabledColor% r4 s%HyperPause_SubMenu_HelpFontSize% Regular
            Gdip_FillRectangle(HP_G29, HyperPause_SubMenu_DisabledBrushV, HyperPause_SubMenu_Width - HelpTextLenghtWidth - 2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_Height- HyperPause_SubMenu_SmallFontSize, HelpTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_HelpFontSize)
            Gdip_TextToGraphics(HP_G29, "Press Left or Right to Change the Volume Level", OptionsHelp, HyperPause_SubMenu_HelpFont, 0, 0)
        }
        If(VSubMenuItem = 2) and (HSubmenuitemSoundVSubmenuitem2=1){
            HelpTextLenghtWidth := MeasureText(0,"Press Select to Change Mute Status",HyperPause_SubMenu_HelpFont,HyperPause_SubMenu_HelpFontSize,"Regular")
            posHelpX := round(HyperPause_SubMenu_Width - HelpTextLenghtWidth/2 - HyperPause_SubMenu_AdditionalTextMarginContour)
            OptionsHelp = x%posHelpX% y%posHelpY% Center c%HyperPause_MainMenu_LabelDisabledColor% r4 s%HyperPause_SubMenu_HelpFontSize% Regular
            Gdip_FillRectangle(HP_G29, HyperPause_SubMenu_DisabledBrushV, HyperPause_SubMenu_Width - HelpTextLenghtWidth - 2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_Height- HyperPause_SubMenu_SmallFontSize, HelpTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_HelpFontSize)
            Gdip_TextToGraphics(HP_G29, "Press Select to Change Mute Status", OptionsHelp, HyperPause_SubMenu_HelpFont, 0, 0)
        }
        If(VSubMenuItem = 2) and (HSubmenuitemSoundVSubmenuitem2=2){
            HelpTextLenghtWidth := MeasureText(0,"Press Select to Enable Music While Playing the Game",HyperPause_SubMenu_HelpFont,HyperPause_SubMenu_HelpFontSize,"Regular")
            posHelpX := round(HyperPause_SubMenu_Width - HelpTextLenghtWidth/2 - HyperPause_SubMenu_AdditionalTextMarginContour)
            OptionsHelp = x%posHelpX% y%posHelpY% Center c%HyperPause_MainMenu_LabelDisabledColor% r4 s%HyperPause_SubMenu_HelpFontSize% Regular
            Gdip_FillRectangle(HP_G29, HyperPause_SubMenu_DisabledBrushV, HyperPause_SubMenu_Width - HelpTextLenghtWidth - 2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_Height- HyperPause_SubMenu_SmallFontSize, HelpTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_HelpFontSize)
            Gdip_TextToGraphics(HP_G29, "Press Select to Enable Music While Playing the Game", OptionsHelp, HyperPause_SubMenu_HelpFont, 0, 0)
        }
        If(VSubMenuItem = 3){
            HelpTextLenghtWidth := MeasureText(0,"Press Select to Choose Music Control Option",HyperPause_SubMenu_HelpFont,HyperPause_SubMenu_HelpFontSize,"Regular")
            posHelpX := round(HyperPause_SubMenu_Width - HelpTextLenghtWidth/2 - HyperPause_SubMenu_AdditionalTextMarginContour)
            OptionsHelp = x%posHelpX% y%posHelpY% Center c%HyperPause_MainMenu_LabelDisabledColor% r4 s%HyperPause_SubMenu_HelpFontSize% Regular
            Gdip_FillRectangle(HP_G29, HyperPause_SubMenu_DisabledBrushV, HyperPause_SubMenu_Width - HelpTextLenghtWidth - 2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_Height- HyperPause_SubMenu_SmallFontSize, HelpTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_HelpFontSize)
            Gdip_TextToGraphics(HP_G29, "Press Select to Choose Music Control Option", OptionsHelp, HyperPause_SubMenu_HelpFont, 0, 0)
        }
        UpdateLayeredWindow(HP_hwnd29, HP_hdc29, A_ScreenWidth - HyperPause_SubMenu_Width,A_ScreenHeight-HyperPause_SubMenu_Height,HyperPause_SubMenu_Width,HyperPause_SubMenu_Height)
    } Else {
        Gdip_GraphicsClear(HP_G29)     
        UpdateLayeredWindow(HP_hwnd29, HP_hdc29, A_ScreenWidth - HyperPause_SubMenu_Width,A_ScreenHeight-HyperPause_SubMenu_Height,HyperPause_SubMenu_Width,HyperPause_SubMenu_Height)            
    }
Return


UpdateVideoPlayingInfo:
    If (SelectedMenuOption="Videos") and (VSubMenuItem <> 0){
        Gdip_GraphicsClear(HP_G29)  
        VideoPlayerTextX := (2*HyperPause_Videos_HMargin+VideosMaxFontListWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour) + (HyperPause_SubMenu_Width - (2*HyperPause_Videos_HMargin+VideosMaxFontListWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour)) // 2 
        VideoPlayerTextY := HyperPause_SubMenu_SmallFontSize // 2  
        OptionsVideoPlayerText = x%VideoPlayerTextX% y%VideoPlayerTextY% Center c%HyperPause_MainMenu_LabelDisabledColor% r4 s%HyperPause_SubMenu_SmallFontSize% bold
        try CurrentVideoPlayStatus := wmpVideo.playState
        try CurrentVideoPositionString := wmpVideo.controls.currentPositionString
        try CurrentVideoStatusDescription := wmpVideo.status
        try CurrentVideoDurationString := wmpVideo.currentMedia.durationString
        If ((CurrentVideoPositionString<>"") and ((CurrentVideoPlayStatus=2) or (CurrentVideoPlayStatus=3)))
            Gdip_TextToGraphics(HP_G29, CurrentVideoStatusDescription . " - " . CurrentVideoPositionString . " (" . CurrentVideoDurationString . ")", OptionsVideoPlayerText, HyperPause_SubMenu_Font, 0, 0)
        posHelpY := HyperPause_SubMenu_Height - HyperPause_SubMenu_SmallFontSize
        If(HSubMenuItem = 1){
            HelpTextLenghtWidth := MeasureText(0,"Press Up or Down to Select the Video and Left or Right to Control the Video Playing",HyperPause_SubMenu_HelpFont,HyperPause_SubMenu_HelpFontSize,"Regular")
            posHelpX := round(HyperPause_SubMenu_Width - HelpTextLenghtWidth/2 - HyperPause_SubMenu_AdditionalTextMarginContour)
            OptionsHelp = x%posHelpX% y%posHelpY% Center c%HyperPause_MainMenu_LabelDisabledColor% r4 s%HyperPause_SubMenu_HelpFontSize% Regular
            Gdip_FillRectangle(HP_G29, HyperPause_SubMenu_DisabledBrushV, HyperPause_SubMenu_Width - HelpTextLenghtWidth - 2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_Height- HyperPause_SubMenu_SmallFontSize, HelpTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_HelpFontSize)
            Gdip_TextToGraphics(HP_G29, "Press Up or Down to Select the Video and Left or Right to Control the Video Playing", OptionsHelp, HyperPause_SubMenu_HelpFont, 0, 0)
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
            HelpTextLenghtWidth := MeasureText(0,VideoHelpText,HyperPause_SubMenu_HelpFont,HyperPause_SubMenu_HelpFontSize,"Regular")
            posHelpX := round(HyperPause_SubMenu_Width - HelpTextLenghtWidth/2 - HyperPause_SubMenu_AdditionalTextMarginContour)
            OptionsHelp = x%posHelpX% y%posHelpY% Center c%HyperPause_MainMenu_LabelDisabledColor% r4 s%HyperPause_SubMenu_HelpFontSize% Regular
            Gdip_FillRectangle(HP_G29, HyperPause_SubMenu_DisabledBrushV, HyperPause_SubMenu_Width - HelpTextLenghtWidth - 2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_Height- HyperPause_SubMenu_SmallFontSize, HelpTextLenghtWidth+2*HyperPause_SubMenu_AdditionalTextMarginContour, HyperPause_SubMenu_HelpFontSize)
            Gdip_TextToGraphics(HP_G29, VideoHelpText, OptionsHelp, HyperPause_SubMenu_HelpFont, 0, 0)
        }
        UpdateLayeredWindow(HP_hwnd29, HP_hdc29, A_ScreenWidth - HyperPause_SubMenu_Width,A_ScreenHeight-HyperPause_SubMenu_Height,HyperPause_SubMenu_Width,HyperPause_SubMenu_Height)
    } Else {
        Gdip_GraphicsClear(HP_G29)     
        UpdateLayeredWindow(HP_hwnd29, HP_hdc29, A_ScreenWidth - HyperPause_SubMenu_Width,A_ScreenHeight-HyperPause_SubMenu_Height,HyperPause_SubMenu_Width,HyperPause_SubMenu_Height)            
    }
Return

  
SaveScreenshot:
    CoordMode, ToolTip
    ToolTip
    HyperPause_SaveScreenshotPath := HLMediaPath . "\Artwork\" . systemname . "\" . dbName . "\Screenshots\"
        IfNotExist, %HyperPause_SaveScreenshotPath%
            FileCreateDir, %HyperPause_SaveScreenshotPath%
    CurrentScreenshotFileName := HyperPause_SaveScreenshotPath . A_Now . ".bmp"
    pToken := Gdip_Startup()
    CaptureScreen(CurrentScreenshotFileName)
    ToolTip, Screenshot saved (%CurrentScreenshotFileName%), 0,A_ScreenHeight
    settimer,EndofToolTipDelay, -2000   
    If HyperPause_Loaded
        {
        If(HyperPause_ArtworkMenuEnabled="true"){
            ;reseting menu variables
            ArtworkList =
            Loop, % TotalSubMenuItemsArtwork
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
            ;recreating Artwork list
            MultiContentSubMenuList("Artwork")
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
                UpdateLayeredWindow(HP_hwnd25, HP_hdc25,0,round((A_ScreenHeight-HyperPause_MainMenu_BarHeight)/2)+HyperPause_MainMenu_BarVerticalOffset, A_ScreenWidth, HyperPause_MainMenu_BarHeight)
            }
        }
    }
Return

CaptureScreen(File)
{
	nL = 0 ;SysGet, nL, 76
	nT = 0 ;SysGet, nT, 77
	nW := A_ScreenWidth ;SysGet, nW, 78
	nH := A_ScreenHeight ;SysGet, nH, 79
	mDC := DllCall("CreateCompatibleDC", "Uint", 0)
	hBM := CreateDIBSection(nW, nH, mDC)
	oBM := DllCall("SelectObject", "Uint", mDC, "Uint", hBM)
	hDC := DllCall("GetDC", "Uint", 0)
	DllCall("BitBlt", "Uint", mDC, "int", 0, "int", 0, "int", nW, "int", nH, "Uint", hDC, "int", nL, "int", nT, "Uint", 0x40000000 | 0x00CC0020)
	DllCall("ReleaseDC", "Uint", 0, "Uint", hDC)
	DllCall("SelectObject", "Uint", mDC, "Uint", oBM)
	DllCall("DeleteDC", "Uint", mDC)
	SaveHBITMAPToFile(hBM, File)
}


SaveHBITMAPToFile(hBitmap, sFile)
{
	DllCall("GetObject", "Uint", hBitmap, "int", VarSetCapacity(oi,84,0), "Uint", &oi)
    hFile:=	DllCall("CreateFile", "Uint", &sFile, "Uint", 0x40000000, "Uint", 0, "Uint", 0, "Uint", 2, "Uint", 0, "Uint", 0)
	DllCall("WriteFile", "Uint", hFile, "int64P", 0x4D42|14+40+NumGet(oi,44)<<16, "Uint", 6, "UintP", 0, "Uint", 0)
	DllCall("WriteFile", "Uint", hFile, "int64P", 54<<32, "Uint", 8, "UintP", 0, "Uint", 0)
	DllCall("WriteFile", "Uint", hFile, "Uint", &oi+24, "Uint", 40, "UintP", 0, "Uint", 0)
	DllCall("WriteFile", "Uint", hFile, "Uint", NumGet(oi,20), "Uint", NumGet(oi,44), "UintP", 0, "Uint", 0)
	DllCall("CloseHandle", "Uint", hFile)
}

EndofToolTipDelay:
	ToolTip
Return


;Mouse Control
hpMouseClick:
    submenuMouseClickChange := 1
    Gdip_GraphicsClear(HP_G32)
    If (FullScreenView = 1)
        Gdip_DrawImage(HP_G32, MouseFullScreenOverlayBitmap, 0, 0, MouseOverlayW, MouseOverlayH)
    Else
        Gdip_DrawImage(HP_G32, MouseOverlayBitmap, 0, 0, MouseOverlayW, MouseOverlayH)	
    Random, MouseRndmSound, 1, % MouseSoundsAr.MaxIndex()
    CoordMode, Mouse, Screen 
    MouseGetPos, ClickX, ClickY
    ;adjusting mouse position to image position:
    ClickX := ClickX
    ClickY := ClickY-A_ScreenHeight+MouseOverlayH
    If (FullScreenView = 1)
        MouseMaskColor := Gdip_GetPixel( MouseFullScreenMaskBitmap, ClickX, ClickY)
    Else
        MouseMaskColor := Gdip_GetPixel( MouseMaskBitmap, ClickX, ClickY)	
    SetFormat Integer, Hex
    MouseMaskColor += 0
    SetFormat Integer, D
    Log("xxx" ClickX "xxx" ClickY,5) 
    If (MouseMaskColor=0xFFFF0000) {
        Gdip_DrawImage(HP_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay % HyperPause_MouseSoundPath . MouseSoundsAr[MouseRndmSound]
        gosub, MoveUp
    } Else If (MouseMaskColor=0xFF00FFFF) {
        Gdip_DrawImage(HP_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay % HyperPause_MouseSoundPath . MouseSoundsAr[MouseRndmSound]
        gosub, MoveRight
    } Else If (MouseMaskColor=0xFF0000FF) {
        Gdip_DrawImage(HP_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay % HyperPause_MouseSoundPath . MouseSoundsAr[MouseRndmSound]
        gosub, MoveDown
    } Else If (MouseMaskColor=0xFF00FF00) {
        Gdip_DrawImage(HP_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay % HyperPause_MouseSoundPath . MouseSoundsAr[MouseRndmSound]
        gosub, MoveLeft
    } Else If (MouseMaskColor=0xFFFF00FF) {
        Gdip_DrawImage(HP_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay % HyperPause_MouseSoundPath . MouseSoundsAr[MouseRndmSound]
        gosub, ToggleItemSelectStatus
    } Else If (MouseMaskColor=0xFFFFFF00) {
        Gdip_DrawImage(HP_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay % HyperPause_MouseSoundPath . MouseSoundsAr[MouseRndmSound]
        gosub, TogglePauseMenuStatus
    } Else If (MouseMaskColor=0xFFFF6400) {
        Gdip_DrawImage(HP_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay % HyperPause_MouseSoundPath . MouseSoundsAr[MouseRndmSound]
        gosub, BacktoMenuBar
    } Else If (MouseMaskColor=0xFF00FF64) {
        Gdip_DrawImage(HP_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay % HyperPause_MouseSoundPath . MouseSoundsAr[MouseRndmSound]
        gosub, SaveScreenshot
    } Else If (MouseMaskColor=0xFF6400FF) {
        Gdip_DrawImage(HP_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay % HyperPause_MouseSoundPath . MouseSoundsAr[MouseRndmSound]
        gosub, ZoomIn
    } Else If (MouseMaskColor=0xFF0064FF) {
        Gdip_DrawImage(HP_G32, MouseClickImageBitmap, ClickX-MouseClickImageW//2, ClickY-MouseClickImageH//2, MouseClickImageW, MouseClickImageH)
        If MouseSoundsAr.MaxIndex()
            SoundPlay % HyperPause_MouseSoundPath . MouseSoundsAr[MouseRndmSound]
        gosub, ZoomOut
    }
    UpdateLayeredWindow(HP_hwnd32, HP_hdc32,0,A_ScreenHeight-MouseOverlayH, MouseOverlayW, MouseOverlayH,HyperPause_MouseControlTransparency)
    settimer, ClearMouseClickImages, -500
Return


ClearMouseClickImages:
    Gdip_GraphicsClear(HP_G32)
    If (FullScreenView = 1)
        Gdip_DrawImage(HP_G32, MouseFullScreenOverlayBitmap, 0, 0, MouseOverlayW, MouseOverlayH)
    Else
        Gdip_DrawImage(HP_G32, MouseOverlayBitmap, 0, 0, MouseOverlayW, MouseOverlayH)	
    UpdateLayeredWindow(HP_hwnd32, HP_hdc32,0,A_ScreenHeight-MouseOverlayH, MouseOverlayW, MouseOverlayH,HyperPause_MouseControlTransparency)        
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
