MEmu = Pinball FX2
MEmuV = N/A
MURL = http://www.pinballfx.com/
MAuthor = djvj
MVersion = 2.0
MCRC = AE975C5B
iCRC = 72934A25
mId = 635244873683327779
MSystem = "Pinball FX2","Pinball"
;----------------------------------------------------------------------------
; Notes:
; If launching as a Steam game:
; When setting this up in HLHQ under the global emulators tab, make sure to select it as a Virtual Emulator. Also no rom extensions, executable, or rom paths need to be defined. 
; Set Skip Checks to "Rom and Emu" when using this module as roms do not exist.
;
; If not launching through Steam:
; Add this as any other standard emulator and define the PInball FX2.exe as your executable, but still select Virtual Emulator as you do not need rom extensions or rom paths
; Set Skip Checks to "Rom and Emu" when using this module as roms do not exist.
;
;This module requires BlockInput.exe to exist in your Module Extensions folder. It is used to prevent users from messing up the table selection routine.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

pinballTitleClass := "Pinball FX2 ahk_class PxWindowClass"
settingsFile := modulePath . "\" . moduleName . ".ini"
sleepLogo := IniReadCheck(settingsFile, "Settings", "Sleep_Until_Logo",12000,,1)
sleepMenu := IniReadCheck(settingsFile, "Settings", "Sleep_Until_Main_Menu",1500,,1)
tableNavX := IniReadCheck(settingsFile, romName, "x",,,1)
tableNavY := IniReadCheck(settingsFile, romName, "y",,,1)

CheckFile(moduleExtensionsPath . "\BlockInput.exe")

If (tableNavX = "" || tableNavY = "")
	ScriptError("This game is not configured in the module ini. Please set the grid coordinates in HyperLaunchHQ so HyperLaunch can launch the game for you")
 
If executable {
	Log("Module - Running Pinball FX2 as a stand alone game and not through Steam as an executable was defined.")
	Run(executable, emuPath)
} Else {
	Log("Module - Running Pinball FX2 through Steam applaunch.")
	RegRead, steamPath, HKLM, Software\Valve\Steam, InstallPath
	Run("Steam.exe -applaunch 226980", steamPath)
}

WinWait(pinballTitleClass)
WinWaitActive(pinballTitleClass)

Run("BlockInput.exe 30", moduleExtensionsPath)	; start the tool that blocks all input so user cannot interrupt the launch process for 30 seconds
SetKeyDelay, 50	; required otherwise pinball fx2 does not respond to the keys
Sleep, %sleepLogo%	; sleep till Pinball FX2 logo appears
ControlSend,, {Esc Down}{Esc Up}200{Enter Down}{Enter Up}, %pinballTitleClass%	; cancel pinball fx2 logo
Sleep, %sleepMenu%	; sleep till table select window appears

Loop % tableNavX-1
{	ControlSend,, {Right Down}{Right Up}, %pinballTitleClass%
	Sleep, 50
}
Loop % tableNavY-1
{	ControlSend,, {Down Down}{Down Up}, %pinballTitleClass%
	Sleep, 50
}
ControlSend,, {Enter Down}{Enter Up}, %pinballTitleClass%	; select game
Sleep, 500
ControlSend,, {Enter Down}{Enter Up}, %pinballTitleClass%	; start game
Process("Close", "BlockInput.exe")	; end script that blocks all input

FadeInExit()
Process("WaitClose", "Pinball FX2.exe")
FadeOutExit()
ExitModule()
    
    
CloseProcess:
	FadeOutStart()
	WinClose(pinballTitleClass)
Return
