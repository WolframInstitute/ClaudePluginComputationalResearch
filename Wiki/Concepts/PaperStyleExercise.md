# Running the paper style guide against a real notebook

*[ LLM Generated ]*

What broke when [`style.md`](../../skills/research-notebook/style.md) was used for the first time on a real document.
Measured 2026-08-20 for `ExercisePaperStyle` T1, building [EquidistanceOddGirth](#the-document-under-test) end to end.
The corrections themselves are T3's; this article is the evidence they have to answer to.

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
