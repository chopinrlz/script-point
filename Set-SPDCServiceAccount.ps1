Param(
    [Parameter(Mandatory=$true)][string]$DomainName,
    [Parameter(Mandatory=$true)][string]$UserName
)
$service = "AppFabricCachingService"
$acct = Get-SPManagedAccount -Identity "$DomainName\$UserName"
if( $acct ) {
    $farm = Get-SPFarm
    if( $farm ) {
        $svc = $farm.Services | ? Name -eq $service
        if( $svc ) {
            Write-Host "Setting Distributed Cache service account to $DomainName\$UserName"
            $svc.ProcessIdentity.CurrentIdentityType = "SpecificUser"
            $svc.ProcessIdentity.ManagedAccount = $acct
            $svc.ProcessIdentity.Update() | Out-Null
            $svc.ProcessIdentity.Deploy() | Out-Null
        } else {
            Write-Warning "Failed to fetch $service"
        }
    } else {
        Write-Warning "Cannot access the local Farm"
    }
} else {
    Write-Warning "No managed account for $DomainName\$UserName"
}