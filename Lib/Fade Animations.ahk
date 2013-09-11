MCRC=AA51CC2D
MVersion=1.0.4

; Default transition animation used for Fade_In
DefaultAnimateFadeIn(direction,time){
	Global hdc1,1_ID,hdc2,2_ID,hdc3,3_ID,hdc4,4_ID,hdc5,5_ID
	Global fadeLyr2PicW,fadeLyr2PicH,fadeLyr2PicX,fadeLyr2PicY,fadeLyr2PicPadX,fadeLyr2PicPadY
	Global fadeLyr3CanvasX,fadeLyr3CanvasY,fadeLyr3CanvasW,fadeLyr3CanvasH
	Global fadeLyr4PicX,fadeLyr4PicY,fadeLyr4PicW,fadeLyr4PicH,FadeLayer4AnimFilesAr
	Log("DefaultAnimateFadeIn - Started")
	startTime := A_TickCount
	If direction = in
	Log("DefaultAnimateFadeIn - Drawing First FadeIn Image.", 1)
	Loop{
		t := ((TimeElapsed := A_TickCount-startTime) < time) ? (If direction="in" ? 255*(timeElapsed/time) : 255*(1-(timeElapsed/time))) : (If direction="in" ? 255 : 0)
		UpdateLayeredWindow(1_ID, hdc1, 0, 0, A_ScreenWidth, A_ScreenHeight, t)	; to fade in, set transparency to 0 at first
		UpdateLayeredWindow(2_ID, hdc2, fadeLyr2PicX + fadeLyr2PicPadX, fadeLyr2PicY + fadeLyr2PicPadY, fadeLyr2PicW, fadeLyr2PicH, t)
		If direction = out
		{
			UpdateLayeredWindow(5_ID, hdc5,0,0, A_ScreenWidth, A_ScreenHeight, t)
			UpdateLayeredWindow(3_ID, hdc3,fadeLyr3CanvasX,fadeLyr3CanvasY, fadeLyr3CanvasW, fadeLyr3CanvasH, t)
			If FadeLayer4AnimFilesAr.MaxIndex() > 0 {
				SetTimer, FadeLayer4Anim, Off 
				UpdateLayeredWindow(4_ID, hdc4,fadeLyr4PicX,fadeLyr4PicY, fadeLyr4PicW, fadeLyr4PicH, t)
			}
		}
		If (direction = "in" && t >= 255) or (direction = "out" && t <= 0)
			Break
	}
	Log("DefaultAnimateFadeIn - Ended")
}

; Default transition animation used for Fade_Out
DefaultAnimateFadeOut(direction,time){
	Global outhdc1,out1_ID,fadeOutBlackScreenEnabled,FadeOutBlackScreen_ID
	Log("DefaultAnimateFadeOut - Started")
	If fadeOutBlackScreenEnabled = true
	{	Log("DefaultAnimateFadeOut - Destroying FadeOutBlackScreen",4)
		AnimateWindow(FadeOutBlackScreen_ID, "out", "fade", 100) ; animate FadeOutBlackScreen out quickly
		Gui, FadeOutBlackScreen:Destroy	; destroy the temporary FadeOutBlackScreen
	}
	startTime := A_TickCount
	Loop{
		t := ((TimeElapsed := A_TickCount-startTime) < time) ? (If direction="in" ? 255*(timeElapsed/time) : 255*(1-(timeElapsed/time))) : (If direction="in" ? 255 : 0)
		UpdateLayeredWindow(out1_ID, outhdc1, 0, 0, A_ScreenWidth, A_ScreenHeight, t)	; to fade in, set transparency to 0 at first
		If (direction = "in" && t >= 255) or (direction = "out" && t <= 0)
			Break
	}
	Log("DefaultAnimateFadeOut - Ended")
}

