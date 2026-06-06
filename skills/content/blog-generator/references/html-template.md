# HTML Template Reference

Reference for editing the AstroPaper-style blog skeleton. The full template lives as a real file at **`assets/blog-template.html`** — copy it, don't reconstruct it.

## Architecture

- **No build, no framework** — vanilla HTML + CSS + a tiny `<script>` for the theme toggle, plus two ESM CDN imports for Mermaid and Shiki.
- **Skin-token CSS variables** — colors expressed as `rgb(var(--color-*) / alpha)` so light/dark swap by adding/removing one class on `<html>`.
- **Theme toggle** — sun/moon SVGs, click flips the class, `localStorage` persists the choice, `themechange` event re-renders Mermaid + Shiki.
- **Native ES modules** — `<script type="module">` for both libraries; no Babel.
- **Click-to-zoom Mermaid diagrams** — every `<div class="mermaid">` is clickable; a native `<dialog id="diagram-dialog">` clones the rendered SVG into a fullscreen view. Hover hint via CSS `::after`. Closes on backdrop click, × button, or Escape.
- **Copy as Markdown button** — a `#copy-md-btn` in the meta line walks `<main>`, reads `data-src` / `data-lang` from Shiki-replaced and Mermaid-rendered blocks, and writes a clean Markdown serialisation to the clipboard. Lossless for code fences and Mermaid; converts callouts to blockquotes and tables to pipe tables.

## Required CDN Dependencies

```html
<!-- Mermaid 11 -->
import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';

<!-- Shiki 1.x -->
import { codeToHtml } from 'https://esm.sh/shiki@1.24.0';
```

Both load on first paint. The page must work fully offline once the bundles are cached.

## Skin Tokens (AstroPaper defaults)

| Token | Dark (default) | Light |
|-------|---------------|-------|
| `--color-fill`        | `33, 39, 55`     | `251, 254, 251` |
| `--color-text-base`   | `234, 237, 243`  | `40, 39, 40`    |
| `--color-accent`      | `255, 107, 1`    | `0, 108, 172`   |
| `--color-inverted`    | `33, 39, 55`     | `255, 255, 255` |
| `--color-card`        | `52, 63, 96`     | `230, 230, 230` |
| `--color-card-muted`  | `138, 51, 2`     | `205, 205, 205` |
| `--color-border`      | `171, 75, 8`     | `236, 233, 233` |

Values are RGB triplets so they can be combined with alpha via `rgb(var(--color-X) / 0.7)`.

## Mermaid theming

Mermaid's theme engine only reliably parses **hex colours** ("Only hex colors are recognized by the theming engine," per its docs). Our skin tokens are stored as RGB triplet strings (e.g. `"52, 63, 96"`) for use with `rgb(var(--…) / α)` in CSS — those triplets are *not* valid CSS colours on their own, and **must not** be passed straight into `themeVariables`. The template provides two helpers in the Mermaid `<script type="module">` block: `hex('--color-x')` returns `#rrggbb`, and `rgba('--color-x', α)` returns the legacy comma-separated `rgba(r, g, b, α)` form (which Mermaid does accept for alpha-blended edges).

The mapping below shows which CSS variable drives which Mermaid theme variable. Edit the helpers, not individual call sites — the assignments are intentionally uniform so a single change to the skin tokens repaints every diagram.

| Skin token | Mermaid variable(s) | Role |
|---|---|---|
| `--color-card` | `background`, `edgeLabelBackground`, `tertiaryColor`, `activationBkgColor` | Diagram container + small chrome fills |
| `--color-fill` | `primaryColor`, `mainBkg`, `actorBkg`, `labelBoxBkgColor` | Node / actor body fill (page bg — keeps nodes distinct from the card) |
| `--color-accent` | `primaryBorderColor`, `nodeBorder`, `actorBorder`, `signalColor`, `titleColor`, `labelBoxBorderColor`, `activationBorderColor` | All accent strokes / arrows |
| `--color-text-base` | `primaryTextColor`, `textColor`, `nodeTextColor`, `actorTextColor`, `signalTextColor`, `labelTextColor`, `loopTextColor`, `noteTextColor` (+ `lineColor`/`defaultLinkColor`/`actorLineColor` via `rgba` w/ low α) | Text + low-contrast edge lines |
| `--color-card-muted` | `secondaryColor`, `clusterBkg`, `noteBkgColor` | Subgroup / note fills |
| `--color-border` | `clusterBorder`, `noteBorderColor` | Subgroup / note strokes |
| `--color-inverted` | `sequenceNumberColor` | Text on accent-coloured chips |

