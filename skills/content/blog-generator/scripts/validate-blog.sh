#!/usr/bin/env bash
# validate-blog.sh — deterministic structural checks for a generated blog-*.html.
#
# Usage: bash validate-blog.sh <path/to/blog-foo.html>
# Exits 0 on PASS, non-zero on first failure.

set -uo pipefail

if [ $# -ne 1 ]; then
  echo "usage: $0 <blog-foo.html>" >&2
  exit 2
fi

FILE="$1"
PASSED=0
FAILED=0
FAILURES=()

pass() { PASSED=$((PASSED+1)); echo "  ✓ $1"; }
fail() { FAILED=$((FAILED+1)); FAILURES+=("$1"); echo "  ✗ $1" >&2; }

echo "Validating $FILE"

# 1. file exists, ends in .html
if [ ! -f "$FILE" ]; then
  fail "file does not exist: $FILE"; echo; echo "Result: FAIL"; exit 1
fi
case "$FILE" in
  *.html) pass "file exists and is .html" ;;
  *) fail "expected .html suffix" ;;
esac

# 2. doctype on line 1
if head -1 "$FILE" | grep -qi '^<!doctype html>'; then
  pass "doctype html"
else
  fail "first line is not <!doctype html>"
fi

# 3. <html lang="en" class="dark">
if grep -q '<html lang="en" class="dark">' "$FILE"; then
  pass "html.dark default"
else
  fail '<html lang="en" class="dark"> missing — dark must be default'
fi

# 4. skin tokens defined for both dark (:root) and light (html.light)
DARK_TOKEN=$(grep -c '^\s*:root' "$FILE" || true)
LIGHT_TOKEN=$(grep -c 'html\.light' "$FILE" || true)
if [ "$DARK_TOKEN" -ge 1 ] && [ "$LIGHT_TOKEN" -ge 1 ]; then
  pass "skin tokens (dark + light) defined"
else
  fail "skin tokens missing — need :root (dark) and html.light blocks"
fi

# 5. theme toggle button
if grep -q 'id="theme-btn"' "$FILE"; then
  pass "theme toggle button present"
else
  fail '#theme-btn missing'
fi

# 6. >= 3 mermaid diagrams
MERMAID_COUNT=$(grep -c '<div class="mermaid"' "$FILE" || true)
if [ "$MERMAID_COUNT" -ge 3 ]; then
  pass "$MERMAID_COUNT mermaid diagrams (>=3)"
else
  fail "only $MERMAID_COUNT mermaid diagrams (need >=3)"
fi

# 7. every <pre><code …> has a language- class — python regex
LANG_REPORT=$(python3 - "$FILE" <<'PY'
import re, sys
src = open(sys.argv[1]).read()
all_blocks = re.findall(r'<pre><code\b[^>]*>', src)
with_lang = [b for b in all_blocks if 'language-' in b]
print(f'{len(all_blocks)}|{len(with_lang)}')
PY
)
TOTAL_BLOCKS="${LANG_REPORT%%|*}"
LANG_BLOCKS="${LANG_REPORT##*|}"
if [ "$TOTAL_BLOCKS" -eq "$LANG_BLOCKS" ]; then
  pass "$TOTAL_BLOCKS code blocks, all have language-* class"
else
  MISSING=$((TOTAL_BLOCKS - LANG_BLOCKS))
  fail "$MISSING of $TOTAL_BLOCKS code blocks missing language-* class"
fi

# 8. TOC entries (>= 12) and anchors resolve
TOC_REPORT=$(python3 - "$FILE" <<'PY'
import re, sys
src = open(sys.argv[1]).read()
# Isolate the TOC nav
m = re.search(r'<nav id="contents"[^>]*>(.*?)</nav>', src, re.DOTALL)
if not m:
    print("0|0|MISSING_TOC")
    sys.exit(0)
toc_html = m.group(1)
hrefs = re.findall(r'href="#([^"]+)"', toc_html)
ids   = set(re.findall(r'id="([^"]+)"', src))
unresolved = [h for h in hrefs if h not in ids]
status = "OK" if not unresolved else "UNRESOLVED:" + ",".join(unresolved[:3])
print(f"{len(hrefs)}|{len(ids)}|{status}")
PY
)
TOC_COUNT="$(echo "$TOC_REPORT" | cut -d'|' -f1)"
TOC_STATUS="$(echo "$TOC_REPORT" | cut -d'|' -f3)"
if [ "$TOC_COUNT" -lt 12 ]; then
  fail "TOC has $TOC_COUNT entries (need >=12)"
