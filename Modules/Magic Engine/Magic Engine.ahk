MEmu = Magic Engine
MEmuV = v1.1.3
MURL = http://www.magicengine.com/
MAuthor = djvj
MVersion = 2.0
MCRC = 821018BC
iCRC = 7930CF86
MID = 635038268901782138
MSystem = "NEC PC Engine","NEC PC Engine-CD","NEC PC-FX","NEC SuperGrafx","NEC TurboGrafx-16","NEC TurboGrafx-CD"
;----------------------------------------------------------------------------
; Notes:
; Download and extract nomousy to the folder with this module from http://www.autohotkey.com/forum/viewtopic.php?t=2197 (it makes the cursor transparent, so clicks will still register)
; This is used to prevent the mouse cursor from appearing in the middle of your screen when you run Magic Engine
; xPadder/joy2key don't work, the emu reads raw inputs. If you use gamepads, make sure you set your keys in Config->Gamepad
; Set your desired Video settings below.
;
; NEC PC-FX:
; Tested with emulator Magic Engine FX v1.0.1
; This is not the same emu as Magic Engine. It only emulates a PC-FX, but module script is almost the same.
;
; CD systems:
; Make sure your DAEMON_Tools_Path in Settings\Global HyperLaunch.ini is correct
; Make sure you have the syscard3.pce rom in your emu dir. You can find the file here: http://www.fantasyanime.com/emuhelp/syscards.zip
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Windowed := IniReadCheck(settingsFile, "Settings", "Windowed","y",,1)					; y=Simulated Fullscreen mode, n=Normal Fullscreen mode - Simulated Fullscreen mode is preferred, it still looks fullscreen
WideScreenMode := IniReadCheck(settingsFile, "Settings", "WideScreenMode","n",,1)		; y=enable, n=disable
DesktopMode := IniReadCheck(settingsFile, "Settings", "DesktopMode","y",,1)			; y=enable, n=disable - This is basically what sets fullscreen mode. Set to n to show emu in a small window
FullscreenStretch := IniReadCheck(settingsFile, "Settings", "FullscreenStretch","y",,1)		; y=enable, n=disable - This stretches the game screen while keeping the aspect ratio
HighResMode := IniReadCheck(settingsFile, "Settings", "HighResMode","y",,1)		; y=enable, n=disable
Filter := IniReadCheck(settingsFile, "Settings", "Filter","1",,1)							; 1=bilinear filtering , 0=disable
TripleBuffer := IniReadCheck(settingsFile, "Settings", "TripleBuffer","y",,1)					; y=enable, n=disable (DirectX only)
Zoom := IniReadCheck(settingsFile, "Settings", "Zoom","2",,1)							; 4=zoom max , 0=no zoom, use any value between 0 and 4
scanlines := IniReadCheck(settingsFile, "Settings", "scanlines","0",,1)					; 0=none, 40=black, use any value in between 0 and 40
vSync := IniReadCheck(settingsFile, "Settings", "vSync","1",,1)							; 0=disable, 1=enable, 2=vsync + timer (special vsync for windowed mode)
vDriver := IniReadCheck(settingsFile, "Settings", "vDriver","1",,1)							; 0=DirectX, 1=OpenGL
xRes := IniReadCheck(settingsFile, "Settings", "xRes","1280",,1)
yRes := IniReadCheck(settingsFile, "Settings", "yRes","1024",,1)
bitDepth := IniReadCheck(settingsFile, "Settings", "bitDepth","32",,1)
DisplayRes := IniReadCheck(settingsFile, "Settings", "DisplayRes","n",,1)				; Display screen resolution for troubleshooting
UseNoMousy := IniReadCheck(settingsFile, "Settings", "UseNoMousy","true",,1)		; Use NoMousy tool to hide the mouse. If false, will move mouse off the screen instead

If systemName contains pcfx,pc-fx
	meini = pcfx.ini
Else
	meini = pce.ini

MEINI := CheckFile(emuPath . "\" . meini,"Could not find " . emuPath . "\" . meini . "`nPlease run Magic Engine manually first so it is created for you.")
If UseNoMousy = true
	noMousyFile := CheckFile(moduleExtensionsPath . "\nomousy.exe","You have UseNoMousy enabled in the module, but could not find " . moduleExtensionsPath . "\nomousy.exe")
If systemName contains CD,pcfx,pc-fx
{
	CheckFile(emuPath . "\SYSCARD3.PCE","Cannot find " . emuPath . "\SYSCARD3.PCE`nThis file is required for CD systems  when using Magic Engine.")
	If dtEnabled = true
		DaemonTools("get")	; populates the dtDriveLetter variable with the drive letter to your scsi or dt virtual drive
	Else
		ScriptError("You are running a CD-based system with Magic Engine but do not have Daemon Tools enabled. Please enable DT `, it is required to run CD systems with this module.")
}
If InStr(systemName,"CD")?"":" -cd"

; Now let's update all our keys if they differ in the ini
iniLookup =
( ltrim c
	video, windowed, %Windowed%
	video, wide, %WideScreenMode%
	video, desktop, %DesktopMode%
	video, fullscreen, %FullscreenStretch%
	video, high_res, %HighResMode%
	video, filter, %Filter%
	video, triple_buffer, %TripleBuffer%
	video, Zoom, %Zoom%
	video, scanlines, %scanlines%
	video, vsync, %vSync%
	video, driver, %vDriver%
	video, screen_width, %xRes%
	video, screen_height, %yRes%
	video, screen_depth, %bitDepth%
	cdrom, drive_letter, %dtDriveLetter%:
	misc, screen_resolution, %DisplayRes%
)
Loop, Parse, iniLookup, `n
{
	StringSplit, split, A_LoopField, `,, %A_Space%%A_Tab%
	IniRead, tempVar, %MEINI%, %split1%, %split2%
	If ( tempVar != split3 )
		IniWrite, % split3, %MEINI%, %split1%, %split2%
}

7z(romPath, romName, romExtension, 7zExtractPath)

If systemName contains CD,pcfx,pc-fx	; your system name must have "CD" in it's name
{
	DaemonTools("mount",romPath . "\" . romName . romExtension)
	Run, % executable . " syscard3.pce" . (If InStr(systemName,"CD")?"":" -cd"), %emuPath%
}Else
	Run, %executable% "%romPath%\%romName%%romExtension%", %emuPath%

WinWait("MagicEngine ahk_class MagicEngineWindowClass")
WinWaitActive("MagicEngine ahk_class MagicEngineWindowClass")

If UseNoMousy = true
	Run, %noMousyFile% /hide	; hide cursor
Else
	MouseMove %A_ScreenWidth%,%A_ScreenHeight%

FadeInExit()
Process("WaitClose", executable)

If systemName contains CD,pcfx,pc-fx
	DaemonTools("unmount")
If UseNoMousy = true
	Run, %noMousyFile%	; unhide cursor

7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("MagicEngine ahk_class MagicEngineWindowClass")
Return

Esc::Return ; this prevents the quick flash of Hyperspin when exiting with fade on. You can still exit with Esc.
