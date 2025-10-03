<#
.SYNOPSIS
Keep Windows Spotlight lock screen images while removing quick search / tips / promotional overlay links.

.DESCRIPTION
Targets HKCU registry values to:
- Preserve Spotlight image rotation.
- Disable lock screen overlay "fun facts", tips, promotions, search/web shortcut links.
- Optionally restore defaults via -Revert.

Works on Windows 10 / 11 (build detection used only for informational output; current keys are consistent across both).

Values touched under:
HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager

We DO NOT disable the core Spotlight feature (leave SubscribedContent-310093Enabled = 1 and RotatingLockScreenEnabled = 1).
We DO disable overlay / suggestion related values.

Use -WhatIf to preview. Idempotent.

.PARAMETER Revert
Re-enable previously disabled suggestion keys (restores Microsoft defaults for Spotlight experience).

.EXAMPLE
powershell -ExecutionPolicy Bypass -File .\lock_screen_spotlight_minimal.ps1

.EXAMPLE
powershell -ExecutionPolicy Bypass -File .\lock_screen_spotlight_minimal.ps1 -Revert

.NOTES
If changes do not apply immediately, lock screen may need a sign-out or wait for next rotation.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [switch]$Revert
)

$ErrorActionPreference = 'Stop'

$cdmPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'

# Keys we intentionally KEEP (set to 1) to preserve Spotlight image rotation.
$keepEnabled = @(
  'SubscribedContent-310093Enabled'   # Core Windows Spotlight lock screen feature.
  'RotatingLockScreenEnabled'         # Legacy flag still respected on some builds.
)

# Keys we DISABLE to remove overlays / tips / ads / web links.
$disableKeys = @(
  'RotatingLockScreenOverlayEnabled'  # Overlay layer with facts / tips.
  'SubscribedContent-338387Enabled'   # Suggestions / tips variant.
  'SubscribedContent-338388Enabled'   # Additional spotlight suggestions.
  'SubscribedContent-338389Enabled'   # Promotional / fun facts channel.
)

function Test-RegistryPath {
  param([string]$Path)
  if (-not (Test-Path $Path)) {
    New-Item -Path $Path -Force | Out-Null
  }
}

function Set-IntValue {
  param(
    [string]$Path,
    [string]$Name,
    [int]$Value
  )
  if ($PSCmdlet.ShouldProcess("$Path\$Name", "Set to $Value")) {
    New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType DWord -Force | Out-Null
  }
}

function Get-BuildInfo {
  $build = [System.Environment]::OSVersion.Version.Build
  if ($build -ge 22000) { 'Windows 11 (Build {0})' -f $build }
  else { 'Windows 10 (Build {0})' -f $build }
}

Write-Host "Lock Screen Spotlight Minimal Overlay Script"
$buildInfo = Get-BuildInfo
Write-Host "Detected: $buildInfo"
if ($Revert) {
  Write-Host "Mode: REVERT (restore spotlight suggestions/overlays)"
}
else {
  Write-Host "Mode: APPLY (keep images, remove overlays)"
}

Test-RegistryPath -Path $cdmPath

if ($Revert) {
  # Re-enable everything (suggestions + overlays) while ensuring core spotlight stays on.
  foreach ($name in ($keepEnabled + $disableKeys | Sort-Object -Unique)) {
    Set-IntValue -Path $cdmPath -Name $name -Value 1
  }
  Write-Host "Reverted: Overlay / suggestion keys re-enabled."
}
else {
  # Ensure spotlight base is enabled
  foreach ($name in $keepEnabled) {
    Set-IntValue -Path $cdmPath -Name $name -Value 1
  }
  # Disable overlays / suggestions
  foreach ($name in $disableKeys) {
    Set-IntValue -Path $cdmPath -Name $name -Value 0
  }
  Write-Host "Applied: Spotlight images retained; overlays / quick links / tips disabled."
}

Write-Host "Done."
Write-Host "You can run with -Revert to restore default spotlight experience."