@echo off
REM allow_ps1_bootstrap.cmd
REM Purpose: Enable PowerShell script execution (CurrentUser RemoteSigned) even when current policy is Restricted.
REM Why: When ExecutionPolicy is Restricted, double-clicking or invoking a .ps1 may be blocked, but we can start a transient
REM      PowerShell process with -ExecutionPolicy Bypass and set the policy for CurrentUser (no admin required).
REM Usage: Double-click this .cmd OR run in cmd:
REM        allow_ps1_bootstrap.cmd
REM After: You can run local .ps1 scripts without needing an elevated PowerShell (for CurrentUser scope).
REM Revert (optional): Run a PowerShell window and execute:
REM        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Undefined -Force
REM Admin NOT required for CurrentUser scope. This does NOT weaken system-wide (LocalMachine) policy.

setlocal
echo.
echo [*] Setting PowerShell ExecutionPolicy for CurrentUser to RemoteSigned...
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "try { Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force -ErrorAction Stop; Write-Host '[+] Success: CurrentUser ExecutionPolicy = RemoteSigned' -ForegroundColor Green } catch { Write-Host '[-] Failed: ' + $_.Exception.Message -ForegroundColor Red; exit 1 }"
if errorlevel 1 (
  echo.
  echo [-] Operation failed. If this is a corporate machine, Group Policy may enforce MachinePolicy/UserPolicy.
  echo     You can check with:  powershell Get-ExecutionPolicy -List
  exit /b 1
)
echo.
echo Done. Try running your .ps1 scripts now.
endlocal