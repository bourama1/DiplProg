do {
    # Textové rozhraní
    Write-Host "Stiskni 1 => WinAudit.exe - ulozit do html a porovnat (Python)"
    Write-Host "Stiskni 2 => WinAudit.exe - ulozit databaze"
    Write-Host "Stiskni 3 => WinAudit.exe - porovnani dvou poslednich zaznamu auditu z databaze a rozdily ulozit do tabulky Rozdily"
    Write-Host "Stiskni 4 => WMIC - ulozit informace o BIOS do databaze"
    Write-Host "Stiskni 5 => WMIC - porovnani dvou poslednich zaznamu WMIC z databaze a rozdily ulozit do tabulky RozdilyWMIC"
    Write-Host "Stiskni 6 => firewall rules"
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
            & ".\createWinAuditDB.ps1"
        }
        '3' {
            Write-Host "Probíhá akce 3"
            & ".\compareWinAuditDB.ps1"
        }
        '4' {
            Write-Host "Probíhá akce 4"
            & ".\createBiosDB.ps1"
        }
        '5' {
            Write-Host "Probíhá akce 5"
            & ".\compareBiosDB.ps1"
        }
        '6' {
            Write-Host "Probíhá akce 6"
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
} while ($userInput -ne '0')