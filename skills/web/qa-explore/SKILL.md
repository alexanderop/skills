---
name: qa-explore
description: Exploratory browser QA — drive agent-browser through a real UI flow, capture screenshots and console output, then produce a structured markdown report with TC-## test cases, pass/fail verdicts, defects, risks and a ship recommendation. Use this whenever the user says "qa this", "verify like a qa engineer", "exploratory test", "manually verify in browser", "drive the browser and check X works", or asks for a QA report on a change. Prefer this over just running automated tests when the user explicitly wants hands-on, real-browser verification.
argument-hint: [optional: feature / branch / flow to verify]
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# QA Explore

Act as a hands-on QA engineer. Drive a real browser, walk the flow a user would walk, capture evidence, and deliver a written report. The goal is to **prove the feature actually works** — not just that the code type-checks.

Argument (if provided): **$ARGUMENTS** — treat this as the feature, branch, or flow under test. If empty, infer from the recent conversation (the last implementation, the current branch diff, the open file).

## Why this exists

Type-check + unit tests prove code correctness. They don't prove feature correctness. Things that slip past them: wrong copy rendered, silent fallbacks, empty states that render blank, nav that routes to a 404, API-dependent flows that secretly 500, components that throw on first mount for new accounts. The only way to catch these is to actually use the app.

## Phase 0 — Orient

Before touching the browser, spend one or two minutes figuring out the terrain. Do these in parallel where you can:

1. **Read `CLAUDE.md`** (project root) and any referenced brain/docs files for the dev command, test command, test-credentials path, and testing conventions.
2. **Inspect `package.json` scripts** — what's `dev` / `test` / `typecheck`? Which port?
3. **Look for test-credentials notes** — common paths: `brain/local/test-credentials.md`, `docs/local/*`, `.env.local`. If Clerk is in use, note the `+clerk_test` convention and the `424242` OTP.
4. **Identify the flow** — which routes, which state transitions, which edge cases. From the argument, the recent diff, or by asking.

If the user's intent is ambiguous (e.g. "qa this" with no diff), ask one concise clarifying question and then proceed.

## Phase 1 — Bring the app up

```bash
# Start the dev server in the background; capture its output path.
pnpm dev   # or npm run dev / yarn dev — whatever package.json says
```

Run in background (`run_in_background: true`). Poll the output file until the "ready" banner appears (e.g. Astro: `Local    http://localhost:4321/`, Next: `ready on http://…`). Use the **real** port from the banner — don't guess.

If a server is already running on the expected port, reuse it. Don't start a second one.

## Phase 2 — Browser session

Use **agent-browser** with a persistent named session so auth and local-first storage survive across runs:

```bash
agent-browser --session-name <project>-qa \
  --profile ~/.<project>-qa-profile \
  open http://localhost:<port>
```

Then set `AGENT_BROWSER_SESSION=<project>-qa` in subsequent commands so every call targets the same window:

```bash
AGENT_BROWSER_SESSION=<project>-qa agent-browser wait --load networkidle
AGENT_BROWSER_SESSION=<project>-qa agent-browser snapshot -i -u
```

Core commands you'll use constantly:

| Command | Use for |
|---|---|
| `snapshot -i -u` | Accessibility tree with interactive elements + URLs. Refs are `@e1`, `@e2`… and **only valid until the next DOM mutation**. |
| `screenshot /tmp/qa-<step>.png` | Save a visual. Read it back via `Read` to actually see it. |
| `click @eN` / `fill @eN "text"` / `press Enter` | Act on refs. Re-snapshot after any action that changes the page. |
| `eval "<js>"` | Last-resort inspection — read `window.location.href`, a textarea `.value`, a computed style. |
| `console` | Full browser console log. Filter mentally for `[error]`. |
| `errors` | **Uncaught** JS exceptions only. This is the cleanest signal. |
| `wait --load networkidle` / `wait --text "X"` / `wait --fn "<expr>"` | Wait on real signals. Never sleep arbitrarily. |
| `close` | End of session — do this in Phase 5. |

### Navigating client-side routes

Frameworks like TanStack Router, Next App Router with client nav, or SvelteKit often 404 on direct URL loads for routes that were pushed in by a prior client nav. If `open http://.../some/route` gives a 404, navigate via the router instead:

```bash
AGENT_BROWSER_SESSION=<project>-qa agent-browser eval \
  "window.history.pushState({}, '', '/app/insights'); window.dispatchEvent(new PopStateEvent('popstate'))"
```

### Authenticating (if the flow requires it)

