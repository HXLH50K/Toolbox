<#
.SYNOPSIS
Hide Windows Spotlight desktop "Learn about this picture" icon and lock screen overlay ads/tips while keeping Spotlight images.

.DESCRIPTION
Combines previous scripts:
- hide_spotlight_info_icon.ps1
- lock_screen_spotlight_minimal.ps1

APPLY (default):
- Hides desktop info icon (CLSID {2cc5ca98-6485-489a-920e-b3e88a6ccce3})
- Keeps Spotlight image rotation
- Disables lock screen overlays / tips / promotional links

REVERT:
- Shows desktop icon
- Re-enables lock screen overlay / suggestion values (restores defaults)

Uses HKCU registry only. Idempotent. Supports -WhatIf.

.PARAMETER Revert
Restore default behavior (show desktop icon, enable all overlay / suggestion keys).

.EXAMPLE
powershell -ExecutionPolicy Bypass -File .\spotlight_hide_ads.ps1

.EXAMPLE
powershell -ExecutionPolicy Bypass -File .\spotlight_hide_ads.ps1 -Revert

.NOTES
Changes may need logoff / explorer refresh / next lock screen cycle.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [switch]$Revert
)

$ErrorActionPreference = 'Stop'

# Desktop icon CLSID and paths
$desktopIconClsid = '{2cc5ca98-6485-489a-920e-b3e88a6ccce3}'
$desktopBase = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons'
$desktopScopes = @('NewStartPanel', 'ClassicStartMenu')

# Content Delivery Manager path
$cdmPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'

# Keys to keep enabled to preserve Spotlight images
$keepEnabled = @(
  'SubscribedContent-310093Enabled'
  'RotatingLockScreenEnabled'
)

# Keys to disable (overlays / suggestions / tips)
$disableKeys = @(
  'RotatingLockScreenOverlayEnabled'
  'SubscribedContent-338387Enabled'
  'SubscribedContent-338388Enabled'
  'SubscribedContent-338389Enabled'
)

function Ensure-Key {
  param([string]$Path)
  if (-not (Test-Path $Path)) {
    New-Item -Path $Path -Force | Out-Null
  }
}

function Set-Dword {
  param(
    [string]$Path,
    [string]$Name,
    [int]$Value
  )
  if ($PSCmdlet.ShouldProcess("$Path\$Name", "Set $Value")) {
    New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType DWord -Force | Out-Null
  }
}

function Remove-ValueIfExists {
  param(
    [string]$Path,
    [string]$Name
  )
  if (Test-Path $Path) {
    $prop = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -ne $prop) {
      if ($PSCmdlet.ShouldProcess("$Path\$Name", "Remove")) {
        Remove-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
      }
    }
  }
}

function Get-BuildInfo {
  $b = [System.Environment]::OSVersion.Version.Build
  if ($b -ge 22000) { "Windows 11 (Build $b)" } else { "Windows 10 (Build $b)" }
}

Write-Host "Spotlight Hide Ads Script"
Write-Host "Detected: $(Get-BuildInfo)"
if ($Revert) {
  Write-Host "Mode: REVERT (restore desktop icon + lock screen overlays)"
}
else {
  Write-Host "Mode: APPLY (hide icon, disable overlays, keep images)"
}

# Prepare registry structure
Ensure-Key -Path $cdmPath
Ensure-Key -Path (Join-Path $desktopBase 'NewStartPanel')
Ensure-Key -Path (Join-Path $desktopBase 'ClassicStartMenu')

if ($Revert) {
  # Desktop icon: remove value (or could set 0)
  foreach ($scope in $desktopScopes) {
    $full = Join-Path $desktopBase $scope
    Remove-ValueIfExists -Path $full -Name $desktopIconClsid
  }
  # Re-enable all relevant keys
  foreach ($k in ($keepEnabled + $disableKeys | Sort-Object -Unique)) {
    Set-Dword -Path $cdmPath -Name $k -Value 1
  }
  Write-Host "Reverted: desktop icon visible; lock screen overlays / tips enabled."
}
else {
  # Hide desktop icon (set value to 1)
  foreach ($scope in $desktopScopes) {
    $full = Join-Path $desktopBase $scope
    Set-Dword -Path $full -Name $desktopIconClsid -Value 1
  }
  # Keep Spotlight enabled
  foreach ($k in $keepEnabled) {
    Set-Dword -Path $cdmPath -Name $k -Value 1
  }
  # Disable overlays / suggestions
  foreach ($k in $disableKeys) {
    Set-Dword -Path $cdmPath -Name $k -Value 0
  }
  Write-Host "Applied: desktop icon hidden; overlays / tips disabled; images retained."
}

Write-Host "Done. Use -Revert to restore default experience."