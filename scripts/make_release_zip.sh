#!/bin/bash
# ============================================================
#  リリース用 ZIP を作成するスクリプト
#  使い方: scripts/make_release_zip.sh [バージョン]
#  例:     scripts/make_release_zip.sh v1.1.0
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# バージョンを引数または index.html から取得
VERSION="${1:-$(grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' "$REPO_DIR/app/index.html" | head -1)}"
if [[ -z "$VERSION" ]]; then
    echo "バージョンが取得できませんでした。引数で指定してください: $0 v1.0.0"
    exit 1
fi

ZIP_NAME="gallery-dl-commander-${VERSION}.zip"
OUTPUT="$REPO_DIR/$ZIP_NAME"
WORK_DIR=$(mktemp -d)
DIST_DIR="$WORK_DIR/gallery-dl-commander"

echo "バージョン: $VERSION"
echo "出力先: $OUTPUT"
echo ""

# 必要なファイルだけコピー
mkdir -p "$DIST_DIR"
cp -r "$REPO_DIR/app"       "$DIST_DIR/"
cp -r "$REPO_DIR/src"       "$DIST_DIR/"
cp -r "$REPO_DIR/editions"  "$DIST_DIR/"
cp -r "$REPO_DIR/scripts"   "$DIST_DIR/"
mkdir -p "$DIST_DIR/docs"
cp "$REPO_DIR/docs/manual.html" "$DIST_DIR/docs/"
cp "$REPO_DIR/README.md"    "$DIST_DIR/"

# ZIP 作成
cd "$WORK_DIR"
zip -r "$OUTPUT" "gallery-dl-commander" -x "*.DS_Store" -x "__pycache__/*" -x "*.pyc"
rm -rf "$WORK_DIR"

echo "✓ 作成完了: $ZIP_NAME"
echo "  $(du -sh "$OUTPUT" | cut -f1)"
