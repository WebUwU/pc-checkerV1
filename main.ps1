
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

function Show-Menu {
    Clear-Host
    Write-Host "====== PC Checker Menü ======" -ForegroundColor Cyan
    Write-Host "1. VolumeChecker von GitHub laden & ausführen"
    Write-Host "2. VPNChecker von GitHub laden & ausführen"
    Write-Host "3. (Platzhalter)"
    Write-Host "4. (Platzhalter)"
    Write-Host "5. (Platzhalter)"
    Write-Host "6. (Platzhalter)"
    Write-Host "7. (Platzhalter)"
    Write-Host "8. (Platzhalter)"
    Write-Host "9. (Platzhalter)"
    Write-Host "0. Beenden"
}

do {
    Show-Menu
    $choice = Read-Host "`nBitte eine Option wählen (0-9)"

    switch ($choice) {
        "1" {
            Clear-Host
            Write-Host ">> Lade VolumeChecker.ps1 von GitHub..." -ForegroundColor Yellow
            $tempPath = "$env:TEMP\VolumeChecker.ps1"
            Invoke-WebRequest -Uri "https://raw.githubusercontent.com/WebUwU/pc-checkerV1/main/VolumeChecker.ps1" -OutFile $tempPath
            if (Test-Path $tempPath) {
                Write-Host ">> Ausführen..." -ForegroundColor Cyan
                & $tempPath
            } else {
                Write-Host "Fehler: VolumeChecker konnte nicht geladen werden!" -ForegroundColor Red
            }
            Read-Host "`nDrücke ENTER, um zurück zum Menü zu kehren" > $null
        }

        "2" {
            Clear-Host
            Write-Host ">> Lade VPNChecker.ps1..." -ForegroundColor Yellow
            $vpnPath = "$env:TEMP\VPNChecker.ps1"
            Invoke-WebRequest -Uri "https://raw.githubusercontent.com/WebUwU/pc-checkerV1/main/VPNChecker.ps1" -OutFile $vpnPath

            Write-Host ">> Lade vpn_patterns.txt..." -ForegroundColor Yellow
            $patternPath = "$env:TEMP\vpn_patterns.txt"
            Invoke-WebRequest -Uri "https://raw.githubusercontent.com/WebUwU/pc-checkerV1/main/vpn_patterns.txt" -OutFile $patternPath

            if ((Test-Path $vpnPath) -and (Test-Path $patternPath)) {
                Write-Host ">> Starte VPNChecker..." -ForegroundColor Cyan
                & $vpnPath
            } else {
                Write-Host "❌ Fehler beim Laden von VPNChecker oder der Pattern-Datei." -ForegroundColor Red
            }
            Read-Host "`nDrücke ENTER, um zurück zum Menü zu kehren" > $null
        }

        "0" {
            Write-Host "`nProgramm wird beendet..." -ForegroundColor Green
        }

        default {
            Write-Host "`nUngültige Eingabe. Bitte erneut versuchen." -ForegroundColor Red
            Start-Sleep -Seconds 1.5
        }
    }
} while ($choice -ne "0")
