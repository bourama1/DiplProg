# Textové rozhraní
Write-Host "Stiskni 1 => WinAudit.exe ulozit do html a porovnat (Python)"
Write-Host "Stiskni 2 => WinAudit.exe porovnat databaze a rozdily ulozit do tabulky Rozdily"
Write-Host "Stiskni 3 => WMIC"
Write-Host "Stiskni 4 => firewall rules"
Write-Host "Stiskni 0 => Ukonci program"

# Čtení vstupu od uživatele
$userInput = Read-Host "Zadejte číslo akce"

# Zpracování vstupu
switch ($userInput) {
    '1' {
        Write-Host "Probíhá akce 1"
        & ".\winAuditHTML.ps1"
    }
    '2' {
        Write-Host "Probíhá akce 2"
        & ".\winAuditDB.ps1"
    }
    '3' {
        Write-Host "Probíhá akce 3"
        & ".\bios.ps1"
    }
    '4' {
        Write-Host "Probíhá akce 4"
        & ".\firewallRules.ps1"
    }
    '0' {
        Write-Host "Ukončuji program"
        break
    }
    default {
        Write-Host "Neplatná volba, zadejte platné číslo akce."
    }
}
