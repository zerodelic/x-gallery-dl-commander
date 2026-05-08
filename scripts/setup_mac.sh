#!/bin/bash
# ============================================================
#  gallery-dl セットアップスクリプト (Mac)
#  Kraftwerk DL Tool - MACHINE EDITION
# ============================================================

set -e

RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[1;33m'
CYN='\033[0;36m'
WHT='\033[1;37m'
RST='\033[0m'

echo ""
echo -e "${RED}███████████████████████████████████████████${RST}"
echo -e "${WHT}   KRAFTWERK DL TOOL - セットアップ開始   ${RST}"
echo -e "${RED}███████████████████████████████████████████${RST}"
echo ""

# ── STEP 1: Homebrew ──────────────────────────────────────
echo -e "${CYN}[1/3] Homebrew を確認中...${RST}"

if command -v brew &> /dev/null; then
    echo -e "${GRN}  ✓ Homebrew はインストール済みです${RST}"
else
    echo -e "${YLW}  Homebrew が見つかりません。インストールします...${RST}"
    echo -e "${WHT}  途中でパスワードを求められたら Mac のログインパスワードを入力してください${RST}"
    echo ""
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Apple Silicon の PATH 設定
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    echo -e "${GRN}  ✓ Homebrew のインストールが完了しました${RST}"
fi

echo ""

# ── STEP 2: gallery-dl ────────────────────────────────────
echo -e "${CYN}[2/3] gallery-dl を確認中...${RST}"

if command -v gallery-dl &> /dev/null; then
    CURRENT=$(gallery-dl --version 2>&1)
    echo -e "${GRN}  ✓ gallery-dl はインストール済みです（${CURRENT}）${RST}"
    echo -e "    最新版に更新します..."
    brew upgrade gallery-dl 2>/dev/null || true
else
    echo -e "${YLW}  gallery-dl をインストールします...${RST}"
    brew install gallery-dl
    echo -e "${GRN}  ✓ gallery-dl のインストールが完了しました${RST}"
fi

echo ""

# ── STEP 3: HTMLツールをデスクトップにコピー ─────────────
echo -e "${CYN}[3/3] GUIツールをデスクトップに配置中...${RST}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HTML_SRC="${SCRIPT_DIR}/gallery-dl-commander.html"
HTML_DST="${HOME}/Desktop/gallery-dl-commander.html"

if [[ -f "$HTML_SRC" ]]; then
    cp "$HTML_SRC" "$HTML_DST"
    echo -e "${GRN}  ✓ デスクトップに gallery-dl-commander.html を配置しました${RST}"
else
    echo -e "${YLW}  ⚠ gallery-dl-commander.html が見つかりません（同じフォルダに置いてください）${RST}"
fi

echo ""

# ── 完了 ──────────────────────────────────────────────────
echo -e "${RED}███████████████████████████████████████████${RST}"
echo -e "${WHT}         セットアップ完了！               ${RST}"
echo -e "${RED}███████████████████████████████████████████${RST}"
echo ""
echo -e "${WHT}次のステップ:${RST}"
echo -e "  1. Chrome で ${CYN}x.com${RST} にログインしてください"
echo -e "  2. デスクトップの ${CYN}gallery-dl-commander.html${RST} をブラウザで開く"
echo -e "  3. ハッシュタグや条件を設定してコマンドをコピー"
echo -e "  4. このターミナルに貼り付けて実行"
echo ""
echo -e "${YLW}  停止したいときは control + C${RST}"
echo ""
