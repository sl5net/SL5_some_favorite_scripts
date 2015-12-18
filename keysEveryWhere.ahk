;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;~ please use this ! as first line in every script before all includes! :)
isDevellopperMode=true ; enthällt auch update script.
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#Include *i init_global.init.inc.ahk


;~ #Include keysEveryWhere_4_Refactor_engine.ahk

;
;~ ListHotkeys 	 
;~ Anzeige der Hotkeys welche vom aktuellen Script verwendet werden, ungeachtet dessen ob ihre Subroutinen z.Z. laufen, und ob sie den Tastatur- oder Maus-Hook benutzen. 
;~ http://www.essential-freebies.de/board/viewtopic.php?t=11375


;MouseMove,50,0
;ToolTip,5erts sdfgdsg wwwwwwwww
;~ lll(A_LineNumber, "keysEveryWhere.ahk")


programmNummer:=1
lll(A_LineNumber, "keysEveryWhere.ahk")
 
;~ ;<<<<<<<<<<<<<<<<< selftest <<<<<<<<<<<<<<
;~ countOfSelftest:=1
;~ the selftest is at end of the file 
;~ ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

;~ ;<<<<<<<<<<<<<<<<< selftest <<<<<<<<<<<<<<
;~ countOfSelftest:=1
;~ Send,#e
;~ msgbox,%Last_A_This%
;~ the selftest is at end of the file
;~ countOfSelftest--
;~ ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;~ sometimes some keys hook nonstop
;~ so initial them first, so reload could help:
Send,{CtrlUp}
Send,{AltUp}
Send,{ShiftUp}
Send,{Blind}
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

;~ 

s1:=1000
m1:=s1 * 60
m10:=m1 * 10

#InstallKeybdHook
;~ http://de.autohotkey.com/wiki/index.php?title=InstallKeybdHook

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;~ produce sideeffect with drag script
;~ SetCapsLockState, Off
;~ SetScrollLockState, Off
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><>>>>>>>>>

miliSec:=5000


;################ Begin Hotkeys
;~ 8-6-24_14-80008-6-24_14-8000 8-6-24_14-8000



Suspend,off

;~ MsgBox,%A_LineNumber%

#IfWinActive,
~^c::
   ; check clipboard is changed
