MEmu = Virtual APF
MEmuV =  v0.4
MURL = http://www.oocities.org/emucompboy/
MAuthor = brolly
MVersion = 2.0.2
MCRC = C27BE7E4
iCRC = 8046E4E1
MID = 635038268930235818
MSystem = "APF Imagination Machine"
;----------------------------------------------------------------------------
; Notes:
; Make sure you configure your controllers inside the emulator by going to Configure-Emulated Keyboard, then make sure you have 
; Enable joystick checked and select Use Emulated Keys. The 2 bottom rows below Space are your controller keys, FR is the fire button
;
; How to load tape games:
; Make sure you don't have any cart loaded and the system is booting into the built-in Basic ROM with Enable ROM hack fast I/O checked
; Press your FR button (delete by default) type CLOAD, hit enter, hit enter again to get the file browser dialog, select your tape 
; file, once you see OK on the screen type RUN and hit enter again to start the game.
; Some games might require you to type RUN before CLOAD to clear the memory/pointers. This happens on at least some APF Professional tapes
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
WindowSize := IniReadCheck(settingsFile, "Settings", "WindowSize","2",,1)
TapeLoadingMethod := IniReadCheck(settingsFile, romName, "TapeLoadingMethod","1",,1)

mcIni := CheckFile(emuPath . "\mc10.ini")
IniRead, DefaultIni, %emuPath%\mc10.ini, CONFIG, ini
emuIni := CheckFile(emuPath . "\" . DefaultIni)

enhancedflag := IniReadCheck(emuIni, "MEMORY", "enhancedflag","1",,1)
usebuiltinromflag := IniReadCheck(emuIni, "MEMORY", "usebuiltinromflag","1",,1)
carttype := IniReadCheck(emuIni, "MEMORY", "carttype","1",,1)
enableromhacksflag := IniReadCheck(emuIni, "MEMORY", "enableromhacksflag","1",,1)

dialogOpen := i18n("dialog.open")	; Looking up local translation

BezelStart("fixResMode")

windowscaling := IniReadCheck(emuIni, "VIDEO", "windowscaling","1",,1)

hideEmuObj := Object(dialogOpen . " ahk_class #32770",0,"ahk_class VAPF",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

NewfileNameType=GAMEfilename
NewEnhancedflag=0
NewUsebuiltinromflag=1
NewCarttype=0
NewEnableromhacksflag=1 ;This MUST be true for all Basic and Tape games
TapeGame=false

If romExtension in .bin,.rom
{	NewCarttype=3
	IniWrite, %romPath%\%romName%%romExtension%, %emuIni%, MEMORY, GAMEfilename

	If romName contains Trash Truck
	{	NewUsebuiltinromflag=0
		IniWrite, %romPath%\%romName%%romExtension%, %emuIni%, MEMORY, ROMfilename
	} Else If romName contains Basic
	{	NewCarttype=2
		IniWrite, %romPath%\%romName%%romExtension%, %emuIni%, MEMORY, BASICfilename
	} Else If romName contains Space Destroyers
		NewEnhancedflag=1
}
Else If If romExtension = .s19
{	NewCarttype=4
	If romName contains Space Destroyers
		NewEnhancedflag=1
	IniWrite, %romPath%\%romName%%romExtension%, %emuIni%, MEMORY, S19filename
} Else If romExtension in  .cas,.cpf,.k7,.wav
{	TapeGame=true
	NewCarttype=1
	NewEnableromhacksflag=1
}

If enhancedflag != NewEnhancedflag
	IniWrite, %NewEnhancedflag%, %emuIni%, MEMORY, enhancedflag
If usebuiltinromflag != NewUsebuiltinromflag
	IniWrite, %NewUsebuiltinromflag%, %emuIni%, MEMORY, usebuiltinromflag
If carttype != NewCarttype
	IniWrite, %NewCarttype%, %emuIni%, MEMORY, carttype
If enableromhacksflag != NewEnableromhacksflag
	IniWrite, %NewEnableromhacksflag%, %emuIni%, MEMORY, enableromhacksflag
If windowscaling != WindowSize
	IniWrite, %WindowSize%, %emuIni%, VIDEO, windowscaling

HideEmuStart()
Run(executable, emuPath)

WinWait("ahk_class VAPF")
WinWaitActive("ahk_class VAPF")

If TapeGame = true
{	Sleep, 250 ;Wait for Basic screen to boot
	SetKeyDelay(100)
	SendCommand("{delete}{Wait:200}") ;Fire button to get past the Basic boot screen
	If (TapeLoadingMethod = "2")
		SendCommand("run{Enter}")
	SendCommand("cload{Enter}{Wait:200}{Enter}")
	fullRomPath := romPath . "\" . romName . romExtension
	OpenROM(dialogOpen . " ahk_class #32770", fullRomPath)
	Sleep, 1500 ;wait for OK to show up, increase this if run is being sent too soon
	If (TapeLoadingMethod = "2")
		SendCommand("goto100{Enter}")
	Else
		SendCommand("run{Enter}")
}

If (Fullscreen = "true")
	Send, {F12} ;Fullscreen

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose",executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("ahk_class VAPF")
Return
