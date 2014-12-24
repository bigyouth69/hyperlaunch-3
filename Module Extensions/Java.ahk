MCRC=86AEBE16
MVersion=1.0.0

;Finds and Returns the path to the Java executable installed on your system
;Will ScriptError If it cannot be found
FindJava(requiredJavaVersion="", enforceJavaVersion="false")
{
	; Detecting Windows version
	winVer := (InStr(ProgramFiles, "(x86)") ? ("64") : ("32")) ; check If windows is 32 or 64 bit

	If (requiredJavaVersion = "")
		requiredJavaVersion := winVer

	Log("FindJava - Trying to detect Java " . requiredJavaVersion . "bit, EnforceVersion=" . enforceJavaVersion, 4)

	If ( requiredJavaVersion = "64" && winVer = "32" )
		ScriptError("Unable to run a 64bit Java on a 32bit Windows. Install a 64bit version of Windows first or use an emulator version requiring a 32bit Java.")

	; Detecting Java version
	If (winVer = "64")
	{
		;Search 64bit first then 32bit
		Java64Exe := FindJavaReg("64",Java64VersionNr)
		Java32Exe := FindJavaReg("32",Java32VersionNr)

		;If nothing is found in the registry check the file system
		If (!Java64Exe)
			Java64Exe := FindJavaSys("64",Java64VersionNr)
		If (!Java32Exe)
			Java32Exe := FindJavaSys("32",Java32VersionNr)

		If ( Java32Exe && requiredJavaVersion = "32" && enforceJavaVersion = "true" )
		{
			;Java 32bit is required and was found
			javaVersion := "32"
			javaVersionNr := Java32VersionNr
			javaExe := Java32Exe
		}
		Else If ( Java64Exe )
		{
			;Java 64bit will be used
			javaVersion := "64"
			javaVersionNr := Java64VersionNr
			javaExe := Java64Exe
		}
		Else If ( Java32Exe )
		{
			;Java 32bit will be used
			javaVersion := "32"
			javaVersionNr := Java32VersionNr
			javaExe := Java32Exe
		}
	}
	Else
	{
		;Search 32bit only
		javaVersion := "32"
		javaExe := FindJavaReg("32",javaVersionNr)
	}

	If (!javaExe)
		ScriptError("Could not find any Java installation on this machine.")
	If ( requiredJavaVersion = "64" && javaVersion != "64" )
		ScriptError("Java 64bit is not installed.")
	If ( requiredJavaVersion != javaVersion && enforceJavaVersion = "true")
		ScriptError("Unable to properly run a 64bit application from a 32bit Java VM on a 64bit platform.")

	;MsgBox, Checking for: Java : %requiredJavaVersion%-Bit - Requires exact version : %enforceJavaVersion% `nWindows Version : %winVer%-Bit`nJava Install Found : %javaExe% - v%javaVersionNr% %javaVersion%-Bit
	Log("FindJava - Java Install found : " . javaExe . "version" . javaVersionNr . " " . javaVersion . "bit", 4)

	Return javaExe
}

