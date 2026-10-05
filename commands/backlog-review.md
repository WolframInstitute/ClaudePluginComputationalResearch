Review a finished work item with the user, using the `backlog-review` skill.

Find the item in `Work/UnderReview/` or on its unmerged `work/<Item>` branch, show the run digest, walk the Acceptance criteria one by one with each task's test instructions, and run the checks that can be run.
End on the user's verdict: accept (merge the branch, item to `Work/Done/`) or send back (merge the branch, a new task from their words, item to `Work/Active/`).
Nothing is fixed during the review.

Example: `/backlog-review GraphCurvature`
