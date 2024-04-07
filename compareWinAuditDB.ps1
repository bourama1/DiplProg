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
SELECT * FROM Audit_Data
WHERE Audit_ID = (SELECT MAX(Audit_ID) FROM Audit_Data)
"@

$sqlQuery2 = @"
SELECT * FROM Audit_Data
WHERE Audit_ID = (SELECT MAX(Audit_ID) FROM Audit_Data WHERE Audit_ID < (SELECT MAX(Audit_ID) FROM Audit_Data))
"@

# Zjisteni jestli jiz existuje tabulka rozdily, popr. jeji smazani
$tableName = "Rozdily"
if (TableExists $tableName $databasePath) {
  DropTable $tableName $databasePath
}

# Vytvoření tabulky v nové databázi pro uložení rozdílů
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
ExecuteQuery -databasePath $databasePath -sqlQuery $createTableScript

# Vykonání dotazu pro obě databáze
$data1 = ExecuteQuery -databasePath $databasePath -sqlQuery $sqlQuery1
$data2 = ExecuteQuery -databasePath $databasePath -sqlQuery $sqlQuery2

# Načtení dat z kategorie 1000
$data1Category1000 = $data1 | Where-Object { $_.Category_ID -eq 1000 }
$data2Category1000 = $data2 | Where-Object { $_.Category_ID -eq 1000 }

# Porovnání dat pouze na základě Item_4 pro kategorii 1000
$differencesCategory1000 = Compare-Object -ReferenceObject $data1Category1000 -DifferenceObject $data2Category1000 -Property Item_4 -PassThru | Where-Object { $_.Property -notin @('Audit_ID', 'Record_Ordinal', "Computer_ID", "Category_ID") }
$groupedDifferences = $differencesCategory1000 | Group-Object -Property Item_4
$aggregatedDifferences = AggregateDifferences -groupedDifferences $groupedDifferences

# Nyní máme $aggregatedDifferences obsahující pouze jeden záznam pro každý unikátní Item_4
# Voláme InsertDifferences s tímto nově agregovaným seznamem
InsertDifferences -differences $aggregatedDifferences

# Načtení dat z kategorie 4200
$data1Category4200 = $data1 | Where-Object { $_.Category_ID -eq 4200 }
$data2Category4200 = $data2 | Where-Object { $_.Category_ID -eq 4200 }

# Porovnání dat pouze na základě Item_1 pro kategorii 4200
$differencesCategory4200 = Compare-Object -ReferenceObject $data1Category4200 -DifferenceObject $data2Category4200 -Property Item_1 -PassThru | Where-Object { $_.Property -notin @('Audit_ID', 'Record_Ordinal', "Computer_ID", "Category_ID") }
$groupedDifferences = $differencesCategory4200 | Group-Object -Property Item_1
$aggregatedDifferences = AggregateDifferences -groupedDifferences $groupedDifferences

# Nyní máme $aggregatedDifferences obsahující pouze jeden záznam pro každý unikátní Item_1
# Voláme InsertDifferences s tímto nově agregovaným seznamem
InsertDifferences -differences $aggregatedDifferences

### Získání všech vlastností z prvního objektu
$allProperties = $data1 | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name

# Specifikujte vlastnosti, které NEchcete porovnávat
$excludeProperties = @('Audit_ID', 'Record_Ordinal', 'Computer_ID', 'Category_ID', 'Item_7')

# Vyfiltrujte všechny vlastnosti, které chcete porovnat (vše kromě vyloučených)
$propertiesToCompare = $allProperties | Where-Object { $_ -notin $excludeProperties }

# Načtení dat z kategorie 7800
$data1Category7800 = $data1 | Where-Object { $_.Category_ID -eq 7800 }
$data2Category7800 = $data2 | Where-Object { $_.Category_ID -eq 7800 }

# Porovnání dat na základě krom Item_7 pro kategorii 7800
$differencesCategory7800 = Compare-Object -ReferenceObject $data1Category7800 -DifferenceObject $data2Category7800 -Property $propertiesToCompare -PassThru | Where-Object { $_.Property -notin @('Audit_ID', 'Record_Ordinal', "Computer_ID", "Category_ID") }
InsertDifferences($differencesCategory7800)

# Zbytek dat pro další porovnání + vyhozeni kategori 3600 (info o zaplneni RAM)
$data1Other = $data1 | Where-Object { $_.Category_ID -ne 1000 -and $_.Category_ID -ne 4200 -and $_.Category_ID -ne 7800 -and $_.Category_ID -ne 3600 }
$data2Other = $data2 | Where-Object { $_.Category_ID -ne 1000 -and $_.Category_ID -ne 4200 -and $_.Category_ID -ne 7800 -and $_.Category_ID -ne 3600 }

# Specifikujte vlastnosti, které NEchcete porovnávat
$excludeProperties = @('Audit_ID', 'Record_Ordinal', 'Computer_ID', 'Category_ID')

# Vyfiltrujte všechny vlastnosti, které chcete porovnat (vše kromě vyloučených)
$propertiesToCompare = $allProperties | Where-Object { $_ -notin $excludeProperties }

# Porovnání zbylých dat
$differencesOther = Compare-Object -ReferenceObject $data1Other -DifferenceObject $data2Other -Property $propertiesToCompare -PassThru | Where-Object { $_.Property -notin @('Audit_ID', 'Record_Ordinal', "Computer_ID", "Category_ID") }
InsertDifferences($differencesOther)