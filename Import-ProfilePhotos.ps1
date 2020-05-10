# PowerShell 5.1
Param(
    [Parameter(Mandatory=$true)]
    [string]$DomainName,
    [switch]$Verbose
)
# $snapin = Get-PSSnapIn Microsoft.SharePoint.PowerShell
# if( -not $snapin ) {
#     Add-PSSnapIn Microsoft.SharePoint.Powershell
# }
$address = "LDAP://"
$DomainName.Split(".") | % { "DC=$_" } | % { $address += "$_" } | Out-Null
Write-Verbose "address:$address"
$adsi = [ADSI]$address.Substring( 0, $address.Length - 2 )
$ldap = New-Object System.DirectoryServices.Protocols.LdapConnection -ArgumentList $DomainName
$ldap.Credential = Get-Credential
$search = New-Object System.DirectoryServices.Protocols.SearchRequest