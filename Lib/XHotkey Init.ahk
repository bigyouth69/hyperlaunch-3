MCRC=C3010E3
MVersion=1.0.0

; Create the exitKeyTable. If the tabel is not returned from the function, only the first key works and KeyWait has no effect
exitEmulatorKey := xHotKeyVarEdit(exitEmulatorKey,"exitEmulatorKey","~","Add")
XHotKeywrapper(exitEmulatorKey,"CloseProcess")
If (exitEmulatorKeyWait && forceHoldKey)
	ForceHoldKey(forceHoldKey, exitEmulatorKeyWait)
Else If exitEmulatorKeyWait
	ForceHoldKey(exitEmulatorKey, exitEmulatorKeyWait)

; Some keys should have ~ removed like navigation keys, while others like the exit key, should have it added. This makes it so the user doesn't have to worry about what is what when setting keys.
exitScriptKey := xHotKeyVarEdit(exitScriptKey,"exitScriptKey","~","Add")
exitEmulatorKey := xHotKeyVarEdit(exitEmulatorKey,"exitEmulatorKey","~","Add")
toggleCursorKey := xHotKeyVarEdit(toggleCursorKey,"toggleCursorKey","~","Add")
navUpKey:= xHotKeyVarEdit(navUpKey,"navUpKey","~","Remove")
navDownKey := xHotKeyVarEdit(navDownKey,"navDownKey","~","Remove")
navLeftKey := xHotKeyVarEdit(navLeftKey,"navLeftKey","~","Remove")
navRightKey := xHotKeyVarEdit(navRightKey,"navRightKey","~","Remove")
navSelectKey := xHotKeyVarEdit(navSelectKey,"navSelectKey","~","Remove")
