# Content Structure for Deep-Dive Blog Posts

How to plan and write the prose half of a `blog-generator` post. The HTML template is in [html-template.md](html-template.md); this doc is about *what to put inside it*.

## The thesis

A deep-dive post answers: **"How does this actually work, and could I rebuild it?"**

That's the bar. Anything that doesn't help the reader form a working mental model or answer the rebuild question should be cut.

## Section recipe

Below is the canonical 12-15 section structure for a library/SDK deep dive. Adapt section titles to the topic, but keep the *shape* — each section earns its place.

### 1. Mental model (always section 1)

**What it is**: One-paragraph reframe that resets the reader's expectations.

**The job**: Replace the reader's prior assumption about what the system *is* with the right one. This is the "if you only read one paragraph" section.

**Format**: Short. 80-120 words. End with a `.callout` that captures the reframe in a single sentence.

**Anti-pattern**: A summary of features. Keep features for later — this section is about the conceptual frame.

### 2. Layered architecture (always second)

**What it is**: Top-down overview diagram + 50 words.

**The job**: Show the layer cake before zooming in. The reader should be able to point at any layer and predict what's in it.

**Format**:
- One `flowchart TD` Mermaid diagram showing 4-7 layers stacked.
- Each node label has a short title + `<sub>` with key methods/responsibilities.
- One sentence after the diagram naming the **two layers worth understanding first**.

**Anti-pattern**: 12 layers. If you have 12, group into 5.

### 3. The core abstraction

**What it is**: The single interface or type that every other layer talks to.

**The job**: This is the load-bearing one. If the reader understands this, the rest of the system clicks. Quote the actual `interface` or `type`.

**Format**:
- One TypeScript code block with the real interface.
- 2-3 sentences explaining why this exact shape was chosen.
- Optional follow-up table listing 2-3 concrete implementations.
- A `.callout` for any non-obvious invariant ("this method must return a fresh instance per call").

### 4. The implementations / adapters

**What it is**: 2-3 concrete things that satisfy the core abstraction.

**The job**: Make the abstraction concrete. Compare them in a table.

**Format**: A table. Rows are the implementations, columns are *Backed by*, *File*, *Notable*. Then one paragraph each pulling out something interesting.

### 5. The main loop

**What it is**: How a request flows through the system.

**The job**: This is where the reader sees the whole machine in motion. Use a sequence diagram.

**Format**:
- 1 paragraph framing what the loop does.
- 1 short code block showing the entry point (the function that starts the loop).
- 1 `sequenceDiagram` Mermaid block with 4-5 participants.
- 1 paragraph after the diagram on what's *not* in it (what gets delegated, etc.).

### 6. Configuration assembly (or system-prompt assembly for AI systems)

**What it is**: How the system composes its config / prompt / state at startup.

**The job**: Show the surprisingly simple recipe behind something that looks magical. This is often where the reader has the biggest "oh, that's all?" moment.

**Format**:
- A pseudo-code or text block showing the assembly order.
- A `.callout` for any single-sentence trick that does heavy lifting.

### 7. The clever subsystem

**What it is**: The cleverest 100-300 LOC in the codebase. The trick worth stealing.

**The job**: Earn the "deep dive" label. This section should make a smart reader nod or laugh.

**Format**:
- 2 paragraphs framing the problem.
- 1 short code snippet showing the API.
- A `flowchart TD` Mermaid diagram of the internal state machine.
- A numbered list (5-7 items) walking through what happens when the trick fires.
- A closing one-liner: *"The whole pattern is &lt;200 LOC."*

This section often deserves twice the prose budget of others.

### 8. An orthogonal feature

**What it is**: A feature that composes with the rest — subagents, plugins, hooks, middlewares.

**The job**: Show the system's compositional reach. The reader should leave with a feel for *what extends naturally*.

**Format**: Standard prose + one bulleted lifecycle list.

### 9. A second clever bit

**What it is**: The second-cleverest thing. Often a "synthetic" version of something — fabricated events, fake state, audit trails.

**The job**: Reinforce that the design is *intentional*, not just lucky.

**Format**: 2-3 paragraphs + one tiny pseudo-history snippet.

### 10. Roles / overrides / precedence

**What it is**: How the system handles per-call customization.

**The job**: Show the precedence ladder. Readers want to know *which override wins*.

**Format**: One short text block with the ladder (`call > session > agent`), one paragraph on why it's that way.

### 11. Resource management (compaction, GC, batching)

**What it is**: How the system handles bounded resources — tokens, memory, connections.

**The job**: Show the system isn't naive. Anyone shipping this in production has hit these problems.

**Format**: Numbered list of 4-6 mechanism steps. One paragraph after on the failure mode.

### 12. The build / packaging pipeline

**What it is**: How source becomes deployable.

**The job**: Most posts skip this. Including it is what makes the rebuild plan real — the reader sees the seams.

**Format**:
- One `flowchart TD` Mermaid diagram of the pipeline.
- One paragraph on externalization, bundling, or any platform-specific quirk.

### 13. Persistence / state

**What it is**: What survives a restart, where it lives, and the keying scheme.

**Format**: One small interface block + 2 bullet points listing the implementations.

### 14. Rebuild plan (always last before close)

**What it is**: Numbered milestones that get the reader from blank repo to working clone.

**The job**: This is what the reader takes with them. Treat it like a checklist.

**Format**:
- Lead-in: *"Here's the order I'd do it in. Each step gives you something runnable."*
- 8-12 numbered `<h4>` headings.
- One short paragraph per step (3-5 sentences max).
- Each step should be **independently runnable** — *something* works at the end.
- The last step should be "add the second backend" or "wire up the second platform" — that's where you discover whether your abstractions held.

