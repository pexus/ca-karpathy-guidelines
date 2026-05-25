@echo off
setlocal

echo Karpathy Guidelines Installer (Windows)
echo.

where pwsh >nul 2>&1
if %ERRORLEVEL%==0 (
    echo Using PowerShell 7+ (pwsh)...
    pwsh -NoProfile -ExecutionPolicy Bypass -Command ^
        "iwr -useb https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/scripts/install.ps1 | iex"
    goto :eof
)

where powershell >nul 2>&1
if %ERRORLEVEL%==0 (
    echo Using Windows PowerShell...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "iwr -useb https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/scripts/install.ps1 | iex"
    goto :eof
)

echo ERROR: PowerShell not found.
echo Please install PowerShell 7+ or use Git Bash / WSL.
exit /b 1
