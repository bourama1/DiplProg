Function Get-FileName($initialDirectory)
{  
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "Text files (*.txt*)| *.txt*"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} #end function Get-FileName

# Get BIOS information using Get-CimInstance
$bios = Get-CimInstance -ClassName Win32_BIOS

# Get the current date and time in a specific format
$currentDateTime = Get-Date -Format "yyyyMMdd-HHmmss"

# Construct the output file name with the datetime
$outputFileName = "BIOS-$currentDateTime.txt"

# Create a string to store the output
$outputString = "BIOS Information:`n-----------------`n"

foreach ($property in $bios.PSObject.Properties) {
    $outputString += "$($property.Name): $($property.Value)`n"
}

# Save the output to a file
$outputString | Out-File -FilePath $outputFileName

Write-Host "Output saved to $outputFileName"

### File compare
Write-Host "Zadej soubor pro porovnani:"
$firstFilePath = Get-FileName("D:\Documents\DiplProg")

# Kontrola, zda uživatel vybral soubory
if ($firstFilePath) {
    # Načtení obsahu souborů
    $firstFileContent = Get-Content -Path $firstFilePath
    $secondFileContent = Get-Content -Path $outputFileName

    # Porovnání obsahu souborů
    $differences = Compare-Object $firstFileContent $secondFileContent

    # Výpis rozdílů
    if ($differences) {
        Write-Host "Nalezeny rozdíly mezi soubory:"
        $differences | ForEach-Object {
            $message = if ($_.SideIndicator -eq "<=") {
                "První soubor obsahuje: $_"
            } else {
                "Druhý soubor obsahuje: $_"
            }
            Write-Host $message
        }
    } else {
        Write-Host "Soubory jsou identické."
    }
} else {
    Write-Host "Výběr souborů byl zrušen."
}