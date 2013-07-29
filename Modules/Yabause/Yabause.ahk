MEmu = Yabause
MEmuV =  r3046
MURL = http://yabause.org/
MAuthor = djvj & brolly
MVersion = 2.0
MCRC = E83945D3
iCRC = 9ED5DA00
MID = 635038268937782092
MSystem = "Sega Saturn"
;------------------------------------------------------------------------
; Notes:
; SSF is still far superior, I suggest using that emu instead
; CLI is broken, loading via ini instead
; If yabause.ini does not exist, change a setting in the emu's options and exit, it will be created.
; Set the path to your yabause.ini in the setting below. Do NOT put a backslash on the end. This is required because the emu places it's ini in an odd location and differs between OS(s).
; This only works with DTLite, not DTPro
; Make sure your DAEMONTools_Path in Settings\HyperLaunch.ini is correct
; Rom_Extension should include cue,iso
; Set fullscreen mode via the variable below
; Make a bios subfolder with your emulator and place your bios files there, then set the bios you want to use in the emu at File->Settings->General->Bios ROM File
; Ini files are stored at %LOCALAPPDATA%\yabause (on Win7/8 and XP) or alternatively in %USERPROFILE%\Local Settings\Application Data\yabause (on WinXP only)
;------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
IniFolderSearchType := IniReadCheck(settingsFile, "Settings", "IniFolderSearchType","1",,1)
HideBars := IniReadCheck(settingsFile, "Settings", "HideBars","true",,1)					; If true, will hide both the menubar and toolbar in the emu

If IniFolderSearchType = 1
	IniPath := GetCommonPath("LOCAL_APPDATA")
Else {
	EnvGet, IniPath, USERPROFILE
	IniPath := IniPath . "\Local Settings\Application Data"
}

yabauseINI := CheckFile(IniPath . "\yabause\yabause.ini")

If dtEnabled = true
{	DaemonTools("get")	; populates the dtDriveLetter variable with the drive letter to your scsi or dt virtual drive
	cdRomType=2
} Else
	cdRomType=1

7z(romPath, romName, romExtension, 7zExtractPath)

; Now let's update all our keys if they differ in the ini
Fullscreen := If ( Fullscreen = "true" ) ? "true" : "false"
gameImage := If ( dtEnabled = "true" ) ? dtDriveLetter . ":\" : romPath . "\" . romName . romExtension
hideBars := If ( hideBars = "true" ) ? 1 : 0

iniLookup =
( ltrim c
	0.9.11, autostart, true
	0.9.11, Video\Fullscreen, %Fullscreen%
	0.9.11, General\CdRomISO, %gameImage%
	0.9.11, General\CdRom, %cdRomType%
	0.9.11, View\Menubar, %hideBars%
	0.9.11, View\Toolbar, %hideBars%
)
Loop, Parse, iniLookup, `n
{	StringSplit, split, A_LoopField, `,, %A_Space%%A_Tab%
	IniRead, tempVar, %yabauseINI%, %split1%, %split2%
	If ( tempVar != split3 )
		IniWrite, % split3, %yabauseINI%, %split1%, %split2%
}

If dtEnabled = true
	DaemonTools("mount",romPath . "\" . romName . romExtension)

Run(executable,emuPath)

WinWait("Qt Yabause ahk_class QWidget")
WinWaitActive("Qt Yabause ahk_class QWidget")

FadeInExit()
Process("WaitClose", executable)

If dtEnabled = true
	DaemonTools("unmount")

7zCleanUp()
FadeOutExit()
ExitModule()


GetCommonPath( csidl ) {
	Static init 
	If !init 
	{
		CSIDL_APPDATA                 =0x001A     ; Application Data, new for NT4 
		CSIDL_COMMON_APPDATA          =0x0023     ; All Users\Application Data 
		CSIDL_COMMON_DOCUMENTS        =0x002e     ; All Users\Documents 
		CSIDL_DESKTOP                 =0x0010     ; C:\Documents and Settings\username\Desktop 
		CSIDL_FONTS                   =0x0014     ; C:\Windows\Fonts 
		CSIDL_LOCAL_APPDATA           =0x001C     ; non roaming, user\Local Settings\Application Data 
		CSIDL_MYMUSIC                 =0x000d     ; "My Music" folder 
		CSIDL_MYPICTURES              =0x0027     ; My Pictures, new for Win2K 
		CSIDL_PERSONAL                =0x0005     ; My Documents 
		CSIDL_PROGRAM_FILES_COMMON    =0x002b     ; C:\Program Files\Common 
		CSIDL_PROGRAM_FILES           =0x0026     ; C:\Program Files 
		CSIDL_PROGRAMS                =0x0002     ; C:\Documents and Settings\username\Start Menu\Programs 
		CSIDL_RESOURCES               =0x0038     ; %windir%\Resources\, For theme and other windows resources. 
		CSIDL_STARTMENU               =0x000b     ; C:\Documents and Settings\username\Start Menu 
		CSIDL_STARTUP                 =0x0007     ; C:\Documents and Settings\username\Start Menu\Programs\Startup. 
		CSIDL_SYSTEM                  =0x0025     ; GetSystemDirectory() 
		CSIDL_WINDOWS                 =0x0024     ; GetWindowsDirectory() 
	} 
	val = % CSIDL_%csidl% 
	VarSetCapacity(fpath, 256) 
	DllCall( "shell32\SHGetFolderPathA", "uint", 0, "int", val, "uint", 0, "int", 0, "str", fpath) 
	Return %fpath% 
}

CloseProcess:
	FadeOutStart()
	WinClose("Qt Yabause ahk_class QWidget")
	;WinKill, Qt Yabause ahk_class QWidget,,3 ; sometimes the emu didn't close, this assures it does
Return
