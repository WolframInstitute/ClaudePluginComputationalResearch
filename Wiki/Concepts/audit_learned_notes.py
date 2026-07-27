#!/usr/bin/env python3
"""Regenerate every number in Wiki/Concepts/ProgressWikiSplit.md.

Audits where the knowledge in `Work/` item files actually belongs, for
EvaluateWorkItemsEfficiency T2. Extracts every claim-line of every
`- **Learned:**` note across all items, applies the hand classification in
CLASS below, and prices the misplacement against the read model of
next-session step 2.

Claim-lines, not notes, are the unit: the sources use `Semantic line breaks: on`,
so one source line is one sentence is (near enough) one claim, and every note
audited mixes classes internally.

Classes — assigned by DESTINATION, i.e. where the line would live if the split
were right:

  D  durable      a fact about an external tool, artifact, or this plugin that
                  outlives the item and is true regardless of which task ran.
                  Destination Wiki/.
  X  decision     a choice and its rationale, or a reconciliation with the Spec.
                  Destination `## Decisions` / `## Spec` — durable to the item,
                  not to the project.
  H  hand-off     a pointer aimed at one named next task ("T3 must ...").
                  Live for exactly one session; inert forever after.
  N  narration    headers, counts ("four things."), meta-commentary on the
                  Spec's framing, generalised process maxims, and the
                  scaffolding of a correction. Destination: nowhere.

Flags:
  c  the line exists because an EARLIER Progress block of the same item carried
     a wrong claim. Had that claim been in Wiki/ it would have been edited in
     place and this text would not exist.
  f  the line was later falsified by a subsequent block, and was read as true
     by at least one session in between.
  w  the line duplicates content that the same session also wrote to Wiki/.
"""

import os, re, subprocess

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
FIXED_OVERHEAD = 27671  # from measure_session_budget.py

# One entry per claim-line, in the order audit() yields them, grouped by
# Progress block.  "<class><flags>" — see the module docstring.
CLASS = """
AdoptMarkdownToNotebook
  S1  D H D Hf Hf D
  S2  N Nc Nc Dc Dc Hc N N D H D N D D
  S3  N N D D D N D D D H N D D N N D D
  S4  N N D D D N X D X X Nc N D N
  S5  N N D N N N N D X N D D D D D D D
DeclutterReadme
  S1  X X D
EvaluateMarkdownToNotebook
  S1  N D D H
  S2  D H D
  S3  D D D D
  S4  N D X
MarketplaceReadme
  S1  D D
MathNotebookIntegration
  S1  D H D
  S2  Nc D H D
  S3  N D D
  S4  D
  S5  N D D D
  S6  D D X
PacletDocumentation
  S1  N D H H
  S2  D H
  S3  N N H
  S4  X H
  S5  D D H
  S6  D D H
EvaluateWorkItemsEfficiency
  S1  N N Dw Hw Hw
  S2  N Xw N N H
"""
CLASS = [t for t in CLASS.split() if re.fullmatch(r"[DXHN][cfw]*", t)]

# `Did` is 69 % of Progress and the same classes apply to it, but 60 kB is more
# than one session can hand-classify honestly. Sample: the MEDIAN-sized `Did`
# block of each item with >= 4 sessions (reproducible, no cherry-picking).
# A bold `**lead sentence.**` on its own line is counted N even when it states
# the finding, so D is a LOWER bound in both tables.
DID_SAMPLE = """
AdoptMarkdownToNotebook S4     N N N D D N Nw Nw N N Nw Nw
EvaluateMarkdownToNotebook S2  N N D D D D D N N N D D D D D D D D D D D D D D N D D N D D D
MathNotebookIntegration S5     N N D D X N D D D D D N D N D D N
PacletDocumentation S6         N N D D Dw N Xw Dw Dw N D D N
"""
DID_SAMPLE = [t for t in DID_SAMPLE.split() if re.fullmatch(r"[DXHN][cfw]*", t)]

FIELDS = ("Prompt", "Did", "Learned", "Next")


def git(*args):
    return subprocess.run(["git", "-C", REPO, *args], capture_output=True, text=True).stdout


def items():
    paths = [p for p in git("ls-files", "Work").splitlines() if re.search(r"/(Done|Active)/", p)]
    return sorted(paths, key=lambda p: (not p.startswith("Work/Done"), p))