### 15. Closing notes

**What it is**: 100-200 words.

**The job**: Pull back. Name the thesis: *most of this is boring choices in tight composition.*

**Format**: 2-3 short paragraphs. End with an aphorism or a one-line recap.

## Voice rules

The full voice spec is in [voice.md](voice.md) — read it before generating prose. Quick recap:

- **Cite real files.** `agent.ts:44-55`, not "in the agent module."
- **Quote real signatures.** Not paraphrased pseudo-code.
- **Use callouts sparingly.** 2-4 per post. Each one is a load-bearing insight.
- **Em-dashes for asides**, not parentheses.
- **POV is flexible.** "I", "you", or "we" — pick whichever fits the sentence. Avoid marketing voice.
- **Name the surprise.** When something is clever, *say so*: "this is the single cleverest bit."

## Length targets

| Section | Words | Diagrams |
|---------|-------|----------|
| Mental model | 80-120 | 0 |
| Layered architecture | 60-100 | 1 (flowchart) |
| Core abstraction | 150-250 | 0 |
| Implementations | 120-200 | 0 |
| Main loop | 200-300 | 1 (sequence) |
| Config assembly | 150-200 | 0 |
| Clever subsystem | 350-500 | 1 (flowchart) |
| Orthogonal feature | 150-200 | 0 |
| Second clever bit | 150-200 | 0 |
| Roles / precedence | 100-150 | 0 |
| Resource mgmt | 150-200 | 0 |
| Build pipeline | 150-200 | 1 (flowchart) |
| Persistence | 100-150 | 0 |
| Rebuild plan | 400-700 | 0 |
| Closing | 100-200 | 0 |

**Total**: ~2,500-3,500 words, 4 diagrams. ~12-15 min read.

## Things that do NOT belong in a deep-dive

- Marketing language. "Powerful", "blazing-fast", "best-in-class" — gone.
- API reference. If a parameter list runs longer than 8 lines, you're writing docs not a post.
- Tutorial steps for the *user* of the library. The post is about *building* the library, not using it.
- "What is X?" framing for terms the reader knows. Skip "What is a Promise?" — assume technical baseline.
- Disclaimers. Don't soften strong observations.
- Future work / roadmap. The post is about what exists, not what's coming.

## When the topic isn't a library

The recipe still works for:

- **An architecture write-up** — sections 1-7, 12-15. Skip "implementations" if there's only one.
- **A mechanism explainer** ("how does X work") — collapse to sections 1, 3, 5, 7, 14. ~1,000 words.
- **A design-decision essay** — sections 1, 6, 7, 9, 14. Heavy on callouts.

## Final pass before generating HTML

Once the outline is drawn, run through this list:

- [ ] Each section answers a *question* the reader would ask, not a topic.
- [ ] At least 3 Mermaid diagrams across the post.
- [ ] At least 2 callouts highlighting load-bearing insights.
- [ ] No section is just "here's some code" — every code block has prose around it.
- [ ] The rebuild plan has 8-12 ordered, independent steps.
- [ ] Real file paths are cited at least 5 times across the post.

## Generation conventions

Voice, formatting, and tooling rules for the HTML generation pass (Step 4 of the workflow). The HTML *patterns* are in `html-template.md`; this section is about *what to put inside them*.

### Voice

The default voice is in [voice.md](voice.md) — calibrated to alexop.dev. Read it before writing. If the user supplied a different voice sample at trigger time, follow that instead.

Hard rules that apply on top of any voice:

- **Cite real files and line ranges**: `<code>build.ts:62-218</code>`.
- **Quote real signatures and short snippets**, not paraphrases.
- **Em-dashes for asides**, not parentheses.
- **Mark surprising design choices with `.callout`** — they're the highlight, not running commentary.

### Heading prefixes

`h2` and `h3` get a CSS-injected `# ` / `## ` prefix in the accent color (an AstroPaper convention). **Don't add the hash characters yourself** — the stylesheet does it via `::before`.

### Diagrams

- Use `flowchart TD` or `flowchart LR` for static structure.
- Use `sequenceDiagram` for the main loop.
- Keep node labels short; put detail in `<sub>` tags inside the label.
- **Don't add `classDef`** in Mermaid — the page CSS variables theme it via `themeVariables` already.
- Inside Mermaid, escape `<` as `&lt;` and `>` as `&gt;` (we're nested inside HTML).
- **Don't revert the Mermaid theme block to `` rgba(${styleVar(n)} / ${a}) ``** — that emits invalid CSS (Mermaid's engine only parses hex; the malformed string makes it silently fall back to its purple/cream defaults). Use the `hex()` / `rgba()` helpers in the template.

### Code blocks

- Tag every block with `class="language-XXX"`. Common: `language-ts`, `language-js`, `language-md`, `language-text`, `language-bash`, `language-json`.
- Use `language-text` for ASCII trees, prompt skeletons, and pseudo-history snippets.
- Keep blocks under 30 lines. If longer, split.
- Inside a code block, escape `<` `>` `&` as HTML entities.

### "Rebuild plan" section

- Always last (before "Closing notes").
- Use numbered `<h4>1. ` / `<h4>2. ` headings — the validator expects contiguous numbering starting at 1.
- One short paragraph per step (3–5 sentences max).
- Each step should be **independently runnable** — when the reader finishes step N, *something* works.
- Aim for 8–12 steps. The last step should be "add the second backend" or similar — that's where the abstractions get tested.
