param(
  [string]$databasePath = $null
)

# Načtení souboru s funkcemi
. .\functions.ps1

if (-not $databasePath) {
  Write-Host "Vyberte databázi:"
  $databasePath = GetFileName("D:\Documents\DiplProg")
}

# Získání vlastností objektu BIOS
$biosProperties = Get-CimInstance -ClassName Win32_BIOS | Get-Member -MemberType Property

# Sestavení SQL dotazu pro vytvoření tabulky
$createTableQuery = "CREATE TABLE BiosInfo (ID AUTOINCREMENT PRIMARY KEY, "
foreach ($prop in $biosProperties) {
	$createTableQuery += "$($prop.Name) TEXT(255), "
}
$createTableQuery = $createTableQuery.TrimEnd(", ") + ")"

# Kontrola, zda tabulka 'BiosInfo' existuje
if (-not (TableExists -tableName "BiosInfo" -databasePath $databasePath)) {
  # Tabulka neexistuje, vytvoříme ji
  ExecuteQuery -databasePath $databasePath -sqlQuery $createTableQuery
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

ExecuteQuery -databasePath $databasePath -sqlQuery $insertQuery
Write-Host "Data o bios byla úspěšně uložena do databáze."