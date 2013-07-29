MCRC=A2787BAA
MVersion=1.0.3

FadeInStart(){
	Gosub, FadeInStart
	Gosub, CoverFE
}
FadeInExit(){
	SetTimer, FadeInExit, -1	; so we can have emu launch while waiting for fade delay to end
}
FadeOutStart(){
	Gosub, FadeOutStart
	Gosub, ShowFE
}
FadeOutExit(){
	Gosub, FadeOutExit
}

CoverFE:
	Log("CoverFE - Started",4)
	StringTrimRight, fadeLyr1ColorAlpha, fadeLyr1Color, 6
	fadeLyr1ColorAlpha := "0x" . fadeLyr1ColorAlpha
	StringTrimLeft, fadeLyr1ColorClr, fadeLyr1Color, 2
	Gui, 20: New, -Caption +ToolWindow +OwnDialogs
	Gui, 20: Color, %fadeLyr1ColorClr%
	Gui, 20: Show, x0 y0 W%A_ScreenWidth% H%A_ScreenHeight%, CoverFE
	WinSet, Transparent, 0x%fadeLyr1ColorAlpha%, A
	If hideFE = true
		FadeApp("ahk_pid " . frontendPID,"out")
	Log("CoverFE - Ended",4)
Return
ShowFE:
	Log("ShowFE - Started",4)
	Gui, 20: Destroy
	If hideFE = true
		FadeApp("ahk_pid " . frontendPID,"in")
	Log("ShowFE - Ended",4)
Return

CloseFadeIn:
	Log("CloseFadeIn - Started",4)
	fadeInActive:=	; interrupts the fade loop if it is checking this var
	fadeInEndTime := fadeInEndTime - A_TickCount	; turns off user set FadeInDelay by increasing the var checked in the timer
	t1 = 100	; sets image-based fade animation to the last loop (100%) and completes animation
	Process, Exist, 7z.exe
	If ErrorLevel {
		7zCanceled=1
		Process, Close, 7z.exe	; if 7z is running and extracting a game, it force closes 7z and returns to the front end (acts as a 7z cancel)
		Log("User cancelled 7z extraction. Ending HyperLaunch and returning to Front End")
		Process, WaitClose, 7z.exe	; wait until 7z is closed so we don't try to delete files too fast
		Sleep, 200	; just force a little more time to help prevent files from still being locked
		7zCleanUp()	; must delete partially extracted file
		ExitApp
	}
	Log("CloseFadeIn - Ended",4)
Return
CloseFadeOut:
	Log("CloseFadeOut - Started",4)
	fadeOutEndTime := A_TickCount
	t2 = 100
	Log("CloseFadeOut - Ended",4)
Return

; Might need this for MG support also
AnykeyFadeBypass:
	If (A_TimeIdlePhysical <= anykeyStart) {	; If our current idle time is less then the amount we started, user must of pressed a key and we should exit fade
		Log("AnykeyFadeBypass - User interrupted Fade_" . anykeyMethod . ", skipping to " . (If anykeyMethod = "in" ? "FadeInExit" : "FadeOutExit"))
		fadeInterrupted = 1
		Goto, % (If anykeyMethod = "in" ? "CloseFadeIn" : "CloseFadeOut")
	}
Return

UpdateFadeFor7z:
	Gosub, %fadeLyr37zAnimation%	; Calling user set animation function for 7z
	CLR_Stop()
Return

