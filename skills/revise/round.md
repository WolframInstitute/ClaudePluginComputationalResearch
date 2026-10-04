# The revision round

One round turns a document the user has read and annotated into its next version.
The user reviews where they read — in the notebook, the paper, the Markdown file — not in the chat.
This file is the procedure; [SKILL.md](SKILL.md) § *Revision round* is the summary.
What the document remembers between rounds — its notes, hand edits, requests and rules — is kept in its provenance file, whose format is [provenance § *Document provenance*](../provenance/SKILL.md#document-provenance).

## The note grammar

A **note** is the text between `<<` and `>>`.
It may sit inside a line or run over several lines; in a notebook it stays within one cell.

| Where | Written as |
|---|---|
| prose, Markdown, a notebook Text cell | `<< make this example smaller >>`, anywhere in a sentence |
| LaTeX | `% << cite the source here >>`, so it stays out of the PDF; a note over several lines starts each line with `%` |
| Typst, C-like code | `// << shorter >>` |
| Wolfram code, a notebook Input cell | `(* << use a smaller graph >> *)`, or a bare `<< use a smaller graph >>` |
| shell, Python | `# << quote the path >>` |

In prose a note goes anywhere.
In code it goes inside a comment.
A bare `<< … >>` in Wolfram code is a syntax error (`SyntaxQ[ "<< shorter >>" ]` is `False`), so a cell with a note cannot be run by mistake.
Code also uses `<<` and `>>` for itself — `<< Package``, `x >> file`, `cout << x`, a shell heredoc — and `<< Package`` has no closing `>>`.
A match outside a comment in code is read before it is taken: it is a note only when it is words addressed to the reader, not code.

**What a note refers to.**
A note that shares a line or a cell with other text refers to that passage.
A note alone on its lines, or alone in its cell, refers to the passage just above it — a reader writes the note after reading the passage.
When its words say otherwise — "the example above", "the whole section" — the words win.

## Names

The versions of one document share a **stem** and differ by a round number:

```
Note_260927.tex        version 1
Note_260927_2.tex      version 2
Note_260927_3.tex      version 3
```

A file `Name_<k>.<ext>` is round `k` of `Name` only when `Name.<ext>` exists beside it.
Otherwise the trailing number is part of the name: a lone `Chapter_3.tex` is version 1 of stem `Chapter_3`, and its next version is `Chapter_3_2.tex`.
The date in a stem is the date the work was settled; the number counts rounds within it.
The provenance file `Name.provenance.md` belongs to the stem, not to a version: it is not numbered, and no round copies it.

**A version number names the whole set.**
Version `k+1` holds every file of the stem that version `k` holds:

- an annotated document is revised;
- a `.pdf` is rebuilt from the new `.tex` (then `latexmk -c`);
- every other file — a `.wl`, a companion document with no notes — is copied verbatim, and changed only where a note in it asks;
- the `.md` source of a notebook is carried as `Name_k+1.md` beside `Name_k+1.nb`, and kept in step with it (§ *Notebooks*).

A **folder-shaped artifact** (`Name_YYMMDD/` holding `Notebook/`, `Code/`, …) is revised as a copy of the whole folder, `Name_YYMMDD_2/`, so the bare inner names keep resolving.
An annotated file that is part of any other multi-file build — an `\input`, an `#include`, a `Get` from a sibling file — is **not** renamed on its own, since that breaks the build.
Ask the user which folder is the unit before writing anything.

## Steps

1. **Find the document.**
   `/revise <file>` names it.
   With no argument, take the files changed since the last commit (`git status`) that hold a note; if exactly one does, use it, otherwise ask.
2. **Take the latest version.**
   List the stem's versions and work on the highest number.
   If the user named an older version and it holds notes, stop and ask: a round from an old version would drop the later rounds.
3. **Read the provenance file.**
   Read `## Rules` and the last two entries under `## Rounds` of `Name.provenance.md`.
   A rule that differs from the file's last commit was written or edited by the user, and is protected.
   If there is none — a document from before this convention — create it with an empty `## Rules`, and record that it starts at this round.
4. **Collect.**
   List every note with its line range, the passage it refers to, and its text.
   Find the hand edits ([§ *Hand edits*](../provenance/SKILL.md#hand-edits)), and take any request the user made about this document in the chat since the last round.
   Draw the rules these give ([provenance § *Rules*](../provenance/SKILL.md#rules)) now, not at step 9: a rule drawn from this round's edits already binds this round's rewrites.
   With no notes, say so and write no `k+1`; record the hand edits as in steps 5 and 9, commit, and stop.
5. **Record version `k` as the user left it.**
   Commit it — notes and hand edits — with the provenance file as the user left it, before anything is written: `docs(revise): <stem> v<k> notes`.
   The user asked for the round, so this commit is part of it.
   After this, version `k` is never edited again.
   A notebook has nothing to commit here, since a `.nb` is never committed; its notes and hand edits reach git through the provenance file in step 9.
6. **Write version `k+1`** by the path for the file type below.
   Change only the passages the notes name, and obey every rule while doing it.
   Everything else is carried over verbatim, including every hand edit.
   Delete each note that was acted on.
7. **Check against the rules.**
   Read each rewritten passage against every rule in `## Rules` and every rule drawn in step 4, and check that no hand edit recorded in an earlier round is undone.
   A passage that breaks one is fixed in `k+1`.
   A new note that contradicts a rule wins; the rule is rewritten in step 9.
8. **Rebuild and check.**
   Rebuild the `.pdf` if there is one.
   Search `k+1` for notes: only the ones not acted on may remain, each followed by its `not done` note.
9. **Record the round** in the provenance file: a `### r<k+1>` entry under `## Rounds` with each note, hand edit and request, and the rules drawn in step 4 or rewritten in step 7 under `## Rules` — format in [provenance § *Document provenance*](../provenance/SKILL.md#document-provenance).
10. **Commit version `k+1`** and the provenance file: `docs(revise): <stem> v<k+1>`.
    Stage files by name: the text files of the stem and its provenance file, never a `.nb` — a generated notebook is not committed, only its `.md` is.
    The commit hook caps the subject at 72 characters, so keep it this short even for a long stem.
11. **Present and wait.**
    Reply with one line per note — the note, and what was done or why not:

    | Note | Done |
    |---|---|
    | `<< make this example smaller >>` | example 2 now uses a 6-vertex cycle |
    | `<< cite the source >>` | not done — no source named, and none found in `Resources/` |

    Then list each rule added or rewritten this round, saying that the user overrules one by editing or deleting it in the provenance file.
    Then wait (the loop in [SKILL.md](SKILL.md)).
    The user's next review is another round on `k+1`.

## No invention

A round changes only the passages its notes name.
It adds no sentence, result, claim, example or reference that no note asked for, and it does not tidy, reword or reformat the rest.
A note that asks for new material gets exactly that material, where the note sits.

This matters most in `Output/`, which is the user's: a round may write `k+1` there, because the user asked and nothing is overwritten, but it writes only what the notes ask.
When acting on a note would take a claim nobody has checked — a number, a citation, a proof step — do not supply one.
Leave the note and say why.

## A note not acted on

A note the round cannot or should not act on stays in `k+1`, followed by a second note giving the reason, in the same form:

```
% << cite the source here >>
% << not done: no source named, and none found in Resources/ >>
```

In a notebook the reason is a new last line of the same cell.
The user answers by editing the note or deleting both in `k+1`.

## Text files

`.tex`, `.typ`, `.md`, `.wl`, `.py` — any file that is plain text.

1. Find the notes, with the lines each one spans:

   ```bash
   perl -0777 -ne 'while (/<<(.*?)>>/sg) { $s = 1 + (substr($_, 0, $-[0]) =~ tr/\n//); $e = $s + ($& =~ tr/\n//); print "L$s-L$e: $&\n" }' Name_k.ext
   ```

   In code, read each match: one outside a comment is usually code (§ *The note grammar*).
2. Copy the file: `cp Name_k.ext Name_k+1.ext`.
3. Make each change with the Edit tool on the copy, one note at a time: the passage it names and the note itself.
   Never rewrite the file whole — copy-then-edit is what keeps everything without a note byte-identical.
4. `git diff --no-index Name_k.ext Name_k+1.ext` must show only the annotated passages.

## Notebooks

A notebook is a pair: `Name_k.nb`, which the user reads, annotates and edits, and `Name_k.md`, its Markdown source.
Each generated cell carries the lines of the `.md` it came from, as `"SourceLines" -> { first, last }` in its own `TaggingRules` ([provenance § *Anchors*](../provenance/SKILL.md#anchors)), so a note in a cell is anchored to lines of the `.md`.
The round carries both halves:

- **The `.nb` the user edited is the base of `Name_k+1.nb`.** Every cell without a note is carried over as it is, hand edits included; nothing is regenerated from Markdown.
- **`Name_k+1.md` is kept in step with it.** A change is written into the `.md` first and only that passage is converted; a cell the user edited is written back into the `.md` by reading that one cell.

The reverse converter (`NotebookToMarkdown`) is never used, since it silently loses content (`Wiki/Resources/MarkdownToNotebook.md`).
Everything runs on the AgentTools MCP kernel (`mcp__Wolfram__WolframLanguageEvaluator`), after `Get[ "${CLAUDE_PLUGIN_ROOT}/scripts/source_lines.wl" ]`.
The `.nb` is never committed; the `.md` is.
**A round never evaluates cells.**

1. **Find the annotated cells, and their lines.**

   ```wolfram
   With[ { nb = Import[ "Name_k.nb", "NB" ] },
     With[ { pos = Position[ nb,
           Cell[ content : Except[ _CellGroupData ], ___ ] /;
             StringContainsQ[ StringJoin @ Cases[ content, _String, { 0, Infinity } ], "<<" ~~ Shortest[ ___ ] ~~ ">>" ] ] },
       { pos, CellSourceLines /@ Extract[ nb, pos ], Extract[ nb, pos ] } ] ]
   ```

   The joined strings of a cell are its text: a typed `<<` in an Input cell is a `"<<"` token in its `BoxData`, inside a comment too, and a Text cell's lines are separated by `"\n"`.
   `Except[ _CellGroupData ]` is load-bearing — a group cell contains the strings of every cell under it, so without it each section containing a note matches as well.
   An Input cell holding both a `Get` and a `Put` matches too; read it before taking it as a note.
   Positions, not `CellID`s: a cell the user added may carry none.
   A cell with no lines was added by the user; its note is anchored `after L<n>`, the last line of the nearest cell above that has lines.
2. **Find the hand-edited cells** by the fingerprint ([provenance § *Hand edits*](../provenance/SKILL.md#hand-edits)): edited, added and deleted cells, each with its lines.
   A deleted cell's lines are the block of `Name_k.md` between its neighbours' ranges that no remaining cell carries.
3. **Write `Name_k+1.md`.**
   `cp Name_k.md Name_k+1.md`, then make each change with the Edit tool, **from the bottom of the file up**, so the line numbers above an edit stay valid:
   - **A hand-edited cell** is written back: read the cell in the kernel — an Input cell's joined strings are its code verbatim, a text cell's content in `InputForm` shows its formulas — and change its lines to say what the cell now says.
     Change only what the user changed; the rest of the passage keeps its Markdown as written, `$…$` and `{#Tag}` included.
     A cell the user added goes in after the lines of the cell above it; a deleted cell's lines are taken out.
   - **An annotated passage** is rewritten as the note asks, and the note removed.
     A note asking for a new cell becomes a new passage after the lines it refers to.

   Keep a list of the passages, each with its range `{ first, last }` in `Name_k.md`, its new length in lines, and its new text.
   Keep the text itself: in `Name_k+1.md` a passage sits below its old `first` by every change of length above it, so reading it back at `first` takes the wrong lines.
   `git diff --no-index Name_k.md Name_k+1.md` must show only these passages.
4. **Write `Name_k+1.nb`** from `Name_k.nb`, one passage at a time, bottom up again.
   For a rewritten passage, convert its new text from the step 3 list alone with the engine that built the notebook, stamped, its lines moved to where the passage starts:

   ```wolfram
   With[ { new = First @ SourceLineNotebook[ MarkdownToNotebook[ #, "Evaluate" -> False ] &, passage ] /.
         ( "SourceLines" -> range_ ) :> "SourceLines" -> range + first - 1,
       pos = Position[ nb, c : Cell[ _, _String, ___ ] /; MatchQ[ CellSourceLines[ c ], { a_, b_ } /; first <= a && b <= last ] ] },
     ReplacePart[ Delete[ ShiftSourceLines[ nb, { first, last }, length ], Rest[ pos ] ], First[ pos ] -> Sequence @@ new ] ]
   ```

   - Run the generating skill's per-cell passes on `new` before inserting it: the `CellLabel` and `CellID` strip, and for a research notebook `ReadCellTags` and the passes of `MathNotebookDocument` (`First @ MathNotebookDocument[ cells, tags ]`, with `tags` every `CellTags` value in the notebook plus the bib keys, so citations resolve), and `FoldExampleGroups` if the passage holds an Example.
     Give the new cells `CellID`s above the largest in the notebook.
   - A hand-edited passage keeps its cells as the user left them: only `ShiftSourceLines` runs, and each cell the write-back moved or added gets its new lines with `StampSourceLines[ cell, { first, last } ]`.
   - A cell that was only a note is deleted once acted on.
5. **Leave outputs alone.**
   An Output below a rewritten Input is now stale; it stays, since removing it is not what the note asked, and the reply says which ones to re-evaluate.
6. **Export and check.**
   `Export[ "Name_k+1.nb", new, "NB" ]`, then re-import and compare cell by cell with `Name_k.nb`: only the cells of the passages may differ, apart from their `"SourceLines"`.
   `Export` adds `FrontEndVersion`, `StyleDefinitions` and an `ExpressionUUID` to a notebook that lacks them, so compare cells, not the whole expression; from then on the round trip is a fixed point.
   Then check the pair: every range in `Name_k+1.nb` is a block of `Name_k+1.md`, in order.

   ```wolfram
   With[ { ranges = DeleteCases[ Cases[ Import[ "Name_k+1.nb", "NB" ], c : Cell[ _, _String, ___ ] :> CellSourceLines[ c ], Infinity ], None ] },
     { Complement[ ranges, SourceBlocks @ Import[ "Name_k+1.md", "Text" ] ] === { }, OrderedQ[ ranges ] } ]
   ```

7. **Re-stamp the fingerprint** from the re-imported `Name_k+1.nb` ([fingerprint.md](../new-research-notebook/fingerprint.md)), so the next round measures hand edits against version `k+1` as written; the user's edits of this round are already in the provenance file and in `Name_k+1.md`.

**A notebook without source lines** — generated before cells carried them — has no anchors and no `.md` to keep in step.
Its notes are anchored by quoted passage, `L?`; each annotated cell's content is rewritten in place with `ReplacePart[ nb, Append[ p, 1 ] -> newContent ]` (a string or `TextData` for a text cell, boxes from `FrontEnd`UndocumentedTestFEParserPacket[ code, False ]` for an Input cell), and no `Name_k+1.md` is written; the reply says so.
