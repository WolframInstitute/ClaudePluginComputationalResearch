#!/usr/bin/env python3
"""Apply the board's pending.json to the Work/ files: section edits, notes, moves, new items.

usage: work-board-sync.py <pending.json> <board.json> <root> [--dry-run]

Prints a report of what it did and of what needs Claude's judgement (notes and kept
answers to fold into Technical details, index lines to update). Commits nothing.
"""

import json
import os
import re
import subprocess
import sys
from datetime import date

HUMAN = ["Summary", "Motivation", "Acceptance criteria"]
ORDER = HUMAN + ["Prompt history", "Technical details", "Spec", "Tasks"]
DATED = {"Done", "Dropped"}

NEW_ITEM = """# {title}

*[ LLM Generated ]*

> Type: research
> Waiting on: you — a `/refine` sitting; filed from the board on {date}.

## Summary

{summary}

## Motivation

{motivation}

## Acceptance criteria

- (to be written)

## Prompt history

- {date} — "{title}" — filed from the board.

## Technical details

(to be written in the first `/refine` sitting)

## Tasks

### Done

## Hand-off

(nothing yet)

## Decisions

| Date | Decision | Rationale |
|---|---|---|

## Progress
"""


def main(pendingPath, boardPath, root, dry=False):
    pending = json.load(open(pendingPath))
    board = json.load(open(boardPath))
    byId = {it["id"]: (p, it) for p in board["projects"] for it in p["items"]}
    report = {"edited": [], "moved": [], "created": [], "judge": [], "repos": set(), "missing": []}

    for itemId, e in pending.get("edits", {}).items():
        if itemId not in byId:
            report["missing"].append(itemId)
            continue
        proj, it = byId[itemId]
        workDir = os.path.join(root, proj["path"])
        path = os.path.join(workDir, it["file"])
        text = open(path).read()
        for name, body in e.get("sections", {}).items():
            text = withSection(text, name, body)
            report["edited"].append(f"{proj['name']}/{it['file']}: {name}")
        for n in e.get("notes", []):
            text = addPrompt(text, n["date"], n["text"])
            report["judge"].append({"item": f"{proj['name']}/{it['file']}", "kind": "note", **n})
        for k in e.get("kept", []):
            report["judge"].append({"item": f"{proj['name']}/{it['file']}", "kind": "kept answer", **k})
        if not dry:
            open(path, "w").write(text)
        report["repos"].add(workDir)
        if e.get("move"):
            dest = move(workDir, it, e["move"], dry)
            report["moved"].append(f"{proj['name']}: {it['file']} -> {dest}")

    for n in pending.get("newItems", []):
        proj = next(p for p in board["projects"] if p["name"] == n["project"])
        workDir = os.path.join(root, proj["path"])
        name = camel(n["title"])
        path = os.path.join(workDir, "Backlog", name + ".md")
        if os.path.exists(path):
            report["missing"].append(f"new item {name} already exists in {proj['name']}")
            continue
        if not dry:
            os.makedirs(os.path.dirname(path), exist_ok=True)
            open(path, "w").write(NEW_ITEM.format(
                title=n["title"], date=n["date"],
                summary=n.get("summary") or "(to be written)",
                motivation=n.get("motivation") or "- (to be written)"))
        report["created"].append(f"{proj['name']}/Backlog/{name}.md")
        report["repos"].add(workDir)

    report["repos"] = sorted(report["repos"])
    print(json.dumps(report, indent=1, ensure_ascii=False))


def sections(text):
    marks = [(m.group(1).strip(), m.start(), m.end()) for m in re.finditer(r"^## +(.+?)\s*$", text, flags=re.M)]
    return [(n, s, b, marks[i + 1][1] if i + 1 < len(marks) else len(text)) for i, (n, s, b) in enumerate(marks)]


def withSection(text, name, body):
    secs = sections(text)
    block = f"## {name}\n\n{body.strip()}\n\n"
    hit = next((s for s in secs if s[0] == name), None)
    if hit:
        return text[:hit[1]] + block + text[hit[3]:]
    after = ORDER[ORDER.index(name) + 1:]
    anchor = next((s for s in secs if s[0] in after), None)
    at = anchor[1] if anchor else len(text)
    return text[:at] + block + text[at:]


def addPrompt(text, day, words):
    quoted = re.sub(r"\s+", " ", words.strip()).replace('"', "'")
    line = f'- {day} — "{quoted}" (from the board)'
    secs = sections(text)
    hit = next((s for s in secs if s[0] == "Prompt history"), None)
    if hit:
        body = text[hit[2]:hit[3]].rstrip()
        return text[:hit[2]] + body + "\n" + line + "\n\n" + text[hit[3]:]
    return withSection(text, "Prompt history", line)


def move(workDir, it, to, dry):
    stem = it["file"].split("/", 1)[1][:-3]
    name = re.sub(r"^\d{4}-\d{2}-\d{2}-", "", stem)
    dest = f"{to}/{date.today().isoformat()}-{name}.md" if to in DATED else f"{to}/{name}.md"
    if not dry:
        os.makedirs(os.path.join(workDir, to), exist_ok=True)
        subprocess.run(["git", "-C", workDir, "mv", it["file"], dest], check=True)
    return dest


def camel(title):
    words = re.findall(r"[A-Za-z0-9]+", title)
    return "".join(w[:1].upper() + w[1:] for w in words)[:60] or "NewItem"


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if a != "--dry-run"]
    main(*args[:3], dry="--dry-run" in sys.argv)
