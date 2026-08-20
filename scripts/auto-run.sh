#!/usr/bin/env bash
# auto-run.sh — drive Work/ items unattended, one cold `claude -p` process per task.
# Specification: Wiki/Concepts/AutonomousPipeline.md (this plugin's repo).
#
# The loop is deliberately intolerant: it verifies every run instead of trusting
# its exit status, halts on the first failure, and never cleans up after itself.

set -uo pipefail

# ── defaults ────────────────────────────────────────────────────────────────

MAX_TASKS=3
MAX_MINUTES=90
MAX_COST=5.00
DRY_RUN=0
ITEM=""

# `acceptEdits` covers file edits only, so the git invocations `next-session`
# step 8 makes have to be named.
#
# This list is a FLOOR, not a ceiling: `--allowedTools` is added to whatever the
# settings files already allow, it does not replace them. A tool the user's
# `~/.claude/settings.json` allows is therefore reachable in an unattended run
# whether or not it appears below, and on a machine with blanket `Bash`/`Edit`
# rules almost nothing can be denied. Only a tool absent from every settings
# file lands in `permission_denials` and halts the run naming itself
# (established live, HardenAutoRun T2 — see Wiki/Concepts/AutoRunOperations.md
# § Growing the allowlist). So the floor has to carry everything a task legally
# needs, rather than relying on the halt to discover it.
ALLOWED=(
  Read Write Edit Glob Grep Skill TodoWrite
  "Bash(git status:*)" "Bash(git add:*)" "Bash(git commit:*)" "Bash(git mv:*)"
  "Bash(git log:*)" "Bash(git diff:*)" "Bash(git show:*)" "Bash(git rev-parse:*)"
  "Bash(ls:*)" "Bash(cat:*)" "Bash(mkdir:*)" "Bash(date:*)" "Bash(grep:*)"
  # The MCP-first Wolfram set from CLAUDE.md § Wolfram Kernel Execution Policy:
  # one persistent kernel, no extra license seat. `SymbolDefinition` is the one
  # that was actually observed denied, and the other six are the same server's
  # tools any Wolfram-touching task reaches for next.
  mcp__Wolfram__WolframLanguageEvaluator mcp__Wolfram__WolframLanguageContext
  mcp__Wolfram__SymbolDefinition mcp__Wolfram__CodeInspector
  mcp__Wolfram__TestReport
  mcp__Wolfram__ReadNotebook mcp__Wolfram__WriteNotebook
  # The `.wls` fallback for when no MCP is attached; costs a license seat, so
  # CLAUDE.md's policy has the skill check headroom before spawning it.
  "Bash(wolframscript:*)"
)

# ── arguments ───────────────────────────────────────────────────────────────

while [ $# -gt 0 ]; do
  case "$1" in
    --max-tasks)   MAX_TASKS="$2"; shift 2 ;;
    --max-minutes) MAX_MINUTES="$2"; shift 2 ;;
    --max-cost)    MAX_COST="$2"; shift 2 ;;
    --allow)       ALLOWED+=("$2"); shift 2 ;;
    --dry-run)     DRY_RUN=1; shift ;;
    -h|--help)
      sed -n '2,8p' "$0"
      echo
      echo "usage: auto-run.sh [<Item>] [--max-tasks N] [--max-minutes M]"
      echo "                   [--max-cost USD] [--allow 'Tool(pattern)'] [--dry-run]"
      echo
      echo "Each task's model and effort come from its own routing annotation:"
      echo "  - [ ] T3 (model: sonnet, effort: high — why) — the task body."
      exit 0 ;;
    -*) echo "auto-run: unknown option $1" >&2; exit 2 ;;
    *)  ITEM="$1"; shift ;;
  esac
done

# ── helpers ─────────────────────────────────────────────────────────────────

die() { echo "auto-run: $1" >&2; exit 2; }

# First unchecked task line in `## Tasks`, excluding the `### Done` subsection.
next_task() {
  awk '/^## Tasks/{t=1;next} /^### Done/{t=0;next} /^## /{t=0} t && /^- \[ \]/{print;exit}' "$1"
}

done_boxes() {
  awk '/^### Done/{d=1;next} /^## /{d=0} d && /^- \[x\]/{c++} END{print c+0}' "$1"
}

