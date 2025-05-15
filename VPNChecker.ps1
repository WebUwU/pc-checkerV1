
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "===== VPN Checker gestartet =====" -ForegroundColor Cyan

# Pfad zur VPN-Liste (muss im gleichen Ordner liegen)
$vpnListPath = "$PSScriptRoot\vpn_patterns.txt"
if (!(Test-Path $vpnListPath)) {
    Write-Host "Fehler: vpn_patterns.txt nicht gefunden!" -ForegroundColor Red
    return
}

$vpnPatterns = Get-Content $vpnListPath
$vpnFound = $false

# Netzwerkanalyse
Write-Host "`n🔍 Scanne Netzwerkadapter auf bekannte VPN-Signaturen..." -ForegroundColor Yellow
Get-NetAdapter | ForEach-Object {
    $adapterInfo = $_.Name + " " + $_.InterfaceDescription
    foreach ($pattern in $vpnPatterns) {
        if ($adapterInfo -match $pattern) {
            Write-Host ("VPN-Verdacht: {0} (Treffer: {1})" -f $adapterInfo, $pattern) -ForegroundColor Magenta
            $vpnFound = $true
        }
    }
}

if (-not $vpnFound) {
    Write-Host "✅ Keine bekannten VPN-Adapternamen gefunden." -ForegroundColor Green
}

# Öffentliche IP abrufen
Write-Host "`n🌐 Ermittele öffentliche IP-Adresse..." -ForegroundColor Yellow
try {
    $publicIP = Invoke-RestMethod -Uri "https://api.ipify.org"
    Write-Host ("🌍 Öffentliche IP-Adresse: {0}" -f $publicIP) -ForegroundColor Cyan
} catch {
    Write-Host "❌ Fehler beim Abrufen der öffentlichen IP." -ForegroundColor Red
}

Write-Host "`n===== VPN Checker abgeschlossen =====" -ForegroundColor Green
