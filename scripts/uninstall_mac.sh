#!/bin/bash
# ============================================================
#  X-gallery-dl-commander アンインストーラー (Mac)
# ============================================================

INSTALL_DIR="$HOME/Applications/gallery-dl-commander"

GRN='\033[0;32m'
YLW='\033[1;33m'
CYN='\033[0;36m'
WHT='\033[1;37m'
RST='\033[0m'

echo ""
echo -e "${CYN}=============================================${RST}"
echo -e "${WHT} X-gallery-dl-commander アンインストーラー ${RST}"
echo -e "${CYN}=============================================${RST}"
echo ""

# ── アプリ本体を削除 ──────────────────────────────────────
if [[ -d "$INSTALL_DIR" ]]; then
    echo -e "${YLW}  削除します: $INSTALL_DIR${RST}"
    rm -rf "$INSTALL_DIR"
    echo -e "${GRN}  ✓ アプリを削除しました${RST}"
else
    echo -e "${YLW}  アプリフォルダが見つかりません（スキップ）${RST}"
fi

# ── デスクトップの HTML を削除 ────────────────────────────
if [[ -f "$HOME/Desktop/gallery-dl-commander.html" ]]; then
    rm "$HOME/Desktop/gallery-dl-commander.html"
    echo -e "${GRN}  ✓ デスクトップの HTML ファイルを削除しました${RST}"
fi

echo ""

# ── gallery-dl の削除（選択式）────────────────────────────
echo -e "${WHT}gallery-dl について${RST}"
echo -e "  gallery-dl は他の用途でも使えるため、デフォルトでは削除しません。"
echo -n "  gallery-dl もアンインストールしますか？ [y/N]: "
read -r answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    brew uninstall gallery-dl 2>/dev/null \
        && echo -e "${GRN}  ✓ gallery-dl を削除しました${RST}" \
        || echo -e "${YLW}  ⚠ 削除に失敗しました（手動で: brew uninstall gallery-dl）${RST}"
else
    echo -e "  スキップしました"
fi

echo ""
echo -e "${CYN}=============================================${RST}"
echo -e "${WHT}      アンインストール完了！               ${RST}"
echo -e "${CYN}=============================================${RST}"
echo ""
