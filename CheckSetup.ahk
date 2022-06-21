﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#NoTrayIcon
#SingleInstance Force
SetBatchLines -1

good2go=0

PluginDataDir = %1%
es_find_rules_path = %PluginDataDir%\EmulationStation-DE\resources\systems\windows\es_find_rules.xml
es_systems_path = %PluginDataDir%\EmulationStation-DE\resources\systems\windows\es_systems.xml

FileRead,XML_es_find_rules, %A_ScriptDir%\pn_es_find_rules.xml
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


CheckSetup:
{
	IfNotExist, %PluginDataDir%\EmulationStation-DE
		gosub InstallESDE
	
	IfNotExist, %PluginDataDir%\PNRunner.exe
		FileCopy, %A_ScriptDir%\PNRunner.exe, %PluginDataDir%\PNRunner.exe
	
	FileRead, XML_es_find_rules_test, % es_find_rules_path
	FileRead, XML_es_systems_test, % es_systems_path
	
	if (XML_es_find_rules_test != XML_es_find_rules)
	{
		FileDelete, % es_find_rules_path
		FileAppend , % XML_es_find_rules, % es_find_rules_path
	}
	
	if (XML_es_systems_test != XML_es_systems)
	{
		FileDelete, % es_systems_path
		FileAppend , % XML_es_systems, % es_systems_path
	}
	good2go=1
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