FadeInStart:
	If fadeIn = true
	{	Log("FadeInStart - Started",4)
		If !pToken := Gdip_Startup()	; Start gdi+
			ScriptError("Gdiplus failed to start. Please ensure you have gdiplus on your system")

		If mgEnabled = true
			XHotKeywrapper(mgKey,"StartMulti","OFF")
		If hpEnabled = true
			XHotKeywrapper(hpKey,"TogglePauseMenuStatus","OFF")
		XHotKeywrapper(exitEmulatorKey,"CloseProcess","OFF")
		XHotKeywrapper(exitEmulatorKey,"CloseFadeIn","ON")
		If fadeInterruptKey = anykey	; if user wants anykey to be able to disrupt fade, use this label
		{	anykeyStart := A_TimeIdlePhysical	; store current idle time so AnykeyFadeBypass timer knows if it has been reset
			anykeyMethod = in	; this tells AnykeyFadeBypass if we are in fadeIn or fadeOut so it knows what label to advance to
			SetTimer, AnykeyFadeBypass, 200	; idle check timer should run every 200ms and to check if user has pressed a key causing idletime to reset
		} Else {	; else set custom interrupt key and convert exitEmulatorKey to fadeinterrupt
			Hotkey, Enter, CloseFadeIn, On
			Hotkey, Esc, CloseFadeIn, On
			XHotKeywrapper(fadeInterruptKey,"CloseFadeIn","ON")
		}

		fadeInLyr1File := GetFadePicFile("Layer",1)
		fadeInLyr2File := GetFadePicFile("Layer",2)

		; Create canvas and Image for Layer 1
		IfExist, % fadeInLyr1File	; If a layer 1 image exists, let's get its dimensions
		{	fadeLyr1Pic := Gdip_CreateBitmapFromFile(fadeInLyr1File)
			Gdip_GetImageDimensions(fadeLyr1Pic, fadeLyr1PicW, fadeLyr1PicH)
		}
		hbm1 := CreateDIBSection(A_ScreenWidth,A_ScreenHeight)	; still need to create these if an image does not exist so a background color can be used instead
		hdc1 := CreateCompatibleDC(), obm1 := SelectObject(hdc1, hbm1)
		G1 := Gdip_GraphicsFromhdc(hdc1), Gdip_SetInterpolationMode(G1, 7)

		; Create canvas and Image for Layer 2
		IfExist, % fadeInLyr2File	; If a layer 2 image exists, let's get its dimensions
		{	fadeLyr2Pic := Gdip_CreateBitmapFromFile(fadeInLyr2File)
			Gdip_GetImageDimensions(fadeLyr2Pic, fadeLyr2PicW, fadeLyr2PicH)
			fadeLyr2PicW := fadeLyr2PicW * fadeLyr2Adjust
			fadeLyr2PicH := fadeLyr2PicH * fadeLyr2Adjust
			GetFadePicPosition(fadeLyr2PicX,fadeLyr2PicY,fadeLyr2X,fadeLyr2Y,fadeLyr2PicW,fadeLyr2PicH,fadeLyr2Pos)
			hbm2 := CreateDIBSection(fadeLyr2PicW,fadeLyr2PicH)
			hdc2 := CreateCompatibleDC(), obm2 := SelectObject(hdc2, hbm2)
			G2 := Gdip_GraphicsFromhdc(hdc2), Gdip_SetInterpolationMode(G2, 7)
		}

		CurrentGUI := 1
		Gui, Fade_GUI%CurrentGUI%: New, +Hwnd%CurrentGUI%_ID +E0x80000 +ToolWindow -Caption +AlwaysOnTop +OwnDialogs, FadeIn Layer %CurrentGUI%
		Loop, 6
		{	CurrentGUI++
			OwnerGUI := A_Index
			Gui, Fade_GUI%CurrentGUI%: New, +OwnerFade_GUI%OwnerGUI% +Hwnd%CurrentGUI%_ID +E0x80000 +ToolWindow -Caption +AlwaysOnTop +OwnDialogs, FadeIn Layer %CurrentGUI%
		}

		pBrush := Gdip_BrushCreateSolid("0x" . fadeLyr1Color)
		Gdip_FillRectangle(G1, pBrush, -1, -1, A_ScreenWidth+1, A_ScreenHeight+1)
		If fadeInLyr1File {
			GetBGPicPosition(fadeLyr1PicXNew,fadeLyr1PicYNew,fadeLyr1PicWNew,fadeLyr1PicHNew,fadeLyr1PicW,fadeLyr1PicH,fadeLyr1AlignImage)	; get the background pic's new position and size
			If (fadeLyr1AlignImage = "Stretch and Lose Aspect") {	; 
				Gdip_DrawImage(G1, fadeLyr1Pic, 0, 0, A_ScreenWidth+1, A_ScreenHeight+1, 0, 0, fadeLyr1PicW, fadeLyr1PicH)
			} Else If (fadeLyr1AlignImage = "Stretch and Keep Aspect" Or fadeLyr1AlignImage = "Center Width" Or fadeLyr1AlignImage = "Center Height" Or fadeLyr1AlignImage = "Align to Bottom Left" Or fadeLyr1AlignImage = "Align to Bottom Right") {
				Gdip_DrawImage(G1, fadeLyr1Pic, fadeLyr1PicXNew, fadeLyr1PicYNew, fadeLyr1PicWNew+1, fadeLyr1PicHNew+1, 0, 0, fadeLyr1PicW, fadeLyr1PicH)
			} Else If (fadeLyr1AlignImage = "Center") {	; original image size and aspect
				Gdip_DrawImage(G1, fadeLyr1Pic, fadeLyr1PicXNew, fadeLyr1PicYNew, fadeLyr1PicW+1, fadeLyr1PicH+1, 0, 0, fadeLyr1PicW, fadeLyr1PicH)
			} Else If (fadeLyr1AlignImage = "Align to Top Right") {	; place the pic so the top right corner matches the screen's top right corner
				Gdip_DrawImage(G1, fadeLyr1Pic, fadeLyr1PicXNew, 0,fadeLyr1PicWNew+1,fadeLyr1PicHNew, 0, 0, fadeLyr1PicW, fadeLyr1PicH)
			} Else {	; place the pic so the top left corner matches the screen's top left corner, also the default
				Gdip_DrawImage(G1, fadeLyr1Pic, 0, 0,fadeLyr1PicWNew+1,fadeLyr1PicHNew+1, 0, 0, fadeLyr1PicW, fadeLyr1PicH)
			}
		}

		If fadeInLyr2File {
			; figure out what quadrant the layer 2 image is in, so we know to apply a + or - pad value so the user does not have to
			If fadeLyr2Pos in No Alignment,Center,Top Left Corner
				fadeLyr2PicPadX:=fadeLyr2PicPad, fadeLyr2PicPadY:=fadeLyr2PicPad
			Else If fadeLyr2Pos = Top Center
				fadeLyr2PicPadX:=0, fadeLyr2PicPadY:=fadeLyr2PicPad
			Else If fadeLyr2Pos = Left Center
				fadeLyr2PicPadX:=fadeLyr2PicPad, fadeLyr2PicPadY:=0
			Else If fadeLyr2Pos = Top Right Corner
				fadeLyr2PicPadX:=fadeLyr2PicPad*-1, fadeLyr2PicPadY:=fadeLyr2PicPad
			Else If fadeLyr2Pos = Right Center
				fadeLyr2PicPadX:=fadeLyr2PicPad*-1, fadeLyr2PicPadY:=0
			Else If fadeLyr2Pos = Bottom Left Corner
				fadeLyr2PicPadX:=fadeLyr2PicPad, fadeLyr2PicPadY:=fadeLyr2PicPad*-1
			Else If fadeLyr2Pos = Bottom Center
				fadeLyr2PicPadX:=0, fadeLyr2PicPadY:=fadeLyr2PicPad*-1
			Else If fadeLyr2Pos = Bottom Right Corner
				fadeLyr2PicPadX:=fadeLyr2PicPad*-1, fadeLyr2PicPadY:=fadeLyr2PicPad*-1

			Gdip_DrawImage(G2, fadeLyr2Pic, 0, 0, fadeLyr2PicW, fadeLyr2PicH, 0, 0, fadeLyr2PicW//fadeLyr2Adjust, fadeLyr2PicH//fadeLyr2Adjust)
		}

		UpdateLayeredWindow(1_ID, hdc1, 0, 0, A_ScreenWidth, A_ScreenHeight)
		UpdateLayeredWindow(2_ID, hdc2, fadeLyr2PicX + fadeLyr2PicPadX, fadeLyr2PicY + fadeLyr2PicPadY, fadeLyr2PicW, fadeLyr2PicH)

		Loop, 7	; Show all 7 layers of GUI on screen
			Gui Fade_GUI%A_Index%: Show
		%fadeInTransitionAnimation%("in",fadeInDuration)

		fadeInEndTime := A_TickCount + fadeInDelay

		If (7zEnabled != "true") or (7zEnabled = "true" && found7z != "true") {
			GoSub, %fadeLyr3Animation%
		}
		Log("FadeInStart - Ended",4)
	}
	; Tacking on these features below so they trigger at the desired positions during launch w/o a need for additional calls in each module
	If (mgEnabled = "true" || hpEnabled = "true")
		SetTimer, CreateMGRomTable, -1

	If (romMappingLaunchMenuEnabled = "true") ; && romMapMultiRomsFound)
		DestroyRomMappingLaunchMenu()
	StartGlobalUserFeatures%zz%()	; starting global user functions here so they are triggered after fade screen is up
