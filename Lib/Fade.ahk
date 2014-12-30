MCRC=B578DC50
MVersion=1.0.7

FadeInStart(){
	Gosub, FadeInStart
	Gosub, CoverFE
}
FadeInExit(){
	gosub, FadeInExit
	;SetTimer, FadeInExit, -1	; so we can have emu launch while waiting for fade delay to end
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
	Process("Exist", "7z.exe")
	If ErrorLevel {
		7zCanceled=1
		Process("Close", "7z.exe")	; if 7z is running and extracting a game, it force closes 7z and returns to the front end (acts as a 7z cancel)
		Log("User cancelled 7z extraction. Ending HyperLaunch and returning to Front End",3)
		Process("WaitClose", "7z.exe")	; wait until 7z is closed so we don't try to delete files too fast
		Sleep, 200	; just force a little more time to help prevent files from still being locked
		7zCleanUp()	; must delete partially extracted file
		ExitModule()
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

UpdateFadeForNon7z:
	Gosub, %fadeLyr3Animation%	; Calling user set animation function for 7z when no 7z extraction took place
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
		
		;Acquiring screen info for dealing with rotated menu drawings
		Gdip_Alt_GetRotatedDimensions(A_ScreenWidth, A_ScreenHeight, screenRotationAngle, baseScreenWidth, baseScreenHeight)
		Gdip_GetRotatedTranslation(baseScreenWidth, baseScreenHeight, screenRotationAngle, xTranslation, yTranslation)
		xTranslation:=round(xTranslation), yTranslation:=round(yTranslation)
		XBaseRes := 1920, YBaseRes := 1080
		if (((A_screenWidth < A_screenHeight) and ((screenRotationAngle=0) or (screenRotationAngle=180))) or ((A_screenWidth > A_screenHeight) and ((screenRotationAngle=90) or (screenRotationAngle=270))))
			XBaseRes := 1080, YBaseRes := 1920
		if !fadeXScale 
			fadeXScale := baseScreenWidth/XBaseRes
		if !fadeYScale
			fadeYScale := baseScreenHeight/YBaseRes
		Log("Fade screen scale factor: X=" . fadeXScale . ", Y= " . fadeYScale,5)
		OptionScale(fadeLyr2X, fadeXScale)
		OptionScale(fadeLyr2Y, fadeYScale)
		OptionScale(fadeLyr2PicPad, fadeXScale) ;could be Y also
	
		fadeInLyr1File := GetFadePicFile("Layer 1",if (fadeUseBackgrounds="true") ? true : false)
		If fadeLyr2Prefix
			fadeInLyr2File := GetFadePicFile(fadeLyr2Prefix)
		
		; Create canvas for the two first fade in screens
		Loop, 2 { 
        CurrentGUI := A_Index
			If (A_Index=1)
                Gui, Fade_GUI%CurrentGUI%: -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop 
			else { 
				OwnerGUI := CurrentGUI - 1
                Gui, Fade_GUI%CurrentGUI%: +OwnerFade_GUI%OwnerGUI% -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop
			}
            Gui, Fade_GUI%CurrentGUI%: Margin,0,0
            Gui, Fade_GUI%CurrentGUI%: Show,, fadeLayer%CurrentGUI%
            Fade_hwnd%CurrentGUI% := WinExist()
            Fade_hbm%CurrentGUI% := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
            Fade_hdc%CurrentGUI% := CreateCompatibleDC()
            Fade_obm%CurrentGUI% := SelectObject(Fade_hdc%CurrentGUI%, Fade_hbm%CurrentGUI%)
            Fade_G%CurrentGUI% := Gdip_GraphicsFromhdc(Fade_hdc%CurrentGUI%)
            Gdip_SetInterpolationMode(Fade_G%CurrentGUI%, 7)
            Gdip_SetSmoothingMode(Fade_G%CurrentGUI%, 4)
			Gdip_TranslateWorldTransform(Fade_G%CurrentGUI%, xTranslation, yTranslation)
            Gdip_RotateWorldTransform(Fade_G%CurrentGUI%, screenRotationAngle)
        }	
		fadeLyr1CanvasX := 0 , fadeLyr1CanvasY := 0
		fadeLyr1CanvasW := baseScreenWidth, fadeLyr1CanvasH := baseScreenHeight
		pGraphUpd(Fade_G1,fadeLyr1CanvasW,fadeLyr1CanvasH)
		pBrush := Gdip_BrushCreateSolid("0x" . fadeLyr1Color)
		Gdip_Alt_FillRectangle(Fade_G1, pBrush, -1, -1, baseScreenWidth+2, baseScreenHeight+2)
		
		If FileExist(fadeInLyr1File)	; If a layer 1 image exists, let's get its dimensions
		{	fadeLyr1Pic := Gdip_CreateBitmapFromFile(fadeInLyr1File)
			Gdip_GetImageDimensions(fadeLyr1Pic, fadeLyr1PicW, fadeLyr1PicH)
			GetBGPicPosition(fadeLyr1PicXNew,fadeLyr1PicYNew,fadeLyr1PicWNew,fadeLyr1PicHNew,fadeLyr1PicW,fadeLyr1PicH,fadeLyr1AlignImage)	; get the background pic's new position and size
			If (fadeLyr1AlignImage = "Stretch and Lose Aspect") {	; 
				Gdip_Alt_DrawImage(Fade_G1, fadeLyr1Pic, fadeLyr1PicXNew,fadeLyr1PicYNew,fadeLyr1PicWNew+1,fadeLyr1PicHNew+1)
			} Else If (fadeLyr1AlignImage = "Stretch and Keep Aspect" Or fadeLyr1AlignImage = "Center Width" Or fadeLyr1AlignImage = "Center Height" Or fadeLyr1AlignImage = "Align to Bottom Left" Or fadeLyr1AlignImage = "Align to Bottom Right") {
				Gdip_Alt_DrawImage(Fade_G1, fadeLyr1Pic, fadeLyr1PicXNew, fadeLyr1PicYNew, fadeLyr1PicWNew+1, fadeLyr1PicHNew+1)
			} Else If (fadeLyr1AlignImage = "Center") {	; original image size and aspect
				Gdip_Alt_DrawImage(Fade_G1, fadeLyr1Pic, fadeLyr1PicXNew, fadeLyr1PicYNew, fadeLyr1PicW+1, fadeLyr1PicH+1)
			} Else If (fadeLyr1AlignImage = "Align to Top Right") {	; place the pic so the top right corner matches the screen's top right corner
				Gdip_Alt_DrawImage(Fade_G1, fadeLyr1Pic, fadeLyr1PicXNew, 0,fadeLyr1PicWNew+1,fadeLyr1PicHNew)
			} Else {	; place the pic so the top left corner matches the screen's top left corner, also the default
				Gdip_Alt_DrawImage(Fade_G1, fadeLyr1Pic, 0, 0,fadeLyr1PicWNew+1,fadeLyr1PicHNew+1)
			}
		}
		
		If FileExist(fadeInLyr2File)	; If a layer 2 image exists, let's get its dimensions
		{	fadeLyr2Pic := Gdip_CreateBitmapFromFile(fadeInLyr2File)
			Gdip_GetImageDimensions(fadeLyr2Pic, fadeLyr2PicW, fadeLyr2PicH)
			; find Width and Height
			If (fadeLyr2Pos = "Stretch and Lose Aspect"){
				fadeLyr2PicW := baseScreenWidth
				fadeLyr2PicH := baseScreenHeight
				fadeLyr2PicPadX := 0 , fadeLyr2PicPadY := 0
			} else if (fadeLyr2Pos = "Stretch and Keep Aspect"){	
				widthMaxPercent := ( baseScreenWidth / fadeLyr2PicW )	; get the percentage needed to maximumise the image so it reaches the screen's width
				heightMaxPercent := ( baseScreenHeight / fadeLyr2PicH )
				percentToEnlarge := If (widthMaxPercent < heightMaxPercent) ? widthMaxPercent : heightMaxPercent	; this basicallys says if the width's max reaches the screen's width first, use the width's percentage instead of the height's
				fadeLyr2PicW := Round(fadeLyr2PicW * percentToEnlarge)	
				fadeLyr2PicH := Round(fadeLyr2PicH * percentToEnlarge)	
				fadeLyr2PicPadX := 0 , fadeLyr2PicPadY := 0
			} else {
				fadeLyr2PicW := fadeLyr2PicW * fadeLyr2Adjust
				fadeLyr2PicH := fadeLyr2PicH * fadeLyr2Adjust
			}
			GetFadePicPosition(fadeLyr2PicX,fadeLyr2PicY,fadeLyr2X,fadeLyr2Y,fadeLyr2PicW,fadeLyr2PicH,fadeLyr2Pos)
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
			fadeLyr2CanvasX := fadeLyr2PicX + fadeLyr2PicPadX , fadeLyr2CanvasY := fadeLyr2PicY + fadeLyr2PicPadY
			fadeLyr2CanvasW := fadeLyr2PicW, fadeLyr2CanvasH := fadeLyr2PicH
			pGraphUpd(Fade_G2,fadeLyr2CanvasW,fadeLyr2CanvasH)
			if ((fadeLyr2Pos = "Stretch and Lose Aspect") or (fadeLyr2Pos = "Stretch and Keep Aspect"))
				Gdip_Alt_DrawImage(Fade_G2, fadeLyr2Pic, 0, 0, fadeLyr2PicW, fadeLyr2PicH)
			else
				Gdip_Alt_DrawImage(Fade_G2, fadeLyr2Pic, 0, 0, fadeLyr2PicW, fadeLyr2PicH, 0, 0, fadeLyr2PicW//fadeLyr2Adjust, fadeLyr2PicH//fadeLyr2Adjust)
		}

		%fadeInTransitionAnimation%("in",fadeInDuration)

		fadeInEndTime := A_TickCount + fadeInDelay

		fadeOptionsScale() ; scale fade options to adjust for user resolution
		
		; Create canvas for all remaining fade in screens
		Loop, 6 { 
			OwnerGUI := CurrentGUI - 1
			if (A_Index=1) {
				CurrentGUI := "3Static"   ; creating layer 3 static
			} else if  (A_Index=2) {
				OwnerGUI := "3Static"
				CurrentGUI := A_Index+1   ; creating layer 3
			} else 
				CurrentGUI := A_Index+1   ; creating layer 4 to 7
			Gui, Fade_GUI%CurrentGUI%: +OwnerFade_GUI%OwnerGUI% -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop
			Gui, Fade_GUI%CurrentGUI%: Margin,0,0
            Gui, Fade_GUI%CurrentGUI%: Show,, fadeLayer%CurrentGUI%
            Fade_hwnd%CurrentGUI% := WinExist()
            Fade_hbm%CurrentGUI% := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
            Fade_hdc%CurrentGUI% := CreateCompatibleDC()
            Fade_obm%CurrentGUI% := SelectObject(Fade_hdc%CurrentGUI%, Fade_hbm%CurrentGUI%)
            Fade_G%CurrentGUI% := Gdip_GraphicsFromhdc(Fade_hdc%CurrentGUI%)
            Gdip_SetInterpolationMode(Fade_G%CurrentGUI%, 7)
            Gdip_SetSmoothingMode(Fade_G%CurrentGUI%, 4)
			Gdip_TranslateWorldTransform(Fade_G%CurrentGUI%, xTranslation, yTranslation)
            Gdip_RotateWorldTransform(Fade_G%CurrentGUI%, screenRotationAngle)
        }
		
		If (7zEnabled != "true") or (7zEnabled = "true" && found7z != "true") or (hlmode="fade7z") {
			GoSub, %fadeLyr3Animation%
		}
		Log("FadeInStart - Ended",4)
	}
	; Tacking on these features below so they trigger at the desired positions during launch w/o a need for additional calls in each module
	If (!romTable && mgCandidate)
		SetTimer, CreateMGRomTable, -1

	If (romMappingLaunchMenuEnabled = "true" && romMapLaunchMenuCreated) ; && romMapMultiRomsFound)
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
			Log("FadeInExit - fadeInExitDelay started",4)
			Loop {
				If ((A_TickCount >= fadeInExitDelayEnd) Or fadeInterrupted ) {	; if delay has been met or user cancelled by pressing a fade interrupt key break out and continue
					fadeInterrupted:=	; reset var so we know not to start another sleep
					Break
				}
				Sleep, 100
			}
			Log("FadeInExit - fadeInExitDelay ended",4)
		}
		XHotKeywrapper(exitEmulatorKey,"CloseFadeIn","OFF")
		If fadeInterruptKey = anykey	; if user wants anykey to be able to disrupt fade, use this label
			SetTimer, AnykeyFadeBypass, Off
		Else {
			Hotkey, Esc, CloseFadeIn, Off
			Hotkey, Enter, CloseFadeIn, Off
			XHotKeywrapper(fadeInterruptKey,"CloseFadeIn","OFF")
		}
	
		if (fadeMuteEmulator = "true") and !(hlMode){
			if !emulatorInitialMuteState
				{
				getVolume(emulatorInitialVolume,emulatorVolumeObject) 
				setVolume(0,emulatorVolumeObject) 
				setMute(0,emulatorVolumeObject)
				SetTimer, FadeSmoothVolumeIncrease, 100
			}
		}
		
		fadeInExitComplete := true
		
		%fadeInTransitionAnimation%("out",fadeInDuration)
		
		; Clean up on exit
		Gdip_DeleteBrush(pBrush)
		Loop, 7 {
			Gdip_GraphicsClear(Fade_G%A_Index%)	; clearing canvas for all layers
			UpdateLayeredWindow(Fade_hwnd%A_Index%, Fade_hdc%A_Index%)	; showing cleared canvas
			Gdip_DisposeImage(fadeLyr%A_Index%Pic), SelectObject(Fade_hdc%A_Index%, Fade_obm%A_Index%), DeleteObject(Fade_hbm%A_Index%), DeleteDC(Fade_hdc%A_Index%), Gdip_DeleteGraphics(Fade_G%A_Index%)
			Gui, Fade_GUI%A_Index%: Destroy
		}
		If mgEnabled = true
			XHotKeywrapper(mgKey,"StartMulti","ON")
		If hpEnabled = true
			XHotKeywrapper(hpKey,"TogglePauseMenuStatus","ON")
		XHotKeywrapper(exitEmulatorKey,"CloseProcess","ON")
		Log("FadeInExit - Ended, waiting for user to close launched application",4)
	}
	gameSectionStartTime := A_TickCount
	gameSectionStartHour := A_Now ; These two vars are in StartModule() and here because we need a way of it always being created if the module does not have Fade support. It's more accurate if used here vs starting in StartModule()
	;if bezelPath
	;	Loop, 7 { 
	;		index := a_index + 1
	;		Gui, Bezel_GUI%index%: Show
	;	}
