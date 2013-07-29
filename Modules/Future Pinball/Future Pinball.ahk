MEmu = Future Pinball
MEmuV = v1.9.1.20101231
MURL = http://www.futurepinball.com/
MAuthor = djvj
MVersion = 2.0
MCRC = E4BFE69C
iCRC =
MID = 635038268894446032
MSystem = "Future Pinball"
;----------------------------------------------------------------------------
; Notes:
; Thanks to the FPLaunch author for some of the code
; To set fullscreen, open the emu and goto Preferences->Video / Rendering Options and set your resolution and check fullscreen.
; AHK is not 100% reliable with its focusing. If coin/start/flipper buttons don't function when you start a table, try clicking your left mouse button.
; The script will fail if you have any errors or missing files for your tables. Make sure every table is working before you turn on the LoadingScreen.
; If you use Esc as your exit_emulator_key, you may see the table editor flash in when you exit a game. This is because Esc is the default fixed key for FP so it's closing the game before ahk does.
; If you get script errors or no tables seem to work, try running FP as admin and it will probably fix it.
; If you need to run FP as admin, you can try this trick http://www.zdnet.com/blog/bott/fixing-windows-vista-part-2-taming-uac/436?pg=4 and use the other Run command commented below
; Future Pinball stores its config in the registry @ HKEY_USERS\S-1-5-21-440413192-1003725550-97281542-1001\Software\Future Pinball\GamePlayer
;----------------------------------------------------------------------------
StartModule()
FadeInStart()
7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable . " /open """ . romPath . "\" . romName . romExtension . """ /play /exit /arcaderender", emupath, "Hide")
;Run, "schtasks /run /tn �Future Pinball�", C:\Windows\system32 ; this runs FP via Task Scheduler if you need to run as admin and don't want to see a UAC popup

WinWait("ahk_class FuturePinball")
WinWait("ahk_class FuturePinballOpenGL")
WinActivate, ahk_class FuturePinballOpenGL
WinWaitActive("ahk_class FuturePinballOpenGL")
WinWait, ahk_class FuturePinballOpenGLSecondary,,1	; do not use the function because it will ScriptError after 1 second
WinActivate, ahk_class FuturePinballOpenGLSecondary
WinWaitActive, ahk_class FuturePinballOpenGLSecondary,,1	; do not use the function because it will ScriptError after 1 second
WinWaitClose("ahk_class Ghost",,5)	; this doesn't always get picked up by ahk, so we need a timeout
Loop {
	IfWinActive, Future Pinball ahk_class FuturePinballOpenGL
		Break
	WinActivate, Future Pinball ahk_class FuturePinballOpenGL
	Sleep, 50
}
WinWaitActive("Future Pinball ahk_class FuturePinballOpenGL")

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinHide, ahk_class FuturePinball	; need these 2 lines otherwise the table editor flashes over the GUI
	WinMinimize, ahk_class FuturePinball
	WinClose("ahk_class FuturePinball")
	WinWaitClose("ahk_class FuturePinball")	; this helps eliminate the slight flicker when you exit the table
Return
