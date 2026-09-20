Freeze the current conversation as a research artifact using the `new-research-note` skill.

Writes five files sharing one dated stem in `Research/Artifacts/`: a plain mathematics document (`<Topic>_<YYMMDD>.tex` and its compiled `.pdf`) carrying a Setting, numbered Steps, Claims with complete proofs, named Assumptions for every unproved input, Observations marked "measured, not proved", and a catalogue of the degenerate cases and the smallest counterexamples — no abstract and no prose paragraphs. Beside it a paclet-independent Wolfram notebook (`.md` source, converted `.nb`, shipped unevaluated for the user to run) and a `.wl` with the same definitions for `Get`, plus a row in the folder's index saying what was settled.

Every number in the document is computed in a kernel session first, and every notebook cell is evaluated there before it is written down. Nothing is uploaded to the Wolfram Cloud and nothing is committed.

Pass the topic as argument (e.g. `/new-research-note geodesic pools`). Otherwise infer it from the conversation and say what you chose before starting.
