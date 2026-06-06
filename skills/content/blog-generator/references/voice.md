---
name: voice
description: Default voice for blog-generator output, calibrated to alexop.dev (https://alexop.dev/llms.txt) and Deirdre McCloskey's "Economical Writing". Loaded during Step 4 generation.
---

# Voice — Default (alexop.dev + Economical Writing)

This is the prose voice the generator writes in by default. Two sources, pulling the same direction:

1. **Calibration** — the writing on [alexop.dev](https://alexop.dev/llms.txt). Direct, opinionated, concrete, low on hedge.
2. **Discipline** — the 10 rules from Deirdre McCloskey's *Economical Writing* (2019). Mechanical rules for clarity at the sentence and paragraph level. See "The 10 rules" section below.

If the user supplies their own voice sample, llms.txt URL, or "write like X" instruction at trigger time, follow that instead and ignore this file. The 10 rules below are *always* on — they're craft, not style.

## Voice in one paragraph

Direct. Lead with the claim, then back it up. Short sentences. Real numbers, real file paths, real quotes. Trade-offs named, not buried. Em-dashes for asides — not parentheses. No marketing words. Opinion is welcome; hedge is not.

## Person and POV

All three are fine — pick whichever fits the sentence:

- **"I"** for personal experience, decisions, choices: *"I run two linters: Oxlint first, then ESLint."*
- **"you"** when telling the reader what to do or what they'll see: *"You delegate a ticket, review the output, and tighten the architecture."*
- **"we"** for shared mental models or walking through code together: *"we see that the loop just dispatches one event."*

What to avoid: "this author", "the developer", "one might". Royal-we for marketing reasons. Switching POV mid-paragraph for no reason.

## Sentence shape

- **Short.** Most sentences land between 8 and 18 words.
- **Lead with the claim, not the setup.** *"An agent writes most of my frontend code now."* — not *"In recent years, with the rise of AI tooling, many developers have started…"*
- **One-line paragraphs are allowed for emphasis.** *"Today."* / *"Most of the industry still works this way."* Use sparingly — one or two per post.
- **Em-dashes for asides**, not parentheses. *"the harness — pi-agent-core's `Agent` class — drives the loop."* Cap at ~3 em-dashes per paragraph; more than that turns into noise.
- **Colon-then-payoff** is a strong opener for short paragraphs: *"The trade-off: Oxlint supports fewer rules."*

## Be concrete

Every claim should land on something a reader can verify.

- **Numbers**: *"~50× faster"*, *"10 to 14 days"*, *"1,300 pull requests per week"*, *"under 200 LOC"*. Round numbers are fine; precision is fine; vague qualifiers ("much faster", "lots of") are not.
- **Real file paths and line ranges**: *"`agent.ts:44-55`"*, *"`build.ts:62-218`"*. Not "in the agent module".
- **Real signatures**: quote the actual `interface` / `type` / function signature. Don't paraphrase into pseudo-code.
- **Real quotes with attribution**: *"Boris Cherny [said](…): 'We're going to start to see…'"* — link the source.
- **Real tool names**: Vitest, Oxlint, Pact, MSW. Don't say "a popular linter" when you mean Oxlint.

## Opinion, not hedge

The default voice has a point of view. Examples that work:

- *"the highest-leverage change you can make"*
- *"this is the single cleverest bit"*
- *"these rules aren't arbitrary"*
- *"the conventional choice is X. The 2026 alternative is Y."*

Things that read as hedge — and don't belong:

- "It might be worth considering…"
- "Some would argue…"
- "There are many ways to approach this…"
- "It depends on your situation."

If you genuinely have a trade-off, name it directly: *"The trade-off: Oxlint has a smaller rule set."* Don't hide it behind hedge.

## Words to cut

These words are banned from generated output:

- **Marketing**: *powerful, blazing-fast, lightning-fast, best-in-class, robust, seamless, cutting-edge, world-class, game-changing, revolutionary, next-generation, state-of-the-art, elegant, beautiful (about code), simply, just (as filler), incredible, amazing*
- **Throat-clearing**: *let me explain, in this post we'll, as we'll see, without further ado, dive into, deep dive (in body prose — fine in titles), unpack, demystify*
- **Apology / hedge filler**: *I think, I believe, in my humble opinion, sort of, kind of, basically, essentially, somewhat, fairly, quite, very*

## Opening patterns that work

Pick one of these for the post's first paragraph (or a top-of-section paragraph):

1. **State the change.** *"An agent writes most of my frontend code now. I review what it produces and tighten the architecture where it overreaches."*
2. **State the conclusion up front.** *"The current models and tooling are enough to build software factories. Today."*
3. **State the puzzle.** *"A Dialog is a great test case for compound components because every product needs three or four versions of one."*
4. **State the inversion.** *"You used to write tests so the next person on the file stayed sane. Now you write them so the agent can check its own work."*

Avoid: backstory, "in the world of…", "imagine if…", definitional preambles.

## Section micro-patterns

Patterns to reach for repeatedly across the post:

- **TL;DR up top** (optional but encouraged for posts > 2,000 words): a `.callout` with 3–5 one-line takeaways.
- **"The trade-off:"** as a paragraph opener when introducing a downside.
- **"What you get for the work:"** as a list opener after a chunk of setup.
- **Comparison tables** with three columns: *Old default*, *What I use*, *Why* — one row per swap.
- **"Why X?" subheadings** answered in one short paragraph. *"Why two linters? Speed and coverage."*

## Code blocks

- Tag every block with a `language-…` class (see `html-template.md`).
- Real code or honest pseudo-code — never invented APIs.
- Inline a `// comment` or `# comment` when the surprising bit needs naming.
- Don't pad with imports and boilerplate. Show the load-bearing 5–25 lines.

## Diagrams

- Match the diagram to the section's job (see `content-structure.md`):
  - structure → `flowchart TD`
  - request flow → `sequenceDiagram`
  - state machine → `flowchart TD` with states
- Short node labels. Detail goes in `<sub>` tags, not in the label itself.
- The diagram should make a point the prose then names. Don't draw a diagram that just restates the prose.

## Callouts

Callouts are reserved for **load-bearing insights** — the sentence a reader would underline. Rules:

- 2–4 per post, no more.
- One sentence each. Two if the second is the punchline.
- They're never summaries ("So we've seen that…"). They're claims.
- Good callout: *"`provide` / `inject` is the entire mechanism — there is no second clever bit."*
- Bad callout: *"This section explained how the dialog primitives compose."*

## Closing notes

- 100–200 words.
- Pull back to the thesis. Often: *most of this is boring choices in tight composition.*
- End on an aphorism or a one-line recap. Not a roadmap. Not a CTA.

## Worked before/after

**Before** (default-LLM voice):

> In this comprehensive blog post, we'll dive deep into the powerful world of compound components. By leveraging the elegant `provide`/`inject` API, you can build incredibly flexible UI primitives that scale beautifully across your entire application.

**After** (this voice):

> A Dialog is a great test case for compound components because every product needs three or four versions of one: confirm, edit, share, settings. The naive paths both fail — copy a monolithic dialog into every variant and the shells drift; collapse them into one god component and the props turn into `mode`, `showHeader`, `showCancel`, `confirmVariant`. The compound pattern Reka UI uses puts state into a `provide` / `inject` context and exposes small primitives the consumer arranges into the variant they need.

What changed: real example, real tools named, trade-off explicit, no "powerful" / "elegant" / "beautifully", no "in this post we'll".

## The 10 rules (Economical Writing — McCloskey)

These are *always* on, regardless of which voice the user requested. They're craft.

### 1. Be clear; seek joy too

> "Clarity is a matter of speed directed at The Point. Bad writing makes slow reading."

Every sentence should move the reader toward the point at speed. If a sentence makes the reader pause to decode it, rewrite it. Joy is allowed — a wry observation, a sharp metaphor — but never at the cost of clarity.

❌ *"The aforementioned methodology was implemented to facilitate the optimization of resource allocation."*
✅ *"We used this method to make the best use of our resources."*

### 2. Use precise words

The writer's tool is vocabulary. Pick the exact word — not a thesaurus dress-up of a vaguer one. If `compose` is the right word, don't write `synthesize`. If `cache` is the right word, don't write `persistent storage layer`.

When a domain term has a precise meaning (memoization, debounce, idempotent), use it. Don't paraphrase to sound more accessible — name the thing.

### 3. Avoid boilerplate

> "Never start a paper with that all-purpose filler for the bankrupt imagination, 'This paper . . .'"

Cut all variants of the throat-clearing opener:

- "In this post, we'll explore…"
- "This article will examine…"
- "We're going to dive into…"
- "Throughout this guide we will…"

Start with a claim. The reader knows they're reading a post — you don't have to announce it.

❌ *"In this paper, we will explore, examine, and analyze the various factors that contribute to climate change."*
✅ *"Climate change stems from several key factors, including rising greenhouse gas emissions and deforestation."*

### 4. One paragraph, one point

> "The paragraph should be a more or less complete discussion of one topic."

A paragraph is a unit of thought. If you're switching topic, switch paragraph. If a paragraph has more than one point buried in it, split it — or cut whichever point doesn't earn its keep. Three-sentence paragraphs are fine; eight-sentence paragraphs that drift across two topics are not.

### 5. Make writing cohere

> "Make writing hang together."

Use connectives — *however*, *therefore*, *because*, *but*, *so*, *and yet*. Don't force the reader to bridge gaps you should have bridged. Each sentence should follow from the last in a way the reader can feel.

❌ *"The experiment failed. We used new equipment. The results were unexpected."*
✅ *"We used new equipment for the experiment. However, it failed, producing unexpected results."*

### 6. Avoid elegant variation

> "The seventh grade, they should realize, is over."

When you've named a thing, keep calling it by that name. Don't reach for a synonym to avoid "repeating yourself" — the synonym makes the reader wonder if you're now talking about something else.

❌ *"The cat sat on the windowsill. The feline then jumped to the floor. The domestic pet finally curled up in its bed."*
✅ *"The cat sat on the windowsill. It then jumped to the floor and finally curled up in its bed."*

In code-heavy posts: if the entity is `Agent`, call it `Agent` every time. Not "the agent class", "the executor", "the runner".

### 7. Watch punctuation

A few rules that get violated most often:

- Comma after an introductory clause: *"However, we decided to ship."* — not *"However we decided to ship."*
- Semicolon (`;`) for "likewise / also" — joins two complete clauses.
- Colon (`:`) for "to be specific" — what follows expands what came before.
- Em-dashes (`—`) for asides; cap at ~3 per paragraph.
- Don't comma-splice: *"I shipped it, it broke."* → use a semicolon, period, or conjunction.

### 8. Reorder until the end carries the emphasis

> "The end is the place of emphasis. The reader leaves the sentence with the last word ringing in her mental ears."

The last word of a sentence is the loudest. Put the load-bearing idea there. Read every sentence aloud once and ask: *what word do I leave the reader with?* If it's a throwaway like "things" or "situation" or a date, reorder.

❌ *"Looking through a lens-shape magnified what you saw."* (ends on "saw" — flat)
✅ *"Looking through a lens-shape would magnify what you saw."* (still flat — but rule 8 is about reordering for emphasis)

A sharper example:

❌ *"The end of the sentence is the emphatic location."* (emphasis on "location" — weak)
✅ *"The end of the sentence is the place of emphasis."* (emphasis on "emphasis" — the point itself)

### 9. Use active verbs

> "Use active verbs: not 'Active verbs should be used,' which is cowardice, hiding the user in the passive voice."

Verbs carry the sentence. Pick verbs that are active, accurate, and lively. Hide nothing in the passive — *"the decision was made"* always begs the question *by whom?*

❌ *"The decision was made by the committee to approve the proposal."*
✅ *"The committee approved the proposal."*

Exception: passive is fine when the agent genuinely doesn't matter (*"the file is loaded at startup"*).

### 10. Avoid vague *this / that / these / those*

> "The formula in revision is to ask of every this, these, those whether it might better be replaced by either plain old the (the most common option) or it, or such (a)."

A bare *"This causes…"* makes the reader scan back to figure out what *this* refers to. Either name the antecedent, or replace with `the` / `it`.

❌ *"This led to that, which caused these problems."*
✅ *"The budget cuts led to staff shortages, which caused project delays."*

In technical writing this rule is brutal: *"This means the cache invalidates."* → *"The new key means the cache invalidates."* The reader doesn't have to climb back up the paragraph.

## Quick checklist before generating

Voice (alexop.dev calibration):

- [ ] No banned words (see "Words to cut").
- [ ] Every claim has a number, file path, signature, or named tool behind it.
- [ ] Opening paragraph follows one of the four patterns above.
- [ ] Em-dashes used for asides, not parentheses; ≤3 per paragraph.
- [ ] At least one one-line paragraph for emphasis somewhere in the post.
- [ ] Callouts are claims, not summaries.
- [ ] Closing pulls back to the thesis; no roadmap, no CTA.

Discipline (Economical Writing — always on):

- [ ] No "In this post we'll…" / "This article…" openers (rule 3).
- [ ] Each paragraph has one point — no multi-topic paragraphs (rule 4).
- [ ] Connectives present where the reader would otherwise have to bridge (rule 5).
- [ ] No elegant variation — same entity, same name (rule 6).
- [ ] Comma after introductory clauses; no comma splices (rule 7).
- [ ] Each sentence ends on its load-bearing word (rule 8).
- [ ] Active verbs by default; passive only when the agent doesn't matter (rule 9).
- [ ] No bare *this / that / these / those* without a clear antecedent (rule 10).
