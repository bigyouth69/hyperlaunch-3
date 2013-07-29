MEmu = Nestopia
MEmuV =  v1.42
MURL = http://www.emucr.com/2011/09/nestopia-unofficial-v1420.html
MAuthor = djvj & BBB
MVersion = 2.0
MCRC = 5D376759
iCRC = 656EE1DF
MID = 635038268908287546
MSystem = "Nintendo Entertainment System","Nintendo Famicom","Nintendo Famicom Disk System"
;----------------------------------------------------------------------------
; Notes:
; If using this for Nintendo Famicom Disk System, make sure you place an FDS bios in your bios subfolder for your emu. You will have to select it on first launch of any FDS game.
; Set your fullscreen key to Alt+Enter if it is not already for HyperPause support
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "settings", "Fullscreen","true",,1)
ExitKey := IniReadCheck(settingsFile, "settings", "ExitKey","Esc",,1)
ToggleMenuKey := IniReadCheck(settingsFile, "settings", "ToggleMenuKey","Alt+M",,1)

emuSettingsFile := emuPath . "\" . "nestopia.xml"
FileRead, nesXML, %emuSettingsFile%

IfInString, nesXML, % "<confirm-exit>yes</confirm-exit>"	; find if this setting is not the desired value
	StringReplace, nesXML, nesXML, % "<confirm-exit>yes</confirm-exit>", % "<confirm-exit>no</confirm-exit>"	; turning off confirmation on exit
IfNotInString, nesXML, % "<exit>" . ExitKey . "</exit>"	; find if this setting is not the desired value
{	currentExitKey := StrX(nesXML,"<exit>" ,0,0,"</exit>",0,0)	; trim confirm-exit to what it's current setting is
	StringReplace, nesXML, nesXML, % currentExitKey, % "<exit>" . ExitKey . "</exit>"	; replacing the current exit key to the desired one from above
}
IfNotInString, nesXML, % "<toggle-menu>" . ToggleMenuKey . "</toggle-menu>"	; find if this setting is not the desired value
{	currentMenuKey := StrX(nesXML,"<toggle-menu>" ,0,0,"</toggle-menu>",0,0)	; trim toggle-menu to what it's current setting is
	StringReplace, nesXML, nesXML, % currentMenuKey, % "<toggle-menu>" . ToggleMenuKey . "</toggle-menu>"	; replacing the current toggle-menu key to the desired one from above
}

; Enable Fullscreen
currentFS := StrX(nesXML,"<start-fullscreen>" ,0,0,"</start-fullscreen>",0,0)	; trim start-fullscreen to what it's current setting is
StringReplace, nesXML, nesXML, % currentFS, % "<start-fullscreen>" . ((If Fullscreen = "true")?"yes":"no") . "</start-fullscreen>"	; setting start-fullscreen to the desired setting from above

SaveFile()

7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinActivate, ahk_class Nestopia
WinWaitActive("ahk_class Nestopia")

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


SaveFile(){
	Global emuSettingsFile
	Global nesXML
	FileDelete, %emuSettingsFile%
	FileAppend, %nesXML%, %emuSettingsFile%
}

HaltEmu:
	; Send, !{Enter}
	Sleep, 200
Return
RestoreEmu:
	WinActivate, ahk_id  %emulatorID%
	; Send, !{Enter}
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class Nestopia")
Return
