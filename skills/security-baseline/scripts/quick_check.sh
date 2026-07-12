#!/usr/bin/env bash
# security-baseline quick check — リリース前の機械チェック
# 使い方: bash quick_check.sh [プロジェクトルート]（省略時はカレント）
# 結果は docs/security/quick_check_YYYYMMDD_HHMMSS.md に保存する。
# 注意: 機械チェックで拾えるのは一部。認可・IDOR・CSRF は grep では見つからない。
#       必ず references/release-checklist.md の全項目確認と併用すること。

set -u
ROOT="${1:-.}"
cd "$ROOT" || { echo "ディレクトリが見つからない: $ROOT"; exit 1; }

OUTDIR="docs/security"
mkdir -p "$OUTDIR"
REPORT="$OUTDIR/quick_check_$(date +%Y%m%d_%H%M%S).md"

EXCLUDES=(--exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
          --exclude-dir=build --exclude-dir=.next --exclude-dir=.venv \
          --exclude-dir=venv --exclude-dir=__pycache__ --exclude-dir=docs)
CODE=(--include='*.js' --include='*.jsx' --include='*.ts' --include='*.tsx' \
      --include='*.py' --include='*.go' --include='*.rb' --include='*.vue' --include='*.svelte')

FLAGS=0

say()  { echo "$1" | tee -a "$REPORT"; }
head_() { echo "" | tee -a "$REPORT"; say "## $1"; }
flag() { FLAGS=$((FLAGS+1)); say "⚠ $1"; }
ok()   { say "✓ $1"; }

echo "# Security Quick Check — $(date '+%Y-%m-%d %H:%M')" > "$REPORT"
say "対象: $(pwd)"
say ""
say "> 機械チェックは補助。認可・IDOR・CSRF・設計の穴は検出できない。チェックリスト全項目の確認が本体。"

head_ "1. 仮実装の残存（TODO / FIXME / HACK）"
if grep -rn "${EXCLUDES[@]}" "${CODE[@]}" -E "TODO|FIXME|HACK" . >> "$REPORT" 2>/dev/null; then
  flag "仮実装マーカーが残っている（上記参照）。認証・認可がらみの TODO は出荷前に必ず潰す"
else
  ok "仮実装マーカーなし"
fi

head_ "2. .env の Git 追跡"
if command -v git >/dev/null && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  TRACKED=$(git ls-files | grep -E '(^|/)\.env(\..+)?$' | grep -v '\.example$' || true)
  if [ -n "$TRACKED" ]; then
    flag "Git が .env を追跡している: $TRACKED — 鍵は漏えい済みとして無効化・再発行し、追跡を外す"
  else
    ok ".env は Git 追跡外"
  fi
  if [ -f .gitignore ] && grep -qE '^\s*\.env' .gitignore; then
    ok ".gitignore に .env あり"
  else
    flag ".gitignore に .env の記載が見当たらない"
  fi
else
  say "（Git リポジトリではないためスキップ）"
fi

head_ "3. 秘密情報らしきパターンのハードコード"
if grep -rn "${EXCLUDES[@]}" -E "sk-ant-[A-Za-z0-9_-]{8,}|AKIA[0-9A-Z]{16}|-----BEGIN( RSA| EC)? PRIVATE KEY" . >> "$REPORT" 2>/dev/null; then
  flag "APIキー・秘密鍵らしき文字列がコード内にある（上記参照）"
else
  ok "既知パターンの直書きは検出されず（網羅ではない）"
fi
if grep -rn "${EXCLUDES[@]}" -E "NEXT_PUBLIC_[A-Z_]*(SECRET|PRIVATE|SERVICE_ROLE)[A-Z_]*" . >> "$REPORT" 2>/dev/null; then
  flag "NEXT_PUBLIC_ に秘密らしき名前——クライアントに露出する。命名と用途を確認"
else
  ok "NEXT_PUBLIC_ の秘密らしき誤用は検出されず"
fi

head_ "4. XSS の入口候補（innerHTML 系）"
if grep -rn "${EXCLUDES[@]}" "${CODE[@]}" -E "\.innerHTML\s*=|dangerouslySetInnerHTML" . >> "$REPORT" 2>/dev/null; then
  flag "innerHTML への代入がある（上記参照）。エスケープ有無を1件ずつ確認"
else
  ok "innerHTML 直代入なし"
fi

head_ "5. 依存の監査"
if [ -f package.json ]; then
  if command -v npm >/dev/null; then
    say '```'
    npm audit --audit-level=high >> "$REPORT" 2>&1 && ok "npm audit: High 以上なし" || flag "npm audit で High 以上あり（上記参照）"
    say '```'
  else
    say "（npm が見つからないためスキップ）"
  fi
  [ -f package-lock.json ] && ok "lockfile あり" || flag "package-lock.json がない——バージョン固定できていない"
fi
if ls requirements*.txt pyproject.toml >/dev/null 2>&1; then
  if command -v pip-audit >/dev/null; then
    say '```'
    pip-audit >> "$REPORT" 2>&1 && ok "pip-audit: 検出なし" || flag "pip-audit で検出あり（上記参照）"
    say '```'
  else
    say "（pip-audit 未導入。 pip install pip-audit で導入を推奨）"
  fi
fi

head_ "結果"
if [ "$FLAGS" -eq 0 ]; then
  say "機械チェックはすべて通過。次: release-checklist.md の全項目確認へ。"
else
  say "⚠ フラグ ${FLAGS} 件。各項目を確認・修正し、横展開（同系統 grep）まで行うこと。"
fi
say ""
say "レポート: $REPORT"
