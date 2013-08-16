iCRC = EB44FC76
MEmu = DFend
MEmuV = v1.3.3
MURL = http://dfendreloaded.sourceforge.net/
MAuthor = djvj
MVersion = 2.0
MCRC = 24C65188
MID = 635038268883456883
MSystem = "DOS","Microsoft MS-DOS"
;----------------------------------------------------------------------------
; Notes:
; Requires DoSBox @ http://www.dosbox.com/ or you can get newer SVN versions on EmuCR
; You can find an Enhanced DosBox with many unofficial features on ykhwong's page @ http://ykhwong.x-y.net/
; Blank txt files need to be created for every game for HS1. In HS2, set skipchecks to true if you are not using 7z_enable. Otherwise you have to create blank txt files.
; path needs to be the folder with the DFend.exe and exe needs to be DFend.exe
; romPath needs to point to the dir with all the blank txt files for HS1. In HS2 it is not needed if skipchecks is true. If using 7z_enable, set romPath to your compressed games.
; If 7z_Enable is true, this module will set your Default Game Location in DFend to match the 7z_extract_dir in your system.ini.
; Many old games placed save games inside their own dirs, if you use 7z_enable and 7z_delete_temp is true, you will del these save games. Set 7z_delete_temp to false to prevent this.
; Setup all your games in the DFend frontend before you compress them, this module will launch each game using DFend instead of straight dosbox
; This allows for easy editing of dosbox settings in case they are needed
; Controls are done via in-game options for each game.
;
; For fullscreen setting to work, a few things must match:
; DFend profile name and file name must match romName (Press Ctrl+Enter on the game while in DFend)
; If your games are compressed (zip, 7z, rar, etc), the game's fileName must match romName like any other emu
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

If 7zEnable = true
{	dfendINI := CheckFile(emuPath . "\Settings\DFend.ini")
	IniRead, GameLoc, %dfendINI%, ProgramSets, DefGameLoc
	If ( 7zExtractPath != GameLoc )
		IniWrite, %7zExtractPath%HS\, %dfendINI%, ProgramSets, DefGameLoc
}

dfendProf := CheckFile(emuPath . "\Confs\" . romName . ".prof")	; profile name must match romName in dfend otherwise error here
IniRead, currentFullScreen, %dfendProf%, sdl, fullscreen
; Setting Fullscreen setting in ini if it doesn't match what user wants above
If ( Fullscreen != "true" And currentFullScreen = 1 )
	IniWrite, 0, %dfendProf%, sdl, fullscreen
Else If ( Fullscreen = "true" And currentFullScreen = 0 )
	IniWrite, 1, %dfendProf%, sdl, fullscreen


; 7z(romPath, romName, romExtension, 7zExtractPath) ; 7z not supported yet
; 7Z SUPPORT IS NEW FOR V1.3, NEED TO TEST AND FINISH THIS MODULE
; Would need to do a regexreplace to change the relativepaths to our new ones in the conf files to support 7z:
; [Extra]
; Exe=.\VirtualHD\SimCity 2000\sc2vesa.bat
; Setup=.\VirtualHD\SimCity 2000\install.exe
; 0=.\VirtualHD\;Drive;C;false;

Run(executable . " """ . romName . """", emuPath)

WinWait("DOSBox ahk_class SDL_app")
WinWaitActive("DOSBox ahk_class SDL_app")
Sleep, 1000 ; DOSBox gains focus before it goes fullscreen, this prevents HS from flashing back in due to this

FadeInExit()
Process("WaitClose", "DOSBox.exe")
; 7zCleanUp()
FadeOutExit()
ExitModule()


RestoreEmu:
	Send, !{Enter}
Return

CloseProcess:
	FadeOutStart()
	WinClose("DOSBox ahk_class SDL_app")
Return
