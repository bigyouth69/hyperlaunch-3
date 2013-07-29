MEmu = DWJukebox
MEmuV = v3.4.1.0
MURL = http://dwjukebox.com/
MAuthor = brolly
MVersion = 2.0
MCRC = A9CC8823
iCRC = D1C74E15
MID = 635038268885548621
MSystem = "Jukebox"
;----------------------------------------------------------------------------
; Notes:
; If you are launching the jukebox directly from the main wheel then make sure 
; the MusicFoldersAsRoms variable below is set to false. If on the other hand you 
; have a sub-wheel listing your own music db and want to launch each music individually 
; then make sure MusicFoldersAsRoms is set to true.
; You'll need to have a jukebox.ini named after each one of your db entries properly configured 
; to have it's SongPath keys pointing to the correct folders. Then you can point your 
; RomPath to the folder where you keep those ini files and set the file extension to .ini.
; If you are launching directly from the main menu wheel, don't forget to set skipchecks=true 
; on HyperLaunch.ini. romExtension and romPath should be empty on this case.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
MusicFoldersAsRoms := IniReadCheck(settingsFile, "Settings", "MusicFoldersAsRoms","false",,1)

If MusicFoldersAsRoms = true
{	CheckFile(emuPath . "\conf\" . romName . ".ini")
	options = "%romPath%"
	7z(romPath, romName, romExtension, 7zExtractPath)
}

Run(executable . " " . options, emuPath)

WinWait("DWJukebox ahk_class AllegroWindow")
WinWaitActive("DWJukebox ahk_class AllegroWindow")

FadeInExit()
Process("WaitClose", executable)
If MusicFoldersAsRoms = true
	7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("DWJukebox ahk_class AllegroWindow")
Return
