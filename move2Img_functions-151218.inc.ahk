;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;~ please use this ! as first line in every script before all includes! :)
isDevellopperMode=true ; enthällt auch update script.
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#Include *i init_global.init.inc.ahk
#Include *i SL5_some_favorite_scripts-master/init_global.init.inc.ahk

winActiveCheck(winExpected , fromLine){
   Loop,5
   {
      WinActivate,%winExpected%
      WinWaitActive,%winExpected%,,1
      IfWinActive,%winExpected%
         break
      Sleep,30
   }
   IfWinNotActive,%winExpected% 
      MsgBox,%fromLine%>%A_LineNumber%:  `n :( not active `n %winExpected%  
   return
}
;    if(	move2ImgORImg(htmlPNG, tmplPNG,"htmlPNG, tmplPNG", yOffset) ) {
move2ImgORImg(i, i2 , textInfo, mm){
   if(!i || !i2 || !textInfo)
   {
      MsgBox, %i% = i `n %i2% = i2  `n   %textInfo% = textInfo (line:%A_LineNumber%) `n 
      return
   }
   kundencenter_Googl = Kundencenter - Google Chrome ahk_class Chrome_WidgetWin_1 ;  

   CoordMode , Pixel , Screen
   CoordMode , Mouse , Screen
   ToolTip, ; clean from distubing tooltips
   ;~ ImageSearch, XPos, YPos, 0, 0, A_ScreenWidth, A_ScreenHeight, *10 %i%
   ; 	 number between 0 and 255 (inclusive) to indicate the allowed number of shades of variation 
   ImageSearch, XPos, YPos1, 0, mm["left"] , mm["top"] , mm["width"] , mm["height"] , *80 %i%
   ImageSearch, XPos, YPos2, 0, mm["left"] , mm["top"] , mm["width"] , mm["height"] , *100 %i2% 
      if(!YPos1)
YPos1 := YPos2 ; try prevent empty variables
      if(!YPos2)
YPos2 := YPos1 ; try prevent empty variables

   if(YPos1 < YPos2) ; take the smaler yPos
      YPos :=  YPos1
   else
      YPos :=  YPos2
   ;~ ImageSearch, XPos, YPos, 0, 0, A_ScreenWidth, A_ScreenHeight,  %i%
   if ErrorLevel = 2
   {
      ; 2 if there was a problem that prevented the command from conducting the search (such as failure to open the image file or a badly formatted option).
      ToolTip3sec(" ErrorLevel = " . ErrorLevel . "`n  :( Die Suche konnte nicht durchgeführt werden.  `n textInfo =`n" . textInfo ) 
      IfNotExist,%i%
         MsgBox,%i% existiert nicht. `n `n  %i% = i (line:%A_LineNumber%) `n 
      return false
   }
   
   else if ErrorLevel = 1
   {
       msg = ErrorLevel: %ErrorLevel%  `n textInfo =`n '%textInfo%'  `n`n '%i%' `n  '%i2%' `n  `n  :( Icon could not be found on the screen.  `n `n   (line:%A_LineNumber%) `n
      ToolTip4sec(msg)  
      Sleep,4000
      return false
   }
   
   ;~ MsgBox Das Icon wurde bei %XPos%x%YPos% gefunden.
   CoordMode, Mouse, Screen ; 
   MouseMove,% XPos ,% YPos , 0
   ;~ MouseMove,
   ;~ SetKeyDelay,50,50
   ;~ MouseClick,left,% XPos + 20 ,% YPos + 20 
   return true
}


move2Img(i , textInfo, mm){
   if(!i || !textInfo)
   {
      MsgBox, %i% = i (line:%A_LineNumber%) `n  ||  %textInfo% = textInfo (line:%A_LineNumber%) `n 
      return false
   }
   if(!mm["left"] || !mm["top"] || !mm["width"] || !mm["height"] )
   {
      msg=A_LineNumber . " " . A_ScriptName . " " . A_ThisFunc . A_ThisLabel
      	ToolTip1sec(msg)
      MsgBox, :( '%mm%' = mm `n %textInfo% `n  (line:%A_LineNumber%) `n  %msg%
      return false
   }
 coord = Screen
 ;~ coord = Client
   CoordMode, ToolTip, %coord%
CoordMode, Pixel, %coord%
CoordMode, Mouse, %coord%
CoordMode, Caret, %coord%
CoordMode, Menu, %coord%
;~ CoordMode,Client
; 
   ;~ CoordMode , Mouse , Screen
   ;~ CoordMode , Caret , Screen
   ToolTip, ; clean from distubing tooltips
   ;~ ImageSearch, XPos, YPos, 0, 0, A_ScreenWidth, A_ScreenHeight, *10 %i%
   ; 	 number between 0 and 255 (inclusive) to indicate the allowed number of shades of variation 
   ;~ ImageSearch, XPos, YPos, 0, % yOffset , A_ScreenWidth, A_ScreenHeight, *85 %i%
   ImageSearch, XPos, YPos, mm["left"] , mm["top"] , mm["width"] , mm["height"] , *85 %i%
   ;~ ImageSearch, XPos, YPos, 0, 0, A_ScreenWidth, A_ScreenHeight,  %i%
      ;~ MsgBox,%ErrorLevel% = ErrorLevel (line:%A_LineNumber%) `n %textInfo% = textInfo `n 

   if ErrorLevel = 2
   {
      ; 2 if there was a problem that prevented the command from conducting the search (such as failure to open the image file or a badly formatted option).
      ToolTip3sec(" ErrorLevel = " . ErrorLevel . "`n  :( Die Suche konnte nicht durchgeführt werden.  `n textInfo =`n" . textInfo ) 
      Sleep,3000
      IfNotExist,%i%
         MsgBox,%i% existiert nicht. `n `n  %i% = i (line:%A_LineNumber%) `n 
      return false
   }
   else if ErrorLevel = 1
   {
       ;~ msg = ErrorLevel: %ErrorLevel%  `n textInfo =`n '%textInfo%'  `n '%i%' `n  `n  :( Icon could not be found on the screen.  `n `n   (line:%A_LineNumber%) `n
      ;~ ToolTip3sec(msg)  
      ;~ Sleep,3000
         ;~ MsgBox,%msg% `n `n  %i% = i (line:%A_LineNumber%) `n 
      ;~ Sleep,1000
      return false
   }
   
   ;~ MsgBox Das Icon wurde bei %XPos%x%YPos% gefunden.
   CoordMode, Mouse, Screen
   MouseMove,% XPos ,% YPos , 0
   ;~ MouseMove,
   ;~ SetKeyDelay,50,50
   ;~ MouseClick,left,% XPos + 20 ,% YPos + 20 
   return true
}

clickImg(i, textInfo, mm, offset = 20){
   ;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   ; offset , mm are assoziativ arrays
   ; offset could given as number. then it will converted to assoziativ array
   ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   ret := move2Img(i, textInfo, mm)
   if(ret)
   {
      if(RegExMatch(offset,"\d+"))
      {
         ;~ MsgBox,%offset% = offset (line:%A_LineNumber%) `n 
         ;~ return
         offset := {left: offset, top:offset}  
      }
      ;~ else
         ;~ offset["left"] , offset["top"]
      CoordMode,Mouse
      SetKeyDelay,50,50
      ;~ MouseClick,left,% XPos + 20 ,% YPos + 20 , 1, , R
      MouseClick,left, offset["left"] , offset["top"] , , 0 , ,  R
      if(false){
      ToolTip, its clicked `n  %textInfo% = textInfo (line:%A_LineNumber%) `n 
      Sleep,3000
      ToolTip
   }
      ;~ MouseClick,
      return ret
   }
   return ret
}

setChromeDefaultZoom(kundencenter_Googl, errorLogMetho=""){
   return true
   WinGetActiveTitle,activeTitle
   ;~ Ctrl+0 for default zoom.
   IfWinNotExist,%kundencenter_Googl% 
   {
      SoundBeepString("MsgBox") 
      MsgBox,:( webSite `n  %kundencenter_Googl% `n  not found (line:%A_LineNumber%) `n
      return false
   }
   WinActivate,%kundencenter_Googl% 
   WinWaitActive,%kundencenter_Googl% 
   Send,^0
   WinActivate,%activeTitle%
   Sleep,200
   return  true
}



moveFilesAndFolders(SourcePattern, DestinationFolder, DoOverwrite = false)
; Moves all files and folders matching SourcePattern into the folder named DestinationFolder and
; returns the number of files/folders that could not be moved. This function requires v1.0.38+
; because it uses FileMoveDir's mode 2.
{
	if DoOverwrite = 1
		DoOverwrite = 2  ; See FileMoveDir for description of mode 2 vs. 1.
	; First move all the files (but not the folders):
    if( !SourcePattern || !DestinationFolder){
	MsgBox,, :( , source or destination could not be empty `n `n  '%SourcePattern%' -> '%DestinationFolder%', 4
      return false
 }
	FileMove, %SourcePattern%, %DestinationFolder%, %DoOverwrite%
	ErrorCount := ErrorLevel
	; Now move all the folders:
	Loop, %SourcePattern%, 2  ; 2 means "retrieve folders only".
	{
		FileMoveDir, %A_LoopFileFullPath%, %DestinationFolder%\%A_LoopFileName%, %DoOverwrite%
		ErrorCount += ErrorLevel
		if ErrorLevel  ; Report each problem folder by name.
			MsgBox Could not move %A_LoopFileFullPath% into %DestinationFolder%.
	}
	return ErrorCount
}

isDirEmpty(Dir){
   Loop %Dir%\*.*, 0, 1
      return false
   return true
}

;   winWaitCorrectWindow() 

winWaitCorrectWindow(){
   return true
   kundencenter_Googl = Kundencenter - Google Chrome ahk_class Chrome_WidgetWin_1
   SetTitleMatchMode,1
   IfWinNotActive ,%kundencenter_Googl% 
   {
      WinWaitActive,%kundencenter_Googl% 
      MsgBox,your back in focus. keep on running the script?
   }
   return  
}


getMultiMonitor()
{
	;~ Run, "C:\Windows\System32\rundll32.exe" shell32`.dll`,Control_RunDLL desk`.cpl ; opens the monitor dialog window

	;~ SysGet, MouseButtonCount, 43
	SysGet, VirtualScreenWidth, 78
	SysGet, VirtualScreenHeight, 79
    VirtualMonitorLeft := 0
    VirtualMonitorTop := 0

	SysGet, MonitorCount, MonitorCount
	;~ SysGet, MonitorPrimary, MonitorPrimary
	;~ Message .= "Monitor Count:`t" MonitorCount "`nPrimary Monitor:`t" MonitorPrimary
	Loop, %MonitorCount%
	{
		;~ SysGet, MonitorName, MonitorName, %A_Index%
		;~ SysGet, Monitor, Monitor, %A_Index%
		SysGet, MonitorWorkArea, MonitorWorkArea, %A_Index%
		;~ Message .= "`n`nMonitor:`t#" A_Index "`nName:`t" MonitorName "`nLeft:`t" MonitorLeft "(" MonitorWorkAreaLeft " work)`nTop:`t" MonitorTop " (" MonitorWorkAreaTop " work)`nRight:`t" MonitorRight " (" MonitorWorkAreaRight " work)`nBottom:`t" MonitorBottom "(" MonitorWorkAreaBottom " work)"
      if( VirtualMonitorLeft > MonitorWorkAreaLeft) 
         VirtualMonitorLeft := MonitorWorkAreaLeft
        if( VirtualMonitorTop > MonitorWorkAreaTop) 
         VirtualMonitorTop := MonitorWorkAreaTop
        
	}
;~ Message .= "`n`n VirtualScreenWidth = " . VirtualScreenWidth
;~ Message .= "`n VirtualScreenHeight = " . VirtualScreenHeight
;~ Message .= "`n`n VirtualMonitorLeft = " . VirtualMonitorLeft
;~ Message .= "`n VirtualMonitorTop = " . VirtualMonitorTop
	;~ msgbox % Message
    mm := {left:VirtualMonitorLeft, top:VirtualMonitorTop, width:VirtualScreenWidth, height:VirtualScreenHeight}
	Return mm
}


mouseMove( p, speed = 0 ) {
   if(!p["x"] && !p["y"] )
   {
      p["x"]:=p["left"]
      p["y"] := p["top"]
   }
      if(!p["x"] || !p["y"] )
      {
      msg=A_LineNumber . " " . A_ScriptName . " " . A_ThisFunc . A_ThisLabel
      ToolTip3sec(msg)
     For key,value in p
      msg .= "`n" key . " = " . value

      MsgBox, :(  `n  (line:%A_LineNumber%) `n  %msg%
      return false
      }
      
      if(0)
      {
            For key,value in p
      msg .= "`n" key . " = " . value

      MsgBox, :(  `n  (line:%A_LineNumber%) `n  %msg%
  
      }
      
   MouseMove,p["x"], p["y"] , speed
}

getMousePos()
{
	CoordMode, Mouse, Screen 

	MouseGetPos,x , y, id, control
	p := {x:x, y:y}
	return p
}


#Include *i functions_global.inc.ahk
#Include *i SL5_some_favorite_scripts-master/functions_global.inc.ahk
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;~ subroutinen beispielsweise müsen ans Dateiende
#Include *i functions_global_dateiende.inc.ahk
#Include *i SL5_some_favorite_scripts-master/functions_global_dateiende.inc.ahk
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#Include *i UPDATEDSCRIPT_global.inc.ahk
#Include *i SL5_some_favorite_scripts-master/UPDATEDSCRIPT_global.inc.ahk
return 