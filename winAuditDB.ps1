Function Get-FileName($initialDirectory)
{  
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "Database files (*.mdb*)| *.mdb*"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} #end function Get-FileName

### Create WinAudit Report
# Start-Process -FilePath ".\WinAudit.exe" -ArgumentList "/r=gsoPxuTUeERNtnzDaIbMpmidcSArCOHG", "/f=DBQ=D:\Documents\DiplProg\Template2.mdb;Driver={Microsoft Access Driver (*.mdb)};" -Wait

### File compare
Write-Host "Zadej soubory pro porovnani:"
$databazePath = Get-FileName("D:\Documents\DiplProg")

# Funkce pro provedení dotazu na databázi
function ExecuteQuery ($databasePath, $sqlQuery) {
    $connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$databasePath"
    $connection = New-Object System.Data.OleDb.OleDbConnection($connectionString)
    $command = $connection.CreateCommand()
    $command.CommandText = $sqlQuery

    $adapter = New-Object System.Data.OleDb.OleDbDataAdapter($command)
    $dataset = New-Object System.Data.DataSet

    $connection.Open()
    $adapter.Fill($dataset) | Out-Null
    $connection.Close()

    return $dataset.Tables[0]
}

# SQL dotaz pro vybrání dat z tabulky
$sqlQuery1 = @"
SELECT * FROM Audit_Data
WHERE Audit_ID = 7
"@

$sqlQuery2 = @"
SELECT * FROM Audit_Data
WHERE Audit_ID = 8
"@

# Vykonání dotazu pro obě databáze
$data1 = ExecuteQuery -databasePath $databazePath -sqlQuery $sqlQuery1
$data2 = ExecuteQuery -databasePath $databazePath -sqlQuery $sqlQuery2

# Porovnání dat
$differences = Compare-Object $data1 $data2 -Property Category_ID, Item_1 # Specifikuj sloupce, které chceš porovnat

# Vytvoření tabulky v nové databázi pro uložení rozdílů
$createTableScript = @"
CREATE TABLE Rozdily (
    ID AUTOINCREMENT PRIMARY KEY,
    Category_ID INT,
    Column1 VARCHAR(255)
);
"@
ExecuteQuery -databasePath $databazePath -sqlQuery $createTableScript

# Uložení rozdílů do nové databáze
foreach ($difference in $differences) {
    $insertScript = @"
INSERT INTO Rozdily (Category_ID, Column1)
VALUES ('$($difference.Category_ID)', '$($difference.Item_1)');
"@
    
    ExecuteQuery -databasePath $databazePath -sqlQuery $insertScript
}

Write-Host "Rozdíly byly úspěšně uloženy do nové databáze."