MEmu = MakaronEX
MEmuV = v4.01
MURL = http://www.emu-land.net/consoles/dreamcast/emuls/windows
MAuthor = djvj
MVersion = 2.0.2
MCRC = E94322C5
iCRC = 2B4EA0AE
MID = 635038268902883049
MSystem = "Sega Dreamcast","Sega Naomi"
;----------------------------------------------------------------------------
; Notes:
; Set fullscreen via the variable below
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
enable2Players := IniReadCheck(settingsFile, "Settings", "Enable2Players","true",,1)

dialogOpen := i18n("dialog.open")	; Looking up local translation
hideEmuObj := Object(dialogOpen . " ahk_class #32770",0,"MakaronEX ahk_class TForm1",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later

SetControlDelay, %ControlDelay%
SetKeyDelay(KeyDelay)

If systemName contains naomi
	makINI := CheckFile(emuPath . "\Naomi\Naomi.ini")
Else If systemName contains dreamcast,dc
	makINI := CheckFile(emuPath . "\Dreamcast\Makaron.ini")
Else
	ScriptError(systemName . " is not a recognized (aka supported) System Name for this module")

IniRead, currentFullScreen, %makINI%, Settings, fullscreen 

; Setting Fullscreen setting in ini if it doesn't match what user wants above
If ( Fullscreen != "true" And currentFullScreen = 1 )
	IniWrite, 0, %makINI%, Settings, fullscreen
Else If ( Fullscreen = "true" And currentFullScreen = 0 )
	IniWrite, 1, %makINI%, Settings, fullscreen

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

Run(executable, emuPath, (If InStr(systemName,"naomi") ? "hide":""))

WinWait("MakaronEX ahk_class TForm1")
WinWaitActive("MakaronEX ahk_class TForm1")
If systemName contains naomi
{	; ControlClick, TToolBar1, MakaronEX ahk_class TForm1,, L,1,x240 y5 ; Click Naomi on Toolbar
	Control, Check,, TToolBar1, MakaronEX ahk_class TForm1 ; Somehow this selects Naomi on Toolbar... mmkay
	WinMenuSelectItem, MakaronEX ahk_class TForm1,, File, Open Rom, 2& ; Open Naomi T12.7 roms
	makEXTitle = NAOMI - PVR ahk_class PVR2
} Else If systemName contains dreamcast,dc
{	WinMenuSelectItem, MakaronEX ahk_class TForm1,, File, Open Image ; Open Image for dreamcast
	makEXTitle = Makaron - PVR ahk_class PVR2
}

WinWait(dialogOpen . " ahk_class #32770")
WinWaitActive(dialogOpen . " ahk_class #32770")

OpenROM(dialogOpen . " ahk_class #32770", romPath . "\" . romName . romExtension)

WinWait(makEXTitle)
WinWaitActive(makEXTitle)

If enable2Players = true
	PostMessage, 0x111, 40115,,,%makEXTitle%	; Enable 2 players

HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
FadeOutExit()
ExitModule()


HaltEmu:
	If fullscreen = true
		disableActivateBlackScreen = true
Return

CloseProcess:
	FadeOutStart()
	If WinActive("MakaronEX ahk_class TForm1")
		WinClose("MakaronEX ahk_class TForm1")
	Else {
		ControlSend,, {F8}, %makEXTitle%
		WinWait("MakaronEX ahk_class TForm1")
		WinActivate, MakaronEX ahk_class TForm1
		WinClose("MakaronEX ahk_class TForm1")
	}
Return
