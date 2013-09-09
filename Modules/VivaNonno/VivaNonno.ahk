MEmu = VivaNonno
MEmuV = v22.0.3
MURL = http://vivanonno.vg-network.com/
MAuthor = djvj
MVersion = 2.0.1
MCRC = 67829F0C
iCRC = 92DAE2C4
MID = 635038268933548574
MSystem = "Namco System 22","VivaNonno"
;------------------------------------------------------------------------
; Notes:
; Roms must reside in the roms subdir of the emulator and be zipped. They must be built from the mame v0.112 romset, the current mame uses roms with a different crc
; Many of the emulator's settings are stored in settings.xml. This will only appear after you run a game. You can setup your analog controls here if you have any.
; Dat for roms can be found here: http://www.logiqx.com/Dats/OlderEmus/Older%20Emus%2020080420%20(xml).zip
;
; Default Controls:
; System Controls
; t			; Service Menu

; Player 1 Controls
; Up		; Shift Up
; Down	; Shift Down
; Left		; Steer Left
; Right	; Steer Right
; c			; Gas Pedal
; x			; Brake Pedal
; v			; VIEW Switch (Rave Racer Only)
; s			; Pause
; q			; Coin (also serves as Service Switch)
;------------------------------------------------------------------------
StartModule()
FadeInStart()

; The object controls how the module remaps your romNames to what VivaNonno supports. It works with the VivaNonno xml or the Namco System 22 xml
romType := Object("ridgeracj","rr1","ridgera2ja","rrs1","ridgera2j","rrs1b","raveracja","rv1","raveracj","rv1b","raveracw","rv2","rr1","rr1","rrs1","rrs1","rrs1b","rrs1b","rv1","rv1","rv1b","rv1b","rv2","rv2")
ident := romType[romName]
If !ident
	ScriptError("Your romName is: " . romName . "`nIt is not one of the known supported roms for this " . MEmu . " module: " . moduleName)

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
KeepAspect := IniReadCheck(settingsFile, "Settings", "KeepAspect","true",,1)
WinX := IniReadCheck(settingsFile, "Settings", "WinX","0",,1)
WinY := IniReadCheck(settingsFile, "Settings", "WinY","0",,1)

DetectHiddenWindows, off ; do not turn on

Run(executable,emuPath)

WinWait("ahk_class ATL:004DB490")
WinActivate, ahk_class ATL:004DB490

PostMessage, 0x111, 40001,,,ahk_class ATL:004DB490	; opening rom select

WinWait("Select System ahk_class #32770")
WinActivate, Select System ahk_class #32770

; Selecting the game we want to play
If romName = rr1	; Ridge Racer (Japan-A)
	SelectGame(1)
Else If romName = rrs1	; Ridge Racer 2 (Japan-A)
	SelectGame(2)
Else If romName = rrs1b	; Ridge Racer 2 (Japan-B)
	SelectGame(3)
Else If romName = rv1	; Rave Racer (Japan-A)
	SelectGame(4)
Else If romName = rv1b	; Rave Racer (Japan-B)
	SelectGame(5)
 Else If romName = rv2	; Rave Racer (World-B)
	SelectGame(6)

Sleep, 100 ; increase if emu not going full screen

; Set Fullscreen
If Fullscreen = true
	If KeepAspect = true
		MaximizeWindow("ahk_class ATL:004DB490")
	Else
		Send, !{ENTER}

Sleep, 2000 ; increase if black screen disappears before game starts

FadeInExit()

; In windowed mode on smaller resolutions, the game screen is might not be fully on screen and the emu doesn't save its last position. It doesn't take effect if you run fullscreen.
If Fullscreen != true
	WinMove, ahk_class ATL:004DB490,, %WinX%, %WinY%

Process("WaitClose",executable)
FadeOutExit()
ExitModule()


SelectGame(var){
	Control, Choose, %var%, ListBox1, ahk_class #32770
}

MaximizeWindow(class){
	WinSet, Style, -0xC00000, %class%	;Removes the titlebar of the game window
	WinSet, Style, -0x40000, %class%		;Removes the border of the game window
	WinGetPos, appX, appY, appWidth, appHeight, %class%
	widthMaxPercenty := ( A_ScreenWidth / appWidth )
	heightMaxPercenty := ( A_ScreenHeight / appHeight )

	If  ( widthMaxPercenty < heightMaxPercenty )
		percentToEnlarge := widthMaxPercenty
	Else
		percentToEnlarge := heightMaxPercenty

	appWidthNew := appWidth * percentToEnlarge
	appHeightNew := appHeight * percentToEnlarge
	Transform, appX, Round, %appX%
	Transform, appY, Round, %appY%
	Transform, appWidthNew, Round, %appWidthNew%, 2
	Transform, appHeightNew, Round, %appHeightNew%, 2
	appXPos := ( A_ScreenWidth / 2 ) - ( appWidthNew / 2 )
	appYPos := ( A_ScreenHeight / 2 ) - ( appHeightNew / 2 )
	WinMove, %class%,, appXPos, appYPos, appWidthNew, appHeightNew
}

HaltEmu:
	disableSuspendEmu = true
	If KeepAspect != true
		Send, !{Enter}
	Send, S
	Sleep, 200
Return
RestoreEmu:
	WinActivate, ahk_id %emulatorID%
	If KeepAspect != true
		Send, !{Enter}
	Send, S
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class ATL:004DB490")
Return
