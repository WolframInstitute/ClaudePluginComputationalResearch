#!/usr/bin/env python3
"""Regenerate the numbers in Wiki/Concepts/GeneratedPreambleAudit.md.

Applies the must-be-resident test of Wiki/Concepts/PreambleAudit.md to the CLAUDE.md
this plugin *generates* — claude_template.md / math_claude_template.md, each with
code_style_template.md appended — rather than to the plugin's own CLAUDE.md.

    python3 Wiki/Concepts/measure_generated_preamble.py

The classification is hand-assigned and asserted against the live templates, so an
edit to a template fails this script instead of silently misaligning the article.
Run with --before to classify the templates as they stood before S8's cuts.
"""

import os
import re
import subprocess
import sys

BEFORE_REV = "713177f"  # last commit before EvaluateWorkItemsEfficiency S8 (T9)

#   policy    — changes what a session does, and is unfindable at the point of use
#               because nothing tells you to look
#   reference — needed only by the skill that uses it, and that skill knows to look
#   inventory — a list of what exists on disk, answerable by `ls` when the question arises
CLASS = {
    "claude_template.md": {
        "# {{PROJECT_NAME}}": "title",
        "## Project goals": "policy",
        "## Code structure": "inventory",
        "## Resources": "inventory",
        "## Work": "policy",
        "## Provenance": "policy",
        "## Scientific journal": "policy",
        "## MCP usage": "policy",
        "## Loading code": "reference",
    },
    "math_claude_template.md": {
        "# {{PROJECT_NAME}}": "title",
        "## Project goals": "policy",
        "## Project type": "policy",
        "## Directory layout": "inventory",
        "## Work": "policy",
        "## Provenance": "policy",
        "## Scientific journal": "policy",
        "## Working style": "policy",
        "## MCP usage": "policy",
        "## Loading code": "reference",
        "## Commits": "policy",
    },
    "code_style_template.md": {
        "## Source formatting": "policy",
        "## Code style": "policy",
        "### Comments": "policy",
        "### Performance": "policy",
        "### Testing": "policy",
        "### Knowledge Base (Wiki)": "policy",
        "### Commits": "policy",
    },
}

# How the same headings classified before S8's cuts. `## Work` was a 600 B restatement of
# the scaffolded Work/README.md — reference; what survives is the Wiki-vs-Work split rule,
# which is policy. The skills listing existed only before.
BEFORE_OVERRIDE = {
    "claude_template.md": {"## Work": "reference"},
    "math_claude_template.md": {"## Work": "reference",
                                "## Skills tuned for this project type": "inventory"},
    "code_style_template.md": {},
}

# Sections whose dominant class hides bytes of another class. Recorded so the table's
# section-level granularity — the same granularity measure_preamble.py used — is honest.
IMPURE = {
    ("claude_template.md", "## Code structure"):
        ("policy", "`Notebooks/` is reserved for your hand-authored files and is never touched"),
    ("claude_template.md", "## Resources"):
        ("policy", "named as `Author_Year_Title.pdf`"),
    ("math_claude_template.md", "## Directory layout"):
        ("policy", "one `.md` per theorem"),
}

# Rules the template restates from the user's global ~/.claude/CLAUDE.md, which is also
# auto-loaded. Substance, not wording — matched by a probe phrase in each file.
GLOBAL_OVERLAP = [
    ("no defensive programming", "No defensive programming", "No defensive programming"),
    ("main functions first", "Main functions first", "Main functions first"),
    ("functional style", "Functional style", "Functional style preferred"),
    ("{x} |-> over Function", "not `Function[{x}, ...]`", "always use `{x} |-> ...`"),
]

# The contradiction: two auto-loaded files, one forbidding what the other mandates.
CONTRADICTION = (
    "no comments or docstrings unless explicitly requested",  # global ~/.claude/CLAUDE.md
    "One-line mathematical summary per exported symbol",  # code_style_template.md
)

root = subprocess.run(["git", "rev-parse", "--show-toplevel"],
                      capture_output=True, text=True).stdout.strip()
os.chdir(root)
ASSETS = "skills/new-project/assets"
before = "--before" in sys.argv


def read(name):
    path = f"{ASSETS}/{name}"
    if before:
        return subprocess.run(["git", "show", f"{BEFORE_REV}:{path}"],
                              capture_output=True, text=True).stdout
    return open(path).read()


def sections(text):
    """[(heading, bytes)] for every level 1-3 heading, section = heading through next heading."""
    lines = text.split("\n")
    idx = [i for i, l in enumerate(lines) if re.match(r"^#{1,3} ", l)] + [len(lines)]
    return [(lines[a], len(("\n".join(lines[a:b]) + "\n").encode())) for a, b in zip(idx, idx[1:])]


