#!/usr/bin/env python3
"""validate_plan.py — gate script for the `plan` step.

Checks that $FACTORY_RUN_DIR/plan.md (or a path passed as arg 1):
  - exists
  - has YAML-ish frontmatter with `branch:` and `title:`
  - has a `## Tickets` section with at least one ticket bullet
  - each ticket has a `Done when:` sub-bullet

Exits 0 on pass, 1 on fail (with a human-readable error on stderr).
Intentionally no external deps — re.split + str.startswith, that's it.
"""

from __future__ import annotations

import os
import re
import sys
from pathlib import Path


def fail(msg: str) -> "NoReturn":
    sys.stderr.write(f"plan gate FAIL: {msg}\n")
    sys.exit(1)


def main() -> None:
    if len(sys.argv) >= 2:
        path = Path(sys.argv[1])
    else:
        run_dir = os.environ.get("FACTORY_RUN_DIR")
        if not run_dir:
            fail("FACTORY_RUN_DIR not set and no path argument given")
        path = Path(run_dir) / "plan.md"

    if not path.exists():
        fail(f"plan.md not found at {path}")

    text = path.read_text(encoding="utf-8")

    # Frontmatter must be the first thing in the file.
    if not text.startswith("---\n"):
        fail("missing frontmatter (file must start with '---')")

    parts = text.split("---\n", 2)
    if len(parts) < 3:
        fail("frontmatter not closed (need a second '---')")

    frontmatter, body = parts[1], parts[2]

    if not re.search(r"^branch:\s*\S", frontmatter, re.MULTILINE):
        fail("frontmatter missing `branch:`")
    if not re.search(r"^title:\s*\S", frontmatter, re.MULTILINE):
        fail("frontmatter missing `title:`")

    if "## Tickets" not in body:
        fail("missing `## Tickets` section")

    tickets_section = body.split("## Tickets", 1)[1]
    # End the section at the next `## ` heading.
    tickets_section = re.split(r"^## ", tickets_section, maxsplit=1, flags=re.MULTILINE)[0]

    ticket_titles = re.findall(r"^\s*-\s+\*\*T\d+\*\*", tickets_section, re.MULTILINE)
    if not ticket_titles:
        fail("no tickets found (expected `- **T1** — ...` bullets)")

    done_when_count = len(re.findall(r"Done when:", tickets_section))
    if done_when_count < len(ticket_titles):
        fail(
            f"only {done_when_count} `Done when:` lines for {len(ticket_titles)} tickets"
        )

    print(f"plan gate OK: {len(ticket_titles)} tickets")


if __name__ == "__main__":
    main()
