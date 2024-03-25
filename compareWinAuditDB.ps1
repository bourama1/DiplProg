# Načtení souboru s funkcemi
. .\functions.ps1

<#
.SYNOPSIS
Inserts differences and corresponding rows into a new database.

.DESCRIPTION
This function takes a difference object as input and inserts the differences and their corresponding rows into a new database. It iterates through the differences array and checks if there is a corresponding row. If a corresponding row is found, it inserts both the difference and the corresponding row into the database. It also keeps track of the stored indexes to avoid duplicate inserts.

.PARAMETER difference
The difference object containing the data to be inserted into the database.

.EXAMPLE
InsertDifference -difference $difference
# Inserts the differences and corresponding rows into the database.

.NOTES
This function requires the ExecuteQuery function from the functions.ps1 file to be loaded.

.LINK
functions.ps1
#>
function InsertDifferences($differences) {
    # Uložení rozdílů a odpovídajících řádků do nové databáze
    $storedIndexes = @()  # Pole indexů uložených rozdílů
    for ($i = 0; $i -lt $differences.Count; $i++) {
        $difference = $differences[$i]
        # Pokud existuje odpovídající řádek
        if ($difference.SideIndicator -eq "=>") {
            # Vložení do databáze
            $insertScript = @"
INSERT INTO Rozdily (Audit_ID, Record_Ordinal, Computer_ID, Category_ID, Item_1, Item_2, Item_3, Item_4, Item_5, Item_6, Item_7, Item_8, Item_9, Item_10, Item_11, Item_12, Item_13, Item_14, Item_15, Item_16, Item_17, Item_18, Item_19, Item_20, Item_21, Item_22, Item_23, Item_24, Item_25, Item_26, Item_27, Item_28, Item_29, Item_30, Item_31, Item_32, Item_33, Item_34, Item_35, Item_36, Item_37, Item_38, Item_39, Item_40, Item_41, Item_42, Item_43, Item_44, Item_45, Item_46, Item_47, Item_48, Item_49, Item_50)
VALUES ('$($difference.Audit_ID)', '$($difference.Record_Ordinal)', '$($difference.Computer_ID)', '$($difference.Category_ID)', '$($difference.Item_1)', '$($difference.Item_2)', '$($difference.Item_3)', '$($difference.Item_4)', '$($difference.Item_5)', '$($difference.Item_6)', '$($difference.Item_7)', '$($difference.Item_8)', '$($difference.Item_9)', '$($difference.Item_10)', '$($difference.Item_11)', '$($difference.Item_12)', '$($difference.Item_13)', '$($difference.Item_14)', '$($difference.Item_15)', '$($difference.Item_16)', '$($difference.Item_17)', '$($difference.Item_18)', '$($difference.Item_19)', '$($difference.Item_20)', '$($difference.Item_21)', '$($difference.Item_22)', '$($difference.Item_23)', '$($difference.Item_24)', '$($difference.Item_25)', '$($difference.Item_26)', '$($difference.Item_27)', '$($difference.Item_28)', '$($difference.Item_29)', '$($difference.Item_30)', '$($difference.Item_31)', '$($difference.Item_32)', '$($difference.Item_33)', '$($difference.Item_34)', '$($difference.Item_35)', '$($difference.Item_36)', '$($difference.Item_37)', '$($difference.Item_38)', '$($difference.Item_39)', '$($difference.Item_40)', '$($difference.Item_41)', '$($difference.Item_42)', '$($difference.Item_43)', '$($difference.Item_44)', '$($difference.Item_45)', '$($difference.Item_46)', '$($difference.Item_47)', '$($difference.Item_48)', '$($difference.Item_49)', '$($difference.Item_50)')
"@
            ExecuteQuery -databasePath $databasePath -sqlQuery $insertScript
            $storedIndexes += $i  # Uložit index zapsaného rozdílu do pole
            
            # Projít všechny následující položky a hledat odpovídající řádek
            for ($j = $i + 1; $j -lt $differences.Count; $j++) {
                $correspondingRow = $differences[$j]
                if ($j -notin $storedIndexes -and $correspondingRow.SideIndicator -eq "<=") {
                    # Vložení odpovídajícího řádku do databáze
                    $insertScript = @"
INSERT INTO Rozdily (Audit_ID, Record_Ordinal, Computer_ID, Category_ID, Item_1, Item_2, Item_3, Item_4, Item_5, Item_6, Item_7, Item_8, Item_9, Item_10, Item_11, Item_12, Item_13, Item_14, Item_15, Item_16, Item_17, Item_18, Item_19, Item_20, Item_21, Item_22, Item_23, Item_24, Item_25, Item_26, Item_27, Item_28, Item_29, Item_30, Item_31, Item_32, Item_33, Item_34, Item_35, Item_36, Item_37, Item_38, Item_39, Item_40, Item_41, Item_42, Item_43, Item_44, Item_45, Item_46, Item_47, Item_48, Item_49, Item_50)
VALUES ('$($correspondingRow.Audit_ID)', '$($correspondingRow.Record_Ordinal)', '$($correspondingRow.Computer_ID)', '$($correspondingRow.Category_ID)', '$($correspondingRow.Item_1)', '$($correspondingRow.Item_2)', '$($correspondingRow.Item_3)', '$($correspondingRow.Item_4)', '$($correspondingRow.Item_5)', '$($correspondingRow.Item_6)', '$($correspondingRow.Item_7)', '$($correspondingRow.Item_8)', '$($correspondingRow.Item_9)', '$($correspondingRow.Item_10)', '$($correspondingRow.Item_11)', '$($correspondingRow.Item_12)', '$($correspondingRow.Item_13)', '$($correspondingRow.Item_14)', '$($correspondingRow.Item_15)', '$($correspondingRow.Item_16)', '$($correspondingRow.Item_17)', '$($correspondingRow.Item_18)', '$($correspondingRow.Item_19)', '$($correspondingRow.Item_20)', '$($correspondingRow.Item_21)', '$($correspondingRow.Item_22)', '$($correspondingRow.Item_23)', '$($correspondingRow.Item_24)', '$($correspondingRow.Item_25)', '$($correspondingRow.Item_26)', '$($correspondingRow.Item_27)', '$($correspondingRow.Item_28)', '$($correspondingRow.Item_29)', '$($correspondingRow.Item_30)', '$($correspondingRow.Item_31)', '$($correspondingRow.Item_32)', '$($correspondingRow.Item_33)', '$($correspondingRow.Item_34)', '$($correspondingRow.Item_35)', '$($correspondingRow.Item_36)', '$($correspondingRow.Item_37)', '$($correspondingRow.Item_38)', '$($correspondingRow.Item_39)', '$($correspondingRow.Item_40)', '$($correspondingRow.Item_41)', '$($correspondingRow.Item_42)', '$($correspondingRow.Item_43)', '$($correspondingRow.Item_44)', '$($correspondingRow.Item_45)', '$($correspondingRow.Item_46)', '$($correspondingRow.Item_47)', '$($correspondingRow.Item_48)', '$($correspondingRow.Item_49)', '$($correspondingRow.Item_50)')
"@
                    ExecuteQuery -databasePath $databasePath -sqlQuery $insertScript
                    $storedIndexes += $j  # Uložit index zapsaného rozdílu do pole
                    break
                }
            }
        } elseif ($i -notin $storedIndexes) {
            # Pokud řádek není uložen do databáze tak ho ulozim
            $insertScript = @"
INSERT INTO Rozdily (Audit_ID, Record_Ordinal, Computer_ID, Category_ID, Item_1, Item_2, Item_3, Item_4, Item_5, Item_6, Item_7, Item_8, Item_9, Item_10, Item_11, Item_12, Item_13, Item_14, Item_15, Item_16, Item_17, Item_18, Item_19, Item_20, Item_21, Item_22, Item_23, Item_24, Item_25, Item_26, Item_27, Item_28, Item_29, Item_30, Item_31, Item_32, Item_33, Item_34, Item_35, Item_36, Item_37, Item_38, Item_39, Item_40, Item_41, Item_42, Item_43, Item_44, Item_45, Item_46, Item_47, Item_48, Item_49, Item_50)
VALUES ('$($difference.Audit_ID)', '$($difference.Record_Ordinal)', '$($difference.Computer_ID)', '$($difference.Category_ID)', '$($difference.Item_1)', '$($difference.Item_2)', '$($difference.Item_3)', '$($difference.Item_4)', '$($difference.Item_5)', '$($difference.Item_6)', '$($difference.Item_7)', '$($difference.Item_8)', '$($difference.Item_9)', '$($difference.Item_10)', '$($difference.Item_11)', '$($difference.Item_12)', '$($difference.Item_13)', '$($difference.Item_14)', '$($difference.Item_15)', '$($difference.Item_16)', '$($difference.Item_17)', '$($difference.Item_18)', '$($difference.Item_19)', '$($difference.Item_20)', '$($difference.Item_21)', '$($difference.Item_22)', '$($difference.Item_23)', '$($difference.Item_24)', '$($difference.Item_25)', '$($difference.Item_26)', '$($difference.Item_27)', '$($difference.Item_28)', '$($difference.Item_29)', '$($difference.Item_30)', '$($difference.Item_31)', '$($difference.Item_32)', '$($difference.Item_33)', '$($difference.Item_34)', '$($difference.Item_35)', '$($difference.Item_36)', '$($difference.Item_37)', '$($difference.Item_38)', '$($difference.Item_39)', '$($difference.Item_40)', '$($difference.Item_41)', '$($difference.Item_42)', '$($difference.Item_43)', '$($difference.Item_44)', '$($difference.Item_45)', '$($difference.Item_46)', '$($difference.Item_47)', '$($difference.Item_48)', '$($difference.Item_49)', '$($difference.Item_50)')
"@
            ExecuteQuery -databasePath $databasePath -sqlQuery $insertScript
            $storedIndexes += $i
        }
    }
}

