# The three places

Every folder that holds documents has the same three places.
Shared by [revise](../revise/SKILL.md), [`/clean`](../../commands/clean.md), the generating skills — [new-notebook](SKILL.md), [new-research-note](../new-research-note/SKILL.md), [new-research-notebook](../new-research-notebook/SKILL.md) — and [new-paper](../new-paper/SKILL.md).
One rule, applied to every folder.

## The rule

```
Research/
  GeodesicPools_260919.tex      a document in progress
  GeodesicPools_260919_2.tex    its next version
  Artifacts/                    what the plugin made once, on request
  Archive/                      earlier versions, moved aside
```

- **The folder itself** holds the documents in progress: the ones the user writes, and the ones the user and the plugin write together, one numbered version per [revision round](../revise/round.md).
- **`Artifacts/`** holds what the plugin made once, on request: a notebook, a note on a conversation, an exploration.
  One dated stem per artifact, and an index.
- **`Archive/`** holds what is superseded: earlier versions and older artifacts.
  Nothing is deleted.

The rule is recursive.
`Artifacts/` is a folder too, so it has its own `Archive/`: a document revised inside `Artifacts/` archives into `Artifacts/Archive/`.
`Archive/` is created when something is first moved into it, never in advance.

`Work/` and `Wiki/` are not document folders.
`Work/` has its status folders, and `Wiki/` has no versions: an article is corrected in place.

## Never overwrite

**The plugin never overwrites a file.**
It writes a new artifact, or version `k+1` of a document beside version `k`, and version `k` is never edited again.

**Outside `Artifacts/`, it writes only on request.**
A document starts in the folder itself only when the user asks for it there; a round writes `k+1` there only when the user asks for the round.
Everywhere else outside `Artifacts/`, the plugin proposes rather than writes — [revise](../revise/SKILL.md) § *Protected content*.

Two things are not overwriting:

- **A generated file** is rebuilt in place from its source: a `.nb` from its `.md`, a `.pdf` from its `.tex`.
  Its source is the document; the generated file is not.
- **Code under development** — a `.wl` package, a script — is edited in place, with approval, and git holds its history.
  Versions and `Archive/` are for documents someone reads, not for code someone runs.

## Which place

A generating skill takes a destination: **the folder itself** for a document in progress, **`Artifacts/`** for a one-off.
A request that does not say which goes to `Artifacts/`, without asking: nothing is overwritten either way, so the cheap default is safe, and the user can move it up later.

| Producer | Folder | Document in progress | One-off |
|---|---|---|---|
| `new-notebook` | `Code/` | `Code/` | `Code/Artifacts/` |
| `new-research-note` | `Research/` | `Research/` | `Research/Artifacts/` |
| `new-research-notebook` | `Research/` | `Research/` | `Research/Artifacts/` |
| `new-paper` | `Research/` | always | never |

`Code/` holds the code and the notebooks about it: demonstrations, walkthroughs, explorations of what the project's own functions do.
`Research/` holds standalone mathematics, independent of any one paclet: papers, research notebooks, notes.
A document goes next to what it is about.
Create `Artifacts/` if it is missing, with the index described below.

In a working root that holds several projects, `Research/` sits at the root beside them, and each project keeps its own `Code/`.

Paclets stay in their own clones ([paclet-dev](../new-project/paclet-dev.md)); nothing built lands in the project.

### Papers

A paper is always a document in progress: it is the user's from the moment it is scaffolded, and it is never an artifact.
It lives in `Research/`, flat, or in `Research/<PaperName>/` once it has its own bibliography and figures.
A project that already has a `Paper/` folder keeps it: the paper is found and used there, the user is told that `Research/` is the new place, and nothing is moved.

### Moving up

To keep working on an artifact, the user moves it up into the folder: a plain `git mv`, no command.
From then on it is a document in progress, and its next round is written beside it there.
The next update of the `Artifacts/` index notes where it went.

## The shape

A document or an artifact is **one stem**, and whatever files it needs share it:

```
Artifacts/
  README.md                       the index
  GeodesicPools_260919.tex        the document
  GeodesicPools_260919.pdf        compiled from it
  GeodesicPools_260919.md         the notebook source
  GeodesicPools_260919.nb         converted from it, unevaluated, not committed
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

Bare inner names are not cosmetic: they are what lets a `build.wls`, an `\input` or a cross-folder `Get` keep resolving when the stem is re-dated or renamed.

## Naming

`CapitalizedWords` saying what the stem settles, then `_YYMMDD` — the date the work was settled, not the date a file was last touched.

Explicit over short: `InfraCircleTheoryAndInterface_260914`, not `InfraCircle`.
A reader scanning the folder should know what each stem answers without opening it.

A revision round appends its number to the stem — `_2`, `_3` — by the rule in [round.md](../revise/round.md) § *Names*.
A paper, and any file the user named, keeps its name; rounds number it the same way.

Shared machinery — `macros.tex`, `references.bib`, a template — carries no date, because it is not a document.

## Archive

Two things supersede a stem, and both end in the `Archive/` of the folder the stem is in:

- **A round** renumbers one date: `Note_260927_2.tex` supersedes `Note_260927.tex`.
  [`/clean`](../../commands/clean.md) moves every round but the latest into `Archive/`.
- **A revisit** is a new artifact with a new date, not new files in an old stem.
  The generating skill moves the earlier artifact's files into `Archive/` when it writes the new date.

`Archive/` is tracked in git like everything else.
A stem's provenance file stays beside its latest round ([provenance § *Document provenance*](../provenance/SKILL.md#document-provenance)).

## The index

Every `Artifacts/` folder carries a `README.md`: the convention in brief, then one table row per artifact — name, what it settles, and its state (page count, whether it compiled, what is still a scaffold).
It is updated in the same step that creates the artifact, never later.
An artifact moved up into its folder, or into `Archive/`, keeps its row with a link to where it went.

## Git and the Cloud

**Every file of a stem is tracked, except a generated `.nb`.**
A generated notebook is not committed; its `.md` source is, and the `.nb` is rebuilt from it.
Stage a stem's files by name, so a `.nb` is never added by accident.
A document under revision also keeps its provenance file, `<stem>.provenance.md`, tracked beside it; the generating skill writes its first Request and commits version 1 as written ([provenance § *Document provenance*](../provenance/SKILL.md#document-provenance)).

Build litter is never committed: `.aux`, `.log`, `.fls`, `.fdb_latexmk`, `.out`, `.synctex.gz`, `.bbl`, `.blg`, editor backups.
Run `latexmk -c` after a build.

**Nothing is uploaded to the Wolfram Cloud unless the user asks for it.**
Publishing is a separate act, and the artifact's index line records that it happened.
