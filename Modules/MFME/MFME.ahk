MEmu = MFME
MEmuV = v3.2 & v9.4 & v10.1a
MURL = http://www.fruit-emu.com/
MAuthor = djvj
MVersion = 2.0.1
MCRC = DEE1A30F
iCRC = 85E674CF
MID = 635038268906095729
MSystem = "Fruit Machine","MFME"
;----------------------------------------------------------------------------
; Notes:
; MFME's different versions all support different games. No one version plays them all. Place all your MFME exes into your Emu_Path dir. Create one emu section for each of the 3 MFME versions used by this module in your Global Emulators or Emulators.ini
; Each game should be in its own dir. The dir name should match the game name from your database xml.
; Each game has a ".gam" file, It's name needs to match the name from the database. This is like a cue file that contains info about a game's settings and where to find the rest of the files.
; For example, if you have a game name of "Back To The Features" and when you extract the game it looks like this:
; 	Back To The Features\Back_To_The_Features.gam
; Rename it so it looks like this:
; 	Back To The Features\Back To The Features.gam
;
; Your Games.ini needs to have a section for each game that will not use your default emulator defined in Emulators.ini. This module supports MFME v3.2, 9.4, and 10.1a
; I would set MFME v10.1a as your default emulator.
; For each game that needs to use MFME v9.4, create a section like this:
; [Game 1]
; Emulator=MFME v9.4
; For each game that needs to use MFME v3.2, create a section like this:
; [Game 1]
; Emulator=MFME v3.2
; See the HyperLaunch site on how to use Games.ini for additional help

; If you use Magnifier mode, start it manually once and set it's view to Dock, then Exit
; If you want the script to be able to move and remove the border/title of the magnifier window, it has to be done as admin or you need to turn off UAC.
; Optionally you can set MagnifyWrapper.exe to run as admin if you are on win7 or greater and it will close Magnifier on exit
;
; MFME stores its settings in the registry @ HKEY_USERS\S-1-5-21-440413192-1003725550-97281542-1001\Software\CJW\MFME
; As far as I can tell, there is no way to go fullscreen (only v3.2 supports it)
;----------------------------------------------------------------------------
StartModule()

settingsFile := modulePath . "\" . moduleName . ".ini"
MinimizeWindows := IniReadCheck(settingsFile, "Settings", "MinimizeWindows","true",,1)
ResizeDesktop := IniReadCheck(settingsFile, "Settings", "ResizeDesktop","true",,1)
ResizeW := IniReadCheck(settingsFile, "Settings", "ResizeW","1280",,1)			; Do not change this, layouts are made to fit this size desktop
ResizeH := IniReadCheck(settingsFile, "Settings", "ResizeH","1024",,1)					; Do not change this, layouts are made to fit this size desktop
BackgroundPic := IniReadCheck(settingsFile, "Settings", "BackgroundPic",modulePath . "\Background.png",,1)
Magnify := IniReadCheck(settingsFile, "Settings", "Magnify","true",,1)			; Create a windows magnifier window in the bottom right corner to see things closer over your cursor
MagnifyPercentage := IniReadCheck(settingsFile, "Settings", "MagnifyPercentage","200",,1)
MagnifyWinSizeW := IniReadCheck(settingsFile, "Settings", "MagnifyWinSizeW","245",,1)
MagnifyWinSizeH := IniReadCheck(settingsFile, "Settings", "MagnifyWinSizeH","245",,1)
MagnifyWinPosX := IniReadCheck(settingsFile, "Settings", "MagnifyWinPosX",A_Space,,1)
MagnifyWinPosY := IniReadCheck(settingsFile, "Settings", "MagnifyWinPosY",A_Space,,1)
ambientSound := IniReadCheck(settingsFile, "Settings", "ambientSound","true",,1)
ambientSoundFile := IniReadCheck(settingsFile, "Settings", "ambientSoundFile",moduleExtensionsPath . "\Quiet atmosphere in a small restaurant (indistinct speech) - 1978 (1R8,reprocessed).mp3",,1)
ambientSoundPlayer := IniReadCheck(settingsFile, "Settings", "ambientSoundPlayer",moduleExtensionsPath . "\djAmbiencePlayer.exe",,1)
ambientStopKey := IniReadCheck(settingsFile, "Settings", "ambientStopKey","PAUSE",,1)
ResetKey := IniReadCheck(settingsFile, "Settings", "ResetKey","F12",,1)								; key to reset the game while playing


