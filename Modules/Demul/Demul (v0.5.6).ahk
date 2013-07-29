MEmu = Demul
MEmuV =  v0.5.6
MURL = http://demul.emulation64.com/
MAuthor = djvj
MVersion = 2.0.2
MCRC = 6A989154
iCRC = 5C9B9311
MID = 635038268881325110
MSystem = "Sammy Atomiswave","Sega Dreamcast","Sega Naomi"
;----------------------------------------------------------------------------
; Notes:
; Required - control and nvram files can be found in my user dir on the FTP at /Upload Here/djvj/Sega Naomi\Emulators. Additonal instructions from my orignal HL1.0 script at http://www.hyperspin-fe.com/forum/showpost.php?p=86093&postcount=104
; Required - moduleName ini: can be found in my user dir on the FTP at /Upload Here/djvj/Sega Naomi\Modules\Sega Naomi
; moduleName ini must be placed in same folder as this module
; GDI images must match mame zip names and be extracted and have a .dat extension
; Rom_Extension should be zip
;
; Place the naomi.zip bios archive in the demul\roms subdir
; Set your Video Plugin to gpuOglv3 and set your desired resolution there
; In case your control codes do not match mine, set your desired control type in demul, then open the demul.ini and find section PORTB and look for the device key. Use this number instead of the one I provided
;
; Controls:
; Start a game of each control type (look in the moduleName ini for these types) and configure your controls to play the game. Copy paste the JAMMA0_0 and JAMMA0_1 (for naomi) or the ATOMISWAVE0_0 and ATOMISWAVE0_1 (for atomiswave) sections into the moduleName ini under the matching controls section.
;
; Sega Dreamcast:
; This script supports the following DC images: GDI, CDI, CHD, MDS, CCD, NRG, CUE
; Place your dc.zip bios in the roms subdir of your emu
; Run demul manually and goto Config->Plugins->GD-ROM Plugin and set it to gdrImage
; Set your Video Plugin to gpuOglv3
; On first run of a game, demul will ask you to setup all your plugin choices if you haven't already.
; If you want to convert your roms from gdi to chd, see here: http://www.emutalk.net/showthread.php?t=51502
; FileDelete(s) are in the script because sometimes demul will corrupt the ini and make it crash. The script recreates a clean ini for you.
;
; Troubleshooting:
; For some reason demul's ini files can get corrupted and ahk can't read/write to them correctly.
; If your ini keys are not being read or not writing to their existing keys in the demul inis, create a new file and copy/paste everything from the old ini into the new one and save.
; If you use Fade_Out, the module will force close demul because you cannot send ALT+F4 to demul if another GUI is covering it. Otherwise demul should close cleanly when Fade_Out is disabled. I suggest keeping Fade_Out disabled if you use this emu.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

; This object controls how the module reacts to different systems. Demul can play a few systems, but needs to know what system you want to run, so this module has to adapt.
mType := Object("Sammy Atomiswave","atomiswave","Sega Dreamcast","dc","Sega Naomi","naomi")
ident := mType[systemName]	; search object for the systemName identifier MESS uses
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this MESS module: " . moduleName)

settingsFile := modulePath . "\" . moduleName . ".ini"
demulFile := CheckFile(emuPath . "\Demul.ini")
padFile := CheckFile(emuPath . "\padDemul.ini")

controls := IniReadCheck(settingsFile, romname, "controls","standard",,1)	; have to read this first so the below loop works

