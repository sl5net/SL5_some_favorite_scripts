;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;~ please use this ! as first line in every script before all includes! :)
isDevellopperMode=true ; enthällt auch update script.
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#Include *i init_global.init.inc.ahk
#Include *i SL5_some_favorite_scripts-master/init_global.init.inc.ahk


#IfWinActive, 

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; sorten to long mont names. Lange Monath Names
:*:Janu::Januar
:*:Febr::Februar
:*:septe::September
:*:Nove::November
:*:Deze::Dezember



SetTitleMatchMode,2
#IfWinNotActive ahk_class SciTEWindow 
#IfWinNotActive PhpStorm
  :*:^+v::  
  runCopyQ_Ctrl_Shift_v()
return


#IfWinActive ahk_class SciTEWindow 
:*:´::
  Last_A_This:=A_ThisFunc . A_ThisLabel
  ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
  Suspend,on
  Send,````{BackSpace}
  ;~ Send,```
  Suspend,off
  lll(A_LineNumber, "StringReplaceEveryWhere.ahk",Last_A_This)
return
    
:*:ToolT::  
  Last_A_This:=A_ThisFunc . A_ThisLabel
  ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
  t=ToolTip1sec()
  t:=convert123To_NumPad123(t)
  Send,{Blind}
  Suspend,on
  ;~ Send,ToolTip1sec(){Left}ToolTip1sec()
  Send,%t%{Left}
  Suspend,off
return

:*:__F::  
  Last_A_This:=A_ThisFunc . A_ThisLabel
  ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
  Suspend,on
  FILE := "__" . "FILE" . "__" ; protect it from preprozessor
  FILE2 = FILE_2 :=
  ; protect it from preprozessor
  FILE3 = "__" . "FILE" . "__"
 ; protect it from preprozessor
leftSteps := StrLen(FILE2 . FILE3) + 1
  ;~ Send,%FILE% `; %FILE2%%FILE3% `n {ShiftDown}{left %leftSteps%}{ShiftUp}
  Send,%FILE% `; %FILE2%%FILE3%`n
Sleep,100
  Send,{BackSpace 2}{ShiftDown}{left %leftSteps%}{ShiftUp}
  Suspend,off 
return

:*:lll::  
  Suspend,on
  FILE := "__" . "FILE" . "__" ; protect it from preprozessor
  DIR := "__" . "DIR" . "__" ; protect it from preprozessor
  Send,lll(A_LineNumber, %DIR%%FILE%,Last_A_This){Left}
  Suspend,off
  lll(A_LineNumber, "StringReplaceEveryWhere.ahk",Last_A_This)
  Last_A_This:=A_ThisFunc . A_ThisLabel
  ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
return


;~      :*:l`:`:l::l`:`:l(__LINE__,"StringReplaceEveryWhere.ahk"),'',
; lll(A_LineNumber, "StringReplaceEveryWhere.ahk")
; lll(A_LineNumber, "StringReplaceEveryWhere.ahk")
:*:http::http://
;~ % 

#IfWinActive ahk_class Chrome_WidgetWin_1
:*:autoh::{BackSpace}{Space}Autohotkey{Space} 
:*:atutoh::{BackSpace}{Space}Autohotkey{Space} 
:*:autho::{BackSpace}{Space}Autohotkey{Space} 


::iframep::
s = <a href="http://piratepad.net/%Clipboard%">http://piratepad.net/%Clipboard%</a>   <iframe width="
s := s . "860"
s2 =" scrolling="yes" height="
s3 := 800
s4 = " frameborder="1" src="http://piratepad.net/%Clipboard%"></iframe>

s := s . s2 . s3 . s4 
ssend := convert123To_NumPad123(s)
Send,%ssend%
return


;~ Skype
SetTitleMatchMode,2
#IfWinActive ahk_class tSkMainForm 
; #IfWinActive ahk_class TConversationForm
#IfWinActive ahk_class tSkMainForm 
#IfWinActive ahk_class TConversationForm 
 ; w=400,
 ; x=129,y=516,t=0x11e92
:*:kiss::(kiss)
::y::(y)
::ja::(y)
::yes::(y)
:*:clap::(clap)
:*:angel::(angel)
::hi::(hi)
:*:hug::(bear)
::bear::(bear)
::hearz::(heart)
::herz::(heart)
::heart::(heart)
::herat::(heart)
::hertz::(heart)
::hrtz::(heart)
::sonne::(sun)
::party::(party)
::inlove::(inlove)
::love::(inlove)
::ape::(monkey) 
::affe::(monkey) 
::monkey::(monkey) 
::uff::(whew)  
::whew::(whew)  
::applaus::(clap)   
::clap::(clap)   
::call::(call)
::telefon::(call)





ReloadPyton:
;~ ifwinexist  i)park.*site .* 192.168\..*
;~ SetTitleMatchMode RegEx
SetTitleMatchMode,2
#IfWinActive, ahk_class TkTopLevel
WinGetActiveTitle,at
:*:print::
send,print({end}){f5}
Sleep,500
WinActivate,%at%
return
   


;~ (h5) (highfive) (y) (Y)

;~ http://nullseite.de/2009/01/20/skype-smileys-emoticons-codes/
#IfWinActive Outlook

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
:*:sgh::Sehr geehrter Herr
:*:sgf::Sehr geehrte Frau
:*:sgdh::Sehr geehrte Damen und Herren
:*:fgsl::Freundliche Grüße`n

 
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


