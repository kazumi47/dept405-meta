# DEPT.405 - Meta Repository

> DEPT.405 の開発の型（skills）・テンプレート・振り返りを集約する、横断ドキュメントリポジトリ

---

## 3分ブートストラップ

```bash
# 1. このリポジトリを clone（済みならスキップ）
git clone <this-repo> && cd dept405-meta

# 2. skills を ~/.claude/skills/ にシンボリックリンクとして配布（初回のみ・以後は git pull だけで全環境に反映）
./install.sh

# 3. 新規プロジェクトの雛形を生成
./scripts/new-project.sh my-new-project [作成先ディレクトリ]

# 4. 生成されたプロジェクトで Claude Code を起動
cd my-new-project
claude
```

`install.sh` はシンボリックリンクを張るだけなので、このリポジトリを `git pull` すれば **全プロジェクト・全環境の skills が同時に最新化される**。プロジェクトごとに skills をコピーする必要はない。

---

## DEPT.405 とは

**DEPT.405** は、ソロインディー開発者「わたし」の創作・開発レーベル。

### 制作カテゴリ

- **創作系**：役に立たないけど役に立つかもしれない、無意味を愛でる
- **プロダクト系**：実用的なユーティリティアプリ

### 開発スタイル

- 1 人 + AI（Claude Code / Antigravity / Claude.ai を用途別に使い分け）
- AI 駆動開発 × Spec-Driven Development（SDD）
- ノンエンジニアのバイブコーディング × SIer 出身の上流工程経験

---

## このリポジトリの目的

複数プロジェクトを並走する中で、**横断的な開発の型・テンプレート・振り返りを一元管理**する。

- 各プロジェクトのリポジトリは別々
- このリポジトリは「メタな情報」（skills、テンプレート、振り返り、思想）を集約
- 正本はこのリポジトリのみ。配布はシンボリックリンク（skills）とコピー（templates）で行う

---

## skills 一覧

`skills/` 配下が実務手順の正本。`install.sh` で `~/.claude/skills/` にリンクされ、Claude Code が状況に応じて自動的に読み込む。

| skill | 一言 | 発火場面 |
|---|---|---|
| `spec-driven-dev` | AI エージェントに実装を委任するプロジェクトの立ち上げ・運営の型 | 新規プロジェクト開始、要件定義、コンセプト作成、CLAUDE.md・decisions.md・roadmap の整備、DoD 設計 |
| `llm-eval-cycle` | 正解が曖昧な領域で LLM 出力の品質を評価・改善する評価サイクル設計 | ゴールデンセット、LLM-as-a-Judge、ルーブリック、ブラインド A/B、モデル選定 |
| `noise-catalog-jp` | 日本語テキスト検索・コーパス収集で発生する既知のノイズ型カタログと対策 | 日本語コーパスの検索・RAG 前処理設計、誤爆・ヒット数異常・表記ゆれの調査 |
| `security-baseline` | AI 支援開発で「動くが安全ではない」コードを出荷しないためのセキュリティ基本方針 | 認証・認可・DB・ファイルアップロード等の実装、リリース前レビュー、脆弱性修正 |

各 skill の詳細は `skills/<name>/SKILL.md` を参照。

---

## ディレクトリ構造

```
dept405-meta/
├── README.md                      # このファイル
├── install.sh                     # skills を ~/.claude/skills/ へシンボリックリンク配布
├── skills/                        # 開発の型（正本）。4 skill を格納
│   ├── spec-driven-dev/
│   ├── llm-eval-cycle/
│   ├── noise-catalog-jp/
│   └── security-baseline/
├── scripts/
│   └── new-project.sh             # 新規プロジェクトの雛形生成
├── templates/
│   ├── CLAUDE.md.template
│   ├── concept.md.template
│   ├── requirements.md.template
│   ├── design.md.template
│   ├── decisions.md.template
│   ├── tasks.md.template
│   └── roadmap.md.template
├── guidelines/
│   └── dept405_development_guideline.md   # 思想・背景・DEPT.405 の価値観（手順は skills/ へ移譲済み）
└── retrospectives/
    └── （各プロジェクトの振り返り、1 プロジェクト 1 ファイル）
```

