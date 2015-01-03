MCRC=80467078
MVersion=1.0.7

; Default transition animation used for Fade_In
DefaultAnimateFadeIn(direction,time){
	Global Fade_hwnd1,Fade_hdc1,fadeLyr1CanvasX,fadeLyr1CanvasY,fadeLyr1CanvasW,fadeLyr1CanvasH
	Global Fade_hwnd2,Fade_hdc2,fadeLyr2CanvasX,fadeLyr2CanvasY,fadeLyr2CanvasW,fadeLyr2CanvasH
	Global Fade_hwnd3Static,Fade_hdc3Static,fadeLyr3StaticCanvasX,fadeLyr3StaticCanvasY,fadeLyr3StaticCanvasW,fadeLyr3StaticCanvasH
	Global Fade_hwnd3,Fade_hdc3,fadeLyr3CanvasX,fadeLyr3CanvasY,fadeLyr3CanvasW,fadeLyr3CanvasH
	Global Fade_hwnd4,Fade_hdc4,fadeLyr4CanvasX,fadeLyr4CanvasY,fadeLyr4CanvasW,fadeLyr4CanvasH,FadeLayer4AnimFilesAr
	Global Fade_hwnd5,Fade_hdc5,fadeLyr5CanvasX,fadeLyr5CanvasY,fadeLyr5CanvasW,fadeLyr5CanvasH
	Global Fade_hwnd6,Fade_hdc6,fadeLyr6CanvasX,fadeLyr6CanvasY,fadeLyr6CanvasW,fadeLyr6CanvasH
	Global Fade_hwnd7,Fade_hdc7,fadeLyr7CanvasX,fadeLyr7CanvasY,fadeLyr7CanvasW,fadeLyr7CanvasH
	Log("DefaultAnimateFadeIn - Started")
	startTime := A_TickCount
	If direction = in
	Log("DefaultAnimateFadeIn - Drawing First FadeIn Image.", 1)
	Loop{
		t := ((TimeElapsed := A_TickCount-startTime) < time) ? (If direction="in" ? 255*(timeElapsed/time) : 255*(1-(timeElapsed/time))) : (If direction="in" ? 255 : 0)
		if fadeLyr1CanvasW
			Alt_UpdateLayeredWindow(Fade_hwnd1, Fade_hdc1, fadeLyr1CanvasX, fadeLyr1CanvasY, fadeLyr1CanvasW, fadeLyr1CanvasH, t)	; to fade in, set transparency to 0 at first
		if fadeLyr2CanvasW
			Alt_UpdateLayeredWindow(Fade_hwnd2,Fade_hdc2,fadeLyr2CanvasX,fadeLyr2CanvasY,fadeLyr2CanvasW,fadeLyr2CanvasH, t)
		If direction = out
		{
			if fadeLyr3StaticCanvasW
				Alt_UpdateLayeredWindow(Fade_hwnd3Static, Fade_hdc3Static,fadeLyr3StaticCanvasX,fadeLyr3StaticCanvasY, fadeLyr3StaticCanvasW, fadeLyr3StaticCanvasH, t)
			if fadeLyr3CanvasW
				Alt_UpdateLayeredWindow(Fade_hwnd3, Fade_hdc3,fadeLyr3CanvasX,fadeLyr3CanvasY, fadeLyr3CanvasW, fadeLyr3CanvasH, t)
			if fadeLyr5CanvasW
				Alt_UpdateLayeredWindow(Fade_hwnd5, Fade_hdc5,fadeLyr5CanvasX,fadeLyr5CanvasY, fadeLyr5CanvasW, fadeLyr5CanvasH, t)
			if fadeLyr6CanvasW
				Alt_UpdateLayeredWindow(Fade_hwnd6, Fade_hdc6,fadeLyr6CanvasX,fadeLyr6CanvasY, fadeLyr6CanvasW, fadeLyr6CanvasH, t)
			if fadeLyr7CanvasW
				Alt_UpdateLayeredWindow(Fade_hwnd7, Fade_hdc7,fadeLyr7CanvasX,fadeLyr7CanvasY, fadeLyr7CanvasW, fadeLyr7CanvasH, t)
			If FadeLayer4AnimFilesAr.MaxIndex() > 0 {
				SetTimer, FadeLayer4Anim, Off 
				Alt_UpdateLayeredWindow(Fade_hwnd4, Fade_hdc4,fadeLyr4CanvasX,fadeLyr4CanvasY, fadeLyr4CanvasW, fadeLyr4CanvasH, t)
			}
		}
		If (direction = "in" && t >= 255) or (direction = "out" && t <= 0)
			Break
	}
	Log("DefaultAnimateFadeIn - Ended")
}

; Default transition animation used for Fade_Out
DefaultAnimateFadeOut(direction,time){
	Global FadeOut_hwnd1, FadeOut_hdc1, fadeOutLyr1CanvasX,fadeOutLyr1CanvasY,fadeOutLyr1CanvasW,fadeOutLyr1CanvasH
	Global fadeOutExtraScreen,FadeOutExtraScreen_ID
	Log("DefaultAnimateFadeOut - Started")
	If fadeOutExtraScreen = true
	{	Log("DefaultAnimateFadeOut - Destroying FadeOutBlackScreen",4)
		AnimateWindow(FadeOutExtraScreen_ID, "out", "fade", 100) ; animate FadeOutBlackScreen out quickly
		Gui, FadeOutExtraScreen:Destroy	; destroy the temporary FadeOutBlackScreen
	}
	startTime := A_TickCount
	Loop{
		t := ((TimeElapsed := A_TickCount-startTime) < time) ? (If direction="in" ? 255*(timeElapsed/time) : 255*(1-(timeElapsed/time))) : (If direction="in" ? 255 : 0)
		Alt_UpdateLayeredWindow(FadeOut_hwnd1, FadeOut_hdc1, fadeOutLyr1CanvasX,fadeOutLyr1CanvasY,fadeOutLyr1CanvasW,fadeOutLyr1CanvasH, t)	; to fade in, set transparency to 0 at first
		If (direction = "in" && t >= 255) or (direction = "out" && t <= 0)
			Break
	}
	Log("DefaultAnimateFadeOut - Ended")
}

; Legacy fadein animation for use when gdi does not work with an emulator. Jpgs are not supported and will not show on this legacy gui
LegacyFadeInTransition(direction,time){
	Global Fade_hwnd1,Fade_hdc1,Fade_G1,fadeLyr1CanvasX,fadeLyr1CanvasY,fadeLyr1CanvasW,fadeLyr1CanvasH
	Global Fade_hwnd2,Fade_hdc2,fadeLyr2CanvasX,fadeLyr2CanvasY,fadeLyr2CanvasW,fadeLyr2CanvasH
	Global Fade_hwnd3Static,Fade_hdc3Static,fadeLyr3StaticCanvasX,fadeLyr3StaticCanvasY,fadeLyr3StaticCanvasW,fadeLyr3StaticCanvasH
	Global Fade_hwnd3,Fade_hdc3,fadeLyr3CanvasX,fadeLyr3CanvasY,fadeLyr3CanvasW,fadeLyr3CanvasH
	Global Fade_hwnd4,Fade_hdc4,fadeLyr4CanvasX,fadeLyr4CanvasY,fadeLyr4CanvasW,fadeLyr4CanvasH
	Global Fade_hwnd5,Fade_hdc5,fadeLyr5CanvasX,fadeLyr5CanvasY,fadeLyr5CanvasW,fadeLyr5CanvasH
	Global Fade_hwnd6,Fade_hdc6,fadeLyr6CanvasX,fadeLyr6CanvasY,fadeLyr6CanvasW,fadeLyr6CanvasH
	Global Fade_hwnd7,Fade_hdc7,fadeLyr7CanvasX,fadeLyr7CanvasY,fadeLyr7CanvasW,fadeLyr7CanvasH
	Global fadeLyr1PicW,fadeLyr1PicH,fadeInLyr1File,fadeLyr1Color,fadeLyr1AlignImage
	Log("LegacyFadeInTransition - Started")
	StringTrimLeft,fadeLyr1ColorNoAlpha,fadeLyr1Color,2	; for legacy gui, we need to trim the alpha from the color as it's not supported
	
	If direction = in
	{	Log("LegacyFadeInTransition - Drawing First FadeIn Image.", 1)
		Gui, Fade_GUI1:Color, %fadeLyr1ColorNoAlpha%
		GetBGPicPosition(fadeLyr1PicXNew,fadeLyr1PicYNew,fadeLyr1PicWNew,fadeLyr1PicHNew,fadeLyr1PicW,fadeLyr1PicH,fadeLyr1AlignImage)	; get the background pic's new position and size
		If (fadeLyr1AlignImage = "Stretch and Lose Aspect")
			Gui, Fade_GUI1:Add, Picture,w%baseScreenWidth% h%baseScreenHeight% x0 y0, %fadeInLyr1File%
		Else If (fadeLyr1AlignImage = "Stretch and Keep Aspect" Or fadeLyr1AlignImage = "Center Width" Or fadeLyr1AlignImage = "Center Height" Or fadeLyr1AlignImage = "Align to Bottom Left" Or fadeLyr1AlignImage = "Align to Bottom Right")
			Gui, Fade_GUI1:Add, Picture,w%fadeLyr1PicWNew% h%fadeLyr1PicHNew% x%fadeLyr1PicXNew% y%fadeLyr1PicYNew%, %fadeInLyr1File%
		Else If (fadeLyr1AlignImage = "Center")	; original image size and aspect
			Gui, Fade_GUI1:Add, Picture,w%fadeLyr1PicW% h%fadeLyr1PicH% x%fadeLyr1PicXNew% y%fadeLyr1PicYNew%, %fadeInLyr1File%
		Else If (fadeLyr1AlignImage = "Align to Top Right")	; place the pic so the top right corner matches the screen's top right corner
			Gui, Fade_GUI1:Add, Picture,w%fadeLyr1PicWNew% h%fadeLyr1PicHNew% x%fadeLyr1PicXNew% y0, %fadeInLyr1File%
		Else	; place the pic so the top left corner matches the screen's top left corner, also the default
			Gui, Fade_GUI1:Add, Picture,w%fadeLyr1PicWNew% h%fadeLyr1PicHNew% x0 y0, %fadeInLyr1File%
		Gui, Fade_GUI1:Show, x0 y0 h%baseScreenHeight% w%baseScreenWidth% Hide
	}
	If direction = out
	{	SetTimer, FadeLayer4Anim, Off
		Gdip_GraphicsClear(Fade_G2)
		Gdip_GraphicsClear(Fade_G3Static)
		Gdip_GraphicsClear(Fade_G3)
		Gdip_GraphicsClear(Fade_G4)
		Gdip_GraphicsClear(Fade_G5)
		Gdip_GraphicsClear(Fade_G6)
		Gdip_GraphicsClear(Fade_G7)
		Alt_UpdateLayeredWindow(Fade_hwnd2, Fade_hdc2, fadeLyr2CanvasX, fadeLyr2CanvasY, fadeLyr2CanvasW, fadeLyr2CanvasH)
		Alt_UpdateLayeredWindow(Fade_hwnd3Static, Fade_hdc3Static,fadeLyr3StaticCanvasX,fadeLyr3StaticCanvasY, fadeLyr3StaticCanvasW, fadeLyr3StaticCanvasH)
		Alt_UpdateLayeredWindow(Fade_hwnd3, Fade_hdc3, fadeLyr3CanvasX, fadeLyr3CanvasY, fadeLyr3CanvasW, fadeLyr3CanvasH)
		Alt_UpdateLayeredWindow(Fade_hwnd4, Fade_hdc4, fadeLyr4CanvasX, fadeLyr4CanvasY, fadeLyr4CanvasW, fadeLyr4CanvasH)
		Alt_UpdateLayeredWindow(Fade_hwnd5, Fade_hdc5, fadeLyr5CanvasX, fadeLyr5CanvasY, fadeLyr5CanvasW, fadeLyr5CanvasH)
		Alt_UpdateLayeredWindow(Fade_hwnd6, Fade_hdc6, fadeLyr6CanvasX, fadeLyr6CanvasY, fadeLyr6CanvasW, fadeLyr6CanvasH)
		Alt_UpdateLayeredWindow(Fade_hwnd7, Fade_hdc7, fadeLyr7CanvasX, fadeLyr7CanvasY, fadeLyr7CanvasW, fadeLyr7CanvasH)
	}		
	AnimateWindow(Fade_hwnd1, direction, "fade", time) ; animate in fadeLayer1
	If direction = in
		Alt_UpdateLayeredWindow(Fade_hwnd2, Fade_hdc2, fadeLyr2CanvasX, fadeLyr2CanvasY, fadeLyr2CanvasW, fadeLyr2CanvasH)
	; AnimateWindow(1_ID, direction, "slide bt", time) ; slide
	Log("LegacyFadeInTransition - Ended")
}

