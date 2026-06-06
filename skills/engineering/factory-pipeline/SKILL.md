---
name: factory-pipeline
description: >
  Run a multi-step coding pipeline (PRD → plan → ralph TDD loop → review → pr)
  by acting as an orchestrator that delegates each step to a fresh subprocess
  of the user-chosen coding harness (Claude Code, Codex, or GitHub Copilot
  CLI), gating on artifacts written under `.factory/runs/<id>/`.
  TRIGGER on: "run factory", "factory this PRD", "dogfood this PRD",
  "$factory-pipeline <prd-path>", "/factory-pipeline <prd-path>",
  or when the user hands you a PRD/plan file under `plans/` and asks to
  execute it end-to-end. Also trigger when the user names a specific harness:
  "factory this with codex", "use copilot to ralph these tickets".
allowed-tools: Bash Read Write Edit Glob Grep
metadata:
  author: Alexander Opalic
  version: "0.2.0"
---

# Factory Pipeline (orchestrator skill)

You are the **orchestrator**. You do not write production code yourself. You
delegate each step to a **fresh subprocess** of the configured coding harness
(`claude` | `codex` | `copilot`) via `tools/run_step.sh`, then gate on the
artifact the worker wrote before moving on.

The motivation and design trade-offs live in
[references/architecture.md](references/architecture.md) — read it once per
session before your first run, then keep this file in context.

## Arguments

```
$factory-pipeline <prd-path> [--harness claude|codex|copilot]
                              [--resume <run-id>] [--from <step>]
```

- `<prd-path>` — required on first run. Markdown file describing what to build.
- `--harness` — which coding CLI to invoke as the worker for every step.
  Default `claude`. Honor whichever harness the user names ("use codex",
  "with copilot", etc.) and persist it in `manifest.json` so `--resume`
  uses the same one.
- `--resume <run-id>` — pick up an existing run from its manifest.
- `--from <step>` — start from a specific step (`plan` | `ralph` | `review` | `pr`).
  Implies you trust prior artifacts; useful for debugging.

## Harness selection

| harness   | binary    | invocation built by `run_step.sh`                                         |
| --------- | --------- | ------------------------------------------------------------------------- |
| `claude`  | `claude`  | `claude --dangerously-skip-permissions -p "<prompt>"`                     |
| `codex`   | `codex`   | `codex exec --dangerously-bypass-approvals-and-sandbox "<prompt>"`        |
| `copilot` | `copilot` | `copilot --allow-all -p "<prompt>"`                                       |

All three are unattended modes — the orchestrator gates artifacts, so an
interactive permission prompt would deadlock the run. If a harness isn't on
`$PATH`, `run_step.sh` exits 127 with a clear message; surface it and stop.

Pick the harness by what the user named in the request. If they didn't name
one, default to `claude`. Do not silently switch harnesses mid-run.

## Run state

Every run lives under `.factory/runs/<id>/`:

```
.factory/runs/<id>/
├── prd.md            # copy of the input PRD
├── plan.md           # output of step 1
├── tickets/          # one file per ticket from plan.md
├── prompts/          # assembled prompt text per step (audit trail)
├── <step>.stdout     # raw harness stdout per step
├── manifest.json     # run id, harness, status
└── events.jsonl      # append-only log
```

Initialize a run with:

```bash
bash .claude/skills/factory-pipeline/tools/init_run.sh "<prd_path>"
```

This prints the absolute run-dir path. Export it as `FACTORY_RUN_DIR`. Every
subsequent tool invocation requires that variable.

## Pipeline

Execute steps **strictly in order**. Do not skip ahead. Do not parallelize
across steps (parallelism within `ralph` across tickets is allowed — see below).

### 1. plan

```bash
bash .claude/skills/factory-pipeline/tools/run_step.sh <harness> plan
```

- Expected artifact: `$FACTORY_RUN_DIR/plan.md`.
- Gate: `python3 .claude/skills/factory-pipeline/tools/validate_plan.py` — file
  exists, has frontmatter with `branch` + `title`, ≥1 ticket, each ticket has
  a `Done when:` clause.
- On gate fail: retry once with the parser error appended to the prompt. On
  second fail, abort and surface the run dir.

