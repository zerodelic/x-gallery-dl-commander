@echo off
setlocal enabledelayedexpansion

set INSTALL_DIR=%LOCALAPPDATA%\gallery-dl-commander

echo.
echo =============================================
echo   X-gallery-dl-commander Uninstaller
echo =============================================
echo.

rem Remove app folder
if exist "%INSTALL_DIR%" (
    echo Removing %INSTALL_DIR% ...
    rmdir /S /Q "%INSTALL_DIR%"
    echo   OK Removed.
) else (
    echo   App folder not found. Skipping.
)

rem Remove Desktop files
if exist "%USERPROFILE%\Desktop\gallery-dl-commander.bat" (
    del /Q "%USERPROFILE%\Desktop\gallery-dl-commander.bat"
    echo   OK Removed launcher from Desktop.
)
if exist "%USERPROFILE%\Desktop\gallery-dl-commander.html" (
    del /Q "%USERPROFILE%\Desktop\gallery-dl-commander.html"
    echo   OK Removed HTML file from Desktop.
)

echo.
echo gallery-dl is not removed by default
echo (it may be used by other tools).
set /p ANSWER="Uninstall gallery-dl too? [y/N]: "
if /i "!ANSWER!"=="y" (
    winget uninstall --id mikf.gallery-dl --silent
    echo   OK gallery-dl removed.
) else (
    echo   Skipped.
)

echo.
echo =============================================
echo   Uninstall complete!
echo =============================================
echo.
pause
