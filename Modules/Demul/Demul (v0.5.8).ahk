MEmu = Demul
MEmuV =  v0.5.8.2
MURL = http://demul.emulation64.com/
MAuthor = djvj
MVersion = 2.0.4
MCRC = 9B5AD892
iCRC = F43FB746
mId = 635211874656892855
MSystem = "Sammy Atomiswave","Sega Dreamcast","Sega Naomi","Gaelco"
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
; gpuDX11, gpuDXv3, and gpuDXLegacy are all supported. Define what plugin you want to use for each game in the moduleName ini.
; Read the notes at the top of the moduleName ini on how to control windowed fullscreen, true fullscreen, or windowed mode
; Windowed fullscreen will take effect the 2nd time you run the emu. It has to calculate your resolution on first run.
;
; Controls:
; Start a game of each control type (look in the moduleName ini for these types) and configure your controls to play the game. Copy paste the JAMMA0_0 and JAMMA0_1 (for naomi) or the ATOMISWAVE0_0 and ATOMISWAVE0_1 (for atomiswave) sections into the moduleName ini under the matching controls section.
;
; Troubleshooting:
; For some reason demul's ini files can get corrupted and ahk can't read/write to them correctly.
; If your ini keys are not being read or not writing to their existing keys in the demul inis, create a new file and copy/paste everything from the old ini into the new one and save.
; If you use Fade_Out, the module will force close demul because you cannot send ALT+F4 to demul if another GUI is covering it. Otherwise demul should close cleanly when Fade_Out is disabled. I suggest keeping Fade_Out disabled if you use this emu.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

; This object controls how the module reacts to different systems. Demul can play a few systems, but needs to know what system you want to run, so this module has to adapt.
mType := Object("Sammy Atomiswave","atomiswave","Sega Dreamcast","dc","Sega Naomi","naomi","Gaelco","gaelco")
ident := mType[systemName]	; search object for the systemName identifier Demul uses
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this Demul module: " . moduleName)

settingsFile := modulePath . "\" . moduleName . ".ini"
demulFile := CheckFile(emuPath . "\Demul.ini")
padFile := CheckFile(emuPath . "\padDemul.ini")

controls := IniReadCheck(settingsFile, romname, "controls","standard",,1)	; have to read this first so the below loop works

