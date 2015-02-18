MEmu = Fusion
MEmuV =  v3.64
MURL = http://www.eidolons-inn.net/tiki-index.php?page=Kega
MAuthor = djvj
MVersion = 2.1.0
MCRC = F512EFED
iCRC = C78F8D9A
MID = 635038268893895568
MSystem = "Samsung Gam Boy","Sega 32X","Sega CD","Sega Game Gear","Sega Genesis","Sega Master System","Sega Mega Drive","Sega Mega-CD","Sega Pico","Sega SC-3000","Sega SG-1000"
;----------------------------------------------------------------------------
; Notes:
; Don't forget to setup your bios or you might just get a black screen.
; Set your fullscreen resolution by going to Video->Full Screen Resolution
; Fusion only supports 4 different windowed resolutions. If you don't use fullscreen, set the one you want by going to Video->Window Size
; Esc is Fusion's default key to go Fullscreen/Windowed mode. This cannot be changed, but this module will still close if you use Esc to exit. You may see the emu leave fullscreen first though.
; Esc can also cause Fusion to change its fullscreen mode on exit, causing it to lockup for 5-10 seconds. The only fix for this is to not use Esc as your exit key.
; For Sega CD, make sure your cues are correctly pointing to all the tracks or else you will not get sound. Also turn off auto-play for CDs
;
; Sega CD
; Configure your Sega CD bios first by going to Options -> Set Config -> Sega CD
; Set the scsi drive you want to use manually by going to Options -> CD Drive and seleting the one that corresponds to your scsi drive in DT. A dt drive is not supported by the emu, it must be scsi.
;
; Defining per-game controller types:
; In the module ini, set Controller_Reassigning_Enabled to true
; Default_P1_Controller and Default_P2_Controller should be set to the controller type you normally use for games not listed in the ini
; Make a new ini section with the name of your rom in your database, for example [Super Scope 6 (USA)]
; Under this section you can have 2 keys, P1_Controller and P2_Controller
; For P1_Controller - 0=None, 1=Gamepad, 2=Multitap, 3=Mouse, 4=Serial USART
; For P2_Controller - 0=None, 1=Gamepad, 2=Multitap, 3=Mouse, 4=Super Scope, 5=Justifier, 6=Dual Justifiers, 7=Serial USART
;
; Some games will not work if you have Teamplayer or 4way play active all the time, so you can set the MultiTapType for those problematic games in the module settings for each of these games.
;
; Windows 8 and 8.1 users:
; You may experience an issue with Fusion never getting higher than 33.5fps. Use Ctrl+F to bring up the FPS counter in Fusion to check if you are affected. This is caused by some compatibility changes Microsoft made for DirectDraw applications. There are two ways of fixing this issue:
; 1) Apply a compatibility patch for the Fusion executable using the Microsoft Application Compatibility Toolkit
; 2) Copy a prepatched ddraw.dll into the Fusion directory.
; Using the Microsoft Application Compatibility Toolkit is a cleaner fix but takes a few minutes to go through the steps to apply. Using the prepatched ddraw.dll file is quick and simple but may break the right-click menus when in full-screen mode, requiring you to make all configuration changes with the emulator windowed.
; Both methods are fully detailed with downloads, instructions and screenshots at http://www.blitzbasic.com/Community/post.php?topic=99477&post=1202630
;----------------------------------------------------------------------------
StartModule()
If InStr(systemName, "Pico")
	StorywaveOverlayGUI()
BezelGUI()
FadeInStart()

; The object controls how the module reacts to different systems. Fusion can play a lot of systems, but changes itself slightly so this module has to adapt 
mType := Object("Samsung Gam Boy","sms","Sega 32X","32X","Sega CD","scd","Sega Mega-CD","scd","Sega Game Gear","gg","Sega Genesis","gen","Sega Mega Drive","gen","Sega Master System","sms","Sega Pico","gen","Sega SC-3000","sms","Sega SG-1000","sms")
ident := mType[systemName]	; search 1st array for the systemName identifier mednafen uses
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this Fusion module: " . moduleName)

Log("Module - Started reading module ini")

IfExist, % modulePath . "\" . systemName . ".ini"	; use a custom systemName ini if it exists
	settingsFile := modulePath . "\" . systemName . ".ini"
