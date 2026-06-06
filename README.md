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
- **[harden-github-actions](./skills/engineering/harden-github-actions/SKILL.md)** — Run `zizmor --persona pedantic` on any GitHub Actions workflow you create or edit, and fix every finding before calling it done.
- **[c4-architecture](./skills/engineering/c4-architecture/SKILL.md)** — Generate architecture documentation using C4-model Mermaid diagrams (context, container, component, deployment).

### Content

- **[blog-generator](./skills/content/blog-generator/SKILL.md)** — Generate a self-contained, deeply-technical "deep dive" blog post as a single offline-capable HTML file (AstroPaper aesthetic, light/dark toggle, Mermaid + Shiki via CDN).
- **[good-docs-writer](./skills/content/good-docs-writer/SKILL.md)** — Turn a topic into a structured blog-post draft for a developer audience, using The Good Docs Project templates as the structural backbone.

### Web

- **[app-screenshots](./skills/web/app-screenshots/SKILL.md)** — Generate annotated screenshot documentation for web apps and websites, local dev servers or live sites.
- **[qa-explore](./skills/web/qa-explore/SKILL.md)** — Exploratory browser QA: drive `agent-browser` through a real UI flow, capture screenshots + console output, and produce a structured pass/fail report with a ship recommendation.

### Workflow

Short helpers for the everyday git/PR loop.

- **[push](./skills/workflow/push/SKILL.md)** — Commit staged changes and push to remote.
- **[pr](./skills/workflow/pr/SKILL.md)** — Open a pull request from the current branch.
- **[check](./skills/workflow/check/SKILL.md)** — Review current changes with parallel subagents.
- **[fix-pipeline](./skills/workflow/fix-pipeline/SKILL.md)** — Check GitHub pipeline status and plan fixes if failing.
- **[interview](./skills/workflow/interview/SKILL.md)** — Get interviewed about the plan before building.
- **[learn](./skills/workflow/learn/SKILL.md)** — Analyze the conversation for learnings and save them to a docs folder.
- **[review-coderabbit](./skills/workflow/review-coderabbit/SKILL.md)** — Review CodeRabbit comments on the current PR and implement valid fixes.

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
