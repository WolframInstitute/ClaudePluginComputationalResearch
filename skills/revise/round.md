# The revision round

One round turns a document the user has read and commented into its next version.
The user reviews where they read — in the notebook, the paper, the Markdown file — not in the chat.
This file is the procedure; [SKILL.md](SKILL.md) § *Revision round* is the summary.

## The comment grammar

A **comment** is a line whose text starts with `>>`.
In code it may follow the language's comment sign:

| Where | Written as |
|---|---|
| prose, Markdown, a notebook Text cell | `>> make this example smaller` |
| LaTeX | `% >> cite the source here` |
| Typst, C-like code | `// >> shorter` |
| HTML, Markdown source | `<!-- >> drop this table -->` |
| Wolfram code, a notebook Input cell | `(* >> use a smaller graph *)` or a bare `>> use a smaller graph` |
| shell, Python | `# >> quote the path` |

A comment runs to the end of its line; in a notebook, to the end of its cell.
Consecutive comment lines are one comment.

A comment opened by a comment sign counts anywhere in a line, so `Graph[g] (* >> smaller *)` is a comment on that line.
A bare `>>` counts only at the start of a line: `a >> file` in the middle of Wolfram code is `Put`, not a comment.
A bare `>>` at the start of an Input cell is a syntax error, so a commented cell cannot be run by mistake.

**What a comment refers to.**
A comment that shares a line or a cell with other text refers to that passage.
A comment alone on its lines, or alone in its cell, refers to the passage just above it — a reader writes the note after reading the passage.
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

**A version number names the whole set.**
Version `k+1` holds every file of the stem that version `k` holds:

- a commented document is revised;
- a `.pdf` is rebuilt from the new `.tex` (then `latexmk -c`);
- every other file — a `.wl`, an uncommented companion document — is copied verbatim, and changed only where a comment in it asks;
- the `.md` source of a notebook is not carried: it stays version 1's source, because from round 2 the `.nb` is the source.

A **folder-shaped artifact** (`Name_YYMMDD/` holding `Notebook/`, `Code/`, …) is revised as a copy of the whole folder, `Name_YYMMDD_2/`, so the bare inner names keep resolving.
A commented file that is part of any other multi-file build — an `\input`, an `#include`, a `Get` from a sibling file — is **not** renamed on its own, since that breaks the build.
Ask the user which folder is the unit before writing anything.

## Steps

1. **Find the document.**
   `/revise <file>` names it.
   With no argument, take the files changed since the last commit (`git status`) that hold a comment; if exactly one does, use it, otherwise ask.
2. **Take the latest version.**
   List the stem's versions and work on the highest number.
   If the user named an older version and it holds comments, stop and ask: a round from an old version would drop the later rounds.
3. **Collect.**
   List every comment with the passage it refers to.
   With no comments, say so and write no `k+1`; if the file differs from its last commit, those are hand edits — commit them as in step 4, and stop.
4. **Record the commented version.**
   Commit version `k` exactly as the user left it — comments and hand edits — before anything is written:
   `docs(revise): <stem> v<k> comments`.
   The user asked for the round, so this commit is part of it.
   After this, version `k` is never edited again.
5. **Write version `k+1`** by the path for the file type below.
   Change only the passages the comments name.
   Everything else is carried over verbatim, including every hand edit.
   Delete each comment that was acted on.
6. **Rebuild and check.**
   Rebuild the `.pdf` if there is one.
   Search `k+1` for comments: only the ones not acted on may remain, each followed by its `not done` line.
7. **Commit version `k+1`**: `docs(revise): <stem> v<k+1>`.
   The commit hook caps the subject at 72 characters, so keep it this short even for a long stem.
8. **Present and wait.**
   Reply with one line per comment — the comment, and what was done or why not:

   | Comment | Done |
   |---|---|
   | `>> make this example smaller` | example 2 now uses a 6-vertex cycle |
   | `>> cite the source` | not done — no source named, and none found in `Resources/` |

   Then wait (the loop in [SKILL.md](SKILL.md)).
   The user's next review is another round on `k+1`.

## No invention

A round changes only the passages its comments name.
It adds no sentence, result, claim, example or reference that no comment asked for, and it does not tidy, reword or reformat the rest.
A comment that asks for new material gets exactly that material, where the comment sits.

