#!/usr/bin/env bash
set -euo pipefail

# Prints the skill directories declared in .claude-plugin/plugin.json.
REPO="$(cd "$(dirname "$0")/.." && pwd)"

node -e '
  const fs = require("fs");
  const path = require("path");
  const repo = process.argv[1];
  const manifest = JSON.parse(fs.readFileSync(path.join(repo, ".claude-plugin/plugin.json"), "utf8"));
  for (const rel of manifest.skills) {
    const dir = path.resolve(repo, rel);
    const ok = fs.existsSync(path.join(dir, "SKILL.md"));
    console.log(`${ok ? "ok " : "MISSING "} ${path.basename(dir).padEnd(20)} ${rel}`);
  }
' "$REPO"
