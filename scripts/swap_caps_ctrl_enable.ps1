# swap_caps_ctrl_enable.ps1
# Purpose: Swap Caps Lock and Left Ctrl (effective after logoff or reboot).
# Mechanism: Writes HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout\Scancode Map.
# Requirement: Must run elevated (Administrator) because it writes under HKLM.
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\swap_caps_ctrl_enable.ps1
# Revert:
#   Run swap_caps_ctrl_disable.ps1
#
# Scan codes:
#   CapsLock = 0x3A
#   LeftCtrl = 0x1D
# Scancode Map layout:
#   Header (8 bytes) + DWORD entry count + mapping entries (4 bytes each) + 4 zero bytes terminator.
# Entry count = number of mappings + 1 (terminator).
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Error 'Please run elevated (Administrator required for HKLM write).'
  exit 1
}
$regPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout'
$name = 'Scancode Map'
# Binary mapping: Caps -> Ctrl, Ctrl -> Caps
$map = [byte[]](
  0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00,
  0x03, 0x00, 0x00, 0x00,
  0x1D, 0x00, 0x3A, 0x00,
  0x3A, 0x00, 0x1D, 0x00,
  0x00, 0x00, 0x00, 0x00
)
$existing = (Get-ItemProperty -Path $regPath -Name $name -ErrorAction SilentlyContinue).$name
if ($existing) {
  $same = ($existing.Length -eq $map.Length) -and (@($existing) -ceq $map | Measure-Object -Sum).Sum -eq $map.Length
  if ($same) {
    Write-Host 'Mapping already present. No change.'
    exit 0
  }
  else {
    Write-Host 'Different Scancode Map found. Overwriting.'
  }
}
New-ItemProperty -Path $regPath -Name $name -PropertyType Binary -Value $map -Force | Out-Null
Write-Host 'Scancode Map written: CapsLock <-> LeftCtrl swapped.'
Write-Host 'Log off or reboot for the change to take effect.'