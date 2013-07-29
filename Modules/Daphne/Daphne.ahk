MEmu = Daphne
MEmuV =  v1.0.12
MURL = http://www.daphne-emu.com/
MAuthor = djvj & BBB
MVersion = 2.0.2
MCRC = 99F557EC
iCRC = F82F9DBA
MID = 635038268879753802
MSystem = "Daphne","LaserDisc"
;----------------------------------------------------------------------------
; Notes:
; Executable should be Daphne.exe NOT Daphneloader.exe
; You need my Settings.ini from my user dir on the FTP @ /Upload Here/djvj/Daphne/
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := CheckFile(modulePath . "\" . moduleName . ".ini")

globalParams := IniReadCheck(settingsFile,"settings","globalParams",,,1)
pauseOnExit := IniReadCheck(settingsFile,"settings","pauseOnExit",,,1)

min_seek_delay := IniReadCheck(settingsFile,romName,"min_seek_delay",A_Space,,1)
seek_frames_per_ms := IniReadCheck(settingsFile,romName,"seek_frames_per_ms",A_Space,,1)
homedir := IniReadCheck(settingsFile,romName,"homedir",".",,1)
bank0 := IniReadCheck(settingsFile,romName,"bank0",A_Space,,1)
bank1 := IniReadCheck(settingsFile,romName,"bank1",A_Space,,1)
bank2 := IniReadCheck(settingsFile,romName,"bank2",A_Space,,1)
bank3 := IniReadCheck(settingsFile,romName,"bank3",A_Space,,1)
sound_buffer := IniReadCheck(settingsFile,romName,"sound_buffer",A_Space,,1)
params := IniReadCheck(settingsFile,romName,"params",A_Space,,1)
version := IniReadCheck(settingsFile,romName,"version",romName,,1)

frameFile = %romName% ; storing parent romName to send as the framefile name so we don't send wrong name when using an alternate version of a game

; Emptying variables if they are not set
min_seek_delay := (min_seek_delay ? ("-min_seek_delay " . min_seek_delay) : (""))
seek_frames_per_ms := (seek_frames_per_ms ? ("-seek_frames_per_ms " . seek_frames_per_ms) : (""))
homedir := (homedir ? ("-homedir " . homedir) : (""))
bank0 := (bank0 ? ("-bank 0 " . bank0) : (""))
bank1 := (bank1 ? ("-bank 1 " . bank1) : (""))
bank2 := (bank2 ? ("-bank 2 " . bank2) : (""))
bank3 := (bank3 ? ("-bank 3 " . bank3) : (""))
sound_buffer := (sound_buffer ? ("-sound_buffer " . sound_buffer) : (""))

params := globalParams . " " . params
7z(romPath, romName, romExtension, 7zExtractPath)

; If launched game is an alternate version of a parent, this will send the alternate's name to daphne.
romName = %version%

; This allows us to send variables, that when empty, are not sent to the Run command
Run(executable . A_Space . romName . A_Space . params . A_Space . min_seek_delay . A_Space . seek_frames_per_ms . A_Space . homedir . A_Space . bank0 . A_Space . bank1 . A_Space . bank2 . A_Space . bank3 . A_Space . sound_buffer . A_Space . "-framefile """ . romPath . "\" . frameFile . romExtension . """", emuPath)

WinWait("ahk_class SDL_app")
WinWaitActive("ahk_class SDL_app")

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()

HaltEmu:
	Send, {P}
Return
RestoreEmu:
	Winrestore, AHK_class %EmulatorClass%
	Send, {P}
Return

CloseProcess:
	FadeOutStart()
	If pauseOnExit = true
	{	Send, {P}
		Sleep, 100
	}
	WinClose("ahk_class SDL_app")
Return
