# DECISIONS — 設計判断の記録

コードを読んでも分からない「なぜこうしたか」を記録する。
1判断 = 日付 + 数行。新しいものを上に追記。作業履歴は書かない(git log が担う)。

---

## 2026-08-19 pytestの対象を main.py のロジックのみに絞り、実プロセス起動はモック化した
- 判断: `tests/test_main.py` では `asyncio.create_subprocess_shell` をモックして偽のプロセス（stdout行・returncodeを差し替え可能な `_FakeProcess`）を返すようにし、実際にgallery-dlを起動するテストは書かない
- 理由: CI環境（GitHub Actions）にgallery-dl本体をインストールする手間・バージョン差異による不安定化を避けたい。main.py側で検証したいのはジョブのライフサイクル管理（生成・SSE配信・クリーンアップ・停止）であり、gallery-dl自体の動作はgallery-dl側の責務
- 代替案: 実際にgallery-dlをCIにインストールしてE2Eテストする → 却下。Xへの実ログインが必要になり自動化が困難なため見送り

## 2026-08-19 pause/resumeのOS分岐テストは sys.platform をモックせず実行環境の値をそのまま使う
- 判断: `test_pause_platform_gating` 等は `monkeypatch.setattr(sys, "platform", ...)` で偽装せず、CI実行環境（windows-latest / macos-latest）の実際の `sys.platform` に応じてテスト内の期待値を分岐させる
- 理由: モックで偽装すると「Windowsだと信じ込ませたLinux上のテスト」になり、実際のOS依存動作を検証したことにならない。GitHub Actionsのマトリクスで実Windows・実Mac双方のランナーを使う今回の構成なら、モックせずに実環境の分岐を検証する方が意味がある
- 代替案: モックで両分岐を1ランナーで検証 → 却下。実行速度は上がるが、実OSでの検証という今回の目的（Windows作業がMacを壊していないかの自動検知）に反する

---

## 2026-08-19 Windows対応: シェル文字列生成をやめ、argvリスト実行に移行する方針を決定
- 判断: `app/index.html` + `app/main.py` の実行経路は、シェル文字列を組み立てて `create_subprocess_shell` に渡す方式をやめ、引数配列を組み立てて `create_subprocess_exec` に渡す方式(シェルを介さない)に移行する。`src/gallery-dl-commander.html` と `editions/kraftwerk/` はコピペ専用ツール(実行機能なし)なので対象外とし、OS判定によるクォート文字切り替えのみ行う
- 理由: 既存の `shellQuote()`(POSIXシングルクォートエスケープ)がWindowsの `cmd.exe` では引用符がそのまま文字として渡ってしまい `Unsupported URL ''https://...''` のようなエラーを起こすことを実機で確認した。シェル文字列を組み立てる限り、bash向けとcmd.exe向けでクォート方式が根本的に異なり、今後も同種の互換性バグが再発するリスクがある。argv実行にすればシェルの解釈自体が発生しないため、引用符・エスケープ・行継続(`\`)の問題が原理的に消える
- 代替案:
  - OS判定でクォート文字を切り替えるだけ(シェル文字列のまま) → 却下。cmd.exeの `&`/`|`/`%VAR%` によるインジェクションには対応できず、対症療法に留まる
  - Firefoxへの乗り換え(Cookie問題の回避策として検討) → ユーザーがFirefoxのインストールを希望せず却下。手動 `cookies.txt` エクスポート方式を採用(下記参照)
- 影響範囲の注意: `main.py` と `app/index.html` はMac/Windows共通コードのため、この変更はMac側にも影響しうる（`~` のチルダ展開はシェルではなくサーバー側で `os.path.expanduser()` により明示的に行う必要がある、複数ハッシュタグの逐次実行ロジックも書き換えが必要）。実装前にCI回帰テスト基盤(下記)を先に構築することにした

## 2026-08-19 Windows回帰テストをGitHub Actionsのマトリクス(windows-latest / macos-latest)で自動化する方針を決定
- 判断: `tests/command-builder.test.js`(Vitest)に加え、`app/main.py` 用のpytestスイートを新設し、GitHub Actionsで `windows-latest` と `macos-latest` の両方を回すマトリクスCIを構築する。argvリスト実行への移行(上記)は、このCI基盤を先に整えてから着手する
- 理由: Windows側のセッションからはMacの実機検証ができない。GitHub Actionsの実Macランナー上で自動テストを回せば、Windows対応の変更がMac側の挙動(チルダ展開・複数ハッシュタグ逐次実行など)を壊していないか、都度自動確認できる
- 代替案: 手動でのMac側回帰テスト(ユーザーが別セッションで都度確認) → 継続的に発生する確認コストが高く、見落としリスクもあるため、自動化を優先

## 2026-08-19 Windows で Chrome/Edge の `--cookies-from-browser` 自動読み取りが使えないことが判明
- 判断: Windows環境では、gallery-dlの `-C/--cookies` オプションで手動エクスポートした `cookies.txt` を使う方式を暫定の回避策とする（`--cookies-from-browser chrome/edge` の自動読み取りは使わない）
- 理由: Chrome(v127+)・Edge(v133+)ともにApp-Bound Encryptionを採用しており、gallery-dl（2026-08時点の最新版でも）はこれを復号できない。Cookieファイルのロック問題（ブラウザを閉じれば回避可）とは別の、復号そのものが不可能な問題。gallery-dlの公式CHANGELOGにも対応した形跡なし
- 代替案:
  - Firefoxへの乗り換え（App-Bound Encryption非対応のため動作する）→ ユーザーがFirefoxインストールを希望せず却下
  - Edgeに一本化 → 当初はこれで回避できると判断したが、EdgeもApp-Bound Encryptionを導入済みと判明し誤りだった（要修正: 過去のセッションでEdgeを推奨した経緯があるため、関連ドキュメントがあれば要訂正）
