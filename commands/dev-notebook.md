Build the paclet's "dev notebook" using the `dev-notebook` skill.

A self-contained, evaluated, cloud-deployed Wolfram notebook that presents every exported function (a reference card) plus worked examples — each mostly code, each producing an embedded picture. Outputs are embedded (graphics rasterized, small symbolic results kept as live boxes), the build is smoke-tested headless to zero messages, deployed public to the Wolfram Cloud, and the stable URL is linked from the README.

The source of truth is `Scripts/build_<name>_notebook.wls` (copied from the plugin template); re-running it rebuilds and redeploys to the same cloud object.

Pass the paclet name as argument if ambiguous (e.g., `/dev-notebook SyntheticInfrageometry`). Otherwise detect it from the project's CLAUDE.md or by scanning for PacletInfo.wl.
