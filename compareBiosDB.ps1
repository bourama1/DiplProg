param(
  [string]$databasePath = $null,
  [ValidateSet("automatic", "manual")]
  [string]$mode = "automatic"
)

# Načtení souboru s funkcemi
. .\functions.ps1

$tableName = "BiosInfo"

Function CompareBiosDatabases($path1, $query1, $path2, $query2) {
  # Zjisteni jestli jiz existuje tabulka rozdily, popr. jeji smazani
  $newTableName = "RozdilyBios"
  if (TableExists -tableName $newTableName -databasePath $path1) {
    DropTable -tableName $newTableName -databasePath $path1
  }

  # Získání seznamu sloupců z tabulky BiosInfo
  $columns = GetTableColumns -databasePath $path1 -tableName $tableName

  # Sestavení SQL dotazu pro vytvoření tabulky RozdilyBios s dynamickými sloupci
  $createQuery = "CREATE TABLE $newTableName (ID AUTOINCREMENT PRIMARY KEY, Audit_ID INT, "
  foreach ($column in $columns -ne 'ID') {
    $createQuery += "$column TEXT(255), "
  }
  $createQuery = $createQuery.TrimEnd(", ") + ")"

  # Vytvoření tabulky
  ExecuteQuery -databasePath $path1 -sqlQuery $createQuery

  # Odebrání ID sloupce pro porovnání, pokud je mezi sloupci
  $columnsToCompare = $columns -ne 'ID'

  # Vykonání dotazu pro obě databáze
  $data1 = ExecuteQuery -databasePath $path1 -sqlQuery $query1
  $data2 = ExecuteQuery -databasePath $path2 -sqlQuery $query2

  # Dynamické porovnání dat bez zahrnutí ID do porovnání
  $differences = Compare-Object -ReferenceObject $data1 -DifferenceObject $data2 -Property $columnsToCompare -PassThru

  # Iterace přes nalezené rozdíly a jejich vložení do tabulky RozdilyBios
  foreach ($difference in $differences) {
    $valuesToInsert = ($columnsToCompare | ForEach-Object { "'" + $difference.$_ + "'" }) -join ', '
    $columnsToInsert = ($columnsToCompare -join ', ')
    $insertQuery = "INSERT INTO RozdilyBios (Audit_ID, $columnsToInsert) VALUES ('$($difference.ID)', $valuesToInsert)"
    ExecuteQuery -databasePath $path1 -sqlQuery $insertQuery
  }
}

# Rozhodování mezi automatickým a manuálním režimem
switch ($mode) {
  "automatic" {
    if (-not $databasePath) {
      Write-Host "Vyberte databázi:"
      $databasePath = GetFileName("D:\Documents\DiplProg")
    }
    $sqlQuery1 = "SELECT * FROM $tableName WHERE ID = (SELECT MAX(ID) FROM $tableName)"
    $sqlQuery2 = "SELECT * FROM $tableName WHERE ID = (SELECT MAX(ID) FROM $tableName WHERE ID < (SELECT MAX(ID) FROM $tableName))"
    CompareBiosDatabases $databasePath $sqlQuery1 $databasePath $sqlQuery2
  }

  "manual" {
    Write-Host "Vyberte soubor pro první databázi:"
    $databasePath1 = GetFileName("D:\Documents\DiplProg")
    Write-Host "Zadejte ID pro první data:"
    $id1 = Read-Host
    $sqlQuery1 = "SELECT * FROM $tableName WHERE ID = $id1"

    Write-Host "Vyberte soubor pro druhou databázi:"
    $databasePath2 = GetFileName("D:\Documents\DiplProg")
    Write-Host "Zadejte ID pro druhá data:"
    $id2 = Read-Host
    $sqlQuery2 = "SELECT * FROM $tableName WHERE ID = $id2"

    CompareBiosDatabases $databasePath1 $sqlQuery1 $databasePath2 $sqlQuery2
  }
}