; Legacy fadeout animation for use when gdi does not work with an emulator. Jpgs are not supported and will not show on this legacy gui
LegacyFadeOutTransition(direction,time){
	Global FadeOut_hwnd1, FadeOut_hdc1, fadeOutLyr1CanvasX,fadeOutLyr1CanvasY,fadeOutLyr1CanvasW,fadeOutLyr1CanvasH
	Global fadeOutExtraScreen,FadeOutExtraScreen_ID
	Global lyr1OutPicW,lyr1OutPicH,lyr1OutFile,fadeLyr1Color,fadeLyr1AlignImage
	;,fadeOutBlackScreenEnabled,FadeOutBlackScreen_ID
	Log("LegacyFadeOutTransition - Started")
	StringTrimLeft,fadeLyr1ColorNoAlpha,fadeLyr1Color,2	; for legacy gui, we need to trim the alpha from the color as it's not supported
	If direction = in
	{
		Gui, FadeOut_GUI1:Color, %fadeLyr1ColorNoAlpha%
		GetBGPicPosition(fadeLyr1OutPicXNew,fadeLyr1OutPicYNew,fadeLyr1OutPicWNew,fadeLyr1OutPicHNew,lyr1OutPicW,lyr1OutPicH,fadeLyr1AlignImage)	; get the background pic's new position and size
		If (fadeLyr1AlignImage = "Stretch and Lose Aspect")
			Gui, FadeOut_GUI1:Add, Picture,w%baseScreenWidth% h%baseScreenHeight% x0 y0, %lyr1OutFile%
		Else If (fadeLyr1AlignImage = "Stretch and Keep Aspect" Or fadeLyr1AlignImage = "Center Width" Or fadeLyr1AlignImage = "Center Height" Or fadeLyr1AlignImage = "Align to Bottom Left" Or fadeLyr1AlignImage = "Align to Bottom Right")
			Gui, FadeOut_GUI1:Add, Picture,w%fadeLyr1OutPicWNew% h%fadeLyr1OutPicHNew% x%fadeLyr1OutPicXNew% y%fadeLyr1OutPicYNew%, %lyr1OutFile%
		Else If (fadeLyr1AlignImage = "Center")	; original image size and aspect
			Gui, FadeOut_GUI1:Add, Picture,w%lyr1OutPicW% h%lyr1OutPicH% x%fadeLyr1OutPicXNew% y%fadeLyr1OutPicYNew%, %lyr1OutFile%
		Else If (fadeLyr1AlignImage = "Align to Top Right")	; place the pic so the top right corner matches the screen's top right corner
			Gui, FadeOut_GUI1:Add, Picture,w%fadeLyr1OutPicWNew% h%fadeLyr1OutPicHNew% x%fadeLyr1OutPicXNew% y0, %lyr1OutFile%
		Else	; place the pic so the top left corner matches the screen's top left corner, also the default
			Gui, FadeOut_GUI1:Add, Picture,w%fadeLyr1OutPicWNew% h%fadeLyr1OutPicHNew% x0 y0, %lyr1OutFile%
		Gui, FadeOut_GUI1:Show, x0 y0 h%baseScreenHeight% w%baseScreenWidth% Hide
	}
	If fadeOutExtraScreen = true
	{	Log("LegacyFadeOutTransition - Destroying FadeOutBlackScreen",4)
		AnimateWindow(FadeOutExtraScreen_ID, "out", "fade", 100) ; animate FadeOutBlackScreen out quickly
		Gui, FadeOutExtraScreen:Destroy	; destroy the temporary FadeOutBlackScreen
	}
	AnimateWindow(FadeOut_hwnd1, direction, "fade", time) ; animate in fadeLayer1
	; AnimateWindow(out1_ID, direction, "slide bt", time) ; slide
	Log("LegacyFadeOutTransition - Ended")
}

