#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
; #Persistent
#NoTrayIcon
#SingleInstance Force
SetBatchLines -1

jsonpath = %1%
SplitPath, jsonpath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
ESDERomsDir = %OutDir%\EmulationStation-DE\ROMs

FileDelete, %OutDir%\CurLib.json
FileMove, % jsonpath, %OutDir%\CurLib.json
jsonpath = %OutDir%\CurLib.json
FileRead, NewLibJson, % jsonpath

NewLib := JsonToAHK(NewLibJson)


;clean first
Loop, Files, %ESDERomsDir%\*, R   
{
	IniRead, PNUrl, % A_LoopFileFullPath, InternetShortcut, URL
	StringGetPos, pos, PNUrl , /, R
	pos++
	StringTrimLeft, ThisShortcutIDChk, PNUrl, %pos% 
	;msgbox % ThisShortcutIDChk
	lnkmatch = 0
	loop % NewLib.Length()
	{
		ThisName := Newlib[A_Index].Name
		ThisShortcutID := NewLib[A_Index].Id
		if (NewLib[A_Index].Hidden = 0)
			ThisIsHidden := false
		else
			ThisIsHidden := true
			
		if ( ThisShortcutID = ThisShortcutIDChk ) or ThisIsHidden = true
			lnkmatch = 1
	}
	if lnkmatch = 0
		FileDelete, % A_LoopFileFullPath
}


loop % NewLib.Length()
{
	ThisName := Newlib[A_Index].Name
	ThisName := RegExReplace(ThisName, "[-,0/\:*?""<>|]") ;Sanitize name for shortcut
	ThisGameId := NewLib[A_Index].GameId
	ThisShortcutID := NewLib[A_Index].Id
	ThisSourceId := NewLib[A_Index].Source.Id
	ThisSourceName := NewLib[A_Index].Source.Name
	ThisPlatform := ""
	if ( NewLib[A_Index].Platforms.Length() > 1 )
		msgbox more than one platform for "%ThisName%"`, TODO: handle this 
	else
		ThisPlatform := NewLib[A_Index].Platforms
		
	if (ThisPlatform = "")
		ThisPlatform := NewLib[A_Index].Platforms[1]
	
	if InStr(ThisSourceName, "steam")
		ThisPlatform := ThisPlatform . " (Steam)"
		
	if InStr(ThisSourceName, "epic")
		ThisPlatform := ThisPlatform . " (Epic)"
		
	;if InStr(ThisSourceName, "origin")
		;ThisPlatform := ThisPlatform . " (Origin)"
		
	ThisTags := NewLib[A_Index].Tags
	
	if (NewLib[A_Index].IsInstalled = 0)
		ThisIsInstalled := false
	else
		ThisIsInstalled := true
		
	if (NewLib[A_Index].Hidden = 0)
		ThisIsHidden := false
	else
		ThisIsHidden := true
		
	if (NewLib[A_Index].Favorite = 0)
		ThisIsFavorite := false
	else
		ThisIsFavorite := true

	;;;;  Still loopin	;;;;
	IniRead, ThisEsDePlatformMap, %A_ScriptDir%\PlatformMaps.ini, Playnite Platform Mappings, % ThisPlatform, ERROR
	UrlFile = %ESDERomsDir%\%ThisEsDePlatformMap%\%ThisName%.url
	if InStr(UrlFile, "error")
		GoSub PlatformError
	if (ThisPlatform != "") and (ThisIsHidden = false)
	{
		IfNotExist, %ESDERomsDir%\%ThisEsDePlatformMap%
			FileCreateDir, %ESDERomsDir%\%ThisEsDePlatformMap%
		IniWrite, playnite://playnite/start/%ThisShortcutID%, %ESDERomsDir%\%ThisEsDePlatformMap%\%ThisName%.url, InternetShortcut, URL
		;if (ThisIsFavorite = false)
	}
}


ExitApp
;;;;;;;;;;;;;;;;;;;;Functions;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return

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


PlatformError:
{
ErrorData =
(
Platform Map error

you should run the platform configurator

Playnite platform: %ThisPlatform%
ESDE map: %ThisEsDePlatformMap%


Name: %ThisName%
├─ShortcutID: %ThisShortcutID%
├─Tags: %ThisTags%
│
├─GameID: %ThisGameId%
├┬Source:
│├─Id: %ThisSourceId%
│└─Name: %ThisSourceName%
│
├─Platform(s): %ThisPlatform%
│
├─Installed: %ThisIsInstalled%
├─Hidden: %ThisIsHidden%
└─Favorite: %ThisIsFavorite%
)

MsgBox, , Platform Map error, % ErrorData, 3
	
}




;;;;;keeping for now

InputData = 
(
Name: %ThisName%
├─ShortcutID: %ThisShortcutID%
├─Tags: %ThisTags%
│
├─GameID: %ThisGameId%
├┬Source:
│├─Id: %ThisSourceId%
│└─Name: %ThisSourceName%
│
├─Platform(s): %ThisPlatforms%
│
├─Installed: %ThisIsInstalled%
├─Hidden: %ThisIsHidden%
└─Favorite: %ThisIsFavorite%
)

UrlFileData  = 
(
[InternetShortcut]
IconIndex=0
IconFile=L:\Playnite\library\files\b1d43f79-fda2-4182-b5be-dda1d832cb27\a531dd9d-e987-49f8-8b3f-0be1b243c1c0.ico
URL=playnite://playnite/start/%ThisShortcutID%
)				
