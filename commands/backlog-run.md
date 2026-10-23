Run one disciplined work session using the `backlog-run` skill.

Pick the next incomplete task from the named work item, or the single active one (ask if several).
When the user explicitly asks for the next Ready task, use the Ready-table order in `Work/README.md`, then unlisted Ready items alphabetically; resolve existing item branches first and skip items already UnderReview, Done or Dropped there.
Study its Spec, implement EXACTLY ONE task, append a Progress report, mark the task done, sync the Wiki, commit, and STOP.

Run this in a FRESH session each time — clean context per task is the whole point.
Example: `/backlog-run GraphCurvature`
