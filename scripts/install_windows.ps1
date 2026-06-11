# ============================================================
#  X-gallery-dl-commander インストーラー (Windows)
#  アプリ版 + HTML版 をインストールします
#  PowerShell で実行してください
# ============================================================

$INSTALL_DIR = Join-Path $env:LOCALAPPDATA "gallery-dl-commander"
$SCRIPT_DIR  = Split-Path -Parent $MyInvocation.MyCommand.Path
$REPO_DIR    = Split-Path -Parent $SCRIPT_DIR

$GREEN  = [System.ConsoleColor]::Green
$YELLOW = [System.ConsoleColor]::Yellow
$CYAN   = [System.ConsoleColor]::Cyan
$WHITE  = [System.ConsoleColor]::White

function Write-Color($text, $color) { Write-Host $text -ForegroundColor $color }

Write-Host ""
Write-Color "=============================================" $CYAN
Write-Color "   X-gallery-dl-commander インストーラー   " $WHITE
Write-Color "=============================================" $CYAN
Write-Host ""

# ── STEP 1: winget ────────────────────────────────────────
Write-Color "[1/5] winget を確認中..." $CYAN
try {
    $v = (winget --version 2>&1)
    Write-Color "  ✓ winget が使用可能です ($v)" $GREEN
} catch {
    Write-Color "  ✗ winget が見つかりません" $YELLOW
    Write-Color "  Microsoft Store から「アプリ インストーラー」を更新してください" $WHITE
    Read-Host "Enterキーを押して終了"
    exit 1
}
Write-Host ""

# ── STEP 2: gallery-dl ────────────────────────────────────
Write-Color "[2/5] gallery-dl を確認中..." $CYAN
try {
    $v = (gallery-dl --version 2>&1)
    Write-Color "  ✓ インストール済みです ($v)" $GREEN
    winget upgrade --id mikf.gallery-dl --silent 2>$null
} catch {
    Write-Color "  インストールします..." $YELLOW
    winget install --id mikf.gallery-dl --silent --accept-source-agreements --accept-package-agreements
    $userPath    = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    $machinePath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
    $env:PATH    = $userPath + ";" + $machinePath
    Write-Color "  ✓ インストール完了" $GREEN
}
Write-Host ""

# ── STEP 3: Python ────────────────────────────────────────
Write-Color "[3/5] Python を確認中..." $CYAN
try {
    $v = (python --version 2>&1)
    Write-Color "  ✓ $v" $GREEN
} catch {
    Write-Color "  ✗ Python が見つかりません" $YELLOW
    Write-Color "  https://www.python.org/downloads/ からインストール後、再実行してください" $WHITE
    Read-Host "Enterキーを押して終了"
    exit 1
}
Write-Host ""

# ── STEP 4: アプリ本体をインストール ─────────────────────
Write-Color "[4/5] アプリをインストール中..." $CYAN
$appSrc = Join-Path $REPO_DIR "app"
if (-not (Test-Path $INSTALL_DIR)) { New-Item -ItemType Directory -Path $INSTALL_DIR | Out-Null }
Copy-Item "$appSrc\*" $INSTALL_DIR -Recurse -Force
Write-Color "  ✓ $INSTALL_DIR にコピー完了" $GREEN

Write-Color "  Python パッケージをインストール中..." $CYAN
python -m pip install fastapi uvicorn -q
Write-Color "  ✓ パッケージインストール完了" $GREEN

# デスクトップにランチャー (.bat) を生成
$batPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "gallery-dl-commander.bat"
@"
@echo off
chcp 65001 >nul
cd /d "$INSTALL_DIR"
python main.py
"@ | Set-Content -Path $batPath -Encoding UTF8
Write-Color "  ✓ デスクトップにランチャー (gallery-dl-commander.bat) を作成しました" $GREEN
Write-Host ""

# ── STEP 5: HTML版をデスクトップへ ───────────────────────
Write-Color "[5/5] HTML版をデスクトップに配置中..." $CYAN
$htmlSrc = Join-Path $REPO_DIR "src\gallery-dl-commander.html"
$htmlDst = Join-Path ([Environment]::GetFolderPath("Desktop")) "gallery-dl-commander.html"
Copy-Item $htmlSrc $htmlDst -Force
Write-Color "  ✓ デスクトップに配置しました" $GREEN
Write-Host ""

# ── 完了 ──────────────────────────────────────────────────
Write-Color "=============================================" $CYAN
Write-Color "         インストール完了！               " $WHITE
Write-Color "=============================================" $CYAN
Write-Host ""
Write-Color "【アプリ版の起動】" $WHITE
Write-Host "  デスクトップの gallery-dl-commander.bat をダブルクリック"
Write-Host ""
Write-Color "【HTML版の起動】" $WHITE
Write-Host "  デスクトップの gallery-dl-commander.html をブラウザで開く"
Write-Host ""
Write-Color "【アンインストール】" $WHITE
Write-Host "  scripts\uninstall_windows.ps1 を実行"
Write-Host ""
Read-Host "Enterキーを押して閉じる"
