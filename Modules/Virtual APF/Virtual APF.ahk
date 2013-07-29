MEmu = Virtual APF
MEmuV =  v0.4
MURL = http://www.oocities.org/emucompboy/
MAuthor = brolly
MVersion = 2.0
MCRC = F879A832
iCRC = A17E58D9
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
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
SelectGameMode := IniReadCheck(settingsFile, "Settings", "SelectGameMode","1",,1)		;1 = Uses a loop to detect the Edit Box has the romname and path in it. This doesn't work on all PCs, so if you get stuck at the open rom window, use mode 2. 2 = Uses a simple Ctrl+v to paste the romname and path, then press Enter to load the game.

7z(romPath, romName, romExtension, 7zExtractPath)

mcIni := CheckFile(emuPath . "\mc10.ini")
IniRead, DefaultIni, %emuPath%\mc10.ini, CONFIG, ini

emuIni := CheckFile(emuPath . "\" . DefaultIni)

enhancedflag := IniReadCheck(settingsFile, "MEMORY", "enhancedflag","1",,1)
usebuiltinromflag := IniReadCheck(settingsFile, "MEMORY", "usebuiltinromflag","1",,1)
carttype := IniReadCheck(settingsFile, "MEMORY", "carttype","1",,1)
enableromhacksflag := IniReadCheck(settingsFile, "MEMORY", "enableromhacksflag","1",,1)

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

Run(executable, emuPath)

WinWait("ahk_class VAPF")
WinWaitActive("ahk_class VAPF")

If TapeGame = true
{	Sleep, 200 ;Wait for Basic screen to boot
	SetKeyDelay, 100
	Send, {delete down}{delete up} ;Fire button to get past the Basic boot screen
	Sleep, 200
	Send,{C down}{C up},{l down}{l up}{o down}{o up}{a down}{a up}{d down}{d up}{enter down}{enter up}
	Sleep, 200
	Send, {enter down}{enter up}
	
	WinWait("Open ahk_class #32770")
	WinWaitActive("Open ahk_class #32770")

	If ( SelectGameMode = 1 ) {
		Loop {
			ControlGetText, edit1Text, Edit1, Open ahk_class #32770
			If ( edit1Text = romPath . "\" . romName . romExtension )
				Break
			Sleep, 100
			ControlSetText, Edit1, %romPath%\%romName%%romExtension%, Open ahk_class #32770
		}
		Sleep, 500
		ControlSend, Button1, {Enter}, Open ahk_class #32770 ; Select Open
	} Else If SelectGameMode = 2
	{	Clipboard := romPath . "\" . romName . romExtension
		Send, ^v{Enter}
	} Else
		ScriptError("You did not choose a valid SelectGameMode.`nOpen the module and set the mode at the top.")

	Sleep, 1500 ;wait for OK to show up, increase this if run is being sent too soon
	Send, {r down}{r up}{u down}{u up}{n down}{n up}{enter down}{enter up}
}

Send, {F12} ;Fullscreen
FadeInExit()
Process("WaitClose",executable)
7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("ahk_class VAPF")
Return
