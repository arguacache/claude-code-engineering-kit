# Rules in code vs rules in the prompt

A rule in `CLAUDE.md` is a request. A rule in a hook is a fact about the system. Pick by asking
one question: **what does it cost if the model ignores this once?**

## Put it in the prompt when
- Violation is cheap and visible (naming, tone, which library to prefer).
- The rule needs judgement ("keep PRs small") that a script cannot evaluate.
- It is guidance for a task type; conditional `<important if="...">` blocks keep it out of
  unrelated work.

## Put it in a hook when
- Violation is expensive or irreversible (a destructive write, a push of untested code).
- The condition is mechanical: a regex over the command, a file's mtime, a missing parameter.
- The prompt version has already failed once. A reminder that was ignored will be ignored again.

## Worked example 1: the SQL write gate
Prompt version: "load the schema skill before writing SQL." The model sometimes skips it and
guesses a column, or reports cents as dollars.

Hook version (`sql-write-gate.sh`): when a `psql` command contains INSERT, UPDATE, DELETE,
ALTER, DROP or TRUNCATE and `.claude/state/db-skill-loaded` does not exist, return
`permissionDecision: "deny"` with a reason that names the fix. A second hook
(`db-skill-flag.sh`) sets the flag when a `db-*` skill loads. SELECTs are never gated: the gate
adds friction only where the damage is.

## Worked example 2: the subagent model guard
Prompt version: "use cheap models for workers." A general-purpose subagent launched without
`model` silently inherits the expensive parent model; nothing fails, the bill just grows.

Hook version (`subagent-model-guard.sh`): deny when the type is general-purpose (or omitted)
and `model` is empty. The reason tells the model exactly what to pass. An explicit escape token
(`EXPENSIVE_OK`) keeps the rule from becoming a trap when the expensive model is the right call.

## Design rules for hooks
1. **Fail open.** A broken guard must not brick the session: missing `jq` or unparsable input
   means allow.
2. **Say how to fix it.** The deny reason is the model's only feedback; make it actionable.
3. **Use the right channel.** To block, print `permissionDecision: "deny"` JSON on stdout and
   exit 0. To warn, use `additionalContext`. stderr with exit 0 is invisible to the model.
4. **Always leave an escape hatch** for the legitimate exception, and make it explicit.
5. **Test the hooks.** They are code; `tests/run.sh` pipes sample payloads through each one.

## The principle
A permission isn't requested, it's removed. If a worker must not push, do not write "do not
push" in its prompt and hope: give it no tool that can. If a gate must hold, enforce it where
the model cannot talk its way around it. Prompts shape intent; code bounds behaviour.
