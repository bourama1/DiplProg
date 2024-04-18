param(
  [string]$databasePath = $null,
  [ValidateSet("automatic", "manual")]
  [string]$mode = "automatic"
)

# Načtení souboru s funkcemi
. .\functions.ps1

Function AnalyzeDatabases($path1, $query1, $path2, $query2, $excludedCategories = $null) {
  $tableName = "Rozdily"
  if (TableExists $tableName $path1) {
    DropTable $tableName $path1
  }

  $createTableScript = @"
CREATE TABLE Rozdily (
    ID AUTOINCREMENT PRIMARY KEY,
    Audit_ID INT,
    Record_Ordinal INT,
    Computer_ID INT,
    Category_ID INT,
    Item_1 TEXT,
    Item_2 TEXT,
    Item_3 TEXT,
    Item_4 TEXT,
    Item_5 TEXT,
    Item_6 TEXT,
    Item_7 TEXT,
    Item_8 TEXT,
    Item_9 TEXT,
    Item_10 TEXT,
    Item_11 TEXT(255),
    Item_12 TEXT(255),
    Item_13 TEXT(255),
    Item_14 TEXT(255),
    Item_15 TEXT(255),
    Item_16 TEXT(255),
    Item_17 TEXT(255),
    Item_18 TEXT(255),
    Item_19 TEXT(255),
    Item_20 TEXT(255),
    Item_21 TEXT(255),
    Item_22 TEXT(255),
    Item_23 TEXT(255),
    Item_24 TEXT(255),
    Item_25 TEXT(255),
    Item_26 TEXT(255),
    Item_27 TEXT(255),
    Item_28 TEXT(255),
    Item_29 TEXT(255),
    Item_30 TEXT(255),
    Item_31 TEXT(255),
    Item_32 TEXT(255),
    Item_33 TEXT(255),
    Item_34 TEXT(255),
    Item_35 TEXT(255),
    Item_36 TEXT(255),
    Item_37 TEXT(255),
    Item_38 TEXT(255),
    Item_39 TEXT(255),
    Item_40 TEXT(255),
    Item_41 TEXT(255),
    Item_42 TEXT(255),
    Item_43 TEXT(255),
    Item_44 TEXT(255),
    Item_45 TEXT(255),
    Item_46 TEXT(255),
    Item_47 TEXT(255),
    Item_48 TEXT(255),
    Item_49 TEXT(255),
    Item_50 TEXT(255)
);
"@
  ExecuteQuery -databasePath $path1 -sqlQuery $createTableScript

  # Vykonání dotazu pro obě databáze
  $data1 = ExecuteQuery -databasePath $path1 -sqlQuery $query1
  $data2 = ExecuteQuery -databasePath $path2 -sqlQuery $query2

  # Filtr dat pouze pokud existuje seznam vyloučených kategorií
  if ($excludedCategories) {
      $data1 = $data1 | Where-Object { $excludedCategories -notcontains $_.Category_ID }
      $data2 = $data2 | Where-Object { $excludedCategories -notcontains $_.Category_ID }
  }

  # Logika pro porovnání a zpracování dat
  CompareAndProcessData $data1 $data2 $path1
}


