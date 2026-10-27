# Claude Code Engineering Kit

A small, working reference of senior-level patterns for engineering with Claude Code, built
around a fictional online bookstore ("Inkwell Books": orders, inventory, customers, Postgres).
Everything here is original and runnable; the smoke tests prove the hooks behave.

## Philosophy
- **A permission isn't requested, it's removed.** Hard rules live in hooks, not prose.
- **Expensive model orchestrates, cheap model executes.** Specs in, conclusions out.
- **Fail open, explain closed.** A broken guard never bricks the session; a deny always says how to fix it.
- **Context is a budget.** Conditional instructions and a capped, trigger-routed memory index.
- **The doer is not the grader.** Verify load-bearing claims from workers yourself.

## Patterns

| Pattern | Where | What it shows |
|---|---|---|
| SQL write gate | [`sql-write-gate.sh`](.claude/hooks/sql-write-gate.sh), [`db-skill-flag.sh`](.claude/hooks/db-skill-flag.sh) | Writes blocked until the schema skill is loaded; SELECT untouched |
| Test-before-push | [`test-before-push.sh`](.claude/hooks/test-before-push.sh) | Push blocked unless tests passed after the last commit (mtime check) |
| Injection guard | [`web-content-guard.sh`](.claude/hooks/web-content-guard.sh) | Fetched content scanned; model told to treat it as data |
| Subagent cost guard | [`subagent-model-guard.sh`](.claude/hooks/subagent-model-guard.sh) | No silent inheritance of the expensive model; explicit escape token |
| Task-based agents | [`code-finder`](.claude/agents/code-finder.md), [`implementer`](.claude/agents/implementer.md) | Model tiering via frontmatter; spec-driven worker that never commits |
| Gated skill | [`db-inkwell`](.claude/skills/db-inkwell/SKILL.md) | Schema reference plus the "amount scale" (cents) hallucination trap |
| Conditional instructions | [`CLAUDE.md`](CLAUDE.md) | `<important if="...">` blocks keep always-on context small |
| Layered memory | [`memory/`](memory/SCHEMA.md), [`build-memory-index.py`](scripts/build-memory-index.py) | Gold/silver/bronze tiers, trigger index with size cap and `pin: true` |
| MCP server | [`mcp/inventory-server/`](mcp/inventory-server/README.md) | FastMCP tools over a SQLite fixture; `.mcp.json` included |
| Design essay | [`docs/rules-in-code-vs-prompt.md`](docs/rules-in-code-vs-prompt.md) | When a rule belongs in a hook vs the prompt |
| Tests | [`tests/run.sh`](tests/run.sh) | Hook payloads piped in, deny/allow asserted |

## Hook output contract

Get this right or the hook silently does nothing.

- **Block** a PreToolUse: print JSON on stdout and exit 0.
  ```json
  {"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"..."}}
  ```
- **Warn** without blocking: print `{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"..."}}`.
- **stderr with exit 0 is invisible to the model.** Warnings must go through `additionalContext`.
- Scripts depend only on bash + jq and fail open if jq is missing or input is unparsable.

Registration (`.claude/settings.json`):
```json
{"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/sql-write-gate.sh"}]}]}}
```

## How to try it

```bash
bash tests/run.sh                      # smoke tests (needs bash, jq, python3)
python3 scripts/build-memory-index.py  # regenerate memory/INDEX.md
```

To use the patterns in a project: copy `.claude/` (and optionally `CLAUDE.md`, `memory/`,
`scripts/`) into it, keep the hook scripts executable, and adapt the `db-inkwell` skill to
your schema. The push gate expects your test runner to `touch .claude/state/tests-passed`
on success. For the MCP server see [`mcp/inventory-server/README.md`](mcp/inventory-server/README.md).

---

© 2026 Angel Guacache. All rights reserved. Shared for portfolio review; no license is granted for reuse.
