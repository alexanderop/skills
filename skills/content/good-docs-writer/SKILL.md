---
name: good-docs-writer
description: >
  Turn a topic into a structured blog-post draft for a developer audience,
  using The Good Docs Project templates as the structural backbone. Classifies
  the post intent (explainer, walkthrough, recipe, quickstart, debug story,
  release post, cheat sheet) via an internal index, fetches the matching
  Good Docs template (bundled locally from gitlab.com/tgdp/templates), then
  adapts it to blog voice (hook, narrative, takeaways, CTA). TRIGGER on: "good-docs-writer",
  "write a blog post about X", "draft a blog post on X", "blog post for X",
  or the explicit form "$good-docs-writer <intent> <topic>".
allowed-tools: Bash Read Write Glob Grep AskUserQuestion
metadata:
  author: Alexander Opalic
  version: "0.1"
---

# Good Docs Writer

Turn a topic into a first-draft blog post that already has a solid structural spine (a Good Docs template) and a blog voice (hook, narrative, takeaways, CTA).

> Built on top of [**The Good Docs Project**](https://www.thegooddocsproject.dev/) — templates fetched at runtime from `gitlab.com/tgdp/templates` (MIT-0). All credit for the structural craft of the templates goes to that community; this skill is just the adapter.

## Why this matters

The hardest part of a blog post is not the writing — it's deciding what shape the post should have. Good Docs templates already encode the right shape for each documentation intent. This skill maps blog-post intents to those templates, fetches the live template, and layers blog voice on top.

This is the **blog-flavored** counterpart to `doc-generator` (which produces neutral docs) and `doc-improver` (which improves existing rough markdown).

## Process

### 1. Classify the post intent

If the user used the explicit form (`$good-docs-writer walkthrough adding auth to Astro`), trust the intent and skip classification.

Otherwise, read [references/template-index.md](references/template-index.md) and walk the decision matrix top-to-bottom. Stop at the first row that matches.

If two rows fit equally — most commonly `concept` (explainer) vs. `tutorial` (walkthrough), or `tutorial` vs. `how-to` — call `AskUserQuestion`. Don't guess.

State the chosen intent and template back to the user in one sentence before generating, e.g. *"Treating this as an **explainer** — using the Good Docs `concept` template as the spine."*

If the topic is an opinion essay or personal narrative with no good template fit, tell the user and offer either a loose `concept` backbone or freeform.

### 2. Read the bundled template + guide

The skill ships with a frozen snapshot of every supported Good Docs template under [`references/templates/`](references/templates/). Use `Read` on the local files — **do not WebFetch**, the snapshot is the source of truth.

Read [`references/templates.md`](references/templates.md) for the catalog and exact paths. For the chosen key, read:

- `references/templates/<key>/template.md` — the scaffold to fill in
- `references/templates/<key>/guide.md` — explains what each section/placeholder means

Also read `references/writing-tips.md` once per session if you need general voice/concision guidance. Only read the larger `references/style-guide.md` when verifying a specific style call (it's ~49 KB).

**Do not reproduce template structure from memory.** The bundled file is canonical — if you can't read it, stop and tell the user something is wrong with the install.

### 3. Gather material for the post

Two paths:

- **Topic is tied to the user's repo** (e.g. "blog post about how our auth flow works"): explore the repo with `Glob` / `Grep` / `Read` to collect concrete file paths, function names, code excerpts. For larger explorations, you can launch subagents — but most blog posts only need a focused scan, not parallel agents.
- **Topic is general / not repo-tied** (e.g. "blog post about Postgres advisory locks"): ask the user for any anchor material — links, prior drafts, key points they want included. If they have none, proceed from general knowledge but flag it ("this draft uses general knowledge — verify specifics before publishing").

Either way, ask the user **once** for: target audience (e.g. "Vue devs new to Pinia"), rough length, and any voice cues they want preserved (their existing posts, a tone they want to match). Skip if they already specified.

### 4. Fill the template, then blogify

Walk the fetched template section by section:

- Replace each `{placeholder}` with concrete content drawn from material gathered in step 3.
- If a section has no matching material, **skip it entirely** — do not invent filler.
- Preserve the template's section order and heading text where it reads naturally; rename headings if the docs phrasing sounds stiff in a blog context (the section-by-section moves in [references/blog-voice.md](references/blog-voice.md) tell you which renames are safe).

Then layer blog voice using [references/blog-voice.md](references/blog-voice.md):

- Add a **hook** in place of the neutral summary paragraph.
- Add a **stakes paragraph** right after the hook — what the reader walks away with.
- Add a **takeaways** block before the conclusion (3–5 bullets, full sentences).
- Add a **CTA** as the final paragraph — one specific next action.
- Apply the voice rules globally (first person OK, contractions on, short hook sentences, show trade-offs, code over prose).

Code snippets must be real — if the post is repo-tied, every snippet should be greppable in the repo. If general, mark sample code as illustrative.

### 5. Write the output file

- **Slug**: kebab-case of the topic (e.g. "Adding auth to Astro" → `adding-auth-to-astro.md`).
- **Path**: detect existing blog folder convention, in this order:
  1. `src/content/blog/` (Astro/most modern setups)
  2. `content/blog/` (Nuxt/Hugo)
  3. `posts/` (Jekyll/older blogs)
  4. `_posts/` (Jekyll convention)
  5. Fallback: `blog/` (create if missing)
- **Frontmatter**: if sibling posts in the chosen folder use frontmatter (Astro content collections, Hugo, Jekyll, etc.), match their shape exactly — title, date (today, ISO), description, draft-flag, tags. Read 1–2 sibling files to confirm. If no sibling pattern exists, omit frontmatter.
- Filenames use hyphens, never underscores or spaces.

### 6. Report what was generated

After writing, print a short summary (≤ 10 lines):

- The intent and template chosen, in one sentence.
- Which template sections were filled vs. skipped, with the reason for any skips.
- Where the file was written, and which sibling-frontmatter convention was matched (or "no frontmatter — none detected").
- The 1–2 things the user should manually verify (claims that came from general knowledge, code snippets that need a working example, etc.).

The user will read the draft themselves — don't summarize the post content.

## Rules

- **Never fabricate the template.** Always `Read` from `references/templates/<key>/`. If the file is missing, stop and tell the user the install is incomplete.
- **Never invent code, file paths, or APIs** for repo-tied posts. Every snippet must be greppable.
- **One topic per run.** If the user asks for a series, push back and ask which post to start with.
- **Preserve template structure** — Good Docs sections are load-bearing. Add blog voice *around* them, not by deleting them.
- **Ask when ambiguous.** Use `AskUserQuestion` for intent ties (concept vs. tutorial, tutorial vs. how-to) rather than guessing.
- **Show, don't pad.** A working snippet beats three paragraphs of explanation. Cut filler aggressively.

## Example invocations

```
$good-docs-writer explainer how Vue's reactivity proxy works
$good-docs-writer walkthrough adding Clerk auth to an Astro site
$good-docs-writer debug-story the trailing-slash 404 in production
write a blog post about Postgres advisory locks
draft a blog post on our migration from Webpack to Turbopack
```
