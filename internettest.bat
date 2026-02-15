@echo off
REM Uses pwsh (PowerShell 7+) script in this folder and keep the window open
pwsh -NoExit -ExecutionPolicy Bypass -File "%~dp0internettest.ps1"

exit /b 0