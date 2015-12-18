#Include *i init_global.init.inc.ahk
#Include *i SL5_some_favorite_scripts-master/init_global.init.inc.ahk


isInteger(var) {
    return var~="^\s*[\+\-]?((0x[0-9A-Fa-f]+)|\d+)\s*$"
}

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
lll(ln, scriptName, text="")
{	
	global GLOBAL_lllog_only_this_scriptName
	scriptName := trim(scriptName)
	GLOBAL_lllog_only_this_scriptName := trim(GLOBAL_lllog_only_this_scriptName)
	if(StrLen(GLOBAL_lllog_only_this_scriptName)>0) {
	do_createLog_notAppendLog:=true
		if(scriptName != GLOBAL_lllog_only_this_scriptName)
			return false
	}
	
	
;~ logFileName=log\%A_ScriptName%.log.txt
	logFileName=log\%scriptName%.log.txt
	
					; M = Modification time (this is the default if the parameter is omitted)
		FileGetTime, cFileMTime, %logFileName%, M
	
		diff_cFileMTime_Now_hour:=A_Now
		EnvSub, diff_cFileMTime_Now_hour, %cFileMTime%, hours
		
		diff_cFileMTime_Now_min:= Round(diff_cFileMTime_Now_hour / 60)

		diff_cFileMTime_Now_day:=A_Now
		EnvSub, diff_cFileMTime_Now_day, %cFileMTime%, days
		
		diff_cFileMTime_Now_year:= Round(diff_cFileMTime_Now_day / 365)
		;~ EnvSub, diff_cFileMTime_Now_year, %cFileMTime%, year

		if(diff_cFileMTime_Now_hour > 1)
			FileDelete,%logFileName%

		;~ if(diff_cFileMTime_Now_day > 7)
			;~ FileDelete,%logFileName%
	
	
	
	if(StrLen(scriptName) < 5 ) ; || "functions_global.inc.ahk" != A_ScriptName ... for that we need a PreCompiler !!!
	{
		lll(A_LineNumber, "functions_global.inc.ahk")
	
		;~ t := ""
		;~ t .= "#Include *i init_global.init.inc.ahk" . "`n"
		;~ t .= "#Include *i functions_global.inc.ahk" . "`n"
		;~ Clipboard := t
	
		Clipboard="%A_ScriptName%" 
		MsgBox, functions_global.inc.ahk `n ln=%ln% `n  scriptName = %scriptName% `n parameter FILE must not be empty `n `n you find this now inside your clipboard : %Clipboard% `n `n move to line %ln% and fix the bug. `n `n or let run the SL5_AHK_preparser.ahk
		return -1		
	}
	;~ tipp: use notepadd++ , diverses> ohne rückfraen aktuallisieren
	;~ tipp: use notepadd++ , diverses> nach aktuallisierung zum ende springen
	msg:=""
	;~ msg.= ";<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<`n"
	
	if(strlen(text)>0)
		msgtext := """" . text . """"
	else
		msgtext := text
	msg.= scriptName . ">" . ln  . msgtext  . "`n"
	;~ msg.= ";>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>`n`n"
	
	global lll
	if(StrLen(lll)>0)
		lll .= msg
	else	
		lll := msg
	Suspend,on
	if(!FileExist("log"))
	{
		FileCreateDir,log
		if(true != InStr(FileExist("log"), "D") )
		{
		;~ would be true only if the file exists and is a directory
		MsgBox,15-05-15_17-00 ops Who could we store logfiles ?
		}
	}
	
;~if(StrLen(GLOBAL_lllog_only_this_scriptName)>0
	if(do_createLog_notAppendLog)
	{
		FileDelete,%logFileName%
		while(FileExist(logFileName))
			Sleep,100
		gLOBAL_lllog = GLOBAL_lllog_only_this_scriptName
		strLen_GLOBAL_lllog := StrLen(gLOBAL_lllog)
		subStr_lll__strLen := SubStr(lll,1,strLen_GLOBAL_lllog)
		if(subStr_lll__strLen != gLOBAL_lllog)
		{
		;~ MsgBox,%subStr_lll__strLen% %GLOBAL_lllog_only_this_scriptName% := GLOBAL_lllog_only_this_scriptName `n
		lll := "GLOBAL_lllog_only_this_scriptName = " . GLOBAL_lllog_only_this_scriptName . "`n" . lll 
		}
	}
	
	FileAppend, % lll, %logFileName%
	;~ ToolTip,%logFileName% := logFileName `n
	;~ MsgBox,%lll%
	Suspend,off
	return
}
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
changeAllIncludeDir_and_copy2dir(used_ahk,preFix,copy2dir){
	if(!FileExist(copy2dir) )
		MsgBox,copydir=%copydir% preFix=%preFix% copydir=%copydir% 
f:=A_ScriptDir . "\" . used_ahk
source:=""
source:=changeAllIncludeDir(f,preFix)
StrLen_source:=StrLen(source)
if(StrLen_source < 100 )
{
	errormsg=ERROR StrLen(source of %f%) < 100 `n source=%source% `n f=%f% `n
	;~ MsgBox,,,errormsg=%errormsg% `n , 2
	ToolTip,errormsg=%errormsg% `n
	;~ Reload
	return -1
}



 b:=";<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<`n"
 e:=";>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>`n"
 source := b . "; warning: this is a copy only! never edit in this file! thanks :-)`n" . e . source . newLine . "`n"
 ;~ MsgBox, ,,%source%,4
 newFileAdress:= copy2dir . "\" .  used_ahk

 FileGetTime, sourceModifiedTime, %f%  ; Retrieves the modification time by default.
exist_newFileAdress:=FileExist(newFileAdress)

if(exist_newFileAdress){
 FileGetTime, targetCreatedTime, %newFileAdress%, C  ; Retrieves the creation time.
 ToolTip,sourceModifiedTime=%sourceModifiedTime%  > %targetCreatedTime% `n

 ;~ MsgBox,,,exist_newFileAdress = %exist_newFileAdress% `n`n newFileAdress=%newFileAdress% `nsourceModifiedTime=%sourceModifiedTime% `n targetCreatedTime=%targetCreatedTime% `n,20



sourceNewerDiff := sourceModifiedTime - targetCreatedTime

   if(InStr(f,"test_area"))
   {
      MsgBox,sourceNewerDiff=%sourceNewerDiff% `n  
      ;~ continue
   }


 if(sourceModifiedTime > targetCreatedTime ) 
{
 ;~ MsgBox,sourceModifiedTime=%sourceModifiedTime%  > %targetCreatedTime% `n

  FileDelete,%newFileAdress%
	;~ MsgBox,FileDelete %newFileAdress%
}
 else
 {
	; thats ok. if source is older we dont need to copy. it takes time so that the copyied files always little newer.
	; lets do nothing and return -1 means not copied
 ;~ MsgBox,sourceModifiedTime=%sourceModifiedTime%  < %targetCreatedTime% `n newFileAdress=%newFileAdress% `n sourceNewerDiff=%sourceNewerDiff% `n
  if( timeDiff > 9 * 1000 * 1000 ) ; if its much newer we take it back to the root version. all changes overwrite.
   return -1
 }
}

 FileAppend,%source%,%newFileAdress%
exist_newFileAdress:=FileExist(newFileAdress)
if(!exist_newFileAdress)
{
	Clipboard=%newFileAdress%
	MsgBox,%A_LineNumber%: ERROR  (!exist_newFileAdress)  newFileAdress=%newFileAdress% `n copy2dir=%copy2dir% `n f=%f% `n StrLen_source=%StrLen_source% `n
	Reload
}

return 1
}
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

;~ whats shift + f5 ?ßß?ß
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
changeAllIncludeDir(f,preFix)
{ 
 source := ""
 Loop
 {
     FileReadLine, line, %f%, %A_Index%
     if ErrorLevel
         break
     newLine := RegExReplace(line, "i)(^#include)(\s+)([^;]+)", "$1$2" . preFix . "\$3 `; automatically replaced by changeAllIncludeDir ") ; case insesitive 
     ;~ newLine := StringReplace(newLine, "\\", "\") ; case insesitive 
     StringReplace, newLine, newLine, \\, \, All

     ;~ source := source . line . "`n"
     source := source . newLine . "`n"
     ;~ if(A_Index > 22)
      ;~ break
     ;~ MsgBox, 4, , Line #%A_Index% is "%line%".  Continue?
     ;~ IfMsgBox, No
         ;~ return
 }
 return source
}
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


isFile(Path)
{
   Return !InStr(FileExist(Path), "D") 
}

isDir(Path)
{
   Return !!InStr(FileExist(Path), "D") 
}

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
rundIfNotExist(m_r , m_WinTitle = "",m_category="")
{
	global runCount ,SleepBeforeRundIfExist 
	; This global variable was previously given a value somewhere outside this function.
	Sleep,%SleepBeforeRundIfExist%

	;~ debug:=1
	debug:=0

	fileName := RegExReplace(m_r, ".*\\([\w\s\.]+)$", "$1")

	if( strlen( m_WinTitle ) > 0 ){
		fileNameWithoutPATHandEXT := m_WinTitle
	}else
	{
		fileNameWithoutPATHandEXT := RegExReplace(m_r, ".*\\([\w\s\._]+)\.\w+$", "$1")
		;~ fileNameWithoutPATH := RegExReplace(m_r, ".*\\([\w\s\._]+)\.\w+$", "$1")
	}

	if(InStr(fileName,"Thunderbird-Portable.exe"))
		fileNameWithoutPATHandEXT=Mozilla Thunderbird ahk_class MozillaUIWindowClass

;~ if(debug && InStr(fileName,"PhpStorm.exe"))
	;~ {
		;~ MsgBox, IfWinNotExist %fileNameWithoutPATHandEXT% `n fileName = %fileName% `n %A_LineNumber%
	;~ }


	DetectHiddenWindows,On
	SetTitleMatchMode,2

	if(0)
	{
		; during debuging sometimes to many windows.
		WinClose,%fileNameWithoutPATHandEXT%
		WinClose,%m_r%
		return
	}

	IfExist,%m_r%
	{
		IfWinNotExist,%fileNameWithoutPATHandEXT%
		{

			;~ Clipboard=OR fileName="%fileName%"
			;~ MsgBox,%fileName%
			;~ MsgBox, IfWinNotExist %fileNameWithoutPATHandEXT% `n fileName = %fileName%
			;~ ExitApp

			ToolTip,%m_category%: %fileNameWithoutPATHandEXT%
			run,%m_r%
			; Waits until the specified window exists.
			WinWait,%fileNameWithoutPATHandEXT%,,5

			runCount := runCount + 1
			;~ run,%m_r%

			if(debug = 1 && InStr(fileName,"PhpStorm.exe"))
			{
				;~ MsgBox, IfWinNotExist %fileNameWithoutPATHandEXT% `n fileName = %fileName% `n %A_LineNumber%
				ToolTip, IfWinNotExist %fileNameWithoutPATHandEXT% `n fileName = %fileName% `n %A_LineNumber%
			}

			IfWinNotExist,%fileNameWithoutPATHandEXT%
			{

				;~ MsgBox,this should not happen
				;~ MsgBox,this should not happen %A_LineNumber%: IfWinNotExist %fileNameWithoutPATHandEXT% `n fileName = %fileName%
				ToolTip,this should not happen %A_LineNumber%: IfWinNotExist %fileNameWithoutPATHandEXT% `n fileName = %fileName%
				; PhpStorm
			}

		}
		else{
			;~ MsgBox,else:  %fileName%
		}



	}else
	{
		if(debug = 1 && InStr(fileName,"PhpStorm.exe"))
		{
			MsgBox, IfWinNotExist %fileNameWithoutPATHandEXT% `n fileName = %fileName% `n %A_LineNumber%
		}
	}
	ToolTip,
	return,runCount

}
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 winGetPos(){
         WinGetPos , left, top, width, height, A   ;, %needle
		    ;~ mm := {left:left, top:top, width:width, height:height}
		    mm := {left:left, top:top, width:width, height:height,right:left + width, bottom:top + height}
return mm
		
}

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
WinActivateTry(wintit,tries){
  SetTitleMatchMode,2 ; anywhere
  ;Frameset neues Spiel (schacharena.de) - Mozilla Firefox ahk_class MozillaUIWindowClass
  ;firefox=Mozilla Firefox ahk_class MozillaUIWindowClass
  Loop,%tries%
  {
    WinActivate , %wintit%
    IfWinActive , %wintit%
      return true
    sleep,100
  }  
  return false
}
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  
contextHelp(HardDriveLetter){
	ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . A_ThisFunc . A_ThisLabel)
	SetTitleMatchMode, 1 ; must start match

	;WinGetActiveStats, ActiveTitle, w, h, x, y 
	Seconds:=1

	WinGetActiveTitle, ActiveTitle
	ActiveTitle2:=ActiveTitle

	wText=dummy ; wText abzufragen wäre vermutlich zu übertrieben.
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

  ; nur anfangsbuchstaben des titells, maximal begrentzt stück
  ; nur anfangsbuchstaben des titells, maximal begrentzt stück
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

  ;  MsgBox,%A_LineNumber%


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
		WinGetActiveStats, bcTitle, Aw, Ah , Ax, Ay 
		x:= Ax
		y:= -20
		w:= Aw
		h:= AY + y * ( -1 ) 
		;h:=  ;minHeight
		WinMove, %wTitleContextHelp2%,, %x%, %y% , %w%, %h%
		; oben dran kleben
	}
	WinActivate, %wTitleContextHelp2%
	WinWaitActive, %wTitleContextHelp2%,,%Seconds%
	sendplay,{control down}{End}{control up}
	Send,{Blind}
Return
} ;  ; 
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
runCopyQ_Ctrl_Shift_v(){
	;~ MsgBox,Ctrl Shift v `n  dont work actually. `n please use Ctrl Shift 1. `n Sorry about that. thanks. 15.06.2015
	;~ return
	; „<LEER> - CopyQ ahk_cl!A_ScriptDir!A_ScriptDir!A_ScriptDiraA_ScriptDirA_ScriptDirss QWidget...“ (3 Zeilen) - CopyQ ahk_class1`11`n`n`n
		SetTitleMatchMode,2
		DetectHiddenWindows,on
	IfWinNotExist,CopyQ ahk_class QWidget
	{
		MsgBox,it not exist
		run,%A_ScriptDir%\SL5_AHK_Refactor_engine\copyq-windows\copyq.exe
		Sleep,2000
	}
  ; ^+v!; ^+v!; ^+v!; ^+v!; ^+v!; ^+v!; ^+v!; ^+vCopyQ ahk_class QWidget
    ; ^+v7!; ^+v!; ^+v!; ^+v!; ^+v!; ^+v\SL5_AHK_Refactor_engine\SL5_AHK_Refactor_engine\SL5_AHK_Refactor_engine
    Last_A_This:=A_ThisFunc . A_ThisLabel . " p"
    lll(A_LineNumber, "keysEveryWhere.ahk",Last_A_This)
	
    ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
; 
SetKeyDelay,80,80
		send,{Blind}
		Sleep,500
		 ;~ if(GetKeyState("ctrl", "P") )
		;~ {
			;~ ToolTip,:( oops 15-06-14_23-49
			;~ return
		;~ }CopyQ ahk_class QWidgetCopyQ ahk_class QWidget
		SetTitleMatchMode,2
		; {ShiftDown}^1{ShiftUp}
	DetectHiddenWindows,on
	Send,{CtrlDown}{ShiftDown}
	Loop,10
	{
		;~ ControlSend, , - CopyQ{ShiftDown}^1{ShiftUp},ahk_class QWidget- CopyQ
		;~ Sen- CopyQd,{S- CopyQhiftDown}^1{ShiftUp} 1runCopyQ_Ctrl_Shift_v1runCopyQ_Ctrl_Shift_v
		Suspend,on
		send,{Numpad1}
		WinActivate,- CopyQ
		Sleep,100
		IfWinActive,- CopyQ
			break
	}
		Send,{ShiftUp}{CtrlUp} 
		Suspend,Off
		;~ MsgBox, :) great CopyQ is active 
	; CopyQCopyQ CopyQCopyQCopyQCopyQCopyQ{CtrlDown}{ShiftDown}1{ShiftUp}{CtrlUp}{CtrlDown}{- CopyQShiftDown}1{ShiftUp}{CtrlUp}
	WinSet, AlwaysOnTop,On,- CopyQ ; Toggle the always-on-top status of Calculator.
    WinWaitActive, - CopyQ ,,2
    if !WinExist("- CopyQ")
      MsgBox, please install CopyQ and add a global hotkey STRG+SHIFT+1 (v is not possible there - or?)

    WinWaitNotActive, - CopyQ
	; - CopyQ- CopyQ
	; cl- CopyQeanUp 
	Clipboard = %Clipboard% 
	
    return
}



file_put_contents(f, c, doOverwrite=1)
{
	;~ MsgBox,f=%f% `n c=%c% `n 
	;~ return
	if(StrLen(c)<1)
	{ 
		MsgBox,really want overwrite with empty? not allowed
		return -1
	}
	if(InStr(f,"*"))
	{
		MsgBox,wildcards not allowed
		return -1
	}
	atc := A_TickCount
	;~ FormatTime, timestamp, %A_now%,yy-MM-dd_HH-mm
	FormatTime, minute, %A_now%,mm
	;~ atc := A_TickCount
	atc := SubStr(minute,2,1)
	;~ MsgBox,atc=%atc% %f% = f `n 
	;~ file_moveName = %f%_%atc%.move

	file_backName = %f%_%atc%.backup
	file_creName = %f%_%atc%.create

	; backup
	FileCopy,%f%,%file_backName%

	; move
	;~ FileMove,%f%,%fileMove_backup%
	

	; write source in temp
	FileAppend, %c%, %file_creName%
	Sleep,100
	
	; overwrite target
	FileMove, %file_creName%, %f%, %doOverwrite%
	Sleep,100

	fileExistf := FileExist(f)
	Sleep,50
	
	if(StrLen(fileExistf) < 1)
	{
		/*
		FileExist(FilePattern): Returns a blank value (empty string) if FilePattern does not exist (FilePattern is assumed to be in A_WorkingDir if an absolute path isn't specified). Otherwise, it returns the attribute string (a subset of "RASHNDOCT") of the first matching file or folder. If the file has no attributes (rare), "X" is returned. FilePattern may be the exact name of a file or folder, or it may contain wildcards (* or ?). Since an empty string is seen as "false", the function's return value can always be used as a quasi-boolean value. For example, the statement if FileExist("C:\My File.txt") would be true if the file exists and false otherwise. Similarly, the statement if InStr(FileExist("C:\My Folder"), "D") would be true only if the file exists and is a directory. Corresponding commands: IfExist and FileGetAttrib.
		*/
		MsgBox,problem f=%f% `n fileExistf=%fileExistf% `n was probably not created :-( `n LETS TRY RESTORE from BACKUP
		FileMove,%file_backName%,%f%
		return -1
	}
	;~ MsgBox,fileExistf=%fileExistf% `n 
	return fileExistf
}
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;~ hilft bei der Adress-Suche vom Icon
runContextHelpFile(fNameContextHelp, HardDriveLetter, ActiveClass, ActiveTitle)
{	
  SetTitleMatchMode, 2
	IfWinExist, %fNameContextHelp%
	{
	   return true
	}

  path=%HardDriveLetter%:\fre\private\contextHelpAutohotkeyGenerated
	fAdressContextHelp=%path%\%fNameContextHelp%

	IfNotExist, %fAdressContextHelp%
  {
  IfNotExist, %HardDriveLetter%:\fre
    FileCreateDir, %HardDriveLetter%:\fre
  IfNotExist, %HardDriveLetter%:\fre\private
    FileCreateDir, %HardDriveLetter%:\fre\private
  IfNotExist, %path%
    FileCreateDir, %path%
		FileAppend, `n`n`n%ActiveClass%-%ActiveTitle% - ShortCut-Notizen und ähnliches:`n`;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<`n%path%, %fAdressContextHelp%
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
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
sendStrgC(trycount = 10)
{
	ClipboardOLD := Clipboard
	Loop,%trycount%
	{
		Sleep,100
		Send,^c
		if(  ClipboardOLD <> Clipboard )
		  break    
	}
	return, Clipboard
}
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


ternaryOperator( bool , t = true, f = false)
{
	if(bool)
		return t
	else
		return f
}

get_obj_ToString(obj){
   s= (line:%A_LineNumber%) `n `n  
   For key,value in obj
      s .= key . " = '" . value . "' `n "
   s = %s% `n `n 
   return s
}

SoundBeepString(s4)
{
   ; converts letters to a 4 digit number oft the alphabet
   ;~ s4:=lower(s4)
   asc_a := Asc("a")
   n:=""
   Loop,4
   {
      l:= SubStr(s4 , A_Index , 1 ) 
	   StringLower,l,l
      l:= Asc( l ) - asc_a + 1
      n .= l
      if(StrLen(n)>4){
         n := SubStr(n,1,4) ; 
		 ;~ if(n > 10000) ; 32767 any peope cant hear
			;~ n = 10000
         break
      }
      
   }
;~ MsgBox, '%s4%' = s4  `n to `n  '%n%' = n (line:%A_LineNumber%) `n        ;  ; 
   SoundBeep,n ,200 ; high beep

return n
}


IfMsgBox_set2Bool:
IfMsgBox Yes
    IfMsgBox:=true
else
    IfMsgBox:=false


;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
convert123To_NumPad123(t)
{
  StringReplace, t, t, 1 , {numpad1}, All 
  StringReplace, t, t, 2 , {numpad2}, All 
  StringReplace, t, t, 3 , {numpad3}, All 
  StringReplace, t, t, 4 , {numpad4}, All 
  StringReplace, t, t, 5 , {numpad5}, All 
  StringReplace, t, t, 6 , {numpad6}, All 
  StringReplace, t, t, 7 , {numpad7}, All 
  StringReplace, t, t, 8 , {numpad8}, All 
  StringReplace, t, t, 9 , {numpad9}, All 
  StringReplace, t, t, 0 , {numpad0}, All 
  msg = '%t%' = t (line:%A_LineNumber%) `n 
   msg .= A_LineNumber . " " . A_ScriptName . " " . A_ThisFunc . A_ThisLabel
	ToolTip2sec(msg)
  return t
}  
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
clipboardPaste(s)
{
  ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . A_ThisFunc . A_ThisLabel)
	if(!s){
		MsgBox, :(  clipboardPaste(s)  '%s%' = s (line:%A_LineNumber%) `n 
		return false
	}

  clipboardOld := clipboard
  clipboard := s
  Suspend,on
  Send,^v
  Suspend,off
  clipboard := clipboardOld
  return true
}
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

FuzzySearch(string1, string2)
{
	lenl := StrLen(string1)
	lens := StrLen(string2)
	if(lenl > lens)
	{
		shorter := string2
		longer := string1
	}
	else if(lens > lenl)
	{
		shorter := string1
		longer := string2
		lens := lenl
		lenl := StrLen(string2)
	}
	else
		return StringDifference(string1, string2)
	min := 1
	Loop % lenl - lens + 1
	{
		distance := StringDifference(shorter, SubStr(longer, A_Index, lens))
		if(distance < min)
			min := distance
	}
	return min
}
;http://www.autohotkey.com/forum/topic59407.html 
StringDifference(string1, string2, maxOffset=1) {    ;returns a float: between "0.0 = identical" and "1.0 = nothing in common" 
  If (string1 = string2) 
    Return (string1 == string2 ? 0/1 : 0.2/StrLen(string1))    ;either identical or (assumption:) "only one" char with different case 
  If (string1 = "" OR string2 = "") 
    Return (string1 = string2 ? 0/1 : 1/1) 
  StringSplit, n, string1 
  StringSplit, m, string2 
  ni := 1, mi := 1, lcs := 0 
  While((ni <= n0) AND (mi <= m0)) { 
    If (n%ni% == m%mi%) 
      EnvAdd, lcs, 1 
    Else If (n%ni% = m%mi%) 
      EnvAdd, lcs, 0.8 
    Else{ 
      Loop, %maxOffset%  { 
        oi := ni + A_Index, pi := mi + A_Index 
        If ((n%oi% = m%mi%) AND (oi <= n0)){ 
            ni := oi, lcs += (n%oi% == m%mi% ? 1 : 0.8) 
            Break 
        } 
        If ((n%ni% = m%pi%) AND (pi <= m0)){ 
            mi := pi, lcs += (n%ni% == m%pi% ? 1 : 0.8) 
            Break 
        } 
      } 
    } 
    EnvAdd, ni, 1 
    EnvAdd, mi, 1 
  } 
  Return ((n0 + m0)/2 - lcs) / (n0 > m0 ? n0 : m0) 
}

stringLower(s)
{
	stringLower,s,s
	return s	; 
}

isUrlAvailable(URL){
   ;~ URL := "http://localhost/xampp/"
   ;~ isUrlAvailable:=isUrlAvailable(URL)

   isUrlAvailable:=true
   try{
      whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
      whr.Open("GET", URL , true)
      whr.Send()
      whr.WaitForResponse()
      ;~ whr_ResponseText := whr.ResponseText
   } catch e
   {
      isExceptionThrown:=true
      ;~ MsgBox, An exception was thrown!`nSpecifically: %e%
   }
   if(ErrorLevel || isExceptionThrown)
   {
      isUrlAvailable:=false
   }
   if(false){
      infoMsg = '%isUrlAvailable%' = isUrlAvailable  `n '%isExceptionthrown%' = isExceptionThrown `n  '%whr_ResponseText%' = whr_ResponseText   `n `n `n `n '%ErrorLevel%' = ErrorLevel `n   '%html%' = html  `n  '%A_AhkVersion%' = A_AhkVersion '%whr%' = whr (line:%A_LineNumber%) `n `n '%whr_status%' = whr_status
      ToolTip, % infoMsg
      Sleep,6000
   }
   return isUrlAvailable
}

#Include ToolTipSec.inc.ahk 
#Include *i SL5_some_favorite_scripts-master/ToolTipSec.inc.ahk 

#Include *i UPDATEDSCRIPT_global.inc.ahk
#Include *i SL5_some_favorite_scripts-master/UPDATEDSCRIPT_global.inc.ahk
