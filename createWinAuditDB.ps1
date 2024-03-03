# Načtení souboru s funkcemi
. .\functions.ps1

# Získání cílové databáze pro WinAudit report
Write-Host "Vyberte databázi pro WinAudit report:"
$databasePath = GetFileName("D:\Documents\DiplProg")

# Vytvoření WinAudit Reportu
Write-Host "Probíhá proces"
Start-Process -FilePath ".\WinAudit.exe" -ArgumentList "/r=gsoPxuTUeERNtnzDaIbMpmidcSArCOHG", "/f=DBQ=$databasePath;Driver={Microsoft Access Driver (*.mdb)};" -Wait
Write-Host "Audit vytvoren"