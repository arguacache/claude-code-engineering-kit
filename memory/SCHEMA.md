# Memory schema

A layered knowledge base of small markdown files. Each file has frontmatter so a script
(and a retrieval hook) can route to it by trigger phrase without loading everything.

## Tiers
| Tier | Prefix | Holds | Expires |
|---|---|---|---|
| gold | `rules_`, `reference_` | Canonical rules and reference facts. Verified. | No |
| silver | `lesson_`, `feedback_` | Distilled lessons and working preferences. | No |
| bronze | `fix_`, `project_`, `discovery_` | Raw notes: a specific fix, a project log. | Yes, once distilled |

## Frontmatter
```yaml
---
name: short_unique_name
description: One line saying when this applies.
triggers: [phrase one, phrase two]
pin: true        # optional: never dropped from the index by the size cap
---
```

## Promotion flow
1. A fix or discovery is written to **bronze** while it is fresh.
2. When the same shape of problem recurs, or the task closes, distil it into a **silver**
   lesson (what happened, the rule, how to recognise it).
3. A silver lesson that proved right repeatedly and is stated as a rule becomes **gold**.
4. The bronze source is deleted or archived once its lesson exists.

## Index
`python3 scripts/build-memory-index.py` writes `memory/INDEX.md`, a trigger-to-file table.
It is capped in size so it can be auto-loaded; `pin: true` entries are never dropped,
then gold outranks silver outranks bronze when space runs out.
