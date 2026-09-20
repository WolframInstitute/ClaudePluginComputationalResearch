# The artifact convention

Shared by [new-notebook](SKILL.md), [new-research-note](../new-research-note/SKILL.md) and [new-research-notebook](../new-research-notebook/SKILL.md).
One rule, one shape, one index.

## The rule

**Everything the model writes lands in an `Artifacts/` folder.
Everything outside one is the human's.**

That is the whole protection mechanism: a path check, not a judgment call.
There is no author suffix on any filename — who wrote what is recorded inside the document, in its `\author` line and in the `\thanks` naming the operator and how much freedom the model had.

## Where

| Producer | Destination |
|---|---|
| `new-research-note` | `Research/Artifacts/` |
| `new-research-notebook` | `Research/Artifacts/` |
| `new-notebook` | `Code/Artifacts/` |

`Research/Artifacts/` holds standalone mathematics — what was settled, independent of any one paclet.
`Code/Artifacts/` holds notebooks about the code: demonstrations, walkthroughs, explorations of what the project's own functions do.
An artifact goes next to what it is about.
Create the folder if it is missing, with the `README.md` index described below.

In a working root that holds several projects, `Research/Artifacts/` sits at the root beside them, and each project keeps its own `Code/Artifacts/`.

## The shape

An artifact is **one stem**, and whatever files it needs share it:

```
Artifacts/
  README.md                       the index
  GeodesicPools_260919.tex        the document
  GeodesicPools_260919.pdf        compiled from it
  GeodesicPools_260919.md         the notebook source
  GeodesicPools_260919.nb         converted from it, unevaluated
  GeodesicPools_260919.wl         the definitions, loadable with Get
```

It stays flat until it grows its own code, data, bibliography, figures or build script.
Then the **folder takes the stem and the files inside go bare**:

```
  WeylTensorObservables_260828/
    README.md   what it settles, and how to rebuild it
    Notebook/   the .md source and its .nb
    Code/       the .wl definitions and any scripts
    Data/       what the code produced
    build.wls
```

Bare inner names are not cosmetic: they are what lets a `build.wls`, an `\input` or a cross-folder `Get` keep resolving when the artifact is re-dated or renamed.

## Naming

`CapitalizedWords` saying what the artifact settles, then `_YYMMDD` — the date the work was settled, not the date a file was last touched.

Explicit over short: `InfraCircleTheoryAndInterface_260914`, not `InfraCircle`.
A reader scanning the folder should know what each artifact answers without opening it.

Shared machinery — `macros.tex`, `references.bib`, a template — carries no date, because it is not an artifact.

## One artifact, one date

A revisit is a **new artifact**, not new files in an old folder.
When a later pass supersedes an earlier one, the earlier sources move into a `<Topic>VersionSnapshots_YYMMDD/` folder with a README saying what each snapshot was, and the current artifact carries the new date.

## The index

Every `Artifacts/` folder carries a `README.md`: the convention in brief, then one table row per artifact — name, what it settles, and its state (page count, whether it compiled, what is still a scaffold).
It is updated in the same step that creates the artifact, never later.

## Git and the Cloud

**Every file in an artifact is tracked, `.nb` included.**
An artifact is a deliverable, not a build product.
If a notebook should not be in git history, it does not belong in the artifact.

Build litter is not part of the artifact and is never committed: `.aux`, `.log`, `.fls`, `.fdb_latexmk`, `.out`, `.synctex.gz`, `.bbl`, `.blg`, editor backups.
Run `latexmk -c` after a build.

**Nothing is uploaded to the Wolfram Cloud unless the user asks for it.**
Publishing is a separate act, and the artifact's index line records that it happened.