Else
	settingsFile := modulePath . "\" . moduleName . ".ini"

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
forceFullScreen32 := IniReadCheck(settingsFile, "Settings", "ForceFullScreen32","true",,1)
hideTitleBar := IniReadCheck(settingsFile, "Settings", "hideTitleBar","true",,1)	; Removes the border, titlebar, menubar, and centers the emu on your screen. Only need this if fullscreen is false
useRamCarts := IniReadCheck(settingsFile, "Settings", "UseRamCarts","true",,1)
controllerReassigningEnabled := IniReadCheck(settingsFile, "Settings", "Controller_Reassigning_Enabled","false",,1)
multiTapType := IniReadCheck(settingsFile, "Settings" . "|" . romName, "MultiTapType",0,,1)
DTWaitTime := IniReadCheck(settingsFile, systemName, "DTWaitTime","0",,1)
fluxAudioCD := IniReadCheck(settingsFile, systemName, "FluxAudioCD",,,1)	; audio CD for use when Flux is ran
fluxAudioCD := GetFullName(fluxAudioCD)	; convert relative path to absolute
perfectSync := IniReadCheck(settingsFile, romName, "PerfectSync","false",,1)
genP1Controller := IniReadCheck(settingsFile, "Controllers" . "|" . romName, "Genesis_P1_Controller",2,,1)
genP1bController := IniReadCheck(settingsFile, "Controllers" . "|" . romName, "Genesis_P1b_Controller",2,,1)
genP1cController := IniReadCheck(settingsFile, "Controllers" . "|" . romName, "Genesis_P1c_Controller",2,,1)
genP1dController := IniReadCheck(settingsFile, "Controllers" . "|" . romName, "Genesis_P1d_Controller",2,,1)
genP2Controller := IniReadCheck(settingsFile, "Controllers" . "|" . romName, "Genesis_P2_Controller",2,,1)
genP2bController := IniReadCheck(settingsFile, "Controllers" . "|" . romName, "Genesis_P2b_Controller",2,,1)
genP2cController := IniReadCheck(settingsFile, "Controllers" . "|" . romName, "Genesis_P2c_Controller",2,,1)
genP2dController := IniReadCheck(settingsFile, "Controllers" . "|" . romName, "Genesis_P2d_Controller",2,,1)
smsP1Controller := IniReadCheck(settingsFile, "Controllers" . "|" . romName, "SMS_P1_Controller",1,,1)
smsP2Controller := IniReadCheck(settingsFile, "Controllers" . "|" . romName, "SMS_P2_Controller",1,,1)
genP1Use := IniReadCheck(settingsFile, "Controllers" . "|" . romName, "Genesis_P1_Use",1,,1)
genP1bUse := IniReadCheck(settingsFile, "Controllers" . "|" . romName, "Genesis_P1b_Use",1,,1)
genP1cUse := IniReadCheck(settingsFile, "Controllers" . "|" . romName, "Genesis_P1c_Use",1,,1)
genP1dUse := IniReadCheck(settingsFile, "Controllers" . "|" . romName, "Genesis_P1d_Use",1,,1)
genP2Use := IniReadCheck(settingsFile, "Controllers" . "|" . romName, "Genesis_P2_Use",1,,1)
genP2bUse := IniReadCheck(settingsFile, "Controllers" . "|" . romName, "Genesis_P2b_Use",1,,1)
genP2cUse := IniReadCheck(settingsFile, "Controllers" . "|" . romName, "Genesis_P2c_Use",1,,1)
genP2dUse := IniReadCheck(settingsFile, "Controllers" . "|" . romName, "Genesis_P2d_Use",1,,1)
smsP1Use := IniReadCheck(settingsFile, "Controllers" . "|" . romName, "SMS_P1_Use",1,,1)
smsP2Use := IniReadCheck(settingsFile, "Controllers" . "|" . romName, "SMS_P2_Use",1,,1)

