MEmu = FoFiX
MEmuV = v3.121
MURL = https://code.google.com/p/fofix/
MAuthor = djvj
MVersion = 2.0
MCRC = CC70FB83
iCRC = 36E1AE20
MID = 635038268891843865
MSystem = "Frets on Fire X"
;----------------------------------------------------------------------------
; Notes:
; This module allows you to put your themes anywhere you want. Just keep at least one theme in the default location otherwise FoFiX will dump an error
; Set your rom path to the folder you store your themes in. The default is EMU\data\themes\ folder.
; in your rom folder, place a blank txt file named to each game name you have in your xml
; The folder names in the above theme folder must match the game name from your xml. You can consider these your "roms"
; Songs must reside in the "data\songs" folder
; If fullscreen mode is used, FoFiX destroys the fade gui and Hyperspin may pop back into view for a moment.
; If fullscreen is false, the module will remove the titlebar and border of the window to give a look of fullscreen and fade support will still work. Make sure you set the resolution to match your desktop though.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
Resolution := IniReadCheck(settingsFile, "Settings", "Resolution",A_ScreenWidth . "x" . A_ScreenHeight,,1)	; Must be in format WIDTHxHEIGHT (example: 1024x768) default is your primary screen's width and height

7z(romPath, romName, romExtension, 7zExtractPath)

theme := "-t """ . romPath . "\" . romName . """"
fs := If Fullscreen = "true" ? ("-f true") : ("-f false")
resolution := Resolution ? ("-r " . Resolution) : ("-r " . Resolution)

Run(executable . " " . theme . " " . resolution . " " . fs, emuPath)

WinWait("FoFiX ahk_class pygame")
WinWaitActive("FoFiX ahk_class pygame")

If Fullscreen != true
{	WinSet, Style, -0xC00000, FoFiX ahk_class pygame ; Removes the TitleBar
	WinSet, Style, -0x40000, FoFiX ahk_class pygame ; Removes the border of the game window
}

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("FoFiX ahk_class pygame")
Return
