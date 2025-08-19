param(
  [string]$OutPath = "$env:TEMP\volumecheck.txt",
  [switch]$NoOpen
)

$sw = [System.Diagnostics.Stopwatch]::StartNew()

$volumes   = Get-Volume -ErrorAction SilentlyContinue
$logical   = Get-CimInstance Win32_LogicalDisk -ErrorAction SilentlyContinue
$dd        = Get-CimInstance Win32_DiskDrive -ErrorAction SilentlyContinue
$link1     = Get-CimInstance Win32_DiskDriveToDiskPartition -ErrorAction SilentlyContinue
$link2     = Get-CimInstance Win32_LogicalDiskToPartition -ErrorAction SilentlyContinue
$services  = Get-Service -ErrorAction SilentlyContinue
$procs     = Get-Process -ErrorAction SilentlyContinue

$susSvc = @(
  'imdisk','arimg','aim','arim','daemon','dtlite','dtagent','alcohol','poweriso',
  'isodrive','vclone','vcdmp','veracrypt','truecrypt','winCDEmu','psmount'
)
$susProc = @(
  'imdisk','imdsksvc','aimdsrv','daemon','dtlite','alcohol','poweriso','vcdmount',
  'veracrypt','truecrypt','isomounter','winCDEmu','arsenalmount','imgdrive'
)

function Map-DiskModel {
  param($driveLetter)
  $assoc = foreach($a in $link2) {
    if($a.Dependent -like "*$driveLetter*") { $a.Antecedent }
  }
  if(-not $assoc){ return $null }
  $part = ($assoc -replace '^.*DeviceID="','' -replace '".*$','')
  $diskId = foreach($b in $link1){ if($b.Dependent -like "*$part*"){ $b.Antecedent } }
  if(-not $diskId){ return $null }
  $pn = ($diskId -replace '^.*DeviceID="','' -replace '".*$','')
  $disk = $dd | Where-Object { $_.DeviceID -eq $pn }
  if($disk){ return ($disk.Model) } else { return $null }
}

function Classify-Volume {
  param($v)
  $l = ($v.DriveLetter)
  $ld = $logical | Where-Object { $_.DeviceID -eq "$l`:" }
  $model = $null
  if($l){ $model = Map-DiskModel "$l`:" }

  $icon  = "💾"
  $rank  = 0
  $why   = @()

  if($v.DriveType -eq 'CD-ROM' -or $v.FileSystem -in @('UDF','CDFS','ISO9660')){ $icon="⚠️"; $rank+=5; $why+="Optisches/virtuelles Laufwerk" }
  if($ld.ProviderName){ $icon="⚠️"; $rank+=4; $why+="Netzlaufwerk" }
  if($v.DriveType -in @('RAMDisk','Unknown')){ $icon="⚠️"; $rank+=5; $why+="Unbekannter/RAM-Datenträger" }
  if($model -match '(Virtual|VBOX|VMware|Msft Virtual|Microsoft Virtual|Image|ISO)'){ $icon="⚠️"; $rank+=4; $why+="Modell wirkt virtuell: $model" }
  if($v.FileSystem -eq 'exFAT' -and $v.Size -lt 8GB){ $icon="🧪"; $rank+=1; $why+="Kleiner exFAT-Datenträger" }
  if($v.HealthStatus -eq 'Unhealthy'){ $icon="⚠️"; $rank+=3; $why+="HealthStatus $($v.HealthStatus)" }
  if($v.DriveType -eq 'Removable'){ $icon="🧪"; $rank+=2; $why+="Wechseldatenträger" }

  $svcHit = $services | Where-Object { $susSvc -contains $_.Name.ToLower() -or ($susSvc | Where-Object { $_ -like "*$($_.Name.ToLower())*" }) }
  $prcHit = $procs    | Where-Object { $susProc -contains $_.ProcessName.ToLower() -or ($susProc | Where-Object { $_ -like "*$($_.ProcessName.ToLower())*" }) }
  if($svcHit -or $prcHit){ $icon="⚠️"; $rank+=3; $why+="Mount-/Emu-Tool aktiv" }

  $sizeGB = if($v.Size){ [math]::Round($v.Size/1GB,2) } else { $null }
  $freeGB = if($v.SizeRemaining){ [math]::Round($v.SizeRemaining/1GB,2) } else { $null }

  [pscustomobject]@{
    Rank=$rank
    Icon=$icon
    Letter=if($l){"$l:"}else{"-"}
    Label=$v.FileSystemLabel
    FS=$v.FileSystem
    Type=$v.DriveType
    SizeGB=$sizeGB
    FreeGB=$freeGB
    Model=$model
    Reason=($why -join '; ')
    PathHint=($ld.ProviderName)
  }
}

$items = @()
foreach($v in $volumes){ $items += Classify-Volume $v }

$items = $items | Sort-Object -Property @{Expression='Rank';Descending=$true}, Letter

$lines = @()
$lines += "==================== FiveM Volume Check ===================="
$lines += "Zeit: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$lines += "Host: $env:COMPUTERNAME  User: $env:USERNAME"
$lines += "Verdächtige zuerst. Emojis: ⚠️ sus | 🧪 auffällig | 💾 normal"
$lines += "-------------------------------------------------------------"

foreach($i in $items){
  $badge = if($i.Rank -ge 4){'SUS'} elseif($i.Rank -ge 1){'Auffällig'} else {'OK'}
  $lines += ("{0} [{1}] {2}  Label='{3}'  FS={4}  Type={5}  Size={6}GB  Free={7}GB  Model='{8}'{9}" -f `
    $i.Icon,$badge,$i.Letter,$i.Label,$i.FS,$i.Type,$i.SizeGB,$i.FreeGB,($i.Model -replace '\s+',' '), `
    ($(if($i.Reason){ "  => " + $i.Reason } else { "" })))
}

$lines += "-------------------------------------------------------------"
$lines += ("Services/Procs-Hinweis: {0}" -f ($(if(($services | Where-Object { $_.Status -eq 'Running' -and ($susSvc -contains $_.Name.ToLower() -or ($susSvc | Where-Object { $_ -like '*'+$_.Name.ToLower()+'*' })) }).Count -gt 0){"mögliche Mount-Software aktiv"}else{"keine eindeutigen Funde"})))
$lines += "Erstellt: $OutPath"
$lines += "============================================================="

$null = New-Item -Path $OutPath -ItemType File -Force
$lines -join [Environment]::NewLine | Out-File -FilePath $OutPath -Encoding UTF8

$sw.Stop()
Add-Content -Path $OutPath -Value ("Laufzeit: {0} ms" -f $sw.ElapsedMilliseconds)

if(-not $NoOpen){ Start-Process notepad.exe $OutPath }
