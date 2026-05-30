Create or manage a work item using the `work` skill.

With arguments (e.g. `/work graph curvature solver`), start a new work item:
bootstrap Work/ if needed, draft the Spec in `Work/Backlog/`, present it for
approval, then break it into session-sized tasks and move it to `Work/Active/`.
With no arguments, show the active items in Work/README.md and ask which to work on.

Work items hold execution state — spec, tasks, and per-session progress — separate
from Wiki/ (durable knowledge). Specs follow the revision workflow.