This matters most in `Output/`, which is the user's: a round may write `k+1` there, because the user asked and nothing is overwritten, but it writes only what the comments ask.
When acting on a comment would take a claim nobody has checked — a number, a citation, a proof step — do not supply one.
Leave the comment and say why.

## A comment not acted on

A comment the round cannot or should not act on stays in `k+1`, followed on the next line by the reason, in the same comment form:

```
% >> cite the source here
% >> not done: no source named, and none found in Resources/
```

In a notebook the reason is a new last line of the same cell.
The user answers by editing the comment or deleting both lines in `k+1`.

## Text files

`.tex`, `.typ`, `.md`, `.wl`, `.py` — any file that is plain text.

1. Find the comments:

   ```bash
   grep -nE '(^|%|//|<!--|#|\(\*)[[:space:]]*>>' Name_k.ext
   ```

   In Markdown a line starting `>>` could also be a nested block quote; generated Markdown never uses one, so it is a comment, unless it plainly reads as quoted text — then ask.
2. Copy the file: `cp Name_k.ext Name_k+1.ext`.
3. Make each change with the Edit tool on the copy, one comment at a time: the passage it names and the comment itself.
   Never rewrite the file whole — copy-then-edit is what keeps everything uncommented byte-identical.
4. `git diff --no-index Name_k.ext Name_k+1.ext` must show only the commented passages.

## Notebooks

The user edits the `.nb`, so from round 2 the `.nb` is the source.
The round imports `Name_k.nb`, rewrites only the commented cells, and exports `Name_k+1.nb`, all on the AgentTools MCP kernel (`mcp__Wolfram__WolframLanguageEvaluator`).
This is the one exception to `new-notebook`'s rule that a notebook is edited through a Markdown round trip: that round trip loses typeset content and environment styles, and would lose the user's edits with them.
The drift fingerprint does not apply, since nothing is regenerated from Markdown; its `TaggingRules` key is carried over as it is, like every other option.
**A round never evaluates cells.**

1. **Find the commented cells.**

   ```wolfram
   With[ { nb = Import[ "Name_k.nb", "NB" ],
       comment = ( StartOfLine ~~ WhitespaceCharacter ... ~~ ">>" ) | ( "(*" ~~ WhitespaceCharacter ... ~~ ">>" ) },
     With[ { pos = Position[ nb,
           Cell[ content : Except[ _CellGroupData ], ___ ] /;
             StringContainsQ[ StringJoin @ Cases[ content, _String, { 0, Infinity } ], comment ] ] },
       { pos, Extract[ nb, pos ] } ] ]
   ```

   The joined strings of a cell are its text: a typed `>>` in an Input cell is a `">>"` token in its `BoxData`, and a Text cell's lines are separated by `"\n"`.
   `Except[ _CellGroupData ]` is load-bearing — a group cell contains the strings of every cell under it, so without it each section containing a comment matches as well.
   Positions, not `CellID`s: a cell the user added may carry none.
2. **Rewrite each cell's content, and only its content.**
   Keep its style and every option: `ReplacePart[ nb, Append[ p, 1 ] -> newContent ]`.
   - Text-like cells take a string, or `TextData[ … ]` where the cell already had inline styling.
   - Input cells take boxes from the front end parser: `First @ UsingFrontEnd @ FrontEndExecute @ FrontEnd`UndocumentedTestFEParserPacket[ code, False ]`.
     Without a front end, the plain string `code` also works as content; the front end parses it when the notebook is opened.
   - A cell that was only a comment is deleted once acted on: `Delete[ nb, { p1, p2, … } ]`, after all replacements, since deleting shifts positions.
   - A comment asking for a new cell inserts one, in the style of its neighbours.
3. **Leave outputs alone.**
   An Output below a rewritten Input is now stale; it stays, since removing it is not what the comment asked, and the reply says which ones to re-evaluate.
4. **Export and check.**
   `Export[ "Name_k+1.nb", new, "NB" ]`, then re-import and compare cell by cell with `Name_k.nb`: only the positions from step 1 may differ.
   `Export` adds `FrontEndVersion`, `StyleDefinitions` and an `ExpressionUUID` to a notebook that lacks them, so compare cells, not the whole expression; from then on the round trip is a fixed point.
