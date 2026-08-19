# x-gallery-dl-commander
状態: Windows実機検証で複数の不具合を発見。回帰テスト基盤（pytest + GitHub Actions windows-latest/macos-latestマトリクス）構築・push済み。初回CI実行はwindows-latest/macos-latestとも green を確認済み
次の一手: argvリスト実行への移行に着手する（下記メモ4。app/index.htmlのbuildOptionLines()とmain.pyの/run・/streamが対象。既存のCI・pytestを見ながら進められる状態）
メモ: Windows実機検証で見つかった問題と対応状況（詳細な理由・代替案はDECISIONS.md参照）:
  1. cmd.exeは`\`行継続を解釈しない→main.pyでコマンド文字列を1行に正規化する対応が必要（未反映、要着手）
  2. `--config-option`は現行gallery-dlに存在しないフラグ（正しくは`--option`）。app/index.htmlのみ修正済み、src/・tests/は未修正（未反映、要着手）
  3. Chrome(v127+)・Edge(v133+)ともにApp-Bound Encryptionを採用し`--cookies-from-browser`が復号不可。暫定対応は手動`cookies.txt`エクスポート（コード未反映。UIにCookieファイルパス入力欄を追加するかは未決定）
  4. `shellQuote()`（POSIXシングルクォート）がcmd.exeでは引用符が literal に混入し `Unsupported URL` エラーになる。app/index.html+main.pyはargvリスト実行への移行（シェルを介さない `create_subprocess_exec` 方式）、src/・editions/kraftwerk/はOS判定でのクォート切り替えで対応する方針（未反映、要着手）
  5. 上記4の前提としてCI基盤を構築済み（このセッションで完了）:
     - `tests/test_main.py`（pytest）: main.pyのジョブ生成・SSEストリーム・停止・一時停止/再開のOS分岐をカバー。ただし現状は`create_subprocess_shell`をモックしているため、シェル構文（上記1・4のバグ）自体は検出できない点に注意
     - `.github/workflows/test.yml`: push・PRごとにVitest(35件)+pytest(8件)をwindows-latest/macos-latest両方で自動実行。初回実行green確認済み
     - ついでに`tests/command-builder.test.js`の既存の壊れたテスト（'#'除去確認）を修正済み
  次回セッションはこのSTATUS.mdとDECISIONS.mdを読めば経緯を追える。argvリスト実行への移行に着手する際は、まずmain.pyの`_resolve_cmd`まわりとpytestの`create_subprocess_shell`モックを`create_subprocess_exec`モックに置き換えるところから始めるとよい。
