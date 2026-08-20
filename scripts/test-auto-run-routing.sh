#!/usr/bin/env bash
# test-auto-run-routing.sh — the routing annotation, end to end, spending nothing.
#
# Part 1 drives the real `auto-run.sh --dry-run` against fixture items, so the
# parse is exercised where it lives rather than in a copy of it.
# Part 2 puts a stub `claude` on PATH and checks what the driver passes to the
# spawn, what the digest says, and when it recommends an escalation.
#
# usage: bash scripts/test-auto-run-routing.sh [path/to/auto-run.sh]

set -uo pipefail

DRIVER=${1:-$(cd "$(dirname "$0")" && pwd)/auto-run.sh}
[ -f "$DRIVER" ] || { echo "no driver at $DRIVER" >&2; exit 2; }

PASS=0; FAIL=0
ok()      { PASS=$((PASS+1)); printf '  ok   %s\n' "$1"; }
bad()     { FAIL=$((FAIL+1)); printf '  FAIL %s\n' "$1"; }
want()    { if [[ "$2" == *"$3"* ]]; then ok "$1"; else bad "$1 — missing [$3] in: $2"; fi; }
wantnot() { if [[ "$2" != *"$3"* ]]; then ok "$1"; else bad "$1 — unexpected [$3]"; fi; }

item() { # name, task line — a minimal eligible item, committed
  mkdir -p Work/Active
  cat > "Work/Active/$1.md" <<ITEM
# $1

> Type: refactor
> Autonomous: allowed

## Spec

Fixture.

## Tasks

$2

### Done

## Hand-off

## Decisions

## Progress
ITEM
  git add -A >/dev/null && git commit -qm "fixture: $1" >/dev/null
}

# ── part 1: the parse, through --dry-run ────────────────────────────────────

WORK=$(mktemp -d -t auto-run-routing)
cd "$WORK" || exit 2
git init -q . && git config user.email t@t && git config user.name t

check() { # name, task line, expected routing line — or DIE:<substring of stderr>
  item "$1" "$2"
  local out rc got
  out=$(bash "$DRIVER" "$1" --dry-run 2>&1); rc=$?
  case "$3" in
    DIE:*)
      if [ "$rc" = 2 ] && [[ "$out" == *"${3#DIE:}"* ]]
        then ok "$(printf '%-12s exit 2, %s' "$1" "${3#DIE:}")"
        else bad "$(printf '%-12s exit %s: %s' "$1" "$rc" "$out")"; fi ;;
    *)
      got=$(printf '%s\n' "$out" | sed -n 's/^routing   : //p')
      if [ "$rc" = 0 ] && [ "$got" = "$3" ]
        then ok "$(printf '%-12s %s' "$1" "$got")"
        else bad "$(printf '%-12s exit %s, got [%s] want [%s]' "$1" "$rc" "$got" "$3")"; fi ;;
  esac
}

echo "the grammar"
check Full        '- [ ] T1 (model: sonnet, effort: high — ~90% mechanical) — sweep the renames.' \
                  'model sonnet, effort high'
check ModelOnly   '- [ ] T1 (model: opus) — a cross-cutting refactor.' \
                  'model opus, effort inherited'
check EffortOnly  '- [ ] T1 (effort: max) — think hard on the default tier.' \
                  'model inherited, effort max'
check NoAnnot     '- [ ] T1 — an unannotated task.' \
                  'model inherited, effort inherited'
check NoTaskId    '- [ ] (model: fable) — a task line with no id.' \
                  'model fable, effort inherited'

echo "the anchoring — the property the grammar exists for"
check ParenInBody '- [ ] T1 (model: haiku, effort: low — cheap) — rename `f(x)` to `g(x)` (everywhere).' \
                  'model haiku, effort low'
check ProseEffort '- [ ] T1 — decide whether effort: max is worth it for model: opus.' \
                  'model inherited, effort inherited'
check ReasonComma '- [ ] T1 (model: sonnet, effort: high — mechanical, mostly) — body.' \
                  'model sonnet, effort high'
check ReasonColon '- [ ] T1 (model: opus, effort: max — see AutonomousPipeline.md: the loop) — body.' \
                  'model opus, effort max'
check ReasonHyph  '- [ ] T1 (model: sonnet, effort: high - a plain hyphen reason) — body.' \
                  'model sonnet, effort high'

echo "a paren group with no field is not an annotation"
check HumanGate   '- [ ] T1 (human) — the operator rules on this one.' \
                  'model inherited, effort inherited'
check SessionTag  '- [ ] T1 (S2) — a paren group that is not routing.' \
                  'model inherited, effort inherited'

echo "fail closed — a typo must not route to the default"
check BadEffort   '- [ ] T1 (model: sonnet, effort: hgih) — body.' \
                  'DIE:is not one of low|medium|high|xhigh|max'
check BadKey      '- [ ] T1 (modle: sonnet) — body.' \
                  'DIE:unrecognised annotation field'
check BadKey2     '- [ ] T1 (model: sonnet, efort: high) — body.' \
                  'DIE:unrecognised annotation field'

