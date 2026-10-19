# Called by start.bat. Starts Docker Desktop if needed, creates .env.docker
# on first run, starts the 4 containers and opens the website when it is ready.
$ErrorActionPreference = 'Continue'
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

function Test-Docker { cmd /c "docker info >nul 2>&1"; return ($LASTEXITCODE -eq 0) }
function Write-Step($text) { Write-Host ""; Write-Host "==> $text" -ForegroundColor Cyan }

# 1. Docker Desktop
Write-Step "Checking Docker Desktop"
if (-not (Test-Docker)) {
    Write-Host "Docker is not running, starting Docker Desktop..."
    cmd /c "docker desktop start >nul 2>&1"
    if (-not (Test-Docker)) {
        $exe = @(
            "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe",
            "$env:LOCALAPPDATA\Programs\DockerDesktop\Docker Desktop.exe"
        ) | Where-Object { Test-Path $_ } | Select-Object -First 1
        if ($exe) { Start-Process $exe }
    }
    $deadline = (Get-Date).AddMinutes(3)
    while (-not (Test-Docker)) {
        if ((Get-Date) -gt $deadline) {
            Write-Host "Docker Desktop did not start. Open it yourself, wait for 'Engine running', then run start.bat again." -ForegroundColor Red
            exit 1
        }
        Start-Sleep -Seconds 3
    }
}
Write-Host "Docker is running."

# 2. Secrets, created once and never committed (.env* is git-ignored)
if (-not (Test-Path ".env.docker")) {
    Write-Step "First run: creating .env.docker with random passwords"
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    function New-Hex([int]$bytes) {
        $b = New-Object byte[] $bytes; $rng.GetBytes($b)
        return (($b | ForEach-Object { $_.ToString('x2') }) -join '')
    }
    @(
        "PG_PASSWORD=$(New-Hex 12)",
        "NEO4J_PASSWORD=$(New-Hex 12)",
        "QDRANT_API_KEY=$(New-Hex 16)",
        "SESSION_SECRET=$(New-Hex 32)",
        "SEED_MANUFACTURER_PASSWORD=maker-$(New-Hex 4)",
        "SEED_REGULATOR_PASSWORD=inspector-$(New-Hex 4)"
    ) | Set-Content -Encoding ascii ".env.docker"
}

# 3. Login sheet, rebuilt from .env.docker every time (git-ignored)
$envMap = @{}
Get-Content ".env.docker" | ForEach-Object { if ($_ -match '^([A-Z_]+)=(.*)$') { $envMap[$matches[1]] = $matches[2] } }
@(
    "VERITRACE - local logins (this computer only)",
    "",
    "Website        http://localhost:3000",
    "  Manufacturer   username: maker       password: $($envMap['SEED_MANUFACTURER_PASSWORD'])",
    "  Regulator      username: inspector   password: $($envMap['SEED_REGULATOR_PASSWORD'])",
    "",
    "Neo4j Browser  http://localhost:7474   user: neo4j   password: $($envMap['NEO4J_PASSWORD'])",
    "Qdrant UI      http://localhost:6333/dashboard   api key: $($envMap['QDRANT_API_KEY'])",
    "PostgreSQL     localhost:5433   database: veritrace   user: veritrace   password: $($envMap['PG_PASSWORD'])"
) | Set-Content -Encoding utf8 "LOGIN-INFO.txt"

# 4. Containers
Write-Step "Starting PostgreSQL, Neo4j, Qdrant and the website"
Write-Host "The very first start downloads about 1.5 GB and can take 10 to 20 minutes."
New-Item -ItemType Directory -Force -Path "logs" | Out-Null
docker compose --env-file .env.docker up -d --build
if ($LASTEXITCODE -ne 0) {
    Write-Host "docker compose failed. Read the messages above." -ForegroundColor Red
    exit 1
}

# 5. Wait for the website, showing progress from logs\app.log
Write-Step "Waiting for the website (first run also fills the databases)"
$deadline = (Get-Date).AddMinutes(25)
$lastLine = ""
while ($true) {
    try {
        $r = Invoke-WebRequest -Uri "http://localhost:3000/login" -UseBasicParsing -TimeoutSec 5
        if ($r.StatusCode -eq 200) { break }
    } catch { }
    if (Test-Path "logs\app.log") {
        $line = Get-Content "logs\app.log" -Tail 1
        if ($line -and $line -ne $lastLine) { Write-Host "   $line"; $lastLine = $line }
    }
    if ((Get-Date) -gt $deadline) {
        Write-Host "The website is not up after 25 minutes. Check logs\app.log and logs\setup.log." -ForegroundColor Red
        exit 1
    }
    Start-Sleep -Seconds 5
}

Write-Step "Veritrace is running"
Write-Host "Website: http://localhost:3000   (logins are in LOGIN-INFO.txt)"
Write-Host "To stop everything later, double-click stop.bat."
Start-Process "http://localhost:3000"
