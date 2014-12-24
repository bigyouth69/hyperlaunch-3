MEmu = FourDO
MEmuV = v1.3.2.1
MURL = http://www.fourdo.com/
MAuthor = djvj
MVersion = 2.0.2
MCRC = C4967BE7
iCRC = 8FCF5737
MID = 635038268892354290
MSystem = "Panasonic 3DO"
;------------------------------------------------------------------------
; Notes:
; This emu only supports cue/iso images
; If your bios file is called fz10_rom.bin, rename it to fz10.rom, it should be placed in the same dir as the emu exe.
; On first launch, FourDO will ask you to point it to the fz10.rom. After you do that, exit the emu and select a game in HS and it should work.
; "After Startup, Open Last game" option must be enabled, otherwise you will only get the BIOS screen.
; Escape key in emu takes it out of fullscreen. It is remapped to Return at the bottom of the script. If you use Escape to exit, it will still work. This is needed to avoid an unattractive close.
; -StartLoadFile [filename] : Loads a game from file.
; -StartLoadDrive [letter]  : Loads from CD of the drive letter.
; --StartFullScreen         : Start Full Screen.
; --PrintKPrint        : Prints KPRINT (3DO debug) output to console.
; --ForceGDIRendering  : Forces GDI Rendering rather than DirectX.
; --DebugStartupPaused : Start 4do in a paused state.
; Bezel requirement: Open 4do, disable Display >  Snap window to clean elements.
;------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
UseGDI := IniReadCheck(settingsFile, "Settings", "UseGDI","false",,1)	; Forces GDI rendering instead of DirectX (default)

4DOFile := CheckFile(emuPath . "\Settings\FourDO.settings","Cannot find " . emuPath . "\Settings\FourDO.settings`nPlease run FourDO manually first so it is created for you.")

bezelTopOffset := IniReadCheck(settingsFile, "Settings", "Bezel_Top_Offset","24",,1)
bezelBottomOffset := IniReadCheck(settingsFile, "Settings", "Bezel_Bottom_Offset","24",,1)

BezelStart()

If dtEnabled = true
	DaemonTools("get")	; populates the dtDriveLetter variable with the drive letter to your scsi or dt virtual drive

hideEmuObj := Object("4DO",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

If romExtension in .7z,.rar,.zip
	ScriptError("FourDO does not support archived files. Either enable 7z support, or extract your games first.")

; fullscreen := If (Fullscreen = "true") ? ("--StartFullScreen") : ("")	; when CLI fullscreen works, this can be used instead of xpath
useGDI := If (UseGDI = "true") ? "--ForceGDIRendering" : ""
rom := "-StartLoadFile """ . romPath . "\" . romName . romExtension . """"

; Enable Fullscreen via settings because CLI doesn't work with this parameter correctly all the time
xpath_load(4DOXML, 4DOFile ) ; need to read the existing xml otherwise xpath deletes all existing nodes
xpath(4DOXML, "/Settings/WindowFullScreen/text()", (If ( Fullscreen = "true" ) ? "True" : "False"))
xpath_save(4DOXML, 4DOFile) ; write new XML

MouseMove, 0, A_ScreenHeight	; Moves mouse so the menubar doesn't show

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

; Basic usage: 4DO.exe [-option value][/option "value"][--switch]
If dtEnabled = true
{	DaemonTools("mount",romPath . "\" . romName . romExtension)
	Run(executable . " -StartLoadDrive " . dtDriveLetter . " " . fullscreen . " " . useGDI, emuPath)
} Else
	Run(executable . " " . rom . " " . useGDI . " " . fullscreen, emuPath)
	
WinWait("4DO")
WinWaitActive("4DO")

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)

If dtEnabled = true
	DaemonTools("unmount")

7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("4DO")
Return

Escape::Return