If ambientSound = true
{
	ambientSoundFile := CheckFile(ambientSoundFile)
	ambientSoundPlayer := CheckFile(ambientSoundPlayer)
	SplitPath, ambientSoundPlayer, ambientSoundPlayerName, ambientSoundPlayerPath
}

; This gets rid of the emu window that pops up on launch
; GUI creates the splash screen at launch. GUI 3 creates the background that persists during gameplay.
If fadeIn = true
{
	FadeInStart()
	Gui 5: +LastFound
	WinGet GUI_ID5, ID
	Gui 5: -AlwaysOnTop -Caption +ToolWindow
	Gui 5: Color, %loadingColor%
	Gdip_GetImageDimensions(BackgroundPic, backgroundPicW, backgroundPicH)
	backXPos := ( A_ScreenWidth / 2 ) - ( backgroundPicW / 2 )
	backYPos := ( A_ScreenHeight / 2 ) - ( backgroundPicH / 2 )
	Gui 5: Add, Picture,x%backXPos% y%backYPos%, %BackgroundPic%
	Gui 5: Show, x0 y0 h%A_ScreenHeight% w%A_ScreenWidth%
}

ResetKey := xHotKeyVarEdit(ResetKey,"ResetKey","~","Add")
xHotKeywrapper(ResetKey,"Reset")

If MinimizeWindows = true
	WinMinimizeAll

If resizeDesktop = true
{
	;Sleep, 1000 ; probably don't need this
	displaySettings := GetDisplaySettingsAlt() ; Retrieve current display settings
	StringSplit, displayArray, displaySettings, |
	ChangeDisplaySettings( displayArray1 , ResizeW , ResizeH )
	;Sleep, 1000 ; probably don't need this
}

7z(romPath, romName, romExtension, 7zExtractPath)

