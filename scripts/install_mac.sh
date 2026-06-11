#!/bin/bash
# ============================================================
#  X-gallery-dl-commander インストーラー (Mac)
#  アプリ版 + HTML版 をインストールします
# ============================================================

set -e

INSTALL_DIR="$HOME/Applications/gallery-dl-commander"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

GRN='\033[0;32m'
YLW='\033[1;33m'
CYN='\033[0;36m'
WHT='\033[1;37m'
RST='\033[0m'

echo ""
echo -e "${CYN}=============================================${RST}"
echo -e "${WHT}   X-gallery-dl-commander インストーラー   ${RST}"
echo -e "${CYN}=============================================${RST}"
echo ""
echo -e "${WHT}【前提条件】${RST}"
echo -e "  このインストーラーは以下をセットアップします："
echo -e "  - Homebrew（未インストールの場合）"
echo -e "  - gallery-dl"
echo -e "  - Python パッケージ（fastapi / uvicorn）"
echo ""
echo -e "  ${YLW}Python 3.10 以上が別途必要です。${RST}"
echo -e "  未インストールの場合は先にインストールしてください："
echo -e "    brew install python3"
echo ""
echo -e "  ※ Python はブラウザ UI とダウンロード処理を繋ぐ"
echo -e "    ローカルサーバーの実行に使用します。"
echo ""
read -p "続行するには Enter を押してください（中断: Ctrl+C）..." _
echo ""

# ── STEP 1: Homebrew ──────────────────────────────────────
echo -e "${CYN}[1/5] Homebrew を確認中...${RST}"
if command -v brew &>/dev/null; then
    echo -e "${GRN}  ✓ インストール済みです${RST}"
else
    echo -e "${YLW}  インストールします（途中でパスワードを求められる場合があります）...${RST}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    echo -e "${GRN}  ✓ インストール完了${RST}"
fi
echo ""

# ── STEP 2: gallery-dl ────────────────────────────────────
echo -e "${CYN}[2/5] gallery-dl を確認中...${RST}"
if command -v gallery-dl &>/dev/null; then
    echo -e "${GRN}  ✓ $(gallery-dl --version 2>&1)${RST}"
    brew upgrade gallery-dl 2>/dev/null || true
else
    echo -e "${YLW}  インストールします...${RST}"
    brew install gallery-dl
    echo -e "${GRN}  ✓ インストール完了${RST}"
fi
echo ""

# ── STEP 3: Python ────────────────────────────────────────
echo -e "${CYN}[3/5] Python3 を確認中...${RST}"
if command -v python3 &>/dev/null; then
    echo -e "${GRN}  ✓ $(python3 --version)${RST}"
else
    echo -e "${YLW}  ⚠ Python3 が見つかりません${RST}"
    echo -e "    brew install python3 でインストール後、再実行してください"
    read -p "  Enterキーで終了..." _
    exit 1
fi
echo ""

# ── STEP 4: アプリ本体をインストール ─────────────────────
echo -e "${CYN}[4/5] アプリをインストール中...${RST}"
mkdir -p "$INSTALL_DIR"
cp -r "$REPO_DIR/app/"* "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/start.command"
echo -e "${GRN}  ✓ $INSTALL_DIR にコピー完了${RST}"

echo -e "    Python パッケージをインストール中..."
python3 -m pip install fastapi uvicorn -q 2>/dev/null \
    || python3 -m pip install fastapi uvicorn -q --break-system-packages 2>/dev/null \
    || echo -e "${YLW}  ⚠ pip インストールに失敗しました。手動で: pip3 install fastapi uvicorn${RST}"
echo -e "${GRN}  ✓ パッケージインストール完了${RST}"
echo ""

# ── STEP 5: HTML版をデスクトップへ ───────────────────────
echo -e "${CYN}[5/5] HTML版をデスクトップに配置中...${RST}"
cp "$REPO_DIR/src/gallery-dl-commander.html" "$HOME/Desktop/gallery-dl-commander.html"
echo -e "${GRN}  ✓ デスクトップに配置しました${RST}"
echo ""

# ── 完了 ──────────────────────────────────────────────────
echo -e "${CYN}=============================================${RST}"
echo -e "${WHT}         インストール完了！               ${RST}"
echo -e "${CYN}=============================================${RST}"
echo ""
echo -e "${WHT}【アプリ版の起動】${RST}"
echo -e "  ${CYN}$INSTALL_DIR/start.command${RST} をダブルクリック"
echo ""
echo -e "${WHT}【HTML版の起動】${RST}"
echo -e "  デスクトップの ${CYN}gallery-dl-commander.html${RST} をブラウザで開く"
echo ""
echo -e "${WHT}【アンインストール】${RST}"
echo -e "  ${CYN}scripts/uninstall_mac.sh${RST} を実行"
echo ""
