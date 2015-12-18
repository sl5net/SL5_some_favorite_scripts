;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<;~ please use this ! as first line in every script before all includes! :)
isDevellopperMode=true ; enthällt auch update script.
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#Include *i init_global.init.inc.ahk
#Include ping.ahk

lll(A_LineNumber, "window_event_listener.ahk")
;ToolTip5sec("testdd aösldkfjaös asödlfkj asödflkj", 0, 550)
;ToolTip5sec("testdd aösldkfjaös asödlfkj asödflkj", 0, 550)

vBoxGles_WinMax_MaxCount_initial:=3
vBoxGles_WinMax_MaxCount:=vBoxGles_WinMax_MaxCount_initial

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;~ initial

;~ MsgBox % "Round trip time: " . RoundTripTime("127.1.1.0")
;~ MsgBox % "Round trip time: " . RoundTripTime("localhost") ; works only with nummbers
;~ Determines the round trip time (sometimes called the "ping") from the local machine to the address.
;~ Useful for pinging a server to determine latency.

StehSitzDynamik_ON_OFF:=false

lastStoredSec:= A_TickCount/1000

ispyexeAllon:=false
Sleep_before_LoopEndMarker_default=3000
Sleep_before_LoopEndMarker:=Sleep_before_LoopEndMarker_default
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;~ switch on/off
flag_FirefoxHalfTimeOnly:=false
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

;STARTOFSCRIPT

;~ ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . A_ThisFunc . A_ThisLabel)

;~ lll(A_LineNumber, "window_event_listener.ahk")
lll(A_LineNumber, "window_event_listener.ahk")

multiMonitor := getMultiMonitor()


