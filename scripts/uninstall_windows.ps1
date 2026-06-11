# ============================================================
#  X-gallery-dl-commander アンインストーラー (Windows)
#  PowerShell で実行してください
# ============================================================

$INSTALL_DIR = Join-Path $env:LOCALAPPDATA "gallery-dl-commander"

$GREEN  = [System.ConsoleColor]::Green
$YELLOW = [System.ConsoleColor]::Yellow
$CYAN   = [System.ConsoleColor]::Cyan
$WHITE  = [System.ConsoleColor]::White

function Write-Color($text, $color) { Write-Host $text -ForegroundColor $color }

Write-Host ""
Write-Color "=============================================" $CYAN
Write-Color " X-gallery-dl-commander アンインストーラー " $WHITE
Write-Color "=============================================" $CYAN
Write-Host ""

# ── アプリ本体を削除 ──────────────────────────────────────
if (Test-Path $INSTALL_DIR) {
    Write-Color "  削除します: $INSTALL_DIR" $YELLOW
    Remove-Item $INSTALL_DIR -Recurse -Force
    Write-Color "  ✓ アプリを削除しました" $GREEN
} else {
    Write-Color "  アプリフォルダが見つかりません（スキップ）" $YELLOW
}

# ── デスクトップのファイルを削除 ─────────────────────────
$desktop = [Environment]::GetFolderPath("Desktop")
$batPath  = Join-Path $desktop "gallery-dl-commander.bat"
$htmlPath = Join-Path $desktop "gallery-dl-commander.html"

if (Test-Path $batPath) {
    Remove-Item $batPath -Force
    Write-Color "  ✓ ランチャー (.bat) を削除しました" $GREEN
}
if (Test-Path $htmlPath) {
    Remove-Item $htmlPath -Force
    Write-Color "  ✓ HTML ファイルを削除しました" $GREEN
}

Write-Host ""

# ── gallery-dl の削除（選択式）────────────────────────────
Write-Color "gallery-dl について" $WHITE
Write-Host "  gallery-dl は他の用途でも使えるため、デフォルトでは削除しません。"
$answer = Read-Host "  gallery-dl もアンインストールしますか？ [y/N]"
if ($answer -match "^[Yy]$") {
    try {
        winget uninstall --id mikf.gallery-dl --silent
        Write-Color "  ✓ gallery-dl を削除しました" $GREEN
    } catch {
        Write-Color "  ⚠ 削除に失敗しました（手動で: winget uninstall mikf.gallery-dl）" $YELLOW
    }
} else {
    Write-Host "  スキップしました"
}

Write-Host ""
Write-Color "=============================================" $CYAN
Write-Color "      アンインストール完了！               " $WHITE
Write-Color "=============================================" $CYAN
Write-Host ""
Read-Host "Enterキーを押して閉じる"
