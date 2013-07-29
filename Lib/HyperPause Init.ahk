MCRC=E63D6182
MVersion=1.0.0

hpKey := xHotKeyVarEdit(hpKey,"hpKey","~","Add")
hpBackToMenuBarKey := xHotKeyVarEdit(hpBackToMenuBarKey,"hpBackToMenuBarKey","~","Remove")
hpZoomInKey := xHotKeyVarEdit(hpZoomInKey,"hpZoomInKey","~","Remove")
hpZoomOutKey := xHotKeyVarEdit(hpZoomOutKey,"hpZoomOutKey","~","Remove")
hpScreenshotKey := xHotKeyVarEdit(hpScreenshotKey,"hpScreenshotKey","~","Remove")

#Include, %A_ScriptDir%\Module Extensions	; change all future includes to look in the Module Extensions folder
#include,*i VA.ahk
#include,*i RIni.ahk
XHotKeywrapper(hpKey,"TogglePauseMenuStatus")
XHotKeywrapper(hpScreenshotKey,"SaveScreenshot")
COM_Init()	; only needed for HP

