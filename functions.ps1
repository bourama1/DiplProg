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

<#
.SYNOPSIS
    Generates a new Audit_ID for insertion into a specified table in a database.
.DESCRIPTION
    This function generates a new Audit_ID for insertion into a specified table in a database. It retrieves the maximum Audit_ID value from the table, increments it by 1, and returns the new Audit_ID.
.PARAMETER databasePath
    The path to the database where the table exists.
.PARAMETER tableName
    The name of the table where the new Audit_ID will be inserted.
.OUTPUTS
    System.Int32
    Returns the new Audit_ID as an integer.
.EXAMPLE
    Get-NewAuditId -databasePath "C:\Data\Database.mdb" -tableName "AuditTable"
    This example generates a new Audit_ID for insertion into the table "AuditTable" in the database located at "C:\Data\Database.mdb" and returns the new Audit_ID as an integer.
#>
function Get-NewAuditId {
    param(
        [string]$databasePath,
        [string]$tableName
    )

    # Sestavení SQL dotazu pro načtení maximální hodnoty Audit_ID z dané tabulky
    $maxAuditIdQuery = "SELECT MAX(Audit_ID) FROM $tableName"
    $maxAuditIdResult = ExecuteQuery -databasePath $databasePath -sqlQuery $maxAuditIdQuery

    if ($null -ne $maxAuditIdResult -and -not ($maxAuditIdResult[0] -eq [System.DBNull]::Value)) {
        $maxAuditId = [int]$maxAuditIdResult[0]
    } else {
        $maxAuditId = 0
    }

    # Inkrementace Audit_ID pro nové vložení
    $newAuditId = $maxAuditId + 1

    return $newAuditId
}

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

<#
.SYNOPSIS
    Aggregates the grouped differences into a single result.
.DESCRIPTION
    This function takes a collection of grouped differences and aggregates them into a single result. It creates a new PSObject for each group and adds the necessary properties to it. It also filters and aggregates unique values for each item in the group.
.PARAMETER groupedDifferences
    The collection of grouped differences to be aggregated.
.OUTPUTS
    System.Collections.ObjectModel.Collection[psobject]
    Returns a collection of aggregated differences as PSObjects.
#>
function AggregateDifferences {
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.ObjectModel.Collection[psobject]]$groupedDifferences
    )

    $aggregatedDifferences = @()

    foreach ($group in $groupedDifferences) {
        $aggregatedRow = New-Object PSObject
        Add-Member -InputObject $aggregatedRow -MemberType NoteProperty -Name Audit_ID -Value ($group.Group | Select-Object -First 1).Audit_ID
        Add-Member -InputObject $aggregatedRow -MemberType NoteProperty -Name Record_Ordinal -Value ($group.Group | Select-Object -First 1).Record_Ordinal
        Add-Member -InputObject $aggregatedRow -MemberType NoteProperty -Name Computer_ID -Value ($group.Group | Select-Object -First 1).Computer_ID
        Add-Member -InputObject $aggregatedRow -MemberType NoteProperty -Name Category_ID -Value ($group.Group | Select-Object -First 1).Category_ID

        for ($i = 1; $i -le 50; $i++) {
            # Filtrace a agregace unikátních hodnot
            $itemValues = $group.Group | ForEach-Object { $_.("Item_$i") } | Where-Object { $_ -ne $null } | Sort-Object -Unique
            $uniqueItemValues = $itemValues -join "; "
            Add-Member -InputObject $aggregatedRow -MemberType NoteProperty -Name ("Item_$i") -Value $uniqueItemValues
        }

        $aggregatedDifferences += $aggregatedRow
    }

    return $aggregatedDifferences
}