MEmu = Radikal Bikers Emu
MEmuV = v0.9.0.1
MURL = http://aarongiles.com/radikal.html
MAuthor = djvj
MVersion = 2.0
MCRC = 82372D10
iCRC = 1E716C97
MID = 635038268921178278
MSystem = "Radikal Bikers"
;------------------------------------------------------------------------
; Notes:
; radikalb.zip rom must reside in the emulator directory and be zipped. Copy it from your mame set.
; Run the emu manuallly initially and set your resolution and control you want to use. It gets saved in the radikalb.dat
;
; Defaults emu keys:
; System Controls
; 9				; Service Coin
; F2				; Test Mode
; F9				; Display FPS (windowed mode only)
; F10			; Toggle Throttling
; p				; Pause
; Escape	; Quit

; Player 1 Controls
; Down		; Handlebars up
; Left			; Steer Left
; Right		; Steer Right
; LControl	; Accelerate
; LAlt 			; Brake
; Space		; Change View
; 1				; Start
; 5				; Coin
;------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

Run(executable,emuPath,(If (Fullscreen = "true") ? ("Hide") : ("")))

WinWait("Radikal Bikers Setup ahk_class #32770")
WinActivate, Radikal Bikers Setup ahk_class #32770

Control, % (If (Fullscreen = "true") ? "UnCheck" : "Check"),, Button1, Radikal Bikers Setup ahk_class #32770

Send, {ENTER} ; starting game

WinWait("Radikal Bikers ahk_class Radikal Bikers")
WinWaitActive("Radikal Bikers ahk_class Radikal Bikers")

FadeInExit()
Process("WaitClose", executable)
FadeOutExit()
ExitModule()


HaltEmu:
	disableLoadScreen = true
Return

CloseProcess:
	FadeOutStart()
	WinClose, Radikal Bikers ahk_class Radikal Bikers
Return
