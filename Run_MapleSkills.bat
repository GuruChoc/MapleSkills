@echo off
setlocal
title MapleSkills
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0MapleSkills.ps1"
