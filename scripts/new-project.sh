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

echo ""
echo "完了: ${PROJECT_DIR}"
echo ""
echo "skills/ はコピーしていません。~/.claude/skills/ のシンボリックリンク（install.sh 済みなら）が全プロジェクトで有効です。"
echo "公開予定プロジェクトに同梱したい場合のみ、このプロジェクトの .claude/skills/ へ個別にコピーしてください。"