:*:gmh::Guten Morgen Herr `n `n


;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 
;:*:mfg:: 
:*:Mfg::Mit freundlichen Grüßen `n Sebastian Lauffer`n
::fsgs::Freundschaftliche Grüße, `n`n Sebastian`n
:*:fsgsl::Freundschaftliche Grüße, `n`n Sebastian Lauffer`n
::vg::Viele Grüße,`n
::vgs::Viele Grüße,`n Sebastian
::sg::Schöne Grüße,`n
::sgs::Schöne Grüße,`n Sebastian
:*:sgsl::Schönen Gruß,`nSebastian Lauffer`n
:*:vgsl::Viele Grüße,`n Sebastian Lauffer`n
:*:bgar::Beste Grüße aus Reutlingen,`n Sebastian Lauffer`n
:*:lgs::Lieben Gruß Sebastian
:*:glg::Ganz lieben Gruß`nS
:*:ghg::Ganz Herzliche Grüße,`nS  
:*:vlg::Ganz viele liebe Grüße, `nS
:*:brs::best regards`nSe
:*:gsl::Gruß,`nSebastian Lauffer`n


;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
::bgs::Beste Grüße,`nSebastian
:*:bgsl::Beste Grüße,`nSebastian Lauffer
::hgs::Herzliche Grüße,`nSebastian
:*:hgsl::Herzliche Grüße,`nSebastian Lauffer
::bds::Bis dahin,`nSebastian Lauffer
:*:bdsl::Bis dahin,`nSebastian Lauffer
::gs::Gruß,`nSebastian

#IfWinActive

::ups::Oops ; Hoppla! Oops!, Whoops!
;~ 
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;~ abkörzunen
:*:ttyl::TTYL (Talk to you later)
TTYL (Talk to you later)
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>



;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
#IfWinActive
;~ vertipper
:*:sebastian::Sebastian
:*:autohtkey::Autohotkey 
:*:autohtkey::deutschsparachig::deutschsprachig
:*:autohtkey::sparachig::sprachig
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>



;<<<<<<<<<<<<<<< doSqlWeb <<<<<<<<<<<<<<<<<<<<<
#IfWinActive doSqlWeb
doSqlWeb:
:*:[a]::[a]'[a *', '*]'[/a]
:*:[b]::[b]'[b *', '*]'[/b]
:*:[c]::[c]'[c *', '*]'[/c]
:*:[d]::[d]'[d *', '*]'[/d]
:*:[e]::[e]'[e *', '*]'[/e]
:*:[f]::[f]'[f *', '*]'[/f]
:*:[m]::[m]'[m *', '*]'[/m]
:*:[s]::[s][s *,*][/s]
:*:[q]::[q][q *,*][/q]

#IfWinActive php
:*:$this::$this->

;~ :*:selec::SELECT * FROM WHERE ORDER BY 

#IfWinActive
;~ doppelte ^ verhindern
:*:^^::
  test:="{^}{space}"
  Send,%test%
return



#IfWinActive ahk_class SciTEWindow 
:*:\n::
    Last_A_This:=A_ThisFunc . A_ThisLabel
  	ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
Send,``n{Space}
return
; `n  





