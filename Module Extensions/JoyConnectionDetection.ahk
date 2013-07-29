Loop,16
{
VarSetCapacity(joy_State, 512)
joy_Error := DllCall("winmm\joyGetPosEx", "ptr", (A_Index - 1), "ptr", &joy_State)
If joy_Error = 0
	retval := 1
Else
	retval := 0
ret := ret . retval
}
ret := BinaryToNumber(ret)
Exit, %ret%


BinaryToNumber(InputBinary)
{
 Length := StrLen(InputBinary), Result := 0
 Loop, Parse, InputBinary
  Result += A_LoopField << (Length - A_Index)
 Return, Result
}

NumberToBinary(InputNumber)
{
; does not work with negative numbers
 While, InputNumber
  Result := (InputNumber & 1) . Result, InputNumber >>= 1
 Return, Result
}
