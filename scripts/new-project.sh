#!/usr/bin/env bash
# dept405-meta の templates/ から新規プロジェクトの雛形を生成する。
# skills はコピーしない（~/.claude/skills/ のシンボリックリンクが全プロジェクトで有効なため。
# 公開予定プロジェクトに同梱したい場合のみ、生成後に .claude/skills/ へ個別にコピーする）。
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATES_DIR="${REPO_DIR}/templates"

if [ $# -lt 1 ]; then
  echo "使い方: $0 <プロジェクト名> [作成先ディレクトリ（省略時はカレント）]" >&2
  exit 1
fi

PROJECT_NAME="$1"
DEST_PARENT="${2:-.}"
PROJECT_DIR="${DEST_PARENT%/}/${PROJECT_NAME}"

if [ -e "${PROJECT_DIR}" ]; then
  echo "エラー: ${PROJECT_DIR} は既に存在します" >&2
  exit 1
fi

# sed の置換文字列で特殊扱いされる \, &, / をエスケープ
ESCAPED_NAME=$(printf '%s' "${PROJECT_NAME}" | sed -e 's/[\/&\\]/\\&/g')

copy_template() {
  local src="$1" dest="$2"
  sed "s/\[プロダクト名\]/${ESCAPED_NAME}/g" "${src}" > "${dest}"
  echo "作成: ${dest}"
}

mkdir -p "${PROJECT_DIR}/docs" "${PROJECT_DIR}/src" "${PROJECT_DIR}/tests"
cd "${PROJECT_DIR}"
git init -q

copy_template "${TEMPLATES_DIR}/CLAUDE.md.template" "CLAUDE.md"
copy_template "${TEMPLATES_DIR}/concept.md.template" "docs/concept.md"
copy_template "${TEMPLATES_DIR}/requirements.md.template" "docs/requirements.md"
copy_template "${TEMPLATES_DIR}/design.md.template" "docs/design.md"
copy_template "${TEMPLATES_DIR}/decisions.md.template" "docs/decisions.md"
copy_template "${TEMPLATES_DIR}/tasks.md.template" "docs/tasks.md"
copy_template "${TEMPLATES_DIR}/roadmap.md.template" "docs/roadmap.md"

# GitHubリポジトリ（private既定）を作成し、初期コミットをpushする。
# spec-driven-dev §7「こまめにコミット・push」の前提となるリモートを、
# プロジェクト開始時点で必ず用意する（リモート未作成のままpushルールだけが
# 存在する工程の歯抜けを防ぐ。出典: dragon-ball-type の運用監査）。
git add -A
git commit -q -m "chore: プロジェクト雛形を作成（dept405-meta new-project.sh）"

if command -v gh > /dev/null 2>&1 && gh auth status > /dev/null 2>&1; then
  if gh repo create "${PROJECT_NAME}" --private --source . --remote origin --push; then
    echo "GitHub: private リポジトリ ${PROJECT_NAME} を作成し、初期コミットをpushしました"
  else
    echo "警告: GitHubリポジトリの作成に失敗しました。手動で作成してください:" >&2
    echo "  gh repo create ${PROJECT_NAME} --private --source . --remote origin --push" >&2
  fi
else
  echo "警告: gh CLI が未導入または未認証のため、リモートを作成していません。" >&2
  echo "  リモート未作成のままではpush運用（spec-driven-dev §7）が機能しません。" >&2
  echo "  後で必ず実行: gh repo create ${PROJECT_NAME} --private --source . --remote origin --push" >&2
fi

echo ""
echo "完了: ${PROJECT_DIR}"
echo ""
echo "skills/ はコピーしていません。~/.claude/skills/ のシンボリックリンク（install.sh 済みなら）が全プロジェクトで有効です。"
echo "公開予定プロジェクトに同梱したい場合のみ、このプロジェクトの .claude/skills/ へ個別にコピーしてください。"
