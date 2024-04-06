<#
.SYNOPSIS
    Function to get the path to a file.
.DESCRIPTION
    This function opens a file dialog to allow the user to select a file and returns the path of the selected file.
.PARAMETER initialDirectory
    The directory where the file dialog should be opened.
.OUTPUTS
    System.String
    Returns the path of the selected file as a string.
#>
function GetFileName($initialDirectory)
{
    # Load the System.Windows.Forms assembly
    Add-Type -AssemblyName System.Windows.Forms

    # Create a new instance of the OpenFileDialog class
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog

    # Set the initial directory of the file dialog
    $openFileDialog.InitialDirectory = $initialDirectory

    # Set the filter of the file dialog to only show database files with the extension .mdb
    $openFileDialog.Filter = "Database files (*.mdb*)| *.mdb*"

    # Show the file dialog and wait for the user to select a file
    $dialogResult = $openFileDialog.ShowDialog()

    # If the user selected a file, return the path of the selected file
    if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK)
    {
        return $openFileDialog.FileName
    }
    else
    {
        return $null
    }
}

<#
.SYNOPSIS
    Executes a SQL query on a specified database.
.DESCRIPTION
    This function executes a SQL query on the provided database using the given database path and SQL query.
.PARAMETER databasePath
    The path to the database where the query should be executed.
.PARAMETER sqlQuery
    The SQL query to be executed on the database.
.OUTPUTS
    System.Data.DataTable
    Returns the result of the query as a DataTable object.
.EXAMPLE
    ExecuteQuery -databasePath "C:\Data\Database.mdb" -sqlQuery "SELECT * FROM Customers"
    This example executes the SQL query "SELECT * FROM Customers" on the database located at "C:\Data\Database.mdb" and returns the result as a DataTable object.
#>
function ExecuteQuery ($databasePath, $sqlQuery) {
    $connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$databasePath"
    $connection = [System.Data.OleDb.OleDbConnection]::new($connectionString)
    $command = $connection.CreateCommand()
    $command.CommandText = $sqlQuery

    $adapter = [System.Data.OleDb.OleDbDataAdapter]::new($command)
    $dataset = [System.Data.DataSet]::new()

    $connection.Open()
    $adapter.Fill($dataset) | Out-Null
    $connection.Close()

    return $dataset.Tables[0]
}

<#
.SYNOPSIS
    Checks if a table exists in a database.
.DESCRIPTION
    This function checks if a table with the specified name exists in the provided database.
.PARAMETER tableName
    The name of the table to check for existence.
.PARAMETER databasePath
    The path to the database where the table should be checked.
.OUTPUTS
    System.Boolean
    Returns $true if the table exists, otherwise returns $false.
.EXAMPLE
    TableExists -tableName "Customers" -databasePath "C:\Data\Database.mdb"
    This example checks if the table named "Customers" exists in the database located at "C:\Data\Database.mdb".
#>
function TableExists($tableName, $databasePath) {
    $connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$databasePath"
    $connection = New-Object System.Data.OleDb.OleDbConnection($connectionString)
    $connection.Open()

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

<#
.SYNOPSIS
    Drops a table from a database.
.DESCRIPTION
    This function drops a table from a specified database using the provided table name and database path.
.PARAMETER tableName
    The name of the table to be dropped.
.PARAMETER databasePath
    The path to the database where the table exists.
.EXAMPLE
    DropTable -tableName "Customers" -databasePath "C:\Data\Database.mdb"
    This example drops the table named "Customers" from the database located at "C:\Data\Database.mdb".
#>
function DropTable($tableName, $databasePath) {
    $sqlQuery = "DROP TABLE [$tableName];"
    ExecuteQuery -databasePath $databasePath -sqlQuery $sqlQuery
}

<#
.SYNOPSIS
    Retrieves the column names of a table in a database.
.DESCRIPTION
    This function connects to a database using the provided database path and retrieves the column names of a specified table. It uses the OleDbSchemaTable to get the schema of the table and then extracts the column names from it.
.PARAMETER databasePath
    The path to the database where the table exists.
.PARAMETER tableName
    The name of the table for which the column names should be retrieved.
.OUTPUTS
    System.String[]
    Returns an array of column names as strings.
.EXAMPLE
    GetTableColumns -databasePath "C:\Data\Database.mdb" -tableName "Customers"
    This example retrieves the column names of the table "Customers" in the database located at "C:\Data\Database.mdb" and returns them as an array of strings.
#>
function GetTableColumns {
    param(
        [string]$databasePath,
        [string]$tableName
    )

    # Inicializace seznamu sloupců
    $columns = @()

    # Definice připojovacího řetězce
    $connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$databasePath"

    # Vytvoření připojení
    $connection = New-Object -TypeName System.Data.OleDb.OleDbConnection -ArgumentList $connectionString
    try {
        $connection.Open()

        # Získání schema tabulky
        $tableSchema = $connection.GetOleDbSchemaTable([System.Data.OleDb.OleDbSchemaGuid]::Columns, ($null, $null, $tableName, $null))

        # Procházení schema a sběr názvů sloupců
        $tableSchema | ForEach-Object {
            $columns += $_["COLUMN_NAME"]
        }
    }
    catch {
        Write-Error "Nelze se připojit k databázi nebo získat schema tabulky: $_"
    }
    finally {
        $connection.Close()
    }

    return $columns
}