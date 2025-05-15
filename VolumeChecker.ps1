
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
    Select-Object TimeCreated, Id, Message |
    Sort-Object TimeCreated -Descending

# Export als CSV
$volumeEvents | Export-Csv -Path $exportPath -NoTypeInformation -Encoding UTF8

# Speichern als Log-Datei (Text)
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
