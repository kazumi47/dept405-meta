# DEPT.405 - Meta Repository

> DEPT.405 の開発ガイドライン・テンプレート・振り返りを集約する、横断ドキュメントリポジトリ

---

## DEPT.405 とは

**DEPT.405** は、ソロインディー開発者「あーし」の創作・開発レーベル。

### 制作カテゴリ

- **創作系**：役に立たないけど役に立つかもしれない、無意味を愛でる
- **プロダクト系**：実用的なユーティリティアプリ

### 開発スタイル

- 1 人 + AI（Claude Code / Antigravity / Claude.ai を用途別に使い分け）
- AI 駆動開発 × Spec-Driven Development（SDD）
- ノンエンジニアのバイブコーディング × SIer 出身の上流工程経験

---

## このリポジトリの目的

複数プロジェクトを並走する中で、**横断的なドキュメント・ノウハウを一元管理**する。

- 各プロジェクトのリポジトリは別々
- このリポジトリは「メタな情報」（ガイドライン、テンプレート、振り返り）を集約

---

## ディレクトリ構造

```
dept405-meta/
├── README.md                 # このファイル
├── guidelines/
│   └── development-guideline.md   # 開発の進め方ガイドライン
├── templates/
│   ├── CLAUDE.md.template
│   ├── requirements.md.template
│   ├── design.md.template
│   ├── decisions.md.template
│   └── tasks.md.template
└── retrospectives/
    └── (各プロジェクトの振り返り、跨いだ学び)
```

---

## 使い方

### 新規プロジェクト開始時

1. **GitHub で新規リポジトリを作成**（プロジェクト名で）
2. **このリポジトリから必要なテンプレートをコピー**
   - `templates/CLAUDE.md.template` → 新プロジェクトの `CLAUDE.md`
   - `templates/requirements.md.template` → 新プロジェクトの `docs/requirements.md`
   - 同様に他のテンプレートも
3. **プロジェクト固有の情報に書き換える**
4. **新プロジェクトのリポジトリにプッシュ**

### 開発ルールを確認したい時

- [guidelines/development-guideline.md](./guidelines/development-guideline.md) を参照

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

このリポジトリ内のガイドラインとテンプレートは、自由に参考にしていただいて構いません。  
（公式なライセンス設定は今後検討）

---

## 更新履歴

- **2026-05-19**: 初版作成（ガイドライン、テンプレート 5 種）
