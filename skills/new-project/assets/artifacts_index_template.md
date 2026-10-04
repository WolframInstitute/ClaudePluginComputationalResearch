# Artifacts

What the plugin made once, on request: a notebook, a note on a conversation, an exploration.
The folder one level up holds the documents in progress, and its `Archive/` holds what is superseded.
Nothing is overwritten and nothing is deleted.

An artifact is one stem, `<WhatItSettles>_YYMMDD`, shared by whatever files it needs, flat in this folder.
It becomes a folder of its own name only once it carries its own code, data, bibliography or build script, and then the files inside it go bare.
Every file of an artifact is tracked, `.nb` included; build litter (`.aux`, `.log`, `.fls`, `.fdb_latexmk`, `.out`, `.synctex.gz`) is not.
Nothing here is uploaded to the Wolfram Cloud unless you ask for it.

To keep working on an artifact, move it up into the folder with `git mv`.
Its row here then links to where it went.

| Artifact | What it settles | State |
|---|---|---|
