@echo off
REM ============================================
REM ZMMR Scrap Data Import Launcher
REM Run this manually or schedule with Task Scheduler
REM ============================================

REM Set environment variable to indicate scheduled task execution
set TASK_SCHEDULER_RUN=1

echo Starting ZMMR Scrap Data Import...
echo.

REM Run the PowerShell script
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0Import-ZMMRScrapData.ps1"

echo.
echo Import completed.

REM Only pause if running interactively (double-clicked)
if "%1"=="" if defined SESSIONNAME (
    pause
)
