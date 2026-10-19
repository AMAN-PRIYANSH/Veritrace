@echo off
rem Veritrace: stop. See README.md, "Run with Docker".
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0docker\stop.ps1"
if errorlevel 1 (
  echo.
  echo Something went wrong. Read the messages above, then press any key to close.
  pause >nul
) else (
  echo.
  echo This window closes by itself in 10 seconds.
  timeout /t 10 >nul
)
