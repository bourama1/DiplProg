Function Get-FileName($initialDirectory)
{  
 [System.Reflection.Assembly]::LoadWithPartialName(“System.windows.forms”) |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "Database files (*.mdb*)| *.mdb*"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} #end function Get-FileName

# Start-Process -FilePath ".\WinAudit.exe" -ArgumentList "/r=gsoPxuTUeERNtnzDaIbMpmidcSArCOHG", "/f=DBQ=D:\Documents\DiplProg\Template1.mdb;Driver={Microsoft Access Driver (*.mdb)};" -Wait

# Start-Process "C:\Program Files\Microsoft Office\root\Client\AppVLP.exe" "C:\Program Files (x86)\Microsoft Office\Office16\DCF\DATABASECOMPARE.EXE"

### File compare
Write-Host "Zadej soubor pro porovnani:"
$databaze1Path = Get-FileName("D:\Documents\DiplProg")
$databaze2Path = Get-FileName("D:\Documents\DiplProg")

# SQL dotaz pro vybrání dat z tabulky
$sqlQuery = "SELECT * FROM Audit_Data"

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

# Vykonání dotazu pro obě databáze
$data1 = ExecuteQuery -databasePath $databaze1Path -sqlQuery $sqlQuery
$data2 = ExecuteQuery -databasePath $databaze2Path -sqlQuery $sqlQuery

# Porovnání dat
$differences = Compare-Object $data1 $data2 # -Property Column1, Column2, ... # Specifikuj sloupce, které chceš porovnat

# Vypsání rozdílů
if ($differences) {
    Write-Host "Nalezeny rozdíly mezi databázemi:"
    $differences | ForEach-Object {
        $message = if ($_.SideIndicator -eq "<=") {
            "Databáze 1 obsahuje: $_"
        } else {
            "Databáze 2 obsahuje: $_"
        }
        Write-Host $message
    }
} else {
    Write-Host "Databáze jsou identické."
}