handoff() {
  awk '/^## Hand-off/{h=1;next} /^## /{h=0} h' "$1"
}

eligible() {
  grep -qE '^> *Autonomous: *allowed' "$1"
}

# ── the routing annotation ──────────────────────────────────────────────────
#
#   - [ ] T3 (model: sonnet, effort: high — ~90% mechanical) — sweep the renames.
#
# Grammar and rationale: Wiki/Concepts/ItemFileFormat.md § The per-task routing
# annotation. Three properties of the parse below are load-bearing.
#
# It is ANCHORED: the group has to start where the task id ends, and it is
# matched as `[^)]*`, so a `)` in the task body cannot widen it and an `effort:`
# mentioned in the body's prose cannot be read as a field.
#
# A group carrying no `key:` at all is NOT an annotation — `(human)` and `(S2)`
# pass through untouched — while a group that does carry one must parse
# completely, so `(modle: sonnet)` halts instead of silently inheriting.
#
# Only the effort is validated. The two halves fail in opposite directions: an
# unrecognised model exits 1 with `is_error` at zero cost and trips condition 3
# for free, while an unrecognised effort *succeeds* at default effort and warns
# only on stderr (Wiki/Concepts/HeadlessModelSurface.md).
EFFORT_LEVELS="low medium high xhigh max"
ROUTE_MODEL=""
ROUTE_EFFORT=""
ROUTE_ERROR=""

parse_routing() {
  local task="$1" annot fields rest
  ROUTE_MODEL=""; ROUTE_EFFORT=""; ROUTE_ERROR=""

  annot=$(printf '%s\n' "$task" | sed -n \
    -e 's/^- \[[ x]\] *//' \
    -e 's/^T[0-9]* *//' \
    -e 's/^(\([^)]*\)).*/\1/p')
  [ -n "$annot" ] || return 0
  case "$annot" in *:*) ;; *) return 0 ;; esac

  # The reason clause is prose: it is dropped before the fields are read, so a
  # comma or a colon inside it is not mistaken for another field.
  fields=$(printf '%s\n' "$annot" | sed -e 's/—.*//' -e 's/–.*//' -e 's/ - .*//')
  ROUTE_MODEL=$(printf  '%s\n' "$fields" | sed -n 's/.*model: *\([A-Za-z0-9._-]*\).*/\1/p')
  ROUTE_EFFORT=$(printf '%s\n' "$fields" | sed -n 's/.*effort: *\([A-Za-z0-9._-]*\).*/\1/p')

  rest=$(printf '%s\n' "$fields" \
    | sed -e 's/model: *[A-Za-z0-9._-]*//' -e 's/effort: *[A-Za-z0-9._-]*//' -e 's/[[:space:],]//g')
  if [ -n "$rest" ]; then
    ROUTE_ERROR="unrecognised annotation field in ($annot) — left over: $rest"
    return 1
  fi

  if [ -n "$ROUTE_EFFORT" ]; then
    case " $EFFORT_LEVELS " in
      *" $ROUTE_EFFORT "*) ;;
      *) ROUTE_ERROR="effort '$ROUTE_EFFORT' is not one of ${EFFORT_LEVELS// /|}"; return 1 ;;
    esac
  fi
  return 0
}

# What the digest says about one task's routing: the model actually used, the
# tier it was routed to, and the effort *requested* — no output field reports the
# effort applied, so the line must not imply one was observed.
route_note() {
  local note="model \`${1:-?}\`"
  if [ -n "$ROUTE_MODEL" ]; then note+=" (routed \`$ROUTE_MODEL\`)"; else note+=" (inherited)"; fi
  if [ -n "$ROUTE_EFFORT" ]; then note+=", effort \`$ROUTE_EFFORT\` requested"; else note+=", effort inherited"; fi
  printf '%s' "$note"
}

# Digests are a review surface, not work: they must not trip the dirty-tree stop
# condition in a repo that has not gitignored them.
tree_dirty() {
  [ -n "$(git status --porcelain -- . ':(exclude)Work/Runs/')" ]
}

