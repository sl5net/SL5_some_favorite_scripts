 ;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<;~ please use this ! as first line in every script before all includes! :)
isDevellopperMode=true ; enthällt auch update script.
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#Include *i init_global.init.inc.ahk

#NoTrayIcon
; test
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 
 
ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . A_ThisFunc . A_ThisLabel) 
#InstallKeybdHook 
;~ http://de.autohotkey.com/wiki/index.php?title=InstallKeybdHook 
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 
 



SetTitleMatchMode, 3

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
TTT=%TTT% shift & f1  - ContextHelp  `n
;~ TTT=%TTT% f12 - CamtasiaRecorder_MicroLautstaerke_openDialog `n  
TTT=%TTT% contextHelpForEveryWindow.ahk `n
TTT=%TTT% This will be displayed for 5 seconds.
ToolTip,  %TTT% 
SetTimer, RemoveToolTip, 5000
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

;ctrl & shift z::
;goto, MyLabel
;return
;MyLabel:
;~  MsgBox You pressed %A_ThisHotkey%.
;return



;~ Hotkey, IfWinActive, Camtasia Recorder
;~ Hotkey, f12, CamtasiaRecorder_MicroLautstaerke_openDialog

return

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
shift_f1:
;Hotkey, shift & f1, contextHelp
shift & f1::
  goto, contextHelp
return
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

;#IfWinActive Sites verwalten ahk_class #32770

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
#IfWinActive, - DragonPad - Dokument.rtf ahk_class TalkpadClass
  TTT=
  TTT=%TTT% Use: -> <- Tab and numbers ...  `n
  TTT=%TTT% f12 - CamtasiaRecorder_MicroLautstaerke_openDialog `n  
  TTT=%TTT% contextHelpForEveryWindow.ahk `n
  TTT=%TTT% This will be displayed for 5 seconds.
  ToolTip,  %TTT% 
  SetTimer, RemoveToolTip, 5000
return
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

CamtasiaRecorder_MicroLautstaerke_openDialog:
	; toggle Ton
	; WinWaitActive [, WinTitle, WinText, Seconds, ExcludeTitle, ExcludeText]
	WinActivate, Camtasia Recorder, 
	WinWaitActive, Camtasia Recorder,,1 
	IfWinNotActive, Camtasia Recorder
		return


	Send, {ALTDOWN}t{ALTUP}o
	WinWait, Optionen für Tools, Immer im &Vordergrun

	IfWinNotActive, Optionen für Tools, Immer im &Vordergrun, WinActivate, Optionen für Tools, Immer im &Vordergrun
	WinWaitActive, Optionen für Tools, Immer im &Vordergrun
	Send, {CTRLDOWN}{TAB}{CTRLUP}
	WinWait, Optionen für Tools, Optionen für Bildsch
	IfWinNotActive, Optionen für Tools, Optionen für Bildsch, WinActivate, Optionen für Tools, Optionen für Bildsch
	WinWaitActive, Optionen für Tools, Optionen für Bildsch
	Send, {ALTDOWN}u{ALTUP}
	WinWait, Aufnahme, Mikrofon-Balance:
	IfWinNotActive, Aufnahme, Mikrofon-Balance:, WinActivate, Aufnahme, Mikrofon-Balance:
	WinWaitActive, Aufnahme, Mikrofon-Balance:
	Send, {ALTDOWN}t{ALTUP}
return
 
contextHelp:
   ;MsgBox, test 09-08-14_12-33
  contextHelp(HardDriveLetter)
return


;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 
;~ includes 
#Include *i functions_global.inc.ahk ; SL5_inc_autoloader_copy2subfolder_and_prepare.ahk 
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;~ subroutinen beispielsweise müsen ans Dateiende
#Include *i functions_global_dateiende.inc.ahk
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

