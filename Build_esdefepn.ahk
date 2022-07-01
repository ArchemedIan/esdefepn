#NoEnv
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

SplitPath, A_AhkPath, , AhkDir
Global compiler := AhkDir . "\Compiler\Ahk2Exe.exe"

Global toolbox := "L:\Playnite\Toolbox.exe"

Loop, Files, %A_ScriptDir%\esdefepn_dev\*.ahk, F
	runwait, "%compiler%" "/in" "%A_LoopFileFullPath%"

IniRead, ver, buildver.ini, buildver, dev



ExtDir .=
BuildDir .= 



FileRemoveDir, %A_ScriptDir%\esdefepn_%ver%, 1
sleep 750
gosub YamlData
gosub InstallerManifest
FileDelete, %A_ScriptDir%\esdefepn_dev\extension.yaml
FileDelete, %A_ScriptDir%\installer.yaml
FileAppend, % YamlData, %A_ScriptDir%\esdefepn_dev\extension.yaml
FileAppend, % InstallerYaml, %A_ScriptDir%\installer.yaml
FileCopyDir, %A_ScriptDir%\esdefepn_dev, %A_ScriptDir%\esdefepn_%ver%
;FileRemoveDir, %A_ScriptDir%\esdefepn_%ver%\.git, 1
sleep 750
;msgbox packing
runwait, %toolbox% pack "%A_ScriptDir%\esdefepn_%ver%" "%A_ScriptDir%"








;gosub Build
msgbox built
exitapp
return ;;;functions;;;;;;;;;;;;;;;;
Build:
{
	compileahk("dev")
	IniRead, ver, buildver.ini, buildver, dev
	;msgbox % ver
	FileRemoveDir, %A_ScriptDir%\esdefepn_%ver%, 1
	sleep 750
	gosub YamlData
	gosub InstallerManifest
	FileDelete, %A_ScriptDir%\esdefepn_dev\extension.yaml
	FileDelete, %A_ScriptDir%\esdefepn_dev\installer.yaml
	FileAppend, % YamlData, %A_ScriptDir%\esdefepn_dev\extension.yaml
	FileAppend, % InstallerYaml, %A_ScriptDir%\esdefepn_dev\installer.yaml
	FileCopyDir, %A_ScriptDir%\esdefepn_dev, %A_ScriptDir%\esdefepn_%ver%
	FileRemoveDir, %A_ScriptDir%\esdefepn_%ver%\.git, 1
	sleep 750
	;msgbox packing
	runwait, %toolbox% pack "%A_ScriptDir%\esdefepn_%ver%" "%A_ScriptDir%"
	
return
}



compileahk(BuildType)
{
	Loop, Files, %A_ScriptDir%\esdefepn_%BuildType%\*.ahk, F
	{
		SplitPath, A_LoopFileFullPath, LoopFileName, LoopFileDir, LoopFileExtension, LoopFileNameNoExt, LoopFileDrive
		runwait, "%compiler%" "/in" "%A_ScriptDir%\esdefepn_%BuildType%\%LoopFileName%"
	}
	;msgbox compiled
return
}




YamlData:
{
	YamlData = 
	(
Id: esdefepn
Name: ES-DE-FE-PN
Author: Archemedian
Version: %ver%
Module: ESDEFEPN.psm1
Type: Script
Links:
    - Name: Github
      Url: https://github.com/ArchemedIan/esdefepn	
	)

	
return
}

InstallerManifest:
{
	ver_ := StrReplace(ver, "." , "_")
	InstallerYaml =
	(
AddonId: 'esdefepn'
Packages:
  - Version: %ver%
    RequiredApiVersion: 5.6.0
    ReleaseDate: %A_YYYY%-%A_MM%-%A_DD%
    PackageUrl: https://github.com/ArchemedIan/esdefepn/releases/download/v%ver%/esdefepn_%ver_%.pext


	)
	return
}