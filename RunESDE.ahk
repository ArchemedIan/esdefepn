#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
; #Persistent
#NoTrayIcon
#SingleInstance Force
;msgbox %1%
if ("%1%" = "firstrun")
{
	PluginDataDir = %2%
	Run, CheckSetup.exe "%PluginDataDir%", %A_ScriptDir%
	ExitApp
}
else
{
	PluginDataDir = %1%
}
	
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
Run, %ESDEDir%\EmulationStation.exe, % ESDEDir


