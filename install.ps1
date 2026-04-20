# Vowen Volume Ducker - Installer
# Installs AutoHotkey v2 (if needed), copies the script to %LOCALAPPDATA%\VowenDucker,
# and creates a Startup shortcut so it runs on every login.

$ErrorActionPreference = 'Stop'

$InstallDir  = Join-Path $env:LOCALAPPDATA 'VowenDucker'
$ScriptSrc   = Join-Path $PSScriptRoot 'vowen-duck.ahk'
$ScriptDst   = Join-Path $InstallDir 'vowen-duck.ahk'
$StartupDir  = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup'
$StartupLnk  = Join-Path $StartupDir 'vowen-duck.lnk'
$AhkExe      = Join-Path $env:LOCALAPPDATA 'Programs\AutoHotkey\v2\AutoHotkey64.exe'

Write-Host ''
Write-Host 'Vowen Volume Ducker - Installer' -ForegroundColor Cyan
Write-Host '==============================='
Write-Host ''

# --- 1. AutoHotkey v2 ---
if (Test-Path $AhkExe) {
    Write-Host "AutoHotkey v2 already installed." -ForegroundColor Green
} else {
    Write-Host "Installing AutoHotkey v2 via winget..." -ForegroundColor Yellow
    winget install --id AutoHotkey.AutoHotkey --silent --accept-source-agreements --accept-package-agreements
    if (-not (Test-Path $AhkExe)) {
        Write-Error "AutoHotkey install failed. Install manually from https://autohotkey.com and re-run this script."
        exit 1
    }
    Write-Host "AutoHotkey v2 installed." -ForegroundColor Green
}

# --- 2. Copy script ---
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir | Out-Null
}
if (-not (Test-Path $ScriptSrc)) {
    Write-Error "vowen-duck.ahk not found next to install.ps1. Did you clone the whole repo?"
    exit 1
}
Copy-Item $ScriptSrc $ScriptDst -Force
Write-Host "Script installed at $ScriptDst" -ForegroundColor Green

# --- 3. Startup shortcut ---
$ws = New-Object -ComObject WScript.Shell
$sc = $ws.CreateShortcut($StartupLnk)
$sc.TargetPath        = $AhkExe
$sc.Arguments         = "`"$ScriptDst`""
$sc.WorkingDirectory  = $InstallDir
$sc.Description       = 'Vowen Volume Ducker - auto-ducks system volume during dictation'
$sc.Save()
Write-Host "Auto-start shortcut created." -ForegroundColor Green

# --- 4. Launch now ---
Write-Host ''
Write-Host "Launching..." -ForegroundColor Yellow
Start-Process -FilePath $AhkExe -ArgumentList "`"$ScriptDst`""

Write-Host ''
Write-Host 'Done. Look for a green H in your system tray.' -ForegroundColor Green
Write-Host 'Press Ctrl+Shift to start/stop Vowen dictation - volume will duck and restore automatically.'
Write-Host ''
Write-Host 'To uninstall: run uninstall.ps1 from this folder.'
