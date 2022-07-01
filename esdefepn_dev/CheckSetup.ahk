;@Ahk2Exe-ExeName CheckSetup
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#NoTrayIcon
#SingleInstance Force
SetBatchLines -1

good2go=0

PluginDataDir = %1%
update = %2%
;msgbox %2%
if (%update% = "update")
{
	gosub UpdateESDE
	exitapp
}

es_systems_path = %PluginDataDir%\EmulationStation-DE\.emulationstation\custom_systems\es_systems.xml

FileRead,XML_es_systems, %A_ScriptDir%\pn_es_systems.xml

;msgbox % PluginDataDir


gosub CheckSetup



Exitapp

;;;;;;;;;;;;functions
return

InstallESDE:
{
	msgbox, 305, First Run Setup, First run detected:`n`n Please download`n`n "EmulationStation-DE-[X.Y.Z]-x64_Portable.zip"`n`nfrom `n`nhttps://es-de.org/#Download `n`nThen`, press ok to select the zip file you downloaded.
	IfMsgBox, OK
	{
		FileSelectFile, ESDEzip, 3, ::{20d04fe0-3aea-1069-a2d8-08002b30309d}, Please Select "EmulationStation-DE-[X.Y.Z]-x64_Portable.zip", EmulationStation-DE-*-x64_Portable.zip
		if ( ESDEzip = "")
			exitapp
		else
			Unzip(ESDEzip, PluginDataDir)
	}
	else
	{
		exitapp
	}
	msgbox, 84, Create Shortcut?, Would you like to make a shortcut on the desktop for EmulationStation-DE (Playnite Frontend)?
	IfMsgBox, Yes
	{
		FileCreateShortcut, "%PluginDataDir%\EmulationStation-DE\EmulationStation.exe", %A_Desktop%\EmulationStation-DE (Playnite Frontend).lnk, "%PluginDataDir%\EmulationStation-DE", , Starts EmulationStation-DE (Playnite Frontend), %PluginDataDir%\EmulationStation-DE\EmulationStation.exe
	}



return
}


UpdateESDE:
{
	msgbox, 305, Please select`n`n "EmulationStation-DE-[X.Y.Z]-x64_Portable.zip"`n`nfrom `n`nhttps://es-de.org/#Download `n`nTo apply update
	IfMsgBox, OK
	{
		FileSelectFile, ESDEzip, 3, ::{20d04fe0-3aea-1069-a2d8-08002b30309d}, Please Select "EmulationStation-DE-[X.Y.Z]-x64_Portable.zip", EmulationStation-DE-*-x64_Portable.zip
		if ( ESDEzip = "")
			exitapp
		else
			Unzip(ESDEzip, PluginDataDir)
	}
	else
	{
		exitapp
	}	
return
}

CheckSetup:
{
	IfNotExist, %PluginDataDir%\EmulationStation-DE
		gosub InstallESDE
	
	
	IfNotExist, %PluginDataDir%\PNRunner.exe
		FileCopy, %A_ScriptDir%\PNRunner.exe, %PluginDataDir%\PNRunner.exe
	
	if (FileMD5("%A_ScriptDir%\PNRunner.exe") != FileMD5("%PluginDataDir%\PNRunner.exe"))
		FileCopy, %A_ScriptDir%\PNRunner.exe, %PluginDataDir%\PNRunner.exe, 1
	
	;FileRead, XML_es_find_rules_test, % es_find_rules_path
	FileRead, XML_es_systems_test, % es_systems_path

	;if (XML_es_find_rules_test != XML_es_find_rules)
	;{
;		FileDelete, % es_find_rules_path
;		FileAppend , % XML_es_find_rules, % es_find_rules_path
;	}

	if (XML_es_systems_test != XML_es_systems)
	{
		FileDelete, % es_systems_path
		FileAppend , % XML_es_systems, % es_systems_path
	}
	good2go=1
	sleep 3000
return
}



Unzip(sZip, sUnz)
{
	Gui, New, , Extracting %sZip%
	Gui, Font, Bold Underline
	Gui, Add, Text, R0.7, Extracting %sZip%
	Gui, Show, , Extracting %sZip%
    fso := ComObjCreate("Scripting.FileSystemObject")
    If Not fso.FolderExists(sUnz)  ;http://www.autohotkey.com/forum/viewtopic.php?p=402574
       fso.CreateFolder(sUnz)
    psh  := ComObjCreate("Shell.Application")
    zippedItems := psh.Namespace( sZip ).items().count
    psh.Namespace( sUnz ).CopyHere( psh.Namespace( sZip ).items, 4|16 )
    ;Loop {
    ;    sleep 50
    ;    unzippedItems := psh.Namespace( sUnz ).items().count
    ;    ToolTip Unzipping in progress..
    ;    IfEqual,zippedItems,%unzippedItems%
    ;        break
    ;}
    ;ToolTip

	Gui, Destroy
	return
}

FileMD5(sFile="", cSz=4)
{ 
	cSz := (cSz<0||cSz>8) ? 2**22 : 2**(18+cSz), VarSetCapacity( Buffer,cSz,0 ) ; 18-Jun-2009
	hFil := DllCall( "CreateFile", Str,sFile,UInt,0x80000000, Int,3,Int,0,Int,3,Int,0,Int,0 )
	
	IfLess,hFil,1, Return,hFil
	
	hMod := DllCall( "LoadLibrary", Str,"advapi32.dll" )
	
	DllCall( "GetFileSizeEx", UInt,hFil, UInt,&Buffer ),    fSz := NumGet( Buffer,0,"Int64" )
	
	VarSetCapacity( MD5_CTX,104,0 ),    DllCall( "advapi32\MD5Init", UInt,&MD5_CTX )
	
	Loop % ( fSz//cSz + !!Mod( fSz,cSz ) )
	DllCall( "ReadFile", UInt,hFil, UInt,&Buffer, UInt,cSz, UIntP,bytesRead, UInt,0 )
	, DllCall( "advapi32\MD5Update", UInt,&MD5_CTX, UInt,&Buffer, UInt,bytesRead )
	DllCall( "advapi32\MD5Final", UInt,&MD5_CTX )
	DllCall( "CloseHandle", UInt,hFil )
	Loop % StrLen( Hex:="123456789ABCDEF0" )
		N := NumGet( MD5_CTX,87+A_Index,"Char"), MD5 .= SubStr(Hex,N>>4,1) . SubStr(Hex,N&15,1)
Return MD5, DllCall( "FreeLibrary", UInt,hMod )
}
