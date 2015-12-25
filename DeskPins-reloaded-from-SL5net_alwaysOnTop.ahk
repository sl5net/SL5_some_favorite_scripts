;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;~ please use this ! as first line in every script before all includes! :)
isDevellopperMode=true ; enthällt auch update script.
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#Include *i init_global.init.inc.ahk


ScriptFileExt:= SubStr(A_ScriptName,StrLen(A_ScriptName) - 2)
;~ MsgBox,%ScriptFileExt% ; if its exe we dont need develoment mode

if(ScriptFileExt="ahk")
  developmentMode:=true
else
  developmentMode:=false


iconAdress=%HardDriveLetter%:\fre\private\HtmlDevelop\AutoHotKey\DeskPins.ico
iconAdressSpeedMode=%HardDriveLetter%:\fre\private\HtmlDevelop\AutoHotKey\DeskPinsSpeedMode.ico

iconAdressSetToNormal=%HardDriveLetter%:\fre\private\HtmlDevelop\AutoHotKey\DeskPins-setToNormal2.ico
iconAdressSpeedModeNormalize=%HardDriveLetter%:\fre\private\HtmlDevelop\AutoHotKey\DeskPinsSpeedModeNormalize2.ico

    ifexist,%iconAdress%
      Menu, Tray, Icon, %iconAdress%


;MouseMove,50,0
;ToolTip,5erts sdfgdsg wwwwwwwww

SplashImageTitle=15-05-16_14-55 ; dont delte it! its importand

programmNummer:=1

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;~ config
leftClickActionMode=setNormalOnTop
leftClickActionMode=setAlwaysOnTop
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

if(developmentMode = true)
{
;STARTOFSCRIPT

ToolTip1sec(A_LineNumber . " " . A_ScriptName . " " . A_ThisFunc . A_ThisLabel)
}
#Persistent  ; Keep the script running until the user exits it.
SetBatchLines, -1

SetWinDelay, 100

Menu, Tray, Add, DekPins reloaded from SL5net, ClickHandler
Menu, Tray, Add, Help, HelpHandler
Menu, Tray, Add, visit SL5.net, SL5netHandler
;~ Menu, Tray, Add

Menu, Tray, Add, Exit DekPins reloaded from SL5net, ExitLabel
Menu, Tray, NoStandard

Menu, Tray, Click, 1
Menu, Tray, Default, DekPins reloaded from SL5net
return

SL5netHandler:
run,http://SL5.net
return

HelpHandler:
MsgBox,Please use double click at tray icon to change mode.`nUse single left click on tray icon`n... and make some first trial and error. `nit isn't so difficult. good luck `;) SL5.net
return

