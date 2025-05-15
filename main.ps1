
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

function Show-Menu {
    Clear-Host
    Write-Host "====== PC Checker Menü ======" -ForegroundColor Cyan
    Write-Host "1. VolumeChecker von GitHub laden & ausführen"
    Write-Host "2. VPNChecker von GitHub laden & ausführen"
    Write-Host "3. (Platzhalter)"
    Write-Host "0. Beenden"
}

do {
    Show-Menu
    $choice = Read-Host "`nBitte eine Option wählen (0-9)"

    switch ($choice) {
        "1" {
            Clear-Host
            Write-Host ">> Lade VolumeChecker.ps1 von GitHub..." -ForegroundColor Yellow
            $volumeUrl = "https://raw.githubusercontent.com/WebUwU/pc-checkerV1/main/VolumeChecker.ps1"
            $volumePath = "$env:TEMP\VolumeChecker.ps1"
            Invoke-RestMethod -Uri $volumeUrl | Out-File -FilePath $volumePath -Encoding utf8
            if (Test-Path $volumePath) {
                Write-Host ">> Ausführen..." -ForegroundColor Cyan
                & $volumePath
            } else {
                Write-Host "Fehler: VolumeChecker konnte nicht geladen werden!" -ForegroundColor Red
            }
            Read-Host "`nDrücke ENTER, um zurück zum Menü zu kehren" > $null
        }

        "2" {
            Clear-Host
            Write-Host ">> Lade VPNChecker.ps1 und vpn_patterns.txt von GitHub..." -ForegroundColor Yellow
            $vpnUrl = "https://raw.githubusercontent.com/WebUwU/pc-checkerV1/main/VPNChecker.ps1"
            $patternUrl = "https://raw.githubusercontent.com/WebUwU/pc-checkerV1/main/vpn_patterns.txt"
            $vpnPath = "$env:TEMP\VPNChecker.ps1"
            $patternPath = "$env:TEMP\vpn_patterns.txt"
            Invoke-RestMethod -Uri $vpnUrl | Out-File -FilePath $vpnPath -Encoding utf8
            Invoke-RestMethod -Uri $patternUrl | Out-File -FilePath $patternPath -Encoding utf8
            if ((Test-Path $vpnPath) -and (Test-Path $patternPath)) {
                Write-Host ">> Starte VPNChecker..." -ForegroundColor Cyan
                & $vpnPath
            } else {
                Write-Host "Fehler: Eine Datei konnte nicht geladen werden." -ForegroundColor Red
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
