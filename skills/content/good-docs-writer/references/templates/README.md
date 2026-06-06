# Bundled Good Docs Project templates

The files under this directory are **verbatim copies** of templates from
[The Good Docs Project](https://www.thegooddocsproject.dev/), fetched from
[`gitlab.com/tgdp/templates`](https://gitlab.com/tgdp/templates) (`main` branch)
on **2026-04-25**.

## Provenance

| Local path | Upstream source |
|------------|-----------------|
| `<key>/template.md` | `https://gitlab.com/tgdp/templates/-/raw/main/<key>/template_<key>.md` |
| `<key>/guide.md` | `https://gitlab.com/tgdp/templates/-/raw/main/<key>/guide_<key>.md` |
| `LICENSE` | `https://gitlab.com/tgdp/templates/-/raw/main/LICENSE` |

`<key>` is one of: `concept`, `tutorial`, `how-to`, `quickstart`,
`troubleshooting`, `reference`, `glossary`, `release-notes`,
`installation-guide`, `api-getting-started`.

The cross-cutting files [`../style-guide.md`](../style-guide.md) and
[`../writing-tips.md`](../writing-tips.md) come from the same repo's root.

## License

Templates are © The Good Docs Project contributors and licensed under
**MIT-0** — see [`LICENSE`](./LICENSE) (the upstream license file, copied here
verbatim). MIT-0 permits redistribution without attribution, but this skill
attributes anyway because credit is the right thing.

## Re-syncing

The bundled snapshot is intentionally frozen so the skill is offline and
reproducible. To pull the latest from upstream, re-run the fetch script — see
[`../../tools/sync-templates.sh`](../../tools/sync-templates.sh) (if present)
or run:

```bash
BASE=https://gitlab.com/tgdp/templates/-/raw/main
for key in concept tutorial how-to quickstart troubleshooting reference glossary release-notes installation-guide api-getting-started; do
  curl -fsSL "$BASE/$key/template_$key.md" -o "$key/template.md"
  curl -fsSL "$BASE/$key/guide_$key.md"    -o "$key/guide.md"
done
curl -fsSL "$BASE/STYLE-GUIDE.md"  -o ../style-guide.md
curl -fsSL "$BASE/writing-tips.md" -o ../writing-tips.md
curl -fsSL "$BASE/LICENSE"         -o LICENSE
```

Bump `metadata.version` in `SKILL.md` after re-syncing so installed users see
the change.