;~ subStr_Clipboard_1_5 := SubStr(Clipboard,1,5)
; sometimes copy text with ^ c dont copy. visual feedback ist needet and implemented here. 22.09.2015 18:41
if(Clipboard_OLD  <> Clipboard) {
  c := Clipboard
https_www_google_d = https://www.google.de/
strLen_https_www_goo := StrLen(https_www_google_d)
subStr_c_strLen_http := SubStr(c,1,strLen_https_www_goo)
   ;~ MsgBox,'%subStr_c_strLen_http%' ?= '%https_www_google_d%' (line:%A_LineNumber%) `n 
if(subStr_c_strLen_http == https_www_google_d ){
   c := RegExReplace( c, "([^?]+\?).*(\#?q=[^&]+).*","$1$2")
   MsgBox, '%c%' = c (line:%A_LineNumber%) `n 
   ;~ MsgBox,'%subStr_c_strLen_http%' ?= '%https_www_google_d%' (line:%A_LineNumber%) `n 
;~ Reload
;~ sourceid_chrome_inst = sourceid=chrome-instant&
;~ ion=1&espv=2&es_th=1&ie=UTF-8#q=vidisic%20augengel%20test&es_th=1 
 ;~ https://www.google.de/webhp?sourceid=chrome-instant&ion=1&espv=2&es_th=1&ie=UTF-8#q=vidisic%20augengel%20test&es_th=1 
Clipboard := c
}
  SetTimer,Show_Clipboard_1_5,200 ; it need to show it later. if i use ToolTip inside it schow me the old clipboard :D 22.09.2015 18:33
Clipboard_OLD := c
}
return

Show_Clipboard_1_5:
  SetTimer,Show_Clipboard_1_5,Off 
  subStr_Clipboard_1_5_OLD := subStr_Clipboard_1_5
  subStr_Clipboard_1_5 := SubStr(Clipboard,1,5)
  ToolTip3sec( "" . subStr_Clipboard_1_5 . "..." )
return

;~ Posteingang (27) - sl5softwarelab@gmail.com - Gmail - Google Chrome ahk_class Chrome_WidgetWin_1 
DetectHiddenWindows,on
SetTitleMatchMode,2

#IfWinActive,FreeCommander - DOS ahk_class ConsoleWindowClass
; FreeCommander - DOS ahk_class ConsoleWindowClass 
 ;~ #IfWinActive,MINGW64:/e/xampp-php5.4.4/htdocs/mediawiki-test-15-09-18_11-10 ahk_class mintty 
 
 ; mysql.exe -h localhost -u root -p wom15091718 < "E:\fre\private\office\job\Kunden\WoM\wom_lt.sql"
 
 
 
#IfWinActive,MINGW64:/
^v::
Ctrl & v::
t=%Clipboard%
  t:=convert123To_NumPad123(Trim(t))
Send,%t%
  Last_A_This:=A_ThisFunc . A_ThisLabel
  ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
return
; curl -s -S $SAVELOG_COMMAND SAVELOG_COMMAND="http://webdumper.local/index.php/project/save_log/1_8bd2c3f7fd5b165b470beb1cc83071ab"


#IfWinActive Google Chrome
StrgVonlyText:
Ctrl & v::

  Last_A_This:=A_ThisFunc . A_ThisLabel
  ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
lll(A_LineNumber, "keysEveryWhere.ahk",Last_A_This)
  ClipboardBackup := Clipboard
  Clipboard = %Clipboard%
  ;~ ToolTip,c = %c%
  Suspend,on
  Send,^v
  Suspend,off
  Clipboard := ClipboardBackup

  clipboard=%clipboard%

return


;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
SetTitleMatchMode,2
;~ #IfWinActive,Code::Blocks svn build ahk_class wxWindowClassNR
#IfWinActive,Blocks svn build
;~ #IfWinActive,Code::Blocks
h::
  MsgBox, yeaa
  return
  p0=%HardDriveLetter%:\fre\private\database\
  pB=%HardDriveLetter%:\temp\
  pathList= 0=%p1%  `n 1=%p1%  `n 2=%p2%  `n 3=%p3%  `n 4=%p4%  `n 5=%p5%  `n 6=%p6%  `n 7=%p7%  `n 8=%p8%  `n 9=%p9%`n a=%pA%`n b=%pB%`n x=%pX%
  ToolTipText:="Number for Text:`n BetaShortcuts `n 1=" . pathList 
  ;ToolTip3sec( ToolTipText )
  ToolTip, %ToolTipText%
  Input, k1, L1
  ;MsgBox, %k1%
  
    Suspend,On

  
  send,{home}
  ;{shift down}{end}{shift up}
  if( k1 = 0 )
    send,%p0%
  if( k1 = 1 )
    send,%p1%
  if( k1 = 2 )
    send,%p2%
  if( k1 = 3 )
    send,%p3%
  if( k1 = 4 )
    send,%p4%
  if( k1 = 5 )
    send,%p5%
  if( k1 = 6 )
    send,%p6%
  if( k1 = 7 )
    send,%p7%
  if( k1 = 8 )
    send,%p8%
  if( k1 = 9 )
    send,%p9%
  if( k1 = "a" )
    send,%pA%
  if( k1 = "b" )
    send,%pB%
  if( k1 = "x" )
    send,%pX%
  ToolTip,

  Suspend,Off

;~ Loop 20
   ;~ HotKey % Chr(A_Index+96), Hotty
;~ Return

   ;~ msgbox, %A_Thishotkey%

;~ Hotty:
   ;~ msgbox, %A_Thishotkey%
;~ Return


;~ InputBox, UserInput, Phone Number, Please enter a phone number., , 640, 480
;~ if ErrorLevel
    ;~ MsgBox, CANCEL was pressed.
;~ else
    ;~ MsgBox, You entered "%UserInput%"

  ;~ KeyWait, LWin ; , L ; Wait for the left Alt key to be logically released.
  ;~ KeyWait, RWin ; , L ; Wait for the left Alt key to be logically released.

  ;~ Last_A_This:=A_ThisFunc . A_ThisLabel
	;~ ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
  ;~ SendEvent,%HardDriveLetter%:\fre\private\Büro\Einkauf\
return
 
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>







;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
SetTitleMatchMode,2
;~ Inkscape ahk_class gdkWindowToplevel,
#IfWinActive Inkscape ahk_class gdkWindowToplevel
;~ ahk_class gdkWindowToplevel
down::
;~ send,!x{down}
send,{Alt Down}x{Alt Up}{down}
return
up::
;~ send,!x{down}
send,{Alt Down}x{Alt Up}{up}
return
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
#IfWinActive Mobile Partner ahk_class #32770
Ctrl & a::
  StrgAStrgA()
  ;MsgBox, yes :-)
return
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

BackSpaceExplorer:
SetTitleMatchMode, 2
#IfWinActive ahk_class CabinetWClass
BackSpace::
ToolTip3sec(A_LineNumber . " " . A_ScriptName . "`nPlease use ALT + UP ARROW for waking to the root")
send,!{up}
return


;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;~ doppel actually not trigger. whey ? StrgAStrgA 12-11-22_10-50
StrgAStrgA:
StrgA:
SetTitleMatchMode, 2
#IfWinActive ahk_class
~^a::
  StrgAStrgA()
return
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><>>>>>


SetTitleMatchMode, 2

titleBeforeDictation:="" 
isDragonMicrophoneOn:=0
;MsgBox, %isDragonMicrophoneOn%

;::SC163::Send,#e  ; FN unter IBM T41

#IfWinActive
;~ #tab::send,!{tab}
~#tab::
Suspend,on
  ;~ send,{LWin Down}{tab}{tab}{tab}   
  ;~ send,{LWin Down}{tab}{tab}
;~ wieviel tabs ist nicht immer ganz klar. komisch. naja  
  SetKeyDelay,30
  send,{LWin Down}{tab}{tab}   
  SetKeyDelay,10        
  ;~ MsgBox,            jo                                  
Suspend,off
return


#IfWinExist Camtasia Recorder ahk_class RECORDER_CLASS_D77CA95F_632A_4d48_8FD0_2A8DEAA6DA4A
Ctrl & +::
  ;MsgBox,Shift + Alt + in 
  Send,{Shift Down}!i{Shift Up} ;zoom in
return


Ctrl & -::
  ;MsgBox,Shift + Alt + out
  Send,{Shift Down}!o{Shift Up} ;zoom in
return




;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
SetTitleMatchMode, 2
#IfWinActive - ToDoList © AbstractSpoon ahk_class Afx
ctrl & shift::
{
  ; weil ctrl+shift+n nicht funktioniert
  if(0)
  {
    WinWait, test - ToDoList © AbstractSpoon, Above &Priority
    IfWinNotActive, test - ToDoList © AbstractSpoon, Above &Priority, WinActivate, test - ToDoList © AbstractSpoon, Above &Priority
    WinWaitActive, test - ToDoList © AbstractSpoon, Above &Priority
    MouseClick, left,  392,  522
    Sleep, 100
  }

	Input, SingleKey, L1 M,{Esc}{LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}

  if(SingleKey="n")
  {
  
    ;ToolTip [, Text, X, Y, WhichToolTip]
    ;Send, {CTRLDOWN}{shiftdown}n{shiftup}{CTRLUP}
    Send, {CTRLDOWN}n{CTRLUP}
    sleep,50
    send,{enter}
    sleep,50
    Send, {CTRLDOWN}{right}{CTRLUP}{f2}
  }
  return
}
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>



;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;~ sceenshots by mousclick
;~ #IfWinActive
;~ MouseClickLeft:
;~ ; screenhost active window
;~ ~L::
  ;~ if(0){
    ;~ c:=Clipboard
    ;~ ;while
    ;~ SendInput,!{PrintScreen}
    ;~ Sleep,1500
    ;~ Clipboard:=c
  ;~ }
;~ return





;~ MouseClickRight:
;~ ; screenhost active window
;~ ~RButton::

  ;~ if(0){
    ;~ c:=Clipboard
    ;~ SendInput,!{PrintScreen}
    ;~ Sleep,1500
    ;~ Clipboard:=c
  ;~ return
;~ }
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 ; Doppel-Escape close active Window
;~ #IfWinActive
;~ ESC::
  ;~ Last_A_This:=A_ThisFunc . A_ThisLabel
	;~ ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
	;~ SetTitleMatchMode, 3
	;~ ; 3: A window's title must exactly match WinTitle to be a match.
	;~ WinGetActiveTitle,title
	;~ SendEvent,{Esc}
	;~ Sleep,100
	;~ if Not WinExist(title) 
		;~ return

  ;~ if WinActive("ahk_class freemind.main.FreeMind")
    ;~ return


	;~ ToolTip,You pressed >ESC<  Space=>minimize active Window   Escape=>close active Window

	;~ Input, SingleKey, L1 M,{Esc}{LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}

	;~ Tooltip,%SingleKey%
	
	;~ ;{LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause} 

  ;~ ;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	;~ ; Checks if a keyboard key or mouse/joystick button is down or up. Also retrieves joystick status.



  ;~ GetKeyState, EWD_EscapeState, Escape, P

	;~ if EWD_EscapeState = D  ; Escape has been pressed, so drag is cancelled.
	;~ {

    ;~ ;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    ;~ ; killAllOpenWinWithoutSave
    ;~ w:=" - Editor ahk_class Notepad"
    ;~ IfWinActive,%w%
  	;~ {
      ;~ killAllOpenWinWithoutSave(w)
      ;~ return
    ;~ }
    ;~ ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


	 ;~ ToolTip, %title%
	 
	 
	 ;~ IfWinActive, %title%
	 ;~ Send , !{f4} ; es ist besser erst mit alt+F4, das schließen zu versuchen, wenn man nicht unbedingt den Prozess ganz abschiessen möchte.
	 ;~ ;ControlSend , Control, Keys, WinTitle, WinText, ExcludeTitle, ExcludeText]
	 ;~ ;IfWinActive, %title%
		;~ ;WinClose,%title% ; is mir gerade zu hart ... wurde manchmal mehr geschlossen als ich wollte.
		;~ ;MsgBox, 0, Tutorial, Escape has been pressed
	;~ }
	;~ Else
	;~ {
		;~ If (SingleKey=" ")
			;~ WinMinimize,%title%
		;~ Else
			;~ SendEvent,%SingleKey%
	;~ }
;~ ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	;~ ToolTip,
;~ Return
   ;~ ;==>captureEsc
