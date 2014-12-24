MEmu = DOSBox
MEmuV = v0.74
MURL = http://www.dosbox.com/
MAuthor = brolly, djvj
MVersion = 2.0
MCRC = 616AEEC2
iCRC = EEFBA82B
mId = 635535818862708645
MSystem = "Microsoft MS-DOS","Microsoft Windows 3.x"
;----------------------------------------------------------------------------
; Notes:
; This module is geared to work with the eXoDOS sets and folder structure. If you have games not from this set, you will want to use the same structure he uses.
; You can find an Enhanced DOSBox (highly recommended) with many unofficial features on ykhwong's page @ http://ykhwong.x-y.net/
; This enhanced DOSBox is needed for full Microsoft Windows 3.x support. So just stick with that one version for both systems.
; This module is oriented to work with the  eXoDOS sets, but it can work with any DOSBox configured game if you follow some guidelines.
; - Make sure you set Skip Checks to Rom Only
; - Rom Path should point to the folder where you have all the .zip files if you have 7z enabled and the folder where you keep your extracted games 
; if you keep your games extracted. If the games are extracted make sure you keep each game inside it's own sub-folder named after the romName
; - In your Rom Path you should also have the !dos folder that keeps your DOSBox conf files, but you can change the path to this folder in HLHQ, but 
; your configuration files should ALWAYS be kept inside a sub-folder named after your rom name ex. .\Config\bargon\dosbox.conf, .\Config\KQ1\dosbox.conf
; - The DOSbox configuration files should be named dosbox.conf, you can change the name in HLHQ if you prefer
; - If your games are compressed an additional ZipMapping ini file is required and should also be placed on the module folder so you can map 
; the long filenames to the short ones. Should be kept inside %ModulePath%\ZipMapping\%SystemName%.ini.
; When using 7z support, don't forget to set the 7z_Extract_Path on your ini file, if you are using the eXoDOS sets the last folder on this path must be a 
; a folder named "Games" since the conf files for these sets require such a naming. Module will error out if this doesn't happen
; Since eXoDOS sets rely on games being stored inside a folder named Games, if you want to use this module with other DOS sets, you might need to disable the 
; setting that appends 'Games' automatically to your paths under HLHQ
; DOSBox as a nasty habit of getting on top of all windows which might make it appear on top of the fade screen. If you are having this behavior enabled HideEmu in HLHQ
; Many old games place save games inside their own dirs, if you use 7z_Enable and 7z_Delete_Temp is true, you will delete these save games. Set 7z_Delete_Temp to false to prevent this.
;
; Controls are done via in-game options for each game.
; Dosbox.conf information can be found here: http://www.dosbox.com/wiki/Dosbox.conf
; DOSBox cli parameters: http://www.dosbox.com/wiki/Usage
; DOSBox Manual: http://www.dosbox.com/DOSBoxManual.html
; Compatibility List for DOSBox (often find game specific settings needed to get your games to launch): http://www.dosbox.com/comp_list.php?letter=a
;
; Useful DOSBox links:
; http://www.dosbox.com/wiki/Usage
; http://www.dosbox.com/wiki/Dosbox.conf
;
; Multi-PLayer Games info:
; List of multiplayer network dos games: http://web.archive.org/web/19970521185925/http://www.cs.uwm.edu/public/jimu/netgames.html
; GoG IPX list: http://www.gog.com/mix/dos_games_with_ipx_multiplayer
; MobyGames IPX list: http://www.mobygames.com/attribute/sheet/attributeId,82/p,2/
; MobyGames NetBios list: http://www.mobygames.com/attribute/sheet/attributeId,129/
; MobyGames Null Modem list: http://www.mobygames.com/attribute/sheet/attributeId,84/p,2/
; You can download NetBios from here: http://www.classicgamingarena.com/downloads/games/utilities/netbios
;
; Gravis Ultrasound Games:
; If you want to further Enhance the audio in many of the games, try setting these to use Ultrasound: http://www.mobygames.com/attribute/sheet/attributeId,20/
; Ultrasound Install Guide: http://www.vogons.org/viewtopic.php?t=16974
; Ultrasound recommended patches: http://www.dosgames.com/forum/about10574.html
; Extract the ULTRASNDPPL161 folder anywhere you want, default is %EmuPath%\Gravis_UltraSound, and rename it to ULTRAPRO
; Extract the ULTRASND411 to the same folder and rename it to ULTRASND
; If you did not use the default folder, in HLHQ's DOSBox module settings, change Gravis_Ultrasound_Folder to the folder you did.
; In DOSBox, these folders will be found in U:\ if done correctly. Do not try to use this drive for anything else in the DOS environment.
; Each game needs to be set up with the Midi and/or sound effects cards set to Gravis Ultrasound. This can only be done in the dosbox environment and running the game's setup executable. Usually this is setup.exe.
; If you set the proper Backup_Files in HLHQ, HyperLaunch will backup your settings and Ultrasound will work on next launch.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","false",,1)
hideConsole := IniReadCheck(settingsFile, "Settings", "Hide_Console","true",,1)
gusFolder := IniReadCheck(settingsFile, "Settings", "Gravis_Ultrasound_Folder", emuPath . "\Gravis_UltraSound",,1)
setupOnLaunch := IniReadCheck(settingsFile, "Settings|" . romName, "Setup_On_Launch", "false",,1)
requireGamesFolder := IniReadCheck(settingsFile, "Settings|" . romName, "Require_Games_Folder", "true",,1)
fullscreenResolution := IniReadCheck(settingsFile, "Settings|" . romName, "Fullscreen_Resolution", "original",,1)
windowedResolution := IniReadCheck(settingsFile, "Settings|" . romName, "Windowed_Resolution", "original",,1)
confFile := IniReadCheck(settingsFile, "Settings|" . romName, "Conf_File", "dosbox.conf",,1)
enableUltrasound := IniReadCheck(settingsFile, "Settings|" . romName, "Enable_Ultrasound", "false",,1)
scaler := IniReadCheck(settingsFile, "Settings|" . romName, "Scaler", "none",,1)
aspect := IniReadCheck(settingsFile, "Settings|" . romName, "Aspect", "false",,1)
output := IniReadCheck(settingsFile, "Settings|" . romName, "Output", "surface",,1)
internalEmu := IniReadCheck(settingsFile, romName, "Internal_Emu","false",,1)
internalEmuFolder := IniReadCheck(settingsFile, romName, "Internal_Emu_Folder","dosbox",,1)
command := IniReadCheck(settingsFile, romName, "Command", "",,1)
sendCommandDelay := IniReadCheck(settingsFile, "Settings" . "|" . romName, "Send_Command_Delay", "300",,1)
forceExtractionToRomPath := IniReadCheck(settingsFile, "Settings" . "|" . romName, "Force_Extraction_To_Rom_Path", "false",,1)
setupExecutable := IniReadCheck(settingsFile, dbName, "Setup_Executable", "setup.exe",,1)
noMenu := IniReadCheck(settingsFile, romName, "No_Menu", "false",,1)
enableNetworkPlay := IniReadCheck(settingsFile, romName, "Enable_Network_Play","false",,1)
backupFiles := IniReadCheck(settingsFile, romName, "Backup_Files",,,1)
gusFolder := GetFullName(gusFolder)	; convert relative to absolute

