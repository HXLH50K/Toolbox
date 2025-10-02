# swap_caps_ctrl_disable.ps1
# Purpose: Remove Caps Lock <-> Left Ctrl swap (delete Scancode Map).
# Mechanism: Deletes HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout\Scancode Map.
# Requirement: Run as Administrator (writes HKLM).
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\swap_caps_ctrl_disable.ps1
# Related enable script: swap_caps_ctrl_enable.ps1
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Error 'Please run elevated (Administrator required for HKLM).'
  exit 1
}
$regPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout'
$name = 'Scancode Map'
if (-not (Test-Path $regPath)) {
  Write-Host 'Registry path not found. Nothing to revert.'
  exit 0
}
$prop = Get-ItemProperty -Path $regPath -Name $name -ErrorAction SilentlyContinue
if ($null -eq $prop) {
  Write-Host 'No Scancode Map present. Already default.'
  exit 0
}
try {
  Remove-ItemProperty -Path $regPath -Name $name -ErrorAction Stop
  Write-Host 'Scancode Map removed. Key mapping reverted to default.'
  Write-Host 'Log off or reboot for full effect.'
}
catch {
  Write-Error "Removal failed: $($_.Exception.Message)"
  exit 1
}