print(f"=== the generated CLAUDE.md, by section ({'before S8' if before else 'live'}) ===")
totals, blobs = {}, {}
for name, cls in CLASS.items():
    if before:
        cls = {**cls, **BEFORE_OVERRIDE[name]}
    text = read(name)
    blobs[name] = text
    sec = sections(text)
    if {h for h, _ in sec} != set(cls):
        sys.exit(f"CLASS is out of date with {name}:\n  "
                 + "\n  ".join(sorted({h for h, _ in sec} ^ set(cls))))
    print(f"\n  {name} ({len(text.encode())} B)")
    for h, n in sorted(sec, key=lambda x: -x[1]):
        mark = " *" if (name, h) in IMPURE else ""
        print(f"    {n:6d}  {cls[h]:9s}  {h}{mark}")
        totals.setdefault(name, {})
        totals[name][cls[h]] = totals[name].get(cls[h], 0) + n

for variant, base in (("standard", "claude_template.md"), ("math-research", "math_claude_template.md")):
    merged = {}
    for name in (base, "code_style_template.md"):
        for c, n in totals[name].items():
            merged[c] = merged.get(c, 0) + n
    total = sum(merged.values())
    print(f"\n  {variant}: {base} + code_style_template.md = {total} B")
    for c, n in sorted(merged.items(), key=lambda x: -x[1]):
        print(f"    {c:9s} {n:6d} B  {100*n/total:4.1f} %")

print("\n=== impure sections (bytes of another class inside a section) ===")
for (name, h), (cls, probe) in IMPURE.items():
    hit = probe in blobs[name]
    print(f"  {'ok ' if hit else 'MISSING'}  {name} {h}: contains {cls} — \"{probe[:48]}\"")
    if not hit:
        sys.exit(f"probe no longer present in {name}")

print("\n=== what the templates duplicate ===")
glob_path = os.path.expanduser("~/.claude/CLAUDE.md")
glob = open(glob_path).read() if os.path.exists(glob_path) else ""
if glob:
    print(f"  the user's global ~/.claude/CLAUDE.md, auto-loaded alongside: {len(glob.encode())} B")
    for label, tmpl_probe, glob_probe in GLOBAL_OVERLAP:
        both = tmpl_probe in blobs["code_style_template.md"] and glob_probe in glob
        print(f"    {'both' if both else '----'}  {label}")
else:
    print(f"  no global CLAUDE.md on this machine — overlap check skipped")

work_readme = read("work_readme_template.md") if False else open(f"{ASSETS}/work_readme_template.md").read()
print(f"\n  Work/README.md, scaffolded into every project: {len(work_readme.encode())} B")
for name in ("claude_template.md", "math_claude_template.md"):
    sec = dict(sections(blobs[name]))
    n = sec.get("## Work", 0)
    print(f"    {name} ## Work section restating it: {n} B")

skills = sorted(d for d in os.listdir("skills") if os.path.exists(f"skills/{d}/SKILL.md"))
desc = 0
for s in skills:
    fm = re.match(r"---\n(.*?)\n---\n", open(f"skills/{s}/SKILL.md").read(), re.S).group(1)
    desc += len(re.search(r"description: >?\s*\n?(.*)", fm, re.S).group(1).encode())
sec = dict(sections(blobs["math_claude_template.md"]))
print(f"\n  skill description: frontmatter, injected every session: {desc} B over {len(skills)} skills")
listing = sec.get("## Skills tuned for this project type", 0)
print(f"    math template's 'Skills tuned for this project type' listing 6 of them: "
      + (f"{listing} B" if listing else "deleted"))

print("\n=== the contradiction ===")
glob_hit = CONTRADICTION[0].lower() in glob.lower() if glob else False
tmpl_hit = CONTRADICTION[1] in blobs["code_style_template.md"]
print(f"  global forbids comments:  {glob_hit}  \"{CONTRADICTION[0]}\"")
print(f"  template mandates one:    {tmpl_hit}  \"{CONTRADICTION[1]}\"")
resolved = "**overrides** any global" in blobs["code_style_template.md"]
print(f"  precedence stated in the template: {resolved}")

print("\n=== the fixed term a scaffolded project pays ===")
FIXED = ["skills/next-session/SKILL.md", "skills/revise/SKILL.md"]
rest = [(f, os.path.getsize(f)) for f in FIXED]
for variant, base in (("standard", "claude_template.md"), ("math-research", "math_claude_template.md")):
    gen = len(blobs[base].encode()) + len(blobs["code_style_template.md"].encode()) + 1
    parts = [("generated CLAUDE.md", gen), ("global CLAUDE.md", len(glob.encode())),
             ("Work/README.md", len(work_readme.encode())),
             ("skill descriptions", desc), *((os.path.basename(os.path.dirname(f)), n) for f, n in rest)]
    print(f"  {variant:14s} " + " + ".join(f"{n}" for _, n in parts)
          + f" = {sum(n for _, n in parts)} B")
print("  (" + ", ".join(k for k, _ in parts) + ")")
