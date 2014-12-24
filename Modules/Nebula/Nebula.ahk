MEmu = Nebula
MEmuV = v2.25b
MURL = http://nebula.emulatronia.com/
MAuthor = djvj
MVersion = 2.0.1
MCRC = 45FBA381
iCRC = 1E716C97
MID = 635038268907246687
MSystem = "Sega Model 2","SNK Neo Geo","SNK Neo Geo AES"
;----------------------------------------------------------------------------
; Notes:
; Hardware emulated: NeoGeo, CPS1, CPS2, Konami, PGM
; Under Video->Fullscreen, make sure to set your desired settings for fullscreen operation
; Under Emulation->Rom Directories, make sure all your dirs that you want Nebula to find your roms
; You can find the clrmame dat for nebula @ http://www.logiqx.com/Dats/
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

hideEmuObj := Object("AHK_class Nebula",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

Run(executable . " " . romName, emuPath)

WinWait("AHK_class Nebula")
WinWaitActive("AHK_class Nebula")

Loop { ; looping until nebula is done loading roms and the default window size changes
	WinGetPos,,,W,H,AHK_class Nebula
	res := ( W . "x" . H )
	If ( res != "416x358" )
		Break
	Sleep, 50
}
Sleep, 500 ; increase this is emu is not going fullscreen

If Fullscreen = true
{	SetKeyDelay(50)
	Send, {Alt Down}{Enter Down}{Enter Up}{Alt Up} ; nebula doesn't pick up fast keys, this method slows it down
}

HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("AHK_class Nebula")
Return
