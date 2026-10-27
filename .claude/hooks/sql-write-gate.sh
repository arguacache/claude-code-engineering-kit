#!/usr/bin/env bash
# PreToolUse(Bash): block SQL writes via psql until the DB skill has been loaded.
# SELECTs pass untouched. Fails OPEN: a broken guard must never brick the session,
# so a missing jq or unparsable input means "allow".
set -euo pipefail

command -v jq >/dev/null 2>&1 || exit 0
input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)" || exit 0
[ -n "$cmd" ] || exit 0

# Only care about psql invocations that contain a write/DDL keyword.
printf '%s' "$cmd" | grep -qiE '(^|[^a-z_])psql([^a-z_]|$)' || exit 0
printf '%s' "$cmd" | grep -qiE '\b(insert[[:space:]]+into|update[[:space:]]+[a-z_."]+[[:space:]]+set|delete[[:space:]]+from|alter[[:space:]]+table|drop[[:space:]]+(table|index|column|schema)|truncate)\b' || exit 0

[ -e "${CLAUDE_PROJECT_DIR:-.}/.claude/state/db-skill-loaded" ] && exit 0

jq -nc --arg reason "SQL write/DDL blocked: load the db-inkwell skill first (Skill tool) so the schema and amount scale (cents) are in context. SELECT queries are not gated." \
  '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$reason}}'
exit 0
