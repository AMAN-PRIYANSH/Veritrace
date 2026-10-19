# Called by stop.bat. Stops the 4 containers (data is kept), then quits
# Docker Desktop so nothing keeps running in the background.
$ErrorActionPreference = 'Continue'
Set-Location (Split-Path $PSScriptRoot -Parent)

cmd /c "docker info >nul 2>&1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker is not running, so Veritrace is already stopped."
    exit 0
}

Write-Host "==> Stopping Veritrace (your data is kept)" -ForegroundColor Cyan
if (Test-Path ".env.docker") {
    docker compose --env-file .env.docker stop
} else {
    docker compose -p veritrace stop
}

Write-Host "==> Quitting Docker Desktop" -ForegroundColor Cyan
cmd /c "docker desktop stop >nul 2>&1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Could not quit Docker Desktop automatically. Right-click the whale icon in the taskbar and choose Quit."
} else {
    Write-Host "Docker Desktop stopped."
}
Write-Host ""
Write-Host "Done. Run start.bat to start again; everything comes back as you left it."
