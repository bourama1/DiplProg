# Get BIOS information using Get-CimInstance
$bios = Get-CimInstance -ClassName Win32_BIOS
$jsonFilePath = "bios.json"
$bios | ConvertTo-Json | Out-File -FilePath $jsonFilePath

# Compare
python .\compareJSON.py