# Nastavení cesty k dočasnému souboru
$tempFile = ".\secpol.cfg"

# Export lokálních bezpečnostních politik do dočasného souboru
& secedit /export /cfg $tempFile

# Čtení a zpracování exportovaného souboru
Get-Content $tempFile | ForEach-Object {
    Write-Host $_
}

# Odstranění dočasného souboru po zpracování
Remove-Item $tempFile