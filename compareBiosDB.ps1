# Načtení souboru s funkcemi
. .\functions.ps1

# Získání cílové databáze s WMIC reporty
Write-Host "Vyberte databázi s WMIC reporty:"
$databasePath = GetFileName("D:\Documents\DiplProg")

# SQL dotaz pro vybrání dat z tabulky
$sqlQuery1 = @"
SELECT * FROM BiosInfo
WHERE ID = (SELECT MAX(ID) FROM BiosInfo)
"@

$sqlQuery2 = @"
SELECT * FROM BiosInfo
WHERE ID = (SELECT MAX(ID) FROM BiosInfo WHERE ID < (SELECT MAX(ID) FROM BiosInfo))
"@

# Vykonání dotazu pro obě databáze
$data1 = ExecuteQuery -databasePath $databasePath -sqlQuery $sqlQuery1
$data2 = ExecuteQuery -databasePath $databasePath -sqlQuery $sqlQuery2

# Zjisteni jestli jiz existuje tabulka rozdily, popr. jeji smazani
$tableName = "RozdilyWMIC"
if (TableExists $tableName $databasePath) {
    DropTable $tableName $databasePath
}

# Vytvoření tabulky v nové databázi pro uložení rozdílů
$createQuery = @"
CREATE TABLE RozdilyWMIC (
    ID AUTOINCREMENT PRIMARY KEY,
    Audit_ID INT,
    Manufacturer TEXT(255),
    SerialNumber TEXT(255),
    Version TEXT(255),
    BIOSVersion TEXT(255)
)
"@
ExecuteQuery -databasePath $databasePath -sqlQuery $createQuery

# Porovnání dat bez zahrnutí ID do porovnání
$differences = Compare-Object -ReferenceObject $data1 -DifferenceObject $data2 -Property ("Manufacturer", "SerialNumber", "Version", "BIOSVersion") -PassThru


# Iterace přes nalezené rozdíly a jejich vložení do tabulky RozdilyWMIC
foreach ($difference in $differences) {
    # Příprava SQL dotazu pro vložení rozdílu do tabulky
    $insertQuery = @"
INSERT INTO RozdilyWMIC (Audit_ID, Manufacturer, SerialNumber, Version, BIOSVersion)
VALUES ('$($difference.ID)', '$($difference.Manufacturer)', '$($difference.SerialNumber)', '$($difference.Version)', '$($difference.BIOSVersion)')
"@
    ExecuteQuery -databasePath $databasePath -sqlQuery $insertQuery
}
Write-Host "Rozdíly byly úspěšně uloženy do tabulky RozdilyWMIC."
