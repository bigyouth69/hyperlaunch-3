MCRC=5ECCCB5B
MVersion=1.0.0

Bin2Hex(ByRef h, ByRef b, n=0)      ; n bytes binary data -> stream of 2-digit hex
{                                   ; n = 0: all (SetCapacity can be larger than used!)
	Log("Bin2Hex - Started")
	format = %A_FormatInteger%       ; save original integer format
	SetFormat Integer, Hex           ; for converting bytes to hex

	m := VarSetCapacity(b)
	If (n < 1 or n > m)
		n := m
	Address := &b
	h =
	Loop %n%
	{
		x := *Address                 ; get byte in hex
		StringTrimLeft x, x, 2        ; remove 0x
		x = 0%x%                      ; pad left
		StringRight x, x, 2           ; 2 hex digits
		h = %h%%x%
		Address++
	}
	SetFormat Integer, %format%      ; restore original format
	Log("Bin2Hex - Ended")
}

Hex2Bin(ByRef b, h, n=0)            ; n hex digit-pairs -> binary data
{                                   ; n = 0: all. (Only ByRef can handle binaries)
	Log("Hex2Bin - Started")
	m := Ceil(StrLen(h)/2)
	If (n < 1 or n > m)
		n := m
	Granted := VarSetCapacity(b, n, 0)
	IfLess Granted,%n%, {
	ErrorLevel = Mem=%Granted%
	Return
	}
	Address := &b
	Loop %n%
	{
		StringLeft  x, h, 2
		StringTrimLeft h, h, 2
		x = 0x%x%
		DllCall("RtlFillMemory", "UInt", Address, "UInt", 1, "UChar", x)
		Address++
	}
	Log("Hex2Bin - Ended")
}

/* ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BinWrite ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
|  - Open binary file
|  - (Over)Write n bytes (n = 0: all)
|  - From offset (offset < 0: counted from end)
|  - Close file
|  (Binary)data -> file[offset + 0..n-1], rest of file unchanged
|  Return #bytes actually written
*/ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BinWrite(file, ByRef data, n=0, offset=0) {
	Log("BinWrite - Started - Writing " . n . " bytes from offset " . offset . " in " . file)
	; Open file for WRITE (0x40..), OPEN_ALWAYS (4): creates only if it does not exists
	h := DllCall("CreateFile","str",file,"Uint",0x40000000,"Uint",0,"UInt",0,"UInt",4,"Uint",0,"UInt",0)
	IfEqual h,-1, SetEnv, ErrorLevel, -1
	IfNotEqual ErrorLevel,0, {
		Log("BinWrite - Ended - Couldn't create the file",3)
		Return,0 ; couldn't create the file
	}

	m = 0                            ; seek to offset
	IfLess offset,0, SetEnv,m,2
	r := DllCall("SetFilePointerEx","Uint",h,"Int64",offset,"UInt *",p,"Int",m)
	IfEqual r,0, SetEnv, ErrorLevel, -3
	IfNotEqual ErrorLevel,0, {
		t = %ErrorLevel%              ; save ErrorLevel to be returned
		DllCall("CloseHandle", "Uint", h)
		ErrorLevel = %t%              ; return seek error
		Log("BinWrite - Ended with a seek error",3)
		Return 0
	}

	m := VarSetCapacity(data)        ; get the capacity ( >= used length )
	If (n < 1 or n > m)
		n := m
	result := DllCall("WriteFile","UInt",h,"Str",data,"UInt",n,"UInt *",Written,"UInt",0)
	if (!result or Written < n)
		ErrorLevel = -3
	IfNotEqual ErrorLevel,0, SetEnv,t,%ErrorLevel%

	h := DllCall("CloseHandle", "Uint", h)
	IfEqual h,-1, SetEnv, ErrorLevel, -2
	IfNotEqual t,,SetEnv, ErrorLevel, %t%-%ErrorLevel%

	Log("BinWrite - Ended")
	Return Written
}

/* ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BinRead ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
|  - Open binary file
|  - Read n bytes (n = 0: file size)
|  - From offset (offset < 0: counted from end)
|  - Close file
|  (Binary)data (replaced) <- file[offset + 0..n-1]
|  Return #bytes actually read
*/ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BinRead(file, ByRef data, n=0, offset=0) {
	Log("BinRead - Started - Reading " . n . " bytes from offset " . offset . " in " . file)
	h := DllCall("CreateFile","Str",file,"Uint",0x80000000,"Uint",3,"UInt",0,"UInt",3,"Uint",0,"UInt",0)
	IfEqual h,-1, SetEnv, ErrorLevel, -1
	IfNotEqual ErrorLevel,0, {
		Log("BinRead - Ended - Couldn't create the file",3)
		Return,0 ; couldn't open the file
	}

	m = 0                            ; seek to offset
	IfLess offset,0, SetEnv,m,2
	r := DllCall("SetFilePointerEx","Uint",h,"Int64",offset,"UInt *",p,"Int",m)
	IfEqual r,0, SetEnv, ErrorLevel, -3
	IfNotEqual ErrorLevel,0, {
		t = %ErrorLevel%              ; save ErrorLevel to be returned
		DllCall("CloseHandle", "Uint", h)
		ErrorLevel = %t%              ; return seek error
		Log("BinRead - Ended with a seek error",3)
		Return 0
	}

	m := DllCall("GetFileSize","UInt",h,"Int64 *",r)
	If (n < 1 or n > m)
		n := m
	Granted := VarSetCapacity(data, n, 0)
	IfLess Granted,%n%, {
		ErrorLevel = Mem=%Granted%
		Log("BinRead - Ended with a memory error",3)
		Return 0
	}

	result := DllCall("ReadFile","UInt",h,"Str",data,"UInt",n,"UInt *",Read,"UInt",0)

	if (!result or Read < n)
		t = -3
	IfNotEqual ErrorLevel,0, SetEnv,t,%ErrorLevel%

	h := DllCall("CloseHandle", "Uint", h)
	IfEqual h,-1, SetEnv, ErrorLevel, -2
	IfNotEqual t,,SetEnv, ErrorLevel, %t%-%ErrorLevel%

	Log("BinRead - Ended")
	Return Read
}
