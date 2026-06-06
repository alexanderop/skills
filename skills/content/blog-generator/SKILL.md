---
name: blog-generator
description: Generates a self-contained, deeply-technical "deep dive" blog post as a single offline-capable HTML file — AstroPaper aesthetic, light/dark toggle, Mermaid diagrams (CDN), Shiki syntax highlighting (CDN ESM). Use when the user types "$blog" or "$blog-post", asks to "write a blog post", "deep dive blog", "generate a blog post about how X works", "explain X in a blog post so I can rebuild it", "in-depth post about", or wants a long-form publishable HTML article reverse-engineering a codebase, library, or architecture (not a quick summary, not an interactive walkthrough).
compatibility: Claude Code. Requires Bash + a browser. Internet on first load (CDN fetch for Mermaid + Shiki); offline thereafter.
allowed-tools: "Bash(open:*) Bash(cp:*) Bash(ls:*) Bash(bash:*) Read Write Edit Glob Grep Task"
metadata:
  author: Alexander Opalic
  version: "1.2.0"
---

# Blog Post Generator (Deep-Dive HTML)

Generate a single self-contained HTML blog post that explains how a codebase, library, or architecture works in enough depth that a motivated reader could rebuild it. AstroPaper aesthetic: mono font, skin-token colors, sun/moon toggle, accent headings, card code blocks.

**CRITICAL**: When triggered, you MUST produce a `blog-{slug}.html` file at the project root. Never respond with prose only.

**Defaults to dark theme.** The `<html>` tag MUST start with `class="dark"`. Light mode works via the toggle and `prefers-color-scheme`.

## Workflow

### Step 1 — Scope

Three common shapes:

| Shape | Example prompt |
|-------|----------------|
| **Library/SDK deep-dive** | "Explain how this agent SDK works so I can rebuild it" |
| **Architecture write-up** | "Write a blog post about how the build pipeline is organized" |
| **Mechanism explainer** | "How does the schema-to-tool injection trick work" |

If `$blog` is used **with no topic**, generate a deep dive of the **entire current repo** — the user is in a codebase and wants the architecture written up.

If the prompt is vague (and not a bare `$blog`), ask one clarifying question. Otherwise proceed.

Targets: **12–18 sections, 1,500–3,000 words**, reverse-engineering oriented (cite real files, quote real signatures), ending in an 8–12 step rebuild plan.

### Step 2 — Explore the codebase with parallel subagents

**Always read real source before writing.** Never fabricate APIs, file paths, or function names.

1. Do a quick orientation yourself (2–4 `Glob`/`Grep`/`Read` calls max) to find entry points: README, top-level package, `src/index`, directory layout.
2. Use that to split exploration into **3–6 independent slices**.
3. Launch all Explore subagents **in a single message** so they run in parallel:
   ```
   Task(subagent_type="Explore", description="…", prompt="…")
   ```
4. Each subagent returns a structured note in the format defined in `references/subagent-report-format.md`.
5. Once they return, **stop reading files** and move to Step 3.

### Step 3 — Outline

Produce a section list before writing HTML. The canonical 12–15 section recipe lives in `references/content-structure.md` (mental model → layered architecture → core abstraction → implementations → main loop → config assembly → clever subsystem → orthogonal feature → second clever bit → roles/precedence → resource management → build pipeline → persistence → rebuild plan → closing).

Use **Mermaid for diagrams** at three points minimum: layered architecture (flowchart), main loop (sequenceDiagram), the cleverest subsystem (flowchart).

### Step 4 — Generate the HTML

1. **Copy the template** to the project root, named `blog-{slug}.html` (kebab-case slug):
   ```bash
   cp .claude/skills/blog-generator/assets/blog-template.html blog-{slug}.html
   ```
   (If installed at a different path, adjust accordingly. The asset is under `<skill-root>/assets/blog-template.html`.)

2. **Fill the placeholders** in the copied file: `{{POST_TITLE}}`, `{{LEDE}}`, `{{KICKER}}`, `{{READ_MIN}}`, `{{SLUG}}`, `{{BRAND}}`, `{{FOOTER}}`.

3. **Add TOC entries** under `<nav id="contents">` — one `<li><a href="#section-id">Title</a></li>` per section.

4. **Insert section content** between the TOC and the footer. Use the snippet patterns in `references/html-template.md` (plain section, code block, callout, Mermaid flowchart, sequence diagram, table, rebuild step).

5. **Voice** — `references/voice.md` is the default voice (calibrated to alexop.dev). Read it before writing prose. If the user supplied their own voice sample or "write like X" instruction at trigger time, follow that instead.

6. **Heading, diagram, and code-block conventions** — see `references/content-structure.md` §Generation conventions.

### Step 5 — Validate and open

```bash
bash .claude/skills/blog-generator/scripts/validate-blog.sh blog-{slug}.html
open blog-{slug}.html       # macOS
```

If the validator exits non-zero, fix the issues it lists and re-run. **Do not hand off until validate exits 0.**

### Step 6 — Publish

Once the validator passes, publish the post to the user's GitHub-Pages-backed blog repo. The script copies the file into `<aiblog_dir>/<slug>/index.html`, commits, pushes, and prints the live URL on its final line. It is idempotent — regenerating the post and re-running republishes it; if nothing changed it prints "already up to date" and exits 0.

```bash
bash <skill-root>/scripts/publish-blog.sh blog-{slug}.html
```

By default the script targets `~/Projects/aiBlog`. Override with `AIBLOG_DIR=/path/to/repo` for a different clone.

If the script exits 1 because the blog repo is missing, **relay its setup hint to the user verbatim — don't try to create the repo yourself.** Creating a public repo is a one-time action that needs the user's confirmation.

## Quality checklist (the validator does NOT cover these)

The validator checks structure (doctype, theme tokens, ≥3 Mermaid blocks, language classes, TOC anchors resolve, ≥2 callouts, rebuild plan steps 1–8). After it passes, you still need to verify:

- [ ] Every cited file path and function name maps to **a real file** — no fabrication.
- [ ] Each callout captures a load-bearing insight, not a summary.
- [ ] The "clever subsystem" section earns the deep-dive label (a smart reader nods or laughs).
- [ ] Voice matches `references/voice.md` (or the user's supplied voice). No banned marketing words ("powerful", "blazing-fast", "seamless" — gone). No throat-clearing openers.
- [ ] Each rebuild step is independently runnable — something works after step N.
- [ ] No section is just a heading; every one has prose.

## References

- `references/voice.md` — default voice (alexop.dev calibration); overridable per-call.
- `references/html-template.md` — snippet patterns (plain section, code block, callout, Mermaid, table) and anti-patterns.
- `references/content-structure.md` — section recipe, length targets, generation conventions.
- `references/subagent-report-format.md` — exact format Explore subagents must return.
- `assets/blog-template.html` — the skeleton to copy.
- `scripts/validate-blog.sh` — deterministic post-generation gate.
