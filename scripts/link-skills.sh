#!/usr/bin/env bash
set -euo pipefail

# Symlinks every skill declared in .claude-plugin/plugin.json into
# ~/.claude/skills, so the local Claude CLI can use them during development.
#
# Only manifest skills are linked — nested SKILL.md files bundled inside a
# skill's own references/ (e.g. lfg) are intentionally ignored.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$HOME/.claude/skills"

# Guard: if ~/.claude/skills is a symlink that resolves into this repo, bailing
# out avoids writing per-skill links back into the working copy.
if [ -L "$DEST" ]; then
  resolved="$(readlink -f "$DEST" 2>/dev/null || readlink "$DEST")"
  case "$resolved" in
    "$REPO"|"$REPO"/*)
      echo "error: $DEST is a symlink into this repo ($resolved)." >&2
      echo "Remove it (rm \"$DEST\") and re-run." >&2
      exit 1
      ;;
  esac
fi

mkdir -p "$DEST"

node -e '
  const fs = require("fs");
  const path = require("path");
  const repo = process.argv[1];
  const manifest = JSON.parse(fs.readFileSync(path.join(repo, ".claude-plugin/plugin.json"), "utf8"));
  for (const rel of manifest.skills) {
    console.log(path.resolve(repo, rel));
  }
' "$REPO" |
while IFS= read -r src; do
  name="$(basename "$src")"
  target="$DEST/$name"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    rm -rf "$target"
  fi
  ln -sfn "$src" "$target"
  echo "linked $name -> $src"
done
