# Subagent report format (Step 2 of the blog-generator workflow)

When the main agent launches parallel `Task(subagent_type="Explore", …)` calls during Step 2 of the workflow, each subagent must return a structured note in the format below so the main agent can synthesise without re-reading files.

Each subagent investigates **one slice** of the codebase (e.g. "the build pipeline", "the persistence layer", "the tool injection mechanism"). It should report back:

- **Purpose** — what the slice does in plain English.
- **Key files** — absolute paths the post should cite.
- **Key types / functions** — names + 1-line signatures.
- **Notable design choices** — anything surprising, clever, or load-bearing.
- **One quotable code snippet** (5–15 lines) the post can show.

## Required format

```
SECTION: <slug>
  title: <plain-English heading>
  files: src/foo.ts:120-160, src/bar.ts
  key_idea: <2-3 sentences. Why this exists. What problem it solves.>
  signatures:
    - createFoo(env: Env): Foo
    - foo.run(): Promise<Result>
  snippet:
    lang: typescript
    code: |
      export function createFoo(env: Env): Foo {
        return { /* ... */ };
      }
  rebuild_note: <one sentence on what this becomes in the rebuild plan>
```

## Rules for the launching agent

- **Do NOT read files yourself** during Step 2 — let the subagents do it. The main context is reserved for HTML generation.
- **Launch all subagents in a single message** so they run in parallel. Sequential `Task` calls waste wall-clock time and serialise dependencies that don't exist.
- **3–6 slices** is the sweet spot. Fewer than 3 and you're not parallelising; more than 6 and the main agent struggles to synthesise.
- **Each slice must be independent.** If two slices need to read the same files, merge them.

## Rules for the subagent

- Cite **real file paths and line ranges** — `agent.ts:44-55`, not "in the agent module".
- Quote **real signatures**, not paraphrased pseudo-code.
- The `snippet` block should be the single most quotable 5–15 lines from the slice — the one the blog post will actually show.
- The `rebuild_note` is a one-liner that the main agent can lift verbatim into the rebuild plan.
