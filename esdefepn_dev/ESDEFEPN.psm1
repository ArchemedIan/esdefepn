function GetMainMenuItems()
{
    param(
        $menuArgs
    )
	
	$menuItem15 = New-Object Playnite.SDK.Plugins.ScriptMainMenuItem
    $menuItem15.Description = "First Run Setup"
    $menuItem15.FunctionName = "FirstRunESDE"
    $menuItem15.MenuSection = "@EmulationStation-DE FrontEnd for PlayNite"
	
	$menuItem1 = New-Object Playnite.SDK.Plugins.ScriptMainMenuItem
    $menuItem1.Description = "Run EmulationStation-DE FrontEnd"
    $menuItem1.FunctionName = "RunESDE"
    $menuItem1.MenuSection = "@EmulationStation-DE FrontEnd for PlayNite"

    $menuItem10 = New-Object Playnite.SDK.Plugins.ScriptMainMenuItem
    $menuItem10.Description = "Update ES-DE Library"
    $menuItem10.FunctionName = "UpdateESDELib"
    $menuItem10.MenuSection = "@EmulationStation-DE FrontEnd for PlayNite"
	
	$menuItem11 = New-Object Playnite.SDK.Plugins.ScriptMainMenuItem
    $menuItem11.Description = "Run PlatformMaps.ini configurator"
    $menuItem11.FunctionName = "Configurator"
    $menuItem11.MenuSection = "@EmulationStation-DE FrontEnd for PlayNite|Config"
	
	$menuItem12 = New-Object Playnite.SDK.Plugins.ScriptMainMenuItem
    $menuItem12.Description = "Update EmulationStation-DE"
    $menuItem12.FunctionName = "UpdateESDE"
    $menuItem12.MenuSection = "@EmulationStation-DE FrontEnd for PlayNite|Config"
	
	$menuItem14 = New-Object Playnite.SDK.Plugins.ScriptMainMenuItem
    $menuItem14.Description = "Force Update ES-DE Library"
    $menuItem14.FunctionName = "ForceUpdateESDELib"
    $menuItem14.MenuSection = "@EmulationStation-DE FrontEnd for PlayNite|Config"
	
	$Folder = "$CurrentExtensionDataPath\EmulationStation-DE"
	
	if (Test-Path -Path $Folder) {
		return $menuItem1, $menuItem10, $menuItem14, $menuItem11, $menuItem12
	} else {
		return $menuItem15
	}
	
    return $menuItem1, $menuItem10, $menuItem11, $menuItem12, $menuItem14
	#, $menuItem2, $menuItem3, $menuItem4, $menuItem5, $menuItem6, $menuItem7, $menuItem8, $menuItem9, $menuItem13
}

function RunESDE()
{
    param(
        $scriptMainMenuItemActionArgs
    )
	
	$platforms = @{ label="Platforms"; expression={[string]::Join(" ", $_.Platforms)} }
	$tags = @{ label="Tags"; expression={[string]::Join(" ", $_.Tags)} }
	$Roms = @{ label="Roms"; expression={[string]::Join(" ", $_.Roms)} }
	$PlayniteApi.Database.Games | Select Name, Id, Source, GameId, $tags, Hidden, IsInstalled, Favorite, InstallDirectory, $platforms, $Roms | ConvertTo-Json | Out-File -FilePath $CurrentExtensionDataPath\NewLib.json -Force -Encoding utf8
	
	.\CheckSetup.exe "$CurrentExtensionDataPath" | Out-Null
	
	.\MkEsLib.exe "$CurrentExtensionDataPath\NewLib.json" | Out-Null
	
	
	.\RunESDE.exe "$CurrentExtensionDataPath"
}

function FirstRunESDE()
{
    param(
        $scriptMainMenuItemActionArgs
    )
	
	$platforms = @{ label="Platforms"; expression={[string]::Join(" ", $_.Platforms)} }
	$tags = @{ label="Tags"; expression={[string]::Join(" ", $_.Tags)} }
	$Roms = @{ label="Roms"; expression={[string]::Join(" ", $_.Roms)} }
	$PlayniteApi.Database.Games | Select Name, Id, Source, GameId, $tags, Hidden, IsInstalled, Favorite, InstallDirectory, $platforms, $Roms | ConvertTo-Json | Out-File -FilePath $CurrentExtensionDataPath\NewLib.json -Force -Encoding utf8
	
	.\CheckSetup.exe "$CurrentExtensionDataPath" | Out-Null
	Start-Sleep -Seconds 10
	.\Configurator.exe "$CurrentExtensionDataPath" | Out-Null
	
	.\MkEsLib.exe "$CurrentExtensionDataPath\NewLib.json" | Out-Null
	
}


function Configurator()
{
    param(
        $scriptMainMenuItemActionArgs
    )
	
	.\Configurator.exe "$CurrentExtensionDataPath"
}


function UpdateESDE()
{
    param(
        $scriptMainMenuItemActionArgs
    )
	
	.\CheckSetup.exe "$CurrentExtensionDataPath" "update"
}


function UpdateESDELib()
{
    param(
        $scriptMainMenuItemActionArgs
    )
	
   	$platforms = @{ label="Platforms"; expression={[string]::Join(" ", $_.Platforms)} }
	$tags = @{ label="Tags"; expression={[string]::Join(" ", $_.Tags)} }
	$Roms = @{ label="Roms"; expression={[string]::Join(" ", $_.Roms)} }
	$PlayniteApi.Database.Games | Select Name, Id, Source, GameId, $tags, Hidden, IsInstalled, Favorite, InstallDirectory, $platforms, $Roms | ConvertTo-Json | Out-File -FilePath $CurrentExtensionDataPath\NewLib.json -Force -Encoding utf8
    
	.\CheckSetup.exe "$CurrentExtensionDataPath" | Out-Null
	
	if (Test-Path -Path $CurrentExtensionDataPath\CurLib.json -PathType Leaf) {
		if ($(Get-FileHash $CurrentExtensionDataPath\NewLib.json).Hash -ne $(Get-FileHash $CurrentExtensionDataPath\CurLib.json).Hash) {
			.\MkEsLib.exe "$CurrentExtensionDataPath\NewLib.json"
			$PlayniteApi.Dialogs.ShowMessage("EmulationStation-DE Frontend Library Updated.")
		} else {
			$PlayniteApi.Dialogs.ShowMessage("EmulationStation-DE Frontend Library Did Not Need An Update.")
		}
	} else {
		.\MkEsLib.exe "$CurrentExtensionDataPath\NewLib.json"
		$PlayniteApi.Dialogs.ShowMessage("EmulationStation-DE Frontend Library Was Created.")
	}
	
}


function ForceUpdateESDELib()
{
    param(
        $scriptMainMenuItemActionArgs
    )
	
   	$platforms = @{ label="Platforms"; expression={[string]::Join(" ", $_.Platforms)} }
	$tags = @{ label="Tags"; expression={[string]::Join(" ", $_.Tags)} }
	$Roms = @{ label="Roms"; expression={[string]::Join(" ", $_.Roms)} }
	$PlayniteApi.Database.Games | Select Name, Id, Source, GameId, $tags, Hidden, IsInstalled, Favorite, InstallDirectory, $platforms, $Roms | ConvertTo-Json | Out-File -FilePath $CurrentExtensionDataPath\NewLib.json -Force -Encoding utf8
    
	.\CheckSetup.exe "$CurrentExtensionDataPath" | Out-Null
	.\MkEsLib.exe "$CurrentExtensionDataPath\NewLib.json"
	
	
}