Return

FadeInExit:
	If fadeIn = true
	{	Log("FadeInExit - Started",4)
		If fadeInExitDelay {	; if user wants to use a delay to let the emu load
			If !fadeInExitDelayStart {	; checking if starttime was set already, this prevents looping and restarting of this timer by pressing the interrupt key over and over
				fadeInExitDelayStart := A_TickCount
				fadeInExitDelayEnd := fadeInExitDelay + fadeInExitDelayStart	; when the sleep should end
			}
			Loop {
				If ((A_TickCount >= fadeInExitDelayEnd) Or fadeInterrupted ) {	; if delay has been met or user cancelled by pressing a fade interrupt key break out and continue
					fadeInterrupted:=	; reset var so we know not to start another sleep
					Break
				}
				Sleep, 100
			}
		}
		XHotKeywrapper(exitEmulatorKey,"CloseFadeIn","OFF")
		If fadeInterruptKey = anykey	; if user wants anykey to be able to disrupt fade, use this label
			SetTimer, AnykeyFadeBypass, Off
		Else {
			Hotkey, Esc, CloseFadeIn, Off
			Hotkey, Enter, CloseFadeIn, Off
			XHotKeywrapper(fadeInterruptKey,"CloseFadeIn","OFF")
		}
		
		%fadeInTransitionAnimation%("out",fadeInDuration)

		; Clean up on exit
		Gdip_DeleteBrush(pBrush)
		Loop, 7 {
			Gdip_GraphicsClear(G%A_Index%)	; clearing canvas for all layers
			UpdateLayeredWindow(hwnd%A_Index%, hdc%A_Index%)	; showing cleared canvas
			Gdip_DisposeImage(fadeLyr%A_Index%Pic), SelectObject(hdc%A_Index%, obm%A_Index%), DeleteObject(hbm%A_Index%), DeleteDC(hdc%A_Index%), Gdip_DeleteGraphics(G%A_Index%)
			Gui, Fade_GUI%A_Index%: Destroy
		}
		Gdip_Shutdown(pToken)	; gdi+ may now be shutdown on exiting the program
		If mgEnabled = true
			XHotKeywrapper(mgKey,"StartMulti","ON")
		If hpEnabled = true
			XHotKeywrapper(hpKey,"TogglePauseMenuStatus","ON")
		XHotKeywrapper(exitEmulatorKey,"CloseProcess","ON")
		Log("FadeInExit ended, waiting for user to close launched application",4)
	}
	gameSectionStartTime := A_TickCount
	gameSectionStartHour := A_Now ; These two vars are in StartModule() and here because we need a way of it always being created if the module does not have Fade support. It's more accurate if used here vs starting in StartModule()