; Read all the keys from the moduleName ini. Format is:
; Section, Key, Default Value, unique var
iniLookup =
( ltrim c
	Settings, Fullscreen, true
	Settings, ControllerCode, 16777216
	Settings, MouseCode, 131072
	Settings, KeyboardCode, 1073741824
	Settings, LightgunCode, -2147483648
	Settings, LastControlUsedNaomi, standard
	Settings, LastControlUsedAtomiswave, standard
	Settings, GlobalShaderEffects, false
	Settings, GlobalShaderName
	Settings, GlobalShaderMode
	%romName%, LoadDecrypted
	%romName%, Bios
	%romName%, ShaderEffects
	%romName%, ShaderName
	%romName%, ShaderMode
	%controls%_JAMMA0_0, push1,,n_push1_0
	%controls%_JAMMA0_0, push2,,n_push2_0
	%controls%_JAMMA0_0, push3,,n_push3_0
	%controls%_JAMMA0_0, push4,,n_push4_0
	%controls%_JAMMA0_0, push5,,n_push5_0
	%controls%_JAMMA0_0, push6,,n_push6_0
	%controls%_JAMMA0_0, push7,,n_push7_0
	%controls%_JAMMA0_0, push8,,n_push8_0
	%controls%_JAMMA0_0, SERVICE,,n_service_0
	%controls%_JAMMA0_0, START,,n_start_0
	%controls%_JAMMA0_0, COIN,,n_coin_0
	%controls%_JAMMA0_0, DIGITALUP,,n_digitalup_0
	%controls%_JAMMA0_0, DIGITALDOWN,,n_digitaldown_0
	%controls%_JAMMA0_0, DIGITALLEFT,,n_digitalleft_0
	%controls%_JAMMA0_0, DIGITALRIGHT,,n_digitalright_0
	%controls%_JAMMA0_0, ANALOGUP,,n_analogup_0
	%controls%_JAMMA0_0, ANALOGDOWN,,n_analogdown_0
	%controls%_JAMMA0_0, ANALOGLEFT,,n_analogleft_0
	%controls%_JAMMA0_0, ANALOGRIGHT,,n_analogright_0
	%controls%_JAMMA0_0, ANALOGUP2,,n_analogup2_0
	%controls%_JAMMA0_0, ANALOGDOWN2,,n_analogdown2_0
	%controls%_JAMMA0_0, ANALOGLEFT2,,n_analogleft2_0
	%controls%_JAMMA0_0, ANALOGRIGHT2,,n_analogright2_0
	%controls%_JAMMA0_1, push1,,n_push1_1
	%controls%_JAMMA0_1, push2,,n_push2_1
	%controls%_JAMMA0_1, push3,,n_push3_1
	%controls%_JAMMA0_1, push4,,n_push4_1
	%controls%_JAMMA0_1, push5,,n_push5_1
	%controls%_JAMMA0_1, push6,,n_push6_1
	%controls%_JAMMA0_1, push7,,n_push7_1
	%controls%_JAMMA0_1, push8,,n_push8_1
	%controls%_JAMMA0_1, SERVICE,,n_service_1
	%controls%_JAMMA0_1, START,,n_start_1
	%controls%_JAMMA0_1, COIN,,n_coin_1
	%controls%_JAMMA0_1, DIGITALUP,,n_digitalup_1
	%controls%_JAMMA0_1, DIGITALDOWN,,n_digitaldown_1
	%controls%_JAMMA0_1, DIGITALLEFT,,n_digitalleft_1
	%controls%_JAMMA0_1, DIGITALRIGHT,,n_digitalright_1
	%controls%_JAMMA0_1, ANALOGUP,,n_analogup_1
	%controls%_JAMMA0_1, ANALOGDOWN,,n_analogdown_1
	%controls%_JAMMA0_1, ANALOGLEFT,,n_analogleft_1
	%controls%_JAMMA0_1, ANALOGRIGHT,,n_analogright_1
	%controls%_JAMMA0_1, ANALOGUP2,,n_analogup2_1
	%controls%_JAMMA0_1, ANALOGDOWN2,,n_analogdown2_1
	%controls%_JAMMA0_1, ANALOGLEFT2,,n_analogleft2_1
	%controls%_JAMMA0_1, ANALOGRIGHT2,,n_analogright2_1
	%controls%_ATOMISWAVE0_0, UP,,a_up_0
	%controls%_ATOMISWAVE0_0, DOWN,,a_down_0
	%controls%_ATOMISWAVE0_0, LEFT,,a_left_0
	%controls%_ATOMISWAVE0_0, RIGHT,,a_right_0
	%controls%_ATOMISWAVE0_0, SHOT1,,a_shot1_0
	%controls%_ATOMISWAVE0_0, SHOT2,,a_shot2_0
	%controls%_ATOMISWAVE0_0, SHOT3,,a_shot3_0
	%controls%_ATOMISWAVE0_0, SHOT4,,a_shot4_0
	%controls%_ATOMISWAVE0_0, SHOT5,,a_shot5_0
	%controls%_ATOMISWAVE0_0, START,,a_start_0
	%controls%_ATOMISWAVE0_0, COIN,,a_coin_0
	%controls%_ATOMISWAVE0_1, UP,,a_up_1
	%controls%_ATOMISWAVE0_1, DOWN,,a_down_1
	%controls%_ATOMISWAVE0_1, LEFT,,a_left_1
	%controls%_ATOMISWAVE0_1, RIGHT,,a_right_1
	%controls%_ATOMISWAVE0_1, SHOT1,,a_shot1_1
	%controls%_ATOMISWAVE0_1, SHOT2,,a_shot2_1
	%controls%_ATOMISWAVE0_1, SHOT3,,a_shot3_1
	%controls%_ATOMISWAVE0_1, SHOT4,,a_shot4_1
	%controls%_ATOMISWAVE0_1, SHOT5,,a_shot5_1
	%controls%_ATOMISWAVE0_1, START,,a_start_1
	%controls%_ATOMISWAVE0_1, COIN,,a_coin_1
)
Loop, Parse, iniLookup, `n
{
	StringSplit, split, A_LoopField, `,, %A_Space%%A_Tab%
	If split4
		%split4% := IniReadCheck(settingsFile, split1, split2,split3,,1)
	Else
		%split2% := IniReadCheck(settingsFile, split1, split2,split3,,1)
	; need to empty the vars for the next loop otherwise they will still have values from the previous loop
	split3:=
	split4:=
}

