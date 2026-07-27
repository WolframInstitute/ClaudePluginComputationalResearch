#!/usr/bin/env python3
"""Regenerate the numbers in Wiki/Concepts/PreambleAudit.md.

Measures the auto-loaded preamble of this repo: how CLAUDE.md's bytes split between
policy, reference, and inventory; how much of the inventory is already in context by
other means; and what the split into ARCHITECTURE.md bought.

    python3 Wiki/Concepts/measure_preamble.py

BEFORE_REV is the last commit before EvaluateWorkItemsEfficiency S5 (T6) split the file.
"""

import os
import re
import subprocess
import sys

BEFORE_REV = "4f4ac07"
FIXED = ["CLAUDE.md", "skills/next-session/SKILL.md", "skills/revise/SKILL.md", "Work/README.md"]

# Classification of the pre-split CLAUDE.md sections. Hand-assigned, asserted against the
# live blob below, so an edit to the file fails this script instead of silently drifting.
#   policy    — changes what a session does, and is unfindable at the point of use because
#               nothing tells you to look
#   reference — needed only by the skill that uses it, and that skill knows to look
#   inventory — a list of what exists on disk
CLASS = {
    "# Computational Research Plugin": "title",
    "## Source formatting": "policy",
    "## Wolfram Kernel Execution Policy": "policy",
    "## Plugin Architecture": "reference",
    "### Skills (20)": "inventory",
    "### Scripts (27)": "inventory",
    "### Commands (21)": "inventory",
    "### Templates (in skills/new-project/assets/)": "inventory",
    "## Project Types (scaffolding)": "reference",
    "## Knowledge Base (Wiki)": "policy",
    "### Notebook conversion engines": "reference",
    "## How to Add a New Skill": "reference",
    "## Plugin Maintenance": "policy",
    "### Blog post": "policy",
    "### Keeping CLAUDE.md current": "policy",
}

root = subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True, text=True).stdout.strip()
os.chdir(root)


def git(*args):
    return subprocess.run(["git", *args], capture_output=True, text=True).stdout


def sections(text):
    """[(heading, bytes)] for every level 1-3 heading, section = heading through next heading."""
    lines = text.split("\n")
    idx = [i for i, l in enumerate(lines) if re.match(r"^#{1,3} ", l)] + [len(lines)]
    return [(lines[a], len(("\n".join(lines[a:b]) + "\n").encode())) for a, b in zip(idx, idx[1:])]


before = git("show", f"{BEFORE_REV}:CLAUDE.md")
after = open("CLAUDE.md").read()
arch = open("ARCHITECTURE.md").read() if os.path.exists("ARCHITECTURE.md") else ""

print(f"=== CLAUDE.md at {BEFORE_REV}, by section ===")
by_class = {}
sec = sections(before)
if {h for h, _ in sec} != set(CLASS):
    sys.exit(f"CLASS is out of date with {BEFORE_REV}:CLAUDE.md:\n  "
             + "\n  ".join(sorted({h for h, _ in sec} ^ set(CLASS))))
for h, n in sorted(sec, key=lambda x: -x[1]):
    print(f"  {n:6d}  {CLASS[h]:9s}  {h}")
    by_class[CLASS[h]] = by_class.get(CLASS[h], 0) + n
total_before = sum(n for _, n in sec)
print(f"  {total_before:6d}  TOTAL")
for c, n in sorted(by_class.items(), key=lambda x: -x[1]):
    print(f"    {c:9s} {n:6d} B  {100*n/total_before:4.1f} %")

print("\n=== what the inventory duplicates ===")
skills = sorted(d for d in os.listdir("skills") if os.path.exists(f"skills/{d}/SKILL.md"))
desc = 0
for s in skills:
    fm = re.match(r"---\n(.*?)\n---\n", open(f"skills/{s}/SKILL.md").read(), re.S).group(1)
    desc += len(re.search(r"description: >?\s*\n?(.*)", fm, re.S).group(1).encode())
print(f"  skill description: frontmatter, injected by the harness every session: {desc} B over {len(skills)} skills")
print(f"  CLAUDE.md Skills table it duplicated: {by_class and dict(sec)['### Skills (20)']} B")
print(f"  README.md, the human-facing copy: {os.path.getsize('README.md')} B")

print("\n=== inventory drift at HEAD~ ===")
counts = {
    "Skills": len(skills),
    "Scripts": len(os.listdir("scripts")),
    "Commands": len(os.listdir("commands")),
    "Templates": len(os.listdir("skills/new-project/assets")),
}
for name, n in counts.items():
    m = re.search(rf"^### {name} \((\d+)\)", before, re.M)
    claimed = int(m.group(1)) if m else None
    flag = "ok" if claimed == n else (
        "no count in heading" if claimed is None else f"STALE (heading said {claimed})")
    print(f"  {name:10s} on disk {n:3d}   {flag}")

print("\n=== cost of keeping the inventory current ===")
revs = git("log", "--format=%h", "--follow", "--", "CLAUDE.md").split()
touched = only = 0
for h in revs:
    changed = [l for l in git("show", h, "--", "CLAUDE.md").split("\n") if re.match(r"^[+-][^+-]", l)]
    rows = [l for l in changed if l[1:].lstrip().startswith("|")]
    touched += bool(rows)
    only += bool(rows) and len(rows) == len(changed)
print(f"  commits to CLAUDE.md: {len(revs)}; touched a table: {touched}; table rows only: {only}")

print("\n=== the fixed term, before and after ===")
rest_before = [len(git("show", f"{BEFORE_REV}:{f}").encode()) for f in FIXED[1:]]
rest_after = [os.path.getsize(f) for f in FIXED[1:]]
for label, claude, rest in (("before", len(before.encode()), rest_before),
                            ("after", len(after.encode()), rest_after)):
    print(f"  {label:6s} CLAUDE.md {claude:6d} + {' + '.join(map(str, rest))} = {claude + sum(rest)} B")
print(f"  moved to ARCHITECTURE.md (read on demand): {len(arch.encode())} B")
