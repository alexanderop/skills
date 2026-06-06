# Blog voice — adapting Good Docs structure to a blog post

A Good Docs template gives you the **spine**. A blog post needs a few extra moves on top: a hook, a narrator, takeaways, and a call-to-action. This file describes those moves.

## The four blog-only sections

Add these around the Good Docs scaffold. None of them are in the upstream template — they're how a docs page becomes a post someone wants to read.

### 1. Hook (replaces the template's summary paragraph)

Good Docs templates open with a neutral summary. Blog posts open with a **hook**: a problem the reader feels, a surprising claim, or a concrete scene. Two or three sentences, max.

Patterns that work:

- **Pain hook** — "Last month I spent four hours debugging a 404 that turned out to be a trailing slash. Here's how to avoid that."
- **Claim hook** — "Most React apps re-render 3× more than they need to. The fix is one hook."
- **Scene hook** — "It's 2 a.m. The pager goes off. Postgres CPU is at 100%. You have 15 minutes."

Avoid: "In this post we will…", "Welcome to my blog about…", any meta-commentary.

### 2. Stakes paragraph (right after the hook)

One short paragraph answering: *why should the reader care, and what will they walk away with?* This is the contract. Keep it concrete: name the outcome ("you'll know how to spot a wasted re-render in DevTools") not the topic ("we'll explore performance").

### 3. Takeaways block (right before the conclusion)

A 3–5 bullet recap. The reader skims this even if they don't read the body. Each bullet should be one full sentence with the actionable nugget — *not* a heading echo.

Bad: "Reactivity"
Good: "Use `shallowRef` for objects you mutate but don't deep-watch — it cuts re-render cost without losing reactivity."

### 4. CTA / next step (final paragraph)

A blog post should leave the reader with **one** specific next action: try the demo, read a follow-up post, subscribe, open a PR, etc. Don't list five — pick one.

## Voice rules

These apply across every section, regardless of template.

- **First person is fine.** Good Docs is institutional voice; blogs are a person talking. "I hit this bug" beats "the developer may encounter this issue."
- **Contractions on.** "Don't", "it's", "you'll" — not "do not", "it is", "you will."
- **Short sentences for tension; long sentences for nuance.** Vary deliberately. A wall of medium-length sentences reads flat.
- **Show the trade-off.** Whenever you recommend something, name what it costs. Posts that only list pros read like ads.
- **Code over prose.** A working snippet beats three paragraphs of explanation. If you can show it, show it.
- **One idea per heading.** If a section heading has "and" in it, split it.

## Adapting each template — section-by-section moves

### `concept` → explainer post
- Drop or shorten the "scope" placeholder — the hook + stakes paragraph already do that job.
- Keep the definition, but lead with an analogy or example **before** the formal definition.
- The "see also" section becomes the CTA.

### `tutorial` → walkthrough post
- Keep the prerequisites section but rename it "What you'll need" — friendlier.
- Add a **"What we're building"** intro with a screenshot or final-state snippet, before step 1. Readers want to know the destination.
- After the last step, add a "Where to go from here" — this is the CTA.

### `how-to` → recipe post
- The how-to template is already terse, which is good for blogs. Don't pad it.
- Add a one-line "When you'd use this" right under the title — replaces the stakes paragraph.
- Skip the "additional resources" section in favor of a single CTA.

### `quickstart` → "X in 5 minutes" post
- Keep it brutally short. If the post needs more than ~400 lines, it's not a quickstart anymore — reclassify as `tutorial`.
- Add a timer claim in the hook ("This takes about 5 minutes if you have Node 20 installed.") and *honor it* — count steps and trim.

### `troubleshooting` → debug-story post
- Open with the symptom verbatim — stack trace, error string, screenshot. Readers Google these and will land on your post if it matches.
- Keep the symptom → cause → remedy structure, but add a **narrative wrapper**: how you discovered it, what you tried first, what worked.
- The post is more memorable if you admit the wrong turns, not just the final answer.

### `release-notes` → release blog post
- Lead with the **one** thing readers care about most, even if it's buried in the changelog. The neutral chronological release-notes order is wrong for a blog.
- Group "highlights" → "improvements" → "breaking changes" → "fixes". Skip empty groups.
- CTA is always the upgrade command.

### `reference` → cheat-sheet post
- Reference templates aren't read top-to-bottom — neither are cheat-sheet posts. Keep tables, kill prose.
- Add a one-paragraph intro saying *when* you'd reach for the cheat sheet.

## Style guide imports

The Good Docs `STYLE-GUIDE.md` and `writing-tips.md` (fetch URLs in `templates.md`) are the source of truth for tone and grammar. The most load-bearing rules for blog posts:

- Active voice unless passive is genuinely clearer.
- Sentence-case headings, not Title Case.
- Inline code uses backticks, even for filenames and flag names.
- Avoid "simply", "just", "easy" — they alienate readers who find it not simple.
- Define jargon the first time you use it, even informally in parens.