emuPID := Run(executable . " """ . romPath . "\"  . romName . romExtension . """", emuPath)

WinWait("ahk_class TForm1")
WinWaitActive("ahk_class TForm1")

WinSet, Style, -0xC00000, ahk_class TForm1		;Removes the titlebar of the game window
WinSet, Style, -0x40000, ahk_class TForm1		;Removes the border of the game window
DllCall("SetMenu", uint, WinActive( "A" ), uint, 0) 	;Removes the MenuBar
; Control, Hide, , TPanel, AHK_class TForm1		;Removes the TPanel - Doesn't seem to work
;WinSet, TransColor, F0F0F0, ahk_class TForm1 ; Removes the grey around the machine, but slightly darkens the overall image

WinActivate, ahk_class TForm1
WinWaitActive("ahk_class TForm1")

If Magnify = true
{
	Sleep, 500
	magnifierExe:=CheckFile(A_WinDir . "\system32\magnify.exe","Could not find Windows Magnifier in " . A_WinDir . "\system32\magnify.exe`nPlease disable it's use in the module, or copy it to the above folder.")
	magPID := Process("Exist", "magnify.exe")
	If magPID != 0
		Process("Close", "magnify.exe")
	If A_OSVersion not in WIN_2003, WIN_XP, WIN_2000, WIN_NT4, WIN_95, WIN_98, WIN_M
	{
	RootKey = HKCU
	SubKey = Software\Microsoft\ScreenMagnifier
	If (MagnifyWinPosX = "" or MagnifyWinPosX = "ERROR")	; places window in bottom right corner if not defined
		MagnifyWinPosX := A_ScreenWidth - MagnifyWinSizeW
	If (MagnifyWinPosY = "" or MagnifyWinPosX = "ERROR")
		MagnifyWinPosY := A_ScreenHeight - MagnifyWinSizeH
	MagnifyWinPosY := IniReadCheck(settingsFile, "Settings", "MagnifyWinPosY",(A_ScreenHeight - MagnifyWinSizeH),,1)
	regwrite, REG_DWORD ,%RootKey%,%SubKey%,MagnifierUIWindowMinimized, 1 			; start with ui minimized
	regwrite, REG_DWORD ,%RootKey%,%SubKey%,MagnificationMode, 1					;choosing docked mode
	regwrite, REG_DWORD ,%RootKey%,%SubKey%,ClassicDocked, 0 						;choosing classic window mode
	regwrite, REG_DWORD ,%RootKey%,%SubKey%,Magnification, %MagnifyPercentage% 		;Magnification Percentage
	regwrite, REG_DWORD ,%RootKey%,%SubKey%,ClassicWindowCX, %MagnifyWinSizeW%		;Window Width
	regwrite, REG_DWORD ,%RootKey%,%SubKey%,ClassicWindowCY, %MagnifyWinSizeH% 		;Window Height
	regwrite, REG_DWORD ,%RootKey%,%SubKey%,ClassicWindowX, %MagnifyWinPosX%		;Window Pos x
	regwrite, REG_DWORD ,%RootKey%,%SubKey%,ClassicWindowY, %MagnifyWinPosY% 		;Window Pos y
	}
	Run(magnifierExe) ;,, Min
	WinWait("ahk_class Screen Magnifier Window",,5)
	If ErrorLevel {
		SetKeyDelay, 50
		Send,^!d	; turning on docked mode - does not work w/o admin mode
		Sleep, 3000
	}
	WinWait("ahk_class Screen Magnifier Window",,6)
	If ErrorLevel {
		mfmeError=1
		Gosub, CloseProcess
	}
	XpBelow = false
	If A_OSVersion in WIN_2003,WIN_XP,WIN_2000,WIN_NT4,WIN_95,WIN_98,WIN_M
	{
		XpBelow = true
		WinSet, Style, -0xC00000, ahk_class Screen Magnifier Window		;Removes the titlebar of the magnifier window
		WinSet, Style, -0x40000, ahk_class Screen Magnifier Window		;Removes the border of the magnifier window
		WinMinimize, ahk_class MagUIClass
		WinMove, ahk_class Screen Magnifier Window,, %MagnifyWinPosX%, %MagnifyWinPosY%, %MagnifyWinSizeW%, %MagnifyWinSizeH% 
	} Else {
		;This is because of UAC control if it's turned off this will run much smoother
		errorLvl := Run("MagnifyWrapper.exe """ . executable . """", modulePath,"UseErrorLevel")
		If errorLvl {
			mfmeError=1
			Gosub, CloseProcess
		}
	}
}

If ambientSound = true
	Run(ambientSoundPlayerName . " """ . ambientSoundFile . """ " . ambientStopKey, ambientSoundPlayerPath)

FadeInExit()

; PID doesn't seem to work for MFME, so have to use this method instead
Process("WaitClose", executable)

If (Magnify = "true") And (XpBelow = "true")
	Process("Close","magnify.exe")

If ambientSound = true
	Process("Close", ambientSoundPlayerName)

;restore original resolution
If resizeDesktop = true
{	ChangeDisplaySettings( displayArray1 , displayArray2 , displayArray3 )
	Sleep, 1000
}

If MinimizeWindows = true
	WinMinimizeAllUndo

7zCleanUp()

If mfmeError {
	Sleep, 1000 ; giving some extra time in case desktop needs to be resized
	ScriptError("There was an error launching and docking the Magnifier window. Please manually start Magnifier and set it to docked view.")
}

FadeOutExit()
ExitModule()


Reset:
	Send !r
Return

CloseProcess:
	FadeOutStart()
	Sleep, 400
	; WinClose("MFME")
	; WinClose("ahk_pid " . emuPID)
	WinClose("ahk_class TForm1")
Return
