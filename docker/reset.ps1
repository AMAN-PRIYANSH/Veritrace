# Called by reset.bat. Deletes all Veritrace data (the 3 databases, the
# installed packages and the setup marker) so the next start.bat rebuilds the
# demo data from scratch. The passwords in .env.docker are kept.
$ErrorActionPreference = 'Continue'
Set-Location (Split-Path $PSScriptRoot -Parent)

Write-Host "This deletes every batch, shipment, recall and complaint you added," -ForegroundColor Yellow
Write-Host "and rebuilds the original demo data on the next start." -ForegroundColor Yellow
$answer = Read-Host "Type YES to continue"
if ($answer -ne "YES") { Write-Host "Nothing was changed."; exit 0 }

cmd /c "docker info >nul 2>&1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker Desktop is not running. Start it (or run start.bat), then run reset.bat again." -ForegroundColor Red
    exit 1
}
if (Test-Path ".env.docker") { docker compose --env-file .env.docker down -v } else { docker compose -p veritrace down -v }
Remove-Item -Recurse -Force "logs" -ErrorAction SilentlyContinue
Write-Host ""
Write-Host "Reset done. Run start.bat to rebuild the demo data."
