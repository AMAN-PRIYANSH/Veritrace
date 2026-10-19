@echo off
rem Veritrace: stop. See README.md, "Run with Docker".
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0docker\stop.ps1"
echo.
pause