Return

FadeOutStart:
	If fadeOut = true
	{	Log("FadeOutStart started",4)
		If !pToken := Gdip_Startup()	; Start gdi+
			ScriptError("Gdiplus failed to start. Please ensure you have gdiplus on your system")

		fadeInterrupted:=	; need to reset this key in case Fade_In was interrupted
		If mgEnabled = true
			XHotKeywrapper(mgKey,"StartMulti","OFF")
		If hpEnabled = true
			XHotKeywrapper(hpKey,"TogglePauseMenuStatus","OFF")
		XHotKeywrapper(exitEmulatorKey,"CloseProcess","OFF")
		XHotKeywrapper(exitEmulatorKey,"CloseFadeOut","ON")
		If fadeInterruptKey = anykey	; if user wants anykey to be able to disrupt fade, use this label
		{	anykeyStart := A_TimeIdlePhysical	; store current idle time so AnykeyFadeBypass timer knows if it has been reset
			anykeyMethod = out	; this tells AnykeyFadeBypass if we are in fadeIn or fadeOut so it knows what label to advance to
			SetTimer, AnykeyFadeBypass, 200	; idle check timer should run every 200ms and to check if user has pressed a key causing idletime to reset
		} Else {	; else set custom interrupt key and convert exitEmulatorKey to fadeinterrupt
			Hotkey, Enter, CloseFadeOut, On
			Hotkey, Esc, CloseFadeOut, On
			XHotKeywrapper(fadeInterruptKey,"CloseFadeOut","ON")
		}

		lyr1OutFile := GetFadePicFile("Layer",-1)
		; lyr1OutFile := GetFadePicFile("Layer",-2)	; support for 2nd image on fadeOut

		IfExist, % lyr1OutFile
		{	lyr1OutPic := Gdip_CreateBitmapFromFile(lyr1OutFile)
			Gdip_GetImageDimensions(lyr1OutPic, lyr1OutPicW, lyr1OutPicH)	; get the width and height of the background image
		}
		outhbm1 := CreateDIBSection(A_ScreenWidth, A_ScreenHeight), outhdc1 := CreateCompatibleDC(), outobm1 := SelectObject(outhdc1, outhbm1)	; might have to use the original width / height from before the emu launched if  the screen res changed
		outG1 := Gdip_GraphicsFromhdc(outhdc1), Gdip_SetInterpolationMode(outG1, 7) ;, Gdip_SetSmoothingMode(outG1, 4)
		Gui, Fade_GUI8: New, +Hwndout1_ID +E0x80000 +ToolWindow -Caption +AlwaysOnTop +OwnDialogs, FadeOut Layer 1	; E0x80000 required for UpdateLayeredWindow to work. Is always on top, has no taskbar entry, no caption, and msgboxes will appear on top of the GUI

		; Draw Layer 1 (Background image and color)
		pBrush := Gdip_BrushCreateSolid("0x" . fadeLyr1Color)	; Painting the background color
		Gdip_FillRectangle(outG1, pBrush, -1, -1, A_ScreenWidth+3, A_ScreenHeight+3)	; draw the background first on layer 1, layer order matters!!
		If lyr1OutFile {
			GetBGPicPosition(fadeLyr1OutPicXNew,fadeLyr1OutPicYNew,fadeLyr1OutPicWNew,fadeLyr1OutPicHNew,lyr1OutPicW,lyr1OutPicH,fadeLyr1AlignImage)	; get the background pic's new position and size
			If (fadeLyr1AlignImage = "Stretch and Lose Aspect") {	; 
				Gdip_DrawImage(outG1, lyr1OutPic, 0, 0, A_ScreenWidth+3, A_ScreenHeight+3, 0, 0, lyr1OutPicW, lyr1OutPicH)	; adding a few pixels to avoid showing background on some pcs
			} Else If (fadeLyr1AlignImage = "Stretch and Keep Aspect" Or fadeLyr1AlignImage = "Center Width" Or fadeLyr1AlignImage = "Center Height" Or fadeLyr1AlignImage = "Align to Bottom Left" Or fadeLyr1AlignImage = "Align to Bottom Right") {
				Gdip_DrawImage(outG1, lyr1OutPic, fadeLyr1OutPicXNew, fadeLyr1OutPicYNew, fadeLyr1OutPicWNew+1, fadeLyr1OutPicHNew+1, 0, 0, lyr1OutPicW, lyr1OutPicH)
			} Else If (fadeLyr1AlignImage = "Center") {	; original image size and aspect
				Gdip_DrawImage(outG1, lyr1OutPic, fadeLyr1OutPicXNew, fadeLyr1OutPicYNew, lyr1OutPicW+1, lyr1OutPicH+1, 0, 0, lyr1OutPicW, lyr1OutPicH)
			} Else If (fadeLyr1AlignImage = "Align to Top Right") {	; place the pic so the top right corner matches the screen's top right corner
				Gdip_DrawImage(outG1, lyr1OutPic, fadeLyr1OutPicXNew, 0,fadeLyr1OutPicWNew+1,fadeLyr1OutPicHNew+1, 0, 0, lyr1OutPicW, lyr1OutPicH)
			} Else {	; place the pic so the top left corner matches the screen's top left corner, also the default
				Gdip_DrawImage(outG1, lyr1OutPic, 0, 0,fadeLyr1OutPicWNew+1,fadeLyr1OutPicHNew+1, 0, 0, lyr1OutPicW, lyr1OutPicH)
			}
		}

		UpdateLayeredWindow(out1_ID, outhdc1, 0, 0, A_ScreenWidth, A_ScreenHeight)
		Gui Fade_GUI8: Show
		%fadeOutTransitionAnimation%("in",fadeOutDuration)
		fadeOutEndTime := A_TickCount + fadeOutDelay
		Log("FadeOutStart ended",4)
	}
