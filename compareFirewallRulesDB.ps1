param(
  [string]$databasePath = $null
)

# Načtení souboru s funkcemi
. .\functions.ps1

if (-not $databasePath) {
  Write-Host "Vyberte databázi:"
  $databasePath = GetFileName("D:\Documents\DiplProg")
}

# SQL dotaz pro vybrání dat z tabulky
$sqlQuery1 = @"
SELECT * FROM FirewallRules
WHERE Audit_ID = (SELECT MAX(Audit_ID) FROM FirewallRules)
"@

$sqlQuery2 = @"
SELECT * FROM FirewallRules
WHERE Audit_ID = (SELECT MAX(Audit_ID) FROM FirewallRules WHERE Audit_ID < (SELECT MAX(Audit_ID) FROM FirewallRules))
"@

# Vykonání dotazu pro obě databáze
$data1 = ExecuteQuery -databasePath $databasePath -sqlQuery $sqlQuery1
$data2 = ExecuteQuery -databasePath $databasePath -sqlQuery $sqlQuery2

# Zjisteni jestli jiz existuje tabulka rozdily, popr. jeji smazani
$tableName = "RozdilyFirewall"
if (TableExists $tableName $databasePath) {
  DropTable $tableName $databasePath
}

# Vytvoření tabulky v nové databázi pro uložení rozdílů
$createQuery = @"
CREATE TABLE RozdilyFirewall (
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

# Porovnání dat bez zahrnutí ID do porovnání
$differences = Compare-Object -ReferenceObject $data1 -DifferenceObject $data2 -Property ("Name", "Protocol", "LocalPort", "RemotePort", "LocalAddress", "RemoteAddress", "Enabled", "Profile", "Direction", "Action") -PassThru

# Uložení rozdílů do tabulky
foreach ($difference in $differences) {
	$insertDifferenceQuery = @"
INSERT INTO RozdilyFirewall (Audit_ID, [Name], Protocol, LocalPort, RemotePort, LocalAddress, RemoteAddress, [Enabled], Profile, [Direction], [Action])
VALUES ('$($difference.Audit_ID)', '$($difference.Name)', '$($difference.Protocol)', '$($difference.LocalPort)', '$($difference.RemotePort)', '$($difference.LocalAddress)' , '$($difference.RemoteAddress)',
'$($difference.Enabled)', '$($difference.Profile)', '$($difference.Direction)', '$($difference.Action)')
"@
  ExecuteQuery -databasePath $databasePath -sqlQuery $insertDifferenceQuery
}
Write-Host "Rozdíly byly úspěšně uloženy do databáze."