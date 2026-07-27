#!/usr/bin/env python3
"""Per-section byte counts of every Work/ item file, for EvaluateWorkItemsEfficiency T3.

Regenerates the two tables in Wiki/Concepts/ItemFileFormat.md: the read path with and
without ## Progress, and the ## Decisions row count and bytes per row.

Run from the repo root:  python3 Wiki/Concepts/measure_item_sections.py
"""

import glob
import os
import re


def main():
    rows = [measureItem(path) for path in itemPaths()]
    printSections(rows)
    print()
    printDecisions(rows)
    print()
    printReadPath(rows)


def itemPaths():
    return sorted(glob.glob("Work/Done/*.md")) + sorted(glob.glob("Work/Active/*.md")) + sorted(
        glob.glob("Work/Backlog/*.md")
    )


def measureItem(path):
    text = open(path).read()
    parts = re.split(r"^## ", text, flags=re.M)
    sections = {chunk.split("\n")[0].strip(): len(chunk) + 3 for chunk in parts[1:]}
    decisionRows = [
        line
        for line in re.findall(r"^## Decisions\n(.*?)(?=^## |\Z)", text, flags=re.M | re.S)[0].splitlines()
        if re.match(r"^\| 20", line)
    ] if "## Decisions" in text else []
    return {
        "name": os.path.basename(path).removesuffix(".md"),
        "bucket": path.split("/")[1],
        "sessions": len(re.findall(r"^### Session", text, flags=re.M)),
        "progressLines": len(re.findall(r"^- \*\*S\d+\*\*", text, flags=re.M)),
        "total": len(text),
        "preamble": len(parts[0]),
        "spec": sections.get("Spec", 0),
        "tasks": sections.get("Tasks", 0),
        "handoff": sections.get("Hand-off", 0),
        "decisions": sections.get("Decisions", 0),
        "progress": sections.get("Progress", 0),
        "decisionRows": len(decisionRows),
        "decisionBytes": sum(len(line) + 1 for line in decisionRows),
    }


def printSections(rows):
    print("Section bytes")
    print(
        f"{'item':44s} {'S':>2} {'total':>6} {'pre':>4} {'spec':>6} {'tasks':>5} "
        f"{'hand':>5} {'dec':>5} {'prog':>6}"
    )
    for row in rows:
        print(
            f"{row['name'][:44]:44s} {sessionCount(row):2d} {row['total']:6d} {row['preamble']:4d} "
            f"{row['spec']:6d} {row['tasks']:5d} {row['handoff']:5d} {row['decisions']:5d} {row['progress']:6d}"
        )


def printDecisions(rows):
    print("Decisions table")
    print(f"{'item':44s} {'S':>2} {'rows':>4} {'bytes':>6} {'B/row':>6} {'rows/S':>7}")
    for row in rows:
        sessions = max(sessionCount(row), 1)
        perRow = row["decisionBytes"] // row["decisionRows"] if row["decisionRows"] else 0
        print(
            f"{row['name'][:44]:44s} {sessionCount(row):2d} {row['decisionRows']:4d} "
            f"{row['decisionBytes']:6d} {perRow:6d} {row['decisionRows'] / sessions:7.1f}"
        )


def printReadPath(rows):
    print("Read path — what next-session step 2 opens")
    print(f"{'item':44s} {'S':>2} {'whole file':>10} {'without Progress':>17} {'Spec+Decisions share':>21}")
    for row in rows:
        withoutProgress = row["total"] - row["progress"]
        share = (row["spec"] + row["decisions"]) / withoutProgress if withoutProgress else 0
        print(
            f"{row['name'][:44]:44s} {sessionCount(row):2d} {row['total']:10d} "
            f"{withoutProgress:17d} {share:20.0%}"
        )


def sessionCount(row):
    return row["sessions"] + row["progressLines"]


if __name__ == "__main__":
    main()
