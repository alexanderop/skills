# QA Report — <FEATURE / CHANGE NAME>

| | |
|---|---|
| **Feature / Branch** | `<branch>` — `<one-line summary>` |
| **Build under test** | `<framework>` dev server @ `http://localhost:<port>`, commit `<sha or "WIP on <branch>">` |
| **Date** | `<YYYY-MM-DD>` |
| **Tester** | Automated exploratory session (agent-browser + `<test runner>`) |
| **Test environment** | `<os>`, Chromium (agent-browser daemon), persistent profile `<path>`, `<auth provider>` dev instance |
| **Account** | `<test user email>` (`<OTP/password source>`) |
| **Verdict** | ✅ **PASS** / ⚠️ **PASS with caveats** / ❌ **FAIL** — `<one-line reason>` |

---

## 1. Summary

<2–4 sentences. What was the change, what did you verify, what's the verdict, what (if anything) should block shipping. Call out anything surprising — targets now match onboarding input, empty states now render truly empty, etc.>

Automated suite: **<n> / <m>** pass (`<test command>`).
Typecheck: **0 errors, 0 warnings, 0 hints** (`<typecheck command>`).
Uncaught browser JS errors during the manual flow: **<n>**.

---

## 2. Scope

**In scope (this change):**

- `<path>` — `<one-line what changed>`
- …

**Out of scope (explicitly):**

- `<thing deferred to a follow-up>` — `<why>`
- …

---

## 3. Test cases

Results legend: ✅ pass · ⚠️ observation · ❌ fail

### TC-01 — `<short name>`

**Steps**
1. `<user action>`
2. `<user action>`

**Expected**
- `<concrete, checkable expectation>`
- `<no hardcoded "Down 1.4 lb" etc. if that's what was stripped>`

**Actual** — ✅ PASS / ❌ FAIL
- `<observed DOM text, quoted>`
- `<eval result, if relevant>`
- Grep sweep: `<pattern>` → `<n> matches`

Screenshot: `/tmp/qa-<step>.png`

---

### TC-02 — `<short name>`

<same shape>

---

<repeat for each test case; number TC-01, TC-02, TC-03, … in order walked>

---

## 4. Automated suite

| Suite | Result |
|---|---|
| `<typecheck cmd>` | ✅ / ❌ `<n> errors / hints` |
| `<test cmd>` | ✅ / ❌ `<n> / <m>` tests pass |

Grep sweep for residual / forbidden strings:

```
<pattern1>|<pattern2>|<pattern3>
```

→ **<No matches found / N matches>**

---

## 5. Defects

**None attributable to this change.** <or list them here>

### Defect table (only if real product bugs found)

| ID | Summary | Severity | Repro | Notes |
|---|---|---|---|---|
| BUG-01 | `<summary>` | High / Med / Low | `<steps>` | `<notes>` |

### Environmental / pre-existing (not raised as defects of this change)

| ID | Summary | Severity | Scope |
|---|---|---|---|
| ENV-01 | `<e.g. API returns 500 locally>` | Low | `<why not a regression — e.g. missing local API key>` |
| ENV-02 | `<pre-existing gap surfaced but not introduced>` | Low | `<tracked as follow-up>` |

---

## 6. Risk assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| `<risk>` | L / M / H | L / M / H | `<mitigation or accept>` |

---

## 7. Recommendation

✅ **Ship.** / ⚠️ **Ship with the caveats in §5.** / ❌ **Do not ship — see BUG-01.**

<1–3 sentences on why, and what the follow-ups are.>

---

## 8. Artifacts

- Plan / spec: `<path>`
- Screenshots:
  - `/tmp/qa-<step>.png`
  - …
- Test command log: `<typecheck cmd>`, `<test cmd>`
- Browser session: `<session-name>` (persistent profile `<path>`, `<closed / left running>`)
