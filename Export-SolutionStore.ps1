Param([string]$Folder)
(Get-SPFarm).Solutions | % {
	$file = $_.SolutionFile
	$path = Join-Path -Path $Folder -ChildPath ($_.Name)
	$file.SaveAs( $path )
}
& explorer @($Folder)