Function CompareAndProcessData($data1, $data2, $databasePath) {
  # Kontrola, jestli data nejsou null
  if (-not $data1 -or -not $data2) {
    Write-Host "Jedna nebo obě sady dat jsou prázdné. Skript se předčasně ukončuje."
    return
  }

  # Načtení dat z kategorie 1000 a kontrola null
  $data1Category1000 = $data1 | Where-Object { $_.Category_ID -eq 1000 }
  $data2Category1000 = $data2 | Where-Object { $_.Category_ID -eq 1000 }

  if (-not $data1Category1000 -or -not $data2Category1000) {
      Write-Host "Nebyla nalezena žádná data pro kategorii 1000."
  } else {
      $differencesCategory1000 = Compare-Object -ReferenceObject $data1Category1000 -DifferenceObject $data2Category1000 -Property Item_4 -PassThru | Where-Object { $_.Property -notin @('Audit_ID', 'Record_Ordinal', "Computer_ID", "Category_ID") }
      if ($differencesCategory1000) {
          $groupedDifferences = $differencesCategory1000 | Group-Object -Property Item_4
          $aggregatedDifferences = AggregateDifferences -groupedDifferences $groupedDifferences
          InsertDifferences -differences $aggregatedDifferences -databasePath $databasePath
      }
  }

  # Načtení dat z kategorie 4200 a kontrola null
  $data1Category4200 = $data1 | Where-Object { $_.Category_ID -eq 4200 }
  $data2Category4200 = $data2 | Where-Object { $_.Category_ID -eq 4200 }

  if (-not $data1Category4200 -or -not $data2Category4200) {
      Write-Host "Nebyla nalezena žádná data pro kategorii 4200."
  } else {
      $differencesCategory4200 = Compare-Object -ReferenceObject $data1Category4200 -DifferenceObject $data2Category4200 -Property Item_1 -PassThru | Where-Object { $_.Property -notin @('Audit_ID', 'Record_Ordinal', "Computer_ID", "Category_ID") }
      if ($differencesCategory4200) {
          $groupedDifferences = $differencesCategory4200 | Group-Object -Property Item_1
          $aggregatedDifferences = AggregateDifferences -groupedDifferences $groupedDifferences
          InsertDifferences -differences $aggregatedDifferences -databasePath $databasePath
      }
  }

  ### Získání všech vlastností z prvního objektu
  $allProperties = $data1 | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name

  # Specifikujte vlastnosti, které NEchcete porovnávat
  $excludeProperties = @('Audit_ID', 'Record_Ordinal', 'Computer_ID', 'Category_ID', 'Item_7')

  # Vyfiltrujte všechny vlastnosti, které chcete porovnat (vše kromě vyloučených)
  $propertiesToCompare = $allProperties | Where-Object { $_ -notin $excludeProperties }

  # Načtení dat z kategorie 7800
  $data1Category7800 = $data1 | Where-Object { $_.Category_ID -eq 7800 }
  $data2Category7800 = $data2 | Where-Object { $_.Category_ID -eq 7800 }

  if (-not $data1Category7800 -or -not $data2Category7800) {
    Write-Host "Nebyla nalezena žádná data pro kategorii 7800."
  } else {
    $differencesCategory7800 = Compare-Object -ReferenceObject $data1Category7800 -DifferenceObject $data2Category7800 -Property $propertiesToCompare -PassThru | Where-Object { $_.Property -notin @('Audit_ID', 'Record_Ordinal', "Computer_ID", "Category_ID") }
    if ($differencesCategory7800) {
      InsertDifferences -differences $differencesCategory7800 -databasePath $databasePath
    }
  }

  # Specifikujte vlastnosti, které NEchcete porovnávat
  $excludeProperties = @('Audit_ID', 'Record_Ordinal', 'Computer_ID', 'Category_ID')

  # Vyfiltrujte všechny vlastnosti, které chcete porovnat (vše kromě vyloučených)
  $propertiesToCompare = $allProperties | Where-Object { $_ -notin $excludeProperties }

  # Zbytek dat pro další porovnání
  $data1Other = $data1 | Where-Object { $_.Category_ID -ne 1000 -and $_.Category_ID -ne 4200 -and $_.Category_ID -ne 7800 }
  $data2Other = $data2 | Where-Object { $_.Category_ID -ne 1000 -and $_.Category_ID -ne 4200 -and $_.Category_ID -ne 7800 }

  if (-not $data1Other -or -not $data2Other) {
    Write-Host "Nebyla nalezena žádná zbylá data."
  } else {
    $differencesOther = Compare-Object -ReferenceObject $data1Other -DifferenceObject $data2Other -Property $propertiesToCompare -PassThru | Where-Object { $_.Property -notin @('Audit_ID', 'Record_Ordinal', "Computer_ID", "Category_ID") }
    if ($differencesOther) {
      InsertDifferences -differences $differencesOther -databasePath $databasePath
    }
  }
}

# Rozhodování mezi automatickým a manuálním režimem
switch ($mode) {
  "automatic" {
    if (-not $databasePath) {
      Write-Host "Vyberte databázi:"
      $databasePath = GetFileName("D:\Documents\DiplProg")
    }

    $sqlQuery1 = "SELECT * FROM Audit_Data WHERE Audit_ID = (SELECT MAX(Audit_ID) FROM Audit_Data)"
    $sqlQuery2 = "SELECT * FROM Audit_Data WHERE Audit_ID = (SELECT MAX(Audit_ID) FROM Audit_Data WHERE Audit_ID < (SELECT MAX(Audit_ID) FROM Audit_Data))"

    AnalyzeDatabases $databasePath $sqlQuery1 $databasePath $sqlQuery2
  }

  "manual" {
    Write-Host "Vyberte soubor pro první databázi:"
    $databasePath1 = GetFileName("D:\Documents\DiplProg")
    Write-Host "Zadejte Audit_ID pro první databázi:"
    $auditId1 = Read-Host

    $sqlQuery1 = @"
SELECT * FROM Audit_Data
WHERE Audit_ID = $auditId1
"@

    Write-Host "Vyberte soubor pro druhou databázi:"
    $databasePath2 = GetFileName("D:\Documents\DiplProg")
    Write-Host "Zadejte Audit_ID pro druhou databázi:"
    $auditId2 = Read-Host

    $sqlQuery2 = @"
SELECT * FROM Audit_Data
WHERE Audit_ID = $auditId2
"@

    # Přidání promptu pro kategorie, které nechce uživatel zahrnout
    Write-Host "Zadejte čísla kategorií oddělené čárkou, které nechcete zahrnout do porovnání (např. 1000,4200) !popisky v readme!:"
    $excludedCategories = Read-Host
    $excludedCategoryList = $excludedCategories -split ',' | ForEach-Object { $_.Trim() }

    AnalyzeDatabases $databasePath1 $sqlQuery1 $databasePath2 $sqlQuery2 $excludedCategoryList
  }
}