;~ ;---------------------




;~ Shortcut-Window wechsel
;Alt & Tab::
;Send,Ctrl & Shift & Esc
;~  Last_A_This:=A_ThisFunc . A_ThisLabel
;~  ToolTip1sec("Ctrl Shift Esc `n" . A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
;~  Send,{Ctrl Down}{Shift Down}{Esc}{Shift Up}{Ctrl Up} ; Task Manager
;return
;http://www.autohotkey.com/community/viewtopic.php?t=7757




WINf:
#f::
  KeyWait, LWin ; , L ; Wait for the left Alt key to be logically released.
  KeyWait, RWin ; , L ; Wait for the left Alt key to be logically released.
  ; ErrorLevel is set to 1 if the command timed out or 0 otherwise.
  if ErrorLevel   ; i.e. it's not blank or zero.
    exitBecouseOfErrorInLine(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)

  Last_A_This:=A_ThisFunc . A_ThisLabel
  lll(A_LineNumber, "keysEveryWhere.ahk",Last_A_This)
  ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
  clipboard=%clipboard%
  
  ;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ; beide Methoden funktionieren
  ;SendEvent,%clipboard%
  Suspend,On  
  SendPlay,%clipboard%
  Sleep,1000
  Suspend,Off
  ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  
  ;,%clipboard%,%clipboard%
  
return

;~ jetbrains idea
#IfWinActive,ahk_class SunAwtFrame
;~ sorce here: https://youtrack.jetbrains.com/issue/IDEA-137851
;~ https://gist.github.com/sl5net/b64459d88bbcdeb04a97
;~ BTW other script : https://gist.github.com/sl5net/7170280
^>!7:: ; AltGr + 7
  useCase:=1
  if(useCase == 2)
  {
    ; dont work
    Suspend,on
    Send,{Blind}
    Send,{CtrlDown}!{{} ; works
    ;~ Send,{
    Send,{CtrlUp}
    Send,{Blind}
    Suspend,off
  }
  if(useCase == 1)
  {
    Suspend,on
    Send,{Blind}
    Send,{CtrlDown}{AltDown}
    Send,{{} ; works
    ;~ Send,{
    Send,{Alt Up}{CtrlUp}
    Send,{Blind}
    Suspend,off
  }
return
^>!0:: ; catches AltGr + 0
  useCase:=1
  if(useCase == 1)
  {
    Suspend,on
    Send,{Blind}
    Send,{CtrlDown}{AltDown}
    Send,{}} ; works
    ;~ Send,{
    Send,{Alt Up}{CtrlUp}
    Send,{Blind}
    Suspend,off
  }
return
;~ ~^s::µ
  ;~ sleep,1000
  ;~ SetTitleMatchMode,2
  ;~ WinActivate,PilaWA - Mozilla Firefox
  ;~ WinWaitActive,PilaWA - Mozilla Firefox,,1
  ;~ IfWinActive,PilaWA - Mozilla Firefox
  ;~ send,{f5}
;~ return



WINo:
;#o:: ; 
  KeyWait, LWin ; , L ; Wait for the left Alt key to be logically released.
  KeyWait, RWin ; , L ; Wait for the left Alt key to be logically released.

  if(0)
  {
    Last_A_This:=A_ThisFunc . A_ThisLabel
      ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
      SendEvent,^c ; einfach kopiern ... reicht aber nicht bei Emails und links
    StringReplace, NewStr, clipboard, ", , All
      run,http://www.google.com/search?hl=de&q=site`%3Awww.ifosprogram.com+%NewStr%
      ToolTip2sec( A_ThisLabel . "`n BetaShortcuts `n" . clipboard)
  return
  }

  infoT=Reading-Book-Modus
  info=`n%infoT% `n"mouse move modus"/"%infoT%" - for e.g. you redaing book (paper) and want
  info=`n%info% that as working time in your timecapture-software.
  Last_A_This:=A_ThisFunc . A_ThisLabel
  lll(A_LineNumber, "keysEveryWhere.ahk",Last_A_This)
  ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
  SetTimer,LitleMouseMoveForSkypeIrritation,1000
  MsgBox,0 ,%infoT%, LitleMouseMoveForSkypeIrritation `nPRESS ENTER TO STOP THAT Modus `n#o:: `n%info%
  SetTimer,LitleMouseMoveForSkypeIrritation,OFF
return

LitleMouseMoveForSkypeIrritation:
  Last_A_This:=A_ThisFunc . A_ThisLabel
  lll(A_LineNumber, "keysEveryWhere.ahk",Last_A_This)
  ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
  MouseMove, 5, 5 ,, R
  MouseMove, -5, -5 ,, R
return

#IfWinExist 

WinN:
~#n::
Send,{BackSpace} ; becouse it writes a n . the ~ is for prevent windows to open windows.
  ;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ; n15-05-1%%%5-%%11
  if(0)
  {
    ;Ändern Datumsshortcut (Win+n) von 10-01-25_21-30 in 25.Jan 2010
    FormatTime, timestamp, %A_now% ,dd.MM.yyyy
    SendPlay, %timestamp% ; 8-6-24_14-80008-6-24_14-80008-6-24_14-9000 8-6-24_14-90008-6-24_14-90008-6-24_14-9000
    return
  }
;   
  
  ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  KeyWait, LWin ; , L ; Wait for the left Alt key to be logically released.
  KeyWait, RWin ; , L ; Wait for the left Alt key to be logically released.

  FormatTime, timestamp, %A_now%,yy-MM-dd_HH-mm
  ;~ timestamp:=convert123To_NumPad123(timestamp)
  Last_A_This:=A_ThisFunc . A_ThisLabel
  lll(A_LineNumber, "keysEveryWhere.ahk",Last_A_This)
  ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This . "`n" . timestamp  )
  ;08-07n15-05-12_16-25-07_17-44,
  ;{ASC 0108}; n15-05-12_16-20
  ;SendMessage, 0x111, 4007, 0x00000000, , Windows Task-Manager 
  ;MsgBox, %timestamp%

Suspend,ON

  if(0)
  {
    ; diese methjode geht bei eingeschalteten benutezrknten -steuerungu unter vista leider nicht.
    SendPlay, %timestamp% ; 8-6-24_14-80008-6-24_14-80008-6-24_14-9000 8-6-24_14-90008-6-24_14-90008-6-24_14-9000
  }
  else
  {
    timestamp:=convert123To_NumPad123(timestamp)
    Send,{Blind}
; n--_-n--_-
    Send, %timestamp% ; leider werden einige zahlen dann nicht verarbeitet. 10-07-14_14-06{numpad1}{numpad}-{numpad}{numpad}-{numpad1}{numpad4}_{numpad1}{numpad4}-{numpad}{nu} 10-07-14_14-07 10-07-14_14-07
; n15-05-12_16-17
}
Suspend,Off

return

; 21.09.2015 15:34

WinNgorssgeschrieben:
;RControl & RShift::AltTab
;24.04.2010 "$:=$:"=!="$:=$:"=!="  30.05.2015 
SetTitleMatchMode,2
;~ #IfWinActive,Google Chrome ahk_class Chrome_WidgetWin_1 
#IfWinActive, 
 LWin & LShift::
    ;Ändern Datumsshortcut (Win+n) von 10-01-25_21-30 in 25.Jan 2010
    FormatTime, timestamp, %A_now%,dd.MM.yyyy HH:mm
  KeyWait, LWin ; , L ; Wait for the left Alt key to be logically released.
  KeyWait, RWin ; , L ; Wait for the left Alt key to be logically released.
  ;FormatTime, timestamp, %A_now%,yy-MM-dd_HH-mm
  timestamp:=convert123To_NumPad123(timestamp)
  Send,%timestamp% ; => 22.12.2014
  ;~ SendRaw,,%timestamp% ; erzeugt dieses => {numpad2}{numpad2}.{numpad1}{numpad2}.{numpad2}{numpad}{numpad1}{numpad4}
  Last_A_This:=A_ThisFunc . A_ThisLabel
  ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This . "`n" . timestamp  )
  ;08-07-07_17-44,

return

Suspend,On

  ;{ASC 0108}
  ;SendMessage, 0x111, 4007, 0x00000000, , Windows Task-Manager
  if(0)
  {
    ; diese methjode geht bei eingeschalteten benutezrknten -steuerungu unter vista leider nicht.
    SendPlay, %timestamp% ; 8-6-24_14-80008-6-24_14-80008-6-24_14-9000 8-6-24_14-90008-6-24_14-90008-6-24_14-9000
  }
  else
  {
    timestamp:=convert123To_NumPad123(timestamp)
    Send, %timestamp% ; leider werden einige zahlen dann nicht verarbeitet. 10-07-14_14-06{numpad1}{numpad}-{numpad}{numpad}-{numpad1}{numpad4}_{numpad1}{numpad4}-{numpad}{nu} 10-07-14_14-07 10-07-14_14-07
  }
  
Suspend,Off
  
return





WINoe:
#ö:: ; göögle -suche
; MsgBox,now  göögle -suche 
  ;      NewStr=http://www.google.com/search?q=%NewStr%&esrch=BetaShortcuts&as_qdr=y
        ;~ NewStr=%browserPath%=%NewStr%
        ;~ openUrlInOpenFirefoxBrowser(NewStr)
    ;~ }
  run,http://www.google.com/search?q=define`%3A%clipboard%&esrch=BetaShortcuts

  ;~ }
	;~ ToolTip2sec( A_ThisLabel . "`n BetaShortcuts `n" . clipboard)
return

WINae:
#ä:: ; göögle -definition
  KeyWait, LWin ; , L ; Wait for the left Alt key to be logically released.
  KeyWait, RWin ; , L ; Wait for the left Alt key to be logically released.

  ; ErrorLevel is set to 1 if the command timed out or 0 otherwise.
  if ErrorLevel   ; i.e. it's not blank or zero.
    exitBecouseOfErrorInLine(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)


  Last_A_This:=A_ThisFunc . A_ThisLabel
  lll(A_LineNumber, "keysEveryWhere.ahk",Last_A_This)
  ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
  SendEvent,^c ; einfach kopiern ... reicht aber nicht bei Emails und links
  run,http://www.google.com/search?q=define`%3A%clipboard%&esrch=BetaShortcuts
  ToolTip2sec( A_ThisLabel . "`n define BetaShortcuts")
;http://www.google.com/search?hl=en&esrch=BetaShortcuts&q=define%3Aclipboard&btnG=Search
return

WINue:
#ü:: ; google -codeSuche
  KeyWait, LWin ; , L ; Wait for the left Alt key to be logically released.
  KeyWait, RWin ; , L ; Wait for the left Alt key to be logically released.

  ; ErrorLevel is set to 1 if the command timed out or 0 otherwise.
  if ErrorLevel   ; i.e. it's not blank or zero.
    exitBecouseOfErrorInLine(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)


  Last_A_This:=A_ThisFunc . A_ThisLabel
	ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
	SendEvent,^c ; einfach kopiern ... reicht aber nicht bei Emails und links
	run,http://www.google.com/codesearch?hl=de&lr=&q=2008+%clipboard%+lang`%3Ajava+-google&sbtn=Suche
;http://www.google.com/codesearch?hl=de&lr=&q=2008+%clipboard%+lang%3Ajava+-google&sbtn=Suche
	run,http://books.google.de/books?q=%clipboard%&btnG=Nach+B%C3%BCchern+suchen
	ToolTip2sec( A_ThisLabel . "`n java / books ")
return

exitBecouseOfErrorInLine(info)
{
  MsgBox, %info% `n`n exit
  exit
}

;~ 200801-22-15-27-33
WINe:
#e::
  KeyWait, LWin ; , L ; Wait for the left Alt key to be logically released.
  KeyWait, RWin ; , L ; Wait for the left Alt key to be logically released.
  ; ErrorLevel is set to 1 if the command timed out or 0 otherwise.
  if ErrorLevel   ; i.e. it's not blank or zero.
    exitBecouseOfErrorInLine(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)

  Last_A_This:=A_ThisFunc . A_ThisLabel
	ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
	SetTitleMatchMode, 2
	; 2: A window's title can contain WinTitle anywhere inside it to be a match.

	dir:=""
	WinGetActiveTitle, ActiveTitle
	tc=FreeCommander ahk_class TfcForm
	IfWinActive,%tc% ; , WinText, ExcludeTitle, ExcludeText]
  {
  Last_A_This:=A_ThisFunc . A_ThisLabel
	ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
  	;D: - FreeCommander ahk_class TfcForm
    ;System32 - FreeCommander ahk_class TfcForm
    ;ControlSend, , {CTRLDOWN}{ALTDOWN}{INS}{CTRLUP}{ALTUP} , %ActiveTitle%
    clipboardBackup:=clipboard
    Sleep,50
    Send,{CTRLDOWN}{ALTDOWN}{INS}{CTRLUP}{ALTUP}
		dir:=clipboard 
		clipboard:=clipboardBackup
  	; A_WinDir The Windows directory. For example: C:\Windows
  	run,%A_WinDir%/explorer.exe "%dir%" ; D:\fre\private\
  	;SendEvent,{LWin down}e{LWin up}
  	forceWinActivate("ahk_class CabinetWClass")
    return
  }
	SetTitleMatchMode, 2
	; StringReplace, OutputVar, InputVar, SearchText , ReplaceText, ReplaceAll?] 
	tc2=ahk_class CabinetWClass
	IfWinActive,%tc2% ; , WinText, ExcludeTitle, ExcludeText]
	{
  Last_A_This:=A_ThisFunc . A_ThisLabel
	ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
		StringReplace, dir, ActiveTitle, %tc2%, , All
	}
  
  if(InStr(clipboard, ":\", 1 , 1))
  {
    IfExist, %clipboard%
    {
      clipboardBackup:=clipboard
      dir=%clipboard% 
    }
    else
    {
      ; autohotkey verzeichnis erstellen
      ;MsgBox, 4, , Would you like to create  `n %clipboard% ?, 3  ; 5-second timeout.
      MsgBox, 4, , Would you like to create  `n %clipboard% ?, 3
      IfMsgBox, Yes
      {
        clipboardBackup:=clipboard
        dir=%clipboard% 
          FileCreateDir, %dir%
  
        if ErrorLevel   ; i.e. it's not blank or zero.
            MsgBox, ErrorLevel  %dir%
  
              }
        ;IfMsgBox, Timeout
        ;    Return ; i.e. Assume "No" if it timed out.
  ; Otherwise, continue:

    }
  } 
  
	;if Not WinExist("FreeCommander")
	;#E::Run %A_ProgramFiles%\_\FreeCommander\FreeCommander.exe
	r=%A_ProgramFiles%\_\FreeCommander\FreeCommander.exe

;~  MsgBox, run,%r% "%dir%"

	IfExist, %r%
		run,%r% /R="%dir%"


	;r=C:\Program Files (x86)\_\FreeCommander\FreeCommander.exe
	;IfExist, %r%
	;	run,%r% "%dir%"
	; Run rundll32.exe shell32.dll`,Control_RunDLL desk.cpl`,`, 3  ; 
	;else
	forceWinActivate(tc)
return


WinRRRTitelCopyShort:
#r::
  goto showTitle
return

#IfWinActive
WinV:
~#v::
  c=%Clipboard%
  ToolTip,c = %c%
  Suspend,on
  SendPlay,%c%
  Sleep,1000
  Suspend,off
  Suspend,off
return


WinT:
showTitleTogle=off
~#t::
;~ #t::

  KeyWait, LWin ; , L ; Wait for the left Alt key to be logically released.
  KeyWait, RWin ; , L ; Wait for the left Alt key to be logically released.

  ; ErrorLevel is set to 1 if the command timed out or 0 otherwise.
  if ErrorLevel   ; i.e. it's not blank or zero.
    exitBecouseOfErrorInLine(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)

  Last_A_This:=A_ThisFunc . A_ThisLabel
  ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
  ;~ ToolTip3sec("showTitle-Keys: Win+T, Win+R (Default: Win-ausführen")
  SetTimer, showTitle, 1000
  if showTitleTogle =on
  {
    showTitleTogle =off
    tooltip,
  }
  else
    showTitleTogle =on
  SetTimer, showTitle, %showTitleTogle%
return
	
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
#h::
  p0=%HardDriveLetter%:\fre\private\database\
  p1=%HardDriveLetter%:\fre\private\HtmlDevelop\AutoHotKey\
  p2=%HardDriveLetter%:\fre\private\HtmlDevelop\Aptana\
  p3=%HardDriveLetter%:\fre\private\Viertuallisierung\
  p4=%HardDriveLetter%:\fre\private\video\tutorial\
  p5=%HardDriveLetter%:\fre\
  p6=%HardDriveLetter%:\fre\office\
  p7=%HardDriveLetter%:\fre\
  pA=%HardDriveLetter%:\fre\private\office\
  pB=%HardDriveLetter%:\temp\
  pX=X:\public_html\wiki\sinnlos-im-all
  pathList= 0=%p1%  `n 1=%p1%  `n 2=%p2%  `n 3=%p3%  `n 4=%p4%  `n 5=%p5%  `n 6=%p6%  `n 7=%p7%  `n 8=%p8%  `n 9=%p9%`n a=%pA%`n b=%pB%`n x=%pX%
  ToolTipText:="Number for Text:`n BetaShortcuts `n 1=" . pathList 
  ;ToolTip3sec( ToolTipText )
  ToolTip, %ToolTipText%
  Input, k1, L1
  ;MsgBox, %k1%
  
    Suspend,On

  
  send,{home}
  ;{shift down}{end}{shift up}
  if( k1 = 0 )
    send,%p0%
  if( k1 = 1 )
    send,%p1%
  if( k1 = 2 )
    send,%p2%
  if( k1 = 3 )
    send,%p3%
  if( k1 = 4 )
    send,%p4%
  if( k1 = 5 )
    send,%p5%
  if( k1 = 6 )
    send,%p6%
  if( k1 = 7 )
    send,%p7%
  if( k1 = 8 )
    send,%p8%
  if( k1 = 9 )
    send,%p9%
  if( k1 = "a" )
    send,%pA%
  if( k1 = "b" )
    send,%pB%
  if( k1 = "x" )
    send,%pX%
  ToolTip,

  Suspend,Off

;~ Loop 20
   ;~ HotKey % Chr(A_Index+96), Hotty
;~ Return

   ;~ msgbox, %A_Thishotkey%

;~ Hotty:
   ;~ msgbox, %A_Thishotkey%
;~ Return


;~ InputBox, UserInput, Phone Number, Please enter a phone number., , 640, 480
;~ if ErrorLevel
    ;~ MsgBox, CANCEL was pressed.
;~ else
    ;~ MsgBox, You entered "%UserInput%"

  ;~ KeyWait, LWin ; , L ; Wait for the left Alt key to be logically released.
  ;~ KeyWait, RWin ; , L ; Wait for the left Alt key to be logically released.

  ;~ Last_A_This:=A_ThisFunc . A_ThisLabel
	;~ ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
  ;~ SendEvent,%HardDriveLetter%:\fre\private\Büro\Einkauf\
return

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


;~^r::
;#IfWinActive,Brain Workshop 4.8.4 ahk_class GenericAppClass57625872
#IfWinActive,Brain Workshop 4.8.4
q::a
w::a
e::a
r::a
t::a
z::a
s::a
d::a
f::a
g::a ; ist eigentlih der fortschrittsgraph
h::a
y::a
x::a
c::a
v::a
b::a

j::l
k::l
ö::l
ä::l
;`#::l
u::l
i::l
o::l
p::l ;pause eigentlich
ü::l
+::l
n::l
m::l
,::l
.::l
-::l







#IfWinActive,.php - PhpStorm 
;~ Ctrl & b::
;~ If GetKeyState("shift", "p")
;~ {
  ;~ tooltip,Ctrl + shift + B = toggle beetween { } 
  ;~ Suspend,On
  ;~ ControlSend,,^b^`,, PhpStorm 7.0 ahk_class SunAwtFrame
  ;~ Suspend,Off
;~ }
;~ else
;~ {
  ;~ tooltip,Ctrl + B = jump to declaration 
  ;~ Suspend,On
  ;~ ControlSend,,^b, PhpStorm 7.0 ahk_class SunAwtFrame
  ;~ Suspend,Off
;~ }
;~ return
f1::
;~ MsgBox,press now c for copying name==value condition
;~ InputBox, k, for copying name==value condition`n move mouse over name in watchlist, `nthen insert c, `nenter
;~ if ErrorLevel 
;~ return 
;~ MsgBox, %k%
SleepValue:=200
ClipboardOLD = %Clipboard%
Loop,10
{
  Send,^c
  Sleep,%SleepValue%
  if(ClipboardOLD <> Clipboard)
    break
}
value = %Clipboard%
ToolTip,value %Clipboard%
Sleep,%SleepValue%
ToolTip,
Send,{f2}
Sleep,%SleepValue%
Send,^a
Sleep,%SleepValue%
ClipboardOLD = %Clipboard%
Loop,10
{
  Send,^c
  Sleep,%SleepValue%
  if(ClipboardOLD <> Clipboard)
    break
}
name = %Clipboard%
condition := name . "=='" . value . "'"
Clipboard = %condition%
ToolTip,%condition%
Sleep,%SleepValue%
;~ MsgBox [, Options, Title, Text, Timeout]
MsgBox,,Clipboard = %condition%,Clipboard = %condition%,2
Sleep,%SleepValue%
Send,{esc}
return

#IfWinActive,.php - PhpStorm asökfjasoeiruaweölksdölfksdjf 
enter::
;~ Suspend,On
;~ ControlSend,,{enter},.php - PhpStorm 
;~ Suspend,Off
;~ return
infoText:="Ctrl + shift + enter = Complete Current Statement (Settings | Keymap)" 
  tooltip,%infoText% 
  Suspend,On
  ControlSend,,{CtrlDown}+{enter}{CtrlUp},.php - PhpStorm 7.1.1 ahk_class SunAwtFrame
  sleep,10
  MsgBox, 4,, ControlSend enter?  (press Yes or No)`n%infoText%,1
IfMsgBox Yes
{
    ;~ MsgBox You pressed Yes.
  ControlSend,,{enter},.php - PhpStorm 7.1.1 ahk_class SunAwtFrame
}
else
{
    ;~ MsgBox You pressed No.
}
Sleep,500
  Suspend,Off
return

#IfWinActive,.php - PhpStorm 
^NumpadAdd::
  tooltip,%A_LineNumber%: Ctrl & NumpadAdd (may start it as win-admin)
  Suspend,On
    send,^{WheelUp}
    ;~ ControlSend,,^{WheelUp},PhpStorm 7.0 ahk_class SunAwtFrame
  Suspend,Off
return

#IfWinActive,.php - PhpStorm 
^NumpadSub::
  tooltip,%A_LineNumber%: Ctrl & NumpadAdd
  Suspend,On
    send,^{WheelDown}
    ;~ ControlSend,,^{WheelUp},PhpStorm 7.0 ahk_class SunAwtFrame
  Suspend,Off
return

#IfWinActive,Rename ahk_class SunAwtDialog
up::
  tooltip,esc
  Suspend,On
  ControlSend,,{esc},Rename ahk_class SunAwtDialog
  Suspend,Off
return
Down::
  tooltip,esc
  Suspend,On
  ControlSend,,{esc},Rename ahk_class SunAwtDialog
  Suspend,Off
return
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#IfWinActive,awäeorjsadlöfkaäsdlfk Mozilla Firefox
StrgR:
^r::
  ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
  send,{CtrlDown}
return
#IfWinActive,Facebook - Mozilla Firefox ahk_class MozillaUIWindowClass
StrgW:
^w::
  ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
  send,{CtrlDown}
return


;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;~ thanks to:
;~ http://www.autohotkey.com/board/topic/75390-ahk-l-unicode-uri-encode-url-encode-function/
;~ http://www.w3schools.com/tags/ref_urlencode.asp
UriEncode(Uri)
{
	oSC := ComObjCreate("ScriptControl")
	oSC.Language := "JScript"
    Uri:= RegExReplace(Uri, " = ", "\n\n")  ; Returns "aaaXYZzzz" by means of the $1 backreference.
    Uri:= RegExReplace(Uri, "[\n\r]", "###Zeilenumbruch###")  ; Returns "aaaXYZzzz" by means of the $1 backreference.


    ;~ Uri=%Uri%
    ;~ MsgBox,test %Uri%
	Script := "var Encoded = encodeURIComponent(""" . Uri . """)"
	oSC.ExecuteStatement(Script)
    Uri:= oSC.Eval("Encoded")
    ;~ Clipboard:=Uri
    ;~ MsgBox,%Uri%
    ; C3 BC is the UTF-8 encoding of ü
    ; http://www.andre-jochim.de/url-encode.htm
    Uri:= RegExReplace(Uri, "%C3%BC", "ue")  ; ü
    Uri:= RegExReplace(Uri, "%C3%9C", "Ue")  ; Ü
    Uri:= RegExReplace(Uri, "%C3%A4", "ae")  ; 
    Uri:= RegExReplace(Uri, "%C3%84", "Ae")  ; 
    Uri:= RegExReplace(Uri, "%C3%B6", "oe")  ; 
    Uri:= RegExReplace(Uri, "%C3%96", "Oe")  ; 
    Uri:= RegExReplace(Uri, "%253A", ":")  ; 
    
    Uri:= RegExReplace(Uri, "%23%23%23Zeilenumbruch%23%23%23","%0D%0A")  ; Returns "aaaXYZzzz" by means of the $1 backreference.

Return, Uri
}

UriDecode(Uri)
{
	oSC := ComObjCreate("ScriptControl")
	oSC.Language := "JScript"
	Script := "var Decoded = decodeURIComponent(""" . Uri . """)"
	oSC.ExecuteStatement(Script)
	Return, oSC.Eval("Decoded")
}
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>





SetTitleMatchMode,2
#IfWinActive - Eclipse SDK ahk_class SWT_Window0
  ^m::
	ToolTip1sec("Sendet STRG+ALT+Z für Eclipse-Fullscreen-Plugin")
  SendPlay,{ctrldown}m{altdown}z{altup}{ctrlup}
  Last_A_This:=A_ThisFunc . A_ThisLabel
	;ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
	WinActivate, - Eclipse SDK ahk_class SWT_Window0
return




SetScrollLockState, AlwaysOff

; #PRINTSCREEN::SendEvent,{^}PRINTSCREEN
; ^PRINTSCREEN::SendEvent,{^}PRINTSCREEN
; #CTRLBREAK::SendEvent,{^}CTRLBREAK ; der geht nicht ...
; ^CTRLBREAK::SendEvent,{^}CTRLBREAK
;PRINTSCREEN^CTRLBREAK^CTRLBREAK^PRINTSCREEN^PRINTSCREEN




ReloudFirefoxLoop:
#f5::
;ReloudFirefox
  KeyWait, LWin ; , L ; Wait for the left Alt key to be logically released.
  KeyWait, RWin ; , L ; Wait for the left Alt key to be logically released.

  ; ErrorLevel is set to 1 if the command timed out or 0 otherwise.
  if ErrorLevel   ; i.e. it's not blank or zero.
    exitBecouseOfErrorInLine(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)

  Last_A_This:=A_ThisFunc . A_ThisLabel
	ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
  if ReloudFirefox=on
    ReloudFirefox=off
  else
    ReloudFirefox=on
  SetTimer, Lbl_Toggle_ReloudFirefox , %ReloudFirefox%
return

;#IfWinActive
;^!c::MsgBox You pressed Control+Alt+C in a window other than Notepad/WordPad.


;~ StartTime := A_TickCount
;~ Sleep, 1000
;~ ElapsedTime := A_TickCount - StartTime






#IfWinActive
#Down::Send {Volume_Down 3}  ; Lower the master volume by 3 intervals.
#Up::Send {Volume_Up 3}  ; Upper the master volume by 3 intervals.
;~ On Windows Vista, SoundSet and SoundGet affect only the script itself (this may be resolved in a future version). There are at least two ways to work around this:
;~ 1) In the properties dialog for the file "AutoHotkey.exe" (or a compiled script), change the compatibility setting to "Windows XP".
;~ 2) Have the script send volume-control keystrokes to change the master volume for the entire system. For example:
;~ Send {Volume_Up}  ; Raise the master volume by 1 interval (typically 5%).
;~ Send {Volume_Down 3}  ; Lower the master volume by 3 intervals.
;~ Send {Volume_Mute}  ; Mute/unmute the master volume.
;=========================================


;~ Ctrl-Alt-F Collapse the Current Level 
;~ Ctrl-Alt-Shift-F Uncollapse the Current Level
;~ diese Tastenkombinationen sind zu schwierig für mich (auf Dauer).
;~ numplus
#IfWinActive ahk_class Notepad++
	^+NumpadAdd::
    Last_A_This:=A_ThisFunc . A_ThisLabel
  	ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
    ControlSend,,^!+f,ahk_class Notepad++ ; fold All
  RETURN
#IfWinActive ahk_class Notepad++
	^+NumpadSub::
    Last_A_This:=A_ThisFunc . A_ThisLabel
  	ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
    ControlSend,,^!f,ahk_class Notepad++ ; fold All
  RETURN


;~ Alt-(0~8) Collapse the Level (0~8)
;~ Alt-Shift-0 Unfold All
;~ Alt-Shift-(1~8) Uncollapse the Level (1~8)
#IfWinActive ahk_class Notepad++
	!^::nPPcollapseLevel(0)
#IfWinActive ahk_class Notepad++
	!1::nPPcollapseLevel(1)
#IfWinActive ahk_class Notepad++
	!2::nPPcollapseLevel(2)
#IfWinActive ahk_class Notepad++
	!3::nPPcollapseLevel(3)
#IfWinActive ahk_class Notepad++
	!4::nPPcollapseLevel(4)
#IfWinActive ahk_class Notepad++
	!5::nPPcollapseLevel(5)
#IfWinActive ahk_class Notepad++
	!6::nPPcollapseLevel(6)
#IfWinActive ahk_class Notepad++
	!7::nPPcollapseLevel(7)
#IfWinActive ahk_class Notepad++
	!8::nPPcollapseLevel(8)

;#IfWinActive
;^!c::MsgBox You pressed Control+Alt+C in a window other than Notepad/WordPad.



KeyState(Key, State) {
   GetKeyState, S, %Key%, %State%
   Return, %S%
}


;~ Alt-(0~8) Collapse the Level (0~8)
;~ Alt-Shift-0 Unfold All
;~ Alt-Shift-(1~8) Uncollapse the Level (1~8)
nPPcollapseLevel(level){
 	ControlSend,,!0,ahk_class Notepad++ ; fold All
	if(level>0)
	{
		; Unfold
		Loop, %level%
		ControlSend,,{Shift down}!%A_Index%{Shift up},ahk_class Notepad++
	}
	return
}

;SetTitleMatchMode, 2
#IfWinActive ahk_class Notepad++
	~^tab::
    Last_A_This:=A_ThisFunc . A_ThisLabel
		ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . A_ThisFunc . A_ThisLabel . "`nDies ist eine Notlösung unter Vista" )
		;WinActivate, ahk_class Notepad++
		;WinActivate, ahk_class #32770
		;ControlFocus, , ahk_class Notepad++  ;, WinText, ExcludeTitle, ExcludeText]
		Sleep,2000
		ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . A_ThisFunc . A_ThisLabel . "`nTabTab als Notlösung nach 5 Sekunden" )
		Send,!{Tab}!{Tab}
		;ControlClick, x200 y400, ahk_class Notepad++  ; Clicks at a set of coordinates
	;~^tab::ControlSend , N, hallo, ahk_class Notepad++ ; ControlSend , N,  ahk_class Notepad++ ;, WinText, WhichButton, ClickCount, Options, ExcludeTitle, ExcludeText]
  return

  
