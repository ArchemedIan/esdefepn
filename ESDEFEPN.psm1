function GetMainMenuItems()
{
    param(
        $menuArgs
    )
	$menuItem1 = New-Object Playnite.SDK.Plugins.ScriptMainMenuItem
    $menuItem1.Description = "Run EmulationStation-DE FrontEnd"
    $menuItem1.FunctionName = "RunESDE"
    $menuItem1.MenuSection = "@EmulationStation-DE FrontEnd for PlayNite"

    $menuItem10 = New-Object Playnite.SDK.Plugins.ScriptMainMenuItem
    $menuItem10.Description = "Update ES-DE Library"
    $menuItem10.FunctionName = "UpdateESDELib"
    $menuItem10.MenuSection = "@EmulationStation-DE FrontEnd for PlayNite"
	
	$menuItem12 = New-Object Playnite.SDK.Plugins.ScriptMainMenuItem
    $menuItem12.Description = "Run PlatformMaps.ini configurator"
    $menuItem12.FunctionName = "Configurator"
    $menuItem12.MenuSection = "@EmulationStation-DE FrontEnd for PlayNite"
	
	$menuItem14 = New-Object Playnite.SDK.Plugins.ScriptMainMenuItem
    $menuItem14.Description = "Force Update ES-DE Library"
    $menuItem14.FunctionName = "ForceUpdateESDELib"
    $menuItem14.MenuSection = "@EmulationStation-DE FrontEnd for PlayNite"
    return $menuItem1, $menuItem10, $menuItem12, $menuItem14
	#, $menuItem2, $menuItem3, $menuItem4, $menuItem5, $menuItem6, $menuItem7, $menuItem8, $menuItem9,  $menuItem11,  $menuItem13
}

function RunESDE()
{
    param(
        $scriptMainMenuItemActionArgs
    )
	
	.\RunESDE.exe "$CurrentExtensionDataPath"
}

function Configurator()
{
    param(
        $scriptMainMenuItemActionArgs
    )
	
	.\Configurator.exe "$CurrentExtensionDataPath"
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
    
	.\CheckSetup.exe "$CurrentExtensionDataPath"
	
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
    
	.\CheckSetup.exe "$CurrentExtensionDataPath"
	.\MkEsLib.exe "$CurrentExtensionDataPath\NewLib.json"
	
	
}