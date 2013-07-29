MEmu = CCS64
MEmuV = v3.9
MURL = http://www.ccs64.com/
MAuthor = djvj
MVersion = 2.0
MCRC = 6C50D63B
iCRC = 2D6D3A54
MID = 635038268878192501
MSystem = "Commodore 64"
;----------------------------------------------------------------------------
; Notes:
; To set fullscreen, set your VideoMode in HQ
; Does not support archived roms
; Not all roms autoload for an unknown reason
; fastload seems to not work

; Supports prg, p00, p01, t64, d64, g41, g64, tap, crt, c64
; CLI Syntax:
; CCS64 rom [-cfg filename] [-fastload] [-normalload] [-autorun] [-manualrun] [-window] [hardsid id]
;----------------------------------------------------------------------------
StartModule()
FadeInStart()
7z(romPath, romName, romExtension, 7zExtractPath)

If romExtension not in .c64,.crt,.d64,.g41,.g64,.p00,.p01,.t64,.tap
	ScriptError("Your rom has an extension of " . romExtension . ", only these extensions are supported:`nc64,crt,d64,g41,g64,p00,p01,t64,tap")

settingsFile := modulePath . "\" . moduleName . ".ini"
videoMode := IniReadCheck(settingsFile, "Settings", "VideoMode","1024x768x32",,1)

VMarray := Object("Window 1x",0,"Window 2x",1,"Window 3x",2,"640x480x32",3,"720x480x32",4,"720x576x32",5,"800x600x32",6,"1024x768x32",7,"1152x864x32",8,"1280x720x32",9,"1280x768x32",10,"1280x800x32",11,"1280x960x32",12,"1280x1024x32",13,"1360x768x32",14,"1366x768x32",15,"1600x900x32",16,"1600x1024x32",17,"1600x1200x32",18,"1680x1050x32",19,"1920x1080x32",20,"1920x1200x32",21,"640x480x16",22,"720x480x16",23,"720x576x16",24,"800x600x16",25,"1024x768x16",26,"1152x864x16",27,"1280x720x16",28,"1280x768x16",29,"1280x800x16",30,"1280x960x16",31,"1280x1024x16",32,"1360x768x16",33,"1366x768x16",34,"1600x900x16",35,"1600x1024x16",36,"1600x1200x16",37,"1680x1050x16",38,"1920x1080x16",39,"1920x1200x16",40)

videoMode := VMarray[videoMode]
If !videoMode
	ScriptError("Invalid Parameters for the key videoMode in " . settingsFile . " under the section [Settings]")

ccs64File := emuPath . "\C64.cfg"
IfNotExist, %ccs64File%
	FileAppend,, %ccs64File%	; emu does not create this automatically
FileRead, ccs64CFG, %ccs64File%

; Setting videoMode setting in CFG
ccs64CFG := RegExReplace(ccs64CFG,"\$SCREENMODE=[0-9]+","$SCREENMODE=" . videoMode) ; setting windowed resolution
SaveFile(ccs64CFG, ccs64File)

Run(executable . " """ . romPath . "\" . romName . romExtension . """"" -cfg ccs.cfg -autorun", emuPath)

WinWait("CCS64 ahk_class Afx:00400000:0")
WinWaitActive("CCS64 ahk_class Afx:00400000:0")

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


SaveFile(text,file) {
	FileDelete, %file%
	FileAppend, %text%, %file%
}

CloseProcess:
	FadeOutStart()
	WinClose("CCS64 ahk_class Afx:00400000:0")
Return
