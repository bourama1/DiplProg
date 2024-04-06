param(
  [string]$databasePath = $null
)

# Načtení souboru s funkcemi
. .\functions.ps1

if (-not $databasePath) {
  Write-Host "Vyberte databázi:"
  $databasePath = GetFileName("D:\Documents\DiplProg")
}

# Zjisteni jestli jiz existuje tabulka rozdily, popr. jeji smazani
$newTableName = "RozdilyBios"
if (TableExists -tableName $newTableName -databasePath $databasePath) {
  DropTable -tableName $newTableName -databasePath $databasePath
}

# Získání seznamu sloupců z tabulky BiosInfo
$tableName = "BiosInfo"
$columns = GetTableColumns -databasePath $databasePath -tableName $tableName

# Sestavení SQL dotazu pro vytvoření tabulky RozdilyBios s dynamickými sloupci
$createQuery = "CREATE TABLE $newTableName (ID AUTOINCREMENT PRIMARY KEY, Audit_ID INT, "
foreach ($column in $columns -ne 'ID') {
  $createQuery += "$column TEXT(255), "
}
$createQuery = $createQuery.TrimEnd(", ") + ")"

# Vytvoření tabulky
ExecuteQuery -databasePath $databasePath -sqlQuery $createQuery

# Odebrání ID sloupce pro porovnání, pokud je mezi sloupci
$columnsToCompare = $columns -ne 'ID'

# Dynamické sestavení SQL dotazů (zůstává stejné)
$sqlQuery1 = "SELECT * FROM BiosInfo WHERE ID = (SELECT MAX(ID) FROM BiosInfo)"
$sqlQuery2 = "SELECT * FROM BiosInfo WHERE ID = (SELECT MAX(ID) FROM BiosInfo WHERE ID < (SELECT MAX(ID) FROM BiosInfo))"

# Vykonání dotazu pro obě databáze
$data1 = ExecuteQuery -databasePath $databasePath -sqlQuery $sqlQuery1
$data2 = ExecuteQuery -databasePath $databasePath -sqlQuery $sqlQuery2

# Dynamické porovnání dat bez zahrnutí ID do porovnání
$differences = Compare-Object -ReferenceObject $data1 -DifferenceObject $data2 -Property $columnsToCompare -PassThru

# Iterace přes nalezené rozdíly a jejich vložení do tabulky RozdilyBios
foreach ($difference in $differences) {
  $valuesToInsert = ($columnsToCompare | ForEach-Object { "'" + $difference.$_ + "'" }) -join ', '
  $columnsToInsert = ($columnsToCompare -join ', ')
  $insertQuery = "INSERT INTO RozdilyBios (Audit_ID, $columnsToInsert) VALUES ('$($difference.ID)', $valuesToInsert)"
  ExecuteQuery -databasePath $databasePath -sqlQuery $insertQuery
}

Write-Host "Rozdíly byly úspěšně uloženy do tabulky RozdilyBios."