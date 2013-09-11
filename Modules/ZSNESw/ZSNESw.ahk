MEmu = ZSNESw
MEmuV =  v1.51
MURL = http://www.zsnes.com/
MAuthor = djvj
MVersion = 2.0
MCRC = 90F089AF
iCRC = 3B0E8F48
MID = 635038268938832977
MSystem = "Super Nintendo Entertainment System"
;----------------------------------------------------------------------------
; Notes:
; Make sure you set quickexit to your Exit_Emulator_Key key while in ZSNES.
; If you want to use Esc as your quick exit key, open zsnesw.cfg with a text editor and find the lines below.
; Set KeyQuickExit to 1, as shown below. You can't set the quick exit key to escape while in the emulator, because that's the exit key to configuring keys. 
;
; Quit ZSNES / Load Menu / Reset Game / Panic Key
; KeyQuickExit=1
; KeyQuickLoad=0
; KeyQuickRst=0
; KeyResetAll=42
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
Stretch := IniReadCheck(settingsFile, "Settings", "Stretch","false",,1)
resX := IniReadCheck(settingsFile, "Settings", "resX","1024",,1)
resY := IniReadCheck(settingsFile, "Settings", "resY","768",,1)
DisplayRomInfo := IniReadCheck(settingsFile, "Settings", "DisplayRomInfo","false",,1)	; Display rom info on load along bottom of screen

SetKeyDelay, 50
zsnesFile := CheckFile(emuPath . "\zsnesw.cfg")
FileRead, zsnesCfg, %zsnesFile%

xLine := TF_Find(zsnesCfg,"","","CustomResX=") ; find location in zsnes cfg where it stores its custom X res
yLine := TF_Find(zsnesCfg,"","","CustomResY=") ; find location in zsnes cfg where it stores its custom Y res
modeLine := TF_Find(zsnesCfg,"","","cvidmode=") ; find location in zsnes cfg where it stores its custom vid mode
zsnesCfg := TF_ReplaceLine(zsnesCfg,xLine,xLine,"CustomResX=" . resX) ; update custom X res in zsnes cfg file
zsnesCfg := TF_ReplaceLine(zsnesCfg,yLine,yLine,"CustomResY=" . resY) ; update custom Yres in zsnes cfg file

If ( Fullscreen = "true" && Stretch = "true" ) ; sets fullscreen, stretch, and filter support
	vidMode = 39
Else If ( Fullscreen = "true" && Stretch != "true" ) ; sets fullscreen, correct aspect ratio, and filter support
	vidMode = 42
Else ; sets windowed mode with filter support
	vidMode = 38

zsnesCfg := TF_ReplaceLine(zsnesCfg,modeLine,modeLine,"cvidmode=" . vidMode) ; update custom vid mode in zsnes cfg file

; Setting DisplayRomInfo setting in cfg if it doesn't match what user wants above
currentDRI := (InStr(zsnesCfg, "DisplayInfo=1") ? ("true") : ("false"))
If ( DisplayRomInfo != "true" And currentDRI = "true" ) {
	StringReplace, zsnesCfg, zsnesCfg, DisplayInfo=1, DisplayInfo=0
} Else If ( DisplayRomInfo = "true" And currentDRI = "false" ) {
	StringReplace, zsnesCfg, zsnesCfg, DisplayInfo=0, DisplayInfo=1
}

SaveFile(zsnesCfg, zsnesFile) ; save changes to zsnesw.cfg

7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("ZSNES ahk_class ZSNES")
WinWaitActive("ZSNES ahk_class ZSNES")

FadeInExit()
Process("WaitClose",executable)
7zCleanUp()
FadeOutExit()
ExitModule()


SaveFile(text,file) {
	FileDelete, %file%
	FileAppend, %text%, %file%
}

CloseProcess:
	FadeOutStart()
	SetWinDelay, 50
	Send, {Alt Down}{F4 Down}{F4 Up}{Alt Up} ; No other closing method seems to work
Return


