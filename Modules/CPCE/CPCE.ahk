MEmu = CPCE
MEmuV = v1.94
MURL = http://cngsoft.no-ip.org/cpce/index.htm
MAuthor = horseyhorsey & djvj
MVersion = 2.0.1
MCRC = 48461B7
iCRC = CCC36497
mId = 635251593387342549
MSystem = "Amstrad CPC"
;------------------------------------------------------------------------
; Notes:
; PC joystick (360 controller uses stick) JOYSTICK=1 in the CPC.ini
; or emulating joystick through numpad arrow keys 8462 0 fire. This is toggled with NumLock. Normaly numpad keys are the F1-F10 on CPC. 
; NumLock is set when the module runs
;
; Setting the image width & height on 0 values crops the top & side border. Default values shipped with emu are width:3 height:5
; For scanlines to work Image Double has to be enabled
; Should auto load every unzipped game - Tape or Disk (.cdt .dsk) - 7z should be enabled for archives
;
; Multigame:
; In the module and works but I've only managed to get these working If they are pre unzipped. I keep them in separate folders:
; ie: Disk-Multi Tape-Multi (Disk 1) (Disk 2) (Tape 1 Side A) (Tape 1 Side B) etc.
;
; Emulator SpecIfic Keys:
;
; F1 - Shows all keys
; F6 - Throttle emu - Used to speed up loading tapes or fast forward
; F2 - Save snapshot, F3 - Load Snapshot
; HOME, END, PAGE UP and PAGE DOWN scroll the screen
; 
; Lots more help in the cpc.txt with emulator
;
; General game keys help:
; Most games you should be able to play without a keyboard but here are some important keys you can set which should get you by in a lot of games:
;
; J - Set Joystick, K - Set Keyboard, R - Redefine Keys
; 0 - 4 Game menus, choosing players. 0 can be sometimes be for start game
; S - Start game, Y - Yes , N - No
; Space & Enter
;------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
CPCEconfig := CheckFile(emuPath . "\CPCE.ini")
; Video
Fullscreen := IniReadCheck(settingsFile, "Win32 Video Settings|" . romName, "Fullscreen","true",,1)	
Greenscreen := IniReadCheck(settingsFile, "Win32 Video Settings|" . romName, "Green Screen","true",,1)
FixGamma := IniReadCheck(settingsFile, "Win32 Video Settings|" . romName, "Fix Gamma","true",,1)
Dither := IniReadCheck(settingsFile, "Win32 Video Settings|" . romName, "Dither","true",,1)
Scanlines := IniReadCheck(settingsFile, "Win32 Video Settings|" . romName, "Scanlines","0",,1)
ImageDouble := IniReadCheck(settingsFile, "Win32 Video Settings|" . romName, "Image Double","0",,1)
ImageWidth := IniReadCheck(settingsFile, "Win32 Video Settings|" . romName, "Image Width","0",,1)
ImageHeight := IniReadCheck(settingsFile, "Win32 Video Settings|" . romName, "Image Height","0",,1)
; Audio
SoundQuality := IniReadCheck(settingsFile, "Audio Settings|" . romName, "Sound Quality","2",,1)	; default is 44KHz
16Bit := IniReadCheck(settingsFile, "Audio Settings|" . romName, "16Bit","true",,1)
Stereo := IniReadCheck(settingsFile, "Audio Settings|" . romName, "Stereo","true",,1)
Filter := IniReadCheck(settingsFile, "Audio Settings|" . romName, "Filter","true",,1)

BezelStart()

; Write settings to the CPCE.ini
IniWrite, % If (Fullscreen = "true") ? 1 : 0, %CPCEconfig%, CPCE, IMAGE_FULLSCREEN
IniWrite, % If (Greenscreen = "true") ? 1 : 0, %CPCEconfig%, CPCE, GREEN_SCREEN
IniWrite, % If (FixGamma = "true") ? 1 : 0, %CPCEconfig%, CPCE, WIN32.IMAGE_FIXGAMMA
IniWrite, % If (Dither = "true") ? 1 : 0, %CPCEconfig%, CPCE, IMAGE_DITHER
IniWrite, %Scanlines%, %CPCEconfig%, CPCE, WIN32.IMAGE_SCANLINES
IniWrite, % If (ImageDouble = "true") ? 1 : 0, %CPCEconfig%, CPCE, WIN32.IMAGE_DOUBLE
IniWrite, %ImageWidth%, %CPCEconfig%, CPCE, WIN32.IMAGE_WIDTH
IniWrite, %ImageHeight%, %CPCEconfig%, CPCE, WIN32.IMAGE_HEIGHT	
IniWrite, %SoundQuality%, %CPCEconfig%, CPCE, WIN32.SOUND_QUALITY
IniWrite, % If (16Bit = "true") ? 1 : 0, %CPCEconfig%, CPCE, WIN32.SOUND_16BITS
IniWrite, % If (Stereo = "true") ? 1 : 0, %CPCEconfig%, CPCE, WIN32.SOUND_STEREO
IniWrite, % If (Filter = "true") ? 1 : 0, %CPCEconfig%, CPCE, WIN32.SOUND_FILTER

7z(romPath, romName, romExtension, 7zExtractPath)

; Running emu with the auto run /a+ switch
Run(executable . " """ . romPath . "\" . romName . romExtension . " """ . "/a+", emuPath)

WinWait("ahk_class OS95")
WinWaitActive("ahk_class OS95")

BezelDraw()

Gosub, JoystickOn

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


BezelLabel:
	disableHideTitleBar := false
	disableHideToggleMenu := false
	disableHideBorder := false
	disableWinMove := false
Return

JoystickOn:
	Send, {NumLock}
Return

PreMultiGame:
Return

MultiGame:
	Clipboard := 
	Clipboard := selectedRom
	WinWait("ahk_class OS95")
	If (mgRomExt = ".cdt")
	   	Send {LAlt Down}{5}{F3 Down}{F3 Up}{LAlt Up}
	If (mgRomExt = ".dsk")
		Send {F7}
	Sleep,750
	Send, ^v{50}{enter}
Return

SaveStateSlot1:
SaveStateSlot2:
SaveStateSlot3:
SaveStateSlot4:
SaveStateSlot5:
LoadStateSlot1:
LoadStateSlot2:
LoadStateSlot3:
LoadStateSlot4:
LoadStateSlot5:
    StringLeft, stateType, A_ThisLabel, 4 ;defines If it is a load or save state call
    StringRight, CurrentSaveStateSlotSelected, A_ThisLabel, 1 ; defines the slot called
    WinWait("ahk_class OS95")
	WinActivate, ahk_class OS95
	
	If (stateType="Save") 
	{	Send, {F2 Down}{10}{F2 Up}
		If !FileExist(HLMediaPath . "\Saved Games\%SystemName%\" . romname)
			FileCreateDir, %HLMediaPath%/Saved Games/%SystemName%/%romname%
	} Else ;it's a load call
		Send, {F3 Down}{10}{F3 Up}
	
    WinWait("ahk_class #32770")
    WinWaitActive("ahk_class #32770")

	Clipboard = %HLMediaPath%\Saved Games\%SystemName%\%romname%	
	ControlClick, ToolbarWindow323, ahk_class #32770 ,,,, NA x192 x0
    Send, ^v{100}{Enter}{200}
    ControlClick, Edit1, ahk_class #32770
	Clipboard = %romName%-%CurrentSaveStateSlotSelected%
	Send, ^v{50}{Enter}
    If (stateType="Save")
		Send,{5}{Left}{Enter}
	Sleep, 250
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class OS95")	
Return