Return

FadeSmoothVolumeIncrease:
	if !smoothVolumeIncreaseStartTime
		smoothVolumeIncreaseStartTime := A_TickCount
	fadeSmoothVolumeIncreasePercentage := ((A_TickCount-smoothVolumeIncreaseStartTime)/fadeInDuration)
	fadeSmoothVolumeIncreasePercentage := (fadeSmoothVolumeIncreasePercentage>=1) ? 1 : fadeSmoothVolumeIncreasePercentage
	if emulatorVolumeObject
		setVolume(Round(emulatorInitialVolume*fadeSmoothVolumeIncreasePercentage,1),emulatorVolumeObject)
	else
		setVolume(Round(emuVolume*fadeSmoothVolumeIncreasePercentage,1),emulatorVolumeObject)
	if (fadeSmoothVolumeIncreasePercentage=1)
		SetTimer, FadeSmoothVolumeIncrease, off
Return

FadeOutStart:
	If fadeOut = true
	{	Log("FadeOutStart - Started",4)
		If !pToken := Gdip_Startup()	; Start gdi+
			ScriptError("Gdiplus failed to start. Please ensure you have gdiplus on your system")
		if (fadeMuteEmulator = "true") and !(hlMode)
			if !emulatorInitialMuteState
				setMute(1,emulatorVolumeObject)
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

		lyr1OutFile := GetFadePicFile("Layer -1")
		; lyr1OutFile := GetFadePicFile("Layer",-2)	; support for 2nd image on fadeOut

		IfExist, % lyr1OutFile
		{	lyr1OutPic := Gdip_CreateBitmapFromFile(lyr1OutFile)
			Gdip_GetImageDimensions(lyr1OutPic, lyr1OutPicW, lyr1OutPicH)	; get the width and height of the background image
		}		
		;Acquiring screen info for dealing with rotated menu drawings
		if !(If fadeIn = true)
			{
			Gdip_Alt_GetRotatedDimensions(A_ScreenWidth, A_ScreenHeight, screenRotationAngle, baseScreenWidth, baseScreenHeight)
			Gdip_GetRotatedTranslation(baseScreenWidth, baseScreenHeight, screenRotationAngle, xTranslation, yTranslation)
			xTranslation:=round(xTranslation), yTranslation:=round(yTranslation)
		}		
		FadeOut_hbm1 := CreateDIBSection(A_ScreenWidth, A_ScreenHeight), FadeOut_hdc1 := CreateCompatibleDC(), FadeOut_obm1 := SelectObject(FadeOut_hdc1, FadeOut_hbm1)	; might have to use the original width / height from before the emu launched if  the screen res changed
		FadeOut_G1 := Gdip_GraphicsFromhdc(FadeOut_hdc1), Gdip_SetInterpolationMode(FadeOut_G1, 7) ;, Gdip_SetSmoothingMode(FadeOut_G1, 4)
		Gui, FadeOut_GUI1: New, +HwndFadeOut_hwnd1 +E0x80000 +ToolWindow -Caption +AlwaysOnTop +OwnDialogs, FadeOut Layer 1	; E0x80000 required for UpdateLayeredWindow to work. Is always on top, has no taskbar entry, no caption, and msgboxes will appear on top of the GUI
		Gdip_TranslateWorldTransform(FadeOut_G1, xTranslation, yTranslation)
		Gdip_RotateWorldTransform(FadeOut_G1, screenRotationAngle)
		fadeOutLyr1CanvasX := 0 , fadeOutLyr1CanvasY := 0
		fadeOutLyr1CanvasW := baseScreenWidth, fadeOutLyr1CanvasH := baseScreenHeight
		pGraphUpd(FadeOut_G1,fadeOutLyr1CanvasW,fadeOutLyr1CanvasH)
		; Draw Layer 1 (Background image and color)
		pBrush := Gdip_BrushCreateSolid("0x" . fadeLyr1Color)	; Painting the background color
		Gdip_Alt_FillRectangle(FadeOut_G1, pBrush, -1, -1, baseScreenWidth+3, baseScreenHeight+3)	; draw the background first on layer 1, layer order matters!!
		If lyr1OutFile {
			GetBGPicPosition(fadeLyr1OutPicXNew,fadeLyr1OutPicYNew,fadeLyr1OutPicWNew,fadeLyr1OutPicHNew,lyr1OutPicW,lyr1OutPicH,fadeLyr1AlignImage)	; get the background pic's new position and size
			If (fadeLyr1AlignImage = "Stretch and Lose Aspect") {	; 
				Gdip_Alt_DrawImage(FadeOut_G1, lyr1OutPic, 0, 0, baseScreenWidth+3, baseScreenHeight+3, 0, 0, lyr1OutPicW, lyr1OutPicH)	; adding a few pixels to avoid showing background on some pcs
			} Else If (fadeLyr1AlignImage = "Stretch and Keep Aspect" Or fadeLyr1AlignImage = "Center Width" Or fadeLyr1AlignImage = "Center Height" Or fadeLyr1AlignImage = "Align to Bottom Left" Or fadeLyr1AlignImage = "Align to Bottom Right") {
				Gdip_Alt_DrawImage(FadeOut_G1, lyr1OutPic, fadeLyr1OutPicXNew, fadeLyr1OutPicYNew, fadeLyr1OutPicWNew+1, fadeLyr1OutPicHNew+1, 0, 0, lyr1OutPicW, lyr1OutPicH)
			} Else If (fadeLyr1AlignImage = "Center") {	; original image size and aspect
				Gdip_Alt_DrawImage(FadeOut_G1, lyr1OutPic, fadeLyr1OutPicXNew, fadeLyr1OutPicYNew, lyr1OutPicW+1, lyr1OutPicH+1, 0, 0, lyr1OutPicW, lyr1OutPicH)
			} Else If (fadeLyr1AlignImage = "Align to Top Right") {	; place the pic so the top right corner matches the screen's top right corner
				Gdip_Alt_DrawImage(FadeOut_G1, lyr1OutPic, fadeLyr1OutPicXNew, 0,fadeLyr1OutPicWNew+1,fadeLyr1OutPicHNew+1, 0, 0, lyr1OutPicW, lyr1OutPicH)
			} Else {	; place the pic so the top left corner matches the screen's top left corner, also the default
				Gdip_Alt_DrawImage(FadeOut_G1, lyr1OutPic, 0, 0,fadeLyr1OutPicWNew+1,fadeLyr1OutPicHNew+1, 0, 0, lyr1OutPicW, lyr1OutPicH)
			}
		}
		;Alt_UpdateLayeredWindow(FadeOut_hwnd1, FadeOut_hdc1, fadeOutLyr1CanvasX,fadeOutLyr1CanvasY,fadeOutLyr1CanvasW,fadeOutLyr1CanvasH)

		If fadeOutExtraScreen = true	; if user wants to use a temporary extra gui layer for this system right before fadeOut starts
		{	Log("FadeOutStart - Creating temporary FadeOutExtraScreen",4)
			Gosub, FadeOutExtraScreen
		}
		Gui FadeOut_GUI1: Show	; show layer -1 GUI
		%fadeOutTransitionAnimation%("in",fadeOutDuration)

		fadeOutEndTime := A_TickCount + fadeOutDelay
		Log("FadeOutStart - Ended",4)
	}
	HideEmuStart()	; global support for hiding emus on exit
