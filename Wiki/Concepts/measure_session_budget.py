#!/usr/bin/env python3
"""Regenerate every number in Wiki/Concepts/SessionInformationBudget.md from git history.

Measures the bookkeeping information budget of the Work/ + next-session system:
fixed per-session overhead, item-file growth, what the partial-read rule of
next-session step 2 actually saves, and how much of a mature item file is inert.

Gotcha: `git log --follow --reverse` collapses to one commit (--follow needs the
reverse-chronological walk). Use --follow alone and reverse in Python.
"""

import os, re, subprocess

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

FIXED = ["CLAUDE.md", "skills/next-session/SKILL.md", "skills/revise/SKILL.md", "Work/README.md"]
SECTIONS = ("Spec", "Tasks", "Progress", "Decisions")


def git(*args):
    return subprocess.run(["git", "-C", REPO, *args], capture_output=True, text=True).stdout


def sections(text):
    """Byte size of each top-level `## ` section, plus preamble and total."""
    heads = [(m.start(), m.group(1)) for m in re.finditer(r"(?m)^## (.+)$", text)]
    out = {"preamble": len(text[: heads[0][0]].encode()) if heads else len(text.encode())}
    for i, (pos, name) in enumerate(heads):
        end = heads[i + 1][0] if i + 1 < len(heads) else len(text)
        key = name.strip().split()[0]
        out[key] = out.get(key, 0) + len(text[pos:end].encode())
    out["total"] = len(text.encode())
    return out


def progress_blocks(text):
    """(heading, bytes) per `### Session` block inside `## Progress`."""
    body = re.search(r"(?ms)^## Progress\b(.*?)(?=^## |\Z)", text)
    if not body:
        return []
    body = body.group(1)
    heads = [(m.start(), m.group(0).strip()) for m in re.finditer(r"(?m)^### .+$", body)]
    return [
        (head, len(body[pos : (heads[i + 1][0] if i + 1 < len(heads) else len(body))].encode()))
        for i, (pos, head) in enumerate(heads)
    ]


def history(path):
    """Chronological [(sha, subject, sections, blocks)] for an item, across renames."""
    base = os.path.basename(path)
    stem = re.sub(r"^\d{4}-\d\d-\d\d-", "", base)
    candidates = [f"Work/Done/{base}", f"Work/Active/{stem}", f"Work/Backlog/{stem}"]
    entries = []
    for line in reversed(git("log", "--follow", "--format=%H|%s", "--", path).splitlines()):
        sha, subject = line.split("|", 1)
        for candidate in candidates:
            text = git("show", f"{sha}:{candidate}")
            if text:
                entries.append((sha[:7], subject, sections(text), progress_blocks(text)))
                break
    return entries


def rule_bytes(sect, blocks):
    """next-session step 2: full preamble/Spec/Tasks, Progress tail of 2, plus Decisions."""
    tail = sum(b for _, b in blocks[-2:])
    intro = sect.get("Progress", 0) - sum(b for _, b in blocks)
    return (sect["preamble"] + sect.get("Spec", 0) + sect.get("Tasks", 0)
            + intro + tail + sect.get("Decisions", 0))


items = {p: history(p) for p in git("ls-files", "Work/Done").splitlines() if p.endswith(".md")}
short = lambda p: re.sub(r"^\d{4}-\d\d-\d\d-", "", os.path.basename(p))[:-3]

fixed = {f: len(git("show", f"HEAD:{f}").encode()) for f in FIXED}
print("FIXED PER-SESSION OVERHEAD")
for name, size in fixed.items():
    print(f"  {name:<32} {size:>7}")
print(f"  {'TOTAL':<32} {sum(fixed.values()):>7}")

print("\nITEM FILE GROWTH  (per commit: total / section bytes)")
for path, hist in items.items():
    print(f"  {short(path)}")
    for sha, subject, sect, blocks in hist:
        print(f"    {sha} tot={sect['total']:>6} spec={sect.get('Spec', 0):>5} "
              f"tasks={sect.get('Tasks', 0):>5} prog={sect.get('Progress', 0):>6} "
              f"dec={sect.get('Decisions', 0):>5} blocks={len(blocks)}  {subject[:44]}")

print("\nPROGRESS GROWTH PER SESSION")
for path, hist in items.items():
    seq = [s.get("Progress", 0) for _, _, s, _ in hist]
    deltas = [b - a for a, b in zip(seq, seq[1:]) if b > a]
    if deltas:
        print(f"  {short(path):<28} {deltas}  mean={sum(deltas) // len(deltas)}")

print("\nSPEC / DECISIONS DRIFT OVER THE ITEM'S LIFE")
for path, hist in items.items():
    first, last = hist[0][2], hist[-1][2]
    print(f"  {short(path):<28} Spec {first.get('Spec', 0):>5} -> {last.get('Spec', 0):>5}"
          f"   Decisions {first.get('Decisions', 0):>5} -> {last.get('Decisions', 0):>5}")

print("\nWHAT THE PARTIAL-READ RULE AVOIDS  (each state a session had to start from)")
totals = [0, 0]
states = []
for path, hist in items.items():
    for i in range(1, len(hist)):
        _, _, sect, blocks = hist[i - 1]
        full, rule = sect["total"], rule_bytes(sect, blocks)
        totals[0] += full
        totals[1] += rule
        states.append(full)
        print(f"  {short(path) + ' #' + str(i):<32} full={full:>6} rule={rule:>6} "
              f"avoided={100 * (full - rule) / full:>3.0f}%")
states.sort()
median = (states[len(states) // 2 - 1] + states[len(states) // 2]) / 2
print(f"  ALL {len(states)} states: full={totals[0]} rule={totals[1]} "
      f"avoided={100 * (totals[0] - totals[1]) / totals[0]:.0f}%")
print(f"  item file at session start: {min(states)}..{max(states)}, median {median:.0f}")
print(f"  states where the item file was SMALLER than the fixed overhead "
      f"({sum(fixed.values())}): {sum(s < sum(fixed.values()) for s in states)}/{len(states)}")
print(f"  states where the item file was smaller than CLAUDE.md alone "
      f"({fixed['CLAUDE.md']}): {sum(s < fixed['CLAUDE.md'] for s in states)}/{len(states)}")

print("\nINERT FRACTION AT THE LAST SESSION")
for path, hist in items.items():
    _, _, sect, blocks = hist[-2] if len(hist) > 1 else hist[0]
    live = (sect["preamble"] + sect.get("Spec", 0) + sect.get("Tasks", 0)
            + sect.get("Decisions", 0) + (blocks[-1][1] if blocks else 0))
    inert = sect["total"] - live
    final = hist[-1][2]
    print(f"  {short(path):<28} file={sect['total']:>6} live={live:>6} inert={inert:>6} "
          f"({100 * inert / sect['total']:>3.0f}%)   Progress={100 * final.get('Progress', 0) / final['total']:>3.0f}% of closed file")

print("\nDURABLE OUTPUT PER COMMIT  (lines added inside vs outside Work/)")
for path, hist in items.items():
    for sha, subject, _, _ in hist:
        inside = outside = 0
        for line in git("show", "--numstat", "--format=", "-M", sha).splitlines():
            cols = line.split("\t")
            if len(cols) == 3 and cols[0].isdigit():
                if cols[2].startswith("Work/"):
                    inside += int(cols[0])
                else:
                    outside += int(cols[0])
        print(f"  {short(path):<28} {sha}  Work+={inside:>5}  other+={outside:>5}")