Return

FadeOutExit:
	StopGlobalUserFeatures%zz%()	; stoping global user functions here so they are closed before fade screen exits
	If fadeOut = true
	{	Log("FadeOutExit started",4)
		If fadeOutExitDelay {	; if user wants to use a delay
			If !fadeOutExitDelayStart {	; checking if starttime was set already, this prevents looping and restarting of this timer by pressing the interrupt key over and over
				fadeOutExitDelayStart := A_TickCount
				fadeOutExitDelayEnd := fadeOutExitDelay + fadeOutExitDelayStart	; when the sleep should end
			}
			Loop {
				If ((A_TickCount >= fadeOutExitDelayEnd) Or fadeInterrupted ) {	; if delay has been met or user cancelled by pressing a fade interrupt key break out and continue
					fadeInterrupted:=	; reset var so we know not to start another sleep
					Break
				}
				Sleep, 100
			}
		}
		XHotKeywrapper(exitEmulatorKey,"CloseFadeOut","OFF")
		If fadeInterruptKey = anykey	; if user wants anykey to be able to disrupt fade, use this label
			SetTimer, AnykeyFadeBypass, Off
		Else {
			Hotkey, Esc, CloseFadeOut, Off
			Hotkey, Enter, CloseFadeOut, Off
			XHotKeywrapper(fadeInterruptKey,"CloseFadeOut","OFF")
		}

		While fadeOutEndTime > A_TickCount {
			Sleep, 100
			Continue
		}

		%fadeOutTransitionAnimation%("out",fadeOutDuration)

		; Clean up on exit
		Gdip_DeleteBrush(pBrush)
		Gdip_DisposeImage(lyr1OutPic), SelectObject(outhdc1, outobm1), DeleteObject(outhbm1), DeleteDC(outhdc1), Gdip_DeleteGraphics(outG1)
		Gui, Fade_GUI8: Destroy
		Gdip_Shutdown(pToken)	; gdi+ may now be shutdown on exiting the program
		if GifAnimation
			{
			AniGif_DestroyControl(hAniGif1)
			Gui, Fade_GifAnim_GUI: Destroy
		}
		
		Log("FadeOutExit ended",4)
	}
