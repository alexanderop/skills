# Template index — pick the right Good Docs template for a blog post

Most blog posts fall into one of a few intents. Pick the **first** row whose trigger questions match — don't try to be clever. If two rows fit equally, ask the user.

| # | Blog intent | Trigger questions (yes → pick this row) | Good Docs template | Why it fits |
|---|-------------|------------------------------------------|--------------------|-------------|
| 1 | **Explainer** — "what is X and why should I care" | Is the post mainly explaining a concept, mental model, or trade-off? Is the reader expected to *understand* something rather than *do* something? | `concept` | Good Docs `concept` is built for "what it is, why it matters, how it relates" — same shape as a tech explainer post. |
| 2 | **Walkthrough** — "let's build X together, end to end" | Does the post hand-hold the reader through a multi-step build, with a finished thing at the end? Is the reader assumed to be a beginner to this thing? | `tutorial` | `tutorial` is learning-oriented, sequential, with a working result at the end. |
| 3 | **Recipe / how-to** — "how to do X (you already know the basics)" | Is the post solving one specific task for someone who already knows the surrounding tooling? No hand-holding? | `how-to` | `how-to` is task-oriented, terse, assumes context. |
| 4 | **Quickstart** — "X in 5 minutes" | Is the post the *fastest* path to a first success — minimal explanation, maximum throughput? | `quickstart` | `quickstart` is explicitly "minimum viable success" shape. |
| 5 | **Debug story** — "I hit error X, here's what I learned" | Is the post organized around a problem → diagnosis → fix? Does it list symptoms a reader could grep for? | `troubleshooting` | `troubleshooting` is symptom→cause→remedy, which is also the shape of a good debug post. |
| 6 | **Release / changelog post** — "what's new in vX.Y" | Is the post announcing a release, listing changes since last version? | `release-notes` | `release-notes` already has the right scaffolding (highlights, breaking changes, fixes). |
| 7 | **Cheat sheet / reference dump** — "every flag, option, or API in one page" | Is the post a flat catalog of options rather than a narrative? | `reference` | `reference` is for lookup, not reading top-to-bottom — same as a cheat-sheet blog. |
| 8 | **Glossary post** — "key terms in domain X" | Is the post a curated list of term definitions? | `glossary` | Direct fit. |
| 9 | **Install guide post** — "how to set up X on your machine" | Is the post specifically about installation/setup steps before any feature work? | `installation-guide` | Direct fit. |
| 10 | **API getting started post** — "first request to API X" | Is the post the first-touch story for an HTTP API specifically (auth, first call, response)? | `api-getting-started` | Direct fit for API tutorial posts. |

## Decision rule

Walk the rows top-to-bottom. **Stop at the first row that matches.** Rows are ordered roughly by how common the intent is for dev blog posts (explainers and walkthroughs dominate).

If nothing matches cleanly, the topic is probably:
- An **opinion / essay post** — Good Docs has no template for this. Tell the user, and offer to use `concept` as a loose backbone (intro → claim → reasoning → conclusion) without rigid template adherence.
- A **personal narrative / "year in review"** — same: no template fits. Suggest writing freeform, but still apply the writing tips in `blog-voice.md`.

## When to ask the user

Call `AskUserQuestion` if:
- The topic could plausibly be #1 (concept) **or** #2 (tutorial) — this is the most common ambiguity. Ask: *"Do you want this to teach the reader the underlying concept, or walk them through building something?"*
- The topic could be #2 (tutorial) **or** #3 (how-to) — ask: *"Is this for someone new to this, or someone who just needs the steps?"*

## After picking

State the choice back to the user in one sentence before generating, e.g. *"Treating this as an **explainer** — using the Good Docs `concept` template as the spine."*
