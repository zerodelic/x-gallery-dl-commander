@echo off
setlocal enabledelayedexpansion

set INSTALL_DIR=%LOCALAPPDATA%\gallery-dl-commander
pushd %~dp0..
set REPO_DIR=%CD%
popd

echo.
echo =============================================
echo   X-gallery-dl-commander Installer
echo =============================================
echo.
echo [Prerequisites]
echo   The following will be installed:
echo     - gallery-dl
echo     - Python packages (fastapi / uvicorn)
echo.
echo   Python 3.10+ is required separately.
echo   If not installed, get it first:
echo     https://www.python.org/downloads/
echo     * Check "Add Python to PATH" during install
echo.
echo   Python is used to run the local server that
echo   connects the browser UI with gallery-dl.
echo.
pause
echo.

rem --- STEP 1: winget
echo [1/5] Checking winget...
where winget >nul 2>&1
if errorlevel 1 (
    echo [ERROR] winget not found.
    echo         Update "App Installer" from Microsoft Store.
    pause
    exit /b 1
)
echo   OK
echo.

rem --- STEP 2: gallery-dl
echo [2/5] Checking gallery-dl...
where gallery-dl >nul 2>&1
if errorlevel 1 (
    echo   Installing gallery-dl...
    winget install --id mikf.gallery-dl --silent --accept-source-agreements --accept-package-agreements
    echo   OK Installed.
) else (
    echo   OK Already installed. Upgrading...
    winget upgrade --id mikf.gallery-dl --silent >nul 2>&1
)
echo.

rem --- STEP 3: Python
echo [3/5] Checking Python...
where python >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found.
    echo         Install from: https://www.python.org/downloads/
    echo         Check "Add Python to PATH" during install.
    pause
    exit /b 1
)
python --version
echo.

rem --- STEP 4: Install app
echo [4/5] Installing app...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
xcopy /E /Y /I "%REPO_DIR%\app" "%INSTALL_DIR%" >nul
echo   OK Copied to %INSTALL_DIR%

echo   Installing Python packages...
python -m pip install fastapi uvicorn -q
echo   OK Packages installed.

rem Create desktop launcher
set BAT_DST=%USERPROFILE%\Desktop\gallery-dl-commander.bat
(
    echo @echo off
    echo cd /d "%INSTALL_DIR%"
    echo call start.bat
) > "%BAT_DST%"
echo   OK Launcher created on Desktop.
echo.

rem --- STEP 5: HTML version
echo [5/5] Copying HTML version to Desktop...
copy /Y "%REPO_DIR%\src\gallery-dl-commander.html" "%USERPROFILE%\Desktop\gallery-dl-commander.html" >nul
echo   OK Done.
echo.

echo =============================================
echo   Installation complete!
echo =============================================
echo.
echo [App version]
echo   Double-click gallery-dl-commander.bat on Desktop.
echo.
echo [HTML version]
echo   Open gallery-dl-commander.html in your browser.
echo.
echo [Uninstall]
echo   Run scripts\uninstall_windows.bat
echo.
pause
