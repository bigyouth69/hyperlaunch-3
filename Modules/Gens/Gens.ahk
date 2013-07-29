MEmu = Gens
MEmuV =  v2.14
MURL = http://segaretro.org/Gens/GS
MAuthor = djvj
MVersion = 2.0.1
MCRC = 7B3AF9E0
iCRC = 2805229D
MID = 635038268896537774
MSystem = "Sega CD","Sega Genesis","Sega Mega Drive","Sega Mega-CD"
;----------------------------------------------------------------------------
; Notes:
; For Sega CD, don't forget to setup your bios or you might just get a black screen.
; Fullscreen and stretch are controlled via the variable below
;
; Sega CD & Sega 32X
; Configure your Sega CD bios first by going to Option -> Bios/Misc Files
; Gens only supports bin files for Sega CD, not cue
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
Stretch := IniReadCheck(settingsFile, "Settings", "Stretch","true",,1)


7z(romPath, romName, romExtension, 7zExtractPath)

gensINI := CheckFile(emuPath . "\Gens.cfg")

IniRead, currentFullScreen, %gensINI%, Graphics, Full Screen
IniRead, currentStretch, %gensINI%, Graphics, Stretch

If ( romExtension = ".cue" )
	ScriptError("Gens does not support cue files, please use another extension")

; Setting Fullscreen setting in ini if it doesn't match what user wants above
If ( Fullscreen != "true" And currentFullScreen = 1 )
	IniWrite, 0, %gensINI%, Graphics, Full Screen
Else If ( Fullscreen = "true" And currentFullScreen = 0 )
	IniWrite, 1, %gensINI%, Graphics, Full Screen

; Setting Stretch setting in ini if it doesn't match what user wants above
If ( Stretch != "true" And currentStretch = 1 )
	IniWrite, 0, %gensINI%, Graphics, Stretch
Else If ( Stretch = "true" And currentStretch = 0 )
	IniWrite, 1, %gensINI%, Graphics, Stretch

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("Gens ahk_class Gens")
WinWaitActive("Gens ahk_class Gens")

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


RestoreEmu:
	Send, !{Enter}
Return

CloseProcess:
	FadeOutStart()
	WinClose("Gens ahk_class Gens")
Return