; Read all the keys from the moduleName ini. Format is:
; Section, Key, Default Value, unique var
iniLookup =
( ltrim c
	Settings, GlobalMax, false
	Settings, MaxHideTaskbar
	Settings, ControllerCode, 16777216
	Settings, MouseCode, 131072
	Settings, KeyboardCode, 1073741824
	Settings, LightgunCode, -2147483648
	Settings, LastControlUsed, standard
	Settings, GlobalPlugin, gpuDX11
	Settings, GlobalShaderUsePass1, false
	Settings, GlobalShaderUsePass2, false
	Settings, GlobalShaderNamePass1
	Settings, GlobalShaderNamePass2
	%romName%, Max
	%romName%, LoadDecrypted
	%romName%, Bios
	%romName%, ShaderUsePass1
	%romName%, ShaderUsePass2
	%romName%, ShaderNamePass1
	%romName%, ShaderNamePass2
	%romName%, Plugin
	%romName%, ListSorting
	%controls%_JAMMA0_0, push1,,push1_0
	%controls%_JAMMA0_0, push2,,push2_0
	%controls%_JAMMA0_0, push3,,push3_0
	%controls%_JAMMA0_0, push4,,push4_0
	%controls%_JAMMA0_0, push5,,push5_0
	%controls%_JAMMA0_0, push6,,push6_0
	%controls%_JAMMA0_0, push7,,push7_0
	%controls%_JAMMA0_0, push8,,push8_0
	%controls%_JAMMA0_0, SERVICE,,service_0
	%controls%_JAMMA0_0, START,,start_0
	%controls%_JAMMA0_0, COIN,,coin_0
	%controls%_JAMMA0_0, DIGITALUP,,digitalup_0
	%controls%_JAMMA0_0, DIGITALDOWN,,digitaldown_0
	%controls%_JAMMA0_0, DIGITALLEFT,,digitalleft_0
	%controls%_JAMMA0_0, DIGITALRIGHT,,digitalright_0
	%controls%_JAMMA0_0, ANALOGUP,,analogup_0
	%controls%_JAMMA0_0, ANALOGDOWN,,analogdown_0
	%controls%_JAMMA0_0, ANALOGLEFT,,analogleft_0
	%controls%_JAMMA0_0, ANALOGRIGHT,,analogright_0
	%controls%_JAMMA0_0, ANALOGUP2,,analogup2_0
	%controls%_JAMMA0_0, ANALOGDOWN2,,analogdown2_0
	%controls%_JAMMA0_0, ANALOGLEFT2,,analogleft2_0
	%controls%_JAMMA0_0, ANALOGRIGHT2,,analogright2_0
	%controls%_JAMMA0_1, push1,,push1_1
	%controls%_JAMMA0_1, push2,,push2_1
	%controls%_JAMMA0_1, push3,,push3_1
	%controls%_JAMMA0_1, push4,,push4_1
	%controls%_JAMMA0_1, push5,,push5_1
	%controls%_JAMMA0_1, push6,,push6_1
	%controls%_JAMMA0_1, push7,,push7_1
	%controls%_JAMMA0_1, push8,,push8_1
	%controls%_JAMMA0_1, SERVICE,,service_1
	%controls%_JAMMA0_1, START,,start_1
	%controls%_JAMMA0_1, COIN,,coin_1
	%controls%_JAMMA0_1, DIGITALUP,,digitalup_1
	%controls%_JAMMA0_1, DIGITALDOWN,,digitaldown_1
	%controls%_JAMMA0_1, DIGITALLEFT,,digitalleft_1
	%controls%_JAMMA0_1, DIGITALRIGHT,,digitalright_1
	%controls%_JAMMA0_1, ANALOGUP,,analogup_1
	%controls%_JAMMA0_1, ANALOGDOWN,,analogdown_1
	%controls%_JAMMA0_1, ANALOGLEFT,,analogleft_1
	%controls%_JAMMA0_1, ANALOGRIGHT,,analogright_1
	%controls%_JAMMA0_1, ANALOGUP2,,analogup2_1
	%controls%_JAMMA0_1, ANALOGDOWN2,,analogdown2_1
	%controls%_JAMMA0_1, ANALOGLEFT2,,analogleft2_1
	%controls%_JAMMA0_1, ANALOGRIGHT2,,analogright2_1
)
Loop, Parse, iniLookup, `n
{
	StringSplit, split, A_LoopField, `,, %A_Space%%A_Tab%
	If split4
		%split4% := IniReadCheck(settingsFile, split1, split2, split3,,1)
	Else
		%split2% := IniReadCheck(settingsFile, split1, split2, split3,,1)
	; need to empty the vars for the next loop otherwise they will still have values from the previous loop
	split3:=
	split4:=
}

; Now compare global & rom keys to get final value
max := If (max = "" or max = "ERROR") ? globalMax : max
plugin := If (plugin = "" or plugin = "ERROR") ? globalPlugin : plugin
shaderUsePass1 := If (shaderUsePass1 = "" or shaderUsePass1 = "ERROR") ? globalShaderUsePass1 : shaderUsePass1
shaderUsePass2 := If (shaderUsePass2 = "" or shaderUsePass2 = "ERROR") ? globalShaderUsePass2 : shaderUsePass2
shaderNamePass1 := If (shaderNamePass1 = "" or shaderNamePass1 = "ERROR") ? globalShaderNamePass1 : shaderNamePass1
shaderNamePass2 := If (shaderNamePass2 = "" or shaderNamePass2 = "ERROR") ? globalShaderNamePass2 : shaderNamePass2

; Verify user set desired gpu plugin name correctly
If ( plugin != "gpuDX11" And plugin != "gpuDX10" ) or ( plugin = "" or plugin = "ERROR" )
	ScriptError(plugin . " is not a supported gpu plugin.`nLeave the plugin blank to use the default ""gpuDX11"".`nValid options are gpuDX11, or gpuDX10.")

