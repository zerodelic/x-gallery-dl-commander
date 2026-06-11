@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set INSTALL_DIR=%LOCALAPPDATA%\gallery-dl-commander

echo.
echo =============================================
echo  X-gallery-dl-commander アンインストーラー
echo =============================================
echo.

:: ── アプリ本体を削除 ──────────────────────────
if exist "%INSTALL_DIR%" (
    echo   削除します: %INSTALL_DIR%
    rmdir /S /Q "%INSTALL_DIR%"
    echo   OK アプリを削除しました
) else (
    echo   アプリフォルダが見つかりません（スキップ）
)

:: ── デスクトップのファイルを削除 ──────────────
if exist "%USERPROFILE%\Desktop\gallery-dl-commander.bat" (
    del /Q "%USERPROFILE%\Desktop\gallery-dl-commander.bat"
    echo   OK ランチャー (.bat) を削除しました
)
if exist "%USERPROFILE%\Desktop\gallery-dl-commander.html" (
    del /Q "%USERPROFILE%\Desktop\gallery-dl-commander.html"
    echo   OK HTML ファイルを削除しました
)

echo.

:: ── gallery-dl の削除（選択式）────────────────
echo gallery-dl について
echo   gallery-dl は他の用途でも使えるため、デフォルトでは削除しません。
set /p ANSWER="  gallery-dl もアンインストールしますか？ [y/N]: "
if /i "!ANSWER!"=="y" (
    winget uninstall --id mikf.gallery-dl --silent
    echo   OK gallery-dl を削除しました
) else (
    echo   スキップしました
)

echo.
echo =============================================
echo       アンインストール完了！
echo =============================================
echo.
pause