;~ same hotkey subroutine executed by more than one variant:
#IfWinActive In Datei speichern ahk_class #32770
  *Space::
#IfWinActive Bitte geben Sie den Dateinamen an`, unter dem die Datei gespeichert werden soll… ahk_class #32770
  *Space::
#IfWinActive Sichern als ahk_class #32770
  *Space::
#IfWinActive Enter name of file 
  *Space::
#IfWinActive Speichern unter ahk_class #32770
  *Space::
#IfWinActive Save as ahk_class #32770
  *Space::
#IfWinActive Save As ahk_class #32770
  *Space::
  Send,_
return  

#IfWinActive Dragon NaturallySpeaking 11 - InstallShield Wizard ahk_class MsiDialogCloseClass
  #-::
    NewStr=Clipboard
    NewStr:=convert123To_NumPad123(NewStr)
    ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
    ;StringReplace,NewStr,NewStr,-,{tab},All
    StringReplace,NewStr,NewStr,-,,All
    SendEvent,%NewStr%
return









SetTitleMatchMode,2
#IfWinActive,- IntelliJ IDEA 14.1.3 ahk_class SunAwtFrame 
Strg_Shift_5:
^%::
+%::
tipp_use_STRG_J = tipp: use STRG+J type sout
  Last_A_This:=A_ThisFunc . A_ThisLabel
  ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This . "`n" . tipp_use_STRG_J)

  if(StrLen(clipboard) < 100 )    
  {
    c := clipboard
    
    c2 := "{NumpadAdd} "" = " . c . "\n"""
  ; k
    strLen_c2 := StrLen(c2) - StrLen("{NumpadAdd}") + 1
    Suspend,on
  
    Send,%c% %c2%{ShiftDown}{Left %strLen_c2%}{ShiftUp}
    Suspend,off
  }
  return



