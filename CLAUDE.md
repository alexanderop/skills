# CLAUDE.md

This repo is a **single installable skills collection**, published via [skills.sh](https://skills.sh) and installed with `npx skills add alexanderop/skills`.

## Structure

```
.claude-plugin/plugin.json   # the manifest — lists every shipped skill path
skills/<bucket>/<name>/SKILL.md
scripts/link-skills.sh       # symlink shipped skills into ~/.claude/skills for local dev
scripts/list-skills.sh       # print manifest skills + check each has a SKILL.md
README.md                    # links every shipped skill to its SKILL.md
```

Buckets: `engineering/` (code work), `content/` (writing/docs), `web/` (browser/UI), `workflow/` (everyday git/PR helpers). `in-progress/` holds drafts that are **deliberately excluded** from `.claude-plugin/plugin.json` and `README.md` until they're ready to ship.

## Rules when adding or editing a skill

- A skill is a folder containing `SKILL.md` (uppercase) plus optional `references/`, `tools/`, `scripts/`, `assets/`.
- `SKILL.md` is the only file loaded at trigger time. Its frontmatter `description` governs activation — put the literal phrases a user would type into it. Push detailed how-to into `references/*.md`.
- **Every shipped skill must appear in BOTH `.claude-plugin/plugin.json` and `README.md`.** Run `bash scripts/list-skills.sh` to verify the manifest resolves.
- Bump `metadata.version` in a skill's frontmatter on meaningful behavior changes.
- Nested `SKILL.md` files inside a skill's own `references/` (e.g. `lfg`) are bundled resources, not separate skills — keep them out of the manifest.