;Searches the registry for Java installations. It will check both JRE and JDK
FindJavaReg(JavaVersion="32", ByRef JavaVersionNr="")
{
	Log("FindJavaReg - Trying to detect Java " . JavaVersion . " bit on registry ", 4)

	; Detecting Windows version
	winVer := (InStr(ProgramFiles, "(x86)") ? ("64") : ("32"))

	If (JavaVersion = "64")
	{
		JREKey := "SOFTWARE\JavaSoft\Java Runtime Environment"
		JDKKey := "SOFTWARE\JavaSoft\Java Development Kit"
	}
	Else
	{
		JREKey := (If winVer = "64" ? ("SOFTWARE\Wow6432Node\JavaSoft\Java Runtime Environment") : ("SOFTWARE\JavaSoft\Java Runtime Environment")) 
		JDKKey := (If winVer = "64" ? ("SOFTWARE\Wow6432Node\JavaSoft\Java Development Kit") : ("SOFTWARE\JavaSoft\Java Development Kit")) 
	}
	
	Log("FindJavaReg - JREKey is " . JREKey . " and JDKKey key is " . JDKKey, 4)

	;Detect JRE
	JREVersion := RegRead("HKEY_LOCAL_MACHINE", JREKey, "CurrentVersion", JavaVersion)
	JREDir := RegRead("HKEY_LOCAL_MACHINE", JREKey . "\" . JREVersion, "JavaHome", JavaVersion)
	
	JREExe := JREDir . "\bin\java.exe"
	JREExew := JREDir . "\bin\javaw.exe"
	If FileExist(JREExe) and FileExist(JREExew)
	{
		;JRE Found
		Log("FindJavaReg - JRE executable found at " . JREExe, 4)
		GetJavaVersion(JREExe,JavaBit,JavaVersionNr)
		Log("FindJavaReg - JRE executable is " . JavaBit . "bit", 4)
		If (JavaVersion = JavaBit)
		{
			Log("FindJavaReg - Returning " . JREExew, 4)
			Return JREExew
		}
		Else
		{
			Log("FindJavaReg - JRE executable doesn't match required version", 4)
		}
	}
	Else
	{
		;Detect JDK
		Log("FindJavaReg - JRE executable not found", 4)
		JDKVersion := RegRead("HKEY_LOCAL_MACHINE", JDKKey, "CurrentVersion", JavaVersion)
		JDKDir := RegRead("HKEY_LOCAL_MACHINE", JDKKey . "\" . JDKVersion, "JavaHome", JavaVersion)
		JDKExe := JDKDir . "\bin\java.exe"
		JDKExew := JDKDir . "\bin\javaw.exe"
		If FileExist(JDKExe) and FileExist(JDKExew)
		{
			;JDK Found
			Log("FindJavaReg - JDK executable found at " . JDKExe, 4)
			GetJavaVersion(JDKExe,JavaBit,JavaVersionNr)
			Log("FindJavaReg - JDK executable is " . JavaBit . "bit", 4)
			If (JavaVersion = JavaBit)
			{
				Log("FindJavaReg - Returning " . JDKExew, 4)
				Return JDKExew
			}
			Else
			{
				Log("FindJavaReg - JDK executable doesn't match required version", 4)
			}
		}
		Else
		{
			Log("FindJavaReg - JDK executable not found", 4)
		}
	}
	Log("FindJavaReg - Java installation not found on registry", 4)
}

; Searches the file system for Java installations. It will check both System32 and SysWOW64 folders for java executables
; Info about accessing the System folders under 64bit Windows when running AHK 32bit:
; http://www.autohotkey.com/board/topic/37492-how-run-msconfig-using-autohotkey/
; http://msdn.microsoft.com/en-us/library/aa384187.aspx
FindJavaSys(JavaVersion="32", ByRef JavaVersionNr="")
{
	Log("FindJavaSys - Trying to detect Java " . JavaVersion . " bit on system folders", 4)

	; Detecting Windows version
	winVer := (InStr(ProgramFiles, "(x86)") ? ("64") : ("32"))
	If (winVer = "64")
	{
		;We need to use Sysnative instead of System32 since AHK isn't a 64-bit process otherwise Windows would redirect it to SysWOW64
		;Can also use System32 instead of SysWOW64 as it will be automatically redirected to SysWOW64
		javaExe := (If JavaVersion = "64" ? (windir . "\Sysnative\java.exe") : (windir . "\SysWOW64\java.exe"))
		javawExe := (If JavaVersion = "64" ? (windir . "\Sysnative\javaw.exe") : (windir . "\SysWOW64\javaw.exe"))
		Log("FindJavaSys - Searching for " . javaExe, 4)
		If FileExist(javaExe) and FileExist(javawExe)
		{
			Log("FindJavaSys - Java executable found at " . javaExe, 4)
			GetJavaVersion(javaExe,JavaBit,JavaVersionNr)
			Log("FindJavaSys - Java executable is " . JavaBit . "bit", 4)
			If (JavaVersion = JavaBit)
			{
				Log("FindJavaSys - Returning " . javawExe, 4)
				Return javawExe
			}
			Else
			{
				Log("FindJavaSys - Java executable doesn't match required version", 4)
			}
		}
	}
	Else
	{
		javaExe := windir . "\System32\java.exe"
		javawExe := windir . "\System32\java.exe"
		Log("FindJavaSys - Searching for " . javaExe, 4)
		If FileExist(javaExe) and FileExist(javawExe)
		{
			Log("FindJavaSys - Java executable found at " . javaExe, 4)
			GetJavaVersion(javaExe,JavaBit,JavaVersionNr)
			Log("FindJavaSys - Java executable is " . JavaBit . "bit", 4)
			If (JavaVersion = JavaBit)
			{
				Log("FindJavaSys - Returning " . javawExe, 4)
				Return javawExe
			}
			Else
			{
				Log("FindJavaSys - Java executable doesn't match required version", 4)
			}
		}
	}
	Log("FindJavaSys - Java installation not found on system folders", 4)
}

; This will get the Java Version Number and 32/64bit info based on the stdout of the actual executable, after running java.exe -version
GetJavaVersion(Executable,ByRef JavaBit="",ByRef JavaVersionNr="")
{
	javastdout := StdoutToVar_CreateProcess(Executable . " -version")
	IfInString, javastdout, 64-Bit
		JavaBit := "64"
	Else
		JavaBit := "32"
	
	;Find the Version
	toFind := "(build "
	findLen := StrLen(toFind)
	StringGetPos, pos, javastdout, %toFind%
	If pos >= 0
	{
		StringGetPos, posf, javastdout, ),L1,pos
		StringMid, JavaVersionNr, javastdout, (pos+findLen) , (posf-(pos+findLen)+1)
	}
}
