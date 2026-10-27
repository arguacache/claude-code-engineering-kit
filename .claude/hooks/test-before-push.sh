#!/usr/bin/env bash
# PreToolUse(Bash): on `git push`, require .claude/state/tests-passed to be newer
# than the latest commit. Your test runner should `touch` that file on success.
# Fails OPEN on missing jq / unparsable input / repo without commits.
set -euo pipefail

command -v jq >/dev/null 2>&1 || exit 0
input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)" || exit 0
printf '%s' "$cmd" | grep -qE '(^|[;&|[:space:]])git[[:space:]]+push([[:space:]]|$)' || exit 0

root="${CLAUDE_PROJECT_DIR:-.}"
commit_ts="$(git -C "$root" log -1 --format=%ct 2>/dev/null || true)"
[ -n "$commit_ts" ] || exit 0

marker="$root/.claude/state/tests-passed"
marker_ts=0
if [ -e "$marker" ]; then
  # BSD stat (macOS) first, then GNU stat (Linux).
  marker_ts="$(stat -f %m "$marker" 2>/dev/null || stat -c %Y "$marker" 2>/dev/null || echo 0)"
fi

if [ "$marker_ts" -le "$commit_ts" ]; then
  jq -nc --arg reason "git push blocked: no passing test run since the latest commit. Run the test suite, then touch .claude/state/tests-passed." \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$reason}}'
fi
exit 0
