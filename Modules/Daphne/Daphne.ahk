MEmu = Daphne
MEmuV =  v1.0.13
MURL = http://www.daphne-emu.com/
MAuthor = djvj
MVersion = 2.0.6
MCRC = F8545233
iCRC = 7FCE1920
MID = 635038268879753802
MSystem = "Daphne","LaserDisc"
;----------------------------------------------------------------------------
; Notes:
; Executable should be Daphne.exe NOT Daphneloader.exe
; You need the module's ini from GIT, remove the (Example) from the filename. It has settings for each game so they work properly.
; If you want to define custom controls for each game, follow this process:
; 1) Manually run DaphneLoader.exe
; 2) Select each game you want to configure and click the Configure button. Select the Input tab and define your controls and hit OK and repeat for each game.
; 3) Create a folder in your emu directory called "controls" and copy your current dapinput.ini into it. This will be your default controls used for all games that a custom one was not created.
; 4) Launch each game you defined controls for through DaphneLoader. DaphneLoader will set your custom controls in the dapinput.ini. Now exit the game.
; 5) After each game you launch, copy the dapinput.ini into the controls folder and name it after the rom name you use in your xml: Example: lair.ini
;
; First time users, please follow the guide found @ http://www.hyperspin-fe.com/forum/showthread.php?29410-Complete-Guide-for-Daphne-in-HyperSpin-and-HL3
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
globalParams := IniReadCheck(settingsFile,"settings","globalParams","vldp -blank_searches -prefer_samples -noissues -fastboot",,1)
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
screenWidth := IniReadCheck(settingsFile, "Settings", "ScreenWidth",A_ScreenWidth,,1)
screenHeight := IniReadCheck(settingsFile, "Settings", "ScreenHeight",A_ScreenHeight,,1)
pauseOnExit := IniReadCheck(settingsFile,"settings","pauseOnExit","false",,1)
hwAccel := IniReadCheck(settingsFile,"settings","hwAccel","true",,1)
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

BezelStart()
fullscreen := If fullscreen = "true" ? " -fullscreen" : ""

If bezelPath	; this variable is only filled if bezel is enabled and a valid bezel image is found
{	params:= params . " -ignore_aspect_ratio"
	screenWidth := " -x " . Round(bezelScreenWidth)  ;bezelScreenWidth variable is defined on the BezelStart function and it gives the desired width that your game screen should have while using this bezel 
	screenHeight := " -y " . Round(bezelScreenHeight) ;idem above
} Else {
	screenWidth := " -x " . screenWidth
	screenHeight := " -y " . screenHeight
}

min_seek_delay := If min_seek_delay ? " -min_seek_delay " . min_seek_delay : ""
seek_frames_per_ms := If seek_frames_per_ms ? " -seek_frames_per_ms " . seek_frames_per_ms : ""
homedir := If homedir ? " -homedir " . homedir : ""
bank0 := If bank0 ? " -bank 0 " . bank0 : ""
bank1 := If bank1 ? " -bank 1 " . bank1 : ""
bank2 := If bank2 ? " -bank 2 " . bank2 : ""
bank3 := If bank3 ? " -bank 3 " . bank3 : ""
sound_buffer := If sound_buffer ? " -sound_buffer " . sound_buffer : ""
hwAccel := If hwAccel = "true" ? " -opengl" : " -nohwaccel"
params := globalParams . " " . params

hideEmuObj := Object("ahk_class SDL_app",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

; If you have alternate controls for a specific game, this will overwrite the current dapinput.ini with your custom one
romControlIni := emuPath . "\controls\" . romName . ".ini"
defaultControlIni := emuPath . "\controls\dapinput.ini"
daphneControlIni := emuPath . "\dapinput.ini"
If FileExist(romControlIni) {	; if a romName control ini exists
	Log("Module - Found a romName input ini and will overwrite the existing dapinput.ini: " . romControlIni)
	FileCopy, %romControlIni%, %daphneControlIni%, 1	; copy rom dapinput, overwriting working one
} Else If FileExist(defaultControlIni) {	; if a default control ini exists
	Log("Module - No romName input ini found, overwriting the current dapinput.ini with a default one: " . defaultControlIni)
	FileCopy, %defaultControlIni%, %daphneControlIni%, 1	; copy default dapinput, overwriting working one in case a rom one was set from previous launch
} Else
	Log("Module - No romName or default inis found, leaving the current dapinput.ini alone")

; If launched game is an alternate version of a parent, this will send the alternate's name to daphne.
romName = %version%

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

; This allows us to send variables, that when empty, are not sent to the Run command
; msgbox % executable . A_Space . romName . A_Space . params . fullscreen . screenWidth . screenHeight . min_seek_delay . seek_frames_per_ms . homedir . bank0 . bank1 . bank2 . bank3 . sound_buffer . " -framefile """ . romPath . "\" . frameFile . romExtension . """"
Run(executable . A_Space . romName . A_Space . params . hwAccel . fullscreen . screenWidth . screenHeight . min_seek_delay . seek_frames_per_ms . homedir . bank0 . bank1 . bank2 . bank3 . sound_buffer . " -framefile """ . romPath . "\" . frameFile . romExtension . """", emuPath)

WinWait("ahk_class SDL_app")
WinWaitActive("ahk_class SDL_app")

BezelDraw()
HideEmuEnd()
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
	BezelExit()
	If pauseOnExit = true
	{	Send, {P}
		Sleep, 100
	}
	WinClose("ahk_class SDL_app")
Return
