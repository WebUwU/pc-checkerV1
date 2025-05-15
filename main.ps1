
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

function Show-Menu {
    Clear-Host
    Write-Host "====== PC Checker Menü ======" -ForegroundColor Cyan
    Write-Host "1. VolumeChecker aus GitHub laden & ausführen"
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
    $choice = Read-Host "`nBitte eine Option wähleń (0-9)"

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
