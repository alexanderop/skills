#!/usr/bin/env bash
# emit_event.sh — append one JSON line to $FACTORY_RUN_DIR/events.jsonl.
# Usage: bash tools/emit_event.sh <step> <status> [detail]
#   step:   plan | ralph | review | pr
#   status: START | DONE | FAIL | RETRY | BLOCKED | PAUSED
#   detail: optional free-form string (will be JSON-escaped)
#
# The manifest is derived from this log; never hand-edit either file.

set -euo pipefail

if [[ -z "${FACTORY_RUN_DIR:-}" ]]; then
  echo "error: FACTORY_RUN_DIR not set" >&2
  exit 2
fi

if [[ $# -lt 2 ]]; then
  echo "usage: $0 <step> <status> [detail]" >&2
  exit 2
fi

STEP="$1"
STATUS="$2"
DETAIL="${3:-}"

TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# JSON-escape the detail string (quotes, backslashes, control chars).
# Uses python because it's everywhere; if you don't have python, swap for jq.
ESCAPED_DETAIL="$(
  python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$DETAIL"
)"

LINE="{\"ts\":\"$TS\",\"step\":\"$STEP\",\"status\":\"$STATUS\",\"detail\":$ESCAPED_DETAIL}"

echo "$LINE" >> "$FACTORY_RUN_DIR/events.jsonl"
echo "$LINE"
