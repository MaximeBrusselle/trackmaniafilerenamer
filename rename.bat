@echo off
echo Launching Trackmania Replay Renamer...
powershell -ExecutionPolicy Bypass -File "%~dp0rename.ps1" %*
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo An error occurred during script execution.
    echo Please check the output above for details.
)
pause