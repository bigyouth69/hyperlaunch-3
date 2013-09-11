MEmu = Bgb
MEmuV =  v1.4.1
MURL = http://bgb.bircd.org/
MAuthor = djvj
MVersion = 2.0
MCRC = 4D7EC090
iCRC = EB44FC76
MID = 635038268875480245
MSystem = "Nintendo Game Boy","Nintendo Game Boy Color"
;----------------------------------------------------------------------------
; Notes:
; Place the "[BIOS] Nintendo Game Boy Color Boot ROM (World).gbc" rom in the bgb dir so you get correct colors
; Run the emu, right click and goto Options->System->GBC Bootrom and paste in the filename of the GBC boot rom
; Don't forget to check the "bootroms enabled" box
; Set fullscreen via the variable below
; You can set your fullscreen res by dragging the window to your desired size or selecting one of the Window sizes
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

BezelStart()

bgbFile := CheckFile(emuPath . "\bgb.ini")
FileRead, bgbINI, %bgbFile%

; Setting Fullscreen setting in INI if it doesn't match what user wants above
currentFullScreen := (InStr(bgbINI, "Windowmode=3") ? ("true") : ("false"))
If ( Fullscreen != "true" And currentFullScreen = "true" ) {
	StringReplace, bgbINI, bgbINI, Windowmode=3, Windowmode=1
	SaveFile(bgbINI, bgbFile)
} Else If ( Fullscreen = "true" And currentFullScreen = "false" ) {
	StringReplace, bgbINI, bgbINI, Windowmode=1, Windowmode=3
	SaveFile(bgbINI, bgbFile)
}
debugKey := (InStr(bgbINI, "DebugEsc=1") ? ("true") : ("false"))

; This disables Esc from bringing up the debug window (bgb's default behavior). If it's on, pressing Esc brings up debug, rather then closing the emu
If debugKey = true
{	StringReplace, bgbINI, bgbINI, DebugEsc=1, DebugEsc=0
	SaveFile(bgbINI, bgbFile)
}

7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable . " """ . romPath . "\" . romName . romExtension . """",emuPath)

WinWait("bgb ahk_class Tfgb")
WinWaitActive("bgb ahk_class Tfgb")

BezelDraw()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


SaveFile(text,file) {
	FileDelete, %file%
	FileAppend, %text%, %file%
}

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class Tfgb")
Return
