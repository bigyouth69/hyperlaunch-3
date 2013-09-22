MEmu = SuperModel
MEmuV = r251
MURL = http://www.supermodel3.com/
MAuthor = djvj & chillin
MVersion = 2.0.3
MCRC = 11990B8A
iCRC = 7677A2C1
MID = 635038268926572770
MSystem = "Sega Model 3"
;----------------------------------------------------------------------------
; Notes:
; Required settings.ini file found on the ftp @ /Upload Here/djvj/Sega Model 3/ goes in the folder with this module
; Set ConfigInputs to true if you want to configure the controls for the emulator. Set to false when you want to play a game
;----------------------------------------------------------------------------
StartModule()
BezelGui()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings|" . romName, "Fullscreen","true",,1)
Widescreen := IniReadCheck(settingsFile, "Settings|" . romName, "Widescreen","true",,1)
ConfigInputs := IniReadCheck(settingsFile, "Settings|" . romName, "ConfigInputs","false",,1)
screenWidth := IniReadCheck(settingsFile, "Settings|" . romName, "ScreenWidth",A_ScreenWidth,,1)	; Width
screenHeight := IniReadCheck(settingsFile, "Settings|" . romName, "ScreenHeight",A_ScreenHeight,,1)	; Height
vertShader := IniReadCheck(settingsFile, "Settings|" . romName, "VertShader",A_Space,,1)					; Filename of the 3D vertex shader
vertShader := GetFullName(vertShader)	; convert from relative to absolute
fragShader := IniReadCheck(settingsFile, "Settings|" . romName, "FragShader",A_Space,,1)					; Filename of the 3D fragment shader
fragShader := GetFullName(fragShader)	; convert from relative to absolute
inputSystem := IniReadCheck(settingsFile, "Settings|" . romName, "InputSystem","dinput",,1)				; Choices are dinput (default), xinput, & rawinput. Use dinput for most setups. Use xinput if you use XBox 360 controllers. Use rawinput for multiple mice or keyboard support.
forceFeedback := IniReadCheck(settingsFile, "Settings|" . romName, "ForceFeedback","true",,1)			; Turns on force feedback if you have a controller that supports it. Scud Race' (including 'Scud Race Plus'), 'Daytona USA 2' (both editions), and 'Sega Rally 2' are the only games that support it.
frequency := IniReadCheck(SettingsFile, "Settings|" . romName, "Frequency","25",,1)
throttle := IniReadCheck(SettingsFile, "Settings|" . romName, "Throttle","false",,1)
multiThreading := IniReadCheck(SettingsFile, "Settings|" . romName, "MultiThreading","true",,1)
musicVolume := IniReadCheck(SettingsFile, "Settings|" . romName, "MusicVolume",,,1)
soundVolume := IniReadCheck(SettingsFile, "Settings|" . romName, "SoundVolume",,,1)

BezelStart()

If bezelEnabled = true	; If bezels are enabled, the emu's width and height need to be set to the width and height of the bezel. Otherwise the user defined width and height are used.
{	screenWidth := If bezelEnabled = "true" ? bezelScreenWidth : screenWidth
	screenHeight := If bezelEnabled = "true" ? bezelScreenHeight : screenHeight
}

freq := If frequency != "" ? "-ppc-frequency=" . frequency : ""
throttle := If throttle = "true" ? "" : "-no-throttle"
fullscreen := If Fullscreen = "true" ? "-fullscreen" : "-window"
widescreen := If widescreen = "true" ? "-wide-screen" : ""
resolution := If screenWidth != "" ? "-res=" . screenWidth . "`," . screenHeight : ""
vertShader := If vertShader != "" ? "-vert-shader=""" . vertShader . """" : ""
fragShader := If fragShader != "" ? "-frag-shader=""" . fragShader . """" : ""
inputSystem := If inputSystem != "" ? "-input-system=" . inputSystem : ""
forceFeedback := If forceFeedback = "true" ? "-force-feedback" : ""
multiThreading := If multiThreading = "true" ? "-gpu-multi-threaded" : "-no-threads"
musicVolume := If musicVolume != "" ? "-music-volume=" . musicVolume : ""
soundVolume := If soundVolume != "" ? "-sound-volume=" . soundVolume : ""

If ConfigInputs = true
	Run(executable . " -config-inputs", emuPath)
Else
	Run(executable . " """ . romPath . "\" . romName . romExtension . """ " . fullscreen . " " . widescreen . " " . resolution . " " . freq . " " . throttle . " " . vertShader . " " . fragShader . " " . inputSystem . " " . forceFeedback . " " . multiThreading, emuPath, "Min")

WinWait("Supermodel")

If ConfigInputs = true
{	WinWait("ahk_class ConsoleWindowClass")
	WinGetPos,,, width,, ahk_class ConsoleWindowClass
	x := ( A_ScreenWidth / 2 ) - ( width / 2 )
	WinMove, ahk_class ConsoleWindowClass,, %x%, 0,, %A_ScreenHeight%
	WinHide, Supermodel
	WinActivate, ahk_class ConsoleWindowClass
} Else {
	WinWaitActive("Supermodel ahk_class SDL_app")
	Sleep, 1000
	BezelDraw()
}

FadeInExit()
Process("WaitClose", executable)
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("Supermodel ahk_class SDL_app")
Return