#IfWinActive Chrome Remote Desktop
  ^w::
m= Oops. dont close Chrome Remote Desktop 
ToolTip3sec(A_LineNumber . " " . A_ScriptName . "`n " . m)
  return

#IfWinActive Chrome Remote Desktop
esc::
m= Oops. pls leave it fullscreen. Chrome Remote Desktop 
ToolTip3sec(A_LineNumber . " " . A_ScriptName . "`n " . m)
return


;~ same hotkey subroutine executed by more than one variant:
#IfWinActive In Datei speichern ahk_class #32770
  ^v::
#IfWinActive Bitte geben Sie den Dateinamen an`, unter dem die Datei gespeichert werden soll… ahk_class #32770
  ^v::
#IfWinActive Sichern als ahk_class #32770
  ^v::
#IfWinActive Enter name of file 
  ^v::
#IfWinActive Speichern unter ahk_class #32770
  ^v::
#IfWinActive Save As ahk_class #32770
  ^v::
#IfWinActive Save as ahk_class #32770
  ^v::
  Last_A_This:=A_ThisFunc . A_ThisLabel
  ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)


;NewStr := clipboard
  	NewStr := SubStr(clipboard, 1 , 400) ;specify 1 to start at the first character
    ;NewStr := RegExReplace(NewStr, "(\w+)", "$1") 
    ;RegExReplace
    ;NewStr:= RegExReplace(NewStr, "[A-Za-z]", "")  ;  funktioniert
    NewStr := RegExReplace(NewStr, "\s+", "_") 
    NewStr:= RegExReplace(NewStr, ".*?([A-Za-z_\d\\\.\:]*)", "$1")  ;  
  	NewStr := SubStr(NewStr, 1 , 255) ;specify 1 to start at the funktioniert
  
  	Needle = .
  	StringGetPos, pos, NewStr, %Needle%
  	if pos >= 0
  	{
  	    ;MsgBox, The string was found at position %pos%.
  	}
  	else
  	{
  		NewStr=%NewStr%.txt
  	}
    NewStr:=convert123To_NumPad123(NewStr)

  Suspend,On
  SendEvent,%NewStr%+{left 4}
  Suspend,Off

