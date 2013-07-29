mTest = true	; HLHQ will not look at this as a module
#SingleInstance Force

StringReplace, 1, 1, ",, All ; remove quote marks
WaitCloseProcess = %1%		;	get name of process from cmd parameter passed to this script

If !WaitCloseProcess
	Gosub, CloseMagnifyExe
Else
{
WinSet, Style, -0xC00000, ahk_class Screen Magnifier Window		;Removes the titlebar of the magnifier window
WinSet, Style, -0x40000, ahk_class Screen Magnifier Window		;Removes the border of the magnifier window

Process, WaitClose, %WaitCloseProcess%

Gosub, CloseMagnifyExe
}
ExitApp
	

CloseMagnifyExe:
	Process,Close, magnify.exe
	ExitApp
Return
