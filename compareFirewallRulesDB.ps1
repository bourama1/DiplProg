param(
  [string]$databasePath = $null,
  [ValidateSet("automatic", "manual")]
  [string]$mode = "automatic"
)

# Načtení souboru s funkcemi
. .\functions.ps1

Function AnalyzeFirewall($path1, $query1, $path2, $query2) {
  $tableName = "RozdilyFirewall"

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
  ExecuteQuery -databasePath $path1 -sqlQuery $createQuery

  # Vykonání dotazu pro obě databáze
  $data1 = ExecuteQuery -databasePath $path1 -sqlQuery $query1
  $data2 = ExecuteQuery -databasePath $path2 -sqlQuery $query2

  # Porovnání dat bez zahrnutí ID do porovnání
  $properties = @("Name", "Protocol", "LocalPort", "RemotePort", "LocalAddress", "RemoteAddress", "Enabled", "Profile", "Direction", "Action")
  $differences = Compare-Object -ReferenceObject $data1 -DifferenceObject $data2 -Property $properties -PassThru

  # Uložení rozdílů do tabulky
  foreach ($difference in $differences) {
    $insertDifferenceQuery = @"
INSERT INTO $tableName (Audit_ID, [Name], Protocol, LocalPort, RemotePort, LocalAddress, RemoteAddress, [Enabled], Profile, [Direction], [Action])
VALUES ('$($difference.Audit_ID)', '$($difference.Name)', '$($difference.Protocol)', '$($difference.LocalPort)', '$($difference.RemotePort)', '$($difference.LocalAddress)',
'$($difference.RemoteAddress)', '$($difference.Enabled)', '$($difference.Profile)', '$($difference.Direction)', '$($difference.Action)')
"@
    ExecuteQuery -databasePath $path1 -sqlQuery $insertDifferenceQuery
  }
  Write-Host "Rozdíly byly úspěšně uloženy do databáze."
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
SELECT * FROM FirewallRules
WHERE Audit_ID = (SELECT MAX(Audit_ID) FROM FirewallRules)
"@

    $sqlQuery2 = @"
SELECT * FROM FirewallRules
WHERE Audit_ID = (SELECT MAX(Audit_ID) FROM FirewallRules WHERE Audit_ID < (SELECT MAX(Audit_ID) FROM FirewallRules))
"@

    AnalyzeFirewall $databasePath $sqlQuery1 $databasePath $sqlQuery2
  }

  "manual" {
    Write-Host "Vyberte soubor pro první databázi:"
    $databasePath1 = GetFileName("D:\Documents\DiplProg")
    Write-Host "Zadejte Audit_ID pro první databázi:"
    $auditId1 = Read-Host
    $sqlQuery1 = "SELECT * FROM FirewallRules WHERE Audit_ID = $auditId1"

    Write-Host "Vyberte soubor pro druhou databázi:"
    $databasePath2 = GetFileName("D:\Documents\DiplProg")
    Write-Host "Zadejte Audit_ID pro druhou databázi:"
    $auditId2 = Read-Host
    $sqlQuery2 = "SELECT * FROM FirewallRules WHERE Audit_ID = $auditId2"

    AnalyzeFirewall $databasePath1 $sqlQuery1 $databasePath2 $sqlQuery2
  }
}