EnforceNumLock:
   NumLockStatus := GetKeyState("Numlock", "T")
    IfEqual, NumLockStatus, 0
      {
      SetNumLockState, On
      ;Uncomment the below line if you want some kind of feedback.
      ;TrayTip,%appname%,NumLock Status = On,,1
      }
Return

forceWinActivate(t)
{
	sleep,150
	ifwinactive,%t%
			return
	; Windows Vista verhölt sich in vielen Dingen eigenartig und eigenwillig.
	; im folgenden soll erzwungen werden, was eigentlich selbstverstöndlich sein sollte.
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
send_convert123To_NumPad123(t)
{
  n:=convert123To_NumPad123(t)
  send,%n%
  return
}

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
getAnredeTimeGenerated( fullAdress:="" , firstname:="",lastname:="", duSie:="Du", mf:="m")
{
  ; Guten Tag sag ich ,wenn ich frï¿½h aufgestanden bin, ab 11Uhr.
  if(fullAdress =="gehieim@gehiemösadlkfjsldfk.com"){
    duSie=du
    firstname=Patric
  }
  
   
  helloHour=Guten Morgen
    
  if(A_Hour > 5)
    helloHour=Guten Morgen
  
  if(A_Hour > 11)
    if(duSie == "du")
      helloHour=Hallo 
	else
      helloHour=Guten Tag 
	

  ;Ich denke in Deutschland sagt man so ab 17:00h guten Abend, da haben viele Leute Feierabend 
  if(A_Hour > 17)
    helloHour=Guten Abend 


  
  anrede:=""
  if(duSie <> "du")
  {
    if(mf <> "")
    {
      if(mf == "m")
        anrede:=" sehr geehrter Herr"   
      if(mf == "f")
        anrede:=" sehr geehrte Frau"  
    }
    use_name:=fullname
    ;MsgBox, %fn_letter%
  }
  else
  {
    ; vorname einfï¿½gen.
    ;MsgBox, %fn_letter%
    use_name:=firstname
  }
  sayHelloText=%helloHour%%anrede% %use_name%,`n`n

  ; Zusatzinfos
  ; InStr(Haystack, Needle [, CaseSensitive?, StartingPos])
  if( InStr(fn_letter,"Nele") )
  {
    sayHelloText=%sayHelloText%(P.S. falls du mal Zeit ...: `n 
    if(random01)
      sayHelloText=%sayHelloText%
    else
      sayHelloText=%sayHelloText%
  }
    



return sayHelloText

}
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
sendSlow(m,t)
{
  Loop, parse, m, `n, `r  ; Specifying `n prior to `r allows both Windows and Unix files to be parsed.
  {
    Suspend,On
    send,%A_LoopField%`n
    Suspend,Off
    t2 := t * StrLen(A_LoopField) 
    Sleep,%t2%
  }
  

}
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


; lll(A_LineNumber, "StringReplaceEveryWhere.ahk")

return  ; probably redundant. its more secure if we do that.
#Include *i functions_global.inc.ahk
#Include *i SL5_some_favorite_scripts-master/functions_global.inc.ahk
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;~ subroutinen beispielsweise müsen ans Dateiende
#Include *i functions_global_dateiende.inc.ahk
#Include *i SL5_some_favorite_scripts-master/functions_global_dateiende.inc.ahk
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#Include *i UPDATEDSCRIPT_global.inc.ahk
#Include *i SL5_some_favorite_scripts-master/UPDATEDSCRIPT_global.inc.ahk

