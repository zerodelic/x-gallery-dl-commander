@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: インストール先と作業ディレクトリを設定
set INSTALL_DIR=%LOCALAPPDATA%\gallery-dl-commander
pushd %~dp0..
set REPO_DIR=%CD%
popd

echo.
echo =============================================
echo    X-gallery-dl-commander インストーラー
echo =============================================
echo.
echo 【前提条件】
echo   このインストーラーは以下をセットアップします：
echo   - gallery-dl
echo   - Python パッケージ（fastapi / uvicorn）
echo.
echo   Python 3.10 以上が別途必要です。
echo   未インストールの場合は先にインストールしてください：
echo     https://www.python.org/downloads/
echo     ※ インストール時に「Add Python to PATH」にチェックを入れてください
echo.
echo   Python はブラウザ UI とダウンロード処理を繋ぐ
echo   ローカルサーバーの実行に使用します。
echo.
pause
echo.

:: ── STEP 1: winget ────────────────────────────
echo [1/5] winget を確認中...
where winget >nul 2>&1
if errorlevel 1 (
    echo   [ERROR] winget が見つかりません
    echo   Microsoft Store から「アプリ インストーラー」を更新してください
    pause
    exit /b 1
)
echo   OK winget が使用可能です
echo.

:: ── STEP 2: gallery-dl ────────────────────────
echo [2/5] gallery-dl を確認中...
where gallery-dl >nul 2>&1
if errorlevel 1 (
    echo   インストールします...
    winget install --id mikf.gallery-dl --silent --accept-source-agreements --accept-package-agreements
    echo   OK インストール完了
) else (
    echo   OK インストール済みです
    winget upgrade --id mikf.gallery-dl --silent >nul 2>&1
)
echo.

:: ── STEP 3: Python ────────────────────────────
echo [3/5] Python を確認中...
where python >nul 2>&1
if errorlevel 1 (
    echo   [ERROR] Python が見つかりません
    echo   https://www.python.org/downloads/ からインストール後、再実行してください
    pause
    exit /b 1
)
python --version
echo.

:: ── STEP 4: アプリをインストール ──────────────
echo [4/5] アプリをインストール中...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
xcopy /E /Y /I "%REPO_DIR%\app" "%INSTALL_DIR%" >nul
echo   OK %INSTALL_DIR% にコピー完了

echo   Python パッケージをインストール中...
python -m pip install fastapi uvicorn -q
echo   OK パッケージインストール完了

:: デスクトップにランチャーを生成
set BAT_DST=%USERPROFILE%\Desktop\gallery-dl-commander.bat
(
    echo @echo off
    echo chcp 65001 ^>nul
    echo cd /d "%INSTALL_DIR%"
    echo python main.py
) > "%BAT_DST%"
echo   OK デスクトップにランチャー (gallery-dl-commander.bat) を作成しました
echo.

:: ── STEP 5: HTML版をデスクトップへ ───────────
echo [5/5] HTML版をデスクトップに配置中...
copy /Y "%REPO_DIR%\src\gallery-dl-commander.html" "%USERPROFILE%\Desktop\gallery-dl-commander.html" >nul
echo   OK デスクトップに配置しました
echo.

echo =============================================
echo          インストール完了！
echo =============================================
echo.
echo 【アプリ版の起動】
echo   デスクトップの gallery-dl-commander.bat をダブルクリック
echo.
echo 【HTML版の起動】
echo   デスクトップの gallery-dl-commander.html をブラウザで開く
echo.
echo 【アンインストール】
echo   scripts\uninstall_windows.bat を実行
echo.
pause
