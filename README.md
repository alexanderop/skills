# Alexander Opalic's Skills

[![skills.sh](https://skills.sh/b/alexanderop/skills)](https://skills.sh/alexanderop/skills)

Agent skills I use for engineering and writing. Small, composable, and installable in one command.

## Quickstart

```bash
npx skills@latest add alexanderop/skills
```

Pick the skills and the agents you want to install them on. That's it.

## Skills

### Engineering

- **[clone-repo](./skills/engineering/clone-repo/SKILL.md)** — Vendor a library's source into the current repo as a git subtree under `repos/<name>/` and wire it into `AGENTS.md`, so coding agents read real source instead of stale docs.
- **[factory-pipeline](./skills/engineering/factory-pipeline/SKILL.md)** — Run a multi-step coding pipeline (PRD → plan → TDD loop → review → PR) by orchestrating fresh subprocesses of your chosen coding harness (Claude Code, Codex, or Copilot CLI).
- **[lfg](./skills/engineering/lfg/SKILL.md)** — The full autonomous engineering pipeline end-to-end: recall, plan, TDD, review, verify, commit, push, open PR, watch CI, and compound the learning.

### Content

- **[blog-generator](./skills/content/blog-generator/SKILL.md)** — Generate a self-contained, deeply-technical "deep dive" blog post as a single offline-capable HTML file (AstroPaper aesthetic, light/dark toggle, Mermaid + Shiki via CDN).
- **[good-docs-writer](./skills/content/good-docs-writer/SKILL.md)** — Turn a topic into a structured blog-post draft for a developer audience, using The Good Docs Project templates as the structural backbone.

### Web

- **[app-screenshots](./skills/web/app-screenshots/SKILL.md)** — Generate annotated screenshot documentation for web apps and websites, local dev servers or live sites.

## Local development

Symlink every skill into `~/.claude/skills` so your local Claude CLI picks them up:

```bash
bash scripts/link-skills.sh
```

List what would be linked without touching anything:

```bash
bash scripts/list-skills.sh
```

## License

[MIT](./LICENSE)