For Clerk dev instances, use the `+clerk_test` email with OTP `424242` (no real email required). Load creds from the project's test-credentials file rather than hardcoding. Fill email, submit, fill OTP, submit, wait for redirect.

After login, verify the landing URL with `eval "window.location.href"` before you proceed — don't trust that a click "worked".

## Phase 3 — Walk the flow

For each test case:

1. **Navigate** to the route.
2. **Wait** for a real signal (`networkidle` is a decent default; prefer `wait --text` when you know a specific string should appear).
3. **Snapshot** (`snapshot -i -u`) — capture what's interactive and where links go.
4. **Screenshot** to `/tmp/qa-<route>.png` — later you'll `Read` it inline into your report reasoning.
5. **Compare against expectation** — is the copy right? Is the empty state an empty state, or is the old demo data leaking through? Are goal/target values the user's own, not the migration defaults?
6. **Act and re-snapshot** — refs go stale after any DOM change, so always re-snapshot before the next click.

Things worth checking at every step:

- **Console & errors.** Run `errors` once at the end of the flow; scan `console` for `[error]` entries. Distinguish product bugs (uncaught exceptions, React errors) from environmental noise (API 500s because a key isn't set locally).
- **DOM vs screenshot.** Screenshots don't reveal state. Pair them with `eval "document.querySelector('textarea').value"` or similar when value matters.
- **Round-trip when possible.** If you log a meal, post a message, edit a setting — navigate back and confirm the downstream view actually updated.
- **Don't skip the boring views.** Profile pages, settings pages, empty-state cards. Those are where demo data loves to hide.

### When something fails

If a screen is blank or wrong, don't immediately declare a bug. Check:

1. Is `window.location.href` what you expect? (You might have landed on `about:blank`.)
2. Did `open` actually navigate? Re-issue with the full URL.
3. Is there a Jazz / IndexedDB / service-worker migration happening on first load? `wait --fn` on a real app signal.
4. Are the console errors *real*, or are they an unrelated API the local env doesn't have keys for?

Triage before reporting.

## Phase 4 — Automated cross-check

In parallel with (or right after) the manual walk, run the project's own suites and a targeted grep sweep for data you expected to remove / change:

```bash
pnpm typecheck   # or equivalent
pnpm test        # or equivalent
```

Example grep sweep for the common "removed demo data" case:

```bash
# Pick terms relevant to what was removed.
rg 'MOCK_|SAMPLE_|DEMO_|TODO_DEMO|<specific-string-you-killed>' src/
```

Automated green + zero grep matches + zero uncaught browser errors = strong triangulation.

## Phase 5 — Tear down

```bash
AGENT_BROWSER_SESSION=<project>-qa agent-browser close
```

Leave the dev server up unless you started it for this task and the user isn't using it.

## Phase 6 — Write the report

Write the report as a markdown file in the project root (or a project-conventional location like `docs/qa/` if it exists). Default filename: `qa-report-<feature-slug>.md`. Use the template at `assets/report-template.md` (sibling of this SKILL.md) — copy it, then fill every section from the evidence you captured.

Report discipline:

- **Every TC needs evidence.** "Actual" is not the place for vibes — quote the DOM text you saw, name the screenshot path, paste the eval result.
- **Separate product bugs from environmental noise.** Use the "Observation" table, not the defect table, for API 500s caused by missing local keys, etc. A real QA report loses credibility fast if it cries wolf.
- **Scope is honest.** If you didn't exercise a path, say so. "Round-trip not verified manually (API returns 500 locally); covered by automated suite in `add-meal-flow.test.tsx`" is a perfectly fine actual.
- **One recommendation.** Ship / don't ship / ship with caveats. The user came here for a decision.

### Ending the turn

Tell the user in one or two sentences where the report is, the verdict, and any caveat. Link screenshot paths so they can open them. Don't recap the body of the report.

## Gotchas the hard way

- `snapshot -i` (interactive only) often returns "no interactive elements" before the app has hydrated. Wait on `networkidle` first, or re-issue after a short `wait`.
- Refs **do not survive** navigation or most clicks. Re-snapshot.
- `agent-browser open <url>` occasionally leaves you at `about:blank` — verify with `eval "window.location.href"`.
- Client-routed URLs that return 404 on direct load are a framework behaviour, not a bug — use `history.pushState` as shown above.
- `errors` returning no output is the best possible result. An empty `errors` is not a tool failure.
- Jazz / local-first apps persist in the profile directory. For "brand-new-user" tests, use a **fresh** `--profile` path. For "returning-user" tests, reuse one.
- Don't `cd` into the project and fight with paths — use absolute paths for the profile and for screenshots so the session is portable.
