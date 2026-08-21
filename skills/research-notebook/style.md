# Paper style

The shared writing guide.
Canonical for [research-notebook](SKILL.md) (a paper as a `.nb`) and for [scaffold-paper](../scaffold-paper/SKILL.md) (a paper as LaTeX or Typst).
Read this before writing a line of either.

**The paper is read by a human who wants to check it.**
Everything below follows from that: short sentences, complete arguments, and a hard separation between what is settled and what is not.

## The four tiers — Critical

A statement's tier decides which document it goes in.
**The default is out.**
A statement earns a place in the paper; it does not get one by existing.

| Tier | Test | Home |
|---|---|---|
| **Settled** | proved here in full, or cited to a source you have read | the paper: `Definition`, `Theorem`, `Lemma`, `Proposition`, `Corollary`, `Construction`, `Example` |
| **Open and central** | you cannot prove it, and the paper is about it | the paper's outlook, as `Conjecture` or `Question` — few, each stated once, evidence with the experiments |
| **Experimental** | numbers over a family: enumeration ranges, sweeps, distributions, timings | the *Ruliology* section |
| **Marginal** | hedged assertions, heuristics, alternate proofs, failed attempts, unresolved `[lookup]` | the [journal](../journal/SKILL.md) — never the paper; when the journal is off, § *When the journal is off* |

Two consequences worth stating plainly.

**"Verified by enumeration up to $n = 8$" is not a theorem, and it is not paper prose.**
The statement goes to the journal, or — when the paper is about it — into the paper as a `Conjecture` whose evidence sits in *Ruliology*.
It never appears as a hedge attached to a body statement.

**Nothing is silently dropped.**
A statement that fails the settled test moves to the journal with one line saying why.
Cutting is a transfer, never a deletion.

### When the journal is off — refuse to cut silently

