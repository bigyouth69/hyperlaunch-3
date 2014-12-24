
;Alternative Gdip function wrappers with support for graphics rotation

Alt_UpdateLayeredWindow(hwnd, hdc,X="", Y="",W="",H="",Alpha=255){
	Global screenRotationAngle, xTranslation, yTranslation, baseScreenWidth, baseScreenHeight
	if (W > baseScreenWidth - X)
		W := baseScreenWidth - X
	if (H > baseScreenHeight - Y)
		H := baseScreenHeight - Y
	if screenRotationAngle
		WindowCoordUpdate(X,Y,W,H)
Return UpdateLayeredWindow(hwnd, hdc, X, Y, W, H, Alpha)	
}

Gdip_Alt_TextToGraphics(pGraphics, Text, Options, Font="Arial", Width="", Height="", Measure=0){
	Global screenRotationAngle
	if screenRotationAngle
		{
		RegExMatch(Options, "i)X([\-\d\.]+)(p*)", xpos)
		RegExMatch(Options, "i)Y([\-\d\.]+)(p*)", ypos)
		X := SubStr(xpos, 2), Y := SubStr(ypos, 2)
		graphicsCoordUpdate(pGraphics,X,Y)
		Options := RegExReplace(Options, "i)X([\-\d\.]+)(p*)", "x" . X)
		Options := RegExReplace(Options, "i)Y([\-\d\.]+)(p*)", "y" . Y)
	}
Return Gdip_TextToGraphics(pGraphics, Text, Options, Font, Width, Height, Measure)
}

Gdip_Alt_FillRectangle(pGraphics, pBrush, X, Y, W, H){
	Global screenRotationAngle
	if screenRotationAngle
		GraphicsCoordUpdate(pGraphics,X,Y)
Return Gdip_FillRectangle(pGraphics, pBrush, X, Y, W, H)
}
	
Gdip_Alt_DrawImage(pGraphics, pBitmap, dx="", dy="", dw="", dh="", sx="", sy="", sw="", sh="", Matrix=1){
	Global screenRotationAngle
	if screenRotationAngle
		GraphicsCoordUpdate(pGraphics,dx,dy)
Return Gdip_DrawImage(pGraphics, pBitmap, dx, dy, dw, dh, sx, sy, sw, sh, Matrix)
}	

Gdip_Alt_FillRoundedRectangle(pGraphics, pBrush, x, y, w, h, r){
	Global screenRotationAngle
	if screenRotationAngle
		GraphicsCoordUpdate(pGraphics,X,Y)
Return Gdip_FillRoundedRectangle(pGraphics, pBrush, x, y, w, h, r)
}

Gdip_Alt_DrawRoundedRectangle(pGraphics, pPen, x, y, w, h, r){
	Global screenRotationAngle
	if screenRotationAngle
		GraphicsCoordUpdate(pGraphics,X,Y)
Return Gdip_DrawRoundedRectangle(pGraphics, pPen, x, y, w, h, r)
}	
	
Gdip_Alt_GetRotatedDimensions(Width, Height, Angle, ByRef RWidth, ByRef RHeight)
{
	pi := 3.14159, TAngle := Angle*(pi/180)
	RWidth := Round(Abs(Width*Cos(TAngle))+Abs(Height*Sin(TAngle)))
	RHeight := Round(Abs(Width*Sin(TAngle))+Abs(Height*Cos(Tangle)))
}

WindowCoordUpdate(ByRef X, ByRef Y, ByRef W, ByRef H){
	global screenRotationAngle, xTranslation, yTranslation
	Gdip_Alt_GetRotatedDimensions(W, H, screenRotationAngle, rW, rH)
	W := rW, H := rH 
	Gdip_Alt_GetRotatedDimensions(X, Y, screenRotationAngle, rotX, rotY)
	X := if xTranslation ? xTranslation - rotX - W : rotX	
	Y := if yTranslation ? yTranslation - rotY - H : rotY		
}

GraphicsCoordUpdate(pGraphics,ByRef x,ByRef y){
	global xTranslation, yTranslation, baseScreenWidth, baseScreenHeight, pGraphicsUpd
	x := if yTranslation ? baseScreenWidth - pGraphicsUpd[pGraphics,"W"] + x : x	
	y := if xTranslation ? baseScreenHeight - pGraphicsUpd[pGraphics,"H"] + y : y
}

pGraphUpd(pGraphics,W,H){
	Global pGraphicsUpd, baseScreenWidth, baseScreenHeight
	if !pGraphicsUpd
		pGraphicsUpd := []
		pGraphicsUpd[pGraphics,"W"]:=W
		pGraphicsUpd[pGraphics,"H"]:=H
}