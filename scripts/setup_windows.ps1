# ============================================================
#  gallery-dl セットアップスクリプト (Windows)
#  Kraftwerk DL Tool - MACHINE EDITION
#  PowerShell で実行してください
# ============================================================

$RED    = [System.ConsoleColor]::Red
$GREEN  = [System.ConsoleColor]::Green
$YELLOW = [System.ConsoleColor]::Yellow
$CYAN   = [System.ConsoleColor]::Cyan
$WHITE  = [System.ConsoleColor]::White

function Write-Color($text, $color) {
    Write-Host $text -ForegroundColor $color
}

Write-Host ""
Write-Color "███████████████████████████████████████████" $RED
Write-Color "   KRAFTWERK DL TOOL - セットアップ開始   " $WHITE
Write-Color "███████████████████████████████████████████" $RED
Write-Host ""

# ── STEP 1: winget の確認 ─────────────────────────────────
Write-Color "[1/3] winget を確認中..." $CYAN

try {
    $wingetVersion = (winget --version 2>&1)
    Write-Color "  ✓ winget が使用可能です ($wingetVersion)" $GREEN
} catch {
    Write-Color "  ✗ winget が見つかりません" $YELLOW
    Write-Host ""
    Write-Color "  Windows 10/11 の場合、Microsoft Store から" $WHITE
    Write-Color "  「アプリ インストーラー」を更新すると使えるようになります。" $WHITE
    Write-Color "  https://aka.ms/getwinget" $CYAN
    Write-Host ""
    Write-Host "  または、以下のURLからgallery-dl.exeを直接ダウンロードしてください："
    Write-Color "  https://github.com/mikf/gallery-dl/releases/latest" $CYAN
    Read-Host "Enterキーを押して終了"
    exit 1
}

Write-Host ""

# ── STEP 2: gallery-dl のインストール ────────────────────
Write-Color "[2/3] gallery-dl を確認中..." $CYAN

$galleryDlExists = $false
try {
    $ver = (gallery-dl --version 2>&1)
    Write-Color "  ✓ gallery-dl はインストール済みです ($ver)" $GREEN
    Write-Color "    最新版に更新します..." $YELLOW
    winget upgrade --id mikf.gallery-dl --silent 2>$null
    $galleryDlExists = $true
} catch {
    Write-Color "  gallery-dl をインストールします..." $YELLOW
    winget install --id mikf.gallery-dl --silent --accept-source-agreements --accept-package-agreements
    
    # PATH を更新
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "User") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
    
    Write-Color "  ✓ gallery-dl のインストールが完了しました" $GREEN
}

Write-Host ""

# ── STEP 3: HTMLツールをデスクトップにコピー ─────────────
Write-Color "[3/3] GUIツールをデスクトップに配置中..." $CYAN

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$htmlSrc   = Join-Path $scriptDir "gallery-dl-commander.html"
$htmlDst   = Join-Path ([Environment]::GetFolderPath("Desktop")) "gallery-dl-commander.html"

if (Test-Path $htmlSrc) {
    Copy-Item $htmlSrc $htmlDst -Force
    Write-Color "  ✓ デスクトップに gallery-dl-commander.html を配置しました" $GREEN
} else {
    Write-Color "  ⚠ gallery-dl-commander.html が見つかりません（同じフォルダに置いてください）" $YELLOW
}

Write-Host ""

# ── 完了 ──────────────────────────────────────────────────
Write-Color "███████████████████████████████████████████" $RED
Write-Color "         セットアップ完了！               " $WHITE
Write-Color "███████████████████████████████████████████" $RED
Write-Host ""
Write-Color "次のステップ:" $WHITE
Write-Host "  1. Chrome または Edge で x.com にログインしてください"
Write-Host "  2. デスクトップの gallery-dl-commander.html をブラウザで開く"
Write-Host "  3. ハッシュタグや条件を設定してコマンドをコピー"
Write-Host "  4. PowerShell に貼り付けて実行"
Write-Host ""
Write-Color "  ※ Windowsでは --cookies-from-browser に chrome または edge を使います" $YELLOW
Write-Host ""
Write-Color "  停止したいときは Ctrl + C" $YELLOW
Write-Host ""
Read-Host "Enterキーを押して閉じる"
