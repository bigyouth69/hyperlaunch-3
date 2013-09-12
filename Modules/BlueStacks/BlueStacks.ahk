MEmu = BlueStacks
MEmuV =  v0.7.10.869
MURL = http://www.bluestacks.com/
MAuthor = djvj
MVersion = 2.0.1
MCRC = 418600C6
iCRC = 79D03371
MID = 635038268876501094
MSystem = "Android"
;----------------------------------------------------------------------------
; Notes:
; Set your Emu_Path to "PATH\HD-Frontend.exe" where bluestacks is installed, something like this: C:\Program Files (x86)\BlueStacks\HD-Frontend.exe
; Rom_Extension should be set to lnk
; Each game you install in BlueStacks will have a lnk shortcut made in your C:\ProgramData\BlueStacks\UserData\Library\My Apps
; Rom_Path should point to this Library folder
; If the HD-Agent does not quit after you exit a game, the next time you launch you will be back in the same Android Virtual Environment and the previous game will have crashed
; Due to this, some games may not save settings when you quit. It is advised you close the game in Android by normal means, then exit.
; BlueStacks stores its config in the registry @ HKEY_LOCAL_MACHINE\SOFTWARE\BlueStacks
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "settings", "Fullscreen","true",,1)
Width := IniReadCheck(settingsFile, "settings", "Width","1600",,1)
Height := IniReadCheck(settingsFile, "settings", "Height","900",,1)
WindowedWidth := IniReadCheck(settingsFile, "Settings", "WindowedWidth","750",,1)
WindowedHeight := IniReadCheck(settingsFile, "Settings", "WindowedHeight","450",,1)

BezelStart("FixResMode")

currentFullScreen := ReadReg("FullScreen")
If ( Fullscreen != "true" And currentFullScreen = 1 )
	WriteReg("FullScreen", 0)
Else If ( Fullscreen = "true" And currentFullScreen = 0 )
	WriteReg("FullScreen", 1)

If bezelPath {	; Setting windowed mode resolution
	Width := WindowedWidth
	Height := WindowedHeight
}

currentWidth := ReadReg("Width")	; update width if desired width does not match current
If ( Width != currentWidth and Width != "" )
	WriteReg("Width", Width)
currentHeight := ReadReg("Height")	; update height if desired width does not match current
If ( Height != currentHeight and Height != ""  )
	WriteReg("Height", Height)

Run("" . romPath . "\" . romName . romExtension . "")

WinWait("BlueStacks App Player")
WinWaitActive("BlueStacks App Player")

BezelDraw()
FadeInExit()
Process("WaitClose", executable)
Sleep, 100
Run, HD-Quit.exe, %emuPath%	; this is the provided exe to quit BlueStacks Agent
TrayRefresh()	; attempts to prevent dead icons from building up on your tray
BezelExit()
FadeOutExit()
ExitModule()


ReadReg(var1) {
	RegRead, regValue, HKEY_LOCAL_MACHINE, SOFTWARE\BlueStacks\Guests\Android\FrameBuffer\0, %var1%
	Return %regValue%
}

WriteReg(var1, var2) {
	RegWrite, REG_DWORD, HKEY_LOCAL_MACHINE, SOFTWARE\BlueStacks\Guests\Android\FrameBuffer\0, %var1%, %var2%
}

TrayRefresh() {
	static WM_MOUSEMOVE = 0x200
	ControlGetPos,,,w,h,ToolbarWindow321, AHK_class Shell_TrayWnd
	width:=w, hight:=h
	while ((h:=h-5)>0 and w:=width)
	while ((w:=w-5)>0)
	PostMessage, WM_MOUSEMOVE,0, ((hight-h) >> 16)+width-w, ToolbarWindow321, AHK_class Shell_TrayWnd
}

CloseProcess:
	FadeOutStart()
	WinClose("BlueStacks App Player")
Return