def blocks(path):
    """[(item, session, block_bytes, {field: bytes}, [claim_lines])] per Progress block."""
    text = open(os.path.join(REPO, path)).read()
    body = re.search(r"(?ms)^## Progress\b(.*?)(?=^## |\Z)", text)
    if not body:
        return []
    body = body.group(1)
    heads = [(m.start(), m.group(0).strip()) for m in re.finditer(r"(?m)^### .+$", body)]
    item = re.sub(r"^\d{4}-\d\d-\d\d-", "", os.path.basename(path))[:-3]
    out = []
    for i, (pos, head) in enumerate(heads):
        block = body[pos : (heads[i + 1][0] if i + 1 < len(heads) else len(body))]
        fields = {}
        for f in FIELDS:
            m = re.search(r"(?ms)^- \*\*%s:\*\*(.*?)(?=^- \*\*|\Z)" % f, block)
            fields[f] = len(m.group(1).strip().encode()) if m else 0
        learned = re.search(r"(?ms)^- \*\*Learned:\*\*(.*?)(?=^- \*\*|\Z)", block)
        lines = [l.strip() for l in learned.group(1).split("\n") if l.strip()] if learned else []
        session = int(re.search(r"Session (\d+)", head).group(1))
        out.append((item, session, len(block.encode()), fields, lines))
    return out


def audit():
    """[(item, session, class, flags, bytes, text)] over every claim-line."""
    rows, k = [], 0
    for path in items():
        for item, session, _, _, lines in blocks(path):
            for line in lines:
                tag = CLASS[k]
                k += 1
                rows.append((item, session, tag[0], tag[1:], len(line.encode()), line))
    assert k == len(CLASS), f"CLASS has {len(CLASS)} entries, corpus has {k} claim-lines"
    return rows


rows = audit()
allblocks = [b for p in items() for b in blocks(p)]
total = sum(r[4] for r in rows)


def share(pred, of=None):
    n = sum(r[4] for r in rows if pred(r))
    return n, 100 * n / (of or total)


print("CORPUS")
print(f"  items {len({r[0] for r in rows})}  Progress blocks {len(allblocks)}  "
      f"claim-lines {len(rows)}  Learned bytes {total}")
prog = sum(b[2] for b in allblocks)
fieldsum = {f: sum(b[3][f] for b in allblocks) for f in FIELDS}
print(f"  Progress blocks total {prog} B; of which "
      + ", ".join(f"{f} {v} ({100*v/prog:.0f}%)" for f, v in fieldsum.items()))

print("\nCLASS SPLIT OF THE LEARNED CORPUS")
for cls, name in [("D", "durable -> Wiki/"), ("X", "decision -> Decisions/Spec"),
                  ("H", "hand-off -> next session only"), ("N", "narration -> nowhere")]:
    n, pct = share(lambda r, c=cls: r[2] == c)
    lines = sum(1 for r in rows if r[2] == cls)
    print(f"  {cls} {name:<30} {n:>6} B ({pct:>4.1f}%)  {lines:>3} lines")
n, pct = share(lambda r: r[2] in "HN")
print(f"  {'':2} {'H+N = inert after one session':<30} {n:>6} B ({pct:>4.1f}%)")

print("\nFLAGGED")
for flag, name in [("c", "correction scaffolding"), ("f", "later falsified"),
                   ("w", "duplicated into Wiki/ the same session")]:
    n, pct = share(lambda r, f=flag: f in r[3])
    print(f"  {flag} {name:<40} {n:>6} B ({pct:>4.1f}%)  "
          f"{sum(1 for r in rows if flag in r[3])} lines")

print("\nPER ITEM  (Learned bytes by class)")
print(f"  {'item':<28} {'D':>6} {'X':>6} {'H':>6} {'N':>6} {'total':>6}  D%")
for item in dict.fromkeys(r[0] for r in rows):
    sub = [r for r in rows if r[0] == item]
    by = {c: sum(r[4] for r in sub if r[2] == c) for c in "DXHN"}
    t = sum(by.values())
    print(f"  {item:<28} " + " ".join(f"{by[c]:>6}" for c in "DXHN")
          + f" {t:>6}  {100*by['D']/t:>3.0f}%")

print("\nWHAT A SESSION PAYS FOR THE LEARNED NOTES IT READS")
print("  next-session step 2: tail of 2 Progress blocks. Everything older is")
print("  read-as-skim or skipped, so its durable content is paid for and hidden.")
for path in items():
    bs = blocks(path)
    if len(bs) < 2:
        continue
    item = bs[0][0]
    seen = 0
    for i in range(1, len(bs)):  # state entering session i+1
        tail = {b[1] for b in bs[:i][-2:]}
        sub = [r for r in rows if r[0] == item and r[1] <= bs[i - 1][1]]
        hidden = sum(r[4] for r in sub if r[1] not in tail and r[2] == "D")
        intail = sum(r[4] for r in sub if r[1] in tail)
        inert = sum(r[4] for r in sub if r[1] in tail and r[2] in "HN")
        seen = max(seen, hidden)
        print(f"  {item[:24]:<24} entering S{bs[i][1]}: tail={intail:>5} B "
              f"(of which {inert:>4} B inert)   hidden durable={hidden:>5} B")

