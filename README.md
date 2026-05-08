# X-gallery-dl-commander

X（旧Twitter）のハッシュタグ・ユーザーから画像・動画を一括ダウンロードする GUI コマンドビルダーです。  
ブラウザで HTML を開き、設定を選んでコマンドをコピー → ターミナルに貼り付けるだけで使えます。

---

## ファイル構成

```
x-gallery-dl-commander/
├── src/
│   └── gallery-dl-commander.html     ← 標準版 GUI（シアンテーマ）
├── editions/
│   └── kraftwerk/
│       └── gallery-dl-commander.html ← Kraftwerk Edition（赤テーマ・背景画像入り）
├── scripts/
│   ├── setup_mac.sh                  ← Mac 用セットアップスクリプト
│   └── setup_windows.ps1             ← Windows 用セットアップスクリプト
├── .gitignore
├── TODO.md
└── README.md
```

---

## Editions について

| バージョン | 場所 | 特徴 |
|---|---|---|
| 標準版 | `src/` | シアン（`#00d4ff`）テーマ。軽量（約36KB） |
| Kraftwerk Edition | `editions/kraftwerk/` | 赤テーマ・背景画像埋め込み（約650KB）。クラフトワーク来日記念版 |

---

## セットアップ

### Mac

```bash
cd ~/Downloads/x-gallery-dl-commander   # 展開したフォルダに移動
bash scripts/setup_mac.sh
```

自動で以下をインストールします：
- **Homebrew**（パッケージマネージャー）
- **gallery-dl**（ダウンロードエンジン）
- GUI ツールをデスクトップにコピー

### Windows

PowerShell を **管理者として実行** し、以下を実行：

```powershell
cd ~\Downloads\x-gallery-dl-commander
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\setup_windows.ps1
```

自動で以下をインストールします：
- **gallery-dl**（winget 経由）
- GUI ツールをデスクトップにコピー

---

## 使い方

1. **Chrome で [x.com](https://x.com) にログイン**
2. `src/gallery-dl-commander.html` をブラウザで開く
3. ハッシュタグ・日付・メディア種別などを設定
4. 「コピー」ボタンでコマンドをコピー
5. ターミナル（Mac）または PowerShell（Windows）に貼り付けて実行

---

## GUI 機能一覧

| 機能 | 内容 |
|---|---|
| 取得対象 | ハッシュタグ / ユーザーのメディア / いいね / 単一ツイート |
| ハッシュタグ複数指定 | カンマ区切りで複数入力可（例: `cats, 猫, ねこ`） |
| メディア種別 | 写真・動画・GIF をチェックボックスで個別指定 |
| 日付範囲 | 開始日〜終了日で絞り込み（クイック選択付き） |
| 件数制限 | スライダーで最大件数を指定（0 = 無制限） |
| ファイル名 | 標準 / 日付入り / カスタムパターン |
| 保存先 | テキスト入力またはクイック選択（Downloads / Desktop / Pictures） |
| オプション | スリープ / スキップしない / 最高画質 / メタデータ保存 |
| クイックプリセット | よく使う設定の組み合わせをワンクリックで呼び出し |

---

## ダウンロード先

デフォルトの保存先は `~/Downloads/x_media/` です。  
ファイル名は `@ユーザー名_ツイートID_連番.jpg` 形式で自動整理されます。

---

## 注意事項

- 実行前にブラウザで X にログインした状態にしてください
- 大量ダウンロードは X のレート制限に引っかかる場合があります。「スリープ」オプションを ON にすることをおすすめします
- ダウンロードしたコンテンツの著作権は各投稿者に帰属します。**個人利用の範囲でご使用ください**
- 途中で止めたいときは `control + C`（Mac）または `Ctrl + C`（Windows）

---

## トラブルシューティング

**「401 Unauthorized」エラーが出る**  
→ ブラウザで x.com を開いてログインし直してから再実行してください。

**画像が 0 件で DL が終わる**  
→ ハッシュタグのスペルを確認してください。日本語ハッシュタグは正常に URL エンコードされます。

**Windows で `gallery-dl` コマンドが見つからない**  
→ PowerShell を一度閉じて開き直してから実行してください。

---

## ライセンス

MIT License

---

## 将来の拡張予定

```
x-gallery-dl-commander/
├── app/          # ローカルアプリ版（Python FastAPI + SSE 進捗表示）
└── docs/         # ドキュメント
```
