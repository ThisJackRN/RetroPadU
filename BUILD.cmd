@echo off
rem Double-click to build output\Mario Kart Retro Rewind WiiVC [RMCETO].wbfs
rem Options are passed through, e.g. BUILD.cmd -KeepWork
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\build-wiivc.ps1" %*
set "RC=%ERRORLEVEL%"
echo.
pause
exit /b %RC%
