# サプライチェーンと AI エージェントの運用

「コードは無事でも、設定・運用・依存で破られる」領域。依存追加時と Claude Code の権限整備時に読む。

## 目次
- §1 サプライチェーン3層と実際の事件
- §2 外部スクリプト（CDN 経由 JS）
- §3 MCP サーバー
- §4 Cloud 設定と Secrets 管理
- §5 コードを「動かす」AI エージェントのリスク
- §6 Claude Code: 設定すべき5項目

## §1 サプライチェーン3層と実際の事件

依存の汚染は3層で起きる: ①パッケージ（npm / pip）②外部スクリプト（CDN 経由 JS）③MCP サーバー。
`npm install` 自体が攻撃の実行トリガーになる。

npm を狙う3つの攻撃型（講義資料 2026年時点の事例。出典例: Google Threat Intelligence /
Microsoft Security / Datadog Security Labs, 2025–2026）:

| 型 | 事例 | 手口 |
|---|---|---|
| ① メンテナーアカウント乗っ取り | Axios 事件（2026年3月） | 正規メンテナーの認証情報窃取 → バックドア入りバージョン公開 → `npm install` した全環境で自動実行。週1億 DL 超のライブラリが約3時間で汚染。北朝鮮（UNC1069）との関連が指摘 |
| ② 自己増殖ワーム | Shai-Hulud（2025年9月〜） | 感染パッケージが npm トークンを窃取 → そのトークンで他パッケージを汚染 → 連鎖感染。796 パッケージに影響 |
| ③ タイポスクワッティング | Microsoft 検知（2026年5月） | 本物に似た名前で偽パッケージを公開（例: `opensearch-setup`）。14 パッケージを短時間に一斉公開、インストール時に AWS 認証情報を窃取。似た名前ほどレビューで見落とされやすい |

狙われるもの: npm token / GitHub PAT / AWS credentials / SSH 秘密鍵 / CI/CD シークレット。

対策:
- `npm ci` ＋ lockfile 固定（`package-lock.json` をコミットし、CI では `npm ci` を使う）
- `npm audit` / `pip-audit` を CI・リリース前チェックに組み込む（Critical/High ゼロが出荷条件）
- バージョンを自動追従しない（`^` `~` の無邪気な最新追従をやめ、更新は意図して行う）
- パッケージ追加時は名前のスペル・公開者・DL 数・更新履歴を確認する

## §2 外部スクリプト: polyfill.io 事件の教訓

**外部スクリプトを1行読み込む＝その配信元を信頼すると宣言している。**
自分のサーバーは一度もハッキングされていなくても、配信元が危険化すれば自サイトが汚染される。

タイムライン（出典: 各社公式告知・Sansec、2026年6月時点）:
2024年2月 Funnull が polyfill.io ドメインを買収 → 2024年6月 10万以上のサイトへの攻撃が発覚 →
2024年後半 ドメイン停止（DNS 停止）→ **2026年5月 ドメインが GoDaddy へ移管・再稼働** →
2026年6月 日本企業サイト（無印良品・東芝・象印マホービン・ほぼ日ほか）で不審な認証画面が続発。
外部参照が残っていたページで、ブラウザ標準の認証ダイアログが表示された。

教訓: **「対応済み」のつもりでも、参照が残れば2年後に再被害。**

対策チェック: □ 外部スクリプトの棚卸し □ 不要なら削除 □ SRI（Subresource Integrity）□ CSP

## §3 MCP サーバー: npm パッケージと同じ危険を持つ

開発者が MCP サーバーを追加 → Claude Code 等が接続、の先に3つのリスク:

| リスク | 内容 |
|---|---|
| ① Prompt Injection | ツールのドキュメント・返却値内の悪意ある文字列が LLM を誘導 → 意図しないコマンド実行・ファイル送信 |
| ② Tool Poisoning | Day1 は安全に見えたツールが、Day7 には API キー転送へ改変される（更新で豹変） |
| ③ 野良 MCP サーバー | preinstall hook 等で悪意ある MCP サーバーを自動登録 |

実際の CVE 事例（講義資料 2026年時点）: CVE-2026-30615（Windsurf の Prompt Injection → RCE）、
2026年初頭までに MCP 関連で 30 以上の CVE、最高 CVSS 9.6（CVE-2025-6514）。
公開 MCP サーバー約 7,000 台のうち半数が認証なしで動作（2026年初頭）。

