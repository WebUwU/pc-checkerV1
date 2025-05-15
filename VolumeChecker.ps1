
# VolumeChecker.ps1
$ErrorActionPreference = "SilentlyContinue"

# Pfade
$logPath = "$env:TEMP\VolumeID_Check_Log.txt"
$exportPath = "$env:TEMP\VolumeID_Events.csv"
$regExportPath = "$env:TEMP\MountedDevices_Backup.reg"

# Aktuelle Zeit
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $logPath -Value "`n==== Scan: $timestamp ===="

# EventLog Check: Volume-bezogene Ereignisse filtern
$volumeEvents = Get-WinEvent -LogName System |
    Where-Object { $_.Message -like "*\Device\HarddiskVolume*" -or $_.Message -like "*\\?\Volume{*" } |
    Sort-Object TimeCreated -Descending

# Export alle Events
$volumeEvents | Export-Csv -Path $exportPath -NoTypeInformation -Encoding UTF8

# Ausgabe der letzten 5 relevanten Events (für Cheater-Check)
$lastChanges = $volumeEvents | Where-Object { $_.Id -eq 98 -or $_.Id -eq 16 } | Select-Object -First 5

Add-Content -Path $logPath -Value "`nLetzte 5 Volume-/Partition-Änderungen (möglicherweise Spoofing/Cheat):"
foreach ($e in $lastChanges) {
    $entry = "[" + $e.TimeCreated + "] ID " + $e.Id + "`n" + $e.Message + "`n"
    Add-Content -Path $logPath -Value $entry
    Write-Host $entry -ForegroundColor Yellow
}

# Alle Events zusätzlich ins Log
Add-Content -Path $logPath -Value "`nAlle Volume-bezogenen Events:"
$volumeEvents | ForEach-Object {
    Add-Content -Path $logPath -Value ("[" + $_.TimeCreated + "] ID " + $_.Id + "`n" + $_.Message + "`n")
}

# MountedDevices Registry Key sichern
reg export "HKLM\SYSTEM\MountedDevices" $regExportPath /y | Out-Null
Add-Content -Path $logPath -Value "`nMountedDevices Registry Backup gespeichert unter:`n$regExportPath"

# Fertigmeldung
Add-Content -Path $logPath -Value "`n=== Scan abgeschlossen ===`n"
Write-Host "`n✅ VolumeChecker fertig. Ergebnis gespeichert unter:`n$logPath"
Write-Host "CSV-Export: $exportPath"
Write-Host "Registry-Backup: $regExportPath`n"
