---
name: feedback_dry_run_before_write
description: Preferred workflow for any data mutation: count, sample, show, then write in a transaction.
triggers: [update rows, bulk update, delete rows, data fix]
---
# Dry-run before write
Show `count(*)` and a 5-row sample with the same WHERE before the write, then use explicit
BEGIN/COMMIT, then verify with a query that would differ if the write had failed.
