mTest = true	; HLHQ will not look at this as a module
#SingleInstance force
SetWorkingDir A_ScriptDir
Version := 1.0

k0 := 0xF39A0B65
k1 := 0xA0D728C6
k2 := 0x66F27F1E
k3 := 0x2A5B56D3

Hotkey, ~Escape, GuiClose

Gui, 1:Add, Text, x10 y5 w150 h20, Steam Username:
Gui, 1:Add, Edit, x10 y20 w80 h20 vUserEdit1 gUserEdit1, % (Decrypt(ReadReg("sU"),"k"))
Gui, 1:Add, Text, x110 y5 w150 h20, Steam Password:
Gui, 1:Add, Edit, x110 y20 w120 h20 vUserEdit2 gUserEdit2 Password, % (Decrypt(ReadReg("sP"),"k"))
Gui, 1:Add, Text, x10 y45 w150 h20, Origin Username:
Gui, 1:Add, Edit, x10 y60 w80 h20 vUserEdit3 gUserEdit3, % (Decrypt(ReadReg("oU"),"k"))
Gui, 1:Add, Text, x110 y45 w150 h20, Origin Password:
Gui, 1:Add, Edit, x110 y60 w120 h20 vUserEdit4 gUserEdit4 Password, % (Decrypt(ReadReg("oP"),"k"))
Gui, 1:Show, x142 y96 w240 h90

Return

UserEdit1:
	Gui, Submit, NoHide
	WriteReg("sU", Encrypt(UserEdit1,"k"))
Return
UserEdit2:
	Gui, Submit, NoHide
	WriteReg("sP", Encrypt(UserEdit2,"k"))
Return
UserEdit3:
	Gui, Submit, NoHide
	WriteReg("oU", Encrypt(UserEdit3,"k"))
Return
UserEdit4:
	Gui, Submit, NoHide
	WriteReg("oP", Encrypt(UserEdit4,"k"))
Return

GuiClose:
	Gui, Destroy
	ExitApp
Return


ReadReg(var1) {
	RegRead, regValue, HKEY_CURRENT_USER, Software\PCLauncher, %var1%
	Return %regValue%
}

WriteReg(var1, var2) {
	RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\PCLauncher, %var1%, %var2%
}

Decrypt(T,key)                   ; Text, key-name
{
   Local p, i, L, u, v, k5, a, c

   StringLeft p, T, 8
   If p is not xdigit            ; if no IV: Error
   {
      ErrorLevel = 1
      Return
   }
   StringTrimLeft T, T, 8        ; remove IV from text (no separator)
   k5 = 0x%p%                    ; set new IV
   p = 0                         ; counter to be Encrypted
   i = 9                         ; pad-index, force restart
   L =                           ; processed text
   k0 := %key%0
   k1 := %key%1
   k2 := %key%2
   k3 := %key%3
   Loop % StrLen(T)
   {
      i++
      IfGreater i,8, {           ; all 9 pad values exhausted
         u := p
         v := k5                 ; IV
         p++                     ; increment counter
         TEA(u,v, k0,k1,k2,k3)
         Stream9(u,v)            ; 9 pads from Encrypted counter
         i = 0
      }
      StringMid c, T, A_Index, 1
      a := Asc(c)
      if a between 32 and 126
      {                          ; chars > 126 or < 31 unchanged
         a -= s%i%
         IfLess a, 32, SetEnv, a, % a+95
         c := Chr(a)
      }
      L = %L%%c%                 ; attach Encrypted character
   }
   Return L
 }

Encrypt(T,key)                   ; Text, key-name
{
   Local p, i, L, u, v, k5, a, c, IV

   k0 := %key%0
   k1 := %key%1
   k2 := %key%2
   k3 := %key%3

   StringLeft k5, A_NowUTC, 8    ; current time
   StringRight v, A_NowUTC, 6
   v := v*1000 + A_MSec          ; in MSec
   SetFormat Integer, H
   TEA(k5,v, k0,k1,k2,k3)        ; k5 = IV: starting random counter value
   SetFormat Integer, D
   StringTrimLeft u, k5, 2
   u = 0000000%u%
   StringRight IV, u, 8          ; 8-digit hex w/o 0x

   i = 9                         ; pad-index, force restart
   p = 0                         ; counter to be Encrypted
   L = %IV%                      ; IV prepended to processed text
   Loop % StrLen(T)
   {
      i++
      IfGreater i,8, {           ; all 9 pad values exhausted
         u := p
         v := k5                 ; IV
         p++                     ; increment counter
         TEA(u,v, k0,k1,k2,k3)
         Stream9(u,v)            ; 9 pads from Encrypted counter
         i = 0
      }
      StringMid c, T, A_Index, 1
      a := Asc(c)
      if a between 32 and 126
      {                          ; chars > 126 or < 31 unchanged
         a += s%i%
         IfGreater a, 126, SetEnv, a, % a-95
         c := Chr(a)
      }
      L = %L%%c%                 ; attach Encrypted character
   }
   Return L
 }

TEA(ByRef y,ByRef z,k0,k1,k2,k3) ; (y,z) = 64-bit I/0 block
{                                ; (k0,k1,k2,k3) = 128-bit key
   IntFormat = %A_FormatInteger%
   SetFormat Integer, D          ; needed for decimal indices
   s := 0
   d := 0x9E3779B9
   Loop 32
   {
      k := "k" . s & 3           ; indexing the key
      y := 0xFFFFFFFF & (y + ((z << 4 ^ z >> 5) + z  ^  s + %k%))
      s := 0xFFFFFFFF & (s + d)  ; simulate 32 bit operations
      k := "k" . s >> 11 & 3
      z := 0xFFFFFFFF & (z + ((y << 4 ^ y >> 5) + y  ^  s + %k%))
   }
   SetFormat Integer, %IntFormat%
   y += 0
   z += 0                        ; Convert to original ineger format
}

Stream9(x,y)                     ; Convert 2 32-bit words to 9 pad values
{                                ; 0 <= s0, s1, ... s8 <= 94
   Local z                       ; makes all s%i% global
   s0 := Floor(x*0.000000022118911147) ; 95/2**32
   Loop 8
   {
      z := (y << 25) + (x >> 7) & 0xFFFFFFFF
      y := (x << 25) + (y >> 7) & 0xFFFFFFFF
      x  = %z%
      s%A_Index% := Floor(x*0.000000022118911147)
   }
}
