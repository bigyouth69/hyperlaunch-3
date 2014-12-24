MCRC=F4BE3E80
MVersion=1.0.1

If fadeInterruptKey != anykey
	fadeInterruptKey := xHotKeyVarEdit(fadeInterruptKey,"fadeInterruptKey","~","Remove")

fadeAnimationsIni := libPath . "\Fade Animations.ini"
IfNotExist, %fadeAnimationsIni%
FileAppend,,%fadeAnimationsIni%

FileRead, fadeAnimFile, %libPath%\Fade Animations.ahk
IfNotInString, fadeAnimFile, %fadeInTransitionAnimation%(
	fadeInTransitionAnimation := "DefaultAnimateFadeIn"
IfNotInString, fadeAnimFile, %fadeOutTransitionAnimation%(
	fadeOutTransitionAnimation := "DefaultAnimateFadeOut"
IfNotInString, fadeAnimFile, %fadeLyr3Animation%:
	fadeLyr3Animation := "DefaultFadeAnimation"
IfNotInString,  fadeAnimFile, %fadeLyr37zAnimation%:
	fadeLyr37zAnimation := "DefaultFadeAnimation"
Log("fadeInTransitionAnimation: " . fadeInTransitionAnimation,4)
Log("fadeOutTransitionAnimation: " . fadeOutTransitionAnimation,4)
Log("fadeLyr3Animation: " . fadeLyr3Animation,4)
Log("fadeLyr37zAnimation: " . fadeLyr37zAnimation,4)

