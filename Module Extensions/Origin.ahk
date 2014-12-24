MCRC=A4332C53
MVersion=1.0.0

Origin(aName, aPath, params="") {
	Global k,moduleExtensionsPath,AppPID
	Log("Origin - Started")
	Log("Origin - Checking Origin status.")
	originFullPath := RegRead("HKLM", "Software\origin", "ClientPath")
	CheckFile(originFullPath)
	SplitPath, originFullPath, originExe, originPath
	Log("Origin - Origin install path: " . originPath)
	originLoginWindow := "Origin ahk_class QWidget"
	OriginPID := Process("Exist", originExe)
	If (OriginPID && (WinExist(originLoginWindow) != "0x0")) {	; if Origin is running, but at the login window, we need to close it first, then rerun it with our login info
		WinGet, orResize, Style, %originLoginWindow%
		If (orResize & 0x10000)	; testing if the window has WS_MAXIMIZEBOX, the only difference between the Origin Main Window and the Origin Login Window
			Log("Origin - Origin is already running and logged in. Skipping login scripts and running game.")
		Else {
			Log("Origin - Origin is already running and at the login window.")
			Gosub, OriginLogin
		}
	} Else If !OriginPID {	; if Origin is not running at all, start it with our login info
		Log("Origin - Origin is not running.")
		Gosub, OriginLaunch
	} Else {
		Log("Origin - Origin is already running and looks to be logged in as no login window was detected.")
	}
	errLevel := Run(aName . " " . params, aPath,, AppPID)
	If errLevel
		ScriptError("There was a problem launching your Application. Please check it is a valid executable.")
	Log("Origin - Ended")
	Return

	OriginLaunch:	; Origin is not running
		Log("OriginLaunch - Origin is not running, launching it and then filling credentials if defined.")
		RegRead, oU, HKEY_CURRENT_USER, Software\PCLauncher, oU
		RegRead, oP, HKEY_CURRENT_USER, Software\PCLauncher, oP
		oU := Decrypt(oU,"k")
		oP := Decrypt(oP,"k")
		If (!oU || !oP)
			ScriptError("OriginLaunch - Origin is not running and needs to be logged in to launch this Origin game. HyperLaunch can do this, but you need to run ""EncryptPasswords"" application in your PCLauncher module folder first and set your login credentials.")
		Run(originExe . " " . params, originPath,,OriginPID)
		erLvl := WinWait(originLoginWindow,,15)	; wait 15 seconds until the Origin Login window exists
		If erLvl	; if we simply timed out, some other problem happened
			ScriptError("OriginLaunch - Timed out waiting 15 seconds for Origin's Login window. Please try again.")
		Else If WinExist(originLoginWindow)	; If Origin Login window exists
		{	;WinSet, Transparent, On, %originLoginWindow%
			WinGet, orHwnd, ID, %originLoginWindow%	; get the hwnd of the login window
			CheckFile(moduleExtensionsPath . "\BlockInput.exe", "Cannot find the module extension ""BlockInput.exe"". It is required to automate the Origin login process: " . moduleExtensionsPath . "\BlockInput.exe")
			Log("OriginLaunch - Blocking all Input for 20 seconds while Origin is logged in for you.",4)
			Run("BlockInput.exe 20", moduleExtensionsPath)	; start the tool that blocks all input so user cannot interrupt the login process for 20 seconds
			Sleep, 3000	; have to wait some time for origin window to appear and be usable. Unforunately there is no programatic way to detect this so giving extra sleep time to be safe.
			SetKeyDelay(10,100)	; The only delay that worked 100% of the time with pasting shifted keys into Origin's boxes. If there is ever a problem with credentials not correct, this may need to be adjusted
			Log("OriginLaunch - Activating the Origin Login window.",4)
			WinActivate, %originLoginWindow%
			ControlSend,,{Tab 2}%oU%{Tab}%oP%{Enter}, %originLoginWindow%
			Log("OriginLaunch - Finished logging into Origin.",4)
			Process("Close", "BlockInput.exe")	; end script that blocks all input
		} Else
			ScriptError("OriginLaunch - Unhandled Origin Scenario. Please report this and post the log and what you did to make this happen.")
		erLvl := WinWaitClose("ahk_id " . orHwnd,,15)	; wait some time for Origin to login and window to disappear
		If erLvl	; if we simply timed out, some other problem happened
			ScriptError("OriginLaunch - Timed out waiting 15 seconds for Origin's Login window to close. There was a problem logging in. Please try again or check your credentials.")
		SetTimer, OriginHide, 100	; Start a timer to destroy ads that may popup after logging in
	Return
	OriginLogin:	; @ Origin login window
		Log("OriginLogin - Origin is at the login window. Trying to login with your credentials if defined")
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
}