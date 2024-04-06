# Načtení souboru s funkcemi
. .\functions.ps1

# Získání cílové databáze pro ukládání informací o pravidlech firewall
Write-Host "Vyberte databázi pro ukládání informací o pravidlech firewall:"
$databasePath = GetFileName("D:\Documents\DiplProg")

# Kontrola, zda tabulka 'FirewallRules' existuje
if (-not (TableExists -tableName "FirewallRules" -databasePath $databasePath)) {
  # Tabulka neexistuje, vytvoříme ji ### Problem s nekterymi z nazvu sloupcu, proto nutne pouzit hranate zavorky aby Access neinterpretoval jako rezervovaná slova
  $createQuery = @"
CREATE TABLE FirewallRules (
  ID AUTOINCREMENT PRIMARY KEY,
  Audit_ID INT,
  [Name] TEXT(255),
  Protocol TEXT(255),
  LocalPort TEXT(255),
  RemotePort TEXT(255),
  RemoteAddress TEXT(255),
  [Enabled] TEXT(255),
  Profile TEXT(255),
  [Direction] TEXT(255),
  [Action] TEXT(255)
)
"@
  ExecuteQuery -databasePath $databasePath -sqlQuery $createQuery
  Write-Host "Tabulka FirewallRules byla úspěšně vytvořena."
}

# Získání pravidel firewall a jejich formátování pro databázi
$firewallRules = Get-NetFirewallRule -Action Allow -Enabled True | ForEach-Object {
  $portFilter = $_ | Get-NetFirewallPortFilter
  $addressFilter = $_ | Get-NetFirewallAddressFilter

  @{
    Name = $_.DisplayName.Replace("'", "''") # Escape apostrophes
    Protocol = $portFilter.Protocol
    LocalPort = $portFilter.LocalPort
    RemotePort = $portFilter.RemotePort
    RemoteAddress = $addressFilter.RemoteAddress
    Enabled = $_.Enabled
    Profile = $_.Profile.ToString()
    Direction = $_.Direction
    Action = $_.Action
  }
}

# Načtení maximální hodnoty Audit_ID
$maxAuditIdQuery = "SELECT MAX(Audit_ID) FROM FirewallRules"
$maxAuditIdResult = ExecuteQuery -databasePath $databasePath -sqlQuery $maxAuditIdQuery
if ($null -ne $maxAuditIdResult -and -not ($maxAuditIdResult[0] -eq [System.DBNull]::Value)) {
  $maxAuditId = [int]$maxAuditIdResult[0]
} else {
  $maxAuditId = 0
}
$newAuditId = $maxAuditId + 1

# Vkládání pravidel firewall do databáze
foreach ($rule in $firewallRules) {
  $insertQuery = @"
INSERT INTO FirewallRules (Audit_ID, [Name], Protocol, LocalPort, RemotePort, RemoteAddress, [Enabled], Profile, [Direction], [Action])
VALUES ($newAuditId, '$($rule.Name)', '$($rule.Protocol)', '$($rule.LocalPort)', '$($rule.RemotePort)', '$($rule.RemoteAddress)',
'$($rule.Enabled)', '$($rule.Profile)', '$($rule.Direction)', '$($rule.Action)')
"@
  ExecuteQuery -databasePath $databasePath -sqlQuery $insertQuery
}

Write-Host "Pravidla firewall byla úspěšně uložena do databáze s Audit_ID $newAuditId."