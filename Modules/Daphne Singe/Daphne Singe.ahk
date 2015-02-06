MEmu = Daphne Singe
MEmuV =  v1.14
MURL = http://www.singeengine.com/cms/
MAuthor = djvj
MVersion = 2.0.4
MCRC = 2CBC6BD2
iCRC = 777E5B50
MID = 635038268880264228
MSystem = "American Laser Games","WoW Action Max"
;----------------------------------------------------------------------------
; Notes:
; Rom_Extension should be singe
; Your framefiles need to exist in the same dir as your Rom_Path, in each game's subfolder, and have a txt extension. The filename should match the name in your xml.
; If you are upgrading from the old daphne-singe-v1.0 to 1.14, don't forget to copy the old singe dir to the new emu folder, it doesn't come with the contents of that folder that you need.
; For this emu to work, paths need to be set in the singe files pointing to the movie files. The old method was done with manual file edits. The new method has the module do it for you automatically.
;
; NEW METHOD:
; Do nothing!
;
; OLD METHOD:
; American Laser Games
; For example,  If you rompath is C:Hyperspin\Games\American Laser Games\, the drugwars game would be found in C:Hyperspin\Games\American Laser Games\maddog\
; and the framefile would be in C:Hyperspin\Games\American Laser Games\maddog\maddog.txt
; To change the dir you want to run your games from:
; 1. Backup all your /daphne/singe/ROMNAME/ROMNAME.singe, cdrom-globals.singe, and service.singe files, most games all three in each romdir
; 2. Move all the folders in your /daphne/singe/ folder to the new location you want. You should have one folder for each game.
; 3. Open each ROMNAME.singe, cdrom-globals.singe, and service.singe in notepad and do a find/replace of all instances shown below. For example using an SMB share:
; Old
; ("singe/
; New:
; ("//SERVER/Hyperspin/Games/American Laser Games/
;
; If using a local drive, it would look something like this C:/Hyperspin/Games/American Laser Games/

; WoW Action Max
; Emu_Path should be something like this C:\HyperSpin\Emulators\WoW Action Max\daphne-singe\
; Rom_Path has to point to where all the m2v video files are kept
; Rom_Extension should be singe
; Your framefiles need to exist in the same dir as your rompath and all have txt extensions. The filename should match the name in your xml.
; To change the dir you want to run your games from:
; 1. Backup your /daphne/singe/Action Max/Emulator.singe file
; 2. Move all the files (except Emulator.singe) in your /daphne/singe/Action Max/ folder to the new location you want.
; 3. Open Emulator.singe in notepad and do a find/replace of all instances shown below. For example using an SMB share:
; Old
; "singe/Action Max/
; New:
; "//SERVER/Hyperspin/Games/WoW Action Max/
;
; If using a local drive, it would look something like this C:/Hyperspin/Games/WoW Action Max/
;
; There should be 18 instances that need replacing.
; 4. The only file that should be in your /daphne/singe/Action Max/ dir should be the edited Emulator.singe file (and your backup).
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "settings", "Fullscreen","true",,1)
globalParams := IniReadCheck(settingsFile,"settings","globalParams","",,1)
daphneWidth := IniReadCheck(settingsFile, "settings", "daphneWidth","1024",,1)
daphneHeight := IniReadCheck(settingsFile, "settings", "daphneHeight","768",,1)
singePathUpdate := IniReadCheck(settingsFile, "settings", "SingePathUpdate","true",,1)
forcePathUpdate := IniReadCheck(settingsFile, "settings", "ForcePathUpdate","false",,1)
params := IniReadCheck(settingsFile,romName,"params","",,1)
params := " " . globalParams . " " .  params

BezelStart()

; Emptying variables If they are not set
fullscreen := If fullscreen = "true" ? " -fullscreen_window" : ""	; fullscreen_window mode allows guncon and aimtraks to work
If bezelPath   ; this variable is only filled if bezel is enabled and a valid bezel image is found
{	params := params . " -ignore_aspect_ratio"
	daphneWidth := " -x " . Round(bezelScreenWidth)  ;bezelScreenWidth variable is defined on the BezelStart function and it gives the desired width that your game screen should have while using this bezel 
	daphneHeight := " -y " . Round(bezelScreenHeight) ;idem above
} Else {
	daphneWidth := " -x " . daphneWidth
	daphneHeight := " -y " . daphneHeight  
}

hideEmuObj := Object("DAPHNE ahk_class SDL_app",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

If singePathUpdate = true
	SingePathUpdate()

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

; This allows us to send variables, that when empty, are not sent to the Run command
Run(executable . " singe vldp" . daphneWidth . daphneHeight . fullscreen . params . " -framefile """ . romPath . "\" . romName . ".txt"" -script """ . romPath . "\" . romName . ".singe""", emuPath)

WinWait("DAPHNE ahk_class SDL_app")
WinWaitActive("DAPHNE ahk_class SDL_app")

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


SingePathUpdate(){
	Global romPath,romName,updatedLines,forcePathUpdate,systemName,emuPath
	Log("SingePathUpdate - Started")
	FileFullPath := []
	updatedLines := 0
	singeData :=
	singeCount :=
	singeUpdateStrings := ["dofile(","spriteLoad","io.input","io.output","fontLoad","soundLoad"]	; look for these strings in the singe files

	; Check if paths have been updated prior
	romSingeFile := romPath . "\" . romName . ".singe"
	FileRead, romSingeData, %romSingeFile%
	StringReplace, rompathCommonSlash, romPath, \, /, all
	If InStr(romSingeData, rompathCommonSlash)
		If (forcePathUpdate = "false") {
			Log("SingePathUpdate - """ . romSingeFile . """ contains the current Rom Path. Skipping the SingePathUpdate function because your files appear to have the correct paths already set. If you want to force a path update, please set the ForcePathUpdate variable in the Daphne Singe module options in HLHQ to true.")
			Log("SingePathUpdate - Ended")
			Return
		}

	If InStr(systemName, "Action") {	; WoW Action Max
		emuSingeFile := emuPath . "\singe\ActionMax\Emulator.singe"
		FileRead, emuSingeData, %emuSingeFile%
		FileFullPath[1,1] := emuSingeFile
		FileFullPath[1,2] := emuSingeData
		FileFullPath[2,1] := romSingeFile
		FileFullPath[2,2] := romSingeData
		Log("SingePathUpdate - Added the " . romName . ".singe and Emulator.singe to be updated",4)
	} Else {	; basically only American Laser Games
		Loop, % romPath . "\*.singe"
		{	FileRead, singeData, %A_LoopFileFullPath%
			Loop % singeUpdateStrings.MaxIndex() {	; for each string in the array
				If InStr(singeData, singeUpdateStrings[A_Index]) {	; check each singe file for the strings
					singeCount++
					FileFullPath[singeCount,1] := A_LoopFileFullPath	; building a table of each .singe file in the romPath and storing it in row 1
					FileFullPath[singeCount,2] := singeData		; inserting the file data into row 2
					Log("SingePathUpdate - Found a file that needs to have its paths updated: " . A_LoopFileFullPath,4)
					Break	; go to next file
				}
			}
		}
	}
	Log("SingePathUpdate - " . FileFullPath.MaxIndex() . " files will have their paths updated")

	Loop, % FileFullPath.MaxIndex()
	{
		currentSingeIndex := A_Index
		Log("SingePathUpdate - Now updating this singe file's paths: " . FileFullPath[currentSingeIndex,1],4)
		updatedText :=
		currentData := FileFullPath[currentSingeIndex,2]
		Loop, Parse, currentData, `n, `r
		{
			oldSingeLine := A_LoopField
			lineUpdated :=
			Loop % singeUpdateStrings.MaxIndex()	; for each string in the array
				If InStr(oldSingeLine, singeUpdateStrings[A_Index]) {	; check each singe file for the strings
					updatedText .= (If A_Index = 1 ? "" : "`r`n") . UpdateLine(oldSingeLine, singeUpdateStrings[A_Index])
					lineUpdated := 1
				}
			If !lineUpdated	; if line was not found above, just put the old line back
				updatedText .= (If A_Index = 1 ? "" : "`r`n") . A_LoopField
		}
		Log("SingePathUpdate - Deleting file: " . FileFullPath[currentSingeIndex,1],4)
		FileDelete, % FileFullPath[currentSingeIndex,1]
		Log("SingePathUpdate - Recreating file: " . FileFullPath[currentSingeIndex,1],4)
		FileAppend, %updatedText%, % FileFullPath[currentSingeIndex,1]
	}
	Log(updatedLines . " Singe paths updated by HyperLaunch.")
	Log("SingePathUpdate - Ended")
	Return
}

UpdateLine(oldLine, string) {
	Global rompath,emuPath,systemName,updatedLines
	StringReplace, rompathCommonSlash, romPath, \, /, all
	StringReplace, emupathCommonSlash, emuPath, \, /, all
	StringReplace, string2, string, ., \., all
	regex = i)%string2%.*/\K(?:.(?!/))+$|%string2%.*\\\K(?:.(?!\\))+$
	If RegExMatch(RegExReplace(oldLine,"\s*$",""), regex, matchedLine)
	{
		If (InStr(systemName, "Action") and InStr(matchedLine, "framework.singe"))
			Line := RegExReplace(RegExReplace(oldLine,"\s*$",""), string2 . "\(.*\)$", string . "(" . """" . emupathCommonSlash . "/singe/singe/" . matchedLine)
		Else If (InStr(systemName, "Action") and InStr(matchedLine, "emulator.singe"))
			Line := RegExReplace(RegExReplace(oldLine,"\s*$",""), string2 . "\(.*\)$", string . "(" . """" . emupathCommonSlash . "/singe/ActionMax/" . matchedLine)
		Else
			Line := RegExReplace(RegExReplace(oldLine,"\s*$",""), string2 . "\(.*\)$", string . "(" . """" . rompathCommonSlash . "/" . matchedLine)
		updatedLines++
	} Else
		Line := oldLine
	Log("UpdateLine - " . line,4)
	Return Line
}

HaltEmu:
	Send, {P}
Return
RestoreEmu:
	Winrestore, AHK_class %EmulatorClass%
	Send, {P}
Return

CloseProcess:
	FadeOutStart()
	BezelExit()
	WinClose("DAPHNE ahk_class SDL_app")
	;Process, Close, %executable% ; WoW Action Max module used this
Return