# Získání cílové databáze s WinAudit reporty
Write-Host "Vyberte databázi s WinAudit reporty:"
$databasePath = GetFileName("D:\Documents\DiplProg")

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
    Item_1 VARCHAR(255),
    Item_2 VARCHAR(255),
    Item_3 VARCHAR(255),
    Item_4 VARCHAR(255),
    Item_5 VARCHAR(255),
    Item_6 VARCHAR(255),
    Item_7 VARCHAR(255),
    Item_8 VARCHAR(255),
    Item_9 VARCHAR(255),
    Item_10 VARCHAR(255),
    Item_11 VARCHAR(255),
    Item_12 VARCHAR(255),
    Item_13 VARCHAR(255),
    Item_14 VARCHAR(255),
    Item_15 VARCHAR(255),
    Item_16 VARCHAR(255),
    Item_17 VARCHAR(255),
    Item_18 VARCHAR(255),
    Item_19 VARCHAR(255),
    Item_20 VARCHAR(255),
    Item_21 VARCHAR(255),
    Item_22 VARCHAR(255),
    Item_23 VARCHAR(255),
    Item_24 VARCHAR(255),
    Item_25 VARCHAR(255),
    Item_26 VARCHAR(255),
    Item_27 VARCHAR(255),
    Item_28 VARCHAR(255),
    Item_29 VARCHAR(255),
    Item_30 VARCHAR(255),
    Item_31 VARCHAR(255),
    Item_32 VARCHAR(255),
    Item_33 VARCHAR(255),
    Item_34 VARCHAR(255),
    Item_35 VARCHAR(255),
    Item_36 VARCHAR(255),
    Item_37 VARCHAR(255),
    Item_38 VARCHAR(255),
    Item_39 VARCHAR(255),
    Item_40 VARCHAR(255),
    Item_41 VARCHAR(255),
    Item_42 VARCHAR(255),
    Item_43 VARCHAR(255),
    Item_44 VARCHAR(255),
    Item_45 VARCHAR(255),
    Item_46 VARCHAR(255),
    Item_47 VARCHAR(255),
    Item_48 VARCHAR(255),
    Item_49 VARCHAR(255),
    Item_50 VARCHAR(255)
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
InsertDifferences($differencesCategory1000)