;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
LoopMarker_Beginn:
   Loop, 
   {
      WinWaitNotActive , %tc%
      ;msgbox, notaktiv %tc%
      WinGetActiveTitle, ActiveTitle 
      WinGetClass, ActiveClass, %ActiveTitle% ; , WinText, ExcludeTitle, ExcludeText]
      test=%ActiveTitle% ahk_class %ActiveClass%
      ;msgbox, test=%test%
      sleep, 600
      if( test = tcOld ) continue
         if ( StrLen(test) =  StrLen(tcOld)  AND ( InStr(test , tcOld ) OR InStr(tcOld , test ) ))
      continue
      
      ;ToolTip2sec("`n 1: " . test . " `n 2: " . tcOld, 0, 0)
      Sleep,100
      if( test = tcOld ) 
         continue
      if( test = tcOld ) 
      {
         msgbox, das darf eigentlich hier gar nicht passieren: `n 1: %test% `n 2: %tcOld%
      }
      if( test = "ahk_class" ) continue
         tcOld2:=tcOld 
      
      tOld2:=tOld 
      cOld2:=cOld 
      tOld:=tit 
      cOld:=cla 
      
      tcOld=%tc% 
      tcSetToActiveTitleActiveClass:
      tc=%test%
      tit=%ActiveTitle% 
      cla=%ActiveClass%
      
      sec2:=sec1
      sec1 := A_TickCount/1000
      secDiff := sec1 - lastStoredSec 
      min20 := (1000*60)*20
      if( secDiff > 1 )
      {
         lastStoredSec:=sec1
      }
      if( secDiff > 9 AND secDiff < min20 )
      {
         ;ToolTip , secDiff= %t%
         t2SQL:=tOld
         t2SQL:=SubStr(t2SQL, 1, 50)
         ;23456789012345678901234567890123456789012345678901234567890
         ;~        0         0         0         0         0         0
         ; instr ...  0 is synonymous with "false", making it an intuitive "not found"
         
         ;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
         ;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
         
         ;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
         ;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
         LogWinTitleToMySql_Beginn: 
         if(0)
         {
            ;ob=C:\Program Files (x86)\_\OffByOne_kleinster_Browser\ob1.exe http://google.de
            p=sess=123456798987654321sebrai&t=%t2SQL%&c=%cOld%&secDiff=%secDiff%&pc=%A_ComputerName%
            StringReplace, p, p, %A_SPACE%, +, All
            
            ;Run, Target [, WorkingDir, MaxMin|Hide|UseErrorLevel, OutputVarPID]
            OutputVarPID=
            RunOBexe: 
            if(1)
            {
               Run,ob1.exe http:// . .... _\OffByOne_kleinster_Browser , Hide, OutputVarPID
               ;msgbox,%p%
            }else  {
               Run,ob1.exe http://   .... insert.php?%p% , C:\Program Files (x86)\_\OffByOne_kleinster_Browser , , OutputVarPID
               Sleep,9000
            } 
            DetectHiddenWindows, On
            
            ;WinWait [, WinTitle, WinText, Seconds, ExcludeTitle, ExcludeText]
            WinWait ahk_pid %OutputVarPID%,,1
            
            loop
            {
               Sleep,1000
               Process, Close, %OutputVarPID%
               WinWaitClose ahk_pid %OutputVarPID%
               WinClose ahk_pid %OutputVarPID%
               Sleep,100
               WinKill ahk_pid %OutputVarPID%
               ; OffByOne - Google ahk_class Afx:400000:b:10003:6:168211f9
               SetTitleMatchMode, 1
               woby=OffByOne ; - Page Status 
               IfWinNotExist, %woby%
                  break
               WinClose, %woby%
               Sleep,100
               WinKill, %woby%
            }
            DetectHiddenWindows, Off
         }
         ;OffByOne - The Off By One Web Browser - Start Page ahk_class Afx:400000:b:10003:6:5da1123
         ;OffByOne - Google ahk_class Afx:400000:b:10003:6:266110b
         ; WinHide [, WinTitle, WinText, ExcludeTitle, ExcludeText]
      }	
      ;msgbox,o2=`n2=%tcOld2% `no=%tcOld% `nc=%tc%
      ;tooltip, neues fenster aktiv %tc%
      ;msgbox, neues fenster aktiv %tc%
      
      ;=======================================================
      
      ; kleine eigentlich andere / Themenfremde Überprüfungen:
      ; das ist hier eine kleine provisorische Lösung für ein Bug
      ; das mit mir unter Vista aufgefallen ist.
      ; das passiert zum Beispiel nach einem Control+Tab im Notepad Editor. 08-06-26_11-44
      ; GetKeyState, state, Shift
      ; if state = D
      ; Send,{shift up}
      ;MsgBox At least one Shift key is down.
      
      ; GetKeyState, state, Alt
      ; if state = D
      ; Send,{alt up}
      
      
      ;=======================================================
      ; um man zur debuggin zeit zu sehen welche fenster hier alles durchkommen:
      ;FileAppend, %tc%`n, D:\tc_fensterlog_top.txt
      
      SetTitleMatchMode,3
      ; <???> ist so ein blöder NatSpeak wenns MIC an ist Tooltip blöderer stährt 
      TitleOfNSpeakExeTooltip=:"<???> ahk_class #32770"
      if WinExist(TitleOfNSpeakExeTooltip)
      WinSetTitle, %TitleOfNSpeakExeTooltip%, ,  , ; ExcludeTitle, ExcludeText] 
      
      temp := RegExReplace(ActiveClass, "\W+", "", ReplacementCount)  
      
      ; nur anfangsbuchstaben des titells, maximal begrentzt stück
      temT := SubStr( RegExReplace(ActiveTitle, "([\d\w])\w*\W*", "$1", ReplacementCount) , 1 , 6 ) 
      
      ;ToolTip3sec(temT )
      ;MsgBox, %temT%
      
      fNameContextHelp=%temp%.txt ; class_spezifisch
      if(temT)
         fNameContextHelp2=%temp%_%temT%.txt ; classTitle_spezifisch
      else
         fNameContextHelp2:=fNameContextHelp 
      
      ;MsgBox, %fNameContextHelp2%
      
      
      fAdressContextHelpLast:=fAdressContextHelp
      
      fAdressContextHelp = %HardDriveLetter%:\fre\private\contextHelpAutohotkeyGenerated\%fNameContextHelp%
      fAdressContextHelp2 = %HardDriveLetter%:\fre\private\contextHelpAutohotkeyGenerated\%fNameContextHelp%
      
      ;wTitleContextHelp=%fNameContextHelp% ahk_class Notepad
      
      ;~ 
      FE1:=FileExist(fAdressContextHelp)
      if(fAdressContextHelp <> fAdressContextHelp2)
         FE2:=FileExist(fAdressContextHelp2)
      else
         FE2:=FE1
      
      if( FE1 OR FE2 )
      {
         if ( fAdressContextHelpLast <> fAdressContextHelp )
         {
            editthis:="[Shift+F1]=changeText" ; ( " . tc . " )"
            text:=""
            text:=readPartFromFile(fAdressContextHelp)
            if(fAdressContextHelp<>fAdressContextHelp2)
               text:= text . readPartFromFile(fAdressContextHelp2)
            textLength := StrLen(text)
         }
         if( textLength > 0 )
         {
            ; manchmal ziehts das fenster mit wenn gerade die mausgedrückt ist/war
            ; was wir aber nicht wollen.
            ; WinGetActiveStats, Title, Width, Height, X, Y 
            
            WinGetActiveStats, wTitleBlaBlaUnbekannt, wWidth, wHeight, wX, wY 
            MouseGetPos, X, Y ; , OutputVarWin, OutputVarControl , 3
            
            if( test = tcOld )
            {
               ; das darf eigentlich gar nicht passsieren
               Sleep,1000
               continue
            } 
            ToolTip2sec(text . " " . editthis , 0, 0)
            ;~ MsgBox,%text% := text `n %editthis% := editthis `n
            ;ToolTip2sec(text . " " . editthis . " `n" . test . " `n" . tcOld, 0, 0)
            Sleep,1000
            
            ;###################
            ; deswegen soll kein capture ausgelöst werden
            ; daher sleep
            ;sleep,2200
            ;###################
            
            ;ToolTip,%text% %editthis% , 0, 0
            ;ToolTip, %match%, %A_CaretX%, %display_y%
         }
         
         textLengthOld := textLength
         ;textOld:=text
      } 
      
      
      ;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      
      
      
      
      
      ;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      ;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      




      
      
      TODO_AbstractSpoon_Preferences: 
      needle=Preferences (User Interface > Column Selection) ahk_class #32770
      needle2=Preferences (General) ahk_class #32770
      ;~ 	ToolTip3sec(A_LineNumber . " " . A_ScriptName . " 'n " . "")
      if( 1 AND (InStr(tc, needle) OR InStr(tc, needle2) ))
      {
         ;Send,{tab}{tab}{tab}
         ;MsgBox, test
         ;diff:=abs( workbraveLogRuhepause - A_Now)
         ;workbraveLogRuhepause:=A_Now
         ;FileAppend, %diff% (%A_Now%)`n, %needle%.log.txt
      }
      
      
      TODO_AbstractSpoon: 
      needle=ToDoList (c) AbstractSpoon ahk_class ToDoListFrame
      needle2:=needle
      ;~ 	ToolTip3sec(A_LineNumber . " " . A_ScriptName . " 'n " . "")
      if( 1 AND (InStr(tc, needle) OR InStr(tc, needle2) ))
      {
         ;Send,{tab}{tab}{tab}
         ;~ MsgBox, 14-12-12_13-00
         ;diff:=abs( workbraveLogRuhepause - A_Now)
         ;workbraveLogRuhepause:=A_Now
         ;FileAppend, %diff% (%A_Now%)`n, %needle%.log.txt
      }
      
      
      
      ;~ SAP2Office_implementation.graphml - yEd ahk_class SunAwtFrame
      needle=yEd ahk_class SunAwtFrame
      if( InStr(tc, needle) )
      {
         ;~   Run,yEd_v3.0.0.8-fastEdit.ahk
         Send,{f2}
      }
      
      
      ; ###################################
      ; ###################################
      ; ###################################
      SetTitleMatchMode, 3
      n=Screenshot Captor Options ahk_class TOptionsForm
      n2=ahk_class
      n3=ahk_class TOptionsForm
      n4=ahk_class #32770
      n5=ahk_class MozillaUIWindowClass
      ;tooltip,hölkjölkjölkjölkjölkjölkjölkjölkjölkjölkjlö
      ;pause
      if( tc = n OR tc = n2 OR tc = n3 OR tc = n4 OR tc = n5 )
         continue
      
      
      
      Sleep,%Sleep_before_LoopEndMarker%
      ; ###################################
      ; ###################################
      ; ###################################
      ;SplashTextOn, 600, 300, StehSitzDynamik, test
   }
   LoopEndMarker:
   
   exitapp
   ;###############################################
   
   
   
   
   
   
   
   
   mySplashTextOff:
   ; as label wird nie erreicht :-(((
   ; oder doch??? gerade wurde es ereicht
   ;MsgBox, tach
   ;IfWinExist , StehSitzDynamik
   ;  MsgBox, Text
   ; sicherheitshallber mach ich das noch in den update script timer
   Last_A_This:=A_ThisFunc . A_ThisLabel 
   ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
   SplashTextOff
   ;SplashTextOff, , , StehSitzDynamik
return

;###############################################








readPartFromFile(fAdress)
{
   Loop
   {
      FileReadLine, line, %fAdress%, %A_Index%
      if ErrorLevel
      break
      StringLen, len, line
      if ( len = 0 AND A_Index = 1 )
      {
         ; if the first line is empty ... now text will showed,
         ; only the default-hint that text is availeble.
         text=. . .
         break
      }
      
      if ( len = 0 )
         continue
      if ( A_Index = 1 )
         text=%line%
      else
         text=%text%`n%line%
      if ( A_Index >= 2 )
      {
         text=%text% . . .
         break
      }}
   return text
}

SendSlow(s,ms)
{
   Last_A_This:=A_ThisFunc . A_ThisLabel
   ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
   StringLen, len, s
   Loop,%len%
   {
      one:=SubStr(s, A_Index, 1)
      one:=convert123To_NumPad123(one)
      Tooltip,%one%
      Send,%one%
      Sleep,%ms%
   }
   ToolTip3sec(A_LineNumber . " " . A_ScriptName . " " . Last_A_This)
}

;===================================================================





; #Include move2Img_functions.inc.ahk

#Include *i functions_global.inc.ahk
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;~ subroutinen beispielsweise müsen ans Dateiende
#Include *i functions_global_dateiende.inc.ahk
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#Include *i UPDATEDSCRIPT_global.inc.ahk