The tier rules name the journal as the home of everything marginal, and the journal is [off by default](../journal/SKILL.md#the-toggle-check-this-first).
With it off there is no honest destination: the Wiki is a deduplicated encyclopedia, which is the wrong shape for a dated record of what did not make the paper.
So the generator does not decide.

**It stops, lists what has no home, and asks** — one prompt, once per document, and only when something is actually below the settled tier:

1. turn the journal on now (it scaffolds `Journal/` and the material transfers as usual);
2. keep this material in the paper for now, marked;
3. drop it, explicitly.

The third option is the only route to a deletion, and it needs the operator to say so.
That is what makes *cutting is a transfer, never a deletion* true rather than aspirational: silence cannot delete anything.

Two things this deliberately is not.
It is not the journal asking to be turned on — that skill stays silent when off, and the prompt comes from the paper generator, which has material in hand and nowhere to put it.
And it is not a decision the generator may take on the operator's behalf, in either direction: it neither writes the toggle nor floods the paper.

**The ruling is taken at the tier sort, before anything is built.**
It is not a closing step.
Option 2 changes the document, and by the end of a build the document has been converted, evaluated, deployed and linked from the README — a ruling taken there arrives after the thing it rules on was published.
So the prompt fires where the cut is made: [research-notebook](SKILL.md) step 2, and the moment material is set aside on the typeset path.
The hand-off step at the end only carries out a ruling already taken.

#### The retained block

Option 2 needs a fixed form, or retained material is indistinguishable from paper content and no later pass can find it again.

- **One terminal section**, after the outlook and before *Initialization*, titled to say what it is — *Retained material (no journal)*.
- **One `Remark` per item**, each opening with the literal marker `[ Retained — no journal ]` and one clause naming the tier it failed.
- The section's first sentence states that the material is not paper content and that the block is removable in one pass once a journal exists.

**A retained block is not the body.**
The bans on hedges, verification ranges and `[lookup]` are bans on *body* content, and a retained item is by construction one of those things — the marker is what holds the two apart.
It is the one place in a paper where `[lookup]` may stand, and it stands only until there is a journal to move it to.

This is the only section this guide prescribes, and it is prescribed because it is build metadata rather than mathematics: it is written in order to be deleted.

**Unattended, retain and report.**
An [autonomous run](../revise/SKILL.md#autonomous-mode--the-gate-is-deferred-not-dropped) has no one to ask, so the choice is fixed to (2) — the material stays in the paper as a retained block — and **the list goes into the item's `## Hand-off`**.
That is not a paraphrase of "the digest": the session cannot write the digest at all.
`scripts/auto-run.sh` builds it from the driver's own variables, and the one thing it prints from the session is `## Hand-off`, before and after, as the *Hand-off delta*.
A list written anywhere else does not reach the operator, who meets it at the merge — where that mode already defers every other gate.

## Results — stated in full, at the generality you can reach

The tier rule says what may enter. This is about how a result is stated, not about how big it is.

**State the result at the generality you can actually prove.**
A general theorem is the goal and always worth the work — generality is what makes a result useful to anyone else.
The rule is only that generality is never bought with a gap: if the argument closes for all $n$, say so and prove it; if it closes for $n = 3$, the honest paper says $n = 3$ and puts the general statement in a `Conjecture`.
A result is not diminished by being modest, and it is not improved by being stated wider than the proof reaches.

**A short paper is fine.**
If a session settles one thing, the honest document is short, and that is not a failure.
Never pad to look substantial, and never promote a statement a tier to fill a section.

**A statement names its own hypotheses.**
No "under the assumptions of Section 2", no "with notation as above", no hypothesis living only in the surrounding prose.
The test is lifting: cut the statement out, paste it into another document, and it must still mean exactly the same thing.
That test is also what makes a result quotable in a later paper, and what makes it translatable to Lean.

**Nothing is used before it is proved.**
Not merely before it is *defined* — before it is *proved*.
A forward reference forces the reader to hold an unverified claim in their head, which is the thing a checkable document must never ask.
Order the sections so one linear pass verifies everything.

On a typeset path `\cref` prints the number and a forward reference is visible on the page.
In a notebook a tag is inert text, so nothing shows and the citation reads like any other: the order has to be checked by reading the citations in sequence.

**Every definition is used.**
A definition that no later statement or example uses is deleted, however nice it is.
Dead notation costs the reader more than it costs you to cut.

**Every conjecture says what would settle it.**
One sentence: what a proof would need, or where the first open case sits.
A `Question` carries the same sentence and is the honest form where you cannot say which way it goes — a conjecture asserts, a question asks, and guessing in order to assert is worse than asking.

> **Conjecture.** Every connected graph has $\kappa \ge -1$. A proof would need a transport bound
> uniform in the degree; the first unchecked case is $|V| = 9$.

A conjecture without that sentence is decoration.
With it, it is the next piece of work.

**The paper ends on an outlook.**
The open statements — the conjectures and the questions — are gathered at the end rather than left where they arose, so a reader who wants the next piece of work finds it in one place.
It has no prescribed title and no prescribed length: a paper that settles one thing may close on a single `Question`.
What it is not is a summary of what was done (§ *Length*).

**Formalisation is never undertaken unasked.**
Do not start a Lean development, and do not add formalisation as a task, unless the operator explicitly asks for it — see [lean](../lean/SKILL.md).
Where a Lean proof already exists because it was asked for, name the file and theorem after the proof: it is the strongest verifiability signal the document can carry and it costs one clause.

What *is* always worth doing is writing statements precisely enough that formalising them later is possible — explicit hypotheses, explicit quantifiers, no appeal to a picture.
That is the same discipline as the lifting test above, and it pays off whether or not anyone formalises anything.

## Length — Critical

| Part | Budget |
|---|---|
| Abstract | ≤ 4 sentences: the problem, the result, the method, the computation |
| Introduction | 3 paragraphs, ≤ 6 sentences each: the problem, the results, the roadmap |
| Prose between statements | ≤ 6 sentences, and never two such paragraphs in a row |
| Proof | complete; one run of deductions past about 8 sentences wants a lemma factored out |
| Conclusion | 2–3 sentences |
| Examples | **one per statement** — every definition and every result |
| Sentence of connecting prose | ≤ 25 words |

These are the defaults that keep a document readable, not quotas to satisfy.
A passage that genuinely needs more takes more — but the budget is what it has to argue against, and most prose loses that argument.

Three of those budgets have a scope, and [the first documents written under this guide](../../Wiki/Concepts/PaperStyleExercise.md) found each one by breaking it.

**The 25-word cap is a rule about prose.**
In connecting prose a long sentence is usually two sentences, and cutting it costs nothing.
A proof deduction is governed by *one deduction per sentence* instead: what makes it long is the premises it uses and the tags it rests on, so splitting it hides which of them the step used.
An abstract sentence is the same case — four sentences carry the problem, the result, the method and the computation, and the one stating the result is often a formula.
There the sentence *count* is the budget and the word cap is not.

**Never two prose paragraphs in a row is a rule about prose between statements.**
The abstract, the introduction and the *Ruliology* entries are prose by construction and cannot interleave statements, so the rule does not reach them.
A code block between two paragraphs is not a statement and does not reset the run, which is why *Ruliology* has to be named here.

**The proof trigger counts one run of deductions, not a proof.**
A two-part proof — an equivalence, a two-sided bound, an induction with a base case — is counted part by part, and a proof of four two-sentence parts is not long.
Where the trigger and § *Proofs* disagree, § *Proofs* wins: a lemma factored out to satisfy a count, and used exactly once, is the shattering that section forbids.

A section is definitions and results with prose *connecting* them.
If two paragraphs of prose sit together, one of them is usually exposition and can go.

Two lines are worth their words against that budget, which would otherwise cut them.
A sentence at the head of a section saying what it establishes is the most useful line in it for anyone scanning — worth writing wherever the section is not self-evident from its title.
And where there is a conclusion, it says what is **open** rather than what was done: the introduction already stated every result, and a paper that summarises itself twice teaches the reader to skip both.

The rule against filling a slot reaches the apparatus a template ships.
An empty References section in a paper that cites nothing, and a table of contents on a paper of a few pages, are both there because the file had a line for them.
Delete the line, or comment it out.

## Sentences

Short and declarative.
One statement per sentence.
Standard mathematical phrasing: *We define. Let $G$ be. Suppose that. Then. It follows that. Conversely. Notice that. We say that $X$ is reduced if.*

Voice is the declarative "we".
Italicise a term where it is defined and never again.

**Banned — vocabulary from other fields.**
Each reads as jargon and each has an exact replacement:

| Do not write | Write |
|---|---|
| census, sweep, scan, battery, suite | name the range: "for all connected graphs with at most 8 vertices" |
| witness | example, counterexample |
| the bar, clears the bar | (delete — say what the example computes) |
| workhorse, pipeline, harvest, probe, drill down | (delete) |
| verdict, audit, smoke test, flag | (delete; in prose, "we verified") |
| marker, tag | label, number |

**Banned — adjectives asserting importance:** remarkable, powerful, elegant, striking, cleanly, sharp, fragile, genuinely, cautionary, deep, beautiful.
State the fact instead.
Write "the bound 2 cannot be lowered, since margin 1 fails" — not "the margin is sharp".

Commentary belongs in a `Remark`, not in loose prose between statements.

## Proofs — complete, and checkable in order — Critical

**A given argument is given in full.**
The reader checks it deduction by deduction without supplying anything.
A gap is worse than a missing proof, because a missing proof is visible.

- **Prose, not labelled steps.** No `Step 1.`, no numbered list. One deduction per sentence, in the order a reader checks them.
- **Every deduction names what it uses** — by tag: "by [Def:Hodge]", "by [Eq:Cyclic]", "by [Lem:HodgeType]". A deduction resting on nothing stated is a gap.
- **Display the algebra.** A computation running over three equalities is a display, not a sentence.
- **One deduction per sentence.** Two steps in one sentence is one step hidden. This rule, not the 25-word cap, is what governs the length of a proof sentence (§ *Length*).
- **A long proof is fine when it reads clearly.** Never abbreviate to hit a length, and do not shatter an argument into a chain of tiny lemmas either — a run of one-line lemmas is harder to follow than the single proof it came from. Pull a step out only when it has content of its own or gets used more than once. § *Length*'s trigger counts one run of deductions, so a two-part proof is counted part by part and this rule wins where the two disagree.

- **Do not type the closing □.** Both paths supply it — a `QED` character style ending the last paragraph on the notebook path, `amsthm`'s own on the typeset one. A hand-typed square doubles it.

**Banned — every phrase that stands in for a step:** clearly, obviously, evidently, one easily sees, it is well known, a straightforward computation shows, by a similar argument, we omit the details, sketch of proof, left to the reader.

*One checks that* is allowed only when the check itself follows as a display on the next line.

Where a deduction is computational, say what was computed and put the code in the Example after the proof.
Where you cannot prove the statement, do not write a partial proof — move the statement down a tier.

## Examples — one per statement

An example shows the object.
It is not a test, a benchmark, or a survey.

- **One per statement.** A definition earns an example as much as a result does: the reader meets a new object there, and a picture of it is what makes the definition checkable rather than merely readable. A section of definitions with no example among them is the one shape to avoid.
- **The answer is a picture or a small algebraic value** — the geometry illustrated, or one symbolic result that is itself the point. Never a table of numbers, never a boolean list, never a statistic. Those are *Ruliology*.
- **At most ten lines as the reader sees them**, and there is no floor: two lines is a good example when two lines answer, which is the usual case where a paclet function does the work. Readable top to bottom, and a reader copies it into a fresh document and changes one argument in. A 130-character one-liner is one line in a notebook cell and three or four in a printed column, so on a typeset path the call is wrapped to the text width by hand before it is counted.
- **One instance, and the picture shows something.** Choose the smallest object in which the phenomenon is *visible* — not the smallest one satisfying the definition, and not the triangle when the triangle is degenerate. A picture in which the phenomenon cannot be seen costs the reader the same space as one in which it can.
- **Err large rather than small.** Where the phenomenon appears across a family, take an instance big enough that the picture is of the phenomenon and not of the whole object: a triangle or a 4-cycle is a toy the reader checks by counting, and a graph of a dozen or more vertices reads as mathematics. Small instances belong in an exercise, not in a paper.
- **No labels on the picture.** No vertex or edge labels, no legend, no caption, no text in the graphic at all. The sentence above the example says what is being shown; the picture shows it.
- **Check that the highlight has not hidden the thing it highlights.** A highlighted set drawn over a highlighted pair covers it, and the reader then cannot see which pair the example is about — measured on the first example written under this rule. Render the picture and look at it before it goes in.
- **Bare.** No `PlotLabel`, legend, frame, `Style`, `Labeled`, no annotation restating the definition, no colour beyond a pastel default. Anything deletable without losing information is deleted.
- **Unlabelled unless something cites it.** An example is almost never cited, because the sentence above it already points at it; the same holds for a closing question. Tag or `\label` it only when a citation exists.

```wolfram
graph = GridGraph[ { 4, 4 } ];
HighlightGraph[ graph, FindShortestPath[ graph, 1, 16 ] ]
```

Bad — variables, options and labels carrying no mathematics:

```wolfram
Module[ { g, path, styled },
  g = GridGraph[ { 4, 4 }, VertexSize -> Medium, GraphLayout -> "SpringEmbedding" ];
  path = FindShortestPath[ g, 1, 16 ];
  styled = HighlightGraph[ g, path, GraphHighlightStyle -> "Thick" ];
  Labeled[ styled, Style[ "Shortest path in the 4×4 grid", Bold, 14 ], Top ] ]
```

**On a typeset path the picture is a file.**
Notebook code evaluates, so the picture is the Output cell under the call.
LaTeX and Typst do not evaluate, so the Example carries the call *and* an exported graphic — and the two are honestly linked only if the graphic came from exactly the code shown, on the kernel that ran it.
The ban on annotation rules out `figure` with a `\caption`, which numbers and labels the picture: use a centred non-floating box.
Bind it to the call in one unbreakable block (`minipage`), or the picture floats to the next page, away from the Example that owns it.

## Ruliology — where the experiments go

Experiments are kept out of the mathematical development, and the usual place for them is one section near the end: enumeration ranges, parameter sweeps, distributions, timings, counterexample searches.
**If there are no experiments there is no such section** — this is where they go, not a slot to fill.
A single stray computation can as easily sit in a `Remark`, and a large body of them belongs in the [journal](../journal/SKILL.md).

- One short paragraph per entry: what was computed, over what range, what came out.
- **And the call that reproduces it** — the function and the range, so a reader re-runs the check instead of trusting it. This is the one place code appears outside an Example, and it is what makes a computational claim verifiable at all.
- **The decoration rules relax here.** `ArrayPlot`, histograms, a labelled table over a family — these are data and are read as data.
- Each entry that supports a `Conjecture` in the body names its tag.
- Past about a page, the material belongs in the journal and the section keeps a one-line summary.

**The code that makes those calls runnable does not live here.**
An entry is one paragraph and one call, and the predicates and helpers the call needs are not part of the mathematics: a wall of them buries the calls the section exists to carry.
In a notebook they belong in the folded *Initialization* section at the end, out of the reading path.
In LaTeX or Typst they belong in an appendix, named once from *Ruliology* so a reader knows where to look.

The name is deliberate: it marks the material as exploration, so a reader knows the mathematical development ended above it.

## Citations and `[lookup]`

A named theorem is cited to a source you have read, with the precise location — author, title, year, and the section or page.

When you cannot verify it now, write `[lookup]` inline and log the item to the journal with the date and what you searched for.
**`[lookup]` must not survive into a finished paper.**
The one exception is a retained block written under § *When the journal is off*, which is not body content and is deleted the moment a journal exists.
Never attach a citation you have not opened, and never state a named result from memory.

## Authorship and the session footnote — Critical

**The author is the model, and nothing else.**
The document was written by the model; naming a human as author misattributes it.

- **Author** — the model, by name and exact identifier: `Claude Opus 5 (claude-opus-5[1m])`.
- **Date** — the date the document was generated, written out. Never `\today` or `datetime.today()`: those re-date the paper on every compile, and nothing in the output shows that it moved.
- **Footnote** — the operator, **how much freedom the model had**, and a one-sentence summary of the instructions it worked under.

The operator is the person who ran the session, not an author.

### The freedom level — Critical

A reader deciding how much to trust a machine-written paper needs to know **how much of its direction was the machine's**.
That is not the same question as whether the mathematics is right, and the document must not leave it to be guessed.

So the footnote carries one of exactly three labels, **set in bold**, and the reader learns the vocabulary once:

| Label | Means |
|---|---|
| **Directed** | the operator supplied the definitions, the statement and the method; the model executed and checked |
| **Guided** | the operator set the question and the constraints; the model chose the route and found the results |
| **Open exploration** | the operator named a topic; the questions, the direction and the results are the model's |

**Between two labels, take the more open one.**
The error that misleads a reader is claiming human direction the work did not have.

After the label comes **one sentence summarising the instructions actually given** — the internal prompt, paraphrased, not what the document turned out to contain:

> Operator: Pavel Hájek. **Open exploration** — asked whether the interior form sees anything about the boundary on trees, with no method or target statement named.

> Operator: Pavel Hájek. **Directed** — supplied Definition 2.1 and the statement of Theorem 3.4, and asked for the transport-argument proof.

Two rules on that sentence.
Write what was asked, including what was *not* specified, since that is what the label is about.
Where the instructions changed mid-session — an exploration that became a target — describe where they ended and pick the label for the work as it stands.

Where the [provenance](../provenance/SKILL.md) toggle is on, this line is the reader-visible summary of what the ledger records verbatim.

| Format | Author | Date | Footnote |
|---|---|---|---|
| notebook | `Author` cell, model name | `Date` cell | a second `Date` cell, the label in `StyleBox[…, FontWeight -> "Bold"]` |
| LaTeX | `\author{<model>}` carrying `\thanks{…}` | `\date{…}` | the `\thanks`, the label in `\textbf{…}` |
| Typst | the centred model line | the date line | a small block beneath it, the label in `*…*` |

The notebook has no footnote style, and `Caption` is not one — it carries a `Figure ⟨n⟩.` dingbat and increments a counter.
`Date` inherits `Text`, is centred and small, takes neither dingbat nor counter, and every MathNotebook sheet declares it, so it survives a stylesheet swap.

The `[ LLM Generated ]` line stays, above the title, on every path.
Neither amsart nor a plain Typst document has a slot for it, so it is built into the title itself — in LaTeX the first line of `\title`, set `\normalfont\normalsize` above a `\\[0.8ex]` break, with a short `\title[…]` for the running head; in Typst a small line above the title text.
It is the one marker that tells a reader what they are holding, and the LaTeX path dropped it until it was built by hand.

## Notation

Introduce notation once and never redefine it.
There is no symbol index.

- **LaTeX / Typst:** every nontrivial symbol gets a macro in `macros.sty` / `macros.typ`, defined once and used everywhere. The namespace is already occupied at many of the obvious names — `\mid` and `\d` both exist — so a macro sometimes drifts from the symbol it denotes (`\mps` for $M(u,v)$). Take the shortest free name and use it everywhere; never redefine an existing command to get a nicer one.
- **Notebook:** there is no macro mechanism, so the discipline is the same by hand — italicise the term at its definition, and use the symbol unchanged afterwards.

A definition defines a mathematical object; it does not name the function computing it.
Bind the two in one sentence after the definition, or let the Example do it by using the symbol:

> We compute the interior form with `GraphInteriorForm`.

## Checklist

- [ ] Every body statement is proved in full or cited to a source you have read.
- [ ] Conjectures and questions few, gathered in the outlook, each stated once, each saying what would settle it, evidence with the experiments.
- [ ] Every result stated at the generality the proof actually reaches — no wider, and no narrower than you can prove; no statement promoted a tier to fill a section.
- [ ] Every statement names its own hypotheses and survives the lifting test.
- [ ] Nothing used before it is proved — every citation read in order and its target checked to sit above it; every definition used by something later.
- [ ] The ending is an outlook of open statements, not a summary of what was done; no section exists to fill a slot, including the template's own empty References and its table of contents.
- [ ] No verification ranges, hedges, heuristics or failed attempts in the body — they are in the journal, or in a marked retained block if the journal is off (§ *When the journal is off*).
- [ ] Experiments in *Ruliology*, not in the development, each naming the call that reproduces it; the code those calls need is in Initialization (notebook) or an appendix (LaTeX/Typst), not in the section.
- [ ] Budgets met: abstract ≤ 4 sentences, intro 3 × ≤ 6, prose between statements ≤ 6 sentences and never two in a row, connecting sentences ≤ 25 words — proof deductions and abstract sentences are not word-capped.
- [ ] Proofs complete: every deduction present, one per sentence, each naming its tag; no *clearly*, *easily sees*, *omit the details*, *sketch*.
- [ ] No proof abbreviated to fit, none shattered into a chain of tiny lemmas, and no lemma existing only to satisfy the length trigger.
- [ ] One example per statement — every definition and every result; each answers with a picture that shows the phenomenon or one small algebraic value, bare, at most 10 rendered lines, labelled only if cited; on a typeset path the graphic is exported from exactly the call shown and bound to it in one unbreakable block.
- [ ] No banned vocabulary, no selling adjectives; commentary in a `Remark`.
- [ ] No `[lookup]` left; notation introduced once; macros defined in one file (LaTeX/Typst).
- [ ] The author is the model plus the generation date — never the compile date — with `[ LLM Generated ]` above the title on every path; no human is named as author.
- [ ] The footnote names the operator, carries the freedom level **in bold** (Directed / Guided / Open exploration), and summarises the instructions actually given, including what was left unspecified.
- [ ] Everything cut is in the journal with one line saying why — nothing deleted; with the journal off, the cut list was put to the operator **at the tier sort** (§ *When the journal is off*), nothing was dropped without a ruling, and retained material carries the `[ Retained — no journal ]` marker.
