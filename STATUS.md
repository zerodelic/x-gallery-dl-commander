# x-gallery-dl-commander
状態: Windows実機検証で複数の不具合を発見。回帰テスト基盤（pytest + GitHub Actions windows-latest/macos-latestマトリクス）構築・push済み、CIグリーン確認待ち
次の一手: GitHub Actionsの初回CI実行結果（windows-latest / macos-latest 両方）を確認する。グリーンなら、argvリスト実行への移行（下記メモ4）に着手する
メモ: Windows実機検証で見つかった問題と対応状況（詳細な理由・代替案はDECISIONS.md参照）:
  1. cmd.exeは`\`行継続を解釈しない→main.pyでコマンド文字列を1行に正規化する対応が必要（未反映、要着手）
  2. `--config-option`は現行gallery-dlに存在しないフラグ（正しくは`--option`）。app/index.htmlのみ修正済み、src/・tests/は未修正（未反映、要着手）
  3. Chrome(v127+)・Edge(v133+)ともにApp-Bound Encryptionを採用し`--cookies-from-browser`が復号不可。暫定対応は手動`cookies.txt`エクスポート（コード未反映。UIにCookieファイルパス入力欄を追加するかは未決定）
  4. `shellQuote()`（POSIXシングルクォート）がcmd.exeでは引用符が literal に混入し `Unsupported URL` エラーになる。app/index.html+main.pyはargvリスト実行への移行（シェルを介さない `create_subprocess_exec` 方式）、src/・editions/kraftwerk/はOS判定でのクォート切り替えで対応する方針（未反映、要着手）
  5. 上記4の実装前に、Mac側への影響（`~`展開、複数ハッシュタグ逐次実行）を自動検知できるようCI基盤を先に構築した（このセッションで完了）:
     - `tests/test_main.py`（pytest）: main.pyのジョブ生成・SSEストリーム・停止・一時停止/再開のOS分岐をカバー
     - `.github/workflows/test.yml`: push・PRごとにVitest(35件)+pytest(8件)をwindows-latest/macos-latest両方で自動実行
     - ついでに`tests/command-builder.test.js`の既存の壊れたテスト（'#'除去確認）を修正済み
  次回セッションはこのSTATUS.mdとDECISIONS.mdを読めば経緯を追える。GitHub ActionsのActionsタブでCI結果を確認してから作業を始めること。
