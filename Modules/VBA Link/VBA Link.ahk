MEmu = VBA Link
MEmuV =  1.80b0
MURL = http://www.vbalink.info/
MAuthor = ghutch92
MVersion = 2.0
MCRC = 966425DD
iCRC = 8C119AE5
mId = 635048371877057298
MSystem = "Nintendo Game Boy","Nintendo Game Boy Color","Nintendo Game Boy Advance"
;----------------------------------------------------------------------------
; Notes:
; On first run, you will be guided to set your fullscreen settings. Follow the instructions in 
; the msgboxes. Afterwards Fullscreen size and fulscreen on/off toggle are controlled by the 
; settings you provide for the module. I suggest using VisualBoyAdvance-M unless you need the 
; linking feature since this module is for one gameboy only.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
VideoMode := IniReadCheck(settingsFile, "Settings", "VideoMode","3",,1) ;0-3 are window sizes. 4=320x240, 5=640x480, 6=600x800, 7 = fullscreen 
fsWidth := IniReadCheck(settingsFile, "Settings", "fsWidth",A_ScreenWidth,,1) ;fullscreen width
fsHeight := IniReadCheck(settingsFile, "Settings", "fsHeight",A_ScreenHeight,,1) ;fullscreen height

BezelStart()
7z(romPath, romName, romExtension, 7zExtractPath)

; vba1.ini is automatically created when the emulator is opened
vbaINI_1 := CheckFile(emuPath . "\vba1.ini")
IniRead, currentVideoMode, %vbaINI_1%, preferences, video

If (currentVideoMode > 3) AND (Fullscreen = "false")
	VideoMode = 3
Else If (currentVideoMode < 4) AND (Fullscreen = "true")
	VideoMode = 7

IniWrite, %VideoMode%, %vbaINI_1%, preferences, video
IniWrite, %fsWidth%, %vbaINI_1%, preferences, fsWidth
IniWrite, %fsHeight%, %vbaINI_1%, preferences, fsHeight

; This changes the mode the emulator runs in
If systemName = Nintendo Game Boy
	emuType = 3
Else If systemName = Nintendo Game Boy Color
	emuType = 1
Else If systemName = Nintendo Game Boy Advance
	emuType = 4
IniWrite, %emuType%, %vbaINI_1%, preferences, emulatorType

Run(executable . " """ . romPath . "\" . romName . romExtension,emuPath)

WinWait("VisualBoyAdvance")
WinWaitActive("VisualBoyAdvance")

BezelDraw()

FadeInExit()
Process("WaitClose",executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("VisualBoyAdvance")
Return
