MEmu = Yape
MEmuV = v1.0.4
MURL = http://vice-emu.sourceforge.net/
MAuthor = wahoobrian
MVersion = 1.0
MCRC = BB4C57B8
iCRC = 797414C9
MID = 000000000000000000
MSystem = "Commodore 16 & Plus4"
;----------------------------------------------------------------------------
; Notes:
; Roms must be unzipped.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
DoubleSizedWindow := IniReadCheck(settingsFile, "Settings", "DoubleSizedWindow","true",,1)
WarpKey := IniReadCheck(settingsFile, "Settings", "WarpKey","F9",,1) ;toggle warp speed
JoySwapKey := IniReadCheck(settingsFile, "Settings", "JoySwapKey","F10",,1) ;swap joystick port
SendCommandDelay := IniReadCheck(settingsFile, romName, "SendCommandDelay", "1500",,1)
RequiresReset := IniReadCheck(settingsFile, romName, "RequiresReset", "false",,1)

BezelStart("fixResMode")

hideEmuObj := Object("Autostart image ahk_class #32770",0,"ahk_class Yape",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

yapeINI := CheckFile(emuPath . "\yape.ini")
IniRead, currentStartInFullScreen, %yapeINI%, Yape configuration file, StartInFullScreen
IniRead, currentDoubleSizedWindow, %yapeINI%, Yape configuration file, Double sized window

If romExtension not in .prg,.d64,.t64,.tap,.crt,.g64
	ScriptError("Your rom has an extension of " . romExtension . ", only these extensions are supported:`nprg,d64,t64,tap,crt,g64")

; Setting DoubleSizedWindow setting in ini If it doesn't match what user wants above
If ( DoubleSizedWindow != "true" And currentDoubleSizedWindow = 1 )
	IniWrite, 0, %yapeINI%, Yape configuration file, Double sized window
Else If ( DoubleSizedWindow = "true" And currentDoubleSizedWindow = 0 )
	IniWrite, 1, %yapeINI%, Yape configuration file, Double sized window

; Setting Fullscreen setting in ini If it doesn't match what user wants above
If ( Fullscreen != "true" And currentStartInFullScreen = 1 )
	IniWrite, 0, %yapeINI%, Yape configuration file, StartInFullScreen
Else If ( Fullscreen = "true" And currentStartInFullScreen = 0 )
	IniWrite, 1, %yapeINI%, Yape configuration file, StartInFullScreen

WarpKey := xHotKeyVarEdit(WarpKey,"WarpKey","~","Add")
JoySwapKey := xHotKeyVarEdit(JoySwapKey,"JoySwapKey","~","Add")
xHotKeywrapper(WarpKey,"Warp")
xHotKeywrapper(JoySwapKey,"JoySwap")

If romName contains (USA),(Canada)
	VideoStandard = NTSC
Else
	VideoStandard = PAL

VideoMode := IniReadCheck(settingsFile, romName, "VideoMode", VideoStandard,,1)

; Setting video mode depending on rom, default NTSC	
If (VideoMode = "NTSC")
	IniWrite, 1, %yapeINI%, Yape configuration file, VideoStandard  ;NTSC
Else
	IniWrite, 0, %yapeINI%, Yape configuration file, VideoStandard  ;PAL

Model := IniReadCheck(settingsFile, romName, "Model", "Commodore Plus/4",,1)

Command := IniReadCheck(settingsFile, romName, "Command", "",,1)
StringLower, Command, Command ;Command MUST be in lower case so let's force it

HideEmuStart()
Run(executable, emuPath)

WinWait("ahk_class Yape")
WinWaitActive("ahk_class Yape")
Send, {F7} ;Open Autostart Image Select Dialog

OpenROM("Autostart image ahk_class #32770", romPath . "\" . romName . romExtension)

;WinWait("Autostart image...ahk_class #32770")
;WinWaitActive("Autostart image...ahk_class #32770")
;Clipboard := romPath . "\" . romName . romExtension 
;Send, ^v{Enter}	;Paste in selected disk	

If (RequiresReset = "true") 
{
	WinWaitActive("ahk_class Yape")
	Sleep, 500 ; increase If command is not appearing in the emu window or some just some letters
	Send, {F11}
}

If %Command% 
{
	WinWaitActive("ahk_class Yape")
	SendCommand(Command, SendCommandDelay)
}

WinWait("ahk_class Yape")
WinWaitActive("ahk_class Yape")

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


JoySwap:
	Send !j
Return

Warp:
	Send !w
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class Yape")
Return

