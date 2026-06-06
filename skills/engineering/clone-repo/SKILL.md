---
name: clone-repo
description: Vendor a library's source code into the current repo as a git subtree under `repos/<name>/`, then wire it into AGENTS.md as reference material so coding agents read real source instead of fighting stale docs. Use when the user types "$clone-repo <url>", "/clone-repo <url>", "vendor <url>", "clone <url> as a subtree", "add <url> as reference for the agent", "feed <url> to the agent", "just clone the repo <url>", or otherwise asks to set up a third-party repo as agent-readable context.
allowed-tools: Bash Read Write Edit Grep Glob
metadata:
  author: Alexander Opalic
  version: "0.1.0"
---

# Clone Repo (vendor as subtree)

Pulls a library's source into the current project at `repos/<name>/` so coding agents can read real source instead of relying on stale training data or doc-CLI shims. Move from Michael Arnaldi's "Vibe Engineering Effect Apps" — agents are post-trained on reading code, not prose, so feed them code.

The result: a dumb directory the agent treats as "more of my codebase". Distilling what's relevant into project-local `patterns/*.md` is a separate, on-demand step.

## What this skill does NOT do

- It does not generate `patterns/*.md`. That's a per-topic follow-up the user invokes explicitly so they self-select which subset of the library the project actually uses.
- It does not configure ESLint / TypeScript strictness — orthogonal, project-wide setup.
- It does not pull updates. Re-running on the same name will refuse; see "Updates" below for the manual upgrade command.

## Arguments

```
$clone-repo <url> [name] [branch]
```

- `<url>` — required. Any clone URL (https or ssh).
- `[name]` — optional. Directory under `repos/`. Defaults to the URL's basename without `.git`.
- `[branch]` — optional. Defaults to the remote's HEAD branch (queried via `git ls-remote --symref`).

If the user just gives a URL, infer name and branch.

## Workflow

### 1. Preflight checks

Run all of these. If any fails, **stop and tell the user exactly what to fix** — do not try to fix it for them.

```bash
git rev-parse --is-inside-work-tree            # must print "true"
git rev-parse HEAD >/dev/null 2>&1              # must succeed — subtree needs ≥1 commit
test -z "$(git status --porcelain)"             # working tree must be clean
test ! -e repos/<name>                           # destination must not exist
```

Each failure has a concrete remedy to relay:
- not in a git repo → `git init && git commit --allow-empty -m "init"`
- no commits yet → `git commit --allow-empty -m "init"`
- dirty tree → ask the user to commit/stash; do not stash on their behalf
- `repos/<name>` exists → either pick a different `[name]`, or run the update command (see Updates)

### 2. Resolve the default branch (if not given)

```bash
git ls-remote --symref <url> HEAD | awk '/^ref:/ {sub("refs/heads/", "", $2); print $2; exit}'
```

If the command fails (private repo, network), ask the user for the branch instead of guessing `main`.

### 3. Add the subtree

```bash
git subtree add --prefix=repos/<name> <url> <branch> --squash
```

Creates `repos/<name>/` with the library's source at that branch's tip, plus a single squashed commit on the current branch. No history pollution; the SHA is pinned by the squash commit.

### 4. Wire it into AGENTS.md

Find the agent-instructions file in this order: `AGENTS.md`, `CLAUDE.md`, `.cursor/rules/agents.md`. Whichever exists first, **append** (do not overwrite) a "Reference repositories" section if one isn't already there, then add a bullet for the new subtree:

```markdown
## Reference repositories

Source-of-truth code for libraries we depend on. Treat as **read-only reference material** — do not edit files under `repos/`. When asked about a library listed below, explore its source here first instead of guessing or relying on training data.

- `repos/<name>/` — <url> @ <branch> (squashed)
```

If none of those files exist, create `AGENTS.md` with that section as the only content.

If an entry for `repos/<name>` already exists, leave it alone.

### 5. Report

One short message to the user:

- The subtree path, source URL, branch, and squash commit (`git log -1 --oneline` on the current branch).
- The exact follow-up prompt to distill patterns:
  > Explore `repos/<name>/` for patterns on how to <task>. Save your findings to `patterns/<task>.md` with concrete file references.
- The update command (so they know where the upgrade path lives — see below).

Stop there. Do not write patterns yourself unless asked.

## Updates (manual, not automated by the skill)

To pull upstream changes later:

```bash
git subtree pull --prefix=repos/<name> <url> <branch> --squash
```

## Why subtree, not submodule, not plain clone

- **Submodule** — extra `.gitmodules` machinery, requires `git submodule update --init` on every clone, agents often skip the contents.
- **Plain `git clone` + .gitignore** — not reproducible across machines or CI runs; the cloned SHA isn't pinned anywhere.
- **Subtree --squash** — files live in the repo, pinned to a SHA via the squash commit, no special tooling on clone. Agents see them as ordinary directories. Matches what Arnaldi uses in the talk.

## Reference

- Article: "Vibe Engineering Effect Apps: Just Clone the Repo" — alexop.dev
- Original talk: Michael Arnaldi, https://www.youtube.com/watch?v=Wmp2Tku2PrI