; check for the specified gpu plugin
gpuFile := CheckFile(emuPath . "\" . plugin . ".ini")

; This updates the DX11gpu ini file to turn List Sorting on or off. Depending on the games, turning this on for some games may remedy missing graphics, having it off on other games may fix corrupted graphics. Untill they improve the DX11gpu, this is the best it's gonna get.
;If plugin = gpuDX11
If ( plugin = "gpuDX11" ) Or ( plugin = "gpuDX10" )
	If ListSorting = true
		IniWrite, 0, %gpuFile%, main, AutoSort	; 0 enables Auto Sort in demul 0.5.7, opposite from 0.5.6
	Else
		IniWrite, 1, %gpuFile%, main, AutoSort	; Disabling Auto Sort unless someone specifies it to be on or off in settings

; This updates the demul.ini with your gpu plugin choice for the selected rom
IniWrite, %plugin%.dll, %demulFile%, plugins, gpu

 ; Shader Effects
 ;If plugin = gpuDX11
If ( plugin = "gpuDX11" ) Or ( plugin = "gpuDX10" )	; Demul 0.5.7 only supports shaders using the gpuDX11 plugin
 {
	Loop, 2 {
		shaderUsePass%A_Index% := If (ShaderUsePass%A_Index% != "" and ShaderUsePass%A_Index% != "ERROR" ? (ShaderUsePass%A_Index%) : (GlobalShaderUsePass%A_Index%))	; determine what shaderUsePass to use
		IniRead, currentusePass%A_Index%, %gpuFile%, shaders, usePass%A_Index%
		If (shaderUsePass%A_Index% = "true")
		{
			shaderNamePass%A_Index% := If (ShaderNamePass%A_Index% != "" and ShaderNamePass%A_Index% != "ERROR" ? (ShaderNamePass%A_Index%) : (GlobalShaderNamePass%A_Index%))	; determine what shaderNamePass to use
			If shaderNamePass%A_Index% not in FXAA,HDR-TV,SCANLINES,CARTOON,RGB DOT(MICRO),RGB DOT(TINY),BLUR
				ScriptError(shaderNamePass%A_Index% . " is not a valid choice for a shader. Your options are FXAA, HDR-TV, SCANLINES, CARTOON, RGB DOT(MICRO), RGB DOT(TINY), or BLUR.")
			If (currentusePass%A_Index% = 0)
				IniWrite, 1, %gpuFile%, shaders, usePass%A_Index%	; turn shader on in gpuDX11 ini
			IniWrite, % shaderNamePass%A_Index%, %gpuFile%, shaders, shaderPass%A_Index%	; update gpuDX11 ini with the shader name to use
		}Else If (shaderUsePass%A_Index% != "true" and currentusePass%A_Index% = 1)
			IniWrite, 0, %gpuFile%, shaders, usePass%A_Index%	; turn shader off in gpuDX11 ini
	}
}

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
}

; This section writes your custom keys to the padDemul.ini. Naomi games had many control panel layouts. The only way we can accomodate these differing controls, is to keep track of them all and write them to the ini at the launch of each game.
; First we check if the last controls used are the same as the game we want to play, so we don't waste time updating the ini if it is not necessary. For example playing 2 sfstyle type games in a row, we wouldn't need to write to the ini.

; This section tells demul what arcade control type should be connected to the game. Options are standard (aka controller), mouse, lightgun, or keyboard
If ( controls = "lightgun" || controls = "mouse" )
	IniWrite, %MouseCode%, %demulFile%, PORTB, device
Else If ( controls = "keyboard" )
	IniWrite, %KeyboardCode%, %demulFile%, PORTB, device
Else ; accounts for all other control types
	IniWrite, %ControllerCode%, %demulFile%, PORTB, device

If ( LastControlUsed != controls ) {	; find out last controls used for the system we are launching
	WriteControls(padFile, 0,push1_0,push2_0,push3_0,push4_0,push5_0,push6_0,push7_0,push8_0,SERVICE_0,START_0,COIN_0,DIGITALUP_0,DIGITALDOWN_0,DIGITALLEFT_0,DIGITALRIGHT_0,ANALOGUP_0,ANALOGDOWN_0,ANALOGLEFT_0,ANALOGRIGHT_0,ANALOGUP2_0,ANALOGDOWN2_0,ANALOGLEFT2_0,ANALOGRIGHT2_0)
	WriteControls(padFile, 1,push1_1,push2_1,push3_1,push4_1,push5_1,push6_1,push7_1,push8_1,SERVICE_1,START_1,COIN_1,DIGITALUP_1,DIGITALDOWN_1,DIGITALLEFT_1,DIGITALRIGHT_1,ANALOGUP_1,ANALOGDOWN_1,ANALOGLEFT_1,ANALOGRIGHT_1,ANALOGUP2_1,ANALOGDOWN2_1,ANALOGLEFT2_1,ANALOGRIGHT2_1)
	IniWrite, %controls%, %settingsFile%, Settings, LastControlUsed
}

; Setting demul to use true fullscreen if defined in settings.ini, otherwise sets demul to run windowed. This is for gpuDX11 plugin only
If plugin = gpuDX11
	If Max = fullscreen
		IniWrite, 1, %gpuFile%, main, UseFullscreen
	Else
		IniWrite, 0, %gpuFile%, main, UseFullscreen

