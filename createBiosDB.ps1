# Načtení souboru s funkcemi
. .\functions.ps1

# Získání cílové databáze pro WinAudit report
Write-Host "Vyberte databázi pro ulozeni informaci o pravidlech BIOSu:"
$dbPath = GetFileName("D:\Documents\DiplProg")

# Kontrola, zda tabulka 'BiosInfo' existuje
if (-not (TableExists -tableName "BiosInfo" -databasePath $dbPath)) {
    # Tabulka neexistuje, vytvoříme ji
    $createQuery = @"
CREATE TABLE BiosInfo (
    ID AUTOINCREMENT PRIMARY KEY,
    Manufacturer TEXT(255),
    SerialNumber TEXT(255),
    Version TEXT(255),
    BIOSVersion TEXT(255)
)
"@
    ExecuteQuery -databasePath $dbPath -sqlQuery $createQuery
    Write-Host "Tabulka BiosInfo byla úspěšně vytvořena."
}

# Získání informací o BIOS a příprava SQL příkazu pro vložení dat
$biosInfo = Get-CimInstance -ClassName Win32_BIOS
$insertQuery = "INSERT INTO BiosInfo (Manufacturer, SerialNumber, Version, BIOSVersion) VALUES ('$($biosInfo.Manufacturer)', '$($biosInfo.SerialNumber)', '$($biosInfo.Version)', '$($biosInfo.SMBIOSBIOSVersion)')"

# Vložení dat do tabulky
ExecuteQuery -databasePath $dbPath -sqlQuery $insertQuery
Write-Host "Data byla úspěšně uložena do databáze."