Return

FadeOutExtraScreen:
	StringTrimLeft,fadeLyr1ColorNoAlpha,fadeLyr1Color,2	; for legacy gui, we need to trim the alpha from the color as it's not supported
	Gui, FadeOutExtraScreen: New, +HwndFadeOutExtraScreen_ID +ToolWindow -Caption +AlwaysOnTop +OwnDialogs, FadeOutExtraScreen	; Is always on top, has no taskbar entry, no caption, and msgboxes will appear on top of the GUI
	Gui, FadeOutExtraScreen:Color, %fadeLyr1ColorNoAlpha%
	Gui, FadeOutExtraScreen:Show, x0 y0 h%A_ScreenHeight% w%A_ScreenWidth% Hide
	AnimateWindow(FadeOutExtraScreen_ID, "in", "fade", 50) ; animate FadeOutExtraScreen in quickly
Return

FadeOutExit:
	StopGlobalUserFeatures%zz%()	; stoping global user functions here so they are closed before fade screen exits
	If fadeOut = true
	{	Log("FadeOutExit - Started",4)
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
		
		if (fadeMuteEmulator = "true") and !(hlMode)
			if !emulatorInitialMuteState
				setMute(0,emulatorVolumeObject)
		
		; Clean up on exit
		Gdip_DeleteBrush(pBrush)
		Gdip_DisposeImage(lyr1OutPic), SelectObject(FadeOut_hdc1, FadeOut_obm1), DeleteObject(FadeOut_hbm1), DeleteDC(FadeOut_hdc1), Gdip_DeleteGraphics(FadeOut_G1)
		Gui, FadeOut_GUI1: Destroy
		if GifAnimation
			{
			AniGif_DestroyControl(hAniGif1)
			Gui, Fade_GifAnim_GUI: Destroy
		}
		
		Log("FadeOutExit - Ended",4)
	}
	HideEmuEnd()
