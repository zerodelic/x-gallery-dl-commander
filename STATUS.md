# x-gallery-dl-commander
状態: Windows実機検証で複数の不具合を発見・一部修正中（未push、DECISIONS.md参照）
次の一手: pytest導入とGitHub Actionsのwindows-latest/macos-latestマトリクスCIを構築する（argvリスト実行への移行の前段）
メモ: Windows実機検証で見つかった問題と対応状況:
  1. cmd.exeは`\`行継続を解釈しない→main.pyでコマンド文字列を1行に正規化する対応が必要（未反映）
  2. `--config-option`は現行gallery-dlに存在しないフラグ（正しくは`--option`）。app/index.htmlのみ修正済み、src/・tests/は未修正
  3. Chrome(v127+)・Edge(v133+)ともにApp-Bound Encryptionを採用し`--cookies-from-browser`が復号不可。暫定対応は手動`cookies.txt`エクスポート（詳細はDECISIONS.md）
  4. `shellQuote()`（POSIXシングルクォート）がcmd.exeでは引用符が literal に混入し `Unsupported URL` エラーになる。app/index.html+main.pyはargvリスト実行への移行、src/・editions/kraftwerk/はOS判定でのクォート切り替えで対応する方針（DECISIONS.md参照）
  次回セッションはこのSTATUS.mdとDECISIONS.mdを読めば経緯を追える。
