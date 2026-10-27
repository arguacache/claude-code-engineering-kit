# CLAUDE.md: Inkwell Books (example)

Online bookstore backend: orders, inventory, customers. Postgres. This file demonstrates
conditional blocks: each `<important if="...">` applies only when its condition is true,
which keeps the always-on part short.

## Project map
| Area | Path |
|---|---|
| API | `services/api/` |
| Migrations | `db/migrations/` |
| Inventory MCP server | `mcp/inventory-server/` |

<important if="you are about to write a migration (ALTER TABLE, CREATE TABLE, new column)">

- Migrations live ONLY in `db/migrations/`, as `<timestamp>_<name>.up.sql` and `.down.sql`.
- The schema doc `.claude/skills/db-inkwell/references/schema.md` changes in the same PR.
- Never edit an already-applied migration; add a new one.

</important>

<important if="you are about to write or run SQL">

- Load the `db-inkwell` skill first (writes are blocked by a hook until you do).
- Money is integer cents. Divide by 100.0 once, in SQL.
- Writes: dry-run (count + sample), explicit BEGIN/COMMIT, verify afterwards.

</important>

<important if="you are about to open a pull request or push">

- Branch from the latest `origin/main`; never commit on `main`.
- Run the full test suite, then `touch .claude/state/tests-passed` (the push hook checks it).
- One PR per feature per service; title under 70 chars.

</important>

<important if="the task spans more than one service or more than three files">

State a plan in 3-5 bullets (affected services, approach, what will be tested) before editing.
Wait for approval.

</important>

<important if="you are about to do substantial investigation, review or implementation">

Orchestration: the expensive model plans, decides and verifies; cheap models execute.
- Delegate search to `code-finder` (haiku) and implementation to `implementer` (sonnet).
- Every worker spec states goal, exact paths, what NOT to touch, and output format.
- Independent workstreams run in parallel in one message.
- Verify load-bearing claims from workers yourself; the doer is not the grader.

</important>
