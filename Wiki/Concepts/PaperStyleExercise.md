# Running the paper style guide against a real document

*[ LLM Generated ]*

What broke when [`style.md`](../../skills/research-notebook/style.md) was used for the first time on real documents.
Measured 2026-08-20 for `ExercisePaperStyle`: T1 built [EquidistanceOddGirth](#the-document-under-test) as a notebook, and T2 re-set the same mathematics as a [scaffolded LaTeX paper](#the-latex-path--the-same-document-re-set).
The corrections themselves are T3's; this article is the evidence they have to answer to.

The guide is shared by the two paths, so a finding that reproduces on both is a guide bug and a finding that appears on one is a bug in that path's generator.
That split is the reason T2 re-set the same document instead of writing a new one.

Seven of the guide's rules fought the mathematics, and two of the seven are rules of the guide fighting *each other*.
Three defects in the build path turned up alongside them.

## The document under test

`NotebooksLLM/EquidistanceOddGirth.md` in the SyntheticInfrageometry dev repo — a short paper on what an infra-observer's betweenness and equidistance relations reveal about a graph substrate.
It carries 7 definitions, 3 lemmas, 2 propositions, 2 theorems, 2 corollaries, 9 proofs, 3 examples and one question, all settled: proved in full, checked over all 995 connected graphs with at most seven vertices, with no external citation and nothing hedged.
Built through the two-half pipeline to a 71-cell `.nb` with three folded example groups and a 74-cell fingerprint.

It is a real test rather than a rehearsal because the mathematics was found during the session, not transcribed: the pattern first noticed as a conjecture (σ = ⌈(k+1)/2⌉ for odd girth 2k+1) turned out to be provable in both directions, which is exactly the case the tier rules are supposed to handle well.

## Two rules of the guide contradict each other

**The 8-sentence proof trigger versus the ban on shattering.**
§ *Length* says a proof past about 8 sentences should have a lemma factored out.
§ *Proofs* says not to shatter an argument into a chain of tiny lemmas, and never to abbreviate to hit a length.
Four of the nine proofs run over the cap (9, 10, 13, 13 sentences), and the two longest are the two-part ones: the bipartite characterisation proves an equivalence, and the radius theorem proves a lower and an upper bound.
Factoring either one means creating a lemma used exactly once, which is the shattering the other rule forbids.
The trigger should not count a two-part proof — an equivalence, a two-sided bound, an induction with a base case — as one run.

**The 3-paragraph introduction versus "never two prose paragraphs in a row".**
§ *Structure* requires an introduction of three paragraphs; § *Length* says two prose paragraphs never sit together.
The introduction breaks the second rule twice by obeying the first.
The abstract and the introduction need an explicit exemption, since neither can be interleaved with statements.

## Five rules that fought the mathematics

**The *Ruliology* format mandates consecutive prose paragraphs.**
The section is one short paragraph per entry plus the call that reproduces it, and four entries therefore put four prose paragraphs in a row.
A code fence between two paragraphs is not a statement, so it does not reset the run.

**Four sentences of at most 25 words will not hold an abstract.**
The abstract must carry the problem, the result, the method and the computation in four sentences, and two of the four came out at 26 and 27 words.
One of them has to state the result, which here is a formula.
Either the sentence cap or the sentence count has to give, and the cap is the one that should.

**"One deduction per sentence" plus "name what it uses" pushes proof sentences past 25 words.**
Sixteen sentences in the document exceed 25 words and fourteen of them are proof deductions.
The premise of a step and the tag it rests on are what make the sentence long:

> A geodesic from $u$ to $w$, one from $w$ to $v$ and one from $v$ to $u$ form a closed walk of odd length $2s + d(u,v)$, which is at most $4s - 1$.

Splitting that sentence hides which three geodesics the walk is made of, which is the deduction.
The 25-word rule is a prose rule and should say so.

**Tag exactly when cited, but the SKILL invites tagging examples.**
`research-notebook` says an `Example` numbers on the shared counter "so it is citable as Example 2.2", which reads as an instruction to tag it.
Six tags were attached and never cited — the base definition, all three examples, one corollary and the question — and were deleted to satisfy § *Referencing*.
An example is almost never cited, because the sentence above it already points at it; the same holds for a closing question.

**The introduction cannot state results as numbered statements without numbering them twice.**
`research-notebook` § *Structure* asks for an introduction whose results are each "a numbered statement whose body says where it is proved".
Statement numbers are per-section, so such a statement numbers 1.1 while the theorem it announces numbers 5.2, and the reader meets one result under two numbers.
The introduction here states each result in prose citing the real tag ("by [Thm:Radius]"), which is what a paper does.

## What the guide got right

The tier rules held: no `Claim` reached the body, the enumerations went to *Ruliology* with their calls, and the conclusion says what is open rather than what was done.
The banned-vocabulary list cost nothing — zero hits in a document that names ranges instead of sweeps.
"One example per result" produced three examples for nine results and the page reads better for it; the definition-dense first section wanted none, which is the opposite of the suspicion recorded in the item's Spec.
The freedom footnote rendered as designed, and **Open exploration** is the honest label for a session whose mathematics the operator did not direct.

Two more findings, both negative and both useful.
The journal never came up: nothing in the session fell below the settled tier, so the gap [JournalAsPaperSink](../../Work/Backlog/JournalAsPaperSink.md) is filed against did not bite.
And semantic line breaks are safe in these sources — measured: a statement split across two source lines still converts to exactly one cell, and a trailing `{#Tag}` still attaches.

## Three defects in the build path

**The converter's `CellID`s are dropped by `Export`, which nearly blinded the fingerprint.**
`MarkdownToNotebook` stamps every cell with a 19-digit `CellID`; `Export[…, "NB"]` drops those silently, and `AssignCellIDs` skips a cell that already has one.
The first build shipped 8 fingerprinted cells out of 71 — the generator's own head and output cells, the only ones with kernel-assigned ids.
Stripping `CellID` alongside `CellLabel` in the build's normalisation step, and running `AssignCellIDs` on the notebook `MathNotebookDocument` returns, gives 74 of 74.
[build.md](../../skills/research-notebook/build.md) says to strip `CellLabel` only, and its pass order puts `AssignCellIDs` before `MathNotebookDocument`.

**Outputs must be evaluated from the source text, never from the cell boxes.**
A two-line `Input` cell holds both statements in one `RowBox` separated by `"\n"`, and `ToExpression[boxes, StandardForm, Hold]` reads that newline as multiplication: `(g = CycleGraph[4];) * InfraSceneHighlight[…]`.
[output-embedding.md](../../skills/research-notebook/output-embedding.md) already says to parse the code string with `ToExpression[code, InputForm, Hold]`; the reason it is not optional belongs next to it.

**A Markdown H1 plus the frontmatter title gives two `Title` cells.**
`ResearchHeadCells` builds the head from the frontmatter, so an `# Title` line in the source — the natural thing to write in Markdown — adds a second one.
The source carries no H1; `build.md` should say so.

## The three suspect numbers

The Spec singled out three numbers as set against flooding rather than measured.
What this document says about them, for T3 to rule on:

| Rule | Verdict here |
|---|---|
| one example per result | holds, and is if anything generous — 3 examples for 9 results read well, and the definition section needed none |
| example length 3–10 lines | holds — all three examples are 2 lines, because the paclet's `InfraSceneHighlight` does the work |
| sentence ≤ 25 words | fails for proofs and for the abstract; correct for connecting prose |

## The LaTeX path — the same document re-set

`ResearchNotebooks/EquidistanceOddGirth/Paper/` in the SyntheticInfrageometry dev repo, scaffolded by `scripts/scaffold-paper.sh` and compiled with `latexmk` to a 7-page PDF with no warnings and no overfull boxes.
The mathematics is T1's, unchanged except where the guide's own rules forced a change; every enumeration was re-run on a live kernel and every number reproduced exactly, including the 7-cycle being the only graph with at most seven vertices whose $\sigma$ is below its $k$.

### Five findings reproduce on both paths, so they are the guide's

The abstract, the proof sentences, the *Ruliology* paragraph run, the 8-sentence proof trigger against the ban on shattering, and the 3-paragraph introduction against the same ban all recur unchanged.
The two sentence-length cases are worth stating numerically, because they came out identical: the abstract's second and third sentences are 26 and 27 words in both documents, and the same fourteen proof deductions exceed 25 words.
None of the five is a notebook artefact.

### Four findings the LaTeX path exposed on its own

**The guide has no home for the code that makes a *Ruliology* call runnable.**
The notebook keeps its nine helper predicates in an *Initialization* section at the end, out of the reading path.
LaTeX has no such section, so they were written into *Ruliology*, where a wall of wrapped code buried the four one-line calls it exists to carry.
They now sit in an appendix, and `style.md` names neither destination.

**Code in a paper is wrapped by the column, not by the source.**
A notebook cell holding a 130-character one-liner is one line in the source and three or four on the page, broken at the listings package's continuation arrow.
The 3–10 line budget counts source lines, which is not what the reader sees, so the long calls here were hand-wrapped to the text width — the same discipline a human author applies and one the guide does not mention.

**An Example whose answer is a picture needs the picture as a file.**
Notebook code evaluates, so the picture is the output cell; LaTeX code does not, so the Example carries the call *and* an exported graphic, and the two are only honestly linked if the graphic was produced by exactly the code shown.
The three figures here were exported from the displayed calls on the kernel that ran them.
The § *Examples* ban on annotation also rules out `figure` plus `\caption`, since that numbers and labels the picture, so the graphic is a non-floating centred box — against ordinary LaTeX practice, and it needs binding into an unbreakable block or the picture floats onto the next page away from the Example that owns it, which is what the first compile did.

**T1's notebook contains a forward reference, and the checklist did not catch it.**
Its § *Primitives* asserted that `FindInfraMidpoint` returns a midpoint exactly at even distance "by [Lem:Subpath]", a lemma proved one section later.
§ *Results* forbids exactly that, and the checklist has a line for it.
In a notebook a tag is inert text, so a forward reference is indistinguishable from any other citation; writing `\cref` made it visible.
The claim is dropped from the paper, which now only binds the function to the definition.

### The build path — six defects in the shipped template

**Every `\cref` to anything but a theorem prints "Theorem".**
`macros_template.sty` numbers all thirteen environments on the shared `theorem` counter, and cleveref takes a reference's name from its counter.
So a definition is cited as "by Theorem 2.4", which is not a cosmetic problem: the paper tells the reader the wrong kind of thing is being invoked.
The fix is `aliascnt`, giving each environment its own counter name aliased to `theorem`, which keeps the shared numbering.

**And that fix, alone, makes a multi-reference silently drop entries.**
With aliased counters, cleveref's default range compression reads the shared values wrongly and swallows part of the list.
Measured on a five-label `\cref` in a two-section test file:

| `macros.sty` state | renders |
|---|---|
| as shipped, shared counter | `Theorems 1.1 to 1.3, 2.1 and 2.2` — five entries, all misnamed |
| `aliascnt` added | `Definitions 1.1 to 1.3` — correctly named, **two entries gone** |
| `aliascnt` + `nosort` | `Definitions 1.1, 1.2, 1.3, 2.1 and 2.2` |

The real document hit this: `\cref` over five definitions printed four numbers, one of them wrong, with no warning in the log.
Both halves of the fix are needed, and `nosort` is the one that is easy to leave out.

**`main_template.tex` emits no `[ LLM Generated ]` line.**
§ *Authorship* requires it above the title and the notebook path produces it, so the LaTeX path silently drops the one marker that tells a reader what they are holding.
amsart has no slot for it; it takes a hand-built two-line `\title`.

**`\date{\today}` dates the compile, not the document.**
§ *Authorship* asks for the date the document was generated.
`\today` re-dates the paper every time anyone runs `latexmk`, and nothing in the output shows that it moved.

**`\printbibliography` and `\tableofcontents` are unconditional.**
A self-contained paper cites nothing, so `references.bib` stays empty and the template prints an empty References section; a 7-page paper does not want a table of contents.
Both are slots filled because they are in the template, which is the failure § *Length* is written against.
Both are commented out here.

**`macros_template.sty` ships no code environment at all**, though § *Examples* and § *Ruliology* both require code.
A `listings` setup was added to the paper's copy.

One further defect is in the scaffold script rather than the templates: `scaffold-paper.sh` writes `<dir>/Paper/main.tex` with no check for an existing one, so running it at the dev repo root would have overwritten the author's own paper and `references.bib`.
That is why the exercise paper sits under `ResearchNotebooks/` instead.

### The three suspect numbers, on this path

| Rule | Verdict here |
|---|---|
| one example per result | holds, as in T1 — 3 examples for 9 results |
| example length 3–10 lines | holds in the source, but the budget should say it counts *rendered* lines, and that an Example is a call plus a picture on this path |
| sentence ≤ 25 words | fails identically to T1, which settles it as a guide rule rather than a notebook artefact |

A minor note on § *Notation*, which asks for one macro per nontrivial symbol.
LaTeX's namespace is already occupied at the obvious names — `\mid` and `\d` are taken — so the macro for $M(u,v)$ ended up `\mps`, drifting from the symbol it denotes.
The rule is right and the cost is real; it is only worth a sentence in the guide.

## What T3 corrected

Every finding above is now answered in the shipped files (2026-08-20).
The guide's own rules were corrected in place, as the item's Spec requires; the generator and template defects were fixed where the finding named them.

| Finding | Correction |
|---|---|
| 25-word cap fails for proofs and the abstract | the cap is scoped to connecting prose; a proof deduction is governed by *one deduction per sentence* and an abstract sentence by the sentence count — `style.md` § *Length*, § *Proofs* |
| 8-sentence proof trigger against the ban on shattering | the trigger counts one **run** of deductions, so a two-part proof is counted part by part, and § *Proofs* wins where the two disagree |
| 3-paragraph introduction against "never two prose paragraphs in a row" | that rule governs prose *between statements*; the abstract, the introduction and the *Ruliology* entries are exempt, and a code block does not reset a run |
| *Ruliology* has no home for its supporting code | notebook: the folded *Initialization* section; LaTeX/Typst: an appendix named once from *Ruliology* — `style.md` § *Ruliology*, `scaffold-paper` |
| example budget counts source lines, not rendered ones | "three to ten lines **as the reader sees them**", wrapped to the text width by hand on a typeset path |
| an Example answering with a picture, on a typeset path | the call plus a graphic exported from exactly that call, no `figure`/`\caption`, bound to the call in one unbreakable block |
| the SKILL invited tagging examples | an `Example` is tagged only when something cites it, which is rare — `research-notebook` § *Examples and the fold* |
| the introduction cannot state results as numbered statements | it states them in prose, each citing the tag where the result is proved — `research-notebook` § *Structure* |
| a forward reference is invisible in a notebook | the checklist line now says to read every citation in order and check its target sits above it |
| macros drift from the symbol they denote | one sentence in § *Notation*: take the shortest free name, never redefine an existing command |
| `\cref` names everything "Theorem"; `nosort` missing | `macros_template.sty` ships `aliascnt` + `nosort`, copied from the paper's verified copy |
| no code environment in the template | the same copy's `wolfram` listings environment, wrapped at the column |
| no `[ LLM Generated ]` line on the LaTeX path | built into `\title` as a `\normalfont\normalsize` first line, with a short running head; the Typst template gains the same line |
| `\date{\today}` dates the compile | the date is a scaffold argument, defaulting to today and baked in |
| unconditional `\printbibliography` and `\tableofcontents` | both ship commented out, with the reason in the comment; `style.md` § *Length* names template apparatus as a slot |
| `scaffold-paper.sh` overwrites an existing paper | it refuses when `main.tex`, `main.typ`, `macros.*` or `references.bib` exists, unless `--force` |
| converter `CellID`s blind the fingerprint | `build.md` strips `CellID` alongside `CellLabel`; see the sharper measurement below |
| boxes read as a product | `output-embedding.md` now carries why the source string is parsed, not the cell's boxes |
| a Markdown H1 gives two `Title` cells | `build.md` says the source carries no `#` heading; sections start at `##` |

### Two findings changed under re-measurement

**`Export` drops a 19-digit `CellID` and keeps a small one.**
Measured directly: a notebook holding `CellID -> 1234567890123456789`, `CellID -> 7` and no id at all round-trips through `Export[…, "NB"]` with only the `7` still in the file body.
That is why stripping the converter's ids and letting `AssignCellIDs` restamp with small sequential ones works, rather than merely being tidier.

**The pass order is immaterial, so the stripping is the whole fix.**
T1 recorded the order — `AssignCellIDs` before `MathNotebookDocument` — as part of the defect.
Measured on a fixture with a tagged statement, a tagged display equation, a citation, a bib key and a folded example group, the two orders return an **identical** notebook: `MathNotebookDocument` converts cells and carries their options through, and emits none of its own.
What was really wrong is that the order `mathnotebook_post.wl` documents was not callable: `AssignCellIDs` took only a cell list, so `AssignCellIDs[ MathNotebookDocument[ … ] ]` did not evaluate and a build following the comment would have exported the unevaluated expression.
It now has a `Notebook` overload, and `build.md` says the orders are equivalent.

### The three suspect numbers, as T3 leaves them for T4

| Rule | T3's ruling |
|---|---|
| one example per result | unchanged — both paths found it generous rather than tight |
| example length 3–10 lines | unchanged in magnitude, corrected in meaning: rendered lines, not source lines |
| sentence ≤ 25 words | scoped rather than moved: it governs connecting prose, and proofs and abstracts are out of its reach |

None of the three is re-numbered, because on both paths what failed was a rule's *scope* and not its threshold.

### The corrections are compiled, not just written

`scaffold-paper.sh` was run from the corrected assets into a scratch directory, both formats, and both compiled clean — `latexmk` for LaTeX, `typst compile` for Typst.
On the LaTeX side the five-label `\cref` that silently lost two entries now prints `Definitions 1.1, 1.2, 1.3, 2.1 and 2.2`, a mixed reference prints `Definition 1.1, Lemma 1.4, and Theorem 2.3`, the `[ LLM Generated ]` line sits above the title, the date is the baked one, and there is no table of contents and no empty References section.
The overwrite guard refuses a second scaffold into the same directory and exits 1.

## What the T4 read found

T4 is the operator's own task: read both documents end to end and rule on the three numbers and the tier boundaries.
It produced two build-path defects before any ruling — recorded below — and then the ruling itself, which is [at the end of this section](#the-ruling).
The two defects are in the build path rather than in the guide.

### The QED square was cell furniture

The `Proof` style carried the □ as a right-hand `CellFrameLabels`, and the front end centres a frame label vertically against the whole cell.
So on a five-line proof the square sat beside line three, and only a one-line proof looked correct — which is why neither T1 nor T3 caught it, and why the operator did on a continuous read.
All **seven** MathNotebook stylesheets carried the same three lines, so every proof in every sheet was affected.

Three placements were rendered and compared:

| Placement | Result |
|---|---|
| frame label, as shipped | □ at mid-height on any proof past one line |
| its own right-aligned cell | flush right like LaTeX, at the cost of one extra cell per proof |
| □ ending the last paragraph | correct at any length, no extra cell |
| frame label inside a bottom-aligned `Pane` | dead end — the Pane's fixed height inflates every proof cell |

The separate cell was built first, on the operator's choice, and then rejected on sight of it: the square hung a line below the prose with white space around it.
The last row is what shipped, and it is what the paclet already did everywhere else — `Resources/ComplexSystems.nb` declares a `QED` character style and the journal's author templates write `StyleBox["\[EmptySquare]", "QED"]` at the end of the proof's last paragraph, as do Wolfram's own `Article/JournalArticle.nb` and `PublicationDefault.nb`.
Reading the paclet's own precedent before choosing would have skipped a round.

The stylesheets are **generated** by `Scripts/BuildStyleSheets.wls`, which the first pass missed: seven hand-edited sheets would have been silently reverted by the next build.
The fix is in the generator, and the sheets are regenerated from it — semantically diffed against the previous seven to confirm the only changes are the frame label leaving `Proof` and the `QED` style arriving.

Because the square is content rather than a cell, the pass adds no cell, so the `AssignCellIDs` order T3 measured stays immaterial after all.
It matches the `"Proof"` style, so a proof split across cells by a display equation gets its square at the end of the first paragraph rather than the proof; the rule that keeps a proof in one cell was already in the guide, and this is a second reason for it.

The generated path is fixed; **the interactive path is not**, and that is the open half of this fix.
Two places in the paclet's kernel read the square as cell furniture and are now inert: `Referencing.wl`'s `continueEnvironment` explicitly clears the frame label from the cell a proof used to end on, and `Document.wl`'s importer suppresses it on every cell of a multi-cell block but the last.
So the palette's *Proof* button inserts a `Cell["", "Proof"]` that now carries no square at all, and an imported `\begin{proof}` gets none either.
The palette tooltip and the tutorial both still say the style ends with the square.
None of that is testable headlessly — it is front-end behaviour — and where the square should land when a block is continued is a design call, so it is left for the paclet's own session.
The paclet's suite otherwise passes on the regenerated sheets: `StyleSheets`, `Document`, `Referencing` and `Palette` all green, with `FrontEnd.wlt`'s three failures reproduced on a clean tree and therefore not this change's.

### Three fingerprint entries were stale, and the drift gate would have blocked on them

Re-checking the notebook before regenerating reported three cells as user-edited on a file nobody had opened — the three graphics `Output` cells, and nothing else.
Measured: the hash is stable across three separate kernels, and `Export`/`Import` is a fixed point for those cells, so neither the mechanism nor the round trip is at fault.
The recorded entries simply did not match the file that shipped, which means the outputs were re-evaluated between fingerprinting and the final write — floats from a layout differ in their last digits while the picture looks identical.

The consequence is the part that matters: a false positive in the drift gate is indistinguishable from a real operator edit, and the documented response to drift is to **stop**.
Any research notebook carrying a picture would therefore have refused to regenerate.
The rebuild re-stamped all 74 cells and the gate now reports zero drift; what has *not* been done is to make the build stamp from the final file by construction, so the defect can recur.

### The ruling

Four passages were read, chosen so that each one carried a number or a boundary the guide had never had tested against a page.
The operator's four answers (2026-08-21) settle the item.

| Read | Question | Ruling |
|---|---|---|
| § *Primitives*, five definitions with no example among them | is a definitions-only section right bare? | **no** — definitions get examples, with pictures |
| the Example after `Prop:Tree`, two lines and a picture | is that enough of an example? | **yes**, unchanged |
| the abstract, two of four sentences at 26–27 words | do they read long? | **no** — fine as they are |
| § *What is open*, closing on a `Question` | right choice? | **yes**, and the section itself is not required — but an outlook carrying questions and conjectures is |

**One rule was overturned, not rescoped.**
Every other finding of this exercise came out as a rule whose *scope* was wrong.
§ *Examples* held that a definition takes an example "only when the object is not evident from its statement", and called the `Definition, Example, Definition, Example` alternation a thing that "usually floods the page".
That was written from the flooding diagnosis this whole item came out of, and it is wrong: the reader meets a new object at a definition, and a picture is what makes the definition checkable rather than merely readable.
The guide now asks for one example per **statement** — definitions included — and names a definitions-only section as the shape to avoid.
The anti-flooding guard did not move: still no tables of numbers, still nothing decorative, still one instance.

The instruction came with its own limit — *nontrivial pictures, but simple pictures, no overstyling* — which is two rules, and both are now in § *Examples*.
The picture must show the phenomenon, so the object is the smallest one in which it is **visible** rather than the smallest one satisfying the definition; and the drawing stays bare, which § *Examples* already required.
A picture in which the phenomenon cannot be seen costs the reader the same space as one in which it can.

**The example floor is gone.**
Every example on both paths was two lines, because `InfraSceneHighlight` does the work, and the operator approved them.
A budget no approved instance has ever satisfied is not a budget: the range is now a ceiling of ten rendered lines with no floor, and the guide says two lines is a good example where two lines answer.

**The other two numbers stand as T3 left them.**
The abstract's long sentences read fine, which confirms the 25-word cap belongs to connecting prose alone — where it binds twice in 31 sentences, both at 26–28 words, against a mean of 17.
The tier boundaries hold, with one addition: *Open and central* now names `Question` alongside `Conjecture`, since a question is the honest form where you cannot say which way it goes, and guessing in order to assert is worse than asking.
Both belong to an **outlook** at the end of the paper — gathered there rather than left where they arose, with no prescribed title and no prescribed length.

**What the ruling leaves.**
The two exercise documents no longer satisfy the guide they corrected: § *Primitives* has five definitions and no example on either path.
They were the instrument, not a deliverable, and neither is deployed; bringing them into line is a fresh item's work, not a correction to this one.
The forward reference at `EquidistanceOddGirth.md:37` is still there for the same reason.

## Exercising the corrected rule

The ruling left both exercise documents failing the rule they had produced — five definitions with no example in § *Primitives*, two more in § *Radius* — so `ExampleEveryDefinition` put six examples into each path the same day (2026-08-21).
The six instances were verified on a kernel and rendered onto one contact sheet for the operator before a line of either document was touched, which is the cheapest order: a picture that shows nothing is visible in two seconds and costs a rebuild to find out later.

Six for seven definitions.
The base *substrate* definition takes none, because a picture of a graph illustrates nothing about the definition of a graph.
The Petersen graph carries two definitions on one pair — the equidistant set, then the midpoint — so the second picture is visibly the first minus the vertices that are not between, which two different graphs would have lost.

The notebook came out at 84 top-level cells with 9 example groups, 93 cells fingerprinted, zero drift; the paper at 9 pages from 7, no unresolved references, and one underfull vbox where it had none — the cost of six more unbreakable example blocks.

### Three findings, all of them the build path's

**A highlight can hide the thing it highlights.**
The first example computed the between-set honestly, which includes the pair itself, so the green set was drawn over the red pair and the picture no longer showed *which* pair the example was about.
Nothing in the guide caught it and nothing could: it is visible only by looking at the render.
§ *Examples* now says to render the picture and look at it, and the example excludes the endpoints and says *strictly between*.

**The stale fingerprint has a mechanism, and it is the stamping order.**
The three graphics outputs came out stale again on this build's predecessor, exactly as [S4 predicted they could](#three-fingerprint-entries-were-stale-and-the-drift-gate-would-have-blocked-on-them).
Measured: `Export`/`Import` is a fixed point for those cells, so the round trip is not the problem — the problem is writing a stamp taken from the round trip back onto the **in-memory** notebook, whose graphics boxes `Export` then normalises differently.
The build now stamps `Notebook[ First[ imported ], … ]` and re-imports to confirm the drift report is empty before declaring the build good; 93 of 93 cells match on the first check.
`fingerprint.md` carries the rule.

**Which fences get an Output was undocumented, and the obvious test silently embeds nothing.**
Only an `Input` directly under an `Example` is evaluated and folded; the *Ruliology* calls and the Initialization cells are shown, not run.
`build.md` said none of that, and the natural implementation — test the preceding cell for the `Example` style — matches nothing, because `ConvertEnvironmentCells` runs later inside `MathNotebookDocument`, so at embedding time an Example is still a `Text` cell whose content begins `Example.`.
The failure is silent: the build reports zero outputs and writes a notebook with nine bare `Input` cells.
Both facts are now in `build.md`.

A fourth thing is worth recording as a kernel-session trap rather than a guide finding.
A cell is **parsed before it is evaluated**, so a `Needs` at the top of a cell does not put its context on the path in time for the symbols further down that same cell: they resolve into the current context instead.
Six figures were exported from `Sessions`…`InfraSceneHighlight` — unevaluated, and `Export` reported success on every one, at seven times the byte size of a real picture.
The check that caught it is `Head` on the expression before exporting it, which is now what the export loop prints.