print("\nTHE MISPLACEMENT BILL")
d, _ = share(lambda r: r[2] == "D")
hn, _ = share(lambda r: r[2] in "HN")
print(f"  durable bytes written into Progress instead of Wiki/: {d} B")
print(f"  of those, in a block older than the tail at the item's last session:")
lasthidden = 0
for path in items():
    bs = blocks(path)
    if len(bs) < 3:
        continue
    item = bs[0][0]
    tail = {b[1] for b in bs[-2:]}
    h = sum(r[4] for r in rows if r[0] == item and r[1] not in tail and r[2] == "D")
    lasthidden += h
    print(f"    {item:<28} {h:>6} B")
print(f"    {'TOTAL':<28} {lasthidden:>6} B  "
      f"({100*lasthidden/d:.0f}% of all durable Learned bytes)")
print(f"  inert bytes re-read on every whole-file read: {hn} B "
      f"({100*hn/total:.0f}% of the Learned corpus)")
print(f"  fixed per-session overhead for comparison: {FIXED_OVERHEAD} B")
print(f"  whole Learned corpus as a fraction of that: {100*total/FIXED_OVERHEAD:.0f}%")

print("\nTHE `Did` SAMPLE  (median-sized Did block of each item with >= 4 sessions)")
sample, k = [], 0
for path in items():
    bs = blocks(path)
    if len(bs) < 4:
        continue
    text = open(os.path.join(REPO, path)).read()
    body = re.search(r"(?ms)^## Progress\b(.*?)(?=^## |\Z)", text).group(1)
    heads = [(m.start(), m.group(0)) for m in re.finditer(r"(?m)^### .+$", body)]
    dids = []
    for i, (pos, head) in enumerate(heads):
        blk = body[pos : (heads[i + 1][0] if i + 1 < len(heads) else len(body))]
        m = re.search(r"(?ms)^- \*\*Did:\*\*(.*?)(?=^- \*\*|\Z)", blk)
        dids.append((len(m.group(1).strip().encode()), bs[i][1], m.group(1).strip()))
    dids.sort()
    size, session, txt = dids[len(dids) // 2]
    lines = [l.strip() for l in txt.split("\n") if l.strip()]
    for line in lines:
        tag = DID_SAMPLE[k]
        k += 1
        sample.append((bs[0][0], session, tag[0], tag[1:], len(line.encode()), line))
    print(f"  {bs[0][0]:<28} S{session}  {size:>5} B  {len(lines):>2} lines")
assert k == len(DID_SAMPLE), f"DID_SAMPLE has {len(DID_SAMPLE)}, sample has {k} lines"

stot = sum(r[4] for r in sample)
print(f"  sample total {stot} B = {100*stot/fieldsum['Did']:.0f}% of all {fieldsum['Did']} B of Did")
for cls, name in [("D", "durable -> Wiki/"), ("X", "decision"), ("H", "hand-off"),
                  ("N", "narration / verification record")]:
    n = sum(r[4] for r in sample if r[2] == cls)
    print(f"  {cls} {name:<34} {n:>6} B ({100*n/stot:>4.1f}%)  "
          f"{sum(1 for r in sample if r[2] == cls):>2} lines")
dup = sum(r[4] for r in sample if "w" in r[3])
print(f"  w duplicated into a durable artifact the same session: {dup} B "
      f"({100*dup/stot:.1f}%)")
sd = sum(r[4] for r in sample if r[2] == "D")
print(f"  extrapolated durable bytes across all {fieldsum['Did']} B of Did: "
      f"~{round(fieldsum['Did']*sd/stot/100)*100} B")
print(f"  vs durable bytes in the fully-classified Learned corpus: "
      f"{sum(r[4] for r in rows if r[2]=='D')} B")
rate = sd / stot
dupe_rate = dup / stot

print("\nTOTAL DURABLE CONTENT SITTING IN Work/  vs  Wiki/")
did_d = fieldsum["Did"] * rate
learn_d = sum(r[4] for r in rows if r[2] == "D")
print(f"  Did (extrapolated at {100*rate:.0f}%)   ~{did_d/1000:>5.1f} kB")
print(f"  Learned (classified)          {learn_d/1000:>6.1f} kB")
print(f"  total durable in Progress    ~{(did_d+learn_d)/1000:>6.1f} kB")
wiki = {os.path.relpath(os.path.join(dp, f), REPO): os.path.getsize(os.path.join(dp, f))
        for dp, _, fs in os.walk(os.path.join(REPO, "Wiki")) for f in fs if f.endswith(".md")}
for f, s in sorted(wiki.items()):
    print(f"    {f:<44} {s:>6} B")
harvested = sum(s for f, s in wiki.items() if not f.endswith(("Index.md", "Status.md")))
print(f"  Wiki/ total                   {sum(wiki.values())/1000:>6.1f} kB "
      f"(articles only, no Index/Status: {harvested/1000:.1f} kB)")
print(f"  ratio durable-in-Work : Wiki-articles = "
      f"{(did_d+learn_d)/harvested:.1f} : 1")

print("\nDURABLE BYTES HIDDEN BELOW THE TAIL AT AN ITEM'S LAST SESSION")
hid_total = 0
for path in items():
    bs = blocks(path)
    if len(bs) < 3:
        continue
    tail = {b[1] for b in bs[-2:]}
    old_did = sum(b[3]["Did"] for b in bs if b[1] not in tail)
    old_learn = sum(r[4] for r in rows if r[0] == bs[0][0] and r[1] not in tail and r[2] == "D")
    h = old_did * rate + old_learn
    hid_total += h
    print(f"  {bs[0][0]:<28} Did {old_did:>6} B x {100*rate:.0f}% + Learned {old_learn:>5} B "
          f"= ~{h/1000:.1f} kB hidden")
print(f"  {'TOTAL':<28} ~{hid_total/1000:.1f} kB of durable knowledge below the tail")
print(f"  restated-elsewhere waste, extrapolated over all Did: "
      f"~{fieldsum['Did']*dupe_rate/1000:.1f} kB")

print("\nDID Wiki/ EVEN EXIST?  (fairness check on the 'unharvested' verdict)")
wikiborn = git("log", "--diff-filter=A", "--format=%H %at", "--", "Wiki/").splitlines()[-1]
wikisha, wikitime = wikiborn.split()[0][:7], int(wikiborn.split()[1])
print(f"  Wiki/ first committed in {wikisha}")
before = after = 0
for path in items():
    for item, session, _, _, _ in blocks(path):
        # commit that first introduced this `### Session N` heading
        hist = git("log", "--follow", "--format=%H %at", "--", path).splitlines()
        born = None
        for line in hist:  # newest first; keep walking back while the heading is present
            sha, at = line.split()
            for cand in [f"Work/Done/{os.path.basename(path)}",
                         f"Work/Active/{re.sub(r'^[0-9-]{11}', '', os.path.basename(path))}",
                         f"Work/Backlog/{re.sub(r'^[0-9-]{11}', '', os.path.basename(path))}"]:
                text = git("show", f"{sha}:{cand}")
                if text:
                    if re.search(r"(?m)^### Session %d\b" % session, text):
                        born = (sha[:7], int(at))
                    break
        if born:
            tag = "after " if born[1] >= wikitime else "BEFORE"
            if born[1] >= wikitime:
                after += 1
            else:
                before += 1
            print(f"  {item[:26]:<26} S{session}  {born[0]}  {tag} Wiki/ existed")
print(f"  {before} of {before+after} Progress blocks were written before Wiki/ existed")

print("\nPROJECTION: Progress with the durable content moved to Wiki/")
keep_learn = sum(r[4] for r in rows if r[2] in "HNX") / sum(r[4] for r in rows)
keep_did = sum(r[4] for r in sample if r[2] in "HNX") / stot
print(f"  keep-fraction: Learned {100*keep_learn:.0f}%, Did {100*keep_did:.0f}%")
print(f"  {'item':<28} {'blocks':>6} {'Progress':>9} {'projected':>9}")
for path in items():
    bs = blocks(path)
    p = sum(b[2] for b in bs)
    proj = (sum(b[3]["Did"] for b in bs) * keep_did
            + sum(b[3]["Learned"] for b in bs) * keep_learn
            + sum(b[3]["Prompt"] + b[3]["Next"] for b in bs)
            + sum(b[2] - sum(b[3].values()) for b in bs))  # headings + list markers
    print(f"  {bs[0][0]:<28} {len(bs):>6} {p:>8} B {proj:>8.0f} B  "
          f"({100*proj/p:.0f}%, {p/len(bs):.0f} -> {proj/len(bs):.0f} B per session)")
print(f"  {'ALL':<28} {len(allblocks):>6} {prog:>8} B "
      f"{prog*0 + sum(fieldsum[f] for f in ('Prompt','Next')) + fieldsum['Did']*keep_did + fieldsum['Learned']*keep_learn + (prog - sum(fieldsum.values())):>8.0f} B")

print("\nCLAIM-LINE DETAIL")
for i, (item, session, cls, flags, b, text) in enumerate(rows, 1):
    print(f"  {i:>3} {cls}{flags:<2} {item[:20]:<20} S{session} {b:>4}  {text[:96]}")