; Legacy fadein animation for use when gdi does not work with an emulator. Jpgs are not supported and will not show on this legacy gui
LegacyFadeInTransition(direction,time){
	Global 1_ID,fadeLyr1PicW,fadeLyr1PicH,fadeInLyr1File,fadeLyr1Color,fadeLyr1AlignImage
	Global G2,hdc2,2_ID,G3,hdc3,3_ID,G4,hdc4,4_ID,G5,hdc5,5_ID
	Global fadeLyr2PicW,fadeLyr2PicH,fadeLyr2PicX,fadeLyr2PicY,fadeLyr2PicPadX,fadeLyr2PicPadY
	Global fadeLyr3CanvasX,fadeLyr3CanvasY,fadeLyr3CanvasW,fadeLyr3CanvasH
	Global fadeLyr4PicX,fadeLyr4PicY,fadeLyr4PicW,fadeLyr4PicH,FadeLayer4AnimFilesAr
	Log("LegacyFadeInTransition - Started")
	StringTrimLeft,fadeLyr1ColorNoAlpha,fadeLyr1Color,2	; for legacy gui, we need to trim the alpha from the color as it's not supported
	; msgbox, fadeInLyr1File: %fadeInLyr1File%`nfadeLyr1PicW: %fadeLyr1PicW%`nfadeLyr1PicH: %fadeLyr1PicH%`n1_ID: %1_ID%`ndirection: %direction%`ntime: %time%`n

	If direction = in
	{	Log("LegacyFadeInTransition - Drawing First FadeIn Image.", 1)
		Gui, Fade_GUI1:Color, %fadeLyr1ColorNoAlpha%
		GetBGPicPosition(fadeLyr1PicXNew,fadeLyr1PicYNew,fadeLyr1PicWNew,fadeLyr1PicHNew,fadeLyr1PicW,fadeLyr1PicH,fadeLyr1AlignImage)	; get the background pic's new position and size
		If (fadeLyr1AlignImage = "Stretch and Lose Aspect")
			Gui, Fade_GUI1:Add, Picture,w%A_ScreenWidth% h%A_ScreenHeight% x0 y0, %fadeInLyr1File%
		Else If (fadeLyr1AlignImage = "Stretch and Keep Aspect" Or fadeLyr1AlignImage = "Center Width" Or fadeLyr1AlignImage = "Center Height" Or fadeLyr1AlignImage = "Align to Bottom Left" Or fadeLyr1AlignImage = "Align to Bottom Right")
			Gui, Fade_GUI1:Add, Picture,w%fadeLyr1PicWNew% h%fadeLyr1PicHNew% x%fadeLyr1PicXNew% y%fadeLyr1PicYNew%, %fadeInLyr1File%
		Else If (fadeLyr1AlignImage = "Center")	; original image size and aspect
			Gui, Fade_GUI1:Add, Picture,w%fadeLyr1PicW% h%fadeLyr1PicH% x%fadeLyr1PicXNew% y%fadeLyr1PicYNew%, %fadeInLyr1File%
		Else If (fadeLyr1AlignImage = "Align to Top Right")	; place the pic so the top right corner matches the screen's top right corner
			Gui, Fade_GUI1:Add, Picture,w%fadeLyr1PicWNew% h%fadeLyr1PicHNew% x%fadeLyr1PicXNew% y0, %fadeInLyr1File%
		Else	; place the pic so the top left corner matches the screen's top left corner, also the default
			Gui, Fade_GUI1:Add, Picture,w%fadeLyr1PicWNew% h%fadeLyr1PicHNew% x0 y0, %fadeInLyr1File%
		Gui, Fade_GUI1:Show, x0 y0 h%A_ScreenHeight% w%A_ScreenWidth% Hide
	}
	If direction = out
	{	SetTimer, FadeLayer4Anim, Off
		Gdip_GraphicsClear(G2)
		Gdip_GraphicsClear(G3)
		Gdip_GraphicsClear(G4)
		Gdip_GraphicsClear(G5)
		UpdateLayeredWindow(2_ID, hdc2, fadeLyr2PicX + fadeLyr2PicPadX, fadeLyr2PicY + fadeLyr2PicPadY, fadeLyr2PicW, fadeLyr2PicH)
		UpdateLayeredWindow(3_ID, hdc3,fadeLyr3CanvasX,fadeLyr3CanvasY, fadeLyr3CanvasW, fadeLyr3CanvasH)
		UpdateLayeredWindow(4_ID, hdc4,fadeLyr4PicX,fadeLyr4PicY, fadeLyr4PicW, fadeLyr4PicH)
		UpdateLayeredWindow(5_ID, hdc5,0,0, A_ScreenWidth, A_ScreenHeight)
	}		
	AnimateWindow(1_ID, direction, "fade", time) ; animate in fadeLayer1
	If direction = in
		UpdateLayeredWindow(2_ID, hdc2, fadeLyr2PicX + fadeLyr2PicPadX, fadeLyr2PicY + fadeLyr2PicPadY, fadeLyr2PicW, fadeLyr2PicH)
	; AnimateWindow(1_ID, direction, "slide bt", time) ; slide
	Log("LegacyFadeInTransition - Ended")
}