ClickHandler:
ClickCount := SingleDoubleClickFinder("LButton")
IF (ClickCount=1)
{
  
  if(leftClickActionMode = "setAlwaysOnTop")
  {
    ifexist,%iconAdressSpeedMode%
      Menu, Tray, Icon, %iconAdressSpeedMode%
    else
      MsgBox,:( %iconAdressSpeedMode%
    ;~ ToolTip3sec(A_LineNumber)

    SplashImage, DeskPinsSpeedMode.bmp, b W20 H20,,,%SplashImageTitle%
    WinSet, AlwaysOnTop, On,%SplashImageTitle%
    SetTimer,MoveSplashImage,50
  }
  else
  {
    ifexist,%iconAdressSpeedModeNormalize%
      Menu, Tray, Icon, %iconAdressSpeedModeNormalize%
    else
      MsgBox,:( %iconAdressSpeedModeNormalize%
    ;~ ToolTip3sec(A_LineNumber)

    SplashImage, DeskPinsSpeedModeNormalize2.bmp, b W20 H20,,,%SplashImageTitle%
    WinSet, AlwaysOnTop, On,%SplashImageTitle%
    SetTimer,MoveSplashImage,50
  }

  ToolTip3sec("Pls LefClick windows`nduring next 4 seconds.")

  KeyWait, LButton, D T4 ; seconds
  if ErrorLevel   ; i.e. it's not blank or zero.
  {
    ;~ MsgBox,%A_LineNumber%  ´ErrorLevel: %leftClickActionMode%
    ;~ ExitApp
    ToolTip1sec("timout => no window selected.")
    SplashImageOff() ; sollte eigentlich nie notwenig sein
    if(leftClickActionMode = "setNormalOnTop")
      Menu, Tray, Icon, %iconAdressSetToNormal%
    else
      

    ;~ leftClickActionMode=setAlwaysOnTop

    return
  }
  
  WinGetActiveTitle,ActiveTitle
  
  if(leftClickActionMode = "setNormalOnTop")
  {
    WinSet, AlwaysOnTop,Off,%ActiveTitle% 
    setAlwaysOnTopOffLoop()
    ;~ ToolTip3sec(A_LineNumber . ": end loop")
    ;~ ToolTip3sec(A_LineNumber . ": restore tray ion Tray Icon " . iconAdressSetToNormal )
    Menu, Tray, Icon, %iconAdressSetToNormal%
  }
  if(leftClickActionMode = "setAlwaysOnTop")
  {
    AlwaysOnTopAction(ActiveTitle)
    setAlwaysOnTopOnLoop()
    ;~ ToolTip3sec(A_LineNumber . ": end loop")
    ;~ ToolTip3sec(A_LineNumber . ": restore tray ion Tray Icon " . iconAdress )
    
  }
  SplashImageOff()
  SplashImageOff()
  SplashImageOff()
  return

}
Else If (ClickCount=2)
{
  if(leftClickActionMode = "setNormalOnTop")
  {
    leftClickActionMode:=changLeftClickActionMode(iconAdress,"setAlwaysOnTop")
  }
  else
  {
    ;~ leftClickActionMode := changModeToNormalOnTop(iconAdressSetToNormal)
    leftClickActionMode:=changLeftClickActionMode(iconAdressSetToNormal,"setNormalOnTop")
  }
  
	;~ MsgBox,, Tray Icon Double Click,Put here actions for Double %ErrorLevel%-Click.
}
return


;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
setAlwaysOnTopOnLoop()
{
  Loop,99
  {
    WinGetActiveTitle,ActiveTitle
    WinGetActiveTitle,ActiveTitle
    AlwaysOnTopAction(ActiveTitle)
    
    KeyWait, LButton, D T4 ; seconds
    if ErrorLevel
    {
      ;~ ToolTip3sec(A_LineNumber . ": break")
      break
    }
    ;~ ToolTip3sec(A_LineNumber . ": AlwaysOnTopAction(" . ActiveTitle . ")")    
  } 
  return
}
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
setAlwaysOnTopOffLoop()
{
  Loop
  {
    WinGetActiveTitle,ActiveTitle
    WinGetActiveTitle,ActiveTitle
    WinSet,AlwaysOnTop,Off,%ActiveTitle%
    
    setOriginalWinTitle(ActiveTitle)
    
    KeyWait, LButton, D T4 ; seconds
    if ErrorLevel
    {
      ;~ ToolTip3sec(A_LineNumber . ": break")
      break 
    }
    ;~ ToolTip3sec(A_LineNumber . ": AlwaysOnTop,Off," . ActiveTitle . "")
  } 
  return
}
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 ;~ ActiveTitleBackup:=ActiveTitle
    ;~ WinGetActiveTitle,ActiveTitle
    ;~ if(ActiveTitle = ActiveTitleBackup)
    ;~ {
      ;~ ToolTip3sec(A_LineNumber . ": break")
      ;~ break
    ;~ }

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
setOriginalWinTitle(ActiveTitle)
{
  newStrlen := StrLen( ActiveTitle ) - StrLen(" TOP") 
  ActiveTitleLast := SubStr( ActiveTitle, newStrlen + 1 )
  if(ActiveTitleLast = " TOP")
    ActiveTitleNew := SubStr( ActiveTitle, 1 , newStrlen )
  else
    ActiveTitleNew:=ActiveTitle 
  if(ActiveTitleNew < 0)
  {
    ToolTip,:( ActiveTitleNew < 0`n%ActiveTitle% %newStrlen%
  }
  else
  {
    WinSetTitle,%ActiveTitle% , , %ActiveTitleNew%
  }
  return
}
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

SplashImageOff()
  {
  SetTimer,MoveSplashImage,Off
  ToolTip,
  SplashImage, Off
}

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
MoveSplashImage:
CoordMode, ToolTip , Screen
	;~ MouseGetPos,x , y, id, control

  ;~ MouseGetPos, mouseX, mouseY, mouseWin, mouseControl
  ;~ MouseGetPos, mouseX, mouseY, id, control
  ;~ MouseGetPos,mouseX , mouseY, mouseWin, mouseControl
  
  ;~ WinGetPos,wX ,wY , , ,%mouseWin%
  
  		p := getMousePos()
		;~ MsgBox % p["x"] . " mouse "
  
  mouseX := p["x"] - 100
  mouseY := p["y"] - 20
  tx := p["x"] + 100
  ty := p["y"] + 20
  
  ToolTip,%mouseX% %mouseY%, %tx% , %ty%
  ;~ ToolTip,%mouseX%
  ;~ if(mouseX<50)
    ;~ mouseX:=50
  ;~ if(mouseY<50)
    ;~ mouseY:=50
    DetectHiddenWindows,on
    IfWinNotExist,%SplashImageTitle%
      MsgBox,not exist :( %SplashImageTitle% = SplashImageTitle `n 
  WinMove,%SplashImageTitle%,,%mouseX%, %mouseY%  ; Move the splash window 
return
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
getMousePos()
{
	CoordMode, Mouse, Screen 

	MouseGetPos,x , y, id, control
	p := {x:x, y:y}
	return p
}
changLeftClickActionMode(iconAdress,modeValue)
{
  leftClickActionMode:=modeValue
  
  
  return,leftClickActionMode
}
AlwaysOnTopAction(ActiveTitle)
{
  WinSet, AlwaysOnTop, On, %ActiveTitle% ; Toggle the always-on-top status of Calculator.
  ;~ WinSet, Style, -0xC00000, A ; remove title
  ;~ WinSet, Region, 50-0 W200 H250 E, %ActiveTitle% ; cuts it to a circle
  ;~ WinSet, Region, 50-0 , %ActiveTitle% ; cuts it to a circle

  newStrlen := StrLen( ActiveTitle ) - StrLen(" TOP") 
  ActiveTitleLast := SubStr( ActiveTitle, newStrlen + 1 )
  ;~ MsgBox,%ActiveTitleLast%
  if(ActiveTitleLast = " TOP")
    ActiveTitleNew := ActiveTitle
  else
    ActiveTitleNew=%ActiveTitle% TOP

  WinSetTitle,%ActiveTitle%,,%ActiveTitleNew%
  return
}


ExitLabel:
ExitApp
Return


SingleDoubleClickFinder(cKey) { ; Detects Single or Double Click for the specified Key(cKey), and accordingly returns 1 or 2.
	STATIC DblClickSpeed, OldKey, firstClick=0
	If (((A_TickCount-firstClick) < (DblClickSpeed := DblClickSpeed ? DblClickSpeed : DllCall("GetDoubleClickTime"))) && (cKey = OldKey)) {
		ErrorLevel := cKey , firstClick := 0 , OldKey := ""
		RETURN 2		; Double click
	} Else {
		firstClick := A_TickCount , OldKey := cKey
		KeyWait, %cKey%
		KeyWait, %cKey%, % "D T" . DblClickSpeed/1000
		IF (ErrorLevel && firstClick && OldKey) {
			ErrorLevel := cKey , firstClick := 0 , OldKey := ""
			RETURN 1	; Single click
		}
	}
}

ToolTipSec.inc.ahk


return  ; probably redundant. its more secure if we do that.
#Include *i functions_global.inc.ahk
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;~ subroutinen beispielsweise müsen ans Dateiende
#Include *i functions_global_dateiende.inc.ahk
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#Include *i UPDATEDSCRIPT_global.inc.ahk


