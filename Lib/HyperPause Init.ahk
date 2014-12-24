MCRC=2870AF42
MVersion=1.0.1

hpKey := xHotKeyVarEdit(hpKey,"hpKey","~","Add")
hpBackToMenuBarKey := xHotKeyVarEdit(hpBackToMenuBarKey,"hpBackToMenuBarKey","~","Remove")
hpZoomInKey := xHotKeyVarEdit(hpZoomInKey,"hpZoomInKey","~","Remove")
hpZoomOutKey := xHotKeyVarEdit(hpZoomOutKey,"hpZoomOutKey","~","Remove")
hpScreenshotKey := xHotKeyVarEdit(hpScreenshotKey,"hpScreenshotKey","~","Remove")

XHotKeywrapper(hpKey,"TogglePauseMenuStatus")
XHotKeywrapper(hpScreenshotKey,"SaveScreenshot")
COM_Init()	; only needed for HP