;NewStr := RegExReplace(NewStr, "(\w+)", "$1") 
  return  


;~ notepad++ hat die blöde angewohnheit alt+d zu benutzen.
;~ #IfWinActive - Notepad++ ahk_class Notepad++
  ; !d::
  ; msgbox, no
;~ return
  

#IfWinActive ahk_class freemind.main.FreeMind
  #ö:: ; göögle -suche
    Last_A_This:=A_ThisFunc . A_ThisLabel
  	ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
    ;SendEvent,^+c ; einfach kopiern ... reicht aber nicht bei Emails und links
    SendEvent,{f2}
    Sleep,500
    SendEvent,^a^c ; einfach kopiern ... reicht aber nicht bei Emails und links
    run,http://www.google.com/search?q=%clipboard%&esrch=BetaShortcuts
  return



ToggleFullScreen(ByRef hWnd)
{
  IniFile := A_ScriptName ".tmp"
  IniRead, Array, %IniFile%, Handles, %hWnd%, Empty
  If (Array="Empty")
    {
      hMenu := DllCall("GetMenu", "UInt", hWnd)
      WinGet, Maximized, MinMax
      DllCall("SetMenu", "UInt", hWnd, "UInt", 0)
      WinMaximize
      WinSet, Style, -0xC00000
      IniWrite, %hMenu%`,%Maximized%, %IniFile%, Handles, %hWnd%
    }
  Else
    {
      StringSplit, Array, Array, `,
      hMenu := Array1
      Maximized := Array2
      DllCall("SetMenu", "UInt", hWnd, "UInt", hMenu)
      If !(Maximized)
        {
          WinRestore
        }
      WinSet, Style, +0xC00000
      IniDelete, %IniFile%, Handles, %hWnd%
    }
}



