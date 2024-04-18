param(
  [string]$databasePath = $null,
  [ValidateSet("automatic", "manual")]
  [string]$mode = "automatic"
)

# Načtení souboru s funkcemi
. .\functions.ps1

Function AnalyzePolicies($path1, $query1, $path2, $query2) {
  $tableName = "RozdilyPolicies"

  # Zjisteni jestli jiz existuje tabulka rozdily, popr. jeji smazani
  if (TableExists -tableName $tableName -databasePath $path1) {
    DropTable -tableName $tableName -databasePath $path1
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
  ExecuteQuery -databasePath $path1 -sqlQuery $createQuery

  # Vykonání dotazu pro obě databáze
  $data1 = ExecuteQuery -databasePath $path1 -sqlQuery $query1
  $data2 = ExecuteQuery -databasePath $path2 -sqlQuery $query2

  # Porovnání dat
  $differences = Compare-Object -ReferenceObject $data1 -DifferenceObject $data2 -Property "Name", "Value" -PassThru

  # Uložení rozdílů
  foreach ($diff in $differences) {
    $insertDiffQuery = @"
INSERT INTO $tableName (Audit_ID, [Name], [Value]) VALUES ('$($diff.Audit_ID)', '$($diff.Name)', '$($diff.Value)')
"@
    ExecuteQuery -databasePath $path1 -sqlQuery $insertDiffQuery
  }
}

# Rozhodování mezi automatickým a manuálním režimem
switch ($mode) {
  "automatic" {
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
    AnalyzePolicies $databasePath $sqlQuery1 $databasePath $sqlQuery2
  }

  "manual" {
    Write-Host "Vyberte soubor pro první databázi:"
    $databasePath1 = GetFileName("D:\Documents\DiplProg")
    Write-Host "Zadejte Audit_ID pro první databázi:"
    $auditId1 = Read-Host
    $sqlQuery1 = @"
SELECT * FROM LocalPolicies
WHERE Audit_ID = $auditId1
"@

    Write-Host "Vyberte soubor pro druhou databázi:"
    $databasePath2 = GetFileName("D:\Documents\DiplProg")
    Write-Host "Zadejte Audit_ID pro druhou databázi:"
    $auditId2 = Read-Host
    $sqlQuery2 = @"
SELECT * FROM LocalPolicies
WHERE Audit_ID = $auditId2
"@

    AnalyzePolicies $databasePath1 $sqlQuery1 $databasePath2 $sqlQuery2
  }
}