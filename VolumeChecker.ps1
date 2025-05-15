
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# VolumeChecker.ps1 (with full console output)
$ErrorActionPreference = "SilentlyContinue"

# Pfade
$logPath = "$env:TEMP\VolumeID_Check_Log.txt"
$exportPath = "$env:TEMP\VolumeID_Events.csv"
$regExportPath = "$env:TEMP\MountedDevices_Backup.reg"

# Aktuelle Zeit
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "`n==== VolumeChecker Scan: $timestamp ====" -ForegroundColor Cyan
Add-Content -Path $logPath -Value "`n==== Scan: $timestamp ===="

# EventLog Check: Volume-bezogene Ereignisse filtern
$volumeEvents = Get-WinEvent -LogName System |
    Where-Object { $_.Message -like "*\Device\HarddiskVolume*" -or $_.Message -like "*\\?\Volume{*" } |
    Sort-Object TimeCreated -Descending

# Export alle Events
$volumeEvents | Export-Csv -Path $exportPath -NoTypeInformation -Encoding UTF8

# Ausgabe der letzten 5 relevanten Events
$lastChanges = $volumeEvents | Where-Object { $_.Id -eq 98 -or $_.Id -eq 16 } | Select-Object -First 5

Write-Host "`nLetzte 5 Volume-/Partition-Änderungen (möglicherweise Spoofing/Cheat):" -ForegroundColor Yellow
Add-Content -Path $logPath -Value "`nLetzte 5 Volume-/Partition-Änderungen (möglicherweise Spoofing/Cheat):"

foreach ($e in $lastChanges) {
    $entry = "[" + $e.TimeCreated + "] ID " + $e.Id + "`n" + $e.Message + "`n"
    Write-Host $entry -ForegroundColor White
    Add-Content -Path $logPath -Value $entry
}

# MountedDevices Registry Key sichern
reg export "HKLM\SYSTEM\MountedDevices" $regExportPath /y | Out-Null
Write-Host "`nRegistry-Backup gespeichert unter: $regExportPath" -ForegroundColor Cyan
Add-Content -Path $logPath -Value "`nMountedDevices Registry Backup gespeichert unter:`n$regExportPath"

# Abschlussmeldung
Write-Host "`nCSV-Export gespeichert unter: $exportPath" -ForegroundColor Cyan
Write-Host "`nLog-Datei gespeichert unter: $logPath" -ForegroundColor Cyan
Write-Host "`n=== Scan abgeschlossen ===`n" -ForegroundColor Green
Add-Content -Path $logPath -Value "`n=== Scan abgeschlossen ===`n"
