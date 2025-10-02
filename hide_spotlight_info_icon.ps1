# hide_spotlight_info_icon.ps1
# Purpose: Hide the Windows Spotlight "Learn about this picture" desktop icon while keeping Spotlight wallpaper.
# Mechanism: Set the CLSID entry to 1 under:
#   HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\{NewStartPanel,ClassicStartMenu}
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\hide_spotlight_info_icon.ps1
# Effect: Usually immediate; if still visible, refresh desktop or later restart Explorer / log off (script does NOT auto-restart Explorer).
$clsid = '{2cc5ca98-6485-489a-920e-b3e88a6ccce3}'
$basePath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons'
$keys = @('NewStartPanel', 'ClassicStartMenu')
foreach ($k in $keys) {
  $full = Join-Path $basePath $k
  if (-not (Test-Path $full)) { New-Item -Path $full -Force | Out-Null }
  New-ItemProperty -Path $full -Name $clsid -Value 1 -PropertyType DWord -Force | Out-Null
}
Write-Host 'Spotlight info desktop icon hidden (registry applied).'