# Paclet changes — branch, worktree, PR (paclet-dev)

Read this only when a `next-session` task changes code in a **paclet submodule** of a `paclet-dev` repo.
Items touching only the dev repo (Wiki, `Work/`, `Code/`, notebooks, research) skip all of it — commit to `main` as usual.

The dev repo stays linear on `main` — `Wiki/`, `Work/`, `Code/` commit there.
Finished **paclet** code instead goes through a branch and a PR **in the paclet's own submodule repo**; the dev repo's `main` only moves its submodule pointer once that PR merges.
This keeps the shared Wiki/Work index conflict-free.

When a task changes a paclet `<Paclet>`:

1. **Worktree + branch (once per item).** If the sibling `<Paclet>--<item>/` does not exist, create it as a submodule worktree on a fresh branch — the dev repo gitignores `*--*/`:
   ```bash
   git -C <Paclet> worktree add ../<Paclet>--<item> -b work/<item>
   ```
   Edit the paclet's code there, not in the submodule's primary checkout.
2. **Commit split, each session.** Commit paclet code in the worktree to `work/<item>` (the submodule's own `.githooks/commit-msg` applies).
   Commit the dev-repo tracking — `Work/`, `Wiki/`, `Code/` — to the dev repo's `main`.
   Do **not** bump the dev repo's submodule pointer to the unmerged branch; the item's `## Hand-off` names the branch until the PR merges.
3. **On the last task (item → `Done/`).** Push and open the PR in the paclet repo:
   ```bash
   git -C <Paclet>--<item> push -u origin work/<item>
   gh pr create -R <Org>/<Paclet> -H work/<item> -B main --title "<item>" --body "<Spec>"
   ```
   Completing the dev-repo item does not wait on review.
4. **After the PR merges** (possibly a later session).
   On dev `main`, bump the submodule pointer to the merged commit and commit it, then prune: `git -C <Paclet> worktree remove ../<Paclet>--<item>` and delete `work/<item>`.
