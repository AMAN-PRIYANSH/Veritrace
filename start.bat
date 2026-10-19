@echo off
rem Veritrace: start. See README.md, "Run with Docker".
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0docker\start.ps1"
echo.
pause
