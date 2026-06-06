#!/usr/bin/env bash
# Publish a generated blog-<slug>.html to a GitHub-Pages-backed repo.
#
# Usage:
#   bash publish-blog.sh blog-<slug>.html
#
# Env:
#   AIBLOG_DIR  Path to the local clone of the blog repo. Defaults to ~/Projects/aiBlog.
#
# Behaviour:
#   - Extracts <slug> from the filename (must match `blog-<slug>.html`).
#   - Copies the file to <AIBLOG_DIR>/<slug>/index.html (overwriting if it exists).
#   - Stages, commits, and pushes. If nothing changed, prints "already up to date".
#   - Derives the live URL from the `origin` remote (no hardcoded owner).
#   - Prints the live URL on the final line.

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: publish-blog.sh blog-<slug>.html" >&2
  exit 2
fi

src="$1"

if [ ! -f "$src" ]; then
  echo "error: file not found: $src" >&2
  exit 1
fi

base="$(basename -- "$src")"

# Filename gate: must be blog-<slug>.html.
if [[ ! "$base" =~ ^blog-([A-Za-z0-9._-]+)\.html$ ]]; then
  echo "error: filename must match 'blog-<slug>.html' (got: $base)" >&2
  exit 1
fi
slug="${BASH_REMATCH[1]}"

aiblog_dir="${AIBLOG_DIR:-$HOME/Projects/aiBlog}"

if [ ! -d "$aiblog_dir/.git" ]; then
  cat >&2 <<EOF
error: blog repo not found at: $aiblog_dir

This script publishes to a GitHub-Pages-backed repo. If you already have one
elsewhere, point the script at it:

  AIBLOG_DIR=/path/to/your/blog/clone bash publish-blog.sh "$base"

If you don't have one yet, create a public repo and enable Pages once:

  gh repo create <owner>/<repo> --public --clone --add-readme
  cd <repo>
  git push -u origin main
  gh api -X POST repos/<owner>/<repo>/pages -f 'source[branch]=main' -f 'source[path]=/'

Then re-run this script (with AIBLOG_DIR set if it's not at ~/Projects/aiBlog).
EOF
  exit 1
fi

# Derive owner/repo from origin so the live URL works for anyone.
remote_url="$(git -C "$aiblog_dir" remote get-url origin)"
if [[ "$remote_url" =~ github\.com[:/]+([^/]+)/([^/.]+)(\.git)?/?$ ]]; then
  owner="${BASH_REMATCH[1]}"
  repo="${BASH_REMATCH[2]}"
else
  echo "error: could not parse github.com owner/repo from origin: $remote_url" >&2
  exit 1
fi

dest_dir="$aiblog_dir/$slug"
dest_file="$dest_dir/index.html"

mkdir -p "$dest_dir"
cp -- "$src" "$dest_file"

# Regenerate the post list in <aiblog_dir>/index.html if it has the marker block.
# The index template wraps its <li> entries in `<!-- POSTS-START -->` / `<!-- POSTS-END -->`.
index_html="$aiblog_dir/index.html"
if [ -f "$index_html" ] && grep -q "POSTS-START" "$index_html"; then
  python3 - "$aiblog_dir" "$index_html" <<'PY'
import os, re, sys, html

aiblog_dir, index_path = sys.argv[1], sys.argv[2]

entries = []
for name in sorted(os.listdir(aiblog_dir)):
    post_index = os.path.join(aiblog_dir, name, "index.html")
    if not os.path.isfile(post_index):
        continue
    if name.startswith(".") or name in {"node_modules"}:
        continue
    with open(post_index, encoding="utf-8") as f:
        body = f.read()
    m = re.search(r"<title>([^<]*)</title>", body)
    title = html.escape((m.group(1).strip() if m else name))
    slug = html.escape(name)
    entries.append(
        f'    <li><a href="{slug}/">\n'
        f'      <div class="post-title">{title}</div>\n'
        f'      <div class="post-meta">{slug}</div>\n'
        f'    </a></li>'
    )

new_block = "\n".join(entries) if entries else "    <!-- no posts yet -->"

with open(index_path, encoding="utf-8") as f:
    index = f.read()

index = re.sub(
    r"(<!-- POSTS-START -->).*?(<!-- POSTS-END -->)",
    lambda m: m.group(1) + "\n" + new_block + "\n    " + m.group(2),
    index,
    count=1,
    flags=re.DOTALL,
)

with open(index_path, "w", encoding="utf-8") as f:
    f.write(index)
PY
fi

git -C "$aiblog_dir" add -- "$slug/index.html"
[ -f "$index_html" ] && git -C "$aiblog_dir" add -- "index.html"

live_url="https://${owner}.github.io/${repo}/${slug}/"

if git -C "$aiblog_dir" diff --cached --quiet; then
  echo "already up to date: $slug"
  echo "$live_url"
  echo "(GitHub Pages typically rebuilds in 10-30s)"
  exit 0
fi

git -C "$aiblog_dir" commit -m "publish: $slug" >/dev/null
git -C "$aiblog_dir" push origin HEAD >/dev/null

echo "published: $slug"
echo "$live_url"
echo "(GitHub Pages typically rebuilds in 10-30s)"
