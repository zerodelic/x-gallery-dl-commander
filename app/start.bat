@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo ================================================
echo   X-gallery-dl-commander
echo ================================================
echo.

:: Python チェック
where python >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python が見つかりません
    echo         https://www.python.org/downloads/ からインストールしてください
    echo         ※ インストール時に「Add Python to PATH」にチェックを入れてください
    pause
    exit /b 1
)

:: gallery-dl チェック
where gallery-dl >nul 2>&1
if errorlevel 1 (
    echo [WARN]  gallery-dl が見つかりません
    echo         winget install mikf.gallery-dl でインストールしてください
    pause
    exit /b 1
)

:: 依存パッケージのインストール
echo 依存パッケージを確認中...
python -m pip install -r requirements.txt -q
if errorlevel 1 (
    echo [ERROR] パッケージインストールに失敗しました
    pause
    exit /b 1
)
echo 準備完了
echo.
echo ブラウザが自動で開きます...
echo 停止するには Ctrl+C を押してください
echo.

python main.py
pause