; Bleasby's DefaultFadeAnimation included in HL - you can use it on both layer 3 animation and layer 3 7z animation
DefaultFadeAnimation:
	;SetTimer, DetectFadeError, Off
	Log("DefaultFadeAnimation - Started")
	;====== Begin of menu code
	fadeInActive=1	; As long as user did not press a key to exit fade, this var will be filled and fade will do its full animation	
	;====== Loading info about layer 3 image
	if fadeLyr3StaticPrefix
		fadeInLyr3StaticFile := GetFadePicFile(fadeLyr3StaticPrefix)
	If FileExist(fadeInLyr3StaticFile)	; If a layer 3 static image exists, let's get its dimensions
	{	fadeLyr3StaticPic := Gdip_CreateBitmapFromFile(fadeInLyr3StaticFile)
		Gdip_GetImageDimensions(fadeLyr3StaticPic, fadeLyr3StaticPicW, fadeLyr3StaticPicH)
		; find Width and Height
		If (fadeLyr3StaticPos = "Stretch and Lose Aspect"){
			fadeLyr3StaticPicW := baseScreenWidth
			fadeLyr3StaticPicH := baseScreenHeight
			fadeLyr3StaticPicPadX := 0 , fadeLyr3StaticPicPadY := 0
		} else if (fadeLyr3StaticPos = "Stretch and Keep Aspect"){	
			widthMaxPercent := ( baseScreenWidth / fadeLyr3StaticPicW )	; get the percentage needed to maximumise the image so it reaches the screen's width
			heightMaxPercent := ( baseScreenHeight / fadeLyr3StaticPicH )
			percentToEnlarge := If (widthMaxPercent < heightMaxPercent) ? widthMaxPercent : heightMaxPercent	; this basicallys says if the width's max reaches the screen's width first, use the width's percentage instead of the height's
			fadeLyr3StaticPicW := Round(fadeLyr3StaticPicW * percentToEnlarge)	
			fadeLyr3StaticPicH := Round(fadeLyr3StaticPicH * percentToEnlarge)	
			fadeLyr3StaticPicPadX := 0 , fadeLyr3StaticPicPadY := 0
		} else {
			fadeLyr3StaticPicW := fadeLyr3StaticPicW * fadeLyr3StaticAdjust
			fadeLyr3StaticPicH := fadeLyr3StaticPicH * fadeLyr3StaticAdjust
		}
		GetFadePicPosition(fadeLyr3StaticPicX,fadeLyr3StaticPicY,fadeLyr3StaticX,fadeLyr3StaticY,fadeLyr3StaticPicW,fadeLyr3StaticPicH,fadeLyr3StaticPos)
		; figure out what quadrant the layer 3 Static image is in, so we know to apply a + or - pad value so the user does not have to
		If fadeLyr3StaticPos in No Alignment,Center,Top Left Corner
			fadeLyr3StaticPicPadX:=fadeLyr3StaticPicPad, fadeLyr3StaticPicPadY:=fadeLyr3StaticPicPad
		Else If fadeLyr3StaticPos = Top Center
			fadeLyr3StaticPicPadX:=0, fadeLyr3StaticPicPadY:=fadeLyr3StaticPicPad
		Else If fadeLyr3StaticPos = Left Center
			fadeLyr3StaticPicPadX:=fadeLyr3StaticPicPad, fadeLyr3StaticPicPadY:=0
		Else If fadeLyr3StaticPos = Top Right Corner
			fadeLyr3StaticPicPadX:=fadeLyr3StaticPicPad*-1, fadeLyr3StaticPicPadY:=fadeLyr3StaticPicPad
		Else If fadeLyr3StaticPos = Right Center
			fadeLyr3StaticPicPadX:=fadeLyr3StaticPicPad*-1, fadeLyr3StaticPicPadY:=0
		Else If fadeLyr3StaticPos = Bottom Left Corner
			fadeLyr3StaticPicPadX:=fadeLyr3StaticPicPad, fadeLyr3StaticPicPadY:=fadeLyr3StaticPicPad*-1
		Else If fadeLyr3StaticPos = Bottom Center
			fadeLyr3StaticPicPadX:=0, fadeLyr3StaticPicPadY:=fadeLyr3StaticPicPad*-1
		Else If fadeLyr3StaticPos = Bottom Right Corner
			fadeLyr3StaticPicPadX:=fadeLyr3StaticPicPad*-1, fadeLyr3StaticPicPadY:=fadeLyr3StaticPicPad*-1
		fadeLyr3StaticCanvasX := fadeLyr3StaticPicX + fadeLyr3StaticPicPadX , fadeLyr3StaticCanvasY := fadeLyr3StaticPicY + fadeLyr3StaticPicPadY
		fadeLyr3StaticCanvasW := fadeLyr3StaticPicW, fadeLyr3StaticCanvasH := fadeLyr3StaticPicH
		pGraphUpd(Fade_G3Static,fadeLyr3StaticCanvasW,fadeLyr3StaticCanvasH)
		if ((fadeLyr3StaticPos = "Stretch and Lose Aspect") or (fadeLyr3StaticPos = "Stretch and Keep Aspect"))
			Gdip_Alt_DrawImage(Fade_G3Static, fadeLyr3StaticPic, 0, 0, fadeLyr3StaticPicW, fadeLyr3StaticPicH)
		else
			Gdip_Alt_DrawImage(Fade_G3Static, fadeLyr3StaticPic, 0, 0, fadeLyr3StaticPicW, fadeLyr3StaticPicH, 0, 0, fadeLyr3StaticPicW//fadeLyr3StaticAdjust, fadeLyr3StaticPicH//fadeLyr3StaticAdjust)
	}
	;====== Loading info about layer 3 image
	fadeInLyr3File := GetFadePicFile("Layer 3")
	IfExist, % fadeInLyr3File
		{
		fadeLyr3Pic := Gdip_CreateBitmapFromFile(fadeInLyr3File)
		Gdip_GetImageDimensions(fadeLyr3Pic, fadeLyr3PicW, fadeLyr3PicH)
		fadeLyr3PicW := fadeLyr3PicW * fadeLyr3Adjust
		fadeLyr3PicH := fadeLyr3PicH * fadeLyr3Adjust
		GetFadePicPosition(fadeLyr3PicX,fadeLyr3PicY,fadeLyr3X,fadeLyr3Y,fadeLyr3PicW,fadeLyr3PicH,fadeLyr3Pos)
	}
	;Layer 3 padding
	If fadeLyr3PicX < baseScreenWidth//2
		fadeLyr3PicX := fadeLyr3PicX+fadeLyr3PicPad
	Else 
		fadeLyr3PicX := fadeLyr3PicX-fadeLyr3PicPad
	If fadeLyr3PicY < baseScreenHeight//2
		fadeLyr3PicY := fadeLyr3PicY+fadeLyr3PicPad
	Else 
		fadeLyr3PicY := fadeLyr3PicY-fadeLyr3PicPad
	;====== Loading Gif Files
	GifAnimation := GetFadeGifFile("Anim")
	If GifAnimation
		{
		AnimatedGifControl_GetImageDimensions(GifAnimation, GifWidth, GifHeight)
		fadeLyr4PicW := GifWidth
		fadeLyr4PicH := GifHeight
		If (fadeLyr4Pos = "Above Layer 3 - Left") {
			fadeLyr4PicX := fadeLyr3PicX
			fadeLyr4PicY := fadeLyr3PicY-fadeLyr4PicH
		} Else If (fadeLyr4Pos = "Above Layer 3 - Center") {
			fadeLyr4PicX := fadeLyr3PicX+fadeLyr3PicW/2
			fadeLyr4PicY := fadeLyr3PicY-fadeLyr4PicH
		} Else If (fadeLyr4Pos = "Above Layer 3 - Right") {
			fadeLyr4PicX := fadeLyr3PicX+fadeLyr3PicW-fadeLyr4PicX
			fadeLyr4PicY := fadeLyr3PicY-fadeLyr4PicH
		} Else {
			GetFadePicPosition(fadeLyr4PicX,fadeLyr4PicY,fadeLyr4X,fadeLyr4Y,fadeLyr4PicW,fadeLyr4PicH,fadeLyr4Pos)
		}
		fadeTranspGifColor := % "0x" . fadeTranspGifColor
		Gui, Fade_GifAnim_GUI: +OwnerFade_GUI3 -Caption +LastFound +ToolWindow +AlwaysOnTop
		GifAnim_GUI_ID := WinExist()
		Gui, Fade_GifAnim_GUI: Color, %fadeTranspGifColor%
		WinSet, TransColor, %fadeTranspGifColor% , ahk_id %GifAnim_GUI_ID%
		hAniGif1 := AniGif_CreateControl(GifAnim_GUI_ID, 0, 0, fadeLyr4PicW,fadeLyr4PicH, "center")
	}
	;====== Loading Layer 4 Animation Files
	If !GifAnimation
	{
		FadeLayer4AnimFilesAr := GetFadeAnimFiles("Layer",4)
		If FadeLayer4AnimFilesAr.MaxIndex() > 0
			{
			For index, value in FadeLayer4AnimFilesAr
				{
				FadeLayer4Anim%a_index%Pic := Gdip_CreateBitmapFromFile(value)
				FadeLayer4AnimTotal := a_index
			}
			Gdip_GetImageDimensions(FadeLayer4Anim1Pic, fadeLyr4PicW, fadeLyr4PicH)
			fadeLyr4PicW := fadeLyr4PicW * fadeLyr4Adjust
			fadeLyr4PicH := fadeLyr4PicH * fadeLyr4Adjust
			If (fadeLyr4Pos = "Above Layer 3 - Left") {
				fadeLyr4PicX := fadeLyr3PicX
				fadeLyr4PicY := fadeLyr3PicY-fadeLyr4PicH
			} Else If (fadeLyr4Pos = "Above Layer 3 - Center") {
				fadeLyr4PicX := fadeLyr3PicX+fadeLyr3PicW/2
				fadeLyr4PicY := fadeLyr3PicY-fadeLyr4PicH
			} Else If (fadeLyr4Pos = "Above Layer 3 - Right") {
				fadeLyr4PicX := fadeLyr3PicX+fadeLyr3PicW-fadeLyr4PicX
				fadeLyr4PicY := fadeLyr3PicY-fadeLyr4PicH
			} Else {
				GetFadePicPosition(fadeLyr4PicX,fadeLyr4PicY,fadeLyr4X,fadeLyr4Y,fadeLyr4PicW,fadeLyr4PicH,fadeLyr4Pos)
			}
		}
	}
	;Layer 4 padding
	If fadeLyr4PicX < baseScreenWidth//2
		fadeLyr4PicX := fadeLyr4PicX+fadeLyr4PicPad
	Else 
		fadeLyr4PicX := fadeLyr4PicX-fadeLyr4PicPad
	If fadeLyr4PicY < baseScreenHeight//2
		fadeLyr4PicX := fadeLyr4PicX+fadeLyr4PicPad
	Else 
		fadeLyr4PicX := fadeLyr4PicX-fadeLyr4PicPad
	;====== Loading Bar options
	If ((fadeLyr3Type = "bar") or (fadeLyr3Type = "ImageAndBar")) and ((fadeBar="true") or ( (fadeBar="7zOnly") and ((found7z="true") and (7zEnabled = "true") and !7zTempRomExists and use7zAnimation)) )
		{
		;Creating Progress Bar Brushes
		fadeBrushWindow1 := Gdip_CreateLineBrushFromRect(0, 0, fadeBarWindowW, fadeBarWindowH, 0xff555555, 0xff050505)
		fadeBrushWindow2 := Gdip_BrushCreateHatch(0xff000000, 0x00000000, fadeBarWindowHatchStyle)
		fadeBrushBarBack := Gdip_BrushCreateSolid("0x" . fadeBarBackColor)
		fadeBrushBar := Gdip_BrushCreateHatch(0x00000000, "0x" . fadeBarColor, fadeBarHatchStyle)
		if (fadeBarWindow="Image") {
			fadeLyr3ProgressBarFile := GetFadePicFile("Progress Bar")
			fadeLyr3ProgressBar := Gdip_CreateBitmapFromFile(fadeLyr3ProgressBarFile)
			Gdip_GetImageDimensions(fadeLyr3ProgressBar, fadeBarWindowW, fadeBarWindowH)
			fadeBarWindowW := Round(fadeBarWindowW*fadeXScale)
			fadeBarWindowH := Round(fadeBarWindowH*fadeYScale)
		}
		fadeBarW := fadeBarWindowW-2*fadeBarWindowM	; controls the bar's width, calculated from the bar window width and margin
		;Progress Bar
		fadeBarX := fadeBarWindowM	; Relative to window update area
		yBar := (fadeBarWindowH-fadeBarH)//2	; Relative to window update area
		; Percentage Text
		Gdip_FontFamilyCreate(fadeFont)	; Creating font family
		;Acquiring text font size
		Loop, parse, fadeText1Options, %A_Space%
			{
			If (InStr(A_LoopField, "s")=1)
				stringtrimleft, fadeText1Height, A_LoopField, 1
		}
		Loop, parse, fadeText2Options, %A_Space%
			{
			If (InStr(A_LoopField, "s")=1)
				stringtrimleft, fadeText2Height, A_LoopField, 1
		}
		If !fadeText1X
			fadeText1X := fadeBarX	; text1 X is set in relation to the bar X If not set by the user
		If !fadeText1Y
			fadeText1Y := round((fadeBarWindowH-fadeBarH)//2-1.5*fadeText1Height)	; text1 Y calculation If not set by the user
		If !fadeText2X
			fadeText2X := fadeBarWindowW-fadeBarWindowM	; text2 X calculation If not set by the user
		If !fadeText2Y
			fadeText2Y := round((fadeBarWindowH+fadeBarH)//2+0.5*fadeText2Height)	; text2 Y calculation If not set by the user
		; Window Update Area
		If (fadeLyr3Type = "bar") {
			xTopLeft := If fadeBarWindowX ? fadeBarWindowX : (baseScreenWidth-fadeBarWindowW)//2	; calculates where the X of the topleft corner of the bar window needs to be
			yTopLeft := If fadeBarWindowY ? fadeBarWindowY : (baseScreenHeight-fadeBarWindowH)//2	; calculates where the Y of the topleft corner of the bar window needs to be
		} Else {
			xTopLeft := If fadeBarWindowX ? fadeBarWindowX : (baseScreenWidth-fadeBarWindowW)//2+fadeBarXOffset	; calculates where the X of the topleft corner of the bar window needs to be
			yTopLeft := If fadeBarWindowY ? fadeBarWindowY : (baseScreenHeight-fadeBarWindowH)//2+fadeBarYOffset	; calculates where the Y of the topleft corner of the bar window needs to be
		}
	} Else {
		xTopLeft := fadeLyr3PicX
		yTopLeft := fadeLyr3PicY
	}
	;====== Loading extraction time text info
	If !fadeExtractionTimeTextX
		fadeExtractionTimeTextX := fadeBarWindowM	; text X calculation If not set by the user
	If !fadeExtractionTimeTextY
		fadeExtractionTimeTextY := round((fadeBarWindowH+fadeBarH)//2+0.5*fadeText2Height)	; text Y calculation If not set by the user
	;====== Redefining Layer 3 to cover image plus bar size
	; Defining Layer 3 update area
	If ((fadeLyr3Type = "bar") and ((fadeBar="true") or ( (fadeBar="7zOnly") and ((found7z="true") and (7zEnabled = "true") and !7zTempRomExists and use7zAnimation)) )){
		fadeLyr3CanvasX := xTopLeft
		fadeLyr3CanvasY := yTopLeft
		fadeLyr3CanvasW := fadeBarWindowW
		fadeLyr3CanvasH := fadeBarWindowH
	} Else If ((fadeLyr3Type = "ImageAndBar") and ((fadeBar="true") or ( (fadeBar="7zOnly") and ((found7z="true") and (7zEnabled = "true") and !7zTempRomExists and use7zAnimation)) )){
		fadeLyr3CanvasX := fadeLyr3PicX < xTopLeft ? fadeLyr3PicX : xTopLeft
		fadeLyr3CanvasY := fadeLyr3PicY < yTopLeft ? fadeLyr3PicY : yTopLeft 
		fadeLyr3CanvasW := fadeLyr3PicX+fadeLyr3PicW-fadeLyr3CanvasX > xTopLeft+fadeBarWindowW-fadeLyr3CanvasX ? fadeLyr3PicX+fadeLyr3PicW-fadeLyr3CanvasX : xTopLeft+fadeBarWindowW-fadeLyr3CanvasX
		fadeLyr3CanvasH := fadeLyr3PicY+fadeLyr3PicH-fadeLyr3CanvasY > yTopLeft+fadeBarWindowH-fadeLyr3CanvasY ? fadeLyr3PicY+fadeLyr3PicH-fadeLyr3CanvasY : yTopLeft+fadeBarWindowH-fadeLyr3CanvasY
	} Else { ;(fadeLyr3Type = "image")
		fadeLyr3CanvasX := fadeLyr3PicX
		fadeLyr3CanvasY := fadeLyr3PicY
		fadeLyr3CanvasW := fadeLyr3PicW
		fadeLyr3CanvasH := fadeLyr3PicH
	}
	;====== Rom Info Text
	romInfoText := [] ; 1,1 - romInfoText ; 1,2 romInfoTextContent ; 1,3 - romInfoTextFormatedContent ; 1,4 - romInfoTextOptions ; 1,5 - romInfoBitmap ; 1,6 - romInfoBitmapX ; 1,7 - romInfoBitmapY ; 1,8 - romInfoBitmapW ; 1,9 - romInfoBitmapH
	clearGameName := gameInfo["Name"].Value
	stringSplit, clearGameName, clearGameName, (
	clearGameName := clearGameName1
	Displacement := 0
	Loop, parse, fadeRomInfoOrder,|,
		{
		romInfoText[A_Index,1] := A_LoopField 
		If (romInfoText[A_Index,1] = "Description") {
			descriptionTextIndex := A_Index
			romInfoText[A_Index,2] := gameInfo["Name"].Value
			If  (fadeRomInfoDescription="filtered text") {
				romInfoText[A_Index,3] := clearGameName
			} else if (fadeRomInfoDescription="text") {
				romInfoText[A_Index,3] := romInfoText[A_Index,2]
			} else if (fadeRomInfoDescription="filtered text with label") {
				romInfoText[A_Index,3] := "Game: " . clearGameName
			} else if (fadeRomInfoDescription="text with label") {
				romInfoText[A_Index,3] := "Game: " . romInfoText[A_Index,2]
			}	
		} Else If (romInfoText[A_Index,1] = "SystemName") {
			romInfoText[A_Index,2] := systemName
			If  (fadeRomInfoSystemName="text with label") {
				romInfoText[A_Index,3] := "System: " .  romInfoText[A_Index,2]
			} Else 
				romInfoText[A_Index,3] := romInfoText[A_Index,2]
		} Else If (romInfoText[A_Index,1] = "Year") {
			yearTextIndex := A_Index
			romInfoText[A_Index,2] := gameInfo["Year"].Value
			If  (fadeRomInfoYear="text with label") {
				romInfoText[A_Index,3] := "Year: " . romInfoText[A_Index,2]
			} Else 
				romInfoText[A_Index,3] := romInfoText[A_Index,2]
		} Else If (romInfoText[A_Index,1] = "Manufacturer") {
			manufacturerTextIndex := A_Index		
			romInfoText[A_Index,2] := gameInfo["Manufacturer"].Value
			If  (fadeRomInfoManufacturer="text with label") {
				romInfoText[A_Index,3] := "Manufacturer: " . romInfoText[A_Index,2]
			 } Else 
				romInfoText[A_Index,3] := romInfoText[A_Index,2]
		} Else If (romInfoText[A_Index,1] = "Genre") {
			romInfoText[A_Index,2] := gameInfo["Genre"].Value
			If  (fadeRomInfoGenre="text with label") {
				romInfoText[A_Index,3] := "Genre: " . romInfoText[A_Index,2]
			} Else 
				romInfoText[A_Index,3] := romInfoText[A_Index,2]
		} Else If (romInfoText[A_Index,1] = "Rating") {
			romInfoText[A_Index,2] := gameInfo["Rating"].Value
			If  (fadeRomInfoRating="text with label") {
				romInfoText[A_Index,3] := "Rating: " . romInfoText[A_Index,2]
			} Else 
				romInfoText[A_Index,3] := romInfoText[A_Index,2]
		}
	}
	; Resizing text if does not fit the defined width
	Loop, 6
		{
		currentRomInfoTextIndex := A_Index
		currentRomInfoTextType := "fadeRomInfo" . romInfoText[currentRomInfoTextIndex,1] 
		if !((%currentRomInfoTextType%="Image")or(%currentRomInfoTextType%="Disabled")){
			RegExMatch(fadeRomInfoText%currentRomInfoTextIndex%Options, "i)W([\-\d\.]+)(p*)", Width)
			if Width
				{
				RegExMatch(fadeRomInfoText%currentRomInfoTextIndex%Options, "i)S([\-\d\.]+)(p*)", Size)
				StringReplace, textOptions, fadeRomInfoText%currentRomInfoTextIndex%Options, %Width%,
				Width := SubStr(Width, 2), FontSize := SubStr(Size, 2)
				textLength := MeasureText(romInfoText[currentRomInfoTextIndex,3],textOptions,fadeFont)
				if (textLength>Width) {
					loop,
						{
						StringReplace, textOptions, textOptions, % "S" . FontSize, % "S" . FontSize-5
						FontSize := FontSize - 5
						textLength := MeasureText(romInfoText[currentRomInfoTextIndex,3],textOptions,fadeFont)
						if (textLength<Width){
							fadeRomInfoText%currentRomInfoTextIndex%Options := RegExReplace(fadeRomInfoText%currentRomInfoTextIndex%Options, "i)S(\d+)(p*)", "s" .  FontSize )
							RegExMatch(fadeRomInfoText%currentRomInfoTextIndex%Options, "i)Y([\-\d\.]+)(p*)", YPos)
							fadeRomInfoText%currentRomInfoTextIndex%Options := RegExReplace(fadeRomInfoText%currentRomInfoTextIndex%Options, "i)Y([\-\d\.]+)(p*)", "y" . Round(SubStr(YPos,2)+(5*A_Index)/2) )
							break
						}
					}
				}
			}
		}
	}
	; Handling Rom Info images
	Loop, 6
		{
		currentRomInfoTextType := "fadeRomInfo" . romInfoText[A_Index,1] 
		If (%currentRomInfoTextType%="Image") {
			If (romInfoText[A_Index,1] = "Description") {
				If romInfoText[A_Index,2]
					{
					If FileExist(HLMediaPath . "\Wheels\" . systemname . "\" . dbname . "\*.png") {
						fadeRomWheelImageList := []
						Loop, %HLMediaPath%\Wheels\%systemname%\%dbname%\*.png
							fadeRomWheelImageList.Insert(A_LoopFileFullPath)
						Random, RndmFadeRomWheelImage, 1, % fadeRomWheelImageList.MaxIndex()
						fadeRomWheelImage := FadeRomWheelImageList[RndmFadeRomWheelImage]
						imagePointer := Gdip_CreateBitmapFromFile(fadeRomWheelImage)
					} Else If FileExist( frontendPath . "\Media\" . systemName . "\Images\Wheel\" . dbname . ".png") {
						imagePointer := Gdip_CreateBitmapFromFile( frontendPath . "\Media\" . systemName . "\Images\Wheel\" . dbname . ".png" )
					}
				}
			} Else If (romInfoText[A_Index,1] = "SystemName") {
				If romInfoText[A_Index,2]
				{
					If FileExist(HLMediaPath . "\Wheels\" . systemname . "\_Default\*.png") {
						fadeSystemWheelImageList := []
						Loop, %HLMediaPath%\Wheels\%systemname%\_Default\*.png
							fadeSystemWheelImageList.Insert(A_LoopFileFullPath)
						Random, RndmFadeSystemWheelImage, 1, % fadeSystemWheelImageList.MaxIndex()
						fadeSystemWheelImage := fadeSystemWheelImageList[RndmFadeSystemWheelImage]
						imagePointer := Gdip_CreateBitmapFromFile(fadeSystemWheelImage)
					} Else If FileExist( frontendPath . "\Media\Main Menu\Images\Wheel\" . systemname . ".png") {
						imagePointer := Gdip_CreateBitmapFromFile( frontendPath . "\Media\Main Menu\Images\Wheel\" . systemname . ".png" )
					}
				}
			} Else {
				If romInfoText[A_Index,2]
					If FileExist( fadeImgPath . "\_Default\" . romInfoText[A_Index,1]  . "\" . romInfoText[A_Index,2] . ".png" )
						imagePointer := Gdip_CreateBitmapFromFile( fadeImgPath . "\_Default\" . romInfoText[A_Index,1] . "\" . romInfoText[A_Index,2] . ".png" )
			}
			If imagePointer
				romInfoText[A_Index,5] := imagePointer
		}
		imagePointer := 
	}
	;Defining Image W and H of images
	Loop, 6
		{
		currentRomInfoTextType := "fadeRomInfo" . romInfoText[A_Index,1]  
		If (%currentRomInfoTextType%="Image") {
			RegExMatch(fadeRomInfoText%A_Index%Options, "i)W([\-\d\.]+)(p*)", UserDefinedW) ; getting w coordinates
			RegExMatch(fadeRomInfoText%A_Index%Options, "i)H([\-\d\.]+)(p*)", UserDefinedH) ; getting h coordinates
			stringtrimLeft, UserDefinedW, UserDefinedW, 1
			stringtrimLeft, UserDefinedH, UserDefinedH, 1
			Gdip_GetImageDimensions(romInfoText[A_Index,5], W, H)
			If ((UserDefinedW) and (UserDefinedH)){
				romInfoText[A_Index,8] := UserDefinedW
				romInfoText[A_Index,9] := UserDefinedH
			} Else If (UserDefinedW) {
				romInfoText[A_Index,8] := UserDefinedW
				romInfoText[A_Index,9] := round(H*UserDefinedW/W)
			} Else If (UserDefinedH) {
				romInfoText[A_Index,9] := UserDefinedH
				romInfoText[A_Index,8] := round(W*UserDefinedH/H)
			} Else {
				romInfoText[A_Index,8] := W
				romInfoText[A_Index,9] := H			
			}
		}
	}
	If (fadeRomInfoTextPlacement="User Defined"){
		Loop, 6
			{
			currentRomInfoTextType := "fadeRomInfo" . romInfoText[A_Index,1]  
			If ((%currentRomInfoTextType%="Text") or (%currentRomInfoTextType%="filtered text") or (%currentRomInfoTextType%="filtered text with label")  or (%currentRomInfoTextType%="text with label")) 

				romInfoText[A_Index,4] := fadeRomInfoText%A_Index%Options 
			Else If (%currentRomInfoTextType%="Image") {
				RegExMatch(fadeRomInfoText%A_Index%Options, "i)X([\-\d\.]+)(p*)", UserDefinedX) ; getting x coordinates
				RegExMatch(fadeRomInfoText%A_Index%Options, "i)Y([\-\d\.]+)(p*)", UserDefinedY) ; getting y coordinates
				stringtrimLeft, UserDefinedX, UserDefinedX, 1
				stringtrimLeft, UserDefinedY, UserDefinedY, 1
				romInfoText[A_Index,6] := UserDefinedX
				romInfoText[A_Index,7] := UserDefinedY
				If !UserDefinedX
					romInfoText[A_Index,6] := (baseScreenWidth-romInfoText[A_Index,8])//2
				If !UserDefinedY
					romInfoText[A_Index,7] := (baseScreenHeight-romInfoText[A_Index,9])//2
			}
		}
	} Else {
		Loop, 6
			{
			currentRomInfoTextType := "fadeRomInfo" . romInfoText[A_Index,1] 
			If ((%currentRomInfoTextType%="Text") or (%currentRomInfoTextType%="filtered text") or (%currentRomInfoTextType%="filtered text with label")  or (%currentRomInfoTextType%="text with label")) { ;parsing text options to remove x, y, W, H

				romInfoText[A_Index,4] := RegExReplace(fadeRomInfoText%A_Index%Options, "i)X([\-\d\.]+)(p*)", " ") ; Removing x
				romInfoText[A_Index,4] := RegExReplace(romInfoText[A_Index,4], "i)Y([\-\d\.]+)(p*)", " ") ; Removing y
				romInfoText[A_Index,4] := RegExReplace(romInfoText[A_Index,4], "i)W([\-\d\.]+)(p*)", " ") ; Removing w
				romInfoText[A_Index,4] := RegExReplace(romInfoText[A_Index,4], "i)H([\-\d\.]+)(p*)", " ") ; Removing h
				romInfoText[A_Index,4] := RegExReplace(romInfoText[A_Index,4], "i)Top|Up|Bottom|Down|vCentre|vCenter", " ") ; Removing Align
				FoundPos := RegExMatch(romInfoText[A_Index,4], "i)S(\d+)(p*)", Size) ; Acquiring rom info font size
				StringTrimLeft, Size , Size,1
				maxromInfoTextSize := maxromInfoTextSize > Size ? maxromInfoTextSize : Size 
			}
		}
		If (fadeRomInfoTextPlacement="corners"){
			romInfoText[1,4] := "x" . fadeRomInfoTextMargin . " y" . fadeRomInfoTextMargin . " Left " . romInfoText[1,4]
			romInfoText[1,6] := fadeRomInfoTextMargin
			romInfoText[1,7] := fadeRomInfoTextMargin
			romInfoText[2,4] := "x" . baseScreenWidth-fadeRomInfoTextMargin . " y" .  fadeRomInfoTextMargin . " Right " . romInfoText[2,4]
			romInfoText[2,6] := baseScreenWidth-fadeRomInfoTextMargin-romInfoText[2,8]
			romInfoText[2,7] := fadeRomInfoTextMargin
			romInfoText[3,4] := "x" . fadeRomInfoTextMargin . " y" . baseScreenHeight-maxromInfoTextSize-fadeRomInfoTextMargin . " Left " . romInfoText[3,4]
			romInfoText[3,6] := fadeRomInfoTextMargin
			romInfoText[3,7] := baseScreenHeight-fadeRomInfoTextMargin-romInfoText[3,9]
			romInfoText[4,4] := "x" . baseScreenWidth-fadeRomInfoTextMargin . " y" . baseScreenHeight-maxromInfoTextSize-fadeRomInfoTextMargin . " Right " . romInfoText[4,4]
			romInfoText[4,6] := baseScreenWidth-fadeRomInfoTextMargin-romInfoText[4,8]
			romInfoText[4,7] := baseScreenHeight-fadeRomInfoTextMargin-romInfoText[4,9]
			romInfoText[5,4] := "x" . baseScreenWidth//2 . " y" . fadeRomInfoTextMargin . " Center " . romInfoText[5,4]
			romInfoText[5,6] := (baseScreenWidth-romInfoText[5,8])//2
			romInfoText[5,7] := fadeRomInfoTextMargin
			romInfoText[6,4] := "x" . baseScreenWidth//2 . " y" . baseScreenHeight-maxromInfoTextSize-fadeRomInfoTextMargin . " Center " . romInfoText[6,4]
			romInfoText[6,6] := (baseScreenWidth-romInfoText[6,8])//2
			romInfoText[6,7] := baseScreenHeight-fadeRomInfoTextMargin-romInfoText[6,9]
		} Else {
			Loop, 6
				{
				currentRomInfoTextType := "fadeRomInfo" . romInfoText[A_Index,1] 
				If ((fadeRomInfoTextPlacement="bottomRight") or (fadeRomInfoTextPlacement="bottomLeft")) {
					If ((%currentRomInfoTextType%="Text") or (%currentRomInfoTextType%="filtered text") or (%currentRomInfoTextType%="filtered text with label")  or (%currentRomInfoTextType%="text with label")) 

						Displacement := Displacement + (maxromInfoTextSize+10)
					Else If (%currentRomInfoTextType%="Image") 
						Displacement := Displacement + ( romInfoText[A_Index,9] +10)
				}
				If (fadeRomInfoTextPlacement="topRight") {
					romInfoText[A_Index,4] := "x" . baseScreenWidth-fadeRomInfoTextMargin . " y" . Displacement+fadeRomInfoTextMargin . " Right " . romInfoText[A_Index,4]	
					romInfoText[A_Index,6] := baseScreenWidth-fadeRomInfoTextMargin-romInfoText[A_Index,8]
					romInfoText[A_Index,7] := Displacement+fadeRomInfoTextMargin
				} Else If (fadeRomInfoTextPlacement="topLeft") {
					romInfoText[A_Index,4] := "x" . fadeRomInfoTextMargin . " y" . Displacement+fadeRomInfoTextMargin . " Left " . romInfoText[A_Index,4]
					romInfoText[A_Index,6] := fadeRomInfoTextMargin
					romInfoText[A_Index,7] := Displacement+fadeRomInfoTextMargin
				} Else If (fadeRomInfoTextPlacement="bottomRight") {
					romInfoText[A_Index,4] := "x" . baseScreenWidth-fadeRomInfoTextMargin . " y" . baseScreenHeight-Displacement-fadeRomInfoTextMargin . " Right " . romInfoText[A_Index,4]
					romInfoText[A_Index,6] := baseScreenWidth-fadeRomInfoTextMargin-romInfoText[A_Index,8]
					romInfoText[A_Index,7] :=  baseScreenHeight-fadeRomInfoTextMargin-Displacement
				} Else If (fadeRomInfoTextPlacement="bottomLeft") {
					romInfoText[A_Index,4] := "x" . fadeRomInfoTextMargin . " y" . baseScreenHeight-Displacement-fadeRomInfoTextMargin . " Left " . romInfoText[A_Index,4]
					romInfoText[A_Index,6] := fadeRomInfoTextMargin
					romInfoText[A_Index,7] := baseScreenHeight-fadeRomInfoTextMargin-Displacement
				}
				If ((fadeRomInfoTextPlacement="topRight") or (fadeRomInfoTextPlacement="topLeft")) {
					If ((%currentRomInfoTextType%="Text") or (%currentRomInfoTextType%="filtered text") or (%currentRomInfoTextType%="filtered text with label")  or (%currentRomInfoTextType%="text with label")) 

						Displacement := Displacement + (maxromInfoTextSize+10)
					Else If (%currentRomInfoTextType%="Image") 
						Displacement := Displacement + ( romInfoText[A_Index,9] +10)
				}
			}
		}
	}
	;====== Statistics Info Text
	If !( (fadeRomInfoTextPlacement=fadestatsInfoTextPlacement) and ((fadeRomInfoTextPlacement="topRight") or (fadeRomInfoTextPlacement="topLeft") or (fadeRomInfoTextPlacement="bottomRight") or (fadeRomInfoTextPlacement="bottomLeft")) ) 
		Displacement := 0
	If  (statisticsEnabled = "true"){
		If ((fadeStats_Number_of_Times_Played<>disabled) or (fadeStats_Last_Time_Played<>disabled) or (fadeStats_Average_Time_Played<>disabled) or (fadeStats_Total_Time_Played<>disabled) or (fadeStats_System_Total_Played_Time<>disabled) or (fadeStats_Total_Global_Played_Time<>disabled) ){
			;Load statistics
			If (!romTable && mgCandidate)
				romTable := CreateRomTable(dbName)
			Totaldiscsofcurrentgame:=romTable.MaxIndex()
			If (Totaldiscsofcurrentgame>1) 
				DescriptionNameWithoutDisc := romTable[1,4]
			Else
				DescriptionNameWithoutDisc := gameInfo["Name"].Value 
			stringsplit, DescriptionNameSplit, DescriptionNameWithoutDisc, "(", ;Only game  description name
			ClearDescriptionName := RegexReplace( DescriptionNameSplit1, "^\s+|\s+$" ) ; Statistics cleared game name
			IniRead, Number_of_Times_Played, % HLDataPath . "\Statistics\" . systemName . ".ini", % dbName, Number_of_Times_Played, 0
			IniRead, Last_Time_Played, % HLDataPath . "\Statistics\" . systemName . ".ini", % dbName, Last_Time_Played, 0
			IniRead, Average_Time_Played, % HLDataPath . "\Statistics\" . systemName . ".ini", % dbName, Average_Time_Played, 0
			IniRead, Total_Time_Played, % HLDataPath . "\Statistics\" . systemName . ".ini", % dbName, Total_Time_Played, 0
			IniRead, System_Total_Played_Time, % HLDataPath . "\Statistics\" . systemName . ".ini", General, System_Total_Played_Time, 0
			IniRead, Total_Global_Played_Time, % HLDataPath . "\Statistics\Global Statistics.ini", General, Total_Global_Played_Time, 0
			;Formating stats
			If(Number_of_Times_Played=0)
				Number_of_Times_Played := "Never"
			Else If (Number_of_Times_Played=1) 
				Number_of_Times_Played := Number_of_Times_Played . " time"
			Else 
				Number_of_Times_Played := Number_of_Times_Played . " times"
			If(Last_Time_Played=0)
				Last_Time_Played := "Never"
			If (Average_Time_Played>0)
				Average_Time_Played := GetTimeString(Average_Time_Played) . " per session"
			Total_Time_Played := GetTimeString(Total_Time_Played)
			System_Total_Played_Time := GetTimeString(System_Total_Played_Time)
			Total_Global_Played_Time := GetTimeString(Total_Global_Played_Time) 
			statsInfoText := [] 
			Loop, parse, fadeStatsInfoOrder,|,
				{
				statsInfoText[A_Index,1] := A_LoopField 
				If (statsInfoText[A_Index,1] = "Number_of_Times_Played") {
					statsInfoText[A_Index,2] := Number_of_Times_Played
					If  (fadeStats_Number_of_Times_Played="text with label") {
						statsInfoText[A_Index,3] := "Times Played: " . statsInfoText[A_Index,2]
					} Else 
						statsInfoText[A_Index,3] := statsInfoText[A_Index,2]
				} Else If (statsInfoText[A_Index,1] = "Last_Time_Played") {
					statsInfoText[A_Index,2] := Last_Time_Played
					If  (fadeStats_Last_Time_Played="text with label") {
						statsInfoText[A_Index,3] := "Last Time Played: " .  statsInfoText[A_Index,2]
					} Else 
						statsInfoText[A_Index,3] := statsInfoText[A_Index,2]
				} Else If (statsInfoText[A_Index,1] = "Average_Time_Played") {
					statsInfoText[A_Index,2] := Average_Time_Played
					If  (fadeStats_Average_Time_Played="text with label") {
						statsInfoText[A_Index,3] := "Average Time Played: " . statsInfoText[A_Index,2]
					} Else 
						statsInfoText[A_Index,3] := statsInfoText[A_Index,2]
				} Else If (statsInfoText[A_Index,1] = "Total_Time_Played") {
					statsInfoText[A_Index,2] := Total_Time_Played
					If  (fadeStats_Total_Time_Played="text with label") {
						statsInfoText[A_Index,3] := "Total Time Played: " . statsInfoText[A_Index,2]
					} Else 
						statsInfoText[A_Index,3] := statsInfoText[A_Index,2]
				} Else If (statsInfoText[A_Index,1] = "System_Total_Played_Time") {
					statsInfoText[A_Index,2] := System_Total_Played_Time
					If  (fadeStats_System_Total_Played_Time="text with label") {
						statsInfoText[A_Index,3] := "System Total Played Time: " . statsInfoText[A_Index,2]
					} Else 
						statsInfoText[A_Index,3] := statsInfoText[A_Index,2]
				} Else If (statsInfoText[A_Index,1] = "Total_Global_Played_Time") {
					statsInfoText[A_Index,2] := Total_Global_Played_Time
					If  (fadeStats_Total_Global_Played_Time="text with label") {
						statsInfoText[A_Index,3] := "Total Global Played Time: " . statsInfoText[A_Index,2]
					} Else 
						statsInfoText[A_Index,3] := statsInfoText[A_Index,2]
				}
			}
			If (fadeStatsInfoTextPlacement="User Defined"){
				Loop, 6
					{
					currentStatsInfoTextType := "fadeStats_" . statsInfoText[A_Index,1]  
					If ((%currentStatsInfoTextType%="Text") or  (%currentStatsInfoTextType%="text with label"))  
						statsInfoText[A_Index,4] := fadeStatsInfoText%A_Index%Options 
				}
			} Else {
				Loop, 6
					{
					currentStatsInfoTextType := "fadeStats_" . statsInfoText[A_Index,1]  
					If ((%currentStatsInfoTextType%="Text") or  (%currentStatsInfoTextType%="text with label")) { ;parsing text options to remove x, y, W, H
						statsInfoText[A_Index,4] := RegExReplace(fadeStatsInfoText%A_Index%Options, "i)X([\-\d\.]+)(p*)", " ") ; Removing x
						statsInfoText[A_Index,4] := RegExReplace(statsInfoText[A_Index,4], "i)Y([\-\d\.]+)(p*)", " ") ; Removing y
						statsInfoText[A_Index,4] := RegExReplace(statsInfoText[A_Index,4], "i)W([\-\d\.]+)(p*)", " ") ; Removing w
						statsInfoText[A_Index,4] := RegExReplace(statsInfoText[A_Index,4], "i)H([\-\d\.]+)(p*)", " ") ; Removing h
						statsInfoText[A_Index,4] := RegExReplace(statsInfoText[A_Index,4], "i)Top|Up|Bottom|Down|vCentre|vCenter", " ") ; Removing Align
						FoundPos := RegExMatch(statsInfoText[A_Index,4], "i)S(\d+)(p*)", Size) ; Acquiring stats info font size
						StringTrimLeft, Size , Size,1
						maxStatsInfoTextSize := maxStatsInfoTextSize > Size ? maxStatsInfoTextSize : Size 
					}
				}
				If (fadestatsInfoTextPlacement="corners"){
					statsInfoText[1,4] := "x" . fadeStatsInfoTextMargin . " y" . fadeStatsInfoTextMargin . " Left " . statsInfoText[1,4]
					statsInfoText[2,4] := "x" . baseScreenWidth-fadeStatsInfoTextMargin . " y" .  fadeStatsInfoTextMargin . " Right " . statsInfoText[2,4]
					statsInfoText[3,4] := "x" . fadeStatsInfoTextMargin . " y" . baseScreenHeight-maxstatsInfoTextSize-fadeStatsInfoTextMargin . " Left " . statsInfoText[3,4]
					statsInfoText[4,4] := "x" . baseScreenWidth-fadeStatsInfoTextMargin . " y" . baseScreenHeight-maxstatsInfoTextSize-fadeStatsInfoTextMargin . " Right " . statsInfoText[4,4]
					statsInfoText[5,4] := "x" . baseScreenWidth//2 . " y" . fadeStatsInfoTextMargin . " Center " . statsInfoText[5,4]
					statsInfoText[6,4] := "x" . baseScreenWidth//2 . " y" . baseScreenHeight-maxstatsInfoTextSize-fadeStatsInfoTextMargin . " Center " . statsInfoText[6,4]
				} Else {
					Loop, 6
						{
						If ((fadestatsInfoTextPlacement="bottomRight") or (fadestatsInfoTextPlacement="bottomLeft")) {
							if statsInfoText[A_Index,2] 
								Displacement := Displacement + (maxstatsInfoTextSize+10)
							else if (A_Index=1)
								Displacement := (maxstatsInfoTextSize+10)								
						}
						If (fadestatsInfoTextPlacement="topRight")
							statsInfoText[A_Index,4] := "x" . baseScreenWidth-fadeStatsInfoTextMargin . " y" . Displacement+fadeStatsInfoTextMargin . " Right " . statsInfoText[A_Index,4]	
						Else If (fadestatsInfoTextPlacement="topLeft")
							statsInfoText[A_Index,4] := "x" . fadeStatsInfoTextMargin . " y" . Displacement+fadeStatsInfoTextMargin . " Left " . statsInfoText[A_Index,4]
						Else If (fadestatsInfoTextPlacement="bottomRight")
							statsInfoText[A_Index,4] := "x" . baseScreenWidth-fadeStatsInfoTextMargin . " y" . baseScreenHeight-Displacement-fadeStatsInfoTextMargin . " Right " . statsInfoText[A_Index,4]
						Else If (fadestatsInfoTextPlacement="bottomLeft")
							statsInfoText[A_Index,4] := "x" . fadeStatsInfoTextMargin . " y" . baseScreenHeight-Displacement-fadeStatsInfoTextMargin . " Left " . statsInfoText[A_Index,4]
						If ((fadestatsInfoTextPlacement="topRight") or (fadestatsInfoTextPlacement="topLeft")) {
							if statsInfoText[A_Index,2] 
								Displacement := Displacement + (maxstatsInfoTextSize+10)
						}
					}
				}
			}
		}
	}
	;====== Defining Drawing areas
	pGraphUpd(Fade_G3,fadeLyr3CanvasW,fadeLyr3CanvasH)
	fadeLyr4CanvasX := round(fadeLyr4PicX) , fadeLyr4CanvasY := round(fadeLyr4PicY)
	fadeLyr4CanvasW := round(fadeLyr4PicW), fadeLyr4CanvasH := round(fadeLyr4PicH)
	pGraphUpd(Fade_G4,fadeLyr4CanvasW,fadeLyr4CanvasH)
	fadeLyr5CanvasX := 0 , fadeLyr5CanvasY := 0
	fadeLyr5CanvasW := baseScreenWidth, fadeLyr5CanvasH := baseScreenHeight
	pGraphUpd(Fade_G5,fadeLyr5CanvasW,fadeLyr5CanvasH)
	;====== Defining Layer 3 Static
	Alt_UpdateLayeredWindow(Fade_hwnd3Static, Fade_hdc3Static,fadeLyr3StaticCanvasX,fadeLyr3StaticCanvasY, fadeLyr3StaticCanvasW, fadeLyr3StaticCanvasH)
	;====== Drawing text info
	Loop, 6
		{
		currentRomInfoTextType := "fadeRomInfo" . romInfoText[A_Index,1] 
		If ((%currentRomInfoTextType%="Text") or (%currentRomInfoTextType%="filtered text") or (%currentRomInfoTextType%="filtered text with label")  or (%currentRomInfoTextType%="text with label")) {
			If romInfoText[A_Index,2] 
				Gdip_Alt_TextToGraphics(Fade_G5, romInfoText[A_Index,3], romInfoText[A_Index,4], fadeFont, 0, 0)
		} Else If (%currentRomInfoTextType%="Image") {
			If romInfoText[A_Index,2] 
				Gdip_Alt_DrawImage(Fade_G5, romInfoText[A_Index,5], romInfoText[A_Index,6], romInfoText[A_Index,7], romInfoText[A_Index,8], romInfoText[A_Index,9])
		}
	}
	; Drawing Statistics text info
	If  (statisticsEnabled = "true"){
		Loop, 6
			{
			currentStatsInfoTextType := "fadeStats_" . statsInfoText[A_Index,1] 
			If ((%currentStatsInfoTextType%="Text") or  (%currentStatsInfoTextType%="text with label")) 
				If statsInfoText[A_Index,2] 
					Gdip_Alt_TextToGraphics(Fade_G5, statsInfoText[A_Index,3], statsInfoText[A_Index,4], fadeFont, 0, 0)
		}
	}
	Alt_UpdateLayeredWindow(Fade_hwnd5, Fade_hdc5,fadeLyr5CanvasX,fadeLyr5CanvasY, fadeLyr5CanvasW, fadeLyr5CanvasH)
	;====== drawing animated gif
	If GifAnimation
		SetTimer, FadeLayer4Anim, -1
	Else If (FadeLayer4AnimFilesAr.MaxIndex() > 0)
		SetTimer, FadeLayer4Anim, %fadeLyr4FPS%
	;====== Defining Progress Bar Update for non 7z 
	timeToMax := fadeLyr3Speed / fadeLyr3Repeat ; calculate how long layer 3 needs to take to show 100% of the image
	; update fadeInExitDelay value to assure that the fadeLyr3 animation finishes before exiting fade
	If (((fadeLyr3Type = "Image") or (fadeLyr3Type = "ImageAndBar")) and (fadeInLyr3File) and (fadeLyr3Repeat))
		if (fadeLyr3Speed>fadeInDelay+fadeInExitDelay)
			fadeInExitDelay := fadeInExitDelay + fadeLyr3Speed-(fadeInDelay+fadeInExitDelay)
	;Defining Progress Bar Update Time
	If ((fadeLyr3Type = "bar") or (fadeLyr3Type = "ImageAndBar")) and (fadeBar="true")
		progressBarTimeToMax := if (fadeBarNon7zProgressTime) ? fadeBarNon7zProgressTime : (fadeInDelay+fadeInExitDelay)
	;======checking for extraction and loading sound
	If ((found7z="true" and 7zEnabled = "true" and !7zTempRomExists and use7zAnimation) or (hlmode="fade7z")) and (7zSounds = "true") {
		If not (fadeLyr3Type = image and fadeLyr3ImgFollow7zProgress = false) {
			If FileExist( HLMediaPath . "\Fade\" . SystemName . "\" . dbName . "\7z extracting.mp3")
				extractionSound := HLMediaPath . "\Fade\" . SystemName . "\" . dbName . "\7z extracting.mp3"
			Else If FileExist( HLMediaPath . "\Fade\" . SystemName . "\_Default\7z extracting.mp3")
				extractionSound := HLMediaPath . "\Fade\" . SystemName . "\_Default\7z extracting.mp3"
			Else If FileExist( HLMediaPath . "\Fade\_Default\7z extracting.mp3")
				extractionSound := HLMediaPath . "\Fade\_Default\7z extracting.mp3"
			If extractionSound {
				Log("DefaultFadeAnimation - Playing " . extractionSound)
				SoundPlay, %extractionSound%
			}
		}
	} else {
		If FileExist( HLMediaPath . "\Fade\" . SystemName . "\" . dbName . "\loading.mp3")
			loadingSound := HLMediaPath . "\Fade\" . SystemName . "\" . dbName . "\loading.mp3"
		Else If FileExist( HLMediaPath . "\Fade\" . SystemName . "\_Default\loading.mp3")
			loadingSound := HLMediaPath . "\Fade\" . SystemName . "\_Default\loading.mp3"
		Else If FileExist( HLMediaPath . "\Fade\_Default\loading.mp3")
			loadingSound := HLMediaPath . "\Fade\_Default\loading.mp3"
		If loadingSound {
			Log("DefaultFadeAnimation - Playing " . loadingSound)
			SoundPlay, %loadingSound%
		}
	}
	;==== Create timer to update layer 3
	SetTimer, _DefaultFadeAnimationLoop, 50
	startTime := A_TickCount
	layer3startTime := A_TickCount
	If fadeInActive
		GoSub, FadeInDelay	; This must always be at the end of all animation functions. It's a simple timer that will force the GUI to stay up the defined amount of delay If the animation was shorter then said delay.
Return

_DefaultFadeAnimationLoop:
	if (!(fadeInActive)) or (fadeInExitComplete)
		SetTimer, _DefaultFadeAnimationLoop, Off
	if AnimationLoopFinished
		{
		SetTimer, _DefaultFadeAnimationLoop, Off
		Alt_UpdateLayeredWindow(Fade_hwnd3, Fade_hdc3,fadeLyr3CanvasX,fadeLyr3CanvasY, fadeLyr3CanvasW, fadeLyr3CanvasH)
		;stoping extraction sound and checking for complete sound
		If ((found7z="true" and 7zEnabled = "true" and !7zTempRomExists and use7zAnimation) or (hlmode="fade7z")) and (7zSounds = "true") {
			If extractionSound
				SoundPlay, blank.mp3  ; playing non existent file to stop extraction sound.
			If FileExist( HLMediaPath . "\Fade\" . SystemName . "\" . dbName . "\7z complete.mp3")
				completeSound := HLMediaPath . "\Fade\" . SystemName . "\" . dbName . "\7z complete.mp3"
			Else If FileExist( HLMediaPath . "\Fade\" . SystemName . "\_Default\7z complete.mp3")
				completeSound := HLMediaPath . "\Fade\" . SystemName . "\_Default\7z complete.mp3"
			Else If FileExist( HLMediaPath . "\Fade\_Default\7z complete.mp3")
				completeSound := HLMediaPath . "\Fade\_Default\7z complete.mp3"
			If completeSound
				SoundPlay, %completeSound%
		} else {
			If loadingSound
				SoundPlay, blank.mp3  ; playing non existent file to stop extraction sound.
			If FileExist( HLMediaPath . "\Fade\" . SystemName . "\" . dbName . "\loading complete.mp3")
				loadingSound := HLMediaPath . "\Fade\" . SystemName . "\" . dbName . "\loading complete.mp3"
			Else If FileExist( HLMediaPath . "\Fade\" . SystemName . "\_Default\loading complete.mp3")
				loadingSound := HLMediaPath . "\Fade\" . SystemName . "\_Default\loading complete.mp3"
			Else If FileExist( HLMediaPath . "\Fade\_Default\loading complete.mp3")
				loadingSound := HLMediaPath . "\Fade\_Default\loading complete.mp3"
			If loadingSound {
				Log("DefaultFadeAnimation - Playing " . loadingSound)
				SoundPlay, %loadingSound%
			}
		}
		Log("DefaultFadeAnimation - Ended")
	}
	;====== Begin of animation Loop
		Gdip_GraphicsClear(Fade_G3)
		;====== Updating 7z extraction info
		If (((found7z="true") and (7zEnabled = "true") and !(7zTempRomExists) and (use7zAnimation)) and !(hlmode="fade7z")) {
			If not (fadeLyr3Type = image and fadeLyr3ImgFollow7zProgress = false) {
				romExPercentageAndFile := COM_Invoke(HLObject, "getExtractionSize", 7zRomPath, 0)	; Get the current file being extracted and size of the 7z Extract Path - (Extraction Size\Progress (0=Accurate Method, 1=Fast Detection Method))
				Loop, Parse, romExPercentageAndFile, |	; StringSplit oddly doesn't work for some unknown reason, must resort to a parsing Loop instead
				{
					If A_Index = 1
					{
						romExCurSize := A_LoopField									; Store bytes extracted
						romExPercentage := (A_LoopField / romExSize) * 100	; Calculate percentage extracted
					} Else If A_Index = 2
						romExFile := A_LoopField
				}
				layer3Percentage := romExPercentage
			}
		} else { ; to be used for drawing the progress bar on non 7z fade or in hlmode "fade"
			timeElapsed := A_TickCount - startTime
			layer3TimeElapsed := A_TickCount - layer3startTime
			romExPercentage := (timeElapsed < progressBarTimeToMax) ? Round((timeElapsed / progressBarTimeToMax)*100) : 100
			if !fadeLyr3Drawn
				layer3Percentage := (layer3TimeElapsed < timeToMax) ? Round((layer3TimeElapsed / timeToMax)*100) : 100
		}
		;====== Drawing layer 3 image
		If (fadeLyr3Type = "Image") or (fadeLyr3Type = "ImageAndBar")
			{
			IfExist, % fadeInLyr3File
				{
				If fadeLyr3Repeat != 0	; Only Loop animation If user does not want a static image
					{
					if fadeLyr3BackImageTransparency
						Gdip_Alt_DrawImage(Fade_G3, fadeLyr3Pic, fadeLyr3PicX-fadeLyr3CanvasX, fadeLyr3PicY-fadeLyr3CanvasY, fadeLyr3PicW, fadeLyr3PicH, 0, 0, fadeLyr3PicW//fadeLyr3Adjust, fadeLyr3PicH//fadeLyr3Adjust, fadeLyr3BackImageTransparency/100) ; draw layer 3 image with transparency
					If (found7z="true") and (7zEnabled = "true") and (fadeLyr3ImgFollow7zProgress="true") and !7zTempRomExists and use7zAnimation {
						Gdip_Alt_DrawImage(Fade_G3, fadeLyr3Pic, fadeLyr3PicX-fadeLyr3CanvasX, fadeLyr3PicY-fadeLyr3CanvasY, round(fadeLyr3PicW*layer3Percentage/100), fadeLyr3PicH, 0, 0, Round((fadeLyr3PicW/fadeLyr3Adjust)*layer3Percentage/100), fadeLyr3PicH//fadeLyr3Adjust)	; draw layer 3 image onto screen on layer 3 and adjust the size If set
						If (layer3Percentage >= 100){
							If 7zEnded
								fadeLyr3Drawn := true
							7zEnded=1	; Often on small archives, 7z.exe ends so fast, it doesn't give us the chance to show 100% completion. By looping a 2nd time after 7z.exe is closed, the 2nd Loop after 7zEnded, sets the percentage to 100%.
						}
					} Else {
						If (t1 < 100 and fadeLyr3DrawnTimes<fadeLyr3Repeat) {
							t1 := ((timeElapsed := A_TickCount - layer3startTime) < timeToMax) ? timeElapsed / timeToMax : 100
							Gdip_Alt_DrawImage(Fade_G3, fadeLyr3Pic, fadeLyr3PicX-fadeLyr3CanvasX, fadeLyr3PicY-fadeLyr3CanvasY, fadeLyr3PicW*t1, fadeLyr3PicH, 0, 0, fadeLyr3PicW//fadeLyr3Adjust*t1, fadeLyr3PicH//fadeLyr3Adjust)	; draw layer 3 image onto screen on layer 3 and adjust the size If set
						} Else {
							layer3startTime := A_TickCount	; reset on each Loop
							fadeLyr3DrawnTimes++
							t1 := 0
							If (fadeLyr3DrawnTimes>=fadeLyr3Repeat) {
								fadeLyr3Drawn := true
								Gdip_Alt_DrawImage(Fade_G3, fadeLyr3Pic, fadeLyr3PicX-fadeLyr3CanvasX, fadeLyr3PicY-fadeLyr3CanvasY, fadeLyr3PicW, fadeLyr3PicH, 0, 0, fadeLyr3PicW//fadeLyr3Adjust, fadeLyr3PicH//fadeLyr3Adjust)	; draw layer 3 image onto screen on layer 3 and adjust the size If set
							}
						}
					}
				} Else If !fadeLyr3Drawn {	; If fadeLyr3Repeat is set to 0 (a static image), just show it, rather then animate
					Gdip_Alt_DrawImage(Fade_G3, fadeLyr3Pic, fadeLyr3PicX-fadeLyr3CanvasX, fadeLyr3PicY-fadeLyr3CanvasY, fadeLyr3PicW, fadeLyr3PicH, 0, 0, fadeLyr3PicW//fadeLyr3Adjust, fadeLyr3PicH//fadeLyr3Adjust)	; draw layer 3 image onto screen on layer 3 and adjust the size If set
					fadeLyr3Drawn := true
				}
			} Else {
				fadeLyr3Drawn := true
			}
		} Else {
			fadeLyr3Drawn := true
		}
		;====== Drawing Bar
		If ((fadeLyr3Type = "bar") or (fadeLyr3Type = "ImageAndBar")) and ((fadeBar="true") or ( (fadeBar="7zOnly") and ((found7z="true") and (7zEnabled = "true") and !7zTempRomExists and use7zAnimation)) )
			{
			; Bar Window
			if (fadeBarWindow="Image") {
				Gdip_Alt_DrawImage(Fade_G3, fadeLyr3ProgressBar, xTopLeft-fadeLyr3CanvasX, yTopLeft-fadeLyr3CanvasY, fadeBarWindowW, fadeBarWindowH)
			} else if (fadeBarWindow="GDI") {
				Gdip_Alt_FillRoundedRectangle(Fade_G3, fadeBrushWindow1, xTopLeft-fadeLyr3CanvasX, yTopLeft-fadeLyr3CanvasY, fadeBarWindowW, fadeBarWindowH, fadeBarWindowR)
				Gdip_Alt_FillRoundedRectangle(Fade_G3, fadeBrushWindow2, xTopLeft-fadeLyr3CanvasX, yTopLeft-fadeLyr3CanvasY, fadeBarWindowW, fadeBarWindowH, fadeBarWindowR)
			}
			; Bar Background 
			If (fadeBarBack = "true")
				Gdip_Alt_FillRoundedRectangle(Fade_G3, fadeBrushBarBack, xTopLeft+fadeBarX-fadeLyr3CanvasX, yTopLeft+yBar-fadeLyr3CanvasY, fadeBarW, fadeBarH, fadeBarR)
			; Progress Bar
			percentage := romExPercentage
			If percentage > 100
				percentage := 100
			If(fadeBarW*percentage/100<3*fadeBarR)	; avoiding glitch in rounded rectangle drawing when they are too small
				currentRBar := fadeBarR * ((fadeBarW*percentage/100)/(3*fadeBarR))
			Else
				currentRBar := fadeBarR
			If (fadeBarPercentageText = "true")
				Gdip_Alt_TextToGraphics(Fade_G3, round(percentage) . "%", "x" round(xTopLeft+fadeText1X+fadeBarW*percentage/100)-fadeLyr3CanvasX " y" yTopLeft+fadeText1Y-fadeLyr3CanvasY . " " . fadeText1Options, fadeFont, 0, 0)
			If percentage < 100
				{
				If (fadeBarInfoText = "true")
					{
					if (found7z="true") and (7zEnabled = "true") and !7zTempRomExists and use7zAnimation
						Gdip_Alt_TextToGraphics(Fade_G3, fadeText1, "x" xTopLeft+fadeText2X-fadeLyr3CanvasX " y" yTopLeft+fadeText2Y-fadeLyr3CanvasY . " " . fadeText1Options, fadeFont, 0, 0)
					else
						Gdip_Alt_TextToGraphics(Fade_G3, fadeText3, "x" xTopLeft+fadeText2X-fadeLyr3CanvasX " y" yTopLeft+fadeText2Y-fadeLyr3CanvasY . " " . fadeText1Options, fadeFont, 0, 0)
				}
				If !(fadeExtractionTime="Disabled") {
					extractionElapsedTime := (A_TickCount - startTime)//1000
					if ((fadeExtractionTime="Remaining Time") or (fadeExtractionTime="Labeled Remaining Time")){
						if (timerUpdate + 250 < A_TickCount) {
							timerUpdate := A_TickCount
							tempExtractionRemainingTime := extractionElapsedTime *(100 / percentage - 1)
							extractionRemainingTime := ((tempExtractionRemainingTime - extractionRemainingTime) > 0 and (tempExtractionRemainingTime - extractionRemainingTime) < 6)  ? extractionRemainingTime : tempExtractionRemainingTime
							extractionTimeText := (fadeExtractionTime="Labeled Remaining Time") ? "Remaining Time: " . GetTimeString(round(extractionRemainingTime)) : GetTimeString(round(extractionRemainingTime))
							if (stabilityThreshold<4) 
								{
								diff := (prevExtractionRemainingTime - extractionRemainingTime)
								if (diff > 0)
									stabilityThreshold++
								else if (diff < 0)
									stabilityThreshold:=0
								extractionTimeText := "Calculating..."
							}
							prevExtractionRemainingTime := extractionRemainingTime
						}
					} else
						extractionTimeText := (fadeExtractionTime="Labeled Elapsed Time") ? "Elapsed Time: " . GetTimeString(extractionElapsedTime) : GetTimeString(extractionElapsedTime)
					Gdip_Alt_TextToGraphics(Fade_G3, extractionTimeText, "x" xTopLeft+fadeExtractionTimeTextX-fadeLyr3CanvasX " y" yTopLeft+fadeExtractionTimeTextY-fadeLyr3CanvasY . " " . fadeExtractionTimeTextOptions, fadeFont, 0, 0)
				}
			} Else {	; bar is at 100%
				finishedBar:= 1
				If (fadeBarInfoText = "true")
					{
					if (found7z="true") and (7zEnabled = "true") and !7zTempRomExists and use7zAnimation
						Gdip_Alt_TextToGraphics(Fade_G3, fadeText2, "x" xTopLeft+fadeText2X-fadeLyr3CanvasX " y" yTopLeft+fadeText2Y-fadeLyr3CanvasY . " " . fadeText2Options, fadeFont, 0, 0)
					else
						Gdip_Alt_TextToGraphics(Fade_G3, fadeText4, "x" xTopLeft+fadeText2X-fadeLyr3CanvasX " y" yTopLeft+fadeText2Y-fadeLyr3CanvasY . " " . fadeText2Options, fadeFont, 0, 0)
				}
			}
			Gdip_Alt_FillRoundedRectangle(Fade_G3, fadeBrushBar, xTopLeft+fadeBarX-fadeLyr3CanvasX, yTopLeft+yBar-fadeLyr3CanvasY, fadeBarW*percentage/100, fadeBarH,currentRBar)
			Process, Exist, 7z.exe	; This breaks out of 7z.exe If it's no longer running. Sometimes an extraction was very quick or there was an error and we don't want to be stuck in an infinite Loop
			If !ErrorLevel and fadeLyr3Drawn ; bar is at 100% or 7z is already closed or user interrupted fade, so break out
				If (((found7z="true") and (7zEnabled = "true") and (7zSounds = "true") and !(7zTempRomExists) and (use7zAnimation)) and !(hlmode="fade7z"))
					AnimationLoopFinished := true
			If fadeLyr3Drawn and (finishedBar or !fadeInActive)
				AnimationLoopFinished := true
		} Else {
			If fadeLyr3Drawn
				AnimationLoopFinished := true
		}
		Alt_UpdateLayeredWindow(Fade_hwnd3, Fade_hdc3,fadeLyr3CanvasX,fadeLyr3CanvasY, fadeLyr3CanvasW, fadeLyr3CanvasH)
Return

; Simple Hello World Fade Code Tutorial
HelloWorldCustomFadeAnimation:
	;====== Initializing Fade Code
	fadeInActive=1 
	;====== Start Loop to draw Hello World text and update 7z extraction percentage If necessary	
	Loop {	
		Gdip_GraphicsClear(Fade_G3)
		; Updating 7z extraction info
		If (found7z="true") and (7zEnabled = "true") and !7zTempRomExists {
			SetFormat, Float, 3	; don't want to show decimal places in the percentage
			romExPercentageAndFile := COM_Invoke(HLObject, "getExtractionSize", 7zRomPath, 0)	; Get the current file being extracted and size of the 7z Extract Path - (Extraction Size\Progress (0=Accurate Method, 1=Fast Detection Method))
			Loop, Parse, romExPercentageAndFile, |	; StringSplit oddly doesn't work for some unknown reason, must resort to a parsing Loop instead
			{
				If A_Index = 1
				{
					romExCurSize := A_LoopField									; Store bytes extracted
					romExPercentage := (A_LoopField / romExSize) * 100	; Calculate percentage extracted
				} Else If A_Index = 2
					romExFile := A_LoopField
			}
		}
		; Defining text to be shown
		FadeOutputText = Hello World
		If (found7z="true") and (7zEnabled = "true") and !7zTempRomExists
			FadeOutputText := % "Hello World`n Extracting file: " . romExFile . "`nPercentage Extracted: " . romExPercentage . "%" 
		; Calculating the text position centered at the screen
		fadeLyr3CanvasW := MeasureText(FadeOutputText, "s40 Bold","Arial")+20 ; Length of the text
		fadeLyr3CanvasH := 40 ; Font Size	
		If (found7z="true") and (7zEnabled = "true") and !7zTempRomExists 
			fadeLyr3CanvasH := 140
		fadeLyr3CanvasX := (baseScreenWidth-fadeLyr3CanvasW)//2
		fadeLyr3CanvasY := (baseScreenHeight-fadeLyr3CanvasH)//2
		; Creating the GDI+ text element
		Gdip_Alt_TextToGraphics(Fade_G3, FadeOutputText, "x" fadeLyr3CanvasW//2 " y0 Bold Center cFFffffff r4 s40", "Arial", 0, 0)
		; Showing the Hello World text
		Alt_UpdateLayeredWindow(Fade_hwnd3, Fade_hdc3,fadeLyr3CanvasX,fadeLyr3CanvasY, fadeLyr3CanvasW, fadeLyr3CanvasH)	
		; Breaking animation Loop
		Process, Exist, 7z.exe	; This breaks out of 7z.exe If it's no longer running. Sometimes an extraction was very quick or there was an error and we don't want to be stuck in an infinite Loop
		If (!ErrorLevel or (romExPercentage >= 100) or !fadeInActive)	; bar is at 100% or 7z is already closed or user interrupted fade, so break out
			Break	
	}	
	; Assuring that fade remains active for the amount of time defined at the fade delay variable
	If fadeInActive
		GoSub, FadeInDelay	
Return

; Blank animation which can be used with legacy transition
NoAnimation:
	Log("NoAnimation - No Animation selected for Fade")
	GoSub, FadeInDelay	; This must always be at the end of all animation functions. It's a simple timer that will force the GUI to stay up the defined amount of delay If the animation was shorter then said delay.
Return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------ USER CUSTOM ANIMATIONS AND TRANSITIONS BELOW THIS LINE ------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

MyFirstAnimation:
	Log("MyFirstAnimation - Started")
	Log("MyFirstAnimation - Ended")
Return



