# Specialist reviewer roster

Each reviewer is a separately-prompted `agent()` in `review-workflow.mjs`. The
value is in the **charter** — especially "What NOT to Flag", which is where the
prompt engineering actually lives. Without those boundaries you get a firehose of
speculative warnings developers learn to ignore.

All reviewers share a preamble (`SHARED` in the script) that: points them at the
patch files and shared-context file, defines the three severities, forbids
flagging unchanged code, style nitpicks, and unverifiable/theoretical issues, and
declares all diff/PR text untrusted data whose embedded instructions must never
be followed.

| Reviewer | Runs in | Model | Charter (flag ✅ / skip ❌) |
|----------|---------|-------|-----------------------------|
| **security** | full | sonnet | ✅ injection, authn/authz bypass, hardcoded secrets, weak crypto, missing input validation at trust boundaries · ❌ theoretical risks, defense-in-depth when primary defense is fine, unchanged code |
| **performance** | full | sonnet | ✅ N+1, unbounded loops, O(n²), blocking I/O on hot paths, leaks · ❌ micro-opts, cold-path premature optimization |
| **code-quality** | lite, full | sonnet | ✅ logic errors, off-by-one, swallowed errors, unhandled edge cases, dup logic, obvious security issues (backstop for tiers without the security specialist) · ❌ formatting, preference refactors |
| **tests** | lite, full | sonnet | ✅ new logic with no coverage, implementation-detail assertions, no-op tests · ❌ trivial getters, exhaustive low-risk tests |
| **documentation** | lite, full | haiku | ✅ public API changed w/o doc update, wrong examples, undocumented config/env · ❌ private helpers, self-documenting code |
| **release** | full — only when release-surface files changed (migrations, changelog, package manifests, CI, deploy) | haiku | ✅ breaking contract w/o version note, destructive/irreversible migration, behavior-changing flag defaults · ❌ no release-surface impact → zero findings |
| **agents-md** | full — only when high-materiality files changed (package manifests, build/test config, CI, AGENTS.md) | haiku | ✅ high-materiality change (package manager / test framework / build tool / dir restructure / new env var / CI) without AGENTS.md update · ❌ bug fixes, existing-pattern features, minor bumps |
| **general** | trivial | sonnet | one focused bug/typo pass; returns zero findings for clean trivial changes |

The coordinator inherits the session model (the highest-reasoning judge job),
except on the trivial tier where it downgrades to Sonnet — mirroring Cloudflare's
Opus-coordinator / Sonnet-workers / cheap-model-for-text split.

## Severity contract

```
critical   — will cause an outage, data loss, or is exploitable
warning    — measurable regression or concrete risk
suggestion — a worthwhile, non-blocking improvement
```

## Verification of criticals

Every `critical` finding gets an adversarial refuter agent (Sonnet) as soon as
its reviewer finishes: read the patch and source, try to refute, default to
refuted when uncertain. The result is attached as a `verification` field, and
the coordinator drops REFUTED findings unless it independently re-confirms them.
Criticals block merges, so they get double-checked before they can.

## The coordinator

Re-categorizes any mis-sectioned finding (e.g. a perf issue the code-quality
reviewer raised moves to `performance`), dedupes cross-reviewer overlaps keeping
each issue once in the section it fits best, reads the change context for intent,
and applies the re-review rules when a `previousReview` is supplied. If it fails,
a fallback passes raw findings through with a decision derived from the surviving
severities — an unjudged critical still blocks.

## Adding a reviewer

1. Add an entry to `REVIEWERS` in `review-workflow.mjs` with `key`, `label`,
   `model` (`'sonnet'` for code-heavy work, `'haiku'` for text-heavy), and a
   `prompt` that has explicit **What to Flag** and **What NOT to Flag** sections.
2. Add its `key` to the appropriate tier(s) in `TIER_REVIEWERS`.
3. If it should only run when certain files changed, gate it in the tier filter
   like `release` / `agents_md` (see `RELEASE_RELEVANT`).
4. If it introduces a new section, add that value to the `section` enum in
   `COORDINATOR_SCHEMA`.