; Legacy fadeout animation for use when gdi does not work with an emulator. Jpgs are not supported and will not show on this legacy gui
LegacyFadeOutTransition(direction,time){
	Global out1_ID,lyr1OutPicW,lyr1OutPicH,lyr1OutFile,fadeLyr1Color,fadeLyr1AlignImage,fadeOutBlackScreenEnabled,FadeOutBlackScreen_ID
	Log("LegacyFadeOutTransition - Started")
	StringTrimLeft,fadeLyr1ColorNoAlpha,fadeLyr1Color,2	; for legacy gui, we need to trim the alpha from the color as it's not supported

	If direction = in
	{
		Gui, Fade_GUI8:Color, %fadeLyr1ColorNoAlpha%
		GetBGPicPosition(fadeLyr1OutPicXNew,fadeLyr1OutPicYNew,fadeLyr1OutPicWNew,fadeLyr1OutPicHNew,lyr1OutPicW,lyr1OutPicH,fadeLyr1AlignImage)	; get the background pic's new position and size
		If (fadeLyr1AlignImage = "Stretch and Lose Aspect")
			Gui, Fade_GUI8:Add, Picture,w%A_ScreenWidth% h%A_ScreenHeight% x0 y0, %lyr1OutFile%
		Else If (fadeLyr1AlignImage = "Stretch and Keep Aspect" Or fadeLyr1AlignImage = "Center Width" Or fadeLyr1AlignImage = "Center Height" Or fadeLyr1AlignImage = "Align to Bottom Left" Or fadeLyr1AlignImage = "Align to Bottom Right")
			Gui, Fade_GUI8:Add, Picture,w%fadeLyr1OutPicWNew% h%fadeLyr1OutPicHNew% x%fadeLyr1OutPicXNew% y%fadeLyr1OutPicYNew%, %lyr1OutFile%
		Else If (fadeLyr1AlignImage = "Center")	; original image size and aspect
			Gui, Fade_GUI8:Add, Picture,w%lyr1OutPicW% h%lyr1OutPicH% x%fadeLyr1OutPicXNew% y%fadeLyr1OutPicYNew%, %lyr1OutFile%
		Else If (fadeLyr1AlignImage = "Align to Top Right")	; place the pic so the top right corner matches the screen's top right corner
			Gui, Fade_GUI8:Add, Picture,w%fadeLyr1OutPicWNew% h%fadeLyr1OutPicHNew% x%fadeLyr1OutPicXNew% y0, %lyr1OutFile%
		Else	; place the pic so the top left corner matches the screen's top left corner, also the default
			Gui, Fade_GUI8:Add, Picture,w%fadeLyr1OutPicWNew% h%fadeLyr1OutPicHNew% x0 y0, %lyr1OutFile%
		Gui, Fade_GUI8:Show, x0 y0 h%A_ScreenHeight% w%A_ScreenWidth% Hide
	}
	If fadeOutBlackScreenEnabled = true
	{	Log("LegacyFadeOutTransition - Destroying FadeOutBlackScreen",4)
		AnimateWindow(FadeOutBlackScreen_ID, "out", "fade", 100) ; animate FadeOutBlackScreen out quickly
		Gui, FadeOutBlackScreen:Destroy	; destroy the temporary FadeOutBlackScreen
	}
	AnimateWindow(out1_ID, direction, "fade", time) ; animate in fadeLayer1
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
	fadeInLyr3File := GetFadePicFile("Layer",3)
	IfExist, % fadeInLyr3File
		{
		fadeLyr3Pic := Gdip_CreateBitmapFromFile(fadeInLyr3File)
		Gdip_GetImageDimensions(fadeLyr3Pic, fadeLyr3PicW, fadeLyr3PicH)
		fadeLyr3PicW := fadeLyr3PicW * fadeLyr3Adjust
		fadeLyr3PicH := fadeLyr3PicH * fadeLyr3Adjust
		GetFadePicPosition(fadeLyr3PicX,fadeLyr3PicY,fadeLyr3X,fadeLyr3Y,fadeLyr3PicW,fadeLyr3PicH,fadeLyr3Pos)
	}
	;Layer 3 padding
	If fadeLyr3PicX < A_ScreenWidth//2
		fadeLyr3PicX := fadeLyr3PicX+fadeLyr3PicPad
	Else 
		fadeLyr3PicX := fadeLyr3PicX-fadeLyr3PicPad
	If fadeLyr3PicY < A_ScreenHeight//2
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
	hbm4 := CreateDIBSection(fadeLyr4PicW,fadeLyr4PicH)
	hdc4 := CreateCompatibleDC(), obm4 := SelectObject(hdc4, hbm4)
	G4 := Gdip_GraphicsFromhdc(hdc4), Gdip_SetInterpolationMode(G4, 7)
	;Layer 4 padding
	If fadeLyr4PicX < A_ScreenWidth//2
		fadeLyr4PicX := fadeLyr4PicX+fadeLyr4PicPad
	Else 
		fadeLyr4PicX := fadeLyr4PicX-fadeLyr4PicPad
	If fadeLyr4PicY < A_ScreenHeight//2
		fadeLyr4PicX := fadeLyr4PicX+fadeLyr4PicPad
	Else 
		fadeLyr4PicX := fadeLyr4PicX-fadeLyr4PicPad
	;====== Loading Bar options
	If ((fadeLyr3Type = "bar") or (fadeLyr3Type = "ImageAndBar")) and (found7z="true") and (7zEnabled = "true") and !7zTempRomExists and use7zAnimation
		{
		;Creating Progress Bar Brushes
		fadeBrushWindow1 := Gdip_CreateLineBrushFromRect(0, 0, fadeBarWindowW, fadeBarWindowH, 0xff555555, 0xff050505)
		fadeBrushWindow2 := Gdip_BrushCreateHatch(0xff000000, 0x00000000, fadeBarWindowHatchStyle)
		fadeBrushBarBack := Gdip_BrushCreateSolid("0x" . fadeBarBackColor)
		fadeBrushBar := Gdip_BrushCreateHatch(0x00000000, "0x" . fadeBarColor, fadeBarHatchStyle)
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
			xTopLeft := If fadeBarWindowX ? fadeBarWindowX : (A_ScreenWidth-fadeBarWindowW)//2	; calculates where the X of the topleft corner of the bar window needs to be
			yTopLeft := If fadeBarWindowY ? fadeBarWindowY : (A_ScreenHeight-fadeBarWindowH)//2	; calculates where the Y of the topleft corner of the bar window needs to be
		} Else {
			xTopLeft := If fadeBarWindowX ? fadeBarWindowX : (A_ScreenWidth-fadeBarWindowW)//2+fadeBarXOffset	; calculates where the X of the topleft corner of the bar window needs to be
			yTopLeft := If fadeBarWindowY ? fadeBarWindowY : (A_ScreenHeight-fadeBarWindowH)//2+fadeBarYOffset	; calculates where the Y of the topleft corner of the bar window needs to be
		}
	} Else {
		xTopLeft := fadeLyr3PicX
		yTopLeft := fadeLyr3PicY
	}
	;====== Redefining Layer 3 to cover image plus bar size
	; Defining Layer 3 update area
	If (fadeLyr3Type = "image") {
		fadeLyr3CanvasX := fadeLyr3PicX
		fadeLyr3CanvasY := fadeLyr3PicY
		fadeLyr3CanvasW := fadeLyr3PicW
		fadeLyr3CanvasH := fadeLyr3PicH
	} Else If (fadeLyr3Type = "bar") {
		fadeLyr3CanvasX := xTopLeft
		fadeLyr3CanvasY := yTopLeft
		fadeLyr3CanvasW := fadeBarWindowW
		fadeLyr3CanvasH := fadeBarWindowH
	} Else If (fadeLyr3Type = "ImageAndBar") {
		fadeLyr3CanvasX := fadeLyr3PicX < xTopLeft ? fadeLyr3PicX : xTopLeft
		fadeLyr3CanvasY := fadeLyr3PicY < yTopLeft ? fadeLyr3PicY : yTopLeft 
		fadeLyr3CanvasW := fadeLyr3PicX+fadeLyr3PicW-fadeLyr3CanvasX > xTopLeft+fadeBarWindowW-fadeLyr3CanvasX ? fadeLyr3PicX+fadeLyr3PicW-fadeLyr3CanvasX : xTopLeft+fadeBarWindowW-fadeLyr3CanvasX
		fadeLyr3CanvasH := fadeLyr3PicY+fadeLyr3PicH-fadeLyr3CanvasY > yTopLeft+fadeBarWindowH-fadeLyr3CanvasY ? fadeLyr3PicY+fadeLyr3PicH-fadeLyr3CanvasY : yTopLeft+fadeBarWindowH-fadeLyr3CanvasY
	}
	; Creating GDI+ Layer 3 Drawn section
	hbm3 := CreateDIBSection(fadeLyr3CanvasW,fadeLyr3CanvasH)
	hdc3 := CreateCompatibleDC(), obm3 := SelectObject(hdc3, hbm3)
	G3 := Gdip_GraphicsFromhdc(hdc3), Gdip_SetInterpolationMode(G3, 7)	
	;====== Load database name
	If !GameXMLInfo
		Gosub ReadHyperSpinXML
	;====== Rom Info Text
	romInfoText := [] ; 1,1 - romInfoText ; 1,2 romInfoTextContent ; 1,3 - romInfoTextFormatedContent ; 1,4 - romInfoTextOptions ; 1,5 - romInfoBitmap ; 1,6 - romInfoBitmapX ; 1,7 - romInfoBitmapY ; 1,8 - romInfoBitmapW ; 1,9 - romInfoBitmapH
	Displacement := 0
	Loop, parse, fadeRomInfoOrder,|,
		{
		romInfoText[A_Index,1] := A_LoopField 
		If (romInfoText[A_Index,1] = "Description") {
			romInfoText[A_Index,2] := XMLDescription
			If  (fadeRomInfoDescription="text with label") {
				romInfoText[A_Index,3] := "Game: " . romInfoText[A_Index,2]
				fadeRomInfoDescription := "text"
			} Else 
				romInfoText[A_Index,3] := romInfoText[A_Index,2]
		} Else If (romInfoText[A_Index,1] = "SystemName") {
			romInfoText[A_Index,2] := systemName
			If  (fadeRomInfoSystemName="text with label") {
				romInfoText[A_Index,3] := "System: " .  romInfoText[A_Index,2]
				fadeRomInfoSystemName := "text"
			} Else 
				romInfoText[A_Index,3] := romInfoText[A_Index,2]
		} Else If (romInfoText[A_Index,1] = "Year") {
			romInfoText[A_Index,2] := XMLYear
			If  (fadeRomInfoYear="text with label") {
				romInfoText[A_Index,3] := "Year: " . romInfoText[A_Index,2]
				fadeRomInfoYear := "text"
			} Else 
				romInfoText[A_Index,3] := romInfoText[A_Index,2]
		} Else If (romInfoText[A_Index,1] = "Manufacturer") {
			romInfoText[A_Index,2] := XMLManufacturer
			If  (fadeRomInfoManufacturer="text with label") {
				romInfoText[A_Index,3] := "Manufacturer: " . romInfoText[A_Index,2]
				fadeRomInfoManufacturer := "text"
			 } Else 
				romInfoText[A_Index,3] := romInfoText[A_Index,2]
		} Else If (romInfoText[A_Index,1] = "Genre") {
			romInfoText[A_Index,2] := XMLGenre
			If  (fadeRomInfoGenre="text with label") {
				romInfoText[A_Index,3] := "Genre: " . romInfoText[A_Index,2]
				fadeRomInfoGenre := "text"
			} Else 
				romInfoText[A_Index,3] := romInfoText[A_Index,2]
		} Else If (romInfoText[A_Index,1] = "Rating") {
			romInfoText[A_Index,2] := XMLRating
			If  (fadeRomInfoRating="text with label") {
				romInfoText[A_Index,3] := "Rating: " . romInfoText[A_Index,2]
				fadeRomInfoRating := "text"
			} Else 
				romInfoText[A_Index,3] := romInfoText[A_Index,2]
		}
	}
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
			If (%currentRomInfoTextType%="Text") 
				romInfoText[A_Index,4] := fadeRomInfoText%A_Index%Options 
			Else If (%currentRomInfoTextType%="Image") {
				RegExMatch(fadeRomInfoText%A_Index%Options, "i)X([\-\d\.]+)(p*)", UserDefinedX) ; getting x coordinates
				RegExMatch(fadeRomInfoText%A_Index%Options, "i)Y([\-\d\.]+)(p*)", UserDefinedY) ; getting y coordinates
				stringtrimLeft, UserDefinedX, UserDefinedX, 1
				stringtrimLeft, UserDefinedY, UserDefinedY, 1
				romInfoText[A_Index,6] := UserDefinedX
				romInfoText[A_Index,7] := UserDefinedY
				If !UserDefinedX
					romInfoText[A_Index,6] := (A_ScreenWidth-romInfoText[A_Index,8])//2
				If !UserDefinedY
					romInfoText[A_Index,7] := (A_ScreenHeight-romInfoText[A_Index,9])//2
			}
		}
	} Else {
		Loop, 6
			{
			currentRomInfoTextType := "fadeRomInfo" . romInfoText[A_Index,1] 
			If (%currentRomInfoTextType%="Text") { ;parsing text options to remove x, y, W, H
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
			romInfoText[2,4] := "x" . A_ScreenWidth-fadeRomInfoTextMargin . " y" .  fadeRomInfoTextMargin . " Right " . romInfoText[2,4]
			romInfoText[2,6] := A_ScreenWidth-fadeRomInfoTextMargin-romInfoText[2,8]
			romInfoText[2,7] := fadeRomInfoTextMargin
			romInfoText[3,4] := "x" . fadeRomInfoTextMargin . " y" . A_ScreenHeight-maxromInfoTextSize-fadeRomInfoTextMargin . " Left " . romInfoText[3,4]
			romInfoText[3,6] := fadeRomInfoTextMargin
			romInfoText[3,7] := A_ScreenHeight-fadeRomInfoTextMargin-romInfoText[3,9]
			romInfoText[4,4] := "x" . A_ScreenWidth-fadeRomInfoTextMargin . " y" . A_ScreenHeight-maxromInfoTextSize-fadeRomInfoTextMargin . " Right " . romInfoText[4,4]
			romInfoText[4,6] := A_ScreenWidth-fadeRomInfoTextMargin-romInfoText[4,8]
			romInfoText[4,7] := A_ScreenHeight-fadeRomInfoTextMargin-romInfoText[4,9]
			romInfoText[5,4] := "x" . A_ScreenWidth//2 . " y" . fadeRomInfoTextMargin . " Center " . romInfoText[5,4]
			romInfoText[5,6] := (A_ScreenWidth-romInfoText[5,8])//2
			romInfoText[5,7] := fadeRomInfoTextMargin
			romInfoText[6,4] := "x" . A_ScreenWidth//2 . " y" . A_ScreenHeight-maxromInfoTextSize-fadeRomInfoTextMargin . " Center " . romInfoText[6,4]
			romInfoText[6,6] := (A_ScreenWidth-romInfoText[6,8])//2
			romInfoText[6,7] := A_ScreenHeight-fadeRomInfoTextMargin-romInfoText[6,9]
		} Else {
			Loop, 6
				{
				currentRomInfoTextType := "fadeRomInfo" . romInfoText[A_Index,1] 
				If ((fadeRomInfoTextPlacement="bottomRight") or (fadeRomInfoTextPlacement="bottomLeft")) {
					If (%currentRomInfoTextType%="Text") 
						Displacement := Displacement + (maxromInfoTextSize+10)
					Else If (%currentRomInfoTextType%="Image") 
						Displacement := Displacement + ( romInfoText[A_Index,9] +10)
				}
				If (fadeRomInfoTextPlacement="topRight") {
					romInfoText[A_Index,4] := "x" . A_ScreenWidth-fadeRomInfoTextMargin . " y" . Displacement+fadeRomInfoTextMargin . " Right " . romInfoText[A_Index,4]	
					romInfoText[A_Index,6] := A_ScreenWidth-fadeRomInfoTextMargin-romInfoText[A_Index,8]
					romInfoText[A_Index,7] := Displacement+fadeRomInfoTextMargin
				} Else If (fadeRomInfoTextPlacement="topLeft") {
					romInfoText[A_Index,4] := "x" . fadeRomInfoTextMargin . " y" . Displacement+fadeRomInfoTextMargin . " Left " . romInfoText[A_Index,4]
					romInfoText[A_Index,6] := fadeRomInfoTextMargin
					romInfoText[A_Index,7] := Displacement+fadeRomInfoTextMargin
				} Else If (fadeRomInfoTextPlacement="bottomRight") {
					romInfoText[A_Index,4] := "x" . A_ScreenWidth-fadeRomInfoTextMargin . " y" . A_ScreenHeight-Displacement-fadeRomInfoTextMargin . " Right " . romInfoText[A_Index,4]
					romInfoText[A_Index,6] := A_ScreenWidth-fadeRomInfoTextMargin-romInfoText[A_Index,8]
					romInfoText[A_Index,7] :=  A_ScreenHeight-fadeRomInfoTextMargin-Displacement
				} Else If (fadeRomInfoTextPlacement="bottomLeft") {
					romInfoText[A_Index,4] := "x" . fadeRomInfoTextMargin . " y" . A_ScreenHeight-Displacement-fadeRomInfoTextMargin . " Left " . romInfoText[A_Index,4]
					romInfoText[A_Index,6] := fadeRomInfoTextMargin
					romInfoText[A_Index,7] := A_ScreenHeight-fadeRomInfoTextMargin-Displacement
				}
				If ((fadeRomInfoTextPlacement="topRight") or (fadeRomInfoTextPlacement="topLeft")) {
					If (%currentRomInfoTextType%="Text") 
						Displacement := Displacement + (maxromInfoTextSize+10)
					Else If (%currentRomInfoTextType%="Image") 
						Displacement := Displacement + ( romInfoText[A_Index,9] +10)
				}
			}
		}
	}
	; Creating GDI+ Layer 5 Drawn section
	hbm5 := CreateDIBSection(A_ScreenWidth,A_ScreenHeight)
	hdc5 := CreateCompatibleDC(), obm5 := SelectObject(hdc5, hbm5)
	G5 := Gdip_GraphicsFromhdc(hdc5), Gdip_SetInterpolationMode(G5, 7)
	;====== Statistics Info Text
	Displacement := 0
	If  (statisticsEnabled = "true"){
		If ((fadeStats_Number_of_Times_Played<>disabled) or (fadeStats_Last_Time_Played<>disabled) or (fadeStats_Average_Time_Played<>disabled) or (fadeStats_Total_Time_Played<>disabled) or (fadeStats_System_Total_Played_Time<>disabled) or (fadeStats_Total_Global_Played_Time<>disabled) ){
			;Load statistics
			If !romTable
				romTable:=CreateRomTable(dbName)
			Totaldiscsofcurrentgame:=romTable.MaxIndex()
			If (Totaldiscsofcurrentgame>1) 
				DescriptionNameWithoutDisc := romTable[1,4]
			Else
				DescriptionNameWithoutDisc := XMLDescription 
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
						fadeStats_Number_of_Times_Played := "text"
					} Else 
						statsInfoText[A_Index,3] := statsInfoText[A_Index,2]
				} Else If (statsInfoText[A_Index,1] = "Last_Time_Played") {
					statsInfoText[A_Index,2] := Last_Time_Played
					If  (fadeStats_Last_Time_Played="text with label") {
						statsInfoText[A_Index,3] := "Last Time Played: " .  statsInfoText[A_Index,2]
						fadeStats_Last_Time_Played := "text"
					} Else 
						statsInfoText[A_Index,3] := statsInfoText[A_Index,2]
				} Else If (statsInfoText[A_Index,1] = "Average_Time_Played") {
					statsInfoText[A_Index,2] := Average_Time_Played
					If  (fadeStats_Average_Time_Played="text with label") {
						statsInfoText[A_Index,3] := "Average Time Played: " . statsInfoText[A_Index,2]
						fadeStats_Average_Time_Played := "text"
					} Else 
						statsInfoText[A_Index,3] := statsInfoText[A_Index,2]
				} Else If (statsInfoText[A_Index,1] = "Total_Time_Played") {
					statsInfoText[A_Index,2] := Total_Time_Played
					If  (fadeStats_Total_Time_Played="text with label") {
						statsInfoText[A_Index,3] := "Total Time Played: " . statsInfoText[A_Index,2]
						fadeStats_Total_Time_Played := "text"
					} Else 
						statsInfoText[A_Index,3] := statsInfoText[A_Index,2]
				} Else If (statsInfoText[A_Index,1] = "System_Total_Played_Time") {
					statsInfoText[A_Index,2] := System_Total_Played_Time
					If  (fadeStats_System_Total_Played_Time="text with label") {
						statsInfoText[A_Index,3] := "System Total Played Time: " . statsInfoText[A_Index,2]
						fadeStats_System_Total_Played_Time := "text"
					} Else 
						statsInfoText[A_Index,3] := statsInfoText[A_Index,2]
				} Else If (statsInfoText[A_Index,1] = "Total_Global_Played_Time") {
					statsInfoText[A_Index,2] := Total_Global_Played_Time
					If  (fadeStats_Total_Global_Played_Time="text with label") {
						statsInfoText[A_Index,3] := "Total Global Played Time: " . statsInfoText[A_Index,2]
						fadeStats_Total_Global_Played_Time := "text"
					} Else 
						statsInfoText[A_Index,3] := statsInfoText[A_Index,2]
				}
			}
			If (fadeStatsInfoTextPlacement="User Defined"){
				Loop, 6
					{
					currentStatsInfoTextType := "fadeStats_" . statsInfoText[A_Index,1]  
					If (%currentStatsInfoTextType%="Text") 
						statsInfoText[A_Index,4] := fadeStatsInfoText%A_Index%Options 
				}
			} Else {
				Loop, 6
					{
					currentStatsInfoTextType := "fadeStats_" . statsInfoText[A_Index,1]  
					If (%currentStatsInfoTextType%="Text") { ;parsing text options to remove x, y, W, H
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
					statsInfoText[2,4] := "x" . A_ScreenWidth-fadeStatsInfoTextMargin . " y" .  fadeStatsInfoTextMargin . " Right " . statsInfoText[2,4]
					statsInfoText[3,4] := "x" . fadeStatsInfoTextMargin . " y" . A_ScreenHeight-maxstatsInfoTextSize-fadeStatsInfoTextMargin . " Left " . statsInfoText[3,4]
					statsInfoText[4,4] := "x" . A_ScreenWidth-fadeStatsInfoTextMargin . " y" . A_ScreenHeight-maxstatsInfoTextSize-fadeStatsInfoTextMargin . " Right " . statsInfoText[4,4]
					statsInfoText[5,4] := "x" . A_ScreenWidth//2 . " y" . fadeStatsInfoTextMargin . " Center " . statsInfoText[5,4]
					statsInfoText[6,4] := "x" . A_ScreenWidth//2 . " y" . A_ScreenHeight-maxstatsInfoTextSize-fadeStatsInfoTextMargin . " Center " . statsInfoText[6,4]
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
							statsInfoText[A_Index,4] := "x" . A_ScreenWidth-fadeStatsInfoTextMargin . " y" . Displacement+fadeStatsInfoTextMargin . " Right " . statsInfoText[A_Index,4]	
						Else If (fadestatsInfoTextPlacement="topLeft")
							statsInfoText[A_Index,4] := "x" . fadeStatsInfoTextMargin . " y" . Displacement+fadeStatsInfoTextMargin . " Left " . statsInfoText[A_Index,4]
						Else If (fadestatsInfoTextPlacement="bottomRight")
							statsInfoText[A_Index,4] := "x" . A_ScreenWidth-fadeStatsInfoTextMargin . " y" . A_ScreenHeight-Displacement-fadeStatsInfoTextMargin . " Right " . statsInfoText[A_Index,4]
						Else If (fadestatsInfoTextPlacement="bottomLeft")
							statsInfoText[A_Index,4] := "x" . fadeStatsInfoTextMargin . " y" . A_ScreenHeight-Displacement-fadeStatsInfoTextMargin . " Left " . statsInfoText[A_Index,4]
						If ((fadestatsInfoTextPlacement="topRight") or (fadestatsInfoTextPlacement="topLeft")) {
							if statsInfoText[A_Index,2] 
								Displacement := Displacement + (maxstatsInfoTextSize+10)
						}
					}
				}
			}
		}
	}
	;====== Begin of animation Loop
	; Drawing text info
	Loop, 6
		{
		currentRomInfoTextType := "fadeRomInfo" . romInfoText[A_Index,1] 
		If (%currentRomInfoTextType%="Text") {
			If romInfoText[A_Index,2] 
				Gdip_TextToGraphics(G5, romInfoText[A_Index,3], romInfoText[A_Index,4], fadeFont, 0, 0)
		} Else If (%currentRomInfoTextType%="Image") {
			If romInfoText[A_Index,2] 
				Gdip_DrawImage(G5, romInfoText[A_Index,5], romInfoText[A_Index,6], romInfoText[A_Index,7], romInfoText[A_Index,8], romInfoText[A_Index,9])
		}
	}
	; Drawing Statistics text info
	If  (statisticsEnabled = "true"){
		Loop, 6
			{
			currentStatsInfoTextType := "fadeStats_" . statsInfoText[A_Index,1] 
			If (%currentStatsInfoTextType%="Text")
				If statsInfoText[A_Index,2] 
					Gdip_TextToGraphics(G5, statsInfoText[A_Index,3], statsInfoText[A_Index,4], fadeFont, 0, 0)
		}
	}
	UpdateLayeredWindow(5_ID, hdc5,0,0, A_ScreenWidth, A_ScreenHeight)
	; drawing animated gif
	If GifAnimation
		SetTimer, FadeLayer4Anim, -1
	Else If (FadeLayer4AnimFilesAr.MaxIndex() > 0)
		SetTimer, FadeLayer4Anim, %fadeLyr4FPS%
	timeToMax := fadeLyr3Speed / fadeLyr3Repeat 	; calculate how long layer 3 needs to take to show 100% of the image
	startTime := A_TickCount
	SetFormat, Float, 3.2
	;checking for extraction sound
	If (found7z="true") and (7zEnabled = "true") and (7zSounds = "true") and !7zTempRomExists and use7zAnimation {
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
	}
	; start the animation Loop
	Loop {	
		Gdip_GraphicsClear(G3)
		;====== Updating 7z extraction info
		If (found7z="true") and (7zEnabled = "true")  and !7zTempRomExists and use7zAnimation {
			If not (fadeLyr3Type = image and fadeLyr3ImgFollow7zProgress = false) {
				romExPercentageAndFile := COM_Invoke(HLObject, "getExtractionSize", 7zRomPath, 0)	; Get the current file being extracted and size of the 7z Extract Path - (Extraction Progress (Accurate Method))
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
		}
		;====== Drawing layer 3 image
		If (fadeLyr3Type = "Image") or (fadeLyr3Type = "ImageAndBar")
			{
			IfExist, % fadeInLyr3File
				{
				If fadeLyr3Repeat != 0	; Only Loop animation If user does not want a static image
					{
					If (found7z="true") and (7zEnabled = "true") and (fadeLyr3ImgFollow7zProgress="true") and !7zTempRomExists and use7zAnimation {
						Gdip_DrawImage(G3, fadeLyr3Pic, fadeLyr3PicX-fadeLyr3CanvasX, fadeLyr3PicY-fadeLyr3CanvasY, fadeLyr3PicW*romExPercentage/100, fadeLyr3PicH, 0, 0, (fadeLyr3PicW//fadeLyr3Adjust)*romExPercentage/100, fadeLyr3PicH//fadeLyr3Adjust)	; draw layer 3 image onto screen on layer 3 and adjust the size If set
						If (romExPercentage >= 100){
							If 7zEnded
								fadeLyr3Drawn := true
							7zEnded=1	; Often on small archives, 7z.exe ends so fast, it doesn't give us the chance to show 100% completion. By looping a 2nd time after 7z.exe is closed, the 2nd Loop after 7zEnded, sets the percentage to 100%.
						}
					} Else {
						If (t1 < 100 and fadeLyr3DrawnTimes<fadeLyr3Repeat) {
							t1 := ((timeElapsed := A_TickCount - startTime) < timeToMax) ? timeElapsed / timeToMax : 100
							Gdip_DrawImage(G3, fadeLyr3Pic, fadeLyr3PicX-fadeLyr3CanvasX, fadeLyr3PicY-fadeLyr3CanvasY, fadeLyr3PicW*t1, fadeLyr3PicH, 0, 0, fadeLyr3PicW//fadeLyr3Adjust*t1, fadeLyr3PicH//fadeLyr3Adjust)	; draw layer 3 image onto screen on layer 3 and adjust the size If set
						} Else {
							startTime := A_TickCount	; reset on each Loop
							fadeLyr3DrawnTimes++
							t1 := 0
							If (fadeLyr3DrawnTimes>=fadeLyr3Repeat) {
								fadeLyr3Drawn := true
								Gdip_DrawImage(G3, fadeLyr3Pic, fadeLyr3PicX-fadeLyr3CanvasX, fadeLyr3PicY-fadeLyr3CanvasY, fadeLyr3PicW, fadeLyr3PicH, 0, 0, fadeLyr3PicW//fadeLyr3Adjust, fadeLyr3PicH//fadeLyr3Adjust)	; draw layer 3 image onto screen on layer 3 and adjust the size If set
							}
						}
					}
				} Else If !fadeLyr3Drawn {	; If fadeLyr3Repeat is set to 0 (a static image), just show it, rather then animate
					Gdip_DrawImage(G3, fadeLyr3Pic, fadeLyr3PicX-fadeLyr3CanvasX, fadeLyr3PicY-fadeLyr3CanvasY, fadeLyr3PicW, fadeLyr3PicH, 0, 0, fadeLyr3PicW//fadeLyr3Adjust, fadeLyr3PicH//fadeLyr3Adjust)	; draw layer 3 image onto screen on layer 3 and adjust the size If set
					fadeLyr3Drawn := true
				}
			} Else {
				fadeLyr3Drawn := true
			}
		} Else {
			fadeLyr3Drawn := true
		}
		;====== Drawing Bar
		If (found7z="true") and (7zEnabled = "true")  and !7zTempRomExists and use7zAnimation {
			If (fadeLyr3Type = "bar") or (fadeLyr3Type = "ImageAndBar")
				{
				; Bar Window
				If fadeBarWindow=true 
					{
					Gdip_FillRoundedRectangle(G3, fadeBrushWindow1, xTopLeft-fadeLyr3CanvasX, yTopLeft-fadeLyr3CanvasY, fadeBarWindowW, fadeBarWindowH, fadeBarWindowR)
					Gdip_FillRoundedRectangle(G3, fadeBrushWindow2, xTopLeft-fadeLyr3CanvasX, yTopLeft-fadeLyr3CanvasY, fadeBarWindowW, fadeBarWindowH, fadeBarWindowR)
				}
				; Bar Background 
				If (fadeBarBack = "true")
					Gdip_FillRoundedRectangle(G3, fadeBrushBarBack, xTopLeft+fadeBarX-fadeLyr3CanvasX, yTopLeft+yBar-fadeLyr3CanvasY, fadeBarW, fadeBarH, fadeBarR)
				; Progress Bar
				percentage := romExPercentage
				If percentage > 100
					percentage := 100
				If(fadeBarW*percentage/100<3*fadeBarR)	; avoiding glitch in rounded rectangle drawing when they are too small
					currentRBar := fadeBarR * ((fadeBarW*percentage/100)/(3*fadeBarR))
				Else
					currentRBar := fadeBarR
				If (fadeBarPercentageText = "true")
					Gdip_TextToGraphics(G3, round(percentage) . "%", "x" round(xTopLeft+fadeText1X+fadeBarW*percentage/100)-fadeLyr3CanvasX " y" yTopLeft+fadeText1Y-fadeLyr3CanvasY . " " . fadeText1Options, fadeFont, 0, 0)
				If percentage < 100
					{
					If (fadeBarInfoText = "true")
						Gdip_TextToGraphics(G3, fadeText1, "x" xTopLeft+fadeText2X-fadeLyr3CanvasX " y" yTopLeft+fadeText2Y-fadeLyr3CanvasY . " " . fadeText1Options, fadeFont, 0, 0)
				} Else {	; bar is at 100%
					finishedBar:= 1
					If (fadeBarInfoText = "true")
						Gdip_TextToGraphics(G3, fadeText2, "x" xTopLeft+fadeText2X-fadeLyr3CanvasX " y" yTopLeft+fadeText2Y-fadeLyr3CanvasY . " " . fadeText2Options, fadeFont, 0, 0)
				}
				Gdip_FillRoundedRectangle(G3, fadeBrushBar, xTopLeft+fadeBarX-fadeLyr3CanvasX, yTopLeft+yBar-fadeLyr3CanvasY, fadeBarW*percentage/100, fadeBarH,currentRBar)
				Process, Exist, 7z.exe	; This breaks out of 7z.exe If it's no longer running. Sometimes an extraction was very quick or there was an error and we don't want to be stuck in an infinite Loop
				If !ErrorLevel and fadeLyr3Drawn ; bar is at 100% or 7z is already closed or user interrupted fade, so break out
					Break
				If fadeLyr3Drawn and (finishedBar or !fadeInActive)
				Break
			} Else {
				If fadeLyr3Drawn
					Break
			}
		} Else {
			If fadeLyr3Drawn
				Break
		}
		UpdateLayeredWindow(3_ID, hdc3,fadeLyr3CanvasX,fadeLyr3CanvasY, fadeLyr3CanvasW, fadeLyr3CanvasH)
		; Start Layer 4 animation timer If there is a Layer 4 image
		Sleep, 5	; This slows down how often the animation gets updated (a pseudo FPS)
	}
	;stoping extraction sound and checking for complete sound
	If (found7z="true") and (7zEnabled = "true") and (7zSounds = "true") and !7zTempRomExists and use7zAnimation {
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
	}
	UpdateLayeredWindow(3_ID, hdc3,fadeLyr3CanvasX,fadeLyr3CanvasY, fadeLyr3CanvasW, fadeLyr3CanvasH)
	Log("DefaultFadeAnimation - Ended")
	If fadeInActive
		GoSub, FadeInDelay	; This must always be at the end of all animation functions. It's a simple timer that will force the GUI to stay up the defined amount of delay If the animation was shorter then said delay.
Return



; Simple Hello World Fade Code Tutorial
HelloWorldCustomFadeAnimation:
	;====== Initializing Fade Code
	fadeInActive=1 
	;====== Creating GDI+ Layer 3 Drawn section
	hbm3 := CreateDIBSection(A_ScreenWidth,A_ScreenHeight)
	hdc3 := CreateCompatibleDC(), obm3 := SelectObject(hdc3, hbm3)
	G3 := Gdip_GraphicsFromhdc(hdc3), Gdip_SetInterpolationMode(G3, 7)	
	;====== Start Loop to draw Hello World text and update 7z extraction percentage If necessary	
	Loop {	
		Gdip_GraphicsClear(G3)
		; Updating 7z extraction info
		If (found7z="true") and (7zEnabled = "true") and !7zTempRomExists {
			SetFormat, Float, 3	; don't want to show decimal places in the percentage
			romExPercentageAndFile := COM_Invoke(HLObject, "getExtractionSize", 7zRomPath, 1000)	; Get the current file being extracted and size of the 7z Extract Path - (Extraction Progress (Accurate Method))
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
		fadeLyr3CanvasW := MeasureText(0,FadeOutputText,"Arial","40","Bold")+20 ; Length of the text
		fadeLyr3CanvasH := 40 ; Font Size	
		If (found7z="true") and (7zEnabled = "true") and !7zTempRomExists 
			fadeLyr3CanvasH := 140
		fadeLyr3CanvasX := (A_ScreenWidth-fadeLyr3CanvasW)//2
		fadeLyr3CanvasY := (A_ScreenHeight-fadeLyr3CanvasH)//2
		; Creating the GDI+ text element
		Gdip_TextToGraphics(G3, FadeOutputText, "x" fadeLyr3CanvasW//2 " y0 Bold Center cFFffffff r4 s40", "Arial", 0, 0)
		; Showing the Hello World text
		UpdateLayeredWindow(3_ID, hdc3,fadeLyr3CanvasX,fadeLyr3CanvasY, fadeLyr3CanvasW, fadeLyr3CanvasH)	
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