---

## 運用ループ

DEPT.405 の開発は、1 プロジェクトの完了で終わらない。学びを型として蓄積し、次のプロジェクトに引き継ぐ。

```
プロジェクト完了
  → retrospective 1 枚を retrospectives/ に書く（何を学んだか）
  → 学びを該当する skills/ に追記する（型として汎化する）
  → git push で全プロジェクト・全環境の skills が更新される
```

新規プロジェクト開始時はこの逆で、`new-project.sh` でテンプレートを引き、既存 skills を Claude Code が自動的に参照しながら実装が進む。

### 新規プロジェクトへの skills 同梱について

`new-project.sh` は skills をコピーしない。`install.sh` 済みの環境では `~/.claude/skills/` のシンボリックリンクが全プロジェクトで有効なため、個別プロジェクトへの同梱は不要。

**例外**: 公開予定のプロジェクト（他者が clone して単体で動かす想定のもの）に skills を同梱したい場合のみ、そのプロジェクトの `.claude/skills/` へ個別にコピーする。

---

## 使い方（詳細）

### 新規プロジェクト開始時

1. `./scripts/new-project.sh <プロジェクト名> [作成先]` を実行（フォルダ作成・`git init`・テンプレート複製・`docs/` 構成まで自動）
2. `docs/concept.md` からプロジェクト固有の内容に書き換える
3. `git push` で新プロジェクトのリポジトリに反映

### 開発の型・手順を確認したい時

- 実務手順は `skills/<name>/SKILL.md` を参照（Claude Code は状況に応じて自動的に読み込む）
- 思想・背景・DEPT.405 の価値観は [guidelines/dept405_development_guideline.md](./guidelines/dept405_development_guideline.md) を参照

### 過去の振り返りを見たい時

- [retrospectives/](./retrospectives/) を参照

---

## 関連プロジェクト

### プロダクト（実用系）

- [print-zenroku](https://github.com/kazumi47/print-zenroku) - 学校から持ち帰るプリントを、撮影から一時仕分け・親子での確認・保管・処分まで一元管理する
- [ballet-note](https://github.com/kazumi47/ballet-note) - バレエ練習記録
- [kaimono-go](https://github.com/kazumi47/kaimono-go) - スッキリごはん（レシートの読み取りで食材在庫を更新、AIが栄養を考慮し献立と買い足しを提案するアプリ）
- [jhan-secretary](https://github.com/kazumi47/jhan-secretary) - Discord 開発秘書 bot
- [sukkiri-days-pwa](https://github.com/kazumi47/sukkiri-days-pwa) - すっきりデイズ（ズボラ向け食事と顔を撮るだけ健康管理）

### 創作系

- [my-other-life](https://github.com/kazumi47/my-other-life) - 第2の人生
- [furari-gohan](https://github.com/kazumi47/furari-gohan) - ふらり世界のおうちごはん

---

## ライセンス

このリポジトリ内のガイドライン・テンプレート・skills は、自由に参考にしていただいて構いません。
（公式なライセンス設定は今後検討）

---

## 更新履歴

- **v2（2026-07-12）**: Skills 化・symlink 配布・学びの循環ループ復活。`skills/`（spec-driven-dev / llm-eval-cycle / noise-catalog-jp / security-baseline）新設、`install.sh` / `scripts/new-project.sh` 追加、CLAUDE.md.template の内容重複バグ修正とセキュリティ絶対要件の転記、`concept.md.template` 追加、開発ガイドラインを思想編に縮小、retrospectives/ 実体化
- **2026-05-19**: 初版作成（ガイドライン、テンプレート 5 種）
