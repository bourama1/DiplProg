param(
  [string]$databasePath = $null
)

# Načtení souboru s funkcemi
. .\functions.ps1

if (-not $databasePath) {
  Write-Host "Vyberte databázi:"
  $databasePath = GetFileName("D:\Documents\DiplProg")
}

# Vytvoření WinAudit Reportu
Start-Process -FilePath ".\WinAudit.exe" -ArgumentList "/r=gsoPxuTUeERNtnzDaIbMpmidcSArCOHG", "/f=DBQ=$databasePath;Driver={Microsoft Access Driver (*.mdb)};" -Wait

Write-Host "Data z WinAudit byla úspěšně uložena do databáze."