TF_Find(Text, StartLine = 1, EndLine = 0, SearchText = "", ReturnFirst = 1, ReturnText = 0)
	{ ; complete rewrite for 3.1
	 TF_GetData(OW, Text, FileName)
	 If (RegExMatch(Text, SearchText) < 1)
	 	Return "0" ; SearchText not in file or error, do nothing
     	 TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine) ; create MatchList
	 Loop, Parse, Text, `n
		{
		 If A_Index in %TF_MatchList%
		 	{
			 If (RegExMatch(A_LoopField, SearchText) > 0)
				{
				 If (ReturnText = 0)
					Lines .= A_Index "," ; line number
				 Else If (ReturnText = 1)
					Lines .= A_LoopField "`n" ; text of line 
				 Else If (ReturnText = 2)
					Lines .= A_Index ": " A_LoopField "`n" ; add line number
				 If (ReturnFirst = 1) ; only return first occurence
					Break
				}	
		 	}	
		}
	 If (Lines <> "")
		StringTrimRight, Lines, Lines, 1 ; trim trailing , or `n
	 Else
		Lines = 0 ; make sure we return 0
	 Return Lines
	}

TF_ReplaceLine(Text, StartLine = 1, Endline = 0, ReplaceText = "")
	{
	 TF_GetData(OW, Text, FileName)
	 TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine) ; create MatchList
	 Loop, Parse, Text, `n, `r
		{
		 If A_Index in %TF_MatchList%
			Output .= ReplaceText "`n" 
		 Else 
			Output .= A_LoopField "`n"
		}
	 Return TF_ReturnOutPut(OW, OutPut, FileName)
	}

TF_GetData(byref OW, byref Text, byref FileName) 
	{
	OW=0 ; default setting: asume it is a file and create file_copy
	IfNotInString, Text, `n ; it can be a file as the Text doesn't contact a newline character
		{
		 If (SubStr(Text,1,1)="!") ; first we check for "overwrite" 
			{
			 Text:=SubStr(Text,2)
			 OW=1 ; overwrite file (if it is a file)
			} 
		 IfNotExist, %Text% ; now we can check if the file exists, it doesn't so it is a var
		 {
		  If (OW=1) ; the variable started with a ! so we need to put it back because it is variable/text not a file
			Text:= "!" . Text
		  OW=2 ; no file, so it is a var or Text passed on directly to TF
		 }
		}
	Else ; there is a newline character in Text so it has to be a variable 
		{
		 OW=2
		}
    If (OW = 0) or (OW = 1) ; it is a file, so we have to read into var Text
		{
	 	 Text := (SubStr(Text,1,1)="!") ? (SubStr(Text,2)) : Text
		 FileName=%Text% ; Store FileName
		 FileRead, Text, %Text% ; Read file and return as var Text
		 If (ErrorLevel > 0)
			{
	 		 MsgBox, 48, TF Lib Error, % "Can not read " FileName
			 ExitApp
			}
		}
	Return
	}
	
TF_Count(String, Char)
	{
	StringReplace, String, String, %Char%,, UseErrorLevel
	Return ErrorLevel
	}

TF_ReturnOutPut(OW, Text, FileName, TrimTrailing = 1, CreateNewFile = 0) { ; HugoV
	If (OW = 0) ; input was file, file_copy will be created, if it already exist file_copy will be overwritten
		{
		 IfNotExist, % FileName ; check if file Exist, if not return otherwise it would create an empty file. Thanks for the idea Murp|e
		 	{
		 	 If (CreateNewFile = 1) ; CreateNewFile used for TF_SplitFileBy* and others
				{
				 OW = 1 
		 		 Goto CreateNewFile
				}
			 Else 
				Return
			}
		 If (TrimTrailing = 1)
			 StringTrimRight, Text, Text, 1 ; remove trailing `n
		SplitPath, FileName,, Dir, Ext, Name
		 If (Dir = "") ; if Dir is empty Text & script are in same directory
			Dir := A_ScriptDir
		 IfExist, % Dir "\backup" ; if there is a backup dir, copy original file there
			FileCopy, % Dir "\" Name "_copy." Ext, % Dir "\backup\" Name "_copy.bak", 1
		 FileDelete, % Dir "\" Name "_copy." Ext
		 FileAppend, %Text%, % Dir "\" Name "_copy." Ext
		 Return Errorlevel ? False : True
		}
	 CreateNewFile:	
	 If (OW = 1) ; input was file, will be overwritten by output 
		{
		 IfNotExist, % FileName ; check if file Exist, if not return otherwise it would create an empty file. Thanks for the idea Murp|e
		 	{
		 	If (CreateNewFile = 0) ; CreateNewFile used for TF_SplitFileBy* and others
		 		Return
			}
		 If (TrimTrailing = 1)
			 StringTrimRight, Text, Text, 1 ; remove trailing `n
		 SplitPath, FileName,, Dir, Ext, Name
		 If (Dir = "") ; if Dir is empty Text & script are in same directory
			Dir := A_ScriptDir
		 IfExist, % Dir "\backup" ; if there is a backup dir, copy original file there
			FileCopy, % Dir "\" Name "." Ext, % Dir "\backup\" Name ".bak", 1
		 FileDelete, % Dir "\" Name "." Ext
		 FileAppend, %Text%, % Dir "\" Name "." Ext
		 Return Errorlevel ? False : True
		}
	If (OW = 2) ; input was var, return variable 
		{
		 If (TrimTrailing = 1)
			StringTrimRight, Text, Text, 1 ; remove trailing `n
		 Return Text
		}
	}