If Max = true
{
	If maxHideTaskbar = true
	{
		WinHide, ahk_class Shell_TrayWnd
		WinHide, Start ahk_class Button
	}
	; Create black background to give the emu the fullscreen look
	Gui 2: -Caption +ToolWindow
	Gui 2: Color, Black
	Gui 2: Show, x0 y0 h%A_ScreenHeight% w%A_ScreenWidth%
}

Sleep, 250

;  Construct the CLI for demul and send romName if naomi or atomiswave. Dreamcast needs a full path and romName.
If LoadDecrypted = true	; decrypted naomi rom
	romCLI := "-customrom=" . """" . romPath . "\" . romName . ".bin"""
Else If ident = dc	; dreamcast game
	romCLI := " -image=" . """" . romPath . "\" . romName . romExtension . """"
Else	; standard naomi rom
	romCLI := "-rom=" . romName

Run(executable .  " -run=" . ident . " " . romCLI, emuPath,, emuPID)
 ;Sleep, 1000 ; need a second for demul to launch, increase if yours takes longer and the emu is appearing too soon

Loop { ; looping until demul is done loading rom and gpu starts showing frames
	Sleep, 200
	WinGetTitle, winTitle, ahk_class window
	StringSplit, winTextSplit, winTitle, %A_Space%
	If ( winTextSplit5 = "gpu:" And winTextSplit6 != "0" And winTextSplit6 != "1" )
		break
}
WinActivate ahk_class window

If ( ( mType = "Gaelco" Or mType = "gaelco" ) && Max = "fullscreen" )
	Send !{ENTER} ; Automatic fullscreen seems to be broken in the Gaelco driver, must alt+Enter to get fullscreen

; This is where we calculate and maximize demul's window using our pseudo fullscreen code
If Max = true
{
	WinSet, Style, -0x40000, ahk_class window ; Removes the border of the game window
	WinSet, Style, -0xC00000, ahk_class window ; Removes the TitleBar
	Send, {F3} ; Removes the MenuBar
	MaximizeWindow("ahk_class window") ; this will take effect after you run demul once because we cannot stretch demul's screen while it is running.
}

FadeInExit()
Process("WaitClose", executable)

Gui 2: Destroy

7zCleanup()
FadeOutExit()

If (Max = "true" and maxHideTaskbar = "true") {
	WinShow,ahk_class Shell_TrayWnd
	WinShow,Start ahk_class Button
}

ExitModule()


 ; Write new controls to padDemul.ini
WriteControls(file, player,push1,push2,push3,push4,push5,push6,push7,push8,service,start,coin,digitalup,digitaldown,digitalleft,digitalright,analogup,analogdown,analogleft,analogright,analogup2,analogdown2,analogleft2,analogright2) {
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

MaximizeWindow(class) {
		Global
		WinGetPos, appX, appY, appWidth, appHeight, %class%
		widthMaxPercenty := ( A_ScreenWidth / appWidth )
		heightMaxPercenty := ( A_ScreenHeight / appHeight )

		If  ( widthMaxPercenty < heightMaxPercenty )
			percentToEnlarge := widthMaxPercenty
		Else
			percentToEnlarge := heightMaxPercenty

		appWidthNew := appWidth * percentToEnlarge
		appHeightNew := appHeight * percentToEnlarge
		Transform, appX, Round, %appX%
		Transform, appY, Round, %appY%
		Transform, appWidthNew, Round, %appWidthNew%
		Transform, appHeightNew, Round, %appHeightNew%
		appXPos := ( A_ScreenWidth / 2 ) - ( appWidthNew / 2 )
		appYPos := ( A_ScreenHeight / 2 ) - ( appHeightNew / 2 )
		If ( plugin = "gpuDX11" ) {
			IniWrite, %appWidthNew%, %gpuDX11File%, resolution, Width
			IniWrite, %appHeightNew%, %gpuDX11File%, resolution, Height
		} Else {
			IniWrite, %appWidthNew%, %gpuFile%, resolution, wWidth
			IniWrite, %appHeightNew%, %gpuFile%, resolution, wHeight
		}
		WinMove, %class%,, appXPos, appYPos
	}

HaltEmu:
	If Max = fullscreen
		Send !{ENTER}
Return
RestoreEmu:
	If Max = fullscreen
		Send !{ENTER}
Return

CloseProcess:
	FadeOutStart()
	If fadeOut != true	; cannot send ALT+F4 to a background window (controlsend doesn't work), so we have to force close instead.
	{
		; demul 0.5.7 crashes 50% of the time if you try to close it any other way
		Send, {F3}{Alt}{Up}s{Enter}
		Sleep, 50
	}
	Process("Close", emuPID) ; we have to close this way otherwise demul crashes with WinClose
Return
