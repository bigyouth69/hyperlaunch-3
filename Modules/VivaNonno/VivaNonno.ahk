MEmu = VivaNonno
MEmuV = v22.0.3
MURL = http://vivanonno.vg-network.com/
MAuthor = djvj
MVersion = 2.0
MCRC = D20501BC
iCRC = 9903213F
MID = 635038268933548574
MSystem = "VivaNonno"
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

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
WinX := IniReadCheck(settingsFile, "Settings", "WinX","0",,1)
WinY := IniReadCheck(settingsFile, "Settings", "WinY","0",,1)

DetectHiddenWindows, off ; do not turn on

Run(executable,emuPath)

WinWait("ahk_class ATL:004DB490")
WinActivate, ahk_class ATL:004DB490

Send, {ALT}{ENTER 2} ; opening rom select

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
	Send, !{ENTER}

Sleep, 2000 ; increase if black screen disappears before game starts

FadeInExit()

; In windowed mode on smaller resolutions, the game screen is might not be fully on screen and the emu doesn't save its last position. It doesn't take effect if you run fullscreen.
If Fullscreen != true
	WinMove, ahk_class ATL:004DB490, , %WinX%, %WinY%

Process("WaitClose",executable)
FadeOutExit()
ExitModule()


SelectGame(var){
	Control, Choose, %var%, ListBox1, ahk_class #32770
}

HaltEmu:
	disableSuspendEmu = true
	Send, !{Enter}
	Send, S
	Sleep, 200
Return
RestoreEmu:
	WinActivate, ahk_id  %emulatorID%
	Send, !{Enter}
	Send, S
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class ATL:004DB490")
Return
