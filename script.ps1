do {
    # Textové rozhraní
    Write-Host "Stiskni 1 => Spustit vše - ! potreba admin pravo !"
    Write-Host "Stiskni 2 => WinAudit.exe - ulozit informace z WinAudit do databaze"
    Write-Host "Stiskni 3 => WinAudit.exe - porovnani dvou poslednich zaznamu auditu z databaze a rozdily ulozit do tabulky Rozdily"
    Write-Host "Stiskni 4 => WMIC - ulozit informace o BIOS do databaze"
    Write-Host "Stiskni 5 => WMIC - porovnani dvou poslednich zaznamu WMIC z databaze a rozdily ulozit do tabulky RozdilyWMIC"
    Write-Host "Stiskni 6 => Firewall rules - ulozit informace o Firewall rules do databaze"
    Write-Host "Stiskni 7 => Firewall rules - porovnani dvou poslednich zaznamu Firewall rules z databaze a rozdily ulozit do tabulky RozdilyFirewall"
    Write-Host "Stiskni 8 => Local Policies - ulozit informace o Local Policies do databaze - ! potreba admin pravo !"
    Write-Host "Stiskni 9 => Local Policies - porovnani dvou poslednich zaznamu Local Policies z databaze a rozdily ulozit do tabulky RozdilyPolicies"
    Write-Host "Stiskni 0 => Ukonci program"

    $userInput = Read-Host "Zadejte číslo akce"

    switch ($userInput) {
        '1' {
            Write-Host "Probíhá komplet spuštění"
            $actions = @(
                { & ".\createWinAuditDB.ps1" },
                { & ".\compareWinAuditDB.ps1" },
                { & ".\createBiosDB.ps1" },
                { & ".\compareBiosDB.ps1" },
                { & ".\createFirewallRulesDB.ps1" },
                { & ".\compareFirewallRulesDB.ps1" },
                { & ".\createLocalPoliciesDB.ps1" },
                { & ".\compareLocalPoliciesDB.ps1" }
            )

            $actionDescriptions = @(
                "WinAudit.exe - ukládání informací do databáze",
                "WinAudit.exe - porovnání a ukládání rozdílů",
                "WMIC - ukládání informací do databáze",
                "WMIC - porovnání a ukládání rozdílů",
                "Firewall rules - ukládání informací do databáze",
                "Firewall rules - porovnání a ukládání rozdílů",
                "Local Policies - ukládání informací do databáze",
                "Local Policies - porovnání a ukládání rozdílů"
            )

            for ($i = 0; $i -lt $actions.Count; $i++) {
                Write-Progress -Activity "Spouštění skriptů" -Status $actionDescriptions[$i] -PercentComplete (($i / $actions.Count) * 100)
                $actions[$i].Invoke()
            }
            Write-Progress -Activity "Spouštění skriptů" -Status "Dokončeno" -Completed
            break
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
            & ".\createFirewallRulesDB.ps1"
        }
        '7' {
            Write-Host "Probíhá akce 7"
            & ".\compareFirewallRulesDB.ps1"
        }
        '8' {
            Write-Host "Probíhá akce 8"
            & ".\createLocalPoliciesDB.ps1"
        }
        '9' {
            Write-Host "Probíhá akce 9"
            & ".\compareLocalPoliciesDB.ps1"
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