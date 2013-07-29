MEmu = SuperModel
MEmuV = r251
MURL = http://www.supermodel3.com/
MAuthor = djvj & chillin
MVersion = 2.0
MCRC = 9542479
iCRC = B5F25585
MID = 635038268926572770
MSystem = "Sega Model 3"
;----------------------------------------------------------------------------
; Notes:
; Required settings.ini file found on the ftp @ /Upload Here/djvj/Sega Model 3/ goes in the folder with this module
; Set ConfigInputs to true if you want to configure the controls for the emulator. Set to false when you want to play a game
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
Widescreen := IniReadCheck(settingsFile, "Settings", "Widescreen","true",,1)
ConfigInputs := IniReadCheck(settingsFile, "Settings", "ConfigInputs","false",,1)
Resolution := IniReadCheck(settingsFile, "Settings", "Resolution",A_ScreenWidth . "`," . A_ScreenHeight,,1)	; Width,Height
vertShader := IniReadCheck(settingsFile, "Settings", "vertShader",A_Space,,1)					; Filename of the 3D vertex shader
fragShader := IniReadCheck(settingsFile, "Settings", "fragShader",A_Space,,1)					; Filename of the 3D fragment shader
inputSystem := IniReadCheck(settingsFile, "Settings", "inputSystem","dinput",,1)				; Choices are dinput (default), xinput, & rawinput. Use dinput for most setups. Use xinput if you use XBox 360 controllers. Use rawinput for multiple mice or keyboard support.
forceFeedback := IniReadCheck(settingsFile, "Settings", "forceFeedback","true",,1)			; Turns on force feedback if you have a controller that supports it. Scud Race' (including 'Scud Race Plus'), 'Daytona USA 2' (both editions), and 'Sega Rally 2' are the only games that support it.

frequency := IniReadCheck(SettingsFile, romName, "frequency","25",,1)
throttle := IniReadCheck(SettingsFile, romName, "throttle","25",,1)

; freq = -ppc-frequency=%frequency%
freq := (If frequency != "" ? ("-ppc-frequency=" . frequency) : (""))
throttle := (If throttle = "true" ? ("") : ("-no-throttle"))
fullscreen := (If Fullscreen = "true" ? ("-fullscreen") : ("-window"))
widescreen := (If widescreen = "true" ? ("-wide-screen") : (""))
resolution := (If Resolution != "" ? ("-res=" . Resolution) : (""))
vertShader := (If vertShader != "" ? ("-vert-shader=" . vertShader) : (""))
fragShader := (If fragShader != "" ? ("-frag-shader=" . fragShader) : (""))
inputSystem := (If inputSystem != "" ? ("-input-system=" . inputSystem) : (""))
forceFeedback := (If forceFeedback = "true" ? ("-force-feedback") : (""))

If ConfigInputs = true
	Run(executable . " -config-inputs",emuPath)
Else
	Run(executable . " """ . romPath . "\" . romName . romExtension . """ " . fullscreen . " " . widescreen . " " . resolution . " " . freq . " " . throttle . " " . vertShader . " " . fragShader . " " . inputSystem . " " . forceFeedback,emuPath,"Min")

WinWait("Supermodel")

If ConfigInputs = true
{	WinWait("AHK_class ConsoleWindowClass")
	WinGetPos,,, width,, AHK_class ConsoleWindowClass
	x := ( A_ScreenWidth / 2 ) - ( width / 2 )
	WinMove, AHK_class ConsoleWindowClass,, %x%, 0,, %A_ScreenHeight%
	WinHide, Supermodel
	WinActivate, AHK_class ConsoleWindowClass
} Else {
	WinWaitActive("Supermodel ahk_class SDL_app")
	Sleep, 1000
}

FadeInExit()
Process("WaitClose", executable)
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("Supermodel ahk_class SDL_app")
Return