_MakeMatchList(Text, Start = 1, End = 0)
	{
	ErrorList=
	 (join|
	 Error 01: Invalid StartLine parameter (non numerical character)
	 Error 02: Invalid EndLine parameter (non numerical character)
	 Error 03: Invalid StartLine parameter (only one + allowed)
	 )
	 StringSplit, ErrorMessage, ErrorList, |
	 Error = 0
	 
 	 TF_MatchList= ; just to be sure
	 If (Start = 0 or Start = "")
		Start = 1
		
	 ; some basic error checking
	 
	 ; error: only digits - and + allowed
	 If (RegExReplace(Start, "[ 0-9+\-\,]", "") <> "")
		 Error = 1
		 
	 If (RegExReplace(End, "[0-9 ]", "") <> "")
		 Error = 2

	 ; error: only one + allowed
	 If (TF_Count(Start,"+") > 1)
		 Error = 3
	 	
	 If (Error > 0 )
		{
		 MsgBox, 48, TF Lib Error, % ErrorMessage%Error%
		 ExitApp
		}
		
 	 ; Option #1
	 ; StartLine has + character indicating startline + incremental processing. 
	 ; EndLine will be used
	 ; Make TF_MatchList
 
	 IfInString, Start, `+ 
		{
		 If (End = 0 or End = "") ; determine number of lines
			End:= TF_Count(Text, "`n") + 1
		 StringSplit, Section, Start, `, ; we need to create a new "TF_MatchList" so we split by ,
		 Loop, %Section0%
			{
			 StringSplit, SectionLines, Section%A_Index%, `+
			 LoopSection:=End + 1 - SectionLines1
			 Counter=0
	         	 TF_MatchList .= SectionLines1 ","
			 Loop, %LoopSection%
				{
				 If (A_Index >= End) ; 
					Break
				 If (Counter = (SectionLines2-1)) ; counter is smaller than the incremental value so skip
					{
					 TF_MatchList .= (SectionLines1 + A_Index) ","
					 Counter=0
					}
				 Else
					Counter++
				}
			}
		 StringTrimRight, TF_MatchList, TF_MatchList, 1 ; remove trailing , 
		 Return TF_MatchList
		}

	 ; Option #2
	 ; StartLine has - character indicating from-to, COULD be multiple sections. 
	 ; EndLine will be ignored
	 ; Make TF_MatchList

	 IfInString, Start, `-
		{
		 StringSplit, Section, Start, `, ; we need to create a new "TF_MatchList" so we split by ,
		 Loop, %Section0%
			{
			 StringSplit, SectionLines, Section%A_Index%, `-
			 LoopSection:=SectionLines2 + 1 - SectionLines1
			 Loop, %LoopSection%
				{
				 TF_MatchList .= (SectionLines1 - 1 + A_Index) ","
				}
			}
		 StringTrimRight, TF_MatchList, TF_MatchList, 1 ; remove trailing ,
		 Return TF_MatchList
		}

	 ; Option #3
	 ; StartLine has comma indicating multiple lines. 
	 ; EndLine will be ignored
	 IfInString, Start, `,
		{
		 TF_MatchList:=Start
		 Return TF_MatchList
		}

	 ; Option #4
	 ; parameters passed on as StartLine, EndLine. 
	 ; Make TF_MatchList from StartLine to EndLine

	 If (End = 0 or End = "") ; determine number of lines
			End:= TF_Count(Text, "`n") + 1
	 LoopTimes:=End-Start
	 Loop, %LoopTimes%
		{	
		 TF_MatchList .= (Start - 1 + A_Index) ","
		}
	 TF_MatchList .= End ","
	 StringTrimRight, TF_MatchList, TF_MatchList, 1 ; remove trailing ,
	 Return TF_MatchList
	}
