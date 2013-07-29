MEmu = U64Emu Platinum Edition
MEmuV = v3.11
MURL = http://www.zophar.net/marcade/ultra64-platinum-edition.html
MAuthor = djvj
MVersion = 2.0
MCRC = 8BB0217C
iCRC = 866CCAA2
MID = 635038268928674521
MSystem = "Ultra64"
;------------------------------------------------------------------------
; Notes:
; This emulator only plays Killer Instinct 1 and Killer Instinct 2
; Settings are stored in your registry at HKEY_CURRENT_USER\Software\U64Emu\u64emu
; Roms should be unzipped and match the dirs set in the emuator Rom Settings.
; Mame CHDs don't work, you need the IMG versions, or use the patcher tool to convert your CHD to IMG
; Controls can be remapped near the bottom of the script. Can't move it up or else the emu fails to launch.
; If you use an older mame set and your roms are "ki" and "ki2", do a find/replace and change all kinst to ki and kinst2 to ki2
;
; To use this in your MAME wheel:
; Add the <exe>u64emu</exe> tag to both "kinst" and "kinst2" entries in your database
; Create a u64emu folder in your Modules folder and place this script in there. The name of this script must match the exe tag in your database
; Create a u64emu.ini in your Hyperspin\Settings folder. Open your MAME.ini in this folder and copy the [exe info] section into the u64emu.ini and change the "path" and "exe" to this emulator
;
; Default Keys:
; System Controls
; ::F11		; Service Menu
; ::-			; Volume Up
; ::+			; Volume Down

; Player 1 Controls
; ::Home	; Up
; ::End		; Down
; ::Delete	; Left
; ::PgDn	; Right
; ::w			; Quick Punch
; ::e			; Medium Punch
; ::r			; Fierce Punch
; ::s			; Quick Kick
; ::d			; Medium Kick
; ::f			; Fierce Kick
; ::q			; Start
; ::F7		; Coin

; Player 2 Controls
; ::Up		; Up
; ::Down	; Down
; ::Left		; Left
; ::Right	; Right
; ::u			; Quick Punch
; ::i			; Medium Punch
; ::p			; Fierce Punch
; ::j			; Quick Kick
; ::k			; Medium Kick
; ::l			; Fierce Kick
; ::y			; Start
; ::F8		; Coin
;------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
Resolution := IniReadCheck(settingsFile, "Settings", "Resolution","3",,1)		; 0=320x240, 1=640x480, 2=800x600, 3=1024x768, 4=1280x1024, 5=1600x1200
WinX := IniReadCheck(settingsFile, "Settings", "WinX","0",,1)				; For windowed mode only
WinY := IniReadCheck(settingsFile, "Settings", "WinY","0",,1)

; Set Resolution
If ( Resolution = 0 )
	WriteReg("ScreenRes", 0)
Else If ( Resolution = 1 )
	WriteReg("ScreenRes", 1)
Else If ( Resolution = 2 )
	WriteReg("ScreenRes", 2)
Else If ( Resolution = 3 )
	WriteReg("ScreenRes", 3)
Else If ( Resolution = 4 )
	WriteReg("ScreenRes", 4)
Else If ( Resolution = 5 )
	WriteReg("ScreenRes", 5)

WriteReg("FullScreen", (If Fullscreen = "true" ? 1 : 0))	; Set Fullscreen
WriteReg("RomSet", (If romName = "kinst" ? 1 : 2))	; Setting the game we want to play

Run(executable,emuPath)

WinWait("U64Emu Platinum Edition ahk_class #32770")
WinWaitActive("U64Emu Platinum Edition ahk_class #32770")

WinMenuSelectItem, U64Emu Platinum Edition ahk_class #32770,, Emulation, Start
Sleep, 1000

; In windowed mode on smaller resolutions, the game screen is might not be fully on screen and the emu doesn't save its last position. It doesn't take effect if you run fullscreen.
If Fullscreen != true
	WinMove, AHK_class #32770, , %WinX%, %WinY%

FadeInExit()
Process("WaitClose",executable)
FadeOutExit()
ExitModule()


WriteReg(var1, var2) {
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\U64Emu\u64emu\Options, %var1%, %var2%
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\U64Emu\u64emu\KI2_Options, %var1%, %var2%
}

HaltEmu:
	disableActivateBlackScreen = true
Return

CloseProcess:
	FadeOutStart()
	WinClose("U64Emu Platinum Edition ahk_class #32770")
Return