Lbl_Toggle_ReloudFirefox:
  WinGetTitle, Title, A
  if WinExist("ahk_class MozillaUIWindowClass"){
    WinActivate  ; Uses the last found window.
    ControlSend, , {f5}, ahk_class MozillaUIWindowClass
    Last_A_This:=A_ThisFunc . A_ThisLabel
  	ToolTip3sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
  }
  forceWinActivate(Title)
  ;run,http://www.ustream.tv/channel/gbs-papst-demo-berlin-22-09-11
  sleep,9000
return

showTitle:
  ;~ WinGetActiveTitle, at
  WinGetActiveStats, at, Width, Height, X, Y 
  settitlematchmode,3
  WinGetClass, ac , %at%
  
  
  if(!RegExMatch(at . ac, "\w+" ))
  {
    ;~ MsgBox, % at . ac
    ; boring dont need it
    return
  }
  ;~ ahk_class  
 ; w=1366,
 ; x=-898,y=-185,t=0x371ccc
  
  
  MouseGetPos,mousex,mousey,mousewindowtitle
  clipboard=%at% ahk_class %ac% `n `; w=%Width%,`n `; x=%mousex%,y=%mousey%,t=%mousewindowtitle%
  ToolTip,  %clipboard%
  SetTimer, RemoveToolTip, 4000
