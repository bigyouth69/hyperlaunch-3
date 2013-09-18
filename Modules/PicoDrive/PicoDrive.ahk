MEmu = PicoDrive
MEmuV =  v1.45a
MURL = http://notaz.gp2x.de/pico.php
MAuthor = bleasby
MVersion = 2.0.2
MCRC = E2F8D6A1
iCRC = 51B176D4
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

7z(romPath, romName, romExtension, 7zExtractPath)

BezelStart(3)

If bezelPath
	{
	If ( ChangeRes = "true") {
		ScreenResToBeRestored := desiredScreenRes ? desiredScreenRes : CurrentDisplaySettings(0)
		ScreenResToBeRestored := CheckForNearestSupportedRes( ScreenResToBeRestored )
		StringSplit, ScreenResToBeRestoredArray, ScreenResToBeRestored , |,     ; ResArray1 - width, ResArray2 - height, ResArray3 - color, ResArray4 - frequency,
		bezelRes := CheckForNearestSupportedRes( bezelImageW . "|" . bezelImageH . "|" . ScreenResToBeRestoredArray3 . "|" ScreenResToBeRestoredArray4 )
		StringSplit, bezelResArray, bezelRes , |,     ; ResArray1 - width, ResArray2 - height, ResArray3 - color, ResArray4 - frequency,
		ChangeDisplaySettings(bezelResArray1,bezelResArray2,bezelResArray3,bezelResArray4)
	}
}

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("ahk_class PicoMainFrame")
WinWaitActive("ahk_class PicoMainFrame")

If bezelPath
	{
	Screen1class := "ahk_class PicoMainFrame"
	Screen2class := "Storyware ahk_class PicoSwWnd"
	Screen2class := "Drawing Pad ahk_class PicoPadWnd"
	Screen1ID := WinExist(Screen1class)
	Screen2ID := WinExist("Storyware")
	Screen3ID := WinExist("Drawing")
}

BezelDraw()
FadeInExit()

Process("WaitClose", executable)

7zCleanUp()
BezelExit()
FadeOutExit()

If bezelPath
	{
	If ( ChangeRes = "true")
		ChangeDisplaySettings(ScreenResToBeRestoredArray1,ScreenResToBeRestoredArray2,ScreenResToBeRestoredArray3,ScreenResToBeRestoredArray4)
}

ExitModule()

BezelLabel:
	disableHideToggleMenuScreen2 := true
	disableHideToggleMenuScreen3 := true
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class PicoMainFrame")
Return



