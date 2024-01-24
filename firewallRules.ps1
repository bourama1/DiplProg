$fileNewPath = "FirewallRules.txt"

Get-NetFirewallRule -Action Allow -Enabled True -Direction Inbound |
Format-Table -Property Name,
@{Name='Protocol';Expression={($PSItem | Get-NetFirewallPortFilter).Protocol}},
@{Name='LocalPort';Expression={($PSItem | Get-NetFirewallPortFilter).LocalPort}},
@{Name='RemotePort';Expression={($PSItem | Get-NetFirewallPortFilter).RemotePort}},
@{Name='RemoteAddress';Expression={($PSItem | Get-NetFirewallAddressFilter).RemoteAddress}},
Enabled,Profile,Direction,Action |
Out-File -FilePath $fileNewPath

$fileNew = Get-Content -Path $fileNewPath
$fileOld = Get-Content -Path "FirewallRulesOld.txt"

# Compare the contents of the two files
$comparisonResult = Compare-Object $fileNew $fileOld

# Display the result
$comparisonResult