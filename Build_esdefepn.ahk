#NoEnv
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

SplitPath, A_AhkPath, , AhkDir
Global compiler := AhkDir . "\Compiler\Ahk2Exe.exe"

Global toolbox := "L:\Playnite\Toolbox.exe"

Loop, Files, %A_ScriptDir%\esdefepn_dev\*.ahk, F
	runwait, "%compiler%" "/in" "%A_LoopFileFullPath%"

IniRead, ver, buildver.ini, buildver, dev

gosub YamlData
gosub InstallerManifest

FileDelete, %A_ScriptDir%\esdefepn_dev\extension.yaml
FileAppend, % YamlData, %A_ScriptDir%\esdefepn_dev\extension.yaml

;msgbox packing
runwait, %toolbox% pack "%A_ScriptDir%\esdefepn_dev" "%A_ScriptDir%"

Loop, Read, %A_ScriptDir%\installer.yaml
{
	;msgbox "%A_LoopReadLine%"  = "  - Version: %ver%"
	if (A_LoopReadLine = "  - Version: " ver)
	{
		Global NotAnUpdate := "1"
		break
	}
}	
if (NotAnUpdate != "1")
{
	FileMove, %A_ScriptDir%\installer.yaml, %A_ScriptDir%\installer-old.yaml
	Loop, Read, %A_ScriptDir%\installer-old.yaml, %A_ScriptDir%\installer.yaml
	{
		if (A_Index=2)
			var := A_LoopReadLine "`n  " InstallerYaml
		else
			var:=A_LoopReadLine
		FileAppend, %var%`n
	}
	FileDelete, %A_ScriptDir%\installer-old.yaml
}


;FileAppend, % InstallerYaml, %A_ScriptDir%\installer.yaml






;gosub Build
msgbox built
exitapp


return ;;;functions;;;;;;;;;;;;;;;;

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
  - Version: %ver%
    RequiredApiVersion: 5.6.0
    ReleaseDate: %A_YYYY%-%A_MM%-%A_DD%
    PackageUrl: https://github.com/ArchemedIan/esdefepn/raw/main/esdefepn_%ver_%.pext

	)
	return
}