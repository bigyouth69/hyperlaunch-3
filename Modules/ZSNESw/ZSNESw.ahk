MEmu = ZSNESw
MEmuV =  v1.51
MURL = http://www.zsnes.com/
MAuthor = djvj
MVersion = 2.0.4
MCRC = C8A5967D
iCRC = FF33BDC8
MID = 635038268938832977
MSystem = "Super Nintendo Entertainment System"
;----------------------------------------------------------------------------
; Notes:
; Make sure you set quickexit to your Exit_Emulator_Key key while in ZSNES.
; If you want to use Esc as your quick exit key, open zsnesw.cfg with a text editor and find the lines below.
; If using fullscreen mode, it is suggest you turn fadeout off as it can not allow zsnes to close properly due to the method required to close zsnes.
; Set KeyQuickExit to 1, as shown below. You can't set the quick exit key to escape while in the emulator, because that's the exit key to configuring keys. 
;
; Quit ZSNES / Load Menu / Reset Game / Panic Key
; KeyQuickExit=1
; KeyQuickLoad=0
; KeyQuickRst=0
; KeyResetAll=42
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
Stretch := IniReadCheck(settingsFile, "Settings", "Stretch","false",,1)
resX := IniReadCheck(settingsFile, "Settings", "resX","1024",,1)
resY := IniReadCheck(settingsFile, "Settings", "resY","768",,1)
DisplayRomInfo := IniReadCheck(settingsFile, "Settings", "DisplayRomInfo","false",,1)	; Display rom info on load along bottom of screen

zsnesFile := CheckFile(emuPath . "\zsnesw.cfg")
zsnesIni := LoadProperties(zsnesFile)	; load the config into memory
xLine := ReadProperty(zsnesIni,"CustomResX")	; read current X value
yLine := ReadProperty(zsnesIni,"CustomResY")	; read current Y value
currentDRI := ReadProperty(zsnesIni,"DisplayInfo")	; read current displayinfo value

WriteProperty(zsnesIni,"CustomResX", resX)	; update custom X res in zsnes cfg file
WriteProperty(zsnesIni,"CustomResY", resY)	; update custom Y res in zsnes cfg file

If ( Fullscreen = "true" && Stretch = "true" ) ; sets fullscreen, stretch, and filter support
	vidMode = 39
Else If ( Fullscreen = "true" && Stretch != "true" ) ; sets fullscreen, correct aspect ratio, and filter support
	vidMode = 42
Else ; sets windowed mode with filter support
	vidMode = 38

WriteProperty(zsnesIni,"cvidmode", vidMode)	; update custom Y res in zsnes cfg file

; Setting DisplayRomInfo setting in cfg if it doesn't match what user wants above
If ( DisplayRomInfo != "true" And currentDRI = 1 ) {
	WriteProperty(zsnesIni,"DisplayInfo", 0)
} Else If ( DisplayRomInfo = "true" And currentDRI = 0 ) {
	WriteProperty(zsnesIni,"DisplayInfo", 1)
}

SaveProperties(zsnesFile,zsnesIni)	; save zsnesFile to disk

hideEmuObj := Object("ZSNES ahk_class ZSNES",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("ZSNES ahk_class ZSNES")
WinWaitActive("ZSNES ahk_class ZSNES")

HideEmuEnd()
FadeInExit()
Process("WaitClose",executable)
7zCleanUp()
FadeOutExit()
ExitModule()


SaveFile(text,file) {
	FileDelete, %file%
	FileAppend, %text%, %file%
}

CloseProcess:
	FadeOutStart()
	SetKeyDelay(50)	; slow down the keys below so the emu can register them
	SetWinDelay, 50	; don't remember why I needed this
	Send, {Alt Down}{F4 Down}{F4 Up}{Alt Up} ; No other closing method seems to work, not even ControlSend
Return
