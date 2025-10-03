<#
.SYNOPSIS
Swap CapsLock and Left Ctrl, with -Revert to restore default mapping.

.DESCRIPTION
Writes/Removes HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout\Scancode Map.
Default (no -Revert): enable swap (Caps<->LeftCtrl).
-Revert: delete Scancode Map value to restore default keys.
Requires elevation (Administrator).
Idempotent; detects existing identical/different map.

.EXAMPLE
powershell -ExecutionPolicy Bypass -File .\swap_caps_ctrl.ps1

.EXAMPLE
powershell -ExecutionPolicy Bypass -File .\swap_caps_ctrl.ps1 -Revert

.NOTES
Log off / reboot required to apply changes.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [switch]$Revert
)

$ErrorActionPreference = 'Stop'

# Require elevation
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Error 'Administrator privileges required. Please run PowerShell as Administrator.'
  exit 1
}

$regPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout'
$valueName = 'Scancode Map'

# CapsLock (0x3A) <-> LeftCtrl (0x1D)
$targetMap = [byte[]](
  0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00,
  0x03, 0x00, 0x00, 0x00,
  0x1D, 0x00, 0x3A, 0x00,
  0x3A, 0x00, 0x1D, 0x00,
  0x00, 0x00, 0x00, 0x00
)

function Get-ExistingMap {
  (Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue).$valueName
}

function Compare-ByteArray {
  param([byte[]]$A, [byte[]]$B)
  if ($null -eq $A -or $null -eq $B) { return $false }
  if ($A.Length -ne $B.Length) { return $false }
  for ($i = 0; $i -lt $A.Length; $i++) { if ($A[$i] -ne $B[$i]) { return $false } }
  return $true
}

if ($Revert) {
  Write-Host 'Mode: REVERT (remove Scancode Map, restore default layout)'
  $existing = Get-ExistingMap
  if ($null -eq $existing) {
    Write-Host 'No Scancode Map present; already at default.'
    exit 0
  }
  if ($PSCmdlet.ShouldProcess("$regPath\$valueName", 'Remove')) {
    try {
      Remove-ItemProperty -Path $regPath -Name $valueName -ErrorAction Stop
      Write-Host 'Scancode Map removed. Log off or reboot to apply.'
      exit 0
    }
    catch {
      Write-Error "Removal failed: $($_.Exception.Message)"
      exit 1
    }
  }
  exit 0
}
else {
  Write-Host 'Mode: APPLY (set CapsLock <-> LeftCtrl swap)'
  $existing = Get-ExistingMap
  if (Compare-ByteArray -A $existing -B $targetMap) {
    Write-Host 'Mapping already present; no change.'
    exit 0
  }
  elseif ($existing) {
    Write-Host 'Different Scancode Map detected; overwriting.'
  }
  if ($PSCmdlet.ShouldProcess("$regPath\$valueName", 'Write swap map')) {
    try {
      New-ItemProperty -Path $regPath -Name $valueName -PropertyType Binary -Value $targetMap -Force | Out-Null
      Write-Host 'Scancode Map written: CapsLock <-> LeftCtrl swapped.'
      Write-Host 'Log off or reboot to apply.'
      exit 0
    }
    catch {
      Write-Error "Write failed: $($_.Exception.Message)"
      exit 1
    }
  }
}

# End