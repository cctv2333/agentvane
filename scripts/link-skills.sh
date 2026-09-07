#!/usr/bin/env bash
set -euo pipefail

# DEV-ONLY helper for maintainers of this repo. NOT a supported installer.
# Symlinks each skill into the directories the agent harnesses auto-discover:
#   - ~/.claude/skills : Claude Code
#   - ~/.agents/skills : Codex and other Agent Skills-compatible harnesses (Chatbox too)
# Each entry is a symlink into this repo, so a `git pull` is all it takes to update.
# To remove an install, delete the symlinks in those directories (not this repo).

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DESTS=("$HOME/.claude/skills" "$HOME/.agents/skills")

names=()
srcs=()
while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"
  names+=("$(basename "$src")")
  srcs+=("$src")
done < <(find "$REPO/skills" -name SKILL.md -not -path '*/node_modules/*' -print0)

for DEST in "${DESTS[@]}"; do
  mkdir -p "$DEST"
  for i in "${!names[@]}"; do
    name="${names[$i]}"
    src="${srcs[$i]}"
    target="$DEST/$name"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      rm -rf "$target"
    fi
    ln -sfn "$src" "$target"
    echo "linked $name -> $src  ($DEST)"
  done
done

echo "done. (Also works for Chatbox: it auto-discovers ~/.agents/skills)"
