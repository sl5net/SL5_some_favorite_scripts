;Pseudo Live Edit. Works in every browser. Its Autohotkey Code. 29.03.2013
m=Before you close this message remember this:`n
m=%m%1. Choose Web-Browser-Window by focus it (set it forground)`n
m=%m%2. press Windows-Key + F5 `n
m=%m%2.  `n
m=%m%2. this window will now reloadet`n erery some seconds by sending it F5 key (and stays in forground) `n
MsgBox,%m% 
ToolTip3sec("moving windows you could use ALT+TAB (and use the keyboard)")
ReloudWebBrowserLoop:
#f5::

;ReloudWebBrowser
KeyWait, LWin ; , L ; Wait for the left Alt key to be logically released.
KeyWait, RWin ; , L ; Wait for the left Alt key to be logically released.

; ErrorLevel is set to 1 if the command timed out or 0 otherwise.
if ErrorLevel ; i.e. it's not blank or zero. exitBecouseOfErrorInLine(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)

Last_A_This:=A_ThisFunc . A_ThisLabel
ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)

WinGetActiveTitle,at
WinSet, AlwaysOnTop, On, %at%
;~ WinSet, Style, -0xC00000, %at% ; Entfernt die Titelleiste des aktiven Fensters (WS_CAPTION).
;~ WinSet, Region, 50-0 W200 H250, WinTitle  ; Make all parts of the window outside this rectangle invisible.
; xFirstVisibleFromLef- firstFissibleFromTop
;~ WinSet, Region, 0-100 W5555 H5555 R, %at%
;~ WinSet, Region,, %at% ; Restore the window to its original/default display area.

;~ WinGetPos, x, y, w, h, %at%
;~ w2:=w-50
;~ h2:=h-50

; make a short blink effect
WinSet, Transparent, 0, %at%
Sleep,800
WinSet, Transparent, 255, %at%

;~ WinSet, Region,, %at% ; Restore the window to its original/default display area.
;~ WinSet, Region, 0-50 0-0 W%w2% H%h2%, %at%




if ReloudWebBrowser=on 
ReloudWebBrowser=off
else ReloudWebBrowser=on
SetTimer, Lbl_Toggle_ReloudWebBrowser , %ReloudWebBrowser%
return
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
Lbl_Toggle_ReloudWebBrowser:
WinGetTitle, Title, A
if WinExist(at)
{ 
WinActivate ; Uses the last found window. ControlSend, , {f5}, ahk_class MozillaUIWindowClass Last_A_This:=A_ThisFunc . A_ThisLabel
ToolTip3sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
}
ControlSend,,{f5},%at%
sleep,9000
return
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

ToolTip1sec(t,x=123,y=321){
  ToolTipSec(t,x=123,y=321,1000)
  return
}
ToolTip3sec(t,x=123,y=321){
  ToolTipSec(t,x=123,y=321,3000)
  return
}
ToolTipSec(t,x=123,y=321,sec=1000){
  if( x=123 AND y=321 )
  ToolTip, %t%
  else
 ToolTip, %t%,%x%,%y%
  SetTimer, RemoveToolTip, %sec%
	return
}
forceWinActivate(t) 
{ 
	sleep,150 
	ifwinactive,%t% 
			return 
	Loop,10 
	{ 
		WinActivate ,%t% 
		WinWaitActive,%t%,,1 
		ifwinactive,%t% 
			break 
	}
	return 
}
RemoveToolTip:
	tooltip,
return