echo "the driver's other reads of the same line are unaffected"
item Selection '- [ ] T7 (model: haiku, effort: high — bulk) — a body with (parens) and a `)`.'
TASK=$(awk '/^## Tasks/{t=1;next} /^### Done/{t=0;next} /^## /{t=0} t && /^- \[ \]/{print;exit}' Work/Active/Selection.md)
TID=$(echo "$TASK" | sed -n 's/^- \[ \] *\(T[0-9]*\).*/\1/p')
[ "$TID" = T7 ] && ok "TASK_ID      $TID" || bad "TASK_ID      got [$TID] want [T7]"
case "$TASK" in *"(human)"*) bad "human gate   matched a routed task" ;;
                          *) ok  "human gate   does not match a routed task" ;; esac
case '- [ ] T8 (human) — rule on the table.' in
  *"(human)"*) ok  "human gate   still matches (human)" ;;
            *) bad "human gate   missed (human)" ;; esac

# ── part 2: the spawn and the digest, against a stub `claude` ───────────────

STUBDIR=$(mktemp -d -t auto-run-stub); BIN="$STUBDIR/bin"
mkdir -p "$BIN"
cd "$STUBDIR" || exit 2
git init -q . && git config user.email t@t && git config user.name t

# Records its argv, then replays a run JSON shaped like the real one: the task's
# model carries cache tokens and the auxiliary haiku entry never does, which is
# the discriminator the digest relies on.
cat > "$BIN/claude" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$@" > "$ARGV_FILE"
cat <<JSON
{"is_error": false, "subtype": "success", "stop_reason": "end_turn",
 "terminal_reason": "completed", "num_turns": 12, "permission_denials": [],
 "total_cost_usd": 0.42,
 "usage": {"input_tokens": 30, "output_tokens": 900,
           "cache_creation_input_tokens": 14000, "cache_read_input_tokens": 990000},
 "modelUsage": {
   "claude-haiku-4-5-20251001": {"inputTokens": 900, "outputTokens": 40,
                                 "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0,
                                 "costUSD": 0.0009},
   "claude-sonnet-5": {"inputTokens": 30, "outputTokens": 900,
                       "cacheReadInputTokens": 990000, "cacheCreationInputTokens": 14000,
                       "costUSD": 0.42}}}
JSON
STUB
chmod +x "$BIN/claude"
export PATH="$BIN:$PATH" ARGV_FILE="$STUBDIR/argv.txt"

echo "the spawn — a routed task"
item Routed '- [ ] T1 (model: sonnet, effort: high — mechanical) — do the thing.'
bash "$DRIVER" Routed --max-tasks 1 >/dev/null 2>&1
ARGV=$(tr '\n' ' ' < "$ARGV_FILE")
want "--model passed"     "$ARGV" "--model sonnet"
want "--effort passed"    "$ARGV" "--effort high"
want "prompt still first" "$ARGV" "/computational-research:next-session Routed --output-format"
DIGEST=$(cat Work/Runs/*Routed.md)
want "digest names the model used"      "$DIGEST" 'model `claude-sonnet-5` (routed `sonnet`)'
want "digest says effort *requested*"   "$DIGEST" 'effort `high` requested'
want "escalation on a no-commit halt"   "$DIGEST" '**escalate?** T1 ran on `sonnet`'
want "escalation names the tier above"  "$DIGEST" '(model: opus, effort: high)'
want "stop reason"                      "$DIGEST" 'Stop reason | **no-commit**'
want "tokens still read from .usage"    "$DIGEST" 'Tokens in | 1004030 total = 30 uncached'

echo "the spawn — an unannotated task"
rm -rf Work/Runs; item Plain '- [ ] T1 — do the thing.'
bash "$DRIVER" Plain --max-tasks 1 >/dev/null 2>&1
ARGV=$(tr '\n' ' ' < "$ARGV_FILE")
wantnot "no --model when unannotated"  "$ARGV" "--model"
wantnot "no --effort when unannotated" "$ARGV" "--effort"
DIGEST=$(cat Work/Runs/*Plain.md)
want "digest says inherited"                   "$DIGEST" '(inherited), effort inherited'
want "escalation inferred from the model used" "$DIGEST" '**escalate?** T1 ran on `sonnet`'

echo "fail closed — the halt lands before the spawn"
rm -rf Work/Runs; rm -f "$ARGV_FILE"; item BadEffort '- [ ] T1 (model: sonnet, effort: hgih) — do the thing.'
bash "$DRIVER" BadEffort --max-tasks 1 >/dev/null 2>&1; RC=$?
[ "$RC" = 1 ] && ok "exit 1" || bad "exit $RC, want 1"
[ -e "$ARGV_FILE" ] && bad "spawned anyway" || ok "nothing was spawned"
DIGEST=$(cat Work/Runs/*BadEffort.md)
want "stop reason"     "$DIGEST" 'Stop reason | **bad-annotation**'
want "names the fault" "$DIGEST" "effort 'hgih' is not one of low|medium|high|xhigh|max"
want "no cost charged" "$DIGEST" 'Cost | $0.0000'

echo
echo "$PASS passed, $FAIL failed"
rm -rf "$WORK" "$STUBDIR"
[ "$FAIL" = 0 ]
