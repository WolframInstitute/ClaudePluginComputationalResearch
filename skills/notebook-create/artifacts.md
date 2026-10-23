# The three places

Every folder that holds documents has the same three places.
Shared by [document-revise](../document-revise/SKILL.md), [`/project-clean`](../../commands/project-clean.md), the generating skills — [notebook-create](SKILL.md), [paper-create-note](../paper-create-note/SKILL.md), [paper-create-notebook](../paper-create-notebook/SKILL.md) — and [paper-create](../paper-create/SKILL.md).
This convention organizes new generated outputs; preserve established human document paths and the ownership policies below.

## The rule

```
Research/
  GeodesicPools_260919.tex      a document in progress
  GeodesicPools_260919_2.tex    its next version
  Artifacts/                    what the plugin made once, on request
  Archive/                      earlier versions, moved aside
```

- **The folder itself** holds documents in progress, including human-owned documents and concise companions.
  Number another version only when requested; ordinary scoped edits and companion updates are made in place.
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

For human papers and paclet designs, [paper ownership](../paper-create/workflow.md) and [paclet design ownership](../project-create/paclet-design.md) take precedence over generic artifact and revision defaults.
The human alone advances the document's iterations; a concise `_notes` companion may be maintained in place within the requested scope, preserving human corrections.
Paclet design pairs belong in the repository root beside the paclet folder, not in `Code/Artifacts/` or a new notes directory.
Artifacts are organized by topic, not split into human/LLM directories.
An annotated reading PDF is human work, not a disposable generated output.

**The plugin never silently overwrites human work.**
A requested edit or companion update can be made in place under the policies above; numbered human iterations remain human controlled.
A new artifact or explicitly requested versioned round preserves the previous work; do not create extra versions merely because a notebook received a correction.

**Outside `Artifacts/`, it writes only on request.**
A document starts in the folder itself only when the user asks for it there; a round writes `k+1` there only when the user asks for the round.
Everywhere else outside `Artifacts/`, the plugin proposes rather than writes — [document-revise](../document-revise/SKILL.md) § *Protected content*.

Two things are not overwriting:

- **A faithfully reproducible generated file** may be rebuilt from its reconciled source within the requested scope.
  A notebook with direct human edits is not disposable: use [native targeted editing](editing.md), and check the current [fingerprint contract](../paper-create-notebook/fingerprint.md) before any full regeneration.
  Missing or legacy hashes do not establish that overwriting is safe; incomplete source write-back forbids regeneration from that source.
  An annotated reading PDF is preserved even when a newer source build exists.
- **Code under development** — a `.wl` package, a script — is edited in place, with approval, and git holds its history.
  Versions and `Archive/` are for documents someone reads, not for code someone runs.

## Which place

A generating skill takes a destination: **the folder itself** for a document in progress, **`Artifacts/`** for a one-off.
For a new generated one-off without a specified destination, use `Artifacts/` without asking.
Preserve existing paths, explicit destinations and human-owned paper/design pairs instead of applying this default to them.

| Producer | Folder | Document in progress | One-off |
|---|---|---|---|
| `notebook-create` | `Code/` | `Code/` | `Code/Artifacts/` |
| `paper-create-note` | `Research/` | `Research/` | `Research/Artifacts/` |
| `paper-create-notebook` | `Research/` | `Research/` | `Research/Artifacts/` |
| `paper-create` | `Research/` | always | never |

`Code/` holds the code and the notebooks about it: demonstrations, walkthroughs, explorations of what the project's own functions do.
`Research/` holds standalone mathematics, independent of any one paclet: papers, research notebooks, notes.
A document goes next to what it is about.
Create `Artifacts/` if it is missing, with the index described below.

In a working root that holds several projects, `Research/` sits at the root beside them, and each project keeps its own `Code/`.

Paclets stay in their own clones ([paclet-dev](../project-create/paclet-dev.md)); nothing built lands in the project.

### Papers

A human paper is a document in progress from the moment it is scaffolded.
Preserve its established location and name; `Research/` is the default for a newly scaffolded paper, flat or in a requested `Research/<PaperName>/` subfolder.
A project that already has a `Paper/` folder keeps it: the paper is found and used there, the user is told that `Research/` is the new place, and nothing is moved.

### Moving up

To keep working on an artifact, the user moves it up into the folder: a plain `git mv`, no command.
From then on it is a document in progress; ordinary edits use that path and a requested versioned round is written beside it.
The next update of the `Artifacts/` index notes where it went.

## The shape

A document or an artifact is **one stem**, and whatever files it needs share it:

```
Artifacts/
  README.md                       the index
  GeodesicPools_260919.tex        the document
  GeodesicPools_260919.pdf        compiled from it
  GeodesicPools_260919.md         the notebook source
  GeodesicPools_260919.nb         generated notebook (preserve later direct edits)
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

An explicitly requested versioned artifact round appends `_2`, `_3` by [round.md](../document-revise/round.md#names).
Human-owned numbered documents and any user-named file keep their established names and author-selected next-iteration scheme.
Do not append a date or generic `_2` to a human design pair merely to fit this artifact convention.

Shared machinery — `macros.tex`, `references.bib`, a template — carries no date, because it is not a document.

## Archive

For generated artifacts, two things can supersede a stem, and both end in the `Archive/` of the folder the stem is in.
Do not infer the current human manuscript/design by the highest number or archive its recorded current version without the user's scoped instruction:


- **A round** renumbers one date: `Note_260927_2.tex` supersedes `Note_260927.tex`.
  [`/project-clean`](../../commands/project-clean.md) moves every round but the latest into `Archive/`.
- **A revisit** is a new artifact with a new date, not new files in an old stem.
  The generating skill moves the earlier artifact's files into `Archive/` when it writes the new date.

`Archive/` is tracked in git like everything else.
A stem's provenance file stays beside its latest round ([provenance § *Document provenance*](../project-provenance/SKILL.md#document-provenance)).

## The index

Every `Artifacts/` folder carries a `README.md`: the convention in brief, then one table row per artifact — name, what it settles, and its state (page count, whether it compiled, what is still a scaffold).
It is updated in the same step that creates the artifact, never later.
An artifact moved up into its folder, or into `Archive/`, keeps its row with a link to where it went.

## Git and the Cloud

Follow the project's existing tracking policy and any explicit no-commit instruction.
A generated `.nb` may be excluded only while it is faithfully reproducible from its source and recorded build settings without losing human edits.
Keep human-owned notebooks and notebook-only corrections recoverable as actual notebooks through Git or the established archive/snapshot mechanism; a partial Markdown export or prose summary is not a replacement.
Stage files by name to avoid unrelated changes and disposable build products.
A document under revision keeps its existing provenance file, `<stem>.provenance.md`, beside it ([project-provenance](../project-provenance/SKILL.md#document-provenance)); respect no-commit scope rather than creating a surprise baseline commit.

Build litter is never committed: `.aux`, `.log`, `.fls`, `.fdb_latexmk`, `.out`, `.synctex.gz`, `.bbl`, `.blg`, editor backups.
Run `latexmk -c` after a build.

**Nothing is uploaded to the Wolfram Cloud unless the user asks for it.**
Publishing is a separate act, and the artifact's index line records that it happened.
