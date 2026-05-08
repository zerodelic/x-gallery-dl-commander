#!/bin/bash
# X-gallery-dl-commander — ダブルクリックで起動するランチャー
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

echo "================================================"
echo "  X-gallery-dl-commander"
echo "================================================"
echo ""

# Python チェック
if ! command -v python3 &>/dev/null; then
    echo "❌ Python3 が見つかりません"
    echo "   brew install python3 でインストールしてください"
    read -p "Enterキーで閉じる..." _
    exit 1
fi

# gallery-dl チェック
if ! command -v gallery-dl &>/dev/null; then
    echo "⚠️  gallery-dl が見つかりません"
    echo "   brew install gallery-dl でインストールしてください"
    read -p "Enterキーで閉じる..." _
    exit 1
fi

# 依存パッケージのインストール
echo "📦 依存パッケージを確認中..."
python3 -m pip install -r requirements.txt -q 2>/dev/null \
    || python3 -m pip install -r requirements.txt -q --break-system-packages 2>/dev/null \
    || { echo "❌ パッケージインストールに失敗しました"; read -p "Enterキーで閉じる..." _; exit 1; }
echo "✅ 準備完了"
echo ""
echo "🌐 ブラウザが自動で開きます..."
echo "   停止するには Ctrl+C を押してください"
echo ""

python3 main.py
