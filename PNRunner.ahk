#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
#SingleInstance Force
DetectHiddenWindows, Off
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Persistent
;#NoTrayIcon

WinGetTitle, ParentWindow, ahk_exe EmulationStation.exe


Global ini := A_ScriptDir . "\PNRunner.ini"

if (A_Args.Count() > 1)
	loop % A_Args.Count()
		if (A_Index = 1) 
			Arg := A_Args[A_Index]
		else
			Arg := Arg . " " . A_Args[A_Index]
else
	Arg = %1%

GameCommand := Arg

IniRead, PNUrlFull, % Arg, InternetShortcut, URL

PNUrlStr := StrReplace(PNUrlFull, "playnite://") 
PNUrl := StrSplit(PNUrlStr, "/")
count := PNUrl.Length()

if (PNUrl.Length() = 3)
{
	Target := PNUrl[1]
	Cmd := PNUrl[2]
	CmdArg := PNUrl[3]
	gosub pUrlStuff
}
else
{
	msgbox failed to parse url
}




if (Target = "playnite") and (Cmd = "start")
{
	Global StartID := CmdArg
	IniRead, Delay, % ini, Settings, WindowsDetectDelay(seconds), 30
	
	Delay := Delay * 1000
	
	ExeToMonitor := GetExeName(StartID)
	;msgbox % ExeToMonitor
	if (ExeToMonitor = "unset") or (ExeToMonitor = "noini")
	{
		WinListBefore := GetCurrentWindows()
		Run, %PNUrlFull%
		sleep %Delay%
		WinListAfter := GetCurrentWindows()
		
		Global ExeList := [] 
		loop % WinListAfter.Length()
		{
			AfterIndex := A_Index
			Global Match := "0"
			loop % WinListBefore.Length()
				if (WinListBefore[A_Index] = WinListAfter[AfterIndex])
					Global Match := "1"
			
			if (Match = 0)	
			{
				WinGet, ExeName, ProcessName, % WinListAfter[AfterIndex]
				
				ExeList.Push(ExeName)
				
				;NewWinList.Push(WinListAfter[AfterIndex])
			}
		}
		
		if (ExeList.Length() > 1 )
		{
			loop % ExeList.Length()
				global ExeListStr .= ExeList[A_Index] . "|"
			;pick one in gui
			;set it
			Gui, New, , ExePicker
			Gui, Font, Bold Underline
			Gui, Add, Text, R0.7, Select an exe file to monitor for this game.
			Gui, Font, norm
			Gui, Add, DropDownList, R0.7 vExeToMonitor, % ExeListStr
			Gui, Add, Button, GSaveIt w80, Save
			Gui, Show			
		}
		else
		{
			ExeToMonitor := ExeList[1]
			SetExeName(StartID, ExeToMonitor)
			MonitorExe(ExeToMonitor)
		}
	}
	else
	{
		Run, %PNUrlFull%
		MonitorExe(ExeToMonitor)
	}
	
	
}	
	

	

return ;;;;;;;;;;;;;;functions

SaveIt:
{
	
	Gui, Submit 
	SetExeName(StartID, ExeToMonitor)
	MonitorExe(ExeToMonitor)
return
}


GetCurrentWindows()
{
	WinGet windows, List
	Loop %windows%
	{
		id := windows%A_Index%
		WinGetTitle wt, ahk_id %id%
		if (wt != "")
			r .= wt . ""
	}
	windowlist := StrSplit(r, "")
	return windowlist
}


GetExeName(StartID)
{
	IfExist, % ini
		IniRead, WatchExeName, % ini, ExeToWatch,% StartID , unset
	else
		WatchExeName := "noini"

return WatchExeName
}


SetExeName(StartID, ExeName)
{
	IfNotExist, % ini
		IniWrite, 30, % ini, Settings, WindowsDetectDelay(seconds)
		
	IniWrite, % ExeName, % ini, ExeToWatch, % StartID
}


MonitorExe(Exe)
{
	;msgbox would monitor %Exe%
	Process, Wait, % Exe   ;WinWait, % Exe
	Process, WaitClose, % Exe   ;WinWaitClose, % Exe
	WinWaitActive, Playnite, , 10
	WinMinimize, Playnite
	WinActivate, ahk_exe EmulationStation.exe
	;msgbox would exit
	ExitApp
}





pUrlStuff:
{
UrlStuff = 
(
Target := %Target%
Cmd := %Cmd%
CmdArg := %CmdArg%
)
return
}

