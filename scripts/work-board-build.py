#!/usr/bin/env python3
"""Collect every Work/ folder under a root into the board data file, data/board.json.

usage: work-board-build.py <root> <out/board.json>
"""

import json
import os
import re
import sys
from datetime import datetime

ORDER = ["UnderReview", "Active", "Ready", "Backlog", "Done", "Dropped"]
SKIP_DIRS = {".git", "Archive", "node_modules", "Runs"}


def main(root, out):
    projects = [project(root, d) for d in workDirs(root)]
    data = {
        "generated": datetime.now().strftime("%Y-%m-%d %H:%M"),
        "projects": projects,
    }
    json.dump(data, open(out, "w"), ensure_ascii=False)
    print(f"{sum(len(p['items']) for p in projects)} items in {len(projects)} projects -> {out} ({os.path.getsize(out)} bytes)")


def workDirs(root):
    for dirpath, dirnames, _ in os.walk(root):
        dirnames[:] = sorted(d for d in dirnames if d not in SKIP_DIRS and "--" not in d and not d.startswith("."))
        if os.path.basename(dirpath) == "Work" and os.path.exists(os.path.join(dirpath, "README.md")):
            dirnames[:] = []
            yield dirpath


def project(root, workDir):
    parent = os.path.dirname(workDir)
    name = os.path.basename(parent)
    if name == "WorkingFolder":
        name = os.path.basename(os.path.dirname(parent))
    items = []
    for bucket in sorted(os.listdir(workDir), key=lambda b: ORDER.index(b) if b in ORDER else len(ORDER)):
        path = os.path.join(workDir, bucket)
        if not os.path.isdir(path) or bucket in SKIP_DIRS:
            continue
        for f in sorted(os.listdir(path)):
            if f.endswith(".md") and f != "README.md":
                items.append(item(name, bucket, f, open(os.path.join(path, f)).read()))
    return {"name": name, "path": os.path.relpath(workDir, root), "items": items}


def item(projectName, bucket, filename, text):
    stem = filename[:-3]
    m = re.match(r"^(\d{4}-\d{2}-\d{2})-(.+)$", stem)
    date, name = (m.group(1), m.group(2)) if m else (None, stem)
    sections = splitSections(text)
    tasks = sections.get("Tasks", "")
    openBoxes = re.findall(r"^- \[ \] (.*)$", tasks, flags=re.M)
    doneBoxes = re.findall(r"^- \[x\] ", tasks, flags=re.M | re.I)
    header = dict(
        (k.strip(), v.strip())
        for k, v in re.findall(r"^> *(Type|Target|Waiting on|Autonomous|Paclet):\s*(.+?)\s*(?:<!--.*)?$", text, flags=re.M)
    )
    return {
        "id": re.sub(r"[^A-Za-z0-9._~-]", "-", f"{projectName}.{name}"),
        "name": name,
        "file": f"{bucket}/{filename}",
        "bucket": bucket,
        "date": date,
        "title": title(text, name),
        "summary": summary(sections, text),
        "type": header.get("Type", "").split()[0] if header.get("Type") else "",
        "target": header.get("Target", ""),
        "waiting": header.get("Waiting on", ""),
        "autonomous": header.get("Autonomous", "").startswith("allowed"),
        "open": len(openBoxes),
        "done": len(doneBoxes),
        "next": cleanTask(openBoxes[0]) if openBoxes else "",
        "nextHuman": bool(openBoxes) and "(human)" in openBoxes[0],
        "md": text,
    }


def splitSections(text):
    parts = re.split(r"^## +(.+?)\s*$", text, flags=re.M)
    return {parts[i].strip(): parts[i + 1] for i in range(1, len(parts) - 1, 2)}


def title(text, name):
    m = re.search(r"^# +(.+?)\s*$", text, flags=re.M)
    return m.group(1) if m else name


def summary(sections, text):
    source = sections.get("Summary") or sections.get("Spec") or text.split("\n## ", 1)[0]
    for para in re.split(r"\n\s*\n", source):
        p = para.strip()
        if not p or p.startswith(("#", ">", "<!--", "|", "```", "*[", "Origin:", "Reshaped")):
            continue
        if re.match(r"^[-*] ", p):
            p = re.split(r"\n[-*] ", p)[0][2:]
        p = plain(re.sub(r"\s+", " ", p))
        return p if len(p) <= 320 else p[:317].rsplit(" ", 1)[0] + "…"
    return ""


def cleanTask(line):
    line = re.sub(r"^(T\d+)\s*\((?:model|effort)[^)]*\)\s*", r"\1 ", line)
    return plain(re.sub(r"\s+", " ", line).strip())


def plain(s):
    s = re.sub(r"\[([^\]]+)\]\([^)]*\)", r"\1", s)
    return re.sub(r"(\*\*|__|(?<![\w`])\*(?=\S)|(?<=\S)\*(?![\w`]))", "", s)


if __name__ == "__main__":
    main(*sys.argv[1:3])
