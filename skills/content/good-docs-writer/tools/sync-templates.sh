#!/usr/bin/env bash
# Re-sync bundled Good Docs Project templates from gitlab.com/tgdp/templates.
# Run from anywhere; resolves paths relative to the script.
#
# Usage:
#   bash skills/good-docs-writer/tools/sync-templates.sh [branch-or-tag]
#
# Defaults to `main`. To pin a release: `bash sync-templates.sh v1.5.0`

set -euo pipefail

REF="${1:-main}"
BASE="https://gitlab.com/tgdp/templates/-/raw/${REF}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REFS_DIR="$SCRIPT_DIR/../references"
TEMPLATES_DIR="$REFS_DIR/templates"

KEYS=(concept tutorial how-to quickstart troubleshooting reference glossary release-notes installation-guide api-getting-started)

echo "Syncing from $BASE → $TEMPLATES_DIR"

for key in "${KEYS[@]}"; do
  mkdir -p "$TEMPLATES_DIR/$key"
  curl -fsSL "$BASE/$key/template_$key.md" -o "$TEMPLATES_DIR/$key/template.md" &
  curl -fsSL "$BASE/$key/guide_$key.md"    -o "$TEMPLATES_DIR/$key/guide.md" &
done

curl -fsSL "$BASE/STYLE-GUIDE.md"  -o "$REFS_DIR/style-guide.md" &
curl -fsSL "$BASE/writing-tips.md" -o "$REFS_DIR/writing-tips.md" &
curl -fsSL "$BASE/LICENSE"         -o "$TEMPLATES_DIR/LICENSE" &

wait

# Stamp the README with today's date so provenance stays honest.
DATE="$(date +%Y-%m-%d)"
sed -i.bak -E "s/on \*\*[0-9]{4}-[0-9]{2}-[0-9]{2}\*\*/on **$DATE**/" "$TEMPLATES_DIR/README.md" && rm "$TEMPLATES_DIR/README.md.bak"

echo "Synced. Bump metadata.version in skills/good-docs-writer/SKILL.md before publishing."