Return

FadeInDelay:
	Log("FadeInDelay started",4)
	While fadeInActive && (fadeInEndTime > A_TickCount) {
		Sleep, 100
		Continue
	}
	Log("FadeInDelay ended",4)
Return

FadeLayer4Anim:
	if GifAnimation
		{
		fadeLyr4PicX := round(fadeLyr4PicX)+0 , fadeLyr4PicY := round(fadeLyr4PicY)+0 , fadeLyr4PicW := round(fadeLyr4PicW)+0 , fadeLyr4PicH := round(fadeLyr4PicH)+0 
		AniGif_LoadGifFromFile(hAniGif1, GifAnimation)
		AniGif_SetBkColor(hAniGif1, fadeTranspGifColor)
		Gui, Fade_GifAnim_GUI: Show, x%fadeLyr4PicX% y%fadeLyr4PicY% w%fadeLyr4PicW% h%fadeLyr4PicH%	
	} else {
		Gdip_GraphicsClear(G4)
		currentFadeLyr4Image++
		If (currentFadeLyr4Image>FadeLayer4AnimTotal)
			currentFadeLyr4Image=1
		Gdip_DrawImage(G4, FadeLayer4Anim%currentFadeLyr4Image%Pic, 0, 0, fadeLyr4PicW, fadeLyr4PicH)
		UpdateLayeredWindow(4_ID, hdc4,fadeLyr4PicX,fadeLyr4PicY, fadeLyr4PicW, fadeLyr4PicH)
	}
Return

; Trial feature to help detect if an error has occured launching the emulator and to error out if detected. Currently disabled and might need to be placed in another thread so it can run alongside HL
DetectFadeError:
	fadeTimeToWait += fadeInDuration	; add fade's duration
	fadeTimeToWait += fadeInDelay	; add fade's delay
	If cpWizardEnabled = true
		fadeTimeToWait += cpWizardDelay	; adding delay for CPWizard
	If dtEnabled = true
		fadeTimeToWait += 2000	; tacking on a couple seconds to give time for DT to mount
	fadeErrorStartTime := A_TickCount
	fadeErrorTime := fadeErrorStartTime + fadeTimeToWait + 1000	; giving 15 seconds for the emulator to launch and fade to disappear. If it goes more then that, most likely there was an issue.
	Loop {
		IfWinNotExist, Fade ahk_class AutoHotkeyGUI	; If fade gui does not exist, we know it is finished
			Break
		If 7zEnable = true
		{
			Process, Exist, 7z.exe
			If ErrorLevel
			{
				7zWasUsed := 1	; we know 7z was used at some point
				Continue	; 7z.exe is running, let's keep looping
			} Else If 7zWasUsed	; this will trigger if 7z.exe was found at some point, but it no longer is running
			{
				7zWasUsed :=	; clearing var so it doesn't trigger again
				fadeErrorTime := A_TickCount + fadeInDuration + (If dtEnabled = "true" ? 2000:"") + 15000 + (If (fadeInDelay>A_TickCount - fadeErrorStartTime) ? fadeInDelay - (A_TickCount - fadeErrorStartTime) : "")	; recalculating the end time in case a long 7z extraction took place.  if the 7z time > fadeindelay, we dont need to sum anything, else, we need to sum fadeindelay - time spent on 7z extraction
			}
		}
		If (A_TickCount > fadeErrorTime)
			ScriptError("There was a problem launching the application or with the module. Please disable Fade_In and get it working before turning Fade back on.")
		Sleep, 250
	}
