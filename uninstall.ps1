# Vowen Volume Ducker - Uninstaller
# Stops the running script, removes the Startup shortcut, and deletes the install directory.
# Leaves AutoHotkey itself installed (remove with: winget uninstall AutoHotkey.AutoHotkey).

$ErrorActionPreference = 'Stop'

$InstallDir  = Join-Path $env:LOCALAPPDATA 'VowenDucker'
$StartupLnk  = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup\vowen-duck.lnk'
$ScriptPath  = Join-Path $InstallDir 'vowen-duck.ahk'

Write-Host ''
Write-Host 'Vowen Volume Ducker - Uninstaller' -ForegroundColor Cyan
Write-Host '================================='
Write-Host ''

# --- 1. Stop running instance ---
$stopped = 0
Get-CimInstance Win32_Process -Filter "Name = 'AutoHotkey64.exe'" | ForEach-Object {
    if ($_.CommandLine -like "*vowen-duck.ahk*") {
        Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
        Write-Host "Stopped running instance (PID $($_.ProcessId))" -ForegroundColor Yellow
        $stopped++
    }
}
if ($stopped -eq 0) {
    Write-Host "No running instance found."
}

# --- 2. Remove startup shortcut ---
if (Test-Path $StartupLnk) {
    Remove-Item $StartupLnk -Force
    Write-Host "Startup shortcut removed." -ForegroundColor Green
} else {
    Write-Host "No startup shortcut found."
}

# --- 3. Remove install directory ---
if (Test-Path $InstallDir) {
    Remove-Item $InstallDir -Recurse -Force
    Write-Host "Install directory removed." -ForegroundColor Green
} else {
    Write-Host "No install directory found."
}

Write-Host ''
Write-Host 'Uninstalled.' -ForegroundColor Green
Write-Host 'AutoHotkey itself was left installed. To remove it:'
Write-Host '  winget uninstall AutoHotkey.AutoHotkey'
