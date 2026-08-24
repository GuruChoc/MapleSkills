@echo off
setlocal
title Maple Levels - I/L Mage Guild Tester
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0MapleLevels_ILM_v0.6.ps1"

if errorlevel 1 (
    echo.
    echo ============================================================
    echo  MAPLE LEVELS DID NOT START CORRECTLY
    echo ============================================================
    echo.
    echo If Windows blocked the script, right-click this BAT and
    echo choose "Run as administrator" only for this test.
    echo.
    pause
)