; Now compare global & rom keys to get final value
shaderEffects := If (ShaderEffects = "" or ShaderEffects = "ERROR") ? GlobalShaderEffects : ShaderEffects
shaderName := If (ShaderName = "" or ShaderName = "ERROR") ? GlobalShaderName : ShaderName
shaderMode := If (ShaderMode = "" ShaderMode = "ERROR") ? GlobalShaderMode : ShaderMode

 ; Shader Effects
gpuOglv3File := CheckFile(emuPath . "\gpuOglv3.ini","Shaders are only supported using the gpuOglv3 plugin. Cannot find " . emuPath . "\gpuOglv3.ini")
IniRead, currentShaderValue, %gpuOglv3File%, shader, effects
If shaderEffects = true
{
	shaderPath := emupath . "\shaders"	; define the path to the shaders
	CheckFile(shaderPath . "\" . shaderName . ".slf")	; make sure the shader exists
	If currentShaderValue = false
		IniWrite, true, %gpuOglv3File%, shader, effects
	IniWrite, %shaderMode%, %gpuOglv3File%, shader, mode
	IniWrite, %shaderPath%, %gpuOglv3File%, shader, path
	IniWrite, %shaderName%, %gpuOglv3File%, shader, name
}Else If ( shaderEffects != "true" and currentShaderValue = "true" )
	IniWrite, false, %gpuOglv3File%, shader, effects

If ident = dc
{
	7z(romPath, romName, romExtension, 7zExtractPath)
	If ( romExtension = ".cdi" || romExtension = ".mds" || romExtension = ".ccd" || romExtension = ".nrg" || romExtension = ".gdi" || romExtension = ".cue" ) {
		gdrImageFile := CheckFile(emuPath . "\gdrImage.ini")
		FileDelete, %gdrImageFile%
		Sleep, 500
		IniWrite, gdrImage.dll, %demulFile%, plugins, gdr
		IniWrite, false, %gdrImageFile%, Main, openDialog
		IniWrite, %romPath%\%romName%%romExtension%, %gdrImageFile%, Main, imagefilename
	} Else If romExtension = .chd
	{
		gdrCHDFile := CheckFile(emuPath . "\gdrCHD.ini")
		FileDelete, %gdrCHDFile%
		Sleep, 500
		IniWrite, false, %gdrCHDFile%, Main, openDialog
		IniWrite, gdrCHD.dll, %demulFile%, plugins, gdr
		IniWrite, %romPath%\%romName%%romExtension%, %gdrCHDFile%, Main, imagefilename
	} Else
		ScriptError(romExtension . " is not a supported file type for this " . moduleName . " module.")

	IniWrite, 1, %demulFile%, main, region ; Set BIOS to Auto Region

} Else {	; all other systems, Naomi and Atomiswave
	; This updates the demul.ini with your Bios choice for the selected rom
	If ( Bios != "" and Bios != "ERROR" ) {
		Bios := RegExReplace(Bios,"\s.*")	; Cleans off the added text from the key's value so only the number is left
		IniWrite, false, %demulFile%, main, naomiBiosAuto	; turning auto bios off so we can use a specific one instead
		IniWrite, %Bios%, %demulFile%, main, naomiBios	; setting specific bios user has set from the moduleName ini
	} Else
		IniWrite, true, %demulFile%, main, naomiBiosAuto	; turning auto bios on if user did not specify a specific one

	; This section writes your custom keys to the padDemul.ini. Naomi games had many control panel layouts. The only way we can accomodate these differing controls, is to keep track of them all and write them to the ini at the launch of each game.
	; First we check if the last controls used are the same as the game we want to play, so we don't waste time updating the ini if it is not necessary. For example playing 2 sfstyle type games in a row, we wouldn't need to write to the ini.

	; This section tells demul what arcade control type should be connected to the game. Options are standard (aka controller), mouse, lightgun, or keyboard
	If ( controls = "lightgun" || controls = "mouse" )
		IniWrite, %MouseCode%, %demulFile%, PORTB, device
	Else If ( controls = "keyboard" )
		IniWrite, %KeyboardCode%, %demulFile%, PORTB, device
	Else ; accounts for all other control types
		IniWrite, %ControllerCode%, %demulFile%, PORTB, device

	LastControlUsed := If (ident = "atomiswave")?(LastControlUsedAtomiswave):(LastControlUsedNaomi)	; find out last controls used for the system we are launching
	If ( LastControlUsed != controls ) {
		If ident = atomiswave
		{
			WriteAtomiswaveControls(padFile, 0,a_shot1_0,a_shot2_0,a_shot3_0,a_shot4_0,a_shot5_0,a_start_0,a_coin_0,a_up_0,a_down_0,a_left_0,a_right_0)
			WriteAtomiswaveControls(padFile, 1,a_shot1_1,a_shot2_1,a_shot3_1,a_shot4_1,a_shot5_1,a_start_1,a_coin_1,a_up_1,a_down_1,a_left_1,a_right_1)
			IniWrite, %controls%, %settingsFile%, Settings, LastControlUsedAtomiswave	; write control loaded to the ini so we know what we used last for next launch
		} Else {
			WriteNaomiControls(padFile, 0,n_push1_0,n_push2_0,n_push3_0,n_push4_0,n_push5_0,n_push6_0,n_push7_0,n_push8_0,n_service_0,n_start_0,n_coin_0,n_digitalup_0,n_digitaldown_0,n_digitalleft_0,n_digitalright_0,n_analogup_0,n_analogdown_0,n_analogleft_0,n_analogright_0,n_analogup2_0,n_analogdown2_0,n_analogleft2_0,n_analogright2_0)
			WriteNaomiControls(padFile, 1,n_push1_1,n_push2_1,n_push3_1,n_push4_1,n_push5_1,n_push6_1,n_push7_1,n_push8_1,n_service_1,n_start_1,n_coin_1,n_digitalup_1,n_digitaldown_1,n_digitalleft_1,n_digitalright_1,n_analogup_1,n_analogdown_1,n_analogleft_1,n_analogright_1,n_analogup2_1,n_analogdown2_1,n_analogleft2_1,n_analogright2_1)
			IniWrite, %controls%, %settingsFile%, Settings, LastControlUsedNaomi	; write control loaded to the ini so we know what we used last for next launch
		}
	}
}

Sleep, 250

;  Construct the CLI for demul and send romName if naomi or atomiswave. Dreamcast needs a full path and romName.
If LoadDecrypted = true	; decrypted naomi rom
	romCLI := "-customrom=" . """" . romPath . "\" . romName . ".bin"""
Else If ident = dc	; dreamcast game
	romCLI := " -rom=" . """" . romPath . "\" . romName . romExtension . """"
Else	; standard naomi rom
	romCLI := "-rom=" . romName

Run(executable .  " -run=" . ident . " " . romCLI, emuPath,, emuPID)
; Sleep, 1000 ; need a second for demul to launch, increase if yours takes longer and the emu is appearing too soon

Loop { ; looping until demul is done loading rom and gpu starts showing frames
	Sleep, 200
	WinGetTitle, winTitle, ahk_class window
	StringSplit, winTextSplit, winTitle, %A_Space%
	If ( winTextSplit5 = "gpu:" And winTextSplit6 = "0" )
		Break
}
WinActivate ahk_class window

If fullscreen = true
	Send !{ENTER} ; go fullscreen

FadeInExit()

If systemName contains Dreamcast,DC
	7zCleanUp()

Process("WaitClose", executable)
FadeOutExit()
ExitModule()


 ; Write new naomi controls to padDemul.ini
WriteNaomiControls(file,player,push1,push2,push3,push4,push5,push6,push7,push8,service,start,coin,digitalup,digitaldown,digitalleft,digitalright,analogup,analogdown,analogleft,analogright,analogup2,analogdown2,analogleft2,analogright2) {
	IniWrite, %push1%, %file%, JAMMA0_%player%, PUSH1
	IniWrite, %push2%, %file%, JAMMA0_%player%, PUSH2
	IniWrite, %push3%, %file%, JAMMA0_%player%, PUSH3
	IniWrite, %push4%, %file%, JAMMA0_%player%, PUSH4
	IniWrite, %push5%, %file%, JAMMA0_%player%, PUSH5
	IniWrite, %push6%, %file%, JAMMA0_%player%, PUSH6
	IniWrite, %push7%, %file%, JAMMA0_%player%, PUSH7
	IniWrite, %push8%, %file%, JAMMA0_%player%, PUSH8
	IniWrite, %service%, %file%, JAMMA0_%player%, SERVICE
	IniWrite, %start%, %file%, JAMMA0_%player%, START
	IniWrite, %coin%, %file%, JAMMA0_%player%, COIN
	IniWrite, %digitalup%, %file%, JAMMA0_%player%, DIGITALUP
	IniWrite, %digitaldown%, %file%, JAMMA0_%player%, DIGITALDOWN
	IniWrite, %digitalleft%, %file%, JAMMA0_%player%, DIGITALLEFT
	IniWrite, %digitalright%, %file%, JAMMA0_%player%, DIGITALRIGHT
	IniWrite, %analogup%, %file%, JAMMA0_%player%, ANALOGUP
	IniWrite, %analogdown%, %file%, JAMMA0_%player%, ANALOGDOWN
	IniWrite, %analogleft%, %file%, JAMMA0_%player%, ANALOGLEFT
	IniWrite, %analogright%, %file%, JAMMA0_%player%, ANALOGRIGHT
	IniWrite, %analogup2%, %file%, JAMMA0_%player%, ANALOGUP2
	IniWrite, %analogdown2%, %file%, JAMMA0_%player%, ANALOGDOWN2
	IniWrite, %analogleft2%, %file%, JAMMA0_%player%, ANALOGLEFT2
	IniWrite, %analogright2%, %file%, JAMMA0_%player%, ANALOGRIGHT2
}

 ; Write new atomiswave controls to padDemul.ini
WriteAtomiswaveControls(file,player,shot1,shot2,shot3,shot4,shot5,start,coin,up,down,left,right) {
	IniWrite, %shot1%, %file%, ATOMISWAVE0_%player%, SHOT1
	IniWrite, %shot2%, %file%, ATOMISWAVE0_%player%, SHOT2
	IniWrite, %shot3%, %file%, ATOMISWAVE0_%player%, SHOT3
	IniWrite, %shot4%, %file%, ATOMISWAVE0_%player%, SHOT4
	IniWrite, %shot5%, %file%, ATOMISWAVE0_%player%, SHOT5
	IniWrite, %start%, %file%, ATOMISWAVE0_%player%, START
	IniWrite, %coin%, %file%, ATOMISWAVE0_%player%, COIN
	IniWrite, %up%, %file%, ATOMISWAVE0_%player%, UP
	IniWrite, %down%, %file%, ATOMISWAVE0_%player%, DOWN
	IniWrite, %left%, %file%, ATOMISWAVE0_%player%, LEFT
	IniWrite, %right%, %file%, ATOMISWAVE0_%player%, RIGHT
}

CloseProcess:
	FadeOutStart()
	If fadeOut = true	; cannot send ALT+F4 to a background window (controlsend doesn't work), so we have to force close instead.
		Process("Close", emuPID) ; we have to close this way otherwise demul crashes with WinClose
	Else
		Send, !{F4}
Return