shortName := IniReadCheck(modulePath . "\ZipMapping\" . systemName . ".ini", "mapping", romName, romName,,1)
gameExecutable := IniReadCheck(settingsFile, dbName, "Game_Executable", shortName . ".exe",,1)
Log("Module - """ . romName . """ is using the mapped name: """ . shortName . """")

; Following check is because HL must have Skip Checks set to Rom Only but we still need a method for checking something exists that resembles your rom or correct romPath when multiples paths are defined
romPathFound :=
If (7zEnabled != "true") {
	Loop, Parse, romPath, |
	{
		currentPath := A_LoopField
		Log("Module - Searching for a folder: """ . currentPath . "\" . shortName . """",4)
		If InStr(FileExist(currentPath . "\" . shortName), "D")	; checking for a folder that might match
		{
			romPath := currentPath
			romPathFound := true
			Log("Module - romPath updated to: """ . romPath . """",4)
		}
	}
	If !romPathFound
		ScriptError("Couldn't find a folder " . shortName . " in any of these defined rom paths: " . romPath)
} Else If !romExtension
	ScriptError("Couldn't find " . romName . " in any of these defined rom paths: " . romPath)

If (forceExtractionToRomPath = "true") {
	Log("Module - forceExtractionToRomPath is set to true, setting 7zExtractPath to " . romPath . ". Careful when using this setting!",4)
	7zExtractPath := romPath
	Log("Module - 7zExtractPath updated to: """ . romPath . """",4)
}

defaultConfigFolderName := "!dos"
If (systemName = "Microsoft Windows 3.x")
	defaultConfigFolderName := "!win3x"

configFolder := IniReadCheck(settingsFile, "Settings", "Config_Folder", romPath . "\" . defaultConfigFolderName,,1)
originalConfFile := CheckFile(configFolder . "\" . shortName . "\" . confFile)

; Renaming conf file name so it is unique to this PC because on local networks this could have 2 pcs use the same conf which would be bad. Also we don't want to edit the orignal because that would mess up Meagre
customConfCreated :=
If (enableUltrasound ="true" || enableNetworkPlay = "true" || setupOnLaunch = "true") {
	SplitPath, originalConfFile,, tempConfPath, tempConfExt, tempConfFile
	FileCopy, %originalConfFile%, %tempConfPath%\%tempConfFile%.%A_ComputerName%.%tempConfExt%, 1	; copy conf to new unique file name
	confFile := tempConfPath . "\" . tempConfFile . "." . A_ComputerName . "." . tempConfExt
	Log("Module - Conf file was changed to keep it unique to this PC: " . confFile,4)
	customConfCreated := true
} Else
	confFile := originalConfFile
Log("Module - Using conf: " . confFile)

BezelStart("fixResMode")

hideEmuObj := Object("DOSBox ahk_class SDL_app",1)	;Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later

If (7zEnabled = "true") {
	; 7zExtractPath .= "\" . systemName	; tacking on systemName because with rom checks set to Rom Only it won't have it on there
	If (requireGamesFolder = "true" && (SubStr(7zExtractPath,-5) != "\Games")) {	; check to see if your extractPath ends in \Games which is required by eXoDOS sets
		Log("Module - This game requires the final folder in your 7zExtractPath to be \Games for eXoDOS sets, but your path doesn't have that.",4)
		If (7zAttachSystemName = "true") {
			7zExtractPath .= "\" . systemName
			7zAttachSystemName := false		; this needs to be disabled because 7z will tack on the systemName after \Games, instead, we tack it on here before
		}
		7zExtractPath .= "\Games"
		Log("Module - 7zExtractPath change to """ . 7zExtractPath . """",4)
	}
	gamePath := 7zExtractPath
	baseGamesFolder := 7zExtractPath	; baseGamesFolder is the relative folder sent to DOSBox, which becomes the root of your C drive
	If (requireGamesFolder = "true") {
		;Check if extraction path ends in a folder named Games
		SplitPath, 7zExtractPath, gamesFolder, baseGamesFolder
		If (gamesFolder != "Games")
			ScriptError("Please change your 7z Extract Path. Doesn't end in a folder named Games : " . 7zExtractPath)
		If (7zAttachSystemName = "true")
			ScriptError("Please change your 7z Extract Path and disable 7zAttachSystemName as otherwise the path won't end in a folder named Games : " . 7zExtractPath . "\" . systemName)
	}

	;Let's make sure games won't be extracted to the same folder as your config files, as we don't want that
	SplitPath, romPath,, baseRomPath
	If (baseRomPath = configFolder)
		ScriptError("Please change your 7z Extract Path, or it would extract files to your DOSBox configuration files folder : " . configFolder)

	7z(romPath, romName, romExtension, 7zExtractPath,, (If requireGamesFolder = "true" ? 0 : 1),1)	; setting last switch to AllowLargerFolders when extracted paths may be larger due to save games kept in them
} Else {
	baseGamesFolder := romPath
	If (requireGamesFolder = "true") {
		;Check if rom path ends in a folder named Games
		SplitPath, romPath, gamesFolder, baseGamesFolder
		If (gamesFolder != "Games")
			ScriptError("Please change your Rom Path. Doesn't end in a folder named Games")
	}
	gamePath := romPath
}

dosPath = %emuPath%
if (internalEmu = "true")
	dosPath := CheckFile(gamePath . "\" . shortName . "\" . internalEmuFolder)

params := " -scaler " . scaler . " -exit"
If (noMenu = "true")
	params .= " -nomenu"	; Should only be enabled with Taewoong's DOSBox

hideConsole := If hideConsole = "true" ? " -noconsole" : ""

If (fullscreen = "true")
	fullscreen := " -fullscreen"
Else {
	fullscreen :=
	IniRead, currentfullscreen, %confFile%, sdl, fullscreen
	If (currentfullscreen != fullscreen)
		IniWrite, false, %confFile%, sdl, fullscreen
}

;Edit DOSBox conf file if necessary
IniRead, currentaspect, %confFile%, render, aspect
IniRead, currentoutput, %confFile%, sdl, output
IniRead, currentfsresolution, %confFile%, sdl, fullresolution
IniRead, currentwindresolution, %confFile%, sdl, windowresolution
If (currentaspect != aspect)
	IniWrite, %aspect%, %confFile%, render, aspect
If (currentoutput != output)
	IniWrite, %output%, %confFile%, sdl, output
If (currentfsresolution != fullscreenResolution)
	IniWrite, %fullscreenResolution%, %confFile%, sdl, fullresolution
If (currentwindresolution != windowedResolution)
	IniWrite, %windowedResolution%, %confFile%, sdl, windowresolution

restoreConf :=
networkSession :=
If (enableNetworkPlay = "true") {
	Log("Module - Network Multi-Player is an available option for " . dbName,4)
	networkProtocol := IniReadCheck(settingsFile, dbName, "Network_Protocol","IPX",,1)
	onlineEnable := IniReadCheck(settingsFile, "Network", "","false",,1)
	networkRequiresSetup := IniReadCheck(settingsFile, dbName, "Network_Requires_Setup",,,1)
	If (onlineEnable = "true")
		myPublicIP := GetPublicIP()
	defaultServer%networkProtocol%IP := IniReadCheck(settingsFile, "Network", "Default_Server_" . networkProtocol . "_IP", myPublicIP,,1)
	defaultServer%networkProtocol%Port := IniReadCheck(settingsFile, "Network", "Default_Server_" . networkProtocol . "_Port", (If networkProtocol = "IPX" || networkProtocol = "NetBios" ? 213 : 23),,1)
	last%networkProtocol%IP := IniReadCheck(settingsFile, "Network", "Last_" . networkProtocol . "_IP", defaultServer%networkProtocol%IP,,1)	; does not need to be on the ISD
	last%networkProtocol%Port := IniReadCheck(settingsFile, "Network", "Last_" . networkProtocol . "_Port", defaultServer%networkProtocol%Port,,1)	; does not need to be on the ISD

	; Gosub, QuestionUserTemp
	MultiplayerMenu(last%networkProtocol%IP, last%networkProtocol%Port, networkType,, (If networkRequiresSetup = "true" ? 1 : 0))	; supplying the networkRequiresSetup here tells the MP menu to give the user a choice to setup the network first
	networkIP := last%networkProtocol%IP	; for easier reading
	networkPort := last%networkProtocol%Port

	If networkSession {
		Log("Module - Using an " . networkProtocol . " Network for " . dbName,4)
		; Save last used IP and Port for quicker launching next time
		IniWrite, %networkPort%, %settingsFile%, Network, Last_%networkProtocol%_Port
		If (networkType = "client")
			IniWrite, %networkIP%, %settingsFile%, Network, Last_%networkProtocol%_IP

		networkDirectExecutable := IniReadCheck(settingsFile, dbName, "Network_Direct_Executable",,,1)
		maximumPlayers := IniReadCheck(settingsFile, dbName, "Maximum_Players",,,1)

		netBiosCommand :=
		thisLine :=
		parsedNetworkExecutable :=
		ipxClientCommand := "IPXNET CONNECT " . networkIP . " " . networkPort	; command for a client in an IPX network
		ipxServerCommand := "IPXNET STARTSERVER " . networkPort	; command for the server in an IPX network
		ipxSessionCommand := "`r`n" . (If networkType = "client" ? ipxClientCommand : ipxServerCommand)

		If (networkProtocol = "NetBios") {
			netbiosExe := CheckFile(moduleExtensionsPath . "\novell\netbios.exe", "Could not find the netbios.exe, which is required for NetBios connections. Please download and place this file here: """ . moduleExtensionsPath . "\novell\netbios.exe""")
			netBiosCommand := "`r`nMount N " . netbiosExe . "`r`nN:\netbios.exe"	; Mount netbios.exe to the N drive and run it
		}

		If networkRequiresSetup {
			Log("Module - User selected to run this game's Setup mode")
			networkExecutable := setupExecutable
		} Else
			networkExecutable := networkDirectExecutable

		addIPXBlock :=
		If (networkProtocol = "IPX" || networkProtocol = "NetBios" || networkExecutable) {		; these all require the autoexec section to be updated to support network play
			addIPXBlock := true
			If (networkProtocol = "IPX" || networkProtocol = "NetBios") {
				IniRead, currentIPX, %confFile%, ipx, ipx
				If (currentIPX != "true")
					IniWrite, 1, %confFile%, ipx, ipx	; enable ipx network
			}
		}

		If (networkProtocol = "modem" || networkProtocol = "nullmodem") {
			; Modem settings: http://www.dosbox.com/wiki/Connectivity#Modem_emulation
			defaultServerSerialPort := IniReadCheck(settingsFile, "Network", "Default_Server_Serial_Port", 23,,1)
			serialRxDelay := IniReadCheck(settingsFile, "Network", "Serial_RxDelay",,,1)
			serialTxDelay := IniReadCheck(settingsFile, "Network", "Serial_TxDelay",,,1)
			serialInhSocket := IniReadCheck(settingsFile, dbName, "Serial_InhSocket",,,1)
			serialComPort := IniReadCheck(settingsFile, dbName, "Com_Port", "com1",,1)
			
			If (networkProtocol = "modem") {
				If (networkType = "server") {
					IniWrite, %networkProtocol% listenport:%networkPort%, %confFile%, serial, serial1	; MIGHT ONLY WORK ON ENHANCED DOSBOX
				} Else If (networkType = "client") {
					IniWrite, %networkProtocol% listenport:%networkPort%, %confFile%, serial, serial1
					IniWrite, %networkIP%:%networkPort%, %confFile%, serial, phone1
				}
			} Else If (networkProtocol = "nullmodem") {	; same as directserial
				If (networkType = "server") {
					nmValue := networkProtocol . " " . networkPort . (If serialRxDelay ? " " . serialRxDelay : "") . (If serialTxDelay ? " " . serialTxDelay : "")
					IniWrite, %networkProtocol% port:%networkPort%, %confFile%, serial, serial1
				} Else If (networkType = "client") {
					IniWrite, %networkProtocol% server:%networkIP% port:%networkPort%, %confFile%, serial, serial1
				}
			}
		}
		Log("Module - Starting a " . networkProtocol . " using the IP """ . networkIP . """ and PORT """ . networkPort . """",4)
	} Else
		Log("Module - User chose Single Player mode for this session",4)
}

; Ultrasound Support
addedGUS :=
If (enableUltrasound = "pro" || enableUltrasound = "standard") {
	gusPath := If enableUltrasound = "pro" ? "ULTRAPRO" : "ULTRASND"
	IniWrite, true, %confFile%, gus, gus	; enable ultrasound support
	IniWrite, U:\%gusPath%, %confFile%, gus, ultradir	; tell dosbox where to find Ultrasound, hardcoded to U:\
	addedGUS := true
	gusStartTag := "#---------------Ultrasound Start---------------"
	gusEndTag := "#---------------Ultrasound End---------------"
	Log("Module - Gravis Ultrasound has been enabled.",4)
}

; Restoring any backed up files prior to launch.
If backupFiles {
	filesRestored :=
	Log("Module - Looking for backup files to restore for this game session",4)
	dosboxBackupFolder := emuPath . "\BackupFiles\" . dbName
	dosboxRestoreFolder := romPath . "\" . shortName
	Loop, Parse, backupFiles, |
	{
		If InStr(A_LoopField, "..\") {
			newRestorePath := AbsoluteFromRelative(dosboxRestoreFolder, A_LoopField)
			newBackupPath := AbsoluteFromRelative(dosboxBackupFolder, A_LoopField)
			msgbox newRestorePath: %newRestorePath%`nnewBackupPath: %newBackupPath%
			msgbox restore folder: %dosboxRestoreFolder%\%A_LoopField%`nbackup folder: %dosboxBackupFolder%\%A_LoopField%
			Continue	; do not support these files yet
		}
		Log("Module - Restoring """ . dosboxBackupFolder . "\" . A_LoopField . """ to """ . dosboxRestoreFolder . "\" . A_LoopField . """",4)
		FileCopy %dosboxBackupFolder%\%A_LoopField%, %dosboxRestoreFolder%\%A_LoopField%, 1	; only supports files, not folders
		filesRestored++
	}
	Log("Module - Restored " . filesRestored . " backup files for this game session",4)
}