StorywaveOverlayPath := IniReadCheck(settingsFile, "Settings", "Storywave_Overlay_Path",emuPath . "\Overlays\" . dbName,,1)
toggleStorywaveOverlayKey := IniReadCheck(settingsFile, "Settings", "Toggle_Storywave_Overlay_Visibility_Key","X",,1) ; Show Overlay
downStorywaveOverlayKey := IniReadCheck(settingsFile, "Settings", "Storywave_Overlay_Page_Down_Key","Z",,1)  ; Previous Page
upStorywaveOverlayKey := IniReadCheck(settingsFile, "Settings", "Storywave_Overlay_Page_Up_Key","C",,1)   ; Next Page
resetStorywaveOverlayKey := IniReadCheck(settingsFile, "Settings", "Storywave_Overlay_Reset_Page_Key","R",,1)   ; Reset Storywave to Initial Page
StorywaveOverlayTransparency := IniReadCheck(settingsFile, "Settings", "Storywave_Overlay_Transparency","50",,1) ; Overlay Transparency

Log("Module - Finished reading module ini")

BezelStart()

fusionFile := CheckFile(emuPath . "\fusion.ini")
fusionIni := LoadProperties(fusionFile)	; load the config into memory
currentFullScreen := ReadProperty(fusionIni,"FullScreen")	; read current fullscreen state
currentForceFullScreen32 := ReadProperty(fusionIni,"forceFullScreen32")	; read current ForceFullScreen32 state
currentPerfectSync := ReadProperty(fusionIni,"PerfectSync")	; read current PerfectSync state

hideEmuObj := Object("Load RAM Cart ahk_class #32770",0,"Create RAM Cart ahk_class #32770",0,"Select RAM Cart Size ahk_class #32770",0,"Fusion ahk_class KegaClass",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

If romExtension in .7z,.rar
	ScriptError(MEmu . " only supports uncompressed or zip compressed roms. Please enable 7z support in HLHQ to use this module/emu for this extension: """ . romExtension . """")

If ( Fullscreen != "true" And currentFullScreen = "1" ) {
	WriteProperty(fusionIni,"FullScreen", 0)
	If controllerReassigningEnabled != true	; no need to save file if it's going to be written later
		SaveProperties(fusionFile,fusionIni)	; save fusionFile to disk
} Else If ( Fullscreen = "true" And currentFullScreen = "0" ) {
	WriteProperty(fusionIni,"FullScreen", 1)
	If controllerReassigningEnabled != true	; no need to save file if it's going to be written later
		SaveProperties(fusionFile,fusionIni)	; save fusionFile to disk
}

If ( forceFullScreen32 != "true" And currentForceFullScreen32 = "1" ) {
	WriteProperty(fusionIni,"ForceFullScreen32", 0)
	If controllerReassigningEnabled != true	; no need to save file if it's going to be written later
		SaveProperties(fusionFile,fusionIni)	; save fusionFile to disk
} Else If ( forceFullScreen32 = "true" And currentForceFullScreen32 = "0" ) {
	WriteProperty(fusionIni,"ForceFullScreen32", 1)
	If controllerReassigningEnabled != true	; no need to save file if it's going to be written later
		SaveProperties(fusionFile,fusionIni)	; save fusionFile to disk
}

If ( perfectSync != "true" And currentPerfectSync = "1" ) {
	WriteProperty(fusionIni,"PerfectSync", 0)
	If controllerReassigningEnabled != true	; no need to save file if it's going to be written later
		SaveProperties(fusionFile,fusionIni)	; save fusionFile to disk
} Else If ( perfectSync = "true" And currentPerfectSync = "0" ) {
	WriteProperty(fusionIni,"PerfectSync", 1)
	If controllerReassigningEnabled != true	; no need to save file if it's going to be written later
		SaveProperties(fusionFile,fusionIni)	; save fusionFile to disk
}

hideEmu := If Fullscreen = "true" ? "Hide" : ""
fullscreen := If Fullscreen = "true" ? " -fullscreen" : ""

If bezelPath ; Setting windowed mode resolution
{	WriteProperty(fusionIni,"GameGearZoom", 1) ; disabling emulator default bezel
	If controllerReassigningEnabled != true	; no need to save file if it's going to be written later
		SaveProperties(fusionFile,fusionIni)	; save fusionFile to disk
}

 ; Allows you to set on a per-rom basis the controller type plugged into controller ports 1 and 2
If controllerReassigningEnabled = true
{	Log("Module - Started reassigning Fusion's ini controls")
	WriteProperty(fusionIni,"MultiTapType", multiTapType)	; sets MultiTap
	WriteProperty(fusionIni,"Joystick1Type", genP1Controller)	; sets controls for P1
	WriteProperty(fusionIni,"Joystick1bType", genP1bController)	; sets controls for P1b
	WriteProperty(fusionIni,"Joystick1cType", genP1cController)	; sets controls for P1c
	WriteProperty(fusionIni,"Joystick1dType", genP1dController)	; sets controls for P1d
	WriteProperty(fusionIni,"Joystick2Type", genP2Controller)	; sets controls for P2
	WriteProperty(fusionIni,"Joystick2bType", genP2bController)	; sets controls for P2b
	WriteProperty(fusionIni,"Joystick2cType", genP2cController)	; sets controls for P2c
	WriteProperty(fusionIni,"Joystick2dType", genP2dController)	; sets controls for P2d
	WriteProperty(fusionIni,"Joystick1MSType", smsP1Controller)	; sets controls for sms P1
	WriteProperty(fusionIni,"Joystick2MSType", smsP2Controller)	; sets controls for sms P2
	WriteProperty(fusionIni,"Joystick1Using", genP1Use)	; sets controls for P1
	WriteProperty(fusionIni,"Joystick1bUsing", genP1bUse)	; sets controls for P1b
	WriteProperty(fusionIni,"Joystick1cUsing", genP1cUse)	; sets controls for P1c
	WriteProperty(fusionIni,"Joystick1dUsing", genP1dUse)	; sets controls for P1d
	WriteProperty(fusionIni,"Joystick2Using", genP2Use)	; sets controls for P2
	WriteProperty(fusionIni,"Joystick2bUsing", genP2bUse)	; sets controls for P2b
	WriteProperty(fusionIni,"Joystick2cUsing", genP2cUse)	; sets controls for P2c
	WriteProperty(fusionIni,"Joystick2dUsing", genP2dUse)	; sets controls for P2d
	WriteProperty(fusionIni,"Joystick1MSUsing", smsP1Use)	; sets controls for sms P1
	WriteProperty(fusionIni,"Joystick2MSUsing", smsP2Use)	; sets controls for sms P2
	SaveProperties(fusionFile,fusionIni)	; save fusionFile to disk
	Log("Module - Finished reassigning Fusion's ini controls")
}

fluxRom := InStr(romName, "flux")	; test if this game is Flux, a special case game that requires an Audio CD to be mounted
If fluxRom {
	Log("Module - Mounting the Audio CD because """ . romName . """ requires one to function.")
	ident := "gen"	; change ident to gen because Flux has to be mounted as a Genesis rom
	DaemonTools("mount", fluxAudioCD)	; mount the Audio CD the user has set in the module settings
}

scdExtension := InStr(".ccd|.cue|.bin|.iso", romExtension)	; the sega cd extensions supported by fusion

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

If (ident = "scd" && dtEnabled = "true" && scdExtension) {
	If dtUseSCSI = false
		Log("Module - Daemon Tools drive type is set to ""dt"" but only ""scsi"" is supported for Fusion. Forcing scsi drive.", 2)
	DaemonTools("mount", romPath . "\" . romName . romExtension, (If dtUseSCSI = "false" ? "scsi" : ""))
	Sleep, DTWaitTime
	Run(executable . " -auto -" . ident . " " . fullscreen, emuPath, hideEmu)
} Else {
	If (ident = "scd" && dtEnabled = "true" && !scdExtension)
		Log("Module - " . romExtension . " is not a supported cd image extension for Fusion. Launching Fusion without DT support.", 2)
	Run(executable . " -auto -" . ident . fullscreen . " """ . romPath . "\" . romName . romExtension . """", emuPath, hideEmu)
}

WinWait("Fusion ahk_class KegaClass")
WinWaitActive("Fusion ahk_class KegaClass")

If fluxRom
	PostMessage, 0x111, 40009,,,ahk_class KegaClass	; Runs the Boot Sega-CD command to load the Audio CD that should be mounted in DT already

If (ident = "scd" && useRamCarts = "true")	; Sega CD or Mega CD only
{	brmPath := ReadProperty(fusionIni,"BRMFiles")		; read BRM path
	IfNotExist, %brmPath%
		FileCreateDir, %brmPath%	; create brmPath if it does not exist
	selectRamWin := "Select RAM Cart Size ahk_class #32770"
	createRamWin := "Create RAM Cart ahk_class #32770"
	loadRamWin := "Load RAM Cart ahk_class #32770"
	; Create New Ram Cart if it doesn't exist already
	IfNotExist, %brmPath%\%romName%.crm
	{	PostMessage, 0x111, 40036,,,ahk_class KegaClass	; Open Create New Ram Cart Window
		WinWait, %selectRamWin%
		WinSet, Transparent, On, %selectRamWin%
		Control, Check,, Button7, %selectRamWin%
		ControlSend, Button1, {Enter}, %selectRamWin%
		OpenROM(createRamWin, brmPath . "\" . romName . ".crm")
	}
	; Now load the Ram Cart
	PostMessage, 0x111, 40035,,,ahk_class KegaClass	; Open Load Ram Cart Window
	OpenROM(loadRamWin, brmPath . "\" . romName . ".crm")
}

WinWaitActive("Fusion ahk_class KegaClass")

Loop { ; looping until Fusion is done loading game
	Sleep, 200
	WinGetTitle, winTitle, Fusion ahk_class KegaClass
	StringSplit, T, winTitle, %A_Space%
	If (T3 = "-")
		Break
	If (A_Index > 75) {
		Log("Module - Timed out detecting that a game was loaded in Fusion. There may be a problem with the emu loading your game." . (If ident = "scd" ? "You need to make sure you select the proper CD drive manually in Fusion first by going to Options -> CD Drive":""),3)
		Break
	}
}

If hideTitleBar = true
{	WinSet, Style, -0x40000, Fusion ahk_class KegaClass ; Removes the border of the game window
	WinSet, Style, -0xC00000, Fusion ahk_class KegaClass ; Removes the TitleBar
	DllCall("SetMenu", uint, WinActive( "A" ), uint, 0) ; Removes the MenuBar
	If bezelEnabled != true
		Center(Fusion ahk_class KegaClass)
}

BezelDraw()
If InStr(systemName, "Pico")
	StorywaveOverlayLoad()
HideEmuEnd()
FadeInExit()

If InStr(systemName, "Pico")
	PostMessage, 0x111, 40183,,,ahk_class KegaClass	; tell Kega Fusion to capture mouse input

Process("WaitClose", executable)

If (fluxRom || (ident = "scd" && dtEnabled = "true" && scdExtension))
	DaemonTools("unmount")

7zCleanUp()
StorywaveOverlayExit()
BezelExit()
FadeOutExit()
ExitModule()


Center(title) {
	WinGetPos, X, Y, width, height, %title%
	x := ( A_ScreenWidth / 2 ) - ( width / 2 )
	y := ( A_ScreenHeight / 2 ) - ( height / 2 )
	WinMove, %title%, , x, y
}

MultiGame:
	; msgbox % "selectedRom = " . selectedRom . "`nselected game = " . currentButton . "`nmgRomPath = " . mgRomPath . "`nmgRomExt = " . mgRomExt . "`nmgRomName = "  . mgRomName
	; Unmount the CD from DaemonTools
	If ( scdExtension && dtEnabled = "true" )
		DaemonTools("unmount")
	Sleep, 500	; Required to prevent  DT from bugging
	; Mount the CD using DaemonTools
	If ( scdExtension && dtEnabled = "true" )
		DaemonTools("mount", selectedRom)
Return

CloseProcess:
	FadeOutStart()
	WinClose("Fusion ahk_class KegaClass")
	; PostMessage, 0x111, 40039,,,ahk_class KegaClass	; Tells Fusion to Power Off
	; Sleep, 100	; giving time for Fusion to unload rom
	; PostMessage, 0x111, 40005,,,ahk_class KegaClass	; Tells Fusion to exit
Return



;_______________Storywave Overlay__________________________

StorywaveOverlayGUI(){
	Global
	If !pToken
		pToken := Gdip_Startup()
	Gui, StorywaveOverlay_GUI: +Disabled -Caption +E0x80000 +OwnDialogs +LastFound +ToolWindow +AlwaysOnTop
	Gui, StorywaveOverlay_GUI: Margin,0,0
	Gui, StorywaveOverlay_GUI: Show,, StorywaveOverlay_Layer
	StorywaveOverlay_hwnd := WinExist()
	StorywaveOverlay_hbm := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
	StorywaveOverlay_hdc := CreateCompatibleDC()
	StorywaveOverlay_obm := SelectObject(StorywaveOverlay_hdc, StorywaveOverlay_hbm)
	StorywaveOverlay_G := Gdip_GraphicsFromhdc(StorywaveOverlay_hdc)
	Gdip_SetSmoothingMode(StorywaveOverlay_G, 4)
	Return
}

StorywaveOverlayLoad(){
	Global
	StorywaveOverlayArray := []
	Loop, % StorywaveOverlayPath . "\*.png"
		StorywaveOverlayArray.Insert(A_LoopFileFullPath)
	if (StorywaveOverlayArray.MaxIndex() > 0)
	{
		WinGet emulatorID, ID, A
		WinGetPos, emuX, emuY, emuW, emuH, ahk_id %emulatorID%
		currentStorywaveOverlay := 1
		StorywaveOverlayDraw := false
		XHotKeywrapper(toggleStorywaveOverlayKey,"toggleStorywaveOverlay","ON") 
		XHotKeywrapper(upStorywaveOverlayKey,"upStorywaveOverlay","ON")
		XHotKeywrapper(downStorywaveOverlayKey,"downStorywaveOverlay","ON")
		XHotKeywrapper(resetStorywaveOverlayKey,"resetStorywaveOverlay","ON")
	}
	Return
}

StorywaveOverlayExit(){
	Global
	SelectObject(StorywaveOverlay_hdc,StorywaveOverlay_obm)
	DeleteObject(StorywaveOverlay_hbm)
	DeleteDC(StorywaveOverlay_hdc)
	Gdip_DeleteGraphics(StorywaveOverlay_G)
	Gui, StorywaveOverlay_GUI: Destroy
	Gdip_DisposeImage(StorywaveOverlayBitmap)
	Return
}

StorywaveOverlayHide(){
	Global
	Gdip_GraphicsClear(StorywaveOverlay_G)
	UpdateLayeredWindow(StorywaveOverlay_hwnd, StorywaveOverlay_hdc,emuX,emuY, emuW, emuH)
	StorywaveOverlayDraw := false
	Return
}

StorywaveOverlayShow(){
	Global
	Tooltip, "Current Page " %currentStorywaveOverlay%
	settimer,EndofCurrentPageToolTipDelay, -2000  
	Gdip_GraphicsClear(StorywaveOverlay_G)
	StorywaveOverlayBitmap := Gdip_CreateBitmapFromFile(StorywaveOverlayArray[currentStorywaveOverlay])
	Gdip_DrawImage(StorywaveOverlay_G, StorywaveOverlayBitmap, 0, 0,emuW,emuH)
	UpdateLayeredWindow(StorywaveOverlay_hwnd, StorywaveOverlay_hdc,emuX,emuY, emuW, emuH,StorywaveOverlayTransparency)
	StorywaveOverlayDraw := true
	Return
}

EndofCurrentPageToolTipDelay:
	ToolTip
Return

toggleStorywaveOverlay:
	If StorywaveOverlayDraw
		StorywaveOverlayHide()
	Else
		StorywaveOverlayShow()
Return

upStorywaveOverlay:
	currentStorywaveOverlay++
	If (currentStorywaveOverlay > StorywaveOverlayArray.MaxIndex())
		currentStorywaveOverlay--
	StorywaveOverlayShow()
Return

downStorywaveOverlay:
	currentStorywaveOverlay--
	If (currentStorywaveOverlay < 1)	; This variable cannot be lower than 1 (first page)
		currentStorywaveOverlay := 1
	StorywaveOverlayShow()
Return

resetStorywaveOverlay:
	currentStorywaveOverlay := 1
	StorywaveOverlayShow()
Return
