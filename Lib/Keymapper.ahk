MCRC=890E075
MVersion=1.0.1

;##################################################################
;LoadPreferredControllers(JoyIDsPreferredControllers)
;##################################################################
;Creates a list for Joy IDs by creating a list of currently connected controllers and re-arranging that list to match the order presented in the Preferred Controller List.
;If both an Oem Name and a related custom joy name is found in the list, the oem name position is used
;JoyIDsPreferredControllers this is the list of preferred controllers
;it should be a list of controller names separated with |
;##################################################################

LoadPreferredControllers(JoyIDsPreferredControllers) {
	Global CustomJoyNameArray
	
	Log("Keymapper - JoyIDsPreferredControllers = " . JoyIDsPreferredControllers,5)
	; 16 is max number of joysticks windows and joyids allows
	Log("Keymapper - Creating a list of currently connected joysticks",5) 
	JoystickArray := GetJoystickArray()
	Loop, 16
	{
		ControllerName := JoystickArray[A_Index,1]
		MID := JoystickArray[A_Index,2]
		PID := JoystickArray[A_Index,3]
		GUID := JoystickArray[A_Index,4]
		If ControllerName
		{
			;CustomJoyNameArray is an Associative Array that associates a custom joy name to a controller name. See ahk_l documentation for objects.
			CustomJoyName := CustomJoyNameArray[ControllerName]
			;prepare for string position searching
			JoyIDsPreferredControllersModified := "|" . JoyIDsPreferredControllers . "|"
			;store last position this will be used for controllers not in PreferredControllerList
			LastPosition := StrLen(JoyIDsPreferredControllersModified)
			;position order 1 is for the normal controller name and position order 2 is for the custom name
			;normal controller name always takes higher priority over custom names since it is more specific
			PositionOrder_1 := InStr(JoyIDsPreferredControllersModified, "|" . ControllerName . "|")
			If CustomJoyName
				PositionOrder_2 := InStr(JoyIDsPreferredControllersModified, "|" . CustomJoyName . "|")
				
			If PositionOrder_1
				PositionOrder := PositionOrder_1
			Else If PositionOrder_2
				PositionOrder := PositionOrder_2
			Else
				PositionOrder := LastPosition
			;Position Order is the order found in the JoyIDsPreferredControllersModified list
			;it will be appended with a decimal value relative to order they were found in.
			;create sorting string also add the order found. If controllers are not found in preferred, plug-in order is used.
			;example format: 123.01|360 Controller
			Log("Keymapper - Preferred Order Sorting List -> " . PositionOrder . "." . SubStr("0" . A_Index, -1) . "|" . MID . "|" . PID . "|" . GUID,5)
			If !String2Sort
				String2Sort := PositionOrder . "." . SubStr("0" . A_Index, -1) . "|" . MID . "|" . PID . "|" . GUID
			Else
				String2Sort .= "`n" . PositionOrder . "." . SubStr("0" . A_Index, -1) . "|" . MID . "|" . PID . "|" . GUID
		}
	}
	Log("Keymapper - Sorting Currently Connected joysticks List to match the order of the Preferred Controller List")  
	;sort numerically
	Sort, String2Sort, N
	Log("Keymapper - Assigning the New Joystick IDs according to the preferred list for the active controllers")
	;parse the string
	Loop, Parse, String2Sort, `n
	{
		StringSplit, JoyIDsSortArray, A_LoopField, |
		MID := JoyIDsSortArray2
		PID := JoyIDsSortArray3
		GUID := JoyIDsSortArray4
		ChangeJoystickID(Mid,Pid,GUID,A_Index)
	}
}

;##################################################################
;RunKeyMapper(keymapperLoad_Or_Unload,keymapper)
;##################################################################
;keymapperLoad_Or_Unload  can be = "load" or "unload" or "menu"
; menu is for loading the HyperLaunch menu profile
; keymapper can be = "xpadder", "joytokey" or "joy2key"
; this function returns FEProfile
;##################################################################

RunKeymapper(keymapperLoad_Or_Unload,Keymapper)
{
	Global blankProfile,defaultProfile,FEProfile,romProfile,emuProfile,xPadderSystemProfile,systemProfile,HyperLaunchProfile
	Global CustomJoyNameArray
	Global keymapperFullPath 
	Global KeymapperHyperLaunchProfileEnabled, keymapperEnabled
	;Global keymapperLoad_Or_Unload
	
	If ((KeymapperHyperLaunchProfileEnabled = "false") OR (keymapperEnabled = "false")) AND (keymapperLoad_Or_Unload = "menu")
		Return

	SplitPath, keymapperFullPath, keymapperExe, keymapperPath, keymapperExt ; splitting pathname into variables
	;define profiles to load and run keymappers
	If (keymapper = "xpadder")
	{
		;close xpadder to refresh controllers
		Log("Keymapper - Closing xpadder to refresh controllers seen by xpadder",5)
		Run, %keymapperExe% /C, %keymapperPath%
		Log("Keymapper - Creating an array of connected controllers and profiles to arrange according to the order found in " . keymapperPath . "\xpadder.ini",5)
		XpadderArray := []
		;get controller name mid and pid
		JoystickArray := GetJoystickArray()
		Loop, 16
		{
			ControllerName := JoystickArray[A_Index,1]
			Mid := JoystickArray[A_Index,2]
			Pid := JoystickArray[A_Index,3]
			;check to see if controller name has been previously been found
			String := XpadderArray[ControllerName]
			StringSplit,SplitArray,String,|
			If SplitArray0
			{
				;if controller has been found add new profile to associated profiles
				;get profile is a custom function
				;help here
				If (keymapperLoad_Or_Unload = "load")
					Profile2Load := GetProfile(ControllerName, keymapper, romProfile . "|" . emuProfile . "|" . xPadderSystemProfile . "|" . defaultProfile . "|" . blankProfile, A_Index, keymapperLoad_Or_Unload)
				Else If (keymapperLoad_Or_Unload = "unload")
					Profile2Load := GetProfile(ControllerName, keymapper, FEProfile . "|" . blankProfile, A_Index, keymapperLoad_Or_Unload)
				Else If (keymapperLoad_Or_Unload = "menu")
					Profile2Load := GetProfile(ControllerName, keymapper, HyperLaunchProfile . "|" . blankProfile, A_Index, keymapperLoad_Or_Unload)
				;store ID numbers that are compatible xpadder in SplitArray1
				;append the newly found profile2load with the previously found profiles associated with this controller separated with a ? to be later replaced with " "
				XpadderArray[ControllerName] := SplitArray1 . "|" . SplitArray2 . "?" . Profile2Load
			}
			Else If ControllerName
			{
				;if controller has Not been found create new entry in XpadderArray (associative)
				If (keymapperLoad_Or_Unload = "load")
					Profile2Load := GetProfile(ControllerName, keymapper, romProfile . "|" . emuProfile . "|" . xPadderSystemProfile . "|" . defaultProfile . "|" . blankProfile, A_Index, keymapperLoad_Or_Unload)
				Else If (keymapperLoad_Or_Unload = "unload")
					Profile2Load := GetProfile(ControllerName, keymapper, FEProfile . "|" . blankProfile, A_Index, keymapperLoad_Or_Unload)
				Else If (keymapperLoad_Or_Unload = "menu")
					Profile2Load := GetProfile(ControllerName, keymapper, HyperLaunchProfile . "|" . blankProfile, A_Index, keymapperLoad_Or_Unload)
				
				;convert hexadecimal Mid and Pid values into a format compatible with xpadder's xpadder.ini
				ID1:=SubStr(Mid,1,2),ID2:=SubStr(Mid,3,2),ID3:=SubStr(Pid,1,2),ID4:=SubStr(Pid,3,2)
				Loop,4
				{
					ID%A_Index% := "0x" . ID%A_Index%
					ID%A_Index%+=0
				}
				ControllerID = %ID1%`,%ID2%`,%ID3%`,%ID4%
				Value := ControllerID . "|" . Profile2Load
				XpadderArray.Insert(ControllerName,Value)
			}
		}
		Process, WaitClose, %keymapperExe% ;wait for xpadder to finish writing its values to xpadder.ini before reading and editing it
		Log("Keymapper - Reading the order in " . keymapperPath . "\xpadder.ini and arranging profiles found to match that order",5)
		Loop
		{
			;get profiles in order as appears in xpadder.ini
			LoopIndex := A_Index ;record number in case we need to add a new key to xpadder.
			IniRead, IniControllerName, %keymapperPath%\Xpadder.ini, Controllers, Controller%LoopIndex%Name
			If (IniControllerName = "ERROR") ;this means there are no more controllers to be found in the ini
				Break
			;look to see if the controller found in the ini is already in our array
			XpadderArrayValue := XpadderArray[IniControllerName]
			If XpadderArrayValue
			{
				StringSplit,SplitArray,XpadderArrayValue,|
				;make sure controller is not hidden. if it is one xpadder does not recognize controller and the profile loading is messed up.
				IniWrite, 0, %keymapperPath%\Xpadder.ini, Controllers, Controller%LoopIndex%Hidden
				; this is for later use
				If !IniControllersFound
					IniControllersFound := IniControllerName
				Else
					IniControllersFound .= "," . IniControllerName
				;start creating the string of profiles to send to xpadder
				If !ProfilesInXpadderOrder
					ProfilesInXpadderOrder := SplitArray2
				Else
					ProfilesInXpadderOrder.= """ """ . SplitArray2
				;because we looped and looked up profiles in the array in the order of the ini, they will be in order when sent to xpadder
			}
		}
		For key, XpadderArrayValue in XpadderArray
		{
			If key not in %IniControllersFound%
			{
				Log("Keymapper - Could not find " . key . " in xpadder.ini. Writing the new controller to xpadder.ini",5)
				StringSplit,SplitArray,XpadderArrayValue,|
				;write new key values for the controllers not found in xpadder.ini to xpadder so it sees them when it restarts.
				IniWrite, %key%, %keymapperPath%\Xpadder.ini, Controllers, Controller%LoopIndex%Name
				IniWrite, %SplitArray1%, %keymapperPath%\Xpadder.ini, Controllers, Controller%LoopIndex%ID
				IniWrite, 0, %keymapperPath%\Xpadder.ini, Controllers, Controller%LoopIndex%Hidden
				
				;look for matching xpaddercontroller file in xpadder.exe root directory
				CustomJoyName := CustomJoyNameArray[key]
				;profiles can be named after CustomJoyName or controller name. Oem Name takes priority.
				If (FileExist(keymapperPath . key . ".xpaddercontroller")) {
					Log("Keymapper - Loading " . keymapperPath . "\" . key  ".xpaddercontroller layout for the new controller",5)
					IniWrite, %key%.xpaddercontroller, %keymapperPath%\Xpadder.ini, Controllers, Controller%LoopIndex%File
				}
				Else If (CustomJoyName AND FileExist(keymapperPath . CustomJoyName . ".xpaddercontroller")) {
					Log("Keymapper - Loading " . keymapperPath . "\" . CustomJoyName  ".xpaddercontroller layout for the new controller",5)
					IniWrite, %CustomJoyName%.xpaddercontroller, %keymapperPath%\Xpadder.ini, Controllers, Controller%LoopIndex%File
				}
				Else
				{
					;this means a xpaddercontroller profile has not been found
					ScriptError("Please create a xpaddercontroller profile named either " . key . " or " . CustomJoyName . ". It also needs to be in the same folder as xpadder.exe")
				}
				Loop, 4
					IniWrite,%A_Space%, %keymapperPath%\Xpadder.ini, Controllers, Controller%LoopIndex%Recent%A_Index%
				LoopIndex++
				If !ProfilesInXpadderOrder
					ProfilesInXpadderOrder := SplitArray2
				Else
					ProfilesInXpadderOrder .= """ """ . SplitArray2
			}
		}
		StringReplace, ProfilesInXpadderOrder, ProfilesInXpadderOrder, ?, " ", All
		If ProfilesInXpadderOrder
		{
			Log("Keymapper - Run`," . keymapperExe . " """ . ProfilesInXpadderOrder . """ /M`, " . keymapperPath . "`, Hide")
			Run, %keymapperExe% "%ProfilesInXpadderOrder%" /M, %keymapperPath%, Hide
		}
	}
	Else If (keymapper="joy2key") OR (keymapper = "joytokey")
	{
		JoystickArray := GetJoystickArray()
		Loop, 16
		{
			ControllerName := JoystickArray[A_Index,1]
			If ControllerName
			{
				If (keymapperLoad_Or_Unload = "load")
					Profile2Load := GetProfile(ControllerName, keymapper, romProfile . "|" . emuProfile . "|" . systemProfile . "|" . defaultProfile . "|" . blankProfile, A_Index, keymapperLoad_Or_Unload)
				Else If (keymapperLoad_Or_Unload = "unload")
					Profile2Load := GetProfile(ControllerName, keymapper, FEProfile . "|" . blankProfile, A_Index, keymapperLoad_Or_Unload)
				Else If (keymapperLoad_Or_Unload = "menu")
					Profile2Load := GetProfile(ControllerName, keymapper, HyperLaunchProfile . "|" . blankProfile, A_Index, keymapperLoad_Or_Unload)
				
				If !Profiles
					Profiles := Profile2Load
				Else
					Profiles .= "|" . Profile2Load
			}
		}
		StringSplit,ProfilesArray,Profiles,|
	
		; don't really understand this part, it's a carryover from the last HyperLaunch
		; I tested it and it works fine
		IniRead, exitMeansMinimize, %keymapperPath%\JoyToKey.ini, LastStatus, ExitMeansMinimize
		If ( exitMeansMinimize = "ERROR" )
			ScriptError("You are using KeyMapper support but are not up-to-date with JoyToKey or cannot find JoyToKey.ini in " . keymapperPath . "`nPlease make sure you are running JoyToKey v5.1.0 or later",10)
		Else If ( exitMeansMinimize = 1 ) {
			Process, Close, %keymapperExe%
			Process, WaitClose, %keymapperExe%
			IniWrite, 0, %keymapperPath%\JoyToKey.ini, LastStatus, ExitMeansMinimize
		}
		DetectHiddenWindows, On
		WinClose, JoyToKey ahk_class TMainForm
		;creating new cfg file by splicing together the user's cfg files
		;this file is to be used by HL only and is what joy2key will recieve in the end
		;setting the name and path of the dynamic cfg file
		j2kTemp = %keymapperProfilePath%j2kTEMP.cfg
		;deleting any previous instances of the file, since we will create new one
		FileDelete, %j2kTemp%
		;loop the number of profiles found
		Log("Keymapper - Creating new temporary Frankenstein profile from profiles loaded for joy2key",5)
		Loop, %ProfilesArray0%
		{
			; defining the "cfg(ini)" section and end section. 
			Section := "[Joystick " . A_Index . "]", EndSection := "[Joystick " . A_Index+1 . "]"
			;SectionFound is set to false since we haven't found the next section yet
			SectionFound := "false", profile := ProfilesArray%A_Index%
			Log("Keymapper - For Player " . A_Index . "`, Getting [Joystick " . A_Index .  "] section from the profile : " . profile,5)
			; j2k's cfg's are formatted like an ini file
			; I use the FileRead since it is more robust and faster than multiple IniRead's and Writes
			; I chose FileRead since it uses less reads and writes
			FileRead, ProfileContents, %profile%
			; fileread was done instead of loop,read since I need to check to see if the section I'm 
			; looking for exists.
			If ProfileContents contains %Section%
			{
				; this is splitting it by line so I can look for Section and End Section
				; reason InStr() was not used is because there is not an endsection if the
				; current section is the last one created by the user
				StringSplit, ContentLines, ProfileContents,`n
				;ContentLines0 is where ahk stores the lenght of the array of the StringSplit
				Loop, %ContentLines0%
				{
					; store a line in a var for further evaluation
					LoopLine := ContentLines%A_Index%
					; end loop if the last section is found
					If LoopLine contains %EndSection%
						Break
					; we will copy all the lines above [joystick 1], which would be the required [General] section
					If (Section = "[Joystick 1]")
						tempProfileContents .= LoopLine . "`n"
					Else 
					{
					; we don't need to copy the general section for joystick 2 through 8 so we
					; separate their reading and storing operation
						If LoopLine contains %Section% 
						{
							tempProfileContents .= LoopLine . "`n"
							; we now know to start copying everyline after the section since SectionFound = true
							SectionFound = true
						}
						Else If (SectionFound = "true")
							tempProfileContents .= LoopLine . "`n"
					}
				}
			}
			Else 
			{
				Log("Keymapper - Profile: " . profile . " is missing this section" . section . "substituting it with a blank one for now.",5)
				; if the section I'm looking for doesn't exist,
				; write a blank section and log error
				tempProfileContents .= Section . "`nAxis1n=0`nAxis1p=0`nAxis2n=0`nAxis2p=0`nAxis3n=0`nAxis3p=0`nAxis4n=0`nAxis4p=0`nAxis5n=0`nAxis5p=0`nAxis6n=0`nAxis6p=0`nAxis7n=0`nAxis7p=0`nAxis8n=0`nAxis8p=0`nPOV1-1=0`nPOV1-2=0`nPOV1-3=0`nPOV1-4=0`nPOV1-5=0`nPOV1-6=0`nPOV1-7=0`nPOV1-8=0`nPOV2-1=0`nPOV2-2=0`nPOV2-3=0`nPOV2-4=0`nPOV2-5=0`nPOV2-6=0`nPOV2-7=0`nPOV2-8=0`nUp-Right=0`nUp- Left=0`nDn- Left=0`nDn-Right=0`nUp-Right2=0`nUp- Left2=0`nDn- Left2=0`nDn-Right2=0`nButton01=0`nButton02=0`nButton03=0`nButton04=0`nButton05=0`nButton06=0`nButton07=0`nButton08=0`nButton09=0`nButton10=0`nButton11=0`nButton12=0`nButton13=0`nButton14=0`nButton15=0`nButton16=0`nButton17=0`nButton18=0`nButton19=0`nButton20=0`nButton21=0`nButton22=0`nButton23=0`nButton24=0`nButton25=0`nButton26=0`nButton27=0`nButton28=0`nButton29=0`nButton30=0`nButton31=0`nButton32=0`n"
			}
		}
		; write our newly created cfg to a file
		Log("Keymapper - Finished creating the temp profile: " . j2kTemp,5)
		FileAppend, %tempProfileContents%, %j2kTemp%
		; change the number of joysticks j2k is looking for to match the number we found
		IniWrite, %numberOfProfiles%, %j2kTemp%, General, NumberOfJoysticks
		Process, WaitClose, %keymapperExe%,2
		If ErrorLevel
			Process, Close, %keymapperExe%
		; HQ may turn of joytokey from starting minimized, let's set it just in case
		IniRead, startMinimized, %keymapperPath%\JoyToKey.ini, LastStatus, StartIconified
		If startMinimized != 1
			IniWrite, 1, %keymapperPath%\JoyToKey.ini, LastStatus, StartIconified
		; finally we start the keymapper with our newly created cfg profile
		Log("Keymapper - Run`, " . keymapperExe .  " """ . j2kTemp . """`, " . keymapperPath)
		Run, %keymapperExe% "%j2kTemp%", %keymapperPath%
	}	
Return %FEProfile%
}

;#########################
; GetProfile(ControllerName,keymapper, ProfilePrefixes [,PlayerNumber], keymapperLoad_Or_Unload)
; Only use FEProfile if you want to ignore rom and system profile
; PlayerNumber is there for possible use by other functions including this one
; keymapperLoad_Or_Unload can be load, unload, or menu. for error purposes
; ControllerName must not be empty (no error checks in function)
; keymapper needs to be a valid keymapper (no error checks in function)
; ProfilePrefixes separate prefixes with a "|"
; this function is menat only for use by the Load keymapper function.
;#########################

GetProfile(ControllerName, keymapper, ProfilePrefixes, ByRef PlayerNumber = 1, keymapperLoad_Or_Unload = "load") 
{
	Global CustomJoyNameArray, blankProfile, systemName, dbName, emuName, keymapperFrontEndProfileName, keymapperProfilePath

	;static associative array that is holds what extension is for what keymapper.
	;keymapper: "keymapper profile extension". Adding name variations to this array should not slow down the script which means name variations can be accounted for.
	Static ExtensionList := {xpadder: ".xpadderprofile",joy2key: ".cfg",joytokey: ".cfg"}
	keymapperExtension := ExtensionList[keymapper]
	PlayerNumber := (If PlayerNumber = "" ? (1) : (PlayerNumber)) ; perform check for blank PlayerNumber
	
	If (keymapperExtension = ".xpadderprofile")
		PlayerIndicator := "\p" . PlayerNumber
	Else
		PlayerIndicator := "" ;joy2key does not need a player number since the numbers are stored in the cfg

	CustomJoyName := CustomJoyNameArray[ControllerName]
	;If CustomJoyName Exists look for it. If not, don't look for an empty [].
	If CustomJoyName 
	{
		LoopNumber := 3
		PossibleJoyNames1 := "\" . ControllerName
		PossibleJoyNames2 := "\" . CustomJoyName
		PossibleJoyNames3 := ""
	} Else {
		LoopNumber := 2
		PossibleJoyNames1 := "\" . ControllerName
		PossibleJoyNames2 := ""
	}

	;start looking for profiles
	;profile prefixes for loading should look like %romProfile%|%emuProfile%|%systemProfile%|%defaultProfile%|%blankProfile%
	;profile prefixes for unloading should look like %FEProfile%|%blankProfile%
	Profile2Load := ""
	Loop,Parse,ProfilePrefixes,|
	{
		ProfileName := A_LoopField
		Loop, %LoopNumber%
		{
			JoyName := PossibleJoyNames%A_Index%
			If (ProfileName = blankProfile) ;blankProfile is global variable. This check is here because blank profiles don't need player number.
			{
				Profile := ProfileName . keymapperExtension
				Log("Keymapper - Searching -> " . Profile,5)
				If FileExist(Profile)
				{
					Profile2Load := Profile
					Log("Keymapper - Loading Profile -> " . Profile2Load)
					Return %Profile2Load%
				}
				Break
			}
			Else
			{
				Profile := ProfileName . JoyName . PlayerIndicator . keymapperExtension
				Log("Keymapper - Searching -> " . Profile,5)
				If FileExist(Profile)
				{
					Profile2Load := Profile
					PlayerNumber++
					Log("Keymapper - Loading Profile -> " . Profile2Load)
					Return %Profile2Load%
				}
			}
		}
	}
	If !Profile2Load {
		If (keymapperLoad_Or_Unload = "load")
			Log("Keymapper support is enabled for """ . keymapper . """`, but could not find a """ . dbName . """`, """ . emuName . """`, """ . systemName . """`, default`, a """ . ControllerName . """ player " . PlayerNumber . " profile or a blank profile in """ . keymapperProfilePath . """ for controller """ . ControllerName . """",2)
		Else If (keymapperLoad_Or_Unload = "unload")
			Log("Keymapper support is enabled for """ . keymapper . """`, but could not find a " . keymapperFrontEndProfileName . " profile or a blank profile in " . keymapperProfilePath . " for controller " . ControllerName,2)
		Else If (keymapperLoad_Or_Unload = "menu")
			Log("Keymapper support is enabled for """ . keymapper . """`, but could not find a HyperLaunch profile or a blank profile in " . keymapperProfilePath . " for controller " . ControllerName,2)
	}
}

;#########################
; GetJoystickArray()
; returns a 4 column by 17 row table.
; the row number is the same as the player number or id #. this is equivalent to port number + 1 
; so if your joystick is in port 0 or has an id of 1 it's name will be in JoyStickArray[1,1]
; column 1 contains the oem name, column 2 contains the mid and column 3 contains the pid, column 4 contains the guid
; Guid is a Global Universal ID that is assigned by the OS. It is 128 bits and randomly generated, It is the devices unique identifier while it is plugged in.
; row 0 column 1 contains the a pipedelimited list of the ids with connected controllers. (ex: 1|2|4) this means there is a joystick for id 1, 2 and 4.
; row 0 columns 2, 3, and 4 are empty. Future info may be added here.
;#########################

GetJoystickArray() {
	Global HLObject
	
	Result := COM_Invoke(HLObject, "getConnectedJoysticks")
	
	log("Keymapper - Joysticks Detected: " . Result,5)
	
	StringSplit,joyDet,Result
	joyArray := Object()
	Loop, 4
	{
		joyArray[0,A_Index] := ""
	}
	Loop, %joyDet0%
	{
		CurrentController := A_Index
		Mid := "", Pid := "", joy_name := "" ; erase values
		Connected := joyDet%CurrentController%
		If (Connected = "1")
		{
			If joyArray[0,1]
				joyArray[0,1] := joyArray[0,1] . "|" . CurrentController 
			Else
				joyArray[0,1] := CurrentController
			VarSetCapacity(joybank,1024,0)
			i:=0
			port := CurrentController - 1
			Loop, 1024
			{
				;get driver information
				err :=dllcall("winmm.dll\joyGetDevCapsA",Int,port,UInt,&joybank,UInt,i)
				i++
				; a successful dllcall returns a 0
				If (err = 0)
				{
					;converting decimal values to hex since windows uses the hex value more often
					offset = 0
					Loop, 2 
					{
						SetFormat, IntegerFast, hex
						ret := NumGet(&joybank,offset,"UShort")
						ret .= ""
						SetFormat, IntegerFast, d
						; remove the 0x we don't need it and padding it with 0's to have a width of four
						; advice: leave these two lines out if using this function in other scripts
						StringTrimLeft,ret,ret,2
						ID%A_Index% := SubStr("0000" . ret,-3)
						offset := offset+2
					}
					Mid := ID1, Pid := ID2
				}
			}
			If !Mid OR !Pid
				joy_name := ""
			Else
			{
				regFolder := "VID_" . Mid . "&PID_" . Pid
				RegRead, joy_name, HKEY_CURRENT_USER, System\CurrentControlSet\Control\MediaProperties\PrivateProperties\Joystick\OEM\%regFolder%, OEMName
				If ErrorLevel
					RegRead, joy_name, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Control\MediaProperties\PrivateProperties\Joystick\OEM\%regFolder%, OEMName
			}
		}
		joyArray[A_Index,1] := joy_name
		joyArray[A_Index,2] := Mid
		joyArray[A_Index,3] := Pid
		joyArray[A_Index,4] := GetJoystickGUID(Mid,Pid,A_Index)
	}
Return %joyArray%
}

;#########################
; GetJoystickGUID(Mid,Pid,JoystickID)
; This function is used internally by the GetJoystickArray() function
; It returns the matching guid for a joystick device. Empty if error occurred.
; Mid = JoystickArray[JoystickID,2]
; PID = JoystickArray[JoystickID,3]
; JoystickID = 1 through 16
;#########################

GetJoystickGUID(Mid,Pid,JoystickID)
{
If !Mid OR !PID OR !JoystickID
	Return
	
If JoystickID not between 1 and 16
	Return

SetFormat, IntegerFast, hex
REG_JOY_ID := JoystickID - 1
REG_JOY_ID .= "000000"
StringReplace, REG_JOY_ID , REG_JOY_ID, x
SetFormat, IntegerFast, d

If A_OSVersion in WIN_2003,WIN_XP,WIN_2000,WIN_NT4,WIN_95,WIN_98,WIN_ME
	RootKey = HKEY_LOCAL_MACHINE
Else
	RootKey = HKEY_CURRENT_USER

Loop
{
	NumIndex := A_Index-1
	RegRead, regValue, %RootKey%, System\CurrentControlSet\Control\MediaProperties\PrivateProperties\DirectInput\VID_%Mid%&PID_%Pid%\Calibration\%NumIndex%, Joystick Id
	If ErrorLevel
		Break
	If (regValue = REG_JOY_ID)
	{
		RegRead, GUID, %RootKey%, System\CurrentControlSet\Control\MediaProperties\PrivateProperties\DirectInput\VID_%Mid%&PID_%Pid%\Calibration\%NumIndex%, GUID
		Break
	}
}
Return %GUID%
}

;#########################
; ChangeJoystickID(Mid,Pid,GUID,NewJoystickID)
; This is an awesome little function that changes the joystick id.
; It gives us more control over what devices are moved than JoyIDs.exe ever did.
; It returns 0 if successful, 1 if unsuccessful.
; Mid = JoystickArray[JoystickID,2]
; PID = JoystickArray[JoystickID,3]
; GUID = JoystickArray[JoystickID,4]
; NewJoystickID = 1 through 16, this is the new ID for the joystick with the matching MID,PID,GUID
; it has no way of checking to make sure it's not assigning the same id as an already active controller,
; so this check must be done outside the function.
;#########################

ChangeJoystickID(Mid,Pid,GUID,NewJoystickID)
{

If !Mid OR !PID OR !GUID OR !NewJoystickID
	Return 1

If NewJoystickID not between 1 and 16
	Return 1

SetFormat, IntegerFast, hex
NewJoystickID := NewJoystickID - 1
NewJoystickID .= "000000"
StringReplace, NewJoystickID , NewJoystickID, x
SetFormat, IntegerFast, d

If A_OSVersion in WIN_2003,WIN_XP,WIN_2000,WIN_NT4,WIN_95,WIN_98,WIN_ME
	RootKey = HKEY_LOCAL_MACHINE
Else
	RootKey = HKEY_CURRENT_USER

Loop
{
	NumIndex := A_Index-1
	
	RegRead, regValue, %RootKey%, System\CurrentControlSet\Control\MediaProperties\PrivateProperties\DirectInput\VID_%Mid%&PID_%Pid%\Calibration\%NumIndex%, GUID
	RegRead, jid, %RootKey%, System\CurrentControlSet\Control\MediaProperties\PrivateProperties\DirectInput\VID_%Mid%&PID_%Pid%\Calibration\%NumIndex%, Joystick Id
	If ErrorLevel
		Break
	If (regValue = GUID)
	{
		RegWrite, REG_BINARY, %RootKey%, System\CurrentControlSet\Control\MediaProperties\PrivateProperties\DirectInput\VID_%Mid%&PID_%Pid%\Calibration\%NumIndex%, Joystick Id, %NewJoystickID%
		Log("Keymapper - Swapping Joystick ID: " . jid . " to the New Joystick ID: " . NewJoystickID . ", for the Joystick VID_" . Mid . "&PID_" . Pid . "&GUID_" . GUID,5)
		Break
	}
}
Return %ErrorLevel%
}