### 2. ralph (TDD loop, one subprocess per ticket)

- Read `$FACTORY_RUN_DIR/plan.md`, split it into ticket files under
  `$FACTORY_RUN_DIR/tickets/T<n>.md` (one ticket per file).
- For each ticket:
  ```bash
  bash .claude/skills/factory-pipeline/tools/run_step.sh <harness> ralph \
       "$FACTORY_RUN_DIR/tickets/T<n>.md"
  ```
- Workers are fully independent and write one commit each.
- You may run multiple ticket-workers in parallel **only if** the plan marks
  them as `[parallel-safe]`. Otherwise run them sequentially on the same
  branch to avoid merge churn.
- Gate per ticket: the ticket's "Done when" assertions pass (typecheck +
  tests green, files touched match the ticket's `files:` field — verify
  with `git diff --stat HEAD~1`).
- If a ticket fails after 3 retries, mark it `FAILED` in the manifest and
  continue with the rest. Do not block the pipeline on one bad ticket.

### 3. review

```bash
bash .claude/skills/factory-pipeline/tools/run_step.sh <harness> review
```

- Expected artifact: `$FACTORY_RUN_DIR/review.md` (a findings list).
- Gate: artifact exists. Severity-`high` findings block step 4 — surface them
  and stop. Severity-`low`/`info` findings are noted but do not block.

### 4. pr

```bash
bash .claude/skills/factory-pipeline/tools/run_step.sh <harness> pr
```

- The worker opens the PR using `gh pr create`, title from `plan.md`
  frontmatter, body from the ticket summaries and `review.md`.
- Gate: PR URL appears in `$FACTORY_RUN_DIR/pr.stdout`.

## Delegation rules (non-negotiable)

These rules are the entire point of the skill. If you violate them, you
collapse to "the orchestrator doing everything in one context," which is the
exact failure mode the pipeline shape is meant to prevent.

1. **Never inline a step's work.** If you find yourself opening a source file
   under the project tree to edit it, stop — that's a worker's job. You only
   read artifacts under `$FACTORY_RUN_DIR/`.
2. **One `run_step.sh` invocation = one step (or one ticket).** Fresh
   subprocess context is the whole point.
3. **Don't paraphrase the step prompts.** `run_step.sh` assembles the prompt
   from `steps/<name>.md` verbatim, plus the run-dir context and optional
   extra-context file. Don't pass a hand-edited prompt instead.
4. **Gate before continuing.** Every step has a deterministic gate (a script
   or a parse). Run it. Do not "trust the worker said it's done."
5. **Append every state change to `events.jsonl`** via
   `tools/emit_event.sh <step> <status> <detail>`. The manifest is derived
   from events; never hand-edit either file.

See [references/delegation-rules.md](references/delegation-rules.md) for the
reasoning and worked examples.

## Stop conditions

- Plan has zero tickets → abort, ask the user to refine the PRD.
- Any step exceeds 3 retries → abort, surface `$FACTORY_RUN_DIR/`.
- Harness binary missing (`run_step.sh` exit 127) → abort, tell the user to
  install it or pick a different `--harness`.
- User Ctrl-Cs → write a `PAUSED` event so `--resume` can pick up cleanly.

## Resume semantics

If invoked with `--resume <run-id>`:

1. Read `.factory/runs/<id>/manifest.json`.
2. Use the harness recorded there (do not re-prompt the user).
3. Find the first step whose latest event is not `DONE`. Resume from it.
   Earlier artifacts are trusted as-is.

## Output to the user

After each step, one line: `[<harness>] [<step>] <status> — <artifact path>`.
At the end of a run, print the PR URL and the run dir. Nothing else.

## What this skill does NOT do

- It does not mix harnesses within a run. One `--harness` value is used for
  every step. If you want different harnesses for different steps, do
  separate runs and `--from` into each.
- It does not handle multi-repo or cross-repo PRs.
- It does not write the steps' prompts for you. Customize `steps/*.md` to
  match your project's conventions before running.
- It does not parse harness tool-event streams. Gates inspect filesystem
  artifacts and git state, not the worker's stdout.
