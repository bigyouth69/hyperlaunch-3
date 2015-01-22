; Transition Animation functions:
; User Transition Animation used for FadeIn and/or FadeOut. Select this as your Transition Animation in HLHQ.
; FadeIn animations should contain the text FadeIn on their name and FadeOut animations should contain the text FadeOut on their name.
; Function arguments should be exactly "direction,time".
MyCustomAnimateFadeIn(direction,time){
	Log("MyCustomAnimateFadeIn - Started")
	IniRead, myVar, %userFadeAnimIniFile%, ExampleSection, ExampleSetting	; userFadeAnimIniFile is the variable pointing to the User Fade Animations.ini file
	Log("MyCustomAnimateFadeIn - Ended")
}


; Progress Animation labels:
; User Progress Animation used for FadeIn when 7z is enabled and used. Select this as your Progress Animation in HLHQ.
; They can have any name, but cannot start with the underscore (_) character.
; Functions or Label names starting by an underscore (_) will be ignored by HLHQ since they are reserved for any extra labels/functions the user might need to create. Example _MyLabel:
MyCustomAnimation:
	Log("MyCustomAnimation - Started")
	Log("MyCustomAnimation - Ended")
Return
