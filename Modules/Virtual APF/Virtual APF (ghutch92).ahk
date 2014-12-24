MEmu = VirtualAPF
MEmuV =  v0.4
MURL = http://www.oocities.org/emucompboy/
MAuthor = ghutch92
MVersion = 2.0.1
MCRC = A63B0611
iCRC = 73727B15
MID = 635038268930766257
MSystem = "APF Imagination Machine"
;----------------------------------------------------------------------------
; Notes:
; To load a cassette, hit your FR button (usually delete) type cload, hit enter, hit enter, type run, hit enter
; This emulator also has no cli.
; Let the author of this module know if there are any more settings that should be added to the module ini
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
HideCassetteLoading := IniReadCheck(settingsFile, "Settings", "HideCassetteLoading","true",,1)

hideEmuObj := Object("Open ahk_class #32770",0,"ahk_class VAPF",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

If FileExist(emuPath . "\mc10.ini")
	IniRead, DefIni, %emuPath%\mc10.ini, CONFIG, ini
Else
	DefIni = foo.ini
emuIni := CheckFile(emuPath . "\" . DefIni)

If romExtension = .S19
{	IniWrite, 4, %emuIni%, MEMORY, carttype
	HideCassetteLoading = false
} Else If romExtension in  .cpf,.wav,.cas,.k7
{	IniWrite, 1, %emuIni%, MEMORY, carttype
	IniWrite, 1, %emuIni%, MEMORY, enableromhacksflag
	Key1:="K40", Key2:="K2A", Key3:="K08", Key4:="K24", Key5:="K22", Key6:="K04", Key7:="K0F", Key8:="K0A", Key9:="K1E", Key10:="K10"
	KeyValue1:="2E", KeyValue2:="0D", KeyValue3:="43", KeyValue4:="4C", KeyValue5:="4F", KeyValue6:="41", KeyValue7:="44", KeyValue8:="52", KeyValue9:="55", KeyValue10:="4E"
	Loop, 10
	{	k := Key%A_Index%
		kv := KeyValue%A_Index%
		IniRead, x, %emuIni%, EMUKEYBOARD, %k%
		lrn := StrLen(kv)/2
		If (lrn <  1)
			IniWrite, %kv%, %emuIni%, EMUKEYBOARD, %k%
		Else {
			match = 0
			Loop, %lrn%
			{	twoLengthText := SubStr(x,(1+(A_Index-1)*2),2)
				If (kv = twoLengthText)
				{	match =1
					Break
				}
			}
			If !match
				IniWrite, %kv%%x%, %emuIni%, EMUKEYBOARD, %k%
		}
	}
}
Else If romExtension in .bin,.rom
{	HideCassetteLoading = false
	
	fileNameType := IniReadCheck(settingsFile, romName, "fileNameType","GAME",,1)
	enhancedflag := IniReadCheck(settingsFile, romName, "enhancedflag","0",,1)
	usebuiltinromflag := IniReadCheck(settingsFile, romName, "usebuiltinromflag","1",,1)
	expandertype := IniReadCheck(settingsFile, romName, "expandertype","0",,1)
	enableromhacksflag := IniReadCheck(settingsFile, romName, "enableromhacksflag","1",,1)
	carttype := IniReadCheck(settingsFile, romName, "carttype","3",,1)
	If fileNameType = GAME
		IniWrite, %romPath%\%romName%%romExtension%, %emuIni%, MEMORY, GAMEfilename
	Else If fileNameType = ROM
		IniWrite, %romPath%\%romName%%romExtension%, %emuIni%, MEMORY, ROMfilename
	Else If fileNameType = BASIC
		IniWrite, %romPath%\%romName%%romExtension%, %emuIni%, MEMORY, BASICfilename
	Else
		ScriptError(fileNameType . " is not a valid value for fileNameType.`nAcceptable values are ROM, GAME and BASIC.") 
	IniWrite, %enhancedflag%, %emuIni%, MEMORY, enhancedflag
	IniWrite, %expanderflag%, %emuIni%, MEMORY, expanderflag
	IniWrite, %usebuiltinromflag%, %emuIni%, MEMORY, usebuiltinromflag
	IniWrite, %expandertype%, %emuIni%, MEMORY, expandertype
	IniWrite, %enableromhacksflag%, %emuIni%, MEMORY, enableromhacksflag
	IniWrite, %carttype%, %emuIni%, MEMORY, carttype
} Else
	ScriptError("This module does not support " . romExtension . " files")

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

Run(executable, emuPath)


WinWait("ahk_class VAPF")
If HideCassetteLoading = true
	WinSet, Transparent, 0, ahk_class VAPF
WinWaitActive("ahk_class VAPF")
If romExtension in  .cpf,.wav,.cas,.k7
{	SetTimer, WaitForDialog, 2
	SetKeyDelay(200)
	Send, {delete down}{delete up}
	Send, {C down}{C up}
	Send,{l down}{l up}{o down}{o up}{a down}{a up}{d down}{d up}{enter down}{enter up}
	Sleep, 500 ;wait for emu
	Send, {enter down}{enter up}
	Sleep, 1500 ;wait for dialog
	Send, {r down}{r up}{u down}{u up}{n down}{n up}{enter down}{enter up}
}
If HideCassetteLoading = true
	WinSet, Transparent, 255, ahk_class VAPF

Send, {F12} ;fullscreen

HideEmuEnd()
FadeInExit()
Process("WaitClose",executable)
7zCleanUp()
FadeOutExit()
ExitModule()


WaitForDialog:
	IfWinNotExist, Open ahk_class #32770
		Return
	Else {
		Clipboard := romPath . "\" . romName . romExtension
		WinSet, Transparent, 0, Open ahk_class #32770
		Send, ^v{Enter}
		SetTimer, WaitForDialog, Off
	}
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class VAPF")
Return
