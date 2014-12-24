MEmu = Emma 02
MEmuV =  v1.18
MURL = http://www.emma02.hobby-site.com/
MAuthor = brolly
MVersion = 2.0.2
MCRC = 8744EDDD
iCRC = 1E716C97
MID = 635038268887179980
MSystem = "RCA Studio II"
;----------------------------------------------------------------------------
; Notes:
; Best way to configure controls is to run Emma 02.exe directly do all the changes you want and then go to %APPDATA%\Emma 02 and copy the file emma_02.ini
; to the emulators data folder otherwise to edit controls you need to edit this file manually since when running in portable mode you don't have access to the GUI.
;
; To run the built-in games create txt files with the correct names and put them on your roms folder
; Built-in games require pressing a specific button on the controller in order to start, so make sure you edit the keys on the module below to match your own configuration
; Most of the games require you to press a button to start the game, like 1 or 2. So the game screen will be black until you do.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

hideEmuObj := Object("Studio II ahk_class wxWindowNR",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

If romExtension in %7zFormats%
	ScriptError(MEmu . " only supports extracted roms. Please extract your roms or turn on 7z for this system as the emu is being sent this extension: """ . romExtension . """")

options := "-p" . (If Fullscreen = "true" ? " -f" : "") . " -u -c=studio"

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

Run(executable . " " . options . " -s """ . (If romExtension = .txt ? "" : romPath . "\" . romName . romExtension) . """", emuPath)

WinWait("Studio II ahk_class wxWindowNR")
WinWaitActive("Studio II ahk_class wxWindowNR")

;Built-In Games require a button press for selection
;Make sure you change the keys below to match your own configuration!
If romExtension = .txt
{	SetKeyDelay(50)
	Sleep, 1500 ;Increase if game doesn't start automatically
	If romName contains Doodle
		SendInput, {k down}{k up}	; Press 1 on P1 controller
	If romName contains Patterns
		SendInput, {Up down}{Up up}	; Press 2 on P1 controller
	If romName contains Bowling
		SendInput, {x down}{x up}	; Press 3 on P1 controller
	If romName contains Freeway
		SendInput, {Left down}{Left up}	; Press 4 on P1 controller
	If romName contains Addition
		SendInput, {z down}{z up}	; Press 5 on P1 controller
}

HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("Studio II ahk_class wxWindowNR")
Return
