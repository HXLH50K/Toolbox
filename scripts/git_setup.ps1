<#
.SYNOPSIS
Set or unset global git proxy and user identity.
.PARAMETER Action
'set' (default) applies settings; 'unset' removes them.
.EXAMPLE
./git_setup.ps1
.EXAMPLE
./git_setup.ps1 -Action unset
#>

Param(
  [ValidateSet("set", "unset")]
  [string]$Action = "set"
)

$settings = @{
  "http.proxy"  = "socks5://127.0.0.1:12450"
  "https.proxy" = "socks5://127.0.0.1:12450"
  "user.name"   = "hxlh50k"
  "user.email"  = "hxlh50k@gmail.com"
}

if ($Action -eq "set") {
  foreach ($k in $settings.Keys) {
    git config --global $k $settings[$k]
  }
  Write-Host "[git_setup] Applied settings."
}
else {
  foreach ($k in $settings.Keys) {
    git config --global --unset $k 2>$null
  }
  Write-Host "[git_setup] Cleared settings."
}

Write-Host "[git_setup] Current values (blank if unset):"
foreach ($k in $settings.Keys) {
  $v = git config --global --get $k 2>$null
  if (-not $v) { $v = "" }
  Write-Host (" - {0} = {1}" -f $k, $v)
}