The critical non-obvious rule: **`primaryColor` (node fill) must differ from `background` (container fill)**, otherwise nodes vanish into the surrounding `.mermaid` card. We map `primaryColor` to `--color-fill` (page bg) and `background` to `--color-card` (card bg) for that contrast.

## Workflow with the template

1. `cp <skill-root>/assets/blog-template.html blog-{slug}.html` at the project root.
2. Replace placeholders: `{{POST_TITLE}}`, `{{LEDE}}`, `{{KICKER}}`, `{{READ_MIN}}`, `{{SLUG}}`, `{{BRAND}}`, `{{FOOTER}}`.
3. Add TOC entries inside `<nav id="contents"><ol>…</ol></nav>` — one `<li><a href="#section-id">Title</a></li>` per section.
4. Insert the section content using the snippet patterns below, between the TOC and the `<footer>`.
5. Run `bash <skill-root>/scripts/validate-blog.sh blog-{slug}.html` before opening.

## Section patterns

Drop these into `<main>` between the TOC and the footer.

### Plain section

```html
<h2 id="section-slug">Section title</h2>
<p>Opening paragraph that frames why this section matters.</p>
<p>Second paragraph — usually concrete details.</p>
```

### Code block

Always include `class="language-X"`. Common langs: `ts`, `js`, `tsx`, `md`, `text`, `bash`, `json`, `yaml`, `html`, `css`.

```html
<pre><code class="language-ts">interface SessionEnv {
  exec(command: string): Promise&lt;ShellResult&gt;;
}</code></pre>
```

Use `&lt;` / `&gt;` / `&amp;` for HTML-entity escaping inside the block.

### Callout

```html
<div class="callout">
  <strong>The key insight.</strong> One-sentence elaboration that the reader
  should walk away remembering.
</div>
```

### Mermaid flowchart

```html
<div class="mermaid">
flowchart TD
    A["Step A<br/><sub>extra detail</sub>"] --&gt; B["Step B"]
    B --&gt; C{"Decision?"}
    C -- yes --&gt; D["Outcome 1"]
    C -- no  --&gt; E["Outcome 2"]
</div>
```

Use `&gt;` for `>` and `&lt;` for `<` inside Mermaid because we're already inside HTML.

> No extra markup is needed for the zoom feature — the template's CSS + dialog + delegated click handler pick up every `.mermaid` div automatically.

### Mermaid sequence diagram

```html
<div class="mermaid">
sequenceDiagram
    autonumber
    participant U as Caller
    participant S as System
    U-&gt;&gt;S: request
    S--&gt;&gt;U: response
</div>
```

### Table

```html
<table>
  <thead><tr><th>Col</th><th>Col</th></tr></thead>
  <tbody>
    <tr><td><code>foo</code></td><td>does X</td></tr>
  </tbody>
</table>
```

### Numbered rebuild step (h4)

```html
<h4>1. Define <code>SessionEnv</code></h4>
<p>One short paragraph saying what to do and why this is a good first step.</p>
```

## Anti-patterns

- **Don't** add Tailwind, React, or any framework. The skill is plain HTML on purpose.
- **Don't** prefix `h2`/`h3` text with `# ` / `## ` yourself — the CSS does that via `::before`.
- **Don't** style the Mermaid graph with `classDef` blocks. The `themeVariables` config already paints it from the live skin tokens.
- **Don't** forget the language class on a code block — Shiki silently leaves it as plain text.
- **Don't** leave an ASCII-art diagram in place of a Mermaid one. The skill ships diagrams as Mermaid for theme awareness.
- **Don't** edit `assets/blog-template.html` for a single post — copy it first, then edit the copy.
- **Don't** forget to run the validator (`scripts/validate-blog.sh`) and `open` the file at the end.