Return

GetFadePicFile(name,num){
	Global fadeImgPath,dbName,systemName,fadeSystemAndRomLayersOnly
	fadePicType = png|gif|tif|bmp|jpg
	romFile := fadeImgPath . "\" . systemName . "\" . dbName . "\" . name . " " . num 
	systemFile := fadeImgPath . "\" . systemName . "\_Default\" . name . " " . num 
	globalFile := fadeImgPath . "\_Default\" . name . " " . num 	
	fadePicList := []
	Log("GetFadePicFile - Checking if any Fade " . name . A_Space . num . " images exist in: " . romFile . "*.*",4)
	If FileExist(romFile . "*.*")
        Loop, parse, fadePicType,|,
		{	Log("GetFadePicFile - Looking for Fade " . name . A_Space . num . " pic: " . romFile . "*." . A_LoopField,4)
            Loop, % romFile . "*." . A_LoopField
			{	Log("GetFadePicFile - Found Fade " . name . A_Space . num . " pic: " . A_LoopFileFullPath,4)
				fadePicList.Insert(A_LoopFileFullPath)
			}
		}
	If !fadePicList[1]
	{	Log("GetFadePicFile - Checking if any Fade " . name . A_Space . num . " images exist in: " . systemFile . "*.*",4)
		If FileExist(systemFile . "*.*")
            Loop, parse, fadePicType,|,
			{	Log("GetFadePicFile - Looking for Fade " . name . A_Space . num . " pic: " . systemFile . "*." . A_LoopField,4)
                Loop, % systemFile . "*." . A_LoopField
				{	Log("GetFadePicFile - Found Fade " . name . A_Space . num . " pic: " . A_LoopFileFullPath,4)
                    fadePicList.Insert(A_LoopFileFullPath)
				}
			}
	}
	If !fadePicList[1]
	{	Log("GetFadePicFile - Checking if any Fade " . name . A_Space . num . " images exist in: " . globalFile . "*.*",4)
		If FileExist(globalFile . "*.*")
            Loop, parse, fadePicType,|,
			{	Log("GetFadePicFile - Looking for Fade " . name . A_Space . num . " pic: " . globalFile . "*." . A_LoopField,4)
                Loop, % globalFile . "*." . A_LoopField
				{	Log("GetFadePicFile - Found Fade " . name . A_Space . num . " pic: " . A_LoopFileFullPath,4)
                    fadePicList.Insert(A_LoopFileFullPath)	
				}
			}
	}
	If fadePicList[1]
	{
		Random, RndmfadePic, 1, % fadePicList.MaxIndex()
		file := fadePicList[RndmfadePic]		
	}
	Log("GetFadePicFile - Randomized images and Fade " . name . " " . num . " will use " . file)
	Return file
}

; Usage, params 1&2 are byref so supply the var you want to be filled with the calculated positions. Next 4 are the original pics xy,w,h. Last is the position the user wants.
GetFadePicPosition(ByRef retX, ByRef retY,x,y,w,h,pos){
		If (pos = "Center") {
			retX := ( A_ScreenWidth / 2 ) - ( w / 2 )
			retY := ( A_ScreenHeight / 2 ) - ( h / 2 )
		} Else If (pos = "Top Left Corner") {
			retX := 0
			retY := 0
		} Else If (pos = "Top Right Corner") {
			retX := A_ScreenWidth - w
			retY := 0
		} Else If (pos = "Bottom Left Corner") {
			retX := 0
			retY := A_ScreenHeight - h
		} Else If (pos = "Bottom Right Corner") {
			retX := A_ScreenWidth - w
			retY := A_ScreenHeight - h
		} Else If (pos = "Top Center") {
			retX := ( A_ScreenWidth / 2 ) - ( w / 2 )
			retY := 0
		} Else If (pos = "Bottom Center") {
			retX := ( A_ScreenWidth / 2 ) - ( w / 2 )
			retY := A_ScreenHeight - h
		} Else If (pos = "Left Center") {
			retX := 0
			retY := ( A_ScreenHeight / 2 ) - ( h / 2 )
		} Else If (pos = "Right Center") {
			retX := A_ScreenWidth - w
			retY := ( A_ScreenHeight / 2 ) - ( h / 2 )
		} Else {
			retX := x
			retY := y
		}
}
	
