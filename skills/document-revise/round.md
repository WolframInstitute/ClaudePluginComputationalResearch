# The revision round

One round turns a document the user has read and annotated into its next version.
The user reviews where they read — in the notebook, the paper, the Markdown file — not in the chat.
This file is the procedure; [SKILL.md](SKILL.md) § *Revision round* is the summary.
What the document remembers between rounds — its notes, hand edits, requests and rules — is kept in its provenance file, whose format is [provenance § *Document provenance*](../project-provenance/SKILL.md#document-provenance).

This procedure applies to an explicitly requested versioned revision round.
For a human manuscript or paclet design, the [paper](../paper-create/workflow.md) and [paclet design](../project-create/paclet-design.md) ownership policies take precedence: the human selects the current source, integration and any next numbered iteration.
Ordinary scoped edits and `_notes` updates are made in place; they do not automatically create another human iteration.
Use the author-selected starting text and name when a next human iteration is requested, rather than promoting a companion or choosing a file by recency.

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
Determine the revision unit from the established build and the user's request; ask only when that unit is genuinely ambiguous.

## Steps

1. **Find the document.**
   `/document-revise <file>` names it.
   With no argument, take the files changed since the last commit (`git status`) that hold a note; if exactly one does, use it, otherwise ask.
2. **Select the requested baseline.**
   Use the recorded or explicitly selected human source for human manuscripts and designs.
   For other explicitly versioned documents, list the stem's versions and use the latest unless the user selected a different starting version.
   If that choice is unresolved, explain which later changes would be omitted before proceeding with dependent edits.
3. **Read the provenance file.**
   Read `## Rules` and the last two entries under `## Rounds` of `Name.provenance.md`.
   A rule that differs from the file's last commit was written or edited by the user, and is protected.
   If there is none — a document from before this convention — create it with an empty `## Rules`, and record that it starts at this round.
4. **Collect.**
   List every note with its line range, the passage it refers to, and its text.
   Find the hand edits ([§ *Hand edits*](../project-provenance/SKILL.md#hand-edits)), and take any request the user made about this document in the chat since the last round.
   Draw the rules these give ([provenance § *Rules*](../project-provenance/SKILL.md#rules)) now, not at step 9: a rule drawn from this round's edits already binds this round's rewrites.
   With no notes, say so and write no `k+1`; record the hand edits as in steps 5 and 9, commit, and stop.
5. **Record version `k` as the user left it.**
   Commit it — notes and hand edits — with the provenance file as the user left it, before anything is written: `docs(revise): <stem> v<k> notes`.
   The user asked for the round, so this commit is part of it.
   After this, version `k` is never edited again.
   Follow the established tracking policy for notebooks.
   A reproducible generated `.nb` may be excluded, but direct notebook edits that source/provenance cannot faithfully represent must remain recoverable as the actual notebook through the project's history or archive mechanism.
   Do not substitute a one-line summary for the only saved copy of human notebook work.
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
9. **Record the round** in the provenance file: a `### r<k+1>` entry under `## Rounds` with each note, hand edit and request, and the rules drawn in step 4 or rewritten in step 7 under `## Rules` — format in [provenance § *Document provenance*](../project-provenance/SKILL.md#document-provenance).
10. **Commit version `k+1`** and the provenance file: `docs(revise): <stem> v<k+1>`.
    Stage files by name under the established tracking policy: text/source files, provenance, and any human notebook snapshots required to preserve notebook-only work.
    Exclude only reproducible generated outputs, and respect an explicit no-commit instruction.
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

This matters most for a document in progress in the folder itself, which is the user's ([artifacts.md](../notebook-create/artifacts.md)): a round may write `k+1` there, because the user asked and nothing is overwritten, but it writes only what the notes ask.
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

The saved `.nb` the human edited is the base of the revision.
Carry every unrequested cell, group wrapper, option, tag and metadata value over intact; do not regenerate the document through Markdown.
Follow [notebook-create: native editing](../notebook-create/editing.md) for ordinary in-place edits and faithful source write-back.
Only a requested versioned round writes `Name_k+1.nb`; human-numbered documents keep their author-selected names.

A supporting `Name_k.md` may exist, with `"SourceLines" -> {first, last}` in cell `TaggingRules` ([provenance: Anchors](../project-provenance/SKILL.md#anchors)).
Those anchors locate source passages; they do not prove that the source represents later notebook edits faithfully.
Do not create a source layer merely because an existing notebook has none.

A revision round does not evaluate existing Input cells.
Use available native notebook tools or the evaluator to inspect and patch held Notebook expressions without executing cell contents; confirm that writes reach the user's saved path.

1. **Locate notes and direct edits.** Read the actual saved notebook, including cells inside groups and any cell without a `CellID`.
   A textual search can locate candidate `<< … >>` markers; inspect each candidate in its cell context so `Get`/`Put` code is not mistaken for a note.
   Never join box strings to reconstruct Wolfram source or mathematical text.
   Use source anchors where valid, otherwise quote the passage and record its notebook position/tag with `L?` rather than guessing source lines.
2. **Compare against the available baseline.** Use the [complete fingerprint contract](../paper-create-notebook/fingerprint.md) when present; include semantic options, notebook metadata, order and group structure.
   Missing or legacy hashes leave preservation unverified, not clean.
   Preserve the actual saved notebook and reconcile from it; safe targeted edits do not depend on permission to rebuild the whole file.
3. **Reconcile supporting source only where faithful.** Copy an existing source to the requested new-version name, then update verified source passages from the bottom upward.
   For Input cells, use supported source/InputForm export or held box interpretation and verify the proposed source against the held original as described in [per-cell write-back](../notebook-create/editing.md#per-cell-source-write-back).
   `SuperscriptBox["x", "2"]` must not become `x2`; comments, custom boxes and statement boundaries also need care.
   For rich Text cells, retain formulas, citations and tags rather than writing an `InputForm` dump as if it were Markdown.
   When faithful write-back is unavailable, leave that source block unchanged, preserve the actual cell, and record the unsupported cell or setting in the existing provenance file.
   Set source synchronization to incomplete; do not describe the resulting `.md` as a complete regeneration source.
4. **Patch the requested passages in the notebook copy.** Replace only authorized content/options, preserving the cell's unrelated options and `CellID`.
   Generate a new cell or a faithfully represented replacement fragment with the original engine only when appropriate.
   Apply required environment/citation passes to new content alone; do not replace the head, stylesheet or grouping of unrelated existing cells.
   Keep the user's hand-edited cells as they stand, including any that cannot be represented in Markdown.
   Change or stamp `SourceLines` only for source blocks actually synchronized; shift unaffected ranges only when the verified source edit requires it.
5. **Handle existing outputs explicitly.** An Output under a changed Input is stale until rechecked.
   Preserve outputs outside the requested scope; report affected stale outputs and whether evaluation was requested and performed.
   Do not present an unchanged output as verification of the revised code.
6. **Save and compare.** Re-read the baseline immediately before writing and reconcile concurrent edits.
   Save to the requested new version or authorized in-place path, then re-import and compare cells, nested grouping/order and semantic options/metadata against the baseline.
   Only the requested changes and necessary verified source-anchor shifts may differ; investigate serialization changes instead of ignoring notebook options wholesale.
   Check existing source ranges against the source blocks they actually describe, but do not mistake valid line ranges for a semantic conversion check.
7. **Record the result.** Report each note and any conversion limitation, notebook-only change or stale output.
   If maintaining a fingerprint, stamp the re-imported notebook using the current schema and keep `"SourceSync" -> "Incomplete"` while any source mismatch remains.
   A fresh stamp cannot authorize regeneration from an incomplete source.

For a notebook without source or anchors, make the requested changes directly in its notebook expression, preserving everything else.
Use notebook locations and quoted passages in provenance; do not fabricate Markdown or promise automatic reconstruction.
