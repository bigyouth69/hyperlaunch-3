MEmu = Turbo Engine 16
MEmuV = v0.32
MURL = http://aamirm.hacking-cult.org/www/turbo.html
MAuthor = djvj
MVersion = 2.0
MCRC = 1CCD9273
iCRC = 1E716C97
MID = 635038268927603628
MSystem = "NEC PC Engine","NEC PC Engine-CD","NEC SuperGrafx","NEC TurboGrafx-16","NEC TurboGrafx-CD"
;----------------------------------------------------------------------------
; Notes:
; CD systems:
; Make sure your DAEMON_Tools_Path in Settings\Global HyperLaunch.ini is correct
; Run the emu and goto Misc->CD Driver on the menubar and set the Drive Letter you use for Daemon Tools
; Make sure you have the syscard3.pce rom in your emu dir. You can find the file here: http://www.fantasyanime.com/emuhelp/syscards.zip
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

7z(romPath, romName, romExtension, 7zExtractPath)

CheckFile(emuPath . "\SYSCARD3.pce")

fs := If (Fullscreen = "true") ? "--fullscreen" : ""	; can only use this for roms, if supplied when using an iso, causes an error and unable to select File-Load to start a CD game

If (dtEnabled = "true" && InStr(systemName,"CD"))
{	DaemonTools("mount",romPath . "\" . romName . romExtension)
	Run(executable, emuPath)
	WinWait("Turbo Engine 16 ahk_class TurboEngine16")
	WinWaitActive("Turbo Engine 16 ahk_class TurboEngine16")
	WinMenuSelectItem, Turbo Engine 16 ahk_class TurboEngine16,,File,Load CD-ROM
} Else
	Run(executable . " " . fs . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("Turbo Engine 16 ahk_class TurboEngine16")
WinWaitActive("Turbo Engine 16 ahk_class TurboEngine16")

If (dtEnabled = "true" && Fullscreen = "true")
	WinMenuSelectItem, Turbo Engine 16 ahk_class TurboEngine16,,Video,Enter Fullscreen
	
FadeInExit()
Process("WaitClose", executable)

If systemName contains CD
	DaemonTools("unmount")

7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("Turbo Engine 16 ahk_class TurboEngine16")
Return
