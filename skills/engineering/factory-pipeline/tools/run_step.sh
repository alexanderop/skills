#!/usr/bin/env bash
# run_step.sh — invoke the configured coding harness with a step prompt.
#
# Usage:
#   bash tools/run_step.sh <harness> <step> [extra_context_file]
#
#   harness:           claude | codex | copilot
#   step:              plan | ralph | review | pr  (must match a file in steps/)
#   extra_context_file (optional): path to a file whose contents are appended
#                                  to the prompt. Used by `ralph` to pass the
#                                  specific ticket file.
#
# Reads:
#   $FACTORY_RUN_DIR (must be set)
#   <skill-dir>/steps/<step>.md
#
# Writes:
#   $FACTORY_RUN_DIR/prompts/<step>.txt          (assembled prompt, for audit)
#   $FACTORY_RUN_DIR/<step>.stdout               (raw harness stdout+stderr)
#
# Exit code propagates from the harness.

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "usage: $0 <harness> <step> [extra_context_file]" >&2
  echo "  harness: claude | codex | copilot" >&2
  exit 2
fi

HARNESS="$1"
STEP="$2"
EXTRA="${3:-}"

: "${FACTORY_RUN_DIR:?FACTORY_RUN_DIR not set; run init_run.sh first}"

# Resolve the skill's own root so this works regardless of cwd.
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STEP_FILE="$SKILL_DIR/steps/$STEP.md"

if [[ ! -f "$STEP_FILE" ]]; then
  echo "error: no step prompt at $STEP_FILE" >&2
  exit 2
fi

# Preflight: harness binary must be on PATH.
if ! command -v "$HARNESS" >/dev/null 2>&1; then
  echo "error: harness binary '$HARNESS' not found on PATH" >&2
  echo "       install it, or pass --harness with one of: claude | codex | copilot" >&2
  exit 127
fi

# Build the prompt: step body + run-dir context + optional extra (e.g. ticket).
PROMPT_DIR="$FACTORY_RUN_DIR/prompts"
mkdir -p "$PROMPT_DIR"
PROMPT_FILE="$PROMPT_DIR/$STEP.txt"

{
  cat "$STEP_FILE"
  echo
  echo "---"
  echo "FACTORY_RUN_DIR=$FACTORY_RUN_DIR"
  if [[ -n "$EXTRA" ]]; then
    if [[ ! -f "$EXTRA" ]]; then
      echo "error: extra context file not found: $EXTRA" >&2
      exit 2
    fi
    echo "EXTRA_CONTEXT_FILE=$EXTRA"
    echo
    echo "## Additional context"
    echo
    cat "$EXTRA"
  fi
} > "$PROMPT_FILE"

PROMPT="$(cat "$PROMPT_FILE")"
STDOUT_FILE="$FACTORY_RUN_DIR/$STEP.stdout"

# Dispatch. The flags come from each CLI's headless / non-interactive mode.
# Permissions are set to "skip" — the orchestrator already gates artifacts,
# and an inner prompt for permission would deadlock a non-interactive run.
case "$HARNESS" in
  claude)
    # claude -p reads the prompt from argv; --dangerously-skip-permissions
    # disables interactive permission prompts in headless mode.
    claude --dangerously-skip-permissions -p "$PROMPT" 2>&1 | tee "$STDOUT_FILE"
    ;;
  codex)
    # `codex exec` is the non-interactive mode; the bypass flag mirrors
    # claude's skip and is required for unattended runs.
    codex exec --dangerously-bypass-approvals-and-sandbox "$PROMPT" 2>&1 | tee "$STDOUT_FILE"
    ;;
  copilot)
    # `-p` is GitHub Copilot CLI's non-interactive prompt; --allow-all
    # is the unattended-permissions flag.
    copilot --allow-all -p "$PROMPT" 2>&1 | tee "$STDOUT_FILE"
    ;;
  *)
    echo "error: unknown harness '$HARNESS' (use: claude | codex | copilot)" >&2
    exit 2
    ;;
esac
