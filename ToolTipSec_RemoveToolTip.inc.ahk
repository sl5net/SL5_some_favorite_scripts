#Include *i init_global.init.inc.ahk
#Include *i SL5_some_favorite_scripts-master/init_global.init.inc.ahk
;~ GLOBAL_lllog_only_this_scriptName=ToolTipSec_RemoveToolTip.inc.ahk
RemoveToolTip()
{
  gosub,RemoveToolTip
}
;~ l;~ ll
RemoveToolTip:
  Last_A_This:=A_ThisFunc . A_ThisLabel
  ToolTip,
  SetTimer, RemoveToolTip, Off
return
#Include *i UPDATEDSCRIPT_global.inc.ahk
#Include *i SL5_some_favorite_scripts-master/UPDATEDSCRIPT_global.inc.ahk
