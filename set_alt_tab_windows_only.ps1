# set_alt_tab_windows_only.ps1
# Purpose: Force Alt+Tab to show "Open windows only" (hide Edge / app tabs).
# Equivalent UI path: Settings > System > Multitasking > Alt + Tab.
# Registry:
#   Key  : HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
#   Name : MultiTaskingAltTabFilter (DWORD)
#   Values:
#     0 = Open windows + 20 most recent tabs
#     1 = Open windows + 5 most recent tabs
#     2 = Open windows + 3 most recent tabs
#     3 = Open windows only
# We set the value to 3.
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\set_alt_tab_windows_only.ps1
# Effect: Usually immediate; if not, sign out or restart Explorer.
$regPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$valueName = 'MultiTaskingAltTabFilter'
$desired = 3
if (-not (Test-Path $regPath)) {
  New-Item -Path $regPath -Force | Out-Null
}
$current = (Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue).$valueName
if ($current -ne $desired) {
  New-ItemProperty -Path $regPath -Name $valueName -PropertyType DWord -Value $desired -Force | Out-Null
  Write-Host "Set $valueName = $desired (Open windows only)."
}
else {
  Write-Host "$valueName already = $desired (Open windows only)."
}