対策チェック: □ 公式・信頼できるソースの MCP のみ使用 □ 組織管理する場合は
`allowManagedMcpServersOnly` 相当の管理設定を有効化 □ PreToolUse フックで実行前バリデーション
□ MCP 追加は依存追加と同じ重みで審査する（公開者・権限・更新履歴）

## §4 Cloud 設定と Secrets 管理

**設定差分はコードレビューだけでは見えない → IaC / Cloud 設定も診断範囲に含める。**

Cloud / Config でありがち: S3（R2 等 S3 互換含む）バケットの意図しない公開設定・
デバッグエンドポイントの本番残存・過剰な IAM 権限。
確認例: `aws s3api get-bucket-acl --bucket [name]`（R2 は Cloudflare ダッシュボードの公開設定）。

Secrets でありがち: .env をそのまま GitHub に push・API キーがフロントのソースに露出・
環境変数の中身がログに出力。

対策:
- Secrets は Secrets 管理サービス（Vercel/Cloudflare の環境変数、AWS Secrets Manager / Vault 等）へ。
  ローカルの .env は .gitignore 必須
- シークレットは「隠す」だけでなく **ローテーション・失効まで設計する**（漏えい時に無効化できるか）
- 一度でもコミットした秘密は「漏えい済み」として扱う——履歴から消すのではなく **鍵自体を無効化・再発行**

## §5 コードを「動かす」AI エージェントのリスク

コードを「書く」AI（補完系）は人間がレビューしてから実行するが、コーディングエージェント
（Claude Code 等）はターミナル・ファイル・ネットワーク・Git を自律操作する。
**エージェントは、攻撃者が侵入したのと同じ権限を持ち得る**——「AI が変なコードを書く」問題ではなく、
「AI が自律的に動いてしまう」インフラ・運用の問題。

5つのリスク:
1. 破壊的コマンドの自律実行（`rm -rf *` / `chmod 777` / `git push --force`）——デフォルトでは deny ルールなし
2. 機密ファイルへの無制限アクセス（.env / AWS credentials / SSH 秘密鍵 / *.pem）
3. 意図しない外部ネットワーク送信（Prompt Injection → `curl` で機密送信）——ネットワーク制限なしでは防げない
4. bypassPermissions による権限チェック回避（`--dangerously-skip-permissions`）——常用すると防御が崩壊
5. MCP サーバー経由の権限逸脱（§3）

## §6 Claude Code: 設定すべき5項目

設定ファイル: プロジェクトの `.claude/settings.json`（またはユーザー共通の `~/.claude/settings.json`）。
`/permissions` と `/sandbox` で現在の権限を定期棚卸しする。
**注意: 設定キーはバージョンで変わるため、適用前に公式ドキュメント
（https://code.claude.com/docs/en/permissions）で確認すること。** 以下は 2026年時点の形。

```jsonc
{
  "permissions": {
    // ② 危険コマンドを deny ルールでブロック（評価順: deny → ask → allow）
    // ③ 機密ファイルの読み取りを拒否
    "deny": [
      "Bash(rm -rf *)",
      "Bash(sudo *)",
      "Bash(git push --force *)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(**/*.pem)",
      "Read(**/*.key)",
      "Read(**/secrets/**)"
    ],
    // git push は deny ではなく ask に——DEPT.405 運用（区切りで確認して push）と両立させる
    "ask": [
      "Bash(git push *)"
    ],
    // ④ bypassPermissions モードを無効化（--dangerously-skip-permissions の使用を禁止）
    "disableBypassPermissionsMode": "disable"
  },
  // ① sandbox を有効化（最重要）: OS レベルで Bash の実行を隔離
  "sandbox": {
    "enabled": true,
    "allowUnsandboxedCommands": false,
    "filesystem": {
      "denyRead": ["~/.ssh", "~/.aws", "~/.config/gcloud"]
    },
    // ⑤ ネットワークアクセスを allowlist 管理: Prompt Injection 経由の外部送信を防ぐ
    "network": {
      "allowedDomains": ["github.com", "*.npmjs.org", "registry.npmjs.org", "pypi.org"]
    }
  }
}
```

補足:
- permissions の Read deny は Claude のファイルツールを止めるが、サブプロセス（python スクリプト等）
  の読み取りまでは止めない。OS レベルで塞ぐのが sandbox の `filesystem.denyRead`——**両方使う**
  （多層防御）。
- allowedDomains はプロジェクトで実際に必要なドメインだけを足していく（deny-by-default）。
- 上の deny 例は最小セット。プロジェクト固有の危険操作（本番 DB への接続コマンド等）があれば足す。