elif [ "$TOC_STATUS" = "OK" ]; then
  pass "TOC: $TOC_COUNT entries, all anchors resolve"
else
  fail "TOC anchors do not resolve: $TOC_STATUS"
fi

# 9. >= 2 callouts
CALLOUT_COUNT=$(grep -c '<div class="callout"' "$FILE" || true)
if [ "$CALLOUT_COUNT" -ge 2 ]; then
  pass "$CALLOUT_COUNT callouts (>=2)"
else
  fail "only $CALLOUT_COUNT callouts (need >=2)"
fi

# 10. rebuild plan: <h4>1. through at least <h4>8.
REBUILD_HIGH=$(python3 - "$FILE" <<'PY'
import re, sys
src = open(sys.argv[1]).read()
nums = [int(m.group(1)) for m in re.finditer(r'<h4[^>]*>(\d+)\.\s', src)]
if not nums:
    print(0)
else:
    # require contiguous starting at 1
    contig = 0
    for i in range(1, max(nums) + 2):
        if i in nums:
            contig = i
        else:
            break
    print(contig)
PY
)
if [ "$REBUILD_HIGH" -ge 8 ]; then
  pass "rebuild plan: contiguous steps 1–$REBUILD_HIGH (>=8)"
else
  fail "rebuild plan: only $REBUILD_HIGH contiguous numbered steps (need 8+)"
fi

# 11. Mermaid 11 import
if grep -q 'mermaid@11' "$FILE"; then
  pass "Mermaid 11 ESM import"
else
  fail "Mermaid 11 import missing (expected mermaid@11)"
fi

# 12. Shiki 1.x import
if grep -q 'shiki@1' "$FILE"; then
  pass "Shiki 1.x ESM import"
else
  fail "Shiki 1.x import missing (expected shiki@1)"
fi

# 12b. Mermaid theme helpers must not use the malformed `rgba(${styleVar(n)} / ${a})`
#      pattern — Mermaid's theme engine parses hex only, so that string is invalid
#      and the diagrams silently fall back to Mermaid's purple/cream defaults.
#      Fix: use the hex() / rgba(n, α) helpers in assets/blog-template.html.
if grep -qF 'rgba(${styleVar(n)} / ' "$FILE"; then
  fail "broken Mermaid theme helper detected: \`rgba(\${styleVar(n)} / \${a})\` is invalid CSS — replace with the hex()/rgba(n, α) helpers from assets/blog-template.html"
else
  pass "Mermaid theme helpers use hex (no malformed rgba slash form)"
fi

# 13. .post-title class is used (the accent-colored title)
if grep -q 'class="post-title' "$FILE"; then
  pass ".post-title heading present"
else
  fail ".post-title element missing"
fi

# 14. unfilled placeholders left in?
PLACEHOLDERS=$(grep -oE '\{\{[A-Z_]+\}\}' "$FILE" | sort -u || true)
if [ -z "$PLACEHOLDERS" ]; then
  pass "no unfilled {{PLACEHOLDER}} markers"
else
  fail "unfilled placeholders: $(echo "$PLACEHOLDERS" | tr '\n' ' ')"
fi

TOTAL=$((PASSED + FAILED))
echo
if [ "$FAILED" -eq 0 ]; then
  echo "Result: PASS ($PASSED/$TOTAL checks)"
  exit 0
else
  echo "Result: FAIL ($PASSED/$TOTAL checks, $FAILED failed)"
  exit 1
fi
