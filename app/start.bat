@echo off
cd /d "%~dp0"

echo ================================================
echo   X-gallery-dl-commander
echo ================================================
echo.

rem Check Python
where python >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found.
    echo         Install from: https://www.python.org/downloads/
    echo         Check "Add Python to PATH" during install.
    pause
    exit /b 1
)

rem Check gallery-dl
where gallery-dl >nul 2>&1
if errorlevel 1 (
    echo [ERROR] gallery-dl not found.
    echo         Run: winget install mikf.gallery-dl
    pause
    exit /b 1
)

rem Install dependencies
echo Checking dependencies...
python -m pip install -r requirements.txt -q
if errorlevel 1 (
    echo [ERROR] Failed to install packages.
    pause
    exit /b 1
)

echo Ready.
echo.
echo Browser will open automatically...
echo Press Ctrl+C to stop the server.
echo.

python main.py
pause
