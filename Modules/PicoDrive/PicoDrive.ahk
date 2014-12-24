MEmu = PicoDrive
MEmuV =  v1.45a
MURL = http://notaz.gp2x.de/pico.php
MAuthor = bleasby
MVersion = 2.0.2
MCRC = A2E6897C
iCRC = 34905C0E
mId = 635083171511164818
MSystem = "Sega Pico"
;----------------------------------------------------------------------------
; Notes:
; Sega Pico games have three windows: the game window, the storywave and the drawing pad. For better gameplay please enable the HyperLaunch bezel feature. 
; The bezel overlay feature is not supported for the three screens mode. 
; If you use the provided bezel images in resolutions lower then 1360x768, some parts of the game window could be clipped out of the screen. For better gameplay experience resize the bezel image to fill your screen resolution and update the pixel positions at the bezel.ini file or set the option ChangeRes to true. This cannot be done automatically by HyperLaunch because this emulator does not allow to resize the storywave and the drawing pad. You should keep their sizes at the provided pixel dimensions and just resize the main game screen.
; The ChangeRes option will change your monitor screen resolution before creating the bezel image and restore it after. If the restored resolution does not corresponds to your native monitor resolution, please change the nativeScreenWidth and nativeScreenHeigth variables to the desired monitor resolution.   
; If you want to restore the screen to a different resolution from the one automatically detected one while ChangeRes is set to true, please fill the variable desired ScreenRes with the width|height|quality|frequency info (for example: 1280|1024|32|60 for 1280x1024 pixels with 32 bit colors and 60Hz frequency).
; To use use different Game Pad images, create a folder in your emulator folder\pico\GamePads and save the image as romName.png - with romName being the name of the game you are using it for  
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
ChangeRes := IniReadCheck(settingsFile, "Settings", "ChangeRes","false",,1)		;	Resize your monitor resolution to the bezel image size. 
desiredScreenRes := IniReadCheck(settingsFile, "Settings", "ScreenRes","",,1)	;	Desired Monitor Screen resolution restore after the gameplay
bezelTopOffsetScreen1 := IniReadCheck(settingsFile, "Settings", "Bezel_Top_Offset_Screen_1","29",,1)
storywarePageUPKey := IniReadCheck(settingsFile, "Settings", "Storyware_Page_UP_Key","M",,1)
picoStorywarePageDown := IniReadCheck(settingsFile, "Settings", "Storyware_Page_Down_Key","N",,1)

hideEmuObj := Object("Drawing Pad ahk_class PicoPadWnd",1,"Storyware ahk_class PicoSwWnd",1,"ahk_class PicoMainFrame",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

BezelStart(3)

If bezelPath
{	If (ChangeRes = "true")
	{	ScreenResToBeRestored := desiredScreenRes ? desiredScreenRes : CurrentDisplaySettings(0)
		ScreenResToBeRestored := CheckForNearestSupportedRes( ScreenResToBeRestored )
		StringSplit, ScreenResToBeRestoredArray, ScreenResToBeRestored , |,	; ResArray1 - width, ResArray2 - height, ResArray3 - color, ResArray4 - frequency,
		bezelRes := CheckForNearestSupportedRes( bezelImageW . "|" . bezelImageH . "|" . ScreenResToBeRestoredArray3 . "|" ScreenResToBeRestoredArray4 )
		StringSplit, bezelResArray, bezelRes , |,	; ResArray1 - width, ResArray2 - height, ResArray3 - color, ResArray4 - frequency
		ChangeDisplaySettings(bezelResArray1,bezelResArray2,bezelResArray3,bezelResArray4)
	}
}

picoStorywareCurrentPage := 0
XHotKeywrapper(storywarePageUPKey,"picoStorywarePageUP")
XHotKeywrapper(picoStorywarePageDown,"picoStorywarePageDown")

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("ahk_class PicoMainFrame")
WinWaitActive("ahk_class PicoMainFrame")

If bezelPath
{	Screen1class := "ahk_class PicoMainFrame"
	Screen2class := "Storyware ahk_class PicoSwWnd"
	Screen2class := "Drawing Pad ahk_class PicoPadWnd"
	Screen1ID := WinExist(Screen1class)
	Screen2ID := WinExist("Storyware")
	Screen3ID := WinExist("Drawing")
}

BezelDraw()
HideEmuEnd()
FadeInExit()

Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()

If bezelPath
{	If (ChangeRes = "true")
		ChangeDisplaySettings(ScreenResToBeRestoredArray1,ScreenResToBeRestoredArray2,ScreenResToBeRestoredArray3,ScreenResToBeRestoredArray4)
}

ExitModule()


BezelLabel:
	disableHideToggleMenuScreen1 := true
	disableHideToggleMenuScreen2 := true
	disableHideToggleMenuScreen3 := true
Return

PicoStorywarePageUP:
	Loop
	{	picoStorywareCurrentPage++
		If picoStorywareCurrentPage
			WinMenuSelectItem, ahk_class PicoMainFrame, , Pico, Page %picoStorywareCurrentPage%
		If !ErrorLevel
			Break 
		Else 
			picoStorywareCurrentPage := picoStorywareCurrentPage-1
	}
Return

PicoStorywarePageDown:
	picoStorywareCurrentPage--
	If (picoStorywareCurrentPage < 0)
		picoStorywareCurrentPage := 0
	If picoStorywareCurrentPage
		WinMenuSelectItem, ahk_class PicoMainFrame, , Pico, Page %picoStorywareCurrentPage%
	Else
		WinMenuSelectItem, ahk_class PicoMainFrame, , Pico, Title
Return

CloseProcess:
	FadeOutStart()
	WinClose("Open ahk_class #32770")
	WinClose("Error ahk_class #32770")
	WinClose("ahk_class PicoMainFrame")
Return
