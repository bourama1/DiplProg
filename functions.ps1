<#
 # .SYNOPSIS
 # Funkce pro získání cesty k souboru
 # 
 # .PARAMETER initialDirectory
 # Adresar kde se uzivateli otevre explorer
#>
function GetFileName($initialDirectory)
{  
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "Database files (*.mdb*)| *.mdb*"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
}

<#
 # .SYNOPSIS
 # Funkce pro provedení dotazu na databázi
 # 
 # .PARAMETER databasePath
 # Cesta k databazi kde se dotaz spusti
 #
 # .PARAMETER sqlQuery
 # Sql dotaz k spusteni:Enter a comment or description
#>
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

# Funkce pro zjištění existence tabulky
function TableExists($tableName, $databasePath) {
    $connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$databasePath"
    $connection = New-Object System.Data.OleDb.OleDbConnection($connectionString)
    $connection.Open()

    $tableExists = $false
    try {
        $command = $connection.CreateCommand()
        $command.CommandText = "SELECT TOP 1 * FROM [$tableName];"
        $reader = $command.ExecuteReader()
        $reader.Close()
        $tableExists = $true
    } catch {
        $tableExists = $false
    } finally {
        $connection.Close()
    }

    return $tableExists
}

# Funkce pro smazání tabulky
function DropTable($tableName, $databasePath) {
    $sqlQuery = "DROP TABLE [$tableName];"
    ExecuteQuery -databasePath $databasePath -sqlQuery $sqlQuery
}