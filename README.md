# X-gallery-dl-commander

X（旧Twitter）のハッシュタグ・ユーザーから画像・動画を一括ダウンロードする GUI ツールです。

2つの使い方があります：

| 種類 | 場所 | 特徴 |
|---|---|---|
| **ローカルアプリ版** | `app/` | ブラウザGUI でリアルタイム進捗表示。ダブルクリックで起動 |
| **HTML コマンドビルダー版** | `src/` | ブラウザで開いてコマンドをコピー → ターミナルに貼るだけ。Python 不要 |

---

## ローカルアプリ版（app/）

### 必要なもの

- **Python 3.10+**
- **gallery-dl**（`brew install gallery-dl`）
- **Chrome**（X にログイン済みであること）

### 起動方法

`app/start.command` をダブルクリックするだけです。  
ブラウザが自動で開きます。

初回のみ依存パッケージ（FastAPI / uvicorn）が自動インストールされます。

### 機能

| 機能 | 内容 |
|---|---|
| 取得対象 | ハッシュタグ / キーワード検索 / ユーザーのメディア / いいね / 単一ツイート |
| ハッシュタグ複数指定 | カンマ区切りで複数入力可（例: `cats, 猫, ねこ`） |
| キーワード検索 | スペース区切り AND 検索・`"フレーズ"` 検索・`from:username` 等に対応 |
| メディア種別 | 写真・動画・GIF をチェックボックスで個別指定 |
| 日付範囲 | 開始日〜終了日で絞り込み（クイック選択付き） |
| 件数制限 | スライダーで最大件数を指定（0 = 無制限） |
| ファイル名 | 標準 / 日付入り / カスタムパターン |
| 保存先 | テキスト入力またはクイック選択 |
| オプション | スリープ / スキップしない / 最高画質 / メタデータ保存 |
| クイックプリセット | よく使う設定の組み合わせをワンクリックで呼び出し |
| リアルタイム進捗 | ダウンロード済みファイルを種別アイコン・ステータス付きで一覧表示 |
| 一時停止 / 再開 | ダウンロード中に SIGSTOP / SIGCONT で制御 |
| サーバー停止 | 画面上のボタンからローカルサーバーを終了 |

### 使い方

1. `app/start.command` をダブルクリック
2. ブラウザで自動的に `http://localhost:8766` が開く
3. ハッシュタグ・設定を入力
4. 右パネルの **▶ 実行** ボタンでダウンロード開始
5. 終了後は **⏻ サーバー停止** ボタンでサーバーを止める

---

## HTML コマンドビルダー版（src/）

Python 不要。`src/gallery-dl-commander.html` をブラウザで開くだけで使えます。

1. **Chrome で [x.com](https://x.com) にログイン**
2. `src/gallery-dl-commander.html` をブラウザで開く
3. 設定を入力して「コピー」ボタンを押す
4. ターミナル（Mac）または PowerShell（Windows）に貼り付けて実行

---

## ファイル構成

```
x-gallery-dl-commander/
├── app/
│   ├── main.py              ← FastAPI サーバー
│   ├── index.html           ← ブラウザ UI
│   ├── requirements.txt     ← 依存パッケージ
│   └── start.command        ← Mac 用起動スクリプト（ダブルクリック）
├── src/
│   └── gallery-dl-commander.html   ← HTML コマンドビルダー版
├── editions/
│   └── kraftwerk/
│       └── gallery-dl-commander.html  ← Kraftwerk Edition（赤テーマ）
├── scripts/
│   ├── install_mac.sh               ← Mac インストーラー（アプリ版 + HTML版）
│   ├── install_windows.bat          ← Windows インストーラー（アプリ版 + HTML版）
│   ├── uninstall_mac.sh             ← Mac アンインストーラー
│   ├── uninstall_windows.bat        ← Windows アンインストーラー
│   ├── setup_mac_normal.sh          ← Mac セットアップ（HTML版のみ・ノーマル）
│   ├── setup_mac_kraftwerk.sh       ← Mac セットアップ（HTML版のみ・Kraftwerk）
│   ├── setup_windows_normal.ps1     ← Windows セットアップ（HTML版のみ・ノーマル）
│   └── setup_windows_kraftwerk.ps1  ← Windows セットアップ（HTML版のみ・Kraftwerk）
├── docs/
│   └── manual.html              ← HTML 形式の取扱説明書
└── README.md
```

---

## 注意事項

- 実行前にブラウザで X にログインした状態にしてください
- 大量ダウンロードは X のレート制限に引っかかる場合があります。「スリープ」オプション ON を推奨します
- ダウンロードしたコンテンツの著作権は各投稿者に帰属します。**個人利用の範囲でご使用ください**

---

## トラブルシューティング

**「401 Unauthorized」エラーが出る**  
→ Chrome で x.com を開いてログインし直してから再実行してください。

**画像が 0 件で DL が終わる**  
→ ハッシュタグのスペルを確認してください。日本語ハッシュタグは正常に URL エンコードされます。

**ポート 8766 がすでに使われている**  
→ `app/main.py` の最終行のポート番号を変更してください。

---

## テスト

コマンド生成ロジックのユニットテストを Vitest で実行できます。

### 必要なもの
- Node.js 18+（`brew install node`）

### 実行方法

```bash
npm install
npm test
```

テストファイル: `tests/command-builder.test.js`

---

## マニュアル

詳しい使い方は `docs/manual.html` をブラウザで開いてください。

---

## ライセンス

MIT License
