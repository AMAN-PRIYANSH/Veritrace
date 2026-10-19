@echo off
rem Veritrace: check. See README.md, "Run with Docker".
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0docker\check.ps1"
echo.
pause