return




openUrlInOpenFirefoxBrowser(url)
{
  SetTitleMatchMode, 2
  firfox=Mozilla Firefox ahk_class MozillaUIWindowClass
  WinActivate,%firfox%
  WinWaitActive,%firfox%
  WinGetActiveTitle, myActiveTitle
  
    ; Startseite
  if(0)
  {
    Loop, 30
    {
      send,!{home} ; startseite
      sleep,100
      IfWinNotActive,%myActiveTitle%
        break
    }
  }
  Send,^t ; neues tab
  WinGetActiveTitle, myActiveTitle
  sleep,1000
  ;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ; nun endlich die url
  loop,5
  {
    send,{f6}
    sleep,500
    ;send,^a
    ;send,{del}
      Suspend,On
  Suspend,On

    sendplay,%url%
  Suspend,Off

send,{enter}
  Suspend,Off

;WinWaitActive [, WinTitle, WinText, Seconds, ExcludeTitle, ExcludeText]
    ifWinNotActive,%myActiveTitle%
      break
  }
  ;>>>>>>>>>>>>>>>>>>>>>>>><>>>>>>>>>>>>>>>>>>>>>
  return
}









forceWinActivate(t)
{
	sleep,150
	ifwinactive,%t%
			return
	; Windows Vista verhält sich in vielen Dingen eigenartig und eigenwillig.
	; im folgenden soll erzwungen werden, was eigentlich selbstverständlich sein sollte.
	Loop,10
	{
		WinActivate ,%t%
		WinWaitActive,%t%,,1
		ifwinactive,%t%
			break
		;WinWaitActive [, WinTitle, WinText, Seconds, ExcludeTitle, ExcludeText]
	}
	return
}

;~ ToolTipSec.inc.ahk




;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
killAllOpenWinWithoutSave(w)
{
  MsgBox, 4,, Would you KILL KILL now all "...%w%" ? (press Yes or No) `n`n It will take seconds for KILL each of this. `nso its a good chance for making a short nap now.
  IfMsgBox Yes
  	ToolTip3sec("You pressed Yes.`n OK. Now all '...%w%' - Emails will be KILLED.")
  else
    return


  a_index_backup:=0 
  Loop , 100
  {
      a_index_backup:=a_index
      SetTitleMatchMode, 2
      IfWinNotActive,%w%, , WinActivate,%w%, 
      WinWaitActive,%w%,,1 ; Muss nicht eins existieren.
      IfWinActive,%w%
      {
        ;MsgBox,%w% gefunden.
        WinGetActiveTitle, wat
        ;sendActiveEmail()
        WinKill , %wat%,,1
        ;WinKill [, WinTitle, WinText, SecondsToWait, ExcludeTitle, ExcludeText]
        ; Nachricht speichern ahk_class #32770
        WinWaitClose,%wat%,,1
        ;wiWinWaitClose, WinTitle, WinText, Seconds [, ExcludeTitle, ExcludeText]
      }
      else
        break
  }
  return
}
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


StrgAStrgA()
{
;#IfWinActive Mobile Partner ahk_class #32770
;~ manche dialogfelder haben kein strg+a das braucht man aber
;~ daher hier ein doppel strg+a+a macht trotzdem alles markiert.
  Last_A_This:=A_ThisFunc . A_ThisLabel
  ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
	;tooltip,wait for ^aa
	; Wait for the user to press any key. 
	;SendEvent,^a
	Transform, CtrlA, Chr, 1 ; character for Ctrl-A in the CtrlA var. 
	Input, OutputVar, L1 M I T2, {LControl}{RControl}{LAlt}{RAlt}{Shift}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}
	tooltip,
    
    ;return ; demo mode: that you could see that it stops
    
    ;Suspend,On
	if OutputVar = %CtrlA%
    {
      MsgBox,double STRG+A found
      Send,{Control down}{End}
      Sleep,1000 ; demo mode. slow down that you could see something
      Send,{Shift down}{Home}{Shift up}
      Sleep,1000 ; demo mode. slow down that you could see something
      Send,{Control up}
	}
    else
    {
      ;Send,%OutputVar% ;  i stoped that. it not works any more at 12-11-22_10-57
      
      
            ;MsgBox,double STRG+A found
      Send,{Control down}{End}
      Sleep,1000 ; demo mode. slow down that you could see something
      Send,{Shift down}{Home}{Shift up}
      Sleep,1000 ; demo mode. slow down that you could see something
      Send,{Control up}

      
      
      ;MsgBox,else %Last_A_This%
    }
    ;Suspend,Off
  ;MsgBox,return %Last_A_This%
return

}
;~ End of StrgAStrgA:
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

return  ; probably redundant. its more secure if we do that.
#Include *i functions_global.inc.ahk
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;~ subroutinen beispielsweise müsen ans Dateiende
#Include *i functions_global_dateiende.inc.ahk
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#Include *i UPDATEDSCRIPT_global.inc.ahk

