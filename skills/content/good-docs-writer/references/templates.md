# Templates catalog

The skill ships with a **bundled snapshot** of every Good Docs Project template
it supports — see [`templates/`](./templates/) and the provenance NOTICE in
[`templates/README.md`](./templates/README.md). Read these files locally with
the `Read` tool. **Do not WebFetch** at runtime — the bundled copies are the
source of truth, frozen at skill release time.

For each template key, two files matter:

- `templates/<key>/template.md` — the scaffold to fill in
- `templates/<key>/guide.md` — explains what each section/placeholder means

## Template keys → local paths

| Template key | Template (scaffold) | Guide (instructions) |
|--------------|---------------------|----------------------|
| `concept` | [`templates/concept/template.md`](./templates/concept/template.md) | [`templates/concept/guide.md`](./templates/concept/guide.md) |
| `tutorial` | [`templates/tutorial/template.md`](./templates/tutorial/template.md) | [`templates/tutorial/guide.md`](./templates/tutorial/guide.md) |
| `how-to` | [`templates/how-to/template.md`](./templates/how-to/template.md) | [`templates/how-to/guide.md`](./templates/how-to/guide.md) |
| `quickstart` | [`templates/quickstart/template.md`](./templates/quickstart/template.md) | [`templates/quickstart/guide.md`](./templates/quickstart/guide.md) |
| `troubleshooting` | [`templates/troubleshooting/template.md`](./templates/troubleshooting/template.md) | [`templates/troubleshooting/guide.md`](./templates/troubleshooting/guide.md) |
| `reference` | [`templates/reference/template.md`](./templates/reference/template.md) | [`templates/reference/guide.md`](./templates/reference/guide.md) |
| `glossary` | [`templates/glossary/template.md`](./templates/glossary/template.md) | [`templates/glossary/guide.md`](./templates/glossary/guide.md) |
| `release-notes` | [`templates/release-notes/template.md`](./templates/release-notes/template.md) | [`templates/release-notes/guide.md`](./templates/release-notes/guide.md) |
| `installation-guide` | [`templates/installation-guide/template.md`](./templates/installation-guide/template.md) | [`templates/installation-guide/guide.md`](./templates/installation-guide/guide.md) |
| `api-getting-started` | [`templates/api-getting-started/template.md`](./templates/api-getting-started/template.md) | [`templates/api-getting-started/guide.md`](./templates/api-getting-started/guide.md) |

## Cross-cutting writing references

Always also read these — template-agnostic, apply to every blog post:

- [`style-guide.md`](./style-guide.md) — Good Docs style guide (sentence case, voice, grammar)
- [`writing-tips.md`](./writing-tips.md) — Good Docs writing tips (concise, accurate, accessible)

## Read protocol

When the skill runs:

1. Resolve the template key from [`template-index.md`](./template-index.md).
2. **`Read` the local files** — `templates/<key>/template.md` and `templates/<key>/guide.md`. Read both before filling in the template; the guide explains each placeholder.
3. **`Read` `writing-tips.md`** once per session if the guidance is needed. The full `style-guide.md` is large (~49 KB) — only read it if you need to verify a specific style call.
4. The bundled snapshot is the source of truth. It is **not** automatically refreshed — see provenance and re-sync instructions in [`templates/README.md`](./templates/README.md), or run [`../tools/sync-templates.sh`](../tools/sync-templates.sh).

## Upstream

- Templates source: [gitlab.com/tgdp/templates](https://gitlab.com/tgdp/templates) (`main`)
- Project home: [thegooddocsproject.dev](https://www.thegooddocsproject.dev/)
- License: [MIT-0](./templates/LICENSE)
