@echo off
rem Veritrace: reset. See README.md, "Run with Docker".
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0docker\reset.ps1"
echo.
pause