GetFadeAnimFiles(name,num){
	Global fadeImgPath,dbName,systemName,fadeSystemAndRomLayersOnly
	fadePicType = png|bmp|gif|jpg
	romFile := fadeImgPath . "\" . systemName . "\" . dbName . "\" . name . " " . num 
	systemFile := fadeImgPath . "\" . systemName . "\_Default\" . name . " " . num 
	globalFile := fadeImgPath . "\_Default\" . name . " " . num 
	FadeAnimAr:=[]
	Loop, Parse, fadePicType, |
		If FileExist(romFile . " (1)." . A_LoopField) {
			Loop % romFile . " (*)." . A_LoopField
				FadeAnimAr[A_Index] := A_LoopFileFullPath
		}
	If FadeAnimAr.MaxIndex() <= 0
		Loop, Parse, fadePicType, |
			If FileExist(systemFile . " (1)." . A_LoopField) {
				Loop % systemFile . " (*)." . A_LoopField
					FadeAnimAr[A_Index] := A_LoopFileFullPath
			}
	If FadeAnimAr.MaxIndex() <= 0 {
		If fadeSystemAndRomLayersOnly != true	; if user wants to use global files
			Loop, Parse, fadePicType, |
				If FileExist(globalFile . " (1)." . A_LoopField) {
					Loop % globalFile . " (*)." . A_LoopField
						FadeAnimAr[A_Index] := A_LoopFileFullPath
				}
	}
	Return FadeAnimAr
}

GetFadeGifFile(name){
	Global fadeImgPath,dbName,systemName,fadeSystemAndRomLayersOnly
	;fadePicType = png|bmp|gif|jpg
	romFile := fadeImgPath . "\" . systemName . "\" . dbName . "\" . name . "*.gif"  
	systemFile := fadeImgPath . "\" . systemName . "\_Default\" . name . "*.gif"  
	globalFile := fadeImgPath . "\_Default\" . name . "*.gif"  
	GifAnimationFiles := []
	;Loop, Parse, fadePicType, |
	If FileExist(romFile) {
		Loop % romFile
			GifAnimationFiles.insert(A_LoopFileFullPath)
	}
	If (GifAnimationFiles.MaxIndex() <= 0) {
		If FileExist(systemFile) {
			Loop % systemFile
				GifAnimationFiles.insert(A_LoopFileFullPath)
		}
	}
	If (GifAnimationFiles.MaxIndex() <= 0) {
		If fadeSystemAndRomLayersOnly != true	; if user wants to use global files
			If FileExist(globalFile) {
				Loop % globalFile
					GifAnimationFiles.insert(A_LoopFileFullPath)
			}
	}
	If (GifAnimationFiles.MaxIndex() > 0) {
		Random, RndmGif, 1, % GifAnimationFiles.MaxIndex()
		GifFile := GifAnimationFiles[RndmGif]
	}
	Return GifFile
}


AnimateWindow(Hwnd,Direction,Type,Time=100){
	Static Activate=0x20000, Center=0x10, Fade=0x80000, Hide=0x10000, Slide=0x40000, RL=0x2, LR=0x1, BT=0x8, TB=0x4
	hFlags := 0
	If !Hwnd
		ScriptError("AnimateWindow: No Hwnd supplied. Do not know what window to animate.")
	If !Direction
		ScriptError("AnimateWindow: No direction supplied. Options are In or Out")
	If !Type
		ScriptError("AnimateWindow: No Type supplied. Options are Activate, Center, Fade, Slide, RL, LR, BT, TB. Separate multiple types with a space")
	Loop, parse, Type, %A_Tab%%A_Space%, %A_Tab%%A_Space%
		IfEqual, A_LoopField,,Continue
		Else hFlags |= %A_LoopField%
	IfEqual, hFlags, ,Return "Error: Some of the types are invalid"
	DllCall("AnimateWindow", "uint", Hwnd, "uint", Time, "uint", If Direction="out"?Hide|=hFlags:hFlags)	; adds the Hide type on "out" direction
}
