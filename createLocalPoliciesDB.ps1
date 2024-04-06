# Načtení souboru s funkcemi
. .\functions.ps1

# Nastavení cesty k dočasnému souboru
$tempFile = ".\secpol.cfg"

try {
  # Export lokálních bezpečnostních politik do dočasného souboru
  & secedit /export /cfg $tempFile

  # Získání cesty k databázi
  Write-Host "Vyberte databázi pro ukládání informací:"
  $databasePath = GetFileName("D:\Documents\DiplProg")

  # Kontrola, zda existuje tabulka LocalPolicies, a její vytvoření
  $newTableName = "LocalPolicies"
  if (-not (TableExists -tableName $newTableName -databasePath $databasePath)) {
      $createQuery = "CREATE TABLE $newTableName (ID AUTOINCREMENT PRIMARY KEY, Audit_ID INT, [Name] TEXT(255), [Value] TEXT(255))"
      ExecuteQuery -databasePath $databasePath -sqlQuery $createQuery
  }

  # Načtení maximální hodnoty Audit_ID
  $newAuditId = Get-NewAuditId -databasePath $databasePath -tableName $newTableName

  # Čtení a zpracování exportovaného souboru
  $data = Get-Content $tempFile | Where-Object { $_ -match "=" } | ForEach-Object {
      $parts = $_ -split "=", 2
      [PSCustomObject]@{
          Name = $parts[0].Trim()
          Value = ($parts[1] -split ",").Trim()
      }
  }

  # Vložení naformátovaných dat do databáze
  foreach ($item in $data) {
      foreach ($value in $item.Value) {
          $insertQuery = "INSERT INTO $newTableName (Audit_ID, [Name], [Value]) VALUES ($newAuditId, '$($item.Name)', '$value')"
          ExecuteQuery -databasePath $databasePath -sqlQuery $insertQuery
      }
  }
  Write-Host "Data byla úspěšně uložena do databáze s Audit_ID $newAuditId."
}
catch {
  Write-Error "Při zpracování došlo k chybě: $_"
  }
  finally {
  # Odstranění dočasného souboru po zpracování
  if (Test-Path $tempFile) {
      Remove-Item $tempFile -Force
  }
}