Return

FadeInDelay:
	Log("FadeInDelay - Started",4)
	While fadeInActive && (fadeInEndTime > A_TickCount) {
		Sleep, 100
		Continue
	}
	Log("FadeInDelay - Ended",4)
Return

FadeLayer4Anim:
	if GifAnimation
		{
		fadeLyr4PicX := round(fadeLyr4PicX)+0 , fadeLyr4PicY := round(fadeLyr4PicY)+0 , fadeLyr4PicW := round(fadeLyr4PicW)+0 , fadeLyr4PicH := round(fadeLyr4PicH)+0 
		AniGif_LoadGifFromFile(hAniGif1, GifAnimation)
		AniGif_SetBkColor(hAniGif1, fadeTranspGifColor)
		Gui, Fade_GifAnim_GUI: Show, x%fadeLyr4PicX% y%fadeLyr4PicY% w%fadeLyr4PicW% h%fadeLyr4PicH%	
	} else {
		Gdip_GraphicsClear(Fade_G4)
		currentFadeLyr4Image++
		If (currentFadeLyr4Image>FadeLayer4AnimTotal)
			currentFadeLyr4Image=1
		Gdip_Alt_DrawImage(Fade_G4, FadeLayer4Anim%currentFadeLyr4Image%Pic, 0, 0, fadeLyr4PicW, fadeLyr4PicH)
		Alt_UpdateLayeredWindow(Fade_hwnd4, Fade_hdc4, fadeLyr4CanvasX,fadeLyr4CanvasY,fadeLyr4CanvasW,fadeLyr4CanvasH)
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


GetFadePicFile(name,useBkgdPath=false){
	Global fadeImgPath,dbName,systemName, HLMediaPath, feMedia
	fadePicPath1 := fadeImgPath . "\" . systemName . "\" . dbName . "\" . name	; rom file
	fadePicPath2 := fadeImgPath . "\" . systemName . "\_Default\" . name	; system file
	fadePicPath3 := fadeImgPath . "\_Default\" . name	; global file
	bkgdPicPath1 := HLMediaPath . "\Backgrounds\" . systemName . "\" . dbName . "\"	; rom file
	bkgdPicPath2 := HLMediaPath . "\Backgrounds\" . systemName . "\_Default\"	; system file
	bkgdPicPath3 := HLMediaPath . "\Backgrounds\_Default\"	; global file
	fadePicList := []	; initialize array
	loop, 3 {
		If !fadePicList[1]
			fadePicList := GetFadeDirPicFile(name,fadePicPath%a_index%) 
		If ((useBkgdPath) and (!(fadePicList[1]))){
			fadePicList := GetFadeDirPicFile(name,bkgdPicPath%a_index%) 
			If (!(fadePicList[1]))
			{	if (a_index=1)
					currentAssetType := "game"
				else if (a_index=2)
					currentAssetType := "system"
				if ((a_index=1) or (a_index=2))
				{	for index, element in feMedia["Backgrounds"]
					{   if element.Label
						{   if (element.AssetType=currentAssetType)
							{   loop, % element.TotalItems    
								{    fadePicList.Insert(element["Path" . a_index])
								}
							}
						}
					}
				}
			}
		}
	}	
	If fadePicList[1]	; if we filled anything in the array, stop here, randomize pics found	, and return
	{	Random, RndmfadePic, 1, % fadePicList.MaxIndex()
		file := fadePicList[RndmfadePic]
		Log("GetFadePicFile - Randomized images and Fade " . name . " will use " . file)
		Return file
	}
}

GetFadeDirPicFile(name,path){
	Log("GetFadePicFile - Checking if any Fade " . name . " images exist in: " . path . "*.*",4)
	fadePicType = png|gif|tif|bmp|jpg
	fadePicList := []
	If (FileExist(path . "*.*")) {
		Loop, Parse, fadePicType,|
		{	Log("GetFadePicFile - Looking for Fade " . name . " pic: " . path . "*." . A_LoopField,4)
			Loop, % path . "*." . A_LoopField
			{	Log("GetFadePicFile - Found Fade " . name . " pic: " . A_LoopFileFullPath,4)
				fadePicList.Insert(A_LoopFileFullPath)
			}
		}
	}
	Return fadePicList
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


fadeOptionsScale(){
	global
	OptionScale(fadeLyr3StaticX, fadeXScale)
	OptionScale(fadeLyr3StaticY, fadeYScale)
	OptionScale(fadeLyr3StaticPicPad, fadeXScale) ;could be Y also
	OptionScale(fadeLyr3X, fadeXScale)
	OptionScale(fadeLyr3Y, fadeYScale)
	OptionScale(fadeLyr3PicPad, fadeXScale) ;could be Y also
	OptionScale(fadeLyr4X, fadeXScale)
	OptionScale(fadeLyr4Y, fadeYScale)
	OptionScale(fadeLyr4PicPad, fadeXScale)
	OptionScale(fadeBarWindowX, fadeXScale) ;could be Y also
	OptionScale(fadeBarWindowY, fadeYScale)
	OptionScale(fadeBarWindowW, fadeXScale)
	OptionScale(fadeBarWindowH, fadeYScale)
	OptionScale(fadeBarWindowR, fadeXScale) ;could be Y also
	OptionScale(fadeBarWindowM, fadeXScale) ;could be Y also
	OptionScale(fadeBarH, fadeYScale)
	OptionScale(fadeBarR, fadeXScale) ;could be Y also
	OptionScale(fadeBarXOffset, fadeXScale)
	OptionScale(fadeBarYOffset, fadeYScale)
	OptionScale(fadeRomInfoTextMargin, fadeXScale)
	TextOptionScale(fadeRomInfoText1Options,fadeXScale, fadeYScale)
	TextOptionScale(fadeRomInfoText2Options,fadeXScale, fadeYScale)
	TextOptionScale(fadeRomInfoText3Options,fadeXScale, fadeYScale)
	TextOptionScale(fadeRomInfoText4Options,fadeXScale, fadeYScale)
	TextOptionScale(fadeRomInfoText5Options,fadeXScale, fadeYScale)
	TextOptionScale(fadeRomInfoText6Options,fadeXScale, fadeYScale)
	OptionScale(fadeStatsInfoTextMargin, fadeXScale) ;could be Y also
	TextOptionScale(fadeStatsInfoText1Options,fadeXScale, fadeYScale)
	TextOptionScale(fadeStatsInfoText2Options,fadeXScale, fadeYScale)
	TextOptionScale(fadeStatsInfoText3Options,fadeXScale, fadeYScale)
	TextOptionScale(fadeStatsInfoText4Options,fadeXScale, fadeYScale)
	TextOptionScale(fadeStatsInfoText5Options,fadeXScale, fadeYScale)
	TextOptionScale(fadeStatsInfoText6Options,fadeXScale, fadeYScale)
	OptionScale(fadeText1X, fadeXScale)
	OptionScale(fadeText1Y, fadeYScale)
	TextOptionScale(fadeText1Options,fadeXScale, fadeYScale)
	OptionScale(fadeText2X, fadeXScale)
	OptionScale(fadeText2Y, fadeYScale)
	TextOptionScale(fadeText2Options,fadeXScale, fadeYScale)
	OptionScale(fadeExtractionTimeTextX, fadeXScale)
	OptionScale(fadeExtractionTimeTextY, fadeYScale)
	TextOptionScale(fadeExtractionTimeTextOptions,fadeXScale, fadeYScale)
Return	
}
