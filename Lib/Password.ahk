MCRC=1A21D41D
MVersion=1.0.0

InputPasswordMenu() {
	Global
	Log("InputPasswordMenu - Started")
	If !pToken := Gdip_Startup(){	; Start gdi+
		MsgBox % "Gdiplus failed to start. Please ensure you have gdiplus on your system"
		ExitApp
	}
	passwordMenuWidth=800
	passwordMenuHeight=224
	passwordMenuTextSize=20
	passwordPenWidth=7
	passwordMenuCornerRadius=30
	passwordMenuMargin=30
	passwordMenuImageWidth=125
	passwordMenuInputRadius=15
	passwordMenuInputMargin1=25
	passwordMenuInputMargin2=40
	passwordMenuInputCorrection=5
	Gdip_Alt_GetRotatedDimensions(A_ScreenWidth, A_ScreenHeight, screenRotationAngle, baseScreenWidth, baseScreenHeight)
	Gdip_GetRotatedTranslation(baseScreenWidth, baseScreenHeight, screenRotationAngle, xTranslation, yTranslation)
	xTranslation:=round(xTranslation), yTranslation:=round(yTranslation)
	XBaseRes := 1920, YBaseRes := 1080
    if (((A_screenWidth < A_screenHeight) and ((screenRotationAngle=0) or (screenRotationAngle=180))) or ((A_screenWidth > A_screenHeight) and ((screenRotationAngle=90) or (screenRotationAngle=270))))
        XBaseRes := 1080, YBaseRes := 1920
    if !passwordXScale 
		passwordXScale := baseScreenWidth/XBaseRes
    if !passwordYScale
		passwordYScale := baseScreenHeight/YBaseRes
	OptionScale(passwordMenuWidth, passwordXScale)
	OptionScale(passwordMenuHeight, passwordYScale)
	OptionScale(passwordMenuTextSize, passwordYScale)
	OptionScale(passwordPenWidth, passwordXScale)
	OptionScale(passwordMenuCornerRadius, passwordXScale)
	OptionScale(passwordMenuMargin, passwordXScale)
	OptionScale(passwordMenuImageWidth, passwordXScale)
	OptionScale(passwordMenuInputRadius, passwordXScale)
	OptionScale(passwordMenuInputMargin1, passwordXScale)
	OptionScale(passwordMenuInputMargin2, passwordXScale)
	OptionScale(passwordMenuInputCorrection, passwordYScale)	
	;Create Black Backgroung
	Loop, 2 {
		If (a_index = 1)
			Gui, Password_GUI%A_Index%: +Disabled -Caption +E0x80000 +OwnDialogs +LastFound +ToolWindow +AlwaysOnTop
		Else
			Gui, Password_GUI%A_Index%: +Disabled -Caption +E0x80000 +OwnDialogs +LastFound +ToolWindow +AlwaysOnTop
		Gui, Password_GUI%A_Index%: Margin,0,0
		Gui, Password_GUI%A_Index%: Show,, PasswordLayer%A_Index%
		Password_hwnd%A_Index% := WinExist()
		Password_hbm%A_Index% := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
		Password_hdc%A_Index% := CreateCompatibleDC()
		Password_obm%A_Index% := SelectObject(Password_hdc%A_Index%, Password_hbm%A_Index%)
		Password_G%A_Index% := Gdip_GraphicsFromhdc(Password_hdc%A_Index%)
		Gdip_SetSmoothingMode(Password_G%A_Index%, 4)
		Gdip_TranslateWorldTransform(Password_G%A_Index%, xTranslation, yTranslation)
		Gdip_RotateWorldTransform(Password_G%A_Index%, screenRotationAngle)
	}
	pGraphUpd(Password_G1,baseScreenWidth,baseScreenHeight)
	pGraphUpd(Password_G2,baseScreenWidth,baseScreenHeight)
	pBrush := Gdip_BrushCreateSolid("0xFF000000")	; Painting the background color
	wBrush := Gdip_BrushCreateSolid("0xFFFFFFFF")	; Passwaord field brush
	Gdip_Alt_FillRectangle(Password_G1, pBrush, -1, -1, baseScreenWidth+1, baseScreenHeight+1)	; draw the background first on layer 1 first, layer order matters!!
	;Create Input Password window
	brushPasswordBackground := Gdip_CreateLineBrushFromRect(0, 0, passwordMenuWidth, passwordMenuHeight, 0xff555555, 0xff050505)
	penPasswordBackground := Gdip_CreatePen(0xffffffff, passwordPenWidth)
	Gdip_Alt_FillRoundedRectangle(Password_G1, brushPasswordBackground, (baseScreenWidth - passwordMenuWidth)//2, (baseScreenHeight - passwordMenuHeight)//2, passwordMenuWidth, passwordMenuHeight, passwordMenuCornerRadius)
	Gdip_Alt_DrawRoundedRectangle(Password_G1, penPasswordBackground, (baseScreenWidth - passwordMenuWidth)//2, (baseScreenHeight - passwordMenuHeight)//2, passwordMenuWidth, passwordMenuHeight, passwordMenuCornerRadius)
	PasswordBitmap := Gdip_CreateBitmapFromFile(HLMediaPath . "\Menu Images\HyperLaunch\Password.png" )
	Gdip_Alt_DrawImage(Password_G1,PasswordBitmap, round((baseScreenWidth - passwordMenuWidth)//2 + passwordMenuMargin),round((baseScreenHeight - passwordMenuHeight)//2 + passwordMenuMargin),passwordMenuImageWidth,passwordMenuImageWidth)
	Gdip_Alt_TextToGraphics(Password_G1, "Password:", "x" round((baseScreenWidth-passwordMenuWidth)//2+passwordMenuMargin+passwordMenuImageWidth) " y" round((baseScreenHeight-passwordMenuHeight)//2+passwordMenuMargin)-passwordMenuTextSize " Left vCenter cffffffff r4 s" passwordMenuTextSize " Bold","Arial", passwordMenuWidth - 2*passwordMenuMargin - passwordMenuImageWidth , passwordMenuHeight - 2*passwordMenuMargin)
	inputPasswordtextLengthInfo := MeasureText("Password:", "Left r4 s" . passwordMenuTextSize . " Bold","Arial")
	passwordInputFieldX := round((baseScreenWidth-passwordMenuWidth)//2+passwordMenuMargin+passwordMenuImageWidth + inputPasswordtextLengthInfo + passwordMenuInputMargin1 )
	passwordInputFieldY := round((baseScreenHeight-passwordMenuHeight)//2+passwordMenuMargin) + 2*passwordMenuTextSize
	passwordInputFieldW := passwordMenuWidth - passwordMenuMargin - passwordMenuImageWidth - inputPasswordtextLengthInfo - passwordMenuInputMargin1 - passwordMenuInputMargin2
	passwordInputFieldH := 2*passwordMenuTextSize
	Gdip_Alt_FillRoundedRectangle(Password_G1, wBrush, passwordInputFieldX , passwordInputFieldY, passwordInputFieldW, passwordInputFieldH, passwordMenuInputRadius)
	pwStartTime := A_TickCount
	Loop {	; fade in
		pwTime := ((TimeElapsed := A_TickCount-pwStartTime) < 300) ? (255*(timeElapsed/300)) : 255
		Alt_UpdateLayeredWindow(Password_hwnd1,Password_hdc1, 0, 0, baseScreenWidth, baseScreenHeight,pwTime)
		If pwTime >= 255
			Break
	}
	XHotKeywrapper(navSelectKey,"PassSelect","ON")
	XHotKeywrapper(navUpKey,"PassUp","ON")
	XHotKeywrapper(navDownKey,"PassDown","ON")
	XHotKeywrapper(navLeftKey,"PassLeft","ON")
	XHotKeywrapper(navRightKey,"PassRight","ON")
    XHotKeywrapper(navP2SelectKey,"PassP2Select","ON") 
    XHotKeywrapper(navP2UpKey,"PassP2Up","ON")
    XHotKeywrapper(navP2DownKey,"PassP2Down","ON")
	XHotKeywrapper(navP2LeftKey,"PassP2Left","ON")
    XHotKeywrapper(navP2RightKey,"PassP2Right","ON")
	XHotKeywrapper(exitEmulatorKey,"PassExitMenu")
	Loop
		If inputPasswordMenuExit
			Break
	Log("InputPasswordMenu - Ended")
	Return
}

DestroyInputPasswordMenu() {
	Global
	Log("DestroyInputPasswordMenu - Started")
	mapStartTime := A_TickCount
	Loop{	; fading out the launch menu
		tMap := ((mapTimeElapsed := A_TickCount-mapStartTime) < fadeOutDuration) ? 255*(1-(mapTimeElapsed/fadeOutDuration)) : 0
		Alt_UpdateLayeredWindow(Password_hwnd1,Password_hdc1, 0, 0, baseScreenWidth, baseScreenHeight,tMap)
		Alt_UpdateLayeredWindow(Password_hwnd2,Password_hdc2, 0, 0, baseScreenWidth, baseScreenHeight,tMap)
		If tMap <= 0
			Break
	}
	Loop, 2 {
        SelectObject(Password_hdc%a_index%, Password_obm%a_index%)
		DeleteObject(Password_hbm%a_index%)
		DeleteDC(Password_hdc%a_index%)
		Gdip_DeleteGraphics(Password_G%a_index%)
		Gui, inputPasswordGUI%a_index%: Destroy
	}
	Gdip_DeleteBrush(pBrush), Gdip_DeleteBrush(wBrush), Gdip_DeleteBrush(brushPasswordBackground)
	Gdip_DeletePen(penPasswordBackground)
	Gdip_DisposeImage(PasswordBitmap)
	Log("DestroyInputPasswordMenu - Ended")
	Return
}


PassP2Select:
PassSelect:
	If (launchPasswordCheck = 1) {
		Log("User entered the correct password.")
		Gdip_Alt_TextToGraphics(Password_G2, "Correct Password! Launching Game!", "x" passwordInputFieldX+passwordInputFieldW//2 " y" passwordInputFieldY + 3*passwordMenuTextSize + passwordMenuInputCorrection " Center cff00ff00 r4 s" passwordMenuTextSize " Bold","Arial")
		Alt_UpdateLayeredWindow(Password_hwnd2,Password_hdc2, 0, 0, baseScreenWidth, baseScreenHeight)
		DestroyInputPasswordMenu()	
		inputPasswordMenuExit := true	
	} Else {
		Log("User entered an incorrect password.")
		UserInput := 
		maskedUserInput := 
		Gdip_GraphicsClear(Password_G2)
		Gdip_Alt_TextToGraphics(Password_G2, maskedUserInput, "x" passwordInputFieldX+passwordMenuInputRadius " y" round((baseScreenHeight-passwordMenuHeight)//2+passwordMenuMargin) + 2*passwordMenuTextSize + Round(passwordMenuTextSize/2) + passwordMenuInputCorrection " Left vCenter cff000000 r4 s" passwordMenuTextSize " Bold","Arial")
		Gdip_Alt_TextToGraphics(Password_G2, "Incorrect Password! Please try again!", "x" passwordInputFieldX+passwordInputFieldW//2 " y" passwordInputFieldY + 3*passwordMenuTextSize + passwordMenuInputCorrection " Center cffffff00 r4 s" passwordMenuTextSize " Bold","Arial")
		Alt_UpdateLayeredWindow(Password_hwnd2,Password_hdc2, 0, 0, baseScreenWidth, baseScreenHeight)
	}
Return

PassExitMenu:
	Log("User canceled out the Input Password Menu.")
	DestroyInputPasswordMenu()
	ExitModule()
Return

PassUp:
PassDown:
PassLeft:
PassRight:
PassP2Up:
PassP2Down:
PassP2Left:
PassP2Right:
	passTotalLength++	; keep track of how many keys the user pressed
	currentUserInput := SubStr(A_ThisLabel, 5)
	UserInput := UserInput . currentUserInput
	maskedUserInput := maskedUserInput . "* " 
	Gdip_GraphicsClear(Password_G2)
	Gdip_Alt_TextToGraphics(Password_G2, maskedUserInput, "x" passwordInputFieldX+passwordMenuInputRadius " y" round((baseScreenHeight-passwordMenuHeight)//2+passwordMenuMargin) + 2*passwordMenuTextSize + Round(passwordMenuTextSize/2) + passwordMenuInputCorrection " Left vCenter cff000000 r4 s" passwordMenuTextSize " Bold","Arial")
	Alt_UpdateLayeredWindow(Password_hwnd2,Password_hdc2, 0, 0, baseScreenWidth, baseScreenHeight,pwTime)
	launchPasswordCheck := COM_Invoke(HLObject, "VerifyPassword", UserInput, launchPasswordHash)
	If (launchPasswordCheck = 1)
		Gosub, passSelect
	Else if (passTotalLength >= 16) {
		If hyperlaunchIsExiting	; prevents very fast inputs from triggering ExitModule() more than once
			Return
		Log("The password entered exceeded the maximum length and was incorrect. Returning to your Front End.",3)
		ExitModule()
	}
	; Tooltip, % UserInput
Return
