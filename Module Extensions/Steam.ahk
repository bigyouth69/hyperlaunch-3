MCRC=9466907C
MVersion=1.0.1

; Steam settings can be found in the registry in a few places
; HKEY_CURRENT_USER\Software\Valve\Steam
; HKEY_LOCAL_MACHINE\SOFTWARE\Valve\Steam (32-bit OS)
; HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Valve\Steam (64-bit OS)

Steam(stmID="", stmProtocol="", params="") {
	Global stk,stk0,stk1,stk2,stk3,steamPath,steamExe,steamStartMode,steamIsOffline
	Log("Steam - Started")
	Log("Steam - Received SteamID: """ . stmID . """ | SteamProtocol: """ . stmProtocol . """ | Parameters: """ . params . """")
	If (!steamPath || !steamExe)
		GetSteamPath()
	steamPID := Process("Exist", steamExe)
	If steamStartMode = 1   ; Steam starts in Big Picture mode
	{	Log("Steam - Steam is set to start in Big Picture Mode.")
		IEPath := RegRead("HKLM", "Software\Microsoft\Windows\CurrentVersion\App Paths\IEXPLORE.EXE", "Path", "auto")
		StringTrimRight, IEPath, IEPath, 1	; trim the ; from the path
		IEExe := "iexplore.exe"
		CheckFile(IEPath . "\" . IEExe)
		Run(IEExe . A_Space . (If stmID ? "steam://rungameid/" . stmID : stmProtocol) . A_Space . params, IEPath)
	} Else {	; Steam starts in Standard Mode
		Log("Steam - Steam is set to start in Standard Mode.")
		curDHW := A_DetectHiddenWindows	; record current setting to be restored later
		DetectHiddenWindows, OFF	; this has to be off otherwise if steam is running it will falsely detect the Login window
		If (steamPID && (WinExist("Steam Login") != "0x0")) {	; if steam is running, but at the login window, we need to close it first, then rerun it with our login info
			Log("Steam - Steam is already running and at the login window.")
			Gosub, SteamLogin
		} Else If !steamPID {	; if steam is not running at all, start it with our login info
			Log("Steam - Steam is not running.")
			Gosub, SteamLaunch
		} Else {
			Log("Steam - Steam is already running, using Steam Browser Protocol to launch game.")
		}
		If (stmID != "")
			Run(steamExe . " -applaunch " . stmID . A_Space . params, steamPath)
		Else
			Run(stmProtocol . A_Space . params)
		DetectHiddenWindows, %curDHW%	; restoring previous setting
	}
	Log("Steam - Ended")
	Return

	SteamLaunch:	; steam is not running
		Log("SteamLaunch - Steam is not running, launching it with credentials if defined.")
		RegRead, sU, HKEY_CURRENT_USER, Software\PCLauncher, sU
		RegRead, sP, HKEY_CURRENT_USER, Software\PCLauncher, sP
		sU := Decrypt(sU,"stk")
		sP := Decrypt(sP,"stk")
		If (!sU || !sP)
			ScriptError("SteamLaunch - Steam is not running and needs to be logged in to launch this steam game. HyperLaunch can do this, but you need to run ""EncryptPasswords"" application in your PCLauncher module folder first and set your login credentials.")
		Run(SteamExe . " " . (If sU && sP ? "-login " . sU . " " . sP:"") . " " . (If stmID ? "-applaunch " . stmID : stmProtocol) . " " . params, steamPath,,steamPID,,,1)	; if stmID is defined, launch that, otherwise use the stmProtocol in the CLI (Usually this is for BPM mode)
		erLvl := WinWait("Steam",,15, "Steam Login")	; wait 15 seconds until the main steam window exists (not the login one)
		If erLvl	; if we simply timed out, some other problem happened
			ScriptError("SteamLaunch - Timed out waiting 15 seconds for Steam's Login window. Please try again.")
		Else If WinExist("Steam - Warning")	; if main steam window does not exist, check if we have the warning window up saying there was no response or an error logging
		{	Gosub, SteamWarning
			Goto, SteamLogin
		}
	Return
	SteamLogin:	; @ steam login window
		Log("SteamLogin - Steam is at the login window. Closing Steam to try logging in with your credentials if defined",3)
		Process("Close", steamExe)
		Process("WaitClose", steamExe)
		Sleep, 200	; give some extra time before launching again
		Goto, SteamLaunch
	Return
	SteamWarning:	; @ steam warning window (when login fails to connect)
		Log("SteamWarning - Steam had a problem logging in, servers may be down or credentials may be wrong",3)
		steamWarning ++
		If steamWarning >= 3 
		{	Process("Close", steamExe)
			ScriptError("SteamWarning - Could not log into steam after 3 tries, exiting back to your Front End.")
		}
		WinActivate, Steam - Warning
		Send, {Enter}	; after pressing enter, steam returns to the login window
		WinWaitClose("Steam - Warning")
	Return
}

; Can be called in the module to return the steamPath and steamExe vars in cases the module needs to use them in conditionals before calling Steam()
GetSteamPath() {
	Global steamPath,steamExe,steamStartMode,steamIsOffline
	Log("GetSteamPath - Started")
	; steamPath := RegRead("HKLM", "Software\Valve\Steam", "InstallPath", "auto")
	steamFullPath := RegRead("HKCU", "Software\Valve\Steam", "SteamExe", "auto")
	steamStartMode := RegRead("HKCU", "Software\Valve\Steam", "StartupMode", "auto")
	steamIsOffline := RegRead("HKCU", "Software\Valve\Steam", "Offline", "auto")		; currently not used
	Log("GetSteamPath - Steam is running in " . (If steamIsOffline = 1 ? "Offline" : "Online") . " Mode",4)
	steamFullPath := RegExReplace(steamFullPath, "\/", "\")	; steam stores / instead of \, this replaces all / for \
	SplitPath, steamFullPath, steamExe, steamPath
	CheckFile(steamPath . "\" . steamExe)
	Log("GetSteamPath - Ended - Steam install path: " . steamFullPath)
}