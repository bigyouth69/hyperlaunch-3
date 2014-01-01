MEmu = VisualBoyAdvance-M
MEmuV =  r1099
MURL = http://sourceforge.net/projects/vbam/
MAuthor = djvj
MVersion = 2.0.2
MCRC = 48696C61
iCRC = 9D3A3B7
MID = 635038268933018136
MSystem = "Nintendo Game Boy","Nintendo Game Boy Color","Nintendo Game Boy Advance","Nintendo Super Game Boy"
;----------------------------------------------------------------------------
; Notes:
; On first run, you will be guided to set your fullscreen settings. Follow the instructions in the msgboxes.
; Fullscreen is controlled via the variable below
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
VideoMode := IniReadCheck(settingsFile, "Settings", "VideoMode","3",,1) ;0-5 are window sizes. 11 = fullscreen
fsWidth := IniReadCheck(settingsFile, "Settings", "fsWidth",A_ScreenWidth,,1) ;fullscreen width
fsHeight := IniReadCheck(settingsFile, "Settings", "fsHeight",A_ScreenHeight,,1) ;fullscreen height

BezelStart()
7z(romPath, romName, romExtension, 7zExtractPath)

vbaINI := CheckFile(emuPath . "\vbam.ini")
IniRead, currentVideoMode, %vbaINI%, preferences, video

; Setting Fullscreen setting in ini if it doesn't match what user wants above
If ( Fullscreen != "true" And ((currentVideoMode = 11) or !VideoMode) )
	IniWrite, %VideoMode%, %vbaINI%, preferences, video
Else If ( Fullscreen = "true" And currentVideoMode != 11 ) {
	IniWrite, 11, %vbaINI%, preferences, video
	IniWrite, %fsWidth%, %vbaINI%, preferences, fsWidth
	IniWrite, %fsHeight%, %vbaINI%, preferences, fsHeight
}

; This changes the mode the emulator runs in
If systemName = Nintendo Game Boy
	emuType = 3
Else If systemName = Nintendo Game Boy Color
	emuType = 1
Else If systemName = Nintendo Game Boy Advance
	emuType = 4
Else If systemName = Nintendo Super Game Boy
	emuType = 5
IniWrite, %emuType%, %vbaINI%, preferences, emulatorType

Run(executable . " """ . romPath . "\" . romName . romExtension,emuPath)

WinWait("VisualBoyAdvance-M")
WinWaitActive("VisualBoyAdvance-M")

BezelDraw()

FadeInExit()
Process("WaitClose",executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose, VisualBoyAdvance-M
Return
