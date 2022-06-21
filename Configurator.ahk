#NoEnv  
SetWorkingDir %A_ScriptDir%  
#NoTrayIcon
#SingleInstance Force
SetBatchLines -1

if A_IsCompiled
{
	PluginDataDir = %1%
	ESDEDir = %PluginDataDir%\EmulationStation-DE



	RunWait, %A_ScriptDir%\CheckSetup.exe "%PluginDataDir%", % A_ScriptDir
	IfExist, %PluginDataDir%\NewLib.json
	{
		RunWait, %A_ScriptDir%\MkEsLib.exe "%PluginDataDir%\NewLib.json", % A_ScriptDir
	}
	else
	{
		IfNotExist, %PluginDataDir%\CurLib.json
		{
			msgbox No library found, `n`nPlease run "Update ES-DE Library" from the extensions menu.
			exitapp
		}
	}
	jsonpath = %PluginDataDir%\CurLib.json
}
else
{
	PluginDataDir = L:\Playnite\ExtensionsData\esdefepn
	ESDEDir = %PluginDataDir%\EmulationStation-DE
	jsonpath = %PluginDataDir%\CurLib.json
}


FileRead, NewLibJson, % jsonpath
NewLib := JsonToAHK(NewLibJson)
PlatformList := []

EsPlatformPath = %PluginDataDir%\EmulationStation-DE\ROMs_ALL

loop % NewLib.Length()
{
	if ( NewLib[A_Index].Platforms.Length() > 1 )
	{
		msgbox more than one platform for "", TODO: handle this 
	}
	else
	{
		Global ThisPlatform := NewLib[A_Index].Platforms
		ThisSourceName := NewLib[A_Index].Source.Name
		if InStr(ThisSourceName, "steam")
			Global ThisPlatform := ThisPlatform . " (Steam)"
			
		if InStr(ThisSourceName, "epic")
			Global ThisPlatform := ThisPlatform . " (Epic)"
			
		;if InStr(ThisSourceName, "origin")
			;Global ThisPlatform := ThisPlatform . " (Origin)"
			
		Global MainLIndex := A_Index
		if (PlatformList.Length() != 0)
		{
			loop % PlatformList.Length()
			{
				ThisPCheck := PlatformList[A_Index]
				if InStr(ThisPCheck, ThisPlatform) and platformExists = 0 and (StrLen(ThisPCheck) = StrLen(ThisPlatform))
					global platformExists = 1
			}
			if !platformExists
				PlatformList.Push(ThisPlatform)
				
			global platformExists = 0
		}
		else
		{
			;msgbox % ThisPlatform
			PlatformList.Push(ThisPlatform)
		}
	}
	global platformExists = 0
}
Global ESPlatformListObj := []
Loop, Files, %EsPlatformPath%\*, D
{
	ESPlatformListObj.Push(A_LoopFileName)
	if (EsPlatformList = "")
		EsPlatformList := A_LoopFileName 
	else
		EsPlatformList := EsPlatformList . "|" . A_LoopFileName
}

Gui, New, , Platform Mapping
Gui, Font, Bold Underline
Gui, Add, Text, R0.7, Playnite Platforms:
Gui, Add, Text, xm+185 yp, Emulationstation Platforms:
Gui, Font, norm
loop % PlatformList.Length()
{
	global L_Platform := PlatformList[A_Index]
	Gui, Add, Text, R0.7 xs, % L_Platform
	loop % ESPlatformListObj.Length()
	{
		global match := 0
		Global L_ESPlatform := ESPlatformListObj[A_Index]
		if ( L_ESPlatform = "n3ds" )
			Global L_ESPlatform := "endo 3ds"
		if ( L_ESPlatform = "n64" )
			Global L_ESPlatform := "endo 64"
		if ( L_ESPlatform = "gc" )
			Global L_ESPlatform := "gamecube" 
		if ( L_ESPlatform = "gb" )
			Global L_ESPlatform := "game boy" 
		if ( L_ESPlatform = "gbc" )
			Global L_ESPlatform := "boy color" 
		if ( L_ESPlatform = "gba" )
			Global L_ESPlatform := "boy advanced" 
		if ( L_ESPlatform = "pc" )
			Global L_ESPlatform := "dosbox"
		if ( L_ESPlatform = "psx" . A_Index )
				Global L_ESPlatform := "playstation 1"
		if ( L_ESPlatform = "ports" )
			{
				Global L_ESPlatform := "pc"
				if InStr(L_Platform, "(Steam)")
					continue
			}
		if ( L_ESPlatform = "psx")
			Global L_ESPlatform := "playstation"
		loop 5
			if ( L_ESPlatform = "ps" . A_Index )
				Global L_ESPlatform := "playstation " . A_Index 

		if InStr(L_Platform, L_ESPlatform)
		{
			global match := A_Index
			break
		}
		else
		{
			continue
		}	
	}
	if (match = 0)
		Gui, Add, DropDownList,  vESDEMap%A_index% xm+200 yp, % EsPlatformList
	else
		Gui, Add, DropDownList, Choose%match% vESDEMap%A_index% xm+200 yp, % EsPlatformList
		
	PNMap%A_index% := PlatformList[A_Index]

}

Gui, Add, Button, GSaveIt w80 y+16 xp+23, save
gui, show, W400	
;msgbox % PlatformList[A_Index]




;;;;;;;;;;;;;;;;;functions
return

SaveIt:
{
	Gui, Submit
	FileSelectFile, OutFile, S2, %A_ScriptDir%\PlatformMaps.ini, Append to or create new platform mapping file:, *.ini
	loop % PlatformList.Length()
	{
		if (A_Index = 1) 
			IniWrite,ES-DE platform dir folder name, %OutFile%, Playnite Platform Mappings, Playnite Platform (and source if pc)
		Key := PNMap%A_index%
		Value := ESDEMap%A_index%
		IniWrite, % Value, %OutFile%, Playnite Platform Mappings, % Key
	}
	ExitApp
return
}



JsonToAHK(json, rec := false) 
{ 
	try
	{
		static doc := ComObjCreate("htmlfile") 
			, __ := doc.write("<meta http-equiv=""X-UA-Compatible"" content=""IE=9"">") 
			, JS := doc.parentWindow 
		if !rec 
			obj := %A_ThisFunc%(JS.eval("(" . json . ")"), true) 
		else if !IsObject(json) 
			obj := json 
		else if JS.Object.prototype.toString.call(json) == "[object Array]" { 
			obj := [] 
			Loop % json.length 
			obj.Push( %A_ThisFunc%(json[A_Index - 1], true) ) 
		} 
		else { 
			obj := {} 
			keys := JS.Object.keys(json) 
			Loop % keys.length { 
				k := keys[A_Index - 1] 
				obj[k] := %A_ThisFunc%(json[k], true) 
			} 
		} 
	}
   Return obj 
} 