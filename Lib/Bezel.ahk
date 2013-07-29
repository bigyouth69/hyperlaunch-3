MCRC=CFA34857
MVersion=1.0.1

BezelStart(Mode="",parent="",angle="",width="",height=""){
	Global
	Log("BezelStart - Started")
	;Defining Bezel Mode
	if !Mode
		bezelMode = Normal
	else if (Mode = "fixResMode")
		bezelMode = fixResMode
	else if (Mode = "ThreeScreensFixRes")
		bezelMode = ThreeScreensFixRes		
	else
		bezelLayoutFile = %Mode%	
	;Checking if game is vertical oriented
	if ((angle<>"") and (angle<>0))
		vertical = true
	;Read Bezel Image
	bezelPath := BezelImagePath("Bezel")
	If bezelPath 
		{
		;Setting bezel aleatory choosed file
		bezelImagesList := []
		Loop, %bezelPath%\Bezel*.png
                bezelImagesList.Insert(A_LoopFileFullPath)
		Random, RndmBezel, 1, % bezelImagesList.MaxIndex()
		bezelImageFile := bezelImagesList[RndmBezel]
		Log("Loading Bezel image: " . bezelImageFile,1)		
		;Setting background aleatory choosed file
		bezelBackgroundfile := BezelImagePath("Background")
		bezelBackgroundsList := []
		Loop, %bezelBackgroundFile%\Background*.png
                bezelBackgroundsList.Insert(A_LoopFileFullPath)
		Random, RndmBezelBackground, 1, % bezelBackgroundsList.MaxIndex()
		bezelBackgroundfile := bezelBackgroundsList[RndmBezelBackground]
		If FileExist(bezelBackgroundFile)
			Log("Loading Background image: " . bezelBackgroundFile,1)
		;Setting overlay aleatory choosed file (only searches overlays at the bezel.png folder)
		bezelOverlaysList := []
		Loop, %bezelPath%\Overlay*.png
                bezelOverlaysList.Insert(A_LoopFileFullPath)
		Random, RndmBezelOverlay, 1, % bezelOverlaysList.MaxIndex()
		bezelOverlayFile := bezelOverlaysList[RndmBezelOverlay]
		If FileExist(bezelOverlayFile)
			Log("Loading Overlay image: " . bezelOverlayFile,1)
		;Setting ini file with bezel coordinates and reading its values
		StringTrimRight, bezelIniFile, bezelImageFile, 4
		bezelIniFile := bezelIniFile . ".ini"
		If !FileExist(bezelIniFile)
			Log("Bezel Ini file not found. Creating the file " . bezelIniFile . " with full screen coordinates. You should edit the ini file to enter the coordinates in pixels of the screen emulator location on the bezel image.",2)
		bezelScreenX1 := IniReadCheck(bezelIniFile, "General", "Bezel Screen Top Left X Coordinate", 0)
		bezelScreenY1 := IniReadCheck(bezelIniFile, "General", "Bezel Screen Top Left Y Coordinate", 0)
		bezelScreenX2 := IniReadCheck(bezelIniFile, "General", "Bezel Screen Bottom Right X Coordinate", A_ScreenWidth)
		bezelScreenY2 := IniReadCheck(bezelIniFile, "General", "Bezel Screen Bottom Right Y Coordinate", A_ScreenHeight)
		Log("Bezel ini file defined screen positions: X1=" . bezelScreenX1 . " Y1=" . bezelScreenY1 . " X2=" . bezelScreenX2 . " Y2=" . bezelScreenY2 ,5)	
		;reading additional screens info
		if (bezelMode = "ThreeScreensFixRes") {
			bezelScreen2X1 := IniReadCheck(bezelIniFile, "General", "Bezel Screen 2 Top Left X Coordinate", 0)
			bezelScreen2Y1 := IniReadCheck(bezelIniFile, "General", "Bezel Screen 2 Top Left Y Coordinate", 0)
			bezelScreen3X1 := IniReadCheck(bezelIniFile, "General", "Bezel Screen 3 Top Left X Coordinate", 0)
			bezelScreen3Y1 := IniReadCheck(bezelIniFile, "General", "Bezel Screen 3 Top Left Y Coordinate", 0)
		}
		;initializing gdi plus
		If !pToken
			pToken := Gdip_Startup()
		; creating bitmap pointers
		bezelBitmap := Gdip_CreateBitmapFromFile(bezelImageFile)
		Gdip_GetImageDimensions(bezelBitmap, bezelImageW, bezelImageH)
		if bezelBackgroundFile
			bezelBackgroundBitmap := Gdip_CreateBitmapFromFile(bezelBackgroundFile)
		if bezelOverlayFile
			bezelOverlayBitmap := Gdip_CreateBitmapFromFile(bezelOverlayFile)
		;Choosing to use layout files or normal bezel
		if bezelLayoutFile	
			{
			If !FileExist( emuPath . "\artwork\" . bezelLayoutFile . ".zip") and !FileExist( emuPath . "\artwork\" . parent . ".zip")
				{
				Log("Creating layout file to work as MESS or MAME bezel image",1)
				FileRemoveDir, %emuPath%\artwork\%bezelLayoutFile%, 1
				scalefactor := if (bezelImageH * round((A_ScreenWidth/bezelImageW),10)>A_ScreenHeight) ? round((A_ScreenHeight/bezelImageH),10) : round((A_ScreenWidth/bezelImageW),10)
				bezelImageW := bezelImageW*scalefactor
				bezelImageH := bezelImageH*scalefactor
				bezelImageX1 :=  ( A_ScreenWidth - bezelImageW ) // 2 
				bezelImageY1 :=  ( A_ScreenHeight - bezelImageH ) // 2 
				bezelImageX2 := bezelImageX1 + bezelImageW
				bezelImageY2 := bezelImageY1 + bezelImageH
				bezelScreenX1 := bezelScreenX1*scalefactor
				bezelScreenY1 := bezelScreenY1*scalefactor
				bezelScreenX2 := bezelScreenX2*scalefactor
				bezelScreenY2 := bezelScreenY2*scalefactor
				bezelScreenW := (bezelScreenX2-bezelScreenX1)
				bezelScreenH := (bezelScreenY2-bezelScreenY1)
				scalefactorScreen := if (height * round((bezelScreenW/width),10)>bezelScreenH) ? round((bezelScreenH/height),10) : round((bezelScreenW/width),10)
				bezelScreenWidth := width*scalefactorScreen
				bezelScreenHeight := height*scalefactorScreen
				bezelScreenX1 := bezelImageX1 + bezelScreenX1 + ( bezelScreenW - bezelScreenWidth ) // 2 
				bezelScreenY1 := bezelImageY1 + bezelScreenY1 + ( bezelScreenH - bezelScreenHeight ) // 2 
				bezelScreenX2 := bezelScreenX1 + bezelScreenWidth
				bezelScreenY2 := bezelScreenY1 + bezelScreenHeight
				bezelScreenX1:=round(bezelScreenX1), bezelScreenY1:=round(bezelScreenY1), bezelScreenX2:=round(bezelScreenX2), bezelScreenY2:=round(bezelScreenY2), bezelImageX1:=round(bezelImageX1), bezelImageY1:=round(bezelImageY1), bezelImageX2:=round(bezelImageX2), bezelImageY2:=round(bezelImageY2), backgroundScaleWidth:=round(backgroundScaleWidth), backgroundScaleHeigth:=round(backgroundScaleHeigth)
				FileCreateDir, %emuPath%\artwork\%bezelLayoutFile%
				Log("Bezel Image Screen Position: BezelImage left=" . bezelImageX1 . " top=" . bezelImageY1 . " right=" . bezelImageX2 . " bottom=" . bezelImageY2  ,5)	
				Log("Bezel Game Screen Position: BezelImage left=" . bezelScreenX1 . " top=" . bezelScreenY1 . " right=" . bezelScreenX2 . " bottom=" . bezelScreenY2 ,5)	
				If bezelOverlayFile
					{
					FileCopy, %bezelOverlayFile%, %emuPath%\artwork\%bezelLayoutFile%\Overlay.png
					overlayElement = <element name="overlay">`n<image file="Overlay.png"/>`n</element>`n
					overlayLocation = <overlay element="overlay">`n<bounds left="%bezelScreenX1%" top="%bezelScreenY1%" right="%bezelScreenX2%" bottom="%bezelScreenY2%"/>`n</overlay>`n
					Log("Bezel Overlay Screen Position: BezelImage left=" . bezelScreenX1 . " top=" . bezelScreenY1 . " right=" . bezelScreenX2 . " bottom=" . bezelScreenY2 ,5)	
				}
				If bezelBackgroundFile
					{
					FileCopy, %bezelBackgroundFile%, %emuPath%\artwork\%bezelLayoutFile%\Background.png
					backgroundElement = <element name="backdrop">`n<image file="background.png"/>`n</element>`n
					backgroundLocation = <backdrop element="backdrop">`n<bounds x="0" y="0" width="%a_ScreenWidth%" height="%a_ScreenHeight%" />`n</backdrop>`n
					Log("Bezel Background Screen Position: BezelImage left=" . 0 . " top=" . 0 . " right=" . backgroundScaleWidth . " bottom=" . backgroundScaleHeigth ,5)
				}
				FileCopy, %bezelImageFile%, %emuPath%\artwork\%bezelLayoutFile%\Bezel.png
				layoutFileContents = <!-- %bezelLayoutFile%.lay -->`n<mamelayout version="2">`n<element name="bezel">`n<image file="Bezel.png"/>`n</element>`n%backgroundElement%%overlayElement%<view name="Bezel Artwork">`n<screen index="0">`n<bounds left="%bezelScreenX1%" top="%bezelScreenY1%" right="%bezelScreenX2%" bottom="%bezelScreenY2%"/>`n</screen>`n<bezel element="bezel">`n<bounds left="%bezelImageX1%" top="%bezelImageY1%" right="%bezelImageX2%" bottom="%bezelImageY2%" />`n</bezel>`n%backgroundLocation%%overlayLocation%</view>`n</mamelayout>					
				FileAppend, %layoutFileContents%, %emuPath%\artwork\%bezelLayoutFile%\%bezelLayoutFile%.lay
				deleteLayoutDir = true
			} else {
				Log("MAME or MESS layout file (" . emuPath . "\artwork\" . bezelLayoutFile . ".zip" . " or " . emuPath . "\artwork\" . parent . ".zip" . ") already exists. Bezel addon will exit without doing any change to the emulator launch.",1)
				Log("BezelStart - Ended")
				Return
			}
		} else {
			; calculating bezel and screen gap coordinates for normal bezel behavior (when the emu allow custom resolutions)
			if (bezelMode = "Normal") {
				Log("Reescalling the bezel image to fill the screen without changing its aspect ratio. The game window will be moved to the screen gap on the bezel image.", 1)
				; Resizing bezel transparent area to the screen resolution (image is stretched to Center screen, keeping aspect)
				widthMaxPerc := ( A_ScreenWidth / bezelImageW )	; get the percentage needed to maximise the image so the higher dimension reaches the screen's edge
				heightMaxPerc := ( A_ScreenHeight / bezelImageH )
				scaleFactor := If (widthMaxPerc < heightMaxPerc) ? widthMaxPerc : heightMaxPerc
				bezelImageW := Round(bezelImageW * scaleFactor)
				bezelImageH := Round(bezelImageH * scaleFactor)
				bezelImageX := Round( ( A_ScreenWidth - bezelImageW ) // 2 )
				bezelImageY := Round( ( A_ScreenHeight - bezelImageH ) // 2 )
				; Defining emulator position 
				bezelScreenX := Round ( bezelImageX + (bezelScreenX1 * scaleFactor) )
				bezelScreenY := Round ( bezelImageY + (bezelScreenY1 * scaleFactor) )
				bezelScreenWidth := Round( (bezelScreenX2-bezelScreenX1)* scaleFactor )
				bezelScreenHeight := Round( (bezelScreenY2-bezelScreenY1)* scaleFactor )
				; Applying offsets to correctly place the emulator if the emulator has extra window components
				bezelScreenX := if bezelLeftOffset ? bezelScreenX - bezelLeftOffset : bezelScreenX
				bezelScreenY := if bezelTopOffset ? bezelScreenY - bezelTopOffset : bezelScreenY
				bezelScreenWidth := if bezelRightOffset ? ( if bezelLeftOffset ? bezelScreenWidth + bezelRightOffset + bezelLeftOffset : bezelScreenWidth + bezelRightOffset ) : ( if bezelLeftOffset ? bezelScreenWidth + bezelLeftOffset : bezelScreenWidth )
				bezelScreenHeight := if bezelTopOffset ? ( if bezelBottomOffset ? bezelScreenHeight + bezelTopOffset + bezelBottomOffset : bezelScreenHeight + bezelTopOffset ) : ( if bezelBottomOffset ? bezelScreenHeight + bezelBottomOffset : bezelScreenHeight )
				bezelScreenX := round(bezelScreenX) , bezelScreenY := round(bezelScreenY), bezelScreenWidth := round(bezelScreenWidth) , bezelScreenHeight := round(bezelScreenHeight)
			}
			;force windowed mode
			if !disableForceFullscreen
				Fullscreen := false
			; creating GUi elements and pointers
			Loop, 3 { 
				If (a_index = 1) {
					Gui, Bezel_GUI%A_Index%: +Disabled -Caption +E0x80000 +OwnDialogs +LastFound +ToolWindow
				} Else If (a_index = 2) {
					Gui, Bezel_GUI%A_Index%: +Disabled -Caption +E0x80000 +OwnDialogs +LastFound +ToolWindow +AlwaysOnTop 
				} Else {
					Gui, Bezel_GUI%A_Index%: -Caption +E0x80000 +OwnDialogs +LastFound +ToolWindow +AlwaysOnTop 
				}
				Gui, Bezel_GUI%A_Index%: Margin,0,0
				Gui, Bezel_GUI%A_Index%: Show,, BezelLayer%A_Index%
				Bezel_hwnd%A_Index% := WinExist()
				Bezel_hbm%A_Index% := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
				Bezel_hdc%A_Index% := CreateCompatibleDC()
				Bezel_obm%A_Index% := SelectObject(Bezel_hdc%A_Index%, Bezel_hbm%A_Index%)
				Bezel_G%A_Index% := Gdip_GraphicsFromhdc(Bezel_hdc%A_Index%)
				Gdip_SetSmoothingMode(Bezel_G%A_Index%, 4)
			}
			; Updating GUI 1 - Background - with image
			If bezelBackgroundFile
				{
				Gdip_DrawImage(Bezel_G1, bezelBackgroundBitmap, 0, 0,A_ScreenWidth,A_ScreenHeight)        
				UpdateLayeredWindow(Bezel_hwnd1, Bezel_hdc1,0,0, A_ScreenWidth, A_ScreenHeight)
				Log("Bezel Background Screen Position: BezelImage left=" . 0 . " top=" . 0 . " right=" . A_ScreenWidth . " bottom=" . A_ScreenHeight ,5)
			}
		}
	}
	Log("BezelStart - Ended")
Return 
}

BezelDraw(){
	Global
	Log("BezelDraw - Started")
	if bezelLayoutFile	
		return
	If bezelPath 
		{
		log("Drawing Bezel Image above the emulator.",1)
		if (bezelMode = "ThreeScreensFixRes") {
			bezelImageX := Round( ( A_ScreenWidth - bezelImageW ) // 2 )
			bezelImageY := Round( ( A_ScreenHeight - bezelImageH ) // 2 )
			bezelScreenW := bezelScreenX2-bezelScreenX1
			bezelScreenH := bezelScreenY2-bezelScreenY1
			; Disable widnows components
			WinSet, Style, -0xC00000, ahk_id %Screen1ID%
			ToggleMenu(Screen1ID)
			WinSet, Style, -0xC40000, ahk_id %Screen1ID%
			WinSet, Style, -0xC00000, ahk_id %Screen2ID%
			WinSet, Style, -0xC40000, ahk_id %Screen2ID%
			WinSet, Style, -0xC00000, ahk_id %Screen3ID%
			WinSet, Style, -0xC40000, ahk_id %Screen3ID%			
			;Moving emulator Window to predefined bezel window 
			bezelScreenX1 := bezelScreenX1 + bezelImageX
			bezelScreenY1 := bezelScreenY1 + bezelImageY
			bezelScreen2X1 := bezelScreen2X1 + bezelImageX
			bezelScreen2Y1 := bezelScreen2Y1 + bezelImageY
			bezelScreen3X1 := bezelScreen3X1 + bezelImageX
			bezelScreen3Y1 := bezelScreen3Y1 + bezelImageY
			Log("Emulator Screen 1 Position: left=" . bezelScreenX1 . " top=" . bezelScreenY1 . " width=" . bezelScreenW . " height=" . bezelScreenH ,5)
			Log("Emulator Screen 2 Position: left=" . bezelScreen2X1 . " top=" . bezelScreen2Y1 ,5)
			Log("Emulator Screen 3 Position: left=" . bezelScreen3X1 . " top=" . bezelScreen3Y1 ,5)			
			WinMove, ahk_id %Screen2ID%, , %bezelScreen2X1%, %bezelScreen2Y1%
			WinMove, ahk_id %Screen3ID%, , %bezelScreen3X1%, %bezelScreen3Y1%
			timeout := A_TickCount
			loop 
				{
				WinMove, ahk_id %Screen1ID%, , %bezelScreenX1%, %bezelScreenY1%, %bezelScreenW%, %bezelScreenH%
				WinGetPos, X, Y, W, H, ahk_id %Screen1ID%
				if (X=bezelScreenX1) and (X=bezelScreenY1) and (X=bezelScreenW) and (X=bezelScreenH)
					break
				if(timeout<A_TickCount-2000)
                    break
				sleep, 20
			}
			;Drawing Bezel GUI
			Gdip_DrawImage(Bezel_G3, bezelBitmap, bezelImageX, bezelImageY,bezelImageW,bezelImageH)        
			UpdateLayeredWindow(Bezel_hwnd3, Bezel_hdc3,0,0, A_ScreenWidth, A_ScreenHeight)
			Log("Bezel Image Screen Position: BezelImage left=" . bezelImageX . " top=" . bezelImageY . " right=" . (bezelImageX+bezelImageW) . " bottom=" . (bezelImageY+bezelImageH)  ,5)	
			Log("Bezel Game Screen Position: BezelImage left=" . bezelScreenX . " top=" . bezelScreenY . " right=" . (bezelScreenX+bezelScreenWidth) . " bottom=" . (bezelScreenY+bezelScreenHeight) ,5)	
			return
		}
		WinGet emulatorID, ID, A
		if (bezelMode = "fixResMode") {  ; Define coordinates for emulators that does not support custom made resolutions. 
			Log("Emulator does not support custom made resolution. Game screen will be centered at the emulator resolution and the bezel png will be drawn around it. The bezel image will be croped if its resolution is bigger them the screen resolution.",1)
			timeout := A_TickCount
			loop 
				{
				WinGetPos, bezelScreenX, bezelScreenY, bezelScreenWidth, bezelScreenHeight, A
				if bezelScreenX and bezelScreenY and bezelScreenWidth and bezelScreenHeight
					break
				if(timeout<A_TickCount-2000)
                    break
			}
			Log("Emulator Screen Position: left=" . bezelScreenX . " top=" . bezelScreenY . " width=" . bezelScreenWidth . " height=" . bezelScreenHeight ,5)
			bezelScreenWidth := if bezelRightOffset ? ( if bezelLeftOffset ? bezelScreenWidth - bezelRightOffset - bezelLeftOffset : bezelScreenWidth - bezelRightOffset ) : ( if bezelLeftOffset ? bezelScreenWidth - bezelLeftOffset : bezelScreenWidth )
			bezelScreenHeight := if bezelTopOffset ? ( if bezelBottomOffset ? bezelScreenHeight - bezelTopOffset - bezelBottomOffset : bezelScreenHeight - bezelTopOffset ) : ( if bezelBottomOffset ? bezelScreenHeight - bezelBottomOffset : bezelScreenHeight )
			bezelScreenX:= Round((A_ScreenWidth-bezelScreenWidth)/2)
			bezelScreenY:= Round((A_ScreenHeight-bezelScreenHeight)/2) 
			bezelScreenX := if bezelLeftOffset ? bezelScreenX - bezelLeftOffset : bezelScreenX
			bezelScreenY := if bezelTopOffset ? bezelScreenY - bezelTopOffset : bezelScreenY
			xScaleFactor := (bezelScreenWidth)/(bezelScreenX2-bezelScreenX1)
			yScaleFactor := (bezelScreenHeight)/(bezelScreenY2-bezelScreenY1)
			bezelImageW := Round(bezelImageW * xScaleFactor)
			bezelImageH := Round(bezelImageH * yScaleFactor) 
			bezelImageX := Round(A_ScreenWidth/2-(bezelScreenX2-bezelScreenX1)*xScaleFactor/2-bezelScreenX1*xScaleFactor)
			bezelImageY := Round(A_ScreenHeight/2-(bezelScreenY2-bezelScreenY1)*yScaleFactor/2-bezelScreenY1*yScaleFactor)
		}
		Log("Bezel Screen Offset: left=" . bezelLeftOffset . " top=" . bezelTopOffset . " right=" . bezelRightOffset . " bottom=" . bezelBottomOffset ,1)
		; Going to the label on the module to enable or disable emulator window manipulation codes to hide windows components, ...  
		var := "BezelLabel"
		If IsLabel(var)
			gosub, %var%
		; list of windows manipulation options that can be enabled/disabled on the BezelLabel (they are enable as default)
		If !disableHideTitleBar
			WinSet, Style, -0xC00000, A
		If !disableHideToggleMenu
			ToggleMenu(emulatorID)
		If !disableHideBorder
			WinSet, Style, -0xC40000, A
		;Moving emulator Window to predefined bezel window 
		If !disableWinMove
			{
			bezelScreenX := round(bezelScreenX) , bezelScreenY := round(bezelScreenY), bezelScreenWidth := round(bezelScreenWidth) , bezelScreenHeight := round(bezelScreenHeight)
			if (bezelMode = "fixResMode")
				WinMove, , , %bezelScreenX%, %bezelScreenY%
			else
				WinMove, , , %bezelScreenX%, %bezelScreenY%, %bezelScreenWidth%, %bezelScreenHeight%
		}
		;Drawing Bezel GUI
		Gdip_DrawImage(Bezel_G3, bezelBitmap, bezelImageX, bezelImageY,bezelImageW,bezelImageH)        
		UpdateLayeredWindow(Bezel_hwnd3, Bezel_hdc3,0,0, A_ScreenWidth, A_ScreenHeight)
		Log("Bezel Image Screen Position: BezelImage left=" . bezelImageX . " top=" . bezelImageY . " right=" . (bezelImageX+bezelImageW) . " bottom=" . (bezelImageY+bezelImageH)  ,5)	
		Log("Bezel Game Screen Position: BezelImage left=" . bezelScreenX . " top=" . bezelScreenY . " right=" . (bezelScreenX+bezelScreenWidth) . " bottom=" . (bezelScreenY+bezelScreenHeight) ,5)	
		;Drawing Overlay Image above screen
		If bezelOverlayFile
			{
			Gdip_DrawImage(Bezel_G2, bezelOverlayBitmap, 0, 0,bezelScreenWidth,bezelScreenHeight)        
			UpdateLayeredWindow(Bezel_hwnd2, Bezel_hdc2,bezelScreenX,bezelScreenY, bezelScreenWidth, bezelScreenHeight)
			Log("Bezel Overlay Screen Position: BezelImage left=" . bezelScreenX . " top=" . bezelScreenY . " right=" . (bezelScreenX+bezelScreenWidth) . " bottom=" . (bezelScreenY+bezelScreenHeight) ,5)	
		}
	}
	Log("BezelDraw - Ended")
Return
}


BezelExit(){
	Global
	Log("BezelExit - Started")
	if bezelLayoutFile
		{
		if deleteLayoutDir
			FileRemoveDir, %emuPath%\artwork\%bezelLayoutFile%, 1
		return
	}
	If bezelPath 
		{
		log("Removing bezel image components to exit HyperLaunch.",1)
		;clearing Bezel GUIs
		Gdip_GraphicsClear(Bezel_G1)
		UpdateLayeredWindow(Bezel_hwnd1, Bezel_hdc1,0,0, A_ScreenWidth, A_ScreenHeight)
		Gdip_GraphicsClear(Bezel_G2)
		UpdateLayeredWindow(Bezel_hwnd2, Bezel_hdc2,0,0, A_ScreenWidth, A_ScreenHeight)
		Gdip_GraphicsClear(Bezel_G3)
		UpdateLayeredWindow(Bezel_hwnd3, Bezel_hdc3,0,0, A_ScreenWidth, A_ScreenHeight)
		;Deleting pointers and destroying GUis
		loop, 3 {
			SelectObject(Bezel_hdc%A_Index%, Bezel_obm%A_Index%)
			DeleteObject(Bezel_hbm%A_Index%)
			DeleteDC(Bezel_hdc%A_Index%)
			Gdip_DeleteGraphics(Bezel_G%A_Index%)
			Gui, Bezel_GUI%A_Index%: Destroy
		}
		Gdip_DisposeImage(bezelBitmap)
		if bezelBackgroundFile
			Gdip_DisposeImage(bezelBackgroundBitmap)
		if bezelOverlayFile
			Gdip_DisposeImage(bezelOverlayBitmap) 
	}
	Log("BezelExit - Ended")
Return
}

BezelImagePath(filename)
{
	Global HLMediaPath, SystemName, dbName, vertical
	If FileExist( HLMediaPath . "\Bezels\" . SystemName . "\" . dbName . "\" . filename "*.png")
		bezelPath := HLMediaPath . "\Bezels\" . SystemName . "\" . dbName
	Else If ( (vertical = "true") and (FileExist(HLMediaPath . "\Bezels\" . SystemName . "\_Default\Vertical\" . filename "*.png")) )
		bezelPath := HLMediaPath . "\Bezels\" . SystemName . "\_Default\Vertical"
	Else If FileExist(HLMediaPath . "\Bezels\" . SystemName . "\_Default\Horizontal\" . filename "*.png")
		bezelPath := HLMediaPath . "\Bezels\" . SystemName . "\_Default\Horizontal"
	Else If FileExist( HLMediaPath . "\Bezels\" . SystemName . "\_Default\" . filename "*.png")
		bezelPath := HLMediaPath . "\Bezels\" . SystemName . "\_Default"
	Else If FileExist( HLMediaPath . "\Bezels\_Default\" . filename "*.png")
		bezelPath := HLMediaPath . "\Bezels\_Default"
	Else
		log("Bezel is enabled, however none of the bellow valid " . filename . " files exist: " . "`n`t`t`t`t`t" . HLMediaPath . "\Bezels\" . SystemName . "\" . dbName . "\" . filename "*.png" . "`n`t`t`t`t`t" . HLMediaPath . "\Bezels\" . SystemName . "\_Default\Vertical\" . filename "*.png" . "`n`t`t`t`t`t" . HLMediaPath . "\Bezels\" . SystemName . "\_Default\Horizontal\" . filename "*.png" . "`n`t`t`t`t`t" . HLMediaPath . "\Bezels\" . SystemName . "\_Default\" . filename "*.png" . "`n`t`t`t`t`t" . HLMediaPath . "\Bezels\_Default\" . filename "*.png",2)

return bezelPath
}