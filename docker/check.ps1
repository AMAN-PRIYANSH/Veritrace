# Called by check.bat. Runs the automated checks inside the running app
# container and saves the output to logs\checks-manual.log.
$ErrorActionPreference = 'Continue'
Set-Location (Split-Path $PSScriptRoot -Parent)
$out = "logs\checks-manual.log"
New-Item -ItemType Directory -Force -Path "logs" | Out-Null
"Veritrace checks, $(Get-Date)" | Set-Content $out
foreach ($cmd in @("typecheck", "test", "graph:verify")) {
    Write-Host "==> npm run $cmd" -ForegroundColor Cyan
    docker compose --env-file .env.docker exec -T app npm run $cmd 2>&1 | Tee-Object -FilePath $out -Append
    "EXIT $LASTEXITCODE" | Tee-Object -FilePath $out -Append
}
Write-Host ""
Write-Host "Saved to $out"