;----------------------------------------------------------------------------
; Rebuild eXo's conf file to add network block and mount the Ultrasound drive
If (addedGUS || addIPXBlock || setupOnLaunch = "true") {
	Log("Module - Rebuilding the conf file.")
	rebuiltAutoexec :=
	confFileData :=
	; removedGamesFolder :=
	replacedWithSetup :=
	replacedWithNet :=
	FileRead, confFileData, %confFile%
	sectionRegEx := "ms)(?<=^\[autoexec\])(?:(?!\r^\[).)*"		; Find from the end of the autoexec section to the next section or the end of file
	matchedPos := regexmatch(confFileData, sectionRegEx, sectionText)    ; Get the key and the value whilst excluding the comments
	rebuiltAutoexec := sectionText		; only want to work with the new var, not the original

	If (addedGUS && !InStr(sectionRegEx, gusStartTag)){		; make sure GUS wasn't already added to the autoexec
		rebuiltAutoexec := "`r`n" . gusStartTag . "`r`nmount u """ . gusFolder . """`r`n" . gusEndTag . "`r`n" . rebuiltAutoexec	; mount Ultrasound folder to the U drive
		Log("Module - Autoexec updated in the conf file with the Ultrasound block.",4)
	} Else If addedGUS
		Log("Module - Autoexec already contains an Ultrasound block, no need to add it again.",4)

	If (addIPXBlock || setupOnLaunch = "true") {
		parseThisText := rebuiltAutoexec
		; parseThisText := sectionText
		rebuiltAutoexec :=
		If (gameExecutable = "")
			ScriptError("You need to set a Game_Executable for Setup_On_Launch or Networking to work. It is used to find the correct place in your dosbox conf for HyperLaunch to insert the Setup executable ot IPX initialization")
		Loop, Parse, parseThisText, `n, `r
		{	thisLine := A_LoopField
			If InStr(thisLine, gameExecutable) {
				If (setupOnLaunch = "true") {
					Loop, Parse, setupExecutable, |	; allow multiple commands to be sent, when delimited by a |
						parsedSetupExecutable .= (If A_Index = 1 ? "" : "`r`n") . A_Loopfield
					thisLine := "`r`n" . parsedSetupExecutable
					replacedWithSetup := true
					Log("Module - Autoexec updated in the conf file with Setup Executable.",4)
				} Else If addIPXBlock {
					secNStart := "`r`n#---------------Network Start---------------"
					secNEnd := "`r`n#---------------Network End----------------`r`n"
					Loop, Parse, networkExecutable, |	; allow multiple commands to be sent, when delimited by a |
						parsedNetworkExecutable .= (If A_Index = 1 ? "" : "`r`n") . A_Loopfield
					thisLine := secNStart . (If networkProtocol = "IPX" || networkProtocol = "NetBios" ? ipxSessionCommand : "") . (If networkProtocol = "NetBios" ? netBiosCommand : "") . (If networkExecutable ? "`r`n" . parsedNetworkExecutable . secNEnd : secNEnd . A_LoopField)
					replacedWithNet := true
					Log("Module - Autoexec updated in the conf file with network connection block.",4)
				}
			}
			rebuiltAutoexec .= (If A_Index = 1 ? "" : "`r`n") . thisLine
		}
		If networkExecutable	; if user set a network executable for this game
			Log("Module - This game requires a different executable to be ran for Multi-Player games. Setting it to run: """ . networkExecutable . """ instead of """ . gameExecutable . """",4)
	}

	If (setupOnLaunch = "true" && !replacedWithSetup)
		ScriptError("Tried searching for """ . gameExecutable . """ but could not locate correct section in """ . confFile . """ to use Setup_On_Launch. Please check your module settings in HLHQ that you entered the correct Game_Executable and Setup_Executable.",10)
	If (networkSession && !replacedWithNet)
		ScriptError("Tried searching for """ . gameExecutable . """ but could not locate correct section in """ . confFile . """ to inject network connection parameters. Please check your module settings in HLHQ that you entered the correct Game_Executable and Network_Executable.",10)

	StringReplace, finalConfData, confFileData, %sectionText%, %rebuiltAutoexec%
	FileDelete, %confFile%	; delete old conf first
	FileAppend, %finalConfData%, %confFile%	; writing the new conf
	Log("Module - Recreated conf file with a new autoexec section: """ . confFile . """")
}
;----------------------------------------------------------------------------

HideEmuStart()

Run("""" . dosPath . "\" . executable . """ -conf " . """" . confFile . """ " . fullscreen . hideConsole . params, baseGamesFolder)

WinWait("DOSBox ahk_class SDL_app")
WinWaitActive("DOSBox ahk_class SDL_app")

WinGetActiveTitle, dosboxTitle
If InStr(dosboxTitle, "Daum")
	Log("Module - This DOSBox is the ykhwong enhanced version")
Else
	Log("Module - This DOSBox is the standard non-enhanced version")
Sleep, 700 ; DOSBox gains focus before it goes fullscreen, this prevents HS from flashing back in due to this

SendCommand(command, sendCommandDelay)
Sleep, 100 ;To allow the command to go through and resize the window if that's the case (Some commands will make the game change the window resolution on start, eg the cracked King's Quest 1)

BezelDraw()
FadeInExit()
HideEmuEnd()
Process("WaitClose", executable)

;Some games create this swap file on C:\ when the cwsdpmi runtime is used so we need to delete it if it exists 
IfExist, %gamePath%CWSDPMI.swp	
	FileDelete, %gamePath%CWSDPMI.swp

If customConfCreated {
	FileDelete, %confFile%
	Log("Module - Deleted temporary conf: " . confFile,4)
}

; Backing up all defined files
If backupFiles {
	filesBackedUp :=
	Log("Module - Looking for files to backup from this game session",4)
	If !FileExist(dosboxBackupFolder)
		FileCreateDir, %dosboxBackupFolder%
	Loop, Parse, backupFiles, |
	{
		SplitPath, A_LoopField, dsName, dsDir, dsExtension, dsNameNoExt
		Log("Module - Backing up """ . dosboxRestoreFolder . "\" . A_LoopField . """ to """ . dosboxBackupFolder . "\" . A_LoopField . """",4)
		If !FileExist(dosboxBackupFolder . "\" . dsDir)
			FileCreateDir, %dosboxBackupFolder%\%dsDir%	; make folder first
		FileCopy %dosboxRestoreFolder%\%A_LoopField%, %dosboxBackupFolder%\%A_LoopField%, 1	; only supports files, not folders
		If ErrorLevel
			Log("Module - Error backing up """ . dosboxRestoreFolder . "\" . A_LoopField . """ to """ . dosboxBackupFolder . "\" . A_LoopField . """",3)
		filesBackedUp++
	}
	Log("Module - Backed up " . filesBackedUp . " files from this game session",4)
}

;If forceExtractionToRomPath is true we need to feed 7zCleanUp with the folder directly or the whole Games folder would be deleted
7zCleanUp(If forceExtractionToRomPath ? 7zExtractPath . "\" . shortName : "")

BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("ahk_class SDL_app")
Return