# Active while live, date-prefixed in Done/ once the last task closes.
resolve_item() {
  local name="$1" hit
  [ -f "Work/Active/$name.md" ] && { echo "Work/Active/$name.md"; return 0; }
  hit=$(ls -1 Work/Done/*-"$name".md 2>/dev/null | tail -1)
  [ -n "$hit" ] && { echo "$hit"; return 0; }
  return 1
}

# ── preflight ───────────────────────────────────────────────────────────────

command -v claude >/dev/null || die "claude not found in PATH"
command -v jq >/dev/null     || die "jq not found in PATH (required to read --output-format json)"

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || die "not inside a git repository"
cd "$REPO_ROOT" || exit 2
[ -d Work ] || die "no Work/ directory in $REPO_ROOT"

! tree_dirty || die "working tree is dirty — commit or stash before an unattended run"

# ── selection: fail closed ──────────────────────────────────────────────────

if [ -n "$ITEM" ]; then
  [ -f "Work/Active/$ITEM.md" ] || die "no active item Work/Active/$ITEM.md"
  eligible "Work/Active/$ITEM.md" || die "$ITEM is not marked '> Autonomous: allowed'"
else
  CANDIDATES=()
  for f in Work/Active/*.md; do
    [ -e "$f" ] || continue
    eligible "$f" && CANDIDATES+=("$(basename "$f" .md)")
  done
  case ${#CANDIDATES[@]} in
    1) ITEM="${CANDIDATES[0]}" ;;
    0) die "no active item carries '> Autonomous: allowed' — mark one, or name it explicitly" ;;
    *) die "${#CANDIDATES[@]} eligible active items (${CANDIDATES[*]}) — name the one to run" ;;
  esac
fi

ITEM_FILE="Work/Active/$ITEM.md"
BRANCH="auto/$ITEM"
STARTED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)
STAMP=$(date -u +%Y%m%d-%H%M%S)
DIGEST="Work/Runs/$STAMP-$ITEM.md"
BASE_REF=$(git rev-parse --abbrev-ref HEAD)
BASE_SHA=$(git rev-parse HEAD)
DEADLINE=$(( $(date +%s) + MAX_MINUTES * 60 ))

if [ "$DRY_RUN" = 1 ]; then
  DRY_TASK=$(next_task "$ITEM_FILE")
  # A rehearsal that skipped the annotation would pass on the one input the real
  # run halts on, so `--dry-run` is also how a typo'd annotation is found.
  parse_routing "$DRY_TASK" || die "$ITEM: $ROUTE_ERROR"
  echo "item      : $ITEM"
  echo "branch    : $BRANCH (from $BASE_REF @ ${BASE_SHA:0:8})"
  echo "next task : ${DRY_TASK:-(none — item complete)}"
  echo "routing   : model ${ROUTE_MODEL:-inherited}, effort ${ROUTE_EFFORT:-inherited}"
  echo "caps      : $MAX_TASKS tasks / $MAX_MINUTES min / \$$MAX_COST"
  echo "digest    : $DIGEST"
  echo "allowed   : $(IFS=,; echo "${ALLOWED[*]}")"
  exit 0
fi

# Autonomous work never lands on the caller's branch: the human's merge is the
# `revise` approval step.
git show-ref --verify --quiet "refs/heads/$BRANCH" \
  && git checkout -q "$BRANCH" \
  || git checkout -q -b "$BRANCH"

# ── digest ──────────────────────────────────────────────────────────────────

mkdir -p Work/Runs
ALLOWLIST=$(IFS=,; echo "${ALLOWED[*]}")

# A headless session cannot observe that it is headless: the first live run
# (T8, 2026-07-28) did the task correctly but recorded in `## Hand-off` that it
# had "run as an interactive /next-session", which was false. `revise` asks the
# session to detect autonomous mode from the absence of a user, and absence is
# exactly what is not observable from inside. So the driver states it, in the
# system prompt rather than in the prompt, where it cannot be mistaken for part
# of the slash command's arguments.
AUTONOMY_NOTICE="You are an autonomous run driven by scripts/auto-run.sh: a headless \`claude -p\` process on branch $BRANCH, working Work/Active/$ITEM.md, which is marked '> Autonomous: allowed'. There is no interactive user; nothing you write to the transcript is read by anyone. Follow the \`revise\` skill's section 'Autonomous mode — the gate is deferred, not dropped'. In particular: do not stop to present, commit unconditionally before finishing, and if the task turns on a decision you would otherwise have asked about, write the question into '## Hand-off' on a line containing 'needs-human:', commit that, and stop."
STDERR_FILE=$(mktemp -t auto-run-stderr)
trap 'rm -f "$STDERR_FILE"' EXIT
TASKS_RUN=0
MODEL_USED=""
TOTAL_COST=0
TOTAL_IN=0
TOTAL_OUT=0
TOTAL_CACHE_CREATE=0
TOTAL_CACHE_READ=0
HANDOFF_BEFORE=$(handoff "$ITEM_FILE")
STOP_REASON="unknown"
LOG_LINES=""

emit() { LOG_LINES+="$1"$'\n'; }

# A task that halted under a cheap tier may have halted *because* of the tier.
# The digest names the escalation so the human's one decision is yes/no rather
# than diagnosis. Emitted only for the halts where the session ran and closed
# nothing — not for `permission-denied` or an API-level failure, which name their
# own cause, and not for `needs-human`, where the task finished.
maybe_escalate() {
  local tier="$ROUTE_MODEL" up=""
  if [ -z "$tier" ]; then
    case "$MODEL_USED" in *haiku*) tier=haiku ;; *sonnet*) tier=sonnet ;; esac
  fi
  case "$tier" in
    haiku)        up=sonnet ;;
    sonnet|fable) up=opus ;;
  esac
  [ -n "$up" ] || return 0
  emit "- **escalate?** $TASK_ID ran on \`$tier\` — before treating this halt as a fault in the work, re-run it as \`(model: $up, effort: ${ROUTE_EFFORT:-high})\`. A cheap tier fails by producing confident wrong output, so a re-run at the same tier can repeat the fault rather than expose it."
}

write_digest() {
  local ended handoff_after
  ended=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  handoff_after=""
  local resolved; resolved=$(resolve_item "$ITEM") && handoff_after=$(handoff "$resolved")

  {
    echo "# Autonomous run — $ITEM"
    echo
    echo "*[ LLM Generated ]* — driver digest, gitignored. Review surface for \`$BRANCH\`."
    echo
    echo "| | |"
    echo "|---|---|"
    echo "| Item | \`$ITEM\` |"
    echo "| Branch | \`$BRANCH\` (from \`$BASE_REF\` @ \`${BASE_SHA:0:8}\`) |"
    echo "| Started / ended | $STARTED_AT → $ended |"
    echo "| Tasks run | $TASKS_RUN (cap $MAX_TASKS) |"
    echo "| Stop reason | **$STOP_REASON** |"
    echo "| Cost | \$$(printf '%.4f' "$TOTAL_COST") (cap \$$MAX_COST) |"
    # `.usage.input_tokens` counts only the uncached remainder — 30 on a real
    # task whose true input was a million. Report the sum first, or the digest
    # understates the pipeline's own price by four orders of magnitude.
    echo "| Tokens in | $((TOTAL_IN + TOTAL_CACHE_CREATE + TOTAL_CACHE_READ)) total = $TOTAL_IN uncached + $TOTAL_CACHE_CREATE cache create + $TOTAL_CACHE_READ cache read |"
    echo "| Tokens out | $TOTAL_OUT |"
    echo
    echo "## Per-task verdict"
    echo
    printf '%s' "$LOG_LINES"
    echo
    echo "## Commits — \`$BASE_REF..$BRANCH\`"
    echo
    echo '```'
    git log --oneline "$BASE_SHA..HEAD" 2>/dev/null || echo "(none)"
    echo '```'
    echo
    echo "## Files touched"
    echo
    echo '```'
    git diff --stat "$BASE_SHA..HEAD" 2>/dev/null || echo "(none)"
    echo '```'
    echo
    echo "## Hand-off delta"
    echo
    echo "### Before"
    echo
    printf '%s\n' "${HANDOFF_BEFORE:-(empty)}"
    echo
    echo "### After"
    echo
    printf '%s\n' "${handoff_after:-(empty)}"
  } > "$DIGEST"

  echo
  echo "auto-run: stopped — $STOP_REASON after $TASKS_RUN task(s), \$$(printf '%.4f' "$TOTAL_COST")"
  echo "auto-run: digest $DIGEST"
}

halt() { STOP_REASON="$1"; write_digest; exit "${2:-1}"; }
trap 'STOP_REASON="interrupted"; write_digest; exit 130' INT TERM

# ── the loop ────────────────────────────────────────────────────────────────

while :; do
  # 4 — someone else is mid-edit.
  ! tree_dirty || halt "dirty-tree"

  ITEM_FILE=$(resolve_item "$ITEM") || halt "item-vanished"

  # 1 — success exit.
  TASK=$(next_task "$ITEM_FILE")
  [ -n "$TASK" ] || halt "item-complete" 0

  # 6 — backstop caps, checked BEFORE the author gate. Both can be true at once,
  # and then the cap is the reason the loop stopped: the gated task was never
  # going to run. Gate-first reported `task-gated` (exit 1, "you are needed") for
  # a run that had simply finished its allotment.
  [ "$TASKS_RUN" -lt "$MAX_TASKS" ] || halt "cap-tasks" 0
  [ "$(date +%s)" -lt "$DEADLINE" ] || halt "cap-wallclock" 0
  awk -v c="$TOTAL_COST" -v m="$MAX_COST" 'BEGIN{exit !(c<m)}' || halt "cap-cost" 0

  # per-task author gate
  case "$TASK" in
    *"(human)"*) emit "- **halt** \`${TASK:0:80}\` — task is marked \`(human)\`"; halt "task-gated" ;;
  esac

  TASK_ID=$(echo "$TASK" | sed -n 's/^- \[ \] *\(T[0-9]*\).*/\1/p')
  TASK_ID=${TASK_ID:-T?}
  MODEL_USED=""

  # Fail closed BEFORE spawning: a bad effort would otherwise run to a clean,
  # committed, successful task that silently used the default tier of thinking.
  if ! parse_routing "$TASK"; then
    emit "- **halt** $TASK_ID — $ROUTE_ERROR"
    halt "bad-annotation"
  fi
  ROUTE_ARGS=()
  [ -n "$ROUTE_MODEL" ]  && ROUTE_ARGS+=(--model "$ROUTE_MODEL")
  [ -n "$ROUTE_EFFORT" ] && ROUTE_ARGS+=(--effort "$ROUTE_EFFORT")

  HEAD_BEFORE=$(git rev-parse HEAD)
  DONE_BEFORE=$(done_boxes "$ITEM_FILE")

  echo "auto-run: $ITEM $TASK_ID [${ROUTE_MODEL:-inherited}/${ROUTE_EFFORT:-inherited}] — $(date -u +%H:%M:%SZ)"

  # The prompt goes FIRST: `--allowedTools` is variadic and swallows every
  # positional after it, so a trailing prompt is consumed as a tool name and the
  # run dies with "Input must be provided either through stdin or as a prompt".
  # The `plugin:` prefix is mandatory headless: the bare `/next-session` is a
  # zero-cost no-op that reports is_error:false.
  # `${ROUTE_ARGS[@]+...}` guards the empty-array expansion under `set -u`, which
  # is an error on bash 3.2 — still the /bin/bash on macOS.
  OUT=$(claude -p "/computational-research:next-session $ITEM" \
        --output-format json \
        --permission-mode acceptEdits \
        ${ROUTE_ARGS[@]+"${ROUTE_ARGS[@]}"} \
        --append-system-prompt "$AUTONOMY_NOTICE" \
        --allowedTools "$ALLOWLIST" 2>"$STDERR_FILE")
  RC=$?
  TASKS_RUN=$((TASKS_RUN + 1))

  if ! echo "$OUT" | jq -e . >/dev/null 2>&1; then
    emit "- **halt** $TASK_ID — driver could not parse the run's JSON (exit $RC):"
    emit ''
    emit '  ```'
    emit "  ${OUT:0:1000}"
    emit "  --- stderr ---"
    emit "  $(head -c 1000 "$STDERR_FILE")"
    emit '  ```'
    halt "unparseable-output"
  fi

  IS_ERROR=$(echo "$OUT" | jq -r '.is_error // false')
  SUBTYPE=$(echo "$OUT" | jq -r '.subtype // "?"')
  STOPR=$(echo "$OUT" | jq -r '.stop_reason // "end_turn"')
  TERMR=$(echo "$OUT" | jq -r '.terminal_reason // ""')
  TURNS=$(echo "$OUT" | jq -r '.num_turns // 0')
  DENIALS=$(echo "$OUT" | jq -r '(.permission_denials // []) | length')
  DENIED=$(echo "$OUT" | jq -r '(.permission_denials // []) | map(.tool_name // .toolName // tostring) | unique | join(", ")')
  COST=$(echo "$OUT" | jq -r '.total_cost_usd // 0')

  TOTAL_COST=$(awk -v a="$TOTAL_COST" -v b="$COST" 'BEGIN{printf "%.6f", a+b}')
  # Read `.usage` only — `.modelUsage` repeats the same figures per model.
  read -r U_IN U_OUT U_CC U_CR <<<"$(echo "$OUT" | jq -r '
    .usage // {} |
    "\(.input_tokens // 0) \(.output_tokens // 0)
     \(.cache_creation_input_tokens // 0) \(.cache_read_input_tokens // 0)" | gsub("\\s+";" ")')"
  TOTAL_IN=$((TOTAL_IN + U_IN))
  TOTAL_OUT=$((TOTAL_OUT + U_OUT))
  TOTAL_CACHE_CREATE=$((TOTAL_CACHE_CREATE + U_CC))
  TOTAL_CACHE_READ=$((TOTAL_CACHE_READ + U_CR))

  # The model the task ran on. `.modelUsage | keys` is NOT it: an auxiliary
  # `claude-haiku-4-5-*` call rides along on nearly every run and is frequently
  # `keys[0]`. It always carries zero cache tokens, and the task's model never
  # does — the discriminator held across every run measured (T1). The numbers
  # still come from `.usage` alone, for the reason given above.
  MODEL_USED=$(echo "$OUT" | jq -r '
    [(.modelUsage // {}) | to_entries[]] as $e |
    if   ($e | length) == 0 then "?"
    elif ($e | length) == 1 then $e[0].key
    else ([ $e[]
            | select((((.value.cacheReadInputTokens     // .value.cache_read_input_tokens     // 0)
                     + (.value.cacheCreationInputTokens // .value.cache_creation_input_tokens // 0))) > 0)
            | .key ]
          | if length == 0 then "?" else join(" + ") end)
    end')

  SUMMARY="$TASK_ID — turns $TURNS, \$$(printf '%.4f' "$COST"), $(route_note "$MODEL_USED"), subtype \`$SUBTYPE\`"

  # 3 — the run itself failed.
  [ "$RC" -eq 0 ]           || { emit "- **halt** $SUMMARY, exit $RC"; halt "nonzero-exit"; }
  [ "$IS_ERROR" = "false" ] || { emit "- **halt** $SUMMARY, \`is_error\`"; halt "is-error"; }
  [ "$STOPR" = "end_turn" ] || { emit "- **halt** $SUMMARY, stop_reason \`$STOPR\`"; maybe_escalate; halt "stop-reason"; }
  [ "$DENIALS" -eq 0 ]      || { emit "- **halt** $SUMMARY — $DENIALS permission denial(s): $DENIED"; halt "permission-denied"; }
  # A clean run reports terminal_reason `completed`, not `end_turn`.
  case "${TERMR:-completed}" in
    completed|end_turn) ;;
    *) emit "- **halt** $SUMMARY, terminal_reason \`$TERMR\`"; maybe_escalate; halt "terminal-reason" ;;
  esac

  ITEM_FILE=$(resolve_item "$ITEM") || { emit "- **halt** $SUMMARY — item file gone"; halt "item-vanished"; }

  # 5 — liveness. The load-bearing condition: a silent no-op reports success.
  HEAD_AFTER=$(git rev-parse HEAD)
  DONE_AFTER=$(done_boxes "$ITEM_FILE")
  [ "$HEAD_AFTER" != "$HEAD_BEFORE" ] \
    || { emit "- **halt** $SUMMARY — no new commit"; maybe_escalate; halt "no-commit"; }
  [ "$DONE_AFTER" -gt "$DONE_BEFORE" ] \
    || { emit "- **halt** $SUMMARY — \`### Done\` gained no box ($DONE_BEFORE → $DONE_AFTER)"; maybe_escalate; halt "no-box"; }

  emit "- **ok** $SUMMARY → \`$(git log -1 --format=%h\ %s)\`"

  # 2 — the session asked for a decision rather than guessing.
  if handoff "$ITEM_FILE" | grep -qi 'needs-human'; then
    emit "- **halt** — \`needs-human\` in \`## Hand-off\`; see the delta below"
    halt "needs-human"
  fi
done
