





;STARTOFSCRIPT



SetTitleMatchMode, 3

TTT=%TTT% shift & f1  - ContextHelp  `n
TTT=%TTT% f12 - CamtasiaRecorder_MicroLautstaerke_openDialog `n  
TTT=%TTT% contextHelpForEveryWindow.ahk `n
TTT=%TTT% This will be displayed for 5 seconds.
ToolTip,  %TTT% 
SetTimer, RemoveToolTip, 5000

shift_f1:
Hotkey, shift & f1, contextHelp

Hotkey, IfWinActive, Camtasia Recorder
Hotkey, f12, CamtasiaRecorder_MicroLautstaerke_openDialog

return

CamtasiaRecorder_MicroLautstaerke_openDialog:
	; toggle Ton
	; WinWaitActive [, WinTitle, WinText, Seconds, ExcludeTitle, ExcludeText]
	WinActivate, Camtasia Recorder, 
	WinWaitActive, Camtasia Recorder,,1 
	IfWinNotActive, Camtasia Recorder
		return


	Send, {ALTDOWN}t{ALTUP}o
	WinWait, Optionen f�r Tools, Immer im &Vordergrun

	IfWinNotActive, Optionen f�r Tools, Immer im &Vordergrun, WinActivate, Optionen f�r Tools, Immer im &Vordergrun
	WinWaitActive, Optionen f�r Tools, Immer im &Vordergrun
	Send, {CTRLDOWN}{TAB}{CTRLUP}
	WinWait, Optionen f�r Tools, Optionen f�r Bildsch
	IfWinNotActive, Optionen f�r Tools, Optionen f�r Bildsch, WinActivate, Optionen f�r Tools, Optionen f�r Bildsch
	WinWaitActive, Optionen f�r Tools, Optionen f�r Bildsch
	Send, {ALTDOWN}u{ALTUP}
	WinWait, Aufnahme, Mikrofon-Balance:
	IfWinNotActive, Aufnahme, Mikrofon-Balance:, WinActivate, Aufnahme, Mikrofon-Balance:
	WinWaitActive, Aufnahme, Mikrofon-Balance:
	Send, {ALTDOWN}t{ALTUP}
return

contextHelp:
contextHelp(HardDriveLetter)
return
contextHelp(HardDriveLetter)
{
	ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . A_ThisFunc . A_ThisLabel)
	SetTitleMatchMode, 1 ; must start match

	;WinGetActiveStats, ActiveTitle, w, h, x, y 
	Seconds:=1

	WinGetActiveTitle, ActiveTitle
	ActiveTitle2:=ActiveTitle
	
	wText=dummy ; wText abzufragen w�re vermutlich zu �bertrieben.
	wText2:=wText
	;WinGetText, wText, %ActiveTitle%

	WinGetClass, ActiveClass, A
	ActiveClass2:=ActiveClass

	WinGetActiveStats, ActiveTitle3, w, h, x, y 

	;SendPlay,{f1}
	
	; F1 hatte keine auswirkung, wir machen unser eigenes Hilfe
	;WinGetClass, ActiveClass, %ActiveTitle%, %wText%
;###############################
	temp := RegExReplace(ActiveClass, "\W+", "", ReplacementCount)  ;

  ; nur anfangsbuchstaben des titells, maximal begrentzt st�ck
  ; nur anfangsbuchstaben des titells, maximal begrentzt st�ck
	temT := SubStr( RegExReplace(ActiveTitle, "([\d\w])\w*\W*", "$1", ReplacementCount) , 1 , 6 ) 

	ToolTip3sec(temT )

	fNameContextHelp=%temp%.txt ; class_spezifisch
  ;MsgBox, %temT% 91
	if(temT)
	{
    ;MsgBox, %temT% 94
   	fNameContextHelp2=%temp%_%temT%.txt ; classTitle_spezifisch
  }
  else
   	fNameContextHelp2:=fNameContextHelp 
	
;###############################

	wTitleContextHelp=%fNameContextHelp% ahk_class Notepad
	wTitleContextHelp2=%fNameContextHelp2% ahk_class Notepad


	visible1:=runContextHelpFile(fNameContextHelp, HardDriveLetter, ActiveClass, ActiveTitle)


	if(fNameContextHelp <> fNameContextHelp2)
  	visible2:=runContextHelpFile(fNameContextHelp2, HardDriveLetter, ActiveClass, ActiveTitle)
  else
    	visible2:=visible1

;~  MsgBox,%A_LineNumber%
    	

 ; msgbox, %visible2% fNameContextHelp=%fNameContextHelp% fNameContextHelp2=%fNameContextHelp2%
  
	if(visible2)
	{
  ;  msgbox,%visible2% %fNameContextHelp2%

  	SetTitleMatchMode, 2 
		WinWaitNotActive, %wTitleContextHelp2%,,%Seconds%
		; WinSet, Attribute, Value [, WinTitle, WinText, ExcludeTitle, ExcludeText]
		WinSet, Style, -0xC00000, %wTitleContextHelp2% ; Remove the active window's title bar (WS_CAPTION).

		bottom:=h+y
		minHeight:=150
		if y > minHeight
			minHeight:=y
		;WinMove, %fName%,, %x%, %bottom% , %w%, 100 ; unten dran kleben
ControlClick , ,  ahk_class Notepad
		;WinMove, %wTitleContextHelp%,, 1, 1 , %w%, %minHeight% ; oben dran kleben
		WinMove, %wTitleContextHelp2%,, %x%, -20 , %w%, %minHeight% ; oben dran kleben
		;tooltip, wTitleContextHelp=%wTitleContextHelp% `n wText=%wText% `n ActiveClass=%ActiveClass%  `n fName=%fName% 
	}
	WinActivate, %wTitleContextHelp2%
	WinWaitActive, %wTitleContextHelp2%,,%Seconds%
	sendplay,{control down}{End}{control up}
Return
}


UPDATEDSCRIPT:
  FileGetAttrib,attribs,%A_ScriptFullPath%
  IfInString,attribs,A
  {
    FileSetAttrib,-A,%A_ScriptFullPath%
    SplashTextOn,,,Updated script,
    Sleep,500
    Reload      ; Script wird neu geladen,neu ausgef�hrt
  }
Return


ToolTipSec.inc.ahk

runContextHelpFile(fNameContextHelp, HardDriveLetter, ActiveClass, ActiveTitle)
{	
  SetTitleMatchMode, 2
	IfWinExist, %fNameContextHelp%
	{
	   return true
	}

		fAdressContextHelp = %HardDriveLetter%:\fre\private\contextHelpAutohotkeyGenerated\%fNameContextHelp%

	IfNotExist, %fAdressContextHelp%
  {
  IfNotExist, %HardDriveLetter%:\fre
    FileCreateDir, %HardDriveLetter%:\fre
  IfNotExist, %HardDriveLetter%:\fre\private
    FileCreateDir, %HardDriveLetter%:\fre\private
  IfNotExist, %HardDriveLetter%:\fre\private\contextHelpAutohotkeyGenerated
    FileCreateDir, %HardDriveLetter%:\fre\private\contextHelpAutohotkeyGenerated
		FileAppend, `n`n`n`n`n`n`n%ActiveClass%-%ActiveTitle% - ShortCut-Notizen und �hnliches:`n, %fAdressContextHelp%
  }
	Run,%fAdressContextHelp%
	Sleep,100
	WinWait, %fNameContextHelp%, , 2000
	IfWinExist, %fNameContextHelp%
	{
	   return true
	}
	return false
}


