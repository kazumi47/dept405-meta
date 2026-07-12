#!/usr/bin/env bash
# dept405-meta の skills/ を ~/.claude/skills/ にシンボリックリンクとして配布する。
# 正本は常にこのリポジトリの skills/ 配下。git pull するだけで全プロジェクトに反映される。
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="${REPO_DIR}/skills"
SKILLS_DST="${HOME}/.claude/skills"

if [ ! -d "${SKILLS_SRC}" ]; then
  echo "エラー: ${SKILLS_SRC} が見つかりません" >&2
  exit 1
fi

mkdir -p "${SKILLS_DST}"

for skill_path in "${SKILLS_SRC}"/*/; do
  skill_name="$(basename "${skill_path}")"
  target="${SKILLS_DST}/${skill_name}"

  if [ -L "${target}" ]; then
    echo "既存リンクを張り替え: ${target}"
    rm "${target}"
  elif [ -e "${target}" ]; then
    echo "エラー: ${target} はシンボリックリンクではない実体フォルダです。手動で確認・退避してから再実行してください。" >&2
    exit 1
  fi

  ln -s "${skill_path%/}" "${target}"
  echo "リンク作成: ${target} -> ${skill_path%/}"
done

echo ""
echo "完了。確認: ls -la ${SKILLS_DST}"
