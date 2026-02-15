@echo off
REM Launch the PowerShell script in this folder and keep the window open
powershell -NoExit -ExecutionPolicy Bypass -File "%~dp0internettest.ps1"

exit /b 0