MEmu = PCLauncher
MEmuV =  N/A
MURL = https://sites.google.com/site/hyperlaunch2/additional-features/pclauncher
MAuthor = djvj
MVersion = 2.0.8
MCRC = 5171E760
iCRC = 987FA370
mId = 635243126483565041
MSystem = "Fan Remakes","Games for Windows","Microsoft Windows","PCLauncher","PC Games","Steam","Steam Big Picture","Taito Type X","Touhou"
;----------------------------------------------------------------------------
; Notes:
; Use the examples in the ini, in your Modules\PCLauncher\ folder, to add more applications.
; PCLauncher supports per-System inis. Copy your PCLauncher ini in the same folder and rename it to match the System's Name. Use this if you have games with the same name across multiple systems.
; Read the comments at the top of ini for the definitions of each key.
; For informaion on how to use this module and what all the settings do, please see https://sites.google.com/site/hyperlaunch2/additional-features/pclauncher
;----------------------------------------------------------------------------
StartModule()

If (romExtensions != "")
	ScriptError("PCLauncher does not use extensions, but you have them set to: """ . romExtensions . """. Please remove all extensions from the PCLauncher emulator in HyperLaunchHQ to continue using it.")

FadeInStart()

IfExist, % modulePath . "\" . systemName . ".ini"	; use a custom systemName ini if it exists
	settingsFile := modulePath . "\" . systemName . ".ini"
Else
	settingsFile := CheckFile(modulePath . "\" . moduleName . ".ini", "Could not find """ . modulePath . "\" . moduleName . ".ini"". HyperLaunchHQ will create this file when you configure your first game to be used with this " . MEmu . " module.")

iniLookup = SteamID|Application|AppWaitExe|DiscImage|Parameters|OriginGame|WorkingFolder|PreLaunch|PreLaunchParameters|PreLaunchSleep|PostLaunch|PostLaunchParameters|PostLaunchSleep|PostExit|PostExitParameters|PostExitSleep|ExitMethod|FadeTitle|FadeInExitSleep|HideCursor
Loop, Parse, iniLookup, |
{	%A_LoopField% := IniReadCheck(settingsFile, dbName, A_LoopField, A_Space,,1)
	If A_LoopField in Application
		If (!Application && !SteamID) { ; Create keys if they do not exist in the ini and this is not a steam game
			IniWrite, %A_Space%, %SettingsFile%, %dbName%, %A_LoopField%
			missingKeys = 1
		}
}
hideCursor := IniReadCheck(settingsFile, "Settings|" . dbName, "HideCursor",,,1)

If (missingKeys && !SteamID)
	ScriptError("You have not set up " . dbName . " in HLHQ yet, so PCLauncher does not know what exe, FadeTitle, and/or SteamID to watch for.")

; If Application needs a cd/dvd image in the drive, mount it in DT first
If DiscImage {
	Log("PCLauncher - Application is a Disc Image, mounting it in DT")
	appIsImage=1
	DiscImage := GetFullName(DiscImage)	; convert a relative path defined in the PCLauncher ini to absolute
	CheckFile(DiscImage,"Cannot find this DiscImage for " . dbName . ":`n" . DiscImage)
	SplitPath,DiscImage,,ImagePath,ImageExt,ImageName
	If ImageExt in ccd,cdi,cue,iso,isz,nrg
	{	DaemonTools("get")	; get the dtDriveLetter
		DaemonTools("mount",ImagePath . "\" . ImageName . "." . ImageExt)
	} Else
		ScriptError("You defined a DiscImage, but it is not a supported format for this module and/or DT:`nccd,cdi,cue,iso,isz,nrg")
}

; Verify module's settings are set
CheckSettings()

If hideCursor = true
	SystemCursor("Off")

If PreLaunch {
	Log("PCLauncher - PreLaunch set by user, running: " . PreLaunch)
	PreLaunchParameters := If (!PreLaunchParameters or PreLaunchParameters="ERROR" ) ? "" : PreLaunchParameters
	errLevel := Run(If preLSkip ? PreLaunch : """" . PreLaunchName . """ " . PreLaunchParameters, PreLaunchPath)
	If errLevel
		ScriptError("There was a problem launching your PreLaunch application. Please check it is a valid executable.")
	Sleep, %PreLaunchSleep%
}

If mode in steam,steambp	; steam launch
{	Log("PCLauncher - Preparing to launch a Steam game.")
	RegRead, steamPath, HKLM, Software\Valve\Steam, InstallPath
	Log("PCLauncher - Steam install path: " . steamPath)
	steamExe := "Steam.exe"
	CheckFile(steamPath . "\" . steamExe)
	steamPID := Process("Exist", steamExe)
	curDHW := A_DetectHiddenWindows	; record current setting to be restored later
	DetectHiddenWindows, OFF	; this has to be off otherwise if steam is running it will falsely detect the Login window
	If (steamPID && (WinExist("Steam Login") != "0x0")) {	; if steam is running, but at the login window, we need to close it first, then rerun it with our login info
		Log("PCLauncher - Steam is already running and at the login window.")
		Gosub, SteamLogin
	} Else If !steamPID {	; if steam is not running at all, start it with our login info
		Log("PCLauncher - Steam is not running.")
		Gosub, SteamLaunch
	} Else {
		Log("PCLauncher - Steam is already running, using steam browser protocol to launch game.")
		If mode = steam
			Run("steam://rungameid/" . SteamID .  " " . Parameters)
		Else
			Run(Application .  " " . Parameters)
	}
	DetectHiddenWindows, %curDHW%	; restoring previous setting
} Else If mode = origin		; origin launch
{	Log("PCLauncher - Checking Origin status.")
	RegRead, originFullPath, HKLM, Software\origin, ClientPath
	Log("PCLauncher - Origin install path: " . originPath)
	CheckFile(originFullPath)
	SplitPath, originFullPath, originExe, originPath
	originLoginWindow := "Origin ahk_class QWidget"
	OriginPID := Process("Exist", originExe)
	If (OriginPID && (WinExist(originLoginWindow) != "0x0")) {	; if Origin is running, but at the login window, we need to close it first, then rerun it with our login info
		WinGet, orResize, Style, %originLoginWindow%
		If (orResize & 0x10000)	; testing if the window has WS_MAXIMIZEBOX, the only difference between the Origin Main Window and the Origin Login Window
			Log("PCLauncher - Origin is already running and logged in. Skipping login scripts and running game.")
		Else {
			Log("PCLauncher - Origin is already running and at the login window.")
			Gosub, OriginLogin
		}
	} Else If !OriginPID {	; if Origin is not running at all, start it with our login info
		Log("PCLauncher - Origin is not running.")
		Gosub, OriginLaunch
	} Else {
		Log("PCLauncher - Origin is already running and looks to be logged in as no login window was detected.")
	}
	errLevel := Run(ApplicationName . " " . Parameters, ApplicationPath,, AppPID)
	If errLevel
		ScriptError("There was a problem launching your Application. Please check it is a valid executable.")
} Else {
	If mode = url
	{	Log("PCLauncher - Launching URL.")
		errLevel := Run(Application)
	} Else {	; standard launch
		Log("PCLauncher - Launching a standard application.")
		errLevel := Run("""" . (If WorkingFolder ? ApplicationPath . "\" : "") . ApplicationName . """ " . Parameters, If WorkingFolder ? WorkingFolder : ApplicationPath,, AppPID)
	}
	If errLevel
		ScriptError("There was a problem launching your " . (If appIsImage ? "ImageExe" : "Application") . ". Please check it is a valid executable.")
}

If PostLaunch {
	Log("PCLauncher - PostLaunch set by user, running: " . PostLaunch)
	PostLaunchParameters := If (!PostLaunchParameters or PostLaunchParameters="ERROR" ) ? "" : PostLaunchParameters
	errLevel := Run(If postLSkip ? PostLaunch : """" . PostLaunchName . """ " . PostLaunchParameters, PostLaunchPath)
	If errLevel
		ScriptError("There was a problem launching your PostLaunch application. Please check it is a valid executable.")
	Sleep, %PostLaunchSleep%
}

If FadeTitle {
	Log("PCLauncher - FadeTitle set by user, waiting for """ . FadeTitle . """")
	WinWait(FadeTitle)
	WinWaitActive(FadeTitle)
} Else If AppWaitExe {
	Log("PCLauncher - FadeTitle not set by user, but AppWaitExe is. Waiting for AppWaitExe: " . AppWaitExe)
	AppWaitPID := Process("Wait", AppWaitExe, 15)
	If AppWaitPID = 0
		ScriptError("PCLauncher - There was an error getting the Process ID from your AppWaitExe for """ . dbName . """. Please try setting a FadeTitle instead.")
} Else If SteamIDExe {
	Log("PCLauncher - FadeTitle and AppWaitExe not set by user, but SteamIDExe was found. Waiting for SteamIDExe: " . SteamIDExe)
	SteamIDPID := Process("Wait", SteamIDExe, 15)
	If SteamIDPID = 0
		ScriptError("PCLauncher - There was an error getting the Process ID from your SteamIDExe for """ . dbName . """. Please try setting a FadeTitle instead.")
} Else If AppPID {
	Log("PCLauncher - FadeTitle and AppWaitExe not set by user, but an AppPID was found. Waiting for AppPID: " . AppPID)
	WinWait("ahk_pid " . AppPID)
	WinWaitActive("ahk_pid " . AppPID)
} Else
	Log("PCLauncher - FadeTitle and AppWaitExe not set by user and no AppPID found from an Application, PCLauncher has nothing to wait for",3)

Sleep, %FadeInExitSleep%	; PCLauncher setting for some stubborn games that keeps the fadeIn screen up a little longer
FadeInExit()

If AppWaitExe {
	SplitPath,AppWaitExe,AppWaitExe	; In case someone set this as a path accidentally, only want the filename from this key
	Log("PCLauncher - Waiting for AppWaitExe """ . AppWaitExe . """ to close.")
	Process("WaitClose", AppWaitExe)
} Else If FadeTitle {	; If fadeTitle is set and no appPID was created.
	Log("PCLauncher - Waiting for FadeTitle """ . FadeTitle . """ to close.")
	WinWaitClose(FadeTitle)
} Else If SteamIDExe {
	Log("PCLauncher - Waiting for SteamIDExe """ . SteamIDExe . """ to close.")
	Process("WaitClose", SteamIDExe)
} Else If AppPID {
	Log("PCLauncher - Waiting for AppPID """ . AppPID . """ to close.")
	Process("WaitClose", AppPID)
} Else
	ScriptError("Could not find a proper AppWaitExe`, FadeTitle`, or AppPID (from the launched Application). Try setting either an AppWaitExe or FadeTitle so the module has something to look for.")

If PostExit {
	Log("PCLauncher - PostExit set by user, running: " . PostExit)
	PostExitParameters := If (!PostExitParameters or PostExitParameters="ERROR" ) ? "" : PostExitParameters
	errLevel := Run(If postESkip ? PostExit : """" . PostExitName . """ " . PostExitParameters, PostExitPath)
	If errLevel
		ScriptError("There was a problem launching your PostExit application. Please check it is a valid executable.")
	Sleep, %PostExitSleep%
}

; If Application is a cd/dvd image, unmount it in DT
If appIsImage
	DaemonTools("unmount")

; Close steam if it was not open prior to launch, not really needed anymore because module knows how to launch if steam already running now
; If AppPID = 0
	; Run, Steam.exe -shutdown, %SteamPath%	; close steam

If hideCursor = true
	SystemCursor("On")

FadeOutExit()
ExitModule()


CheckSettings() {
	Global Application,ApplicationPath,ApplicationName,ApplicationExt
	Global PreLaunch,PreLaunchPath,PreLaunchName,PreLaunchExt
	Global PostLaunch,PostLaunchPath,PostLaunchName,PostLaunchExt
	Global PostExit,PostExitPath,PostExitName,PostExitExt
	Global moduleName,appIsImage,dtDriveLetter,SteamID,OriginGame,mode,preLSkip,postLSkip,postESkip,AppWaitExe,SteamIDExe,FadeTitle
	Global modulePath,fadeIn,k0,k1,k2,k3
	Log("CheckSettings - Started")

	; These checks allow you to run URL and Steam browser protocol commands. Without them ahk would error out that it can't find the file. This is different than setting a SteamID but either work
	If (SteamID) {
		mode = steam	; setting module to use steam mode
		Log("PCLauncher - SteamID is set, setting mode to: """ . mode . """")
	} Else If (SubStr(Application,1,3) = "ste") {
		mode = steambp	; setting module to use Steam Browser Protocol mode
		Log("PCLauncher - Application is a Steam Browser Protocol, setting mode to: """ . mode . """")
	} Else If (SubStr(Application,1,4) = "http") {
		mode = url	; setting module to use url mode
		Log("PCLauncher - Application is a URL, setting mode to: """ . mode . """")
	} Else If OriginGame {
		mode = origin	; setting module to use Origin mode
		Application := GetFullName(Application)	; convert a relative path defined in the PCLauncher ini to absolute
		SplitPath,Application,ApplicationName,ApplicationPath,ApplicationExt
		StringRight, ApplicationBackSlash, Application, 1
		Log("PCLauncher - Origin mode enabled. Will log in to Origin if required.")
	} Else If Application {
		mode = standard	; for standard launching
		Application := GetFullName(Application)	; convert a relative path defined in the PCLauncher ini to absolute
		SplitPath,Application,ApplicationName,ApplicationPath,ApplicationExt
		StringRight, ApplicationBackSlash, Application, 1
		Log("PCLauncher - Setting mode to: """ . mode . """")
	} Else	; error if no modes are used
		ScriptError("Please set an Application, SteamID, Steam Browser Protocol, or URL in " moduleName . ".ini for """ . dbName . """")

	If (SteamID && Application)	; do not allow 2 launching methods
		ScriptError("You are trying to use Steam and Application, you must choose one or the other.")

	If ((mode = "steam" || mode = "steambp") && !AppWaitExe && !FadeTitle) { ; && fadeIn = "true") {	; If AppWaitExe or FadeTitle are defined, that will take precedence over the automatic method using the SteamIDs.ini
		SteamIDFile := CheckFile(modulePath . "\SteamIDs.ini")
		If !SteamID
			SplitPath, Application,SteamID ; grab the 
		SteamIDExe := IniReadCheck(SteamIDFile, SteamID, "exe","",,1)
		If !SteamIDExe
			ScriptError("You are using launching a Steam game but no way for the module to know what window to wait for after launching. Please set a AppWaitExe, FadeTitle, or make sure your SteamID and the correct exe is defined in the SteamIDs.ini",10)
		Else
			Log("PCLauncher - Found an exe in the SteamIDs.ini for this game: """ . SteamIDExe . """")
	} Else If (mode = "url" && !AppWaitExe && !FadeTitle)
		ScriptError("You are using launching a URL but no way for the module to know what to window to wait for after launching. Please set a AppWaitExe or FadeTitle to your default application that gets launched when opening URLs.",10)
	
	preLSkip := If (SubStr(PreLaunch,1,4)="http" || SubStr(PreLaunch,1,3)="ste") ? 1:""
	If preLSkip
		Log("PCLauncher - PreLaunch is a URL or Steam Browser Protocol: " . PreLaunch)
	postLSkip := If (SubStr(PostLaunch,1,4)="http" || SubStr(PostLaunch,1,3)="ste") ? 1:""
	If postLSkip
		Log("PCLauncher - PostLaunch is a URL or Steam Browser Protocol: " . PostLaunch)
	postESkip := If (SubStr(PostExit,1,4)="http" || SubStr(PostExit,1,3)="ste") ? 1:""
	If postESkip
		Log("PCLauncher - PostExit is a URL or Steam Browser Protocol: " . PostExit)

	If (ApplicationBackSlash = "\")
		ScriptError("Please make sure your Application does not contain a backslash on the end:`n" . Application)
	If (appIsImage && !ApplicationPath)	; if user only defined an exe for Application with no path, assume it will be found on the root dir of the image when mounted
		ApplicationPath := dtDriveLetter . ":\"
	If (!ApplicationName && mode = "standard" && (mode != "steam" || mode != "steambp"))
		ScriptError("Missing filename on the end of your Application in " . moduleName . ".ini:`n" . Application)
	If (!ApplicationExt && mode = "standard" && (mode != "steam" || mode != "steambp"))
		ScriptError("Missing extension on your Application in " . moduleName . ".ini:`n" . Application)
	If (PreLaunch && !preLSkip) {
		PreLaunch := GetFullName(PreLaunch)
		SplitPath,PreLaunch,PreLaunchName,PreLaunchPath,PreLaunchExt
		StringRight, PreLaunchBackSlash, PreLaunch, 1
		CheckFile(PreLaunch,"Cannot find this PreLaunch application:`n" . PreLaunch)
		If (PreLaunchBackSlash = "\")
			ScriptError("Please make sure your PreLaunch does not contain a backslash on the end:`n" . PreLaunch)
	}
	If (PostLaunch && !postLSkip) {
		PostLaunch := GetFullName(PostLaunch)
		SplitPath,PostLaunch,PostLaunchName,PostLaunchPath,PostLaunchExt
		StringRight, PostLaunchBackSlash, PostLaunch, 1
		CheckFile(PostLaunch,"Cannot find this PostLaunch application:`n" . PostLaunch)
		If (PostLaunchBackSlash = "\")
			ScriptError("Please make sure your PostLaunch does not contain a backslash on the end:`n" . PostLaunch)
	}
	If (PostExit && !postESkip) {
		PostExit := GetFullName(PostExit)
		SplitPath,PostExit,PostExitName,PostExitPath,PostExitExt
		StringRight, PostExitBackSlash, PostExit, 1
		CheckFile(PostExit,"Cannot find this PostExit application:`n" . PostExit)
		If (PostExitBackSlash = "\")
			ScriptError("Please make sure your PostExit does not contain a backslash on the end:`n" . PostExit)
	}
	If mode = standard
		CheckFile(ApplicationPath . "\" . ApplicationName,"Cannot find this Application:`n" . ApplicationPath . "\" . ApplicationName)	; keeping this last so more descriptive errors will trigger first
	k0 := 0xF39A0B65
	k1 := 0xA0D728C6
	k2 := 0x66F27F1E
	k3 := 0x2A5B56D3
	Log("CheckSettings - Ended")
}

ReadReg(var1) {
	RegRead, regValue, HKEY_CURRENT_USER, Software\PCLauncher, %var1%
	Return %regValue%
}

Decrypt(T,key)                   ; Text, key-name
{
   Local p, i, L, u, v, k5, a, c

   StringLeft p, T, 8
   If p is not xdigit            ; if no IV: Error
   {
      ErrorLevel = 1
      Return
   }
   StringTrimLeft T, T, 8        ; remove IV from text (no separator)
   k5 = 0x%p%                    ; set new IV
   p = 0                         ; counter to be Encrypted
   i = 9                         ; pad-index, force restart
   L =                           ; processed text
   k0 := %key%0
   k1 := %key%1
   k2 := %key%2
   k3 := %key%3
   Loop % StrLen(T)
   {
      i++
      IfGreater i,8, {           ; all 9 pad values exhausted
         u := p
         v := k5                 ; IV
         p++                     ; increment counter
         TEA(u,v, k0,k1,k2,k3)
         Stream9(u,v)            ; 9 pads from Encrypted counter
         i = 0
      }
      StringMid c, T, A_Index, 1
      a := Asc(c)
      if a between 32 and 126
      {                          ; chars > 126 or < 31 unchanged
         a -= s%i%
         IfLess a, 32, SetEnv, a, % a+95
         c := Chr(a)
      }
      L = %L%%c%                 ; attach Encrypted character
   }
   Return L
}

TEA(ByRef y,ByRef z,k0,k1,k2,k3) ; (y,z) = 64-bit I/0 block
{                                ; (k0,k1,k2,k3) = 128-bit key
   IntFormat = %A_FormatInteger%
   SetFormat Integer, D          ; needed for decimal indices
   s := 0
   d := 0x9E3779B9
   Loop 32
   {
      k := "k" . s & 3           ; indexing the key
      y := 0xFFFFFFFF & (y + ((z << 4 ^ z >> 5) + z  ^  s + %k%))
      s := 0xFFFFFFFF & (s + d)  ; simulate 32 bit operations
      k := "k" . s >> 11 & 3
      z := 0xFFFFFFFF & (z + ((y << 4 ^ y >> 5) + y  ^  s + %k%))
   }
   SetFormat Integer, %IntFormat%
   y += 0
   z += 0                        ; Convert to original ineger format
}

Stream9(x,y)                     ; Convert 2 32-bit words to 9 pad values
{                                ; 0 <= s0, s1, ... s8 <= 94
   Local z                       ; makes all s%i% global
   s0 := Floor(x*0.000000022118911147) ; 95/2**32
   Loop 8
   {
      z := (y << 25) + (x >> 7) & 0xFFFFFFFF
      y := (x << 25) + (y >> 7) & 0xFFFFFFFF
      x  = %z%
      s%A_Index% := Floor(x*0.000000022118911147)
   }
}

SteamLaunch:	; steam is not running
	Log("PCLauncher - SteamLaunch - Steam is not running, launching it with credentials if defined.")
	sU := Decrypt(ReadReg("sU"),"k")
	sP := Decrypt(ReadReg("sP"),"k")
	If (!sU || !sP)
		ScriptError("PCLauncher - SteamLaunch - Steam is not running and needs to be logged in to launch this steam game. PCLauncher can do this, but you need to run ""EncryptPasswords"" application in your PCLauncher module folder first and set your login credentials.")
	Run(SteamExe . " " . (If sU && sP ? "-login " . sU . " " . sP:"") . " " . (If SteamID ? "-applaunch " . SteamID : Application) . " " . Parameters, steamPath,,steamPID)	; if SteamID is defined, launch that, otherwise use the application in the CLI (Usually this is for BPM mode)
	erLvl := WinWait("Steam",,15, "Steam Login")	; wait 15 seconds until the main steam window exists (not the login one)
	If erLvl	; if we simply timed out, some other problem happened
		ScriptError("PCLauncher - SteamLaunch - Timed out waiting 15 seconds for Steam's Login window. Please try again.")
	Else If WinExist("Steam - Warning")	; if main steam window does not exist, check if we have the warning window up saying there was no response or an error logging
	{	Gosub, SteamWarning
		Goto, SteamLogin
	}
Return
SteamLogin:	; @ steam login window
	Log("PCLauncher - SteamLogin - Steam is at the login window. Closing Steam to try logging in with your credentials if defined",3)
	Process("Close", steamExe)
	Process("WaitClose", steamExe)
	Sleep, 200	; give some extra time before launching again
	Goto, SteamLaunch
Return
SteamWarning:	; @ steam warning window (when login fails to connect)
	Log("PCLauncher - SteamWarning - Steam had a problem logging in, servers may be down or credentials may be wrong",3)
	steamWarning ++
	If steamWarning >= 3 
	{	Process("Close", steamExe)
		ScriptError("PCLauncher - SteamWarning - Could not log into steam after 3 tries, exiting back to your Front End.")
	}
	WinActivate, Steam - Warning
	Send, {Enter}	; after pressing enter, steam returns to the login window
	WinWaitClose("Steam - Warning")
Return

OriginLaunch:	; Origin is not running
	Log("PCLauncher - OriginLaunch - Origin is not running, launching it and then filling credentials if defined.")
	oU := Decrypt(ReadReg("oU"),"k")
	oP := Decrypt(ReadReg("oP"),"k")
	If (!oU || !oP)
		ScriptError("PCLauncher - OriginLaunch - Origin is not running and needs to be logged in to launch this Origin game. PCLauncher can do this, but you need to run ""EncryptPasswords"" application in your PCLauncher module folder first and set your login credentials.")
	Run(originExe . " " . Parameters, originPath,,OriginPID)
	erLvl := WinWait(originLoginWindow,,15)	; wait 15 seconds until the Origin Login window exists
	If erLvl	; if we simply timed out, some other problem happened
		ScriptError("PCLauncher - OriginLaunch - Timed out waiting 15 seconds for Origin's Login window. Please try again.")
	Else If WinExist(originLoginWindow)	; If Origin Login window exists
	{	;WinSet, Transparent, On, %originLoginWindow%
		WinGet, orHwnd, ID, %originLoginWindow%	; get the hwnd of the login window
		CheckFile(moduleExtensionsPath . "\BlockInput.exe", "Cannot find the module extension ""BlockInput.exe"". It is required to automate the Origin login process: " . moduleExtensionsPath . "\BlockInput.exe")
		Log("PCLauncher - OriginLaunch - Blocking all Input for 20 seconds while Origin is logged in for you.",4)
		Run("BlockInput.exe 20", moduleExtensionsPath)	; start the tool that blocks all input so user cannot interrupt the login process for 20 seconds
		Sleep, 3000	; have to wait some time for origin window to appear and be usable. Unforunately there is no programatic way to detect this so giving extra sleep time to be safe.
		SetKeyDelay,10,100	; The only delay that worked 100% of the time with pasting shifted keys into Origin's boxes. If there is ever a problem with credentials not correct, this may need to be adjusted
		Log("PCLauncher - OriginLaunch - Activating the Origin Login window.",4)
		WinActivate, %originLoginWindow%
		ControlSend,,{Tab 2}%oU%{Tab}%oP%{Enter}, %originLoginWindow%
		Log("PCLauncher - OriginLaunch - Finished logging into Origin.",4)
		Process("Close", "BlockInput.exe")	; end script that blocks all input
	} Else
		ScriptError("PCLauncher - OriginLaunch - Unhandled Origin Scenario. Please report this and post the log and what you did to make this happen.")
	erLvl := WinWaitClose("ahk_id " . orHwnd,,15)	; wait some time for Origin to login and window to disappear
	If erLvl	; if we simply timed out, some other problem happened
		ScriptError("PCLauncher - OriginLaunch - Timed out waiting 15 seconds for Origin's Login window to close. There was a problem logging in. Please try again or check your credentials.")
	SetTimer, OriginHide, 100	; Start a timer to destroy ads that may popup after logging in
Return
OriginLogin:	; @ Origin login window
	Log("PCLauncher - OriginLogin - Origin is at the login window. Trying to login with your credentials if defined")
	OriginPID := Process("Exist", originExe)
	If OriginPID {
		Process("Close", originExe)
		Process("WaitClose", originExe)
		Sleep, 200	; give some extra time before launching again
	}
	Goto, OriginLaunch
Return
OriginHide:
	If WinExist("Featured ahk_class QWidget")	; Close Origin ads that pop up
		WinClose("Featured ahk_class QWidget")
Return

CloseProcess:
	If ExitMethod ; fadeout will only take effect if an ExitMethod method was set, otherwise fade will occur and application will not close
		FadeOutStart()
	If ( ExitMethod = "Process Close AppWaitExe" && AppWaitExe) {
		Log("CloseProcess - ExitMethod is ""Process Close AppWaitExe""")
		Process("Close", AppWaitExe)
	} Else If ( ExitMethod = "WinClose AppWaitExe" && AppWaitExe) {
		Log("CloseProcess - ExitMethod is ""WinClose AppWaitExe""")
		AppWaitExePID := Process("Exist", AppWaitExe)
		WinClose("ahk_pid " . AppWaitExePID)
	} Else If ( ExitMethod = "Process Close Application" ) {
		Log("CloseProcess - ExitMethod is ""Process Close Application""")
		Process("Close", ApplicationName)
	} Else If ( ExitMethod = "WinClose Application" && FadeTitle ) {
		Log("CloseProcess - ExitMethod is ""WinClose Close Application""")
		WinClose(FadeTitle)
	} Else If ( ExitMethod = "Send Alt+F4" ) {
		Log("CloseProcess - ExitMethod is ""Send Alt+F4""")
		Send, !{F4}
	} Else {
		Log("CloseProcess - Default ExitMethod`, using ""WinClose""")
		WinClose(ApplicationName)
	}
Return
