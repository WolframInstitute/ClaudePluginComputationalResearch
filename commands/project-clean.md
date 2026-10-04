Archive superseded revision rounds, using the naming rule in [round.md](../skills/document-revise/round.md) § *Names*.

Works on any folder — the current one by default, or the one given as argument (`/project-clean Research/Artifacts`).
Every folder archives into its own `Archive/`, an `Artifacts/` folder included: `/project-clean Research/Artifacts` moves into `Research/Artifacts/Archive/` ([artifacts.md](../skills/notebook-create/artifacts.md) § *The rule*).
For every stem with more than one round (`Name.ext` plus `Name_2.ext`, `_3`, …, told apart from a name that merely ends in a number by the same `Name_<k>.<ext>` needs `Name.<ext>` beside it rule round.md uses), `git mv` every round but the highest-numbered one, and each of its companion files, into the folder's `Archive/` subfolder — created if it does not exist yet, tracked in git like everything else. A folder-shaped artifact (`Name_YYMMDD/`) moves whole.
Nothing is ever deleted.
A stem's provenance file, `Name.provenance.md`, is not a round and not a companion of version 1: it stays in place beside the latest round ([provenance § *Document provenance*](../skills/project-provenance/SKILL.md#document-provenance)).

Only numbered rounds move this way: an artifact a later one supersedes by date, not by round number, stays where it is — that move belongs to the generating skill, made directly against `Archive/` when it writes the new date (per [artifacts.md](../skills/notebook-create/artifacts.md) § *Archive*).

If the folder carries an index `README.md`, update it so each entry names only the latest round, with a link into `Archive/`.

Commit the moves: `chore(clean): archive earlier rounds in <folder>`, with one body line per stem naming the rounds moved. The commit hook takes only lowercase scopes and caps the subject at 72 characters, so the stems go in the body.
