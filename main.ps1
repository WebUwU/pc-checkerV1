
function Show-Menu {
    Clear-Host
    Write-Host "====== PC Checker Menü ======" -ForegroundColor Cyan
    Write-Host "1. VolumeChecker ausführen"
    Write-Host "2. (Platzhalter)"
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
            Write-Host ">> VolumeChecker wird gestartet..." -ForegroundColor Yellow
            $volumeCheckerPath = "$PSScriptRoot\VolumeChecker.ps1"
            if (Test-Path $volumeCheckerPath) {
                & $volumeCheckerPath
            } else {
                Write-Host "VolumeChecker.ps1 nicht gefunden!" -ForegroundColor Red
            }
            do {
                $returnKey = Read-Host "`nDrücke 0, um zurück zum Menü zu kehren"
            } while ($returnKey -ne "0")
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
