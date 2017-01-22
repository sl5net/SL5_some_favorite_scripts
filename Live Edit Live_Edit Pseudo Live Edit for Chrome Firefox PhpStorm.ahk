;Pseudo Live Edit. Works in every browser. Its Autohotkey Code. 29.03.2013
; Update at 17-01-20_17-50: Please also take a look here: http://stackoverflow.com/questions/24100562/phpstorm-live-edit-for-php-or-an-alternative-for-firefox/41768353#41768353
m=Before you close this message remember this:`n`n
m=%m%1. Choose Web-Browser-Window by focus it (set it forground)`n
m=%m%2. press Windows-Key + F5 `n
m=%m%2.  `n
m=%m%2. this window will now reloadet`n erery some seconds by sending it F5 key (and stays in forground) `n
;~ MsgBox,%m% 
SplashTextOn, 400, 300, A_LineNumber . " " . A_ScriptName, %m% 
Sleep,3000
SplashTextOff
ToolTip3sec("moving windows you could use ALT+TAB (and use the keyboard)")

; initialice variables
F5_TickCount := 0

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

; make a short blink effect, only by pressing F5 .. 
WinSet, Transparent, 0, %at%
Sleep,300
WinSet, Transparent, 255, %at%

;~ WinSet, Style, -0xC00000, %at% ; Entfernt die Titelleiste des aktiven Fensters (WS_CAPTION).
;~ WinSet, Region, 50-0 W200 H250, WinTitle  ; Make all parts of the window outside this rectangle invisible.
; xFirstVisibleFromLef- firstFissibleFromTop
;~ WinSet, Region, 0-100 W5555 H5555 R, %at%
;~ WinSet, Region,, %at% ; Restore the window to its original/default display area.

;~ WinGetPos, x, y, w, h, %at%
;~ w2:=w-50
;~ h2:=h-50


;~ WinSet, Region,, %at% ; Restore the window to its original/default display area.
;~ WinSet, Region, 0-50 0-0 W%w2% H%h2%, %at%




if ReloudWebBrowser=on 
ReloudWebBrowser=off
else ReloudWebBrowser=on
SetTimer, Lbl_Toggle_ReloudWebBrowser , %ReloudWebBrowser%
return



;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
Lbl_Toggle_ReloudWebBrowser:

; A_TimeIdle ; The number of milliseconds that have elapsed since the system last received keyboard, mouse, or other input.
;~ ToolTip, A_TimeIdle= %A_TimeIdle% `n millisSinceLastF5= %millisSinceLastF5%
if( A_TimeIdle < 2200 )
	return ; he is in action probably :) donst disturb

millisSinceLastF5 := A_TickCount - F5_TickCount

if( A_TimeIdle > millisSinceLastF5 )
	return ; he did nothing since last time



; A_TickCount ; The number of milliseconds since the computer was rebooted. 


WinGetTitle, lastWinTitle, A
if(InStr( lastWinTitle, "PhpStorm" ))
{
	;~ Send,^s ; save inside PhpStorm 22.01.2017 13:36
	;~ ControlSend,,^s,%lastWinTitle% ; save inside PhpStorm 22.01.2017 13:36
	Send,^s ; save inside PhpStorm 22.01.2017 13:36
	Sleep,250 ; give the OS little time for save it.
}
else
	return ; do nothing if focos is not inside phpstorm

if WinExist(at)
{ 
WinActivate, %at%
; Uses the last found window. ControlSend, , {f5}, ahk_class MozillaUIWindowClass Last_A_This:=A_ThisFunc . A_ThisLabel
;~ ToolTip3sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
} else
{
	ToolTip3sec(" :( ERROR at=%at% dont exist. ExitApp `n `n" . A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
	Sleep,4000
	return
}
F5_TickCount := A_TickCount
ControlSend,,{f5},%at%
WinActivate, %lastWinTitle%

sleep,3500
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
