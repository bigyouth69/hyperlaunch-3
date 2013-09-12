MEmu = Stella
MEmuV =  v3.7.2
MURL = http://stella.sourceforge.net/
MAuthor = djvj
MVersion = 2.0.1
MCRC = DF0BAADB
iCRC = 4405D45A
MID = 635038268926052339
MSystem = "Atari 2600"
;----------------------------------------------------------------------------
; Notes:
; To set fullscreen, hit Tab then goto Video Settings and set Fullscreen to On.
; If you want to use a hotkey to swap disks, assign one in HLHQ for this module
; Stella stores its config @ C:\Users\USERNAME\AppData\Roaming\Stella
; CLI docs @ /docs/index.html#CommandLine
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
FullResolution := IniReadCheck(settingsFile, "Settings", "FullResolution","auto",,1)		; If auto, Stella will try to use the maximum resolution for your screen. Otherwise set your desired res here WxH (ex 1920x1200)
DiskSwapKey := IniReadCheck(settingsFile, "Settings", "DiskSwapKey",,,1)					; swaps disk

7z(romPath, romName, romExtension, 7zExtractPath)

fullscreen := "-fullscreen " . (If (Fullscreen="true") ? ("1") : ("0"))
fullResolution := If FullResolution ? ("-fullres " . FullResolution) : ("")

If DiskSwapKey
	XHotKeywrapper(DiskSwapKey,"DiskSwap")

; This allows us to send variables, that when empty, are not sent to the Run command
Run(executable . " """ . romPath . "\" . romName . romExtension . """  " . fullscreen . " " . fullResolution, emuPath)

WinWait("Stella ahk_class SDL_app")
WinWaitActive("Stella ahk_class SDL_app")
Sleep, 700 ; Necessary otherwise the HyperSpin window flashes back into view

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()

DiskSwap:
	Send, {RCtrl down}{R down}{R up}{RCtrl up} ; need to send the keys slow so stella recognizes them
Return

RestoreEmu:
	Send, {Esc down}{Esc up}
Return

CloseProcess:
	FadeOutStart()
	WinClose("Stella ahk_class SDL_app")
Return
