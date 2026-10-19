@echo off
rem Veritrace: start. See README.md, "Run with Docker".
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0docker\start.ps1"
if errorlevel 1 (
  echo.
  echo Something went wrong. Read the messages above, then press any key to close.
  pause >nul
) else (
  echo.
  echo This window closes by itself in 30 seconds. Veritrace keeps running.
  timeout /t 30 >nul
)
