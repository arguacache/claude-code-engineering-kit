#!/usr/bin/env bash
# PostToolUse(Skill): touch a flag file once a db-* skill has been loaded.
# Fails OPEN (no jq / bad input => do nothing).
set -euo pipefail

command -v jq >/dev/null 2>&1 || exit 0
input="$(cat)"
skill="$(printf '%s' "$input" | jq -r '.tool_input.skill // .tool_input.name // empty' 2>/dev/null)" || exit 0

if printf '%s' "$skill" | grep -qE '(^|:)db-'; then
  dir="${CLAUDE_PROJECT_DIR:-.}/.claude/state"
  mkdir -p "$dir"
  touch "$dir/db-skill-loaded"
fi
exit 0
