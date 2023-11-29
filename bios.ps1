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
    Write-Host "$($property.Name): $($property.Value)"
}

# Save the output to a file
$outputString | Out-File -FilePath $outputFileName

Write-Host "Output saved to $outputFileName"