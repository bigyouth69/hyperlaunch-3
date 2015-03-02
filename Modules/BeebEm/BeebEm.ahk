MEmu = BeebEm
MEmuV =  v4.14
MURL = http://www.mkw.me.uk/beebem/index.html
MAuthor = brolly
MVersion = 1.0.1
MCRC = AEFA614B
iCRC = 4EC57BED
mId = 635599773229077671
MSystem = "Acorn BBC Micro"
;----------------------------------------------------------------------------
; Notes:
; Make sure you set your user data folder to Emulator_Path\UserData, for this start BeebEm and 
; go to Options-Preference Options-Select User Data Folder
;
; Supported Models:
; BBC Model B
; BBC Model B + Integra-B
; BBC Model B Plus
; BBC Master 128
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
configFile := emuPath . "\UserData\Preferences.cfg"

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
Model := IniReadCheck(settingsFile, romName, "Model" . "|" . romName,"0",,1)
TapeSpeed := IniReadCheck(settingsFile, "Settings" . "|" . romName, "TapeSpeed","ee02",,1)
SetTube := IniReadCheck(settingsFile, "Settings" . "|" . romName, "SetTube","false",,1)
ChainCommand := IniReadCheck(settingsFile, romName, "ChainCommand","",,1)
RunCommand := IniReadCheck(settingsFile, romName, "RunCommand","",,1)

StringUpper RunCommand, RunCommand

7z(romPath, romName, romExtension, 7zExtractPath)

If romExtension not in .ssd,.dsd,.ad,.img,.uef
	ScriptError("The extension " . romExtension . " is not one of the known supported extensions for this emulator.")

If !FileExist(configFile)
	ScriptError("Preferences.cfg was not found at " . configFile)

If Model not in 0,1,2,3
	ScriptError("Model " . Model . " is not one of the known supported systems for this module: " . moduleName . ". Please use the option to configure the type of system needed through HyperlaunchHQ.")

configIni := LoadProperties(configFile)	; load the config into memory
SetTube := If SetTube = "true" ? "01" : "00"

Params := Params . "-Data - -DisMenu "
If ( romExtension = ".uef" ) { ;Tape
	Params :=  Params . " -KbdCmd ""OSCLI\s2\STAPE\s2\S\nPAGE\s-\S\s6\SE00\nCH.\s22\S\n"" "
	;Alternatives
	;Params :=  Params . " -KbdCmd ""OSCLI\s2\STAPE\s2\S\nOSCLI\s2\SRUN\s2\S\n"" "
	;Params :=  Params . " -KbdCmd ""\s'\STAPE\nPAGE\s-\S\s6\SE00\nCHAIN \s22\S\n"" "
	;Params :=  Params . " -KbdCmd ""\s'\STAPE\n\s'\SRUN\n"" "
} Else If (ChainCommand) {
	Params :=  Params . " -KbdCmd """ . (If Model = "3" ? "\d0600\S\d0040" : "") . "CH.\s2\S" . ChainCommand . "\s2\S\n"" " ;Loading the Master 128 OS takes longer so we need to simulate a delay before starting to send the commands otherwise not all of it will get through. Then revert it back to the default value of 40ms.
} Else If (RunCommand) {
	Params :=  Params . " -KbdCmd """ . (If Model = "3" ? "\d0600\S\d0040" : "") . "OSCLI\s2\SRUN " . RunCommand . "\s2\S\n"" "  ;Loading the Master 128 OS takes longer so we need to simulate a delay before starting to send the commands otherwise not all of it will get through. Then revert it back to the default value of 40ms.
}
Params :=  Params . " """ . romPath . "\" . romName . romExtension . """"

;Set the properties in the preferences.cfg file
WriteProperty(configIni,"MachineType", "0" . Model)
WriteProperty(configIni,"KeyMapping", "00009c62")
WriteProperty(configIni,"TubeEnabled", SetTube)
WriteProperty(configIni,"Tape Clock Speed", TapeSpeed)
SaveProperties(configFile,configIni)	; save changes to Preferences.cfg

BezelStart()

Fullscreen := If Fullscreen = "true" ? "-FullScreen " : ""

Run(executable . " " . Fullscreen . Params, emuPath)

WinActivate, ahk_class BEEBWIN
WinWaitActive("ahk_class BEEBWIN")

If bezelPath {
	WinGetPos,,, initialwidth,, ahk_class BEEBWIN
	W:=
	timeout := A_TickCount
	Loop {
		Sleep, 50
		WinGetPos,,, W,, ahk_class BEEBWIN
		If (W != initialwidth)
			Break
		If(timeout < A_TickCount - 2000)
			Break
	}
}
Sleep, 50

BezelDraw()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("ahk_class BEEBWIN")
Return
