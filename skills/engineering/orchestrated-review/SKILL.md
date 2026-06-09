---
name: orchestrated-review
description: Orchestrated multi-agent code review modeled on Cloudflare's system. Risk-tiers the diff, filters noise, fans out specialist reviewers (security, performance, code quality, docs, tests, release, AGENTS.md), and consolidates everything through a coordinator judge pass into one structured verdict. Use for "orchestrated review", "multi-agent code review", "deep review", "review like Cloudflare", "thorough AI code review", or to review a GitHub PR with severity-graded findings and an approve/block decision.
allowed-tools: Bash, Read, Workflow, Glob, Grep
metadata:
  version: 1.1.0
---

# Orchestrated Code Review

A Cloudflare-style code review: tier the change, filter noise, fan out specialist
reviewers in parallel, adversarially verify every critical finding, then let a
coordinator dedupe, judge severity, and decide. Unlike `check` (a quick 2–4
reviewer pass), this runs a real coordinator judge pass over structured findings
and emits an approve/block verdict — and on PR re-runs it is aware of its own
previous review.

This skill **uses the Workflow tool** to orchestrate the agents — that is the
explicit opt-in. Do not ask the user to opt in again.

## Inputs

`$ARGUMENTS` may contain:
- a **PR number or URL** → review that GitHub PR (via `gh`)
- nothing → review **local changes** (uncommitted, else branch vs merge-base)
- `--comment` → after reviewing a PR, post the verdict back to the PR

## Steps

### 1. Prep the payload

Run the prep script that ships with this skill. **`<skill-dir>` is the directory
containing this SKILL.md** — resolve it to an absolute path from wherever the
skill is installed (it is NOT relative to the user's repo):

```bash
bash <skill-dir>/scripts/prep-review.sh <PR-or-empty>
```

It builds the unified diff, splits per-file patches, strips noise, classifies
files, and assigns a risk tier. The last stdout line is the path to
`manifest.json`. Read it. If `tier` is `"none"`, tell the user there's nothing
to review and stop. If `oversized` is `true`, warn the user that review quality
degrades on very large diffs and suggest splitting the change — then continue.

Show the user the tier, the selected reviewers, and any dropped files — be
transparent about what is and isn't being reviewed (silent truncation reads as
"covered everything" when it didn't).

| Tier | Trigger | Reviewers run |
|------|---------|---------------|
| `trivial` | ≤10 lines, ≤20 files | 1 general reviewer |
| `lite` | ≤100 lines, ≤20 files | code-quality, documentation, tests |
| `full` | anything bigger, **or any security-sensitive path** | security, performance, code-quality, tests, documentation — plus release / agents-md only when relevant files changed |

### 2. Gather project instructions (optional)

If `AGENTS.md` or `CLAUDE.md` exists at the repo root, read it. Pass its review-relevant
content as `customInstructions` so every reviewer respects project conventions.

### 3. PR mode: break-glass and previous review

Only when reviewing a PR:

1. **Break-glass:** check whether any human comment says **`break glass`**
   (`gh pr view <n> --json comments`). If so, **skip the review**, report that a
   human forced approval, and stop. (Hotfix escape hatch — see `references/architecture.md`.)
2. **Previous review:** fetch the most recent verdict this skill posted, so the
   coordinator can run an incremental re-review (fixed findings drop, unfixed
   ones persist):

   ```bash
   gh api "repos/{owner}/{repo}/issues/<n>/comments" --paginate \
     --jq '[.[] | select(.body | contains("<!-- orchestrated-review -->"))] | last | {id, body}'
   ```

   If a comment is found, pass its `body` as `previousReview` in the workflow
   args, and remember its `id` for step 6.

### 4. Run the orchestration

Invoke the **Workflow** tool with the shipped script and the manifest as `args`:

- `scriptPath`: `<skill-dir>/scripts/review-workflow.mjs` (absolute path)
- `args`: the parsed `manifest.json` object, plus `customInstructions` from
  step 2 and `previousReview` from step 3 (when present).

The workflow fans out the tier's reviewers in parallel (each emits structured
findings with `critical`/`warning`/`suggestion` severity), adversarially
verifies every critical finding with a refuter agent, then a coordinator
deduplicates, re-categorizes, drops false positives, applies the re-review
rules, and returns the verdict.

### 5. Render the verdict

The workflow returns `{ summary, decision, decisionReason, findings[] }`. Render
(the HTML comment marker is required — re-review detection in step 3 depends on it):

```markdown
<!-- orchestrated-review -->
# 🤖 Orchestrated Review — <DECISION>

<summary>  _(<decisionReason>)_

## 🔴 Critical
- `file:line` — **title**. detail

## 🟡 Warnings
- `file:line` — **title**. detail

## 🟢 Suggestions
- `file:line` — **title**. detail
```

Map the decision to an outcome:

| Decision | Meaning |
|----------|---------|
| `approved` | clean / trivial suggestions only |
| `approved_with_comments` | suggestions, or warnings without production risk |
| `minor_issues` | multiple warnings — a risk pattern, fix before merge |
| `significant_concerns` | a critical item or safety risk — **blocks merge** |

Omit empty severity sections. If `findings` is empty, just show the summary and ✅.
On a re-review, surface how many previous findings were resolved (the summary
includes it).

### 6. Post to the PR (only if `--comment` and PR mode)

If step 3 found a previous verdict comment, **update it in place** instead of
stacking a new one:

```bash
gh api "repos/{owner}/{repo}/issues/comments/<id>" -X PATCH -F body=@<verdict-file>
```

Otherwise post fresh: `gh pr comment <n> --body-file <verdict-file>`.

For `significant_concerns`, also surface that it would block merge. Never request
changes or unapprove on the user's behalf without their say-so — default to a comment.

## References

- `references/architecture.md` — how this maps to Cloudflare's design (tiers, rubric, noise filtering, verification, break-glass, re-reviews, injection hardening) and what to tune.
- `references/reviewers.md` — the specialist reviewer roster, model tiers, and their "What to Flag / What NOT to Flag" charters.
