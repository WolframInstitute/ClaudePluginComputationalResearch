Create or manage a work item using the `backlog-add` skill.

With arguments (e.g. `/backlog-add graph curvature solver`), start a new work item: bootstrap Work/ if needed, draft the Spec in `Work/Backlog/`, present it for approval, then break it into session-sized tasks and, on approval, move it to `Work/Ready/` (or `Work/Active/` to start now).
For a long shaping session with the user, hand over to `/backlog-refine`.
With no arguments, show the Ready, Active and Under review items in Work/README.md and ask which to work on.
To review an item in `Work/UnderReview/`, follow `backlog-add` § *Review*.

Work items hold execution state — spec, tasks, and per-session progress — separate from Wiki/ (durable knowledge).
Specs follow the revision workflow.
