# Načtení souboru s funkcemi
. .\functions.ps1

# Získání cílové databáze pro ukládání informací o pravidlech firewall
Write-Host "Vyberte databázi pro ukládání informací o pravidlech firewall:"
$databasePath = GetFileName("D:\Documents\DiplProg")

# Kontrola, zda tabulka 'FirewallRules' existuje
$tableName = "FirewallRules"
if (-not (TableExists -tableName $tableName -databasePath $databasePath)) {
  # Tabulka neexistuje, vytvoříme ji ### Problem s nekterymi z nazvu sloupcu, proto nutne pouzit hranate zavorky aby Access neinterpretoval jako rezervovaná slova
  $createQuery = @"
CREATE TABLE FirewallRules (
  ID AUTOINCREMENT PRIMARY KEY,
  Audit_ID INT,
  [Name] TEXT(255),
  Protocol TEXT(255),
  LocalPort TEXT(255),
  RemotePort TEXT(255),
  LocalAddress TEXT(255),
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
$firewallRules = Get-NetFirewallRule | ForEach-Object {
  $portFilter = $_ | Get-NetFirewallPortFilter
  $addressFilter = $_ | Get-NetFirewallAddressFilter

  @{
    Name = $_.DisplayName.Replace("'", "''") # Escape apostrophes
    Protocol = $portFilter.Protocol
    LocalPort = $portFilter.LocalPort
    RemotePort = $portFilter.RemotePort
		LocalAddress = $addressFilter.LocalAddress
    RemoteAddress = $addressFilter.RemoteAddress
    Enabled = $_.Enabled
    Profile = $_.Profile.ToString()
    Direction = $_.Direction
    Action = $_.Action
  }
}

# Načtení maximální hodnoty Audit_ID
$newAuditId = Get-NewAuditId -databasePath $databasePath -tableName $tableName

# Vkládání pravidel firewall do databáze
foreach ($rule in $firewallRules) {
  $insertQuery = @"
INSERT INTO FirewallRules (Audit_ID, [Name], Protocol, LocalPort, RemotePort, LocalAddress, RemoteAddress, [Enabled], Profile, [Direction], [Action])
VALUES ($newAuditId, '$($rule.Name)', '$($rule.Protocol)', '$($rule.LocalPort)', '$($rule.RemotePort)', '$($rule.LocalAddress)' , '$($rule.RemoteAddress)',
'$($rule.Enabled)', '$($rule.Profile)', '$($rule.Direction)', '$($rule.Action)')
"@
  ExecuteQuery -databasePath $databasePath -sqlQuery $insertQuery
}

Write-Host "Pravidla firewall byla úspěšně uložena do databáze s Audit_ID $newAuditId."