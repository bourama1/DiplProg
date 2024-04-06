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
SELECT * FROM LocalPolicies
WHERE Audit_ID = (SELECT MAX(Audit_ID) FROM LocalPolicies)
"@

$sqlQuery2 = @"
SELECT * FROM LocalPolicies
WHERE Audit_ID = (SELECT MAX(Audit_ID) FROM LocalPolicies WHERE Audit_ID < (SELECT MAX(Audit_ID) FROM LocalPolicies))
"@

# Zjisteni jestli jiz existuje tabulka rozdily, popr. jeji smazani
$tableName = "RozdilyPolicies"
if (TableExists $tableName $databasePath) {
  DropTable $tableName $databasePath
}

# Vytvoření tabulky v nové databázi pro uložení rozdílů
$createQuery = @"
CREATE TABLE $tableName (
  ID AUTOINCREMENT PRIMARY KEY,
  Audit_ID INT,
  [Name] TEXT(255),
  [Value] TEXT(255)
)
"@
ExecuteQuery -databasePath $databasePath -sqlQuery $createQuery

# Vykonání dotazu pro obě databáze
$data1 = ExecuteQuery -databasePath $databasePath -sqlQuery $sqlQuery1
$data2 = ExecuteQuery -databasePath $databasePath -sqlQuery $sqlQuery2

# Porovnání dat
$differences = Compare-Object -ReferenceObject $data1 -DifferenceObject $data2 -Property "Name", "Value" -PassThru

# Uložení rozdílů
foreach ($diff in $differences) {
  $insertDiffQuery = @"
INSERT INTO $tableName (Audit_ID, [Name], [Value]) VALUES ('$($diff.Audit_ID)', '$($diff.Name)', '$($diff.Value)')
"@
  ExecuteQuery -databasePath $databasePath -sqlQuery $insertDiffQuery
}