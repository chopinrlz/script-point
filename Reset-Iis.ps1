# PowerShell 5.1
$snapin = Get-PSSnapIn Microsoft.SharePoint.PowerShell -ErrorAction SilentyContinue
if( -not $snapin ) {
    Add-PSSnapIn Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
}
Get-SPServer | ? Role -ne Invalid | % { Invoke-Command -AsJob -ComputerName $_.Address -ScriptBlock {
        Write-Host "Running iisreset /noforce on $env:COMPUTERNAME"
        & iisreset @("/noforce")
    }
}