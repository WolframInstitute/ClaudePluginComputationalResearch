Build, install, and publish a paclet to Wolfram Cloud using the `publish-paclet` skill.

Runs pre-publish checks (version bump, tests, uncommitted changes), builds the archive, installs locally, and uploads to Wolfram Cloud as a public object.
Produces a PacletInstall URL.

Pass paclet name as argument if ambiguous (e.g., `/publish-paclet SyntheticInfrageometry`).