# Načtení dat z kategorie 4200
$data1Category4200 = $data1 | Where-Object { $_.Category_ID -eq 4200 } 
$data2Category4200 = $data2 | Where-Object { $_.Category_ID -eq 4200 } 

# Porovnání dat pouze na základě Item_1 pro kategorii 4200
$differencesCategory4200 = Compare-Object -ReferenceObject $data1Category4200 -DifferenceObject $data2Category4200 -Property Item_1 -PassThru | Where-Object { $_.Property -notin @('Audit_ID', 'Record_Ordinal', "Computer_ID", "Category_ID") }
InsertDifferences($differencesCategory4200)

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

# Zbytek dat pro další porovnání
$data1Other = $data1 | Where-Object { $_.Category_ID -ne 1000 -and $_.Category_ID -ne 4200 -and $_.Category_ID -ne 7800 }
$data2Other = $data2 | Where-Object { $_.Category_ID -ne 1000 -and $_.Category_ID -ne 4200 -and $_.Category_ID -ne 7800 }

# Specifikujte vlastnosti, které NEchcete porovnávat
$excludeProperties = @('Audit_ID', 'Record_Ordinal', 'Computer_ID', 'Category_ID')

# Vyfiltrujte všechny vlastnosti, které chcete porovnat (vše kromě vyloučených)
$propertiesToCompare = $allProperties | Where-Object { $_ -notin $excludeProperties }

# Porovnání zbylých dat
$differencesOther = Compare-Object -ReferenceObject $data1Other -DifferenceObject $data2Other -Property $propertiesToCompare -PassThru | Where-Object { $_.Property -notin @('Audit_ID', 'Record_Ordinal', "Computer_ID", "Category_ID") }
InsertDifferences($differencesOther)