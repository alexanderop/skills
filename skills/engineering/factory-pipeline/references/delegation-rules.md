# Delegation rules — the reasoning

The orchestrator's whole job is to *not* do the work. This file expands the
five rules in `SKILL.md` with worked examples and failure modes.

## Rule 1 — Never inline a step's work

**Wrong:**

```
User: $factory-pipeline plans/auth.md --harness codex
Orchestrator: I'll plan first... <opens auth.md, drafts plan inline, edits files itself>
```

**Right:**

```
User: $factory-pipeline plans/auth.md --harness codex
Orchestrator: bash tools/init_run.sh plans/auth.md
              → FACTORY_RUN_DIR=.factory/runs/20260511T102314Z-9a8b7c6d
              bash tools/run_step.sh codex plan
              → worker (codex subprocess) writes plan.md
              python3 tools/validate_plan.py
              → gate passes, continue
```

Symptom you're violating this rule: you `Read` or `Edit` a source file that
is not under `$FACTORY_RUN_DIR/`. The moment that happens, stop and delegate.

## Rule 2 — One `run_step.sh` call = one step (or one ticket)

Subprocess context isolation is load-bearing. If you bundle "plan and ralph"
or "review and pr" into one prompt, the worker inherits the planning context
when implementing, which is exactly the prior-bias the pipeline shape exists
to prevent.

The one exception: within `ralph`, you may launch N parallel workers — one
per ticket — *if* the plan marks tickets `[parallel-safe]`. They share no
context with each other; each only sees its one ticket file.

## Rule 3 — Don't paraphrase the step prompts

`run_step.sh` reads `steps/<name>.md` from disk and assembles the prompt for
you. Do not pre-edit the prompt and pass it inline instead. Two reasons:

- The prompts are tuned per step. Paraphrasing drifts.
- Reproducibility — `$FACTORY_RUN_DIR/prompts/<step>.txt` is the audit trail.
  If you bypass it, debugging a failed run becomes guesswork.

The assembled prompt has this shape:

```
<contents of steps/<name>.md>

---
FACTORY_RUN_DIR=<absolute path>
EXTRA_CONTEXT_FILE=<optional: e.g. tickets/T1.md for ralph>

## Additional context

<contents of EXTRA_CONTEXT_FILE, if any>
```

If you need to pass something extra (a parser error from a retry, say), put
it in a file and pass its path as the third argument to `run_step.sh`. Don't
inline.

## Rule 4 — Gate before continuing

Every step has a deterministic check. Examples:

- `plan` gate: `python3 tools/validate_plan.py` — frontmatter present,
  ≥1 ticket, each ticket has a `Done when:` clause.
- `ralph` ticket gate: `git diff --stat HEAD~1` matches the ticket's `files:`
  field within tolerance; project's test command exits 0.
- `review` gate: `review.md` exists; grep for `severity: high` blocks.
- `pr` gate: `$FACTORY_RUN_DIR/pr.stdout` contains a
  `https://github.com/.../pull/\d+` URL.

If the gate fails, retry **once** with the failure output appended via the
extra-context-file arg. If it fails again, abort and surface the run dir.

## Rule 5 — Append to events.jsonl

Every state change writes one JSON line:

```json
{"ts":"2026-05-11T10:23:14Z","step":"plan","status":"START","detail":"harness=codex"}
{"ts":"2026-05-11T10:24:02Z","step":"plan","status":"DONE","detail":"plan.md"}
{"ts":"2026-05-11T10:24:02Z","step":"ralph","status":"START","detail":"T1"}
```

Use `tools/emit_event.sh <step> <status> <detail>` so the format stays
consistent. The manifest is derived — never hand-edit it.

## Common failure modes

- **"The worker said it's done."** Doesn't matter. Run the gate.
- **"It's faster if I just edit this one file myself."** It's faster *this
  time*. Then the next pipeline run drifts because you set a precedent.
- **"The ticket needs context from the previous one."** That's a planning
  bug. Go back, re-plan, split or merge tickets so each is self-contained.
- **"I'll resume by re-running the whole thing."** Use `--resume <run-id>`.
  The manifest exists for this.
- **"`codex` failed mid-run; let me switch to `claude` for the rest."** Don't
  silently change harnesses. Either retry the same harness, or start a new
  run with `--from <step>` and a different `--harness`. The manifest pins
  the harness for a reason — mixing them invalidates the run's reproducibility.
