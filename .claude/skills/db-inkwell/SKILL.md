---
name: db-inkwell
description: Load BEFORE writing or running any SQL against the Inkwell Books Postgres database. Provides the schema, amount scale (cents), and query rules. Required by the sql-write-gate hook for writes.
---

# db-inkwell

Invoking this skill unlocks SQL writes (the `db-skill-flag` hook records it). It exists so the
schema is in context before a query is written. Never guess column names.

## Workflow
1. Read `references/schema.md`. List the columns you will use in your reasoning.
2. Reads (SELECT) may run immediately.
3. Writes: dry-run first (`SELECT count(*)` plus a 5-row sample with the same WHERE), show it,
   then run the write inside an explicit `BEGIN ... COMMIT` (or `ROLLBACK` for a rehearsal).
4. Verify afterwards with a query that would look different if the write had failed.

## The amount scale trap
All money columns are integer **cents**. `order_items.unit_price = 1899` is $18.99.
Divide once, in SQL (`/ 100.0`), never again in prose. Reporting `1899` as "$1,899" is the
classic hallucination this skill exists to prevent.

## Rules
- Cancelled orders (`status = 'cancelled'`) are excluded from revenue unless asked.
- Cast ids explicitly (`'...'::uuid`) when comparing literals.
