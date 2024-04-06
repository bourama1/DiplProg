# Načtení souboru s funkcemi
. .\functions.ps1

# Získání cílové databáze pro WinAudit report
Write-Host "Vyberte databázi pro ulozeni informaci o pravidlech BIOSu:"
$dbPath = GetFileName("D:\Documents\DiplProg")

# Získání vlastností objektu BIOS
$biosProperties = Get-CimInstance -ClassName Win32_BIOS | Get-Member -MemberType Property

# Sestavení SQL dotazu pro vytvoření tabulky
$createTableQuery = "CREATE TABLE BiosInfo (ID AUTOINCREMENT PRIMARY KEY, "
foreach ($prop in $biosProperties) {
    $createTableQuery += "$($prop.Name) TEXT(255), "
}
$createTableQuery = $createTableQuery.TrimEnd(", ") + ")"

# Kontrola, zda tabulka 'BiosInfo' existuje
if (-not (TableExists -tableName "BiosInfo" -databasePath $dbPath)) {
    # Tabulka neexistuje, vytvoříme ji
    ExecuteQuery -databasePath $dbPath -sqlQuery $createTableQuery
    Write-Host "Tabulka BiosInfo byla úspěšně vytvořena."
}

# Získání dat BIOSu
$biosData = Get-CimInstance -ClassName Win32_BIOS

# Sestavení a spuštění SQL dotazu pro vkládání dat
$insertQuery = "INSERT INTO BiosInfo ("
foreach ($prop in $biosProperties) {
    $insertQuery += "$($prop.Name), "
}
$insertQuery = $insertQuery.TrimEnd(", ") + ") VALUES ("
foreach ($prop in $biosProperties) {
    $value = $biosData.$($prop.Name)
    $insertQuery += "'$value', "
}
$insertQuery = $insertQuery.TrimEnd(", ") + ")"

ExecuteQuery -databasePath $dbPath -sqlQuery $insertQuery
Write-Host "Data o bios byla úspěšně uložena do databáze."