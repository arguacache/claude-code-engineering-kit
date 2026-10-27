#!/usr/bin/env bash
# PreToolUse(Agent): a general-purpose subagent launched without an explicit model
# silently inherits the parent's (expensive) model. Block it; require a choice.
# Escape hatch: put EXPENSIVE_OK in the prompt. Fails OPEN on missing jq / bad input.
set -euo pipefail

command -v jq >/dev/null 2>&1 || exit 0
input="$(cat)"
parsed="$(printf '%s' "$input" | jq -r '[(.tool_input.subagent_type // ""), (.tool_input.model // ""), (.tool_input.prompt // "")] | @json' 2>/dev/null)" || exit 0
type="$(printf '%s' "$parsed" | jq -r '.[0]')"
model="$(printf '%s' "$parsed" | jq -r '.[1]')"
prompt="$(printf '%s' "$parsed" | jq -r '.[2]')"

{ [ -z "$type" ] || [ "$type" = "general-purpose" ]; } || exit 0
[ -z "$model" ] || exit 0
case "$prompt" in *EXPENSIVE_OK*) exit 0 ;; esac

jq -nc --arg reason "general-purpose subagent without an explicit model would inherit the expensive parent model. Pass model: \"sonnet\" or \"haiku\", use a specialised agent, or add EXPENSIVE_OK to the prompt if the task truly needs it." \
  '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$reason}}'
exit 0
