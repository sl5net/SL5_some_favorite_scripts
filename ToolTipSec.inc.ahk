#Include *i init_global.init.inc.ahk
#Include *i SL5_some_favorite_scripts-master/init_global.init.inc.ahk

;~ GLOBAL_lllog_only_this_scriptName=ToolTipSec.inc.ahk
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;~ examples:
;~ ToolTip5sec("wwwww`nwwwww`nwwww`n", A_ScreenWidth - 100, A_ScreenHeight - 100)
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#Include *i functions_global.inc.ahk
#Include *i SL5_some_favorite_scripts-master/functions_global.inc.ahk



;~ global jumperVariable6573546378345:=true
;~ jumperVariable6573546378345:=true
;~ LabeljumperVariable6573546378345:

ToolTip1sec(t,x=123,y=321){
  Last_A_This:=A_ThisFunc . A_ThisLabel
  ;~ lll(A_LineNumber, "ToolTipSec.inc.ahk",Last_A_This)
  ToolTipSec(t,x,y,1000)
  return
}


ToolTip2sec(t,x=123,y=321){
Last_A_This:=A_ThisFunc . A_ThisLabel
  ;~ lll(A_LineNumber, "ToolTipSec.inc.ahk",Last_A_This)
  ToolTipSec(t,x,y,2000)
  return
}

ToolTip3sec(t,x=123,y=321){
Last_A_This:=A_ThisFunc . A_ThisLabel
  lll(A_LineNumber, "ToolTipSec.inc.ahk",Last_A_This)

  ToolTipSec(t,x,y,3000)
  return
}

ToolTip4sec(t,x=123,y=321){  
Last_A_This:=A_ThisFunc . A_ThisLabel
  lll(A_LineNumber, "ToolTipSec.inc.ahk",Last_A_This)

  ToolTipSec(t,x,y,4000)
  return
}

ToolTip5sec(t,x=123,y=321){
  ToolTipSec(t,x,y,5000)
  Last_A_This:=A_ThisFunc . A_ThisLabel
  lll(A_LineNumber, "ToolTipSec.inc.ahk",Last_A_This)
  return
}

ToolTipSec(t,x=123,y=321,sec=1000)
{
    Last_A_This:=A_ThisFunc . A_ThisLabel
    lll(A_LineNumber, "ToolTipSec.inc.ahk",Last_A_This)

  if( x=123 AND y=321 )
  {
  	ToolTip, %t%
    lll(A_LineNumber, "ToolTipSec.inc.ahk")
  }
  else
  {
      lll(A_LineNumber, "ToolTipSec.inc.ahk")
	  ToolTip, %t%,%x%,%y%
      ;~ MsgBox,ToolTip %t% %x% %y%
  }


  ; http://www.autohotkey.com/board/topic/81732-try-catch-doesnt-work/
  ;~ .. but here's how to suppress load-time "function not found" errors:
  blank := ""
  ;~ commaBlank := ", "
  ;~ if(isFunc("RemoveToolTip") )
  ;~ RemoveToolTip%blank%( sec )
  SetTimer,RemoveToolTip,%sec%
  ;~ kkk
  ;~ RemoveToolTip( sec )
  ;~ ; jj
  
  ;~ empty:="Timer"
  ;~ Set%empty%,
  return
}

#Include *i ToolTipSec_RemoveToolTip.inc.ahk
#Include *i SL5_some_favorite_scripts-master/ToolTipSec_RemoveToolTip.inc.ahk
